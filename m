From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V7 4/4 net-next] vhost: vhost TX zero-copy support
Date: Sat, 28 May 2011 12:34:27 -0700
Message-ID: <1306611267.5180.97.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

In order to use wait for completion in shutting down, seems to me
another work thread is needed to call vhost_zerocopy_add_used, it seems
too much work to address a minor issue here. Do we really need it?

Right now, the approach I am using is to ignore outstanding userspace
buffers during shutting down if any, the device might DMAed some wrong
data to the wire, do we really care?

Thanks
Shirley

------------

This patch maintains the outstanding userspace buffers in the 
sequence it is delivered to vhost. The outstanding userspace buffers 
will be marked as done once the lower device buffers DMA has finished. 
This is monitored through last reference of kfree_skb callback. Two
buffer index are used for this purpose.

The vhost passes the userspace buffers info to lower device skb 
through message control. Since there will be some done DMAs when
entering vhost handle_tx. The worse case is all buffers in the vq are
in pending/done status, so we need to notify guest to release DMA done 
buffers first before get any new buffers from the vq.

Signed-off-by: Shirley <xma@us.ibm.com>
---

 drivers/vhost/net.c   |   46 +++++++++++++++++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h |   15 +++++++++++++++
 3 files changed, 107 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2f7c76a..e2eaba6 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -32,6 +32,11 @@
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
+/* MAX number of TX used buffers for outstanding zerocopy */
+#define VHOST_MAX_PEND 128
+/* change it to 256 when small message size performance issue is addressed */
+#define VHOST_GOODCOPY_LEN 2048
+
 enum {
 	VHOST_NET_VQ_RX = 0,
 	VHOST_NET_VQ_TX = 1,
@@ -151,6 +156,10 @@ static void handle_tx(struct vhost_net *net)
 	hdr_size = vq->vhost_hlen;
 
 	for (;;) {
+		/* Release DMAs done buffers first */
+		if (atomic_read(&vq->refcnt) > VHOST_MAX_PEND)
+			vhost_zerocopy_signal_used(vq, false);
+
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
@@ -166,6 +175,12 @@ static void handle_tx(struct vhost_net *net)
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
+			/* If more outstanding DMAs, queue the work */
+			if (atomic_read(&vq->refcnt) > VHOST_MAX_PEND) {
+				tx_poll_start(net, sock);
+				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+				break;
+			}
 			if (unlikely(vhost_enable_notify(vq))) {
 				vhost_disable_notify(vq);
 				continue;
@@ -188,6 +203,26 @@ static void handle_tx(struct vhost_net *net)
 			       iov_length(vq->hdr, s), hdr_size);
 			break;
 		}
+		/* use msg_control to pass vhost zerocopy ubuf info to skb */
+		if (sock_flag(sock->sk, SOCK_ZEROCOPY)) {
+			vq->heads[vq->upend_idx].id = head;
+			if (len < VHOST_GOODCOPY_LEN)
+				/* copy don't need to wait for DMA done */
+				vq->heads[vq->upend_idx].len =
+							VHOST_DMA_DONE_LEN;
+			else {
+				struct ubuf_info *ubuf = &vq->ubuf_info[head];
+
+				vq->heads[vq->upend_idx].len = len;
+				ubuf->callback = vhost_zerocopy_callback;
+				ubuf->arg = vq;
+				ubuf->desc = vq->upend_idx;
+				msg.msg_control = ubuf;
+				msg.msg_controllen = sizeof(ubuf);
+			}
+			atomic_inc(&vq->refcnt);
+			vq->upend_idx = (vq->upend_idx + 1) % UIO_MAXIOV;
+		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
 		err = sock->ops->sendmsg(NULL, sock, &msg, len);
 		if (unlikely(err < 0)) {
@@ -198,12 +233,21 @@ static void handle_tx(struct vhost_net *net)
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
-		vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		if (!sock_flag(sock->sk, SOCK_ZEROCOPY))
+			vhost_add_used_and_signal(&net->dev, vq, head, 0);
 		total_len += len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
 			break;
 		}
+		/* if upend_idx is full, then wait for free more */
+/*
+		if (unlikely(vq->upend_idx == vq->done_idx)) {
+			tx_poll_start(net, sock);
+			set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+				break;
+		}
+*/
 	}
 
 	mutex_unlock(&vq->mutex);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 7aa4eea..b76e42a 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -174,6 +174,9 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call_ctx = NULL;
 	vq->call = NULL;
 	vq->log_ctx = NULL;
+	vq->upend_idx = 0;
+	vq->done_idx = 0;
+	atomic_set(&vq->refcnt, 0);
 }
 
 static int vhost_worker(void *data)
@@ -232,6 +235,8 @@ static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
 					  GFP_KERNEL);
 		dev->vqs[i].heads = kmalloc(sizeof *dev->vqs[i].heads *
 					    UIO_MAXIOV, GFP_KERNEL);
+		dev->vqs[i].ubuf_info = kmalloc(sizeof *dev->vqs[i].ubuf_info *
+					    UIO_MAXIOV, GFP_KERNEL);
 
 		if (!dev->vqs[i].indirect || !dev->vqs[i].log ||
 			!dev->vqs[i].heads)
@@ -244,6 +249,7 @@ err_nomem:
 		kfree(dev->vqs[i].indirect);
 		kfree(dev->vqs[i].log);
 		kfree(dev->vqs[i].heads);
+		kfree(dev->vqs[i].ubuf_info);
 	}
 	return -ENOMEM;
 }
@@ -385,6 +391,30 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
 	return 0;
 }
 
+/* In case of DMA done not in order in lower device driver for some reason.
+ * upend_idx is used to track end of used idx, done_idx is used to track head
+ * of used idx. Once lower device DMA done contiguously, we will signal KVM
+ * guest used idx.
+ */
+void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq, bool shutdown)
+{
+	int i, j = 0;
+
+	for (i = vq->done_idx; i != vq->upend_idx; i = ++i % UIO_MAXIOV) {
+		if ((vq->heads[i].len == VHOST_DMA_DONE_LEN) || shutdown) {
+			vq->heads[i].len = VHOST_DMA_CLEAR_LEN;
+			vhost_add_used_and_signal(vq->dev, vq,
+						  vq->heads[i].id, 0);
+			++j;
+		} else
+			break;
+	}
+	if (j) {
+		vq->done_idx = i;
+		atomic_sub(j, &vq->refcnt);
+	}
+}
+
 /* Caller should have device mutex */
 void vhost_dev_cleanup(struct vhost_dev *dev)
 {
@@ -395,6 +425,9 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 			vhost_poll_stop(&dev->vqs[i].poll);
 			vhost_poll_flush(&dev->vqs[i].poll);
 		}
+		/* Wait for all lower device DMAs done */
+		if (atomic_read(&dev->vqs[i].refcnt))
+			vhost_zerocopy_signal_used(&dev->vqs[i], true);
 		if (dev->vqs[i].error_ctx)
 			eventfd_ctx_put(dev->vqs[i].error_ctx);
 		if (dev->vqs[i].error)
@@ -603,6 +636,10 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 
 	mutex_lock(&vq->mutex);
 
+	/* clean up lower device outstanding DMAs, before setting ring */
+	if (atomic_read(&vq->refcnt))
+		vhost_zerocopy_signal_used(vq, true);
+
 	switch (ioctl) {
 	case VHOST_SET_VRING_NUM:
 		/* Resizing ring with an active backend?
@@ -1416,3 +1453,13 @@ void vhost_disable_notify(struct vhost_virtqueue *vq)
 		vq_err(vq, "Failed to enable notification at %p: %d\n",
 		       &vq->used->flags, r);
 }
+
+void vhost_zerocopy_callback(void *arg)
+{
+	struct ubuf_info *ubuf = (struct ubuf_info *)arg;
+	struct vhost_virtqueue *vq;
+
+	vq = (struct vhost_virtqueue *)ubuf->arg;
+	/* set len = 1 to mark this desc buffers done DMA */
+	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
+}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3363ae..0b11734 100644
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
@@ -108,6 +113,14 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	/* vhost zerocopy support */
+	atomic_t refcnt; /* num of outstanding zerocopy DMAs */
+	/* last used idx for outstanding DMA zerocopy buffers */
+	int upend_idx;
+	/* first used idx for DMA done zerocopy buffers */
+	int done_idx;
+	/* an array of userspace buffers info */
+	struct ubuf_info *ubuf_info;
 };
 
 struct vhost_dev {
@@ -154,6 +167,8 @@ bool vhost_enable_notify(struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
+void vhost_zerocopy_callback(void *arg);
+void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq, bool shutdown);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
