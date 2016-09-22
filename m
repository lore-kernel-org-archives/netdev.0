From: Juergen Gross <jgross@suse.com>
Subject: [PATCH resend 2] xen-netback: switch to threaded irq for control ring
Date: Thu, 22 Sep 2016 11:06:25 +0200
Message-ID: <1474535185-15734-1-git-send-email-jgross@suse.com>
Cc: wei.liu2@citrix.com, Juergen Gross <jgross@suse.com>
To: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of open coding it use the threaded irq mechanism in
xen-netback.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
resend due to missing netdev list in first attempt and wrong address in second.
---
 drivers/net/xen-netback/common.h    |  4 +---
 drivers/net/xen-netback/interface.c | 38 ++++++-------------------------------
 drivers/net/xen-netback/netback.c   | 18 ++++--------------
 3 files changed, 11 insertions(+), 49 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 84d6cbd..b38fb2c 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -292,8 +292,6 @@ struct xenvif {
 #endif
 
 	struct xen_netif_ctrl_back_ring ctrl;
-	struct task_struct *ctrl_task;
-	wait_queue_head_t ctrl_wq;
 	unsigned int ctrl_irq;
 
 	/* Miscellaneous private stuff. */
@@ -359,7 +357,7 @@ void xenvif_kick_thread(struct xenvif_queue *queue);
 
 int xenvif_dealloc_kthread(void *data);
 
-int xenvif_ctrl_kthread(void *data);
+irqreturn_t xenvif_ctrl_irq_fn(int irq, void *data);
 
 void xenvif_rx_queue_tail(struct xenvif_queue *queue, struct sk_buff *skb);
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 83deeeb..fb50c6d 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -128,15 +128,6 @@ irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-irqreturn_t xenvif_ctrl_interrupt(int irq, void *dev_id)
-{
-	struct xenvif *vif = dev_id;
-
-	wake_up(&vif->ctrl_wq);
-
-	return IRQ_HANDLED;
-}
-
 int xenvif_queue_stopped(struct xenvif_queue *queue)
 {
 	struct net_device *dev = queue->vif->dev;
@@ -570,8 +561,7 @@ int xenvif_connect_ctrl(struct xenvif *vif, grant_ref_t ring_ref,
 	struct net_device *dev = vif->dev;
 	void *addr;
 	struct xen_netif_ctrl_sring *shared;
-	struct task_struct *task;
-	int err = -ENOMEM;
+	int err;
 
 	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
 				     &ring_ref, 1, &addr);
@@ -581,11 +571,7 @@ int xenvif_connect_ctrl(struct xenvif *vif, grant_ref_t ring_ref,
 	shared = (struct xen_netif_ctrl_sring *)addr;
 	BACK_RING_INIT(&vif->ctrl, shared, XEN_PAGE_SIZE);
 
-	init_waitqueue_head(&vif->ctrl_wq);
-
-	err = bind_interdomain_evtchn_to_irqhandler(vif->domid, evtchn,
-						    xenvif_ctrl_interrupt,
-						    0, dev->name, vif);
+	err = bind_interdomain_evtchn_to_irq(vif->domid, evtchn);
 	if (err < 0)
 		goto err_unmap;
 
@@ -593,19 +579,13 @@ int xenvif_connect_ctrl(struct xenvif *vif, grant_ref_t ring_ref,
 
 	xenvif_init_hash(vif);
 
-	task = kthread_create(xenvif_ctrl_kthread, (void *)vif,
-			      "%s-control", dev->name);
-	if (IS_ERR(task)) {
-		pr_warn("Could not allocate kthread for %s\n", dev->name);
-		err = PTR_ERR(task);
+	err = request_threaded_irq(vif->ctrl_irq, NULL, xenvif_ctrl_irq_fn,
+				   IRQF_ONESHOT, "xen-netback-ctrl", vif);
+	if (err) {
+		pr_warn("Could not setup irq handler for %s\n", dev->name);
 		goto err_deinit;
 	}
 
-	get_task_struct(task);
-	vif->ctrl_task = task;
-
-	wake_up_process(vif->ctrl_task);
-
 	return 0;
 
 err_deinit:
@@ -774,12 +754,6 @@ void xenvif_disconnect_data(struct xenvif *vif)
 
 void xenvif_disconnect_ctrl(struct xenvif *vif)
 {
-	if (vif->ctrl_task) {
-		kthread_stop(vif->ctrl_task);
-		put_task_struct(vif->ctrl_task);
-		vif->ctrl_task = NULL;
-	}
-
 	if (vif->ctrl_irq) {
 		xenvif_deinit_hash(vif);
 		unbind_from_irqhandler(vif->ctrl_irq, vif);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index edbae0b..3d0c989 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -2359,24 +2359,14 @@ static bool xenvif_ctrl_work_todo(struct xenvif *vif)
 	return 0;
 }
 
-int xenvif_ctrl_kthread(void *data)
+irqreturn_t xenvif_ctrl_irq_fn(int irq, void *data)
 {
 	struct xenvif *vif = data;
 
-	for (;;) {
-		wait_event_interruptible(vif->ctrl_wq,
-					 xenvif_ctrl_work_todo(vif) ||
-					 kthread_should_stop());
-		if (kthread_should_stop())
-			break;
+	while (xenvif_ctrl_work_todo(vif))
+		xenvif_ctrl_action(vif);
 
-		while (xenvif_ctrl_work_todo(vif))
-			xenvif_ctrl_action(vif);
-
-		cond_resched();
-	}
-
-	return 0;
+	return IRQ_HANDLED;
 }
 
 static int __init netback_init(void)
-- 
2.6.6
