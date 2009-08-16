From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] Update Neighbor Cache when IPv6 RA is received on a
 router
Date: Sun, 16 Aug 2009 12:00:27 +0930
Message-ID: <20090816120027.3d510139.lk-netdev@lk-netdev.nosense.org>
References: <1250381994-21329-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:60464 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbZHPCac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2009 22:30:32 -0400
In-Reply-To: <1250381994-21329-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sat, 15 Aug 2009 20:19:54 -0400
David Ward <david.ward@ll.mit.edu> wrote:

> When processing a received IPv6 Router Advertisement, the kernel
> creates or updates an IPv6 Neighbor Cache entry for the sender --
> but presently this does not occur if IPv6 forwarding is enabled
> (net.ipv6.conf.*.forwarding = 1), or if IPv6 Router Advertisements
> are not accepted (net.ipv6.conf.*.accept_ra = 0), because in these
> cases processing of the Router Advertisement has already halted.
> 
> This patch allows the Neighbor Cache to be updated in these cases,
> while still avoiding any modification to routes or link parameters.
> 

I'm a bit confused what benefit this has. Is the intent to avoid a
Neighbor Solicitation being triggered when a recent RA has already
provided the router's link local address, therefore reducing by a small
mount ND traffic?

> This continues to satisfy RFC 4861, since any entry created in the
> Neighbor Cache as the result of a received Router Advertisement is
> still placed in the STALE state.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> ---
>  net/ipv6/ndisc.c |   14 ++++++++------
>  1 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 1ba42bd..44b4c87 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1151,10 +1151,6 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>  			   skb->dev->name);
>  		return;
>  	}
> -	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra) {
> -		in6_dev_put(in6_dev);
> -		return;
> -	}
>  
>  	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
>  		in6_dev_put(in6_dev);
> @@ -1163,6 +1159,10 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>  		return;
>  	}
>  
> +	/* skip route and link configuration on routers */
> +	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra)
> +		goto skip_linkparms;
> +
>  #ifdef CONFIG_IPV6_NDISC_NODETYPE
>  	/* skip link-specific parameters from interior routers */
>  	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
> @@ -1283,9 +1283,7 @@ skip_defrtr:
>  		}
>  	}
>  
> -#ifdef CONFIG_IPV6_NDISC_NODETYPE
>  skip_linkparms:
> -#endif
>  
>  	/*
>  	 *	Process options.
> @@ -1312,6 +1310,10 @@ skip_linkparms:
>  			     NEIGH_UPDATE_F_ISROUTER);
>  	}
>  
> +	/* skip route and link configuration on routers */
> +	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra)
> +		goto out;
> +
>  #ifdef CONFIG_IPV6_ROUTE_INFO
>  	if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
>  		struct nd_opt_hdr *p;
> -- 
> 1.6.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
