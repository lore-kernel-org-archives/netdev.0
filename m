From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: intel: igb: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  5 Feb 2017 18:55:44 +0100
Message-ID: <1486317344-20271-1-git-send-email-tremyfr@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32834 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdBERzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 12:55:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  108 ++++++++++++++------------
 1 files changed, 59 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 737b664..3e6281a 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -144,7 +144,8 @@ enum igb_diagnostics_results {
 };
 #define IGB_TEST_LEN (sizeof(igb_gstrings_test) / ETH_GSTRING_LEN)
 
-static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int igb_get_link_ksettings(struct net_device *netdev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -152,11 +153,12 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	struct e1000_sfp_flags *eth_flags = &dev_spec->eth_flags;
 	u32 status;
 	u32 speed;
+	u32 supported, advertising;
 
 	status = rd32(E1000_STATUS);
 	if (hw->phy.media_type == e1000_media_type_copper) {
 
-		ecmd->supported = (SUPPORTED_10baseT_Half |
+		supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
 				   SUPPORTED_100baseT_Half |
 				   SUPPORTED_100baseT_Full |
@@ -164,63 +166,61 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 				   SUPPORTED_Autoneg |
 				   SUPPORTED_TP |
 				   SUPPORTED_Pause);
-		ecmd->advertising = ADVERTISED_TP;
+		advertising = ADVERTISED_TP;
 
 		if (hw->mac.autoneg == 1) {
-			ecmd->advertising |= ADVERTISED_Autoneg;
+			advertising |= ADVERTISED_Autoneg;
 			/* the e1000 autoneg seems to match ethtool nicely */
-			ecmd->advertising |= hw->phy.autoneg_advertised;
+			advertising |= hw->phy.autoneg_advertised;
 		}
 
-		ecmd->port = PORT_TP;
-		ecmd->phy_address = hw->phy.addr;
-		ecmd->transceiver = XCVR_INTERNAL;
+		cmd->base.port = PORT_TP;
+		cmd->base.phy_address = hw->phy.addr;
 	} else {
-		ecmd->supported = (SUPPORTED_FIBRE |
+		supported = (SUPPORTED_FIBRE |
 				   SUPPORTED_1000baseKX_Full |
 				   SUPPORTED_Autoneg |
 				   SUPPORTED_Pause);
-		ecmd->advertising = (ADVERTISED_FIBRE |
+		advertising = (ADVERTISED_FIBRE |
 				     ADVERTISED_1000baseKX_Full);
 		if (hw->mac.type == e1000_i354) {
 			if ((hw->device_id ==
 			     E1000_DEV_ID_I354_BACKPLANE_2_5GBPS) &&
 			    !(status & E1000_STATUS_2P5_SKU_OVER)) {
-				ecmd->supported |= SUPPORTED_2500baseX_Full;
-				ecmd->supported &=
+				supported |= SUPPORTED_2500baseX_Full;
+				supported &=
 					~SUPPORTED_1000baseKX_Full;
-				ecmd->advertising |= ADVERTISED_2500baseX_Full;
-				ecmd->advertising &=
+				advertising |= ADVERTISED_2500baseX_Full;
+				advertising &=
 					~ADVERTISED_1000baseKX_Full;
 			}
 		}
 		if (eth_flags->e100_base_fx) {
-			ecmd->supported |= SUPPORTED_100baseT_Full;
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
+			supported |= SUPPORTED_100baseT_Full;
+			advertising |= ADVERTISED_100baseT_Full;
 		}
 		if (hw->mac.autoneg == 1)
-			ecmd->advertising |= ADVERTISED_Autoneg;
+			advertising |= ADVERTISED_Autoneg;
 
-		ecmd->port = PORT_FIBRE;
-		ecmd->transceiver = XCVR_EXTERNAL;
+		cmd->base.port = PORT_FIBRE;
 	}
 	if (hw->mac.autoneg != 1)
-		ecmd->advertising &= ~(ADVERTISED_Pause |
+		advertising &= ~(ADVERTISED_Pause |
 				       ADVERTISED_Asym_Pause);
 
 	switch (hw->fc.requested_mode) {
 	case e1000_fc_full:
-		ecmd->advertising |= ADVERTISED_Pause;
+		advertising |= ADVERTISED_Pause;
 		break;
 	case e1000_fc_rx_pause:
-		ecmd->advertising |= (ADVERTISED_Pause |
+		advertising |= (ADVERTISED_Pause |
 				      ADVERTISED_Asym_Pause);
 		break;
 	case e1000_fc_tx_pause:
-		ecmd->advertising |=  ADVERTISED_Asym_Pause;
+		advertising |=  ADVERTISED_Asym_Pause;
 		break;
 	default:
-		ecmd->advertising &= ~(ADVERTISED_Pause |
+		advertising &= ~(ADVERTISED_Pause |
 				       ADVERTISED_Asym_Pause);
 	}
 	if (status & E1000_STATUS_LU) {
@@ -236,39 +236,46 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		}
 		if ((status & E1000_STATUS_FD) ||
 		    hw->phy.media_type != e1000_media_type_copper)
-			ecmd->duplex = DUPLEX_FULL;
+			cmd->base.duplex = DUPLEX_FULL;
 		else
-			ecmd->duplex = DUPLEX_HALF;
+			cmd->base.duplex = DUPLEX_HALF;
 	} else {
 		speed = SPEED_UNKNOWN;
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
-	ethtool_cmd_speed_set(ecmd, speed);
+	cmd->base.speed = speed;
 	if ((hw->phy.media_type == e1000_media_type_fiber) ||
 	    hw->mac.autoneg)
-		ecmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	else
-		ecmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 
 	/* MDI-X => 2; MDI =>1; Invalid =>0 */
 	if (hw->phy.media_type == e1000_media_type_copper)
-		ecmd->eth_tp_mdix = hw->phy.is_mdix ? ETH_TP_MDI_X :
+		cmd->base.eth_tp_mdix = hw->phy.is_mdix ? ETH_TP_MDI_X :
 						      ETH_TP_MDI;
 	else
-		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+		cmd->base.eth_tp_mdix = ETH_TP_MDI_INVALID;
 
 	if (hw->phy.mdix == AUTO_ALL_MODES)
-		ecmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
 	else
-		ecmd->eth_tp_mdix_ctrl = hw->phy.mdix;
+		cmd->base.eth_tp_mdix_ctrl = hw->phy.mdix;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
-static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int igb_set_link_ksettings(struct net_device *netdev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 advertising;
 
 	/* When SoL/IDER sessions are active, autoneg/speed/duplex
 	 * cannot be changed
@@ -283,12 +290,12 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	 * some hardware doesn't allow MDI setting when speed or
 	 * duplex is forced.
 	 */
-	if (ecmd->eth_tp_mdix_ctrl) {
+	if (cmd->base.eth_tp_mdix_ctrl) {
 		if (hw->phy.media_type != e1000_media_type_copper)
 			return -EOPNOTSUPP;
 
-		if ((ecmd->eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
-		    (ecmd->autoneg != AUTONEG_ENABLE)) {
+		if ((cmd->base.eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
+		    (cmd->base.autoneg != AUTONEG_ENABLE)) {
 			dev_err(&adapter->pdev->dev, "forcing MDI/MDI-X state is not supported when link speed and/or duplex are forced\n");
 			return -EINVAL;
 		}
@@ -297,10 +304,13 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	while (test_and_set_bit(__IGB_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		hw->mac.autoneg = 1;
 		if (hw->phy.media_type == e1000_media_type_fiber) {
-			hw->phy.autoneg_advertised = ecmd->advertising |
+			hw->phy.autoneg_advertised = advertising |
 						     ADVERTISED_FIBRE |
 						     ADVERTISED_Autoneg;
 			switch (adapter->link_speed) {
@@ -320,31 +330,31 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 				break;
 			}
 		} else {
-			hw->phy.autoneg_advertised = ecmd->advertising |
+			hw->phy.autoneg_advertised = advertising |
 						     ADVERTISED_TP |
 						     ADVERTISED_Autoneg;
 		}
-		ecmd->advertising = hw->phy.autoneg_advertised;
+		advertising = hw->phy.autoneg_advertised;
 		if (adapter->fc_autoneg)
 			hw->fc.requested_mode = e1000_fc_default;
 	} else {
-		u32 speed = ethtool_cmd_speed(ecmd);
+		u32 speed = cmd->base.speed;
 		/* calling this overrides forced MDI setting */
-		if (igb_set_spd_dplx(adapter, speed, ecmd->duplex)) {
+		if (igb_set_spd_dplx(adapter, speed, cmd->base.duplex)) {
 			clear_bit(__IGB_RESETTING, &adapter->state);
 			return -EINVAL;
 		}
 	}
 
 	/* MDI-X => 2; MDI => 1; Auto => 3 */
-	if (ecmd->eth_tp_mdix_ctrl) {
+	if (cmd->base.eth_tp_mdix_ctrl) {
 		/* fix up the value for auto (3 => 0) as zero is mapped
 		 * internally to auto
 		 */
-		if (ecmd->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
+		if (cmd->base.eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
 			hw->phy.mdix = AUTO_ALL_MODES;
 		else
-			hw->phy.mdix = ecmd->eth_tp_mdix_ctrl;
+			hw->phy.mdix = cmd->base.eth_tp_mdix_ctrl;
 	}
 
 	/* reset the link */
@@ -3389,8 +3399,6 @@ static int igb_set_channels(struct net_device *netdev,
 }
 
 static const struct ethtool_ops igb_ethtool_ops = {
-	.get_settings		= igb_get_settings,
-	.set_settings		= igb_set_settings,
 	.get_drvinfo		= igb_get_drvinfo,
 	.get_regs_len		= igb_get_regs_len,
 	.get_regs		= igb_get_regs,
@@ -3428,6 +3436,8 @@ static int igb_set_channels(struct net_device *netdev,
 	.set_channels		= igb_set_channels,
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
+	.get_link_ksettings	= igb_get_link_ksettings,
+	.set_link_ksettings	= igb_set_link_ksettings,
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
