From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2 2/4] cls_flow: add sanity check for the packet length
Date: Wed,  4 Aug 2010 22:48:12 +0800
Message-ID: <1280933292-12176-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:60333 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab0HDOsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 10:48:39 -0400
Received: by pzk26 with SMTP id 26so2015825pzk.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 07:48:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packet length should be checked before the packet data is dereferenced.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: use pskb_network_may_pull(), and handle the error path gracefully.
    remove the return value change.
 net/sched/cls_flow.c |   96 +++++++++++++++++++++++++++++----------------------
 1 file changed, 56 insertions(+), 40 deletions(-)
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index f73542d..e17096e 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -65,37 +65,47 @@ static inline u32 addr_fold(void *addr)
 	return (a & 0xFFFFFFFF) ^ (BITS_PER_LONG > 32 ? a >> 32 : 0);
 }
 
-static u32 flow_get_src(const struct sk_buff *skb)
+static u32 flow_get_src(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return ntohl(ip_hdr(skb)->saddr);
+		if (pskb_network_may_pull(skb, sizeof(struct iphdr)))
+			return ntohl(ip_hdr(skb)->saddr);
+		break;
 	case htons(ETH_P_IPV6):
-		return ntohl(ipv6_hdr(skb)->saddr.s6_addr32[3]);
-	default:
-		return addr_fold(skb->sk);
+		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr)))
+			return ntohl(ipv6_hdr(skb)->saddr.s6_addr32[3]);
+		break;
 	}
+
+	return addr_fold(skb->sk);
 }
 
-static u32 flow_get_dst(const struct sk_buff *skb)
+static u32 flow_get_dst(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return ntohl(ip_hdr(skb)->daddr);
+		if (pskb_network_may_pull(skb, sizeof(struct iphdr)))
+			return ntohl(ip_hdr(skb)->daddr);
+		break;
 	case htons(ETH_P_IPV6):
-		return ntohl(ipv6_hdr(skb)->daddr.s6_addr32[3]);
-	default:
-		return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
+		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr)))
+			return ntohl(ipv6_hdr(skb)->daddr.s6_addr32[3]);
+		break;
 	}
+
+	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 }
 
-static u32 flow_get_proto(const struct sk_buff *skb)
+static u32 flow_get_proto(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return ip_hdr(skb)->protocol;
+		return pskb_network_may_pull(skb, sizeof(struct iphdr)) ?
+		       ip_hdr(skb)->protocol : 0;
 	case htons(ETH_P_IPV6):
-		return ipv6_hdr(skb)->nexthdr;
+		return pskb_network_may_pull(skb, sizeof(struct ipv6hdr)) ?
+		       ipv6_hdr(skb)->nexthdr : 0;
 	default:
 		return 0;
 	}
@@ -116,58 +126,64 @@ static int has_ports(u8 protocol)
 	}
 }
 
-static u32 flow_get_proto_src(const struct sk_buff *skb)
+static u32 flow_get_proto_src(struct sk_buff *skb)
 {
-	u32 res = 0;
-
 	switch (skb->protocol) {
 	case htons(ETH_P_IP): {
-		struct iphdr *iph = ip_hdr(skb);
+		struct iphdr *iph;
 
+		if (!pskb_network_may_pull(skb, sizeof(*iph)))
+			break;
+		iph = ip_hdr(skb);
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
-		    has_ports(iph->protocol))
-			res = ntohs(*(__be16 *)((void *)iph + iph->ihl * 4));
+		    has_ports(iph->protocol) &&
+		    pskb_network_may_pull(skb, iph->ihl * 4 + 2))
+			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4));
 		break;
 	}
 	case htons(ETH_P_IPV6): {
-		struct ipv6hdr *iph = ipv6_hdr(skb);
+		struct ipv6hdr *iph;
 
+		if (!pskb_network_may_pull(skb, sizeof(*iph) + 2))
+			break;
+		iph = ipv6_hdr(skb);
 		if (has_ports(iph->nexthdr))
-			res = ntohs(*(__be16 *)&iph[1]);
+			return ntohs(*(__be16 *)&iph[1]);
 		break;
 	}
-	default:
-		res = addr_fold(skb->sk);
 	}
 
-	return res;
+	return addr_fold(skb->sk);
 }
 
-static u32 flow_get_proto_dst(const struct sk_buff *skb)
+static u32 flow_get_proto_dst(struct sk_buff *skb)
 {
-	u32 res = 0;
-
 	switch (skb->protocol) {
 	case htons(ETH_P_IP): {
-		struct iphdr *iph = ip_hdr(skb);
+		struct iphdr *iph;
 
+		if (!pskb_network_may_pull(skb, sizeof(*iph)))
+			break;
+		iph = ip_hdr(skb);
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
-		    has_ports(iph->protocol))
-			res = ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 + 2));
+		    has_ports(iph->protocol) &&
+		    pskb_network_may_pull(skb, iph->ihl * 4 + 4))
+			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 + 2));
 		break;
 	}
 	case htons(ETH_P_IPV6): {
-		struct ipv6hdr *iph = ipv6_hdr(skb);
+		struct ipv6hdr *iph;
 
+		if (!pskb_network_may_pull(skb, sizeof(*iph) + 4))
+			break;
+		iph = ipv6_hdr(skb);
 		if (has_ports(iph->nexthdr))
-			res = ntohs(*(__be16 *)((void *)&iph[1] + 2));
+			return ntohs(*(__be16 *)((void *)&iph[1] + 2));
 		break;
 	}
-	default:
-		res = addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 	}
 
-	return res;
+	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 }
 
 static u32 flow_get_iif(const struct sk_buff *skb)
@@ -211,7 +227,7 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 })
 #endif
 
-static u32 flow_get_nfct_src(const struct sk_buff *skb)
+static u32 flow_get_nfct_src(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -223,7 +239,7 @@ fallback:
 	return flow_get_src(skb);
 }
 
-static u32 flow_get_nfct_dst(const struct sk_buff *skb)
+static u32 flow_get_nfct_dst(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -235,14 +251,14 @@ fallback:
 	return flow_get_dst(skb);
 }
 
-static u32 flow_get_nfct_proto_src(const struct sk_buff *skb)
+static u32 flow_get_nfct_proto_src(struct sk_buff *skb)
 {
 	return ntohs(CTTUPLE(skb, src.u.all));
 fallback:
 	return flow_get_proto_src(skb);
 }
 
-static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb)
+static u32 flow_get_nfct_proto_dst(struct sk_buff *skb)
 {
 	return ntohs(CTTUPLE(skb, dst.u.all));
 fallback:
@@ -281,7 +297,7 @@ static u32 flow_get_vlan_tag(const struct sk_buff *skb)
 	return tag & VLAN_VID_MASK;
 }
 
-static u32 flow_key_get(const struct sk_buff *skb, int key)
+static u32 flow_key_get(struct sk_buff *skb, int key)
 {
 	switch (key) {
 	case FLOW_KEY_SRC:
