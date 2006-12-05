From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.19 2/4] AT91RM9200 Ethernet: Move check_timer variable
	and use mod_timer()
Date: 05 Dec 2006 15:21:19 +0200
Message-ID: <1165324879.19827.80.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:3611 "EHLO
	za-gw.sanpeople.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937551AbWLENbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 08:31:09 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the global 'check_timer' variable into the private data structure.
Also now use mod_timer().

Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
--- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Tue Dec  5 11:42:55 2006
+++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Tue Dec  5 11:50:49 2006
@@ -41,7 +41,6 @@
 #define DRV_NAME	"at91_ether"
 #define DRV_VERSION	"1.0"
 
-static struct timer_list check_timer;
 #define LINK_POLL_INTERVAL	(HZ)
 
 /* ..................................................................... */
@@ -250,8 +249,7 @@
 		 * PHY doesn't have an IRQ pin (RTL8201, DP83847, AC101L),
 		 * or board does not have it connected.
 		 */
-		check_timer.expires = jiffies + LINK_POLL_INTERVAL;
-		add_timer(&check_timer);
+		mod_timer(&lp->check_timer, jiffies + LINK_POLL_INTERVAL);
 		return;
 	}
 
@@ -298,7 +296,7 @@
 
 	irq_number = lp->board_data.phy_irq_pin;
 	if (!irq_number) {
-		del_timer_sync(&check_timer);
+		del_timer_sync(&lp->check_timer);
 		return;
 	}
 
@@ -360,13 +358,13 @@
 static void at91ether_check_link(unsigned long dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
+	struct at91_private *lp = netdev_priv(dev);
 
 	enable_mdi();
 	update_linkspeed(dev, 1);
 	disable_mdi();
 
-	check_timer.expires = jiffies + LINK_POLL_INTERVAL;
-	add_timer(&check_timer);
+	mod_timer(&lp->check_timer, jiffies + LINK_POLL_INTERVAL);
 }
 
 /* ......................... ADDRESS MANAGEMENT ........................ */
@@ -1030,9 +1028,9 @@
 
 	/* If board has no PHY IRQ, use a timer to poll the PHY */
 	if (!lp->board_data.phy_irq_pin) {
-		init_timer(&check_timer);
-		check_timer.data = (unsigned long)dev;
-		check_timer.function = at91ether_check_link;
+		init_timer(&lp->check_timer);
+		lp->check_timer.data = (unsigned long)dev;
+		lp->check_timer.function = at91ether_check_link;
 	}
 
 	/* Display ethernet banner */
diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.h linux-2.6.19-final/drivers/net/arm/at91_ether.h
--- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.h	Tue Dec  5 10:09:13 2006
+++ linux-2.6.19-final/drivers/net/arm/at91_ether.h	Tue Dec  5 11:50:22 2006
@@ -87,6 +87,7 @@
 	spinlock_t lock;			/* lock for MDI interface */
 	short phy_media;			/* media interface type */
 	unsigned short phy_address;		/* 5-bit MDI address of PHY (0..31) */
+	struct timer_list check_timer;		/* Poll link status */
 
 	/* Transmit */
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */



