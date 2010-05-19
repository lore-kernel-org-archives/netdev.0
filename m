From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [ PATCH 3/3] vhost: make it more scalable by creating a vhost
 thread per device
Date: Tue, 18 May 2010 17:04:55 -0700
Message-ID: <1274227495.2370.111.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make vhost more scalable by creating a separate vhost thread per
vhost device. This provides better scaling across virtio-net interfaces
in multiple guests.

Also attach each vhost thread to the cgroup and cpumask of the 
associated guest(qemu or libvirt).

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9777583..18bf5be 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -329,19 +329,22 @@ static void handle_rx_net(struct work_struct *work)
 static int vhost_net_open(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
+	struct vhost_dev *dev;
 	int r;
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
@@ -644,25 +647,14 @@ static struct miscdevice vhost_net_misc = {
 
 int vhost_net_init(void)
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
+
 module_init(vhost_net_init);
 
 void vhost_net_exit(void)
 {
 	misc_deregister(&vhost_net_misc);
-	vhost_cleanup();
 }
 module_exit(vhost_net_exit);
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 49fa953..b076b9b 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -37,8 +37,6 @@ enum {
 	VHOST_MEMORY_F_LOG = 0x1,
 };
 
-static struct workqueue_struct *vhost_workqueue;
-
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -57,18 +55,19 @@ static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
 	if (!((unsigned long)key & poll->mask))
 		return 0;
 
-	queue_work(vhost_workqueue, &poll->work);
+	queue_work(poll->dev->wq, &poll->work);
 	return 0;
 }
 
 /* Init poll structure */
 void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
-		     unsigned long mask)
+		     unsigned long mask, struct vhost_dev *dev)
 {
 	INIT_WORK(&poll->work, func);
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
+	poll->dev = dev;
 }
 
 /* Start polling a file. We add ourselves to file's wait queue. The caller must
@@ -97,7 +96,7 @@ void vhost_poll_flush(struct vhost_poll *poll)
 
 void vhost_poll_queue(struct vhost_poll *poll)
 {
-	queue_work(vhost_workqueue, &poll->work);
+	queue_work(poll->dev->wq, &poll->work);
 }
 
 static void vhost_vq_reset(struct vhost_dev *dev,
@@ -129,6 +128,13 @@ long vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue *vqs, int nvqs)
 {
 	int i;
+	char vhost_name[20];
+
+	snprintf(vhost_name, 20, "vhost-%d", current->pid);
+	dev->wq = create_singlethread_workqueue_in_current_cg(vhost_name);
+	if (!dev->wq)
+		return -ENOMEM;
+
 	dev->vqs = vqs;
 	dev->nvqs = nvqs;
 	mutex_init(&dev->mutex);
@@ -144,7 +150,7 @@ long vhost_dev_init(struct vhost_dev *dev,
 		if (dev->vqs[i].handle_kick)
 			vhost_poll_init(&dev->vqs[i].poll,
 					dev->vqs[i].handle_kick,
-					POLLIN);
+					POLLIN, dev);
 	}
 	return 0;
 }
@@ -217,6 +223,8 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 	if (dev->mm)
 		mmput(dev->mm);
 	dev->mm = NULL;
+
+	destroy_workqueue(dev->wq);
 }
 
 static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
@@ -1105,16 +1113,3 @@ void vhost_disable_notify(struct vhost_virtqueue *vq)
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
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 44591ba..60fefd0 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -29,10 +29,11 @@ struct vhost_poll {
 	/* struct which will handle all actual work. */
 	struct work_struct        work;
 	unsigned long		  mask;
+	struct vhost_dev	 *dev;
 };
 
 void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
-		     unsigned long mask);
+		     unsigned long mask, struct vhost_dev *dev);
 void vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
 void vhost_poll_flush(struct vhost_poll *poll);
@@ -110,6 +111,7 @@ struct vhost_dev {
 	int nvqs;
 	struct file *log_file;
 	struct eventfd_ctx *log_ctx;
+	struct workqueue_struct *wq;
 };
 
 long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
@@ -136,9 +138,6 @@ bool vhost_enable_notify(struct vhost_virtqueue *);
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
 
-int vhost_init(void);
-void vhost_cleanup(void);
-
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
 		if ((vq)->error_ctx)                               \
