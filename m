From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] vhost_net: remove tx polling state
Date: Thu,  7 Mar 2013 12:31:56 +0800
Message-ID: <1362630716-57674-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

After commit 2b8b328b61c799957a456a5a8dab8cc7dea68575 (vhost_net: handle polling
errors when setting backend), we in fact track the polling state through
poll->wqh, so there's no need to duplicate the work with an extra
vhost_net_polling_state. So this patch removes this and make the code simpler.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c   |   60 ++++++++----------------------------------------
 drivers/vhost/vhost.c |    3 ++
 2 files changed, 13 insertions(+), 50 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 959b1cd..d1a03dd 100644
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
@@ -155,28 +145,6 @@ static void copy_iovec_hdr(const struct iovec *from, struct iovec *to,
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
-static int tx_poll_start(struct vhost_net *net, struct socket *sock)
-{
-	int ret;
-
-	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
-		return 0;
-	ret = vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
-	if (!ret)
-		net->tx_poll_state = VHOST_NET_POLL_STARTED;
-	return ret;
-}
-
 /* In case of DMA done not in order in lower device driver for some reason.
  * upend_idx is used to track end of used idx, done_idx is used to track head
  * of used idx. Once lower device DMA done contiguously, we will signal KVM
@@ -231,6 +199,7 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 static void handle_tx(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
+	struct vhost_poll *poll = net->poll + VHOST_NET_VQ_TX;
 	unsigned out, in, s;
 	int head;
 	struct msghdr msg = {
@@ -256,7 +225,7 @@ static void handle_tx(struct vhost_net *net)
 	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 	if (wmem >= sock->sk->sk_sndbuf) {
 		mutex_lock(&vq->mutex);
-		tx_poll_start(net, sock);
+		vhost_poll_start(poll, sock->file);
 		mutex_unlock(&vq->mutex);
 		return;
 	}
@@ -265,7 +234,7 @@ static void handle_tx(struct vhost_net *net)
 	vhost_disable_notify(&net->dev, vq);
 
 	if (wmem < sock->sk->sk_sndbuf / 2)
-		tx_poll_stop(net);
+		vhost_poll_stop(poll);
 	hdr_size = vq->vhost_hlen;
 	zcopy = vq->ubufs;
 
@@ -287,7 +256,7 @@ static void handle_tx(struct vhost_net *net)
 
 			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
-				tx_poll_start(net, sock);
+				vhost_poll_start(poll, sock->file);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
@@ -298,7 +267,7 @@ static void handle_tx(struct vhost_net *net)
 				    (vq->upend_idx - vq->done_idx) :
 				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
 			if (unlikely(num_pends > VHOST_MAX_PEND)) {
-				tx_poll_start(net, sock);
+				vhost_poll_start(poll, sock->file);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
@@ -364,7 +333,7 @@ static void handle_tx(struct vhost_net *net)
 			}
 			vhost_discard_vq_desc(vq, 1);
 			if (err == -EAGAIN || err == -ENOBUFS)
-				tx_poll_start(net, sock);
+				vhost_poll_start(poll, sock->file);
 			break;
 		}
 		if (err != len)
@@ -627,7 +596,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
-	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
 
 	f->private_data = n;
 
@@ -637,32 +605,24 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 static void vhost_net_disable_vq(struct vhost_net *n,
 				 struct vhost_virtqueue *vq)
 {
+	struct vhost_poll *poll = n->poll + (vq - n->vqs);
 	if (!vq->private_data)
 		return;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
-		tx_poll_stop(n);
-		n->tx_poll_state = VHOST_NET_POLL_DISABLED;
-	} else
-		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
+	vhost_poll_stop(poll);
 }
 
 static int vhost_net_enable_vq(struct vhost_net *n,
 				struct vhost_virtqueue *vq)
 {
+	struct vhost_poll *poll = n->poll + (vq - n->vqs);
 	struct socket *sock;
-	int ret;
 
 	sock = rcu_dereference_protected(vq->private_data,
 					 lockdep_is_held(&vq->mutex));
 	if (!sock)
 		return 0;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
-		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
-		ret = tx_poll_start(n, sock);
-	} else
-		ret = vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
 
-	return ret;
+	return vhost_poll_start(poll, sock->file);
 }
 
 static struct socket *vhost_net_stop_vq(struct vhost_net *n,
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 9759249..4eecdb8 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -89,6 +89,9 @@ int vhost_poll_start(struct vhost_poll *poll, struct file *file)
 	unsigned long mask;
 	int ret = 0;
 
+	if (poll->wqh)
+		return 0;
+
 	mask = file->f_op->poll(file, &poll->table);
 	if (mask)
 		vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
-- 
1.7.1
