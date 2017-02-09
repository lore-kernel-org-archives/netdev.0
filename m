From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: natsemi: use new api ethtool_{get|set}_link_ksettings
Date: Thu,  9 Feb 2017 23:58:25 +0100
Message-ID: <1486681105-12816-1-git-send-email-tremyfr@gmail.com>
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
 drivers/net/ethernet/natsemi/natsemi.c |  119 ++++++++++++++++++--------------
 1 files changed, 67 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 8e72679..18af2a2 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -640,8 +640,10 @@ struct netdev_private {
 static int netdev_get_wol(struct net_device *dev, u32 *supported, u32 *cur);
 static int netdev_set_sopass(struct net_device *dev, u8 *newval);
 static int netdev_get_sopass(struct net_device *dev, u8 *data);
-static int netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd);
-static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd);
+static int netdev_get_ecmd(struct net_device *dev,
+			   struct ethtool_link_ksettings *ecmd);
+static int netdev_set_ecmd(struct net_device *dev,
+			   const struct ethtool_link_ksettings *ecmd);
 static void enable_wol_mode(struct net_device *dev, int enable_intr);
 static int netdev_close(struct net_device *dev);
 static int netdev_get_regs(struct net_device *dev, u8 *buf);
@@ -2584,7 +2586,8 @@ static int get_eeprom_len(struct net_device *dev)
 	return np->eeprom_size;
 }
 
-static int get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int get_link_ksettings(struct net_device *dev,
+			      struct ethtool_link_ksettings *ecmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	spin_lock_irq(&np->lock);
@@ -2593,7 +2596,8 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	return 0;
 }
 
-static int set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int set_link_ksettings(struct net_device *dev,
+			      const struct ethtool_link_ksettings *ecmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int res;
@@ -2689,8 +2693,6 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8
 	.get_drvinfo = get_drvinfo,
 	.get_regs_len = get_regs_len,
 	.get_eeprom_len = get_eeprom_len,
-	.get_settings = get_settings,
-	.set_settings = set_settings,
 	.get_wol = get_wol,
 	.set_wol = set_wol,
 	.get_regs = get_regs,
@@ -2699,6 +2701,8 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8
 	.nway_reset = nway_reset,
 	.get_link = get_link,
 	.get_eeprom = get_eeprom,
+	.get_link_ksettings = get_link_ksettings,
+	.set_link_ksettings = set_link_ksettings,
 };
 
 static int netdev_set_wol(struct net_device *dev, u32 newval)
@@ -2828,29 +2832,32 @@ static int netdev_get_sopass(struct net_device *dev, u8 *data)
 	return 0;
 }
 
-static int netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int netdev_get_ecmd(struct net_device *dev,
+			   struct ethtool_link_ksettings *ecmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	u32 supported, advertising;
 	u32 tmp;
 
-	ecmd->port        = dev->if_port;
-	ethtool_cmd_speed_set(ecmd, np->speed);
-	ecmd->duplex      = np->duplex;
-	ecmd->autoneg     = np->autoneg;
-	ecmd->advertising = 0;
+	ecmd->base.port   = dev->if_port;
+	ecmd->base.speed  = np->speed;
+	ecmd->base.duplex = np->duplex;
+	ecmd->base.autoneg = np->autoneg;
+	advertising = 0;
+
 	if (np->advertising & ADVERTISE_10HALF)
-		ecmd->advertising |= ADVERTISED_10baseT_Half;
+		advertising |= ADVERTISED_10baseT_Half;
 	if (np->advertising & ADVERTISE_10FULL)
-		ecmd->advertising |= ADVERTISED_10baseT_Full;
+		advertising |= ADVERTISED_10baseT_Full;
 	if (np->advertising & ADVERTISE_100HALF)
-		ecmd->advertising |= ADVERTISED_100baseT_Half;
+		advertising |= ADVERTISED_100baseT_Half;
 	if (np->advertising & ADVERTISE_100FULL)
-		ecmd->advertising |= ADVERTISED_100baseT_Full;
-	ecmd->supported   = (SUPPORTED_Autoneg |
+		advertising |= ADVERTISED_100baseT_Full;
+	supported   = (SUPPORTED_Autoneg |
 		SUPPORTED_10baseT_Half  | SUPPORTED_10baseT_Full  |
 		SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 		SUPPORTED_TP | SUPPORTED_MII | SUPPORTED_FIBRE);
-	ecmd->phy_address = np->phy_addr_external;
+	ecmd->base.phy_address = np->phy_addr_external;
 	/*
 	 * We intentionally report the phy address of the external
 	 * phy, even if the internal phy is used. This is necessary
@@ -2870,62 +2877,70 @@ static int netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 	 */
 
 	/* set information based on active port type */
-	switch (ecmd->port) {
+	switch (ecmd->base.port) {
 	default:
 	case PORT_TP:
-		ecmd->advertising |= ADVERTISED_TP;
-		ecmd->transceiver = XCVR_INTERNAL;
+		advertising |= ADVERTISED_TP;
 		break;
 	case PORT_MII:
-		ecmd->advertising |= ADVERTISED_MII;
-		ecmd->transceiver = XCVR_EXTERNAL;
+		advertising |= ADVERTISED_MII;
 		break;
 	case PORT_FIBRE:
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->transceiver = XCVR_EXTERNAL;
+		advertising |= ADVERTISED_FIBRE;
 		break;
 	}
 
 	/* if autonegotiation is on, try to return the active speed/duplex */
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
-		ecmd->advertising |= ADVERTISED_Autoneg;
+	if (ecmd->base.autoneg == AUTONEG_ENABLE) {
+		advertising |= ADVERTISED_Autoneg;
 		tmp = mii_nway_result(
 			np->advertising & mdio_read(dev, MII_LPA));
 		if (tmp == LPA_100FULL || tmp == LPA_100HALF)
-			ethtool_cmd_speed_set(ecmd, SPEED_100);
+			ecmd->base.speed = SPEED_100;
 		else
-			ethtool_cmd_speed_set(ecmd, SPEED_10);
+			ecmd->base.speed = SPEED_10;
 		if (tmp == LPA_100FULL || tmp == LPA_10FULL)
-			ecmd->duplex = DUPLEX_FULL;
+			ecmd->base.duplex = DUPLEX_FULL;
 		else
-			ecmd->duplex = DUPLEX_HALF;
+			ecmd->base.duplex = DUPLEX_HALF;
 	}
 
 	/* ignore maxtxpkt, maxrxpkt for now */
 
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int netdev_set_ecmd(struct net_device *dev,
+			   const struct ethtool_link_ksettings *ecmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	u32 advertising;
 
-	if (ecmd->port != PORT_TP && ecmd->port != PORT_MII && ecmd->port != PORT_FIBRE)
-		return -EINVAL;
-	if (ecmd->transceiver != XCVR_INTERNAL && ecmd->transceiver != XCVR_EXTERNAL)
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						ecmd->link_modes.advertising);
+
+	if (ecmd->base.port != PORT_TP &&
+	    ecmd->base.port != PORT_MII &&
+	    ecmd->base.port != PORT_FIBRE)
 		return -EINVAL;
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
-		if ((ecmd->advertising & (ADVERTISED_10baseT_Half |
+	if (ecmd->base.autoneg == AUTONEG_ENABLE) {
+		if ((advertising & (ADVERTISED_10baseT_Half |
 					  ADVERTISED_10baseT_Full |
 					  ADVERTISED_100baseT_Half |
 					  ADVERTISED_100baseT_Full)) == 0) {
 			return -EINVAL;
 		}
-	} else if (ecmd->autoneg == AUTONEG_DISABLE) {
-		u32 speed = ethtool_cmd_speed(ecmd);
+	} else if (ecmd->base.autoneg == AUTONEG_DISABLE) {
+		u32 speed = ecmd->base.speed;
 		if (speed != SPEED_10 && speed != SPEED_100)
 			return -EINVAL;
-		if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
+		if (ecmd->base.duplex != DUPLEX_HALF &&
+		    ecmd->base.duplex != DUPLEX_FULL)
 			return -EINVAL;
 	} else {
 		return -EINVAL;
@@ -2936,8 +2951,8 @@ static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 	 * transceiver are really not going to work so don't let the
 	 * user select them.
 	 */
-	if (np->ignore_phy && (ecmd->autoneg == AUTONEG_ENABLE ||
-			       ecmd->port == PORT_TP))
+	if (np->ignore_phy && (ecmd->base.autoneg == AUTONEG_ENABLE ||
+			       ecmd->base.port == PORT_TP))
 		return -EINVAL;
 
 	/*
@@ -2956,30 +2971,30 @@ static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 	/* WHEW! now lets bang some bits */
 
 	/* save the parms */
-	dev->if_port          = ecmd->port;
-	np->autoneg           = ecmd->autoneg;
-	np->phy_addr_external = ecmd->phy_address & PhyAddrMask;
+	dev->if_port          = ecmd->base.port;
+	np->autoneg           = ecmd->base.autoneg;
+	np->phy_addr_external = ecmd->base.phy_address & PhyAddrMask;
 	if (np->autoneg == AUTONEG_ENABLE) {
 		/* advertise only what has been requested */
 		np->advertising &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
-		if (ecmd->advertising & ADVERTISED_10baseT_Half)
+		if (advertising & ADVERTISED_10baseT_Half)
 			np->advertising |= ADVERTISE_10HALF;
-		if (ecmd->advertising & ADVERTISED_10baseT_Full)
+		if (advertising & ADVERTISED_10baseT_Full)
 			np->advertising |= ADVERTISE_10FULL;
-		if (ecmd->advertising & ADVERTISED_100baseT_Half)
+		if (advertising & ADVERTISED_100baseT_Half)
 			np->advertising |= ADVERTISE_100HALF;
-		if (ecmd->advertising & ADVERTISED_100baseT_Full)
+		if (advertising & ADVERTISED_100baseT_Full)
 			np->advertising |= ADVERTISE_100FULL;
 	} else {
-		np->speed  = ethtool_cmd_speed(ecmd);
-		np->duplex = ecmd->duplex;
+		np->speed  = ecmd->base.speed;
+		np->duplex = ecmd->base.duplex;
 		/* user overriding the initial full duplex parm? */
 		if (np->duplex == DUPLEX_HALF)
 			np->full_duplex = 0;
 	}
 
 	/* get the right phy enabled */
-	if (ecmd->port == PORT_TP)
+	if (ecmd->base.port == PORT_TP)
 		switch_port_internal(dev);
 	else
 		switch_port_external(dev);
-- 
1.7.4.4
