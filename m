From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 7/7] net,ipv4,ipv6: Correct assignment of skb->network_header to skb->tail
Date: Wed, 29 May 2013 14:27:48 +0900
Message-ID: <1369805268-6291-8-git-send-email-horms@verge.net.au>
References: <1369805268-6291-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46197 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab3E2F1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:27:11 -0400
In-Reply-To: <1369805268-6291-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects an regression introduced by "net: Use 16bits for *_headers
fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
that case skb->tail will be a pointer however skb->network_header is now
an offset.

This patch corrects the problem by adding a wrapper to return skb tail as
an offset regardless of the value of NET_SKBUFF_DATA_USES_OFFSET. It seems
that skb->tail that this offset may be more than 64k and some care has been
taken to treat such cases as an error.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/skbuff.h |    9 +++++++++
 net/core/netpoll.c     |    9 ++++++++-
 net/core/pktgen.c      |   16 ++++++++++++++--
 net/ipv4/ipmr.c        |    8 +++++++-
 4 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8f2b830..26ed287 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1391,6 +1391,11 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
 	skb_reset_tail_pointer(skb);
 	skb->tail += offset;
 }
+
+static inline __u64 skb_tail_offset(const struct sk_buff *skb)
+{
+	return skb->tail;
+}
 #else /* NET_SKBUFF_DATA_USES_OFFSET */
 static inline unsigned char *skb_tail_pointer(const struct sk_buff *skb)
 {
@@ -1407,6 +1412,10 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
 	skb->tail = skb->data + offset;
 }
 
+static inline __u64 skb_tail_offset(const struct sk_buff *skb)
+{
+	return skb->tail - skb->head;
+}
 #endif /* NET_SKBUFF_DATA_USES_OFFSET */
 
 /*
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 37deedd..d4da003 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -676,6 +676,8 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
+			__u64 tail_offset;
+
 			if (!ipv6_addr_equal(daddr, &np->local_ip.in6))
 				continue;
 
@@ -700,7 +702,12 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 			hdr->saddr = *saddr;
 			hdr->daddr = *daddr;
 
-			send_skb->transport_header = send_skb->tail;
+			tail_offset = skb_tail_offset(skb);
+			if (tail_offset > 0xffff) {
+				kfree_skb(send_skb);
+				continue;
+			}
+			skb_set_network_header(send_skb, tail_offset);
 			skb_put(send_skb, size);
 
 			icmp6h = (struct icmp6hdr *)skb_transport_header(skb);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 795498f..f2923ae 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2642,6 +2642,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
 	u16 queue_map;
+	__u64 tail_offset;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2708,7 +2709,12 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 		*vlan_encapsulated_proto = htons(ETH_P_IP);
 	}
 
-	skb->network_header = skb->tail;
+	tail_offset = skb_tail_offset(skb);
+	if (tail_offset > 0xffff) {
+		kfree_skb(skb);
+		return NULL;
+	}
+	skb_set_network_header(skb, tail_offset);
 	skb->transport_header = skb->network_header + sizeof(struct iphdr);
 	skb_put(skb, sizeof(struct iphdr) + sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
@@ -2775,6 +2781,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
 	u16 queue_map;
+	__u64 tail_offset;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2822,7 +2829,12 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 		*vlan_encapsulated_proto = htons(ETH_P_IPV6);
 	}
 
-	skb->network_header = skb->tail;
+	tail_offset = skb_tail_offset(skb);
+	if (tail_offset > 0xffff) {
+		kfree_skb(skb);
+		return NULL;
+	}
+	skb_set_network_header(skb, tail_offset);
 	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
 	skb_put(skb, sizeof(struct ipv6hdr) + sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index f975399..d5b8b4b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -945,6 +945,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	struct igmpmsg *msg;
 	struct sock *mroute_sk;
 	int ret;
+	__be64 tail_offset;
 
 #ifdef CONFIG_IP_PIMSM
 	if (assert == IGMPMSG_WHOLEPKT)
@@ -980,7 +981,12 @@ static int ipmr_cache_report(struct mr_table *mrt,
 
 	/* Copy the IP header */
 
-	skb->network_header = skb->tail;
+	tail_offset = skb_tail_offset(skb);
+	if (tail_offset > 0xffff) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+	skb_set_network_header(skb, tail_offset);
 	skb_put(skb, ihl);
 	skb_copy_to_linear_data(skb, pkt->data, ihl);
 	ip_hdr(skb)->protocol = 0;	/* Flag to the kernel this is a route add */
-- 
1.7.10.4
