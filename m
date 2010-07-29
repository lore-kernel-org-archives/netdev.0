From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: locking/rcu cleanup
Date: Thu, 29 Jul 2010 15:23:25 +0300
Message-ID: <20100729122325.GA24337__27048.1838765138$1280406627$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sridhar Samudrala <samudrala@us.ibm.com>,
	Tejun Heo <tj@kernel.org>, Jeff Dike <jdike@linux.intel.com>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49641 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753125Ab0G2M3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jul 2010 08:29:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I saw WARN_ON(!list_empty(&dev->work_list)) trigger
so our custom flush is not as airtight as need be.

This patch switches to a simple atomic counter + srcu instead of
the custom locked queue + flush implementation.

This will slow down the setup ioctls, which should not matter -
it's slow path anyway. We use the expedited flush to at least
make sure it has a sane time bound.

Works fine for me. I got reports that with many guests,
work lock is highly contended, and this patch should in theory
fix this as well - but I haven't tested this yet.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c   |   55 +++++--------------
 drivers/vhost/vhost.c |  140 ++++++++++++++++++++++---------------------------
 drivers/vhost/vhost.h |   47 +++++++++-------
 3 files changed, 103 insertions(+), 139 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f13e56b..ee69c51 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -111,8 +111,9 @@ static void tx_poll_start(struct vhost_net *net, struct socket *sock)
 
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
-static void handle_tx(struct vhost_net *net)
+static void handle_tx(struct vhost_dev *dev)
 {
+	struct vhost_net *net = container_of(dev, struct vhost_net, dev);
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
 	unsigned out, in, s;
 	int head;
@@ -127,7 +128,7 @@ static void handle_tx(struct vhost_net *net)
 	size_t len, total_len = 0;
 	int err, wmem;
 	size_t hdr_size;
-	struct socket *sock = rcu_dereference(vq->private_data);
+	struct socket *sock = vhost_vq_data(vq, &net->dev);
 	if (!sock)
 		return;
 
@@ -305,7 +306,7 @@ static void handle_rx_big(struct vhost_net *net)
 	size_t len, total_len = 0;
 	int err;
 	size_t hdr_size;
-	struct socket *sock = rcu_dereference(vq->private_data);
+	struct socket *sock = vhost_vq_data(vq, &net->dev);
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
 		return;
 
@@ -416,7 +417,7 @@ static void handle_rx_mergeable(struct vhost_net *net)
 	int err, headcount;
 	size_t vhost_hlen, sock_hlen;
 	size_t vhost_len, sock_len;
-	struct socket *sock = rcu_dereference(vq->private_data);
+	struct socket *sock = vhost_vq_data(vq, &net->dev);
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
 		return;
 
@@ -500,46 +501,15 @@ static void handle_rx_mergeable(struct vhost_net *net)
 	unuse_mm(net->dev.mm);
 }
 
-static void handle_rx(struct vhost_net *net)
+static void handle_rx(struct vhost_dev *dev)
 {
+	struct vhost_net *net = container_of(dev, struct vhost_net, dev);
 	if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF))
 		handle_rx_mergeable(net);
 	else
 		handle_rx_big(net);
 }
 
-static void handle_tx_kick(struct vhost_work *work)
-{
-	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
-						  poll.work);
-	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
-
-	handle_tx(net);
-}
-
-static void handle_rx_kick(struct vhost_work *work)
-{
-	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
-						  poll.work);
-	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
-
-	handle_rx(net);
-}
-
-static void handle_tx_net(struct vhost_work *work)
-{
-	struct vhost_net *net = container_of(work, struct vhost_net,
-					     poll[VHOST_NET_VQ_TX].work);
-	handle_tx(net);
-}
-
-static void handle_rx_net(struct vhost_work *work)
-{
-	struct vhost_net *net = container_of(work, struct vhost_net,
-					     poll[VHOST_NET_VQ_RX].work);
-	handle_rx(net);
-}
-
 static int vhost_net_open(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
@@ -550,16 +520,18 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 		return -ENOMEM;
 
 	dev = &n->dev;
-	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
-	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
+	vhost_work_set_fn(&n->vqs[VHOST_NET_VQ_TX].work, handle_tx);
+	vhost_work_set_fn(&n->vqs[VHOST_NET_VQ_RX].work, handle_rx);
 	r = vhost_dev_init(dev, n->vqs, VHOST_NET_VQ_MAX);
 	if (r < 0) {
 		kfree(n);
 		return r;
 	}
 
-	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
-	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_TX,
+			&n->vqs[VHOST_NET_VQ_TX].work, POLLOUT, dev);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_RX,
+			&n->vqs[VHOST_NET_VQ_RX].work, POLLIN, dev);
 	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
 
 	f->private_data = n;
@@ -640,6 +612,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
+	vhost_dev_free(&n->dev);
 	kfree(n);
 	return 0;
 }
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index e05557d..daa95c8 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -60,22 +60,27 @@ static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
 	return 0;
 }
 
+/* Must be called for each vq before vhost_dev_init. */
+void vhost_work_set_fn(struct vhost_work *work, vhost_work_fn_t fn)
+{
+	work->fn = fn;
+}
+
+static void vhost_work_init(struct vhost_work *work)
+{
+	atomic_set(&work->queue_seq, 0);
+	work->done_seq = 0;
+}
+
 /* Init poll structure */
-void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
+void vhost_poll_init(struct vhost_poll *poll, struct vhost_work *work,
 		     unsigned long mask, struct vhost_dev *dev)
 {
-	struct vhost_work *work = &poll->work;
-
+	poll->work = work;
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
 	poll->dev = dev;
-
-	INIT_LIST_HEAD(&work->node);
-	work->fn = fn;
-	init_waitqueue_head(&work->done);
-	work->flushing = 0;
-	work->queue_seq = work->done_seq = 0;
 }
 
 /* Start polling a file. We add ourselves to file's wait queue. The caller must
@@ -99,40 +104,16 @@ void vhost_poll_stop(struct vhost_poll *poll)
  * locks that are also used by the callback. */
 void vhost_poll_flush(struct vhost_poll *poll)
 {
-	struct vhost_work *work = &poll->work;
-	unsigned seq;
-	int left;
-	int flushing;
-
-	spin_lock_irq(&poll->dev->work_lock);
-	seq = work->queue_seq;
-	work->flushing++;
-	spin_unlock_irq(&poll->dev->work_lock);
-	wait_event(work->done, ({
-		   spin_lock_irq(&poll->dev->work_lock);
-		   left = seq - work->done_seq <= 0;
-		   spin_unlock_irq(&poll->dev->work_lock);
-		   left;
-	}));
-	spin_lock_irq(&poll->dev->work_lock);
-	flushing = --work->flushing;
-	spin_unlock_irq(&poll->dev->work_lock);
-	BUG_ON(flushing < 0);
+	synchronize_srcu_expedited(&poll->dev->worker_srcu);
 }
 
 void vhost_poll_queue(struct vhost_poll *poll)
 {
 	struct vhost_dev *dev = poll->dev;
-	struct vhost_work *work = &poll->work;
-	unsigned long flags;
-
-	spin_lock_irqsave(&dev->work_lock, flags);
-	if (list_empty(&work->node)) {
-		list_add_tail(&work->node, &dev->work_list);
-		work->queue_seq++;
-		wake_up_process(dev->worker);
-	}
-	spin_unlock_irqrestore(&dev->work_lock, flags);
+	struct vhost_work *work = poll->work;
+
+	atomic_inc(&work->queue_seq);
+	wake_up_process(dev->worker);
 }
 
 static void vhost_vq_reset(struct vhost_dev *dev,
@@ -164,41 +145,39 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 static int vhost_worker(void *data)
 {
 	struct vhost_dev *dev = data;
-	struct vhost_work *work = NULL;
-	unsigned uninitialized_var(seq);
+	struct vhost_work *uninitialized_var(work);
+	unsigned n, i, vq = 0;
+	int seq;
 
-	for (;;) {
-		/* mb paired w/ kthread_stop */
-		set_current_state(TASK_INTERRUPTIBLE);
+	n = dev->nvqs;
+repeat:
+	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
 
-		spin_lock_irq(&dev->work_lock);
-		if (work) {
-			work->done_seq = seq;
-			if (work->flushing)
-				wake_up_all(&work->done);
-		}
+	if (kthread_should_stop()) {
+		__set_current_state(TASK_RUNNING);
+		return 0;
+	}
 
-		if (kthread_should_stop()) {
-			spin_unlock_irq(&dev->work_lock);
-			__set_current_state(TASK_RUNNING);
-			return 0;
+	for (i = 0; i < n; ++i) {
+		work = &dev->vqs[(vq + i) % n].work;
+		seq = atomic_read(&work->queue_seq);
+		if (seq != work->done_seq) {
+			work->done_seq = seq;
+			break;
 		}
-		if (!list_empty(&dev->work_list)) {
-			work = list_first_entry(&dev->work_list,
-						struct vhost_work, node);
-			list_del_init(&work->node);
-			seq = work->queue_seq;
-		} else
-			work = NULL;
-		spin_unlock_irq(&dev->work_lock);
+		work = NULL;
+	}
 
-		if (work) {
-			__set_current_state(TASK_RUNNING);
-			work->fn(work);
-		} else
-			schedule();
+	if (work) {
+		int idx;
+		__set_current_state(TASK_RUNNING);
+		idx = srcu_read_lock(&dev->worker_srcu);
+		work->fn(dev);
+		srcu_read_unlock(&dev->worker_srcu, idx);
+	} else
+		schedule();
 
-	}
+	goto repeat;
 }
 
 long vhost_dev_init(struct vhost_dev *dev,
@@ -213,20 +192,22 @@ long vhost_dev_init(struct vhost_dev *dev,
 	dev->log_file = NULL;
 	dev->memory = NULL;
 	dev->mm = NULL;
-	spin_lock_init(&dev->work_lock);
-	INIT_LIST_HEAD(&dev->work_list);
 	dev->worker = NULL;
 
 	for (i = 0; i < dev->nvqs; ++i) {
 		dev->vqs[i].dev = dev;
 		mutex_init(&dev->vqs[i].mutex);
 		vhost_vq_reset(dev, dev->vqs + i);
-		if (dev->vqs[i].handle_kick)
+		if (dev->vqs[i].work.fn)
 			vhost_poll_init(&dev->vqs[i].poll,
-					dev->vqs[i].handle_kick, POLLIN, dev);
+					&dev->vqs[i].work, POLLIN, dev);
 	}
+	return init_srcu_struct(&dev->worker_srcu);
+}
 
-	return 0;
+void vhost_dev_free(struct vhost_dev *dev)
+{
+	cleanup_srcu_struct(&dev->worker_srcu);
 }
 
 /* Caller should have device mutex */
@@ -240,7 +221,7 @@ long vhost_dev_check_owner(struct vhost_dev *dev)
 static long vhost_dev_set_owner(struct vhost_dev *dev)
 {
 	struct task_struct *worker;
-	int err;
+	int i, err;
 	/* Is there an owner already? */
 	if (dev->mm) {
 		err = -EBUSY;
@@ -258,6 +239,10 @@ static long vhost_dev_set_owner(struct vhost_dev *dev)
 	err = cgroup_attach_task_current_cg(worker);
 	if (err)
 		goto err_cgroup;
+
+	for (i = 0; i < dev->nvqs; ++i) {
+		vhost_work_init(&dev->vqs[i].work);
+	}
 	wake_up_process(worker);	/* avoid contributing to loadavg */
 
 	return 0;
@@ -293,7 +278,7 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 {
 	int i;
 	for (i = 0; i < dev->nvqs; ++i) {
-		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
+		if (dev->vqs[i].kick && dev->vqs[i].work.fn) {
 			vhost_poll_stop(&dev->vqs[i].poll);
 			vhost_poll_flush(&dev->vqs[i].poll);
 		}
@@ -322,7 +307,6 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 		mmput(dev->mm);
 	dev->mm = NULL;
 
-	WARN_ON(!list_empty(&dev->work_list));
 	kthread_stop(dev->worker);
 }
 
@@ -644,7 +628,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		r = -ENOIOCTLCMD;
 	}
 
-	if (pollstop && vq->handle_kick)
+	if (pollstop && vq->work.fn)
 		vhost_poll_stop(&vq->poll);
 
 	if (ctx)
@@ -652,12 +636,12 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 	if (filep)
 		fput(filep);
 
-	if (pollstart && vq->handle_kick)
+	if (pollstart && vq->work.fn)
 		vhost_poll_start(&vq->poll, vq->kick);
 
 	mutex_unlock(&vq->mutex);
 
-	if (pollstop && vq->handle_kick)
+	if (pollstop && vq->work.fn)
 		vhost_poll_flush(&vq->poll);
 	return r;
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index afd7729..9c990ea 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -11,9 +11,10 @@
 #include <linux/uio.h>
 #include <linux/virtio_config.h>
 #include <linux/virtio_ring.h>
+#include <linux/srcu.h>
 #include <asm/atomic.h>
 
-struct vhost_device;
+struct vhost_dev;
 
 enum {
 	/* Enough place for all fragments, head, and virtio net header. */
@@ -21,29 +22,33 @@ enum {
 };
 
 struct vhost_work;
-typedef void (*vhost_work_fn_t)(struct vhost_work *work);
+typedef void (*vhost_work_fn_t)(struct vhost_dev *dev);
 
 struct vhost_work {
-	struct list_head	  node;
+	/* Callback function to execute. */
 	vhost_work_fn_t		  fn;
-	wait_queue_head_t	  done;
-	int			  flushing;
-	unsigned		  queue_seq;
-	unsigned		  done_seq;
+	/* Incremented to request callback execution.
+	 * Atomic to allow multiple writers. */
+	atomic_t		  queue_seq;
+	/* Used by worker to track execution requests.
+	 * Used from a single thread so no locking. */
+	int			  done_seq;
 };
 
+void vhost_work_set_fn(struct vhost_work *work, vhost_work_fn_t fn);
+
 /* Poll a file (eventfd or socket) */
 /* Note: there's nothing vhost specific about this structure. */
 struct vhost_poll {
 	poll_table                table;
 	wait_queue_head_t        *wqh;
 	wait_queue_t              wait;
-	struct vhost_work	  work;
+	struct vhost_work	 *work;
 	unsigned long		  mask;
 	struct vhost_dev	 *dev;
 };
 
-void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
+void vhost_poll_init(struct vhost_poll *poll, struct vhost_work* work,
 		     unsigned long mask, struct vhost_dev *dev);
 void vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
@@ -72,11 +77,12 @@ struct vhost_virtqueue {
 	struct eventfd_ctx *error_ctx;
 	struct eventfd_ctx *log_ctx;
 
+	/* The work to execute when the Guest kicks us,
+	 * on Host activity, or timeout. */
+	struct vhost_work work;
+	/* Poll Guest for kicks */
 	struct vhost_poll poll;
 
-	/* The routine to call when the Guest pings us, or timeout. */
-	vhost_work_fn_t handle_kick;
-
 	/* Last available index we saw. */
 	u16 last_avail_idx;
 
@@ -99,12 +105,7 @@ struct vhost_virtqueue {
 	size_t vhost_hlen;
 	size_t sock_hlen;
 	struct vring_used_elem heads[VHOST_NET_MAX_SG];
-	/* We use a kind of RCU to access private pointer.
-	 * All readers access it from worker, which makes it possible to
-	 * flush the vhost_work instead of synchronize_rcu. Therefore readers do
-	 * not need to call rcu_read_lock/rcu_read_unlock: the beginning of
-	 * vhost_work execution acts instead of rcu_read_lock() and the end of
-	 * vhost_work execution acts instead of rcu_read_lock().
+	/* Readers use worker_srcu in device to access private pointer.
 	 * Writers use virtqueue mutex. */
 	void *private_data;
 	/* Log write descriptors */
@@ -112,6 +113,12 @@ struct vhost_virtqueue {
 	struct vhost_log log[VHOST_NET_MAX_SG];
 };
 
+static inline void *vhost_vq_data(struct vhost_virtqueue *vq,
+				  struct vhost_dev *dev)
+{
+	return srcu_dereference(vq->private_data, &dev->worker_srcu);
+}
+
 struct vhost_dev {
 	/* Readers use RCU to access memory table pointer
 	 * log base pointer and features.
@@ -124,12 +131,12 @@ struct vhost_dev {
 	int nvqs;
 	struct file *log_file;
 	struct eventfd_ctx *log_ctx;
-	spinlock_t work_lock;
-	struct list_head work_list;
 	struct task_struct *worker;
+	struct srcu_struct worker_srcu;
 };
 
 long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
+void vhost_dev_free(struct vhost_dev *);
 long vhost_dev_check_owner(struct vhost_dev *);
 long vhost_dev_reset_owner(struct vhost_dev *);
 void vhost_dev_cleanup(struct vhost_dev *);
-- 
1.7.2.rc0.14.g41c1c
