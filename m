From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.17] AT91RM9200 Ethernet #1: Link poll
Date: 20 Jun 2006 11:50:23 +0200
Message-ID: <1150797022.15581.329.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sanpeople.com ([196.41.13.122]:39691 "EHLO
	za-gw.sanpeople.com") by vger.kernel.org with ESMTP id S932537AbWFTJzh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 05:55:37 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For Ethernet PHYs that don't have an IRQ pin or boards that don't
connect the IRQ pin to the processor, we enable a timer to poll the
PHY's link state.

Patch originally supplied by Eric Benard and Roman Kolesnikov.


Signed-off-by: Andrew Victor <andrew@sanpeople.com>

diff -urN linux-2.6.17.orig/drivers/net/arm/at91_ether.c linux-2.6.17/drivers/net/arm/at91_ether.c
--- linux-2.6.17.orig/drivers/net/arm/at91_ether.c	Tue Jun 20 11:27:37 2006
+++ linux-2.6.17/drivers/net/arm/at91_ether.c	Tue Jun 20 11:31:06 2006
@@ -45,6 +45,9 @@
 static struct net_device *at91_dev;
 static struct clk *ether_clk;
 
+static struct timer_list check_timer;
+#define LINK_POLL_INTERVAL	(HZ)
+
 /* ..................................................................... */
 
 /*
@@ -143,7 +146,7 @@
  * MAC accordingly.
  * If no link or auto-negotiation is busy, then no changes are made.
  */
-static void update_linkspeed(struct net_device *dev)
+static void update_linkspeed(struct net_device *dev, int silent)
 {
 	struct at91_private *lp = (struct at91_private *) dev->priv;
 	unsigned int bmsr, bmcr, lpa, mac_cfg;
@@ -151,7 +154,8 @@
 
 	if (!mii_link_ok(&lp->mii)) {		/* no link */
 		netif_carrier_off(dev);
-		printk(KERN_INFO "%s: Link down.\n", dev->name);
+		if (!silent)
+			printk(KERN_INFO "%s: Link down.\n", dev->name);
 		return;
 	}
 
@@ -186,7 +190,8 @@
 	}
 	at91_emac_write(AT91_EMAC_CFG, mac_cfg);
 
-	printk(KERN_INFO "%s: Link now %i-%s\n", dev->name, speed, (duplex == DUPLEX_FULL) ? "FullDuplex" : "HalfDuplex");
+	if (!silent)
+		printk(KERN_INFO "%s: Link now %i-%s\n", dev->name, speed, (duplex == DUPLEX_FULL) ? "FullDuplex" : "HalfDuplex");
 	netif_carrier_on(dev);
 }
 
@@ -226,7 +231,7 @@
 			goto done;
 	}
 
-	update_linkspeed(dev);
+	update_linkspeed(dev, 0);
 
 done:
 	disable_mdi();
@@ -243,14 +248,17 @@
 	unsigned int dsintr, irq_number;
 	int status;
 
-	if (lp->phy_type == MII_RTL8201_ID)	/* RTL8201 does not have an interrupt */
-		return;
-	if (lp->phy_type == MII_DP83847_ID)	/* DP83847 does not have an interrupt */
-		return;
-	if (lp->phy_type == MII_AC101L_ID)	/* AC101L interrupt not supported yet */
+	irq_number = lp->board_data.phy_irq_pin;
+	if (!irq_number) {
+		/*
+		 * PHY doesn't have an IRQ pin (RTL8201, DP83847, AC101L),
+		 * or board does not have it connected.
+		 */
+		check_timer.expires = jiffies + LINK_POLL_INTERVAL;
+		add_timer(&check_timer);
 		return;
+	}
 
-	irq_number = lp->board_data.phy_irq_pin;
 	status = request_irq(irq_number, at91ether_phy_interrupt, 0, dev->name, dev);
 	if (status) {
 		printk(KERN_ERR "at91_ether: PHY IRQ %d request failed - status %d!\n", irq_number, status);
@@ -292,12 +300,11 @@
 	unsigned int dsintr;
 	unsigned int irq_number;
 
-	if (lp->phy_type == MII_RTL8201_ID) 	/* RTL8201 does not have an interrupt */
-		return;
-	if (lp->phy_type == MII_DP83847_ID)	/* DP83847 does not have an interrupt */
-		return;
-	if (lp->phy_type == MII_AC101L_ID)	/* AC101L interrupt not supported yet */
+	irq_number = lp->board_data.phy_irq_pin;
+	if (!irq_number) {
+		del_timer_sync(&check_timer);
 		return;
+	}
 
 	spin_lock_irq(&lp->lock);
 	enable_mdi();
@@ -326,7 +333,6 @@
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
 
-	irq_number = lp->board_data.phy_irq_pin;
 	free_irq(irq_number, dev);			/* Free interrupt handler */
 }
 
@@ -355,6 +361,18 @@
 }
 #endif
 
+static void at91ether_check_link(unsigned long dev_id)
+{
+	struct net_device *dev = (struct net_device *) dev_id;
+
+	enable_mdi();
+	update_linkspeed(dev, 1);
+	disable_mdi();
+
+	check_timer.expires = jiffies + LINK_POLL_INTERVAL;
+	add_timer(&check_timer);
+}
+
 /* ......................... ADDRESS MANAGEMENT ........................ */
 
 /*
@@ -708,7 +727,7 @@
 	/* Determine current link speed */
 	spin_lock_irq(&lp->lock);
 	enable_mdi();
-	update_linkspeed(dev);
+	update_linkspeed(dev, 0);
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
 
@@ -992,11 +1011,18 @@
 	/* Determine current link speed */
 	spin_lock_irq(&lp->lock);
 	enable_mdi();
-	update_linkspeed(dev);
+	update_linkspeed(dev, 0);
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
 	netif_carrier_off(dev);		/* will be enabled in open() */
 
+	/* If board has no PHY IRQ, use a timer to poll the PHY */
+	if (!lp->board_data.phy_irq_pin) {
+		init_timer(&check_timer);
+		check_timer.data = (unsigned long)dev;
+		check_timer.function = at91ether_check_link;
+	}
+
 	/* Display ethernet banner */
 	printk(KERN_INFO "%s: AT91 ethernet at 0x%08x int=%d %s%s (%02x:%02x:%02x:%02x:%02x:%02x)\n",
 		dev->name, (uint) dev->base_addr, dev->irq,



