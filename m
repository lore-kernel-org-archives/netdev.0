From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2] net: intel: ixgbe: use new api ethtool_{get|set}_link_ksettings
Date: Tue,  7 Mar 2017 23:32:25 +0100
Message-ID: <1488925945-32313-1-git-send-email-tremyfr@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
        andrewx.bowers@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36690 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbdCGWfI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:35:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- fix compilation (thanks andrewx bowers)

 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  168 ++++++++++++----------
 1 files changed, 91 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 90fa5bf..0da0752f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -186,60 +186,62 @@ static u32 ixgbe_get_supported_10gtypes(struct ixgbe_hw *hw)
 	}
 }
 
-static int ixgbe_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int ixgbe_get_link_ksettings(struct net_device *netdev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	ixgbe_link_speed supported_link;
 	bool autoneg = false;
+	u32 supported, advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
 
 	hw->mac.ops.get_link_capabilities(hw, &supported_link, &autoneg);
 
 	/* set the supported link speeds */
 	if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
-		ecmd->supported |= ixgbe_get_supported_10gtypes(hw);
+		supported |= ixgbe_get_supported_10gtypes(hw);
 	if (supported_link & IXGBE_LINK_SPEED_1GB_FULL)
-		ecmd->supported |= (ixgbe_isbackplane(hw->phy.media_type)) ?
+		supported |= (ixgbe_isbackplane(hw->phy.media_type)) ?
 				   SUPPORTED_1000baseKX_Full :
 				   SUPPORTED_1000baseT_Full;
 	if (supported_link & IXGBE_LINK_SPEED_100_FULL)
-		ecmd->supported |= SUPPORTED_100baseT_Full;
+		supported |= SUPPORTED_100baseT_Full;
 	if (supported_link & IXGBE_LINK_SPEED_10_FULL)
-		ecmd->supported |= SUPPORTED_10baseT_Full;
+		supported |= SUPPORTED_10baseT_Full;
 
 	/* default advertised speed if phy.autoneg_advertised isn't set */
-	ecmd->advertising = ecmd->supported;
+	advertising = supported;
 	/* set the advertised speeds */
 	if (hw->phy.autoneg_advertised) {
-		ecmd->advertising = 0;
+		advertising = 0;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10_FULL)
-			ecmd->advertising |= ADVERTISED_10baseT_Full;
+			advertising |= ADVERTISED_10baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
+			advertising |= ADVERTISED_100baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
-			ecmd->advertising |= ecmd->supported & ADVRTSD_MSK_10G;
+			advertising |= supported & ADVRTSD_MSK_10G;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL) {
-			if (ecmd->supported & SUPPORTED_1000baseKX_Full)
-				ecmd->advertising |= ADVERTISED_1000baseKX_Full;
+			if (supported & SUPPORTED_1000baseKX_Full)
+				advertising |= ADVERTISED_1000baseKX_Full;
 			else
-				ecmd->advertising |= ADVERTISED_1000baseT_Full;
+				advertising |= ADVERTISED_1000baseT_Full;
 		}
 	} else {
 		if (hw->phy.multispeed_fiber && !autoneg) {
 			if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
-				ecmd->advertising = ADVERTISED_10000baseT_Full;
+				advertising = ADVERTISED_10000baseT_Full;
 		}
 	}
 
 	if (autoneg) {
-		ecmd->supported |= SUPPORTED_Autoneg;
-		ecmd->advertising |= ADVERTISED_Autoneg;
-		ecmd->autoneg = AUTONEG_ENABLE;
+		supported |= SUPPORTED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	} else
-		ecmd->autoneg = AUTONEG_DISABLE;
-
-	ecmd->transceiver = XCVR_EXTERNAL;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 
 	/* Determine the remaining settings based on the PHY type. */
 	switch (adapter->hw.phy.type) {
@@ -248,14 +250,14 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	case ixgbe_phy_x550em_ext_t:
 	case ixgbe_phy_fw:
 	case ixgbe_phy_cu_unknown:
-		ecmd->supported |= SUPPORTED_TP;
-		ecmd->advertising |= ADVERTISED_TP;
-		ecmd->port = PORT_TP;
+		supported |= SUPPORTED_TP;
+		advertising |= ADVERTISED_TP;
+		cmd->base.port = PORT_TP;
 		break;
 	case ixgbe_phy_qt:
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_FIBRE;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		cmd->base.port = PORT_FIBRE;
 		break;
 	case ixgbe_phy_nl:
 	case ixgbe_phy_sfp_passive_tyco:
@@ -273,9 +275,9 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		case ixgbe_sfp_type_da_cu:
 		case ixgbe_sfp_type_da_cu_core0:
 		case ixgbe_sfp_type_da_cu_core1:
-			ecmd->supported |= SUPPORTED_FIBRE;
-			ecmd->advertising |= ADVERTISED_FIBRE;
-			ecmd->port = PORT_DA;
+			supported |= SUPPORTED_FIBRE;
+			advertising |= ADVERTISED_FIBRE;
+			cmd->base.port = PORT_DA;
 			break;
 		case ixgbe_sfp_type_sr:
 		case ixgbe_sfp_type_lr:
@@ -285,102 +287,113 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		case ixgbe_sfp_type_1g_sx_core1:
 		case ixgbe_sfp_type_1g_lx_core0:
 		case ixgbe_sfp_type_1g_lx_core1:
-			ecmd->supported |= SUPPORTED_FIBRE;
-			ecmd->advertising |= ADVERTISED_FIBRE;
-			ecmd->port = PORT_FIBRE;
+			supported |= SUPPORTED_FIBRE;
+			advertising |= ADVERTISED_FIBRE;
+			cmd->base.port = PORT_FIBRE;
 			break;
 		case ixgbe_sfp_type_not_present:
-			ecmd->supported |= SUPPORTED_FIBRE;
-			ecmd->advertising |= ADVERTISED_FIBRE;
-			ecmd->port = PORT_NONE;
+			supported |= SUPPORTED_FIBRE;
+			advertising |= ADVERTISED_FIBRE;
+			cmd->base.port = PORT_NONE;
 			break;
 		case ixgbe_sfp_type_1g_cu_core0:
 		case ixgbe_sfp_type_1g_cu_core1:
-			ecmd->supported |= SUPPORTED_TP;
-			ecmd->advertising |= ADVERTISED_TP;
-			ecmd->port = PORT_TP;
+			supported |= SUPPORTED_TP;
+			advertising |= ADVERTISED_TP;
+			cmd->base.port = PORT_TP;
 			break;
 		case ixgbe_sfp_type_unknown:
 		default:
-			ecmd->supported |= SUPPORTED_FIBRE;
-			ecmd->advertising |= ADVERTISED_FIBRE;
-			ecmd->port = PORT_OTHER;
+			supported |= SUPPORTED_FIBRE;
+			advertising |= ADVERTISED_FIBRE;
+			cmd->base.port = PORT_OTHER;
 			break;
 		}
 		break;
 	case ixgbe_phy_xaui:
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_NONE;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		cmd->base.port = PORT_NONE;
 		break;
 	case ixgbe_phy_unknown:
 	case ixgbe_phy_generic:
 	case ixgbe_phy_sfp_unsupported:
 	default:
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_OTHER;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		cmd->base.port = PORT_OTHER;
 		break;
 	}
 
 	/* Indicate pause support */
-	ecmd->supported |= SUPPORTED_Pause;
+	supported |= SUPPORTED_Pause;
 
 	switch (hw->fc.requested_mode) {
 	case ixgbe_fc_full:
-		ecmd->advertising |= ADVERTISED_Pause;
+		advertising |= ADVERTISED_Pause;
 		break;
 	case ixgbe_fc_rx_pause:
-		ecmd->advertising |= ADVERTISED_Pause |
+		advertising |= ADVERTISED_Pause |
 				     ADVERTISED_Asym_Pause;
 		break;
 	case ixgbe_fc_tx_pause:
-		ecmd->advertising |= ADVERTISED_Asym_Pause;
+		advertising |= ADVERTISED_Asym_Pause;
 		break;
 	default:
-		ecmd->advertising &= ~(ADVERTISED_Pause |
+		advertising &= ~(ADVERTISED_Pause |
 				       ADVERTISED_Asym_Pause);
 	}
 
 	if (netif_carrier_ok(netdev)) {
 		switch (adapter->link_speed) {
 		case IXGBE_LINK_SPEED_10GB_FULL:
-			ethtool_cmd_speed_set(ecmd, SPEED_10000);
+			cmd->base.speed = SPEED_10000;
 			break;
 		case IXGBE_LINK_SPEED_5GB_FULL:
-			ethtool_cmd_speed_set(ecmd, SPEED_5000);
+			cmd->base.speed = SPEED_5000;
 			break;
 		case IXGBE_LINK_SPEED_2_5GB_FULL:
-			ethtool_cmd_speed_set(ecmd, SPEED_2500);
+			cmd->base.speed = SPEED_2500;
 			break;
 		case IXGBE_LINK_SPEED_1GB_FULL:
-			ethtool_cmd_speed_set(ecmd, SPEED_1000);
+			cmd->base.speed = SPEED_1000;
 			break;
 		case IXGBE_LINK_SPEED_100_FULL:
-			ethtool_cmd_speed_set(ecmd, SPEED_100);
+			cmd->base.speed = SPEED_100;
 			break;
 		case IXGBE_LINK_SPEED_10_FULL:
-			ethtool_cmd_speed_set(ecmd, SPEED_10);
+			cmd->base.speed = SPEED_10;
 			break;
 		default:
 			break;
 		}
-		ecmd->duplex = DUPLEX_FULL;
+		cmd->base.duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-static int ixgbe_set_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int ixgbe_set_link_ksettings(struct net_device *netdev,
+				    const struct ethtool_link_ksettings *cmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 advertised, old;
 	s32 err = 0;
+	u32 supported, advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
 	    (hw->phy.multispeed_fiber)) {
@@ -388,12 +401,12 @@ static int ixgbe_set_settings(struct net_device *netdev,
 		 * this function does not support duplex forcing, but can
 		 * limit the advertising of the adapter to the specified speed
 		 */
-		if (ecmd->advertising & ~ecmd->supported)
+		if (advertising & ~supported)
 			return -EINVAL;
 
 		/* only allow one speed at a time if no autoneg */
-		if (!ecmd->autoneg && hw->phy.multispeed_fiber) {
-			if (ecmd->advertising ==
+		if (!cmd->base.autoneg && hw->phy.multispeed_fiber) {
+			if (advertising ==
 			    (ADVERTISED_10000baseT_Full |
 			     ADVERTISED_1000baseT_Full))
 				return -EINVAL;
@@ -401,16 +414,16 @@ static int ixgbe_set_settings(struct net_device *netdev,
 
 		old = hw->phy.autoneg_advertised;
 		advertised = 0;
-		if (ecmd->advertising & ADVERTISED_10000baseT_Full)
+		if (advertising & ADVERTISED_10000baseT_Full)
 			advertised |= IXGBE_LINK_SPEED_10GB_FULL;
 
-		if (ecmd->advertising & ADVERTISED_1000baseT_Full)
+		if (advertising & ADVERTISED_1000baseT_Full)
 			advertised |= IXGBE_LINK_SPEED_1GB_FULL;
 
-		if (ecmd->advertising & ADVERTISED_100baseT_Full)
+		if (advertising & ADVERTISED_100baseT_Full)
 			advertised |= IXGBE_LINK_SPEED_100_FULL;
 
-		if (ecmd->advertising & ADVERTISED_10baseT_Full)
+		if (advertising & ADVERTISED_10baseT_Full)
 			advertised |= IXGBE_LINK_SPEED_10_FULL;
 
 		if (old == advertised)
@@ -428,10 +441,11 @@ static int ixgbe_set_settings(struct net_device *netdev,
 		clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
 	} else {
 		/* in this case we currently only support 10Gb/FULL */
-		u32 speed = ethtool_cmd_speed(ecmd);
-		if ((ecmd->autoneg == AUTONEG_ENABLE) ||
-		    (ecmd->advertising != ADVERTISED_10000baseT_Full) ||
-		    (speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
+		u32 speed = cmd->base.speed;
+
+		if ((cmd->base.autoneg == AUTONEG_ENABLE) ||
+		    (advertising != ADVERTISED_10000baseT_Full) ||
+		    (speed + cmd->base.duplex != SPEED_10000 + DUPLEX_FULL))
 			return -EINVAL;
 	}
 
@@ -3402,8 +3416,6 @@ static int ixgbe_set_priv_flags(struct net_device *netdev, u32 priv_flags)
 }
 
 static const struct ethtool_ops ixgbe_ethtool_ops = {
-	.get_settings           = ixgbe_get_settings,
-	.set_settings           = ixgbe_set_settings,
 	.get_drvinfo            = ixgbe_get_drvinfo,
 	.get_regs_len           = ixgbe_get_regs_len,
 	.get_regs               = ixgbe_get_regs,
@@ -3442,6 +3454,8 @@ static int ixgbe_set_priv_flags(struct net_device *netdev, u32 priv_flags)
 	.get_ts_info		= ixgbe_get_ts_info,
 	.get_module_info	= ixgbe_get_module_info,
 	.get_module_eeprom	= ixgbe_get_module_eeprom,
+	.get_link_ksettings     = ixgbe_get_link_ksettings,
+	.set_link_ksettings     = ixgbe_set_link_ksettings,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
