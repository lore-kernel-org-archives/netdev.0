From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: silan: sc92031: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 27 Feb 2017 22:50:25 +0100
Message-ID: <1488232225-31143-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/silan/sc92031.c |   83 +++++++++++++++++++---------------
 1 files changed, 47 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 6c2e2b3..751c818 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -1122,14 +1122,16 @@ static void sc92031_poll_controller(struct net_device *dev)
 }
 #endif
 
-static int sc92031_ethtool_get_settings(struct net_device *dev,
-		struct ethtool_cmd *cmd)
+static int
+sc92031_ethtool_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct sc92031_priv *priv = netdev_priv(dev);
 	void __iomem *port_base = priv->port_base;
 	u8 phy_address;
 	u32 phy_ctrl;
 	u16 output_status;
+	u32 supported, advertising;
 
 	spin_lock_bh(&priv->lock);
 
@@ -1142,68 +1144,77 @@ static int sc92031_ethtool_get_settings(struct net_device *dev,
 
 	spin_unlock_bh(&priv->lock);
 
-	cmd->supported = SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full
+	supported = SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full
 			| SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full
 			| SUPPORTED_Autoneg | SUPPORTED_TP | SUPPORTED_MII;
 
-	cmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
+	advertising = ADVERTISED_TP | ADVERTISED_MII;
 
 	if ((phy_ctrl & (PhyCtrlDux | PhyCtrlSpd100 | PhyCtrlSpd10))
 			== (PhyCtrlDux | PhyCtrlSpd100 | PhyCtrlSpd10))
-		cmd->advertising |= ADVERTISED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
 
 	if ((phy_ctrl & PhyCtrlSpd10) == PhyCtrlSpd10)
-		cmd->advertising |= ADVERTISED_10baseT_Half;
+		advertising |= ADVERTISED_10baseT_Half;
 
 	if ((phy_ctrl & (PhyCtrlSpd10 | PhyCtrlDux))
 			== (PhyCtrlSpd10 | PhyCtrlDux))
-		cmd->advertising |= ADVERTISED_10baseT_Full;
+		advertising |= ADVERTISED_10baseT_Full;
 
 	if ((phy_ctrl & PhyCtrlSpd100) == PhyCtrlSpd100)
-		cmd->advertising |= ADVERTISED_100baseT_Half;
+		advertising |= ADVERTISED_100baseT_Half;
 
 	if ((phy_ctrl & (PhyCtrlSpd100 | PhyCtrlDux))
 			== (PhyCtrlSpd100 | PhyCtrlDux))
-		cmd->advertising |= ADVERTISED_100baseT_Full;
+		advertising |= ADVERTISED_100baseT_Full;
 
 	if (phy_ctrl & PhyCtrlAne)
-		cmd->advertising |= ADVERTISED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
 
-	ethtool_cmd_speed_set(cmd,
-			      (output_status & 0x2) ? SPEED_100 : SPEED_10);
-	cmd->duplex = (output_status & 0x4) ? DUPLEX_FULL : DUPLEX_HALF;
-	cmd->port = PORT_MII;
-	cmd->phy_address = phy_address;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->autoneg = (phy_ctrl & PhyCtrlAne) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	cmd->base.speed = (output_status & 0x2) ? SPEED_100 : SPEED_10;
+	cmd->base.duplex = (output_status & 0x4) ? DUPLEX_FULL : DUPLEX_HALF;
+	cmd->base.port = PORT_MII;
+	cmd->base.phy_address = phy_address;
+	cmd->base.autoneg = (phy_ctrl & PhyCtrlAne) ?
+		AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
-static int sc92031_ethtool_set_settings(struct net_device *dev,
-		struct ethtool_cmd *cmd)
+static int
+sc92031_ethtool_set_link_ksettings(struct net_device *dev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct sc92031_priv *priv = netdev_priv(dev);
 	void __iomem *port_base = priv->port_base;
-	u32 speed = ethtool_cmd_speed(cmd);
+	u32 speed = cmd->base.speed;
 	u32 phy_ctrl;
 	u32 old_phy_ctrl;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	if (!(speed == SPEED_10 || speed == SPEED_100))
 		return -EINVAL;
-	if (!(cmd->duplex == DUPLEX_HALF || cmd->duplex == DUPLEX_FULL))
-		return -EINVAL;
-	if (!(cmd->port == PORT_MII))
+	if (!(cmd->base.duplex == DUPLEX_HALF ||
+	      cmd->base.duplex == DUPLEX_FULL))
 		return -EINVAL;
-	if (!(cmd->phy_address == 0x1f))
+	if (!(cmd->base.port == PORT_MII))
 		return -EINVAL;
-	if (!(cmd->transceiver == XCVR_INTERNAL))
+	if (!(cmd->base.phy_address == 0x1f))
 		return -EINVAL;
-	if (!(cmd->autoneg == AUTONEG_DISABLE || cmd->autoneg == AUTONEG_ENABLE))
+	if (!(cmd->base.autoneg == AUTONEG_DISABLE ||
+	      cmd->base.autoneg == AUTONEG_ENABLE))
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (!(cmd->advertising & (ADVERTISED_Autoneg
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
+		if (!(advertising & (ADVERTISED_Autoneg
 				| ADVERTISED_100baseT_Full
 				| ADVERTISED_100baseT_Half
 				| ADVERTISED_10baseT_Full
@@ -1213,15 +1224,15 @@ static int sc92031_ethtool_set_settings(struct net_device *dev,
 		phy_ctrl = PhyCtrlAne;
 
 		// FIXME: I'm not sure what the original code was trying to do
-		if (cmd->advertising & ADVERTISED_Autoneg)
+		if (advertising & ADVERTISED_Autoneg)
 			phy_ctrl |= PhyCtrlDux | PhyCtrlSpd100 | PhyCtrlSpd10;
-		if (cmd->advertising & ADVERTISED_100baseT_Full)
+		if (advertising & ADVERTISED_100baseT_Full)
 			phy_ctrl |= PhyCtrlDux | PhyCtrlSpd100;
-		if (cmd->advertising & ADVERTISED_100baseT_Half)
+		if (advertising & ADVERTISED_100baseT_Half)
 			phy_ctrl |= PhyCtrlSpd100;
-		if (cmd->advertising & ADVERTISED_10baseT_Full)
+		if (advertising & ADVERTISED_10baseT_Full)
 			phy_ctrl |= PhyCtrlSpd10 | PhyCtrlDux;
-		if (cmd->advertising & ADVERTISED_10baseT_Half)
+		if (advertising & ADVERTISED_10baseT_Half)
 			phy_ctrl |= PhyCtrlSpd10;
 	} else {
 		// FIXME: Whole branch guessed
@@ -1232,7 +1243,7 @@ static int sc92031_ethtool_set_settings(struct net_device *dev,
 		else /* cmd->speed == SPEED_100 */
 			phy_ctrl |= PhyCtrlSpd100;
 
-		if (cmd->duplex == DUPLEX_FULL)
+		if (cmd->base.duplex == DUPLEX_FULL)
 			phy_ctrl |= PhyCtrlDux;
 	}
 
@@ -1368,8 +1379,6 @@ static void sc92031_ethtool_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops sc92031_ethtool_ops = {
-	.get_settings		= sc92031_ethtool_get_settings,
-	.set_settings		= sc92031_ethtool_set_settings,
 	.get_wol		= sc92031_ethtool_get_wol,
 	.set_wol		= sc92031_ethtool_set_wol,
 	.nway_reset		= sc92031_ethtool_nway_reset,
@@ -1377,6 +1386,8 @@ static void sc92031_ethtool_get_ethtool_stats(struct net_device *dev,
 	.get_strings		= sc92031_ethtool_get_strings,
 	.get_sset_count		= sc92031_ethtool_get_sset_count,
 	.get_ethtool_stats	= sc92031_ethtool_get_ethtool_stats,
+	.get_link_ksettings	= sc92031_ethtool_get_link_ksettings,
+	.set_link_ksettings	= sc92031_ethtool_set_link_ksettings,
 };
 
 
-- 
1.7.4.4
