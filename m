From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sun: cassini: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  4 Mar 2017 16:16:12 +0100
Message-ID: <1488640572-11174-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36244 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752105AbdCDPQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 10:16:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sun/cassini.c |   98 +++++++++++++++++++-----------------
 1 files changed, 52 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 0e8e89f..382993c 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -691,7 +691,8 @@ static void cas_mif_poll(struct cas *cp, const int enable)
 }
 
 /* Must be invoked under cp->lock */
-static void cas_begin_auto_negotiation(struct cas *cp, struct ethtool_cmd *ep)
+static void cas_begin_auto_negotiation(struct cas *cp,
+				       const struct ethtool_link_ksettings *ep)
 {
 	u16 ctl;
 #if 1
@@ -704,16 +705,16 @@ static void cas_begin_auto_negotiation(struct cas *cp, struct ethtool_cmd *ep)
 	if (!ep)
 		goto start_aneg;
 	lcntl = cp->link_cntl;
-	if (ep->autoneg == AUTONEG_ENABLE)
+	if (ep->base.autoneg == AUTONEG_ENABLE) {
 		cp->link_cntl = BMCR_ANENABLE;
-	else {
-		u32 speed = ethtool_cmd_speed(ep);
+	} else {
+		u32 speed = ep->base.speed;
 		cp->link_cntl = 0;
 		if (speed == SPEED_100)
 			cp->link_cntl |= BMCR_SPEED100;
 		else if (speed == SPEED_1000)
 			cp->link_cntl |= CAS_BMCR_SPEED1000;
-		if (ep->duplex == DUPLEX_FULL)
+		if (ep->base.duplex == DUPLEX_FULL)
 			cp->link_cntl |= BMCR_FULLDPLX;
 	}
 #if 1
@@ -4528,19 +4529,21 @@ static void cas_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	strlcpy(info->bus_info, pci_name(cp->pdev), sizeof(info->bus_info));
 }
 
-static int cas_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int cas_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct cas *cp = netdev_priv(dev);
 	u16 bmcr;
 	int full_duplex, speed, pause;
 	unsigned long flags;
 	enum link_state linkstate = link_up;
+	u32 supported, advertising;
 
-	cmd->advertising = 0;
-	cmd->supported = SUPPORTED_Autoneg;
+	advertising = 0;
+	supported = SUPPORTED_Autoneg;
 	if (cp->cas_flags & CAS_FLAG_1000MB_CAP) {
-		cmd->supported |= SUPPORTED_1000baseT_Full;
-		cmd->advertising |= ADVERTISED_1000baseT_Full;
+		supported |= SUPPORTED_1000baseT_Full;
+		advertising |= ADVERTISED_1000baseT_Full;
 	}
 
 	/* Record PHY settings if HW is on. */
@@ -4548,17 +4551,15 @@ static int cas_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	bmcr = 0;
 	linkstate = cp->lstate;
 	if (CAS_PHY_MII(cp->phy_type)) {
-		cmd->port = PORT_MII;
-		cmd->transceiver = (cp->cas_flags & CAS_FLAG_SATURN) ?
-			XCVR_INTERNAL : XCVR_EXTERNAL;
-		cmd->phy_address = cp->phy_addr;
-		cmd->advertising |= ADVERTISED_TP | ADVERTISED_MII |
+		cmd->base.port = PORT_MII;
+		cmd->base.phy_address = cp->phy_addr;
+		advertising |= ADVERTISED_TP | ADVERTISED_MII |
 			ADVERTISED_10baseT_Half |
 			ADVERTISED_10baseT_Full |
 			ADVERTISED_100baseT_Half |
 			ADVERTISED_100baseT_Full;
 
-		cmd->supported |=
+		supported |=
 			(SUPPORTED_10baseT_Half |
 			 SUPPORTED_10baseT_Full |
 			 SUPPORTED_100baseT_Half |
@@ -4574,11 +4575,10 @@ static int cas_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		}
 
 	} else {
-		cmd->port = PORT_FIBRE;
-		cmd->transceiver = XCVR_INTERNAL;
-		cmd->phy_address = 0;
-		cmd->supported   |= SUPPORTED_FIBRE;
-		cmd->advertising |= ADVERTISED_FIBRE;
+		cmd->base.port = PORT_FIBRE;
+		cmd->base.phy_address = 0;
+		supported   |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
 
 		if (cp->hw_running) {
 			/* pcs uses the same bits as mii */
@@ -4590,21 +4590,20 @@ static int cas_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	spin_unlock_irqrestore(&cp->lock, flags);
 
 	if (bmcr & BMCR_ANENABLE) {
-		cmd->advertising |= ADVERTISED_Autoneg;
-		cmd->autoneg = AUTONEG_ENABLE;
-		ethtool_cmd_speed_set(cmd, ((speed == 10) ?
+		advertising |= ADVERTISED_Autoneg;
+		cmd->base.autoneg = AUTONEG_ENABLE;
+		cmd->base.speed =  ((speed == 10) ?
 					    SPEED_10 :
 					    ((speed == 1000) ?
-					     SPEED_1000 : SPEED_100)));
-		cmd->duplex = full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
+					     SPEED_1000 : SPEED_100));
+		cmd->base.duplex = full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
 	} else {
-		cmd->autoneg = AUTONEG_DISABLE;
-		ethtool_cmd_speed_set(cmd, ((bmcr & CAS_BMCR_SPEED1000) ?
+		cmd->base.autoneg = AUTONEG_DISABLE;
+		cmd->base.speed = ((bmcr & CAS_BMCR_SPEED1000) ?
 					    SPEED_1000 :
 					    ((bmcr & BMCR_SPEED100) ?
-					     SPEED_100 : SPEED_10)));
-		cmd->duplex =
-			(bmcr & BMCR_FULLDPLX) ?
+					     SPEED_100 : SPEED_10));
+		cmd->base.duplex = (bmcr & BMCR_FULLDPLX) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 	}
 	if (linkstate != link_up) {
@@ -4619,39 +4618,46 @@ static int cas_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		 * settings that we configured.
 		 */
 		if (cp->link_cntl & BMCR_ANENABLE) {
-			ethtool_cmd_speed_set(cmd, 0);
-			cmd->duplex = 0xff;
+			cmd->base.speed = 0;
+			cmd->base.duplex = 0xff;
 		} else {
-			ethtool_cmd_speed_set(cmd, SPEED_10);
+			cmd->base.speed = SPEED_10;
 			if (cp->link_cntl & BMCR_SPEED100) {
-				ethtool_cmd_speed_set(cmd, SPEED_100);
+				cmd->base.speed = SPEED_100;
 			} else if (cp->link_cntl & CAS_BMCR_SPEED1000) {
-				ethtool_cmd_speed_set(cmd, SPEED_1000);
+				cmd->base.speed = SPEED_1000;
 			}
-			cmd->duplex = (cp->link_cntl & BMCR_FULLDPLX)?
+			cmd->base.duplex = (cp->link_cntl & BMCR_FULLDPLX) ?
 				DUPLEX_FULL : DUPLEX_HALF;
 		}
 	}
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-static int cas_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int cas_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct cas *cp = netdev_priv(dev);
 	unsigned long flags;
-	u32 speed = ethtool_cmd_speed(cmd);
+	u32 speed = cmd->base.speed;
 
 	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE &&
-	    cmd->autoneg != AUTONEG_DISABLE)
+	if (cmd->base.autoneg != AUTONEG_ENABLE &&
+	    cmd->base.autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_DISABLE &&
+	if (cmd->base.autoneg == AUTONEG_DISABLE &&
 	    ((speed != SPEED_1000 &&
 	      speed != SPEED_100 &&
 	      speed != SPEED_10) ||
-	     (cmd->duplex != DUPLEX_HALF &&
-	      cmd->duplex != DUPLEX_FULL)))
+	     (cmd->base.duplex != DUPLEX_HALF &&
+	      cmd->base.duplex != DUPLEX_FULL)))
 		return -EINVAL;
 
 	/* Apply settings and restart link process. */
@@ -4753,8 +4759,6 @@ static void cas_get_ethtool_stats(struct net_device *dev,
 
 static const struct ethtool_ops cas_ethtool_ops = {
 	.get_drvinfo		= cas_get_drvinfo,
-	.get_settings		= cas_get_settings,
-	.set_settings		= cas_set_settings,
 	.nway_reset		= cas_nway_reset,
 	.get_link		= cas_get_link,
 	.get_msglevel		= cas_get_msglevel,
@@ -4764,6 +4768,8 @@ static void cas_get_ethtool_stats(struct net_device *dev,
 	.get_sset_count		= cas_get_sset_count,
 	.get_strings		= cas_get_strings,
 	.get_ethtool_stats	= cas_get_ethtool_stats,
+	.get_link_ksettings	= cas_get_link_ksettings,
+	.set_link_ksettings	= cas_set_link_ksettings,
 };
 
 static int cas_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-- 
1.7.4.4
