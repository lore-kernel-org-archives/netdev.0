From: Bandan Das <bsd@redhat.com>
Subject: [RFC PATCH 2/4] vhost: Limit the number of devices served by a single worker thread
Date: Mon, 13 Jul 2015 00:07:33 -0400
Message-ID: <1436760455-5686-3-git-send-email-bsd@redhat.com>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Eyal Moscovici <EYALMO@il.ibm.com>,
	Razya Ladelsky <RAZYA@il.ibm.com>, cgroups@vger.kernel.org,
	jasowang@redhat.com
To: kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1436760455-5686-1-git-send-email-bsd@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the number of devices increase, the universal thread model
(introduced in the preceding patch) may end up being the bottleneck.
Moreover, a single worker thread also forces us to change cgroups
based on the device we are serving.

We introduce a worker pool struct that starts with one worker
thread and we keep adding more threads when the numbers of devs
reaches a certain threshold. The default value is set at 7 but is
not based on any empirical data. The value can also be changed by
the user with the devs_per_worker module parameter.

Note that this patch doesn't change how cgroups work. We still
keep moving around the worker thread to the cgroups of the
device we are serving at the moment.

Signed-off-by: Razya Ladelsky <razya@il.ibm.com>
Signed-off-by: Bandan Das <bsd@redhat.com>
---
 drivers/vhost/net.c   |   6 +--
 drivers/vhost/scsi.c  |   3 +-
 drivers/vhost/vhost.c | 135 +++++++++++++++++++++++++++++++++++++++++---------
 drivers/vhost/vhost.h |  13 ++++-
 4 files changed, 128 insertions(+), 29 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 7d137a4..7bfa019 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -705,7 +705,8 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 		n->vqs[i].vhost_hlen = 0;
 		n->vqs[i].sock_hlen = 0;
 	}
-	vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
+	if (vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX))
+		return dev->err;
 
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
@@ -801,9 +802,6 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 		sockfd_put(rx_sock);
 	/* Make sure no callbacks are outstanding */
 	synchronize_rcu_bh();
-	/* We do an extra flush before freeing memory,
-	 * since jobs can re-queue themselves. */
-	vhost_net_flush(n);
 	kfree(n->dev.vqs);
 	kvfree(n);
 	return 0;
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 6c42936..97de2db 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1601,7 +1601,8 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
 		vqs[i] = &vs->vqs[i].vq;
 		vs->vqs[i].vq.handle_kick = vhost_scsi_handle_kick;
 	}
-	vhost_dev_init(&vs->dev, vqs, VHOST_SCSI_MAX_VQ);
+	if (vhost_dev_init(&vs->dev, vqs, VHOST_SCSI_MAX_VQ))
+		return vs->dev.err;
 
 	vhost_scsi_init_inflight(vs, NULL);
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 951c96b..6a5d4c0 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -27,11 +27,19 @@
 #include <linux/kthread.h>
 #include <linux/cgroup.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 
 #include "vhost.h"
 
-/* Just one worker thread to service all devices */
-static struct vhost_worker *worker;
+static int __read_mostly devs_per_worker = 7;
+module_param(devs_per_worker, int, S_IRUGO);
+MODULE_PARM_DESC(devs_per_worker, "Setup the number of devices being served by a worker thread");
+
+/* Only used to give a unique id to a vhost thread at the moment */
+static unsigned int total_vhost_workers;
+
+/* Pool of vhost threads */
+static struct vhost_pool *vhost_pool;
 
 enum {
 	VHOST_MEMORY_MAX_NREGIONS = 64,
@@ -270,6 +278,63 @@ static int vhost_worker(void *data)
 	return 0;
 }
 
+static void vhost_create_worker(struct vhost_dev *dev)
+{
+	struct vhost_worker *worker;
+	struct vhost_pool *pool = vhost_pool;
+
+	worker = kzalloc(sizeof(*worker), GFP_KERNEL);
+	if (!worker) {
+		dev->err = -ENOMEM;
+		return;
+	}
+
+	worker->thread = kthread_create(vhost_worker,
+					worker,
+					"vhost-%d",
+					total_vhost_workers);
+	if (IS_ERR(worker->thread)) {
+		dev->err = PTR_ERR(worker->thread);
+		goto therror;
+	}
+
+	spin_lock_init(&worker->work_lock);
+	INIT_LIST_HEAD(&worker->work_list);
+	list_add(&worker->node, &pool->workers);
+	worker->owner = NULL;
+	worker->num_devices++;
+	total_vhost_workers++;
+	dev->worker = worker;
+	dev->worker_assigned = true;
+	return;
+
+therror:
+	if (worker->thread)
+		kthread_stop(worker->thread);
+	kfree(worker);
+}
+
+static int vhost_dev_assign_worker(struct vhost_dev *dev)
+{
+	struct vhost_worker *worker;
+
+	mutex_lock(&vhost_pool->pool_lock);
+	list_for_each_entry(worker, &vhost_pool->workers, node) {
+		if (worker->num_devices < devs_per_worker) {
+			dev->worker = worker;
+			dev->worker_assigned = true;
+			worker->num_devices++;
+			break;
+		}
+	}
+	if (!dev->worker_assigned)
+		/* create a new worker */
+		vhost_create_worker(dev);
+	mutex_unlock(&vhost_pool->pool_lock);
+
+	return dev->err;
+}
+
 static void vhost_vq_free_iovecs(struct vhost_virtqueue *vq)
 {
 	kfree(vq->indirect);
@@ -311,7 +376,7 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 		vhost_vq_free_iovecs(dev->vqs[i]);
 }
 
-void vhost_dev_init(struct vhost_dev *dev,
+int vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue **vqs, int nvqs)
 {
 	struct vhost_virtqueue *vq;
@@ -324,9 +389,14 @@ void vhost_dev_init(struct vhost_dev *dev,
 	dev->log_file = NULL;
 	dev->memory = NULL;
 	dev->mm = NULL;
-	dev->worker = worker;
+	dev->worker = NULL;
+	dev->err = 0;
+	dev->worker_assigned = false;
 	dev->owner = current;
 
+	if (vhost_dev_assign_worker(dev))
+		goto done;
+
 	for (i = 0; i < dev->nvqs; ++i) {
 		vq = dev->vqs[i];
 		vq->log = NULL;
@@ -339,6 +409,9 @@ void vhost_dev_init(struct vhost_dev *dev,
 			vhost_poll_init(&vq->poll, vq->handle_kick,
 					POLLIN, dev);
 	}
+
+done:
+	return dev->err;
 }
 EXPORT_SYMBOL_GPL(vhost_dev_init);
 
@@ -370,7 +443,6 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 
 	/* No owner, become one */
 	dev->mm = get_task_mm(current);
-	dev->worker = worker;
 
 	err = vhost_dev_alloc_iovecs(dev);
 	if (err)
@@ -424,6 +496,24 @@ void vhost_dev_stop(struct vhost_dev *dev)
 }
 EXPORT_SYMBOL_GPL(vhost_dev_stop);
 
+static void vhost_deassign_worker(struct vhost_dev *dev)
+{
+	if (dev->worker) {
+		mutex_lock(&vhost_pool->pool_lock);
+		WARN_ON(dev->worker->num_devices <= 0);
+		if (!--dev->worker->num_devices) {
+			WARN_ON(!list_empty(&dev->worker->work_list));
+			list_del(&dev->worker->node);
+			kthread_stop(dev->worker->thread);
+			dev->worker->thread = NULL;
+			kfree(dev->worker);
+		}
+		mutex_unlock(&vhost_pool->pool_lock);
+	}
+
+	dev->worker = NULL;
+}
+
 /* Caller should have device mutex if and only if locked is set */
 void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 {
@@ -452,6 +542,7 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 	/* No one will access memory at this point */
 	kfree(dev->memory);
 	dev->memory = NULL;
+	vhost_deassign_worker(dev);
 	if (dev->mm)
 		mmput(dev->mm);
 	dev->mm = NULL;
@@ -1542,31 +1633,29 @@ EXPORT_SYMBOL_GPL(vhost_disable_notify);
 
 static int __init vhost_init(void)
 {
-	struct vhost_worker *w =
-		kzalloc(sizeof(*w), GFP_KERNEL);
-	if (!w)
+	struct vhost_pool *pool =
+		kzalloc(sizeof(*pool), GFP_KERNEL);
+	if (!pool)
 		return -ENOMEM;
-
-	w->thread = kthread_create(vhost_worker,
-				   w, "vhost-worker");
-	if (IS_ERR(w->thread))
-		return PTR_ERR(w->thread);
-
-	worker = w;
-	spin_lock_init(&worker->work_lock);
-	INIT_LIST_HEAD(&worker->work_list);
-	wake_up_process(worker->thread);
-	pr_info("Created universal thread to service requests\n");
+	mutex_init(&pool->pool_lock);
+	INIT_LIST_HEAD(&pool->workers);
+	vhost_pool = pool;
 
 	return 0;
 }
 
 static void __exit vhost_exit(void)
 {
-	if (worker) {
-		kthread_stop(worker->thread);
-		WARN_ON(!list_empty(&worker->work_list));
-		kfree(worker);
+	struct vhost_worker *worker;
+
+	if (vhost_pool) {
+		list_for_each_entry(worker, &vhost_pool->workers, node) {
+			kthread_stop(worker->thread);
+			WARN_ON(!list_empty(&worker->work_list));
+			list_del(&worker->node);
+			kfree(worker);
+		}
+		kfree(vhost_pool);
 	}
 }
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 2f204ce..a45193b 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -120,19 +120,30 @@ struct vhost_dev {
 	struct vhost_worker *worker;
 	/* for cgroup support */
 	struct task_struct *owner;
+	bool worker_assigned;
+	int err;
 };
 
 struct vhost_worker {
 	spinlock_t work_lock;
+	unsigned id;
 	struct list_head work_list;
 	struct task_struct *thread;
 	struct task_struct *owner;
+	int num_devices;
+	struct list_head node;
+};
+
+struct vhost_pool {
+	struct work_struct work;
+	struct mutex pool_lock;
+	struct list_head workers;
 };
 
 void vhost_work_queue(struct vhost_worker *worker,
 		      struct vhost_work *work);
 void vhost_work_flush(struct vhost_worker *worker, struct vhost_work *work);
-void vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
+int vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
 long vhost_dev_set_owner(struct vhost_dev *dev);
 bool vhost_dev_has_owner(struct vhost_dev *dev);
 long vhost_dev_check_owner(struct vhost_dev *);
-- 
2.4.3

