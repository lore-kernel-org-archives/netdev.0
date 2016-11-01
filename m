From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 3/3] net: 3c509: use new api ethtool_{get|set}_link_ksettings
Date: Tue,  1 Nov 2016 16:32:27 +0100
Message-ID: <1478014347-14994-3-git-send-email-tremyfr@gmail.com>
References: <1478014347-14994-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: klassert@mathematik.tu-chemnitz.de, davem@davemloft.net,
        mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com,
        fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34605 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbcKAPcl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:32:41 -0400
In-Reply-To: <1478014347-14994-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/3com/3c509.c |   55 +++++++++++++++++++-----------------
 1 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 9f9a5f4..a753378 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -1040,67 +1040,68 @@ static void update_stats(struct net_device *dev)
 }
 
 static int
-el3_netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
+el3_netdev_get_ecmd(struct net_device *dev, struct ethtool_link_ksettings *cmd)
 {
 	u16 tmp;
 	int ioaddr = dev->base_addr;
+	u32 supported;
 
 	EL3WINDOW(0);
 	/* obtain current transceiver via WN4_MEDIA? */
 	tmp = inw(ioaddr + WN0_ADDR_CONF);
-	ecmd->transceiver = XCVR_INTERNAL;
 	switch (tmp >> 14) {
 	case 0:
-		ecmd->port = PORT_TP;
+		cmd->base.port = PORT_TP;
 		break;
 	case 1:
-		ecmd->port = PORT_AUI;
-		ecmd->transceiver = XCVR_EXTERNAL;
+		cmd->base.port = PORT_AUI;
 		break;
 	case 3:
-		ecmd->port = PORT_BNC;
+		cmd->base.port = PORT_BNC;
 	default:
 		break;
 	}
 
-	ecmd->duplex = DUPLEX_HALF;
-	ecmd->supported = 0;
+	cmd->base.duplex = DUPLEX_HALF;
+	supported = 0;
 	tmp = inw(ioaddr + WN0_CONF_CTRL);
 	if (tmp & (1<<13))
-		ecmd->supported |= SUPPORTED_AUI;
+		supported |= SUPPORTED_AUI;
 	if (tmp & (1<<12))
-		ecmd->supported |= SUPPORTED_BNC;
+		supported |= SUPPORTED_BNC;
 	if (tmp & (1<<9)) {
-		ecmd->supported |= SUPPORTED_TP | SUPPORTED_10baseT_Half |
+		supported |= SUPPORTED_TP | SUPPORTED_10baseT_Half |
 				SUPPORTED_10baseT_Full;	/* hmm... */
 		EL3WINDOW(4);
 		tmp = inw(ioaddr + WN4_NETDIAG);
 		if (tmp & FD_ENABLE)
-			ecmd->duplex = DUPLEX_FULL;
+			cmd->base.duplex = DUPLEX_FULL;
 	}
 
-	ethtool_cmd_speed_set(ecmd, SPEED_10);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	cmd->base.speed = SPEED_10;
 	EL3WINDOW(1);
 	return 0;
 }
 
 static int
-el3_netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
+el3_netdev_set_ecmd(struct net_device *dev,
+		    const struct ethtool_link_ksettings *cmd)
 {
 	u16 tmp;
 	int ioaddr = dev->base_addr;
 
-	if (ecmd->speed != SPEED_10)
+	if (cmd->base.speed != SPEED_10)
 		return -EINVAL;
-	if ((ecmd->duplex != DUPLEX_HALF) && (ecmd->duplex != DUPLEX_FULL))
-		return -EINVAL;
-	if ((ecmd->transceiver != XCVR_INTERNAL) && (ecmd->transceiver != XCVR_EXTERNAL))
+	if ((cmd->base.duplex != DUPLEX_HALF) &&
+	    (cmd->base.duplex != DUPLEX_FULL))
 		return -EINVAL;
 
 	/* change XCVR type */
 	EL3WINDOW(0);
 	tmp = inw(ioaddr + WN0_ADDR_CONF);
-	switch (ecmd->port) {
+	switch (cmd->base.port) {
 	case PORT_TP:
 		tmp &= ~(3<<14);
 		dev->if_port = 0;
@@ -1130,7 +1131,7 @@ static void update_stats(struct net_device *dev)
 
 	EL3WINDOW(4);
 	tmp = inw(ioaddr + WN4_NETDIAG);
-	if (ecmd->duplex == DUPLEX_FULL)
+	if (cmd->base.duplex == DUPLEX_FULL)
 		tmp |= FD_ENABLE;
 	else
 		tmp &= ~FD_ENABLE;
@@ -1146,24 +1147,26 @@ static void el3_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
-static int el3_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int el3_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct el3_private *lp = netdev_priv(dev);
 	int ret;
 
 	spin_lock_irq(&lp->lock);
-	ret = el3_netdev_get_ecmd(dev, ecmd);
+	ret = el3_netdev_get_ecmd(dev, cmd);
 	spin_unlock_irq(&lp->lock);
 	return ret;
 }
 
-static int el3_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int el3_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct el3_private *lp = netdev_priv(dev);
 	int ret;
 
 	spin_lock_irq(&lp->lock);
-	ret = el3_netdev_set_ecmd(dev, ecmd);
+	ret = el3_netdev_set_ecmd(dev, cmd);
 	spin_unlock_irq(&lp->lock);
 	return ret;
 }
@@ -1191,11 +1194,11 @@ static void el3_set_msglevel(struct net_device *dev, u32 v)
 
 static const struct ethtool_ops ethtool_ops = {
 	.get_drvinfo = el3_get_drvinfo,
-	.get_settings = el3_get_settings,
-	.set_settings = el3_set_settings,
 	.get_link = el3_get_link,
 	.get_msglevel = el3_get_msglevel,
 	.set_msglevel = el3_set_msglevel,
+	.get_link_ksettings = el3_get_link_ksettings,
+	.set_link_ksettings = el3_set_link_ksettings,
 };
 
 static void
-- 
1.7.4.4
