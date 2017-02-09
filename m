From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: micrel: ksz884x: use new api ethtool_{get|set}_link_ksettings
Date: Thu,  9 Feb 2017 20:25:06 +0100
Message-ID: <1486668306-14381-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34841 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752890AbdBIT0K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:26:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |   62 ++++++++++++++++++++-------------
 1 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 97f6ef1..ee38c18 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -5944,7 +5944,7 @@ static void mdio_write(struct net_device *dev, int phy_id, int reg_num, int val)
 /* These functions use the MII functions in mii.c. */
 
 /**
- * netdev_get_settings - get network device settings
+ * netdev_get_link_ksettings - get network device settings
  * @dev:	Network device.
  * @cmd:	Ethtool command.
  *
@@ -5952,23 +5952,26 @@ static void mdio_write(struct net_device *dev, int phy_id, int reg_num, int val)
  *
  * Return 0 if successful; otherwise an error code.
  */
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct dev_priv *priv = netdev_priv(dev);
 	struct dev_info *hw_priv = priv->adapter;
 
 	mutex_lock(&hw_priv->lock);
-	mii_ethtool_gset(&priv->mii_if, cmd);
-	cmd->advertising |= SUPPORTED_TP;
+	mii_ethtool_get_link_ksettings(&priv->mii_if, cmd);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, TP);
 	mutex_unlock(&hw_priv->lock);
 
 	/* Save advertised settings for workaround in next function. */
-	priv->advertising = cmd->advertising;
+	ethtool_convert_link_mode_to_legacy_u32(&priv->advertising,
+						cmd->link_modes.advertising);
+
 	return 0;
 }
 
 /**
- * netdev_set_settings - set network device settings
+ * netdev_set_link_ksettings - set network device settings
  * @dev:	Network device.
  * @cmd:	Ethtool command.
  *
@@ -5976,54 +5979,65 @@ static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
  *
  * Return 0 if successful; otherwise an error code.
  */
-static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct dev_priv *priv = netdev_priv(dev);
 	struct dev_info *hw_priv = priv->adapter;
 	struct ksz_port *port = &priv->port;
-	u32 speed = ethtool_cmd_speed(cmd);
+	struct ethtool_link_ksettings copy_cmd;
+	u32 speed = cmd->base.speed;
+	u32 advertising;
 	int rc;
 
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+
 	/*
 	 * ethtool utility does not change advertised setting if auto
 	 * negotiation is not specified explicitly.
 	 */
-	if (cmd->autoneg && priv->advertising == cmd->advertising) {
-		cmd->advertising |= ADVERTISED_ALL;
+	if (cmd->base.autoneg && priv->advertising == advertising) {
+		advertising |= ADVERTISED_ALL;
 		if (10 == speed)
-			cmd->advertising &=
+			advertising &=
 				~(ADVERTISED_100baseT_Full |
 				ADVERTISED_100baseT_Half);
 		else if (100 == speed)
-			cmd->advertising &=
+			advertising &=
 				~(ADVERTISED_10baseT_Full |
 				ADVERTISED_10baseT_Half);
-		if (0 == cmd->duplex)
-			cmd->advertising &=
+		if (0 == cmd->base.duplex)
+			advertising &=
 				~(ADVERTISED_100baseT_Full |
 				ADVERTISED_10baseT_Full);
-		else if (1 == cmd->duplex)
-			cmd->advertising &=
+		else if (1 == cmd->base.duplex)
+			advertising &=
 				~(ADVERTISED_100baseT_Half |
 				ADVERTISED_10baseT_Half);
 	}
 	mutex_lock(&hw_priv->lock);
-	if (cmd->autoneg &&
-			(cmd->advertising & ADVERTISED_ALL) ==
-			ADVERTISED_ALL) {
+	if (cmd->base.autoneg &&
+	    (advertising & ADVERTISED_ALL) == ADVERTISED_ALL) {
 		port->duplex = 0;
 		port->speed = 0;
 		port->force_link = 0;
 	} else {
-		port->duplex = cmd->duplex + 1;
+		port->duplex = cmd->base.duplex + 1;
 		if (1000 != speed)
 			port->speed = speed;
-		if (cmd->autoneg)
+		if (cmd->base.autoneg)
 			port->force_link = 0;
 		else
 			port->force_link = 1;
 	}
-	rc = mii_ethtool_sset(&priv->mii_if, cmd);
+
+	memcpy(&copy_cmd, cmd, sizeof(copy_cmd));
+	ethtool_convert_legacy_u32_to_link_mode(copy_cmd.link_modes.advertising,
+						advertising);
+	rc = mii_ethtool_set_link_ksettings(
+		&priv->mii_if,
+		(const struct ethtool_link_ksettings *)&copy_cmd);
 	mutex_unlock(&hw_priv->lock);
 	return rc;
 }
@@ -6597,8 +6611,6 @@ static int netdev_set_features(struct net_device *dev,
 }
 
 static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_settings		= netdev_get_settings,
-	.set_settings		= netdev_set_settings,
 	.nway_reset		= netdev_nway_reset,
 	.get_link		= netdev_get_link,
 	.get_drvinfo		= netdev_get_drvinfo,
@@ -6617,6 +6629,8 @@ static int netdev_set_features(struct net_device *dev,
 	.get_strings		= netdev_get_strings,
 	.get_sset_count		= netdev_get_sset_count,
 	.get_ethtool_stats	= netdev_get_ethtool_stats,
+	.get_link_ksettings	= netdev_get_link_ksettings,
+	.set_link_ksettings	= netdev_set_link_ksettings,
 };
 
 /*
-- 
1.7.4.4
