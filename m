From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 5/8] net_sched: cls_flow: use proto_ports_offset() to support AH message
Date: Wed, 18 Aug 2010 13:05:08 +0800
Message-ID: <1282107908-3585-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42272 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab0HRFFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 01:05:21 -0400
Received: by pwi4 with SMTP id 4so146159pwi.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 22:05:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/sched/cls_flow.c |   67 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 38 insertions(+), 29 deletions(-)
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index e17096e..cd709f1 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -111,44 +111,41 @@ static u32 flow_get_proto(struct sk_buff *skb)
 	}
 }
 
-static int has_ports(u8 protocol)
-{
-	switch (protocol) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_UDPLITE:
-	case IPPROTO_SCTP:
-	case IPPROTO_DCCP:
-	case IPPROTO_ESP:
-		return 1;
-	default:
-		return 0;
-	}
-}
-
 static u32 flow_get_proto_src(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP): {
 		struct iphdr *iph;
+		int poff;
 
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			break;
 		iph = ip_hdr(skb);
-		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
-		    has_ports(iph->protocol) &&
-		    pskb_network_may_pull(skb, iph->ihl * 4 + 2))
-			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4));
+		if (iph->frag_off & htons(IP_MF|IP_OFFSET))
+			break;
+		poff = proto_ports_offset(iph->protocol);
+		if (poff >= 0 &&
+		    pskb_network_may_pull(skb, iph->ihl * 4 + 2 + poff)) {
+			iph = ip_hdr(skb);
+			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 +
+						 poff));
+		}
 		break;
 	}
 	case htons(ETH_P_IPV6): {
 		struct ipv6hdr *iph;
+		int poff;
 
-		if (!pskb_network_may_pull(skb, sizeof(*iph) + 2))
+		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			break;
 		iph = ipv6_hdr(skb);
-		if (has_ports(iph->nexthdr))
-			return ntohs(*(__be16 *)&iph[1]);
+		poff = proto_ports_offset(iph->nexthdr);
+		if (poff >= 0 &&
+		    pskb_network_may_pull(skb, sizeof(*iph) + poff + 2)) {
+			iph = ipv6_hdr(skb);
+			return ntohs(*(__be16 *)((void *)iph + sizeof(*iph) +
+						 poff));
+		}
 		break;
 	}
 	}
@@ -161,24 +158,36 @@ static u32 flow_get_proto_dst(struct sk_buff *skb)
 	switch (skb->protocol) {
 	case htons(ETH_P_IP): {
 		struct iphdr *iph;
+		int poff;
 
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			break;
 		iph = ip_hdr(skb);
-		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
-		    has_ports(iph->protocol) &&
-		    pskb_network_may_pull(skb, iph->ihl * 4 + 4))
-			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 + 2));
+		if (iph->frag_off & htons(IP_MF|IP_OFFSET))
+			break;
+		poff = proto_ports_offset(iph->protocol);
+		if (poff >= 0 &&
+		    pskb_network_may_pull(skb, iph->ihl * 4 + 4 + poff)) {
+			iph = ip_hdr(skb);
+			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 +
+						 2 + poff));
+		}
 		break;
 	}
 	case htons(ETH_P_IPV6): {
 		struct ipv6hdr *iph;
+		int poff;
 
-		if (!pskb_network_may_pull(skb, sizeof(*iph) + 4))
+		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			break;
 		iph = ipv6_hdr(skb);
-		if (has_ports(iph->nexthdr))
-			return ntohs(*(__be16 *)((void *)&iph[1] + 2));
+		poff = proto_ports_offset(iph->nexthdr);
+		if (poff >= 0 &&
+		    pskb_network_may_pull(skb, sizeof(*iph) + poff + 4)) {
+			iph = ipv6_hdr(skb);
+			return ntohs(*(__be16 *)((void *)iph + sizeof(*iph) +
+						 poff + 2));
+		}
 		break;
 	}
 	}
