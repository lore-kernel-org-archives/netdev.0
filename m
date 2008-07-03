From: David Miller <davem@davemloft.net>
Subject: [PATCH 29/39]: netdev: Rationalize SKB queue mapping.
Date: Thu, 03 Jul 2008 00:05:05 -0700 (PDT)
Message-ID: <20080703.000505.210650604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50686
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758560AbYGCHFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:05:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Always set it in dev_pick_tx().

There are two spots that need some adjustments.  Namely
pktgen (which has a roving queue mapping feature that is
not currently handled correctly) and wireless which will
need a queue mapping hook that dev_pick_tx() can invoke.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index cfda430..8ccf016 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1669,7 +1669,10 @@ out_kfree_skb:
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
-	return netdev_get_tx_queue(dev, 0);
+	u16 queue_index = 0;
+
+	skb_set_queue_mapping(skb, queue_index);
+	return netdev_get_tx_queue(dev, queue_index);
 }
 
 int dev_queue_xmit(struct sk_buff *skb)
@@ -1737,8 +1740,6 @@ gso:
 		spin_lock(&txq->lock);
 		q = txq->qdisc;
 		if (q->enqueue) {
-			/* reset queue_mapping to zero */
-			skb_set_queue_mapping(skb, 0);
 			rc = q->enqueue(skb, q);
 			qdisc_run(txq);
 			spin_unlock(&txq->lock);
-- 
1.5.6

