From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] ixgbevf: Add lock around mailbox ops to prevent simultaneous access
Date: Sat, 21 Jul 2012 16:08:52 -0700
Message-ID: <1342912142-11130-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11129 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645Ab2GUXJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:08 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds a spinlock around the mailbox accesses to prevent
simultaneous access to the mailboxes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   41 ++++++++++++++++++++-
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index e167d1b..66858b5 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -249,6 +249,8 @@ struct ixgbevf_adapter {
 	bool link_up;
 
 	struct work_struct watchdog_task;
+
+	spinlock_t mbx_lock;
 };
 
 enum ixbgevf_state_t {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 2dc78d7..7cb678d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1120,9 +1120,14 @@ static int ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
+	spin_lock(&adapter->mbx_lock);
+
 	/* add VID to filter table */
 	if (hw->mac.ops.set_vfta)
 		hw->mac.ops.set_vfta(hw, vid, 0, true);
+
+	spin_unlock(&adapter->mbx_lock);
+
 	set_bit(vid, adapter->active_vlans);
 
 	return 0;
@@ -1133,9 +1138,14 @@ static int ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
+	spin_lock(&adapter->mbx_lock);
+
 	/* remove VID from filter table */
 	if (hw->mac.ops.set_vfta)
 		hw->mac.ops.set_vfta(hw, vid, 0, false);
+
+	spin_unlock(&adapter->mbx_lock);
+
 	clear_bit(vid, adapter->active_vlans);
 
 	return 0;
@@ -1190,11 +1200,15 @@ static void ixgbevf_set_rx_mode(struct net_device *netdev)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
+	spin_lock(&adapter->mbx_lock);
+
 	/* reprogram multicast list */
 	if (hw->mac.ops.update_mc_addr_list)
 		hw->mac.ops.update_mc_addr_list(hw, netdev);
 
 	ixgbevf_write_uc_addr_list(netdev);
+
+	spin_unlock(&adapter->mbx_lock);
 }
 
 static void ixgbevf_napi_enable_all(struct ixgbevf_adapter *adapter)
@@ -1339,6 +1353,8 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 
 	ixgbevf_configure_msix(adapter);
 
+	spin_lock(&adapter->mbx_lock);
+
 	if (hw->mac.ops.set_rar) {
 		if (is_valid_ether_addr(hw->mac.addr))
 			hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
@@ -1350,6 +1366,8 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	msg[1] = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	hw->mbx.ops.write_posted(hw, msg, 2);
 
+	spin_unlock(&adapter->mbx_lock);
+
 	clear_bit(__IXGBEVF_DOWN, &adapter->state);
 	ixgbevf_napi_enable_all(adapter);
 
@@ -1562,11 +1580,15 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 
+	spin_lock(&adapter->mbx_lock);
+
 	if (hw->mac.ops.reset_hw(hw))
 		hw_dbg(hw, "PF still resetting\n");
 	else
 		hw->mac.ops.init_hw(hw);
 
+	spin_unlock(&adapter->mbx_lock);
+
 	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
 		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
 		       netdev->addr_len);
@@ -1893,6 +1915,9 @@ static int __devinit ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 			adapter->netdev->addr_len);
 	}
 
+	/* lock to protect mailbox accesses */
+	spin_lock_init(&adapter->mbx_lock);
+
 	/* Enable dynamic interrupt throttling rates */
 	adapter->rx_itr_setting = 1;
 	adapter->tx_itr_setting = 1;
@@ -2032,8 +2057,16 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	 * no LSC interrupt
 	 */
 	if (hw->mac.ops.check_link) {
-		if ((hw->mac.ops.check_link(hw, &link_speed,
-					    &link_up, false)) != 0) {
+		s32 need_reset;
+
+		spin_lock(&adapter->mbx_lock);
+
+		need_reset = hw->mac.ops.check_link(hw, &link_speed,
+						    &link_up, false);
+
+		spin_unlock(&adapter->mbx_lock);
+
+		if (need_reset) {
 			adapter->link_up = link_up;
 			adapter->link_speed = link_speed;
 			netif_carrier_off(netdev);
@@ -2813,9 +2846,13 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
+	spin_lock(&adapter->mbx_lock);
+
 	if (hw->mac.ops.set_rar)
 		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
 
+	spin_unlock(&adapter->mbx_lock);
+
 	return 0;
 }
 
-- 
1.7.10.4
