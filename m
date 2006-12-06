From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC][4/7] inter address family ipsec tunnel
Date: Wed, 6 Dec 2006 20:35:37 +0900
Message-ID: <20061206203537.2e5ba9ec.kazunori@miyazawa.org>
References: <20061124143839.8559449b.kazunori@miyazawa.org>
	<20061130.164827.57154936.davem@davemloft.net>
	<456FB283.9090904@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:42993 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760504AbWLFLjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 06:39:45 -0500
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
In-Reply-To: <456FB283.9090904@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 01 Dec 2006 13:41:39 +0900
Kazunori MIYAZAWA <kazunori@miyazawa.org> wrote:

> David Miller wrote:
> > From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> > Date: Fri, 24 Nov 2006 14:38:39 +0900
> > 
> > What is going on here?
> > 
> >> +			/* Without this, the atomic inc below segfaults */
> >> +			if (encap_family == AF_INET6) {
> >> +				rt->peer = NULL;
> >> +				rt_bind_peer(rt,1);
> >> +			}
> >  ...
> >> -		dst_prev->output	= xfrm4_output;
> >> +		if (dst_prev->xfrm->props.family == AF_INET)
> >> +			dst_prev->output = xfrm4_output;
> >> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> >> +		else
> >> +			dst_prev->output = xfrm6_output;
> >> +#endif
> >>  		if (rt->peer)
> >>  			atomic_inc(&rt->peer->refcnt);
> > 
> > If it's non-NULL and you get a segfault for atomic_inc() that
> > means there is garbage here, and it seems that if you're
> > setting it to NULL explicitly then it's just a workaround
> > for whatever problem is causing it to be non-NULL to begin
> > with.
> > 
> > What is putting a non-valid pointer value there?  Is this an IPV6 or
> > IPSEC dst route by chance?  If so, that makes this change really
> > wrong, and we are corrupting the route by running rt_bind_peer() on
> > it.  rt_bind_peer() is only valid on ipv4 route entries.
> 
> Thank you for your good catch.
> I think atomic_inc must be done in case of props.family == AF_INET.
> And we probably should manage reference count of the device in case of
> AF_INET6.
> 
> Anyway I'll check and fix it.
> 
> Thank you.
> 

Hello David,

Sorry, I mixed up changes in the patches. I described that [4/7] will add
"IPv6 over IPv4 IPsec tunnel". However I send a patch for "IPv4 over IPv6"
as a reply because it includes the discussing item.
So this patch adds IPv4 over IPv6 IPsec tunnel. It's complicated.

I deleted subustituting NULL for rt->peer and moved atomic_inc stuff
under the "if" section.

BTW, I have a question about descrementing the reference count of rt->peer.
The reference cound in normal "dst" structure is decremented by calling
inet_putpeer from ipv4_dst_destroy. But xfrm4_dst_destroy does not call inet_putpeer.
Where do we decrement the count? Should xfrm4_dst_destroy do that?

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>


---
 net/ipv4/xfrm4_policy.c      |   68 ++++++++++++++++++++++++++++++++----------
 net/ipv6/xfrm6_mode_tunnel.c |   42 ++++++++++++++++++++------
 2 files changed, 83 insertions(+), 27 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index d4107bb..37b14e8 100644
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
@@ -116,19 +118,45 @@ __xfrm4_bundle_create(struct xfrm_policy
 
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
 		} else
@@ -162,10 +190,16 @@ __xfrm4_bundle_create(struct xfrm_policy
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output	= xfrm4_output;
-		if (rt->peer)
-			atomic_inc(&rt->peer->refcnt);
-		x->u.rt.peer = rt->peer;
+		if (dst_prev->xfrm->props.family == AF_INET) {
+			dst_prev->output = xfrm4_output;
+			if (rt->peer)
+				atomic_inc(&rt->peer->refcnt);
+			x->u.rt.peer = rt->peer;
+		}
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+		else
+			dst_prev->output = xfrm6_output;
+#endif
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
 		x->u.rt.rt_flags = rt0->rt_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 5e7d8a7..51eb59d 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -25,6 +25,12 @@ static inline void ipip6_ecn_decapsulate
 		IP6_ECN_set_ce(inner_iph);
 }
 
+static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
+{
+	if (INET_ECN_is_ce(ipv6_get_dsfield(skb->nh.ipv6h)))
+		IP_ECN_set_ce(skb->h.ipiph);
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
-- 
1.4.1





