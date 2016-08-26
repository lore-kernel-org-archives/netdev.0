From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] ipv6: Don't unset flowi6_proto in ipxip6_tnl_xmit()
Date: Fri, 26 Aug 2016 22:49:23 +0300
Message-ID: <20160826224923.62827d04@halley>
References: <20160826155229.8040-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
To: Eli Cooper <elicooper@gmx.com>, Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35539 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751711AbcHZTtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 15:49:32 -0400
Received: by mail-wm0-f67.google.com with SMTP id i5so647877wmg.2
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 12:49:32 -0700 (PDT)
In-Reply-To: <20160826155229.8040-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 26 Aug 2016 23:52:29 +0800 Eli Cooper <elicooper@gmx.com> wrote:
> Commit 8eb30be0352d0916 ("ipv6: Create ip6_tnl_xmit") unsets
> flowi6_proto in ip4ip6_tnl_xmit() and ip6ip6_tnl_xmit().
> Since xfrm_selector_match() relies on this info, IPv6 packets
> sent by an ip6tunnel cannot be properly selected by their
> protocols after removing it. This patch puts flowi6_proto back.
> 
> Cc: stable@vger.kernel.org
> Fixes: 8eb30be0352d ("ipv6: Create ip6_tnl_xmit")
> Signed-off-by: Eli Cooper <elicooper@gmx.com>
> ---
>  net/ipv6/ip6_tunnel.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 2050217..5c57797 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1174,6 +1174,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
>  		encap_limit = t->parms.encap_limit;
>  
>  	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
> +	fl6.flowi6_proto = IPPROTO_IPIP;
>  
>  	dsfield = ipv4_get_dsfield(iph);
>  
> @@ -1233,6 +1234,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
>  		encap_limit = t->parms.encap_limit;
>  
>  	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
> +	fl6.flowi6_proto = IPPROTO_IPV6;
>  

I wonder if this is the right way to go.

This DOES fix the regression for ip4ip6_tnl_xmit and ip6ip6_tnl_xmit
users.

However new users of 'ip6_tnl_xmit' (e.g. __gre6_xmit callers) may still
have their 'fl6->flowi6_proto' not armed.

Maybe the right fix is assigning 'fl6->flowi6_proto = proto', either at
start of 'ip6_tnl_xmit' or just prior the ip6_route_output() call.

Tom, can you acknowledge?

Thanks,
Shmulik
