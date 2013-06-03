From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v2] pktgen: Fix position of ip and udp header
Date: Mon,  3 Jun 2013 23:49:23 +0200
Message-ID: <08fe3153790311fbd98b1570a3e8134ddaac58a3.1370296008.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	Daniel Borkmann <dborkmann@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:40591 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab3FCVt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 17:49:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_set_network_header() expects an offset based on the data pointer
whereas skb_tail_offset() also includes the headroom. This resulted
in the ip header being written in a wrong location.

Use return values of skb_put() directly and rely on skb->len to
set mac, network, and transport header.

Cc: Simon Horman <horms@verge.net.au>
Cc: Daniel Borkmann <dborkmann@redhat.com>
Assisted-by: Daniel Borkmann <dborkmann@redhat.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
V2: removed now obsolete line setting mac_header, thanks Daniel!

 net/core/pktgen.c | 39 ++++++++++++---------------------------
 1 file changed, 12 insertions(+), 27 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d2ede89..303412d 100644
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
 
@@ -2752,8 +2746,6 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	iph->check = 0;
 	iph->check = ip_fast_csum((void *)iph, iph->ihl);
 	skb->protocol = protocol;
-	skb->mac_header = (skb->network_header - ETH_HLEN -
-			   pkt_dev->pkt_overhead);
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
 	pktgen_finalize_skb(pkt_dev, skb, datalen);
@@ -2781,7 +2773,6 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
 	u16 queue_map;
-	unsigned long tail_offset;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2829,18 +2820,14 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
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
@@ -2875,8 +2862,6 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	iph->daddr = pkt_dev->cur_in6_daddr;
 	iph->saddr = pkt_dev->cur_in6_saddr;
 
-	skb->mac_header = (skb->network_header - ETH_HLEN -
-			   pkt_dev->pkt_overhead);
 	skb->protocol = protocol;
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
-- 
1.7.11.7
