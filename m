From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] sch_sfq: add sanity check for the packet length
Date: Wed,  4 Aug 2010 16:55:48 +0800
Message-ID: <1280912148-30410-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:47510 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756811Ab0HDI4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 04:56:12 -0400
Received: by pxi14 with SMTP id 14so1907020pxi.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 01:56:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packet length should be checked before the packet data is dereferenced.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/sched/sch_sfq.c |   31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index c657628..018c528 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -122,7 +122,11 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 	{
-		const struct iphdr *iph = ip_hdr(skb);
+		const struct iphdr *iph;
+
+		if (!pskb_may_pull(skb, skb_network_offset(skb) + sizeof(*iph)))
+			goto err;
+		iph = ip_hdr(skb);
 		h = (__force u32)iph->daddr;
 		h2 = (__force u32)iph->saddr ^ iph->protocol;
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
@@ -131,25 +135,34 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 		     iph->protocol == IPPROTO_UDPLITE ||
 		     iph->protocol == IPPROTO_SCTP ||
 		     iph->protocol == IPPROTO_DCCP ||
-		     iph->protocol == IPPROTO_ESP))
+		     iph->protocol == IPPROTO_ESP) &&
+		     pskb_may_pull(skb, skb_network_offset(skb) +
+					iph->ihl * 4 + 4))
 			h2 ^= *(((u32*)iph) + iph->ihl);
 		break;
 	}
 	case htons(ETH_P_IPV6):
 	{
-		struct ipv6hdr *iph = ipv6_hdr(skb);
+		struct ipv6hdr *iph;
+
+		if (!pskb_may_pull(skb, skb_network_offset(skb) + sizeof(*iph)))
+			goto err;
+		iph = ipv6_hdr(skb);
 		h = (__force u32)iph->daddr.s6_addr32[3];
 		h2 = (__force u32)iph->saddr.s6_addr32[3] ^ iph->nexthdr;
-		if (iph->nexthdr == IPPROTO_TCP ||
-		    iph->nexthdr == IPPROTO_UDP ||
-		    iph->nexthdr == IPPROTO_UDPLITE ||
-		    iph->nexthdr == IPPROTO_SCTP ||
-		    iph->nexthdr == IPPROTO_DCCP ||
-		    iph->nexthdr == IPPROTO_ESP)
+		if ((iph->nexthdr == IPPROTO_TCP ||
+		     iph->nexthdr == IPPROTO_UDP ||
+		     iph->nexthdr == IPPROTO_UDPLITE ||
+		     iph->nexthdr == IPPROTO_SCTP ||
+		     iph->nexthdr == IPPROTO_DCCP ||
+		     iph->nexthdr == IPPROTO_ESP) &&
+		    pskb_may_pull(skb, skb_network_offset(skb) + sizeof(*iph) +
+				       4))
 			h2 ^= *(u32*)&iph[1];
 		break;
 	}
 	default:
+err:
 		h = (unsigned long)skb_dst(skb) ^ (__force u32)skb->protocol;
 		h2 = (unsigned long)skb->sk;
 	}
