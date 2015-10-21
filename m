From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH net-next 1/6] arcnet: move dev_free_skb to its only user
Date: Wed, 21 Oct 2015 17:45:27 +0200
Message-ID: <1445442332-10625-2-git-send-email-m.grzeschik@pengutronix.de>
References: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47653 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbbJUPpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 11:45:45 -0400
In-Reply-To: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The call for dev_free_skb is done only once. This patch
moves its call to its only user and removes the obsolete
condition variable.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcnet.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index e41dd36..542e2b4 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -515,7 +515,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	struct ArcProto *proto;
 	int txbuf;
 	unsigned long flags;
-	int freeskb, retval;
+	int retval;
 
 	arc_printk(D_DURING, dev,
 		   "transmit requested (status=%Xh, txbufs=%d/%d, len=%d, protocol %x)\n",
@@ -554,15 +554,13 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 			 *  the package later - forget about it now
 			 */
 			dev->stats.tx_bytes += skb->len;
-			freeskb = 1;
+			dev_kfree_skb(skb);
 		} else {
 			/* do it the 'split' way */
 			lp->outgoing.proto = proto;
 			lp->outgoing.skb = skb;
 			lp->outgoing.pkt = pkt;
 
-			freeskb = 0;
-
 			if (proto->continue_tx &&
 			    proto->continue_tx(dev, txbuf)) {
 				arc_printk(D_NORMAL, dev,
@@ -574,7 +572,6 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 		lp->next_tx = txbuf;
 	} else {
 		retval = NETDEV_TX_BUSY;
-		freeskb = 0;
 	}
 
 	arc_printk(D_DEBUG, dev, "%s: %d: %s, status: %x\n",
@@ -589,9 +586,6 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 		   __FILE__, __LINE__, __func__, lp->hw.status(dev));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
-	if (freeskb)
-		dev_kfree_skb(skb);
-
 	return retval;		/* no need to try again */
 }
 EXPORT_SYMBOL(arcnet_send_packet);
-- 
2.6.1
