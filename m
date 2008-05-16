From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/6] [BNX2]: Add EEH PCI recovery
Date: Fri, 16 May 2008 14:29:59 -0700
Message-ID: <1210973399.5507.18.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, benli@broadcom.com,
	wendyx@us.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4156 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612AbYEPUiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 16:38:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add EEH PCI recovery.

Add PCI recovery functions to the driver.  The initial pci state is
also saved so the the MSI state can be restored during PCI recovery.

Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   88 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 934c2bf..2589b99 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7119,6 +7119,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	}
 
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 	bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (bp->pm_cap == 0) {
@@ -7628,6 +7629,92 @@ bnx2_resume(struct pci_dev *pdev)
 	return 0;
 }
 
+/**
+ * bnx2_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t bnx2_io_error_detected(struct pci_dev *pdev,
+					       pci_channel_state_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2 *bp = netdev_priv(dev);
+
+	rtnl_lock();
+	netif_device_detach(dev);
+
+	if (netif_running(dev)) {
+		bnx2_netif_stop(bp);
+		del_timer_sync(&bp->timer);
+		bnx2_reset_nic(bp, BNX2_DRV_MSG_CODE_RESET);
+	}
+
+	pci_disable_device(pdev);
+	rtnl_unlock();
+
+	/* Request a slot slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * bnx2_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ */
+static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2 *bp = netdev_priv(dev);
+
+	rtnl_lock();
+	if (pci_enable_device(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
+		rtnl_unlock();
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+
+	if (netif_running(dev)) {
+		bnx2_set_power_state(bp, PCI_D0);
+		bnx2_init_nic(bp, 1);
+	}
+
+	rtnl_unlock();
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * bnx2_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation.
+ */
+static void bnx2_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2 *bp = netdev_priv(dev);
+
+	rtnl_lock();
+	if (netif_running(dev))
+		bnx2_netif_start(bp);
+
+	netif_device_attach(dev);
+	rtnl_unlock();
+}
+
+static struct pci_error_handlers bnx2_err_handler = {
+	.error_detected	= bnx2_io_error_detected,
+	.slot_reset	= bnx2_io_slot_reset,
+	.resume		= bnx2_io_resume,
+};
+
 static struct pci_driver bnx2_pci_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= bnx2_pci_tbl,
@@ -7635,6 +7722,7 @@ static struct pci_driver bnx2_pci_driver = {
 	.remove		= __devexit_p(bnx2_remove_one),
 	.suspend	= bnx2_suspend,
 	.resume		= bnx2_resume,
+	.err_handler	= &bnx2_err_handler,
 };
 
 static int __init bnx2_init(void)
-- 
1.5.5.GIT



