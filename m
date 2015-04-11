From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 02/17] fuse: handle synchronous iocbs internally
Date: Sat, 11 Apr 2015 22:18:13 +0100
Message-ID: <1428787108-13650-2-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37860 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbbDKVS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:29 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>

Based on a patch from Maxim Patlasov <MPatlasov@parallels.com>.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/fuse/file.c   | 51 +++++++++++++++++++++++++++++++--------------------
 fs/fuse/fuse_i.h |  1 +
 2 files changed, 32 insertions(+), 20 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index c01ec3b..f81d83e 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -528,6 +528,17 @@ static void fuse_release_user_pages(struct fuse_req *req, int write)
 	}
 }
 
+static ssize_t fuse_get_res_by_io(struct fuse_io_priv *io)
+{
+	if (io->err)
+		return io->err;
+
+	if (io->bytes >= 0 && io->write)
+		return -EIO;
+
+	return io->bytes < 0 ? io->size : io->bytes;
+}
+
 /**
  * In case of short read, the caller sets 'pos' to the position of
  * actual end of fuse request in IO request. Otherwise, if bytes_requested
@@ -546,6 +557,7 @@ static void fuse_release_user_pages(struct fuse_req *req, int write)
  */
 static void fuse_aio_complete(struct fuse_io_priv *io, int err, ssize_t pos)
 {
+	bool is_sync = is_sync_kiocb(io->iocb);
 	int left;
 
 	spin_lock(&io->lock);
@@ -555,27 +567,21 @@ static void fuse_aio_complete(struct fuse_io_priv *io, int err, ssize_t pos)
 		io->bytes = pos;
 
 	left = --io->reqs;
+	if (!left && is_sync)
+		complete(io->done);
 	spin_unlock(&io->lock);
 
-	if (!left) {
-		long res;
+	if (!left && !is_sync) {
+		ssize_t res = fuse_get_res_by_io(io);
 
-		if (io->err)
-			res = io->err;
-		else if (io->bytes >= 0 && io->write)
-			res = -EIO;
-		else {
-			res = io->bytes < 0 ? io->size : io->bytes;
+		if (res >= 0) {
+			struct inode *inode = file_inode(io->iocb->ki_filp);
+			struct fuse_conn *fc = get_fuse_conn(inode);
+			struct fuse_inode *fi = get_fuse_inode(inode);
 
-			if (!is_sync_kiocb(io->iocb)) {
-				struct inode *inode = file_inode(io->iocb->ki_filp);
-				struct fuse_conn *fc = get_fuse_conn(inode);
-				struct fuse_inode *fi = get_fuse_inode(inode);
-
-				spin_lock(&fc->lock);
-				fi->attr_version = ++fc->attr_version;
-				spin_unlock(&fc->lock);
-			}
+			spin_lock(&fc->lock);
+			fi->attr_version = ++fc->attr_version;
+			spin_unlock(&fc->lock);
 		}
 
 		aio_complete(io->iocb, res, 0);
@@ -2801,6 +2807,7 @@ static ssize_t
 fuse_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter,
 			loff_t offset)
 {
+	DECLARE_COMPLETION_ONSTACK(wait);
 	ssize_t ret = 0;
 	struct file *file = iocb->ki_filp;
 	struct fuse_file *ff = file->private_data;
@@ -2852,6 +2859,9 @@ fuse_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter,
 	if (!is_sync_kiocb(iocb) && (offset + count > i_size) && rw == WRITE)
 		io->async = false;
 
+	if (io->async && is_sync_kiocb(iocb))
+		io->done = &wait;
+
 	if (rw == WRITE)
 		ret = __fuse_direct_write(io, iter, &pos);
 	else
@@ -2864,11 +2874,12 @@ fuse_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter,
 		if (!is_sync_kiocb(iocb))
 			return -EIOCBQUEUED;
 
-		ret = wait_on_sync_kiocb(iocb);
-	} else {
-		kfree(io);
+		wait_for_completion(&wait);
+		ret = fuse_get_res_by_io(io);
 	}
 
+	kfree(io);
+
 	if (rw == WRITE) {
 		if (ret > 0)
 			fuse_write_update_size(inode, pos);
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index 1cdfb07..7354dc1 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -263,6 +263,7 @@ struct fuse_io_priv {
 	int err;
 	struct kiocb *iocb;
 	struct file *file;
+	struct completion *done;
 };
 
 /**
-- 
2.1.4
