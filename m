From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] vhost: address fixme in vhost TX zero-copy support
Date: Tue, 12 Jul 2011 01:04:50 +0300
Message-ID: <20110711220449.GA8346@redhat.com>
References: <1309991321.10209.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309991321.10209.26.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So the following should do it, on top of Shirleys's patch, I think.  I'm
a bit not sure about using vq->upend_idx - vq->done_idx to check the
number of outstanding DMA, Shirley, what do you think?
Untested.

I'm also thinking about making the use of this conditinal
on a module parameter, off by default to reduce
stability risk while still enabling more people to
test the feature.
Thoughts?

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 7de0c6e..cf8deb3 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -156,8 +156,7 @@ static void handle_tx(struct vhost_net *net)
 
 	for (;;) {
 		/* Release DMAs done buffers first */
-		if (atomic_read(&vq->refcnt) > VHOST_MAX_PEND)
-			vhost_zerocopy_signal_used(vq);
+		vhost_zerocopy_signal_used(vq);
 
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
@@ -175,7 +174,7 @@ static void handle_tx(struct vhost_net *net)
 				break;
 			}
 			/* If more outstanding DMAs, queue the work */
-			if (atomic_read(&vq->refcnt) > VHOST_MAX_PEND) {
+			if (vq->upend_idx - vq->done_idx > VHOST_MAX_PEND) {
 				tx_poll_start(net, sock);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
@@ -214,12 +213,12 @@ static void handle_tx(struct vhost_net *net)
 
 				vq->heads[vq->upend_idx].len = len;
 				ubuf->callback = vhost_zerocopy_callback;
-				ubuf->arg = vq;
+				ubuf->arg = vq->ubufs;
 				ubuf->desc = vq->upend_idx;
 				msg.msg_control = ubuf;
 				msg.msg_controllen = sizeof(ubuf);
+				kref_get(&vq->ubufs->kref);
 			}
-			atomic_inc(&vq->refcnt);
 			vq->upend_idx = (vq->upend_idx + 1) % UIO_MAXIOV;
 		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
@@ -646,6 +645,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 {
 	struct socket *sock, *oldsock;
 	struct vhost_virtqueue *vq;
+	struct vhost_ubuf_ref *ubufs, *oldubufs = NULL;
 	int r;
 
 	mutex_lock(&n->dev.mutex);
@@ -675,6 +675,13 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	oldsock = rcu_dereference_protected(vq->private_data,
 					    lockdep_is_held(&vq->mutex));
 	if (sock != oldsock) {
+		ubufs = vhost_ubuf_alloc(vq, sock);
+		if (IS_ERR(ubufs)) {
+			r = PTR_ERR(ubufs);
+			goto err_ubufs;
+		}
+		oldubufs = vq->ubufs;
+		vq->ubufs = ubufs;
 		vhost_net_disable_vq(n, vq);
 		rcu_assign_pointer(vq->private_data, sock);
 		vhost_net_enable_vq(n, vq);
@@ -682,6 +689,9 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 
 	mutex_unlock(&vq->mutex);
 
+	if (oldbufs)
+		vhost_ubuf_put_and_wait(oldbufs);
+
 	if (oldsock) {
 		vhost_net_flush_vq(n, index);
 		fput(oldsock->file);
@@ -690,6 +700,8 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	mutex_unlock(&n->dev.mutex);
 	return 0;
 
+err_ubufs:
+	fput(sock);
 err_vq:
 	mutex_unlock(&vq->mutex);
 err:
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index db242b1..81b1dd7 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -181,7 +181,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->log_ctx = NULL;
 	vq->upend_idx = 0;
 	vq->done_idx = 0;
-	atomic_set(&vq->refcnt, 0);
+	vq->ubufs = NULL;
 }
 
 static int vhost_worker(void *data)
@@ -401,7 +401,7 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
  * of used idx. Once lower device DMA done contiguously, we will signal KVM
  * guest used idx.
  */
-void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
+int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
 {
 	int i, j = 0;
 
@@ -414,10 +414,9 @@ void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
 		} else
 			break;
 	}
-	if (j) {
+	if (j)
 		vq->done_idx = i;
-		atomic_sub(j, &vq->refcnt);
-	}
+	return j;
 }
 
 /* Caller should have device mutex */
@@ -430,9 +429,13 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 			vhost_poll_stop(&dev->vqs[i].poll);
 			vhost_poll_flush(&dev->vqs[i].poll);
 		}
-		/* Wait for all lower device DMAs done (busywait FIXME) */
-		while (atomic_read(&dev->vqs[i].refcnt))
-			vhost_zerocopy_signal_used(&dev->vqs[i]);
+		/* Wait for all lower device DMAs done. */
+		if (dev->vqs[i].ubufs)
+			vhost_ubuf_put_and_wait(dev->vqs[i].ubufs);
+
+		/* Signal guest as appropriate. */
+		vhost_zerocopy_signal_used(&dev->vqs[i]);
+
 		if (dev->vqs[i].error_ctx)
 			eventfd_ctx_put(dev->vqs[i].error_ctx);
 		if (dev->vqs[i].error)
@@ -645,11 +648,6 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 
 	mutex_lock(&vq->mutex);
 
-	/* clean up lower device outstanding DMAs, before setting ring
-	   busywait FIXME */
-	while (atomic_read(&vq->refcnt))
-		vhost_zerocopy_signal_used(vq);
-
 	switch (ioctl) {
 	case VHOST_SET_VRING_NUM:
 		/* Resizing ring with an active backend?
@@ -1525,12 +1523,46 @@ void vhost_disable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	}
 }
 
+static void vhost_zerocopy_done_signal(struct kref *kref)
+{
+	struct vhost_ubuf_ref *ubufs = container_of(kref, struct vhost_ubuf_ref,
+						    kref);
+	wake_up(&ubufs->wait);
+}
+
+struct vhost_ubuf_ref *vhost_ubuf_alloc(struct vhost_virtqueue *vq,
+					void * private_data)
+{
+	struct vhost_ubuf_ref *ubufs;
+	/* No backend? Nothing to count. */
+	if (!private_data)
+		return NULL;
+	ubufs = kmalloc(sizeof *ubufs, GFP_KERNEL);
+	if (!ubufs)
+		return ERR_PTR(-ENOMEM);
+	kref_init(&ubufs->kref);
+	kref_get(&ubufs->kref);
+	init_waitqueue_head(&ubufs->wait);
+	ubufs->vq = vq;
+	return ubufs;
+}
+
+void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
+{
+	kref_put(&ubufs->kref, vhost_zerocopy_done_signal); 
+	wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
+	kfree(ubufs);
+}
+
 void vhost_zerocopy_callback(void *arg)
 {
 	struct ubuf_info *ubuf = (struct ubuf_info *)arg;
+	struct vhost_ubuf_ref *ubufs;
 	struct vhost_virtqueue *vq;
 
-	vq = (struct vhost_virtqueue *)ubuf->arg;
+	ubufs = ubuf->arg;
+	vq = ubufs->vq;
 	/* set len = 1 to mark this desc buffers done DMA */
 	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
+	kref_put(&ubufs->kref, vhost_zerocopy_done_signal); 
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 883688c..b42b126 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -55,6 +55,17 @@ struct vhost_log {
 	u64 len;
 };
 
+struct vhost_virtqueue;
+
+struct vhost_ubuf_ref {
+	struct kref kref;
+	wait_queue_t wait;
+	struct vhost_virtqueue *vq;
+};
+
+struct vhost_ubuf_ref *vhost_ubuf_alloc(struct vhost_virtqueue *, void *);
+void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *);
+
 /* The virtqueue structure describes a queue attached to a device. */
 struct vhost_virtqueue {
 	struct vhost_dev *dev;
@@ -127,6 +138,9 @@ struct vhost_virtqueue {
 	int done_idx;
 	/* an array of userspace buffers info */
 	struct ubuf_info *ubuf_info;
+	/* Reference counting for outstanding ubufs.
+	 * Protected by vq mutex. Writers must also take device mutex. */
+	struct vhost_ubuf_ref *ubufs;
 };
 
 struct vhost_dev {
@@ -174,7 +188,7 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
 void vhost_zerocopy_callback(void *arg);
-void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
+int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
