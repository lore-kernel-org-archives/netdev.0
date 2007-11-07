From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 14/24] [INET]: Give outer DSCP directly to ip*_copy_dscp
Date: Wed, 07 Nov 2007 22:08:30 +0800
Message-ID: <E1Ipla2-0001Hj-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3565 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757567AbXKGOIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:48 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[INET]: Give outer DSCP directly to ip*_copy_dscp

This patch changes the prototype of ipv4_copy_dscp and ipv6_copy_dscp so
that they directly take the outer DSCP rather than the outer IP header.
This will help us to unify the code for inter-family tunnels.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/inet_ecn.h       |    8 ++++----
 net/ipv4/xfrm4_mode_tunnel.c |    2 +-
 net/ipv6/ip6_tunnel.c        |    2 +-
 net/ipv6/xfrm6_mode_tunnel.c |    3 ++-
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index de8399a..ba33db0 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -83,9 +83,9 @@ static inline void IP_ECN_clear(struct iphdr *iph)
 	iph->tos &= ~INET_ECN_MASK;
 }
 
-static inline void ipv4_copy_dscp(struct iphdr *outer, struct iphdr *inner)
+static inline void ipv4_copy_dscp(unsigned int dscp, struct iphdr *inner)
 {
-	u32 dscp = ipv4_get_dsfield(outer) & ~INET_ECN_MASK;
+	dscp &= ~INET_ECN_MASK;
 	ipv4_change_dsfield(inner, INET_ECN_MASK, dscp);
 }
 
@@ -104,9 +104,9 @@ static inline void IP6_ECN_clear(struct ipv6hdr *iph)
 	*(__be32*)iph &= ~htonl(INET_ECN_MASK << 20);
 }
 
-static inline void ipv6_copy_dscp(struct ipv6hdr *outer, struct ipv6hdr *inner)
+static inline void ipv6_copy_dscp(unsigned int dscp, struct ipv6hdr *inner)
 {
-	u32 dscp = ipv6_get_dsfield(outer) & ~INET_ECN_MASK;
+	dscp &= ~INET_ECN_MASK;
 	ipv6_change_dsfield(inner, INET_ECN_MASK, dscp);
 }
 
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index e4deecb..68a9f56 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -113,7 +113,7 @@ static int xfrm4_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	iph = ip_hdr(skb);
 	if (iph->protocol == IPPROTO_IPIP) {
 		if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-			ipv4_copy_dscp(iph, ipip_hdr(skb));
+			ipv4_copy_dscp(ipv4_get_dsfield(iph), ipip_hdr(skb));
 		if (!(x->props.flags & XFRM_STATE_NOECN))
 			ipip_ecn_decapsulate(skb);
 	}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 5383b33..a4051af 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -635,7 +635,7 @@ static void ip6ip6_dscp_ecn_decapsulate(struct ip6_tnl *t,
 					struct sk_buff *skb)
 {
 	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
-		ipv6_copy_dscp(ipv6h, ipv6_hdr(skb));
+		ipv6_copy_dscp(ipv6_get_dsfield(ipv6h), ipv6_hdr(skb));
 
 	if (INET_ECN_is_ce(ipv6_get_dsfield(ipv6h)))
 		IP6_ECN_set_ce(ipv6_hdr(skb));
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index fd84e22..9a43ea7 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -95,7 +95,8 @@ static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	nh = skb_network_header(skb);
 	if (nh[IP6CB(skb)->nhoff] == IPPROTO_IPV6) {
 		if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-			ipv6_copy_dscp(ipv6_hdr(skb), ipipv6_hdr(skb));
+			ipv6_copy_dscp(ipv6_get_dsfield(ipv6_hdr(skb)),
+				       ipipv6_hdr(skb));
 		if (!(x->props.flags & XFRM_STATE_NOECN))
 			ipip6_ecn_decapsulate(skb);
 	} else {
