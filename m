From: xiaohui.xin@intel.com
Subject: Re:[RFC][PATCH v3 2/3] Provides multiple submits and asynchronous notifications.
Date: Fri, 23 Apr 2010 15:08:33 +0800
Message-ID: <1272006513-5188-1-git-send-email-xiaohui.xin@intel.com>
References: <20100422094951.GB30532@redhat.com>
Cc: arnd@arndb.de, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	jdike@linux.intel.com, Xin Xiaohui <xiaohui.xin@intel.com>
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100422094951.GB30532@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

The vhost-net backend now only supports synchronous send/recv
operations. The patch provides multiple submits and asynchronous
notifications. This is needed for zero-copy case.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
---

Michael,
>>>Can't vhost supply a kiocb completion callback that will handle the list?
>>Yes, thanks. And with it I also remove the vq->receivr finally.
>>Thanks
>>Xiaohui

>Nice progress. I commented on some minor issues below.
>Thanks!

The updated patch addressed your comments on the minor issues.
Thanks!

Thanks
Xiaohui  

 drivers/vhost/net.c   |  236 +++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.c |  120 ++++++++++++++-----------
 drivers/vhost/vhost.h |   14 +++
 3 files changed, 314 insertions(+), 56 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 38989d1..18f6c41 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -23,6 +23,8 @@
 #include <linux/if_arp.h>
 #include <linux/if_tun.h>
 #include <linux/if_macvlan.h>
+#include <linux/mpassthru.h>
+#include <linux/aio.h>
 
 #include <net/sock.h>
 
@@ -48,6 +50,7 @@ struct vhost_net {
 	struct vhost_dev dev;
 	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
 	struct vhost_poll poll[VHOST_NET_VQ_MAX];
+	struct kmem_cache       *cache;
 	/* Tells us whether we are polling a socket for TX.
 	 * We only do this when socket buffer fills up.
 	 * Protected by tx vq lock. */
@@ -92,11 +95,138 @@ static void tx_poll_start(struct vhost_net *net, struct socket *sock)
 	net->tx_poll_state = VHOST_NET_POLL_STARTED;
 }
 
+struct kiocb *notify_dequeue(struct vhost_virtqueue *vq)
+{
+	struct kiocb *iocb = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&vq->notify_lock, flags);
+	if (!list_empty(&vq->notifier)) {
+		iocb = list_first_entry(&vq->notifier,
+				struct kiocb, ki_list);
+		list_del(&iocb->ki_list);
+	}
+	spin_unlock_irqrestore(&vq->notify_lock, flags);
+	return iocb;
+}
+
+static void handle_iocb(struct kiocb *iocb)
+{
+	struct vhost_virtqueue *vq = iocb->private;
+	unsigned long flags;
+
+	spin_lock_irqsave(&vq->notify_lock, flags);
+	list_add_tail(&iocb->ki_list, &vq->notifier);
+	spin_unlock_irqrestore(&vq->notify_lock, flags);
+}
+
+static int is_async_vq(struct vhost_virtqueue *vq)
+{
+	return (vq->link_state == VHOST_VQ_LINK_ASYNC);
+}
+
+static void handle_async_rx_events_notify(struct vhost_net *net,
+					  struct vhost_virtqueue *vq,
+					  struct socket *sock)
+{
+	struct kiocb *iocb = NULL;
+	struct vhost_log *vq_log = NULL;
+	int rx_total_len = 0;
+	unsigned int head, log, in, out;
+	int size;
+
+	if (!is_async_vq(vq))
+		return;
+
+	if (sock->sk->sk_data_ready)
+		sock->sk->sk_data_ready(sock->sk, 0);
+
+	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
+		vq->log : NULL;
+
+	while ((iocb = notify_dequeue(vq)) != NULL) {
+		vhost_add_used_and_signal(&net->dev, vq,
+				iocb->ki_pos, iocb->ki_nbytes);
+		size = iocb->ki_nbytes;
+		head = iocb->ki_pos;
+		rx_total_len += iocb->ki_nbytes;
+
+		if (iocb->ki_dtor)
+			iocb->ki_dtor(iocb);
+		kmem_cache_free(net->cache, iocb);
+
+		/* when log is enabled, recomputing the log info is needed,
+		 * since these buffers are in async queue, and may not get
+		 * the log info before.
+		 */
+		if (unlikely(vq_log)) {
+			if (!log)
+				__vhost_get_vq_desc(&net->dev, vq, vq->iov,
+						    ARRAY_SIZE(vq->iov),
+						    &out, &in, vq_log,
+						    &log, head);
+			vhost_log_write(vq, vq_log, log, size);
+		}
+		if (unlikely(rx_total_len >= VHOST_NET_WEIGHT)) {
+			vhost_poll_queue(&vq->poll);
+			break;
+		}
+	}
+}
+
+static void handle_async_tx_events_notify(struct vhost_net *net,
+					  struct vhost_virtqueue *vq)
+{
+	struct kiocb *iocb = NULL;
+	int tx_total_len = 0;
+
+	if (!is_async_vq(vq))
+		return;
+
+	while ((iocb = notify_dequeue(vq)) != NULL) {
+		vhost_add_used_and_signal(&net->dev, vq,
+				iocb->ki_pos, 0);
+		tx_total_len += iocb->ki_nbytes;
+
+		if (iocb->ki_dtor)
+			iocb->ki_dtor(iocb);
+
+		kmem_cache_free(net->cache, iocb);
+		if (unlikely(tx_total_len >= VHOST_NET_WEIGHT)) {
+			vhost_poll_queue(&vq->poll);
+			break;
+		}
+	}
+}
+
+static struct kiocb *create_iocb(struct vhost_net *net,
+				 struct vhost_virtqueue *vq,
+				 unsigned head)
+{
+	struct kiocb *iocb = NULL;
+
+	if (!is_async_vq(vq))
+		return NULL;
+
+	iocb = kmem_cache_zalloc(net->cache, GFP_KERNEL);
+	if (!iocb)
+		return NULL;
+	iocb->private = vq;
+	iocb->ki_pos = head;
+	iocb->ki_dtor = handle_iocb;
+	if (vq == &net->dev.vqs[VHOST_NET_VQ_RX]) {
+		iocb->ki_user_data = vq->num;
+		iocb->ki_iovec = vq->hdr;
+	}
+	return iocb;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_tx(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
+	struct kiocb *iocb = NULL;
 	unsigned head, out, in, s;
 	struct msghdr msg = {
 		.msg_name = NULL,
@@ -129,6 +259,8 @@ static void handle_tx(struct vhost_net *net)
 		tx_poll_stop(net);
 	hdr_size = vq->hdr_size;
 
+	handle_async_tx_events_notify(net, vq);
+
 	for (;;) {
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
@@ -156,6 +288,13 @@ static void handle_tx(struct vhost_net *net)
 		/* Skip header. TODO: support TSO. */
 		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
 		msg.msg_iovlen = out;
+
+		if (is_async_vq(vq)) {
+			iocb = create_iocb(net, vq, head);
+			if (!iocb)
+				break;
+		}
+
 		len = iov_length(vq->iov, out);
 		/* Sanity check */
 		if (!len) {
@@ -165,12 +304,18 @@ static void handle_tx(struct vhost_net *net)
 			break;
 		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
-		err = sock->ops->sendmsg(NULL, sock, &msg, len);
+		err = sock->ops->sendmsg(iocb, sock, &msg, len);
 		if (unlikely(err < 0)) {
+			if (is_async_vq(vq))
+				kmem_cache_free(net->cache, iocb);
 			vhost_discard_vq_desc(vq);
 			tx_poll_start(net, sock);
 			break;
 		}
+
+		if (is_async_vq(vq))
+			continue;
+
 		if (err != len)
 			pr_err("Truncated TX packet: "
 			       " len %d != %zd\n", err, len);
@@ -182,6 +327,8 @@ static void handle_tx(struct vhost_net *net)
 		}
 	}
 
+	handle_async_tx_events_notify(net, vq);
+
 	mutex_unlock(&vq->mutex);
 	unuse_mm(net->dev.mm);
 }
@@ -191,6 +338,7 @@ static void handle_tx(struct vhost_net *net)
 static void handle_rx(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
+	struct kiocb *iocb = NULL;
 	unsigned head, out, in, log, s;
 	struct vhost_log *vq_log;
 	struct msghdr msg = {
@@ -211,7 +359,8 @@ static void handle_rx(struct vhost_net *net)
 	int err;
 	size_t hdr_size;
 	struct socket *sock = rcu_dereference(vq->private_data);
-	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
+	if (!sock || (skb_queue_empty(&sock->sk->sk_receive_queue) &&
+			vq->link_state == VHOST_VQ_LINK_SYNC))
 		return;
 
 	use_mm(net->dev.mm);
@@ -219,9 +368,17 @@ static void handle_rx(struct vhost_net *net)
 	vhost_disable_notify(vq);
 	hdr_size = vq->hdr_size;
 
+	/* In async cases, when write log is enabled, in case the submitted
+	 * buffers did not get log info before the log enabling, so we'd
+	 * better recompute the log info when needed. We do this in
+	 * handle_async_rx_events_notify().
+	 */
+
 	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 		vq->log : NULL;
 
+	handle_async_rx_events_notify(net, vq, sock);
+
 	for (;;) {
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
@@ -250,6 +407,13 @@ static void handle_rx(struct vhost_net *net)
 		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
 		msg.msg_iovlen = in;
 		len = iov_length(vq->iov, in);
+
+		if (is_async_vq(vq)) {
+			iocb = create_iocb(net, vq, head);
+			if (!iocb)
+				break;
+		}
+
 		/* Sanity check */
 		if (!len) {
 			vq_err(vq, "Unexpected header len for RX: "
@@ -257,13 +421,20 @@ static void handle_rx(struct vhost_net *net)
 			       iov_length(vq->hdr, s), hdr_size);
 			break;
 		}
-		err = sock->ops->recvmsg(NULL, sock, &msg,
+
+		err = sock->ops->recvmsg(iocb, sock, &msg,
 					 len, MSG_DONTWAIT | MSG_TRUNC);
 		/* TODO: Check specific error and bomb out unless EAGAIN? */
 		if (err < 0) {
+			if (is_async_vq(vq))
+				kmem_cache_free(net->cache, iocb);
 			vhost_discard_vq_desc(vq);
 			break;
 		}
+
+		if (is_async_vq(vq))
+			continue;
+
 		/* TODO: Should check and handle checksum. */
 		if (err > len) {
 			pr_err("Discarded truncated rx packet: "
@@ -289,6 +460,8 @@ static void handle_rx(struct vhost_net *net)
 		}
 	}
 
+	handle_async_rx_events_notify(net, vq, sock);
+
 	mutex_unlock(&vq->mutex);
 	unuse_mm(net->dev.mm);
 }
@@ -342,6 +515,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN);
 	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
+	n->cache = NULL;
 
 	f->private_data = n;
 
@@ -405,6 +579,18 @@ static void vhost_net_flush(struct vhost_net *n)
 	vhost_net_flush_vq(n, VHOST_NET_VQ_RX);
 }
 
+static void vhost_async_cleanup(struct vhost_net *n)
+{
+	/* clean the notifier */
+	struct vhost_virtqueue *vq = &n->dev.vqs[VHOST_NET_VQ_RX];
+	struct kiocb *iocb = NULL;
+	if (n->cache) {
+		while ((iocb = notify_dequeue(vq)) != NULL)
+			kmem_cache_free(n->cache, iocb);
+		kmem_cache_destroy(n->cache);
+	}
+}
+
 static int vhost_net_release(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = f->private_data;
@@ -421,6 +607,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
+	vhost_async_cleanup(n);
 	kfree(n);
 	return 0;
 }
@@ -472,21 +659,58 @@ static struct socket *get_tap_socket(int fd)
 	return sock;
 }
 
-static struct socket *get_socket(int fd)
+static struct socket *get_mp_socket(int fd)
+{
+	struct file *file = fget(fd);
+	struct socket *sock;
+	if (!file)
+		return ERR_PTR(-EBADF);
+	sock = mp_get_socket(file);
+	if (IS_ERR(sock))
+		fput(file);
+	return sock;
+}
+
+static struct socket *get_socket(struct vhost_virtqueue *vq, int fd,
+				 enum vhost_vq_link_state *state)
 {
 	struct socket *sock;
 	/* special case to disable backend */
 	if (fd == -1)
 		return NULL;
+
+	*state = VHOST_VQ_LINK_SYNC;
+
 	sock = get_raw_socket(fd);
 	if (!IS_ERR(sock))
 		return sock;
 	sock = get_tap_socket(fd);
 	if (!IS_ERR(sock))
 		return sock;
+	sock = get_mp_socket(fd);
+	if (!IS_ERR(sock)) {
+		*state = VHOST_VQ_LINK_ASYNC;
+		return sock;
+	}
 	return ERR_PTR(-ENOTSOCK);
 }
 
+static void vhost_init_link_state(struct vhost_net *n, int index)
+{
+	struct vhost_virtqueue *vq = n->vqs + index;
+
+	WARN_ON(!mutex_is_locked(&vq->mutex));
+	if (vq->link_state == VHOST_VQ_LINK_ASYNC) {
+		INIT_LIST_HEAD(&vq->notifier);
+		spin_lock_init(&vq->notify_lock);
+		if (!n->cache) {
+			n->cache = kmem_cache_create("vhost_kiocb",
+					sizeof(struct kiocb), 0,
+					SLAB_HWCACHE_ALIGN, NULL);
+		}
+	}
+}
+
 static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 {
 	struct socket *sock, *oldsock;
@@ -510,12 +734,14 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 		r = -EFAULT;
 		goto err_vq;
 	}
-	sock = get_socket(fd);
+	sock = get_socket(vq, fd, &vq->link_state);
 	if (IS_ERR(sock)) {
 		r = PTR_ERR(sock);
 		goto err_vq;
 	}
 
+	vhost_init_link_state(n, index);
+
 	/* start polling new socket */
 	oldsock = vq->private_data;
 	if (sock == oldsock)
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 3f10194..add77d3 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -860,61 +860,17 @@ static unsigned get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 	return 0;
 }
 
-/* This looks in the virtqueue and for the first available buffer, and converts
- * it to an iovec for convenient access.  Since descriptors consist of some
- * number of output then some number of input descriptors, it's actually two
- * iovecs, but we pack them into one and note how many of each there were.
- *
- * This function returns the descriptor number found, or vq->num (which
- * is never a valid descriptor number) if none was found. */
-unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
-			   struct iovec iov[], unsigned int iov_size,
-			   unsigned int *out_num, unsigned int *in_num,
-			   struct vhost_log *log, unsigned int *log_num)
+/* This computes the log info according to the index of buffer */
+unsigned __vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+			     struct iovec iov[], unsigned int iov_size,
+			     unsigned int *out_num, unsigned int *in_num,
+			     struct vhost_log *log, unsigned int *log_num,
+			     unsigned int head)
 {
 	struct vring_desc desc;
 	unsigned int i, head, found = 0;
-	u16 last_avail_idx;
-	int ret;
-
-	/* Check it isn't doing very strange things with descriptor numbers. */
-	last_avail_idx = vq->last_avail_idx;
-	if (get_user(vq->avail_idx, &vq->avail->idx)) {
-		vq_err(vq, "Failed to access avail idx at %p\n",
-		       &vq->avail->idx);
-		return vq->num;
-	}
-
-	if ((u16)(vq->avail_idx - last_avail_idx) > vq->num) {
-		vq_err(vq, "Guest moved used index from %u to %u",
-		       last_avail_idx, vq->avail_idx);
-		return vq->num;
-	}
-
-	/* If there's nothing new since last we looked, return invalid. */
-	if (vq->avail_idx == last_avail_idx)
-		return vq->num;
+	unsigned int ret;
 
-	/* Only get avail ring entries after they have been exposed by guest. */
-	smp_rmb();
-
-	/* Grab the next descriptor number they're advertising, and increment
-	 * the index we've seen. */
-	if (get_user(head, &vq->avail->ring[last_avail_idx % vq->num])) {
-		vq_err(vq, "Failed to read head: idx %d address %p\n",
-		       last_avail_idx,
-		       &vq->avail->ring[last_avail_idx % vq->num]);
-		return vq->num;
-	}
-
-	/* If their number is silly, that's an error. */
-	if (head >= vq->num) {
-		vq_err(vq, "Guest says index %u > %u is available",
-		       head, vq->num);
-		return vq->num;
-	}
-
-	/* When we start there are none of either input nor output. */
 	*out_num = *in_num = 0;
 	if (unlikely(log))
 		*log_num = 0;
@@ -978,8 +934,70 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			*out_num += ret;
 		}
 	} while ((i = next_desc(&desc)) != -1);
+	return head;
+}
+
+/* This looks in the virtqueue and for the first available buffer, and converts
+ * it to an iovec for convenient access.  Since descriptors consist of some
+ * number of output then some number of input descriptors, it's actually two
+ * iovecs, but we pack them into one and note how many of each there were.
+ *
+ * This function returns the descriptor number found, or vq->num (which
+ * is never a valid descriptor number) if none was found. */
+unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+			   struct iovec iov[], unsigned int iov_size,
+			   unsigned int *out_num, unsigned int *in_num,
+			   struct vhost_log *log, unsigned int *log_num)
+{
+	struct vring_desc desc;
+	unsigned int i, head, found = 0;
+	u16 last_avail_idx;
+	unsigned int ret;
+
+	/* Check it isn't doing very strange things with descriptor numbers. */
+	last_avail_idx = vq->last_avail_idx;
+	if (get_user(vq->avail_idx, &vq->avail->idx)) {
+		vq_err(vq, "Failed to access avail idx at %p\n",
+		       &vq->avail->idx);
+		return vq->num;
+	}
+
+	if ((u16)(vq->avail_idx - last_avail_idx) > vq->num) {
+		vq_err(vq, "Guest moved used index from %u to %u",
+		       last_avail_idx, vq->avail_idx);
+		return vq->num;
+	}
+
+	/* If there's nothing new since last we looked, return invalid. */
+	if (vq->avail_idx == last_avail_idx)
+		return vq->num;
+
+	/* Only get avail ring entries after they have been exposed by guest. */
+	rmb();
+
+	/* Grab the next descriptor number they're advertising, and increment
+	 * the index we've seen. */
+	if (get_user(head, &vq->avail->ring[last_avail_idx % vq->num])) {
+		vq_err(vq, "Failed to read head: idx %d address %p\n",
+		       last_avail_idx,
+		       &vq->avail->ring[last_avail_idx % vq->num]);
+		return vq->num;
+	}
+
+	/* If their number is silly, that's an error. */
+	if (head >= vq->num) {
+		vq_err(vq, "Guest says index %u > %u is available",
+		       head, vq->num);
+		return vq->num;
+	}
+
+	ret = __vhost_get_vq_desc(dev, vq, iov, iov_size,
+				  out_num, in_num,
+				  log, log_num, head);
 
 	/* On success, increment avail index. */
+	if (ret == vq->num)
+		return ret;
 	vq->last_avail_idx++;
 	return head;
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 44591ba..3c9cbce 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -43,6 +43,11 @@ struct vhost_log {
 	u64 len;
 };
 
+enum vhost_vq_link_state {
+	VHOST_VQ_LINK_SYNC = 0,
+	VHOST_VQ_LINK_ASYNC = 1,
+};
+
 /* The virtqueue structure describes a queue attached to a device. */
 struct vhost_virtqueue {
 	struct vhost_dev *dev;
@@ -96,6 +101,10 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log log[VHOST_NET_MAX_SG];
+	/* Differiate async socket for 0-copy from normal */
+	enum vhost_vq_link_state link_state;
+	struct list_head notifier;
+	spinlock_t notify_lock;
 };
 
 struct vhost_dev {
@@ -124,6 +133,11 @@ unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
 			   struct iovec iov[], unsigned int iov_count,
 			   unsigned int *out_num, unsigned int *in_num,
 			   struct vhost_log *log, unsigned int *log_num);
+unsigned __vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
+			   struct iovec iov[], unsigned int iov_count,
+			   unsigned int *out_num, unsigned int *in_num,
+			   struct vhost_log *log, unsigned int *log_num,
+			   unsigned int head);
 void vhost_discard_vq_desc(struct vhost_virtqueue *);
 
 int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
-- 
1.5.4.4
