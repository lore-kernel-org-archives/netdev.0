From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 01/10] ipv6: Remove external dependency on
 rt6i_dst and rt6i_src
Date: Thu, 21 May 2015 19:37:45 -0400 (EDT)
Message-ID: <20150521.193745.1977924066490073347.davem@davemloft.net>
References: <1432162349-788789-1-git-send-email-kafai@fb.com>
	<1432162349-788789-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, ja@ssi.bg,
	steffen.klassert@secunet.com, Kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756094AbbEUXhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 19:37:50 -0400
In-Reply-To: <1432162349-788789-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 20 May 2015 15:52:20 -0700

> This patch removes the assumptions that the returned rt is always
> a RTF_CACHE entry with the rt6i_dst and rt6i_src containing the
> destination and source address.  The dst and src can be recovered from
> the calling site.
> 
> We may consider to rename (rt6i_dst, rt6i_src) to
> (rt6i_key_dst, rt6i_key_src) later.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I'm fine with this except for the fragmentation handling:

> @@ -549,6 +549,7 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
>  				inet6_sk(skb->sk) : NULL;
>  	struct ipv6hdr *tmp_hdr;
>  	struct frag_hdr *fh;
> +	struct frag_hdr tmp_fh;
>  	unsigned int mtu, hlen, left, len;
>  	int hroom, troom;
>  	__be32 frag_id = 0;
> @@ -584,6 +585,10 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
>  	}
>  	mtu -= hlen + sizeof(struct frag_hdr);
>  
> +	ipv6_select_ident(net, &tmp_fh, &ipv6_hdr(skb)->daddr,
> +			  &ipv6_hdr(skb)->saddr);
> +	frag_id = tmp_fh.identification;
> +
>  	if (skb_has_frag_list(skb)) {
>  		int first_len = skb_pagelen(skb);
>  		struct sk_buff *frag2;

Let's see if we can avoid putting a tmp frag_hdr on the stack.

> @@ -632,11 +637,10 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
>  		skb_reset_network_header(skb);
>  		memcpy(skb_network_header(skb), tmp_hdr, hlen);
>  
> -		ipv6_select_ident(net, fh, rt);
>  		fh->nexthdr = nexthdr;
>  		fh->reserved = 0;
>  		fh->frag_off = htons(IP6_MF);
> -		frag_id = fh->identification;
> +		fh->identification = frag_id;
>  
>  		first_len = skb_pagelen(skb);
>  		skb->data_len = first_len - skb_headlen(skb);

Look, just make ipv6_select_ident() return the 'id', and therefore have no
dependency upon the frag_hdr being available.

ip6_ufo_append_data() has the same silly problem and would benefit from
such a change as well.

The call sites that actually have the frag header available then just go:

	fh->identification = ipv6_select_ident(net, rt);


Thanks.
