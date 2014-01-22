From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net] IPv6: Fix broken IPv6 routing table after
 loopback down-up
Date: Wed, 22 Jan 2014 08:20:55 -0800
Message-ID: <1390407655.27806.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390404908-3914-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	gaofeng@cn.fujitsu.com
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:56728 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbaAVQVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 11:21:01 -0500
Received: by mail-pa0-f53.google.com with SMTP id lj1so588552pab.12
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:20:58 -0800 (PST)
In-Reply-To: <1390404908-3914-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-22 at 16:35 +0100, Sabrina Dubroca wrote:

> 
> ---
>  net/ipv6/addrconf.c | 22 ++++++++++++++++++----
>  1 file changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4b6b720..b2eb653 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2578,6 +2578,23 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
>  }
>  #endif
>  
> +struct rt6_info *addrconf_dst_alloc_once(struct inet6_dev *idev,
> +					 const struct in6_addr *addr,
> +					 bool anycast)
> +{
> +	struct net *net = dev_net(idev->dev);
> +	struct rt6_info *rt = rt6_lookup(net, addr, NULL, 0, 0);

This allocates a dst

> +
> +	if (rt == NULL)
> +		return addrconf_dst_alloc(idev, addr, anycast);
> +	else if (!(rt->rt6i_flags & RTF_NONEXTHOP &&
> +		   ((anycast && rt->rt6i_flags & RTF_ANYCAST) ||
> +		    (!anycast && rt->rt6i_flags & RTF_LOCAL))))
> +		return addrconf_dst_alloc(idev, addr, anycast);

But nothing seems to release it

It seems your patch lacks ip6_rt_put(rt); 

> +
> +	return ERR_PTR(-EEXIST);
> +}
> +
