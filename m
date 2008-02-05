From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 06/24 for-2.6.25] DM9000: Remove old timer based poll routines
Date: Tue, 05 Feb 2008 00:02:05 +0000
Message-ID: <20080205000815.579736299@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58747 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755596AbYBEAIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:25 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-remove-poll.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the timer based MII phy polling, as this is
currently broken with the new EEPROM code that now
uses mutexes to protect the phy access.

This will need to be replaced in the future by some
form of mutex safe mechanism for reading the MII
phy status.

The replacement has not been done here as changing
this patch, which is early in the sequence has quite
a knock-on effect. Once this series is merged, then
a new presentation of an patch to poll the MII link
status can be added.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt2/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt2.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt2/drivers/net/dm9000.c
@@ -81,8 +81,6 @@
 #define CARDNAME "dm9000"
 #define PFX CARDNAME ": "
 
-#define DM9000_TIMER_WUT  jiffies+(HZ*2)	/* timer wakeup time : 2 second */
-
 #ifdef CONFIG_BLACKFIN
 #define readsb	insb
 #define readsw	insw
@@ -131,7 +129,6 @@ typedef struct board_info {
 	struct resource *data_req;
 	struct resource *irq_res;
 
-	struct timer_list timer;
 	unsigned char srom[128];
 	spinlock_t lock;
 
@@ -154,8 +151,6 @@ static int dm9000_open(struct net_device
 static int dm9000_start_xmit(struct sk_buff *, struct net_device *);
 static int dm9000_stop(struct net_device *);
 
-
-static void dm9000_timer(unsigned long);
 static void dm9000_init_dm9000(struct net_device *);
 
 static irqreturn_t dm9000_interrupt(int, void *);
@@ -638,13 +633,6 @@ dm9000_open(struct net_device *dev)
 	/* Init driver variable */
 	db->dbug_cnt = 0;
 
-	/* set and active a timer process */
-	init_timer(&db->timer);
-	db->timer.expires  = DM9000_TIMER_WUT;
-	db->timer.data     = (unsigned long) dev;
-	db->timer.function = &dm9000_timer;
-	add_timer(&db->timer);
-
 	mii_check_media(&db->mii, netif_msg_link(db), 1);
 	netif_start_queue(dev);
 
@@ -766,9 +754,6 @@ dm9000_stop(struct net_device *ndev)
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
-	/* deleted timer */
-	del_timer(&db->timer);
-
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
 
@@ -849,25 +834,6 @@ dm9000_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-/*
- *  A periodic timer routine
- *  Dynamic media sense, allocated Rx buffer...
- */
-static void
-dm9000_timer(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	board_info_t *db = (board_info_t *) dev->priv;
-
-	dm9000_dbg(db, 3, "entering %s\n", __func__);
-
-	mii_check_media(&db->mii, netif_msg_link(db), 0);
-
-	/* Set timer again */
-	db->timer.expires = DM9000_TIMER_WUT;
-	add_timer(&db->timer);
-}
-
 struct dm9000_rxhdr {
 	u8	RxPktReady;
 	u8	RxStatus;

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
