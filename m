From: Liu Ping Fan <kernelfans@gmail.com>
Subject: [PATCH 1/2] [kvm/vhost]: make vhost support NUMA model.
Date: Thu, 17 May 2012 17:20:53 +0800
Message-ID: <1337246456-30909-2-git-send-email-kernelfans@gmail.com>
References: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org,
	Avi Kivity <avi@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ryan Harper <ryanh@us.ibm.com>, Shirley Ma <xma@us.ibm.com>,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>
To: kvm@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liu Ping Fan <pingfank@linux.vnet.ibm.com>

Make vhost allocate vhost_virtqueue on different host nodes as required.

Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
---
 drivers/vhost/vhost.c |  380 +++++++++++++++++++++++++++++++++++--------------
 drivers/vhost/vhost.h |   41 ++++--
 include/linux/vhost.h |    2 +-
 3 files changed, 304 insertions(+), 119 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 51e4c1e..b0d2855 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -23,6 +23,7 @@
 #include <linux/file.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/sched.h>
 #include <linux/kthread.h>
 #include <linux/cgroup.h>
 
@@ -37,12 +38,11 @@ enum {
 	VHOST_MEMORY_F_LOG = 0x1,
 };
 
-static unsigned vhost_zcopy_mask __read_mostly;
 
 #define vhost_used_event(vq) ((u16 __user *)&vq->avail->ring[vq->num])
 #define vhost_avail_event(vq) ((u16 __user *)&vq->used->ring[vq->num])
 
-static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
+void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
 	struct vhost_poll *poll;
@@ -75,12 +75,12 @@ static void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn)
 
 /* Init poll structure */
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev)
+		     unsigned long mask, struct vhost_sub_dev *dev)
 {
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
-	poll->dev = dev;
+	poll->subdev = dev;
 
 	vhost_work_init(&poll->work, fn);
 }
@@ -103,7 +103,7 @@ void vhost_poll_stop(struct vhost_poll *poll)
 	remove_wait_queue(poll->wqh, &poll->wait);
 }
 
-static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
+static bool vhost_work_seq_done(struct vhost_sub_dev *dev, struct vhost_work *work,
 				unsigned seq)
 {
 	int left;
@@ -114,19 +114,19 @@ static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
 	return left <= 0;
 }
 
-static void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
+static void vhost_work_flush(struct vhost_sub_dev *sub, struct vhost_work *work)
 {
 	unsigned seq;
 	int flushing;
 
-	spin_lock_irq(&dev->work_lock);
+	spin_lock_irq(&sub->work_lock);
 	seq = work->queue_seq;
 	work->flushing++;
-	spin_unlock_irq(&dev->work_lock);
-	wait_event(work->done, vhost_work_seq_done(dev, work, seq));
-	spin_lock_irq(&dev->work_lock);
+	spin_unlock_irq(&sub->work_lock);
+	wait_event(work->done, vhost_work_seq_done(sub, work, seq));
+	spin_lock_irq(&sub->work_lock);
 	flushing = --work->flushing;
-	spin_unlock_irq(&dev->work_lock);
+	spin_unlock_irq(&sub->work_lock);
 	BUG_ON(flushing < 0);
 }
 
@@ -134,26 +134,26 @@ static void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
  * locks that are also used by the callback. */
 void vhost_poll_flush(struct vhost_poll *poll)
 {
-	vhost_work_flush(poll->dev, &poll->work);
+	vhost_work_flush(poll->subdev, &poll->work);
 }
 
-static inline void vhost_work_queue(struct vhost_dev *dev,
+static inline void vhost_work_queue(struct vhost_sub_dev *sub,
 				    struct vhost_work *work)
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(&dev->work_lock, flags);
+	spin_lock_irqsave(&sub->work_lock, flags);
 	if (list_empty(&work->node)) {
-		list_add_tail(&work->node, &dev->work_list);
+		list_add_tail(&work->node, &sub->work_list);
 		work->queue_seq++;
-		wake_up_process(dev->worker);
+		wake_up_process(sub->worker);
 	}
-	spin_unlock_irqrestore(&dev->work_lock, flags);
+	spin_unlock_irqrestore(&sub->work_lock, flags);
 }
 
 void vhost_poll_queue(struct vhost_poll *poll)
 {
-	vhost_work_queue(poll->dev, &poll->work);
+	vhost_work_queue(poll->subdev, &poll->work);
 }
 
 static void vhost_vq_reset(struct vhost_dev *dev,
@@ -188,7 +188,8 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 
 static int vhost_worker(void *data)
 {
-	struct vhost_dev *dev = data;
+	struct vhost_sub_dev *sub = data;
+	struct vhost_dev *dev = sub->owner;
 	struct vhost_work *work = NULL;
 	unsigned uninitialized_var(seq);
 
@@ -198,7 +199,7 @@ static int vhost_worker(void *data)
 		/* mb paired w/ kthread_stop */
 		set_current_state(TASK_INTERRUPTIBLE);
 
-		spin_lock_irq(&dev->work_lock);
+		spin_lock_irq(&sub->work_lock);
 		if (work) {
 			work->done_seq = seq;
 			if (work->flushing)
@@ -206,18 +207,18 @@ static int vhost_worker(void *data)
 		}
 
 		if (kthread_should_stop()) {
-			spin_unlock_irq(&dev->work_lock);
+			spin_unlock_irq(&sub->work_lock);
 			__set_current_state(TASK_RUNNING);
 			break;
 		}
-		if (!list_empty(&dev->work_list)) {
-			work = list_first_entry(&dev->work_list,
+		if (!list_empty(&sub->work_list)) {
+			work = list_first_entry(&sub->work_list,
 						struct vhost_work, node);
 			list_del_init(&work->node);
 			seq = work->queue_seq;
 		} else
 			work = NULL;
-		spin_unlock_irq(&dev->work_lock);
+		spin_unlock_irq(&sub->work_lock);
 
 		if (work) {
 			__set_current_state(TASK_RUNNING);
@@ -244,54 +245,189 @@ static void vhost_vq_free_iovecs(struct vhost_virtqueue *vq)
 	vq->ubuf_info = NULL;
 }
 
-void vhost_enable_zcopy(int vq)
+void vhost_enable_zcopy(struct vhost_dev *dev, int rx)
 {
-	vhost_zcopy_mask |= 0x1 << vq;
+	int i;
+	if (rx == 0)
+		for (i = 0; i < dev->node_cnt; i++)
+			dev->zcopy_mask |= 0x1<<(2*i+1);
 }
 
-/* Helper to allocate iovec buffers for all vqs. */
-static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
+/* Need for vq dynamicly allocator, which is important to migrate among NUMA */
+static int vhost_vq_alloc_iovecs(struct vhost_virtqueue *vq)
 {
-	int i;
 	bool zcopy;
+	int i;
+	struct vhost_dev *dev = vq->dev;
+	int node = vq->node_id;
+	vq->indirect = kmalloc_node(sizeof *vq->indirect  *
+					   UIO_MAXIOV, GFP_KERNEL, node);
+	vq->log = kmalloc_node(sizeof *vq->log * UIO_MAXIOV,
+				  GFP_KERNEL, node);
+	vq->heads = kmalloc_node(sizeof *vq->heads *
+					UIO_MAXIOV, GFP_KERNEL, node);
+	for (i = 0; i < dev->node_cnt*2; i++) {
+		if (dev->vqs[i] == vq) {
+			zcopy = dev->zcopy_mask & (0x1 << i);
+			break;
+		}
+	}
+	if (zcopy)
+		vq->ubuf_info =
+			kmalloc_node(sizeof *vq->ubuf_info *
+				UIO_MAXIOV, GFP_KERNEL, node);
+	if (!vq->indirect || !vq->log || !vq->heads ||
+		(zcopy && !vq->ubuf_info)) {
+		kfree(vq->indirect);
+		kfree(vq->log);
+		kfree(vq->heads);
+		kfree(vq->ubuf_info);
 
-	for (i = 0; i < dev->nvqs; ++i) {
-		dev->vqs[i].indirect = kmalloc(sizeof *dev->vqs[i].indirect *
-					       UIO_MAXIOV, GFP_KERNEL);
-		dev->vqs[i].log = kmalloc(sizeof *dev->vqs[i].log * UIO_MAXIOV,
-					  GFP_KERNEL);
-		dev->vqs[i].heads = kmalloc(sizeof *dev->vqs[i].heads *
-					    UIO_MAXIOV, GFP_KERNEL);
-		zcopy = vhost_zcopy_mask & (0x1 << i);
-		if (zcopy)
-			dev->vqs[i].ubuf_info =
-				kmalloc(sizeof *dev->vqs[i].ubuf_info *
-					UIO_MAXIOV, GFP_KERNEL);
-		if (!dev->vqs[i].indirect || !dev->vqs[i].log ||
-			!dev->vqs[i].heads ||
-			(zcopy && !dev->vqs[i].ubuf_info))
+		return -ENOMEM;
+	} else
+		return 0;
+}
+
+/* Helper to allocate iovec buffers for all vqs. */
+static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
+{
+	int i, ret;
+	for (i = 0; i < dev->nvqs; i++) {
+		ret = vhost_vq_alloc_iovecs(dev->vqs[i]);
+		if (ret < 0) {
+			i -= 1;
 			goto err_nomem;
+		}
 	}
 	return 0;
-
 err_nomem:
 	for (; i >= 0; --i)
-		vhost_vq_free_iovecs(&dev->vqs[i]);
+		vhost_vq_free_iovecs(dev->vqs[i]);
 	return -ENOMEM;
 }
 
 static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 {
 	int i;
-
 	for (i = 0; i < dev->nvqs; ++i)
-		vhost_vq_free_iovecs(&dev->vqs[i]);
+		vhost_vq_free_iovecs(dev->vqs[i]);
 }
 
-long vhost_dev_init(struct vhost_dev *dev,
-		    struct vhost_virtqueue *vqs, int nvqs)
+int vhost_dev_alloc_subdevs(struct vhost_dev *dev, unsigned long *numa_map,
+	int sz)
+{
+	int i, j = 0;
+	int cur, prev = 0;
+	struct vhost_sub_dev *sub;
+	/* Todo,replace allow_map with dynamic allocated */
+	dev->allow_map = *numa_map;
+	dev->sub_devs = kmalloc(dev->node_cnt*sizeof(void *), GFP_KERNEL);
+
+	while (1) {
+		cur = find_next_bit(numa_map, sz, prev);
+		if (cur >= sz)
+			break;
+		prev = cur;
+		sub =  kmalloc_node(sizeof(struct vhost_sub_dev), GFP_KERNEL, cur);
+		if (sub == NULL)
+			goto err;
+		j++;
+		sub->node_id = cur;
+		sub->owner = dev;
+		spin_lock_init(&sub->work_lock);
+		INIT_LIST_HEAD(&sub->work_list);
+		dev->sub_devs[i] = sub;
+	}
+
+	dev->node_cnt = j;
+	return 0;
+err:
+	for (i = 0; i < j; i++) {
+		kfree(dev->sub_devs[i]);
+		dev->sub_devs[i] = NULL;
+	}
+	return -ENOMEM;
+
+}
+
+void vhost_dev_free_subdevs(struct vhost_dev *dev)
 {
 	int i;
+	for (i = 0; i < dev->node_cnt; i++)
+		kfree(dev->sub_devs[i]);
+	return;
+}
+
+static int check_numa(int *vqs_map, int sz)
+{
+	int i, node;
+
+	for (i = 0; i < sz; i++) {
+		for_each_online_node(node)
+			if (vqs_map[i] == node)
+				break;
+		if (vqs_map[i] != node)
+			return -1;
+	}
+	return 0;
+}
+
+int check_numa_bmp(unsigned long *numa_bmp, int sz)
+{
+	int i, node, cur, prev = 0;
+
+	for (i = 0; i < sz; i++) {
+		cur = find_next_bit(numa_bmp, sz, prev);
+		prev = cur;
+		if (cur >= sz)
+			return 0;
+		for_each_online_node(node)
+			if (cur == node)
+				break;
+		if (cur != node)
+			return -1;
+	}
+	return 0;
+}
+
+/* allocate vqs in node according to request map */
+int vhost_dev_alloc_vqs(struct vhost_dev *dev, struct vhost_virtqueue **vqs, int cnt,
+	int *vqs_map, int sz, vhost_work_fn_t *handle_kick)
+{
+	int r, i, j = 0;
+	r = check_numa(vqs_map, sz);
+	if (r < 0)
+		return -EINVAL;
+	for (i = 0; i < cnt ; i++) {
+		vqs[i] = kmalloc_node(sizeof(struct vhost_virtqueue),
+			GFP_KERNEL, vqs_map[i]);
+		if (vqs[i] == NULL)
+			goto err;
+		vqs[i]->handle_kick = handle_kick[i];
+		j = i;
+	}
+	return 0;
+err:
+	for (i = 0; i < j; i++)
+		kfree(vqs[i]);
+	return -ENOMEM;
+
+}
+
+void vhost_dev_free_vqs(struct vhost_dev *dev, struct vhost_virtqueue **vqs,
+	int cnt)
+{
+	int i;
+	for (i = 0; i < cnt ; i++)
+		kfree(vqs[i]);
+	return;
+}
+
+long vhost_dev_init(struct vhost_dev *dev, struct vhost_virtqueue **vqs, int nvqs)
+{
+	int i, j, ret = 0;
+	struct vhost_sub_dev *subdev;
+	struct vhost_virtqueue *vq;
 
 	dev->vqs = vqs;
 	dev->nvqs = nvqs;
@@ -300,24 +436,32 @@ long vhost_dev_init(struct vhost_dev *dev,
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
-		vhost_vq_reset(dev, dev->vqs + i);
-		if (dev->vqs[i].handle_kick)
-			vhost_poll_init(&dev->vqs[i].poll,
-					dev->vqs[i].handle_kick, POLLIN, dev);
-	}
+		vq = dev->vqs[i];
+		/* for each numa node, in-vq/out-vq */
+		vq->log = NULL;
+		vq->indirect = NULL;
+		vq->heads = NULL;
+		vq->ubuf_info = NULL;
+		vq->dev = dev;
+		mutex_init(&vq->mutex);
+		vhost_vq_reset(dev, vq);
+
+		if (vq->handle_kick) {
+			for (j = 0; j < i; j++) {
+				subdev =  dev->sub_devs[j];
+				if (vq->node_id == subdev->node_id)
+					vhost_poll_init(&vq->poll, vq->handle_kick, POLLIN, subdev);
+				else {
+					vhost_poll_init(&vq->poll, vq->handle_kick, POLLIN, dev->sub_devs[0]);
+					ret = 1;
+				}
+			}
+		}
 
-	return 0;
+	}
+	return ret;
 }
 
 /* Caller should have device mutex */
@@ -344,19 +488,26 @@ static void vhost_attach_cgroups_work(struct vhost_work *work)
 static int vhost_attach_cgroups(struct vhost_dev *dev)
 {
 	struct vhost_attach_cgroups_struct attach;
-
+	int i, ret = 0;
+	struct vhost_sub_dev *sub;
 	attach.owner = current;
-	vhost_work_init(&attach.work, vhost_attach_cgroups_work);
-	vhost_work_queue(dev, &attach.work);
-	vhost_work_flush(dev, &attach.work);
-	return attach.ret;
+	for (i = 0; i < dev->node_cnt; i++) {
+		sub = dev->sub_devs[i];
+		vhost_work_init(&attach.work, vhost_attach_cgroups_work);
+		vhost_work_queue(sub, &attach.work);
+		vhost_work_flush(sub, &attach.work);
+		ret |= attach.ret;
+	}
+	return ret;
 }
 
 /* Caller should have device mutex */
 static long vhost_dev_set_owner(struct vhost_dev *dev)
 {
 	struct task_struct *worker;
-	int err;
+	int err, i, j, cur, prev = 0;
+	int sz = sizeof(unsigned long);
+	const struct cpumask *mask;
 
 	/* Is there an owner already? */
 	if (dev->mm) {
@@ -366,14 +517,19 @@ static long vhost_dev_set_owner(struct vhost_dev *dev)
 
 	/* No owner, become one */
 	dev->mm = get_task_mm(current);
-	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
-	if (IS_ERR(worker)) {
-		err = PTR_ERR(worker);
-		goto err_worker;
+
+	for (i = 0, j = 0; i < dev->node_cnt; i++, j++) {
+		cur = find_next_bit(&dev->allow_map, sz, prev);
+		dev->sub_devs[i]->worker = kthread_create_on_node(vhost_worker,
+			dev->sub_devs[i], cur, "vhost-%d-node-%d", current->pid, cur);
+		if (dev->sub_devs[i]->worker == NULL)
+			goto err_cgroup;
+		mask = cpumask_of_node(cur);
+		do_set_cpus_allowed(worker, mask);
 	}
 
-	dev->worker = worker;
-	wake_up_process(worker);	/* avoid contributing to loadavg */
+	for (i = 0; i < dev->node_cnt; i++)
+		wake_up_process(dev->sub_devs[i]->worker);
 
 	err = vhost_attach_cgroups(dev);
 	if (err)
@@ -385,9 +541,12 @@ static long vhost_dev_set_owner(struct vhost_dev *dev)
 
 	return 0;
 err_cgroup:
-	kthread_stop(worker);
-	dev->worker = NULL;
-err_worker:
+
+	for (i = 0; i < j; i++) {
+		kthread_stop(dev->sub_devs[i]->worker);
+		dev->sub_devs[i]->worker = NULL;
+	}
+
 	if (dev->mm)
 		mmput(dev->mm);
 	dev->mm = NULL;
@@ -442,28 +601,28 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 	int i;
 
 	for (i = 0; i < dev->nvqs; ++i) {
-		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
-			vhost_poll_stop(&dev->vqs[i].poll);
-			vhost_poll_flush(&dev->vqs[i].poll);
+		if (dev->vqs[i]->kick && dev->vqs[i]->handle_kick) {
+			vhost_poll_stop(&dev->vqs[i]->poll);
+			vhost_poll_flush(&dev->vqs[i]->poll);
 		}
 		/* Wait for all lower device DMAs done. */
-		if (dev->vqs[i].ubufs)
-			vhost_ubuf_put_and_wait(dev->vqs[i].ubufs);
+		if (dev->vqs[i]->ubufs)
+			vhost_ubuf_put_and_wait(dev->vqs[i]->ubufs);
 
 		/* Signal guest as appropriate. */
-		vhost_zerocopy_signal_used(&dev->vqs[i]);
-
-		if (dev->vqs[i].error_ctx)
-			eventfd_ctx_put(dev->vqs[i].error_ctx);
-		if (dev->vqs[i].error)
-			fput(dev->vqs[i].error);
-		if (dev->vqs[i].kick)
-			fput(dev->vqs[i].kick);
-		if (dev->vqs[i].call_ctx)
-			eventfd_ctx_put(dev->vqs[i].call_ctx);
-		if (dev->vqs[i].call)
-			fput(dev->vqs[i].call);
-		vhost_vq_reset(dev, dev->vqs + i);
+		vhost_zerocopy_signal_used(dev->vqs[i]);
+
+		if (dev->vqs[i]->error_ctx)
+			eventfd_ctx_put(dev->vqs[i]->error_ctx);
+		if (dev->vqs[i]->error)
+			fput(dev->vqs[i]->error);
+		if (dev->vqs[i]->kick)
+			fput(dev->vqs[i]->kick);
+		if (dev->vqs[i]->call_ctx)
+			eventfd_ctx_put(dev->vqs[i]->call_ctx);
+		if (dev->vqs[i]->call)
+			fput(dev->vqs[i]->call);
+		vhost_vq_reset(dev, dev->vqs[i]);
 	}
 	vhost_dev_free_iovecs(dev);
 	if (dev->log_ctx)
@@ -477,11 +636,15 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 					locked ==
 						lockdep_is_held(&dev->mutex)));
 	RCU_INIT_POINTER(dev->memory, NULL);
+
+	/* fixme,It will be considered and fixed in next verion */
 	WARN_ON(!list_empty(&dev->work_list));
 	if (dev->worker) {
 		kthread_stop(dev->worker);
 		dev->worker = NULL;
 	}
+	/* end*/
+
 	if (dev->mm)
 		mmput(dev->mm);
 	dev->mm = NULL;
@@ -534,14 +697,14 @@ static int memory_access_ok(struct vhost_dev *d, struct vhost_memory *mem,
 
 	for (i = 0; i < d->nvqs; ++i) {
 		int ok;
-		mutex_lock(&d->vqs[i].mutex);
+		mutex_lock(&d->vqs[i]->mutex);
 		/* If ring is inactive, will check when it's enabled. */
-		if (d->vqs[i].private_data)
-			ok = vq_memory_access_ok(d->vqs[i].log_base, mem,
+		if (d->vqs[i]->private_data)
+			ok = vq_memory_access_ok(d->vqs[i]->log_base, mem,
 						 log_all);
 		else
 			ok = 1;
-		mutex_unlock(&d->vqs[i].mutex);
+		mutex_unlock(&d->vqs[i]->mutex);
 		if (!ok)
 			return 0;
 	}
@@ -650,8 +813,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		return r;
 	if (idx >= d->nvqs)
 		return -ENOBUFS;
-
-	vq = d->vqs + idx;
+	vq = d->vqs[idx];
 
 	mutex_lock(&vq->mutex);
 
@@ -750,6 +912,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		vq->log_addr = a.log_guest_addr;
 		vq->used = (void __user *)(unsigned long)a.used_user_addr;
 		break;
+
 	case VHOST_SET_VRING_KICK:
 		if (copy_from_user(&f, argp, sizeof f)) {
 			r = -EFAULT;
@@ -766,6 +929,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		} else
 			filep = eventfp;
 		break;
+
 	case VHOST_SET_VRING_CALL:
 		if (copy_from_user(&f, argp, sizeof f)) {
 			r = -EFAULT;
@@ -863,7 +1027,7 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned long arg)
 		for (i = 0; i < d->nvqs; ++i) {
 			struct vhost_virtqueue *vq;
 			void __user *base = (void __user *)(unsigned long)p;
-			vq = d->vqs + i;
+			vq = d->vqs[i];
 			mutex_lock(&vq->mutex);
 			/* If ring is inactive, will check when it's enabled. */
 			if (vq->private_data && !vq_log_access_ok(d, vq, base))
@@ -890,9 +1054,9 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned long arg)
 		} else
 			filep = eventfp;
 		for (i = 0; i < d->nvqs; ++i) {
-			mutex_lock(&d->vqs[i].mutex);
-			d->vqs[i].log_ctx = d->log_ctx;
-			mutex_unlock(&d->vqs[i].mutex);
+			mutex_lock(&d->vqs[i]->mutex);
+			d->vqs[i]->log_ctx = d->log_ctx;
+			mutex_unlock(&d->vqs[i]->mutex);
 		}
 		if (ctx)
 			eventfd_ctx_put(ctx);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 8de1fd5..12d4237 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -13,12 +13,13 @@
 #include <linux/virtio_ring.h>
 #include <linux/atomic.h>
 
+#define VHOST_NUMA
 /* This is for zerocopy, used buffer len is set to 1 when lower device DMA
  * done */
 #define VHOST_DMA_DONE_LEN	1
 #define VHOST_DMA_CLEAR_LEN	0
 
-struct vhost_device;
+struct vhost_dev;
 
 struct vhost_work;
 typedef void (*vhost_work_fn_t)(struct vhost_work *work);
@@ -32,6 +33,8 @@ struct vhost_work {
 	unsigned		  done_seq;
 };
 
+struct vhost_sub_dev;
+
 /* Poll a file (eventfd or socket) */
 /* Note: there's nothing vhost specific about this structure. */
 struct vhost_poll {
@@ -40,11 +43,13 @@ struct vhost_poll {
 	wait_queue_t              wait;
 	struct vhost_work	  work;
 	unsigned long		  mask;
-	struct vhost_dev	 *dev;
+	struct vhost_sub_dev *subdev;
 };
 
+void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
+			    poll_table *pt);
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev);
+		     unsigned long mask, struct vhost_sub_dev *dev);
 void vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
 void vhost_poll_flush(struct vhost_poll *poll);
@@ -70,7 +75,7 @@ void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *);
 /* The virtqueue structure describes a queue attached to a device. */
 struct vhost_virtqueue {
 	struct vhost_dev *dev;
-
+	int node_id;
 	/* The actual ring of buffers. */
 	struct mutex mutex;
 	unsigned int num;
@@ -143,6 +148,14 @@ struct vhost_virtqueue {
 	struct vhost_ubuf_ref *ubufs;
 };
 
+struct vhost_sub_dev {
+	struct vhost_dev *owner;
+	int node_id;
+	spinlock_t work_lock;
+	struct list_head work_list;
+	struct task_struct *worker;
+};
+
 struct vhost_dev {
 	/* Readers use RCU to access memory table pointer
 	 * log base pointer and features.
@@ -151,16 +164,24 @@ struct vhost_dev {
 	struct mm_struct *mm;
 	struct mutex mutex;
 	unsigned acked_features;
-	struct vhost_virtqueue *vqs;
+	struct vhost_virtqueue **vqs;
 	int nvqs;
 	struct file *log_file;
 	struct eventfd_ctx *log_ctx;
-	spinlock_t work_lock;
-	struct list_head work_list;
-	struct task_struct *worker;
+	/* todo, change it to bitmap */
+	unsigned long allow_map;
+	unsigned long node_cnt;
+	unsigned long zcopy_mask;
+	struct vhost_sub_dev **sub_devs;
 };
 
-long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
+int check_numa_bmp(unsigned long *numa_bmp, int sz);
+int vhost_dev_alloc_subdevs(struct vhost_dev *dev, unsigned long *numa_map,
+	int sz);
+void vhost_dev_free_subdevs(struct vhost_dev *dev);
+int vhost_dev_alloc_vqs(struct vhost_dev *dev, struct vhost_virtqueue **vqs,
+	int cnt, int *vqs_map, int sz, vhost_work_fn_t *handle_kick);
+long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
 long vhost_dev_check_owner(struct vhost_dev *);
 long vhost_dev_reset_owner(struct vhost_dev *);
 void vhost_dev_cleanup(struct vhost_dev *, bool locked);
@@ -216,6 +237,6 @@ static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
 	return acked_features & (1 << bit);
 }
 
-void vhost_enable_zcopy(int vq);
+void vhost_enable_zcopy(struct vhost_dev *dev, int rx);
 
 #endif
diff --git a/include/linux/vhost.h b/include/linux/vhost.h
index e847f1e..d8c76f1 100644
--- a/include/linux/vhost.h
+++ b/include/linux/vhost.h
@@ -120,7 +120,7 @@ struct vhost_memory {
  * used for transmit.  Pass fd -1 to unbind from the socket and the transmit
  * device.  This can be used to stop the ring (e.g. for migration). */
 #define VHOST_NET_SET_BACKEND _IOW(VHOST_VIRTIO, 0x30, struct vhost_vring_file)
-
+#define VHOST_NET_SET_NUMA  _IOW(VHOST_VIRTIO, 0x31, unsigned long)
 /* Feature bits */
 /* Log all write descriptors. Can be changed while device is active. */
 #define VHOST_F_LOG_ALL 26
-- 
1.7.4.4
