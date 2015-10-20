From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: [RFC PATCH 3/5] netfilter: Allow calling into nat helper without skb_dst.
Date: Tue, 20 Oct 2015 15:20:27 -0700
Message-ID: <1445379629-112880-3-git-send-email-jrajahalme@nicira.com>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
Cc: dev@openvswitch.org, jrajahalme@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36837 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339AbbJTWU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 18:20:57 -0400
Received: by pacfv9 with SMTP id fv9so34638732pac.3
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 15:20:57 -0700 (PDT)
In-Reply-To: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAT checksum recalculation code assumed existence of skb_dst, which
becomes a problem for a later patch in the series.  Simplify this by
removing the checks, as the checksum will be dealt with later in the
stack.

Suggested-by: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 29 ++++++++---------------------
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 29 ++++++++---------------------
 2 files changed, 16 insertions(+), 42 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index 5075b7e..f8aad03 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -127,28 +127,15 @@ static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
 				    u8 proto, void *data, __sum16 *check,
 				    int datalen, int oldlen)
 {
-	const struct iphdr *iph = ip_hdr(skb);
-	struct rtable *rt = skb_rtable(skb);
-
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    (!skb->dev || skb->dev->features & NETIF_F_V4_CSUM)) {
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
index 238e70c..e0be97e 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -131,28 +131,15 @@ static void nf_nat_ipv6_csum_recalc(struct sk_buff *skb,
 				    u8 proto, void *data, __sum16 *check,
 				    int datalen, int oldlen)
 {
-	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
-	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
-
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(rt->rt6i_flags & RTF_LOCAL) &&
-		    (!skb->dev || skb->dev->features & NETIF_F_V6_CSUM)) {
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
