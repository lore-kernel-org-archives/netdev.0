From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] cls_flow: add sanity check for the packet length
Date: Wed,  4 Aug 2010 15:08:07 +0800
Message-ID: <1280905687-8463-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:44395 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758393Ab0HDHId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 03:08:33 -0400
Received: by pvc7 with SMTP id 7so1890753pvc.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 00:08:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packet length should be checked before the packet data is dereferenced.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/skbuff.h |    6 ++--
 net/sched/cls_flow.c   |   69 +++++++++++++++++++++++++++++++++----------------
 2 files changed, 50 insertions(+), 25 deletions(-)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d20d9e7..3f0ac50 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1210,12 +1210,12 @@ static inline unsigned char *pskb_pull(struct sk_buff *skb, unsigned int len)
 	return unlikely(len > skb->len) ? NULL : __pskb_pull(skb, len);
 }
 
-static inline int pskb_may_pull(struct sk_buff *skb, unsigned int len)
+static inline bool pskb_may_pull(struct sk_buff *skb, unsigned int len)
 {
 	if (likely(len <= skb_headlen(skb)))
-		return 1;
+		return true;
 	if (unlikely(len > skb->len))
-		return 0;
+		return false;
 	return __pskb_pull_tail(skb, len - skb_headlen(skb)) != NULL;
 }
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index f73542d..d63a374 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -65,37 +65,48 @@ static inline u32 addr_fold(void *addr)
 	return (a & 0xFFFFFFFF) ^ (BITS_PER_LONG > 32 ? a >> 32 : 0);
 }
 
-static u32 flow_get_src(const struct sk_buff *skb)
+static inline bool flow_pskb_may_pull(struct sk_buff *skb, unsigned int len)
+{
+	return pskb_may_pull(skb, skb_network_offset(skb) + len);
+}
+
+static u32 flow_get_src(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return ntohl(ip_hdr(skb)->saddr);
+		return flow_pskb_may_pull(skb, sizeof(struct iphdr)) ?
+		       ntohl(ip_hdr(skb)->saddr) : 0;
 	case htons(ETH_P_IPV6):
-		return ntohl(ipv6_hdr(skb)->saddr.s6_addr32[3]);
+		return flow_pskb_may_pull(skb, sizeof(struct ipv6hdr)) ?
+		       ntohl(ipv6_hdr(skb)->saddr.s6_addr32[3]) : 0;
 	default:
 		return addr_fold(skb->sk);
 	}
 }
 
-static u32 flow_get_dst(const struct sk_buff *skb)
+static u32 flow_get_dst(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return ntohl(ip_hdr(skb)->daddr);
+		return flow_pskb_may_pull(skb, sizeof(struct iphdr)) ?
+		       ntohl(ip_hdr(skb)->daddr) : 0;
 	case htons(ETH_P_IPV6):
-		return ntohl(ipv6_hdr(skb)->daddr.s6_addr32[3]);
+		return flow_pskb_may_pull(skb, sizeof(struct ipv6hdr)) ?
+		       ntohl(ipv6_hdr(skb)->daddr.s6_addr32[3]) : 0;
 	default:
 		return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 	}
 }
 
-static u32 flow_get_proto(const struct sk_buff *skb)
+static u32 flow_get_proto(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return ip_hdr(skb)->protocol;
+		return flow_pskb_may_pull(skb, sizeof(struct iphdr)) ?
+		       ip_hdr(skb)->protocol : 0;
 	case htons(ETH_P_IPV6):
-		return ipv6_hdr(skb)->nexthdr;
+		return flow_pskb_may_pull(skb, sizeof(struct ipv6hdr)) ?
+		       ipv6_hdr(skb)->nexthdr : 0;
 	default:
 		return 0;
 	}
@@ -116,22 +127,29 @@ static int has_ports(u8 protocol)
 	}
 }
 
-static u32 flow_get_proto_src(const struct sk_buff *skb)
+static u32 flow_get_proto_src(struct sk_buff *skb)
 {
 	u32 res = 0;
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP): {
-		struct iphdr *iph = ip_hdr(skb);
+		struct iphdr *iph;
 
+		if (!flow_pskb_may_pull(skb, sizeof(*iph)))
+			break;
+		iph = ip_hdr(skb);
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
-		    has_ports(iph->protocol))
+		    has_ports(iph->protocol) &&
+		    flow_pskb_may_pull(skb, iph->ihl * 4 + 2))
 			res = ntohs(*(__be16 *)((void *)iph + iph->ihl * 4));
 		break;
 	}
 	case htons(ETH_P_IPV6): {
-		struct ipv6hdr *iph = ipv6_hdr(skb);
+		struct ipv6hdr *iph;
 
+		if (!flow_pskb_may_pull(skb, sizeof(*iph) + 2))
+			break;
+		iph = ipv6_hdr(skb);
 		if (has_ports(iph->nexthdr))
 			res = ntohs(*(__be16 *)&iph[1]);
 		break;
@@ -143,22 +161,29 @@ static u32 flow_get_proto_src(const struct sk_buff *skb)
 	return res;
 }
 
-static u32 flow_get_proto_dst(const struct sk_buff *skb)
+static u32 flow_get_proto_dst(struct sk_buff *skb)
 {
 	u32 res = 0;
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP): {
-		struct iphdr *iph = ip_hdr(skb);
+		struct iphdr *iph;
 
+		if (!flow_pskb_may_pull(skb, sizeof(*iph)))
+			break;
+		iph = ip_hdr(skb);
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
-		    has_ports(iph->protocol))
+		    has_ports(iph->protocol) &&
+		    flow_pskb_may_pull(skb, iph->ihl * 4 + 4))
 			res = ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 + 2));
 		break;
 	}
 	case htons(ETH_P_IPV6): {
-		struct ipv6hdr *iph = ipv6_hdr(skb);
+		struct ipv6hdr *iph;
 
+		if (!flow_pskb_may_pull(skb, sizeof(*iph) + 4))
+			break;
+		iph = ipv6_hdr(skb);
 		if (has_ports(iph->nexthdr))
 			res = ntohs(*(__be16 *)((void *)&iph[1] + 2));
 		break;
@@ -211,7 +236,7 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 })
 #endif
 
-static u32 flow_get_nfct_src(const struct sk_buff *skb)
+static u32 flow_get_nfct_src(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -223,7 +248,7 @@ fallback:
 	return flow_get_src(skb);
 }
 
-static u32 flow_get_nfct_dst(const struct sk_buff *skb)
+static u32 flow_get_nfct_dst(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -235,14 +260,14 @@ fallback:
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
@@ -281,7 +306,7 @@ static u32 flow_get_vlan_tag(const struct sk_buff *skb)
 	return tag & VLAN_VID_MASK;
 }
 
-static u32 flow_key_get(const struct sk_buff *skb, int key)
+static u32 flow_key_get(struct sk_buff *skb, int key)
 {
 	switch (key) {
 	case FLOW_KEY_SRC:
