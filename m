From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbe: ethtool correctly identify autoneg setting
Date: Thu, 22 Nov 2012 02:11:13 -0800
Message-ID: <1353579077-12097-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32084 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988Ab2KVSfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 13:35:52 -0500
In-Reply-To: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch enables ethtool to correctly identify flow control (pause
frame) auto negotiation, as well as disallow enabling it when it is not
supported. The ixgbe_device_supports_autoneg_fc function is exported and
used for this purpose.

There is also one minor cleanup of the device_supports_autoneg_fc by
removing an unnecessary return statement.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 3 ++-
 4 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 8f285ed..5af1eeb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -65,13 +65,12 @@ static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw);
  *  function check the device id to see if the associated phy supports
  *  autoneg flow control.
  **/
-static s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
+s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
 {
 
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_X540T:
 	case IXGBE_DEV_ID_X540T1:
-		return 0;
 	case IXGBE_DEV_ID_82599_T3_LOM:
 		return 0;
 	default:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 587db47..1b65b6c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -78,6 +78,7 @@ s32 ixgbe_disable_rx_buff_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_buff_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
 s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw);
+s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw);
 void ixgbe_fc_autoneg(struct ixgbe_hw *hw);
 
 s32 ixgbe_validate_mac_addr(u8 *mac_addr);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index a545728..3268584 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -383,6 +383,11 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	    (adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		return -EINVAL;
 
+	/* some devices do not support autoneg of link flow control */
+	if ((pause->autoneg == AUTONEG_ENABLE) &&
+	    (ixgbe_device_supports_autoneg_fc(hw) != 0))
+		return -EINVAL;
+
 	fc.disable_fc_autoneg = (pause->autoneg != AUTONEG_ENABLE);
 
 	if ((pause->rx_pause && pause->tx_pause) || pause->autoneg)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 004ea6c..4f67fdc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4567,7 +4567,8 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	ixgbe_pbthresh_setup(adapter);
 	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
 	hw->fc.send_xon = true;
-	hw->fc.disable_fc_autoneg = false;
+	hw->fc.disable_fc_autoneg =
+		(ixgbe_device_supports_autoneg_fc(hw) == 0) ? false : true;
 
 #ifdef CONFIG_PCI_IOV
 	/* assign number of SR-IOV VFs */
-- 
1.7.11.7
