From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/3] vhost: replace vhost_workqueue with per-vhost kthread
Date: Sun, 30 May 2010 22:24:01 +0200
Message-ID: <4C02C961.9050606@kernel.org>
References: <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100530112925.GB27611@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace vhost_workqueue with per-vhost kthread.  Other than callback
argument change from struct work_struct * to struct vhost_poll *,
there's no visible change to vhost_poll_*() interface.

This conversion is to make each vhost use a dedicated kthread so that
resource control via cgroup can be applied.

Partially based on Sridhar Samudrala's patch.

Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>
---
Okay, here is three patch series to convert vhost to use per-vhost
kthread, add cgroup_attach_task_current_cg() and apply it to the vhost
kthreads.  The conversion is mostly straight forward although flush is
slightly tricky.

The problem is that I have no idea how to test this.  It builds fine
and I read it several times but it's entirely possible / likely that I
missed something.  Please proceed with caution (so, no sign off yet).

Thanks.

 drivers/vhost/net.c   |   58 +++++++++++++----------------
 drivers/vhost/vhost.c |   99 ++++++++++++++++++++++++++++++++++++--------------
 drivers/vhost/vhost.h |   32 +++++++++-------
 3 files changed, 117 insertions(+), 72 deletions(-)

Index: work/drivers/vhost/net.c
===================================================================
--- work.orig/drivers/vhost/net.c
+++ work/drivers/vhost/net.c
@@ -294,54 +294,60 @@ static void handle_rx(struct vhost_net *
 	unuse_mm(net->dev.mm);
 }

-static void handle_tx_kick(struct work_struct *work)
+static void handle_tx_kick(struct vhost_poll *poll)
 {
-	struct vhost_virtqueue *vq;
-	struct vhost_net *net;
-	vq = container_of(work, struct vhost_virtqueue, poll.work);
-	net = container_of(vq->dev, struct vhost_net, dev);
+	struct vhost_virtqueue *vq =
+		container_of(poll, struct vhost_virtqueue, poll);
+	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
+
 	handle_tx(net);
 }

-static void handle_rx_kick(struct work_struct *work)
+static void handle_rx_kick(struct vhost_poll *poll)
 {
-	struct vhost_virtqueue *vq;
-	struct vhost_net *net;
-	vq = container_of(work, struct vhost_virtqueue, poll.work);
-	net = container_of(vq->dev, struct vhost_net, dev);
+	struct vhost_virtqueue *vq =
+		container_of(poll, struct vhost_virtqueue, poll);
+	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
+
 	handle_rx(net);
 }

-static void handle_tx_net(struct work_struct *work)
+static void handle_tx_net(struct vhost_poll *poll)
 {
-	struct vhost_net *net;
-	net = container_of(work, struct vhost_net, poll[VHOST_NET_VQ_TX].work);
+	struct vhost_net *net =
+		container_of(poll, struct vhost_net, poll[VHOST_NET_VQ_TX]);
+
 	handle_tx(net);
 }

-static void handle_rx_net(struct work_struct *work)
+static void handle_rx_net(struct vhost_poll *poll)
 {
-	struct vhost_net *net;
-	net = container_of(work, struct vhost_net, poll[VHOST_NET_VQ_RX].work);
+	struct vhost_net *net =
+		container_of(poll, struct vhost_net, poll[VHOST_NET_VQ_RX]);
+
 	handle_rx(net);
 }

 static int vhost_net_open(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
+	struct vhost_dev *dev;
 	int r;
+
 	if (!n)
 		return -ENOMEM;
+
+	dev = &n->dev;
 	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
 	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
-	r = vhost_dev_init(&n->dev, n->vqs, VHOST_NET_VQ_MAX);
+	r = vhost_dev_init(dev, n->vqs, VHOST_NET_VQ_MAX);
 	if (r < 0) {
 		kfree(n);
 		return r;
 	}

-	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT);
-	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
 	n->tx_poll_state = VHOST_NET_POLL_DISABLED;

 	f->private_data = n;
@@ -644,25 +650,13 @@ static struct miscdevice vhost_net_misc

 static int vhost_net_init(void)
 {
-	int r = vhost_init();
-	if (r)
-		goto err_init;
-	r = misc_register(&vhost_net_misc);
-	if (r)
-		goto err_reg;
-	return 0;
-err_reg:
-	vhost_cleanup();
-err_init:
-	return r;
-
+	return misc_register(&vhost_net_misc);
 }
 module_init(vhost_net_init);

 static void vhost_net_exit(void)
 {
 	misc_deregister(&vhost_net_misc);
-	vhost_cleanup();
 }
 module_exit(vhost_net_exit);

Index: work/drivers/vhost/vhost.c
===================================================================
--- work.orig/drivers/vhost/vhost.c
+++ work/drivers/vhost/vhost.c
@@ -17,12 +17,12 @@
 #include <linux/mm.h>
 #include <linux/miscdevice.h>
 #include <linux/mutex.h>
-#include <linux/workqueue.h>
 #include <linux/rcupdate.h>
 #include <linux/poll.h>
 #include <linux/file.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/kthread.h>

 #include <linux/net.h>
 #include <linux/if_packet.h>
@@ -37,8 +37,6 @@ enum {
 	VHOST_MEMORY_F_LOG = 0x1,
 };

-static struct workqueue_struct *vhost_workqueue;
-
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -52,23 +50,27 @@ static void vhost_poll_func(struct file
 static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
 			     void *key)
 {
-	struct vhost_poll *poll;
-	poll = container_of(wait, struct vhost_poll, wait);
+	struct vhost_poll *poll = container_of(wait, struct vhost_poll, wait);
+
 	if (!((unsigned long)key & poll->mask))
 		return 0;

-	queue_work(vhost_workqueue, &poll->work);
+	vhost_poll_queue(poll);
 	return 0;
 }

 /* Init poll structure */
-void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
-		     unsigned long mask)
+void vhost_poll_init(struct vhost_poll *poll, vhost_poll_fn_t fn,
+		     unsigned long mask, struct vhost_dev *dev)
 {
-	INIT_WORK(&poll->work, func);
+	poll->fn = fn;
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
+	INIT_LIST_HEAD(&poll->node);
+	init_waitqueue_head(&poll->done);
 	poll->mask = mask;
+	poll->dev = dev;
+	poll->queue_seq = poll->done_seq = 0;
 }

 /* Start polling a file. We add ourselves to file's wait queue. The caller must
@@ -88,16 +90,28 @@ void vhost_poll_stop(struct vhost_poll *
 	remove_wait_queue(poll->wqh, &poll->wait);
 }

-/* Flush any work that has been scheduled. When calling this, don't hold any
+/* Flush any poll that has been scheduled. When calling this, don't hold any
  * locks that are also used by the callback. */
 void vhost_poll_flush(struct vhost_poll *poll)
 {
-	flush_work(&poll->work);
+	int seq = poll->queue_seq;
+
+	if (seq - poll->done_seq > 0)
+		wait_event(poll->done, seq - poll->done_seq <= 0);
+	smp_rmb();	/* paired with wmb in vhost_poller() */
 }

 void vhost_poll_queue(struct vhost_poll *poll)
 {
-	queue_work(vhost_workqueue, &poll->work);
+	struct vhost_dev *dev = poll->dev;
+
+	spin_lock(&dev->poller_lock);
+	if (list_empty(&poll->node)) {
+		list_add_tail(&poll->node, &dev->poll_list);
+		poll->queue_seq++;
+		wake_up_process(dev->poller);
+	}
+	spin_unlock(&dev->poller_lock);
 }

 static void vhost_vq_reset(struct vhost_dev *dev,
@@ -125,10 +139,50 @@ static void vhost_vq_reset(struct vhost_
 	vq->log_ctx = NULL;
 }

+static int vhost_poller(void *data)
+{
+	struct vhost_dev *dev = data;
+	struct vhost_poll *poll;
+
+repeat:
+	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
+
+	if (kthread_should_stop()) {
+		__set_current_state(TASK_RUNNING);
+		return 0;
+	}
+
+	poll = NULL;
+	spin_lock(&dev->poller_lock);
+	if (!list_empty(&dev->poll_list)) {
+		poll = list_first_entry(&dev->poll_list,
+					struct vhost_poll, node);
+		list_del_init(&poll->node);
+	}
+	spin_unlock(&dev->poller_lock);
+
+	if (poll) {
+		__set_current_state(TASK_RUNNING);
+		poll->fn(poll);
+		smp_wmb();	/* paired with rmb in vhost_poll_flush() */
+		poll->done_seq = poll->queue_seq;
+		wake_up_all(&poll->done);
+	} else
+		schedule();
+
+	goto repeat;
+}
+
 long vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue *vqs, int nvqs)
 {
+	struct task_struct *poller;
 	int i;
+
+	poller = kthread_create(vhost_poller, dev, "vhost-%d", current->pid);
+	if (IS_ERR(poller))
+		return PTR_ERR(poller);
+
 	dev->vqs = vqs;
 	dev->nvqs = nvqs;
 	mutex_init(&dev->mutex);
@@ -136,6 +190,9 @@ long vhost_dev_init(struct vhost_dev *de
 	dev->log_file = NULL;
 	dev->memory = NULL;
 	dev->mm = NULL;
+	spin_lock_init(&dev->poller_lock);
+	INIT_LIST_HEAD(&dev->poll_list);
+	dev->poller = poller;

 	for (i = 0; i < dev->nvqs; ++i) {
 		dev->vqs[i].dev = dev;
@@ -143,8 +200,7 @@ long vhost_dev_init(struct vhost_dev *de
 		vhost_vq_reset(dev, dev->vqs + i);
 		if (dev->vqs[i].handle_kick)
 			vhost_poll_init(&dev->vqs[i].poll,
-					dev->vqs[i].handle_kick,
-					POLLIN);
+					dev->vqs[i].handle_kick, POLLIN, dev);
 	}
 	return 0;
 }
@@ -217,6 +273,8 @@ void vhost_dev_cleanup(struct vhost_dev
 	if (dev->mm)
 		mmput(dev->mm);
 	dev->mm = NULL;
+
+	kthread_stop(dev->poller);
 }

 static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
@@ -1113,16 +1171,3 @@ void vhost_disable_notify(struct vhost_v
 		vq_err(vq, "Failed to enable notification at %p: %d\n",
 		       &vq->used->flags, r);
 }
-
-int vhost_init(void)
-{
-	vhost_workqueue = create_singlethread_workqueue("vhost");
-	if (!vhost_workqueue)
-		return -ENOMEM;
-	return 0;
-}
-
-void vhost_cleanup(void)
-{
-	destroy_workqueue(vhost_workqueue);
-}
Index: work/drivers/vhost/vhost.h
===================================================================
--- work.orig/drivers/vhost/vhost.h
+++ work/drivers/vhost/vhost.h
@@ -5,7 +5,6 @@
 #include <linux/vhost.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
-#include <linux/workqueue.h>
 #include <linux/poll.h>
 #include <linux/file.h>
 #include <linux/skbuff.h>
@@ -20,19 +19,26 @@ enum {
 	VHOST_NET_MAX_SG = MAX_SKB_FRAGS + 2,
 };

+struct vhost_poll;
+typedef void (*vhost_poll_fn_t)(struct vhost_poll *poll);
+
 /* Poll a file (eventfd or socket) */
 /* Note: there's nothing vhost specific about this structure. */
 struct vhost_poll {
+	vhost_poll_fn_t		  fn;
 	poll_table                table;
 	wait_queue_head_t        *wqh;
 	wait_queue_t              wait;
-	/* struct which will handle all actual work. */
-	struct work_struct        work;
+	struct list_head	  node;
+	wait_queue_head_t	  done;
 	unsigned long		  mask;
+	struct vhost_dev	 *dev;
+	int			  queue_seq;
+	int			  done_seq;
 };

-void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
-		     unsigned long mask);
+void vhost_poll_init(struct vhost_poll *poll, vhost_poll_fn_t fn,
+		     unsigned long mask, struct vhost_dev *dev);
 void vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
 void vhost_poll_flush(struct vhost_poll *poll);
@@ -63,7 +69,7 @@ struct vhost_virtqueue {
 	struct vhost_poll poll;

 	/* The routine to call when the Guest pings us, or timeout. */
-	work_func_t handle_kick;
+	vhost_poll_fn_t handle_kick;

 	/* Last available index we saw. */
 	u16 last_avail_idx;
@@ -86,11 +92,11 @@ struct vhost_virtqueue {
 	struct iovec hdr[VHOST_NET_MAX_SG];
 	size_t hdr_size;
 	/* We use a kind of RCU to access private pointer.
-	 * All readers access it from workqueue, which makes it possible to
-	 * flush the workqueue instead of synchronize_rcu. Therefore readers do
+	 * All readers access it from poller, which makes it possible to
+	 * flush the vhost_poll instead of synchronize_rcu. Therefore readers do
 	 * not need to call rcu_read_lock/rcu_read_unlock: the beginning of
-	 * work item execution acts instead of rcu_read_lock() and the end of
-	 * work item execution acts instead of rcu_read_lock().
+	 * vhost_poll execution acts instead of rcu_read_lock() and the end of
+	 * vhost_poll execution acts instead of rcu_read_lock().
 	 * Writers use virtqueue mutex. */
 	void *private_data;
 	/* Log write descriptors */
@@ -110,6 +116,9 @@ struct vhost_dev {
 	int nvqs;
 	struct file *log_file;
 	struct eventfd_ctx *log_ctx;
+	spinlock_t poller_lock;
+	struct list_head poll_list;
+	struct task_struct *poller;
 };

 long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
@@ -136,9 +145,6 @@ bool vhost_enable_notify(struct vhost_vi
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);

-int vhost_init(void);
-void vhost_cleanup(void);
-
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
 		if ((vq)->error_ctx)                               \
