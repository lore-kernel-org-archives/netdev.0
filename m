From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: chelsio: cxgb3: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 12 Dec 2016 00:27:49 +0100
Message-ID: <1481498870-16946-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: santosh@chelsio.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34478 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753930AbcLKX16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 18:27:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c |   65 +++++++++++++----------
 1 files changed, 37 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 092b3c1..7b2224a 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1801,27 +1801,31 @@ static int set_phys_id(struct net_device *dev,
 	return 0;
 }
 
-static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int get_link_ksettings(struct net_device *dev,
+			      struct ethtool_link_ksettings *cmd)
 {
 	struct port_info *p = netdev_priv(dev);
+	u32 supported;
 
-	cmd->supported = p->link_config.supported;
-	cmd->advertising = p->link_config.advertising;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						p->link_config.supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						p->link_config.advertising);
 
 	if (netif_carrier_ok(dev)) {
-		ethtool_cmd_speed_set(cmd, p->link_config.speed);
-		cmd->duplex = p->link_config.duplex;
+		cmd->base.speed = p->link_config.speed;
+		cmd->base.duplex = p->link_config.duplex;
 	} else {
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-		cmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
-	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
-	cmd->phy_address = p->phy.mdio.prtad;
-	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->autoneg = p->link_config.autoneg;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+
+	cmd->base.port = (supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
+	cmd->base.phy_address = p->phy.mdio.prtad;
+	cmd->base.autoneg = p->link_config.autoneg;
 	return 0;
 }
 
@@ -1860,44 +1864,49 @@ static int speed_duplex_to_caps(int speed, int duplex)
 		      ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full | \
 		      ADVERTISED_10000baseT_Full)
 
-static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int set_link_ksettings(struct net_device *dev,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	struct port_info *p = netdev_priv(dev);
 	struct link_config *lc = &p->link_config;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	if (!(lc->supported & SUPPORTED_Autoneg)) {
 		/*
 		 * PHY offers a single speed/duplex.  See if that's what's
 		 * being requested.
 		 */
-		if (cmd->autoneg == AUTONEG_DISABLE) {
-			u32 speed = ethtool_cmd_speed(cmd);
-			int cap = speed_duplex_to_caps(speed, cmd->duplex);
+		if (cmd->base.autoneg == AUTONEG_DISABLE) {
+			u32 speed = cmd->base.speed;
+			int cap = speed_duplex_to_caps(speed, cmd->base.duplex);
 			if (lc->supported & cap)
 				return 0;
 		}
 		return -EINVAL;
 	}
 
-	if (cmd->autoneg == AUTONEG_DISABLE) {
-		u32 speed = ethtool_cmd_speed(cmd);
-		int cap = speed_duplex_to_caps(speed, cmd->duplex);
+	if (cmd->base.autoneg == AUTONEG_DISABLE) {
+		u32 speed = cmd->base.speed;
+		int cap = speed_duplex_to_caps(speed, cmd->base.duplex);
 
 		if (!(lc->supported & cap) || (speed == SPEED_1000))
 			return -EINVAL;
 		lc->requested_speed = speed;
-		lc->requested_duplex = cmd->duplex;
+		lc->requested_duplex = cmd->base.duplex;
 		lc->advertising = 0;
 	} else {
-		cmd->advertising &= ADVERTISED_MASK;
-		cmd->advertising &= lc->supported;
-		if (!cmd->advertising)
+		advertising &= ADVERTISED_MASK;
+		advertising &= lc->supported;
+		if (!advertising)
 			return -EINVAL;
 		lc->requested_speed = SPEED_INVALID;
 		lc->requested_duplex = DUPLEX_INVALID;
-		lc->advertising = cmd->advertising | ADVERTISED_Autoneg;
+		lc->advertising = advertising | ADVERTISED_Autoneg;
 	}
-	lc->autoneg = cmd->autoneg;
+	lc->autoneg = cmd->base.autoneg;
 	if (netif_running(dev))
 		t3_link_start(&p->phy, &p->mac, lc);
 	return 0;
@@ -2097,8 +2106,6 @@ static void get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 }
 
 static const struct ethtool_ops cxgb_ethtool_ops = {
-	.get_settings = get_settings,
-	.set_settings = set_settings,
 	.get_drvinfo = get_drvinfo,
 	.get_msglevel = get_msglevel,
 	.set_msglevel = set_msglevel,
@@ -2120,6 +2127,8 @@ static void get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	.get_regs_len = get_regs_len,
 	.get_regs = get_regs,
 	.get_wol = get_wol,
+	.get_link_ksettings = get_link_ksettings,
+	.set_link_ksettings = set_link_ksettings,
 };
 
 static int in_range(int val, int lo, int hi)
-- 
1.7.4.4
