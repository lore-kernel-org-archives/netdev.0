From: xiaohui.xin@intel.com
Subject: [PATCH v13 14/16]Provides multiple submits and asynchronous notifications.
Date: Fri, 15 Oct 2010 17:12:15 +0800
Message-ID: <4512d4f5e9dc72dc6c1529988234386f3b7380c6.1287132437.git.xiaohui.xin@intel.com>
References: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

    The vhost-net backend now only supports synchronous send/recv
    operations. The patch provides multiple submits and asynchronous
    notifications. This is needed for zero-copy case.

    Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
---
 drivers/vhost/net.c   |  355 +++++++++++++++++++++++++++++++++++++++++++++----
 drivers/vhost/vhost.c |   78 +++++++++++
 drivers/vhost/vhost.h |   15 ++-
 3 files changed, 423 insertions(+), 25 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 7c80082..17c599a 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -24,6 +24,8 @@
 #include <linux/if_arp.h>
 #include <linux/if_tun.h>
 #include <linux/if_macvlan.h>
+#include <linux/mpassthru.h>
+#include <linux/aio.h>
 
 #include <net/sock.h>
 
@@ -32,6 +34,7 @@
 /* Max number of bytes transferred before requeueing the job.
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
+static struct kmem_cache *notify_cache;
 
 enum {
 	VHOST_NET_VQ_RX = 0,
@@ -49,6 +52,7 @@ struct vhost_net {
 	struct vhost_dev dev;
 	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
 	struct vhost_poll poll[VHOST_NET_VQ_MAX];
+	struct kmem_cache *cache;
 	/* Tells us whether we are polling a socket for TX.
 	 * We only do this when socket buffer fills up.
 	 * Protected by tx vq lock. */
@@ -109,11 +113,184 @@ static void tx_poll_start(struct vhost_net *net, struct socket *sock)
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
+		struct vhost_virtqueue *vq,
+		struct socket *sock)
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
+		if (!iocb->ki_left) {
+			vhost_add_used_and_signal(&net->dev, vq,
+					iocb->ki_pos, iocb->ki_nbytes);
+			size = iocb->ki_nbytes;
+			head = iocb->ki_pos;
+			rx_total_len += iocb->ki_nbytes;
+
+			if (iocb->ki_dtor)
+				iocb->ki_dtor(iocb);
+			kmem_cache_free(net->cache, iocb);
+
+			/* when log is enabled, recomputing the log is needed,
+			 * since these buffers are in async queue, may not get
+			 * the log info before.
+			 */
+			if (unlikely(vq_log)) {
+				if (!log)
+					__vhost_get_vq_desc(&net->dev, vq,
+							vq->iov,
+							ARRAY_SIZE(vq->iov),
+							&out, &in, vq_log,
+							&log, head);
+				vhost_log_write(vq, vq_log, log, size);
+			}
+			if (unlikely(rx_total_len >= VHOST_NET_WEIGHT)) {
+				vhost_poll_queue(&vq->poll);
+				break;
+			}
+		} else {
+			int i = 0;
+			int count = iocb->ki_left;
+			int hc = count;
+			while (count--) {
+				if (iocb) {
+					vq->heads[i].id = iocb->ki_pos;
+					vq->heads[i].len = iocb->ki_nbytes;
+					size = iocb->ki_nbytes;
+					head = iocb->ki_pos;
+					rx_total_len += iocb->ki_nbytes;
+
+					if (iocb->ki_dtor)
+						iocb->ki_dtor(iocb);
+					kmem_cache_free(net->cache, iocb);
+
+					if (unlikely(vq_log)) {
+						if (!log)
+							__vhost_get_vq_desc(
+							&net->dev, vq, vq->iov,
+							ARRAY_SIZE(vq->iov),
+							&out, &in, vq_log,
+							&log, head);
+						vhost_log_write(
+							vq, vq_log, log, size);
+					}
+				} else
+					break;
+
+				i++;
+				if (count)
+					iocb = notify_dequeue(vq);
+			}
+			vhost_add_used_and_signal_n(
+					&net->dev, vq, vq->heads, hc);
+		}
+	}
+}
+
+static void handle_async_tx_events_notify(struct vhost_net *net,
+		struct vhost_virtqueue *vq)
+{
+	struct kiocb *iocb = NULL;
+	struct list_head *entry, *tmp;
+	unsigned long flags;
+	int tx_total_len = 0;
+
+	if (!is_async_vq(vq))
+		return;
+
+	spin_lock_irqsave(&vq->notify_lock, flags);
+	list_for_each_safe(entry, tmp, &vq->notifier) {
+		iocb = list_entry(entry,
+				struct kiocb, ki_list);
+		if (!iocb->ki_flags)
+			continue;
+		list_del(&iocb->ki_list);
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
+	spin_unlock_irqrestore(&vq->notify_lock, flags);
+}
+
+static struct kiocb *create_iocb(struct vhost_net *net,
+		struct vhost_virtqueue *vq,
+		unsigned head)
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
+	if (vq == &net->dev.vqs[VHOST_NET_VQ_RX])
+		iocb->ki_user_data = vq->num;
+	iocb->ki_iovec = vq->hdr;
+	return iocb;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_tx(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
+	struct kiocb *iocb = NULL;
 	unsigned out, in, s;
 	int head;
 	struct msghdr msg = {
@@ -146,6 +323,10 @@ static void handle_tx(struct vhost_net *net)
 	if (wmem < sock->sk->sk_sndbuf / 2)
 		tx_poll_stop(net);
 	hdr_size = vq->vhost_hlen;
+	if (!vq->vhost_hlen && is_async_vq(vq))
+		hdr_size = vq->sock_hlen;
+
+	handle_async_tx_events_notify(net, vq);
 
 	for (;;) {
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
@@ -157,11 +338,14 @@ static void handle_tx(struct vhost_net *net)
 			break;
 		/* Nothing new?  Wait for eventfd to tell us they refilled. */
 		if (head == vq->num) {
-			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
-			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
-				tx_poll_start(net, sock);
-				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
-				break;
+			if (!is_async_vq(vq)) {
+				wmem = atomic_read(&sock->sk->sk_wmem_alloc);
+				if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
+					tx_poll_start(net, sock);
+					set_bit(SOCK_ASYNC_NOSPACE,
+					&sock->flags);
+					break;
+				}
 			}
 			if (unlikely(vhost_enable_notify(vq))) {
 				vhost_disable_notify(vq);
@@ -178,6 +362,13 @@ static void handle_tx(struct vhost_net *net)
 		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
 		msg.msg_iovlen = out;
 		len = iov_length(vq->iov, out);
+		/* if async operations supported */
+		if (is_async_vq(vq)) {
+			iocb = create_iocb(net, vq, head);
+			if (!iocb)
+				break;
+		}
+
 		/* Sanity check */
 		if (!len) {
 			vq_err(vq, "Unexpected header len for TX: "
@@ -186,12 +377,18 @@ static void handle_tx(struct vhost_net *net)
 			break;
 		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
-		err = sock->ops->sendmsg(NULL, sock, &msg, len);
+		err = sock->ops->sendmsg(iocb, sock, &msg, len);
 		if (unlikely(err < 0)) {
+			if (is_async_vq(vq))
+				kmem_cache_free(net->cache, iocb);
 			vhost_discard_vq_desc(vq, 1);
 			tx_poll_start(net, sock);
 			break;
 		}
+
+		if (is_async_vq(vq))
+			continue;
+
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
@@ -203,6 +400,8 @@ static void handle_tx(struct vhost_net *net)
 		}
 	}
 
+	handle_async_tx_events_notify(net, vq);
+
 	mutex_unlock(&vq->mutex);
 	unuse_mm(net->dev.mm);
 }
@@ -396,7 +595,8 @@ static void handle_rx_big(struct vhost_net *net)
 static void handle_rx_mergeable(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
-	unsigned uninitialized_var(in), log;
+	unsigned uninitialized_var(in), log, out;
+	struct kiocb *iocb;
 	struct vhost_log *vq_log;
 	struct msghdr msg = {
 		.msg_name = NULL,
@@ -417,28 +617,44 @@ static void handle_rx_mergeable(struct vhost_net *net)
 	size_t vhost_hlen, sock_hlen;
 	size_t vhost_len, sock_len;
 	struct socket *sock = rcu_dereference(vq->private_data);
-	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
+	if (!sock || (skb_queue_empty(&sock->sk->sk_receive_queue) &&
+		      !is_async_vq(vq)))
 		return;
-
 	use_mm(net->dev.mm);
 	mutex_lock(&vq->mutex);
 	vhost_disable_notify(vq);
 	vhost_hlen = vq->vhost_hlen;
 	sock_hlen = vq->sock_hlen;
 
+	/* In async cases, when write log is enabled, in case the submitted
+	 * buffers did not get log info before the log enabling, so we'd
+	 * better recompute the log info when needed. We do this in
+	 * handle_async_rx_events_notify().
+	 */
+
 	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 		vq->log : NULL;
 
-	while ((sock_len = peek_head_len(sock->sk))) {
-		sock_len += sock_hlen;
-		vhost_len = sock_len + vhost_hlen;
-		headcount = get_rx_bufs(vq, vq->heads, vhost_len,
+	handle_async_rx_events_notify(net, vq, sock);
+
+	while (is_async_vq(vq) || (sock_len = peek_head_len(sock->sk))) {
+		if (is_async_vq(vq))
+			headcount = vhost_get_vq_desc(&net->dev, vq, vq->iov,
+						      ARRAY_SIZE(vq->iov),
+						      &out, &in,
+						      vq->log, &log);
+		else {
+			sock_len += sock_hlen;
+			vhost_len = sock_len + vhost_hlen;
+			headcount = get_rx_bufs(vq, vq->heads, vhost_len,
 					&in, vq_log, &log);
+		}
 		/* On error, stop handling until the next kick. */
 		if (unlikely(headcount < 0))
 			break;
 		/* OK, now we need to know about added descriptors. */
-		if (!headcount) {
+		if ((!headcount && !is_async_vq(vq)) ||
+			(headcount == vq->num && is_async_vq(vq))) {
 			if (unlikely(vhost_enable_notify(vq))) {
 				/* They have slipped one in as we were
 				 * doing that: check again. */
@@ -450,16 +666,41 @@ static void handle_rx_mergeable(struct vhost_net *net)
 			break;
 		}
 		/* We don't need to be notified again. */
-		if (unlikely((vhost_hlen)))
-			/* Skip header. TODO: support TSO. */
-			move_iovec_hdr(vq->iov, vq->hdr, vhost_hlen, in);
-		else
-			/* Copy the header for use in VIRTIO_NET_F_MRG_RXBUF:
-			 * needed because sendmsg can modify msg_iov. */
-			copy_iovec_hdr(vq->iov, vq->hdr, sock_hlen, in);
+		if (unlikely((vhost_hlen))) {
+			if (is_async_vq(vq))
+				vq->hdr[0].iov_len = vhost_hlen;
+			else
+				/* Skip header. TODO: support TSO. */
+				move_iovec_hdr(vq->iov, vq->hdr,
+						vhost_hlen, in);
+		} else {
+			if (is_async_vq(vq))
+				vq->hdr[0].iov_len = sock_hlen;
+			else
+				/* Copy the header for use in
+				 * VIRTIO_NET_F_MRG_RXBUF:
+				 * needed because sendmsg can
+				 * modify msg_iov. */
+				copy_iovec_hdr(vq->iov, vq->hdr,
+						sock_hlen, in);
+		}
 		msg.msg_iovlen = in;
-		err = sock->ops->recvmsg(NULL, sock, &msg,
+		if (is_async_vq(vq)) {
+			iocb = create_iocb(net, vq, headcount);
+			if (!iocb)
+				break;
+		}
+		err = sock->ops->recvmsg(iocb, sock, &msg,
 					 sock_len, MSG_DONTWAIT | MSG_TRUNC);
+		if (is_async_vq(vq)) {
+			if (err < 0) {
+				kmem_cache_free(net->cache, iocb);
+				vhost_discard_vq_desc(vq, headcount);
+				break;
+			}
+			continue;
+		}
+
 		/* Userspace might have consumed the packet meanwhile:
 		 * it's not supposed to do this usually, but might be hard
 		 * to prevent. Discard data we got (if any) and keep going. */
@@ -496,6 +737,8 @@ static void handle_rx_mergeable(struct vhost_net *net)
 		}
 	}
 
+	handle_async_rx_events_notify(net, vq, sock);
+
 	mutex_unlock(&vq->mutex);
 	unuse_mm(net->dev.mm);
 }
@@ -561,6 +804,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
 	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
+	n->cache = NULL;
 
 	f->private_data = n;
 
@@ -624,6 +868,21 @@ static void vhost_net_flush(struct vhost_net *n)
 	vhost_net_flush_vq(n, VHOST_NET_VQ_RX);
 }
 
+static void vhost_async_cleanup(struct vhost_net *n)
+{
+	/* clean the notifier */
+	struct vhost_virtqueue *vq;
+	struct kiocb *iocb = NULL;
+	if (n->cache) {
+		vq = &n->dev.vqs[VHOST_NET_VQ_RX];
+		while ((iocb = notify_dequeue(vq)) != NULL)
+			kmem_cache_free(n->cache, iocb);
+		vq = &n->dev.vqs[VHOST_NET_VQ_TX];
+		while ((iocb = notify_dequeue(vq)) != NULL)
+			kmem_cache_free(n->cache, iocb);
+	}
+}
+
 static int vhost_net_release(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = f->private_data;
@@ -640,6 +899,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
+	vhost_async_cleanup(n);
 	kfree(n);
 	return 0;
 }
@@ -691,21 +951,61 @@ static struct socket *get_tap_socket(int fd)
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
+	/* If we dont' have notify_cache, then dont do mpassthru */
+	if (!notify_cache)
+		return ERR_PTR(-ENOTSOCK);
+	/* If we don't have mergeable buffer then dont do mpassthru */
+	if (vhost_has_feature(vq->dev, VIRTIO_NET_F_MRG_RXBUF)) {
+		sock = get_mp_socket(fd);
+		if (!IS_ERR(sock)) {
+			*state = VHOST_VQ_LINK_ASYNC;
+			return sock;
+		}
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
+		if (!n->cache)
+			n->cache = notify_cache;
+	}
+}
+
 static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 {
 	struct socket *sock, *oldsock;
@@ -729,12 +1029,14 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
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
 	if (sock != oldsock) {
@@ -879,6 +1181,9 @@ static struct miscdevice vhost_net_misc = {
 
 static int vhost_net_init(void)
 {
+	notify_cache = kmem_cache_create("vhost_kiocb",
+					sizeof(struct kiocb), 0,
+					SLAB_HWCACHE_ALIGN, NULL);
 	return misc_register(&vhost_net_misc);
 }
 module_init(vhost_net_init);
@@ -886,6 +1191,8 @@ module_init(vhost_net_init);
 static void vhost_net_exit(void)
 {
 	misc_deregister(&vhost_net_misc);
+	if (notify_cache)
+		kmem_cache_destroy(notify_cache);
 }
 module_exit(vhost_net_exit);
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index dd3d6f7..295d9ab 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1015,6 +1015,84 @@ static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 	return 0;
 }
 
+/* To recompute the log */
+int __vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+			struct iovec iov[], unsigned int iov_size,
+			unsigned int *out_num, unsigned int *in_num,
+			struct vhost_log *log, unsigned int *log_num,
+			unsigned int head)
+{
+	struct vring_desc desc;
+	unsigned int i, found = 0;
+	int ret;
+
+	/* When we start there are none of either input nor output. */
+	*out_num = *in_num = 0;
+	if (unlikely(log))
+		*log_num = 0;
+
+	i = head;
+	do {
+		unsigned iov_count = *in_num + *out_num;
+		if (unlikely(i >= vq->num)) {
+			vq_err(vq, "Desc index is %u > %u, head = %u",
+					i, vq->num, head);
+			return -EINVAL;
+		}
+		if (unlikely(++found > vq->num)) {
+			vq_err(vq, "Loop detected: last one at %u "
+					"vq size %u head %u\n",
+					i, vq->num, head);
+			return -EINVAL;
+		}
+		ret = copy_from_user(&desc, vq->desc + i, sizeof desc);
+		if (unlikely(ret)) {
+			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
+					i, vq->desc + i);
+			return -EFAULT;
+		}
+		if (desc.flags & VRING_DESC_F_INDIRECT) {
+			ret = get_indirect(dev, vq, iov, iov_size,
+					out_num, in_num,
+					log, log_num, &desc);
+			if (unlikely(ret < 0)) {
+				vq_err(vq, "Failure detected "
+				       "in indirect descriptor at idx %d\n", i);
+				return ret;
+			}
+			continue;
+		}
+
+		ret = translate_desc(dev, desc.addr, desc.len, iov + iov_count,
+				iov_size - iov_count);
+		if (unlikely(ret < 0)) {
+			vq_err(vq, "Translation failure %d descriptor idx %d\n",
+					ret, i);
+			return ret;
+		}
+		if (desc.flags & VRING_DESC_F_WRITE) {
+			/* If this is an input descriptor,
+			 * increment that count. */
+			*in_num += ret;
+			if (unlikely(log)) {
+				log[*log_num].addr = desc.addr;
+				log[*log_num].len = desc.len;
+				++*log_num;
+			}
+		} else {
+			/* If it's an output descriptor, they're all supposed
+			 * to come before any input descriptors. */
+			if (unlikely(*in_num)) {
+				vq_err(vq, "Descriptor has out after in: "
+						"idx %d\n", i);
+				return -EINVAL;
+			}
+			*out_num += ret;
+		}
+	} while ((i = next_desc(&desc)) != -1);
+
+	return head;
+}
 /* This looks in the virtqueue and for the first available buffer, and converts
  * it to an iovec for convenient access.  Since descriptors consist of some
  * number of output then some number of input descriptors, it's actually two
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index afd7729..915336d 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -55,6 +55,11 @@ struct vhost_log {
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
@@ -110,6 +115,10 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log log[VHOST_NET_MAX_SG];
+	/* Differiate async socket for 0-copy from normal */
+	enum vhost_vq_link_state link_state;
+	struct list_head notifier;
+	spinlock_t notify_lock;
 };
 
 struct vhost_dev {
@@ -136,7 +145,11 @@ void vhost_dev_cleanup(struct vhost_dev *);
 long vhost_dev_ioctl(struct vhost_dev *, unsigned int ioctl, unsigned long arg);
 int vhost_vq_access_ok(struct vhost_virtqueue *vq);
 int vhost_log_access_ok(struct vhost_dev *);
-
+int __vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
+			  struct iovec iov[], unsigned int iov_count,
+			  unsigned int *out_num, unsigned int *in_num,
+			  struct vhost_log *log, unsigned int *log_num,
+			  unsigned int head);
 int vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
 		      struct iovec iov[], unsigned int iov_count,
 		      unsigned int *out_num, unsigned int *in_num,
-- 
1.7.3

