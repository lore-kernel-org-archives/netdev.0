From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][5/7] inter address family ipsec tunnel
Date: Fri, 24 Nov 2006 14:38:52 +0900
Message-ID: <20061124143852.e899dbaf.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:18905 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S934386AbWKXFn4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:43:56 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds IPv4 over IPv6 IPsec tunnel.

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

---
 net/ipv6/xfrm6_mode_tunnel.c |   42 ++++++++++++++++++++++++++++---------
 net/ipv6/xfrm6_policy.c      |   48 ++++++++++++++++++++++++++++++------------
 2 files changed, 66 insertions(+), 24 deletions(-)

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
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8dffd4d..a7f28bf 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -131,16 +131,19 @@ __xfrm6_bundle_create(struct xfrm_policy
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
+	union {
+		struct in6_addr *in6;
+		struct in_addr *in;
+	} remote, local;
+	unsigned short encap_family = 0;
 	int i;
 	int err = 0;
 	int header_len = 0;
@@ -153,7 +156,6 @@ __xfrm6_bundle_create(struct xfrm_policy
 	for (i = 0; i < nx; i++) {
 		struct dst_entry *dst1 = dst_alloc(&xfrm6_dst_ops);
 		struct xfrm_dst *xdst;
-		int tunnel = 0;
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
@@ -178,18 +180,33 @@ __xfrm6_bundle_create(struct xfrm_policy
 		dst1->next = dst_prev;
 		dst_prev = dst1;
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			remote = __xfrm6_bundle_addr_remote(xfrm[i], remote);
-			local  = __xfrm6_bundle_addr_local(xfrm[i], local);
-			tunnel = 1;
+			encap_family = xfrm[i]->props.family;
+			if (encap_family == AF_INET6) {
+				remote.in6 = (struct in6_addr*)&xfrm[i]->id.daddr;
+				local.in6 = (struct in6_addr*)&xfrm[i]->props.saddr;
+			} else if(encap_family == AF_INET){
+				remote.in = (struct in_addr*)&xfrm[i]->id.daddr;
+				local.in = (struct in_addr*)&xfrm[i]->props.saddr;
+			}
 		}
 		__xfrm6_bundle_len_inc(&header_len, &nfheader_len, xfrm[i]);
 		trailer_len += xfrm[i]->props.trailer_len;
+		if (encap_family) {
+			switch(encap_family) {
+			case AF_INET:
+				fl_tunnel.fl4_dst = remote.in->s_addr;
+				fl_tunnel.fl4_src = local.in->s_addr;
+				break;
+			case AF_INET6:
+				ipv6_addr_copy(&fl_tunnel.fl6_dst, remote.in6);
+				ipv6_addr_copy(&fl_tunnel.fl6_src, local.in6);
+				break;
+			default:
+				BUG_ON(1);
+			}
 
-		if (tunnel) {
-			ipv6_addr_copy(&fl_tunnel.fl6_dst, remote);
-			ipv6_addr_copy(&fl_tunnel.fl6_src, local);
-			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
-					      &fl_tunnel, AF_INET6);
+ 			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
+					      &fl_tunnel, encap_family);
 			if (err)
 				goto error;
 		} else
@@ -224,7 +241,10 @@ __xfrm6_bundle_create(struct xfrm_policy
 		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output	= xfrm6_output;
+		if (dst_prev->xfrm->props.family == AF_INET6)
+			dst_prev->output	= xfrm6_output;
+		else
+			dst_prev->output	= xfrm4_output;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
 		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
-- 
