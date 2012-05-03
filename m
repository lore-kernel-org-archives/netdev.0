From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbevf: Make sure jumbo frames are set correctly after PF reset
Date: Thu,  3 May 2012 02:56:31 -0700
Message-ID: <1336038992-3144-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49879 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754995Ab2ECJ4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:37 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If the Physical Function (PF) resets after the VF has set jumbo
frame MTU then the VF jumbo frame is overwritten.  Make sure the
VF driver always requests proper MTU size after reset
synchronization.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   28 ++++++++++----------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index dfed420..0a1b992 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -287,7 +287,7 @@ extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
 extern const char ixgbevf_driver_name[];
 extern const char ixgbevf_driver_version[];
 
-extern int ixgbevf_up(struct ixgbevf_adapter *adapter);
+extern void ixgbevf_up(struct ixgbevf_adapter *adapter);
 extern void ixgbevf_down(struct ixgbevf_adapter *adapter);
 extern void ixgbevf_reinit_locked(struct ixgbevf_adapter *adapter);
 extern void ixgbevf_reset(struct ixgbevf_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 307611a..5a0e228 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1608,13 +1608,14 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
 	adapter->stats.base_vfmprc = adapter->stats.last_vfmprc;
 }
 
-static int ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
+static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i, j = 0;
 	int num_rx_rings = adapter->num_rx_queues;
 	u32 txdctl, rxdctl;
+	u32 msg[2];
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		j = adapter->tx_ring[i].reg_idx;
@@ -1653,6 +1654,10 @@ static int ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 			hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
 	}
 
+	msg[0] = IXGBE_VF_SET_LPE;
+	msg[1] = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	hw->mbx.ops.write_posted(hw, msg, 2);
+
 	clear_bit(__IXGBEVF_DOWN, &adapter->state);
 	ixgbevf_napi_enable_all(adapter);
 
@@ -1667,24 +1672,20 @@ static int ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
 	adapter->link_check_timeout = jiffies;
 	mod_timer(&adapter->watchdog_timer, jiffies);
-	return 0;
 }
 
-int ixgbevf_up(struct ixgbevf_adapter *adapter)
+void ixgbevf_up(struct ixgbevf_adapter *adapter)
 {
-	int err;
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	ixgbevf_configure(adapter);
 
-	err = ixgbevf_up_complete(adapter);
+	ixgbevf_up_complete(adapter);
 
 	/* clear any pending interrupts, may auto mask */
 	IXGBE_READ_REG(hw, IXGBE_VTEICR);
 
 	ixgbevf_irq_enable(adapter, true, true);
-
-	return err;
 }
 
 /**
@@ -2673,9 +2674,7 @@ static int ixgbevf_open(struct net_device *netdev)
 	 */
 	ixgbevf_map_rings_to_vectors(adapter);
 
-	err = ixgbevf_up_complete(adapter);
-	if (err)
-		goto err_up;
+	ixgbevf_up_complete(adapter);
 
 	/* clear any pending interrupts, may auto mask */
 	IXGBE_READ_REG(hw, IXGBE_VTEICR);
@@ -2689,7 +2688,6 @@ static int ixgbevf_open(struct net_device *netdev)
 
 err_req_irq:
 	ixgbevf_down(adapter);
-err_up:
 	ixgbevf_free_irq(adapter);
 err_setup_rx:
 	ixgbevf_free_all_rx_resources(adapter);
@@ -3196,9 +3194,11 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
-	msg[0] = IXGBE_VF_SET_LPE;
-	msg[1] = max_frame;
-	hw->mbx.ops.write_posted(hw, msg, 2);
+	if (!netif_running(netdev)) {
+		msg[0] = IXGBE_VF_SET_LPE;
+		msg[1] = max_frame;
+		hw->mbx.ops.write_posted(hw, msg, 2);
+	}
 
 	if (netif_running(netdev))
 		ixgbevf_reinit_locked(adapter);
-- 
1.7.7.6
