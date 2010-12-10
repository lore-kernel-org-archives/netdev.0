From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH V2 4/5] Add vhost zero copy callback to release guest
 kernel buffers
Date: Fri, 10 Dec 2010 02:08:27 -0800
Message-ID: <1291975707.2167.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch uses msg_control to pass vhost callback to macvtap (any better
idea to pass this in a simple way?). vhost doesn't notify guest to release
buffers until the underlying lower device DMA has done for these buffers.
This vq can not be reset if any outstanding reference.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 drivers/vhost/net.c   |   13 ++++++++++-
 drivers/vhost/vhost.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h |    7 ++++++
 3 files changed, 75 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f442668..6779a1c 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -128,6 +128,7 @@ static void handle_tx(struct vhost_net *net)
 	int err, wmem;
 	size_t hdr_size;
 	struct socket *sock;
+	struct skb_ubuf_info pend;
 
 	/* TODO: check that we are running from vhost_worker?
 	 * Not sure it's worth it, it's straight-forward enough. */
@@ -189,6 +190,13 @@ static void handle_tx(struct vhost_net *net)
 			       iov_length(vq->hdr, s), hdr_size);
 			break;
 		}
+		/* use msg_control to pass vhost zerocopy ubuf info here */
+		if (sock_flag(sock->sk, SOCK_ZEROCOPY)) {
+			pend.callback = vq->callback;
+			pend.desc = head;
+			msg.msg_control = &pend;
+			msg.msg_controllen = sizeof(pend);
+		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
 		err = sock->ops->sendmsg(NULL, sock, &msg, len);
 		if (unlikely(err < 0)) {
@@ -199,7 +207,10 @@ static void handle_tx(struct vhost_net *net)
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
-		vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		if (sock_flag(sock->sk, SOCK_ZEROCOPY))
+			vhost_zerocopy_add_used_and_signal(vq);
+		else
+			vhost_add_used_and_signal(&net->dev, vq, head, 0);
 		total_len += len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 94701ff..b0074bc 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -170,6 +170,8 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call_ctx = NULL;
 	vq->call = NULL;
 	vq->log_ctx = NULL;
+	atomic_set(&vq->refcnt, 0);
+	vq->upend_cnt = 0;
 }
 
 static int vhost_worker(void *data)
@@ -273,6 +275,9 @@ long vhost_dev_init(struct vhost_dev *dev,
 		dev->vqs[i].heads = NULL;
 		dev->vqs[i].dev = dev;
 		mutex_init(&dev->vqs[i].mutex);
+		spin_lock_init(&dev->vqs[i].zerocopy_lock);
+		dev->vqs[i].upend_cnt = 0;
+		atomic_set(&dev->vqs[i].refcnt, 0);
 		vhost_vq_reset(dev, dev->vqs + i);
 		if (dev->vqs[i].handle_kick)
 			vhost_poll_init(&dev->vqs[i].poll,
@@ -370,10 +375,37 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
 	return 0;
 }
 
+void vhost_zerocopy_add_used_and_signal(struct vhost_virtqueue *vq)
+{
+	struct vring_used_elem heads[64];
+	int count, left, mod;
+	unsigned long flags;
+
+	count = (vq->num > 64) ? 64 : vq->num;
+	mod = vq->ubuf_cnt / count;
+	/* notify guest when number of descriptors greater than count */
+	if (mod == 0)
+		return;
+	/* 
+	 * avoid holding spin lock by notifying guest x64 buffers first
+	 */
+	vhost_add_used_and_signal_n(vq->dev, vq, vq->heads, count * mod);
+	/* reset the counter when notifying guest the rest*/
+	left = vq->ubuf_cnt - mod * count;
+	if (left > 0) {
+		spin_lock_irqsave(&vq->zerocopy_lock, flags);
+		memcpy(heads, &vq->heads[mod * count], left * sizeof *vq->heads);
+		vq->ubuf_cnt = 0;
+		spin_unlock_irqrestore(&vq->zerocopy_lock, flags);
+		vhost_add_used_and_signal_n(vq->dev, vq, heads, left);
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
@@ -389,6 +421,12 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 			eventfd_ctx_put(dev->vqs[i].call_ctx);
 		if (dev->vqs[i].call)
 			fput(dev->vqs[i].call);
+		/* wait for all lower device DMAs done, then notify guest */
+		if (atomic_read(&dev->vqs[i].refcnt)) {
+			if (time_after(jiffies, begin + 5 * HZ))
+				vhost_zerocopy_add_used_and_signal(&dev->vqs[i]);
+		}
+
 		vhost_vq_reset(dev, dev->vqs + i);
 	}
 	vhost_dev_free_iovecs(dev);
@@ -1389,3 +1427,21 @@ void vhost_disable_notify(struct vhost_virtqueue *vq)
 		vq_err(vq, "Failed to enable notification at %p: %d\n",
 		       &vq->used->flags, r);
 }
+
+void vhost_zerocopy_callback(struct sk_buff *skb)
+{
+	unsigned long flags;
+	size_t head = skb_shinfo(skb)->ubuf.desc;
+	struct vhost_virtqueue *vq;
+
+	vq = (struct vhost_virtqueue *)container_of(
+					skb_shinfo(skb)->ubuf.callback,
+					struct vhost_virtqueue, callback);
+	if (vq) {
+		spin_lock_irqsave(&vq->zerocopy_lock, flags);
+		vq->heads[vq->upend_cnt].id = head;
+		++vq->upend_cnt;
+		spin_unlock_irqrestore(&vq->zerocopy_lock, flags);
+		atomic_dec(&vq->refcnt);
+	}
+}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 073d06a..42d283a 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -108,6 +108,11 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	/* vhost zerocopy */
+	atomic_t refcnt; /* num of outstanding DMAs */
+	spinlock_t zerocopy_lock;
+	int upend_cnt; /* num of buffers DMA has done, not notify guest yet */
+	void (*callback)(struct sk_buff *skb); /* notify guest DMA done */
 };
 
 struct vhost_dev {
@@ -154,6 +159,8 @@ bool vhost_enable_notify(struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
+void vhost_zerocopy_callback(struct sk_buff *skb);
+void vhost_zerocopy_add_used_and_signal(struct vhost_virtqueue *vq);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
