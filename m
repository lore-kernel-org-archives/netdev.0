From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 2/3] vhost: handle polling errors
Date: Sat,  5 Jan 2013 17:34:05 +0800
Message-ID: <1357378446-19656-3-git-send-email-jasowang@redhat.com>
References: <1357378446-19656-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357378446-19656-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, polling error were ignored in vhost. This may lead some issues (e.g
kenrel crash when passing a tap fd to vhost before calling TUNSETIFF). Fix this
by:

- extend the idea of vhost_net_poll_state to all kinds of vhost_polls
- change the state only when polling is succeed
- let vhost_poll_start() report errors to the caller. If the polling fails in 
  ioctls, the error would be report to userspace. If the polling fails in the
  data path, an error message would be logged.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c   |   75 +++++++++++++++++-------------------------------
 drivers/vhost/vhost.c |   25 +++++++++++++---
 drivers/vhost/vhost.h |   11 ++++++-
 3 files changed, 57 insertions(+), 54 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index d10ad6f..a8ed8e6 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -64,20 +64,10 @@ enum {
 	VHOST_NET_VQ_MAX = 2,
 };
 
-enum vhost_net_poll_state {
-	VHOST_NET_POLL_DISABLED = 0,
-	VHOST_NET_POLL_STARTED = 1,
-	VHOST_NET_POLL_STOPPED = 2,
-};
-
 struct vhost_net {
 	struct vhost_dev dev;
 	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
 	struct vhost_poll poll[VHOST_NET_VQ_MAX];
-	/* Tells us whether we are polling a socket for TX.
-	 * We only do this when socket buffer fills up.
-	 * Protected by tx vq lock. */
-	enum vhost_net_poll_state tx_poll_state;
 	/* Number of TX recently submitted.
 	 * Protected by tx vq lock. */
 	unsigned tx_packets;
@@ -155,24 +145,6 @@ static void copy_iovec_hdr(const struct iovec *from, struct iovec *to,
 	}
 }
 
-/* Caller must have TX VQ lock */
-static void tx_poll_stop(struct vhost_net *net)
-{
-	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
-		return;
-	vhost_poll_stop(net->poll + VHOST_NET_VQ_TX);
-	net->tx_poll_state = VHOST_NET_POLL_STOPPED;
-}
-
-/* Caller must have TX VQ lock */
-static void tx_poll_start(struct vhost_net *net, struct socket *sock)
-{
-	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
-		return;
-	vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
-	net->tx_poll_state = VHOST_NET_POLL_STARTED;
-}
-
 /* In case of DMA done not in order in lower device driver for some reason.
  * upend_idx is used to track end of used idx, done_idx is used to track head
  * of used idx. Once lower device DMA done contiguously, we will signal KVM
@@ -227,6 +199,7 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 static void handle_tx(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
+	struct vhost_poll *poll = net->poll + VHOST_NET_VQ_TX;
 	unsigned out, in, s;
 	int head;
 	struct msghdr msg = {
@@ -252,7 +225,8 @@ static void handle_tx(struct vhost_net *net)
 	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 	if (wmem >= sock->sk->sk_sndbuf) {
 		mutex_lock(&vq->mutex);
-		tx_poll_start(net, sock);
+		if (vhost_poll_start(poll, sock->file))
+			vq_err(vq, "Fail to poll TX\n");
 		mutex_unlock(&vq->mutex);
 		return;
 	}
@@ -261,7 +235,7 @@ static void handle_tx(struct vhost_net *net)
 	vhost_disable_notify(&net->dev, vq);
 
 	if (wmem < sock->sk->sk_sndbuf / 2)
-		tx_poll_stop(net);
+		vhost_poll_stop(poll);
 	hdr_size = vq->vhost_hlen;
 	zcopy = vq->ubufs;
 
@@ -283,7 +257,10 @@ static void handle_tx(struct vhost_net *net)
 
 			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
-				tx_poll_start(net, sock);
+				if (vhost_poll_start(poll, sock->file)) {
+					vq_err(vq, "Fail to poll TX\n");
+					break;
+				}
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
@@ -294,7 +271,10 @@ static void handle_tx(struct vhost_net *net)
 				    (vq->upend_idx - vq->done_idx) :
 				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
 			if (unlikely(num_pends > VHOST_MAX_PEND)) {
-				tx_poll_start(net, sock);
+				if (vhost_poll_start(poll, sock->file)) {
+					vq_err(vq, "Fail to poll TX\n");
+					break;
+				}
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
@@ -360,7 +340,8 @@ static void handle_tx(struct vhost_net *net)
 			}
 			vhost_discard_vq_desc(vq, 1);
 			if (err == -EAGAIN || err == -ENOBUFS)
-				tx_poll_start(net, sock);
+				if (vhost_poll_start(poll, sock->file))
+					vq_err(vq, "fail to poll TX\n");
 			break;
 		}
 		if (err != len)
@@ -623,7 +604,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
-	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
 
 	f->private_data = n;
 
@@ -633,29 +613,26 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 static void vhost_net_disable_vq(struct vhost_net *n,
 				 struct vhost_virtqueue *vq)
 {
+	int index = vq - n->vqs;
 	if (!vq->private_data)
 		return;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
-		tx_poll_stop(n);
-		n->tx_poll_state = VHOST_NET_POLL_DISABLED;
-	} else
-		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
+	vhost_poll_stop(n->poll + index);
 }
 
-static void vhost_net_enable_vq(struct vhost_net *n,
-				struct vhost_virtqueue *vq)
+static int vhost_net_enable_vq(struct vhost_net *n,
+			       struct vhost_virtqueue *vq)
 {
+	int err, index = vq - n->vqs;
 	struct socket *sock;
 
 	sock = rcu_dereference_protected(vq->private_data,
 					 lockdep_is_held(&vq->mutex));
 	if (!sock)
-		return;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
-		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
-		tx_poll_start(n, sock);
-	} else
-		vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
+		return 0;
+
+	n->poll[index].state = VHOST_POLL_STOPPED;
+	err = vhost_poll_start(n->poll + index, sock->file);
+	return err;
 }
 
 static struct socket *vhost_net_stop_vq(struct vhost_net *n,
@@ -833,7 +810,9 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 		r = vhost_init_used(vq);
 		if (r)
 			goto err_used;
-		vhost_net_enable_vq(n, vq);
+		r = vhost_net_enable_vq(n, vq);
+		if (r)
+			goto err_used;
 
 		oldubufs = vq->ubufs;
 		vq->ubufs = ubufs;
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 34389f7..5464ee4 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -77,26 +77,39 @@ void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
 	poll->dev = dev;
+	poll->state = VHOST_POLL_DISABLED;
 
 	vhost_work_init(&poll->work, fn);
 }
 
-/* Start polling a file. We add ourselves to file's wait queue. The caller must
- * keep a reference to a file until after vhost_poll_stop is called. */
-void vhost_poll_start(struct vhost_poll *poll, struct file *file)
+/* Start polling a file. We try to add ourselves to file's wait queue. The
+ * caller must keep a reference to a file until after vhost_poll_stop is
+ * called. The file must guarantee that ourselves were not added to the
+ * waitqueue when POLLERR were returned by poll(), vhost_poll_stop() depends on
+ * this behavior. */
+int vhost_poll_start(struct vhost_poll *poll, struct file *file)
 {
 	unsigned long mask;
+	if (unlikely(poll->state != VHOST_POLL_STOPPED))
+		return 0;
 
 	mask = file->f_op->poll(file, &poll->table);
+	if (mask & POLLERR)
+		return -EINVAL;
 	if (mask)
 		vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
+	poll->state = VHOST_POLL_STARTED;
+	return 0;
 }
 
 /* Stop polling a file. After this function returns, it becomes safe to drop the
  * file reference. You must also flush afterwards. */
 void vhost_poll_stop(struct vhost_poll *poll)
 {
+	if (likely(poll->state != VHOST_POLL_STARTED))
+		return;
 	remove_wait_queue(poll->wqh, &poll->wait);
+	poll->state = VHOST_POLL_STOPPED;
 }
 
 static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
@@ -791,8 +804,10 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 	if (filep)
 		fput(filep);
 
-	if (pollstart && vq->handle_kick)
-		vhost_poll_start(&vq->poll, vq->kick);
+	if (pollstart && vq->handle_kick) {
+		vq->poll.state = VHOST_POLL_STOPPED;
+		r = vhost_poll_start(&vq->poll, vq->kick);
+	}
 
 	mutex_unlock(&vq->mutex);
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 2639c58..4eb06e9 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -26,6 +26,12 @@ struct vhost_work {
 	unsigned		  done_seq;
 };
 
+enum vhost_poll_state {
+	VHOST_POLL_DISABLED = 0,
+	VHOST_POLL_STARTED = 1,
+	VHOST_POLL_STOPPED = 2,
+};
+
 /* Poll a file (eventfd or socket) */
 /* Note: there's nothing vhost specific about this structure. */
 struct vhost_poll {
@@ -35,6 +41,9 @@ struct vhost_poll {
 	struct vhost_work	  work;
 	unsigned long		  mask;
 	struct vhost_dev	 *dev;
+	/* Tells us whether we are polling a file.
+	 * Protected by vq lock. */
+	enum vhost_poll_state	  state;
 };
 
 void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn);
@@ -42,7 +51,7 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work);
 
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
 		     unsigned long mask, struct vhost_dev *dev);
-void vhost_poll_start(struct vhost_poll *poll, struct file *file);
+int vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
 void vhost_poll_flush(struct vhost_poll *poll);
 void vhost_poll_queue(struct vhost_poll *poll);
-- 
1.7.1
