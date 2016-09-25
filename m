From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: tg3: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 25 Sep 2016 23:31:24 +0200
Message-ID: <1474839084-10883-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: siva.kallam@broadcom.com, prashant@broadcom.com,
        mchan@broadcom.com, f.fainelli@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  112 +++++++++++++++++++----------------
 1 files changed, 62 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a2551bc..2726f03 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12079,95 +12079,107 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	return ret;
 }
 
-static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int tg3_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct tg3 *tp = netdev_priv(dev);
+	u32 supported, advertising;
 
 	if (tg3_flag(tp, USE_PHYLIB)) {
 		struct phy_device *phydev;
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
 		phydev = mdiobus_get_phy(tp->mdio_bus, tp->phy_addr);
-		return phy_ethtool_gset(phydev, cmd);
+		return phy_ethtool_ksettings_get(phydev, cmd);
 	}
 
-	cmd->supported = (SUPPORTED_Autoneg);
+	supported = (SUPPORTED_Autoneg);
 
 	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY))
-		cmd->supported |= (SUPPORTED_1000baseT_Half |
-				   SUPPORTED_1000baseT_Full);
+		supported |= (SUPPORTED_1000baseT_Half |
+			      SUPPORTED_1000baseT_Full);
 
 	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES)) {
-		cmd->supported |= (SUPPORTED_100baseT_Half |
-				  SUPPORTED_100baseT_Full |
-				  SUPPORTED_10baseT_Half |
-				  SUPPORTED_10baseT_Full |
-				  SUPPORTED_TP);
-		cmd->port = PORT_TP;
+		supported |= (SUPPORTED_100baseT_Half |
+			      SUPPORTED_100baseT_Full |
+			      SUPPORTED_10baseT_Half |
+			      SUPPORTED_10baseT_Full |
+			      SUPPORTED_TP);
+		cmd->base.port = PORT_TP;
 	} else {
-		cmd->supported |= SUPPORTED_FIBRE;
-		cmd->port = PORT_FIBRE;
+		supported |= SUPPORTED_FIBRE;
+		cmd->base.port = PORT_FIBRE;
 	}
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
 
-	cmd->advertising = tp->link_config.advertising;
+	advertising = tp->link_config.advertising;
 	if (tg3_flag(tp, PAUSE_AUTONEG)) {
 		if (tp->link_config.flowctrl & FLOW_CTRL_RX) {
 			if (tp->link_config.flowctrl & FLOW_CTRL_TX) {
-				cmd->advertising |= ADVERTISED_Pause;
+				advertising |= ADVERTISED_Pause;
 			} else {
-				cmd->advertising |= ADVERTISED_Pause |
-						    ADVERTISED_Asym_Pause;
+				advertising |= ADVERTISED_Pause |
+					ADVERTISED_Asym_Pause;
 			}
 		} else if (tp->link_config.flowctrl & FLOW_CTRL_TX) {
-			cmd->advertising |= ADVERTISED_Asym_Pause;
+			advertising |= ADVERTISED_Asym_Pause;
 		}
 	}
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	if (netif_running(dev) && tp->link_up) {
-		ethtool_cmd_speed_set(cmd, tp->link_config.active_speed);
-		cmd->duplex = tp->link_config.active_duplex;
-		cmd->lp_advertising = tp->link_config.rmt_adv;
+		cmd->base.speed = tp->link_config.active_speed;
+		cmd->base.duplex = tp->link_config.active_duplex;
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.lp_advertising,
+			tp->link_config.rmt_adv);
+
 		if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES)) {
 			if (tp->phy_flags & TG3_PHYFLG_MDIX_STATE)
-				cmd->eth_tp_mdix = ETH_TP_MDI_X;
+				cmd->base.eth_tp_mdix = ETH_TP_MDI_X;
 			else
-				cmd->eth_tp_mdix = ETH_TP_MDI;
+				cmd->base.eth_tp_mdix = ETH_TP_MDI;
 		}
 	} else {
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-		cmd->duplex = DUPLEX_UNKNOWN;
-		cmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
-	}
-	cmd->phy_address = tp->phy_addr;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->autoneg = tp->link_config.autoneg;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
+		cmd->base.eth_tp_mdix = ETH_TP_MDI_INVALID;
+	}
+	cmd->base.phy_address = tp->phy_addr;
+	cmd->base.autoneg = tp->link_config.autoneg;
 	return 0;
 }
 
-static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int tg3_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	u32 speed = ethtool_cmd_speed(cmd);
+	u32 speed = cmd->base.speed;
+	u32 advertising;
 
 	if (tg3_flag(tp, USE_PHYLIB)) {
 		struct phy_device *phydev;
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
 		phydev = mdiobus_get_phy(tp->mdio_bus, tp->phy_addr);
-		return phy_ethtool_sset(phydev, cmd);
+		return phy_ethtool_ksettings_set(phydev, cmd);
 	}
 
-	if (cmd->autoneg != AUTONEG_ENABLE &&
-	    cmd->autoneg != AUTONEG_DISABLE)
+	if (cmd->base.autoneg != AUTONEG_ENABLE &&
+	    cmd->base.autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_DISABLE &&
-	    cmd->duplex != DUPLEX_FULL &&
-	    cmd->duplex != DUPLEX_HALF)
+	if (cmd->base.autoneg == AUTONEG_DISABLE &&
+	    cmd->base.duplex != DUPLEX_FULL &&
+	    cmd->base.duplex != DUPLEX_HALF)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		u32 mask = ADVERTISED_Autoneg |
 			   ADVERTISED_Pause |
 			   ADVERTISED_Asym_Pause;
@@ -12185,7 +12197,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		else
 			mask |= ADVERTISED_FIBRE;
 
-		if (cmd->advertising & ~mask)
+		if (advertising & ~mask)
 			return -EINVAL;
 
 		mask &= (ADVERTISED_1000baseT_Half |
@@ -12195,13 +12207,13 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			 ADVERTISED_10baseT_Half |
 			 ADVERTISED_10baseT_Full);
 
-		cmd->advertising &= mask;
+		advertising &= mask;
 	} else {
 		if (tp->phy_flags & TG3_PHYFLG_ANY_SERDES) {
 			if (speed != SPEED_1000)
 				return -EINVAL;
 
-			if (cmd->duplex != DUPLEX_FULL)
+			if (cmd->base.duplex != DUPLEX_FULL)
 				return -EINVAL;
 		} else {
 			if (speed != SPEED_100 &&
@@ -12212,16 +12224,16 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	tg3_full_lock(tp, 0);
 
-	tp->link_config.autoneg = cmd->autoneg;
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		tp->link_config.advertising = (cmd->advertising |
+	tp->link_config.autoneg = cmd->base.autoneg;
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
+		tp->link_config.advertising = (advertising |
 					      ADVERTISED_Autoneg);
 		tp->link_config.speed = SPEED_UNKNOWN;
 		tp->link_config.duplex = DUPLEX_UNKNOWN;
 	} else {
 		tp->link_config.advertising = 0;
 		tp->link_config.speed = speed;
-		tp->link_config.duplex = cmd->duplex;
+		tp->link_config.duplex = cmd->base.duplex;
 	}
 
 	tp->phy_flags |= TG3_PHYFLG_USER_CONFIGURED;
@@ -14094,8 +14106,6 @@ static int tg3_get_eee(struct net_device *dev, struct ethtool_eee *edata)
 }
 
 static const struct ethtool_ops tg3_ethtool_ops = {
-	.get_settings		= tg3_get_settings,
-	.set_settings		= tg3_set_settings,
 	.get_drvinfo		= tg3_get_drvinfo,
 	.get_regs_len		= tg3_get_regs_len,
 	.get_regs		= tg3_get_regs,
@@ -14128,6 +14138,8 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.get_ts_info		= tg3_get_ts_info,
 	.get_eee		= tg3_get_eee,
 	.set_eee		= tg3_set_eee,
+	.get_link_ksettings	= tg3_get_link_ksettings,
+	.set_link_ksettings	= tg3_set_link_ksettings,
 };
 
 static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
-- 
1.7.4.4
