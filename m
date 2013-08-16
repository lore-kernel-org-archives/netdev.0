From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: drop packets with multiple fragmentation headers
Date: Fri, 16 Aug 2013 13:30:07 +0200
Message-ID: <20130816113007.GD2112@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55690 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab3HPLaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 07:30:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not allowed for an ipv6 packet to contain multiple fragmentation
headers. So discard packets which were already reassembled by
fragmentation logic and send back a parameter problem icmp.

The updates for RFC 6980 will come in later, I have to do a bit more
research here.

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/ipv6.h  | 1 +
 net/ipv6/reassembly.c | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 77a4784..9ac5047 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -103,6 +103,7 @@ struct inet6_skb_parm {
 #define IP6SKB_FORWARDED	2
 #define IP6SKB_REROUTED		4
 #define IP6SKB_ROUTERALERT	8
+#define IP6SKB_FRAGMENTED      16
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 790d9f4..1aeb473 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -490,6 +490,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	ipv6_hdr(head)->payload_len = htons(payload_len);
 	ipv6_change_dsfield(ipv6_hdr(head), 0xff, ecn);
 	IP6CB(head)->nhoff = nhoff;
+	IP6CB(head)->flags |= IP6SKB_FRAGMENTED;
 
 	/* Yes, and fold redundant checksum back. 8) */
 	if (head->ip_summed == CHECKSUM_COMPLETE)
@@ -524,6 +525,9 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int evicted;
 
+	if (IP6CB(skb)->flags & IP6SKB_FRAGMENTED)
+		goto fail_hdr;
+
 	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
@@ -544,6 +548,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 				 ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMOKS);
 
 		IP6CB(skb)->nhoff = (u8 *)fhdr - skb_network_header(skb);
+		IP6CB(skb)->flags |= IP6SKB_FRAGMENTED;
 		return 1;
 	}
 
-- 
1.8.3.1
