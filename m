From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 01/34]bnx2x: Using singlethread work queue
Date: Wed, 14 Jan 2009 18:42:40 +0200
Message-ID: <1231951360.11301.122.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758986AbZANQn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since slow-path events, including link update, are handled in work-queue, a race
condition was introduced in the self-test that sometimes caused the link status
to fail: the self-test was running under RTNL lock, and if the link-watch was
scheduled it stoped the shared work-queue (waiting for the RTNL lock) and so the
link update event was not handled until the self-test ended (releasing the RTNL
lock) with failure (since the link status was not updated)

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_main.c |   20 +++++++++++++++-----
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index fd705d1..96a8889 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -811,7 +811,7 @@ struct bnx2x {
 	int			pm_cap;
 	int			pcie_cap;
 
-	struct work_struct	sp_task;
+	struct delayed_work	sp_task;
 	struct work_struct	reset_task;
 
 	struct timer_list	timer;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 4be0584..cc6ffba 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -95,6 +95,7 @@ MODULE_PARM_DESC(debug, "default debug msglevel");
 module_param(use_multi, int, 0);
 MODULE_PARM_DESC(use_multi, "use per-CPU queues");
 #endif
+static struct workqueue_struct *bnx2x_wq;
 
 enum bnx2x_board_type {
 	BCM57710 = 0,
@@ -671,7 +672,8 @@ static void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 		synchronize_irq(bp->pdev->irq);
 
 	/* make sure sp_task is not running */
-	cancel_work_sync(&bp->sp_task);
+	cancel_delayed_work(&bp->sp_task);
+	flush_workqueue(bnx2x_wq);
 }
 
 /* fast path */
@@ -1660,7 +1662,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 
 
 	if (unlikely(status & 0x1)) {
-		schedule_work(&bp->sp_task);
+		queue_delayed_work(bnx2x_wq, &bp->sp_task, 0);
 
 		status &= ~0x1;
 		if (!status)
@@ -2820,7 +2822,7 @@ static void bnx2x_attn_int(struct bnx2x *bp)
 
 static void bnx2x_sp_task(struct work_struct *work)
 {
-	struct bnx2x *bp = container_of(work, struct bnx2x, sp_task);
+	struct bnx2x *bp = container_of(work, struct bnx2x, sp_task.work);
 	u16 status;
 
 
@@ -2875,7 +2877,7 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 		return IRQ_HANDLED;
 #endif
 
-	schedule_work(&bp->sp_task);
+	queue_delayed_work(bnx2x_wq, &bp->sp_task, 0);
 
 	return IRQ_HANDLED;
 }
@@ -7501,7 +7503,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	mutex_init(&bp->port.phy_mutex);
 
-	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
+	INIT_DELAYED_WORK(&bp->sp_task, bnx2x_sp_task);
 	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
 
 	rc = bnx2x_get_hwinfo(bp);
@@ -10519,12 +10521,20 @@ static struct pci_driver bnx2x_pci_driver = {
 
 static int __init bnx2x_init(void)
 {
+	bnx2x_wq = create_singlethread_workqueue("bnx2x");
+	if (bnx2x_wq == NULL) {
+		printk(KERN_ERR PFX "Cannot create workqueue\n");
+		return -ENOMEM;
+	}
+
 	return pci_register_driver(&bnx2x_pci_driver);
 }
 
 static void __exit bnx2x_cleanup(void)
 {
 	pci_unregister_driver(&bnx2x_pci_driver);
+
+	destroy_workqueue(bnx2x_wq);
 }
 
 module_init(bnx2x_init);
-- 
1.5.4.3




