From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH 1/1] NUMA aware scheduling per cpu vhost thread
Date: Thu, 22 Mar 2012 16:48:56 -0700
Message-ID: <1332460136.7730.19.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	tahm@linux.vnet.ibm.com, kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:52852 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242Ab2CVXtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:49:33 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Thu, 22 Mar 2012 17:49:32 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shirley Ma <xma@us.ibm.com>
Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Tested-by: Tom Lendacky <toml@us.ibm.com>
---

 drivers/vhost/net.c                  |   26 ++-
 drivers/vhost/vhost.c                |  300 ++++++++++++++++++++++++----------
 drivers/vhost/vhost.h                |   16 ++-
 3 files changed, 243 insertions(+), 103 deletions(-)
 
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9dab1f5..4664e63 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -41,12 +41,6 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Experimental Zero Copy TX");
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
@@ -510,8 +504,10 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 		return r;
 	}
 
-	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
-	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT,
+			&n->vqs[VHOST_NET_VQ_TX]);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN,
+			&n->vqs[VHOST_NET_VQ_RX]);
 	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
 
 	f->private_data = n;
@@ -863,15 +859,27 @@ static struct miscdevice vhost_net_misc = {
 
 static int vhost_net_init(void)
 {
+	int ret;
+
 	if (experimental_zcopytx)
 		vhost_enable_zcopy(VHOST_NET_VQ_TX);
-	return misc_register(&vhost_net_misc);
+
+	ret = misc_register(&vhost_net_misc);
+	if (ret)
+		return ret;
+
+	ret = vhost_init();
+	if (ret)
+		misc_deregister(&vhost_net_misc);
+
+	return ret;
 }
 module_init(vhost_net_init);
 
 static void vhost_net_exit(void)
 {
 	misc_deregister(&vhost_net_misc);
+	vhost_cleanup();
 }
 module_exit(vhost_net_exit);
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c14c42b..9fabc5a 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -24,7 +24,7 @@
 #include <linux/highmem.h>
 #include <linux/slab.h>
 #include <linux/kthread.h>
-#include <linux/cgroup.h>
+#include <linux/cpu.h>
 
 #include <linux/net.h>
 #include <linux/if_packet.h>
@@ -42,6 +42,15 @@ static unsigned vhost_zcopy_mask __read_mostly;
 #define vhost_used_event(vq) ((u16 __user *)&vq->avail->ring[vq->num])
 #define vhost_avail_event(vq) ((u16 __user *)&vq->used->ring[vq->num])
 
+/* per cpu vhost struct */
+struct vhost {
+	struct task_struct      *worker;
+	spinlock_t              lock;
+	struct list_head        work_list;
+};
+
+static DEFINE_PER_CPU(struct vhost, vhosts);
+
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -64,25 +73,28 @@ static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
 	return 0;
 }
 
-static void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn)
+static void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn,
+			    struct vhost_virtqueue *vq)
 {
 	INIT_LIST_HEAD(&work->node);
 	work->fn = fn;
 	init_waitqueue_head(&work->done);
 	work->flushing = 0;
 	work->queue_seq = work->done_seq = 0;
+	work->vq = vq;
+	spin_lock_init(&work->lock);
 }
 
 /* Init poll structure */
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev)
+		     unsigned long mask, struct vhost_virtqueue *vq)
 {
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
-	poll->dev = dev;
+	poll->dev = vq->dev;
 
-	vhost_work_init(&poll->work, fn);
+	vhost_work_init(&poll->work, fn, vq);
 }
 
 /* Start polling a file. We add ourselves to file's wait queue. The caller must
@@ -108,25 +120,30 @@ static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
 {
 	int left;
 
-	spin_lock_irq(&dev->work_lock);
+	spin_lock_irq(&work->lock);
 	left = seq - work->done_seq;
-	spin_unlock_irq(&dev->work_lock);
+	spin_unlock_irq(&work->lock);
 	return left <= 0;
 }
 
-static void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
+/* only flushing this work? */
+static void vhost_work_flush(struct vhost_poll *poll)
 {
 	unsigned seq;
 	int flushing;
+	struct vhost_dev *dev = poll->dev;
+	struct vhost_work *work = &poll->work;
 
-	spin_lock_irq(&dev->work_lock);
+	if (list_empty(&work->node))
+		return;
+	spin_lock_irq(&work->lock);
 	seq = work->queue_seq;
 	work->flushing++;
-	spin_unlock_irq(&dev->work_lock);
+	spin_unlock_irq(&work->lock);
 	wait_event(work->done, vhost_work_seq_done(dev, work, seq));
-	spin_lock_irq(&dev->work_lock);
+	spin_lock_irq(&work->lock);
 	flushing = --work->flushing;
-	spin_unlock_irq(&dev->work_lock);
+	spin_unlock_irq(&work->lock);
 	BUG_ON(flushing < 0);
 }
 
@@ -134,21 +151,59 @@ static void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
  * locks that are also used by the callback. */
 void vhost_poll_flush(struct vhost_poll *poll)
 {
-	vhost_work_flush(poll->dev, &poll->work);
+	vhost_work_flush(poll);
+}
+
+/* schedule the cpu on the same socket but different cpu with the given one */
+static unsigned long sched_node_cpu(unsigned long cpu)
+{
+	int node, ncpus_node;
+	unsigned long sched_cpu = cpu;
+
+	node = cpu_to_node(cpu);
+	ncpus_node = nr_cpus_node(node);
+	if (ncpus_node != 1) {
+		/* pick up a random cpu on the same node, exclude
+		 * the input one
+		 */
+		sched_cpu = node * ncpus_node + random32() % (ncpus_node - 1);
+		if (sched_cpu >= cpu)
+			++sched_cpu;
+		/* todo hotplug cpu race */
+		if (!cpu_online(sched_cpu))
+			sched_cpu = cpu;
+	}
+	return sched_cpu;
 }
 
 static inline void vhost_work_queue(struct vhost_dev *dev,
 				    struct vhost_work *work)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&dev->work_lock, flags);
+	unsigned long cpu = work->vq->cpu;
+	struct vhost *vhost;
+
+	/* Is it safe to disable vq notify here ? */
+	vhost_disable_notify(dev, work->vq);
+
+	/* schedule the work on the cpu socket as the work has been delivered
+	 * but different with the cpu the work is delivered on
+	 */
+	preempt_disable();
+	if (cpu_to_node(cpu) != cpu_to_node(smp_processor_id())) {
+		cpu = sched_node_cpu(smp_processor_id());
+		work->vq->cpu = cpu;
+	}
+	preempt_enable();
+	vhost = &per_cpu(vhosts, cpu);
+	spin_lock_irq(&vhost->lock);
+	spin_lock(&work->lock);
 	if (list_empty(&work->node)) {
-		list_add_tail(&work->node, &dev->work_list);
+		list_add_tail(&work->node, &vhost->work_list);
 		work->queue_seq++;
-		wake_up_process(dev->worker);
+		wake_up_process(vhost->worker);
 	}
-	spin_unlock_irqrestore(&dev->work_lock, flags);
+	spin_unlock(&work->lock);
+	spin_unlock_irq(&vhost->lock);
 }
 
 void vhost_poll_queue(struct vhost_poll *poll)
@@ -188,17 +243,18 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 
 static int vhost_worker(void *data)
 {
-	struct vhost_dev *dev = data;
-	struct vhost_work *work = NULL;
+	struct vhost *vhost = &__get_cpu_var(vhosts);
+	struct list_head *work_list;
+	struct mm_struct *prev_mm = NULL;
 	unsigned uninitialized_var(seq);
+	struct vhost_work *work = NULL;
 
-	use_mm(dev->mm);
-
+	work_list = &vhost->work_list;
 	for (;;) {
 		/* mb paired w/ kthread_stop */
 		set_current_state(TASK_INTERRUPTIBLE);
 
-		spin_lock_irq(&dev->work_lock);
+		spin_lock_irq(&vhost->lock);
 		if (work) {
 			work->done_seq = seq;
 			if (work->flushing)
@@ -206,18 +262,26 @@ static int vhost_worker(void *data)
 		}
 
 		if (kthread_should_stop()) {
-			spin_unlock_irq(&dev->work_lock);
+			spin_unlock_irq(&vhost->lock);
 			__set_current_state(TASK_RUNNING);
 			break;
 		}
-		if (!list_empty(&dev->work_list)) {
-			work = list_first_entry(&dev->work_list,
+		if (!list_empty(work_list)) {
+			work = list_first_entry(work_list,
 						struct vhost_work, node);
+			spin_lock(&work->lock);
 			list_del_init(&work->node);
+			spin_unlock(&work->lock);
 			seq = work->queue_seq;
+			if (prev_mm != work->vq->dev->mm) {
+				if (prev_mm)
+					unuse_mm(prev_mm);
+				prev_mm = work->vq->dev->mm;
+				use_mm(prev_mm);
+			}
 		} else
 			work = NULL;
-		spin_unlock_irq(&dev->work_lock);
+		spin_unlock_irq(&vhost->lock);
 
 		if (work) {
 			__set_current_state(TASK_RUNNING);
@@ -226,7 +290,9 @@ static int vhost_worker(void *data)
 			schedule();
 
 	}
-	unuse_mm(dev->mm);
+
+	if (prev_mm)
+		unuse_mm(prev_mm);
 	return 0;
 }
 
@@ -298,9 +364,6 @@ long vhost_dev_init(struct vhost_dev *dev,
 	dev->log_file = NULL;
 	dev->memory = NULL;
 	dev->mm = NULL;
-	spin_lock_init(&dev->work_lock);
-	INIT_LIST_HEAD(&dev->work_list);
-	dev->worker = NULL;
 
 	for (i = 0; i < dev->nvqs; ++i) {
 		dev->vqs[i].log = NULL;
@@ -312,7 +375,8 @@ long vhost_dev_init(struct vhost_dev *dev,
 		vhost_vq_reset(dev, dev->vqs + i);
 		if (dev->vqs[i].handle_kick)
 			vhost_poll_init(&dev->vqs[i].poll,
-					dev->vqs[i].handle_kick, POLLIN, dev);
+					dev->vqs[i].handle_kick, POLLIN,
+					&dev->vqs[i]);
 	}
 
 	return 0;
@@ -325,71 +389,35 @@ long vhost_dev_check_owner(struct vhost_dev *dev)
 	return dev->mm == current->mm ? 0 : -EPERM;
 }
 
-struct vhost_attach_cgroups_struct {
-	struct vhost_work work;
-	struct task_struct *owner;
-	int ret;
-};
-
-static void vhost_attach_cgroups_work(struct vhost_work *work)
-{
-	struct vhost_attach_cgroups_struct *s;
-
-	s = container_of(work, struct vhost_attach_cgroups_struct, work);
-	s->ret = cgroup_attach_task_all(s->owner, current);
-}
-
-static int vhost_attach_cgroups(struct vhost_dev *dev)
-{
-	struct vhost_attach_cgroups_struct attach;
-
-	attach.owner = current;
-	vhost_work_init(&attach.work, vhost_attach_cgroups_work);
-	vhost_work_queue(dev, &attach.work);
-	vhost_work_flush(dev, &attach.work);
-	return attach.ret;
-}
-
 /* Caller should have device mutex */
 static long vhost_dev_set_owner(struct vhost_dev *dev)
 {
-	struct task_struct *worker;
 	int err;
+	unsigned long txcpu, rxcpu;
 
 	/* Is there an owner already? */
 	if (dev->mm) {
 		err = -EBUSY;
-		goto err_mm;
+		goto out;
 	}
 
-	/* No owner, become one */
-	dev->mm = get_task_mm(current);
-	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
-	if (IS_ERR(worker)) {
-		err = PTR_ERR(worker);
-		goto err_worker;
-	}
+	err = vhost_dev_alloc_iovecs(dev);
+	if (err)
+		goto out;
 
-	dev->worker = worker;
-	wake_up_process(worker);	/* avoid contributing to loadavg */
+	/* initial txcpu, rxcpu on the same socket */
+	txcpu = sched_node_cpu(smp_processor_id());
+	rxcpu = sched_node_cpu(txcpu);
 
-	err = vhost_attach_cgroups(dev);
-	if (err)
-		goto err_cgroup;
+	dev->vqs[VHOST_NET_VQ_TX].cpu = txcpu;
+	dev->vqs[VHOST_NET_VQ_RX].cpu = rxcpu;
 
-	err = vhost_dev_alloc_iovecs(dev);
-	if (err)
-		goto err_cgroup;
+	/* No owner, become one */
+	dev->mm = get_task_mm(current);
 
 	return 0;
-err_cgroup:
-	kthread_stop(worker);
-	dev->worker = NULL;
-err_worker:
-	if (dev->mm)
-		mmput(dev->mm);
-	dev->mm = NULL;
-err_mm:
+
+out:
 	return err;
 }
 
@@ -474,11 +502,6 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 	kfree(rcu_dereference_protected(dev->memory,
 					lockdep_is_held(&dev->mutex)));
 	RCU_INIT_POINTER(dev->memory, NULL);
-	WARN_ON(!list_empty(&dev->work_list));
-	if (dev->worker) {
-		kthread_stop(dev->worker);
-		dev->worker = NULL;
-	}
 	if (dev->mm)
 		mmput(dev->mm);
 	dev->mm = NULL;
@@ -1605,3 +1628,104 @@ void vhost_zerocopy_callback(void *arg)
 	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
 	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
 }
+
+/* to do
+static int __cpuinit vhost_pool_callback(struct notifier_block *nfb,
+					 unsigned long action,
+					 void *hcpu)
+{
+	struct vhost *vhost = per_cpu(vhosts, hcpu);
+
+	action &= ~CPU_TASKS_FROZEN;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+	case CPU_UP_PREPARE_FROZEN:
+		if (!create_vhost_task(vhosts, hcpu))
+			return notifier_from_errno(-ENOMEM);
+		break;
+	case CPU_UP_CANCELED:
+	case CPU_UP_CANCELED_FROZEN:
+		kthread_bind(vhost->worker, cpumask_any(cpu_online_mask));
+		destory_vhost_task(vhost, hcpu);
+		break;
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+		kthread_bind(vhost->worker, hcpu);
+		wake_up_process(vhost->worker);
+		break;
+	case CPU_DOWN_PREPARE:
+	case CPU_DOWN_PREPARE_FROZEN:
+	case CPU_DOWN_FAILED:
+	case CPU_DOWN_FAILED_FROZEN:
+		break;
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		destrory_vhost_task(vhosts, hcpu);
+		take_over_work(vhosts, hcpu);
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block vhost_pool_callback_nb __cpuinitdata = {
+	.notifier_call = vhost_pool_callcack,
+	.priority = 0,
+}
+*/
+
+static void free_workers(void)
+{
+	unsigned long cpu;
+	struct vhost *vhost;
+
+	/* to do
+	 * unregister_cpu_notifier(&vhost_pool_callback_nb);
+	 */
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		vhost = &per_cpu(vhosts, cpu);
+		if (!IS_ERR(vhost->worker)) {
+			kthread_stop(vhost->worker);
+			BUG_ON(!list_empty(&vhost->work_list));
+		}
+	}
+	put_online_cpus();
+}
+
+int vhost_init(void)
+{
+	int ret = -ENOMEM;
+	unsigned long cpu;
+	struct vhost *vhost;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		vhost = &per_cpu(vhosts, cpu);
+
+		INIT_LIST_HEAD(&vhost->work_list);
+		spin_lock_init(&vhost->lock);
+		vhost->worker = kthread_create_on_node(vhost_worker, NULL,
+						cpu_to_node(cpu),
+						"vhost-%lu", cpu);
+		if (IS_ERR(vhost->worker))
+			goto err;
+
+		kthread_bind(vhost->worker, cpu);
+		wake_up_process(vhost->worker);
+	}
+	put_online_cpus();
+
+	/* to do
+	 * register_cpu_notifier(&vhost_pool_callback_nb);
+	 */
+	return 0;
+err:
+	free_workers();
+	return ret;
+}
+
+void vhost_cleanup(void)
+{
+	free_workers();
+}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index a801e28..c6ecfb0 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -18,6 +18,12 @@
 #define VHOST_DMA_DONE_LEN	1
 #define VHOST_DMA_CLEAR_LEN	0
 
+enum {
+	VHOST_NET_VQ_RX = 0,
+	VHOST_NET_VQ_TX = 1,
+	VHOST_NET_VQ_MAX = 2,
+};
+
 struct vhost_device;
 
 struct vhost_work;
@@ -30,6 +36,8 @@ struct vhost_work {
 	int			  flushing;
 	unsigned		  queue_seq;
 	unsigned		  done_seq;
+	struct vhost_virtqueue	  *vq;
+	spinlock_t                lock;
 };
 
 /* Poll a file (eventfd or socket) */
@@ -44,7 +52,7 @@ struct vhost_poll {
 };
 
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev);
+		     unsigned long mask, struct vhost_virtqueue *vq);
 void vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
 void vhost_poll_flush(struct vhost_poll *poll);
@@ -141,6 +149,7 @@ struct vhost_virtqueue {
 	/* Reference counting for outstanding ubufs.
 	 * Protected by vq mutex. Writers must also take device mutex. */
 	struct vhost_ubuf_ref *ubufs;
+	unsigned long cpu;
 };
 
 struct vhost_dev {
@@ -155,9 +164,6 @@ struct vhost_dev {
 	int nvqs;
 	struct file *log_file;
 	struct eventfd_ctx *log_ctx;
-	spinlock_t work_lock;
-	struct list_head work_list;
-	struct task_struct *worker;
 };
 
 long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
@@ -190,6 +196,8 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
 void vhost_zerocopy_callback(void *arg);
 int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
+int vhost_init(void);
+void vhost_cleanup(void);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
