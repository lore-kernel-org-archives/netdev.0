From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 1/4] arcnet: add err_skb package for package status feedback
Date: Wed, 28 Jun 2017 18:32:18 +0200
Message-ID: <20170628163221.32301-2-m.grzeschik@pengutronix.de>
References: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42483 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752467AbdF1Qc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:32:29 -0400
In-Reply-To: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to track the status of our queued packages. This way the driving
process knows if failed packages need to be retransmitted. For this
purpose we queue the transferred/failed packages back into the err_skb
message queue added with some status information.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h |  4 +++
 drivers/net/arcnet/arcnet.c    | 74 ++++++++++++++++++++++++++++++++++++------
 2 files changed, 68 insertions(+), 10 deletions(-)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index 20bfb9ba83ea2..cbb4f8566bbe5 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -269,6 +269,10 @@ struct arcnet_local {
 
 	struct timer_list	timer;
 
+	struct net_device *dev;
+	int reply_status;
+	struct tasklet_struct reply_tasklet;
+
 	/*
 	 * Buffer management: an ARCnet card has 4 x 512-byte buffers, each of
 	 * which can be used for either sending or receiving.  The new dynamic
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 62ee439d58829..d87f4da29f113 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -51,6 +51,7 @@
 #include <net/arp.h>
 #include <linux/init.h>
 #include <linux/jiffies.h>
+#include <linux/errqueue.h>
 
 #include <linux/leds.h>
 
@@ -391,6 +392,52 @@ static void arcnet_timer(unsigned long data)
 	}
 }
 
+static void arcnet_reply_tasklet(unsigned long data)
+{
+	struct arcnet_local *lp = (struct arcnet_local *)data;
+
+	struct sk_buff *ackskb, *skb;
+	struct sock_exterr_skb *serr;
+	struct sock *sk;
+	int ret;
+
+	local_irq_disable();
+	skb = lp->outgoing.skb;
+	if (!skb || !skb->sk) {
+		local_irq_enable();
+		return;
+	}
+
+	sock_hold(skb->sk);
+	sk = skb->sk;
+	ackskb = skb_clone_sk(skb);
+	sock_put(skb->sk);
+
+	if (!ackskb) {
+		local_irq_enable();
+		return;
+	}
+
+	serr = SKB_EXT_ERR(ackskb);
+	memset(serr, 0, sizeof(*serr));
+	serr->ee.ee_errno = ENOMSG;
+	serr->ee.ee_origin = SO_EE_ORIGIN_TXSTATUS;
+	serr->ee.ee_data = skb_shinfo(skb)->tskey;
+	serr->ee.ee_info = lp->reply_status;
+
+	/* finally erasing outgoing skb */
+	dev_kfree_skb(lp->outgoing.skb);
+	lp->outgoing.skb = NULL;
+
+	ackskb->dev = lp->dev;
+
+	ret = sock_queue_err_skb(sk, ackskb);
+	if (ret)
+		kfree_skb(ackskb);
+
+	local_irq_enable();
+};
+
 struct net_device *alloc_arcdev(const char *name)
 {
 	struct net_device *dev;
@@ -401,6 +448,7 @@ struct net_device *alloc_arcdev(const char *name)
 	if (dev) {
 		struct arcnet_local *lp = netdev_priv(dev);
 
+		lp->dev = dev;
 		spin_lock_init(&lp->lock);
 		init_timer(&lp->timer);
 		lp->timer.data = (unsigned long) dev;
@@ -436,6 +484,9 @@ int arcnet_open(struct net_device *dev)
 		arc_cont(D_PROTO, "\n");
 	}
 
+	tasklet_init(&lp->reply_tasklet, arcnet_reply_tasklet,
+		     (unsigned long)lp);
+
 	arc_printk(D_INIT, dev, "arcnet_open: resetting card.\n");
 
 	/* try to put the card in a defined state - if it fails the first
@@ -527,6 +578,8 @@ int arcnet_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
 
+	tasklet_kill(&lp->reply_tasklet);
+
 	/* flush TX and disable RX */
 	lp->hw.intmask(dev, 0);
 	lp->hw.command(dev, NOTXcmd);	/* stop transmit */
@@ -635,13 +688,13 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 		txbuf = -1;
 
 	if (txbuf != -1) {
+		lp->outgoing.skb = skb;
 		if (proto->prepare_tx(dev, pkt, skb->len, txbuf) &&
 		    !proto->ack_tx) {
 			/* done right away and we don't want to acknowledge
 			 *  the package later - forget about it now
 			 */
 			dev->stats.tx_bytes += skb->len;
-			dev_kfree_skb(skb);
 		} else {
 			/* do it the 'split' way */
 			lp->outgoing.proto = proto;
@@ -842,8 +895,16 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 		/* a transmit finished, and we're interested in it. */
 		if ((status & lp->intmask & TXFREEflag) || lp->timed_out) {
+			int ackstatus;
 			lp->intmask &= ~(TXFREEflag | EXCNAKflag);
 
+			if (status & TXACKflag)
+				ackstatus = 2;
+			else if (lp->excnak_pending)
+				ackstatus = 1;
+			else
+				ackstatus = 0;
+
 			arc_printk(D_DURING, dev, "TX IRQ (stat=%Xh)\n",
 				   status);
 
@@ -866,18 +927,11 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 				if (lp->outgoing.proto &&
 				    lp->outgoing.proto->ack_tx) {
-					int ackstatus;
-
-					if (status & TXACKflag)
-						ackstatus = 2;
-					else if (lp->excnak_pending)
-						ackstatus = 1;
-					else
-						ackstatus = 0;
-
 					lp->outgoing.proto
 						->ack_tx(dev, ackstatus);
 				}
+				lp->reply_status = ackstatus;
+				tasklet_hi_schedule(&lp->reply_tasklet);
 			}
 			if (lp->cur_tx != -1)
 				release_arcbuf(dev, lp->cur_tx);
-- 
2.11.0
