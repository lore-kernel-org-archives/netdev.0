From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Mon, 16 Jul 2007 20:47:40 +0200
Message-ID: <469BBD4C.5040503@trash.net>
References: <200707161506.47915.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56572 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbXGPSrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 14:47:47 -0400
In-Reply-To: <200707161506.47915.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
> diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
> index fa1902d..7a39f4c 100644
> --- a/net/ipv4/xfrm4_input.c
> +++ b/net/ipv4/xfrm4_input.c
> @@ -108,7 +108,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
>  		if (x->mode->input(x, skb))
>  			goto drop;
>  
> -		if (x->props.mode == XFRM_MODE_TUNNEL) {
> +		if (x->props.mode == XFRM_MODE_TUNNEL ||
> +		    x->props.mode == XFRM_MODE_BEET) {
>  			decaps = 1;
>  			break;
>  		}


I was under the impression that one of the main points of BEET is that
it offers tunnel semantics but does only transport mode processing.
Its necessary for inter-family tunnels, but shouldn't this be avoided
for normal use?

> -		ph->padlen = 4 - (optlen & 4);
> -		ph->hdrlen = optlen / 8;
> -		ph->nexthdr = top_iph->protocol;
> -		if (ph->padlen)
> -			memset(ph + 1, IPOPT_NOP, ph->padlen);
> -

> +			ph = (struct ip_beet_phdr *)skb_transport_header(skb);
> +			ph->padlen = 4 - (optlen & 4);
> +			ph->hdrlen = (optlen + ph->padlen + sizeof(*ph)) / 8;


Reintroduces pseudo-header length bug.

> +			ph->nexthdr = iphv4->protocol;
> +			top_iphv4->protocol = IPPROTO_BEETPH;
> +			top_iphv4->ihl = sizeof(struct iphdr) / 4;


Where did padding go?

>  static int xfrm4_beet_input(struct xfrm_state *x, struct sk_buff *skb)
>  {

> -	if (unlikely(iph->protocol == IPPROTO_BEETPH)) {
> -		struct ip_beet_phdr *ph;
> -
> -		if (!pskb_may_pull(skb, sizeof(*ph)))
> -			goto out;
> -		ph = (struct ip_beet_phdr *)(ipip_hdr(skb) + 1);
> -
> -		phlen = sizeof(*ph) + ph->padlen;
> -		optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
> -		if (optlen < 0 || optlen & 3 || optlen > 250)
> -			goto out;

> +		if (unlikely(iph->protocol == IPPROTO_BEETPH)) {
> +			struct ip_beet_phdr *ph =
> +				(struct ip_beet_phdr*)(iph + 1);
> +
> +			if (!pskb_may_pull(skb, sizeof(*ph)))
> +				goto out;
> +
> +			phlen = ph->hdrlen * 8;
> +			optlen = phlen - ph->padlen - sizeof(*ph);

Reintroduces header length bug.

> diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
> index 44ef208..8db7910 100644
> --- a/net/ipv4/xfrm4_output.c
> +++ b/net/ipv4/xfrm4_output.c
> @@ -53,7 +53,8 @@ static int xfrm4_output_one(struct sk_buff *skb)
>  			goto error_nolock;
>  	}
>  
> -	if (x->props.mode == XFRM_MODE_TUNNEL) {
> +	if (x->props.mode == XFRM_MODE_TUNNEL ||
> +	    x->props.mode == XFRM_MODE_BEET) {
>  		err = xfrm4_tunnel_check_size(skb);


Its not a real tunnel and all packets are generated locally, why
does it need to send ICMPs?

>  		if (err)
> @@ -81,10 +82,15 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
>  			}
>  		}
>  	};
> +	union {
> +		struct in6_addr *in6;
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
> @@ -113,12 +119,24 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
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
> +			} else if (encap_family == AF_INET6) {
> +				remote.in6 = (struct in6_addr *)
> +					xfrm[i]->id.daddr.a6;
> +				local.in6 = (struct in6_addr *)
> +					xfrm[i]->props.saddr.a6;
> +			}


No ifdefs here?

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
> @@ -198,6 +216,12 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
>  	}
>  
>  	xfrm_init_pmtu(dst);
> +	if (encap_family == AF_INET6) {
> +		/* The worst case */
> +		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
> +		u32 mtu = dst_mtu(dst);
> +		xfrm4_update_pmtu(dst, mtu - delta);


This should be known at configuration time, why do you need to call
xfrm4_update_pmtu? Just set header_len correctly.

> diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
> index 5685103..57c2dba 100644
> --- a/net/ipv4/xfrm4_tunnel.c
> +++ b/net/ipv4/xfrm4_tunnel.c
> @@ -27,7 +27,8 @@ static int ipip_xfrm_rcv(struct xfrm_state *x, struct sk_buff *skb)
>  
>  static int ipip_init_state(struct xfrm_state *x)
>  {
> -	if (x->props.mode != XFRM_MODE_TUNNEL)
> +	if (x->props.mode != XFRM_MODE_TUNNEL ||
> +	    x->props.mode != XFRM_MODE_BEET)
>  		return -EINVAL;


Looks like a bug fix that should be seperated.


> @@ -365,6 +366,8 @@ static int esp6_init_state(struct xfrm_state *x)
>  	x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
>  	if (x->props.mode == XFRM_MODE_TUNNEL)
>  		x->props.header_len += sizeof(struct ipv6hdr);
> +	else if (x->props.mode == XFRM_MODE_BEET)
> +		x->props.header_len += IPV4_BEET_PHMAXLEN;


Seems wrong, you don't do option encapsulation for IPv6. All you do is
subtract this length again. What you probably should do is account for
the IPv4 header *if* it is an interfamiyl tunnel.

> diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
> index c858537..bfb3d7b 100644
> --- a/net/ipv6/xfrm6_input.c
> +++ b/net/ipv6/xfrm6_input.c
> @@ -73,7 +73,8 @@ int xfrm6_rcv_spi(struct sk_buff *skb, __be32 spi)
>  		if (x->mode->input(x, skb))
>  			goto drop;
>  
> -		if (x->props.mode == XFRM_MODE_TUNNEL) { /* XXX */
> +		if (x->props.mode == XFRM_MODE_TUNNEL ||
> +		    x->props.mode == XFRM_MODE_BEET) { /* XXX */
>  			decaps = 1;

Same as for IPv4.


I lost interest here, but the reintroduced bugs make me think that
some old version was simply rediffed without even checking the
output and the state initialization also seems to need a bit more work.

