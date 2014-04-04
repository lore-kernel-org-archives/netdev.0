From: Martin Pelikan <martin.pelikan@gmail.com>
Subject: Re: (patch needs review) NULL dereference in xfrm_output with NAT
Date: Fri, 4 Apr 2014 14:29:17 +0200
Message-ID: <20140404122917.GM5945@methuselah>
References: <20140402103711.GJ5945@methuselah>
 <20140404090242.GN32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:50784 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbaDDM3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 08:29:22 -0400
Received: by mail-wi0-f176.google.com with SMTP id r20so1159808wiv.3
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 05:29:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140404090242.GN32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Just returning 0 here is not sufficient, we need to dst_output() the
> packet to its new destination. Does the patch below fix your problem?

Your patch avoids the crash the same way as mine, but doesn't fix my related
problem: I have two flows through that IPv6 endpoint: IPv6 default gw tunnel
+ IPv4 tunnel between two private networks.  But only one of them works at a
time, and it is the one which was set up first.
The other endpoint is OpenBSD with iked(8) and I can see the replies going
into enc0 there, ESP packets arriving into this Linux box at enp4s6, but the
traffic isn't being decapsulated and sent further away on br0.
If I disable the working tunnel (v6 for example), the other one (v4) starts
working immediately, so it's probably not caused by bad strongSwan config.

Do you think these bugs might be related?  Any ideas how to proceed without
spending days on it?  This doesn't work with either diff, but as a crash
fix, I'm fine with yours.

Thanks!
--
Martin Pelikan


> diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
> index baa0f63..52df0e6 100644
> --- a/net/ipv4/xfrm4_output.c
> +++ b/net/ipv4/xfrm4_output.c
> @@ -62,10 +62,7 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
>  	if (err)
>  		return err;
>  
> -	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
> -	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED;
> -
> -	skb->protocol = htons(ETH_P_IP);
> +	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
>  
>  	return x->outer_mode->output2(x, skb);
>  }
> @@ -73,27 +70,36 @@ EXPORT_SYMBOL(xfrm4_prepare_output);
>  
>  int xfrm4_output_finish(struct sk_buff *skb)
>  {
> +	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
> +	skb->protocol = htons(ETH_P_IP);
> +
>  #ifdef CONFIG_NETFILTER
> -	if (!skb_dst(skb)->xfrm) {
> +	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
> +#endif
> +
> +	return xfrm_output(skb);
> +}
> +
> +static int __xfrm4_output(struct sk_buff *skb)
> +{
> +	struct xfrm_state *x = skb_dst(skb)->xfrm;
> +
> +#ifdef CONFIG_NETFILTER
> +	if (!x) {
>  		IPCB(skb)->flags |= IPSKB_REROUTED;
>  		return dst_output(skb);
>  	}
> -
> -	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
>  #endif
>  
> -	skb->protocol = htons(ETH_P_IP);
> -	return xfrm_output(skb);
> +	return x->outer_mode->afinfo->output_finish(skb);
>  }
>  
>  int xfrm4_output(struct sk_buff *skb)
>  {
>  	struct dst_entry *dst = skb_dst(skb);
> -	struct xfrm_state *x = dst->xfrm;
>  
>  	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb,
> -			    NULL, dst->dev,
> -			    x->outer_mode->afinfo->output_finish,
> +			    NULL, dst->dev, __xfrm4_output,
>  			    !(IPCB(skb)->flags & IPSKB_REROUTED));
>  }
>  
> diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
> index 6cd625e..ba62433 100644
> --- a/net/ipv6/xfrm6_output.c
> +++ b/net/ipv6/xfrm6_output.c
> @@ -114,12 +114,6 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
>  	if (err)
>  		return err;
>  
> -	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
> -#ifdef CONFIG_NETFILTER
> -	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
> -#endif
> -
> -	skb->protocol = htons(ETH_P_IPV6);
>  	skb->local_df = 1;
>  
>  	return x->outer_mode->output2(x, skb);
> @@ -128,11 +122,13 @@ EXPORT_SYMBOL(xfrm6_prepare_output);
>  
>  int xfrm6_output_finish(struct sk_buff *skb)
>  {
> +	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
> +	skb->protocol = htons(ETH_P_IPV6);
> +
>  #ifdef CONFIG_NETFILTER
>  	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
>  #endif
>  
> -	skb->protocol = htons(ETH_P_IPV6);
>  	return xfrm_output(skb);
>  }
>  
> @@ -142,6 +138,13 @@ static int __xfrm6_output(struct sk_buff *skb)
>  	struct xfrm_state *x = dst->xfrm;
>  	int mtu;
>  
> +#ifdef CONFIG_NETFILTER
> +	if (!x) {
> +		IP6CB(skb)->flags |= IP6SKB_REROUTED;
> +		return dst_output(skb);
> +	}
> +#endif
> +
>  	if (skb->protocol == htons(ETH_P_IPV6))
>  		mtu = ip6_skb_dst_mtu(skb);
>  	else
> @@ -165,6 +168,7 @@ static int __xfrm6_output(struct sk_buff *skb)
>  
>  int xfrm6_output(struct sk_buff *skb)
>  {
> -	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL,
> -		       skb_dst(skb)->dev, __xfrm6_output);
> +	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb,
> +			    NULL, skb_dst(skb)->dev, __xfrm6_output,
> +			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
>  }
> 
