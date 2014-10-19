From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/4] net: gso: use feature flag argument in all protocol gso handlers
Date: Sun, 19 Oct 2014 22:42:18 +0200
Message-ID: <1413751340-19621-2-git-send-email-fw@strlen.de>
References: <1413751340-19621-1-git-send-email-fw@strlen.de>
Cc: edumazet@google.com, Florian Westphal <fw@strlen.de>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41331 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750993AbaJSUme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 16:42:34 -0400
In-Reply-To: <1413751340-19621-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_gso_segment() has a 'features' argument representing offload features
available to the output path.

A few handlers, e.g. GRE, instead re-fetch the features of skb->dev and use
those instead of the provided ones when handing encapsulation/tunnels.

Depending on dev->hw_enc_features of the output device skb_gso_segment() can
then return NULL even when the caller has disabled all GSO feature bits,
as segmentation of inner header thinks device will take care of segmentation.

This e.g. affects the tbf scheduler, which will silently drop GRE-encap GSO skbs
that did not fit the remaining token quota as the segmentation does not work
when device supports corresponding hw offload capabilities.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/af_inet.c     | 2 +-
 net/ipv4/gre_offload.c | 2 +-
 net/ipv4/udp_offload.c | 2 +-
 net/ipv6/ip6_offload.c | 2 +-
 net/mpls/mpls_gso.c    | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 92db7a6..8b7fe5b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1246,7 +1246,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 
 	encap = SKB_GSO_CB(skb)->encap_level > 0;
 	if (encap)
-		features = skb->dev->hw_enc_features & netif_skb_features(skb);
+		features &= skb->dev->hw_enc_features;
 	SKB_GSO_CB(skb)->encap_level += ihl;
 
 	skb_reset_transport_header(skb);
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index a777295..e084534 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -68,7 +68,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb->mac_len = skb_inner_network_offset(skb);
 
 	/* segment inner packet. */
-	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
+	enc_features = skb->dev->hw_enc_features & features;
 	segs = skb_mac_gso_segment(skb, enc_features);
 	if (IS_ERR_OR_NULL(segs)) {
 		skb_gso_error_unwind(skb, protocol, ghl, mac_offset, mac_len);
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 507310e..6480cea 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -58,7 +58,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		skb->encap_hdr_csum = 1;
 
 	/* segment inner packet. */
-	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
+	enc_features = skb->dev->hw_enc_features & features;
 	segs = gso_inner_segment(skb, enc_features);
 	if (IS_ERR_OR_NULL(segs)) {
 		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 9034f76..820cdb1 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -89,7 +89,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 
 	encap = SKB_GSO_CB(skb)->encap_level > 0;
 	if (encap)
-		features = skb->dev->hw_enc_features & netif_skb_features(skb);
+		features &= skb->dev->hw_enc_features;
 	SKB_GSO_CB(skb)->encap_level += sizeof(*ipv6h);
 
 	ipv6h = ipv6_hdr(skb);
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index e28ed2e..f0f5309 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -48,7 +48,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 	__skb_push(skb, skb->mac_len);
 
 	/* Segment inner packet. */
-	mpls_features = skb->dev->mpls_features & netif_skb_features(skb);
+	mpls_features = skb->dev->mpls_features & features;
 	segs = skb_mac_gso_segment(skb, mpls_features);
 
 
-- 
2.0.4
