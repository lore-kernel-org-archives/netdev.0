From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: ibm: ehea: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  7 Jan 2017 17:47:47 +0100
Message-ID: <1483807667-18264-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: dougmill@linux.vnet.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33122 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752059AbdAGQsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 11:48:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_ethtool.c |   51 +++++++++++++++-----------
 1 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
index 85a3866..4f58d33 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
@@ -31,9 +31,11 @@
 #include "ehea.h"
 #include "ehea_phyp.h"
 
-static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ehea_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct ehea_port *port = netdev_priv(dev);
+	u32 supported, advertising;
 	u32 speed;
 	int ret;
 
@@ -60,68 +62,75 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			speed = -1;
 			break; /* BUG */
 		}
-		cmd->duplex = port->full_duplex == 1 ?
+		cmd->base.duplex = port->full_duplex == 1 ?
 						     DUPLEX_FULL : DUPLEX_HALF;
 	} else {
 		speed = SPEED_UNKNOWN;
-		cmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
-	ethtool_cmd_speed_set(cmd, speed);
+	cmd->base.speed = speed;
 
-	if (cmd->speed == SPEED_10000) {
-		cmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-		cmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-		cmd->port = PORT_FIBRE;
+	if (cmd->base.speed == SPEED_10000) {
+		supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+		advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
+		cmd->base.port = PORT_FIBRE;
 	} else {
-		cmd->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full
+		supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full
 			       | SUPPORTED_100baseT_Half | SUPPORTED_10baseT_Full
 			       | SUPPORTED_10baseT_Half | SUPPORTED_Autoneg
 			       | SUPPORTED_TP);
-		cmd->advertising = (ADVERTISED_1000baseT_Full | ADVERTISED_Autoneg
+		advertising = (ADVERTISED_1000baseT_Full | ADVERTISED_Autoneg
 				 | ADVERTISED_TP);
-		cmd->port = PORT_TP;
+		cmd->base.port = PORT_TP;
 	}
 
-	cmd->autoneg = port->autoneg == 1 ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	cmd->base.autoneg = port->autoneg == 1 ?
+		AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
-static int ehea_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ehea_set_link_ksettings(struct net_device *dev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	int ret = 0;
 	u32 sp;
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		sp = EHEA_SPEED_AUTONEG;
 		goto doit;
 	}
 
-	switch (cmd->speed) {
+	switch (cmd->base.speed) {
 	case SPEED_10:
-		if (cmd->duplex == DUPLEX_FULL)
+		if (cmd->base.duplex == DUPLEX_FULL)
 			sp = H_SPEED_10M_F;
 		else
 			sp = H_SPEED_10M_H;
 		break;
 
 	case SPEED_100:
-		if (cmd->duplex == DUPLEX_FULL)
+		if (cmd->base.duplex == DUPLEX_FULL)
 			sp = H_SPEED_100M_F;
 		else
 			sp = H_SPEED_100M_H;
 		break;
 
 	case SPEED_1000:
-		if (cmd->duplex == DUPLEX_FULL)
+		if (cmd->base.duplex == DUPLEX_FULL)
 			sp = H_SPEED_1G_F;
 		else
 			ret = -EINVAL;
 		break;
 
 	case SPEED_10000:
-		if (cmd->duplex == DUPLEX_FULL)
+		if (cmd->base.duplex == DUPLEX_FULL)
 			sp = H_SPEED_10G_F;
 		else
 			ret = -EINVAL;
@@ -264,7 +273,6 @@ static void ehea_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops ehea_ethtool_ops = {
-	.get_settings = ehea_get_settings,
 	.get_drvinfo = ehea_get_drvinfo,
 	.get_msglevel = ehea_get_msglevel,
 	.set_msglevel = ehea_set_msglevel,
@@ -272,8 +280,9 @@ static void ehea_get_ethtool_stats(struct net_device *dev,
 	.get_strings = ehea_get_strings,
 	.get_sset_count = ehea_get_sset_count,
 	.get_ethtool_stats = ehea_get_ethtool_stats,
-	.set_settings = ehea_set_settings,
 	.nway_reset = ehea_nway_reset,		/* Restart autonegotiation */
+	.get_link_ksettings = ehea_get_link_ksettings,
+	.set_link_ksettings = ehea_set_link_ksettings,
 };
 
 void ehea_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
