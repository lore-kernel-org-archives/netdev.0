From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Thu, 19 Jul 2007 16:46:42 +0200
Message-ID: <469F7952.207@trash.net>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707171730.21655.joakim.koskela@hiit.fi> <469CE793.7020903@trash.net> <200707191708.58863.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36020 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965049AbXGSOrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 10:47:36 -0400
In-Reply-To: <200707191708.58863.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
>  static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
>  {

[... ipv4 handling, looks fine ...]

> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> +		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
> +		u8 protocol;
> +
> +		/* Inner = 6, Outer = 4 : changing the external IP hdr
> +		 * to the outer addresses
> +		 */
> +		hdrlen = x->props.header_len - IPV4_BEET_PHMAXLEN;


This still looks wrong. You removed the IPV4_BEET_PHMAXLEN addition
in esp6_init_state, which was correct since you don't do option
encapsulation for IPv6, but you still substract it here. What
also seems to be missing is accounting for the size difference
between IPv4 and IPv6 headers. In the inner IPv6, outer IPv4 case
its not too important, the other way around we need 20 bytes of
additional space plus room for option encapsulation. By not including
it in the header_len you're breaking MTU calculation and potentially
causing unnecessary reallocations.

> +		skb_push(skb, hdrlen);
> +		iphv6 = ipv6_hdr(skb);
> +
> +		skb_reset_network_header(skb);
> +		top_iphv6 = ipv6_hdr(skb);
> +
> +		protocol = iphv6->nexthdr;
> +		skb_pull(skb, delta);
> +		skb_reset_network_header(skb);
> +		top_iphv4 = ip_hdr(skb);
> +		skb_set_transport_header(skb, hdrlen);
> +		top_iphv4->ihl = (sizeof(struct iphdr) >> 2);
> +		top_iphv4->version = 4;
> +		top_iphv4->id = 0;
> +		top_iphv4->frag_off = htons(IP_DF);
> +		top_iphv4->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
> +		top_iphv4->saddr = x->props.saddr.a4;
> +		top_iphv4->daddr = x->id.daddr.a4;
> +		skb->transport_header += top_iphv4->ihl*4;
> +		top_iphv4->protocol = protocol;
> +
> +		skb->protocol = htons(ETH_P_IP);
> +#endif


The output function in the IPv6/IPv4 case is called from
xfrm6_output_one, which loops until after a tunnel mode
encapsulation is done and then returns to the outer loop
in xfrm6_output_finish2, which passes the packet through
the netfilter hooks and continues with the next transform.

There are multiple problems resulting from the inter-family
encapsulation. First of all, the inner loop continues after
beet mode encapsulation, skipping the netfilter hooks in
case there are more transforms. It should (as with decaps = 1
on input) at least call netfilter hooks after an inter-family
transform. If the beet transform is the last one, the IPv4
skb will be passed through the IPv6 netfilter hooks, which is
clearly wrong. To fix these problems some restructuring in
xfrm[46]_output.c seems to be necessary.

>  static int xfrm4_beet_input(struct xfrm_state *x, struct sk_buff *skb)
>  {
> [...]
> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> +	} else if (x->sel.family == AF_INET6) {
> +		/* Here, the inner family is 6, therefore I have to
> +		 * substitute the IPhdr by enlarging it.
> +		 */
> +		if (skb_tailroom(skb) < delta) {
> +			if (pskb_expand_head(skb, 0, delta, GFP_ATOMIC))


You want skb_headroom I suppose.

> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index 4ff8ed3..ff3d638 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -15,6 +15,7 @@
>  
>  static struct dst_ops xfrm4_dst_ops;
>  static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
> +static void xfrm4_update_pmtu(struct dst_entry *dst, u32 mtu);
>  
>  static int xfrm4_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
>  {
> @@ -81,10 +82,17 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
>  			}
>  		}
>  	};
> +	union {
> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> +		struct in6_addr *in6;
> +#endif
> +		struct in_addr *in;
> +	} remote, local;
>  	int i;
>  	int err;
>  	int header_len = 0;
>  	int trailer_len = 0;
> +	unsigned short encap_family = 0;
>  
>  	dst = dst_prev = NULL;
>  	dst_hold(&rt->u.dst);
> @@ -113,12 +121,26 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
>  
>  		dst1->next = dst_prev;
>  		dst_prev = dst1;
> -
> +		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
> +			encap_family = xfrm[i]->props.family;
> +			if (encap_family == AF_INET) {
> +				remote.in = (struct in_addr *)
> +					&xfrm[i]->id.daddr.a4;
> +				local.in  = (struct in_addr *)
> +					&xfrm[i]->props.saddr.a4;
> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> +			} else if (encap_family == AF_INET6) {
> +				remote.in6 = (struct in6_addr *)
> +					xfrm[i]->id.daddr.a6;
> +				local.in6 = (struct in6_addr *)
> +					xfrm[i]->props.saddr.a6;
> +#endif

You set the addresses above ..

> +			}
> +		}
>  		header_len += xfrm[i]->props.header_len;
>  		trailer_len += xfrm[i]->props.trailer_len;
>  
> -		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
> -			unsigned short encap_family = xfrm[i]->props.family;
> +		if (encap_family) {
>  			switch (encap_family) {
>  			case AF_INET:
>  				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;

and don't seem to use them for anything.

> @@ -198,6 +220,14 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
>  	}
>  
>  	xfrm_init_pmtu(dst);
> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> +	if (encap_family == AF_INET6) {
> +		/* The worst case */
> +		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
> +		u32 mtu = dst_mtu(dst);
> +		xfrm4_update_pmtu(dst, mtu - delta);


Any call to *_update_pmtu indicates that you didn't initialize the
states properly and therefore the MTU calculation gave a wrong result.
Please do proper initialization instead.

> diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> index 7107bb7..7ddd858 100644
> --- a/net/ipv6/esp6.c
> +++ b/net/ipv6/esp6.c
> @@ -246,7 +246,8 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
>  	rem = mtu & (align - 1);
>  	mtu &= ~(align - 1);
>  
> -	if (x->props.mode != XFRM_MODE_TUNNEL) {
> +	if (x->props.mode != XFRM_MODE_TUNNEL ||
> +	    x->props.mode != XFRM_MODE_BEET) {
>  		u32 padsize = ((blksize - 1) & 7) + 1;
>  		mtu -= blksize - padsize;
>  		mtu += min_t(u32, blksize - padsize, rem);


I'm possibly confused, but if you encapsulate IPv4 packets in IPv6
you need to account for option encapsulation overhead here.

> diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
> index 2e61d6d..c5c2f4f 100644
> --- a/net/ipv6/xfrm6_mode_beet.c
> +++ b/net/ipv6/xfrm6_mode_beet.c
> @@ -6,6 +6,7 @@
>   *                    Herbert Xu     <herbert@gondor.apana.org.au>
>   *                    Abhinav Pathak <abhinav.pathak@hiit.fi>
>   *                    Jeff Ahrenholz <ahrenholz@gmail.com>
> + *                    Joakim Koskela <jookos@gmail.com>
>   */
>  
>  #include <linux/init.h>
> @@ -17,6 +18,7 @@
>  #include <net/dst.h>
>  #include <net/inet_ecn.h>
>  #include <net/ipv6.h>
> +#include <net/ip.h>
>  #include <net/xfrm.h>
>  
>  /* Add encapsulation header.
> @@ -33,57 +35,218 @@
>   */
>  static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
>  {

Same problems wrt. netfilter hooks as in IPv4.

> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c

Same comments as for xfrm4_policy.c

> diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
> index baa461b..5c14227 100644
> --- a/net/ipv6/xfrm6_state.c
> +++ b/net/ipv6/xfrm6_state.c
> @@ -98,6 +98,17 @@ __xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
>  			src[i] = NULL;
>  		}
>  	}
> +	if (j == n)
> +		goto end;
> +
> +	/* Rule 5: select IPsec BEET */
> +	for (i = 0; i < n; i++) {
> +		if (src[i] &&
> +		    src[i]->props.mode == XFRM_MODE_BEET) {
> +			dst[j++] = src[i];
> +			src[i] = NULL;
> +		}
> +	}


Just out of interest, is there any particular logic behind the
ordering of the "rules"?

>  	if (likely(j == n))
>  		goto end;
>  
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 157bfbd..75fdb7d 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1299,7 +1299,8 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
>  		xfrm_address_t *local  = saddr;
>  		struct xfrm_tmpl *tmpl = &policy->xfrm_vec[i];
>  
> -		if (tmpl->mode == XFRM_MODE_TUNNEL) {
> +		if (tmpl->mode == XFRM_MODE_TUNNEL ||
> +		    tmpl->mode == XFRM_MODE_BEET) {


Is this a bugfix?

>  			remote = &tmpl->id.daddr;
>  			local = &tmpl->saddr;
>  			family = tmpl->encap_family;
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index dfacb9c..0a2ff8e 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -611,7 +611,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
>  			      selector.
>  			 */
>  			if (x->km.state == XFRM_STATE_VALID) {
> -				if (!xfrm_selector_match(&x->sel, fl, family) ||
> +				if (!xfrm_selector_match(&x->sel, fl, x->sel.family) ||
>  				    !security_xfrm_state_pol_flow_match(x, pol, fl))
>  					continue;
>  				if (!best ||
> @@ -623,7 +623,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
>  				acquire_in_progress = 1;
>  			} else if (x->km.state == XFRM_STATE_ERROR ||
>  				   x->km.state == XFRM_STATE_EXPIRED) {
> -				if (xfrm_selector_match(&x->sel, fl, family) &&
> +				if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
>  				    security_xfrm_state_pol_flow_match(x, pol, fl))
>  					error = -ESRCH;
>  			}


And these two? Also look like bugfixes ..
