From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbevf: Remove checking for mac.ops function pointers
Date: Thu, 15 Nov 2012 06:39:43 -0800
Message-ID: <1352990387-3872-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59047 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993466Ab2KOOjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:54 -0500
In-Reply-To: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The function pointers will always be set - there is no good reason to
check them.  Also just remove get_bus_info() call as the VF has no bus
info to report.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 56 ++++++++---------------
 1 file changed, 18 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a001684..8b8a685 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1150,9 +1150,6 @@ static int ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int err;
 
-	if (!hw->mac.ops.set_vfta)
-		return -EOPNOTSUPP;
-
 	spin_lock_bh(&adapter->mbx_lock);
 
 	/* add VID to filter table */
@@ -1181,8 +1178,7 @@ static int ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	spin_lock_bh(&adapter->mbx_lock);
 
 	/* remove VID from filter table */
-	if (hw->mac.ops.set_vfta)
-		err = hw->mac.ops.set_vfta(hw, vid, 0, false);
+	err = hw->mac.ops.set_vfta(hw, vid, 0, false);
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
@@ -1243,8 +1239,7 @@ static void ixgbevf_set_rx_mode(struct net_device *netdev)
 	spin_lock_bh(&adapter->mbx_lock);
 
 	/* reprogram multicast list */
-	if (hw->mac.ops.update_mc_addr_list)
-		hw->mac.ops.update_mc_addr_list(hw, netdev);
+	hw->mac.ops.update_mc_addr_list(hw, netdev);
 
 	ixgbevf_write_uc_addr_list(netdev);
 
@@ -1414,12 +1409,10 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 
 	spin_lock_bh(&adapter->mbx_lock);
 
-	if (hw->mac.ops.set_rar) {
-		if (is_valid_ether_addr(hw->mac.addr))
-			hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
-		else
-			hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
-	}
+	if (is_valid_ether_addr(hw->mac.addr))
+		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
+	else
+		hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
@@ -2201,6 +2194,7 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 link_speed = adapter->link_speed;
 	bool link_up = adapter->link_up;
+	s32 need_reset;
 
 	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
 
@@ -2208,29 +2202,20 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	 * Always check the link on the watchdog because we have
 	 * no LSC interrupt
 	 */
-	if (hw->mac.ops.check_link) {
-		s32 need_reset;
 
-		spin_lock_bh(&adapter->mbx_lock);
+	spin_lock_bh(&adapter->mbx_lock);
 
-		need_reset = hw->mac.ops.check_link(hw, &link_speed,
-						    &link_up, false);
+	need_reset = hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 
-		spin_unlock_bh(&adapter->mbx_lock);
+	spin_unlock_bh(&adapter->mbx_lock);
 
-		if (need_reset) {
-			adapter->link_up = link_up;
-			adapter->link_speed = link_speed;
-			netif_carrier_off(netdev);
-			netif_tx_stop_all_queues(netdev);
-			schedule_work(&adapter->reset_task);
-			goto pf_has_reset;
-		}
-	} else {
-		/* always assume link is up, if no check link
-		 * function */
-		link_speed = IXGBE_LINK_SPEED_10GB_FULL;
-		link_up = true;
+	if (need_reset) {
+		adapter->link_up = link_up;
+		adapter->link_speed = link_speed;
+		netif_carrier_off(netdev);
+		netif_tx_stop_all_queues(netdev);
+		schedule_work(&adapter->reset_task);
+		goto pf_has_reset;
 	}
 	adapter->link_up = link_up;
 	adapter->link_speed = link_speed;
@@ -3070,8 +3055,7 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 
 	spin_lock_bh(&adapter->mbx_lock);
 
-	if (hw->mac.ops.set_rar)
-		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
@@ -3396,10 +3380,6 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
-	/* pick up the PCI bus settings for reporting later */
-	if (hw->mac.ops.get_bus_info)
-		hw->mac.ops.get_bus_info(hw);
-
 	strcpy(netdev->name, "eth%d");
 
 	err = register_netdev(netdev);
-- 
1.7.11.7
