From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/15] ixgbe: fix fc autoneg ethtool reporting.
Date: Wed, 31 Jul 2013 02:59:25 -0700
Message-ID: <1375264777-13595-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43699 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755458Ab3GaJ7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 05:59:43 -0400
In-Reply-To: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Originally ixgbe_device_supports_autoneg_fc() was only expected to
be called by copper devices.  This would lead to false information
to be displayed via ethtool.

v2: changed ixgbe_device_supports_autoneg_fc() to a bool function,
    it returns bool.  Based on feedback from David Miller

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 42 +++++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  9 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  3 +-
 4 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 9bcdeb8..ddbc3ee 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -65,17 +65,41 @@ static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw);
  *  function check the device id to see if the associated phy supports
  *  autoneg flow control.
  **/
-s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
+bool ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
 {
+	bool supported = false;
+	ixgbe_link_speed speed;
+	bool link_up;
 
-	switch (hw->device_id) {
-	case IXGBE_DEV_ID_X540T:
-	case IXGBE_DEV_ID_X540T1:
-	case IXGBE_DEV_ID_82599_T3_LOM:
-		return 0;
+	switch (hw->phy.media_type) {
+	case ixgbe_media_type_fiber:
+		hw->mac.ops.check_link(hw, &speed, &link_up, false);
+		/* if link is down, assume supported */
+		if (link_up)
+			supported = speed == IXGBE_LINK_SPEED_1GB_FULL ?
+				true : false;
+		else
+			supported = true;
+		break;
+	case ixgbe_media_type_backplane:
+		supported = true;
+		break;
+	case ixgbe_media_type_copper:
+		/* only some copper devices support flow control autoneg */
+		switch (hw->device_id) {
+		case IXGBE_DEV_ID_82599_T3_LOM:
+		case IXGBE_DEV_ID_X540T:
+		case IXGBE_DEV_ID_X540T1:
+			supported = true;
+			break;
+		default:
+			break;
+		}
 	default:
-		return IXGBE_ERR_FC_NOT_SUPPORTED;
+		break;
 	}
+
+	return supported;
 }
 
 /**
@@ -234,7 +258,7 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw)
 						      IXGBE_GSSR_MAC_CSR_SM);
 
 	} else if ((hw->phy.media_type == ixgbe_media_type_copper) &&
-		    (ixgbe_device_supports_autoneg_fc(hw) == 0)) {
+		    ixgbe_device_supports_autoneg_fc(hw)) {
 		hw->phy.ops.write_reg(hw, MDIO_AN_ADVERTISE,
 				      MDIO_MMD_AN, reg_cu);
 	}
@@ -2392,7 +2416,7 @@ void ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 
 	/* Autoneg flow control on copper adapters */
 	case ixgbe_media_type_copper:
-		if (ixgbe_device_supports_autoneg_fc(hw) == 0)
+		if (ixgbe_device_supports_autoneg_fc(hw))
 			ret_val = ixgbe_fc_autoneg_copper(hw);
 		break;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 22eee38..1315b8a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -80,7 +80,7 @@ s32 ixgbe_disable_rx_buff_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_buff_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
 s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw);
-s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw);
+bool ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw);
 void ixgbe_fc_autoneg(struct ixgbe_hw *hw);
 
 s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 24e2e7a..ae58a92 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -355,10 +355,11 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (hw->fc.disable_fc_autoneg)
-		pause->autoneg = 0;
-	else
+	if (ixgbe_device_supports_autoneg_fc(hw) &&
+	    !hw->fc.disable_fc_autoneg)
 		pause->autoneg = 1;
+	else
+		pause->autoneg = 0;
 
 	if (hw->fc.current_mode == ixgbe_fc_rx_pause) {
 		pause->rx_pause = 1;
@@ -384,7 +385,7 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 
 	/* some devices do not support autoneg of link flow control */
 	if ((pause->autoneg == AUTONEG_ENABLE) &&
-	    (ixgbe_device_supports_autoneg_fc(hw) != 0))
+	    !ixgbe_device_supports_autoneg_fc(hw))
 		return -EINVAL;
 
 	fc.disable_fc_autoneg = (pause->autoneg != AUTONEG_ENABLE);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d837f81..531ee44 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4721,8 +4721,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	ixgbe_pbthresh_setup(adapter);
 	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
 	hw->fc.send_xon = true;
-	hw->fc.disable_fc_autoneg =
-		(ixgbe_device_supports_autoneg_fc(hw) == 0) ? false : true;
+	hw->fc.disable_fc_autoneg = ixgbe_device_supports_autoneg_fc(hw);
 
 #ifdef CONFIG_PCI_IOV
 	/* assign number of SR-IOV VFs */
-- 
1.7.11.7
