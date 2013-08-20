From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipsec v2 1/3] ipv6: wire up skb->encapsulation
Date: Tue, 20 Aug 2013 10:35:46 +1000
Message-ID: <20130820003546.GA14038@verge.net.au>
References: <20130818114652.GA10192@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	yoshfuji@linux-ipv6.org, nicolas.dichtel@6wind.com,
	edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56760 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab3HTAeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 20:34:04 -0400
Content-Disposition: inline
In-Reply-To: <20130818114652.GA10192@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 18, 2013 at 01:46:52PM +0200, Hannes Frederic Sowa wrote:
> When pushing a new header before current one call skb_reset_inner_headers
> to record the position of the inner headers in the various ipv6 tunnel
> protocols.
> 
> We later need this to correctly identify the addresses needed to send
> back an error in the xfrm layer.
> 
> This change is safe, because skb->protocol is always checked before
> dereferencing data from the inner protocol.

It seems that the intention is to only track the inner-most header
due to the presence of if (likely(!skb->encapsulation)). Is this the
intention?

> 
> v2:
> a) unchanged
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> This patch is based on Steffen Klassert's ipsec tree.
> 
>  net/ipv6/ip6_gre.c    | 5 +++++
>  net/ipv6/ip6_tunnel.c | 6 ++++++
>  net/ipv6/sit.c        | 5 +++++
>  3 files changed, 16 insertions(+)
> 
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index ecd6073..90747f1 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -724,6 +724,11 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
>  		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
>  	}
>  
> +	if (likely(!skb->encapsulation)) {
> +		skb_reset_inner_headers(skb);
> +		skb->encapsulation = 1;
> +	}
> +
>  	skb_push(skb, gre_hlen);
>  	skb_reset_network_header(skb);
>  	skb_set_transport_header(skb, sizeof(*ipv6h));
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 1e55866..46ba243 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1027,6 +1027,12 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
>  		init_tel_txopt(&opt, encap_limit);
>  		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
>  	}
> +
> +	if (likely(!skb->encapsulation)) {
> +		skb_reset_inner_headers(skb);
> +		skb->encapsulation = 1;
> +	}
> +
>  	skb_push(skb, sizeof(struct ipv6hdr));
>  	skb_reset_network_header(skb);
>  	ipv6h = ipv6_hdr(skb);
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index a3437a4..fbfc5a8 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -888,6 +888,11 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
>  		ttl = iph6->hop_limit;
>  	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
>  
> +	if (likely(!skb->encapsulation)) {
> +		skb_reset_inner_headers(skb);
> +		skb->encapsulation = 1;
> +	}
> +
>  	err = iptunnel_xmit(dev_net(dev), rt, skb, fl4.saddr, fl4.daddr,
>  			    IPPROTO_IPV6, tos, ttl, df);
>  	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
