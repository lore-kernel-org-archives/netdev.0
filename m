From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: dec: de2104x: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  1 Jan 2017 19:05:38 +0100
Message-ID: <1483293938-5227-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/dec/tulip/de2104x.c |   91 +++++++++++++++++-------------
 1 files changed, 51 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 57c17e7..127ce970 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1485,95 +1485,104 @@ static void __de_get_regs(struct de_private *de, u8 *buf)
 	de_rx_missed(de, rbuf[8]);
 }
 
-static int __de_get_settings(struct de_private *de, struct ethtool_cmd *ecmd)
+static int __de_get_link_ksettings(struct de_private *de,
+				   struct ethtool_link_ksettings *cmd)
 {
-	ecmd->supported = de->media_supported;
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->phy_address = 0;
-	ecmd->advertising = de->media_advertise;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						de->media_supported);
+	cmd->base.phy_address = 0;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						de->media_advertise);
 
 	switch (de->media_type) {
 	case DE_MEDIA_AUI:
-		ecmd->port = PORT_AUI;
+		cmd->base.port = PORT_AUI;
 		break;
 	case DE_MEDIA_BNC:
-		ecmd->port = PORT_BNC;
+		cmd->base.port = PORT_BNC;
 		break;
 	default:
-		ecmd->port = PORT_TP;
+		cmd->base.port = PORT_TP;
 		break;
 	}
 
-	ethtool_cmd_speed_set(ecmd, 10);
+	cmd->base.speed = 10;
 
 	if (dr32(MacMode) & FullDuplex)
-		ecmd->duplex = DUPLEX_FULL;
+		cmd->base.duplex = DUPLEX_FULL;
 	else
-		ecmd->duplex = DUPLEX_HALF;
+		cmd->base.duplex = DUPLEX_HALF;
 
 	if (de->media_lock)
-		ecmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 	else
-		ecmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 
 	/* ignore maxtxpkt, maxrxpkt for now */
 
 	return 0;
 }
 
-static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
+static int __de_set_link_ksettings(struct de_private *de,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	u32 new_media;
 	unsigned int media_lock;
+	u8 duplex = cmd->base.duplex;
+	u8 port = cmd->base.port;
+	u8 autoneg = cmd->base.autoneg;
+	u32 advertising;
 
-	if (ethtool_cmd_speed(ecmd) != 10)
-		return -EINVAL;
-	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+
+	if (cmd->base.speed != 10)
 		return -EINVAL;
-	if (ecmd->port != PORT_TP && ecmd->port != PORT_AUI && ecmd->port != PORT_BNC)
+	if (duplex != DUPLEX_HALF && duplex != DUPLEX_FULL)
 		return -EINVAL;
-	if (de->de21040 && ecmd->port == PORT_BNC)
+	if (port != PORT_TP && port != PORT_AUI && port != PORT_BNC)
 		return -EINVAL;
-	if (ecmd->transceiver != XCVR_INTERNAL)
+	if (de->de21040 && port == PORT_BNC)
 		return -EINVAL;
-	if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
+	if (autoneg != AUTONEG_DISABLE && autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
-	if (ecmd->advertising & ~de->media_supported)
+	if (advertising & ~de->media_supported)
 		return -EINVAL;
-	if (ecmd->autoneg == AUTONEG_ENABLE &&
-	    (!(ecmd->advertising & ADVERTISED_Autoneg)))
+	if (autoneg == AUTONEG_ENABLE &&
+	    (!(advertising & ADVERTISED_Autoneg)))
 		return -EINVAL;
 
-	switch (ecmd->port) {
+	switch (port) {
 	case PORT_AUI:
 		new_media = DE_MEDIA_AUI;
-		if (!(ecmd->advertising & ADVERTISED_AUI))
+		if (!(advertising & ADVERTISED_AUI))
 			return -EINVAL;
 		break;
 	case PORT_BNC:
 		new_media = DE_MEDIA_BNC;
-		if (!(ecmd->advertising & ADVERTISED_BNC))
+		if (!(advertising & ADVERTISED_BNC))
 			return -EINVAL;
 		break;
 	default:
-		if (ecmd->autoneg == AUTONEG_ENABLE)
+		if (autoneg == AUTONEG_ENABLE)
 			new_media = DE_MEDIA_TP_AUTO;
-		else if (ecmd->duplex == DUPLEX_FULL)
+		else if (duplex == DUPLEX_FULL)
 			new_media = DE_MEDIA_TP_FD;
 		else
 			new_media = DE_MEDIA_TP;
-		if (!(ecmd->advertising & ADVERTISED_TP))
+		if (!(advertising & ADVERTISED_TP))
 			return -EINVAL;
-		if (!(ecmd->advertising & (ADVERTISED_10baseT_Full | ADVERTISED_10baseT_Half)))
+		if (!(advertising & (ADVERTISED_10baseT_Full |
+				     ADVERTISED_10baseT_Half)))
 			return -EINVAL;
 		break;
 	}
 
-	media_lock = (ecmd->autoneg == AUTONEG_ENABLE) ? 0 : 1;
+	media_lock = (autoneg == AUTONEG_ENABLE) ? 0 : 1;
 
 	if ((new_media == de->media_type) &&
 	    (media_lock == de->media_lock) &&
-	    (ecmd->advertising == de->media_advertise))
+	    (advertising == de->media_advertise))
 		return 0; /* nothing to change */
 
 	de_link_down(de);
@@ -1582,7 +1591,7 @@ static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 
 	de->media_type = new_media;
 	de->media_lock = media_lock;
-	de->media_advertise = ecmd->advertising;
+	de->media_advertise = advertising;
 	de_set_media(de);
 	if (netif_running(de->dev))
 		de_start_rxtx(de);
@@ -1604,25 +1613,27 @@ static int de_get_regs_len(struct net_device *dev)
 	return DE_REGS_SIZE;
 }
 
-static int de_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int de_get_link_ksettings(struct net_device *dev,
+				 struct ethtool_link_ksettings *cmd)
 {
 	struct de_private *de = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&de->lock);
-	rc = __de_get_settings(de, ecmd);
+	rc = __de_get_link_ksettings(de, cmd);
 	spin_unlock_irq(&de->lock);
 
 	return rc;
 }
 
-static int de_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int de_set_link_ksettings(struct net_device *dev,
+				 const struct ethtool_link_ksettings *cmd)
 {
 	struct de_private *de = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&de->lock);
-	rc = __de_set_settings(de, ecmd);
+	rc = __de_set_link_ksettings(de, cmd);
 	spin_unlock_irq(&de->lock);
 
 	return rc;
@@ -1690,13 +1701,13 @@ static void de_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	.get_link		= ethtool_op_get_link,
 	.get_drvinfo		= de_get_drvinfo,
 	.get_regs_len		= de_get_regs_len,
-	.get_settings		= de_get_settings,
-	.set_settings		= de_set_settings,
 	.get_msglevel		= de_get_msglevel,
 	.set_msglevel		= de_set_msglevel,
 	.get_eeprom		= de_get_eeprom,
 	.nway_reset		= de_nway_reset,
 	.get_regs		= de_get_regs,
+	.get_link_ksettings	= de_get_link_ksettings,
+	.set_link_ksettings	= de_set_link_ksettings,
 };
 
 static void de21040_get_mac_address(struct de_private *de)
-- 
1.7.4.4

