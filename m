From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 06/22] NET: DM9000: Use kthread to probe MII status when device open
Date: Mon, 19 Nov 2007 20:39:16 +0000
Message-ID: <20071119204013.745821010@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61658 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751715AbXKSVOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:14:21 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-phy-usekthread.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the device is open, we have to probe the PHY's MII status
periodically as there is no status change interrupt. As the 
phy code is going to change to using calls which might sleep
we move to using a kthread instead of a timer.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -66,6 +66,8 @@
 #include <linux/ethtool.h>
 #include <linux/dm9000.h>
 #include <linux/delay.h>
+#include <linux/kthread.h>
+#include <linux/freezer.h>
 #include <linux/platform_device.h>
 
 #include <asm/delay.h>
@@ -82,8 +84,6 @@
 #define PFX CARDNAME ": "
 #define DRV_VERSION	"1.30"
 
-#define DM9000_TIMER_WUT  jiffies+(HZ*2)	/* timer wakeup time : 2 second */
-
 #ifdef CONFIG_BLACKFIN
 #define readsb	insb
 #define readsw	insw
@@ -131,7 +131,7 @@ typedef struct board_info {
 	struct resource *data_req;
 	struct resource *irq_res;
 
-	struct timer_list timer;
+	struct task_struct *thread;
 	struct net_device_stats stats;
 	unsigned char srom[128];
 	spinlock_t lock;
@@ -159,9 +159,8 @@ static int dm9000_probe(struct platform_
 static int dm9000_open(struct net_device *);
 static int dm9000_start_xmit(struct sk_buff *, struct net_device *);
 static int dm9000_stop(struct net_device *);
+static int dm9000_mii_thread(void *data);
 
-
-static void dm9000_timer(unsigned long);
 static void dm9000_init_dm9000(struct net_device *);
 
 static struct net_device_stats *dm9000_get_stats(struct net_device *);
@@ -679,6 +678,27 @@ dm9000_probe(struct platform_device *pde
 	return ret;
 }
 
+static void dm9000_start_thread(struct net_device *dev)
+{
+	board_info_t *db = (board_info_t *) dev->priv;
+
+	/* Create a thread to keep track of the state of the phy
+	 * as we do not get an interrupt when the PHY state changes.
+	 *
+	 * Note, we do not abort the open if we fail to create the
+	 * thread, as this is mainly to ensure the user is kept up to
+	 * date with the device's state. PHY accesses will still work
+	 * via the MII read and write methods.
+	 */
+
+	db->thread = kthread_create(dm9000_mii_thread, db, dev->name);
+	if (IS_ERR(db->thread)) {
+		dev_err(db->dev, "failed to create MII thread\n");
+		db->thread = NULL;
+	} else
+		wake_up_process(db->thread);
+}
+
 /*
  *  Open the interface.
  *  The interface is opened whenever "ifconfig" actives it.
@@ -704,12 +724,7 @@ dm9000_open(struct net_device *dev)
 	/* Init driver variable */
 	db->dbug_cnt = 0;
 
-	/* set and active a timer process */
-	init_timer(&db->timer);
-	db->timer.expires  = DM9000_TIMER_WUT;
-	db->timer.data     = (unsigned long) dev;
-	db->timer.function = &dm9000_timer;
-	add_timer(&db->timer);
+	dm9000_start_thread(dev);
 
 	mii_check_media(&db->mii, netif_msg_link(db), 1);
 	netif_start_queue(dev);
@@ -833,7 +848,7 @@ dm9000_stop(struct net_device *ndev)
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
 	/* deleted timer */
-	del_timer(&db->timer);
+	kthread_stop(db->thread);
 
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
@@ -925,24 +940,31 @@ dm9000_get_stats(struct net_device *dev)
 	return &db->stats;
 }
 
+#define DM9000_MII_POLLFREQ	(2000)
 
-/*
- *  A periodic timer routine
- *  Dynamic media sense, allocated Rx buffer...
- */
-static void
-dm9000_timer(unsigned long data)
+static int
+dm9000_mii_thread(void *pw)
 {
-	struct net_device *dev = (struct net_device *) data;
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = pw;
+	unsigned long next = jiffies + msecs_to_jiffies(DM9000_MII_POLLFREQ);
 
 	dm9000_dbg(db, 3, "entering %s\n", __func__);
 
-	mii_check_media(&db->mii, netif_msg_link(db), 0);
+	while (!kthread_should_stop()) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		try_to_freeze();
+
+		if (time_after(jiffies, next)) {
+			mii_check_media(&db->mii, netif_msg_link(db), 0);
+			next = jiffies;
+			next += msecs_to_jiffies(DM9000_MII_POLLFREQ);
+		}
+
+		msleep_interruptible(DM9000_MII_POLLFREQ);
+	}
 
-	/* Set timer again */
-	db->timer.expires = DM9000_TIMER_WUT;
-	add_timer(&db->timer);
+	dm9000_dbg(db, 3, "leaving %s\n", __func__);
+	return 0;
 }
 
 struct dm9000_rxhdr {

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
