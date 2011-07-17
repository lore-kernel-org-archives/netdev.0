From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv9] vhost: experimental tx zero-copy support
Date: Sun, 17 Jul 2011 22:36:14 +0300
Message-ID: <20110717193540.GA29392@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <mashirle@us.ibm.com>

This adds experimental zero copy support in vhost-net,
disabled by default. To enable, set the zerocopytx
module option to 1.

This patch maintains the outstanding userspace buffers in the
sequence it is delivered to vhost. The outstanding userspace buffers
will be marked as done once the lower device buffers DMA has finished.
This is monitored through last reference of kfree_skb callback. Two
buffer indices are used for this purpose.

The vhost-net device passes the userspace buffers info to lower device
skb through message control. DMA done status check and guest
notification are handled by handle_tx: in the worst case is all buffers
in the vq are in pending/done status, so we need to notify guest to
release DMA done buffers first before we get any new buffers from the
vq.

One known problem is that if the guest stops submitting
buffers, buffers might never get used until some
further action, e.g. device reset. This does not
seem to affect linux guests.

Signed-off-by: Shirley <xma@us.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

The below is what I came up with. We add the feature enabled
by default for now as there are known issues, but some
guests can benefit so there's value in putting this
in tree, to help the code get wider testing.

 drivers/vhost/net.c   |   73 +++++++++++++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.c |   85 +++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h |   29 +++++++++++++++++
 3 files changed, 186 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index e224a92..226ca6b 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -12,6 +12,7 @@
 #include <linux/virtio_net.h>
 #include <linux/miscdevice.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/mutex.h>
 #include <linux/workqueue.h>
 #include <linux/rcupdate.h>
@@ -28,10 +29,18 @@
 
 #include "vhost.h"
 
+static int zcopytx;
+module_param(zcopytx, int, 0444);
+MODULE_PARM_DESC(lnksts, "Enable Zero Copy Transmit");
+
 /* Max number of bytes transferred before requeueing the job.
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
+/* MAX number of TX used buffers for outstanding zerocopy */
+#define VHOST_MAX_PEND 128
+#define VHOST_GOODCOPY_LEN 256
+
 enum {
 	VHOST_NET_VQ_RX = 0,
 	VHOST_NET_VQ_TX = 1,
@@ -54,6 +63,11 @@ struct vhost_net {
 	enum vhost_net_poll_state tx_poll_state;
 };
 
+static bool vhost_sock_zcopy(struct socket *sock)
+{
+	return unlikely(zcopytx) && sock_flag(sock->sk, SOCK_ZEROCOPY);
+}
+
 /* Pop first len bytes from iovec. Return number of segments used. */
 static int move_iovec_hdr(struct iovec *from, struct iovec *to,
 			  size_t len, int iov_count)
@@ -129,6 +143,8 @@ static void handle_tx(struct vhost_net *net)
 	int err, wmem;
 	size_t hdr_size;
 	struct socket *sock;
+	struct vhost_ubuf_ref *uninitialized_var(ubufs);
+	bool zcopy;
 
 	/* TODO: check that we are running from vhost_worker? */
 	sock = rcu_dereference_check(vq->private_data, 1);
@@ -149,8 +165,13 @@ static void handle_tx(struct vhost_net *net)
 	if (wmem < sock->sk->sk_sndbuf / 2)
 		tx_poll_stop(net);
 	hdr_size = vq->vhost_hlen;
+	zcopy = vhost_sock_zcopy(sock);
 
 	for (;;) {
+		/* Release DMAs done buffers first */
+		if (zcopy)
+			vhost_zerocopy_signal_used(vq);
+
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
@@ -166,6 +187,12 @@ static void handle_tx(struct vhost_net *net)
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
+			/* If more outstanding DMAs, queue the work */
+			if (vq->upend_idx - vq->done_idx > VHOST_MAX_PEND) {
+				tx_poll_start(net, sock);
+				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+				break;
+			}
 			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
 				vhost_disable_notify(&net->dev, vq);
 				continue;
@@ -188,9 +215,39 @@ static void handle_tx(struct vhost_net *net)
 			       iov_length(vq->hdr, s), hdr_size);
 			break;
 		}
+		/* use msg_control to pass vhost zerocopy ubuf info to skb */
+		if (zcopy) {
+			vq->heads[vq->upend_idx].id = head;
+			if (len < VHOST_GOODCOPY_LEN) {
+				/* copy don't need to wait for DMA done */
+				vq->heads[vq->upend_idx].len =
+							VHOST_DMA_DONE_LEN;
+				msg.msg_control = NULL;
+				msg.msg_controllen = 0;
+				ubufs = NULL;
+			} else {
+				struct ubuf_info *ubuf = &vq->ubuf_info[head];
+
+				vq->heads[vq->upend_idx].len = len;
+				ubuf->callback = vhost_zerocopy_callback;
+				ubuf->arg = vq->ubufs;
+				ubuf->desc = vq->upend_idx;
+				msg.msg_control = ubuf;
+				msg.msg_controllen = sizeof(ubuf);
+				ubufs = vq->ubufs;
+				kref_get(&ubufs->kref);
+			}
+			vq->upend_idx = (vq->upend_idx + 1) % UIO_MAXIOV;
+		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
 		err = sock->ops->sendmsg(NULL, sock, &msg, len);
 		if (unlikely(err < 0)) {
+			if (zcopy) {
+				if (ubufs)
+					vhost_ubuf_put(ubufs);
+				vq->upend_idx = ((unsigned)vq->upend_idx - 1) %
+					UIO_MAXIOV;
+			}
 			vhost_discard_vq_desc(vq, 1);
 			tx_poll_start(net, sock);
 			break;
@@ -198,7 +255,8 @@ static void handle_tx(struct vhost_net *net)
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
-		vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		if (!zcopy)
+			vhost_add_used_and_signal(&net->dev, vq, head, 0);
 		total_len += len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
@@ -603,6 +661,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 {
 	struct socket *sock, *oldsock;
 	struct vhost_virtqueue *vq;
+	struct vhost_ubuf_ref *ubufs, *oldubufs = NULL;
 	int r;
 
 	mutex_lock(&n->dev.mutex);
@@ -632,6 +691,13 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	oldsock = rcu_dereference_protected(vq->private_data,
 					    lockdep_is_held(&vq->mutex));
 	if (sock != oldsock) {
+		ubufs = vhost_ubuf_alloc(vq, sock && vhost_sock_zcopy(sock));
+		if (IS_ERR(ubufs)) {
+			r = PTR_ERR(ubufs);
+			goto err_ubufs;
+		}
+		oldubufs = vq->ubufs;
+		vq->ubufs = ubufs;
 		vhost_net_disable_vq(n, vq);
 		rcu_assign_pointer(vq->private_data, sock);
 		vhost_net_enable_vq(n, vq);
@@ -639,6 +705,9 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 
 	mutex_unlock(&vq->mutex);
 
+	if (oldubufs)
+		vhost_ubuf_put_and_wait(oldubufs);
+
 	if (oldsock) {
 		vhost_net_flush_vq(n, index);
 		fput(oldsock->file);
@@ -647,6 +716,8 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	mutex_unlock(&n->dev.mutex);
 	return 0;
 
+err_ubufs:
+	fput(sock->file);
 err_vq:
 	mutex_unlock(&vq->mutex);
 err:
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ea966b3..2ebf6fc 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -179,6 +179,9 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call_ctx = NULL;
 	vq->call = NULL;
 	vq->log_ctx = NULL;
+	vq->upend_idx = 0;
+	vq->done_idx = 0;
+	vq->ubufs = NULL;
 }
 
 static int vhost_worker(void *data)
@@ -237,6 +240,8 @@ static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
 					  GFP_KERNEL);
 		dev->vqs[i].heads = kmalloc(sizeof *dev->vqs[i].heads *
 					    UIO_MAXIOV, GFP_KERNEL);
+		dev->vqs[i].ubuf_info = kmalloc(sizeof *dev->vqs[i].ubuf_info *
+					    UIO_MAXIOV, GFP_KERNEL);
 
 		if (!dev->vqs[i].indirect || !dev->vqs[i].log ||
 			!dev->vqs[i].heads)
@@ -249,6 +254,7 @@ err_nomem:
 		kfree(dev->vqs[i].indirect);
 		kfree(dev->vqs[i].log);
 		kfree(dev->vqs[i].heads);
+		kfree(dev->vqs[i].ubuf_info);
 	}
 	return -ENOMEM;
 }
@@ -390,6 +396,29 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
 	return 0;
 }
 
+/* In case of DMA done not in order in lower device driver for some reason.
+ * upend_idx is used to track end of used idx, done_idx is used to track head
+ * of used idx. Once lower device DMA done contiguously, we will signal KVM
+ * guest used idx.
+ */
+int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
+{
+	int i, j = 0;
+
+	for (i = vq->done_idx; i != vq->upend_idx; i = (i + 1) % UIO_MAXIOV) {
+		if ((vq->heads[i].len == VHOST_DMA_DONE_LEN)) {
+			vq->heads[i].len = VHOST_DMA_CLEAR_LEN;
+			vhost_add_used_and_signal(vq->dev, vq,
+						  vq->heads[i].id, 0);
+			++j;
+		} else
+			break;
+	}
+	if (j)
+		vq->done_idx = i;
+	return j;
+}
+
 /* Caller should have device mutex */
 void vhost_dev_cleanup(struct vhost_dev *dev)
 {
@@ -400,6 +429,13 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 			vhost_poll_stop(&dev->vqs[i].poll);
 			vhost_poll_flush(&dev->vqs[i].poll);
 		}
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
@@ -1486,3 +1522,52 @@ void vhost_disable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 			       &vq->used->flags, r);
 	}
 }
+
+static void vhost_zerocopy_done_signal(struct kref *kref)
+{
+	struct vhost_ubuf_ref *ubufs = container_of(kref, struct vhost_ubuf_ref,
+						    kref);
+	wake_up(&ubufs->wait);
+}
+
+struct vhost_ubuf_ref *vhost_ubuf_alloc(struct vhost_virtqueue *vq,
+					bool zcopy)
+{
+	struct vhost_ubuf_ref *ubufs;
+	/* No zero copy backend? Nothing to count. */
+	if (!zcopy)
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
+void vhost_ubuf_put(struct vhost_ubuf_ref *ubufs)
+{
+	kref_put(&ubufs->kref, vhost_zerocopy_done_signal); 
+}
+
+void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
+{
+	kref_put(&ubufs->kref, vhost_zerocopy_done_signal); 
+	wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
+	kfree(ubufs);
+}
+
+void vhost_zerocopy_callback(void *arg)
+{
+	struct ubuf_info *ubuf = (struct ubuf_info *)arg;
+	struct vhost_ubuf_ref *ubufs;
+	struct vhost_virtqueue *vq;
+
+	ubufs = ubuf->arg;
+	vq = ubufs->vq;
+	/* set len = 1 to mark this desc buffers done DMA */
+	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
+	kref_put(&ubufs->kref, vhost_zerocopy_done_signal); 
+}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 8e03379..e287145 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -13,6 +13,11 @@
 #include <linux/virtio_ring.h>
 #include <asm/atomic.h>
 
+/* This is for zerocopy, used buffer len is set to 1 when lower device DMA
+ * done */
+#define VHOST_DMA_DONE_LEN	1
+#define VHOST_DMA_CLEAR_LEN	0
+
 struct vhost_device;
 
 struct vhost_work;
@@ -50,6 +55,18 @@ struct vhost_log {
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
+struct vhost_ubuf_ref *vhost_ubuf_alloc(struct vhost_virtqueue *, bool zcopy);
+void vhost_ubuf_put(struct vhost_ubuf_ref *);
+void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *);
+
 /* The virtqueue structure describes a queue attached to a device. */
 struct vhost_virtqueue {
 	struct vhost_dev *dev;
@@ -114,6 +131,16 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	/* vhost zerocopy support fields below: */
+	/* last used idx for outstanding DMA zerocopy buffers */
+	int upend_idx;
+	/* first used idx for DMA done zerocopy buffers */
+	int done_idx;
+	/* an array of userspace buffers info */
+	struct ubuf_info *ubuf_info;
+	/* Reference counting for outstanding ubufs.
+	 * Protected by vq mutex. Writers must also take device mutex. */
+	struct vhost_ubuf_ref *ubufs;
 };
 
 struct vhost_dev {
@@ -160,6 +187,8 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
+void vhost_zerocopy_callback(void *arg);
+int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
-- 
1.7.5.53.gc233e
