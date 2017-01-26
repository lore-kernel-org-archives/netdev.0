From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: intel: e1000e: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 26 Jan 2017 22:19:53 +0100
Message-ID: <1485465593-12561-1-git-send-email-tremyfr@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c |   91 ++++++++++++++------------
 1 files changed, 49 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 7aff68a..3768a5c 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -117,15 +117,15 @@ struct e1000_stats {
 
 #define E1000_TEST_LEN ARRAY_SIZE(e1000_gstrings_test)
 
-static int e1000_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int e1000_get_link_ksettings(struct net_device *netdev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 speed;
+	u32 speed, supported, advertising;
 
 	if (hw->phy.media_type == e1000_media_type_copper) {
-		ecmd->supported = (SUPPORTED_10baseT_Half |
+		supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
 				   SUPPORTED_100baseT_Half |
 				   SUPPORTED_100baseT_Full |
@@ -133,39 +133,36 @@ static int e1000_get_settings(struct net_device *netdev,
 				   SUPPORTED_Autoneg |
 				   SUPPORTED_TP);
 		if (hw->phy.type == e1000_phy_ife)
-			ecmd->supported &= ~SUPPORTED_1000baseT_Full;
-		ecmd->advertising = ADVERTISED_TP;
+			supported &= ~SUPPORTED_1000baseT_Full;
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
-
+		cmd->base.port = PORT_TP;
+		cmd->base.phy_address = hw->phy.addr;
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
-		ecmd->transceiver = XCVR_EXTERNAL;
+		cmd->base.port = PORT_FIBRE;
 	}
 
 	speed = SPEED_UNKNOWN;
-	ecmd->duplex = DUPLEX_UNKNOWN;
+	cmd->base.duplex = DUPLEX_UNKNOWN;
 
 	if (netif_running(netdev)) {
 		if (netif_carrier_ok(netdev)) {
 			speed = adapter->link_speed;
-			ecmd->duplex = adapter->link_duplex - 1;
+			cmd->base.duplex = adapter->link_duplex - 1;
 		}
 	} else if (!pm_runtime_suspended(netdev->dev.parent)) {
 		u32 status = er32(STATUS);
@@ -179,30 +176,36 @@ static int e1000_get_settings(struct net_device *netdev,
 				speed = SPEED_10;
 
 			if (status & E1000_STATUS_FD)
-				ecmd->duplex = DUPLEX_FULL;
+				cmd->base.duplex = DUPLEX_FULL;
 			else
-				ecmd->duplex = DUPLEX_HALF;
+				cmd->base.duplex = DUPLEX_HALF;
 		}
 	}
 
-	ethtool_cmd_speed_set(ecmd, speed);
-	ecmd->autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
+	cmd->base.speed = speed;
+	cmd->base.autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
 			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 
 	/* MDI-X => 2; MDI =>1; Invalid =>0 */
 	if ((hw->phy.media_type == e1000_media_type_copper) &&
 	    netif_carrier_ok(netdev))
-		ecmd->eth_tp_mdix = hw->phy.is_mdix ? ETH_TP_MDI_X : ETH_TP_MDI;
+		cmd->base.eth_tp_mdix = hw->phy.is_mdix ?
+			ETH_TP_MDI_X : ETH_TP_MDI;
 	else
-		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+		cmd->base.eth_tp_mdix = ETH_TP_MDI_INVALID;
 
 	if (hw->phy.mdix == AUTO_ALL_MODES)
-		ecmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
 	else
-		ecmd->eth_tp_mdix_ctrl = hw->phy.mdix;
+		cmd->base.eth_tp_mdix_ctrl = hw->phy.mdix;
 
 	if (hw->phy.media_type != e1000_media_type_copper)
-		ecmd->eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
@@ -262,12 +265,16 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 	return -EINVAL;
 }
 
-static int e1000_set_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int e1000_set_link_ksettings(struct net_device *netdev,
+				    const struct ethtool_link_ksettings *cmd)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	int ret_val = 0;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	pm_runtime_get_sync(netdev->dev.parent);
 
@@ -285,14 +292,14 @@ static int e1000_set_settings(struct net_device *netdev,
 	 * some hardware doesn't allow MDI setting when speed or
 	 * duplex is forced.
 	 */
-	if (ecmd->eth_tp_mdix_ctrl) {
+	if (cmd->base.eth_tp_mdix_ctrl) {
 		if (hw->phy.media_type != e1000_media_type_copper) {
 			ret_val = -EOPNOTSUPP;
 			goto out;
 		}
 
-		if ((ecmd->eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
-		    (ecmd->autoneg != AUTONEG_ENABLE)) {
+		if ((cmd->base.eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
+		    (cmd->base.autoneg != AUTONEG_ENABLE)) {
 			e_err("forcing MDI/MDI-X state is not supported when link speed and/or duplex are forced\n");
 			ret_val = -EINVAL;
 			goto out;
@@ -302,35 +309,35 @@ static int e1000_set_settings(struct net_device *netdev,
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		hw->mac.autoneg = 1;
 		if (hw->phy.media_type == e1000_media_type_fiber)
 			hw->phy.autoneg_advertised = ADVERTISED_1000baseT_Full |
 			    ADVERTISED_FIBRE | ADVERTISED_Autoneg;
 		else
-			hw->phy.autoneg_advertised = ecmd->advertising |
+			hw->phy.autoneg_advertised = advertising |
 			    ADVERTISED_TP | ADVERTISED_Autoneg;
-		ecmd->advertising = hw->phy.autoneg_advertised;
+		advertising = hw->phy.autoneg_advertised;
 		if (adapter->fc_autoneg)
 			hw->fc.requested_mode = e1000_fc_default;
 	} else {
-		u32 speed = ethtool_cmd_speed(ecmd);
+		u32 speed = cmd->base.speed;
 		/* calling this overrides forced MDI setting */
-		if (e1000_set_spd_dplx(adapter, speed, ecmd->duplex)) {
+		if (e1000_set_spd_dplx(adapter, speed, cmd->base.duplex)) {
 			ret_val = -EINVAL;
 			goto out;
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
@@ -2313,8 +2320,6 @@ static int e1000e_get_ts_info(struct net_device *netdev,
 }
 
 static const struct ethtool_ops e1000_ethtool_ops = {
-	.get_settings		= e1000_get_settings,
-	.set_settings		= e1000_set_settings,
 	.get_drvinfo		= e1000_get_drvinfo,
 	.get_regs_len		= e1000_get_regs_len,
 	.get_regs		= e1000_get_regs,
@@ -2342,6 +2347,8 @@ static int e1000e_get_ts_info(struct net_device *netdev,
 	.get_ts_info		= e1000e_get_ts_info,
 	.get_eee		= e1000e_get_eee,
 	.set_eee		= e1000e_set_eee,
+	.get_link_ksettings	= e1000_get_link_ksettings,
+	.set_link_ksettings	= e1000_set_link_ksettings,
 };
 
 void e1000e_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
