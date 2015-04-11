From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 01/17] fs: remove ki_nbytes
Date: Sat, 11 Apr 2015 22:18:12 +0100
Message-ID: <1428787108-13650-1-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37857 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153AbbDKVS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:29 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>

There is no need to pass the total request length in the kiocb, as
we already get passed in through the iov_iter argument.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/aio.c               | 34 ++++++++++++++++++----------------
 fs/ceph/file.c         |  2 +-
 fs/nfs/direct.c        |  2 +-
 fs/ocfs2/file.c        |  8 +++-----
 fs/read_write.c        |  8 --------
 fs/udf/file.c          |  2 +-
 include/linux/aio.h    |  1 -
 kernel/printk/printk.c |  2 +-
 mm/page_io.c           |  1 -
 net/socket.c           |  6 +++---
 10 files changed, 28 insertions(+), 38 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 118a2e0..667054c 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1344,12 +1344,13 @@ typedef ssize_t (rw_iter_op)(struct kiocb *, struct iov_iter *);
 static ssize_t aio_setup_vectored_rw(struct kiocb *kiocb,
 				     int rw, char __user *buf,
 				     unsigned long *nr_segs,
+				     size_t *len,
 				     struct iovec **iovec,
 				     bool compat)
 {
 	ssize_t ret;
 
-	*nr_segs = kiocb->ki_nbytes;
+	*nr_segs = *len;
 
 #ifdef CONFIG_COMPAT
 	if (compat)
@@ -1364,21 +1365,22 @@ static ssize_t aio_setup_vectored_rw(struct kiocb *kiocb,
 	if (ret < 0)
 		return ret;
 
-	/* ki_nbytes now reflect bytes instead of segs */
-	kiocb->ki_nbytes = ret;
+	/* len now reflect bytes instead of segs */
+	*len = ret;
 	return 0;
 }
 
 static ssize_t aio_setup_single_vector(struct kiocb *kiocb,
 				       int rw, char __user *buf,
 				       unsigned long *nr_segs,
+				       size_t len,
 				       struct iovec *iovec)
 {
-	if (unlikely(!access_ok(!rw, buf, kiocb->ki_nbytes)))
+	if (unlikely(!access_ok(!rw, buf, len)))
 		return -EFAULT;
 
 	iovec->iov_base = buf;
-	iovec->iov_len = kiocb->ki_nbytes;
+	iovec->iov_len = len;
 	*nr_segs = 1;
 	return 0;
 }
@@ -1388,7 +1390,7 @@ static ssize_t aio_setup_single_vector(struct kiocb *kiocb,
  *	Performs the initial checks and io submission.
  */
 static ssize_t aio_run_iocb(struct kiocb *req, unsigned opcode,
-			    char __user *buf, bool compat)
+			    char __user *buf, size_t len, bool compat)
 {
 	struct file *file = req->ki_filp;
 	ssize_t ret;
@@ -1423,21 +1425,21 @@ rw_common:
 		if (!rw_op && !iter_op)
 			return -EINVAL;
 
-		ret = (opcode == IOCB_CMD_PREADV ||
-		       opcode == IOCB_CMD_PWRITEV)
-			? aio_setup_vectored_rw(req, rw, buf, &nr_segs,
-						&iovec, compat)
-			: aio_setup_single_vector(req, rw, buf, &nr_segs,
-						  iovec);
+		if (opcode == IOCB_CMD_PREADV || opcode == IOCB_CMD_PWRITEV)
+			ret = aio_setup_vectored_rw(req, rw, buf, &nr_segs,
+						&len, &iovec, compat);
+		else
+			ret = aio_setup_single_vector(req, rw, buf, &nr_segs,
+						  len, iovec);
 		if (!ret)
-			ret = rw_verify_area(rw, file, &req->ki_pos, req->ki_nbytes);
+			ret = rw_verify_area(rw, file, &req->ki_pos, len);
 		if (ret < 0) {
 			if (iovec != inline_vecs)
 				kfree(iovec);
 			return ret;
 		}
 
-		req->ki_nbytes = ret;
+		len = ret;
 
 		/* XXX: move/kill - rw_verify_area()? */
 		/* This matches the pread()/pwrite() logic */
@@ -1450,7 +1452,7 @@ rw_common:
 			file_start_write(file);
 
 		if (iter_op) {
-			iov_iter_init(&iter, rw, iovec, nr_segs, req->ki_nbytes);
+			iov_iter_init(&iter, rw, iovec, nr_segs, len);
 			ret = iter_op(req, &iter);
 		} else {
 			ret = rw_op(req, iovec, nr_segs, req->ki_pos);
@@ -1553,10 +1555,10 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	req->ki_obj.user = user_iocb;
 	req->ki_user_data = iocb->aio_data;
 	req->ki_pos = iocb->aio_offset;
-	req->ki_nbytes = iocb->aio_nbytes;
 
 	ret = aio_run_iocb(req, iocb->aio_lio_opcode,
 			   (char __user *)(unsigned long)iocb->aio_buf,
+			   iocb->aio_nbytes,
 			   compat);
 	if (ret)
 		goto out_put_req;
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 905986d..081c4e3 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -807,7 +807,7 @@ static ssize_t ceph_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct file *filp = iocb->ki_filp;
 	struct ceph_file_info *fi = filp->private_data;
-	size_t len = iocb->ki_nbytes;
+	size_t len = iov_iter_count(to);
 	struct inode *inode = file_inode(filp);
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct page *pinned_page = NULL;
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 7077521..27cebf1 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -265,7 +265,7 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter, loff_t
 
 	return -EINVAL;
 #else
-	VM_BUG_ON(iocb->ki_nbytes != PAGE_SIZE);
+	VM_BUG_ON(iov_iter_count(iter) != PAGE_SIZE);
 
 	if (rw == READ)
 		return nfs_file_direct_read(iocb, iter, pos);
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 46e0d4e..266845d 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2280,7 +2280,7 @@ static ssize_t ocfs2_file_write_iter(struct kiocb *iocb,
 		file->f_path.dentry->d_name.name,
 		(unsigned int)from->nr_segs);	/* GRRRRR */
 
-	if (iocb->ki_nbytes == 0)
+	if (count == 0)
 		return 0;
 
 	appending = file->f_flags & O_APPEND ? 1 : 0;
@@ -2330,8 +2330,7 @@ relock:
 	}
 
 	can_do_direct = direct_io;
-	ret = ocfs2_prepare_inode_for_write(file, ppos,
-					    iocb->ki_nbytes, appending,
+	ret = ocfs2_prepare_inode_for_write(file, ppos, count, appending,
 					    &can_do_direct, &has_refcount);
 	if (ret < 0) {
 		mlog_errno(ret);
@@ -2339,8 +2338,7 @@ relock:
 	}
 
 	if (direct_io && !is_sync_kiocb(iocb))
-		unaligned_dio = ocfs2_is_io_unaligned(inode, iocb->ki_nbytes,
-						      *ppos);
+		unaligned_dio = ocfs2_is_io_unaligned(inode, count, *ppos);
 
 	/*
 	 * We can't complete the direct I/O as requested, fall back to
diff --git a/fs/read_write.c b/fs/read_write.c
index 8e1b687..f8b8fc1 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -343,7 +343,6 @@ ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos)
 
 	init_sync_kiocb(&kiocb, file);
 	kiocb.ki_pos = *ppos;
-	kiocb.ki_nbytes = iov_iter_count(iter);
 
 	iter->type |= READ;
 	ret = file->f_op->read_iter(&kiocb, iter);
@@ -366,7 +365,6 @@ ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos)
 
 	init_sync_kiocb(&kiocb, file);
 	kiocb.ki_pos = *ppos;
-	kiocb.ki_nbytes = iov_iter_count(iter);
 
 	iter->type |= WRITE;
 	ret = file->f_op->write_iter(&kiocb, iter);
@@ -426,7 +424,6 @@ ssize_t do_sync_read(struct file *filp, char __user *buf, size_t len, loff_t *pp
 
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
-	kiocb.ki_nbytes = len;
 
 	ret = filp->f_op->aio_read(&kiocb, &iov, 1, kiocb.ki_pos);
 	if (-EIOCBQUEUED == ret)
@@ -446,7 +443,6 @@ ssize_t new_sync_read(struct file *filp, char __user *buf, size_t len, loff_t *p
 
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
-	kiocb.ki_nbytes = len;
 	iov_iter_init(&iter, READ, &iov, 1, len);
 
 	ret = filp->f_op->read_iter(&kiocb, &iter);
@@ -510,7 +506,6 @@ ssize_t do_sync_write(struct file *filp, const char __user *buf, size_t len, lof
 
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
-	kiocb.ki_nbytes = len;
 
 	ret = filp->f_op->aio_write(&kiocb, &iov, 1, kiocb.ki_pos);
 	if (-EIOCBQUEUED == ret)
@@ -530,7 +525,6 @@ ssize_t new_sync_write(struct file *filp, const char __user *buf, size_t len, lo
 
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
-	kiocb.ki_nbytes = len;
 	iov_iter_init(&iter, WRITE, &iov, 1, len);
 
 	ret = filp->f_op->write_iter(&kiocb, &iter);
@@ -719,7 +713,6 @@ static ssize_t do_iter_readv_writev(struct file *filp, int rw, const struct iove
 
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
-	kiocb.ki_nbytes = len;
 
 	iov_iter_init(&iter, rw, iov, nr_segs, len);
 	ret = fn(&kiocb, &iter);
@@ -737,7 +730,6 @@ static ssize_t do_sync_readv_writev(struct file *filp, const struct iovec *iov,
 
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
-	kiocb.ki_nbytes = len;
 
 	ret = fn(&kiocb, iov, nr_segs, kiocb.ki_pos);
 	if (ret == -EIOCBQUEUED)
diff --git a/fs/udf/file.c b/fs/udf/file.c
index 08f3555..9c0b6da 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -122,7 +122,7 @@ static ssize_t udf_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file_inode(file);
 	int err, pos;
-	size_t count = iocb->ki_nbytes;
+	size_t count = iov_iter_count(from);
 	struct udf_inode_info *iinfo = UDF_I(inode);
 
 	mutex_lock(&inode->i_mutex);
diff --git a/include/linux/aio.h b/include/linux/aio.h
index d9c92da..132d1ec 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -42,7 +42,6 @@ struct kiocb {
 
 	__u64			ki_user_data;	/* user's data for completion */
 	loff_t			ki_pos;
-	size_t			ki_nbytes;	/* copy of iocb->aio_nbytes */
 
 	struct list_head	ki_list;	/* the aio core uses this
 						 * for cancellation */
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index c06df7d..60b2aa2 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -521,7 +521,7 @@ static ssize_t devkmsg_write(struct kiocb *iocb, struct iov_iter *from)
 	int i;
 	int level = default_message_loglevel;
 	int facility = 1;	/* LOG_USER */
-	size_t len = iocb->ki_nbytes;
+	size_t len = iov_iter_count(from);
 	ssize_t ret = len;
 
 	if (len > LOG_LINE_MAX)
diff --git a/mm/page_io.c b/mm/page_io.c
index e604580..7ef2157 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -274,7 +274,6 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		iov_iter_bvec(&from, ITER_BVEC | WRITE, &bv, 1, PAGE_SIZE);
 		init_sync_kiocb(&kiocb, swap_file);
 		kiocb.ki_pos = page_file_offset(page);
-		kiocb.ki_nbytes = PAGE_SIZE;
 
 		set_page_writeback(page);
 		unlock_page(page);
diff --git a/net/socket.c b/net/socket.c
index bbedbfc..f921455 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -858,11 +858,11 @@ static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (iocb->ki_pos != 0)
 		return -ESPIPE;
 
-	if (iocb->ki_nbytes == 0)	/* Match SYS5 behaviour */
+	if (!iov_iter_count(to))	/* Match SYS5 behaviour */
 		return 0;
 
 	res = __sock_recvmsg(iocb, sock, &msg,
-			     iocb->ki_nbytes, msg.msg_flags);
+			     iov_iter_count(to), msg.msg_flags);
 	*to = msg.msg_iter;
 	return res;
 }
@@ -883,7 +883,7 @@ static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (sock->type == SOCK_SEQPACKET)
 		msg.msg_flags |= MSG_EOR;
 
-	res = __sock_sendmsg(iocb, sock, &msg, iocb->ki_nbytes);
+	res = __sock_sendmsg(iocb, sock, &msg, iov_iter_count(from));
 	*from = msg.msg_iter;
 	return res;
 }
-- 
2.1.4
