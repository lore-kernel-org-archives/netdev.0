From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 8/8] net_sched: sch_sfq: use proto_ports_offset() to support AH message
Date: Wed, 18 Aug 2010 13:07:35 +0800
Message-ID: <1282108055-3702-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:34539 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab0HRFHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 01:07:48 -0400
Received: by pzk26 with SMTP id 26so73702pzk.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 22:07:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/sched/sch_sfq.c |   33 ++++++++++++++++-----------------
 1 file changed, 16 insertions(+), 17 deletions(-)
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 201cbac..3cf478d 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -123,40 +123,39 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 	case htons(ETH_P_IP):
 	{
 		const struct iphdr *iph;
+		int poff;
 
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			goto err;
 		iph = ip_hdr(skb);
 		h = (__force u32)iph->daddr;
 		h2 = (__force u32)iph->saddr ^ iph->protocol;
-		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
-		    (iph->protocol == IPPROTO_TCP ||
-		     iph->protocol == IPPROTO_UDP ||
-		     iph->protocol == IPPROTO_UDPLITE ||
-		     iph->protocol == IPPROTO_SCTP ||
-		     iph->protocol == IPPROTO_DCCP ||
-		     iph->protocol == IPPROTO_ESP) &&
-		     pskb_network_may_pull(skb, iph->ihl * 4 + 4))
-			h2 ^= *(((u32*)iph) + iph->ihl);
+		if (iph->frag_off & htons(IP_MF|IP_OFFSET))
+			break;
+		poff = proto_ports_offset(iph->protocol);
+		if (poff >= 0 &&
+		    pskb_network_may_pull(skb, iph->ihl * 4 + 4 + poff)) {
+			iph = ip_hdr(skb);
+			h2 ^= *(u32*)((void *)iph + iph->ihl * 4 + poff);
+		}
 		break;
 	}
 	case htons(ETH_P_IPV6):
 	{
 		struct ipv6hdr *iph;
+		int poff;
 
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			goto err;
 		iph = ipv6_hdr(skb);
 		h = (__force u32)iph->daddr.s6_addr32[3];
 		h2 = (__force u32)iph->saddr.s6_addr32[3] ^ iph->nexthdr;
-		if ((iph->nexthdr == IPPROTO_TCP ||
-		     iph->nexthdr == IPPROTO_UDP ||
-		     iph->nexthdr == IPPROTO_UDPLITE ||
-		     iph->nexthdr == IPPROTO_SCTP ||
-		     iph->nexthdr == IPPROTO_DCCP ||
-		     iph->nexthdr == IPPROTO_ESP) &&
-		    pskb_network_may_pull(skb, sizeof(*iph) + 4))
-			h2 ^= *(u32*)&iph[1];
+		poff = proto_ports_offset(iph->nexthdr);
+		if (poff >= 0 &&
+		    pskb_network_may_pull(skb, sizeof(*iph) + 4 + poff)) {
+			iph = ipv6_hdr(skb);
+			h2 ^= *(u32*)((void *)iph + sizeof(*iph) + poff);
+		}
 		break;
 	}
 	default:
