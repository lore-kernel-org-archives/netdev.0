From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][4/7] inter address family ipsec tunnel
Date: Fri, 24 Nov 2006 14:38:39 +0900
Message-ID: <20061124143839.8559449b.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:63390 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S934378AbWKXFn4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:43:56 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds IPv6 over IPv4 IPsec tunnel.

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

---
 net/ipv4/xfrm4_mode_tunnel.c |   57 +++++++++++++++++++++++++++++-------
 net/ipv4/xfrm4_policy.c      |   66 +++++++++++++++++++++++++++++++++---------
 2 files changed, 98 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index e23c21d..e54c549 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -23,6 +23,12 @@ static inline void ipip_ecn_decapsulate(
 		IP_ECN_set_ce(inner_iph);
 }
 
+static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
+{
+	if (INET_ECN_is_ce(iph->tos))
+		IP6_ECN_set_ce(skb->nh.ipv6h);
+}
+
 /* Add encapsulation header.
  *
  * The top IP header will be constructed per RFC 2401.  The following fields
@@ -36,6 +42,7 @@ static inline void ipip_ecn_decapsulate(
 static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
+	struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
 	struct iphdr *iph, *top_iph;
 	int flags;
 
@@ -48,15 +55,27 @@ static int xfrm4_tunnel_output(struct xf
 	top_iph->ihl = 5;
 	top_iph->version = 4;
 
+	flags = x->props.flags;
+
 	/* DS disclosed */
-	top_iph->tos = INET_ECN_encapsulate(iph->tos, iph->tos);
+	if (xdst->route->ops->family == AF_INET) {
+		top_iph->protocol = IPPROTO_IPIP;
+		top_iph->tos = INET_ECN_encapsulate(iph->tos, iph->tos);
+		top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
+			0 : (iph->frag_off & htons(IP_DF));
+	}
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	else {
+		struct ipv6hdr *ipv6h = (struct ipv6hdr*)iph;
+		top_iph->protocol = IPPROTO_IPV6;
+		top_iph->tos = INET_ECN_encapsulate(iph->tos, ipv6_get_dsfield(ipv6h));
+		top_iph->frag_off = 0;
+	}
+#endif
 
-	flags = x->props.flags;
 	if (flags & XFRM_STATE_NOECN)
 		IP_ECN_clear(top_iph);
 
-	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
-		0 : (iph->frag_off & htons(IP_DF));
 	if (!top_iph->frag_off)
 		__ip_select_ident(top_iph, dst->child, 0);
 
@@ -64,7 +83,6 @@ static int xfrm4_tunnel_output(struct xf
 
 	top_iph->saddr = x->props.saddr.a4;
 	top_iph->daddr = x->id.daddr.a4;
-	top_iph->protocol = IPPROTO_IPIP;
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	return 0;
@@ -75,8 +93,16 @@ static int xfrm4_tunnel_input(struct xfr
 	struct iphdr *iph = skb->nh.iph;
 	int err = -EINVAL;
 
-	if (iph->protocol != IPPROTO_IPIP)
-		goto out;
+	switch(iph->protocol){
+		case IPPROTO_IPIP:
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+		case IPPROTO_IPV6:
+			break;
+#endif
+		default:
+			goto out;
+	}
+
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto out;
 
@@ -84,10 +110,19 @@ static int xfrm4_tunnel_input(struct xfr
 	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 		goto out;
 
-	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-		ipv4_copy_dscp(iph, skb->h.ipiph);
-	if (!(x->props.flags & XFRM_STATE_NOECN))
-		ipip_ecn_decapsulate(skb);
+	if (iph->protocol == IPPROTO_IPIP) {
+		if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+			ipv4_copy_dscp(iph, skb->h.ipiph);
+		if (!(x->props.flags & XFRM_STATE_NOECN))
+			ipip_ecn_decapsulate(skb);
+	}
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	else {
+		if (!(x->props.flags & XFRM_STATE_NOECN))
+			ipip6_ecn_decapsulate(iph, skb);
+		skb->protocol = htons(ETH_P_IPV6);
+	}
+#endif
 	skb->mac.raw = memmove(skb->data - skb->mac_len,
 			       skb->mac.raw, skb->mac_len);
 	skb->nh.raw = skb->data;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index d4107bb..992f484 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -72,17 +72,20 @@ __xfrm4_bundle_create(struct xfrm_policy
 	struct dst_entry *dst, *dst_prev;
 	struct rtable *rt0 = (struct rtable*)(*dst_p);
 	struct rtable *rt = rt0;
-	__be32 remote = fl->fl4_dst;
-	__be32 local  = fl->fl4_src;
 	struct flowi fl_tunnel = {
 		.nl_u = {
 			.ip4_u = {
-				.saddr = local,
-				.daddr = remote,
+				.saddr = fl->fl4_src,
+				.daddr = fl->fl4_dst,
 				.tos = fl->fl4_tos
 			}
 		}
 	};
+	union {
+		struct in6_addr *in6;
+		struct in_addr *in;
+	} remote, local;
+	unsigned short encap_family = 0;
 	int i;
 	int err;
 	int header_len = 0;
@@ -94,7 +97,6 @@ __xfrm4_bundle_create(struct xfrm_policy
 	for (i = 0; i < nx; i++) {
 		struct dst_entry *dst1 = dst_alloc(&xfrm4_dst_ops);
 		struct xfrm_dst *xdst;
-		int tunnel = 0;
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
@@ -116,21 +118,52 @@ __xfrm4_bundle_create(struct xfrm_policy
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
-		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			remote = xfrm[i]->id.daddr.a4;
-			local  = xfrm[i]->props.saddr.a4;
-			tunnel = 1;
+
+		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
+			encap_family = xfrm[i]->props.family;
+
+			switch(encap_family) {
+			case AF_INET:
+				remote.in = (struct in_addr*)&xfrm[i]->id.daddr;
+				local.in = (struct in_addr*)&xfrm[i]->props.saddr;
+				break;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+			case AF_INET6:
+				remote.in6 = (struct in6_addr*)&xfrm[i]->id.daddr;
+				local.in6 = (struct in6_addr*)&xfrm[i]->props.saddr;
+				break;
+#endif
+			default:
+				BUG_ON(1);
+			}
 		}
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
-		if (tunnel) {
-			fl_tunnel.fl4_src = local;
-			fl_tunnel.fl4_dst = remote;
+		if (encap_family) {
+			switch(encap_family) {
+			case AF_INET:
+				fl_tunnel.fl4_dst = remote.in->s_addr;
+				fl_tunnel.fl4_src = local.in->s_addr;
+				break;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+			case AF_INET6:
+				ipv6_addr_copy(&fl_tunnel.fl6_dst, remote.in6);
+				ipv6_addr_copy(&fl_tunnel.fl6_src, local.in6);
+				break;
+#endif
+			default:
+				BUG_ON(1);
+			}
 			err = xfrm_dst_lookup((struct xfrm_dst **)&rt,
-					      &fl_tunnel, AF_INET);
+					      &fl_tunnel, encap_family);
 			if (err)
 				goto error;
+			/* Without this, the atomic inc below segfaults */
+			if (encap_family == AF_INET6) {
+				rt->peer = NULL;
+				rt_bind_peer(rt,1);
+			}
 		} else
 			dst_hold(&rt->u.dst);
 	}
@@ -162,7 +195,12 @@ __xfrm4_bundle_create(struct xfrm_policy
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output	= xfrm4_output;
+		if (dst_prev->xfrm->props.family == AF_INET)
+			dst_prev->output = xfrm4_output;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+		else
+			dst_prev->output = xfrm6_output;
+#endif
 		if (rt->peer)
 			atomic_inc(&rt->peer->refcnt);
 		x->u.rt.peer = rt->peer;
-- 
