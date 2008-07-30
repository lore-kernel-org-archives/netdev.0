From: akpm@linux-foundation.org
Subject: [patch 03/12] sundance: set carrier status on link change events
Date: Wed, 30 Jul 2008 12:38:56 -0700
Message-ID: <200807301938.m6UJcvJi012505@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dbn.lists@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33645 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753177AbYG3TkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Nicholson <dbn.lists@gmail.com>

Check if the link is available when a changed interrupt has been received and
set the carrier status appropriately.  The code is copied nearly verbatim from
the dl2k module.  The link status could be used in more places in the driver,
but this is enough to get the carrier status reported to userspace.  Fixes
kernel bug #7487:

    http://bugzilla.kernel.org/show_bug.cgi?id=7487

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Dan Nicholson <dbn.lists@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sundance.c |   95 +++++++++++++++++++++++++--------------
 1 file changed, 62 insertions(+), 33 deletions(-)

diff -puN drivers/net/sundance.c~sundance-set-carrier-status-on-link-change-events drivers/net/sundance.c
--- a/drivers/net/sundance.c~sundance-set-carrier-status-on-link-change-events
+++ a/drivers/net/sundance.c
@@ -409,6 +409,7 @@ static int  change_mtu(struct net_device
 static int  eeprom_read(void __iomem *ioaddr, int location);
 static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
+static int  mdio_wait_link(struct net_device *dev, int wait);
 static int  netdev_open(struct net_device *dev);
 static void check_duplex(struct net_device *dev);
 static void netdev_timer(unsigned long data);
@@ -785,6 +786,24 @@ static void mdio_write(struct net_device
 	return;
 }
 
+static int mdio_wait_link(struct net_device *dev, int wait)
+{
+	int bmsr;
+	int phy_id;
+	struct netdev_private *np;
+
+	np = netdev_priv(dev);
+	phy_id = np->phys[0];
+
+	do {
+		bmsr = mdio_read(dev, phy_id, MII_BMSR);
+		if (bmsr & 0x0004)
+			return 0;
+		mdelay(1);
+	} while (--wait > 0);
+	return -1;
+}
+
 static int netdev_open(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -1393,41 +1412,51 @@ static void netdev_error(struct net_devi
 	int speed;
 
 	if (intr_status & LinkChange) {
-		if (np->an_enable) {
-			mii_advertise = mdio_read (dev, np->phys[0], MII_ADVERTISE);
-			mii_lpa= mdio_read (dev, np->phys[0], MII_LPA);
-			mii_advertise &= mii_lpa;
-			printk (KERN_INFO "%s: Link changed: ", dev->name);
-			if (mii_advertise & ADVERTISE_100FULL) {
-				np->speed = 100;
-				printk ("100Mbps, full duplex\n");
-			} else if (mii_advertise & ADVERTISE_100HALF) {
-				np->speed = 100;
-				printk ("100Mbps, half duplex\n");
-			} else if (mii_advertise & ADVERTISE_10FULL) {
-				np->speed = 10;
-				printk ("10Mbps, full duplex\n");
-			} else if (mii_advertise & ADVERTISE_10HALF) {
-				np->speed = 10;
-				printk ("10Mbps, half duplex\n");
-			} else
-				printk ("\n");
+		if (mdio_wait_link(dev, 10) == 0) {
+			printk(KERN_INFO "%s: Link up\n", dev->name);
+			if (np->an_enable) {
+				mii_advertise = mdio_read(dev, np->phys[0],
+							   MII_ADVERTISE);
+				mii_lpa = mdio_read(dev, np->phys[0], MII_LPA);
+				mii_advertise &= mii_lpa;
+				printk(KERN_INFO "%s: Link changed: ",
+					dev->name);
+				if (mii_advertise & ADVERTISE_100FULL) {
+					np->speed = 100;
+					printk("100Mbps, full duplex\n");
+				} else if (mii_advertise & ADVERTISE_100HALF) {
+					np->speed = 100;
+					printk("100Mbps, half duplex\n");
+				} else if (mii_advertise & ADVERTISE_10FULL) {
+					np->speed = 10;
+					printk("10Mbps, full duplex\n");
+				} else if (mii_advertise & ADVERTISE_10HALF) {
+					np->speed = 10;
+					printk("10Mbps, half duplex\n");
+				} else
+					printk("\n");
 
+			} else {
+				mii_ctl = mdio_read(dev, np->phys[0], MII_BMCR);
+				speed = (mii_ctl & BMCR_SPEED100) ? 100 : 10;
+				np->speed = speed;
+				printk(KERN_INFO "%s: Link changed: %dMbps ,",
+					dev->name, speed);
+				printk("%s duplex.\n",
+					(mii_ctl & BMCR_FULLDPLX) ?
+						"full" : "half");
+			}
+			check_duplex(dev);
+			if (np->flowctrl && np->mii_if.full_duplex) {
+				iowrite16(ioread16(ioaddr + MulticastFilter1+2) | 0x0200,
+					ioaddr + MulticastFilter1+2);
+				iowrite16(ioread16(ioaddr + MACCtrl0) | EnbFlowCtrl,
+					ioaddr + MACCtrl0);
+			}
+			netif_carrier_on(dev);
 		} else {
-			mii_ctl = mdio_read (dev, np->phys[0], MII_BMCR);
-			speed = (mii_ctl & BMCR_SPEED100) ? 100 : 10;
-			np->speed = speed;
-			printk (KERN_INFO "%s: Link changed: %dMbps ,",
-				dev->name, speed);
-			printk ("%s duplex.\n", (mii_ctl & BMCR_FULLDPLX) ?
-				"full" : "half");
-		}
-		check_duplex (dev);
-		if (np->flowctrl && np->mii_if.full_duplex) {
-			iowrite16(ioread16(ioaddr + MulticastFilter1+2) | 0x0200,
-				ioaddr + MulticastFilter1+2);
-			iowrite16(ioread16(ioaddr + MACCtrl0) | EnbFlowCtrl,
-				ioaddr + MACCtrl0);
+			printk(KERN_INFO "%s: Link down\n", dev->name);
+			netif_carrier_off(dev);
 		}
 	}
 	if (intr_status & StatsMax) {
_
