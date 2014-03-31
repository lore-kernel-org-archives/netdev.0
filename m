From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] ixgbevf: Fix rcu warnings induced by LER
Date: Mon, 31 Mar 2014 16:34:59 -0700
Message-ID: <1396308899-20926-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34702 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbaCaXgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:31 -0400
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
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 22 +++++++++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index a08bd7c..e7e7d69 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -419,6 +419,7 @@ enum ixbgevf_state_t {
 	__IXGBEVF_TESTING,
 	__IXGBEVF_RESETTING,
 	__IXGBEVF_DOWN,
+	__IXGBEVF_DISABLED,
 	__IXGBEVF_REMOVING,
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 5d93759..4ba139b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3329,7 +3329,8 @@ static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
 		return retval;
 
 #endif
-	pci_disable_device(pdev);
+	if (!test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state))
+		pci_disable_device(pdev);
 
 	return 0;
 }
@@ -3353,6 +3354,8 @@ static int ixgbevf_resume(struct pci_dev *pdev)
 		dev_err(&pdev->dev, "Cannot enable PCI device from suspend\n");
 		return err;
 	}
+	smp_mb__before_clear_bit();
+	clear_bit(__IXGBEVF_DISABLED, &adapter->state);
 	pci_set_master(pdev);
 
 	ixgbevf_reset(adapter);
@@ -3607,7 +3610,8 @@ err_alloc_etherdev:
 	pci_release_regions(pdev);
 err_pci_reg:
 err_dma:
-	pci_disable_device(pdev);
+	if (!test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state))
+		pci_disable_device(pdev);
 	return err;
 }
 
@@ -3645,7 +3649,8 @@ static void ixgbevf_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
-	pci_disable_device(pdev);
+	if (!test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state))
+		pci_disable_device(pdev);
 }
 
 /**
@@ -3662,15 +3667,20 @@ static pci_ers_result_t ixgbevf_io_error_detected(struct pci_dev *pdev,
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
+	rtnl_lock();
 	netif_device_detach(netdev);
 
-	if (state == pci_channel_io_perm_failure)
+	if (state == pci_channel_io_perm_failure) {
+		rtnl_unlock();
 		return PCI_ERS_RESULT_DISCONNECT;
+	}
 
 	if (netif_running(netdev))
 		ixgbevf_down(adapter);
 
-	pci_disable_device(pdev);
+	if (!test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state))
+		pci_disable_device(pdev);
+	rtnl_unlock();
 
 	/* Request a slot slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
@@ -3694,6 +3704,8 @@ static pci_ers_result_t ixgbevf_io_slot_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
+	smp_mb__before_clear_bit();
+	clear_bit(__IXGBEVF_DISABLED, &adapter->state);
 	pci_set_master(pdev);
 
 	ixgbevf_reset(adapter);
-- 
1.9.0
