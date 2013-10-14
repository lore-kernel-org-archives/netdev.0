From: Bandan Das <bsd@redhat.com>
Subject: [RFC PATCH v2 1/1] Workqueue based vhost workers
Date: Sun, 13 Oct 2013 21:55:43 -0400
Message-ID: <1381715743-13672-2-git-send-email-bsd@redhat.com>
References: <1381715743-13672-1-git-send-email-bsd@redhat.com>
Cc: netdev@vger.kernel.org, Michael Tsirkin <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, Bandan Das <bsd@makefile.in>
To: kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535Ab3JNB6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Oct 2013 21:58:20 -0400
In-Reply-To: <1381715743-13672-1-git-send-email-bsd@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bandan Das <bsd@makefile.in>
---
 drivers/vhost/net.c   |  25 +++++++++++
 drivers/vhost/vhost.c | 115 +++++++++++++++++++++++++++++++++++++++++++-------
 drivers/vhost/vhost.h |   6 +++
 3 files changed, 130 insertions(+), 16 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 831eb4f..f5307d7 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -34,6 +34,10 @@ module_param(experimental_zcopytx, int, 0444);
 MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
 		                       " 1 -Enable; 0 - Disable");
 
+static int cmwq_worker;
+module_param(cmwq_worker, int, 0444);
+MODULE_PARM_DESC(cmwq_worker, "Use cmwq for worker threads - Experimental, 1 - Enable; 0 - Disable");
+
 /* Max number of bytes transferred before requeueing the job.
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
@@ -694,6 +698,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	}
 
 	dev = &n->dev;
+	dev->use_wq = 0;
 	vqs[VHOST_NET_VQ_TX] = &n->vqs[VHOST_NET_VQ_TX].vq;
 	vqs[VHOST_NET_VQ_RX] = &n->vqs[VHOST_NET_VQ_RX].vq;
 	n->vqs[VHOST_NET_VQ_TX].vq.handle_kick = handle_tx_kick;
@@ -706,6 +711,10 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 		n->vqs[i].vhost_hlen = 0;
 		n->vqs[i].sock_hlen = 0;
 	}
+
+	if (cmwq_worker)
+		dev->use_wq = 1;
+
 	r = vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
 	if (r < 0) {
 		kfree(n);
@@ -1123,14 +1132,30 @@ static struct miscdevice vhost_net_misc = {
 
 static int vhost_net_init(void)
 {
+	int ret = 0;
+
 	if (experimental_zcopytx)
 		vhost_net_enable_zcopy(VHOST_NET_VQ_TX);
+
+	if (cmwq_worker) {
+		ret = vhost_wq_init();
+		if (ret) {
+			pr_info("Enabling wq based vhost workers failed! "
+				 "Switching to device based worker instead\n");
+			cmwq_worker = 0;
+		} else
+		  pr_info("Enabled workqueues based vhost workers\n");
+	}
+
 	return misc_register(&vhost_net_misc);
 }
 module_init(vhost_net_init);
 
 static void vhost_net_exit(void)
 {
+	if (cmwq_worker)
+		vhost_wq_cleanup();
+
 	misc_deregister(&vhost_net_misc);
 }
 module_exit(vhost_net_exit);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 69068e0..ba7ff7a 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -37,6 +37,9 @@ enum {
 #define vhost_used_event(vq) ((u16 __user *)&vq->avail->ring[vq->num])
 #define vhost_avail_event(vq) ((u16 __user *)&vq->used->ring[vq->num])
 
+static struct workqueue_struct *qworker;
+static void vhost_submission_workfn(struct work_struct *qwork);
+
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -162,7 +165,10 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work)
 		list_add_tail(&work->node, &dev->work_list);
 		work->queue_seq++;
 		spin_unlock_irqrestore(&dev->work_lock, flags);
-		wake_up_process(dev->worker);
+		if (dev->use_wq)
+			queue_work(qworker, &dev->qwork);
+		else
+			wake_up_process(dev->worker);
 	} else {
 		spin_unlock_irqrestore(&dev->work_lock, flags);
 	}
@@ -307,6 +313,9 @@ long vhost_dev_init(struct vhost_dev *dev,
 	INIT_LIST_HEAD(&dev->work_list);
 	dev->worker = NULL;
 
+	if (dev->use_wq)
+		INIT_WORK(&dev->qwork, vhost_submission_workfn);
+
 	for (i = 0; i < dev->nvqs; ++i) {
 		vq = dev->vqs[i];
 		vq->log = NULL;
@@ -367,7 +376,7 @@ EXPORT_SYMBOL_GPL(vhost_dev_has_owner);
 /* Caller should have device mutex */
 long vhost_dev_set_owner(struct vhost_dev *dev)
 {
-	struct task_struct *worker;
+	struct task_struct *worker = NULL;
 	int err;
 
 	/* Is there an owner already? */
@@ -376,28 +385,35 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 		goto err_mm;
 	}
 
+	err = vhost_dev_alloc_iovecs(dev);
+	if (err)
+		goto err_cgroup;
+
 	/* No owner, become one */
 	dev->mm = get_task_mm(current);
-	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
-	if (IS_ERR(worker)) {
-		err = PTR_ERR(worker);
-		goto err_worker;
-	}
 
-	dev->worker = worker;
-	wake_up_process(worker);	/* avoid contributing to loadavg */
+	if (!dev->use_wq) {
+		worker = kthread_create(vhost_worker,
+					dev, "vhost-%d", current->pid);
+		if (IS_ERR(worker)) {
+			err = PTR_ERR(worker);
+			goto err_worker;
+		}
 
-	err = vhost_attach_cgroups(dev);
-	if (err)
-		goto err_cgroup;
+		dev->worker = worker;
+		/* avoid contributing to loadavg */
+		wake_up_process(worker);
 
-	err = vhost_dev_alloc_iovecs(dev);
-	if (err)
-		goto err_cgroup;
+		err = vhost_attach_cgroups(dev);
+		if (err)
+			goto err_cgroup;
+	} /* else don't worry, we are using wqs for vhost work */
 
 	return 0;
+
 err_cgroup:
-	kthread_stop(worker);
+	if (worker)
+		kthread_stop(worker);
 	dev->worker = NULL;
 err_worker:
 	if (dev->mm)
@@ -1539,6 +1555,73 @@ void vhost_disable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 }
 EXPORT_SYMBOL_GPL(vhost_disable_notify);
 
+static void vhost_submission_workfn(struct work_struct *qwork)
+{
+	struct vhost_dev *dev =
+		container_of(qwork, struct vhost_dev, qwork);
+	struct vhost_work *work = NULL;
+	unsigned uninitialized_var(seq);
+	struct mm_struct *prev_mm = NULL;
+	mm_segment_t oldfs = get_fs();
+
+	set_fs(USER_DS);
+
+	for (;;) {
+
+		spin_lock_irq(&dev->work_lock);
+
+		if (list_empty(&dev->work_list)) {
+			spin_unlock(&dev->work_lock);
+			break;
+		}
+
+		work = list_first_entry(&dev->work_list,
+					struct vhost_work, node);
+		list_del_init(&work->node);
+		seq = work->queue_seq;
+
+		if (prev_mm != dev->mm) {
+			if (prev_mm)
+				unuse_mm(prev_mm);
+			prev_mm = dev->mm;
+			use_mm(prev_mm);
+		}
+
+		spin_unlock_irq(&dev->work_lock);
+
+		if (work) {
+			work->fn(work);
+
+			spin_lock_irq(&dev->work_lock);
+			work->done_seq = seq;
+			if (work->flushing)
+				wake_up_all(&work->done);
+			spin_unlock_irq(&dev->work_lock);
+
+		}
+	}
+
+	if (prev_mm)
+		unuse_mm(prev_mm);
+	set_fs(oldfs);
+}
+
+int vhost_wq_init(void)
+{
+	qworker = alloc_workqueue("vhost_worker",
+			WQ_MEM_RECLAIM|WQ_CPU_INTENSIVE|WQ_SYSFS, 0);
+	if (!qworker)
+		return -ENOMEM;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vhost_wq_init);
+
+void vhost_wq_cleanup(void)
+{
+	destroy_workqueue(qworker);
+}
+EXPORT_SYMBOL_GPL(vhost_wq_cleanup);
+
 static int __init vhost_init(void)
 {
 	return 0;
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 4465ed5..3f6c147 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -125,6 +125,8 @@ struct vhost_dev {
 	spinlock_t work_lock;
 	struct list_head work_list;
 	struct task_struct *worker;
+	int use_wq;
+	struct work_struct qwork;
 };
 
 long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
@@ -161,6 +163,10 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
 
+/* Experimental cmwq decls */
+int  vhost_wq_init(void);
+void vhost_wq_cleanup(void);
+
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
 		if ((vq)->error_ctx)                               \
-- 
1.8.3.1
