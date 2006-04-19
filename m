From: akpm@osdl.org
Subject: [patch 02/10] natsemi: Add support for using MII port with no PHY
Date: Tue, 18 Apr 2006 21:04:05 -0700
Message-ID: <200604190404.k3J44lw7007980@shell0.pdx.osdl.net>
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, akpm@osdl.org,
	broonie@sirena.org.uk, jgarzik@pobox.com, thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17100 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750776AbWDSEGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 00:06:10 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Mark Brown <broonie@sirena.org.uk>

Provide a module option which configures the natsemi driver to use the
external MII port on the chip but ignore any PHYs that may be attached to it. 
The link state will be left as it was when the driver started and can be
configured via ethtool.  Any PHYs that are present can be accessed via the MII
ioctl()s.

This is useful for systems where the device is connected without a PHY or
where either information or actions outside the scope of the driver are
required in order to use the PHYs.

Signed-off-by: Mark Brown <broonie@sirena.org.uk>
Cc: Tim Hockin <thockin@hockin.org>
Cc: Jeff Garzik <jgarzik@pobox.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/natsemi.c |  105 +++++++++++++++++++++++++---------------
 1 files changed, 67 insertions(+), 38 deletions(-)

diff -puN drivers/net/natsemi.c~natsemi-add-support-for-using-mii-port-with-no-phy drivers/net/natsemi.c
--- devel/drivers/net/natsemi.c~natsemi-add-support-for-using-mii-port-with-no-phy	2006-04-10 23:21:19.000000000 -0700
+++ devel-akpm/drivers/net/natsemi.c	2006-04-10 23:21:19.000000000 -0700
@@ -259,7 +259,7 @@ MODULE_PARM_DESC(debug, "DP8381x default
 MODULE_PARM_DESC(rx_copybreak, 
 	"DP8381x copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(options, 
-	"DP8381x: Bits 0-3: media type, bit 17: full duplex");
+	"DP8381x: Bits 0-3: media type, bit 17: full duplex, bit 18: ignore PHY");
 MODULE_PARM_DESC(full_duplex, "DP8381x full duplex setting(s) (1)");
 
 /*
@@ -690,6 +690,8 @@ struct netdev_private {
 	u32 intr_status;
 	/* Do not touch the nic registers */
 	int hands_off;
+	/* Don't pay attention to the reported link state. */
+	int ignore_phy;
 	/* external phy that is used: only valid if dev->if_port != PORT_TP */
 	int mii;
 	int phy_addr_external;
@@ -894,7 +896,19 @@ static int __devinit natsemi_probe1 (str
 	np->intr_status = 0;
 	np->eeprom_size = NATSEMI_DEF_EEPROM_SIZE;
 
+	option = find_cnt < MAX_UNITS ? options[find_cnt] : 0;
+	if (dev->mem_start)
+		option = dev->mem_start;
+
+	/* Ignore the PHY status? */
+	if (option & 0x400) {
+		np->ignore_phy = 1;
+	} else {
+		np->ignore_phy = 0;
+	}
+
 	/* Initial port:
+	 * - If configured to ignore the PHY set up for external.
 	 * - If the nic was configured to use an external phy and if find_mii
 	 *   finds a phy: use external port, first phy that replies.
 	 * - Otherwise: internal port.
@@ -902,7 +916,7 @@ static int __devinit natsemi_probe1 (str
 	 * The address would be used to access a phy over the mii bus, but
 	 * the internal phy is accessed through mapped registers.
 	 */
-	if (readl(ioaddr + ChipConfig) & CfgExtPhy)
+	if (np->ignore_phy || readl(ioaddr + ChipConfig) & CfgExtPhy)
 		dev->if_port = PORT_MII;
 	else
 		dev->if_port = PORT_TP;
@@ -912,7 +926,9 @@ static int __devinit natsemi_probe1 (str
 
 	if (dev->if_port != PORT_TP) {
 		np->phy_addr_external = find_mii(dev);
-		if (np->phy_addr_external == PHY_ADDR_NONE) {
+		/* If we're ignoring the PHY it doesn't matter if we can't
+		 * find one. */
+		if (!np->ignore_phy && np->phy_addr_external == PHY_ADDR_NONE) {
 			dev->if_port = PORT_TP;
 			np->phy_addr_external = PHY_ADDR_INTERNAL;
 		}
@@ -920,10 +936,6 @@ static int __devinit natsemi_probe1 (str
 		np->phy_addr_external = PHY_ADDR_INTERNAL;
 	}
 
-	option = find_cnt < MAX_UNITS ? options[find_cnt] : 0;
-	if (dev->mem_start)
-		option = dev->mem_start;
-
 	/* The lower four bits are the media type. */
 	if (option) {
 		if (option & 0x200)
@@ -957,7 +969,10 @@ static int __devinit natsemi_probe1 (str
 	if (mtu)
 		dev->mtu = mtu;
 
-	netif_carrier_off(dev);
+	if (np->ignore_phy)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
 
 	/* get the initial settings from hardware */
 	tmp            = mdio_read(dev, MII_BMCR);
@@ -1005,6 +1020,8 @@ static int __devinit natsemi_probe1 (str
 		printk("%02x, IRQ %d", dev->dev_addr[i], irq);
 		if (dev->if_port == PORT_TP)
 			printk(", port TP.\n");
+		else if (np->ignore_phy)
+			printk(", port MII, ignoring PHY\n");
 		else
 			printk(", port MII, phy ad %d.\n", np->phy_addr_external);
 	}
@@ -1685,42 +1702,44 @@ static void check_link(struct net_device
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
-	int duplex;
+	int duplex = np->full_duplex;
 	u16 bmsr;
-       
-	/* The link status field is latched: it remains low after a temporary
-	 * link failure until it's read. We need the current link status,
-	 * thus read twice.
-	 */
-	mdio_read(dev, MII_BMSR);
-	bmsr = mdio_read(dev, MII_BMSR);
 
-	if (!(bmsr & BMSR_LSTATUS)) {
-		if (netif_carrier_ok(dev)) {
+	/* If we're not paying attention to the PHY status then don't check. */
+	if (!np->ignore_phy) {
+		/* The link status field is latched: it remains low
+		 * after a temporary link failure until it's read. We
+		 * need the current link status, thus read twice.
+		 */
+		mdio_read(dev, MII_BMSR);
+		bmsr = mdio_read(dev, MII_BMSR);
+
+		if (!(bmsr & BMSR_LSTATUS)) {
+			if (netif_carrier_ok(dev)) {
+				if (netif_msg_link(np))
+					printk(KERN_NOTICE "%s: link down.\n",
+					       dev->name);
+				netif_carrier_off(dev);
+				undo_cable_magic(dev);
+			}
+			return;
+		}
+		if (!netif_carrier_ok(dev)) {
 			if (netif_msg_link(np))
-				printk(KERN_NOTICE "%s: link down.\n",
-					dev->name);
-			netif_carrier_off(dev);
-			undo_cable_magic(dev);
+				printk(KERN_NOTICE "%s: link up.\n", dev->name);
+			netif_carrier_on(dev);
+			do_cable_magic(dev);
 		}
-		return;
-	}
-	if (!netif_carrier_ok(dev)) {
-		if (netif_msg_link(np))
-			printk(KERN_NOTICE "%s: link up.\n", dev->name);
-		netif_carrier_on(dev);
-		do_cable_magic(dev);
-	}
 
-	duplex = np->full_duplex;
-	if (!duplex) {
-		if (bmsr & BMSR_ANEGCOMPLETE) {
-			int tmp = mii_nway_result(
-				np->advertising & mdio_read(dev, MII_LPA));
-			if (tmp == LPA_100FULL || tmp == LPA_10FULL)
+		if (!duplex) {
+			if (bmsr & BMSR_ANEGCOMPLETE) {
+				int tmp = mii_nway_result(
+					np->advertising & mdio_read(dev, MII_LPA));
+				if (tmp == LPA_100FULL || tmp == LPA_10FULL)
+					duplex = 1;
+			} else if (mdio_read(dev, MII_BMCR) & BMCR_FULLDPLX)
 				duplex = 1;
-		} else if (mdio_read(dev, MII_BMCR) & BMCR_FULLDPLX)
-			duplex = 1;
+		}
 	}
 
 	/* if duplex is set then bit 28 must be set, too */
@@ -2936,6 +2955,16 @@ static int netdev_set_ecmd(struct net_de
 	}
 
 	/*
+	 * If we're ignoring the PHY then autoneg and the internal
+	 * transciever are really not going to work so don't let the
+	 * user select them.
+	 */
+	if (np->ignore_phy && (ecmd->autoneg == AUTONEG_ENABLE ||
+			       ecmd->port == PORT_TP)) {
+		return -EINVAL;
+	}
+
+	/*
 	 * maxtxpkt, maxrxpkt: ignored for now.
 	 *
 	 * transceiver:
_
