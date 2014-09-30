From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 4/5] gre: Set inner protocol in v4 and v6 GRE
 transmit
Date: Tue, 30 Sep 2014 14:02:51 +0900
Message-ID: <20140930050251.GE16823@verge.net.au>
References: <1411748554-7346-1-git-send-email-therbert@google.com>
 <1411748554-7346-5-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47676 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbaI3FCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 01:02:54 -0400
Content-Disposition: inline
In-Reply-To: <1411748554-7346-5-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 09:22:33AM -0700, Tom Herbert wrote:
> Call skb_set_inner_protocol to set inner Ethernet protocol to
> protocol being encapsulation by GRE before tunnel_xmit. This is
> needed for GSO if UDP encapsulation (fou) is being done.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  net/ipv4/ip_gre.c  | 2 ++
>  net/ipv6/ip6_gre.c | 8 ++++++--
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 829aff8b..0485ef1 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -241,6 +241,8 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
>  	/* Push GRE header. */
>  	gre_build_header(skb, &tpi, tunnel->tun_hlen);
>  
> +	skb_set_inner_protocol(skb, tpi.proto);
> +
>  	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
>  }
>  
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index 5f19dfb..9a0a1aa 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -616,6 +616,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
>  	int err = -1;
>  	u8 proto;
>  	struct sk_buff *new_skb;
> +	__be16 protocol;
>  
>  	if (dev->type == ARPHRD_ETHER)
>  		IPCB(skb)->flags = 0;
> @@ -732,8 +733,9 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
>  	ipv6h->daddr = fl6->daddr;
>  
>  	((__be16 *)(ipv6h + 1))[0] = tunnel->parms.o_flags;
> -	((__be16 *)(ipv6h + 1))[1] = (dev->type == ARPHRD_ETHER) ?
> -				   htons(ETH_P_TEB) : skb->protocol;
> +	protocol = (dev->type == ARPHRD_ETHER) ?
> +		    htons(ETH_P_TEB) : skb->protocol;
> +	((__be16 *)(ipv6h + 1))[1] = protocol;
>  
>  	if (tunnel->parms.o_flags&(GRE_KEY|GRE_CSUM|GRE_SEQ)) {
>  		__be32 *ptr = (__be32 *)(((u8 *)ipv6h) + tunnel->hlen - 4);
> @@ -754,6 +756,8 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
>  		}
>  	}
>  
> +	skb_set_inner_protocol(skb, protocol);
> +
>  	ip6tunnel_xmit(skb, dev);
>  	if (ndst)
>  		ip6_tnl_dst_store(tunnel, ndst);
> -- 
> 2.1.0.rc2.206.gedb03e5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
