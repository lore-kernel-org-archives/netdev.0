From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: smsc: smc91x: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  4 Mar 2017 11:11:32 +0100
Message-ID: <1488622292-13200-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: nico@fluxnic.net, davem@davemloft.net, robert.jarzmik@free.fr,
        mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, rmk+kernel@armlinux.org.uk,
        fw@strlen.de, jeremy.linton@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33418 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750818AbdCDKSz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 05:18:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/smsc/smc91x.c |   45 +++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 65077c7..23bac47 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1535,32 +1535,33 @@ static int smc_close(struct net_device *dev)
  * Ethtool support
  */
 static int
-smc_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+smc_ethtool_get_link_ksettings(struct net_device *dev,
+			       struct ethtool_link_ksettings *cmd)
 {
 	struct smc_local *lp = netdev_priv(dev);
 	int ret;
 
-	cmd->maxtxpkt = 1;
-	cmd->maxrxpkt = 1;
-
 	if (lp->phy_type != 0) {
 		spin_lock_irq(&lp->lock);
-		ret = mii_ethtool_gset(&lp->mii, cmd);
+		ret = mii_ethtool_get_link_ksettings(&lp->mii, cmd);
 		spin_unlock_irq(&lp->lock);
 	} else {
-		cmd->supported = SUPPORTED_10baseT_Half |
+		u32 supported = SUPPORTED_10baseT_Half |
 				 SUPPORTED_10baseT_Full |
 				 SUPPORTED_TP | SUPPORTED_AUI;
 
 		if (lp->ctl_rspeed == 10)
-			ethtool_cmd_speed_set(cmd, SPEED_10);
+			cmd->base.speed = SPEED_10;
 		else if (lp->ctl_rspeed == 100)
-			ethtool_cmd_speed_set(cmd, SPEED_100);
+			cmd->base.speed = SPEED_100;
+
+		cmd->base.autoneg = AUTONEG_DISABLE;
+		cmd->base.port = 0;
+		cmd->base.duplex = lp->tcr_cur_mode & TCR_SWFDUP ?
+			DUPLEX_FULL : DUPLEX_HALF;
 
-		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->transceiver = XCVR_INTERNAL;
-		cmd->port = 0;
-		cmd->duplex = lp->tcr_cur_mode & TCR_SWFDUP ? DUPLEX_FULL : DUPLEX_HALF;
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.supported, supported);
 
 		ret = 0;
 	}
@@ -1569,24 +1570,26 @@ static int smc_close(struct net_device *dev)
 }
 
 static int
-smc_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+smc_ethtool_set_link_ksettings(struct net_device *dev,
+			       const struct ethtool_link_ksettings *cmd)
 {
 	struct smc_local *lp = netdev_priv(dev);
 	int ret;
 
 	if (lp->phy_type != 0) {
 		spin_lock_irq(&lp->lock);
-		ret = mii_ethtool_sset(&lp->mii, cmd);
+		ret = mii_ethtool_set_link_ksettings(&lp->mii, cmd);
 		spin_unlock_irq(&lp->lock);
 	} else {
-		if (cmd->autoneg != AUTONEG_DISABLE ||
-		    cmd->speed != SPEED_10 ||
-		    (cmd->duplex != DUPLEX_HALF && cmd->duplex != DUPLEX_FULL) ||
-		    (cmd->port != PORT_TP && cmd->port != PORT_AUI))
+		if (cmd->base.autoneg != AUTONEG_DISABLE ||
+		    cmd->base.speed != SPEED_10 ||
+		    (cmd->base.duplex != DUPLEX_HALF &&
+		     cmd->base.duplex != DUPLEX_FULL) ||
+		    (cmd->base.port != PORT_TP && cmd->base.port != PORT_AUI))
 			return -EINVAL;
 
 //		lp->port = cmd->port;
-		lp->ctl_rfduplx = cmd->duplex == DUPLEX_FULL;
+		lp->ctl_rfduplx = cmd->base.duplex == DUPLEX_FULL;
 
 //		if (netif_running(dev))
 //			smc_set_port(dev);
@@ -1744,8 +1747,6 @@ static int smc_ethtool_seteeprom(struct net_device *dev,
 
 
 static const struct ethtool_ops smc_ethtool_ops = {
-	.get_settings	= smc_ethtool_getsettings,
-	.set_settings	= smc_ethtool_setsettings,
 	.get_drvinfo	= smc_ethtool_getdrvinfo,
 
 	.get_msglevel	= smc_ethtool_getmsglevel,
@@ -1755,6 +1756,8 @@ static int smc_ethtool_seteeprom(struct net_device *dev,
 	.get_eeprom_len = smc_ethtool_geteeprom_len,
 	.get_eeprom	= smc_ethtool_geteeprom,
 	.set_eeprom	= smc_ethtool_seteeprom,
+	.get_link_ksettings	= smc_ethtool_get_link_ksettings,
+	.set_link_ksettings	= smc_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops smc_netdev_ops = {
-- 
1.7.4.4
