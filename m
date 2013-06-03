From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] pktgen: Fix position of ip and udp header
Date: Mon,  3 Jun 2013 23:18:52 +0200
Message-ID: <10b1d385b151b94946b77183c34e34a07945983c.1370293920.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:40140 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757714Ab3FCVS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 17:18:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_set_network_header() expects an offset based on the data pointer
whereas skb_tail_offset() also includes the headroom. This resulted
in the ip header being written in a wrong location.

Use return values of skb_put() directly and rely on skb->len to
set mac, network, and transport header.

Cc: Simon Horman <horms@verge.net.au>
Assisted-by: Daniel Borkmann <dborkmann@redhat.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/core/pktgen.c | 35 ++++++++++++-----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d2ede89..0f1fc29b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2642,7 +2642,6 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
 	u16 queue_map;
-	unsigned long tail_offset;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2709,20 +2708,15 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 		*vlan_encapsulated_proto = htons(ETH_P_IP);
 	}
 
-	tail_offset = skb_tail_offset(skb);
-	if (tail_offset > 0xffff) {
-		kfree_skb(skb);
-		return NULL;
-	}
-	skb_set_network_header(skb, tail_offset);
-	skb->transport_header = skb->network_header + sizeof(struct iphdr);
-	skb_put(skb, sizeof(struct iphdr) + sizeof(struct udphdr));
+	skb_set_mac_header(skb, 0);
+	skb_set_network_header(skb, skb->len);
+	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
+
+	skb_set_transport_header(skb, skb->len);
+	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
 	skb->priority = pkt_dev->skb_priority;
 
-	iph = ip_hdr(skb);
-	udph = udp_hdr(skb);
-
 	memcpy(eth, pkt_dev->hh, 12);
 	*(__be16 *) & eth[12] = protocol;
 
@@ -2781,7 +2775,6 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
 	u16 queue_map;
-	unsigned long tail_offset;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2829,18 +2822,14 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 		*vlan_encapsulated_proto = htons(ETH_P_IPV6);
 	}
 
-	tail_offset = skb_tail_offset(skb);
-	if (tail_offset > 0xffff) {
-		kfree_skb(skb);
-		return NULL;
-	}
-	skb_set_network_header(skb, tail_offset);
-	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
-	skb_put(skb, sizeof(struct ipv6hdr) + sizeof(struct udphdr));
+	skb_set_mac_header(skb, 0);
+	skb_set_network_header(skb, skb->len);
+	iph = (struct ipv6hdr *) skb_put(skb, sizeof(struct ipv6hdr));
+
+	skb_set_transport_header(skb, skb->len);
+	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
 	skb->priority = pkt_dev->skb_priority;
-	iph = ipv6_hdr(skb);
-	udph = udp_hdr(skb);
 
 	memcpy(eth, pkt_dev->hh, 12);
 	*(__be16 *) &eth[12] = protocol;
-- 
1.7.11.7
