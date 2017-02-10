From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: natsemi: ns83820: use new api ethtool_{get|set}_link_ksettings
Date: Fri, 10 Feb 2017 23:57:48 +0100
Message-ID: <1486767468-20242-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com, weiyongjun1@huawei.com,
        javier@osg.samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34096 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdBJW56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 17:57:58 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so9354675wmi.1
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 14:57:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/natsemi/ns83820.c |   46 +++++++++++++++++--------------
 1 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index f9d2eb9..729095d 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1217,12 +1217,13 @@ static void ns83820_update_stats(struct ns83820 *dev)
 }
 
 /* Let ethtool retrieve info */
-static int ns83820_get_settings(struct net_device *ndev,
-				struct ethtool_cmd *cmd)
+static int ns83820_get_link_ksettings(struct net_device *ndev,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	u32 cfg, tanar, tbicr;
 	int fullduplex   = 0;
+	u32 supported;
 
 	/*
 	 * Here's the list of available ethtool commands from other drivers:
@@ -1244,44 +1245,47 @@ static int ns83820_get_settings(struct net_device *ndev,
 
 	fullduplex = (cfg & CFG_DUPSTS) ? 1 : 0;
 
-	cmd->supported = SUPPORTED_Autoneg;
+	supported = SUPPORTED_Autoneg;
 
 	if (dev->CFG_cache & CFG_TBI_EN) {
 		/* we have optical interface */
-		cmd->supported |= SUPPORTED_1000baseT_Half |
+		supported |= SUPPORTED_1000baseT_Half |
 					SUPPORTED_1000baseT_Full |
 					SUPPORTED_FIBRE;
-		cmd->port       = PORT_FIBRE;
+		cmd->base.port       = PORT_FIBRE;
 	} else {
 		/* we have copper */
-		cmd->supported |= SUPPORTED_10baseT_Half |
+		supported |= SUPPORTED_10baseT_Half |
 			SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Half |
 			SUPPORTED_100baseT_Full | SUPPORTED_1000baseT_Half |
 			SUPPORTED_1000baseT_Full |
 			SUPPORTED_MII;
-		cmd->port = PORT_MII;
+		cmd->base.port = PORT_MII;
 	}
 
-	cmd->duplex = fullduplex ? DUPLEX_FULL : DUPLEX_HALF;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+
+	cmd->base.duplex = fullduplex ? DUPLEX_FULL : DUPLEX_HALF;
 	switch (cfg / CFG_SPDSTS0 & 3) {
 	case 2:
-		ethtool_cmd_speed_set(cmd, SPEED_1000);
+		cmd->base.speed = SPEED_1000;
 		break;
 	case 1:
-		ethtool_cmd_speed_set(cmd, SPEED_100);
+		cmd->base.speed = SPEED_100;
 		break;
 	default:
-		ethtool_cmd_speed_set(cmd, SPEED_10);
+		cmd->base.speed = SPEED_10;
 		break;
 	}
-	cmd->autoneg = (tbicr & TBICR_MR_AN_ENABLE)
+	cmd->base.autoneg = (tbicr & TBICR_MR_AN_ENABLE)
 		? AUTONEG_ENABLE : AUTONEG_DISABLE;
 	return 0;
 }
 
 /* Let ethool change settings*/
-static int ns83820_set_settings(struct net_device *ndev,
-				struct ethtool_cmd *cmd)
+static int ns83820_set_link_ksettings(struct net_device *ndev,
+				      const struct ethtool_link_ksettings *cmd)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	u32 cfg, tanar;
@@ -1306,10 +1310,10 @@ static int ns83820_set_settings(struct net_device *ndev,
 	spin_lock(&dev->tx_lock);
 
 	/* Set duplex */
-	if (cmd->duplex != fullduplex) {
+	if (cmd->base.duplex != fullduplex) {
 		if (have_optical) {
 			/*set full duplex*/
-			if (cmd->duplex == DUPLEX_FULL) {
+			if (cmd->base.duplex == DUPLEX_FULL) {
 				/* force full duplex */
 				writel(readl(dev->base + TXCFG)
 					| TXCFG_CSI | TXCFG_HBI | TXCFG_ATP,
@@ -1333,7 +1337,7 @@ static int ns83820_set_settings(struct net_device *ndev,
 
 	/* Set autonegotiation */
 	if (1) {
-		if (cmd->autoneg == AUTONEG_ENABLE) {
+		if (cmd->base.autoneg == AUTONEG_ENABLE) {
 			/* restart auto negotiation */
 			writel(TBICR_MR_AN_ENABLE | TBICR_MR_RESTART_AN,
 				dev->base + TBICR);
@@ -1348,7 +1352,7 @@ static int ns83820_set_settings(struct net_device *ndev,
 		}
 
 		printk(KERN_INFO "%s: autoneg %s via ethtool\n", ndev->name,
-				cmd->autoneg ? "ENABLED" : "DISABLED");
+				cmd->base.autoneg ? "ENABLED" : "DISABLED");
 	}
 
 	phy_intr(ndev);
@@ -1375,10 +1379,10 @@ static u32 ns83820_get_link(struct net_device *ndev)
 }
 
 static const struct ethtool_ops ops = {
-	.get_settings    = ns83820_get_settings,
-	.set_settings    = ns83820_set_settings,
 	.get_drvinfo     = ns83820_get_drvinfo,
-	.get_link        = ns83820_get_link
+	.get_link        = ns83820_get_link,
+	.get_link_ksettings = ns83820_get_link_ksettings,
+	.set_link_ksettings = ns83820_set_link_ksettings,
 };
 
 static inline void ns83820_disable_interrupts(struct ns83820 *dev)
-- 
1.7.4.4
