From: xiaohui.xin@intel.com
Subject: [RFC PATCH v9 14/16] Provides multiple submits and asynchronous notifications.
Date: Fri,  6 Aug 2010 17:23:42 +0800
Message-ID: <1281086624-5765-15-git-send-email-xiaohui.xin@intel.com>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-2-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-3-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-4-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-5-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-6-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-7-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-8-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-9-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-10-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-11-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-12-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-13-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-14-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281086624-5765-14-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

The vhost-net backend now only supports synchronous send/recv
operations. The patch provides multiple submits and asynchronous
notifications. This is needed for zero-copy case.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
---
 drivers/vhost/net.c   |  348 +++++++++++++++++++++++++++++++++++++++++++++----
 drivers/vhost/vhost.c |   79 +++++++++++
 drivers/vhost/vhost.h |   15 ++
 3 files changed, 414 insertions(+), 28 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index b38abc6..c4bc815 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -24,6 +24,8 @@
 #include <linux/if_arp.h>
 #include <linux/if_tun.h>
 #include <linux/if_macvlan.h>
+#include <linux/mpassthru.h>
+#include <linux/aio.h>
 
 #include <net/sock.h>
 
@@ -39,6 +41,8 @@ enum {
 	VHOST_NET_VQ_MAX = 2,
 };
 
+static struct kmem_cache *notify_cache;
+
 enum vhost_net_poll_state {
 	VHOST_NET_POLL_DISABLED = 0,
 	VHOST_NET_POLL_STARTED = 1,
@@ -49,6 +53,7 @@ struct vhost_net {
 	struct vhost_dev dev;
 	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
 	struct vhost_poll poll[VHOST_NET_VQ_MAX];
+	struct kmem_cache       *cache;
 	/* Tells us whether we are polling a socket for TX.
 	 * We only do this when socket buffer fills up.
 	 * Protected by tx vq lock. */
@@ -93,11 +98,190 @@ static void tx_poll_start(struct vhost_net *net, struct socket *sock)
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
+	int count;
+
+	struct virtio_net_hdr_mrg_rxbuf hdr = {
+		.hdr.flags = 0,
+		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
+	};
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
+					__vhost_get_desc(&net->dev, vq, vq->iov,
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
+							__vhost_get_desc(
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
+				iocb == NULL;
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
+					  struct vhost_virtqueue *vq)
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
+				  struct kiocb, ki_list);
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
 	unsigned head, out, in, s;
 	struct msghdr msg = {
 		.msg_name = NULL,
@@ -130,6 +314,8 @@ static void handle_tx(struct vhost_net *net)
 		tx_poll_stop(net);
 	vhost_hlen = vq->vhost_hlen;
 
+	handle_async_tx_events_notify(net, vq);
+
 	for (;;) {
 		head = vhost_get_desc(&net->dev, vq, vq->iov,
 				      ARRAY_SIZE(vq->iov),
@@ -138,10 +324,13 @@ static void handle_tx(struct vhost_net *net)
 		/* Nothing new?  Wait for eventfd to tell us they refilled. */
 		if (head == vq->num) {
 			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
-			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
-				tx_poll_start(net, sock);
-				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
-				break;
+			if (!is_async_vq(vq)) {
+				if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
+					tx_poll_start(net, sock);
+					set_bit(SOCK_ASYNC_NOSPACE,
+						&sock->flags);
+					break;
+				}
 			}
 			if (unlikely(vhost_enable_notify(vq))) {
 				vhost_disable_notify(vq);
@@ -158,6 +347,13 @@ static void handle_tx(struct vhost_net *net)
 		s = move_iovec_hdr(vq->iov, vq->hdr, vhost_hlen, out);
 		msg.msg_iovlen = out;
 		len = iov_length(vq->iov, out);
+
+		if (is_async_vq(vq)) {
+			iocb = create_iocb(net, vq, head);
+			if (!iocb)
+				break;
+		}
+
 		/* Sanity check */
 		if (!len) {
 			vq_err(vq, "Unexpected header len for TX: "
@@ -166,12 +362,18 @@ static void handle_tx(struct vhost_net *net)
 			break;
 		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
-		err = sock->ops->sendmsg(NULL, sock, &msg, len);
+		err = sock->ops->sendmsg(iocb, sock, &msg, len);
 		if (unlikely(err < 0)) {
+			if (is_async_vq(vq))
+				kmem_cache_free(net->cache, iocb);
 			vhost_discard_desc(vq, 1);
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
@@ -183,6 +385,8 @@ static void handle_tx(struct vhost_net *net)
 		}
 	}
 
+	handle_async_tx_events_notify(net, vq);
+
 	mutex_unlock(&vq->mutex);
 	unuse_mm(net->dev.mm);
 }
@@ -205,7 +409,8 @@ static int vhost_head_len(struct vhost_virtqueue *vq, struct sock *sk)
 static void handle_rx(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
-	unsigned in, log, s;
+	struct kiocb *iocb = NULL;
+	unsigned in, out, log, s;
 	struct vhost_log *vq_log;
 	struct msghdr msg = {
 		.msg_name = NULL,
@@ -225,25 +430,42 @@ static void handle_rx(struct vhost_net *net)
 	int err, headcount, datalen;
 	size_t vhost_hlen;
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
 
+	/* In async cases, when write log is enabled, in case the submitted
+	 * buffers did not get log info before the log enabling, so we'd
+	 * better recompute the log info when needed. We do this in
+	 * handle_async_rx_events_notify().
+	 */
+
 	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 		vq->log : NULL;
 
-	while ((datalen = vhost_head_len(vq, sock->sk))) {
-		headcount = vhost_get_desc_n(vq, vq->heads,
-					     datalen + vhost_hlen,
-					     &in, vq_log, &log);
+	handle_async_rx_events_notify(net, vq, sock);
+
+	while (is_async_vq(vq) ||
+		(datalen = vhost_head_len(vq, sock->sk)) != 0) {
+		if (is_async_vq(vq))
+			headcount =
+				vhost_get_desc(&net->dev, vq, vq->iov,
+						ARRAY_SIZE(vq->iov),
+						&out, &in,
+						vq->log, &log);
+		else
+			headcount = vhost_get_desc_n(vq, vq->heads,
+						     datalen + vhost_hlen,
+						     &in, vq_log, &log);
 		if (headcount < 0)
 			break;
 		/* OK, now we need to know about added descriptors. */
-		if (!headcount) {
+		if ((!headcount && !is_async_vq(vq)) ||
+			(headcount == vq->num && is_async_vq(vq))) {
 			if (unlikely(vhost_enable_notify(vq))) {
 				/* They have slipped one in as we were
 				 * doing that: check again. */
@@ -256,7 +478,12 @@ static void handle_rx(struct vhost_net *net)
 		}
 		/* We don't need to be notified again. */
 		/* Skip header. TODO: support TSO. */
+		if (is_async_vq(vq) && vhost_hlen == sizeof(hdr)) {
+			vq->hdr[0].iov_len = vhost_hlen;
+			goto nomove;
+		}
 		s = move_iovec_hdr(vq->iov, vq->hdr, vhost_hlen, in);
+nomove:
 		msg.msg_iovlen = in;
 		len = iov_length(vq->iov, in);
 		/* Sanity check */
@@ -266,13 +493,23 @@ static void handle_rx(struct vhost_net *net)
 			       iov_length(vq->hdr, s), vhost_hlen);
 			break;
 		}
-		err = sock->ops->recvmsg(NULL, sock, &msg,
+		if (is_async_vq(vq)) {
+			iocb = create_iocb(net, vq, headcount);
+			if (!iocb)
+				break;
+		}
+		err = sock->ops->recvmsg(iocb, sock, &msg,
 					 len, MSG_DONTWAIT | MSG_TRUNC);
 		/* TODO: Check specific error and bomb out unless EAGAIN? */
 		if (err < 0) {
+			if (is_async_vq(vq))
+				kmem_cache_free(net->cache, iocb);
 			vhost_discard_desc(vq, headcount);
 			break;
 		}
+		if (is_async_vq(vq))
+			continue;
+
 		if (err != datalen) {
 			pr_err("Discarded rx packet: "
 			       " len %d, expected %zd\n", err, datalen);
@@ -280,6 +517,9 @@ static void handle_rx(struct vhost_net *net)
 			continue;
 		}
 		len = err;
+		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF))
+			hdr.num_buffers = headcount;
+
 		err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr,
 				     vhost_hlen);
 		if (err) {
@@ -287,18 +527,7 @@ static void handle_rx(struct vhost_net *net)
 			       vq->iov->iov_base, err);
 			break;
 		}
-		/* TODO: Should check and handle checksum. */
-		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) {
-			struct iovec *iov = vhost_hlen ? vq->hdr : vq->iov;
-
-			if (memcpy_toiovecend(iov, (unsigned char *)&headcount,
-				      offsetof(typeof(hdr), num_buffers),
-				      sizeof(hdr.num_buffers))) {
-				vq_err(vq, "Failed num_buffers write");
-				vhost_discard_desc(vq, headcount);
-				break;
-			}
-		}
+
 		len += vhost_hlen;
 		vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
 					    headcount);
@@ -311,6 +540,8 @@ static void handle_rx(struct vhost_net *net)
 		}
 	}
 
+	handle_async_rx_events_notify(net, vq, sock);
+
 	mutex_unlock(&vq->mutex);
 	unuse_mm(net->dev.mm);
 }
@@ -364,6 +595,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN);
 	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
+	n->cache = NULL;
 
 	f->private_data = n;
 
@@ -427,6 +659,21 @@ static void vhost_net_flush(struct vhost_net *n)
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
@@ -443,6 +690,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
+	vhost_async_cleanup(n);
 	kfree(n);
 	return 0;
 }
@@ -494,21 +742,58 @@ static struct socket *get_tap_socket(int fd)
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
+		if (!n->cache)
+			n->cache = notify_cache;
+	}
+}
+
 static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 {
 	struct socket *sock, *oldsock;
@@ -532,12 +817,14 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
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
@@ -687,6 +974,9 @@ int vhost_net_init(void)
 	r = misc_register(&vhost_net_misc);
 	if (r)
 		goto err_reg;
+	notify_cache = kmem_cache_create("vhost_kiocb",
+					sizeof(struct kiocb), 0,
+					SLAB_HWCACHE_ALIGN, NULL);
 	return 0;
 err_reg:
 	vhost_cleanup();
@@ -700,6 +990,8 @@ void vhost_net_exit(void)
 {
 	misc_deregister(&vhost_net_misc);
 	vhost_cleanup();
+	if (notify_cache)
+		kmem_cache_destroy(notify_cache);
 }
 module_exit(vhost_net_exit);
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 118c8e0..66ff5c5 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -909,6 +909,85 @@ err:
 	return r;
 }
 
+unsigned __vhost_get_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+			   struct iovec iov[], unsigned int iov_size,
+			   unsigned int *out_num, unsigned int *in_num,
+			   struct vhost_log *log, unsigned int *log_num,
+			   unsigned int head)
+{
+	struct vring_desc desc;
+	unsigned int i, found = 0;
+	u16 last_avail_idx;
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
+		if (i >= vq->num) {
+			vq_err(vq, "Desc index is %u > %u, head = %u",
+			       i, vq->num, head);
+			return vq->num;
+		}
+		if (++found > vq->num) {
+			vq_err(vq, "Loop detected: last one at %u "
+			       "vq size %u head %u\n",
+			       i, vq->num, head);
+			return vq->num;
+		}
+		ret = copy_from_user(&desc, vq->desc + i, sizeof desc);
+		if (ret) {
+			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
+			       i, vq->desc + i);
+			return vq->num;
+		}
+		if (desc.flags & VRING_DESC_F_INDIRECT) {
+			ret = get_indirect(dev, vq, iov, iov_size,
+					   out_num, in_num,
+					   log, log_num, &desc);
+			if (ret < 0) {
+				vq_err(vq, "Failure detected "
+				       "in indirect descriptor at idx %d\n", i);
+				return vq->num;
+			}
+			continue;
+		}
+
+		ret = translate_desc(dev, desc.addr, desc.len, iov + iov_count,
+				     iov_size - iov_count);
+		if (ret < 0) {
+			vq_err(vq, "Translation failure %d descriptor idx %d\n",
+			       ret, i);
+			return vq->num;
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
+			if (*in_num) {
+				vq_err(vq, "Descriptor has out after in: "
+				       "idx %d\n", i);
+				return vq->num;
+			}
+			*out_num += ret;
+		}
+	} while ((i = next_desc(&desc)) != -1);
+
+	return head;
+}
+
 /* This looks in the virtqueue and for the first available buffer, and converts
  * it to an iovec for convenient access.  Since descriptors consist of some
  * number of output then some number of input descriptors, it's actually two
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 08d740a..54c6d0b 100644
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
@@ -98,6 +103,10 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log log[VHOST_NET_MAX_SG];
+	/* Differiate async socket for 0-copy from normal */
+	enum vhost_vq_link_state link_state;
+	struct list_head notifier;
+	spinlock_t notify_lock;
 };
 
 struct vhost_dev {
@@ -125,6 +134,11 @@ int vhost_log_access_ok(struct vhost_dev *);
 int vhost_get_desc_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
 		     int datalen, unsigned int *iovcount, struct vhost_log *log,
 		     unsigned int *log_num);
+unsigned __vhost_get_desc(struct vhost_dev *, struct vhost_virtqueue *,
+			struct iovec iov[], unsigned int iov_count,
+			unsigned int *out_num, unsigned int *in_num,
+			struct vhost_log *log, unsigned int *log_num,
+			unsigned int head);
 unsigned vhost_get_desc(struct vhost_dev *, struct vhost_virtqueue *,
 			   struct iovec iov[], unsigned int iov_count,
 			   unsigned int *out_num, unsigned int *in_num,
@@ -165,6 +179,7 @@ enum {
 static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
 {
 	unsigned acked_features = rcu_dereference(dev->acked_features);
+	acked_features |= (1 << VIRTIO_NET_F_MRG_RXBUF);
 	return acked_features & (1 << bit);
 }
 
-- 
1.5.4.4
