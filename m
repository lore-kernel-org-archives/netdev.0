From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/6 net-next] bnx2: Use SIMPLE_DEV_PM_OPS.
Date: Tue, 6 Aug 2013 15:50:10 -0700
Message-ID: <1375829412-26425-5-git-send-email-mchan@broadcom.com>
References: <1375829412-26425-1-git-send-email-mchan@broadcom.com>
 <1375829412-26425-2-git-send-email-mchan@broadcom.com>
 <1375829412-26425-3-git-send-email-mchan@broadcom.com>
 <1375829412-26425-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4004 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756691Ab3HFW2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 18:28:09 -0400
In-Reply-To: <1375829412-26425-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simplifies the suspend/resume code.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   45 +++++++++++++++++++---------------
 1 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 0b54ca0..27a128c 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8602,46 +8602,52 @@ bnx2_remove_one(struct pci_dev *pdev)
 }
 
 static int
-bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
+bnx2_suspend(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2 *bp = netdev_priv(dev);
 
-	/* PCI register 4 needs to be saved whether netif_running() or not.
-	 * MSI address and data need to be saved if using MSI and
-	 * netif_running().
-	 */
-	pci_save_state(pdev);
-	if (!netif_running(dev))
-		return 0;
-
-	cancel_work_sync(&bp->reset_task);
-	bnx2_netif_stop(bp, true);
-	netif_device_detach(dev);
-	del_timer_sync(&bp->timer);
-	bnx2_shutdown_chip(bp);
-	bnx2_free_skbs(bp);
-	bnx2_set_power_state(bp, pci_choose_state(pdev, state));
+	if (netif_running(dev)) {
+		cancel_work_sync(&bp->reset_task);
+		bnx2_netif_stop(bp, true);
+		netif_device_detach(dev);
+		del_timer_sync(&bp->timer);
+		bnx2_shutdown_chip(bp);
+		__bnx2_free_irq(bp);
+		bnx2_free_skbs(bp);
+	}
+	bnx2_setup_wol(bp);
 	return 0;
 }
 
 static int
-bnx2_resume(struct pci_dev *pdev)
+bnx2_resume(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2 *bp = netdev_priv(dev);
 
-	pci_restore_state(pdev);
 	if (!netif_running(dev))
 		return 0;
 
 	bnx2_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
+	bnx2_request_irq(bp);
 	bnx2_init_nic(bp, 1);
 	bnx2_netif_start(bp, true);
 	return 0;
 }
 
+#ifdef CONFIG_PM_SLEEP
+static SIMPLE_DEV_PM_OPS(bnx2_pm_ops, bnx2_suspend, bnx2_resume);
+#define BNX2_PM_OPS (&bnx2_pm_ops)
+
+#else
+
+#define BNX2_PM_OPS NULL
+
+#endif /* CONFIG_PM_SLEEP */
 /**
  * bnx2_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
@@ -8757,8 +8763,7 @@ static struct pci_driver bnx2_pci_driver = {
 	.id_table	= bnx2_pci_tbl,
 	.probe		= bnx2_init_one,
 	.remove		= bnx2_remove_one,
-	.suspend	= bnx2_suspend,
-	.resume		= bnx2_resume,
+	.driver.pm	= BNX2_PM_OPS,
 	.err_handler	= &bnx2_err_handler,
 };
 
-- 
1.7.1
