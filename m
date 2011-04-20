From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V3 4/8] vhost TX zero copy support
Date: Wed, 20 Apr 2011 13:07:37 -0700
Message-ID: <1303330057.19336.50.camel@localhost.localdomain>
References: <1303328216.19336.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Avi Kivity <avi@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303328216.19336.18.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
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

 drivers/vhost/net.c   |   30 +++++++++++++++++++++++++++-
 drivers/vhost/vhost.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.h |   10 +++++++++
 3 files changed, 87 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2f7c76a..1bc4536 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -32,6 +32,8 @@
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
+#define MAX_ZEROCOPY_PEND 64
+
 enum {
 	VHOST_NET_VQ_RX = 0,
 	VHOST_NET_VQ_TX = 1,
@@ -129,6 +131,7 @@ static void handle_tx(struct vhost_net *net)
 	int err, wmem;
 	size_t hdr_size;
 	struct socket *sock;
+	struct skb_ubuf_info pend;
 
 	/* TODO: check that we are running from vhost_worker? */
 	sock = rcu_dereference_check(vq->private_data, 1);
@@ -151,6 +154,10 @@ static void handle_tx(struct vhost_net *net)
 	hdr_size = vq->vhost_hlen;
 
 	for (;;) {
+		/* Release DMAs done buffers first */
+		if (sock_flag(sock->sk, SOCK_ZEROCOPY))
+			vhost_zerocopy_signal_used(vq);
+
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
@@ -166,6 +173,12 @@ static void handle_tx(struct vhost_net *net)
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
+			/* If more outstanding DMAs, queue the work */
+			if (sock_flag(sock->sk, SOCK_ZEROCOPY) &&
+			    (atomic_read(&vq->refcnt) > MAX_ZEROCOPY_PEND)) {
+				vhost_poll_queue(&vq->poll);
+				break;
+			}
 			if (unlikely(vhost_enable_notify(vq))) {
 				vhost_disable_notify(vq);
 				continue;
@@ -188,17 +201,30 @@ static void handle_tx(struct vhost_net *net)
 			       iov_length(vq->hdr, s), hdr_size);
 			break;
 		}
+		/* use msg_control to pass vhost zerocopy ubuf info to skb */
+		if (sock_flag(sock->sk, SOCK_ZEROCOPY)) {
+			pend.callback = vhost_zerocopy_callback;
+			pend.arg = vq;
+			pend.desc = vq->upend_idx;
+			msg.msg_control = &pend;
+			msg.msg_controllen = sizeof(pend);
+			vq->heads[vq->upend_idx].id = head;
+			vq->upend_idx = (vq->upend_idx + 1) % UIO_MAXIOV;
+			atomic_inc(&vq->refcnt);
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
index 2ab2912..09bcb1d 100644
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
@@ -230,7 +233,7 @@ static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
 					       UIO_MAXIOV, GFP_KERNEL);
 		dev->vqs[i].log = kmalloc(sizeof *dev->vqs[i].log * UIO_MAXIOV,
 					  GFP_KERNEL);
-		dev->vqs[i].heads = kmalloc(sizeof *dev->vqs[i].heads *
+		dev->vqs[i].heads = kzalloc(sizeof *dev->vqs[i].heads *
 					    UIO_MAXIOV, GFP_KERNEL);
 
 		if (!dev->vqs[i].indirect || !dev->vqs[i].log ||
@@ -385,10 +388,41 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
 	return 0;
 }
 
+void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
+{
+	int i, j = 0;
+
+	i = vq->done_idx;
+	while (i != vq->upend_idx) {
+		/* len = 1 means DMA done */
+		if (vq->heads[i].len == 1) {
+			/* reset len = 0 */
+			vq->heads[i].len = 0;
+			i = (i + 1) % UIO_MAXIOV;
+			++j;
+		} else
+			break;
+	}
+	if (j) {
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
+
 
 	for (i = 0; i < dev->nvqs; ++i) {
 		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
@@ -405,6 +439,11 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 			eventfd_ctx_put(dev->vqs[i].call_ctx);
 		if (dev->vqs[i].call)
 			fput(dev->vqs[i].call);
+		/* wait for all lower device DMAs done, then notify guest */
+		while (atomic_read(&dev->vqs[i].refcnt)) {
+			if (time_after(jiffies, begin + 5 * HZ))
+				vhost_zerocopy_signal_used(&dev->vqs[i]);
+		}
 		vhost_vq_reset(dev, dev->vqs + i);
 	}
 	vhost_dev_free_iovecs(dev);
@@ -1416,3 +1455,12 @@ void vhost_disable_notify(struct vhost_virtqueue *vq)
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
+	vq->heads[idx].len = 1;
+}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3363ae..cd2febb 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -108,6 +108,14 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	/* vhost zerocopy support */
+	atomic_t refcnt; /* num of outstanding zerocopy DMAs */
+	/* index of zerocopy pending DMA buffers */
+	int upend_idx;
+	/* index of zerocopy done DMA buffers, but not notify guest yet */
+	int done_idx;
+	/* notify vhost zerocopy DMA buffers has done in lower device */
+	void (*callback)(struct sk_buff *);
 };
 
 struct vhost_dev {
@@ -154,6 +162,8 @@ bool vhost_enable_notify(struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
+void vhost_zerocopy_callback(struct sk_buff *skb);
+void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
