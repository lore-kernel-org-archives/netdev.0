From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCHv2 net-next 6/6] arcnet: add netif_carrier_on/off for reconnect
Date: Mon, 26 Oct 2015 09:23:20 +0100
Message-ID: <1445847800-13975-7-git-send-email-m.grzeschik@pengutronix.de>
References: <1445847800-13975-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:34905 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbbJZIXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 04:23:32 -0400
In-Reply-To: <1445847800-13975-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The arcnet device has no interrupt to detect if the link has changed
from disconnected to connected. This patch adds an timer to toggle the
link detection. The timer will get retriggered as long as the
reconnection interrupts accure. If the recon interrupts hold off
for >1s we define the connection stable again.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h |  2 ++
 drivers/net/arcnet/arcnet.c    | 25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index 2edc0c0..20bfb9b 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -267,6 +267,8 @@ struct arcnet_local {
 	struct led_trigger *recon_led_trig;
 	char recon_led_trig_name[ARCNET_LED_NAME_SZ];
 
+	struct timer_list	timer;
+
 	/*
 	 * Buffer management: an ARCnet card has 4 x 512-byte buffers, each of
 	 * which can be used for either sending or receiving.  The new dynamic
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 4242522..6ea963e 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -381,6 +381,16 @@ static void arcdev_setup(struct net_device *dev)
 	dev->flags = IFF_BROADCAST;
 }
 
+static void arcnet_timer(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+
+	if (!netif_carrier_ok(dev)) {
+		netif_carrier_on(dev);
+		netdev_info(dev, "link up\n");
+	}
+}
+
 struct net_device *alloc_arcdev(const char *name)
 {
 	struct net_device *dev;
@@ -392,6 +402,9 @@ struct net_device *alloc_arcdev(const char *name)
 		struct arcnet_local *lp = netdev_priv(dev);
 
 		spin_lock_init(&lp->lock);
+		init_timer(&lp->timer);
+		lp->timer.data = (unsigned long) dev;
+		lp->timer.function = arcnet_timer;
 	}
 
 	return dev;
@@ -490,7 +503,9 @@ int arcnet_open(struct net_device *dev)
 	lp->hw.intmask(dev, lp->intmask);
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
+	netif_carrier_off(dev);
 	netif_start_queue(dev);
+	mod_timer(&lp->timer, jiffies + msecs_to_jiffies(1000));
 
 	arcnet_led_event(dev, ARCNET_LED_EVENT_OPEN);
 	return 0;
@@ -507,7 +522,10 @@ int arcnet_close(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 
 	arcnet_led_event(dev, ARCNET_LED_EVENT_STOP);
+	del_timer_sync(&lp->timer);
+
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 
 	/* flush TX and disable RX */
 	lp->hw.intmask(dev, 0);
@@ -908,6 +926,12 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 			arc_printk(D_RECON, dev, "Network reconfiguration detected (status=%Xh)\n",
 				   status);
+			if (netif_carrier_ok(dev)) {
+				netif_carrier_off(dev);
+				netdev_info(dev, "link down\n");
+			}
+			mod_timer(&lp->timer, jiffies + msecs_to_jiffies(1000));
+
 			arcnet_led_event(dev, ARCNET_LED_EVENT_RECON);
 			/* MYRECON bit is at bit 7 of diagstatus */
 			if (diagstatus & 0x80)
@@ -959,6 +983,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			lp->num_recons = lp->network_down = 0;
 
 			arc_printk(D_DURING, dev, "not recon: clearing counters anyway.\n");
+			netif_carrier_on(dev);
 		}
 
 		if (didsomething)
-- 
2.6.1
