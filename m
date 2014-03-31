From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] ixgbe: Fix rcu warnings induced by LER
Date: Mon, 31 Mar 2014 16:34:58 -0700
Message-ID: <1396308899-20926-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34702 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735AbaCaXga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:30 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Resolve some rcu warnings produced when LER actions take place.
This appears to be due to not holding the rtnl lock when calling
ixgbe_down, so hold the lock. Also avoid disabling the device
when it is already disabled. This check is necessary because the
callback can be called more than once in some cases.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 23 ++++++++++++++++++-----
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 26d27aa..55c53a1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -808,6 +808,7 @@ enum ixgbe_state_t {
 	__IXGBE_TESTING,
 	__IXGBE_RESETTING,
 	__IXGBE_DOWN,
+	__IXGBE_DISABLED,
 	__IXGBE_REMOVING,
 	__IXGBE_SERVICE_SCHED,
 	__IXGBE_IN_SFP_INIT,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c4b930c..8436c65 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5566,6 +5566,8 @@ static int ixgbe_resume(struct pci_dev *pdev)
 		e_dev_err("Cannot enable PCI device from suspend\n");
 		return err;
 	}
+	smp_mb__before_clear_bit();
+	clear_bit(__IXGBE_DISABLED, &adapter->state);
 	pci_set_master(pdev);
 
 	pci_wake_from_d3(pdev, false);
@@ -5663,7 +5665,8 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 	ixgbe_release_hw_control(adapter);
 
-	pci_disable_device(pdev);
+	if (!test_and_set_bit(__IXGBE_DISABLED, &adapter->state))
+		pci_disable_device(pdev);
 
 	return 0;
 }
@@ -8313,7 +8316,8 @@ err_alloc_etherdev:
 				     pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:
 err_dma:
-	pci_disable_device(pdev);
+	if (!test_and_set_bit(__IXGBE_DISABLED, &adapter->state))
+		pci_disable_device(pdev);
 	return err;
 }
 
@@ -8382,7 +8386,8 @@ static void ixgbe_remove(struct pci_dev *pdev)
 
 	pci_disable_pcie_error_reporting(pdev);
 
-	pci_disable_device(pdev);
+	if (!test_and_set_bit(__IXGBE_DISABLED, &adapter->state))
+		pci_disable_device(pdev);
 }
 
 /**
@@ -8489,14 +8494,20 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 
 skip_bad_vf_detection:
 #endif /* CONFIG_PCI_IOV */
+	rtnl_lock();
 	netif_device_detach(netdev);
 
-	if (state == pci_channel_io_perm_failure)
+	if (state == pci_channel_io_perm_failure) {
+		rtnl_unlock();
 		return PCI_ERS_RESULT_DISCONNECT;
+	}
 
 	if (netif_running(netdev))
 		ixgbe_down(adapter);
-	pci_disable_device(pdev);
+
+	if (!test_and_set_bit(__IXGBE_DISABLED, &adapter->state))
+		pci_disable_device(pdev);
+	rtnl_unlock();
 
 	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
@@ -8518,6 +8529,8 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 		e_err(probe, "Cannot re-enable PCI device after reset.\n");
 		result = PCI_ERS_RESULT_DISCONNECT;
 	} else {
+		smp_mb__before_clear_bit();
+		clear_bit(__IXGBE_DISABLED, &adapter->state);
 		adapter->hw.hw_addr = adapter->io_addr;
 		pci_set_master(pdev);
 		pci_restore_state(pdev);
-- 
1.9.0
