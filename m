From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 1/8] ibm_newemac: Fix possible lockup on close
Date: Wed, 21 Nov 2007 17:06:39 +1100
Message-ID: <20071121060729.71A1FDDE01@ozlabs.org>
References: <1195625198.76200.922309668615.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38828 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbXKUGHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 01:07:31 -0500
In-Reply-To: <1195625198.76200.922309668615.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's a bad idea to call flush_scheduled_work from within a
netdev->stop because the linkwatch will occasionally take the
rtnl lock from a workqueue context, and thus that can deadlock.

This reworks things a bit in that area to avoid the problem.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/net/ibm_newemac/core.c |   31 ++++++++++++++++++++-----------
 drivers/net/ibm_newemac/core.h |    1 +
 2 files changed, 21 insertions(+), 11 deletions(-)

Index: linux-work/drivers/net/ibm_newemac/core.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.c	2007-11-20 14:42:50.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.c	2007-11-20 14:46:51.000000000 +1100
@@ -642,9 +642,11 @@ static void emac_reset_work(struct work_
 	DBG(dev, "reset_work" NL);
 
 	mutex_lock(&dev->link_lock);
-	emac_netif_stop(dev);
-	emac_full_tx_reset(dev);
-	emac_netif_start(dev);
+	if (dev->opened) {
+		emac_netif_stop(dev);
+		emac_full_tx_reset(dev);
+		emac_netif_start(dev);
+	}
 	mutex_unlock(&dev->link_lock);
 }
 
@@ -1063,10 +1065,9 @@ static int emac_open(struct net_device *
 	dev->rx_sg_skb = NULL;
 
 	mutex_lock(&dev->link_lock);
+	dev->opened = 1;
 
-	/* XXX Start PHY polling now. Shouldn't wr do like sungem instead and
-	 * always poll the PHY even when the iface is down ? That would allow
-	 * things like laptop-net to work. --BenH
+	/* Start PHY polling now.
 	 */
 	if (dev->phy.address >= 0) {
 		int link_poll_interval;
@@ -1145,9 +1146,11 @@ static void emac_link_timer(struct work_
 	int link_poll_interval;
 
 	mutex_lock(&dev->link_lock);
-
 	DBG2(dev, "link timer" NL);
 
+	if (!dev->opened)
+		goto bail;
+
 	if (dev->phy.def->ops->poll_link(&dev->phy)) {
 		if (!netif_carrier_ok(dev->ndev)) {
 			/* Get new link parameters */
@@ -1170,13 +1173,14 @@ static void emac_link_timer(struct work_
 		link_poll_interval = PHY_POLL_LINK_OFF;
 	}
 	schedule_delayed_work(&dev->link_work, link_poll_interval);
-
+ bail:
 	mutex_unlock(&dev->link_lock);
 }
 
 static void emac_force_link_update(struct emac_instance *dev)
 {
 	netif_carrier_off(dev->ndev);
+	smp_rmb();
 	if (dev->link_polling) {
 		cancel_rearming_delayed_work(&dev->link_work);
 		if (dev->link_polling)
@@ -1191,11 +1195,14 @@ static int emac_close(struct net_device 
 
 	DBG(dev, "close" NL);
 
-	if (dev->phy.address >= 0)
+	if (dev->phy.address >= 0) {
+		dev->link_polling = 0;
 		cancel_rearming_delayed_work(&dev->link_work);
-
+	}
+	mutex_lock(&dev->link_lock);
 	emac_netif_stop(dev);
-	flush_scheduled_work();
+	dev->opened = 0;
+	mutex_unlock(&dev->link_lock);
 
 	emac_rx_disable(dev);
 	emac_tx_disable(dev);
@@ -2756,6 +2763,8 @@ static int __devexit emac_remove(struct 
 
 	unregister_netdev(dev->ndev);
 
+	flush_scheduled_work();
+
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
 		tah_detach(dev->tah_dev, dev->tah_port);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
Index: linux-work/drivers/net/ibm_newemac/core.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.h	2007-11-20 14:42:50.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.h	2007-11-20 14:46:51.000000000 +1100
@@ -258,6 +258,7 @@ struct emac_instance {
 	int				stop_timeout;	/* in us */
 	int				no_mcast;
 	int				mcast_pending;
+	int				opened;
 	struct work_struct		reset_work;
 	spinlock_t			lock;
 };
