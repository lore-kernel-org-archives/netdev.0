From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: intel: e1000: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 21 Jan 2017 16:06:03 +0100
Message-ID: <1485011163-7402-1-git-send-email-tremyfr@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36181 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751060AbdAUPGM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 10:06:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   93 +++++++++++-----------
 1 files changed, 46 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 975eeb8..024a4b5 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -103,104 +103,104 @@ struct e1000_stats {
 
 #define E1000_TEST_LEN	ARRAY_SIZE(e1000_gstrings_test)
 
-static int e1000_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int e1000_get_link_ksettings(struct net_device *netdev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 supported, advertising;
 
 	if (hw->media_type == e1000_media_type_copper) {
-		ecmd->supported = (SUPPORTED_10baseT_Half |
+		supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
 				   SUPPORTED_100baseT_Half |
 				   SUPPORTED_100baseT_Full |
 				   SUPPORTED_1000baseT_Full|
 				   SUPPORTED_Autoneg |
 				   SUPPORTED_TP);
-		ecmd->advertising = ADVERTISED_TP;
+		advertising = ADVERTISED_TP;
 
 		if (hw->autoneg == 1) {
-			ecmd->advertising |= ADVERTISED_Autoneg;
+			advertising |= ADVERTISED_Autoneg;
 			/* the e1000 autoneg seems to match ethtool nicely */
-			ecmd->advertising |= hw->autoneg_advertised;
+			advertising |= hw->autoneg_advertised;
 		}
 
-		ecmd->port = PORT_TP;
-		ecmd->phy_address = hw->phy_addr;
-
-		if (hw->mac_type == e1000_82543)
-			ecmd->transceiver = XCVR_EXTERNAL;
-		else
-			ecmd->transceiver = XCVR_INTERNAL;
-
+		cmd->base.port = PORT_TP;
+		cmd->base.phy_address = hw->phy_addr;
 	} else {
-		ecmd->supported   = (SUPPORTED_1000baseT_Full |
+		supported   = (SUPPORTED_1000baseT_Full |
 				     SUPPORTED_FIBRE |
 				     SUPPORTED_Autoneg);
 
-		ecmd->advertising = (ADVERTISED_1000baseT_Full |
+		advertising = (ADVERTISED_1000baseT_Full |
 				     ADVERTISED_FIBRE |
 				     ADVERTISED_Autoneg);
 
-		ecmd->port = PORT_FIBRE;
-
-		if (hw->mac_type >= e1000_82545)
-			ecmd->transceiver = XCVR_INTERNAL;
-		else
-			ecmd->transceiver = XCVR_EXTERNAL;
+		cmd->base.port = PORT_FIBRE;
 	}
 
 	if (er32(STATUS) & E1000_STATUS_LU) {
 		e1000_get_speed_and_duplex(hw, &adapter->link_speed,
 					   &adapter->link_duplex);
-		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
+		cmd->base.speed = adapter->link_speed;
 
 		/* unfortunately FULL_DUPLEX != DUPLEX_FULL
 		 * and HALF_DUPLEX != DUPLEX_HALF
 		 */
 		if (adapter->link_duplex == FULL_DUPLEX)
-			ecmd->duplex = DUPLEX_FULL;
+			cmd->base.duplex = DUPLEX_FULL;
 		else
-			ecmd->duplex = DUPLEX_HALF;
+			cmd->base.duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
-	ecmd->autoneg = ((hw->media_type == e1000_media_type_fiber) ||
+	cmd->base.autoneg = ((hw->media_type == e1000_media_type_fiber) ||
 			 hw->autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 
 	/* MDI-X => 1; MDI => 0 */
 	if ((hw->media_type == e1000_media_type_copper) &&
 	    netif_carrier_ok(netdev))
-		ecmd->eth_tp_mdix = (!!adapter->phy_info.mdix_mode ?
+		cmd->base.eth_tp_mdix = (!!adapter->phy_info.mdix_mode ?
 				     ETH_TP_MDI_X : ETH_TP_MDI);
 	else
-		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+		cmd->base.eth_tp_mdix = ETH_TP_MDI_INVALID;
 
 	if (hw->mdix == AUTO_ALL_MODES)
-		ecmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
 	else
-		ecmd->eth_tp_mdix_ctrl = hw->mdix;
+		cmd->base.eth_tp_mdix_ctrl = hw->mdix;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-static int e1000_set_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int e1000_set_link_ksettings(struct net_device *netdev,
+				    const struct ethtool_link_ksettings *cmd)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	/* MDI setting is only allowed when autoneg enabled because
 	 * some hardware doesn't allow MDI setting when speed or
 	 * duplex is forced.
 	 */
-	if (ecmd->eth_tp_mdix_ctrl) {
+	if (cmd->base.eth_tp_mdix_ctrl) {
 		if (hw->media_type != e1000_media_type_copper)
 			return -EOPNOTSUPP;
 
-		if ((ecmd->eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
-		    (ecmd->autoneg != AUTONEG_ENABLE)) {
+		if ((cmd->base.eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
+		    (cmd->base.autoneg != AUTONEG_ENABLE)) {
 			e_err(drv, "forcing MDI/MDI-X state is not supported when link speed and/or duplex are forced\n");
 			return -EINVAL;
 		}
@@ -209,32 +209,31 @@ static int e1000_set_settings(struct net_device *netdev,
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
 		msleep(1);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		hw->autoneg = 1;
 		if (hw->media_type == e1000_media_type_fiber)
 			hw->autoneg_advertised = ADVERTISED_1000baseT_Full |
 				     ADVERTISED_FIBRE |
 				     ADVERTISED_Autoneg;
 		else
-			hw->autoneg_advertised = ecmd->advertising |
+			hw->autoneg_advertised = advertising |
 						 ADVERTISED_TP |
 						 ADVERTISED_Autoneg;
-		ecmd->advertising = hw->autoneg_advertised;
 	} else {
-		u32 speed = ethtool_cmd_speed(ecmd);
+		u32 speed = cmd->base.speed;
 		/* calling this overrides forced MDI setting */
-		if (e1000_set_spd_dplx(adapter, speed, ecmd->duplex)) {
+		if (e1000_set_spd_dplx(adapter, speed, cmd->base.duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->flags);
 			return -EINVAL;
 		}
 	}
 
 	/* MDI-X => 2; MDI => 1; Auto => 3 */
-	if (ecmd->eth_tp_mdix_ctrl) {
-		if (ecmd->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
+	if (cmd->base.eth_tp_mdix_ctrl) {
+		if (cmd->base.eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
 			hw->mdix = AUTO_ALL_MODES;
 		else
-			hw->mdix = ecmd->eth_tp_mdix_ctrl;
+			hw->mdix = cmd->base.eth_tp_mdix_ctrl;
 	}
 
 	/* reset the link */
@@ -1875,8 +1874,6 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 }
 
 static const struct ethtool_ops e1000_ethtool_ops = {
-	.get_settings		= e1000_get_settings,
-	.set_settings		= e1000_set_settings,
 	.get_drvinfo		= e1000_get_drvinfo,
 	.get_regs_len		= e1000_get_regs_len,
 	.get_regs		= e1000_get_regs,
@@ -1901,6 +1898,8 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 	.get_coalesce		= e1000_get_coalesce,
 	.set_coalesce		= e1000_set_coalesce,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_link_ksettings	= e1000_get_link_ksettings,
+	.set_link_ksettings	= e1000_set_link_ksettings,
 };
 
 void e1000_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
