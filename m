From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: microchip: encx24j600: use new api ethtool_{get|set}_link_ksettings
Date: Thu,  9 Feb 2017 22:42:18 +0100
Message-ID: <1486676538-3239-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jeroen.de_wachter.ext@nokia.com, fw@strlen.de,
        mugunthanvnm@ti.com, akpm@linux-foundation.org, pmladek@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/microchip/encx24j600.c |   32 +++++++++++++++-----------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index fbce616..f831238 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -940,29 +940,33 @@ static void encx24j600_get_drvinfo(struct net_device *dev,
 		sizeof(info->bus_info));
 }
 
-static int encx24j600_get_settings(struct net_device *dev,
-				   struct ethtool_cmd *cmd)
+static int encx24j600_get_link_ksettings(struct net_device *dev,
+					 struct ethtool_link_ksettings *cmd)
 {
 	struct encx24j600_priv *priv = netdev_priv(dev);
+	u32 supported;
 
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->supported = SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
+	supported = SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 			 SUPPORTED_Autoneg | SUPPORTED_TP;
 
-	ethtool_cmd_speed_set(cmd, priv->speed);
-	cmd->duplex = priv->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
-	cmd->port = PORT_TP;
-	cmd->autoneg = priv->autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+
+	cmd->base.speed = priv->speed;
+	cmd->base.duplex = priv->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
+	cmd->base.port = PORT_TP;
+	cmd->base.autoneg = priv->autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 
 	return 0;
 }
 
-static int encx24j600_set_settings(struct net_device *dev,
-				   struct ethtool_cmd *cmd)
+static int
+encx24j600_set_link_ksettings(struct net_device *dev,
+			      const struct ethtool_link_ksettings *cmd)
 {
-	return encx24j600_setlink(dev, cmd->autoneg,
-				  ethtool_cmd_speed(cmd), cmd->duplex);
+	return encx24j600_setlink(dev, cmd->base.autoneg,
+				  cmd->base.speed, cmd->base.duplex);
 }
 
 static u32 encx24j600_get_msglevel(struct net_device *dev)
@@ -980,13 +984,13 @@ static void encx24j600_set_msglevel(struct net_device *dev, u32 val)
 }
 
 static const struct ethtool_ops encx24j600_ethtool_ops = {
-	.get_settings = encx24j600_get_settings,
-	.set_settings = encx24j600_set_settings,
 	.get_drvinfo = encx24j600_get_drvinfo,
 	.get_msglevel = encx24j600_get_msglevel,
 	.set_msglevel = encx24j600_set_msglevel,
 	.get_regs_len = encx24j600_get_regs_len,
 	.get_regs = encx24j600_get_regs,
+	.get_link_ksettings = encx24j600_get_link_ksettings,
+	.set_link_ksettings = encx24j600_set_link_ksettings,
 };
 
 static const struct net_device_ops encx24j600_netdev_ops = {
-- 
1.7.4.4
