From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 6/8] net: core: propagate SKB lists through
 packet_type lookup
Date: Tue, 19 Apr 2016 14:36:30 +0100
Message-ID: <5716345E.3050206@solarflare.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:42398 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752887AbcDSNgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:36:40 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This could maybe be made more efficient if we first split the list based on
 skb->protocol, and then did ptype lookup for each sublist.  Unfortunately,
 there are things liks sch_handle_ingress and the rx_handlers that can
 produce different results per packet.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/trace/events/net.h |   7 +++
 net/core/dev.c             | 146 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 113 insertions(+), 40 deletions(-)

diff --git a/include/trace/events/net.h b/include/trace/events/net.h
index 30f359c..7a17a31 100644
--- a/include/trace/events/net.h
+++ b/include/trace/events/net.h
@@ -130,6 +130,13 @@ DEFINE_EVENT(net_dev_template, netif_receive_skb,
 	TP_ARGS(skb)
 );
 
+DEFINE_EVENT(net_dev_template, netif_receive_skb_list,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
 DEFINE_EVENT(net_dev_template, netif_rx,
 
 	TP_PROTO(struct sk_buff *skb),
diff --git a/net/core/dev.c b/net/core/dev.c
index 0f914bf..db1d16a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4061,12 +4061,13 @@ static inline int nf_ingress(struct sk_buff *skb, struct packet_type **pt_prev,
 	return 0;
 }
 
-static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
+static int __netif_receive_skb_taps(struct sk_buff *skb, bool pfmemalloc,
+				    struct packet_type **pt_prev)
 {
-	struct packet_type *ptype, *pt_prev;
 	rx_handler_func_t *rx_handler;
 	struct net_device *orig_dev;
 	bool deliver_exact = false;
+	struct packet_type *ptype;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -4081,7 +4082,7 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 		skb_reset_transport_header(skb);
 	skb_reset_mac_len(skb);
 
-	pt_prev = NULL;
+	*pt_prev = NULL;
 
 another_round:
 	skb->skb_iif = skb->dev->ifindex;
@@ -4106,25 +4107,25 @@ another_round:
 		goto skip_taps;
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (pt_prev)
-			ret = deliver_skb(skb, pt_prev, orig_dev);
-		pt_prev = ptype;
+		if (*pt_prev)
+			ret = deliver_skb(skb, *pt_prev, orig_dev);
+		*pt_prev = ptype;
 	}
 
 	list_for_each_entry_rcu(ptype, &skb->dev->ptype_all, list) {
-		if (pt_prev)
-			ret = deliver_skb(skb, pt_prev, orig_dev);
-		pt_prev = ptype;
+		if (*pt_prev)
+			ret = deliver_skb(skb, *pt_prev, orig_dev);
+		*pt_prev = ptype;
 	}
 
 skip_taps:
 #ifdef CONFIG_NET_INGRESS
 	if (static_key_false(&ingress_needed)) {
-		skb = sch_handle_ingress(skb, &pt_prev, &ret, orig_dev);
+		skb = sch_handle_ingress(skb, pt_prev, &ret, orig_dev);
 		if (!skb)
 			goto out;
 
-		if (nf_ingress(skb, &pt_prev, &ret, orig_dev) < 0)
+		if (nf_ingress(skb, pt_prev, &ret, orig_dev) < 0)
 			goto out;
 	}
 #endif
@@ -4136,9 +4137,9 @@ ncls:
 		goto drop;
 
 	if (skb_vlan_tag_present(skb)) {
-		if (pt_prev) {
-			ret = deliver_skb(skb, pt_prev, orig_dev);
-			pt_prev = NULL;
+		if (*pt_prev) {
+			ret = deliver_skb(skb, *pt_prev, orig_dev);
+			*pt_prev = NULL;
 		}
 		if (vlan_do_receive(&skb))
 			goto another_round;
@@ -4148,9 +4149,9 @@ ncls:
 
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
-		if (pt_prev) {
-			ret = deliver_skb(skb, pt_prev, orig_dev);
-			pt_prev = NULL;
+		if (*pt_prev) {
+			ret = deliver_skb(skb, *pt_prev, orig_dev);
+			*pt_prev = NULL;
 		}
 		switch (rx_handler(&skb)) {
 		case RX_HANDLER_CONSUMED:
@@ -4181,47 +4182,112 @@ ncls:
 
 	/* deliver only exact match when indicated */
 	if (likely(!deliver_exact)) {
-		deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
+		deliver_ptype_list_skb(skb, pt_prev, orig_dev, type,
 				       &ptype_base[ntohs(type) &
 						   PTYPE_HASH_MASK]);
 	}
 
-	deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
+	deliver_ptype_list_skb(skb, pt_prev, orig_dev, type,
 			       &orig_dev->ptype_specific);
 
 	if (unlikely(skb->dev != orig_dev)) {
-		deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
+		deliver_ptype_list_skb(skb, pt_prev, orig_dev, type,
 				       &skb->dev->ptype_specific);
 	}
-
-	if (pt_prev) {
-		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
-			goto drop;
-		else
-			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
-	} else {
+	if (*pt_prev && unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		goto drop;
+	return ret;
 drop:
-		if (!deliver_exact)
-			atomic_long_inc(&skb->dev->rx_dropped);
-		else
-			atomic_long_inc(&skb->dev->rx_nohandler);
-		kfree_skb(skb);
-		/* Jamal, now you will not able to escape explaining
-		 * me how you were going to use this. :-)
-		 */
-		ret = NET_RX_DROP;
-	}
-
+	if (!deliver_exact)
+		atomic_long_inc(&skb->dev->rx_dropped);
+	else
+		atomic_long_inc(&skb->dev->rx_nohandler);
+	kfree_skb(skb);
+	/* Jamal, now you will not able to escape explaining
+	 * me how you were going to use this. :-)
+	 */
+	ret = NET_RX_DROP;
 out:
+	*pt_prev = NULL;
 	return ret;
 }
 
-static void __netif_receive_skb_list_core(struct sk_buff_head *list, bool pfmemalloc)
+static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
+{
+	struct net_device *orig_dev = skb->dev;
+	struct packet_type *pt_prev;
+	int ret;
+
+	ret = __netif_receive_skb_taps(skb, pfmemalloc, &pt_prev);
+	if (pt_prev)
+		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+	return ret;
+}
+
+static inline void __netif_receive_skb_list_ptype(struct sk_buff_head *list,
+						  struct packet_type *pt_prev,
+						  struct net_device *orig_dev)
 {
 	struct sk_buff *skb;
 
 	while ((skb = __skb_dequeue(list)) != NULL)
-		__netif_receive_skb_core(skb, pfmemalloc);
+		pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+}
+
+static void __netif_receive_skb_list_core(struct sk_buff_head *list, bool pfmemalloc)
+{
+	/* Fast-path assumptions:
+	 * - There is no RX handler.
+	 * - Only one packet_type matches.
+	 * If either of these fails, we will end up doing some per-packet
+	 * processing in-line, then handling the 'last ptype' for the whole
+	 * sublist.  This can't cause out-of-order delivery to any single ptype,
+	 * because the 'last ptype' must be constant across the sublist, and all
+	 * other ptypes are handled per-packet.  Unless, that is, a ptype can
+	 * be delivered to more than once for a single packet - but that seems
+	 * like it would be a bad idea anyway.
+	 * So it should be fine (at least, I think so), but you'll lose the
+	 * (putative) performance benefits of batching.
+	 */
+	/* Current (common) ptype of sublist */
+	struct packet_type *pt_curr = NULL;
+	/* In the normal (device RX) case, orig_dev should be the same for
+	 * every skb in the list.  But as I'm not certain of this, I check
+	 * it's constant and split the list if not.
+	 * So, od_curr is the current (common) orig_dev of sublist.
+	 */
+	struct net_device *od_curr = NULL;
+	struct sk_buff_head sublist;
+	struct sk_buff *skb;
+
+	__skb_queue_head_init(&sublist);
+
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		struct packet_type *pt_prev;
+		struct net_device *orig_dev = skb->dev;
+
+		__netif_receive_skb_taps(skb, pfmemalloc, &pt_prev);
+		if (pt_prev) {
+			if (skb_queue_empty(&sublist)) {
+				pt_curr = pt_prev;
+				od_curr = orig_dev;
+			} else if (!(pt_curr == pt_prev &&
+				     od_curr == orig_dev)) {
+				/* dispatch old sublist */
+				__netif_receive_skb_list_ptype(&sublist,
+							       pt_curr,
+							       od_curr);
+				/* start new sublist */
+				__skb_queue_head_init(&sublist);
+				pt_curr = pt_prev;
+				od_curr = orig_dev;
+			}
+			__skb_queue_tail(&sublist, skb);
+		}
+	}
+
+	/* dispatch final sublist */
+	__netif_receive_skb_list_ptype(&sublist, pt_curr, od_curr);
 }
 
 static int __netif_receive_skb(struct sk_buff *skb)
