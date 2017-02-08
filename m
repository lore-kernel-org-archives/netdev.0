From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: micrel: ks8695net: use new api ethtool_{get|set}_link_ksettings
Date: Wed,  8 Feb 2017 23:54:45 +0100
Message-ID: <1486594485-24700-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, harvey.hunt@imgtec.com, edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/micrel/ks8695net.c |   91 +++++++++++++++++--------------
 1 files changed, 50 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index d210615..bd51e05 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -854,85 +854,94 @@ static int ks8695_poll(struct napi_struct *napi, int budget)
 }
 
 /**
- *	ks8695_wan_get_settings - Get device-specific settings.
+ *	ks8695_wan_get_link_ksettings - Get device-specific settings.
  *	@ndev: The network device to read settings from
  *	@cmd: The ethtool structure to read into
  */
 static int
-ks8695_wan_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+ks8695_wan_get_link_ksettings(struct net_device *ndev,
+			      struct ethtool_link_ksettings *cmd)
 {
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	u32 ctrl;
+	u32 supported, advertising;
 
 	/* All ports on the KS8695 support these... */
-	cmd->supported = (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
+	supported = (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 			  SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 			  SUPPORTED_TP | SUPPORTED_MII);
-	cmd->transceiver = XCVR_INTERNAL;
 
-	cmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
-	cmd->port = PORT_MII;
-	cmd->supported |= (SUPPORTED_Autoneg | SUPPORTED_Pause);
-	cmd->phy_address = 0;
+	advertising = ADVERTISED_TP | ADVERTISED_MII;
+	cmd->base.port = PORT_MII;
+	supported |= (SUPPORTED_Autoneg | SUPPORTED_Pause);
+	cmd->base.phy_address = 0;
 
 	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
 	if ((ctrl & WMC_WAND) == 0) {
 		/* auto-negotiation is enabled */
-		cmd->advertising |= ADVERTISED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
 		if (ctrl & WMC_WANA100F)
-			cmd->advertising |= ADVERTISED_100baseT_Full;
+			advertising |= ADVERTISED_100baseT_Full;
 		if (ctrl & WMC_WANA100H)
-			cmd->advertising |= ADVERTISED_100baseT_Half;
+			advertising |= ADVERTISED_100baseT_Half;
 		if (ctrl & WMC_WANA10F)
-			cmd->advertising |= ADVERTISED_10baseT_Full;
+			advertising |= ADVERTISED_10baseT_Full;
 		if (ctrl & WMC_WANA10H)
-			cmd->advertising |= ADVERTISED_10baseT_Half;
+			advertising |= ADVERTISED_10baseT_Half;
 		if (ctrl & WMC_WANAP)
-			cmd->advertising |= ADVERTISED_Pause;
-		cmd->autoneg = AUTONEG_ENABLE;
+			advertising |= ADVERTISED_Pause;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 
-		ethtool_cmd_speed_set(cmd,
-				      (ctrl & WMC_WSS) ? SPEED_100 : SPEED_10);
-		cmd->duplex = (ctrl & WMC_WDS) ?
+		cmd->base.speed = (ctrl & WMC_WSS) ? SPEED_100 : SPEED_10;
+		cmd->base.duplex = (ctrl & WMC_WDS) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 	} else {
 		/* auto-negotiation is disabled */
-		cmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 
-		ethtool_cmd_speed_set(cmd, ((ctrl & WMC_WANF100) ?
-					    SPEED_100 : SPEED_10));
-		cmd->duplex = (ctrl & WMC_WANFF) ?
+		cmd->base.speed = (ctrl & WMC_WANF100) ?
+					    SPEED_100 : SPEED_10;
+		cmd->base.duplex = (ctrl & WMC_WANFF) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 	}
 
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
 /**
- *	ks8695_wan_set_settings - Set device-specific settings.
+ *	ks8695_wan_set_link_ksettings - Set device-specific settings.
  *	@ndev: The network device to configure
  *	@cmd: The settings to configure
  */
 static int
-ks8695_wan_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+ks8695_wan_set_link_ksettings(struct net_device *ndev,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	u32 ctrl;
+	u32 advertising;
 
-	if ((cmd->speed != SPEED_10) && (cmd->speed != SPEED_100))
-		return -EINVAL;
-	if ((cmd->duplex != DUPLEX_HALF) && (cmd->duplex != DUPLEX_FULL))
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+
+	if ((cmd->base.speed != SPEED_10) && (cmd->base.speed != SPEED_100))
 		return -EINVAL;
-	if (cmd->port != PORT_MII)
+	if ((cmd->base.duplex != DUPLEX_HALF) &&
+	    (cmd->base.duplex != DUPLEX_FULL))
 		return -EINVAL;
-	if (cmd->transceiver != XCVR_INTERNAL)
+	if (cmd->base.port != PORT_MII)
 		return -EINVAL;
-	if ((cmd->autoneg != AUTONEG_DISABLE) &&
-	    (cmd->autoneg != AUTONEG_ENABLE))
+	if ((cmd->base.autoneg != AUTONEG_DISABLE) &&
+	    (cmd->base.autoneg != AUTONEG_ENABLE))
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if ((cmd->advertising & (ADVERTISED_10baseT_Half |
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
+		if ((advertising & (ADVERTISED_10baseT_Half |
 				ADVERTISED_10baseT_Full |
 				ADVERTISED_100baseT_Half |
 				ADVERTISED_100baseT_Full)) == 0)
@@ -942,13 +951,13 @@ static int ks8695_poll(struct napi_struct *napi, int budget)
 
 		ctrl &= ~(WMC_WAND | WMC_WANA100F | WMC_WANA100H |
 			  WMC_WANA10F | WMC_WANA10H);
-		if (cmd->advertising & ADVERTISED_100baseT_Full)
+		if (advertising & ADVERTISED_100baseT_Full)
 			ctrl |= WMC_WANA100F;
-		if (cmd->advertising & ADVERTISED_100baseT_Half)
+		if (advertising & ADVERTISED_100baseT_Half)
 			ctrl |= WMC_WANA100H;
-		if (cmd->advertising & ADVERTISED_10baseT_Full)
+		if (advertising & ADVERTISED_10baseT_Full)
 			ctrl |= WMC_WANA10F;
-		if (cmd->advertising & ADVERTISED_10baseT_Half)
+		if (advertising & ADVERTISED_10baseT_Half)
 			ctrl |= WMC_WANA10H;
 
 		/* force a re-negotiation */
@@ -961,9 +970,9 @@ static int ks8695_poll(struct napi_struct *napi, int budget)
 		ctrl |= WMC_WAND;
 		ctrl &= ~(WMC_WANF100 | WMC_WANFF);
 
-		if (cmd->speed == SPEED_100)
+		if (cmd->base.speed == SPEED_100)
 			ctrl |= WMC_WANF100;
-		if (cmd->duplex == DUPLEX_FULL)
+		if (cmd->base.duplex == DUPLEX_FULL)
 			ctrl |= WMC_WANFF;
 
 		writel(ctrl, ksp->phyiface_regs + KS8695_WMC);
@@ -1042,12 +1051,12 @@ static int ks8695_poll(struct napi_struct *napi, int budget)
 static const struct ethtool_ops ks8695_wan_ethtool_ops = {
 	.get_msglevel	= ks8695_get_msglevel,
 	.set_msglevel	= ks8695_set_msglevel,
-	.get_settings	= ks8695_wan_get_settings,
-	.set_settings	= ks8695_wan_set_settings,
 	.nway_reset	= ks8695_wan_nwayreset,
 	.get_link	= ethtool_op_get_link,
 	.get_pauseparam = ks8695_wan_get_pause,
 	.get_drvinfo	= ks8695_get_drvinfo,
+	.get_link_ksettings = ks8695_wan_get_link_ksettings,
+	.set_link_ksettings = ks8695_wan_set_link_ksettings,
 };
 
 /* Network device interface functions */
-- 
1.7.4.4
