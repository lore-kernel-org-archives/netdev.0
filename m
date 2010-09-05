From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: fix attach to cgroups regression
Date: Sun, 5 Sep 2010 18:08:38 +0300
Message-ID: <20100905150837.GA22170@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>, Tejun Heo <tj@kernel.org>,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428Ab0IEPOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Sep 2010 11:14:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 2.6.36-rc1, non-root users of vhost-net fail to attach
if they are in any cgroups. This is a regression, and libvirt
actually uses this functionality, as it runs qemu with reduced
priveledges.

The bug is that when qemu uses vhost, vhost wants to attach
its thread to all cgroups that qemu has.  But we got the API backwards,
so a non-priveledged process (qemu) tried to control
the priveledged one (vhost), which fails.

Fix this using the new cgroup_attach_task_all,
and running it from the vhost thread.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Dave, no need to bother with this one unless you really want to -
I'll put it on my tree.

 drivers/vhost/vhost.c |   79 +++++++++++++++++++++++++++++++++++-------------
 1 files changed, 57 insertions(+), 22 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 4b99117..7c75dce 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -60,22 +60,25 @@ static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
 	return 0;
 }
 
+static void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn)
+{
+	INIT_LIST_HEAD(&work->node);
+	work->fn = fn;
+	init_waitqueue_head(&work->done);
+	work->flushing = 0;
+	work->queue_seq = work->done_seq = 0;
+}
+
 /* Init poll structure */
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
 		     unsigned long mask, struct vhost_dev *dev)
 {
-	struct vhost_work *work = &poll->work;
-
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
 	poll->dev = dev;
 
-	INIT_LIST_HEAD(&work->node);
-	work->fn = fn;
-	init_waitqueue_head(&work->done);
-	work->flushing = 0;
-	work->queue_seq = work->done_seq = 0;
+	vhost_work_init(&poll->work, fn);
 }
 
 /* Start polling a file. We add ourselves to file's wait queue. The caller must
@@ -95,35 +98,38 @@ void vhost_poll_stop(struct vhost_poll *poll)
 	remove_wait_queue(poll->wqh, &poll->wait);
 }
 
-/* Flush any work that has been scheduled. When calling this, don't hold any
- * locks that are also used by the callback. */
-void vhost_poll_flush(struct vhost_poll *poll)
+void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
 {
-	struct vhost_work *work = &poll->work;
 	unsigned seq;
 	int left;
 	int flushing;
 
-	spin_lock_irq(&poll->dev->work_lock);
+	spin_lock_irq(&dev->work_lock);
 	seq = work->queue_seq;
 	work->flushing++;
-	spin_unlock_irq(&poll->dev->work_lock);
+	spin_unlock_irq(&dev->work_lock);
 	wait_event(work->done, ({
-		   spin_lock_irq(&poll->dev->work_lock);
+		   spin_lock_irq(&dev->work_lock);
 		   left = seq - work->done_seq <= 0;
-		   spin_unlock_irq(&poll->dev->work_lock);
+		   spin_unlock_irq(&dev->work_lock);
 		   left;
 	}));
-	spin_lock_irq(&poll->dev->work_lock);
+	spin_lock_irq(&dev->work_lock);
 	flushing = --work->flushing;
-	spin_unlock_irq(&poll->dev->work_lock);
+	spin_unlock_irq(&dev->work_lock);
 	BUG_ON(flushing < 0);
 }
 
-void vhost_poll_queue(struct vhost_poll *poll)
+/* Flush any work that has been scheduled. When calling this, don't hold any
+ * locks that are also used by the callback. */
+void vhost_poll_flush(struct vhost_poll *poll)
+{
+	vhost_work_flush(poll->dev, &poll->work);
+}
+
+static inline void vhost_work_queue(struct vhost_dev *dev,
+				    struct vhost_work *work)
 {
-	struct vhost_dev *dev = poll->dev;
-	struct vhost_work *work = &poll->work;
 	unsigned long flags;
 
 	spin_lock_irqsave(&dev->work_lock, flags);
@@ -135,6 +141,11 @@ void vhost_poll_queue(struct vhost_poll *poll)
 	spin_unlock_irqrestore(&dev->work_lock, flags);
 }
 
+void vhost_poll_queue(struct vhost_poll *poll)
+{
+	vhost_work_queue(poll->dev, &poll->work);
+}
+
 static void vhost_vq_reset(struct vhost_dev *dev,
 			   struct vhost_virtqueue *vq)
 {
@@ -236,6 +247,29 @@ long vhost_dev_check_owner(struct vhost_dev *dev)
 	return dev->mm == current->mm ? 0 : -EPERM;
 }
 
+struct vhost_attach_cgroups_struct {
+        struct vhost_work work;
+        struct task_struct *owner;
+        int ret;
+};
+
+static void vhost_attach_cgroups_work(struct vhost_work *work)
+{
+        struct vhost_attach_cgroups_struct *s;
+        s = container_of(work, struct vhost_attach_cgroups_struct, work);
+        s->ret = cgroup_attach_task_all(s->owner, current);
+}
+
+static int vhost_attach_cgroups(struct vhost_dev *dev)
+{
+        struct vhost_attach_cgroups_struct attach;
+        attach.owner = current;
+        vhost_work_init(&attach.work, vhost_attach_cgroups_work);
+        vhost_work_queue(dev, &attach.work);
+        vhost_work_flush(dev, &attach.work);
+        return attach.ret;
+}
+
 /* Caller should have device mutex */
 static long vhost_dev_set_owner(struct vhost_dev *dev)
 {
@@ -255,10 +289,11 @@ static long vhost_dev_set_owner(struct vhost_dev *dev)
 	}
 
 	dev->worker = worker;
-	err = cgroup_attach_task_current_cg(worker);
+	wake_up_process(worker);	/* avoid contributing to loadavg */
+
+	err = vhost_attach_cgroups(dev);
 	if (err)
 		goto err_cgroup;
-	wake_up_process(worker);	/* avoid contributing to loadavg */
 
 	return 0;
 err_cgroup:
-- 
1.7.2.rc0.14.g41c1c
