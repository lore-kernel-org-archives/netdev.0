From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Mon, 16 May 2011 12:34:44 -0700
Message-ID: <1305574484.3456.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

 drivers/vhost/net.c   |   39 +++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h |   12 ++++++++++
 3 files changed, 107 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2f7c76a..c964000 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -32,6 +32,10 @@
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
+/* MAX number of TX used buffers for outstanding zerocopy */
+#define VHOST_MAX_PEND 128
+#define VHOST_GOODCOPY_LEN 256
+
 enum {
 	VHOST_NET_VQ_RX = 0,
 	VHOST_NET_VQ_TX = 1,
@@ -129,6 +133,7 @@ static void handle_tx(struct vhost_net *net)
 	int err, wmem;
 	size_t hdr_size;
 	struct socket *sock;
+	struct skb_ubuf_info pend;
 
 	/* TODO: check that we are running from vhost_worker? */
 	sock = rcu_dereference_check(vq->private_data, 1);
@@ -151,6 +156,10 @@ static void handle_tx(struct vhost_net *net)
 	hdr_size = vq->vhost_hlen;
 
 	for (;;) {
+		/* Release DMAs done buffers first */
+		if (atomic_read(&vq->refcnt) > VHOST_MAX_ZEROCOPY_PEND)
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
@@ -188,17 +203,37 @@ static void handle_tx(struct vhost_net *net)
 			       iov_length(vq->hdr, s), hdr_size);
 			break;
 		}
+		/* use msg_control to pass vhost zerocopy ubuf info to skb */
+		if (sock_flag(sock->sk, SOCK_ZEROCOPY)) {
+			vq->heads[vq->upend_idx].id = head;
+			if (len <= VHOST_GOODCOPY_LEN)
+				/* copy don't need to wait for DMA done */
+				vq->heads[vq->upend_idx].len =
+							VHOST_DMA_DONE_LEN;
+			else {
+				vq->heads[vq->upend_idx].len = len;
+				pend.callback = vhost_zerocopy_callback;
+				pend.arg = vq;
+				pend.desc = vq->upend_idx;
+				msg.msg_control = &pend;
+				msg.msg_controllen = sizeof(pend);
+			}
+			atomic_inc(&vq->refcnt);
+			vq->upend_idx = (vq->upend_idx + 1) % UIO_MAXIOV;
+		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
 		err = sock->ops->sendmsg(NULL, sock, &msg, len);
 		if (unlikely(err < 0)) {
-			vhost_discard_vq_desc(vq, 1);
+			if (!sock_flag(sock->sk, SOCK_ZEROCOPY))
+				vhost_discard_vq_desc(vq, 1);
 			tx_poll_start(net, sock);
 			break;
 		}
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
-		vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		if (!sock_flag(sock->sk, SOCK_ZEROCOPY))
+			vhost_add_used_and_signal(&net->dev, vq, head, 0);
 		total_len += len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ab2912..1a40310 100644
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
@@ -385,16 +388,62 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
 	return 0;
 }
 
+/* Since we need to keep the order of used_idx as avail_idx, it's possible that
+ * DMA done not in order in lower device driver for some reason. To prevent
+ * used_idx out of order, upend_idx is used to track avail_idx order, done_idx
+ * is used to track used_idx order. Once lower device DMA done, then upend_idx
+ * can move to done_idx.
+ */
+void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq, bool shutdown)
+{
+	int i, j = 0;
+
+	i = vq->done_idx;
+	while (i != vq->upend_idx) {
+		if ((vq->heads[i].len == VHOST_DMA_DONE_LEN) || shutdown) {
+			/* reset len = 0 */
+			vq->heads[i].len = 0;
+			i = (i + 1) % UIO_MAXIOV;
+			++j;
+		} else
+			break;
+	}
+	if (j) {
+		/* heads is an array, i is used to tracking the last done_idx,
+		 * if last done_idx is less than current done_idx, then
+		 * add_used_n is not contiguous */
+		if (i > vq->done_idx)
+			vhost_add_used_n(vq, &vq->heads[vq->done_idx], j);
+		else {
+			vhost_add_used_n(vq, &vq->heads[vq->done_idx],
+					 UIO_MAXIOV - vq->done_idx);
+			vhost_add_used_n(vq, vq->heads, i);
+		}
+		vq->done_idx = i;
+		vhost_signal(vq->dev, vq);
+		atomic_sub(j, &vq->refcnt);
+	}
+}
+
 /* Caller should have device mutex */
 void vhost_dev_cleanup(struct vhost_dev *dev)
 {
 	int i;
+	unsigned long begin = jiffies;
 
 	for (i = 0; i < dev->nvqs; ++i) {
 		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
 			vhost_poll_stop(&dev->vqs[i].poll);
 			vhost_poll_flush(&dev->vqs[i].poll);
 		}
+		/* Wait for all lower device DMAs done, then notify virtio_net
+		 * or just notify it without waiting for all DMA done here ?
+		 * in case of DMAs never done for some reason */
+		if (atomic_read(&dev->vqs[i].refcnt)) {
+			/* how long should we wait ? */
+			msleep(1000);
+			vhost_zerocopy_signal_used(&dev->vqs[i], true);
+		}
 		if (dev->vqs[i].error_ctx)
 			eventfd_ctx_put(dev->vqs[i].error_ctx);
 		if (dev->vqs[i].error)
@@ -1416,3 +1465,12 @@ void vhost_disable_notify(struct vhost_virtqueue *vq)
 		vq_err(vq, "Failed to enable notification at %p: %d\n",
 		       &vq->used->flags, r);
 }
+
+void vhost_zerocopy_callback(struct sk_buff *skb)
+{
+	int idx = skb_shinfo(skb)->ubuf.desc;
+	struct vhost_virtqueue *vq = skb_shinfo(skb)->ubuf.arg;
+
+	/* set len = 1 to mark this desc buffers done DMA */
+	vq->heads[idx].len = VHOST_DMA_DONE_LEN;
+}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3363ae..8e3ecc7 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -13,6 +13,10 @@
 #include <linux/virtio_ring.h>
 #include <asm/atomic.h>
 
+/* This is for zerocopy, used buffer len is set to 1 when lower device DMA
+ * done */
+#define VHOST_DMA_DONE_LEN	1
+
 struct vhost_device;
 
 struct vhost_work;
@@ -108,6 +112,12 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	/* vhost zerocopy support */
+	atomic_t refcnt; /* num of outstanding zerocopy DMAs */
+	/* copy of avail idx to monitor outstanding DMA zerocopy buffers */
+	int upend_idx;
+	/* copy of used idx to monintor DMA done zerocopy buffers */
+	int done_idx;
 };
 
 struct vhost_dev {
@@ -154,6 +164,8 @@ bool vhost_enable_notify(struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
+void vhost_zerocopy_callback(struct sk_buff *skb);
+void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq, bool shutdown);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \


