From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 18/29] fm10k: Add support for PCI power management
 and error handling
Date: Thu, 18 Sep 2014 18:38:38 -0400
Message-ID: <20140918223831.10373.21683.stgit@ahduyck-bv4.jf.intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7394 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756630AbaIRWrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 18:47:19 -0400
In-Reply-To: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PCI power management and error handling to allow the device to support
suspend/resume and recovery of any PCIe errors.  The fm10k devices do not
support wake on LAN, and there is no plan to add this as a feature.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c |  221 ++++++++++++++++++++++++++
 1 file changed, 221 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 4e21ddd..9b97da7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -19,6 +19,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/aer.h>
 
 #include "fm10k.h"
 
@@ -1534,6 +1535,8 @@ static int fm10k_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 	}
 
+	pci_enable_pcie_error_reporting(pdev);
+
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
@@ -1660,14 +1663,232 @@ static void fm10k_remove(struct pci_dev *pdev)
 	pci_release_selected_regions(pdev,
 				     pci_select_bars(pdev, IORESOURCE_MEM));
 
+	pci_disable_pcie_error_reporting(pdev);
+
 	pci_disable_device(pdev);
 }
 
+#ifdef CONFIG_PM
+/**
+ * fm10k_resume - Restore device to pre-sleep state
+ * @pdev: PCI device information struct
+ *
+ * fm10k_resume is called after the system has powered back up from a sleep
+ * state and is ready to resume operation.  This function is meant to restore
+ * the device back to its pre-sleep state.
+ **/
+static int fm10k_resume(struct pci_dev *pdev)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	struct net_device *netdev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	u32 err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	/* pci_restore_state clears dev->state_saved so call
+	 * pci_save_state to restore it.
+	 */
+	pci_save_state(pdev);
+
+	err = pci_enable_device_mem(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot enable PCI device from suspend\n");
+		return err;
+	}
+	pci_set_master(pdev);
+
+	pci_wake_from_d3(pdev, false);
+
+	/* refresh hw_addr in case it was dropped */
+	hw->hw_addr = interface->uc_addr;
+
+	/* reset hardware to known state */
+	err = hw->mac.ops.init_hw(&interface->hw);
+	if (err)
+		return err;
+
+	/* reset statistics starting values */
+	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
+
+	rtnl_lock();
+
+	err = fm10k_init_queueing_scheme(interface);
+	if (!err) {
+		fm10k_mbx_request_irq(interface);
+		if (netif_running(netdev))
+			err = fm10k_open(netdev);
+	}
+
+	rtnl_unlock();
+
+	if (err)
+		return err;
+
+	netif_device_attach(netdev);
+
+	return 0;
+}
+
+/**
+ * fm10k_suspend - Prepare the device for a system sleep state
+ * @pdev: PCI device information struct
+ *
+ * fm10k_suspend is meant to shutdown the device prior to the system entering
+ * a sleep state.  The fm10k hardware does not support wake on lan so the
+ * driver simply needs to shut down the device so it is in a low power state.
+ **/
+static int fm10k_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	struct net_device *netdev = interface->netdev;
+	int err = 0;
+
+	netif_device_detach(netdev);
+
+	rtnl_lock();
+
+	if (netif_running(netdev))
+		fm10k_close(netdev);
+
+	fm10k_mbx_free_irq(interface);
+
+	fm10k_clear_queueing_scheme(interface);
+
+	rtnl_unlock();
+
+	err = pci_save_state(pdev);
+	if (err)
+		return err;
+
+	pci_disable_device(pdev);
+	pci_wake_from_d3(pdev, false);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
+}
+
+#endif /* CONFIG_PM */
+/**
+ * fm10k_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t fm10k_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	struct net_device *netdev = interface->netdev;
+
+	netif_device_detach(netdev);
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	if (netif_running(netdev))
+		fm10k_close(netdev);
+
+	fm10k_mbx_free_irq(interface);
+
+	pci_disable_device(pdev);
+
+	/* Request a slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * fm10k_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ */
+static pci_ers_result_t fm10k_io_slot_reset(struct pci_dev *pdev)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	pci_ers_result_t result;
+
+	if (pci_enable_device_mem(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
+		result = PCI_ERS_RESULT_DISCONNECT;
+	} else {
+		pci_set_master(pdev);
+		pci_restore_state(pdev);
+
+		/* After second error pci->state_saved is false, this
+		 * resets it so EEH doesn't break.
+		 */
+		pci_save_state(pdev);
+
+		pci_wake_from_d3(pdev, false);
+
+		/* refresh hw_addr in case it was dropped */
+		interface->hw.hw_addr = interface->uc_addr;
+
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+		fm10k_service_event_schedule(interface);
+
+		result = PCI_ERS_RESULT_RECOVERED;
+	}
+
+	pci_cleanup_aer_uncorrect_error_status(pdev);
+
+	return result;
+}
+
+/**
+ * fm10k_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation.
+ */
+static void fm10k_io_resume(struct pci_dev *pdev)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	struct net_device *netdev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	int err = 0;
+
+	/* reset hardware to known state */
+	hw->mac.ops.init_hw(&interface->hw);
+
+	/* reset statistics starting values */
+	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
+
+	/* reassociate interrupts */
+	fm10k_mbx_request_irq(interface);
+
+	if (netif_running(netdev))
+		err = fm10k_open(netdev);
+
+	/* final check of hardware state before registering the interface */
+	err = err ? : fm10k_hw_ready(interface);
+
+	if (!err)
+		netif_device_attach(netdev);
+}
+
+static const struct pci_error_handlers fm10k_err_handler = {
+	.error_detected = fm10k_io_error_detected,
+	.slot_reset = fm10k_io_slot_reset,
+	.resume = fm10k_io_resume,
+};
+
 static struct pci_driver fm10k_driver = {
 	.name			= fm10k_driver_name,
 	.id_table		= fm10k_pci_tbl,
 	.probe			= fm10k_probe,
 	.remove			= fm10k_remove,
+#ifdef CONFIG_PM
+	.suspend		= fm10k_suspend,
+	.resume			= fm10k_resume,
+#endif
+	.err_handler		= &fm10k_err_handler
 };
 
 /**
