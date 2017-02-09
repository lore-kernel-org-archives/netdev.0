From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: microchip: enc28j60: use new api ethtool_{get|set}_link_ksettings
Date: Thu,  9 Feb 2017 22:02:47 +0100
Message-ID: <1486674167-19306-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mhei@heimpold.de, sergio.valverde@hpe.com,
        jarod@redhat.com, dompe@hpe.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/microchip/enc28j60.c |   31 +++++++++++++++-------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 045b910..f6ecfa7 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1487,27 +1487,30 @@ static void enc28j60_restart_work_handler(struct work_struct *work)
 }
 
 static int
-enc28j60_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+enc28j60_get_link_ksettings(struct net_device *dev,
+			    struct ethtool_link_ksettings *cmd)
 {
 	struct enc28j60_net *priv = netdev_priv(dev);
 
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->supported	= SUPPORTED_10baseT_Half
-			| SUPPORTED_10baseT_Full
-			| SUPPORTED_TP;
-	ethtool_cmd_speed_set(cmd,  SPEED_10);
-	cmd->duplex	= priv->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
-	cmd->port	= PORT_TP;
-	cmd->autoneg	= AUTONEG_DISABLE;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 10baseT_Half);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 10baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, TP);
+
+	cmd->base.speed = SPEED_10;
+	cmd->base.duplex = priv->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
+	cmd->base.port	= PORT_TP;
+	cmd->base.autoneg = AUTONEG_DISABLE;
 
 	return 0;
 }
 
 static int
-enc28j60_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+enc28j60_set_link_ksettings(struct net_device *dev,
+			    const struct ethtool_link_ksettings *cmd)
 {
-	return enc28j60_setlink(dev, cmd->autoneg,
-				ethtool_cmd_speed(cmd), cmd->duplex);
+	return enc28j60_setlink(dev, cmd->base.autoneg,
+				cmd->base.speed, cmd->base.duplex);
 }
 
 static u32 enc28j60_get_msglevel(struct net_device *dev)
@@ -1523,11 +1526,11 @@ static void enc28j60_set_msglevel(struct net_device *dev, u32 val)
 }
 
 static const struct ethtool_ops enc28j60_ethtool_ops = {
-	.get_settings	= enc28j60_get_settings,
-	.set_settings	= enc28j60_set_settings,
 	.get_drvinfo	= enc28j60_get_drvinfo,
 	.get_msglevel	= enc28j60_get_msglevel,
 	.set_msglevel	= enc28j60_set_msglevel,
+	.get_link_ksettings = enc28j60_get_link_ksettings,
+	.set_link_ksettings = enc28j60_set_link_ksettings,
 };
 
 static int enc28j60_chipset_init(struct net_device *dev)
-- 
1.7.4.4
