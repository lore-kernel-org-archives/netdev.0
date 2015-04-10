From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/7] net: refactor __netif_receive_skb_core
Date: Fri, 10 Apr 2015 14:15:36 +0200
Message-ID: <1428668142-4006-2-git-send-email-pablo@netfilter.org>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40092 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754894AbbDJMLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 08:11:47 -0400
In-Reply-To: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits __netif_receive_skb_core() in smaller functions to improve
maintainability.

The function __netif_receive_skb_core() has been split in two:

* __netif_receive_skb_ingress(), to perform all actions up to
  ingress filtering.

* __netif_receive_skb_finish(), if the ingress filter accepts this
  packet, pass it to the corresponding packet_type function handler for further
processing.

This patch also adds __NET_RX_ANOTHER_ROUND that is used when the packet is
stripped off from the vlan header or in case the rx_handler needs it.

This also prepares the introduction of the netfilter ingress hook.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/core/dev.c |  156 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 89 insertions(+), 67 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b2775f0..0e19e4f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3638,72 +3638,17 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 	}
 }
 
-static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
+#define __NET_RX_ANOTHER_ROUND	2
+
+static int __netif_receive_skb_finish(struct sk_buff *skb, bool pfmemalloc,
+				      struct packet_type *pt_prev,
+				      struct net_device *orig_dev)
 {
-	struct packet_type *ptype, *pt_prev;
 	rx_handler_func_t *rx_handler;
-	struct net_device *orig_dev;
 	bool deliver_exact = false;
-	int ret = NET_RX_DROP;
+	int ret;
 	__be16 type;
 
-	net_timestamp_check(!netdev_tstamp_prequeue, skb);
-
-	trace_netif_receive_skb(skb);
-
-	orig_dev = skb->dev;
-
-	skb_reset_network_header(skb);
-	if (!skb_transport_header_was_set(skb))
-		skb_reset_transport_header(skb);
-	skb_reset_mac_len(skb);
-
-	pt_prev = NULL;
-
-	rcu_read_lock();
-
-another_round:
-	skb->skb_iif = skb->dev->ifindex;
-
-	__this_cpu_inc(softnet_data.processed);
-
-	if (skb->protocol == cpu_to_be16(ETH_P_8021Q) ||
-	    skb->protocol == cpu_to_be16(ETH_P_8021AD)) {
-		skb = skb_vlan_untag(skb);
-		if (unlikely(!skb))
-			goto unlock;
-	}
-
-#ifdef CONFIG_NET_CLS_ACT
-	if (skb->tc_verd & TC_NCLS) {
-		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
-		goto ncls;
-	}
-#endif
-
-	if (pfmemalloc)
-		goto skip_taps;
-
-	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (pt_prev)
-			ret = deliver_skb(skb, pt_prev, orig_dev);
-		pt_prev = ptype;
-	}
-
-	list_for_each_entry_rcu(ptype, &skb->dev->ptype_all, list) {
-		if (pt_prev)
-			ret = deliver_skb(skb, pt_prev, orig_dev);
-		pt_prev = ptype;
-	}
-
-skip_taps:
-#ifdef CONFIG_NET_CLS_ACT
-	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
-	if (!skb)
-		goto unlock;
-ncls:
-#endif
-
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
@@ -3713,9 +3658,9 @@ ncls:
 			pt_prev = NULL;
 		}
 		if (vlan_do_receive(&skb))
-			goto another_round;
+			return __NET_RX_ANOTHER_ROUND;
 		else if (unlikely(!skb))
-			goto unlock;
+			return NET_RX_SUCCESS;
 	}
 
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
@@ -3726,10 +3671,9 @@ ncls:
 		}
 		switch (rx_handler(&skb)) {
 		case RX_HANDLER_CONSUMED:
-			ret = NET_RX_SUCCESS;
-			goto unlock;
+			return NET_RX_SUCCESS;
 		case RX_HANDLER_ANOTHER:
-			goto another_round;
+			return __NET_RX_ANOTHER_ROUND;
 		case RX_HANDLER_EXACT:
 			deliver_exact = true;
 		case RX_HANDLER_PASS:
@@ -3780,9 +3724,87 @@ drop:
 		 */
 		ret = NET_RX_DROP;
 	}
+	return ret;
+}
 
-unlock:
+static int __netif_receive_skb_ingress(struct sk_buff *skb, bool pfmemalloc,
+				       struct net_device *orig_dev)
+{
+	struct packet_type *ptype, *pt_prev = NULL;
+	int ret;
+
+	skb->skb_iif = skb->dev->ifindex;
+
+	__this_cpu_inc(softnet_data.processed);
+
+	if (skb->protocol == cpu_to_be16(ETH_P_8021Q) ||
+	    skb->protocol == cpu_to_be16(ETH_P_8021AD)) {
+		skb = skb_vlan_untag(skb);
+		if (unlikely(!skb))
+			return NET_RX_DROP;
+	}
+
+#ifdef CONFIG_NET_CLS_ACT
+	if (skb->tc_verd & TC_NCLS) {
+		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
+		return NET_RX_SUCCESS;
+	}
+#endif
+
+	if (pfmemalloc)
+		goto skip_taps;
+
+	list_for_each_entry_rcu(ptype, &ptype_all, list) {
+		if (pt_prev)
+			ret = deliver_skb(skb, pt_prev, orig_dev);
+		pt_prev = ptype;
+	}
+
+	list_for_each_entry_rcu(ptype, &skb->dev->ptype_all, list) {
+		if (pt_prev)
+			ret = deliver_skb(skb, pt_prev, orig_dev);
+		pt_prev = ptype;
+	}
+
+skip_taps:
+#ifdef CONFIG_NET_CLS_ACT
+	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
+	if (!skb)
+		return NET_RX_DROP;
+#endif
+
+	return __netif_receive_skb_finish(skb, pfmemalloc, pt_prev, orig_dev);
+}
+
+static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
+{
+	struct net_device *orig_dev;
+	int ret;
+
+	net_timestamp_check(!netdev_tstamp_prequeue, skb);
+
+	trace_netif_receive_skb(skb);
+
+	orig_dev = skb->dev;
+
+	skb_reset_network_header(skb);
+	if (!skb_transport_header_was_set(skb))
+		skb_reset_transport_header(skb);
+	skb_reset_mac_len(skb);
+
+	rcu_read_lock();
+
+another_round:
+	ret = __netif_receive_skb_ingress(skb, pfmemalloc, orig_dev);
+	switch (ret) {
+	case NET_RX_SUCCESS:
+	case NET_RX_DROP:
+		break;
+	case __NET_RX_ANOTHER_ROUND:
+		goto another_round;
+	}
 	rcu_read_unlock();
+
 	return ret;
 }
 
-- 
1.7.10.4
