From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: smsc: smc911x: use new api ethtool_{get|set}_link_ksettings
Date: Tue, 28 Feb 2017 23:49:38 +0100
Message-ID: <1488322178-26972-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, a@unstable.cc, fw@strlen.de,
        robert.jarzmik@free.fr, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33541 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdB1Wtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 17:49:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/smsc/smc911x.c |   51 ++++++++++++++++++----------------
 1 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 4f19c61..36307d3 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1446,40 +1446,40 @@ static int smc911x_close(struct net_device *dev)
  * Ethtool support
  */
 static int
-smc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+smc911x_ethtool_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 	int ret, status;
 	unsigned long flags;
+	u32 supported;
 
 	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
-	cmd->maxtxpkt = 1;
-	cmd->maxrxpkt = 1;
 
 	if (lp->phy_type != 0) {
 		spin_lock_irqsave(&lp->lock, flags);
-		ret = mii_ethtool_gset(&lp->mii, cmd);
+		ret = mii_ethtool_get_link_ksettings(&lp->mii, cmd);
 		spin_unlock_irqrestore(&lp->lock, flags);
 	} else {
-		cmd->supported = SUPPORTED_10baseT_Half |
+		supported = SUPPORTED_10baseT_Half |
 				SUPPORTED_10baseT_Full |
 				SUPPORTED_TP | SUPPORTED_AUI;
 
 		if (lp->ctl_rspeed == 10)
-			ethtool_cmd_speed_set(cmd, SPEED_10);
+			cmd->base.speed = SPEED_10;
 		else if (lp->ctl_rspeed == 100)
-			ethtool_cmd_speed_set(cmd, SPEED_100);
-
-		cmd->autoneg = AUTONEG_DISABLE;
-		if (lp->mii.phy_id==1)
-			cmd->transceiver = XCVR_INTERNAL;
-		else
-			cmd->transceiver = XCVR_EXTERNAL;
-		cmd->port = 0;
+			cmd->base.speed = SPEED_100;
+
+		cmd->base.autoneg = AUTONEG_DISABLE;
+		cmd->base.port = 0;
 		SMC_GET_PHY_SPECIAL(lp, lp->mii.phy_id, status);
-		cmd->duplex =
+		cmd->base.duplex =
 			(status & (PHY_SPECIAL_SPD_10FULL_ | PHY_SPECIAL_SPD_100FULL_)) ?
 				DUPLEX_FULL : DUPLEX_HALF;
+
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.supported, supported);
+
 		ret = 0;
 	}
 
@@ -1487,7 +1487,8 @@ static int smc911x_close(struct net_device *dev)
 }
 
 static int
-smc911x_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+smc911x_ethtool_set_link_ksettings(struct net_device *dev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 	int ret;
@@ -1495,16 +1496,18 @@ static int smc911x_close(struct net_device *dev)
 
 	if (lp->phy_type != 0) {
 		spin_lock_irqsave(&lp->lock, flags);
-		ret = mii_ethtool_sset(&lp->mii, cmd);
+		ret = mii_ethtool_set_link_ksettings(&lp->mii, cmd);
 		spin_unlock_irqrestore(&lp->lock, flags);
 	} else {
-		if (cmd->autoneg != AUTONEG_DISABLE ||
-			cmd->speed != SPEED_10 ||
-			(cmd->duplex != DUPLEX_HALF && cmd->duplex != DUPLEX_FULL) ||
-			(cmd->port != PORT_TP && cmd->port != PORT_AUI))
+		if (cmd->base.autoneg != AUTONEG_DISABLE ||
+		    cmd->base.speed != SPEED_10 ||
+		    (cmd->base.duplex != DUPLEX_HALF &&
+		     cmd->base.duplex != DUPLEX_FULL) ||
+		    (cmd->base.port != PORT_TP &&
+		     cmd->base.port != PORT_AUI))
 			return -EINVAL;
 
-		lp->ctl_rfduplx = cmd->duplex == DUPLEX_FULL;
+		lp->ctl_rfduplx = cmd->base.duplex == DUPLEX_FULL;
 
 		ret = 0;
 	}
@@ -1686,8 +1689,6 @@ static int smc911x_ethtool_geteeprom_len(struct net_device *dev)
 }
 
 static const struct ethtool_ops smc911x_ethtool_ops = {
-	.get_settings	 = smc911x_ethtool_getsettings,
-	.set_settings	 = smc911x_ethtool_setsettings,
 	.get_drvinfo	 = smc911x_ethtool_getdrvinfo,
 	.get_msglevel	 = smc911x_ethtool_getmsglevel,
 	.set_msglevel	 = smc911x_ethtool_setmsglevel,
@@ -1698,6 +1699,8 @@ static int smc911x_ethtool_geteeprom_len(struct net_device *dev)
 	.get_eeprom_len = smc911x_ethtool_geteeprom_len,
 	.get_eeprom = smc911x_ethtool_geteeprom,
 	.set_eeprom = smc911x_ethtool_seteeprom,
+	.get_link_ksettings	 = smc911x_ethtool_get_link_ksettings,
+	.set_link_ksettings	 = smc911x_ethtool_set_link_ksettings,
 };
 
 /*
-- 
1.7.4.4
