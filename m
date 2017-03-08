From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: via: via-velocity: use new api ethtool_{get|set}_link_ksettings
Date: Wed,  8 Mar 2017 22:20:20 +0100
Message-ID: <1489008020-29021-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: romieu@fr.zoreil.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/via/via-velocity.c |   62 +++++++++++++++++-------------
 1 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index d088788..ef9538e 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -3291,15 +3291,17 @@ static void velocity_ethtool_down(struct net_device *dev)
 		velocity_set_power_state(vptr, PCI_D3hot);
 }
 
-static int velocity_get_settings(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
+static int velocity_get_link_ksettings(struct net_device *dev,
+				       struct ethtool_link_ksettings *cmd)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 	struct mac_regs __iomem *regs = vptr->mac_regs;
 	u32 status;
+	u32 supported, advertising;
+
 	status = check_connection_type(vptr->mac_regs);
 
-	cmd->supported = SUPPORTED_TP |
+	supported = SUPPORTED_TP |
 			SUPPORTED_Autoneg |
 			SUPPORTED_10baseT_Half |
 			SUPPORTED_10baseT_Full |
@@ -3308,9 +3310,9 @@ static int velocity_get_settings(struct net_device *dev,
 			SUPPORTED_1000baseT_Half |
 			SUPPORTED_1000baseT_Full;
 
-	cmd->advertising = ADVERTISED_TP | ADVERTISED_Autoneg;
+	advertising = ADVERTISED_TP | ADVERTISED_Autoneg;
 	if (vptr->options.spd_dpx == SPD_DPX_AUTO) {
-		cmd->advertising |=
+		advertising |=
 			ADVERTISED_10baseT_Half |
 			ADVERTISED_10baseT_Full |
 			ADVERTISED_100baseT_Half |
@@ -3320,19 +3322,19 @@ static int velocity_get_settings(struct net_device *dev,
 	} else {
 		switch (vptr->options.spd_dpx) {
 		case SPD_DPX_1000_FULL:
-			cmd->advertising |= ADVERTISED_1000baseT_Full;
+			advertising |= ADVERTISED_1000baseT_Full;
 			break;
 		case SPD_DPX_100_HALF:
-			cmd->advertising |= ADVERTISED_100baseT_Half;
+			advertising |= ADVERTISED_100baseT_Half;
 			break;
 		case SPD_DPX_100_FULL:
-			cmd->advertising |= ADVERTISED_100baseT_Full;
+			advertising |= ADVERTISED_100baseT_Full;
 			break;
 		case SPD_DPX_10_HALF:
-			cmd->advertising |= ADVERTISED_10baseT_Half;
+			advertising |= ADVERTISED_10baseT_Half;
 			break;
 		case SPD_DPX_10_FULL:
-			cmd->advertising |= ADVERTISED_10baseT_Full;
+			advertising |= ADVERTISED_10baseT_Full;
 			break;
 		default:
 			break;
@@ -3340,30 +3342,35 @@ static int velocity_get_settings(struct net_device *dev,
 	}
 
 	if (status & VELOCITY_SPEED_1000)
-		ethtool_cmd_speed_set(cmd, SPEED_1000);
+		cmd->base.speed = SPEED_1000;
 	else if (status & VELOCITY_SPEED_100)
-		ethtool_cmd_speed_set(cmd, SPEED_100);
+		cmd->base.speed = SPEED_100;
 	else
-		ethtool_cmd_speed_set(cmd, SPEED_10);
+		cmd->base.speed = SPEED_10;
 
-	cmd->autoneg = (status & VELOCITY_AUTONEG_ENABLE) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
-	cmd->port = PORT_TP;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->phy_address = readb(&regs->MIIADR) & 0x1F;
+	cmd->base.autoneg = (status & VELOCITY_AUTONEG_ENABLE) ?
+		AUTONEG_ENABLE : AUTONEG_DISABLE;
+	cmd->base.port = PORT_TP;
+	cmd->base.phy_address = readb(&regs->MIIADR) & 0x1F;
 
 	if (status & VELOCITY_DUPLEX_FULL)
-		cmd->duplex = DUPLEX_FULL;
+		cmd->base.duplex = DUPLEX_FULL;
 	else
-		cmd->duplex = DUPLEX_HALF;
+		cmd->base.duplex = DUPLEX_HALF;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
-static int velocity_set_settings(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
+static int velocity_set_link_ksettings(struct net_device *dev,
+				       const struct ethtool_link_ksettings *cmd)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
-	u32 speed = ethtool_cmd_speed(cmd);
+	u32 speed = cmd->base.speed;
 	u32 curr_status;
 	u32 new_status = 0;
 	int ret = 0;
@@ -3371,11 +3378,12 @@ static int velocity_set_settings(struct net_device *dev,
 	curr_status = check_connection_type(vptr->mac_regs);
 	curr_status &= (~VELOCITY_LINK_FAIL);
 
-	new_status |= ((cmd->autoneg) ? VELOCITY_AUTONEG_ENABLE : 0);
+	new_status |= ((cmd->base.autoneg) ? VELOCITY_AUTONEG_ENABLE : 0);
 	new_status |= ((speed == SPEED_1000) ? VELOCITY_SPEED_1000 : 0);
 	new_status |= ((speed == SPEED_100) ? VELOCITY_SPEED_100 : 0);
 	new_status |= ((speed == SPEED_10) ? VELOCITY_SPEED_10 : 0);
-	new_status |= ((cmd->duplex == DUPLEX_FULL) ? VELOCITY_DUPLEX_FULL : 0);
+	new_status |= ((cmd->base.duplex == DUPLEX_FULL) ?
+		       VELOCITY_DUPLEX_FULL : 0);
 
 	if ((new_status & VELOCITY_AUTONEG_ENABLE) &&
 	    (new_status != (curr_status | VELOCITY_AUTONEG_ENABLE))) {
@@ -3644,8 +3652,6 @@ static void velocity_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops velocity_ethtool_ops = {
-	.get_settings		= velocity_get_settings,
-	.set_settings		= velocity_set_settings,
 	.get_drvinfo		= velocity_get_drvinfo,
 	.get_wol		= velocity_ethtool_get_wol,
 	.set_wol		= velocity_ethtool_set_wol,
@@ -3658,7 +3664,9 @@ static void velocity_get_ethtool_stats(struct net_device *dev,
 	.get_coalesce		= velocity_get_coalesce,
 	.set_coalesce		= velocity_set_coalesce,
 	.begin			= velocity_ethtool_up,
-	.complete		= velocity_ethtool_down
+	.complete		= velocity_ethtool_down,
+	.get_link_ksettings	= velocity_get_link_ksettings,
+	.set_link_ksettings	= velocity_set_link_ksettings,
 };
 
 #if defined(CONFIG_PM) && defined(CONFIG_INET)
-- 
1.7.4.4
