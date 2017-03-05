From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sun: sunhme: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  5 Mar 2017 22:25:39 +0100
Message-ID: <1488749139-21200-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sun/sunhme.c |   62 ++++++++++++++++++++----------------
 1 files changed, 34 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 72ff05c..53ff66e 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -1294,9 +1294,10 @@ static void happy_meal_init_rings(struct happy_meal *hp)
 }
 
 /* hp->happy_lock must be held */
-static void happy_meal_begin_auto_negotiation(struct happy_meal *hp,
-					      void __iomem *tregs,
-					      struct ethtool_cmd *ep)
+static void
+happy_meal_begin_auto_negotiation(struct happy_meal *hp,
+				  void __iomem *tregs,
+				  const struct ethtool_link_ksettings *ep)
 {
 	int timeout;
 
@@ -1309,7 +1310,7 @@ static void happy_meal_begin_auto_negotiation(struct happy_meal *hp,
 	/* XXX Check BMSR_ANEGCAPABLE, should not be necessary though. */
 
 	hp->sw_advertise = happy_meal_tcvr_read(hp, tregs, MII_ADVERTISE);
-	if (ep == NULL || ep->autoneg == AUTONEG_ENABLE) {
+	if (!ep || ep->base.autoneg == AUTONEG_ENABLE) {
 		/* Advertise everything we can support. */
 		if (hp->sw_bmsr & BMSR_10HALF)
 			hp->sw_advertise |= (ADVERTISE_10HALF);
@@ -1384,14 +1385,14 @@ static void happy_meal_begin_auto_negotiation(struct happy_meal *hp,
 		/* Disable auto-negotiation in BMCR, enable the duplex and
 		 * speed setting, init the timer state machine, and fire it off.
 		 */
-		if (ep == NULL || ep->autoneg == AUTONEG_ENABLE) {
+		if (!ep || ep->base.autoneg == AUTONEG_ENABLE) {
 			hp->sw_bmcr = BMCR_SPEED100;
 		} else {
-			if (ethtool_cmd_speed(ep) == SPEED_100)
+			if (ep->base.speed == SPEED_100)
 				hp->sw_bmcr = BMCR_SPEED100;
 			else
 				hp->sw_bmcr = 0;
-			if (ep->duplex == DUPLEX_FULL)
+			if (ep->base.duplex == DUPLEX_FULL)
 				hp->sw_bmcr |= BMCR_FULLDPLX;
 		}
 		happy_meal_tcvr_write(hp, tregs, MII_BMCR, hp->sw_bmcr);
@@ -2434,20 +2435,21 @@ static void happy_meal_set_multicast(struct net_device *dev)
 }
 
 /* Ethtool support... */
-static int hme_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int hme_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct happy_meal *hp = netdev_priv(dev);
 	u32 speed;
+	u32 supported;
 
-	cmd->supported =
+	supported =
 		(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 		 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 		 SUPPORTED_Autoneg | SUPPORTED_TP | SUPPORTED_MII);
 
 	/* XXX hardcoded stuff for now */
-	cmd->port = PORT_TP; /* XXX no MII support */
-	cmd->transceiver = XCVR_INTERNAL; /* XXX no external xcvr support */
-	cmd->phy_address = 0; /* XXX fixed PHYAD */
+	cmd->base.port = PORT_TP; /* XXX no MII support */
+	cmd->base.phy_address = 0; /* XXX fixed PHYAD */
 
 	/* Record PHY settings. */
 	spin_lock_irq(&hp->happy_lock);
@@ -2456,41 +2458,45 @@ static int hme_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	spin_unlock_irq(&hp->happy_lock);
 
 	if (hp->sw_bmcr & BMCR_ANENABLE) {
-		cmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 		speed = ((hp->sw_lpa & (LPA_100HALF | LPA_100FULL)) ?
 			 SPEED_100 : SPEED_10);
 		if (speed == SPEED_100)
-			cmd->duplex =
+			cmd->base.duplex =
 				(hp->sw_lpa & (LPA_100FULL)) ?
 				DUPLEX_FULL : DUPLEX_HALF;
 		else
-			cmd->duplex =
+			cmd->base.duplex =
 				(hp->sw_lpa & (LPA_10FULL)) ?
 				DUPLEX_FULL : DUPLEX_HALF;
 	} else {
-		cmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 		speed = (hp->sw_bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10;
-		cmd->duplex =
+		cmd->base.duplex =
 			(hp->sw_bmcr & BMCR_FULLDPLX) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 	}
-	ethtool_cmd_speed_set(cmd, speed);
+	cmd->base.speed = speed;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+
 	return 0;
 }
 
-static int hme_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int hme_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct happy_meal *hp = netdev_priv(dev);
 
 	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE &&
-	    cmd->autoneg != AUTONEG_DISABLE)
+	if (cmd->base.autoneg != AUTONEG_ENABLE &&
+	    cmd->base.autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
-	if (cmd->autoneg == AUTONEG_DISABLE &&
-	    ((ethtool_cmd_speed(cmd) != SPEED_100 &&
-	      ethtool_cmd_speed(cmd) != SPEED_10) ||
-	     (cmd->duplex != DUPLEX_HALF &&
-	      cmd->duplex != DUPLEX_FULL)))
+	if (cmd->base.autoneg == AUTONEG_DISABLE &&
+	    ((cmd->base.speed != SPEED_100 &&
+	      cmd->base.speed != SPEED_10) ||
+	     (cmd->base.duplex != DUPLEX_HALF &&
+	      cmd->base.duplex != DUPLEX_FULL)))
 		return -EINVAL;
 
 	/* Ok, do it to it. */
@@ -2537,10 +2543,10 @@ static u32 hme_get_link(struct net_device *dev)
 }
 
 static const struct ethtool_ops hme_ethtool_ops = {
-	.get_settings		= hme_get_settings,
-	.set_settings		= hme_set_settings,
 	.get_drvinfo		= hme_get_drvinfo,
 	.get_link		= hme_get_link,
+	.get_link_ksettings	= hme_get_link_ksettings,
+	.set_link_ksettings	= hme_set_link_ksettings,
 };
 
 static int hme_version_printed;
-- 
1.7.4.4
