From: David Miller <davem@davemloft.net>
Subject: [PATCH]: neigh: Remove by-hand SKB queue handling.
Date: Tue, 23 Sep 2008 01:11:52 -0700 (PDT)
Message-ID: <20080923.011152.193685128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751357AbYIWIME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 04:12:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 92D11C8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 01:11:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


neigh: Remove by-hand SKB queue handling.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/neighbour.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 9d92e41..1dc728b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -927,8 +927,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 			if (skb_queue_len(&neigh->arp_queue) >=
 			    neigh->parms->queue_len) {
 				struct sk_buff *buff;
-				buff = neigh->arp_queue.next;
-				__skb_unlink(buff, &neigh->arp_queue);
+				buff = __skb_dequeue(&neigh->arp_queue);
 				kfree_skb(buff);
 				NEIGH_CACHE_STAT_INC(neigh->tbl, unres_discards);
 			}
@@ -1259,24 +1258,20 @@ static void neigh_proxy_process(unsigned long arg)
 	struct neigh_table *tbl = (struct neigh_table *)arg;
 	long sched_next = 0;
 	unsigned long now = jiffies;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *n;
 
 	spin_lock(&tbl->proxy_queue.lock);
 
-	skb = tbl->proxy_queue.next;
-
-	while (skb != (struct sk_buff *)&tbl->proxy_queue) {
-		struct sk_buff *back = skb;
-		long tdif = NEIGH_CB(back)->sched_next - now;
+	skb_queue_walk_safe(&tbl->proxy_queue, skb, n) {
+		long tdif = NEIGH_CB(skb)->sched_next - now;
 
-		skb = skb->next;
 		if (tdif <= 0) {
-			struct net_device *dev = back->dev;
-			__skb_unlink(back, &tbl->proxy_queue);
+			struct net_device *dev = skb->dev;
+			__skb_unlink(skb, &tbl->proxy_queue);
 			if (tbl->proxy_redo && netif_running(dev))
-				tbl->proxy_redo(back);
+				tbl->proxy_redo(skb);
 			else
-				kfree_skb(back);
+				kfree_skb(skb);
 
 			dev_put(dev);
 		} else if (!sched_next || tdif < sched_next)
-- 
1.5.6.5

