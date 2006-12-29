From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [RFC][PATCH][IPSEC][2/3] IPv6 over IPv4 IPsec tunnel
Date: Fri, 29 Dec 2006 14:47:12 +0900
Message-ID: <20061229144712.e154b021.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:46517 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S964973AbWL2F42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 00:56:28 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the patch to support IPv6 over IPv4 IPsec

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>


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
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8dffd4d..a1ac537 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -131,13 +131,11 @@ __xfrm6_bundle_create(struct xfrm_policy
 	struct dst_entry *dst, *dst_prev;
 	struct rt6_info *rt0 = (struct rt6_info*)(*dst_p);
 	struct rt6_info *rt  = rt0;
-	struct in6_addr *remote = &fl->fl6_dst;
-	struct in6_addr *local  = &fl->fl6_src;
 	struct flowi fl_tunnel = {
 		.nl_u = {
 			.ip6_u = {
-				.saddr = *local,
-				.daddr = *remote
+				.saddr = fl->fl6_src,
+				.daddr = fl->fl6_dst,
 			}
 		}
 	};
@@ -153,7 +151,6 @@ __xfrm6_bundle_create(struct xfrm_policy
 	for (i = 0; i < nx; i++) {
 		struct dst_entry *dst1 = dst_alloc(&xfrm6_dst_ops);
 		struct xfrm_dst *xdst;
-		int tunnel = 0;
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
@@ -177,19 +174,27 @@ __xfrm6_bundle_create(struct xfrm_policy
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
-		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			remote = __xfrm6_bundle_addr_remote(xfrm[i], remote);
-			local  = __xfrm6_bundle_addr_local(xfrm[i], local);
-			tunnel = 1;
-		}
+
 		__xfrm6_bundle_len_inc(&header_len, &nfheader_len, xfrm[i]);
 		trailer_len += xfrm[i]->props.trailer_len;
 
-		if (tunnel) {
-			ipv6_addr_copy(&fl_tunnel.fl6_dst, remote);
-			ipv6_addr_copy(&fl_tunnel.fl6_src, local);
-			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
-					      &fl_tunnel, AF_INET6);
+		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
+			unsigned short encap_family = xfrm[i]->props.family;
+			switch(encap_family) {
+			case AF_INET:
+				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
+				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
+				break;
+			case AF_INET6:
+				ipv6_addr_copy(&fl_tunnel.fl6_dst, (struct in6_addr*)&xfrm[i]->id.daddr.a6);
+				ipv6_addr_copy(&fl_tunnel.fl6_src, (struct in6_addr*)&xfrm[i]->props.saddr.a6);
+				break;
+			default:
+				BUG_ON(1);
+			}
+
+ 			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
+					      &fl_tunnel, encap_family);
 			if (err)
 				goto error;
 		} else
@@ -208,6 +213,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 	i = 0;
 	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
+		struct xfrm_state_afinfo *afinfo;
 
 		dst_prev->xfrm = xfrm[i++];
 		dst_prev->dev = rt->u.dst.dev;
@@ -224,7 +230,17 @@ __xfrm6_bundle_create(struct xfrm_policy
 		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output	= xfrm6_output;
+		/* XXX: When IPv4 is implemented as module and can be unloaded,
+		 * we should manage reference to xfrm4_output in afinfo->output.
+		 * Miyazawa
+		 */
+		afinfo = xfrm_state_get_afinfo(dst_prev->xfrm->props.family);
+		if (!afinfo) {
+			dst = *dst_p;
+			goto error;
+		};
+		dst_prev->output = afinfo->output;
+		xfrm_state_put_afinfo(afinfo);
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
 		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
