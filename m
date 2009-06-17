From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/9] sky2: skb recycling
Date: Wed, 17 Jun 2009 10:30:38 -0700
Message-ID: <20090617173140.244124173@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45311 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758510AbZFQReE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:04 -0400
Content-Disposition: inline; filename=sky2-recycle.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements skb recycling. It reclaims transmitted skb's
for use in the receive ring.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-06-17 10:29:57.400008862 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:29:58.250810500 -0700
@@ -1176,6 +1176,7 @@ static void sky2_rx_clean(struct sky2_po
 			re->skb = NULL;
 		}
 	}
+	skb_queue_purge(&sky2->rx_recycle);
 }
 
 /* Basic MII support */
@@ -1252,6 +1253,12 @@ static void sky2_vlan_rx_register(struct
 }
 #endif
 
+/* Amount of required worst case padding in rx buffer */
+static inline unsigned sky2_rx_pad(const struct sky2_hw *hw)
+{
+	return (hw->flags & SKY2_HW_RAM_BUFFER) ? 8 : 2;
+}
+
 /*
  * Allocate an skb for receiving. If the MTU is large enough
  * make the skb non-linear with a fragment list of pages.
@@ -1261,6 +1268,13 @@ static struct sk_buff *sky2_rx_alloc(str
 	struct sk_buff *skb;
 	int i;
 
+	skb = __skb_dequeue(&sky2->rx_recycle);
+	if (!skb)
+		skb = netdev_alloc_skb(sky2->netdev, sky2->rx_data_size
+				       + sky2_rx_pad(sky2->hw));
+	if (!skb)
+		goto nomem;
+
 	if (sky2->hw->flags & SKY2_HW_RAM_BUFFER) {
 		unsigned char *start;
 		/*
@@ -1269,18 +1283,10 @@ static struct sk_buff *sky2_rx_alloc(str
 		 * The buffer returned from netdev_alloc_skb is
 		 * aligned except if slab debugging is enabled.
 		 */
-		skb = netdev_alloc_skb(sky2->netdev, sky2->rx_data_size + 8);
-		if (!skb)
-			goto nomem;
 		start = PTR_ALIGN(skb->data, 8);
 		skb_reserve(skb, start - skb->data);
-	} else {
-		skb = netdev_alloc_skb(sky2->netdev,
-				       sky2->rx_data_size + NET_IP_ALIGN);
-		if (!skb)
-			goto nomem;
+	} else
 		skb_reserve(skb, NET_IP_ALIGN);
-	}
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
 		struct page *page = alloc_page(GFP_ATOMIC);
@@ -1357,6 +1363,8 @@ static int sky2_rx_start(struct sky2_por
 
 	sky2->rx_data_size = size;
 
+	skb_queue_head_init(&sky2->rx_recycle);
+
 	/* Fill Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
 		re = sky2->rx_ring + i;
@@ -1764,14 +1772,22 @@ static void sky2_tx_complete(struct sky2
 		}
 
 		if (le->ctrl & EOP) {
+			struct sk_buff *skb = re->skb;
+
 			if (unlikely(netif_msg_tx_done(sky2)))
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
 
 			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += re->skb->len;
+			dev->stats.tx_bytes += skb->len;
+
+			if (skb_queue_len(&sky2->rx_recycle) < sky2->rx_pending
+			    && skb_recycle_check(skb, sky2->rx_data_size
+						 + sky2_rx_pad(sky2->hw)))
+				__skb_queue_head(&sky2->rx_recycle, skb);
+			else
+				dev_kfree_skb_any(skb);
 
-			dev_kfree_skb_any(re->skb);
 			sky2->tx_next = RING_NEXT(idx, TX_RING_SIZE);
 		}
 	}
--- a/drivers/net/sky2.h	2009-06-17 10:29:17.200758602 -0700
+++ b/drivers/net/sky2.h	2009-06-17 10:29:58.252811835 -0700
@@ -2028,6 +2028,7 @@ struct sky2_port {
 	u16		     rx_pending;
 	u16		     rx_data_size;
 	u16		     rx_nfrags;
+	struct sk_buff_head  rx_recycle;
 
 #ifdef SKY2_VLAN_TAG_USED
 	u16		     rx_tag;

-- 

