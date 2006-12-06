From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC][5/7] inter address family ipsec tunnel
Date: Wed, 6 Dec 2006 20:35:40 +0900
Message-ID: <20061206203540.a03dae5c.kazunori@miyazawa.org>
References: <20061124143852.e899dbaf.kazunori@miyazawa.org>
	<20061130.164903.26534926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:42993 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760505AbWLFLjq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 06:39:46 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061130.164903.26534926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006 16:49:03 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> Date: Fri, 24 Nov 2006 14:38:52 +0900
> 
> > +static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
> > +{
> > +	if (INET_ECN_is_ce(ipv6_get_dsfield(skb->nh.ipv6h)))
> > +			IP_ECN_set_ce(skb->h.ipiph);
> > +}
> > +
> 
> Please fix this extra tab indentation :-)
> 
> Thank you.
> 

I fixed. As mentioned in another mail, I mixed up the changes
in my previous patch. This adds "IPv6 over IPv4 IPsec tunnel".
The fix of extra tab is included in another mail.


Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

---
 net/ipv4/xfrm4_mode_tunnel.c |   57 ++++++++++++++++++++++++++++++++++--------
 net/ipv6/xfrm6_policy.c      |   48 +++++++++++++++++++++++++----------
 2 files changed, 80 insertions(+), 25 deletions(-)

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
1.4.1

