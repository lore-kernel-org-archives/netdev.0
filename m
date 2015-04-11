From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 03/17] fs: don't allow to complete sync iocbs through aio_complete
Date: Sat, 11 Apr 2015 22:18:14 +0100
Message-ID: <1428787108-13650-3-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37862 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbbDKVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:30 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>

The AIO interface is fairly complex because it tries to allow
filesystems to always work async and then wakeup a synchronous
caller through aio_complete.  It turns out that basically no one
was doing this to avoid the complexity and context switches,
and we've already fixed up the remaining users and can now
get rid of this case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/aio.c            | 24 +-----------------------
 fs/ecryptfs/file.c  |  6 ------
 fs/read_write.c     | 26 ++++++++------------------
 include/linux/aio.h |  4 ----
 net/socket.c        |  9 +++------
 5 files changed, 12 insertions(+), 57 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 667054c..8ca8df1 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -778,22 +778,6 @@ static int kill_ioctx(struct mm_struct *mm, struct kioctx *ctx,
 	return 0;
 }
 
-/* wait_on_sync_kiocb:
- *	Waits on the given sync kiocb to complete.
- */
-ssize_t wait_on_sync_kiocb(struct kiocb *req)
-{
-	while (!req->ki_ctx) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		if (req->ki_ctx)
-			break;
-		io_schedule();
-	}
-	__set_current_state(TASK_RUNNING);
-	return req->ki_user_data;
-}
-EXPORT_SYMBOL(wait_on_sync_kiocb);
-
 /*
  * exit_aio: called when the last user of mm goes away.  At this point, there is
  * no way for any new requests to be submited or any of the io_* syscalls to be
@@ -1025,13 +1009,7 @@ void aio_complete(struct kiocb *iocb, long res, long res2)
 	 *    ref, no other paths have a way to get another ref
 	 *  - the sync task helpfully left a reference to itself in the iocb
 	 */
-	if (is_sync_kiocb(iocb)) {
-		iocb->ki_user_data = res;
-		smp_wmb();
-		iocb->ki_ctx = ERR_PTR(-EXDEV);
-		wake_up_process(iocb->ki_obj.tsk);
-		return;
-	}
+	BUG_ON(is_sync_kiocb(iocb));
 
 	if (iocb->ki_list.next) {
 		unsigned long flags;
diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
index 6f4e659..a36da88 100644
--- a/fs/ecryptfs/file.c
+++ b/fs/ecryptfs/file.c
@@ -52,12 +52,6 @@ static ssize_t ecryptfs_read_update_atime(struct kiocb *iocb,
 	struct file *file = iocb->ki_filp;
 
 	rc = generic_file_read_iter(iocb, to);
-	/*
-	 * Even though this is a async interface, we need to wait
-	 * for IO to finish to update atime
-	 */
-	if (-EIOCBQUEUED == rc)
-		rc = wait_on_sync_kiocb(iocb);
 	if (rc >= 0) {
 		path = ecryptfs_dentry_to_lower_path(file->f_path.dentry);
 		touch_atime(path);
diff --git a/fs/read_write.c b/fs/read_write.c
index f8b8fc1..76e324e 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -346,9 +346,7 @@ ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos)
 
 	iter->type |= READ;
 	ret = file->f_op->read_iter(&kiocb, iter);
-	if (ret == -EIOCBQUEUED)
-		ret = wait_on_sync_kiocb(&kiocb);
-
+	BUG_ON(ret == -EIOCBQUEUED);
 	if (ret > 0)
 		*ppos = kiocb.ki_pos;
 	return ret;
@@ -368,9 +366,7 @@ ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos)
 
 	iter->type |= WRITE;
 	ret = file->f_op->write_iter(&kiocb, iter);
-	if (ret == -EIOCBQUEUED)
-		ret = wait_on_sync_kiocb(&kiocb);
-
+	BUG_ON(ret == -EIOCBQUEUED);
 	if (ret > 0)
 		*ppos = kiocb.ki_pos;
 	return ret;
@@ -426,8 +422,7 @@ ssize_t do_sync_read(struct file *filp, char __user *buf, size_t len, loff_t *pp
 	kiocb.ki_pos = *ppos;
 
 	ret = filp->f_op->aio_read(&kiocb, &iov, 1, kiocb.ki_pos);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&kiocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	*ppos = kiocb.ki_pos;
 	return ret;
 }
@@ -446,8 +441,7 @@ ssize_t new_sync_read(struct file *filp, char __user *buf, size_t len, loff_t *p
 	iov_iter_init(&iter, READ, &iov, 1, len);
 
 	ret = filp->f_op->read_iter(&kiocb, &iter);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&kiocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	*ppos = kiocb.ki_pos;
 	return ret;
 }
@@ -508,8 +502,7 @@ ssize_t do_sync_write(struct file *filp, const char __user *buf, size_t len, lof
 	kiocb.ki_pos = *ppos;
 
 	ret = filp->f_op->aio_write(&kiocb, &iov, 1, kiocb.ki_pos);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&kiocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	*ppos = kiocb.ki_pos;
 	return ret;
 }
@@ -528,8 +521,7 @@ ssize_t new_sync_write(struct file *filp, const char __user *buf, size_t len, lo
 	iov_iter_init(&iter, WRITE, &iov, 1, len);
 
 	ret = filp->f_op->write_iter(&kiocb, &iter);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&kiocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	*ppos = kiocb.ki_pos;
 	return ret;
 }
@@ -716,8 +708,7 @@ static ssize_t do_iter_readv_writev(struct file *filp, int rw, const struct iove
 
 	iov_iter_init(&iter, rw, iov, nr_segs, len);
 	ret = fn(&kiocb, &iter);
-	if (ret == -EIOCBQUEUED)
-		ret = wait_on_sync_kiocb(&kiocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	*ppos = kiocb.ki_pos;
 	return ret;
 }
@@ -732,8 +723,7 @@ static ssize_t do_sync_readv_writev(struct file *filp, const struct iovec *iov,
 	kiocb.ki_pos = *ppos;
 
 	ret = fn(&kiocb, iov, nr_segs, kiocb.ki_pos);
-	if (ret == -EIOCBQUEUED)
-		ret = wait_on_sync_kiocb(&kiocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	*ppos = kiocb.ki_pos;
 	return ret;
 }
diff --git a/include/linux/aio.h b/include/linux/aio.h
index 132d1ec..f851643 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -37,7 +37,6 @@ struct kiocb {
 
 	union {
 		void __user		*user;
-		struct task_struct	*tsk;
 	} ki_obj;
 
 	__u64			ki_user_data;	/* user's data for completion */
@@ -63,13 +62,11 @@ static inline void init_sync_kiocb(struct kiocb *kiocb, struct file *filp)
 	*kiocb = (struct kiocb) {
 			.ki_ctx = NULL,
 			.ki_filp = filp,
-			.ki_obj.tsk = current,
 		};
 }
 
 /* prototypes */
 #ifdef CONFIG_AIO
-extern ssize_t wait_on_sync_kiocb(struct kiocb *iocb);
 extern void aio_complete(struct kiocb *iocb, long res, long res2);
 struct mm_struct;
 extern void exit_aio(struct mm_struct *mm);
@@ -77,7 +74,6 @@ extern long do_io_submit(aio_context_t ctx_id, long nr,
 			 struct iocb __user *__user *iocbpp, bool compat);
 void kiocb_set_cancel_fn(struct kiocb *req, kiocb_cancel_fn *cancel);
 #else
-static inline ssize_t wait_on_sync_kiocb(struct kiocb *iocb) { return 0; }
 static inline void aio_complete(struct kiocb *iocb, long res, long res2) { }
 struct mm_struct;
 static inline void exit_aio(struct mm_struct *mm) { }
diff --git a/net/socket.c b/net/socket.c
index f921455..f6c519d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -633,8 +633,7 @@ static int do_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 	init_sync_kiocb(&iocb, NULL);
 	ret = nosec ? __sock_sendmsg_nosec(&iocb, sock, msg, size) :
 		      __sock_sendmsg(&iocb, sock, msg, size);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&iocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	return ret;
 }
 
@@ -766,8 +765,7 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 
 	init_sync_kiocb(&iocb, NULL);
 	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&iocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	return ret;
 }
 EXPORT_SYMBOL(sock_recvmsg);
@@ -780,8 +778,7 @@ static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
 
 	init_sync_kiocb(&iocb, NULL);
 	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&iocb);
+	BUG_ON(ret == -EIOCBQUEUED);
 	return ret;
 }
 
-- 
2.1.4
