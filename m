From: Liu Ping Fan <kernelfans@gmail.com>
Subject: [PATCH 2/2] [kvm/vhost-net]: make vhost net own NUMA
	attribute
Date: Thu, 17 May 2012 17:20:54 +0800
Message-ID: <1337246456-30909-3-git-send-email-kernelfans@gmail.com>
References: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Shirley Ma <xma@us.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, qemu-devel@nongnu.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, Ryan Harper <ryanh@us.ibm.com>,
	Avi Kivity <avi@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>
To: kvm@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

From: Liu Ping Fan <pingfank@linux.vnet.ibm.com>

Make vhost net support to spread on host node according the command.
And consider the whole vhost_net componsed of lots of logic net units.
for each node, there is a unit, which includes a vhost_worker thread,
rx/tx vhost_virtqueue.

Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
---
 drivers/vhost/net.c |  388 ++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 258 insertions(+), 130 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 1f21d2a..770933e 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -55,8 +55,19 @@ enum vhost_net_poll_state {
 
 struct vhost_net {
 	struct vhost_dev dev;
-	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
+	int numa_init;
+	int vqcnt;
+	struct vhost_virtqueue **vqs;
+	/* one for tx, one for rx */
 	struct vhost_poll poll[VHOST_NET_VQ_MAX];
+	int token[VHOST_NET_VQ_MAX];
+	/* fix me, Although tun.socket.sock can be parrell, but _maybe_, we need to record
+	 * wmem_alloc independly for each subdev.
+	 */
+	struct mutex mutex;
+	struct socket __rcu *tx_sock;
+	struct socket __rcu *rx_sock;
+
 	/* Tells us whether we are polling a socket for TX.
 	 * We only do this when socket buffer fills up.
 	 * Protected by tx vq lock. */
@@ -112,7 +123,9 @@ static void tx_poll_stop(struct vhost_net *net)
 {
 	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
 		return;
+
 	vhost_poll_stop(net->poll + VHOST_NET_VQ_TX);
+
 	net->tx_poll_state = VHOST_NET_POLL_STOPPED;
 }
 
@@ -121,15 +134,15 @@ static void tx_poll_start(struct vhost_net *net, struct socket *sock)
 {
 	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
 		return;
+
 	vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
 	net->tx_poll_state = VHOST_NET_POLL_STARTED;
 }
 
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
-static void handle_tx(struct vhost_net *net)
+static void handle_tx(struct vhost_net *net, struct vhost_virtqueue *vq)
 {
-	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
 	unsigned out, in, s;
 	int head;
 	struct msghdr msg = {
@@ -148,15 +161,15 @@ static void handle_tx(struct vhost_net *net)
 	bool zcopy;
 
 	/* TODO: check that we are running from vhost_worker? */
-	sock = rcu_dereference_check(vq->private_data, 1);
+	sock = rcu_dereference_check(net->tx_sock, 1);
 	if (!sock)
 		return;
 
 	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 	if (wmem >= sock->sk->sk_sndbuf) {
-		mutex_lock(&vq->mutex);
+		mutex_lock(&net->mutex);
 		tx_poll_start(net, sock);
-		mutex_unlock(&vq->mutex);
+		mutex_unlock(&net->mutex);
 		return;
 	}
 
@@ -165,6 +178,7 @@ static void handle_tx(struct vhost_net *net)
 
 	if (wmem < sock->sk->sk_sndbuf / 2)
 		tx_poll_stop(net);
+
 	hdr_size = vq->vhost_hlen;
 	zcopy = vhost_sock_zcopy(sock);
 
@@ -186,8 +200,10 @@ static void handle_tx(struct vhost_net *net)
 
 			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
+				mutex_lock(&net->mutex);
 				tx_poll_start(net, sock);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+				mutex_unlock(&net->mutex);
 				break;
 			}
 			/* If more outstanding DMAs, queue the work.
@@ -197,8 +213,10 @@ static void handle_tx(struct vhost_net *net)
 				    (vq->upend_idx - vq->done_idx) :
 				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
 			if (unlikely(num_pends > VHOST_MAX_PEND)) {
+				mutex_lock(&net->mutex);
 				tx_poll_start(net, sock);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+				mutex_unlock(&net->mutex);
 				break;
 			}
 			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
@@ -353,9 +371,8 @@ err:
 
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
-static void handle_rx(struct vhost_net *net)
+static void handle_rx(struct vhost_net *net, struct vhost_virtqueue *vq)
 {
-	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
 	unsigned uninitialized_var(in), log;
 	struct vhost_log *vq_log;
 	struct msghdr msg = {
@@ -375,11 +392,10 @@ static void handle_rx(struct vhost_net *net)
 	size_t vhost_hlen, sock_hlen;
 	size_t vhost_len, sock_len;
 	/* TODO: check that we are running from vhost_worker? */
-	struct socket *sock = rcu_dereference_check(vq->private_data, 1);
+	struct socket *sock = rcu_dereference_check(net->tx_sock, 1);
 
 	if (!sock)
 		return;
-
 	mutex_lock(&vq->mutex);
 	vhost_disable_notify(&net->dev, vq);
 	vhost_hlen = vq->vhost_hlen;
@@ -465,8 +481,7 @@ static void handle_tx_kick(struct vhost_work *work)
 	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
 						  poll.work);
 	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
-
-	handle_tx(net);
+	handle_tx(net, vq);
 }
 
 static void handle_rx_kick(struct vhost_work *work)
@@ -475,103 +490,115 @@ static void handle_rx_kick(struct vhost_work *work)
 						  poll.work);
 	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
 
-	handle_rx(net);
+	handle_rx(net, vq);
 }
 
-static void handle_tx_net(struct vhost_work *work)
+/* Get sock->file event, then pick up a vhost_worker to wake up.
+ * Currently ,we are round robin, maybe in future, we know which
+ * numa-node the skb from tap want to go.
+ */
+static int deliver_worker(struct vhost_net *net, int rx)
 {
-	struct vhost_net *net = container_of(work, struct vhost_net,
-					     poll[VHOST_NET_VQ_TX].work);
-	handle_tx(net);
+	int i = rx ? VHOST_NET_VQ_RX : VHOST_NET_VQ_TX;
+	int idx = ((net->token[i]++<<1)+i)%net->vqcnt;
+	vhost_poll_queue(&net->vqs[idx]->poll);
+	return 0;
 }
 
-static void handle_rx_net(struct vhost_work *work)
+static int net_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
+			     void *key)
 {
-	struct vhost_net *net = container_of(work, struct vhost_net,
-					     poll[VHOST_NET_VQ_RX].work);
-	handle_rx(net);
+	struct vhost_poll *poll = container_of(wait, struct vhost_poll, wait);
+	struct vhost_poll *head = (poll->mask == POLLIN) ? poll : poll-1;
+	struct vhost_net *net = container_of(head, struct vhost_net, poll[0]);
+
+	if (!((unsigned long)key & poll->mask))
+		return 0;
+
+	if (poll->mask == POLLIN)
+		deliver_worker(net, 1);
+	else
+		deliver_worker(net, 0);
+	return 0;
+}
+
+static void net_poll_init(struct vhost_poll *poll, unsigned long mask)
+{
+	init_waitqueue_func_entry(&poll->wait, net_poll_wakeup);
+	init_poll_funcptr(&poll->table, vhost_poll_func);
+	poll->mask = mask;
+	poll->subdev = NULL;
 }
 
 static int vhost_net_open(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
-	struct vhost_dev *dev;
-	int r;
-
 	if (!n)
 		return -ENOMEM;
-
-	dev = &n->dev;
-	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
-	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
-	r = vhost_dev_init(dev, n->vqs, VHOST_NET_VQ_MAX);
-	if (r < 0) {
-		kfree(n);
-		return r;
-	}
-
-	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
-	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
-	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
-
 	f->private_data = n;
-
 	return 0;
 }
 
-static void vhost_net_disable_vq(struct vhost_net *n,
-				 struct vhost_virtqueue *vq)
+static void vhost_net_disable_xmit(struct vhost_net *n, int rx)
 {
-	if (!vq->private_data)
-		return;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
+	if (rx  == 0) {
 		tx_poll_stop(n);
 		n->tx_poll_state = VHOST_NET_POLL_DISABLED;
 	} else
-		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
+		vhost_poll_stop(n->poll+VHOST_NET_VQ_RX);
 }
 
-static void vhost_net_enable_vq(struct vhost_net *n,
-				struct vhost_virtqueue *vq)
+static void vhost_net_enable_xmit(struct vhost_net *n, int rx)
 {
 	struct socket *sock;
 
-	sock = rcu_dereference_protected(vq->private_data,
-					 lockdep_is_held(&vq->mutex));
-	if (!sock)
-		return;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
+	if (rx == 0) {
+		sock = rcu_dereference_protected(n->tx_sock,
+					 lockdep_is_held(&n->mutex));
+		if (!sock)
+			return;
 		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
 		tx_poll_start(n, sock);
-	} else
+	} else {
+		sock = rcu_dereference_protected(n->rx_sock,
+					 lockdep_is_held(&n->mutex));
+		if (!sock)
+			return;
 		vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
+	}
 }
 
-static struct socket *vhost_net_stop_vq(struct vhost_net *n,
-					struct vhost_virtqueue *vq)
+static int vhost_net_stop_xmit(struct vhost_net *n, int rx)
 {
-	struct socket *sock;
-
-	mutex_lock(&vq->mutex);
-	sock = rcu_dereference_protected(vq->private_data,
-					 lockdep_is_held(&vq->mutex));
-	vhost_net_disable_vq(n, vq);
-	rcu_assign_pointer(vq->private_data, NULL);
-	mutex_unlock(&vq->mutex);
-	return sock;
+	mutex_lock(&n->mutex);
+	vhost_net_disable_xmit(n, rx);
+	mutex_unlock(&n->mutex);
+	return 0;
 }
 
-static void vhost_net_stop(struct vhost_net *n, struct socket **tx_sock,
-			   struct socket **rx_sock)
+static void vhost_net_stop(struct vhost_net *n)
 {
-	*tx_sock = vhost_net_stop_vq(n, n->vqs + VHOST_NET_VQ_TX);
-	*rx_sock = vhost_net_stop_vq(n, n->vqs + VHOST_NET_VQ_RX);
+	vhost_net_stop_xmit(n, 0);
+	vhost_net_stop_xmit(n, 1);
 }
 
-static void vhost_net_flush_vq(struct vhost_net *n, int index)
+/* We wait for vhost_work on all vqs to finish gp. And n->poll[] 
+ * are not vhost_work any longer
+ */
+static void vhost_net_flush_vq(struct vhost_net *n, int rx)
 {
-	vhost_poll_flush(n->poll + index);
-	vhost_poll_flush(&n->dev.vqs[index].poll);
+	int i, idx;
+	if (rx == 0) {
+		for (i = 0; i < n->dev.node_cnt; i++) {
+			idx = (i<<1) + VHOST_NET_VQ_TX;
+			vhost_poll_flush(&n->dev.vqs[idx]->poll);
+		}
+	} else {
+		for (i = 0; i < n->dev.node_cnt; i++) {
+			idx = (i<<1) + VHOST_NET_VQ_RX;
+			vhost_poll_flush(&n->dev.vqs[idx]->poll);
+		}
+	}
 }
 
 static void vhost_net_flush(struct vhost_net *n)
@@ -583,16 +610,16 @@ static void vhost_net_flush(struct vhost_net *n)
 static int vhost_net_release(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = f->private_data;
-	struct socket *tx_sock;
-	struct socket *rx_sock;
 
-	vhost_net_stop(n, &tx_sock, &rx_sock);
+	vhost_net_stop(n);
 	vhost_net_flush(n);
 	vhost_dev_cleanup(&n->dev, false);
-	if (tx_sock)
-		fput(tx_sock->file);
-	if (rx_sock)
-		fput(rx_sock->file);
+
+	if (n->tx_sock)
+		fput(n->tx_sock->file);
+	if (n->rx_sock)
+		fput(n->rx_sock->file);
+
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
@@ -665,30 +692,27 @@ static struct socket *get_socket(int fd)
 	return ERR_PTR(-ENOTSOCK);
 }
 
-static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
+static long vhost_net_set_backend(struct vhost_net *n, unsigned rx, int fd)
 {
 	struct socket *sock, *oldsock;
 	struct vhost_virtqueue *vq;
-	struct vhost_ubuf_ref *ubufs, *oldubufs = NULL;
-	int r;
+	struct vhost_ubuf_ref *ubufs, *old, **oldubufs = NULL;
+	int r, i;
+	struct vhost_poll *poll;
+	struct socket **target;
 
+	oldubufs = kmalloc(sizeof(void *)*n->dev.node_cnt, GFP_KERNEL);
+	if (oldubufs == NULL)
+		return -ENOMEM;
 	mutex_lock(&n->dev.mutex);
 	r = vhost_dev_check_owner(&n->dev);
 	if (r)
 		goto err;
+	if (rx)
+		target = &n->rx_sock;
+	else
+		target = &n->tx_sock;
 
-	if (index >= VHOST_NET_VQ_MAX) {
-		r = -ENOBUFS;
-		goto err;
-	}
-	vq = n->vqs + index;
-	mutex_lock(&vq->mutex);
-
-	/* Verify that ring has been setup correctly. */
-	if (!vhost_vq_access_ok(vq)) {
-		r = -EFAULT;
-		goto err_vq;
-	}
 	sock = get_socket(fd);
 	if (IS_ERR(sock)) {
 		r = PTR_ERR(sock);
@@ -696,70 +720,106 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	}
 
 	/* start polling new socket */
-	oldsock = rcu_dereference_protected(vq->private_data,
-					    lockdep_is_held(&vq->mutex));
+	if (rx == 1)
+		/* todo, consider about protection, hold net->mutex? */
+		oldsock = rcu_dereference_protected(n->rx_sock, 1);
+	else
+		oldsock = rcu_dereference_protected(n->tx_sock, 1);
+
 	if (sock != oldsock) {
-		ubufs = vhost_ubuf_alloc(vq, sock && vhost_sock_zcopy(sock));
-		if (IS_ERR(ubufs)) {
-			r = PTR_ERR(ubufs);
-			goto err_ubufs;
+		if (rx == 1)
+			poll = &n->poll[0];
+		else
+			poll = &n->poll[1];
+
+		/* todo, consider about protection, hold net->mutex? */
+		vhost_poll_stop(poll);
+
+		for (i = 0; i < n->dev.node_cnt; i++) {
+			if (rx == 0)
+				vq = n->vqs[(i<<1)+VHOST_NET_VQ_TX];
+			else
+				vq = n->vqs[(i<<1)+VHOST_NET_VQ_RX];
+
+			mutex_lock(&vq->mutex);
+			ubufs = vhost_ubuf_alloc(vq, sock && vhost_sock_zcopy(sock));
+			if (IS_ERR(ubufs)) {
+				r = PTR_ERR(ubufs);
+				mutex_unlock(&vq->mutex);
+				goto err_ubufs;
+			}
+			oldubufs[i] = vq->ubufs;
+			vq->ubufs = ubufs;
+			r = vhost_init_used(vq);
+			mutex_unlock(&vq->mutex);
+			if (r)
+				goto err_vq;
 		}
-		oldubufs = vq->ubufs;
-		vq->ubufs = ubufs;
-		vhost_net_disable_vq(n, vq);
-		rcu_assign_pointer(vq->private_data, sock);
-		vhost_net_enable_vq(n, vq);
-
-		r = vhost_init_used(vq);
-		if (r)
-			goto err_vq;
+
+		mutex_lock(&n->mutex);
+		vhost_net_disable_xmit(n, rx);
+		if (rx == 1)
+			rcu_assign_pointer(n->rx_sock, sock);
+		else
+			rcu_assign_pointer(n->tx_sock, sock);
+		vhost_net_enable_xmit(n, rx);
+		mutex_unlock(&n->mutex);
+
+		/* todo, consider about protection, hold net->mutex? */
+		vhost_poll_start(poll, sock->file);
 	}
 
-	mutex_unlock(&vq->mutex);
+	for (i = 0; i < n->dev.node_cnt; i++) {
+		old = oldubufs[i];
+		if (rx == 0)
+			vq = n->vqs[(i<<1)+VHOST_NET_VQ_TX];
+		else
+			vq = n->vqs[(i<<1)+VHOST_NET_VQ_RX];
 
-	if (oldubufs) {
-		vhost_ubuf_put_and_wait(oldubufs);
-		mutex_lock(&vq->mutex);
-		vhost_zerocopy_signal_used(vq);
-		mutex_unlock(&vq->mutex);
+		if (old) {
+			vhost_ubuf_put_and_wait(old);
+			mutex_lock(&vq->mutex);
+			vhost_zerocopy_signal_used(vq);
+			mutex_unlock(&vq->mutex);
+		}
 	}
 
 	if (oldsock) {
-		vhost_net_flush_vq(n, index);
+		vhost_net_flush_vq(n, rx);
 		fput(oldsock->file);
 	}
 
 	mutex_unlock(&n->dev.mutex);
+	kfree(oldubufs);
 	return 0;
 
 err_ubufs:
 	fput(sock->file);
 err_vq:
-	mutex_unlock(&vq->mutex);
+	mutex_unlock(&n->mutex);
 err:
 	mutex_unlock(&n->dev.mutex);
+	kfree(oldubufs);
 	return r;
 }
 
 static long vhost_net_reset_owner(struct vhost_net *n)
 {
-	struct socket *tx_sock = NULL;
-	struct socket *rx_sock = NULL;
 	long err;
 
 	mutex_lock(&n->dev.mutex);
 	err = vhost_dev_check_owner(&n->dev);
 	if (err)
 		goto done;
-	vhost_net_stop(n, &tx_sock, &rx_sock);
+	vhost_net_stop(n);
 	vhost_net_flush(n);
 	err = vhost_dev_reset_owner(&n->dev);
 done:
 	mutex_unlock(&n->dev.mutex);
-	if (tx_sock)
-		fput(tx_sock->file);
-	if (rx_sock)
-		fput(rx_sock->file);
+	if (n->tx_sock)
+		fput(n->tx_sock->file);
+	if (n->rx_sock)
+		fput(n->rx_sock->file);
 	return err;
 }
 
@@ -788,17 +848,72 @@ static int vhost_net_set_features(struct vhost_net *n, u64 features)
 	}
 	n->dev.acked_features = features;
 	smp_wmb();
-	for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
-		mutex_lock(&n->vqs[i].mutex);
-		n->vqs[i].vhost_hlen = vhost_hlen;
-		n->vqs[i].sock_hlen = sock_hlen;
-		mutex_unlock(&n->vqs[i].mutex);
+	for (i = 0; i < n->vqcnt; ++i) {
+		mutex_lock(&n->vqs[i]->mutex);
+		n->vqs[i]->vhost_hlen = vhost_hlen;
+		n->vqs[i]->sock_hlen = sock_hlen;
+		mutex_unlock(&n->vqs[i]->mutex);
 	}
 	vhost_net_flush(n);
 	mutex_unlock(&n->dev.mutex);
 	return 0;
 }
 
+static int vhost_netdev_init(struct vhost_net *n)
+{
+	struct vhost_dev *dev;
+	vhost_work_fn_t *handle_kicks;
+	int r, i;
+	int cur, prev = 0;
+	int sz = 64;
+	int vqcnt;
+	int *vqs_map;
+	dev = &n->dev;
+	vqcnt = dev->node_cnt * 2;
+	n->vqs =  kmalloc(vqcnt*sizeof(void *), GFP_KERNEL);
+	handle_kicks = kmalloc(vqcnt*sizeof(void *), GFP_KERNEL);
+	vqs_map = kmalloc(vqcnt*sizeof(int), GFP_KERNEL);
+	for (i = 0; i < vqcnt;) {
+		cur = find_next_bit(&n->dev.allow_map, sz, prev);
+		prev = cur;
+		handle_kicks[i++] = handle_rx_kick;
+		vqs_map[i] = cur;
+		handle_kicks[i++] = handle_tx_kick;
+		vqs_map[i] = cur;
+
+	}
+
+	r = vhost_dev_alloc_subdevs(dev, &n->dev.allow_map, sz);
+	if (r < 0) {
+		/* todo, err handling */
+		return r;
+	}
+	r = vhost_dev_alloc_vqs(dev, n->vqs, vqcnt, vqs_map, vqcnt, handle_kicks);
+	if (r < 0) {
+		/* todo, err handling */
+		return r;
+	}
+	r = vhost_dev_init(dev, n->vqs, vqcnt);
+	if (r < 0)
+		goto exit;
+	if (experimental_zcopytx)
+		vhost_enable_zcopy(dev, 0);
+
+	net_poll_init(n->poll+VHOST_NET_VQ_TX, POLLOUT);
+	net_poll_init(n->poll+VHOST_NET_VQ_RX, POLLIN);
+	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
+	n->numa_init = 1;
+	r = 0;
+exit:
+	kfree(handle_kicks);
+	kfree(vqs_map);
+	if (r == 0)
+		return 0;
+	kfree(n->vqs);
+	kfree(n);
+	return r;
+}
+
 static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
 			    unsigned long arg)
 {
@@ -808,8 +923,23 @@ static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
 	struct vhost_vring_file backend;
 	u64 features;
 	int r;
+	/* todo, dynamic allocated */
+	unsigned long bmp, sz = 64;
+
+	if (!n->numa_init && ioctl != VHOST_NET_SET_NUMA)
+		return -EOPNOTSUPP;
 
 	switch (ioctl) {
+	case VHOST_NET_SET_NUMA:
+		/* 4 must be extended. */
+		if (copy_from_user(&bmp, argp, 4))
+			return -EFAULT;
+		r = check_numa_bmp(&bmp, sz);
+		if (r < 0)
+			return -EINVAL;
+		n->dev.allow_map = bmp;
+		r = vhost_netdev_init(n);
+		return r;
 	case VHOST_NET_SET_BACKEND:
 		if (copy_from_user(&backend, argp, sizeof backend))
 			return -EFAULT;
@@ -863,8 +993,6 @@ static struct miscdevice vhost_net_misc = {
 
 static int vhost_net_init(void)
 {
-	if (experimental_zcopytx)
-		vhost_enable_zcopy(VHOST_NET_VQ_TX);
 	return misc_register(&vhost_net_misc);
 }
 module_init(vhost_net_init);
-- 
1.7.4.4
