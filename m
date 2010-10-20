From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [v3 RFC PATCH 3/4] Changes for vhost
Date: Wed, 20 Oct 2010 14:25:15 +0530
Message-ID: <20101020085515.15579.26368.sendpatchset@krkumar2.in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
Cc: arnd@arndb.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	avi@redhat.com, anthony@codemonkey.ws, kvm@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes for mq vhost.

vhost_net_open is changed to allocate a vhost_net and
return.  The remaining initializations are delayed till
SET_OWNER.  SET_OWNER is changed so that the argument
is used to determine how many txqs to use.  Unmodified
qemu's will pass NULL, so this is recognized and handled
as numtxqs=1.

Besides changing handle_tx to use 'vq', this patch also
changes handle_rx to take vq as parameter.  The mq RX
patch requires this change, but till then it is consistent
(and less confusing) to make the interfaces for handling
rx and tx similar.

vhost thread handling for RX and TX is as follows.  The
first vhost thread handles RX traffic, while the remaining
threads handles TX.  The number of threads is <= #txqs, and
threads handle more than one txq when #txqs is more than
MAX_VHOST_THREADS (4).  When guest is started with >1 txqs
and there is only one stream of traffic from the guest,
that is recognized and handled such that vhost[0] processes
both RX and TX.  This can change dynamically.  vhost_poll
has a new element - find_vq(), which allows optimizing some
code for cases where numtxqs=1 or a packet on vhost[0]
needs processing.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/vhost/net.c   |  284 ++++++++++++++++++++++++++--------------
 drivers/vhost/vhost.c |  275 ++++++++++++++++++++++++++++----------
 drivers/vhost/vhost.h |   42 +++++
 3 files changed, 430 insertions(+), 171 deletions(-)

diff -ruNp org/drivers/vhost/vhost.h new/drivers/vhost/vhost.h
--- org/drivers/vhost/vhost.h	2010-10-11 10:21:14.000000000 +0530
+++ new/drivers/vhost/vhost.h	2010-10-20 14:11:23.000000000 +0530
@@ -35,11 +35,13 @@ struct vhost_poll {
 	wait_queue_t              wait;
 	struct vhost_work	  work;
 	unsigned long		  mask;
-	struct vhost_dev	 *dev;
+	struct vhost_virtqueue	  *(*find_vq)(struct vhost_poll *poll);
+	struct vhost_virtqueue	  *vq;  /* points back to vq */
 };
 
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev);
+		     unsigned long mask, struct vhost_virtqueue *vq,
+		     int single_queue);
 void vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
 void vhost_poll_flush(struct vhost_poll *poll);
@@ -108,6 +110,10 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	struct task_struct *worker; /* vhost for this vq, can be shared */
+	spinlock_t *work_lock;
+	struct list_head *work_list;
+	int qnum;		/* 0 for RX, 1 -> n-1 for TX */
 };
 
 struct vhost_dev {
@@ -119,15 +125,39 @@ struct vhost_dev {
 	struct mutex mutex;
 	unsigned acked_features;
 	struct vhost_virtqueue *vqs;
+	unsigned long *jiffies;
 	int nvqs;
 	struct file *log_file;
 	struct eventfd_ctx *log_ctx;
-	spinlock_t work_lock;
-	struct list_head work_list;
-	struct task_struct *worker;
+	spinlock_t *work_lock;
+	struct list_head *work_list;
 };
 
-long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
+/*
+ * Define maximum number of TX threads, and use that to have a maximum
+ * number of vhost threads to handle RX & TX. First thread handles RX.
+ * If guest is started with #txqs=1, only one vhost thread is started.
+ * Else, upto MAX_VHOST_THREADS are started where th[0] handles RX and
+ * remaining handles TX. However, vhost_poll_queue has an optimization
+ * where th[0] is selected for both RX & TX if there is only one flow.
+ */
+#define MAX_TXQ_THREADS		4
+#define MAX_VHOST_THREADS	(MAX_TXQ_THREADS + 1)
+
+static inline int get_nvhosts(int nvqs)
+{
+	int num_vhosts = nvqs - 1;
+
+	if (nvqs > 2)
+		num_vhosts = min_t(int, nvqs, MAX_VHOST_THREADS);
+
+	return num_vhosts;
+}
+
+int vhost_setup_vqs(struct vhost_dev *dev, int numtxqs);
+void vhost_free_vqs(struct vhost_dev *dev);
+long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs,
+		    int nvhosts);
 long vhost_dev_check_owner(struct vhost_dev *);
 long vhost_dev_reset_owner(struct vhost_dev *);
 void vhost_dev_cleanup(struct vhost_dev *);
diff -ruNp org/drivers/vhost/net.c new/drivers/vhost/net.c
--- org/drivers/vhost/net.c	2010-10-11 10:21:14.000000000 +0530
+++ new/drivers/vhost/net.c	2010-10-20 14:20:10.000000000 +0530
@@ -33,12 +33,6 @@
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
-enum {
-	VHOST_NET_VQ_RX = 0,
-	VHOST_NET_VQ_TX = 1,
-	VHOST_NET_VQ_MAX = 2,
-};
-
 enum vhost_net_poll_state {
 	VHOST_NET_POLL_DISABLED = 0,
 	VHOST_NET_POLL_STARTED = 1,
@@ -47,12 +41,13 @@ enum vhost_net_poll_state {
 
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
 
 /* Pop first len bytes from iovec. Return number of segments used. */
@@ -92,28 +87,28 @@ static void copy_iovec_hdr(const struct 
 }
 
 /* Caller must have TX VQ lock */
-static void tx_poll_stop(struct vhost_net *net)
+static void tx_poll_stop(struct vhost_net *net, int qnum)
 {
-	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
+	if (likely(net->tx_poll_state[qnum] != VHOST_NET_POLL_STARTED))
 		return;
-	vhost_poll_stop(net->poll + VHOST_NET_VQ_TX);
-	net->tx_poll_state = VHOST_NET_POLL_STOPPED;
+	vhost_poll_stop(&net->poll[qnum]);
+	net->tx_poll_state[qnum] = VHOST_NET_POLL_STOPPED;
 }
 
 /* Caller must have TX VQ lock */
-static void tx_poll_start(struct vhost_net *net, struct socket *sock)
+static void tx_poll_start(struct vhost_net *net, struct socket *sock, int qnum)
 {
-	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
+	if (unlikely(net->tx_poll_state[qnum] != VHOST_NET_POLL_STOPPED))
 		return;
-	vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
-	net->tx_poll_state = VHOST_NET_POLL_STARTED;
+	vhost_poll_start(&net->poll[qnum], sock->file);
+	net->tx_poll_state[qnum] = VHOST_NET_POLL_STARTED;
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
@@ -134,7 +129,7 @@ static void handle_tx(struct vhost_net *
 	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 	if (wmem >= sock->sk->sk_sndbuf) {
 		mutex_lock(&vq->mutex);
-		tx_poll_start(net, sock);
+		tx_poll_start(net, sock, vq->qnum);
 		mutex_unlock(&vq->mutex);
 		return;
 	}
@@ -144,7 +139,7 @@ static void handle_tx(struct vhost_net *
 	vhost_disable_notify(vq);
 
 	if (wmem < sock->sk->sk_sndbuf / 2)
-		tx_poll_stop(net);
+		tx_poll_stop(net, vq->qnum);
 	hdr_size = vq->vhost_hlen;
 
 	for (;;) {
@@ -159,7 +154,7 @@ static void handle_tx(struct vhost_net *
 		if (head == vq->num) {
 			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
-				tx_poll_start(net, sock);
+				tx_poll_start(net, sock, vq->qnum);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
@@ -189,7 +184,7 @@ static void handle_tx(struct vhost_net *
 		err = sock->ops->sendmsg(NULL, sock, &msg, len);
 		if (unlikely(err < 0)) {
 			vhost_discard_vq_desc(vq, 1);
-			tx_poll_start(net, sock);
+			tx_poll_start(net, sock, vq->qnum);
 			break;
 		}
 		if (err != len)
@@ -282,9 +277,9 @@ err:
 
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
-static void handle_rx_big(struct vhost_net *net)
+static void handle_rx_big(struct vhost_virtqueue *vq,
+			  struct vhost_net *net)
 {
-	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
 	unsigned out, in, log, s;
 	int head;
 	struct vhost_log *vq_log;
@@ -393,9 +388,9 @@ static void handle_rx_big(struct vhost_n
 
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
-static void handle_rx_mergeable(struct vhost_net *net)
+static void handle_rx_mergeable(struct vhost_virtqueue *vq,
+				struct vhost_net *net)
 {
-	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
 	unsigned uninitialized_var(in), log;
 	struct vhost_log *vq_log;
 	struct msghdr msg = {
@@ -500,96 +495,184 @@ static void handle_rx_mergeable(struct v
 	unuse_mm(net->dev.mm);
 }
 
-static void handle_rx(struct vhost_net *net)
+static void handle_rx(struct vhost_virtqueue *vq)
 {
+	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
+
 	if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF))
-		handle_rx_mergeable(net);
+		handle_rx_mergeable(vq, net);
 	else
-		handle_rx_big(net);
+		handle_rx_big(vq, net);
 }
 
 static void handle_tx_kick(struct vhost_work *work)
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
+
+	kfree(dev->work_list);
+	kfree(dev->work_lock);
+	kfree(dev->jiffies);
+	kfree(n->socks);
+	kfree(n->tx_poll_state);
+	kfree(n->poll);
+	kfree(n->vqs);
+
+	/*
+	 * Reset so that vhost_net_release (after vhost_dev_set_owner call)
+	 * will notice.
+	 */
+	n->vqs = NULL;
+	n->poll = NULL;
+	n->socks = NULL;
+	n->tx_poll_state = NULL;
+	dev->jiffies = NULL;
+	dev->work_lock = NULL;
+	dev->work_list = NULL;
+}
+
+int vhost_setup_vqs(struct vhost_dev *dev, int numtxqs)
+{
+	struct vhost_net *n = container_of(dev, struct vhost_net, dev);
+	int nvhosts;
+	int i, nvqs;
+	int ret;
+
+	if (numtxqs < 0 || numtxqs > VIRTIO_MAX_SQ)
+		return -EINVAL;
+
+	if (numtxqs == 0) {
+		/* Old qemu doesn't pass arguments to set_owner, use 1 txq */
+		numtxqs = 1;
+	}
+
+	/* Get total number of virtqueues */
+	nvqs = numtxqs + 1;
+
+	/* Get total number of vhost threads */
+	nvhosts = get_nvhosts(nvqs);
+
+	n->vqs = kmalloc(nvqs * sizeof(*n->vqs), GFP_KERNEL);
+	n->poll = kmalloc(nvqs * sizeof(*n->poll), GFP_KERNEL);
+	n->socks = kmalloc(nvqs * sizeof(*n->socks), GFP_KERNEL);
+	n->tx_poll_state = kmalloc(nvqs * sizeof(*n->tx_poll_state),
+				   GFP_KERNEL);
+	dev->jiffies = kzalloc(numtxqs * sizeof(*dev->jiffies), GFP_KERNEL);
+	dev->work_lock = kmalloc(nvhosts * sizeof(*dev->work_lock),
+				 GFP_KERNEL);
+	dev->work_list = kmalloc(nvhosts * sizeof(*dev->work_list),
+				 GFP_KERNEL);
+
+	if (!n->vqs || !n->poll || !n->socks || !n->tx_poll_state ||
+	    !dev->jiffies || !dev->work_lock || !dev->work_list) {
+		ret = -ENOMEM;
+		goto err;
+	}
 
-	if (!n)
-		return -ENOMEM;
+	/* 1 RX, followed by 'numtxqs' TX queues */
+	n->vqs[0].handle_kick = handle_rx_kick;
 
-	dev = &n->dev;
-	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
-	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
-	r = vhost_dev_init(dev, n->vqs, VHOST_NET_VQ_MAX);
-	if (r < 0) {
-		kfree(n);
-		return r;
-	}
+	for (i = 1; i < nvqs; i++)
+		n->vqs[i].handle_kick = handle_tx_kick;
+
+	ret = vhost_dev_init(dev, n->vqs, nvqs, nvhosts);
+	if (ret < 0)
+		goto err;
 
-	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
-	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
-	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
+	vhost_poll_init(&n->poll[0], handle_rx_net, POLLIN, &n->vqs[0], 1);
 
-	f->private_data = n;
+	for (i = 1; i < nvqs; i++) {
+		vhost_poll_init(&n->poll[i], handle_tx_net, POLLOUT,
+				&n->vqs[i], (nvqs == 2));
+		n->tx_poll_state[i] = VHOST_NET_POLL_DISABLED;
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
+	int ret = ENOMEM;
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
+	if (qnum) {	/* TX */
+		tx_poll_stop(n, qnum);
+		n->tx_poll_state[qnum] = VHOST_NET_POLL_DISABLED;
 	} else
-		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
+		vhost_poll_stop(&n->poll[qnum]);
 }
 
 static void vhost_net_enable_vq(struct vhost_net *n,
 				struct vhost_virtqueue *vq)
 {
 	struct socket *sock = vq->private_data;
+	int qnum = vq->qnum;
+
 	if (!sock)
 		return;
-	if (vq == n->vqs + VHOST_NET_VQ_TX) {
-		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
-		tx_poll_start(n, sock);
+
+	if (qnum) {	/* TX */
+		n->tx_poll_state[qnum] = VHOST_NET_POLL_STOPPED;
+		tx_poll_start(n, sock, qnum);
 	} else
-		vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
+		vhost_poll_start(&n->poll[qnum], sock->file);
 }
 
 static struct socket *vhost_net_stop_vq(struct vhost_net *n,
@@ -605,11 +688,12 @@ static struct socket *vhost_net_stop_vq(
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
+	for (i = n->dev.nvqs - 1; i >= 0; i--)
+		n->socks[i] = vhost_net_stop_vq(n, &n->vqs[i]);
 }
 
 static void vhost_net_flush_vq(struct vhost_net *n, int index)
@@ -620,26 +704,33 @@ static void vhost_net_flush_vq(struct vh
 
 static void vhost_net_flush(struct vhost_net *n)
 {
-	vhost_net_flush_vq(n, VHOST_NET_VQ_TX);
-	vhost_net_flush_vq(n, VHOST_NET_VQ_RX);
+	int i;
+
+	for (i = n->dev.nvqs - 1; i >= 0; i--)
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
+	for (i = n->dev.nvqs - 1; i >= 0; i--)
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
@@ -717,7 +808,7 @@ static long vhost_net_set_backend(struct
 	if (r)
 		goto err;
 
-	if (index >= VHOST_NET_VQ_MAX) {
+	if (index >= n->dev.nvqs) {
 		r = -ENOBUFS;
 		goto err;
 	}
@@ -738,9 +829,9 @@ static long vhost_net_set_backend(struct
 	/* start polling new socket */
 	oldsock = vq->private_data;
 	if (sock != oldsock) {
-                vhost_net_disable_vq(n, vq);
-                rcu_assign_pointer(vq->private_data, sock);
-                vhost_net_enable_vq(n, vq);
+		vhost_net_disable_vq(n, vq);
+		rcu_assign_pointer(vq->private_data, sock);
+		vhost_net_enable_vq(n, vq);
 	}
 
 	mutex_unlock(&vq->mutex);
@@ -762,22 +853,25 @@ err:
 
 static long vhost_net_reset_owner(struct vhost_net *n)
 {
-	struct socket *tx_sock = NULL;
-	struct socket *rx_sock = NULL;
 	long err;
+	int i;
+
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
+	for (i = n->dev.nvqs - 1; i >= 0; i--)
+		if (n->socks[i])
+			fput(n->socks[i]->file);
+
 	return err;
 }
 
@@ -806,7 +900,7 @@ static int vhost_net_set_features(struct
 	}
 	n->dev.acked_features = features;
 	smp_wmb();
-	for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
+	for (i = 0; i < n->dev.nvqs; ++i) {
 		mutex_lock(&n->vqs[i].mutex);
 		n->vqs[i].vhost_hlen = vhost_hlen;
 		n->vqs[i].sock_hlen = sock_hlen;
diff -ruNp org/drivers/vhost/vhost.c new/drivers/vhost/vhost.c
--- org/drivers/vhost/vhost.c	2010-10-11 10:21:14.000000000 +0530
+++ new/drivers/vhost/vhost.c	2010-10-20 14:20:04.000000000 +0530
@@ -69,16 +69,70 @@ static void vhost_work_init(struct vhost
 	work->queue_seq = work->done_seq = 0;
 }
 
+/*
+ * __vhost_sq_find_vq: This is the poll->find_vq() handler for cases:
+ *	- #numtxqs == 1; or
+ *	- this is an RX vq
+ */
+static struct vhost_virtqueue *__vhost_sq_find_vq(struct vhost_poll *poll)
+{
+	return poll->vq;
+}
+
+/* Define how recently a txq was used, beyond this it is considered unused */
+#define RECENTLY_USED  5
+
+/*
+ * __vhost_mq_find_vq: This is the poll->find_vq() handler for cases:
+ *	- #numtxqs > 1, and
+ *	- this is a TX vq
+ *
+ * Algorithm for selecting vq:
+ *
+ *	Condition:					Return:
+ *	If all txqs unused				vq[0]
+ *	If one txq used, and new txq is same		vq[0]
+ *	If one txq used, and new txq is different	vq[vq->qnum]
+ *	If > 1 txqs used				vq[vq->qnum]
+ * Where "used" means the txq was used in the last RECENTLY_USED jiffies.
+ *
+ * Note: locking is not required as an update race will only result in
+ * a different worker being woken up.
+ */
+static struct vhost_virtqueue *__vhost_mq_find_vq(struct vhost_poll *poll)
+{
+	struct vhost_dev *dev = poll->vq->dev;
+	struct vhost_virtqueue *vq = &dev->vqs[0];
+	unsigned long max_time = jiffies - RECENTLY_USED;
+	unsigned long *table = dev->jiffies;
+	int i, used = 0;
+
+	for (i = 0; i < dev->nvqs - 1; i++) {
+		if (time_after_eq(table[i], max_time) && ++used > 1) {
+			vq = poll->vq;
+			break;
+		}
+	}
+
+	table[poll->vq->qnum - 1] = jiffies;
+	return vq;
+}
+
 /* Init poll structure */
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev)
+		     unsigned long mask, struct vhost_virtqueue *vq,
+		     int single_queue)
 {
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
-	poll->dev = dev;
+	poll->vq = vq;
 
 	vhost_work_init(&poll->work, fn);
+	if (single_queue)
+		poll->find_vq = __vhost_sq_find_vq;
+	else
+		poll->find_vq = __vhost_mq_find_vq;
 }
 
 /* Start polling a file. We add ourselves to file's wait queue. The caller must
@@ -98,25 +152,25 @@ void vhost_poll_stop(struct vhost_poll *
 	remove_wait_queue(poll->wqh, &poll->wait);
 }
 
-static void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
+static void vhost_work_flush(struct vhost_poll *poll, struct vhost_work *work)
 {
 	unsigned seq;
 	int left;
 	int flushing;
 
-	spin_lock_irq(&dev->work_lock);
+	spin_lock_irq(poll->vq->work_lock);
 	seq = work->queue_seq;
 	work->flushing++;
-	spin_unlock_irq(&dev->work_lock);
+	spin_unlock_irq(poll->vq->work_lock);
 	wait_event(work->done, ({
-		   spin_lock_irq(&dev->work_lock);
+		   spin_lock_irq(poll->vq->work_lock);
 		   left = seq - work->done_seq <= 0;
-		   spin_unlock_irq(&dev->work_lock);
+		   spin_unlock_irq(poll->vq->work_lock);
 		   left;
 	}));
-	spin_lock_irq(&dev->work_lock);
+	spin_lock_irq(poll->vq->work_lock);
 	flushing = --work->flushing;
-	spin_unlock_irq(&dev->work_lock);
+	spin_unlock_irq(poll->vq->work_lock);
 	BUG_ON(flushing < 0);
 }
 
@@ -124,26 +178,28 @@ static void vhost_work_flush(struct vhos
  * locks that are also used by the callback. */
 void vhost_poll_flush(struct vhost_poll *poll)
 {
-	vhost_work_flush(poll->dev, &poll->work);
+	vhost_work_flush(poll, &poll->work);
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
+	struct vhost_virtqueue *vq = poll->find_vq(poll);
+
+	vhost_work_queue(vq, &poll->work);
 }
 
 static void vhost_vq_reset(struct vhost_dev *dev,
@@ -174,7 +230,7 @@ static void vhost_vq_reset(struct vhost_
 
 static int vhost_worker(void *data)
 {
-	struct vhost_dev *dev = data;
+	struct vhost_virtqueue *vq = data;
 	struct vhost_work *work = NULL;
 	unsigned uninitialized_var(seq);
 
@@ -182,7 +238,7 @@ static int vhost_worker(void *data)
 		/* mb paired w/ kthread_stop */
 		set_current_state(TASK_INTERRUPTIBLE);
 
-		spin_lock_irq(&dev->work_lock);
+		spin_lock_irq(vq->work_lock);
 		if (work) {
 			work->done_seq = seq;
 			if (work->flushing)
@@ -190,18 +246,18 @@ static int vhost_worker(void *data)
 		}
 
 		if (kthread_should_stop()) {
-			spin_unlock_irq(&dev->work_lock);
+			spin_unlock_irq(vq->work_lock);
 			__set_current_state(TASK_RUNNING);
 			return 0;
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
@@ -251,8 +307,19 @@ static void vhost_dev_free_iovecs(struct
 	}
 }
 
+/* Get index of an existing thread that will handle this txq */
+static int vhost_get_buddy_thread(int index, int nvhosts)
+{
+	int buddy = 0;
+
+	if (nvhosts > 1)
+		buddy = (index - 1) % MAX_TXQ_THREADS + 1;
+
+	return buddy;
+}
+
 long vhost_dev_init(struct vhost_dev *dev,
-		    struct vhost_virtqueue *vqs, int nvqs)
+		    struct vhost_virtqueue *vqs, int nvqs, int nvhosts)
 {
 	int i;
 
@@ -263,20 +330,37 @@ long vhost_dev_init(struct vhost_dev *de
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
-		dev->vqs[i].dev = dev;
-		mutex_init(&dev->vqs[i].mutex);
+		struct vhost_virtqueue *vq = &dev->vqs[i];
+		int single_queue = (!i || dev->nvqs == 2);
+
+		if (i < nvhosts) {
+			spin_lock_init(&dev->work_lock[i]);
+			INIT_LIST_HEAD(&dev->work_list[i]);
+
+			vq->work_lock = &dev->work_lock[i];
+			vq->work_list = &dev->work_list[i];
+		} else {
+			/* Share work with another thread */
+			int j = vhost_get_buddy_thread(i, nvhosts);
+
+			vq->work_lock = &dev->work_lock[j];
+			vq->work_list = &dev->work_list[j];
+		}
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
+					vq->handle_kick, POLLIN, vq,
+					single_queue);
 	}
 
 	return 0;
@@ -290,61 +374,116 @@ long vhost_dev_check_owner(struct vhost_
 }
 
 struct vhost_attach_cgroups_struct {
-        struct vhost_work work;
-        struct task_struct *owner;
-        int ret;
+	struct vhost_work work;
+	struct task_struct *owner;
+	int ret;
 };
 
 static void vhost_attach_cgroups_work(struct vhost_work *work)
 {
-        struct vhost_attach_cgroups_struct *s;
-        s = container_of(work, struct vhost_attach_cgroups_struct, work);
-        s->ret = cgroup_attach_task_all(s->owner, current);
+	struct vhost_attach_cgroups_struct *s;
+	s = container_of(work, struct vhost_attach_cgroups_struct, work);
+	s->ret = cgroup_attach_task_all(s->owner, current);
 }
 
-static int vhost_attach_cgroups(struct vhost_dev *dev)
-{
-        struct vhost_attach_cgroups_struct attach;
-        attach.owner = current;
-        vhost_work_init(&attach.work, vhost_attach_cgroups_work);
-        vhost_work_queue(dev, &attach.work);
-        vhost_work_flush(dev, &attach.work);
-        return attach.ret;
+static int vhost_attach_cgroups(struct vhost_virtqueue *vq)
+{
+	struct vhost_attach_cgroups_struct attach;
+	attach.owner = current;
+	vhost_work_init(&attach.work, vhost_attach_cgroups_work);
+	vhost_work_queue(vq, &attach.work);
+	vhost_work_flush(&vq->poll, &attach.work);
+	return attach.ret;
+}
+
+static void __vhost_stop_workers(struct vhost_dev *dev, int nvhosts)
+{
+	int i;
+
+	for (i = 0; i < nvhosts; i++) {
+		WARN_ON(!list_empty(dev->vqs[i].work_list));
+		if (dev->vqs[i].worker) {
+			kthread_stop(dev->vqs[i].worker);
+			dev->vqs[i].worker = NULL;
+		}
+	}
+}
+
+static void vhost_stop_workers(struct vhost_dev *dev)
+{
+	__vhost_stop_workers(dev, get_nvhosts(dev->nvqs));
+}
+
+static int vhost_start_workers(struct vhost_dev *dev)
+{
+	int nvhosts = get_nvhosts(dev->nvqs);
+	int i, err;
+
+	for (i = 0; i < dev->nvqs; ++i) {
+		struct vhost_virtqueue *vq = &dev->vqs[i];
+
+		if (i < nvhosts) {
+			/* Start a new thread */
+			vq->worker = kthread_create(vhost_worker, vq,
+						    "vhost-%d-%d",
+						    current->pid, i);
+			if (IS_ERR(vq->worker)) {
+				i--;	/* no thread to clean at this index */
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
+			int j = vhost_get_buddy_thread(i, nvhosts);
+			struct vhost_virtqueue *share_vq = &dev->vqs[j];
+
+			vq->worker = share_vq->worker;
+		}
+	}
+	return 0;
+
+err:
+	__vhost_stop_workers(dev, i);
+	return err;
 }
 
 /* Caller should have device mutex */
-static long vhost_dev_set_owner(struct vhost_dev *dev)
+static long vhost_dev_set_owner(struct vhost_dev *dev, int numtxqs)
 {
-	struct task_struct *worker;
 	int err;
 	/* Is there an owner already? */
 	if (dev->mm) {
 		err = -EBUSY;
 		goto err_mm;
 	}
+
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
+		goto err_worker;
 
 	err = vhost_dev_alloc_iovecs(dev);
 	if (err)
-		goto err_cgroup;
+		goto err_iovec;
 
 	return 0;
-err_cgroup:
-	kthread_stop(worker);
-	dev->worker = NULL;
+err_iovec:
+	vhost_stop_workers(dev);
+	vhost_free_vqs(dev);
 err_worker:
 	if (dev->mm)
 		mmput(dev->mm);
@@ -405,11 +544,7 @@ void vhost_dev_cleanup(struct vhost_dev 
 		mmput(dev->mm);
 	dev->mm = NULL;
 
-	WARN_ON(!list_empty(&dev->work_list));
-	if (dev->worker) {
-		kthread_stop(dev->worker);
-		dev->worker = NULL;
-	}
+	vhost_stop_workers(dev);
 }
 
 static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
@@ -760,7 +895,7 @@ long vhost_dev_ioctl(struct vhost_dev *d
 
 	/* If you are not the owner, you can become one */
 	if (ioctl == VHOST_SET_OWNER) {
-		r = vhost_dev_set_owner(d);
+		r = vhost_dev_set_owner(d, arg);
 		goto done;
 	}
 
