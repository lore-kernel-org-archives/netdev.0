From: Mark Brown <broonie@sirena.org.uk>
Subject: [patch 1/2] natsemi: Add support for using MII port with no PHY
Date: Mon, 19 Feb 2007 20:15:39 +0000
Message-ID: <20070219201858.688614000@sirena.org.uk>
References: <20070219201538.420238000@sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:1561 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932621AbXBSUX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 15:23:29 -0500
Content-Disposition: inline; filename=natsemi-ignore-phy.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides code paths which allow the natsemi driver to use the
external MII port on the chip but ignore any PHYs that may be attached to it.
The link state will be left as it was when the driver started and can be
configured via ethtool.  Any PHYs that are present can be accessed via the MII
ioctl()s.

This is useful for systems where the device is connected without a PHY
or where either information or actions outside the scope of the driver
are required in order to use the PHYs.

Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

---

This revision of the patch fixes some issues brought up during review.

Previous versions of this patch exposed the new functionality as a module
option.  This has been removed.  Any hardware that needs this should be
identifiable by a quirk since it unlikely to behave correctly with an
unmodified driver.

Index: linux/drivers/net/natsemi.c
===================================================================
--- linux.orig/drivers/net/natsemi.c	2007-02-19 10:10:40.000000000 +0000
+++ linux/drivers/net/natsemi.c	2007-02-19 10:20:45.000000000 +0000
@@ -568,6 +568,8 @@
 	u32 intr_status;
 	/* Do not touch the nic registers */
 	int hands_off;
+	/* Don't pay attention to the reported link state. */
+	int ignore_phy;
 	/* external phy that is used: only valid if dev->if_port != PORT_TP */
 	int mii;
 	int phy_addr_external;
@@ -696,7 +698,10 @@
 	struct netdev_private *np = netdev_priv(dev);
 	u32 tmp;
 
-	netif_carrier_off(dev);
+	if (np->ignore_phy)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
 
 	/* get the initial settings from hardware */
 	tmp            = mdio_read(dev, MII_BMCR);
@@ -806,8 +811,10 @@
 	np->hands_off = 0;
 	np->intr_status = 0;
 	np->eeprom_size = natsemi_pci_info[chip_idx].eeprom_size;
+	np->ignore_phy = 0;
 
 	/* Initial port:
+	 * - If configured to ignore the PHY set up for external.
 	 * - If the nic was configured to use an external phy and if find_mii
 	 *   finds a phy: use external port, first phy that replies.
 	 * - Otherwise: internal port.
@@ -815,7 +822,7 @@
 	 * The address would be used to access a phy over the mii bus, but
 	 * the internal phy is accessed through mapped registers.
 	 */
-	if (readl(ioaddr + ChipConfig) & CfgExtPhy)
+	if (np->ignore_phy || readl(ioaddr + ChipConfig) & CfgExtPhy)
 		dev->if_port = PORT_MII;
 	else
 		dev->if_port = PORT_TP;
@@ -825,7 +832,9 @@
 
 	if (dev->if_port != PORT_TP) {
 		np->phy_addr_external = find_mii(dev);
-		if (np->phy_addr_external == PHY_ADDR_NONE) {
+		/* If we're ignoring the PHY it doesn't matter if we can't
+		 * find one. */
+		if (!np->ignore_phy && np->phy_addr_external == PHY_ADDR_NONE) {
 			dev->if_port = PORT_TP;
 			np->phy_addr_external = PHY_ADDR_INTERNAL;
 		}
@@ -891,6 +900,8 @@
 		printk("%02x, IRQ %d", dev->dev_addr[i], irq);
 		if (dev->if_port == PORT_TP)
 			printk(", port TP.\n");
+		else if (np->ignore_phy)
+			printk(", port MII, ignoring PHY\n");
 		else
 			printk(", port MII, phy ad %d.\n", np->phy_addr_external);
 	}
@@ -1571,9 +1582,13 @@
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
-	int duplex;
+	int duplex = np->duplex;
 	u16 bmsr;
 
+	/* If we are ignoring the PHY then don't try reading it. */
+	if (np->ignore_phy)
+		goto propagate_state;
+
 	/* The link status field is latched: it remains low after a temporary
 	 * link failure until it's read. We need the current link status,
 	 * thus read twice.
@@ -1585,7 +1600,7 @@
 		if (netif_carrier_ok(dev)) {
 			if (netif_msg_link(np))
 				printk(KERN_NOTICE "%s: link down.\n",
-					dev->name);
+				       dev->name);
 			netif_carrier_off(dev);
 			undo_cable_magic(dev);
 		}
@@ -1609,6 +1624,7 @@
 			duplex = 1;
 	}
 
+propagate_state:
 	/* if duplex is set then bit 28 must be set, too */
 	if (duplex ^ !!(np->rx_config & RxAcceptTx)) {
 		if (netif_msg_link(np))
@@ -2819,6 +2835,15 @@
 	}
 
 	/*
+	 * If we're ignoring the PHY then autoneg and the internal
+	 * transciever are really not going to work so don't let the
+	 * user select them.
+	 */
+	if (np->ignore_phy && (ecmd->autoneg == AUTONEG_ENABLE ||
+			       ecmd->port == PORT_TP))
+		return -EINVAL;
+
+	/*
 	 * maxtxpkt, maxrxpkt: ignored for now.
 	 *
 	 * transceiver:

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
