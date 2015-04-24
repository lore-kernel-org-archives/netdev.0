From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 16/21] ARCNET: capmode: move dev_free_skb to its only user
Date: Fri, 24 Apr 2015 19:20:50 +0200
Message-ID: <1429896055-31680-17-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The call for dev_free_skb is done only once. This patch
moves its call to its only user and removes the obsolete
condition variable.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcnet.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 4990b0d..5eec14d 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -541,7 +541,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	struct ArcProto *proto;
 	int txbuf;
 	unsigned long flags;
-	int freeskb, retval;
+	int retval;
 
 	BUGMSG(D_DURING,
 	       "transmit requested (status=%Xh, txbufs=%d/%d, len=%d, protocol %x)\n",
@@ -578,15 +578,13 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 			/* done right away and we don't want to acknowledge
 			   the package later - forget about it now */
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
 			  BUGMSG(D_NORMAL,
@@ -598,7 +596,6 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 		lp->next_tx = txbuf;
 	} else {
 		retval = NETDEV_TX_BUSY;
-		freeskb = 0;
 	}
 
 	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",
@@ -613,9 +610,6 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	       __FILE__, __LINE__, __func__, lp->hw.status(dev));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
-	if (freeskb) {
-		dev_kfree_skb(skb);
-	}
 	return retval;		/* no need to try again */
 }
 
-- 
2.1.4
