From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: alteon: acenic: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  5 Nov 2016 16:17:54 +0100
Message-ID: <1478359074-23941-1-git-send-email-tremyfr@gmail.com>
Cc: linux-acenic@sunsite.dk, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jes@trained-monkey.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/alteon/acenic.c |   65 ++++++++++++++++++---------------
 1 files changed, 35 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index a5c1e29..16f0c70 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -429,14 +429,16 @@
   "acenic.c: v0.92 08/05/2002  Jes Sorensen, linux-acenic@SunSITE.dk\n"
   "                            http://home.cern.ch/~jes/gige/acenic.html\n";
 
-static int ace_get_settings(struct net_device *, struct ethtool_cmd *);
-static int ace_set_settings(struct net_device *, struct ethtool_cmd *);
+static int ace_get_link_ksettings(struct net_device *,
+				  struct ethtool_link_ksettings *);
+static int ace_set_link_ksettings(struct net_device *,
+				  const struct ethtool_link_ksettings *);
 static void ace_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
 
 static const struct ethtool_ops ace_ethtool_ops = {
-	.get_settings = ace_get_settings,
-	.set_settings = ace_set_settings,
 	.get_drvinfo = ace_get_drvinfo,
+	.get_link_ksettings = ace_get_link_ksettings,
+	.set_link_ksettings = ace_set_link_ksettings,
 };
 
 static void ace_watchdog(struct net_device *dev);
@@ -2579,43 +2581,44 @@ static int ace_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static int ace_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int ace_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 	u32 link;
+	u32 supported;
 
-	memset(ecmd, 0, sizeof(struct ethtool_cmd));
-	ecmd->supported =
-		(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
-		 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
-		 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full |
-		 SUPPORTED_Autoneg | SUPPORTED_FIBRE);
+	memset(cmd, 0, sizeof(struct ethtool_link_ksettings));
 
-	ecmd->port = PORT_FIBRE;
-	ecmd->transceiver = XCVR_INTERNAL;
+	supported = (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
+		     SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
+		     SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full |
+		     SUPPORTED_Autoneg | SUPPORTED_FIBRE);
+
+	cmd->base.port = PORT_FIBRE;
 
 	link = readl(&regs->GigLnkState);
-	if (link & LNK_1000MB)
-		ethtool_cmd_speed_set(ecmd, SPEED_1000);
-	else {
+	if (link & LNK_1000MB) {
+		cmd->base.speed = SPEED_1000;
+	} else {
 		link = readl(&regs->FastLnkState);
 		if (link & LNK_100MB)
-			ethtool_cmd_speed_set(ecmd, SPEED_100);
+			cmd->base.speed = SPEED_100;
 		else if (link & LNK_10MB)
-			ethtool_cmd_speed_set(ecmd, SPEED_10);
+			cmd->base.speed = SPEED_10;
 		else
-			ethtool_cmd_speed_set(ecmd, 0);
+			cmd->base.speed = 0;
 	}
 	if (link & LNK_FULL_DUPLEX)
-		ecmd->duplex = DUPLEX_FULL;
+		cmd->base.duplex = DUPLEX_FULL;
 	else
-		ecmd->duplex = DUPLEX_HALF;
+		cmd->base.duplex = DUPLEX_HALF;
 
 	if (link & LNK_NEGOTIATE)
-		ecmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	else
-		ecmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 
 #if 0
 	/*
@@ -2626,13 +2629,15 @@ static int ace_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	ecmd->txcoal = readl(&regs->TuneTxCoalTicks);
 	ecmd->rxcoal = readl(&regs->TuneRxCoalTicks);
 #endif
-	ecmd->maxtxpkt = readl(&regs->TuneMaxTxDesc);
-	ecmd->maxrxpkt = readl(&regs->TuneMaxRxDesc);
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
 
 	return 0;
 }
 
-static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int ace_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
@@ -2655,11 +2660,11 @@ static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		LNK_RX_FLOW_CTL_Y | LNK_NEG_FCTL;
 	if (!ACE_IS_TIGON_I(ap))
 		link |= LNK_TX_FLOW_CTL_Y;
-	if (ecmd->autoneg == AUTONEG_ENABLE)
+	if (cmd->base.autoneg == AUTONEG_ENABLE)
 		link |= LNK_NEGOTIATE;
-	if (ethtool_cmd_speed(ecmd) != speed) {
+	if (cmd->base.speed != speed) {
 		link &= ~(LNK_1000MB | LNK_100MB | LNK_10MB);
-		switch (ethtool_cmd_speed(ecmd)) {
+		switch (cmd->base.speed) {
 		case SPEED_1000:
 			link |= LNK_1000MB;
 			break;
@@ -2672,7 +2677,7 @@ static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		}
 	}
 
-	if (ecmd->duplex == DUPLEX_FULL)
+	if (cmd->base.duplex == DUPLEX_FULL)
 		link |= LNK_FULL_DUPLEX;
 
 	if (link != ap->link) {
-- 
1.7.4.4
