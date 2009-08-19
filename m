From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/7] sky2: no recycling
Date: Tue, 18 Aug 2009 18:17:10 -0700
Message-ID: <20090819011738.993523293@vyatta.com>
References: <20090819011704.685802801@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:50672 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbZHSBWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 21:22:45 -0400
Content-Disposition: inline; filename=sky2-no-recycle.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recycling turns out to be a bad idea!  For most use cases, the
packet can not be reused: TCP packets are cloned. Even for the ideal
case of forwarding, it hurts performance because of CPU ping/pong.
On a multi-core system forwarding of 64 byte packets is worse
much worse: recycling = 24% forwarded vs no recycling = 42% forwarded

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-08-18 17:50:31.591887510 -0700
+++ b/drivers/net/sky2.c	2009-08-18 17:53:04.506927814 -0700
@@ -1177,7 +1177,6 @@ static void sky2_rx_clean(struct sky2_po
 			re->skb = NULL;
 		}
 	}
-	skb_queue_purge(&sky2->rx_recycle);
 }
 
 /* Basic MII support */
@@ -1269,10 +1268,8 @@ static struct sk_buff *sky2_rx_alloc(str
 	struct sk_buff *skb;
 	int i;
 
-	skb = __skb_dequeue(&sky2->rx_recycle);
-	if (!skb)
-		skb = netdev_alloc_skb(sky2->netdev, sky2->rx_data_size
-				       + sky2_rx_pad(sky2->hw));
+	skb = netdev_alloc_skb(sky2->netdev,
+			       sky2->rx_data_size + sky2_rx_pad(sky2->hw));
 	if (!skb)
 		goto nomem;
 
@@ -1364,8 +1361,6 @@ static int sky2_rx_start(struct sky2_por
 
 	sky2->rx_data_size = size;
 
-	skb_queue_head_init(&sky2->rx_recycle);
-
 	/* Fill Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
 		re = sky2->rx_ring + i;
@@ -1776,12 +1771,7 @@ static void sky2_tx_complete(struct sky2
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += skb->len;
 
-			if (skb_queue_len(&sky2->rx_recycle) < sky2->rx_pending
-			    && skb_recycle_check(skb, sky2->rx_data_size
-						 + sky2_rx_pad(sky2->hw)))
-				__skb_queue_head(&sky2->rx_recycle, skb);
-			else
-				dev_kfree_skb_any(skb);
+			dev_kfree_skb_any(skb);
 
 			sky2->tx_next = RING_NEXT(idx, sky2->tx_ring_size);
 		}
--- a/drivers/net/sky2.h	2009-08-18 17:50:34.706665948 -0700
+++ b/drivers/net/sky2.h	2009-08-18 17:51:02.596652122 -0700
@@ -2032,7 +2032,6 @@ struct sky2_port {
 	u16		     rx_pending;
 	u16		     rx_data_size;
 	u16		     rx_nfrags;
-	struct sk_buff_head  rx_recycle;
 
 #ifdef SKY2_VLAN_TAG_USED
 	u16		     rx_tag;

-- 

