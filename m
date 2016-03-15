From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/18] netfilter: Allow calling into nat helper without skb_dst.
Date: Tue, 15 Mar 2016 02:27:55 +0100
Message-ID: <1458005282-24665-12-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jarno@ovn.org>

NAT checksum recalculation code assumes existence of skb_dst, which
becomes a problem for a later patch in the series ("openvswitch:
Interface with NAT.").  Simplify this by removing the check on
skb_dst, as the checksum will be dealt with later in the stack.

Suggested-by: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 30 ++++++++----------------------
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 30 ++++++++----------------------
 2 files changed, 16 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index 61c7cc2..f8aad03 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -127,29 +127,15 @@ static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
 				    u8 proto, void *data, __sum16 *check,
 				    int datalen, int oldlen)
 {
-	const struct iphdr *iph = ip_hdr(skb);
-	struct rtable *rt = skb_rtable(skb);
-
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    (!skb->dev || skb->dev->features &
-		     (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
-			skb->ip_summed = CHECKSUM_PARTIAL;
-			skb->csum_start = skb_headroom(skb) +
-					  skb_network_offset(skb) +
-					  ip_hdrlen(skb);
-			skb->csum_offset = (void *)check - data;
-			*check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-						    datalen, proto, 0);
-		} else {
-			*check = 0;
-			*check = csum_tcpudp_magic(iph->saddr, iph->daddr,
-						   datalen, proto,
-						   csum_partial(data, datalen,
-								0));
-			if (proto == IPPROTO_UDP && !*check)
-				*check = CSUM_MANGLED_0;
-		}
+		const struct iphdr *iph = ip_hdr(skb);
+
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_headroom(skb) + skb_network_offset(skb) +
+			ip_hdrlen(skb);
+		skb->csum_offset = (void *)check - data;
+		*check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, datalen,
+					    proto, 0);
 	} else
 		inet_proto_csum_replace2(check, skb,
 					 htons(oldlen), htons(datalen), true);
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index 6ce3099..e0be97e 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -131,29 +131,15 @@ static void nf_nat_ipv6_csum_recalc(struct sk_buff *skb,
 				    u8 proto, void *data, __sum16 *check,
 				    int datalen, int oldlen)
 {
-	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
-	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
-
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(rt->rt6i_flags & RTF_LOCAL) &&
-		    (!skb->dev || skb->dev->features &
-		     (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))) {
-			skb->ip_summed = CHECKSUM_PARTIAL;
-			skb->csum_start = skb_headroom(skb) +
-					  skb_network_offset(skb) +
-					  (data - (void *)skb->data);
-			skb->csum_offset = (void *)check - data;
-			*check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
-						  datalen, proto, 0);
-		} else {
-			*check = 0;
-			*check = csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
-						 datalen, proto,
-						 csum_partial(data, datalen,
-							      0));
-			if (proto == IPPROTO_UDP && !*check)
-				*check = CSUM_MANGLED_0;
-		}
+		const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_headroom(skb) + skb_network_offset(skb) +
+			(data - (void *)skb->data);
+		skb->csum_offset = (void *)check - data;
+		*check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
+					  datalen, proto, 0);
 	} else
 		inet_proto_csum_replace2(check, skb,
 					 htons(oldlen), htons(datalen), true);
-- 
2.1.4

