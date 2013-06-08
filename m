From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] pktgen: ipv6: numa: consolidate skb allocation to pktgen_alloc_skb
Date: Sat,  8 Jun 2013 14:18:16 +0200
Message-ID: <1370693896-9294-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371Ab3FHMSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jun 2013 08:18:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently allow for numa-node aware skb allocation only within the
fill_packet_ipv4() path, but not in fill_packet_ipv6(). Consolidate that
code to a common allocation helper to enable numa-node aware skb
allocation for ipv6, and use it in both paths. This also makes both
functions a bit more readable.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/core/pktgen.c | 52 +++++++++++++++++++++++++++-------------------------
 1 file changed, 27 insertions(+), 25 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 888ef11..31c631e 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2627,6 +2627,29 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 	pgh->tv_usec = htonl(timestamp.tv_usec);
 }
 
+static struct sk_buff *pktgen_alloc_skb(struct net_device *dev,
+					struct pktgen_dev *pkt_dev,
+					unsigned int extralen)
+{
+	struct sk_buff *skb = NULL;
+	unsigned int size = pkt_dev->cur_pkt_size + 64 + extralen +
+			    pkt_dev->pkt_overhead;
+
+	if (pkt_dev->flags & F_NODE) {
+		int node = pkt_dev->node >= 0 ? pkt_dev->node : numa_node_id();
+
+		skb = __alloc_skb(NET_SKB_PAD + size, GFP_NOWAIT, 0, node);
+		if (likely(skb)) {
+			skb_reserve(skb, NET_SKB_PAD);
+			skb->dev = dev;
+		}
+	} else {
+		 skb = __netdev_alloc_skb(dev, size, GFP_NOWAIT);
+	}
+
+	return skb;
+}
+
 static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 					struct pktgen_dev *pkt_dev)
 {
@@ -2657,32 +2680,13 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
 
-	if (pkt_dev->flags & F_NODE) {
-		int node;
-
-		if (pkt_dev->node >= 0)
-			node = pkt_dev->node;
-		else
-			node =  numa_node_id();
-
-		skb = __alloc_skb(NET_SKB_PAD + pkt_dev->cur_pkt_size + 64
-				  + datalen + pkt_dev->pkt_overhead, GFP_NOWAIT, 0, node);
-		if (likely(skb)) {
-			skb_reserve(skb, NET_SKB_PAD);
-			skb->dev = odev;
-		}
-	}
-	else
-	  skb = __netdev_alloc_skb(odev,
-				   pkt_dev->cur_pkt_size + 64
-				   + datalen + pkt_dev->pkt_overhead, GFP_NOWAIT);
-
+	skb = pktgen_alloc_skb(odev, pkt_dev, datalen);
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
 	}
-	prefetchw(skb->data);
 
+	prefetchw(skb->data);
 	skb_reserve(skb, datalen);
 
 	/*  Reserve for ethernet and IP header  */
@@ -2786,15 +2790,13 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	mod_cur_headers(pkt_dev);
 	queue_map = pkt_dev->cur_queue_map;
 
-	skb = __netdev_alloc_skb(odev,
-				 pkt_dev->cur_pkt_size + 64
-				 + 16 + pkt_dev->pkt_overhead, GFP_NOWAIT);
+	skb = pktgen_alloc_skb(odev, pkt_dev, 16);
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
 	}
-	prefetchw(skb->data);
 
+	prefetchw(skb->data);
 	skb_reserve(skb, 16);
 
 	/*  Reserve for ethernet and IP header  */
-- 
1.7.11.7
