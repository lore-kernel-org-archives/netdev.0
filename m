From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [RFC][PATCH][IPSEC][3/3] IPv4 over IPv6 IPsec tunnel
Date: Fri, 29 Dec 2006 14:48:08 +0900
Message-ID: <20061229144808.436b38db.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:46517 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754244AbWL2Fzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 00:55:54 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the patch to support IPv4 over IPv6 IPsec.

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index fb9f69c..011136a 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -72,13 +72,11 @@ __xfrm4_bundle_create(struct xfrm_policy
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
@@ -94,7 +92,6 @@ __xfrm4_bundle_create(struct xfrm_policy
 	for (i = 0; i < nx; i++) {
 		struct dst_entry *dst1 = dst_alloc(&xfrm4_dst_ops);
 		struct xfrm_dst *xdst;
-		int tunnel = 0;
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
@@ -116,19 +113,28 @@ __xfrm4_bundle_create(struct xfrm_policy
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
-		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			remote = xfrm[i]->id.daddr.a4;
-			local  = xfrm[i]->props.saddr.a4;
-			tunnel = 1;
-		}
+
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
-		if (tunnel) {
-			fl_tunnel.fl4_src = local;
-			fl_tunnel.fl4_dst = remote;
+		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
+			unsigned short encap_family = xfrm[i]->props.family;
+			switch(encap_family) {
+			case AF_INET:
+				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
+				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
+				break;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+			case AF_INET6:
+				ipv6_addr_copy(&fl_tunnel.fl6_dst, (struct in6_addr*)&xfrm[i]->id.daddr.a6);
+				ipv6_addr_copy(&fl_tunnel.fl6_src, (struct in6_addr*)&xfrm[i]->props.saddr.a6);
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
 		} else
@@ -145,6 +151,7 @@ __xfrm4_bundle_create(struct xfrm_policy
 	i = 0;
 	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
+		struct xfrm_state_afinfo *afinfo;
 		x->u.rt.fl = *fl;
 
 		dst_prev->xfrm = xfrm[i++];
@@ -162,8 +169,17 @@ __xfrm4_bundle_create(struct xfrm_policy
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output	= xfrm4_output;
-		if (rt->peer)
+		/* XXX: When IPv6 module can be unloaded, we should manage reference
+		 * to xfrm6_output in afinfo->output. Miyazawa
+		 * */
+		afinfo = xfrm_state_get_afinfo(dst_prev->xfrm->props.family);
+		if (!afinfo) {
+			dst = *dst_p;
+			goto error;
+		}
+		dst_prev->output = afinfo->output;
+		xfrm_state_put_afinfo(afinfo);
+		if (dst_prev->xfrm->props.family == AF_INET && rt->peer)
 			atomic_inc(&rt->peer->refcnt);
 		x->u.rt.peer = rt->peer;
 		/* Sheit... I remember I did this right. Apparently,
@@ -274,7 +290,7 @@ static void xfrm4_dst_destroy(struct dst
 
 	if (likely(xdst->u.rt.idev))
 		in_dev_put(xdst->u.rt.idev);
-	if (likely(xdst->u.rt.peer))
+	if (dst->xfrm->props.family == AF_INET && likely(xdst->u.rt.peer))
 		inet_putpeer(xdst->u.rt.peer);
 	xfrm_dst_destroy(xdst);
 }
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 5e7d8a7..55cddcb 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -25,6 +25,12 @@ static inline void ipip6_ecn_decapsulate
 		IP6_ECN_set_ce(inner_iph);
 }
 
+static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
+{
+	if (INET_ECN_is_ce(ipv6_get_dsfield(skb->nh.ipv6h)))
+			IP_ECN_set_ce(skb->h.ipiph);
+}
+
 /* Add encapsulation header.
  *
  * The top IP header will be constructed per RFC 2401.  The following fields
@@ -40,6 +46,7 @@ static inline void ipip6_ecn_decapsulate
 static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
+	struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
 	struct ipv6hdr *iph, *top_iph;
 	int dsfield;
 
@@ -52,16 +59,24 @@ static int xfrm6_tunnel_output(struct xf
 	skb->h.ipv6h = top_iph + 1;
 
 	top_iph->version = 6;
-	top_iph->priority = iph->priority;
-	top_iph->flow_lbl[0] = iph->flow_lbl[0];
-	top_iph->flow_lbl[1] = iph->flow_lbl[1];
-	top_iph->flow_lbl[2] = iph->flow_lbl[2];
+	if (xdst->route->ops->family == AF_INET6) {
+		top_iph->priority = iph->priority;
+		top_iph->flow_lbl[0] = iph->flow_lbl[0];
+		top_iph->flow_lbl[1] = iph->flow_lbl[1];
+		top_iph->flow_lbl[2] = iph->flow_lbl[2];
+		top_iph->nexthdr = IPPROTO_IPV6; 
+	} else {
+		top_iph->priority = 0;
+		top_iph->flow_lbl[0] = 0;
+		top_iph->flow_lbl[1] = 0;
+		top_iph->flow_lbl[2] = 0;
+		top_iph->nexthdr = IPPROTO_IPIP;
+	}
 	dsfield = ipv6_get_dsfield(top_iph);
 	dsfield = INET_ECN_encapsulate(dsfield, dsfield);
 	if (x->props.flags & XFRM_STATE_NOECN)
 		dsfield &= ~INET_ECN_MASK;
 	ipv6_change_dsfield(top_iph, 0, dsfield);
-	top_iph->nexthdr = IPPROTO_IPV6; 
 	top_iph->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
@@ -72,7 +87,8 @@ static int xfrm6_tunnel_input(struct xfr
 {
 	int err = -EINVAL;
 
-	if (skb->nh.raw[IP6CB(skb)->nhoff] != IPPROTO_IPV6)
+	if (skb->nh.raw[IP6CB(skb)->nhoff] != IPPROTO_IPV6
+	    && skb->nh.raw[IP6CB(skb)->nhoff] != IPPROTO_IPIP)
 		goto out;
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
@@ -81,10 +97,16 @@ static int xfrm6_tunnel_input(struct xfr
 	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 		goto out;
 
-	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-		ipv6_copy_dscp(skb->nh.ipv6h, skb->h.ipv6h);
-	if (!(x->props.flags & XFRM_STATE_NOECN))
-		ipip6_ecn_decapsulate(skb);
+	if (skb->nh.raw[IP6CB(skb)->nhoff] == IPPROTO_IPV6) {
+		if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+			ipv6_copy_dscp(skb->nh.ipv6h, skb->h.ipv6h);
+		if (!(x->props.flags & XFRM_STATE_NOECN))
+			ipip6_ecn_decapsulate(skb);
+	} else {
+		if (!(x->props.flags & XFRM_STATE_NOECN))
+			ip6ip_ecn_decapsulate(skb);
+		skb->protocol = htons(ETH_P_IP);
+	}
 	skb->mac.raw = memmove(skb->data - skb->mac_len,
 			       skb->mac.raw, skb->mac_len);
 	skb->nh.raw = skb->data;
