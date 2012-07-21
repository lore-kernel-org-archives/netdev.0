From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] ixgbevf: Add support for PCI error handling
Date: Sat, 21 Jul 2012 16:08:53 -0700
Message-ID: <1342912142-11130-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:54382 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680Ab2GUXJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:08 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds support for handling IO errors and slot resets.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   80 +++++++++++++++++++++
 1 file changed, 80 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 7cb678d..ccc801e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3189,12 +3189,92 @@ static void __devexit ixgbevf_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
+/**
+ * ixgbevf_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t ixgbevf_io_error_detected(struct pci_dev *pdev,
+						  pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+
+	netif_device_detach(netdev);
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	if (netif_running(netdev))
+		ixgbevf_down(adapter);
+
+	pci_disable_device(pdev);
+
+	/* Request a slot slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * ixgbevf_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot. Implementation
+ * resembles the first-half of the ixgbevf_resume routine.
+ */
+static pci_ers_result_t ixgbevf_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+
+	if (pci_enable_device_mem(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	pci_set_master(pdev);
+
+	ixgbevf_reset(adapter);
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * ixgbevf_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation. Implementation resembles the
+ * second-half of the ixgbevf_resume routine.
+ */
+static void ixgbevf_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+
+	if (netif_running(netdev))
+		ixgbevf_up(adapter);
+
+	netif_device_attach(netdev);
+}
+
+/* PCI Error Recovery (ERS) */
+static struct pci_error_handlers ixgbevf_err_handler = {
+	.error_detected = ixgbevf_io_error_detected,
+	.slot_reset = ixgbevf_io_slot_reset,
+	.resume = ixgbevf_io_resume,
+};
+
 static struct pci_driver ixgbevf_driver = {
 	.name     = ixgbevf_driver_name,
 	.id_table = ixgbevf_pci_tbl,
 	.probe    = ixgbevf_probe,
 	.remove   = __devexit_p(ixgbevf_remove),
 	.shutdown = ixgbevf_shutdown,
+	.err_handler = &ixgbevf_err_handler
 };
 
 /**
-- 
1.7.10.4
