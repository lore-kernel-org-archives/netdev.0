From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH v2 net-next 8/8] bnxt_en: Enable AER support.
Date: Mon,  7 Mar 2016 15:38:48 -0500
Message-ID: <1457383128-28645-9-git-send-email-michael.chan@broadcom.com>
References: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:49444
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753639AbcCGUiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:38:51 -0500
In-Reply-To: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Baddipadige <sbaddipa@broadcom.com>

Add pci_error_handler callbacks to support for pcie advanced error
recovery.

Signed-off-by: Satish Baddipadige <sbaddipa@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 109 ++++++++++++++++++++++++++++++
 1 file changed, 109 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 18a14a5..0cd55de 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5411,6 +5411,8 @@ static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto init_err_release;
 	}
 
+	pci_enable_pcie_error_reporting(pdev);
+
 	INIT_WORK(&bp->sp_task, bnxt_sp_task);
 
 	spin_lock_init(&bp->ntp_fltr_lock);
@@ -5790,6 +5792,7 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	if (BNXT_PF(bp))
 		bnxt_sriov_disable(bp);
 
+	pci_disable_pcie_error_reporting(pdev);
 	unregister_netdev(dev);
 	cancel_work_sync(&bp->sp_task);
 	bp->sp_event = 0;
@@ -6029,11 +6032,117 @@ init_err_free:
 	return rc;
 }
 
+/**
+ * bnxt_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t bnxt_io_error_detected(struct pci_dev *pdev,
+					       pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+
+	netdev_info(netdev, "PCI I/O error detected\n");
+
+	rtnl_lock();
+	netif_device_detach(netdev);
+
+	if (state == pci_channel_io_perm_failure) {
+		rtnl_unlock();
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	if (netif_running(netdev))
+		bnxt_close(netdev);
+
+	pci_disable_device(pdev);
+	rtnl_unlock();
+
+	/* Request a slot slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * bnxt_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ * At this point, the card has exprienced a hard reset,
+ * followed by fixups by BIOS, and has its config space
+ * set up identically to what it was at cold boot.
+ */
+static pci_ers_result_t bnxt_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct bnxt *bp = netdev_priv(netdev);
+	int err = 0;
+	pci_ers_result_t result = PCI_ERS_RESULT_DISCONNECT;
+
+	netdev_info(bp->dev, "PCI Slot Reset\n");
+
+	rtnl_lock();
+
+	if (pci_enable_device(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
+	} else {
+		pci_set_master(pdev);
+
+		if (netif_running(netdev))
+			err = bnxt_open(netdev);
+
+		if (!err)
+			result = PCI_ERS_RESULT_RECOVERED;
+	}
+
+	if (result != PCI_ERS_RESULT_RECOVERED && netif_running(netdev))
+		dev_close(netdev);
+
+	rtnl_unlock();
+
+	err = pci_cleanup_aer_uncorrect_error_status(pdev);
+	if (err) {
+		dev_err(&pdev->dev,
+			"pci_cleanup_aer_uncorrect_error_status failed 0x%0x\n",
+			 err); /* non-fatal, continue */
+	}
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * bnxt_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells
+ * us that its OK to resume normal operation.
+ */
+static void bnxt_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+
+	rtnl_lock();
+
+	netif_device_attach(netdev);
+
+	rtnl_unlock();
+}
+
+static const struct pci_error_handlers bnxt_err_handler = {
+	.error_detected	= bnxt_io_error_detected,
+	.slot_reset	= bnxt_io_slot_reset,
+	.resume		= bnxt_io_resume
+};
+
 static struct pci_driver bnxt_pci_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= bnxt_pci_tbl,
 	.probe		= bnxt_init_one,
 	.remove		= bnxt_remove_one,
+	.err_handler	= &bnxt_err_handler,
 #if defined(CONFIG_BNXT_SRIOV)
 	.sriov_configure = bnxt_sriov_configure,
 #endif
-- 
1.8.3.1
