From: Jens Osterkamp <jens@de.ibm.com>
Subject: spidernet: dynamic phy setup code
Date: Fri, 26 Jan 2007 14:09:29 +0100
Message-ID: <200701261409.29537.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, Linas Vepstas <linas@austin.ibm.com>,
	jgarzik@pobox.com, James K Lewis <jim@jklewis.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:7054 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965655AbXAZNJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 08:09:32 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l0QD9VcJ102686
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 13:09:31 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0QD9UQH790688
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 13:09:30 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0QD9T6h032153
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 13:09:30 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch modifies the patch submitted by Kou Ishizaki to make it work on the
blade (http://marc.theaimsgroup.com/?l=linux-netdev&m=116593424505539&w=2).
Unfortunately I dont have access to a Celleb so I cannot test it there.

The basic logic behind this is simple : when the interface first comes up
it tries to detect the phy. When the phy is detected, it is initially set up
to use copper. A timer is set to check the link status in spidernet_link_phy
using poll_link. If link check fails more than SPIDER_NET_ANEG_TIMEOUT
times, it switches to fiber link with autonegotiation. If that fails more
than SPIDER_NET_ANEG_TIMEOUT times, it switches to fiber link with no
autonegotiation. If that also fails, it goes back to copper, and so forth.
If the link comes up, it prints the link abilites and we are done.

The name of the phy found attached to the spider chip is reported to the
user. Hardcoded values for the timeout are moved to #defines. I put in a
few comments to make the code more readable.

Signed-off-by: Jens Osterkamp <jens@de.ibm.com>
Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>

Index: linux-2.6/drivers/net/spider_net.c
===================================================================
--- linux-2.6.orig/drivers/net/spider_net.c
+++ linux-2.6/drivers/net/spider_net.c
@@ -1280,19 +1280,23 @@ spider_net_set_mac(struct net_device *ne
  * spider_net_link_reset
  * @netdev: net device structure
  *
+ * This is called when the PHY_LINK signal is asserted. For the blade this is
+ * not connected so we should never get here.
+ *
  */
 static void
 spider_net_link_reset(struct net_device *netdev)
 {
-
  struct spider_net_card *card=netdev_priv(netdev);
 
  del_timer_sync(&card->aneg_timer);
 
+ /* clear interrupt, block further interrupts */
  spider_net_write_reg(card, SPIDER_NET_GMACST,
         spider_net_read_reg(card, SPIDER_NET_GMACST));
  spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
 
+ /* reset phy and setup aneg */
  mii_phy_probe(&card->phy, card->phy.mii_id);
  spider_net_setup_aneg(card, is1000);
  if (card->phy.def->phy_id)
@@ -1616,6 +1620,7 @@ spider_net_init_card(struct spider_net_c
  spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
         SPIDER_NET_CKRCTRL_RUN_VALUE);
 
+ /* trigger ETOMOD signal */
  spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
                       spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
 
@@ -1739,6 +1744,8 @@ spider_net_open(struct net_device *netde
  if (spider_net_init_firmware(card))
   goto init_firmware_failed;
 
+ /* start probing with copper */
+ card->phy.medium = GMII_COPPER;
  spider_net_setup_aneg(card, is1000);
  if (card->phy.def->phy_id)
   mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
@@ -1805,43 +1812,54 @@ static void spider_net_link_phy(unsigned
  struct spider_net_card *card = (struct spider_net_card *)data;
  struct mii_phy *phy = &card->phy;
 
- if (card->aneg_count > 10) {
-  /* timeout */
-  card->aneg_count = 0;
-  is1000 = !is1000;
-  goto re_setup;
+ /* if link didn't come up after SPIDER_NET_ANEG_TIMEOUT tries, setup phy 
again */
+ if (card->aneg_count > SPIDER_NET_ANEG_TIMEOUT) {
+
+  pr_info("%s: link is down, trying to bring it up\n", card->netdev->name);
+
+  switch(phy->medium) {
+  case GMII_COPPER:
+   /* enable fiber with autonegotiation first */
+   if (phy->def->ops->enable_fiber)
+    phy->def->ops->enable_fiber(phy, 1);
+   phy->medium = GMII_FIBER;
+   break;
+
+  case GMII_FIBER:
+   /* fiber didn't come up, try to disable fiber autoneg */
+   if (phy->def->ops->enable_fiber)
+    phy->def->ops->enable_fiber(phy, 0);
+   phy->medium = GMII_UNKNOWN;
+   break;
+
+  case GMII_UNKNOWN:
+   /* copper, fiber with and without autoneg failed,
+    * retry from beginning */
+   spider_net_setup_aneg(card, is1000);
+   phy->medium = GMII_COPPER;
+   break;
+  }
+
+ card->aneg_count = 0;
+ mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+ return;
  }
 
+ /* link still not up, try again later */
  if (!(phy->def->ops->poll_link(phy))) {
   card->aneg_count++;
   mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
   return;
  }
 
+ /* link came up, get abilities */
  phy->def->ops->read_link(phy);
 
- if (phy->speed == 1000 && !is1000) {
-  is1000 = 1;
-  goto re_setup;
- } else if(phy->speed != 1000 && is1000) {
-  is1000 = 0;
-  goto re_setup;
- }
-
- spider_net_write_reg(card, SPIDER_NET_GMACST,
-        spider_net_read_reg(card, SPIDER_NET_GMACST));
- spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0x4);
-
- pr_info("Found %s with %i Mbps, %s-duplex.\n",
-  phy->def->name, phy->speed, phy->duplex==1 ? "Full" : "Half");
+ pr_info("%s: link is up with %i Mbps, %s-duplex, %sautoneg.\n",
+  card->netdev->name, phy->speed, phy->duplex==1 ? "Full" : "Half",
+  phy->autoneg==1 ? "" : "no ");
 
  return;
-
-re_setup:
- mii_phy_probe(phy, phy->mii_id);
- spider_net_setup_aneg(card, is1000);
- card->aneg_count = 0;
- mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
 }
 
 /**
@@ -1871,8 +1889,10 @@ spider_net_setup_phy(struct spider_net_c
   unsigned short id;
   id = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
   if (id != 0x0000 && id != 0xffff) {
-   mii_phy_probe(phy, phy->mii_id);
+   if (!mii_phy_probe(phy, phy->mii_id)) {
+    pr_info("Found %s.\n", phy->def->name);
    break;
+   }
   }
  }
 
Index: linux-2.6/drivers/net/spider_net.h
===================================================================
--- linux-2.6.orig/drivers/net/spider_net.h
+++ linux-2.6/drivers/net/spider_net.h
@@ -51,7 +51,8 @@ extern char spider_net_driver_name[];
 #define SPIDER_NET_TX_DESCRIPTORS_MAX  512
 
 #define SPIDER_NET_TX_TIMER   (HZ/5)
-#define SPIDER_NET_ANEG_TIMER   (HZ*2)
+#define SPIDER_NET_ANEG_TIMER   (HZ)
+#define SPIDER_NET_ANEG_TIMEOUT   2
 
 #define SPIDER_NET_RX_CSUM_DEFAULT  1
 
