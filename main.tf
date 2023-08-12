# creating s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# taking the control of the bucket
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# enabling the public access for our bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# enabling the upload of static website
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}

# adding objects to the s3 bucket
resource "aws_s3_object" "index" {
    bucket = aws_s3_bucket.bucket.id
    key = "index.html"
    source = "index.html"
    acl = "public-read"
    content_type = "text/html"
}

resource "aws_s3_object" "error" {
    bucket = aws_s3_bucket.bucket.id
    key = "error.html"
    source = "error.html"
    acl = "public-read"
    content_type = "text/html"
}

resource "aws_s3_object" "profile" {
    bucket = aws_s3_bucket.bucket.id
    key = "profile.avif"
    source = "profile.avif"
    acl = "public-read"
    content_type = "text/html"
}

# configuring our website
resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.bucket.id
    index_document {
      suffix = "index.html"
    }

    error_document {
      key = "error.html"
    }

    depends_on = [ aws_s3_bucket_acl.example ]
}

# creating github repo for this project
resource "github_repository" "practice_tera_project" {
  name        = "practice_tera_project"
  description = "Creating a project for practicing terraform"

  visibility = "public"
}

resource "github_repository_project" "project" {
  name       = "A Repository Project"
  repository = "${github_repository.practice_tera_project.name}"
  body       = "This is a repository project."
}

resource "github_repository_file" "practice_tera_project" {
  repository          = github_repository.practice_tera_project.name
  branch              = "main"
  file                = "main.tf"
  content             = "**/*.tfstate"
}