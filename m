From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  4/9] ixgbevf: move API neg to reset path
Date: Tue,  1 Oct 2013 04:33:51 -0700
Message-ID: <1380627236-3190-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46701 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834Ab3JALeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:34:01 -0400
In-Reply-To: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

After this patch the API negotiation will occur in the reset path.  So now
the PF will be informed of the API version earlier.  This will also require
the mailbox lock to be initialize sooner as well.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index e3493b0..ce27d62 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1544,8 +1544,6 @@ void ixgbevf_up(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	ixgbevf_negotiate_api(adapter);
-
 	ixgbevf_reset_queues(adapter);
 
 	ixgbevf_configure(adapter);
@@ -1735,10 +1733,12 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 
-	if (hw->mac.ops.reset_hw(hw))
+	if (hw->mac.ops.reset_hw(hw)) {
 		hw_dbg(hw, "PF still resetting\n");
-	else
+	} else {
 		hw->mac.ops.init_hw(hw);
+		ixgbevf_negotiate_api(adapter);
+	}
 
 	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
 		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
@@ -2074,6 +2074,9 @@ static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 	hw->mac.max_tx_queues = 2;
 	hw->mac.max_rx_queues = 2;
 
+	/* lock to protect mailbox accesses */
+	spin_lock_init(&adapter->mbx_lock);
+
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
 		dev_info(&pdev->dev,
@@ -2084,6 +2087,7 @@ static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 			pr_err("init_shared_code failed: %d\n", err);
 			goto out;
 		}
+		ixgbevf_negotiate_api(adapter);
 		err = hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
 		if (err)
 			dev_info(&pdev->dev, "Error reading MAC address\n");
@@ -2099,9 +2103,6 @@ static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 		memcpy(hw->mac.addr, netdev->dev_addr, netdev->addr_len);
 	}
 
-	/* lock to protect mailbox accesses */
-	spin_lock_init(&adapter->mbx_lock);
-
 	/* Enable dynamic interrupt throttling rates */
 	adapter->rx_itr_setting = 1;
 	adapter->tx_itr_setting = 1;
@@ -2622,8 +2623,6 @@ static int ixgbevf_open(struct net_device *netdev)
 		}
 	}
 
-	ixgbevf_negotiate_api(adapter);
-
 	/* setup queue reg_idx and Rx queue count */
 	err = ixgbevf_setup_queues(adapter);
 	if (err)
@@ -3218,6 +3217,8 @@ static int ixgbevf_resume(struct pci_dev *pdev)
 	}
 	pci_set_master(pdev);
 
+	ixgbevf_reset(adapter);
+
 	rtnl_lock();
 	err = ixgbevf_init_interrupt_scheme(adapter);
 	rtnl_unlock();
@@ -3226,8 +3227,6 @@ static int ixgbevf_resume(struct pci_dev *pdev)
 		return err;
 	}
 
-	ixgbevf_reset(adapter);
-
 	if (netif_running(netdev)) {
 		err = ixgbevf_open(netdev);
 		if (err)
-- 
1.8.3.1
