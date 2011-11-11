From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [ver3 PATCH 4/6] vhost_net: vhost_net changes
Date: Fri, 11 Nov 2011 18:35:17 +0530
Message-ID: <20111111130517.9878.53191.sendpatchset@krkumar2.in.ibm.com>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	davem@davemloft.net, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes for multiqueue vhost_net driver.

Signed-off-by: krkumar2@in.ibm.com
---
 drivers/vhost/net.c   |  253 +++++++++++++++++++++++++---------------
 drivers/vhost/vhost.c |  225 ++++++++++++++++++++++++-----------
 drivers/vhost/vhost.h |   26 +++-
 3 files changed, 340 insertions(+), 164 deletions(-)

diff -ruNp org/drivers/vhost/net.c new/drivers/vhost/net.c
--- org/drivers/vhost/net.c	2011-11-11 16:44:56.000000000 +0530
+++ new/drivers/vhost/net.c	2011-11-11 16:45:11.000000000 +0530
@@ -41,12 +41,6 @@ MODULE_PARM_DESC(experimental_zcopytx, "
 #define VHOST_MAX_PEND 128
 #define VHOST_GOODCOPY_LEN 256
 
-enum {
-	VHOST_NET_VQ_RX = 0,
-	VHOST_NET_VQ_TX = 1,
-	VHOST_NET_VQ_MAX = 2,
-};
-
 enum vhost_net_poll_state {
 	VHOST_NET_POLL_DISABLED = 0,
 	VHOST_NET_POLL_STARTED = 1,
@@ -55,12 +49,13 @@ enum vhost_net_poll_state {
 
 struct vhost_net {
 	struct vhost_dev dev;
-	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
-	struct vhost_poll poll[VHOST_NET_VQ_MAX];
+	struct vhost_virtqueue *vqs;
+	struct vhost_poll *poll;
+	struct socket **socks;
 	/* Tells us whether we are polling a socket for TX.
 	 * We only do this when socket buffer fills up.
 	 * Protected by tx vq lock. */
-	enum vhost_net_poll_state tx_poll_state;
+	enum vhost_net_poll_state *tx_poll_state;
 };
 
 static bool vhost_sock_zcopy(struct socket *sock)
@@ -108,28 +103,28 @@ static void copy_iovec_hdr(const struct 
 }
 
 /* Caller must have TX VQ lock */
-static void tx_poll_stop(struct vhost_net *net)
+static void tx_poll_stop(struct vhost_net *net, int qnum)
 {
-	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
+	if (likely(net->tx_poll_state[qnum / 2] != VHOST_NET_POLL_STARTED))
 		return;
-	vhost_poll_stop(net->poll + VHOST_NET_VQ_TX);
-	net->tx_poll_state = VHOST_NET_POLL_STOPPED;
+	vhost_poll_stop(&net->poll[qnum]);
+	net->tx_poll_state[qnum / 2] = VHOST_NET_POLL_STOPPED;
 }
 
 /* Caller must have TX VQ lock */
-static void tx_poll_start(struct vhost_net *net, struct socket *sock)
+static void tx_poll_start(struct vhost_net *net, struct socket *sock, int qnum)
 {
-	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
+	if (unlikely(net->tx_poll_state[qnum / 2] != VHOST_NET_POLL_STOPPED))
 		return;
-	vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
-	net->tx_poll_state = VHOST_NET_POLL_STARTED;
+	vhost_poll_start(&net->poll[qnum], sock->file);
+	net->tx_poll_state[qnum / 2] = VHOST_NET_POLL_STARTED;
 }
 
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
-static void handle_tx(struct vhost_net *net)
+static void handle_tx(struct vhost_virtqueue *vq)
 {
-	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
+	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
 	unsigned out, in, s;
 	int head;
 	struct msghdr msg = {
@@ -155,7 +150,7 @@ static void handle_tx(struct vhost_net *
 	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 	if (wmem >= sock->sk->sk_sndbuf) {
 		mutex_lock(&vq->mutex);
-		tx_poll_start(net, sock);
+		tx_poll_start(net, sock, vq->qnum);
 		mutex_unlock(&vq->mutex);
 		return;
 	}
@@ -164,7 +159,7 @@ static void handle_tx(struct vhost_net *
 	vhost_disable_notify(&net->dev, vq);
 
 	if (wmem < sock->sk->sk_sndbuf / 2)
-		tx_poll_stop(net);
+		tx_poll_stop(net, vq->qnum);
 	hdr_size = vq->vhost_hlen;
 	zcopy = vhost_sock_zcopy(sock);
 
@@ -186,7 +181,7 @@ static void handle_tx(struct vhost_net *
 
 			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
-				tx_poll_start(net, sock);
+				tx_poll_start(net, sock, vq->qnum);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
@@ -197,7 +192,7 @@ static void handle_tx(struct vhost_net *
 				    (vq->upend_idx - vq->done_idx) :
 				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
 			if (unlikely(num_pends > VHOST_MAX_PEND)) {
-				tx_poll_start(net, sock);
+				tx_poll_start(net, sock, vq->qnum);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
@@ -257,7 +252,7 @@ static void handle_tx(struct vhost_net *
 					UIO_MAXIOV;
 			}
 			vhost_discard_vq_desc(vq, 1);
-			tx_poll_start(net, sock);
+			tx_poll_start(net, sock, vq->qnum);
 			break;
 		}
 		if (err != len)
@@ -353,9 +348,9 @@ err:
 
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
-static void handle_rx(struct vhost_net *net)
+static void handle_rx(struct vhost_virtqueue *vq)
 {
-	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
+	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
 	unsigned uninitialized_var(in), log;
 	struct vhost_log *vq_log;
 	struct msghdr msg = {
@@ -464,87 +459,155 @@ static void handle_tx_kick(struct vhost_
 {
 	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
 						  poll.work);
-	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
 
-	handle_tx(net);
+	handle_tx(vq);
 }
 
 static void handle_rx_kick(struct vhost_work *work)
 {
 	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
 						  poll.work);
-	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
 
-	handle_rx(net);
+	handle_rx(vq);
 }
 
 static void handle_tx_net(struct vhost_work *work)
 {
-	struct vhost_net *net = container_of(work, struct vhost_net,
-					     poll[VHOST_NET_VQ_TX].work);
-	handle_tx(net);
+	struct vhost_virtqueue *vq = container_of(work, struct vhost_poll,
+						  work)->vq;
+
+	handle_tx(vq);
 }
 
 static void handle_rx_net(struct vhost_work *work)
 {
-	struct vhost_net *net = container_of(work, struct vhost_net,
-					     poll[VHOST_NET_VQ_RX].work);
-	handle_rx(net);
+	struct vhost_virtqueue *vq = container_of(work, struct vhost_poll,
+						  work)->vq;
+
+	handle_rx(vq);
 }
 
-static int vhost_net_open(struct inode *inode, struct file *f)
+void vhost_free_vqs(struct vhost_dev *dev)
 {
-	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
-	struct vhost_dev *dev;
-	int r;
+	struct vhost_net *n = container_of(dev, struct vhost_net, dev);
 
-	if (!n)
-		return -ENOMEM;
+	if (!n->vqs)
+		return;
 
-	dev = &n->dev;
-	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
-	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
-	r = vhost_dev_init(dev, n->vqs, VHOST_NET_VQ_MAX);
-	if (r < 0) {
-		kfree(n);
-		return r;
+	kfree(n->socks);
+	kfree(n->tx_poll_state);
+	kfree(n->poll);
+	kfree(n->vqs);
+
+	/*
+	 * Reset so that vhost_net_release (which gets called when
+	 * vhost_dev_set_owner() call fails) will notice.
+	 */
+	n->vqs = NULL;
+}
+
+int vhost_setup_vqs(struct vhost_dev *dev, int numtxqs)
+{
+	struct vhost_net *n = container_of(dev, struct vhost_net, dev);
+	int i, nvqs;
+	int ret = -ENOMEM;
+
+	if (numtxqs < 0)
+		return -EINVAL;
+
+	if (numtxqs == 0) {
+		/* Old qemu doesn't pass arguments to set_owner, use 1 txq */
+		numtxqs = 1;
+	}
+
+	/* Get total number of virtqueues */
+	nvqs = numtxqs * 2;
+
+	n->vqs = kmalloc(nvqs * sizeof(*n->vqs), GFP_KERNEL);
+	n->poll = kmalloc(nvqs * sizeof(*n->poll), GFP_KERNEL);
+	n->socks = kmalloc(nvqs * sizeof(*n->socks), GFP_KERNEL);
+	n->tx_poll_state = kmalloc(numtxqs * sizeof(*n->tx_poll_state),
+				   GFP_KERNEL);
+	if (!n->vqs || !n->poll || !n->socks || !n->tx_poll_state)
+		goto err;
+
+	/* RX followed by TX queues */
+	for (i = 0; i < nvqs; i += 2) {
+		n->vqs[i].handle_kick = handle_rx_kick;
+		n->vqs[i + 1].handle_kick = handle_tx_kick;
 	}
 
-	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
-	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
-	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
+	ret = vhost_dev_init(dev, n->vqs, nvqs);
+	if (ret < 0)
+		goto err;
 
-	f->private_data = n;
+	for (i = 0; i < nvqs; i += 2) {
+		vhost_poll_init(&n->poll[i], handle_rx_net, POLLIN,
+				&n->vqs[i]);
+		vhost_poll_init(&n->poll[i+1], handle_tx_net, POLLOUT,
+				&n->vqs[i+1]);
+		if (i / 2 < numtxqs)
+			n->tx_poll_state[i/2] = VHOST_NET_POLL_DISABLED;
+	}
 
 	return 0;
+
+err:
+	/* Free all pointers that may have been allocated */
+	vhost_free_vqs(dev);
+
+	return ret;
+}
+
+static int vhost_net_open(struct inode *inode, struct file *f)
+{
+	struct vhost_net *n = kzalloc(sizeof *n, GFP_KERNEL);
+	int ret = -ENOMEM;
+
+	if (n) {
+		struct vhost_dev *dev = &n->dev;
+
+		f->private_data = n;
+		mutex_init(&dev->mutex);
+
+		/* Defer all other initialization till user does SET_OWNER */
+		ret = 0;
+	}
+
+	return ret;
 }
 
 static void vhost_net_disable_vq(struct vhost_net *n,
 				 struct vhost_virtqueue *vq)
 {
+	int qnum = vq->qnum;
+
 	if (!vq->private_data)
 		return;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
-		tx_poll_stop(n);
-		n->tx_poll_state = VHOST_NET_POLL_DISABLED;
-	} else
-		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
+	if (qnum & 1) {		/* Odd qnum -> TX */
+		tx_poll_stop(n, qnum);
+		n->tx_poll_state[qnum / 2] = VHOST_NET_POLL_DISABLED;
+	} else {		/* Even qnum -> RX */
+		vhost_poll_stop(&n->poll[qnum]);
+	}
 }
 
 static void vhost_net_enable_vq(struct vhost_net *n,
 				struct vhost_virtqueue *vq)
 {
 	struct socket *sock;
+	int qnum = vq->qnum;
 
 	sock = rcu_dereference_protected(vq->private_data,
 					 lockdep_is_held(&vq->mutex));
 	if (!sock)
 		return;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
-		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
-		tx_poll_start(n, sock);
-	} else
-		vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
+	if (qnum & 1) {		/* Odd qnum -> TX */
+		n->tx_poll_state[qnum / 2] = VHOST_NET_POLL_STOPPED;
+		tx_poll_start(n, sock, qnum);
+	} else {		/* Even qnum -> RX */
+		vhost_poll_start(&n->poll[qnum], sock->file);
+	}
 }
 
 static struct socket *vhost_net_stop_vq(struct vhost_net *n,
@@ -561,11 +624,12 @@ static struct socket *vhost_net_stop_vq(
 	return sock;
 }
 
-static void vhost_net_stop(struct vhost_net *n, struct socket **tx_sock,
-			   struct socket **rx_sock)
+static void vhost_net_stop(struct vhost_net *n)
 {
-	*tx_sock = vhost_net_stop_vq(n, n->vqs + VHOST_NET_VQ_TX);
-	*rx_sock = vhost_net_stop_vq(n, n->vqs + VHOST_NET_VQ_RX);
+	int i;
+
+	for (i = 0; i < n->dev.nvqs; i++)
+		n->socks[i] = vhost_net_stop_vq(n, &n->vqs[i]);
 }
 
 static void vhost_net_flush_vq(struct vhost_net *n, int index)
@@ -576,26 +640,33 @@ static void vhost_net_flush_vq(struct vh
 
 static void vhost_net_flush(struct vhost_net *n)
 {
-	vhost_net_flush_vq(n, VHOST_NET_VQ_TX);
-	vhost_net_flush_vq(n, VHOST_NET_VQ_RX);
+	int i;
+
+	for (i = 0; i < n->dev.nvqs; i++)
+		vhost_net_flush_vq(n, i);
 }
 
 static int vhost_net_release(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = f->private_data;
-	struct socket *tx_sock;
-	struct socket *rx_sock;
+	struct vhost_dev *dev = &n->dev;
+	int i;
 
-	vhost_net_stop(n, &tx_sock, &rx_sock);
+	vhost_net_stop(n);
 	vhost_net_flush(n);
-	vhost_dev_cleanup(&n->dev);
-	if (tx_sock)
-		fput(tx_sock->file);
-	if (rx_sock)
-		fput(rx_sock->file);
+	vhost_dev_cleanup(dev);
+
+	for (i = 0; i < n->dev.nvqs; i++)
+		if (n->socks[i])
+			fput(n->socks[i]->file);
+
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
+
+	/* Free all old pointers */
+	vhost_free_vqs(dev);
+
 	kfree(n);
 	return 0;
 }
@@ -677,7 +748,7 @@ static long vhost_net_set_backend(struct
 	if (r)
 		goto err;
 
-	if (index >= VHOST_NET_VQ_MAX) {
+	if (index >= n->dev.nvqs) {
 		r = -ENOBUFS;
 		goto err;
 	}
@@ -743,23 +814,25 @@ err:
 
 static long vhost_net_reset_owner(struct vhost_net *n)
 {
-	struct socket *tx_sock = NULL;
-	struct socket *rx_sock = NULL;
 	long err;
+	int i;
 
 	mutex_lock(&n->dev.mutex);
 	err = vhost_dev_check_owner(&n->dev);
-	if (err)
-		goto done;
-	vhost_net_stop(n, &tx_sock, &rx_sock);
+	if (err) {
+		mutex_unlock(&n->dev.mutex);
+		return err;
+	}
+
+	vhost_net_stop(n);
 	vhost_net_flush(n);
 	err = vhost_dev_reset_owner(&n->dev);
-done:
 	mutex_unlock(&n->dev.mutex);
-	if (tx_sock)
-		fput(tx_sock->file);
-	if (rx_sock)
-		fput(rx_sock->file);
+
+	for (i = 0; i < n->dev.nvqs; i++)
+		if (n->socks[i])
+			fput(n->socks[i]->file);
+
 	return err;
 }
 
@@ -788,7 +861,7 @@ static int vhost_net_set_features(struct
 	}
 	n->dev.acked_features = features;
 	smp_wmb();
-	for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
+	for (i = 0; i < n->dev.nvqs; ++i) {
 		mutex_lock(&n->vqs[i].mutex);
 		n->vqs[i].vhost_hlen = vhost_hlen;
 		n->vqs[i].sock_hlen = sock_hlen;
@@ -864,7 +937,7 @@ static struct miscdevice vhost_net_misc 
 static int vhost_net_init(void)
 {
 	if (experimental_zcopytx)
-		vhost_enable_zcopy(VHOST_NET_VQ_TX);
+		vhost_enable_zcopy(VHOST_NET_TX_VQS);
 	return misc_register(&vhost_net_misc);
 }
 module_init(vhost_net_init);
diff -ruNp org/drivers/vhost/vhost.c new/drivers/vhost/vhost.c
--- org/drivers/vhost/vhost.c	2011-11-11 16:44:56.000000000 +0530
+++ new/drivers/vhost/vhost.c	2011-11-11 16:45:11.000000000 +0530
@@ -75,12 +75,12 @@ static void vhost_work_init(struct vhost
 
 /* Init poll structure */
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev)
+		     unsigned long mask, struct vhost_virtqueue *vq)
 {
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
-	poll->dev = dev;
+	poll->vq = vq;
 
 	vhost_work_init(&poll->work, fn);
 }
@@ -103,30 +103,31 @@ void vhost_poll_stop(struct vhost_poll *
 	remove_wait_queue(poll->wqh, &poll->wait);
 }
 
-static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
-				unsigned seq)
+static bool vhost_work_seq_done(struct vhost_virtqueue *vq,
+				struct vhost_work *work, unsigned seq)
 {
 	int left;
 
-	spin_lock_irq(&dev->work_lock);
+	spin_lock_irq(vq->work_lock);
 	left = seq - work->done_seq;
-	spin_unlock_irq(&dev->work_lock);
+	spin_unlock_irq(vq->work_lock);
 	return left <= 0;
 }
 
-static void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
+static void vhost_work_flush(struct vhost_virtqueue *vq,
+			     struct vhost_work *work)
 {
 	unsigned seq;
 	int flushing;
 
-	spin_lock_irq(&dev->work_lock);
+	spin_lock_irq(vq->work_lock);
 	seq = work->queue_seq;
 	work->flushing++;
-	spin_unlock_irq(&dev->work_lock);
-	wait_event(work->done, vhost_work_seq_done(dev, work, seq));
-	spin_lock_irq(&dev->work_lock);
+	spin_unlock_irq(vq->work_lock);
+	wait_event(work->done, vhost_work_seq_done(vq, work, seq));
+	spin_lock_irq(vq->work_lock);
 	flushing = --work->flushing;
-	spin_unlock_irq(&dev->work_lock);
+	spin_unlock_irq(vq->work_lock);
 	BUG_ON(flushing < 0);
 }
 
@@ -134,26 +135,26 @@ static void vhost_work_flush(struct vhos
  * locks that are also used by the callback. */
 void vhost_poll_flush(struct vhost_poll *poll)
 {
-	vhost_work_flush(poll->dev, &poll->work);
+	vhost_work_flush(poll->vq, &poll->work);
 }
 
-static inline void vhost_work_queue(struct vhost_dev *dev,
+static inline void vhost_work_queue(struct vhost_virtqueue *vq,
 				    struct vhost_work *work)
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(&dev->work_lock, flags);
+	spin_lock_irqsave(vq->work_lock, flags);
 	if (list_empty(&work->node)) {
-		list_add_tail(&work->node, &dev->work_list);
+		list_add_tail(&work->node, vq->work_list);
 		work->queue_seq++;
-		wake_up_process(dev->worker);
+		wake_up_process(vq->worker);
 	}
-	spin_unlock_irqrestore(&dev->work_lock, flags);
+	spin_unlock_irqrestore(vq->work_lock, flags);
 }
 
 void vhost_poll_queue(struct vhost_poll *poll)
 {
-	vhost_work_queue(poll->dev, &poll->work);
+	vhost_work_queue(poll->vq, &poll->work);
 }
 
 static void vhost_vq_reset(struct vhost_dev *dev,
@@ -188,17 +189,17 @@ static void vhost_vq_reset(struct vhost_
 
 static int vhost_worker(void *data)
 {
-	struct vhost_dev *dev = data;
+	struct vhost_virtqueue *vq = data;
 	struct vhost_work *work = NULL;
 	unsigned uninitialized_var(seq);
 
-	use_mm(dev->mm);
+	use_mm(vq->dev->mm);
 
 	for (;;) {
 		/* mb paired w/ kthread_stop */
 		set_current_state(TASK_INTERRUPTIBLE);
 
-		spin_lock_irq(&dev->work_lock);
+		spin_lock_irq(vq->work_lock);
 		if (work) {
 			work->done_seq = seq;
 			if (work->flushing)
@@ -206,18 +207,18 @@ static int vhost_worker(void *data)
 		}
 
 		if (kthread_should_stop()) {
-			spin_unlock_irq(&dev->work_lock);
+			spin_unlock_irq(vq->work_lock);
 			__set_current_state(TASK_RUNNING);
 			break;
 		}
-		if (!list_empty(&dev->work_list)) {
-			work = list_first_entry(&dev->work_list,
+		if (!list_empty(vq->work_list)) {
+			work = list_first_entry(vq->work_list,
 						struct vhost_work, node);
 			list_del_init(&work->node);
 			seq = work->queue_seq;
 		} else
 			work = NULL;
-		spin_unlock_irq(&dev->work_lock);
+		spin_unlock_irq(vq->work_lock);
 
 		if (work) {
 			__set_current_state(TASK_RUNNING);
@@ -226,7 +227,7 @@ static int vhost_worker(void *data)
 			schedule();
 
 	}
-	unuse_mm(dev->mm);
+	unuse_mm(vq->dev->mm);
 	return 0;
 }
 
@@ -260,7 +261,7 @@ static long vhost_dev_alloc_iovecs(struc
 					  GFP_KERNEL);
 		dev->vqs[i].heads = kmalloc(sizeof *dev->vqs[i].heads *
 					    UIO_MAXIOV, GFP_KERNEL);
-		zcopy = vhost_zcopy_mask & (0x1 << i);
+		zcopy = vhost_zcopy_mask & (0x1 << (i & VHOST_NET_TX_VQS));
 		if (zcopy)
 			dev->vqs[i].ubuf_info =
 				kmalloc(sizeof *dev->vqs[i].ubuf_info *
@@ -286,6 +287,30 @@ static void vhost_dev_free_iovecs(struct
 		vhost_vq_free_iovecs(&dev->vqs[i]);
 }
 
+/*
+ * Get index of an existing thread that will handle this rx/tx queue pair.
+ * The same thread handles both rx and tx.
+ */
+static int vhost_get_thread_index(int index)
+{
+	return (index / 2) % MAX_VHOST_THREADS;
+}
+
+/* Get index of the an earlier vq that we can share with */
+static int vhost_get_vq_index(int index)
+{
+	return vhost_get_thread_index(index) * 2;
+}
+
+/*
+ * This is needed to determine whether work_list/work_lock needs
+ * initialization; or to start a new worker thread.
+ */
+static int vhost_needs_init(int i, int j)
+{
+	return i == j * 2;
+}
+
 long vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue *vqs, int nvqs)
 {
@@ -298,21 +323,31 @@ long vhost_dev_init(struct vhost_dev *de
 	dev->log_file = NULL;
 	dev->memory = NULL;
 	dev->mm = NULL;
-	spin_lock_init(&dev->work_lock);
-	INIT_LIST_HEAD(&dev->work_list);
-	dev->worker = NULL;
 
 	for (i = 0; i < dev->nvqs; ++i) {
-		dev->vqs[i].log = NULL;
-		dev->vqs[i].indirect = NULL;
-		dev->vqs[i].heads = NULL;
-		dev->vqs[i].ubuf_info = NULL;
-		dev->vqs[i].dev = dev;
-		mutex_init(&dev->vqs[i].mutex);
+		struct vhost_virtqueue *vq = &dev->vqs[i];
+		int j = vhost_get_thread_index(i);
+
+		if (vhost_needs_init(i, j)) {
+			spin_lock_init(&dev->work[j].work_lock);
+			INIT_LIST_HEAD(&dev->work[j].work_list);
+		}
+
+		vq->ubuf_info = NULL;
+		vq->work_lock = &dev->work[j].work_lock;
+		vq->work_list = &dev->work[j].work_list;
+
+		vq->worker = NULL;
+		vq->qnum = i;
+		vq->log = NULL;
+		vq->indirect = NULL;
+		vq->heads = NULL;
+		vq->dev = dev;
+		mutex_init(&vq->mutex);
 		vhost_vq_reset(dev, dev->vqs + i);
-		if (dev->vqs[i].handle_kick)
-			vhost_poll_init(&dev->vqs[i].poll,
-					dev->vqs[i].handle_kick, POLLIN, dev);
+		if (vq->handle_kick)
+			vhost_poll_init(&vq->poll,
+					vq->handle_kick, POLLIN, vq);
 	}
 
 	return 0;
@@ -339,21 +374,83 @@ static void vhost_attach_cgroups_work(st
 	s->ret = cgroup_attach_task_all(s->owner, current);
 }
 
-static int vhost_attach_cgroups(struct vhost_dev *dev)
+static int vhost_attach_cgroups(struct vhost_virtqueue *vq)
 {
 	struct vhost_attach_cgroups_struct attach;
 
 	attach.owner = current;
 	vhost_work_init(&attach.work, vhost_attach_cgroups_work);
-	vhost_work_queue(dev, &attach.work);
-	vhost_work_flush(dev, &attach.work);
+	vhost_work_queue(vq, &attach.work);
+	vhost_work_flush(vq, &attach.work);
 	return attach.ret;
 }
 
+static void __vhost_stop_workers(struct vhost_dev *dev, int nvhosts)
+{
+	int i;
+
+	for (i = 0; i < dev->nvqs; i++) {
+		if (i < nvhosts) {
+			WARN_ON(!list_empty(dev->vqs[i * 2].work_list));
+			if (dev->vqs[i * 2].worker)
+				kthread_stop(dev->vqs[i * 2].worker);
+		}
+		dev->vqs[i].worker = NULL;
+	}
+
+	if (dev->mm)
+		mmput(dev->mm);
+	dev->mm = NULL;
+}
+
+static void vhost_stop_workers(struct vhost_dev *dev)
+{
+	int nthreads = min_t(int, dev->nvqs / 2, MAX_VHOST_THREADS);
+
+	__vhost_stop_workers(dev, nthreads);
+}
+
+static int vhost_start_workers(struct vhost_dev *dev)
+{
+	int i, err;
+
+	for (i = 0; i < dev->nvqs; ++i) {
+		struct vhost_virtqueue *vq = &dev->vqs[i];
+		int j = vhost_get_thread_index(i);
+
+		if (vhost_needs_init(i, j)) {
+			/* Start a new thread */
+			vq->worker = kthread_create(vhost_worker, vq,
+						    "vhost-%d-%d",
+						    current->pid, j);
+			if (IS_ERR(vq->worker)) {
+				err = PTR_ERR(vq->worker);
+				goto err;
+			}
+
+			wake_up_process(vq->worker);
+
+			/* avoid contributing to loadavg */
+			err = vhost_attach_cgroups(vq);
+			if (err)
+				goto err;
+		} else {
+			/* Share work with an existing thread */
+			int j = vhost_get_vq_index(i);
+
+			vq->worker = dev->vqs[j].worker;
+		}
+	}
+	return 0;
+
+err:
+	__vhost_stop_workers(dev, i / 2);
+	return err;
+}
+
 /* Caller should have device mutex */
-static long vhost_dev_set_owner(struct vhost_dev *dev)
+static long vhost_dev_set_owner(struct vhost_dev *dev, int numtxqs)
 {
-	struct task_struct *worker;
 	int err;
 
 	/* Is there an owner already? */
@@ -362,33 +459,30 @@ static long vhost_dev_set_owner(struct v
 		goto err_mm;
 	}
 
+	err = vhost_setup_vqs(dev, numtxqs);
+	if (err)
+		goto err_mm;
+
 	/* No owner, become one */
 	dev->mm = get_task_mm(current);
-	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
-	if (IS_ERR(worker)) {
-		err = PTR_ERR(worker);
-		goto err_worker;
-	}
-
-	dev->worker = worker;
-	wake_up_process(worker);	/* avoid contributing to loadavg */
 
-	err = vhost_attach_cgroups(dev);
+	/* Start threads */
+	err =  vhost_start_workers(dev);
 	if (err)
-		goto err_cgroup;
+		goto free_vqs;
 
 	err = vhost_dev_alloc_iovecs(dev);
 	if (err)
-		goto err_cgroup;
+		goto clean_workers;
 
 	return 0;
-err_cgroup:
-	kthread_stop(worker);
-	dev->worker = NULL;
-err_worker:
+clean_workers:
+	vhost_stop_workers(dev);
+free_vqs:
 	if (dev->mm)
 		mmput(dev->mm);
 	dev->mm = NULL;
+	vhost_free_vqs(dev);
 err_mm:
 	return err;
 }
@@ -474,14 +568,7 @@ void vhost_dev_cleanup(struct vhost_dev 
 	kfree(rcu_dereference_protected(dev->memory,
 					lockdep_is_held(&dev->mutex)));
 	RCU_INIT_POINTER(dev->memory, NULL);
-	WARN_ON(!list_empty(&dev->work_list));
-	if (dev->worker) {
-		kthread_stop(dev->worker);
-		dev->worker = NULL;
-	}
-	if (dev->mm)
-		mmput(dev->mm);
-	dev->mm = NULL;
+	vhost_stop_workers(dev);
 }
 
 static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
@@ -835,7 +922,7 @@ long vhost_dev_ioctl(struct vhost_dev *d
 
 	/* If you are not the owner, you can become one */
 	if (ioctl == VHOST_SET_OWNER) {
-		r = vhost_dev_set_owner(d);
+		r = vhost_dev_set_owner(d, arg);
 		goto done;
 	}
 
diff -ruNp org/drivers/vhost/vhost.h new/drivers/vhost/vhost.h
--- org/drivers/vhost/vhost.h	2011-11-11 16:44:56.000000000 +0530
+++ new/drivers/vhost/vhost.h	2011-11-11 16:45:11.000000000 +0530
@@ -18,6 +18,9 @@
 #define VHOST_DMA_DONE_LEN	1
 #define VHOST_DMA_CLEAR_LEN	0
 
+/* TX vqs are those vq's whose qnum's are odd */
+#define VHOST_NET_TX_VQS	0x1
+
 struct vhost_device;
 
 struct vhost_work;
@@ -40,11 +43,11 @@ struct vhost_poll {
 	wait_queue_t              wait;
 	struct vhost_work	  work;
 	unsigned long		  mask;
-	struct vhost_dev	 *dev;
+	struct vhost_virtqueue	  *vq;  /* points back to vq */
 };
 
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev);
+		     unsigned long mask, struct vhost_virtqueue *vq);
 void vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
 void vhost_poll_flush(struct vhost_poll *poll);
@@ -141,8 +144,21 @@ struct vhost_virtqueue {
 	/* Reference counting for outstanding ubufs.
 	 * Protected by vq mutex. Writers must also take device mutex. */
 	struct vhost_ubuf_ref *ubufs;
+
+	struct task_struct *worker; /* worker for this vq */
+	spinlock_t *work_lock;	/* points to a dev->work_lock[] entry */
+	struct list_head *work_list;	/* points to a dev->work_list[] entry */
+	int qnum;	/* 0 for RX, 1 for TX, and so on alternatively */
 };
 
+/* work entry and the lock */
+struct work_lock_list {
+	spinlock_t work_lock;
+	struct list_head work_list;
+} ____cacheline_aligned_in_smp;
+
+#define MAX_VHOST_THREADS	4
+
 struct vhost_dev {
 	/* Readers use RCU to access memory table pointer
 	 * log base pointer and features.
@@ -155,11 +171,11 @@ struct vhost_dev {
 	int nvqs;
 	struct file *log_file;
 	struct eventfd_ctx *log_ctx;
-	spinlock_t work_lock;
-	struct list_head work_list;
-	struct task_struct *worker;
+	struct work_lock_list work[MAX_VHOST_THREADS];
 };
 
+int vhost_setup_vqs(struct vhost_dev *dev, int numtxqs);
+void vhost_free_vqs(struct vhost_dev *dev);
 long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
 long vhost_dev_check_owner(struct vhost_dev *);
 long vhost_dev_reset_owner(struct vhost_dev *);
