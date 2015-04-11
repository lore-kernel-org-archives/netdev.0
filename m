From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 04/17] fs: split generic and aio kiocb
Date: Sat, 11 Apr 2015 22:18:15 +0100
Message-ID: <1428787108-13650-4-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37863 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932361AbbDKVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:30 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>

Most callers in the kernel want to perform synchronous file I/O, but
still have to bloat the stack with a full struct kiocb.  Split out
the parts needed in filesystem code from those in the aio code, and
only allocate those needed to pass down argument on the stack.  The
aio code embedds the generic iocb in the one it allocates and can
easily get back to it by using container_of.

Also add a ->ki_complete method to struct kiocb, this is used to call
into the aio code and thus removes the dependency on aio for filesystems
impementing asynchronous operations.  It will also allow other callers
to substitute their own completion callback.

We also add a new ->ki_flags field to work around the nasty layering
violation recently introduced in commit 5e33f6 ("usb: gadget: ffs: add
eventfd notification about ffs events").

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/usb/gadget/function/f_fs.c |  5 +-
 drivers/usb/gadget/legacy/inode.c  |  5 +-
 fs/aio.c                           | 94 ++++++++++++++++++++++++++------------
 fs/direct-io.c                     |  4 +-
 fs/fuse/file.c                     |  2 +-
 fs/nfs/direct.c                    |  2 +-
 include/linux/aio.h                | 46 +++----------------
 7 files changed, 81 insertions(+), 77 deletions(-)

diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index 175c995..b64538b 100644
--- a/drivers/usb/gadget/function/f_fs.c
+++ b/drivers/usb/gadget/function/f_fs.c
@@ -655,9 +655,10 @@ static void ffs_user_copy_worker(struct work_struct *work)
 		unuse_mm(io_data->mm);
 	}
 
-	aio_complete(io_data->kiocb, ret, ret);
+	io_data->kiocb->ki_complete(io_data->kiocb, ret, ret);
 
-	if (io_data->ffs->ffs_eventfd && !io_data->kiocb->ki_eventfd)
+	if (io_data->ffs->ffs_eventfd &&
+	    !(io_data->kiocb->ki_flags & IOCB_EVENTFD))
 		eventfd_signal(io_data->ffs->ffs_eventfd, 1);
 
 	usb_ep_free_request(io_data->ep, io_data->req);
diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index 200f9a5..a4a8069 100644
--- a/drivers/usb/gadget/legacy/inode.c
+++ b/drivers/usb/gadget/legacy/inode.c
@@ -469,7 +469,7 @@ static void ep_user_copy_worker(struct work_struct *work)
 		ret = -EFAULT;
 
 	/* completing the iocb can drop the ctx and mm, don't touch mm after */
-	aio_complete(iocb, ret, ret);
+	iocb->ki_complete(iocb, ret, ret);
 
 	kfree(priv->buf);
 	kfree(priv->to_free);
@@ -497,7 +497,8 @@ static void ep_aio_complete(struct usb_ep *ep, struct usb_request *req)
 		kfree(priv);
 		iocb->private = NULL;
 		/* aio_complete() reports bytes-transferred _and_ faults */
-		aio_complete(iocb, req->actual ? req->actual : req->status,
+
+		iocb->ki_complete(iocb, req->actual ? req->actual : req->status,
 				req->status);
 	} else {
 		/* ep_copy_to_user() won't report both; we hide some faults */
diff --git a/fs/aio.c b/fs/aio.c
index 8ca8df1..9582865 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -151,6 +151,38 @@ struct kioctx {
 	unsigned		id;
 };
 
+/*
+ * We use ki_cancel == KIOCB_CANCELLED to indicate that a kiocb has been either
+ * cancelled or completed (this makes a certain amount of sense because
+ * successful cancellation - io_cancel() - does deliver the completion to
+ * userspace).
+ *
+ * And since most things don't implement kiocb cancellation and we'd really like
+ * kiocb completion to be lockless when possible, we use ki_cancel to
+ * synchronize cancellation and completion - we only set it to KIOCB_CANCELLED
+ * with xchg() or cmpxchg(), see batch_complete_aio() and kiocb_cancel().
+ */
+#define KIOCB_CANCELLED		((void *) (~0ULL))
+
+struct aio_kiocb {
+	struct kiocb		common;
+
+	struct kioctx		*ki_ctx;
+	kiocb_cancel_fn		*ki_cancel;
+
+	struct iocb __user	*ki_user_iocb;	/* user's aiocb */
+	__u64			ki_user_data;	/* user's data for completion */
+
+	struct list_head	ki_list;	/* the aio core uses this
+						 * for cancellation */
+
+	/*
+	 * If the aio_resfd field of the userspace iocb is not zero,
+	 * this is the underlying eventfd context to deliver events to.
+	 */
+	struct eventfd_ctx	*ki_eventfd;
+};
+
 /*------ sysctl variables----*/
 static DEFINE_SPINLOCK(aio_nr_lock);
 unsigned long aio_nr;		/* current system wide number of aio requests */
@@ -220,7 +252,7 @@ static int __init aio_setup(void)
 	if (IS_ERR(aio_mnt))
 		panic("Failed to create aio fs mount.");
 
-	kiocb_cachep = KMEM_CACHE(kiocb, SLAB_HWCACHE_ALIGN|SLAB_PANIC);
+	kiocb_cachep = KMEM_CACHE(aio_kiocb, SLAB_HWCACHE_ALIGN|SLAB_PANIC);
 	kioctx_cachep = KMEM_CACHE(kioctx,SLAB_HWCACHE_ALIGN|SLAB_PANIC);
 
 	pr_debug("sizeof(struct page) = %zu\n", sizeof(struct page));
@@ -480,8 +512,9 @@ static int aio_setup_ring(struct kioctx *ctx)
 #define AIO_EVENTS_FIRST_PAGE	((PAGE_SIZE - sizeof(struct aio_ring)) / sizeof(struct io_event))
 #define AIO_EVENTS_OFFSET	(AIO_EVENTS_PER_PAGE - AIO_EVENTS_FIRST_PAGE)
 
-void kiocb_set_cancel_fn(struct kiocb *req, kiocb_cancel_fn *cancel)
+void kiocb_set_cancel_fn(struct kiocb *iocb, kiocb_cancel_fn *cancel)
 {
+	struct aio_kiocb *req = container_of(iocb, struct aio_kiocb, common);
 	struct kioctx *ctx = req->ki_ctx;
 	unsigned long flags;
 
@@ -496,7 +529,7 @@ void kiocb_set_cancel_fn(struct kiocb *req, kiocb_cancel_fn *cancel)
 }
 EXPORT_SYMBOL(kiocb_set_cancel_fn);
 
-static int kiocb_cancel(struct kiocb *kiocb)
+static int kiocb_cancel(struct aio_kiocb *kiocb)
 {
 	kiocb_cancel_fn *old, *cancel;
 
@@ -514,7 +547,7 @@ static int kiocb_cancel(struct kiocb *kiocb)
 		cancel = cmpxchg(&kiocb->ki_cancel, old, KIOCB_CANCELLED);
 	} while (cancel != old);
 
-	return cancel(kiocb);
+	return cancel(&kiocb->common);
 }
 
 static void free_ioctx(struct work_struct *work)
@@ -550,13 +583,13 @@ static void free_ioctx_reqs(struct percpu_ref *ref)
 static void free_ioctx_users(struct percpu_ref *ref)
 {
 	struct kioctx *ctx = container_of(ref, struct kioctx, users);
-	struct kiocb *req;
+	struct aio_kiocb *req;
 
 	spin_lock_irq(&ctx->ctx_lock);
 
 	while (!list_empty(&ctx->active_reqs)) {
 		req = list_first_entry(&ctx->active_reqs,
-				       struct kiocb, ki_list);
+				       struct aio_kiocb, ki_list);
 
 		list_del_init(&req->ki_list);
 		kiocb_cancel(req);
@@ -932,9 +965,9 @@ static void user_refill_reqs_available(struct kioctx *ctx)
  *	Allocate a slot for an aio request.
  * Returns NULL if no requests are free.
  */
-static inline struct kiocb *aio_get_req(struct kioctx *ctx)
+static inline struct aio_kiocb *aio_get_req(struct kioctx *ctx)
 {
-	struct kiocb *req;
+	struct aio_kiocb *req;
 
 	if (!get_reqs_available(ctx)) {
 		user_refill_reqs_available(ctx);
@@ -955,10 +988,10 @@ out_put:
 	return NULL;
 }
 
-static void kiocb_free(struct kiocb *req)
+static void kiocb_free(struct aio_kiocb *req)
 {
-	if (req->ki_filp)
-		fput(req->ki_filp);
+	if (req->common.ki_filp)
+		fput(req->common.ki_filp);
 	if (req->ki_eventfd != NULL)
 		eventfd_ctx_put(req->ki_eventfd);
 	kmem_cache_free(kiocb_cachep, req);
@@ -994,8 +1027,9 @@ out:
 /* aio_complete
  *	Called when the io request on the given iocb is complete.
  */
-void aio_complete(struct kiocb *iocb, long res, long res2)
+static void aio_complete(struct kiocb *kiocb, long res, long res2)
 {
+	struct aio_kiocb *iocb = container_of(kiocb, struct aio_kiocb, common);
 	struct kioctx	*ctx = iocb->ki_ctx;
 	struct aio_ring	*ring;
 	struct io_event	*ev_page, *event;
@@ -1009,7 +1043,7 @@ void aio_complete(struct kiocb *iocb, long res, long res2)
 	 *    ref, no other paths have a way to get another ref
 	 *  - the sync task helpfully left a reference to itself in the iocb
 	 */
-	BUG_ON(is_sync_kiocb(iocb));
+	BUG_ON(is_sync_kiocb(kiocb));
 
 	if (iocb->ki_list.next) {
 		unsigned long flags;
@@ -1035,7 +1069,7 @@ void aio_complete(struct kiocb *iocb, long res, long res2)
 	ev_page = kmap_atomic(ctx->ring_pages[pos / AIO_EVENTS_PER_PAGE]);
 	event = ev_page + pos % AIO_EVENTS_PER_PAGE;
 
-	event->obj = (u64)(unsigned long)iocb->ki_obj.user;
+	event->obj = (u64)(unsigned long)iocb->ki_user_iocb;
 	event->data = iocb->ki_user_data;
 	event->res = res;
 	event->res2 = res2;
@@ -1044,7 +1078,7 @@ void aio_complete(struct kiocb *iocb, long res, long res2)
 	flush_dcache_page(ctx->ring_pages[pos / AIO_EVENTS_PER_PAGE]);
 
 	pr_debug("%p[%u]: %p: %p %Lx %lx %lx\n",
-		 ctx, tail, iocb, iocb->ki_obj.user, iocb->ki_user_data,
+		 ctx, tail, iocb, iocb->ki_user_iocb, iocb->ki_user_data,
 		 res, res2);
 
 	/* after flagging the request as done, we
@@ -1091,7 +1125,6 @@ void aio_complete(struct kiocb *iocb, long res, long res2)
 
 	percpu_ref_put(&ctx->reqs);
 }
-EXPORT_SYMBOL(aio_complete);
 
 /* aio_read_events_ring
  *	Pull an event off of the ioctx's event ring.  Returns the number of
@@ -1480,7 +1513,7 @@ rw_common:
 static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 			 struct iocb *iocb, bool compat)
 {
-	struct kiocb *req;
+	struct aio_kiocb *req;
 	ssize_t ret;
 
 	/* enforce forwards compatibility on users */
@@ -1503,11 +1536,14 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	if (unlikely(!req))
 		return -EAGAIN;
 
-	req->ki_filp = fget(iocb->aio_fildes);
-	if (unlikely(!req->ki_filp)) {
+	req->common.ki_filp = fget(iocb->aio_fildes);
+	if (unlikely(!req->common.ki_filp)) {
 		ret = -EBADF;
 		goto out_put_req;
 	}
+	req->common.ki_pos = iocb->aio_offset;
+	req->common.ki_complete = aio_complete;
+	req->common.ki_flags = 0;
 
 	if (iocb->aio_flags & IOCB_FLAG_RESFD) {
 		/*
@@ -1522,6 +1558,8 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 			req->ki_eventfd = NULL;
 			goto out_put_req;
 		}
+
+		req->common.ki_flags |= IOCB_EVENTFD;
 	}
 
 	ret = put_user(KIOCB_KEY, &user_iocb->aio_key);
@@ -1530,11 +1568,10 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 		goto out_put_req;
 	}
 
-	req->ki_obj.user = user_iocb;
+	req->ki_user_iocb = user_iocb;
 	req->ki_user_data = iocb->aio_data;
-	req->ki_pos = iocb->aio_offset;
 
-	ret = aio_run_iocb(req, iocb->aio_lio_opcode,
+	ret = aio_run_iocb(&req->common, iocb->aio_lio_opcode,
 			   (char __user *)(unsigned long)iocb->aio_buf,
 			   iocb->aio_nbytes,
 			   compat);
@@ -1623,10 +1660,10 @@ SYSCALL_DEFINE3(io_submit, aio_context_t, ctx_id, long, nr,
 /* lookup_kiocb
  *	Finds a given iocb for cancellation.
  */
-static struct kiocb *lookup_kiocb(struct kioctx *ctx, struct iocb __user *iocb,
-				  u32 key)
+static struct aio_kiocb *
+lookup_kiocb(struct kioctx *ctx, struct iocb __user *iocb, u32 key)
 {
-	struct list_head *pos;
+	struct aio_kiocb *kiocb;
 
 	assert_spin_locked(&ctx->ctx_lock);
 
@@ -1634,9 +1671,8 @@ static struct kiocb *lookup_kiocb(struct kioctx *ctx, struct iocb __user *iocb,
 		return NULL;
 
 	/* TODO: use a hash or array, this sucks. */
-	list_for_each(pos, &ctx->active_reqs) {
-		struct kiocb *kiocb = list_kiocb(pos);
-		if (kiocb->ki_obj.user == iocb)
+	list_for_each_entry(kiocb, &ctx->active_reqs, ki_list) {
+		if (kiocb->ki_user_iocb == iocb)
 			return kiocb;
 	}
 	return NULL;
@@ -1656,7 +1692,7 @@ SYSCALL_DEFINE3(io_cancel, aio_context_t, ctx_id, struct iocb __user *, iocb,
 		struct io_event __user *, result)
 {
 	struct kioctx *ctx;
-	struct kiocb *kiocb;
+	struct aio_kiocb *kiocb;
 	u32 key;
 	int ret;
 
diff --git a/fs/direct-io.c b/fs/direct-io.c
index e181b6b..c38b460 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -265,7 +265,7 @@ static ssize_t dio_complete(struct dio *dio, loff_t offset, ssize_t ret,
 				ret = err;
 		}
 
-		aio_complete(dio->iocb, ret, 0);
+		dio->iocb->ki_complete(dio->iocb, ret, 0);
 	}
 
 	kmem_cache_free(dio_cache, dio);
@@ -1056,7 +1056,7 @@ static inline int drop_refcount(struct dio *dio)
 	 * operation.  AIO can if it was a broken operation described above or
 	 * in fact if all the bios race to complete before we get here.  In
 	 * that case dio_complete() translates the EIOCBQUEUED into the proper
-	 * return code that the caller will hand to aio_complete().
+	 * return code that the caller will hand to ->complete().
 	 *
 	 * This is managed by the bio_lock instead of being an atomic_t so that
 	 * completion paths can drop their ref and use the remaining count to
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index f81d83e..a5c5e38 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -584,7 +584,7 @@ static void fuse_aio_complete(struct fuse_io_priv *io, int err, ssize_t pos)
 			spin_unlock(&fc->lock);
 		}
 
-		aio_complete(io->iocb, res, 0);
+		io->iocb->ki_complete(io->iocb, res, 0);
 		kfree(io);
 	}
 }
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 27cebf1..5db3385 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -393,7 +393,7 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
 		long res = (long) dreq->error;
 		if (!res)
 			res = (long) dreq->count;
-		aio_complete(dreq->iocb, res, 0);
+		dreq->iocb->ki_complete(dreq->iocb, res, 0);
 	}
 
 	complete_all(&dreq->completion);
diff --git a/include/linux/aio.h b/include/linux/aio.h
index f851643..5c40b61 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -14,67 +14,38 @@ struct kiocb;
 
 #define KIOCB_KEY		0
 
-/*
- * We use ki_cancel == KIOCB_CANCELLED to indicate that a kiocb has been either
- * cancelled or completed (this makes a certain amount of sense because
- * successful cancellation - io_cancel() - does deliver the completion to
- * userspace).
- *
- * And since most things don't implement kiocb cancellation and we'd really like
- * kiocb completion to be lockless when possible, we use ki_cancel to
- * synchronize cancellation and completion - we only set it to KIOCB_CANCELLED
- * with xchg() or cmpxchg(), see batch_complete_aio() and kiocb_cancel().
- */
-#define KIOCB_CANCELLED		((void *) (~0ULL))
-
 typedef int (kiocb_cancel_fn)(struct kiocb *);
 
+#define IOCB_EVENTFD		(1 << 0)
+
 struct kiocb {
 	struct file		*ki_filp;
-	struct kioctx		*ki_ctx;	/* NULL for sync ops */
-	kiocb_cancel_fn		*ki_cancel;
-	void			*private;
-
-	union {
-		void __user		*user;
-	} ki_obj;
-
-	__u64			ki_user_data;	/* user's data for completion */
 	loff_t			ki_pos;
-
-	struct list_head	ki_list;	/* the aio core uses this
-						 * for cancellation */
-
-	/*
-	 * If the aio_resfd field of the userspace iocb is not zero,
-	 * this is the underlying eventfd context to deliver events to.
-	 */
-	struct eventfd_ctx	*ki_eventfd;
+	void (*ki_complete)(struct kiocb *iocb, long ret, long ret2);
+	void			*private;
+	int			ki_flags;
 };
 
 static inline bool is_sync_kiocb(struct kiocb *kiocb)
 {
-	return kiocb->ki_ctx == NULL;
+	return kiocb->ki_complete == NULL;
 }
 
 static inline void init_sync_kiocb(struct kiocb *kiocb, struct file *filp)
 {
 	*kiocb = (struct kiocb) {
-			.ki_ctx = NULL,
 			.ki_filp = filp,
 		};
 }
 
 /* prototypes */
 #ifdef CONFIG_AIO
-extern void aio_complete(struct kiocb *iocb, long res, long res2);
 struct mm_struct;
 extern void exit_aio(struct mm_struct *mm);
 extern long do_io_submit(aio_context_t ctx_id, long nr,
 			 struct iocb __user *__user *iocbpp, bool compat);
 void kiocb_set_cancel_fn(struct kiocb *req, kiocb_cancel_fn *cancel);
 #else
-static inline void aio_complete(struct kiocb *iocb, long res, long res2) { }
 struct mm_struct;
 static inline void exit_aio(struct mm_struct *mm) { }
 static inline long do_io_submit(aio_context_t ctx_id, long nr,
@@ -84,11 +55,6 @@ static inline void kiocb_set_cancel_fn(struct kiocb *req,
 				       kiocb_cancel_fn *cancel) { }
 #endif /* CONFIG_AIO */
 
-static inline struct kiocb *list_kiocb(struct list_head *h)
-{
-	return list_entry(h, struct kiocb, ki_list);
-}
-
 /* for sysctl: */
 extern unsigned long aio_nr;
 extern unsigned long aio_max_nr;
-- 
2.1.4
