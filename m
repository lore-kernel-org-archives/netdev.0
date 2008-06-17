From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 14/15]bnx2x: Add PCIE EEH support
Date: Tue, 17 Jun 2008 17:49:48 +0300
Message-ID: <1213714188.5817.184.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Wendy Xiong" <wendyx@us.ibm.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3673 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758227AbYFQOuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 10:50:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PCI recovery functions to the driver.  The initial PCI state is
also saved so the MSI state can be restored during PCI recovery.

Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   96 +++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 90 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index b9e5f5b..911669f 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9989,13 +9989,97 @@ static int bnx2x_resume(struct pci_dev *pdev)
 	return 0;
 }
 
+/**
+ * bnx2x_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t bnx2x_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2x *bp = netdev_priv(dev);
+
+	rtnl_lock();
+	netif_device_detach(dev);
+
+	if (netif_running(dev))
+		bnx2x_nic_unload(bp, UNLOAD_CLOSE);
+
+	pci_disable_device(pdev);
+	rtnl_unlock();
+
+	/* Request a slot slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * bnx2x_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ */
+static pci_ers_result_t bnx2x_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2x *bp = netdev_priv(dev);
+
+	rtnl_lock();
+	if (pci_enable_device(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
+		rtnl_unlock();
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	if (netif_running(dev))
+		bnx2x_set_power_state(bp, PCI_D0);
+
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+	rtnl_unlock();
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * bnx2x_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation.
+ */
+static void bnx2x_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2x *bp = netdev_priv(dev);
+
+	rtnl_lock();
+
+	if (netif_running(dev))
+		bnx2x_nic_load(bp, LOAD_OPEN);
+	netif_device_attach(dev);
+
+	rtnl_unlock();
+}
+
+static struct pci_error_handlers bnx2x_err_handler = {
+	.error_detected = bnx2x_io_error_detected,
+	.slot_reset = bnx2x_io_slot_reset,
+	.resume = bnx2x_io_resume,
+};
+
 static struct pci_driver bnx2x_pci_driver = {
-	.name       = DRV_MODULE_NAME,
-	.id_table   = bnx2x_pci_tbl,
-	.probe      = bnx2x_init_one,
-	.remove     = __devexit_p(bnx2x_remove_one),
-	.suspend    = bnx2x_suspend,
-	.resume     = bnx2x_resume,
+	.name        = DRV_MODULE_NAME,
+	.id_table    = bnx2x_pci_tbl,
+	.probe       = bnx2x_init_one,
+	.remove      = __devexit_p(bnx2x_remove_one),
+	.suspend     = bnx2x_suspend,
+	.resume      = bnx2x_resume,
+	.err_handler = &bnx2x_err_handler,
 };
 
 static int __init bnx2x_init(void)
-- 
1.5.3.2




