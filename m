From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sun: sungem: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  5 Mar 2017 00:04:18 +0100
Message-ID: <1488668658-27461-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com, edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sun/sungem.c |   98 +++++++++++++++++++++---------------
 1 files changed, 57 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 5c5952e..dbfca04 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -1250,12 +1250,17 @@ static void gem_stop_dma(struct gem *gp)
 
 
 // XXX dbl check what that function should do when called on PCS PHY
-static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
+static void gem_begin_auto_negotiation(struct gem *gp,
+				       const struct ethtool_link_ksettings *ep)
 {
 	u32 advertise, features;
 	int autoneg;
 	int speed;
 	int duplex;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						ep->link_modes.advertising);
 
 	if (gp->phy_type != phy_mii_mdio0 &&
      	    gp->phy_type != phy_mii_mdio1)
@@ -1278,13 +1283,13 @@ static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
 	/* Setup link parameters */
 	if (!ep)
 		goto start_aneg;
-	if (ep->autoneg == AUTONEG_ENABLE) {
-		advertise = ep->advertising;
+	if (ep->base.autoneg == AUTONEG_ENABLE) {
+		advertise = advertising;
 		autoneg = 1;
 	} else {
 		autoneg = 0;
-		speed = ethtool_cmd_speed(ep);
-		duplex = ep->duplex;
+		speed = ep->base.speed;
+		duplex = ep->base.duplex;
 	}
 
 start_aneg:
@@ -2515,85 +2520,96 @@ static void gem_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	strlcpy(info->bus_info, pci_name(gp->pdev), sizeof(info->bus_info));
 }
 
-static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int gem_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct gem *gp = netdev_priv(dev);
+	u32 supported, advertising;
 
 	if (gp->phy_type == phy_mii_mdio0 ||
 	    gp->phy_type == phy_mii_mdio1) {
 		if (gp->phy_mii.def)
-			cmd->supported = gp->phy_mii.def->features;
+			supported = gp->phy_mii.def->features;
 		else
-			cmd->supported = (SUPPORTED_10baseT_Half |
+			supported = (SUPPORTED_10baseT_Half |
 					  SUPPORTED_10baseT_Full);
 
 		/* XXX hardcoded stuff for now */
-		cmd->port = PORT_MII;
-		cmd->transceiver = XCVR_EXTERNAL;
-		cmd->phy_address = 0; /* XXX fixed PHYAD */
+		cmd->base.port = PORT_MII;
+		cmd->base.phy_address = 0; /* XXX fixed PHYAD */
 
 		/* Return current PHY settings */
-		cmd->autoneg = gp->want_autoneg;
-		ethtool_cmd_speed_set(cmd, gp->phy_mii.speed);
-		cmd->duplex = gp->phy_mii.duplex;
-		cmd->advertising = gp->phy_mii.advertising;
+		cmd->base.autoneg = gp->want_autoneg;
+		cmd->base.speed = gp->phy_mii.speed;
+		cmd->base.duplex = gp->phy_mii.duplex;
+		advertising = gp->phy_mii.advertising;
 
 		/* If we started with a forced mode, we don't have a default
 		 * advertise set, we need to return something sensible so
 		 * userland can re-enable autoneg properly.
 		 */
-		if (cmd->advertising == 0)
-			cmd->advertising = cmd->supported;
+		if (advertising == 0)
+			advertising = supported;
 	} else { // XXX PCS ?
-		cmd->supported =
+		supported =
 			(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 			 SUPPORTED_Autoneg);
-		cmd->advertising = cmd->supported;
-		ethtool_cmd_speed_set(cmd, 0);
-		cmd->duplex = cmd->port = cmd->phy_address =
-			cmd->transceiver = cmd->autoneg = 0;
+		advertising = supported;
+		cmd->base.speed = 0;
+		cmd->base.duplex = 0;
+		cmd->base.port = 0;
+		cmd->base.phy_address = 0;
+		cmd->base.autoneg = 0;
 
 		/* serdes means usually a Fibre connector, with most fixed */
 		if (gp->phy_type == phy_serdes) {
-			cmd->port = PORT_FIBRE;
-			cmd->supported = (SUPPORTED_1000baseT_Half |
+			cmd->base.port = PORT_FIBRE;
+			supported = (SUPPORTED_1000baseT_Half |
 				SUPPORTED_1000baseT_Full |
 				SUPPORTED_FIBRE | SUPPORTED_Autoneg |
 				SUPPORTED_Pause | SUPPORTED_Asym_Pause);
-			cmd->advertising = cmd->supported;
-			cmd->transceiver = XCVR_INTERNAL;
+			advertising = supported;
 			if (gp->lstate == link_up)
-				ethtool_cmd_speed_set(cmd, SPEED_1000);
-			cmd->duplex = DUPLEX_FULL;
-			cmd->autoneg = 1;
+				cmd->base.speed = SPEED_1000;
+			cmd->base.duplex = DUPLEX_FULL;
+			cmd->base.autoneg = 1;
 		}
 	}
-	cmd->maxtxpkt = cmd->maxrxpkt = 0;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
-static int gem_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int gem_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct gem *gp = netdev_priv(dev);
-	u32 speed = ethtool_cmd_speed(cmd);
+	u32 speed = cmd->base.speed;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE &&
-	    cmd->autoneg != AUTONEG_DISABLE)
+	if (cmd->base.autoneg != AUTONEG_ENABLE &&
+	    cmd->base.autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_ENABLE &&
-	    cmd->advertising == 0)
+	if (cmd->base.autoneg == AUTONEG_ENABLE &&
+	    advertising == 0)
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
@@ -2666,13 +2682,13 @@ static int gem_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 static const struct ethtool_ops gem_ethtool_ops = {
 	.get_drvinfo		= gem_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
-	.get_settings		= gem_get_settings,
-	.set_settings		= gem_set_settings,
 	.nway_reset		= gem_nway_reset,
 	.get_msglevel		= gem_get_msglevel,
 	.set_msglevel		= gem_set_msglevel,
 	.get_wol		= gem_get_wol,
 	.set_wol		= gem_set_wol,
+	.get_link_ksettings	= gem_get_link_ksettings,
+	.set_link_ksettings	= gem_set_link_ksettings,
 };
 
 static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-- 
1.7.4.4
