From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/20] fm10k: implement reset_notify handler for PCIe FLR events
Date: Wed, 20 Jul 2016 15:23:51 -0700
Message-ID: <1469053438-85381-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755391AbcGTWYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:05 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When a function level PCI reset is triggered using sysfs, it calls the
driver's .reset_notify error handler. Implement a handler based on the
now split fm10k_prepare_for_reset and fm10k_handle_reset functions, so
that we fully reset the driver when the PCI function level reset occurs.
This also ensures the reset is handled in a clean way by first disabling
all the driver bits first and then restoring them after the function
reset. Previously the stack simply performed a blind function reset and
our driver didn't take any part in the process.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 33 ++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 716a5c8..c60c3b0 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2373,10 +2373,43 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 		netif_device_attach(netdev);
 }
 
+/**
+ * fm10k_io_reset_notify - called when PCI function is reset
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the PCI function is reset such as from
+ * /sys/class/net/<enpX>/device/reset or similar. When prepare is true, it
+ * means we should prepare for a function reset. If prepare is false, it means
+ * the function reset just occurred.
+ */
+static void fm10k_io_reset_notify(struct pci_dev *pdev, bool prepare)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	int err = 0;
+
+	if (prepare) {
+		/* warn incase we have any active VF devices */
+		if (pci_num_vf(pdev))
+			dev_warn(&pdev->dev,
+				 "PCIe FLR may cause issues for any active VF devices\n");
+
+		fm10k_prepare_suspend(interface);
+	} else {
+		err = fm10k_handle_resume(interface);
+	}
+
+	if (err) {
+		dev_warn(&pdev->dev,
+			 "fm10k_io_reset_notify failed: %d\n", err);
+		netif_device_detach(interface->netdev);
+	}
+}
+
 static const struct pci_error_handlers fm10k_err_handler = {
 	.error_detected = fm10k_io_error_detected,
 	.slot_reset = fm10k_io_slot_reset,
 	.resume = fm10k_io_resume,
+	.reset_notify = fm10k_io_reset_notify,
 };
 
 static struct pci_driver fm10k_driver = {
-- 
2.5.5
