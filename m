From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: del unreachable route when an addr is deleted on
 lo
Date: Tue, 25 Sep 2012 15:43:51 +0200
Message-ID: <1348580631.26828.3047.camel@edumazet-glaptop>
References: <1348568699-3932-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58948 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709Ab2IYNn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 09:43:56 -0400
Received: by eaac11 with SMTP id c11so2262478eaa.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 06:43:55 -0700 (PDT)
In-Reply-To: <1348568699-3932-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-25 at 12:24 +0200, Nicolas Dichtel wrote:
> When an address is added on loopback (ip -6 a a 2002::1/128 dev lo), two routes
> are added:
>  - one in the local table:
>     local 2002::1 via :: dev lo  proto none  metric 0
>  - one the in main table (for the prefix):
>     unreachable 2002::1 dev lo  proto kernel  metric 256  error -101
> 
> When the address is deleted, the route inserted in the main table remains
> because we use rt6_lookup(), which returns NULL when dst->error is set, which
> is the case here! Thus, it is better to use ip6_route_lookup() to avoid this
> kind of filter.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/addrconf.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 6bc85f7..b6b2f9f 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -788,8 +788,12 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
>  		struct in6_addr prefix;
>  		struct rt6_info *rt;
>  		struct net *net = dev_net(ifp->idev->dev);
> +		struct flowi6 fl6 = {};
>  		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
> -		rt = rt6_lookup(net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
> +		fl6.flowi6_oif = ifp->idev->dev->ifindex;
> +		fl6.daddr = prefix;
> +		rt = (struct rt6_info *)ip6_route_lookup(net, &fl6,
> +							 RT6_LOOKUP_F_IFACE);
>  

rt cant be NULL here ( but can be ip6_null_entry )

>  		if (rt && addrconf_is_prefix_route(rt)) {

So this condition is obsolete...
