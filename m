From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 03/13] ixgbevf: Add bit to mark work queue initialization
Date: Fri, 11 Apr 2014 06:52:53 -0700
Message-ID: <1397224383-19269-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47069 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757654AbaDKNxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 09:53:10 -0400
In-Reply-To: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

An indication of work queue initialization is needed. This is
because register accesses prior to that time can detect a removal
and attempt to schedule the watchdog task. Adding the
__IXGBEVF_WORK_INIT bit allows this to be checked and if not
set prevent the watchdog task scheduling. By checking for a
removal right after initialization, the probe can be failed
at that point without getting the watchdog task involved.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 11 ++++++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index e7e7d69..a0a1de9 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -421,6 +421,7 @@ enum ixbgevf_state_t {
 	__IXGBEVF_DOWN,
 	__IXGBEVF_DISABLED,
 	__IXGBEVF_REMOVING,
+	__IXGBEVF_WORK_INIT,
 };
 
 struct ixgbevf_cb {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 4ba139b..905c26c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -107,7 +107,8 @@ static void ixgbevf_remove_adapter(struct ixgbe_hw *hw)
 		return;
 	hw->hw_addr = NULL;
 	dev_err(&adapter->pdev->dev, "Adapter removed\n");
-	schedule_work(&adapter->watchdog_task);
+	if (test_bit(__IXGBEVF_WORK_INIT, &adapter->state))
+		schedule_work(&adapter->watchdog_task);
 }
 
 static void ixgbevf_check_remove(struct ixgbe_hw *hw, u32 reg)
@@ -3573,8 +3574,13 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->watchdog_timer.function = ixgbevf_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 
+	if (IXGBE_REMOVED(hw->hw_addr)) {
+		err = -EIO;
+		goto err_sw_init;
+	}
 	INIT_WORK(&adapter->reset_task, ixgbevf_reset_task);
 	INIT_WORK(&adapter->watchdog_task, ixgbevf_watchdog_task);
+	set_bit(__IXGBEVF_WORK_INIT, &adapter->state);
 
 	err = ixgbevf_init_interrupt_scheme(adapter);
 	if (err)
@@ -3667,6 +3673,9 @@ static pci_ers_result_t ixgbevf_io_error_detected(struct pci_dev *pdev,
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
+	if (!test_bit(__IXGBEVF_WORK_INIT, &adapter->state))
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	rtnl_lock();
 	netif_device_detach(netdev);
 
-- 
1.9.0
