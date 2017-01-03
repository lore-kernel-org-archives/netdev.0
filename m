From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/21] ixgbevf: fix AER error handling
Date: Tue,  3 Jan 2017 13:07:48 -0800
Message-ID: <20170103210757.38847-13-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3461 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966317AbdACVIP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:15 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Make sure that we free the IRQs in ixgbevf_io_error_detected() when
responding to an PCIe AER error and also restore them when the
interface recovers from it.

Previously it was possible to trigger BUG_ON() check in free_msix_irqs()
in the case where we call ixgbevf_remove() after a failed recovery from
AER error because the interrupts were not freed.

Also moved the down and free functions into ixgbevf_close_suspend()
same as with ixgbe.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 43 +++++++++++++----------
 1 file changed, 25 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 8574f21..a78e490 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3228,6 +3228,21 @@ int ixgbevf_open(struct net_device *netdev)
 }
 
 /**
+ * ixgbevf_close_suspend - actions necessary to both suspend and close flows
+ * @adapter: the private adapter struct
+ *
+ * This function should contain the necessary work common to both suspending
+ * and closing of the device.
+ */
+static void ixgbevf_close_suspend(struct ixgbevf_adapter *adapter)
+{
+	ixgbevf_down(adapter);
+	ixgbevf_free_irq(adapter);
+	ixgbevf_free_all_tx_resources(adapter);
+	ixgbevf_free_all_rx_resources(adapter);
+}
+
+/**
  * ixgbevf_close - Disables a network interface
  * @netdev: network interface device structure
  *
@@ -3242,14 +3257,8 @@ int ixgbevf_close(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
-	if (!netif_device_present(netdev))
-		return 0;
-
-	ixgbevf_down(adapter);
-	ixgbevf_free_irq(adapter);
-
-	ixgbevf_free_all_tx_resources(adapter);
-	ixgbevf_free_all_rx_resources(adapter);
+	if (netif_device_present(netdev))
+		ixgbevf_close_suspend(adapter);
 
 	return 0;
 }
@@ -3806,13 +3815,10 @@ static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
 	rtnl_lock();
 	netif_device_detach(netdev);
 
-	if (netif_running(netdev)) {
-		ixgbevf_down(adapter);
-		ixgbevf_free_irq(adapter);
-		ixgbevf_free_all_tx_resources(adapter);
-		ixgbevf_free_all_rx_resources(adapter);
-		ixgbevf_clear_interrupt_scheme(adapter);
-	}
+	if (netif_running(netdev))
+		ixgbevf_close_suspend(adapter);
+
+	ixgbevf_clear_interrupt_scheme(adapter);
 	rtnl_unlock();
 
 #ifdef CONFIG_PM
@@ -4251,7 +4257,7 @@ static pci_ers_result_t ixgbevf_io_error_detected(struct pci_dev *pdev,
 	}
 
 	if (netif_running(netdev))
-		ixgbevf_down(adapter);
+		ixgbevf_close_suspend(adapter);
 
 	if (!test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state))
 		pci_disable_device(pdev);
@@ -4299,12 +4305,13 @@ static pci_ers_result_t ixgbevf_io_slot_reset(struct pci_dev *pdev)
 static void ixgbevf_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
+	rtnl_lock();
 	if (netif_running(netdev))
-		ixgbevf_up(adapter);
+		ixgbevf_open(netdev);
 
 	netif_device_attach(netdev);
+	rtnl_unlock();
 }
 
 /* PCI Error Recovery (ERS) */
-- 
2.9.3
