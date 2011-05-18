From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V6 4/6 net-next] vhost: vhost TX zero-copy support
Date: Tue, 17 May 2011 23:16:23 -0700
Message-ID: <1305699383.10756.100.camel@localhost.localdomain>
References: <1305574484.3456.30.camel@localhost.localdomain>
	 <20110516204540.GD18148@redhat.com>
	 <1305579414.3456.49.camel@localhost.localdomain>
	 <20110516212401.GF18148@redhat.com>
	 <1305606683.10756.3.camel@localhost.localdomain>
	 <20110517055503.GA26989@redhat.com>
	 <1305645734.10756.14.camel@localhost.localdomain>
	 <20110517152840.GA2389@redhat.com>
	 <1305646444.10756.16.camel@localhost.localdomain>
	 <1305665419.10756.33.camel@localhost.localdomain>
	 <20110517212827.GC7589@redhat.com>
	 <1305695674.10756.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1305695674.10756.93.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

Here is the update the patch based on all of your review comments except
the completion/wait for cleanup since I am worried about outstanding
DMAs would prevent vhost from shutting down. I am sending out this for
your review, and test it out later.

For error handling, I update macvtap.c so we can discard the desc even
in zero-copy case.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 drivers/vhost/net.c   |   42 +++++++++++++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h |   13 +++++++++++++
 3 files changed, 103 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2f7c76a..e87a1f8 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -32,6 +32,10 @@
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
+/* MAX number of TX used buffers for outstanding zerocopy */
+#define VHOST_MAX_PEND 128
+#define VHOST_GOODCOPY_LEN PAGE_SIZE
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
@@ -188,6 +203,30 @@ static void handle_tx(struct vhost_net *net)
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
+				vq->heads[vq->upend_idx].len = len;
+				pend.callback = vhost_zerocopy_callback;
+				pend.arg = vq;
+				pend.desc = vq->upend_idx;
+				msg.msg_control = &pend;
+				msg.msg_controllen = sizeof(pend);
+			}
+			atomic_inc(&vq->refcnt);
+			vq->upend_idx = (vq->upend_idx + 1) % UIO_MAXIOV;
+			/* if upend_idx is full, then wait for free more */
+			if (vq->upend_idx == vq->done_idx) {
+				tx_poll_start(net, sock);
+				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+				break;
+			}
+		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
 		err = sock->ops->sendmsg(NULL, sock, &msg, len);
 		if (unlikely(err < 0)) {
@@ -198,7 +237,8 @@ static void handle_tx(struct vhost_net *net)
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
index 2ab2912..f4c2730 100644
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
@@ -385,16 +388,49 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
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
+	for (i = vq->done_idx; i != vq->upend_idx; i = i++ % UIO_MAXIOV) {
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
@@ -603,6 +639,10 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 
 	mutex_lock(&vq->mutex);
 
+	/* clean up lower device outstanding DMAs, before setting ring */
+	if (atomic_read(&vq->refcnt))
+		vhost_zerocopy_signal_used(vq, true);
+
 	switch (ioctl) {
 	case VHOST_SET_VRING_NUM:
 		/* Resizing ring with an active backend?
@@ -1416,3 +1456,12 @@ void vhost_disable_notify(struct vhost_virtqueue *vq)
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
index b3363ae..d0e7ac6 100644
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
@@ -108,6 +113,12 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	/* vhost zerocopy support */
+	atomic_t refcnt; /* num of outstanding zerocopy DMAs */
+	/* last used idx for outstanding DMA zerocopy buffers */
+	int upend_idx;
+	/* first used idx for DMA done zerocopy buffers */
+	int done_idx;
 };
 
 struct vhost_dev {
@@ -154,6 +165,8 @@ bool vhost_enable_notify(struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
+void vhost_zerocopy_callback(struct sk_buff *skb);
+void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq, bool shutdown);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \



