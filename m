From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: ibm: emac: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  7 Jan 2017 22:32:27 +0100
Message-ID: <1483824747-6405-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, ivan@de.ibm.com, jarod@redhat.com,
        mugunthanvnm@ti.com, felipe.balbi@linux.intel.com, fw@strlen.de,
        mpe@ellerman.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ibm/emac/core.c |   70 +++++++++++++++++++--------------
 1 files changed, 40 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 5909615..6ead233 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -1991,69 +1991,79 @@ static irqreturn_t emac_irq(int irq, void *dev_instance)
 };
 
 /* Ethtool support */
-static int emac_ethtool_get_settings(struct net_device *ndev,
-				     struct ethtool_cmd *cmd)
+static int emac_ethtool_get_link_ksettings(struct net_device *ndev,
+					   struct ethtool_link_ksettings *cmd)
 {
 	struct emac_instance *dev = netdev_priv(ndev);
+	u32 supported, advertising;
 
-	cmd->supported = dev->phy.features;
-	cmd->port = PORT_MII;
-	cmd->phy_address = dev->phy.address;
-	cmd->transceiver =
-	    dev->phy.address >= 0 ? XCVR_EXTERNAL : XCVR_INTERNAL;
+	supported = dev->phy.features;
+	cmd->base.port = PORT_MII;
+	cmd->base.phy_address = dev->phy.address;
 
 	mutex_lock(&dev->link_lock);
-	cmd->advertising = dev->phy.advertising;
-	cmd->autoneg = dev->phy.autoneg;
-	cmd->speed = dev->phy.speed;
-	cmd->duplex = dev->phy.duplex;
+	advertising = dev->phy.advertising;
+	cmd->base.autoneg = dev->phy.autoneg;
+	cmd->base.speed = dev->phy.speed;
+	cmd->base.duplex = dev->phy.duplex;
 	mutex_unlock(&dev->link_lock);
 
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-static int emac_ethtool_set_settings(struct net_device *ndev,
-				     struct ethtool_cmd *cmd)
+static int
+emac_ethtool_set_link_ksettings(struct net_device *ndev,
+				const struct ethtool_link_ksettings *cmd)
 {
 	struct emac_instance *dev = netdev_priv(ndev);
 	u32 f = dev->phy.features;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	DBG(dev, "set_settings(%d, %d, %d, 0x%08x)" NL,
-	    cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
+	    cmd->base.autoneg, cmd->base.speed, cmd->base.duplex, advertising);
 
 	/* Basic sanity checks */
 	if (dev->phy.address < 0)
 		return -EOPNOTSUPP;
-	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
+	if (cmd->base.autoneg != AUTONEG_ENABLE &&
+	    cmd->base.autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
-	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
+	if (cmd->base.autoneg == AUTONEG_ENABLE && advertising == 0)
 		return -EINVAL;
-	if (cmd->duplex != DUPLEX_HALF && cmd->duplex != DUPLEX_FULL)
+	if (cmd->base.duplex != DUPLEX_HALF && cmd->base.duplex != DUPLEX_FULL)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_DISABLE) {
-		switch (cmd->speed) {
+	if (cmd->base.autoneg == AUTONEG_DISABLE) {
+		switch (cmd->base.speed) {
 		case SPEED_10:
-			if (cmd->duplex == DUPLEX_HALF &&
+			if (cmd->base.duplex == DUPLEX_HALF &&
 			    !(f & SUPPORTED_10baseT_Half))
 				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL &&
+			if (cmd->base.duplex == DUPLEX_FULL &&
 			    !(f & SUPPORTED_10baseT_Full))
 				return -EINVAL;
 			break;
 		case SPEED_100:
-			if (cmd->duplex == DUPLEX_HALF &&
+			if (cmd->base.duplex == DUPLEX_HALF &&
 			    !(f & SUPPORTED_100baseT_Half))
 				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL &&
+			if (cmd->base.duplex == DUPLEX_FULL &&
 			    !(f & SUPPORTED_100baseT_Full))
 				return -EINVAL;
 			break;
 		case SPEED_1000:
-			if (cmd->duplex == DUPLEX_HALF &&
+			if (cmd->base.duplex == DUPLEX_HALF &&
 			    !(f & SUPPORTED_1000baseT_Half))
 				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL &&
+			if (cmd->base.duplex == DUPLEX_FULL &&
 			    !(f & SUPPORTED_1000baseT_Full))
 				return -EINVAL;
 			break;
@@ -2062,8 +2072,8 @@ static int emac_ethtool_set_settings(struct net_device *ndev,
 		}
 
 		mutex_lock(&dev->link_lock);
-		dev->phy.def->ops->setup_forced(&dev->phy, cmd->speed,
-						cmd->duplex);
+		dev->phy.def->ops->setup_forced(&dev->phy, cmd->base.speed,
+						cmd->base.duplex);
 		mutex_unlock(&dev->link_lock);
 
 	} else {
@@ -2072,7 +2082,7 @@ static int emac_ethtool_set_settings(struct net_device *ndev,
 
 		mutex_lock(&dev->link_lock);
 		dev->phy.def->ops->setup_aneg(&dev->phy,
-					      (cmd->advertising & f) |
+					      (advertising & f) |
 					      (dev->phy.advertising &
 					       (ADVERTISED_Pause |
 						ADVERTISED_Asym_Pause)));
@@ -2234,8 +2244,6 @@ static void emac_ethtool_get_drvinfo(struct net_device *ndev,
 }
 
 static const struct ethtool_ops emac_ethtool_ops = {
-	.get_settings = emac_ethtool_get_settings,
-	.set_settings = emac_ethtool_set_settings,
 	.get_drvinfo = emac_ethtool_get_drvinfo,
 
 	.get_regs_len = emac_ethtool_get_regs_len,
@@ -2251,6 +2259,8 @@ static void emac_ethtool_get_drvinfo(struct net_device *ndev,
 	.get_ethtool_stats = emac_ethtool_get_ethtool_stats,
 
 	.get_link = ethtool_op_get_link,
+	.get_link_ksettings = emac_ethtool_get_link_ksettings,
+	.set_link_ksettings = emac_ethtool_set_link_ksettings,
 };
 
 static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
