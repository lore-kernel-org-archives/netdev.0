From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/1] ipv6: use addrconf_get_prefix_route for prefix route
 lookup [v2] (was [PATCH 1/2] ipv6: avoid blackhole and prohibited entries
 upon prefix purge [v3])
Date: Thu, 10 Jan 2013 18:44:25 +0900
Message-ID: <50EE8D79.1080807@linux-ipv6.org>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com> <1357415941.1678.4163.camel@edumazet-glaptop> <2A507F9D-3D53-475F-8FA9-9E6CFEE9C97A@ipflavors.com> <50EAA28B.1080300@6wind.com> <3EF640F8-5242-486E-B7A3-9DA2A88F5A4F@ipflavors.com> <50EAED10.90904@6wind.com> <08F52788-0BD9-4907-8FC3-E9DF530AB042@ipflavors.com> <50EC47AD.8000801@6wind.com> <50EC54E3.9080606@linux-ipv6.org> <6A08EDC1-08A0-411D-90CF-6DB1CB7FA3A0@ipflavors.com> <50ED88AF.3040705@6wind.com> <683E9BA1-C85B-43E0-AF98-397D50E302F6@ipflavors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Romain KUNTZ <r.kuntz@ipflavors.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33482 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751041Ab3AJJo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 04:44:28 -0500
In-Reply-To: <683E9BA1-C85B-43E0-AF98-397D50E302F6@ipflavors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Romain KUNTZ wrote:

> From 203474c87f45da40b5c9d9e629164561307b4199 Mon Sep 17 00:00:00 2001
> From: Romain Kuntz <r.kuntz@ipflavors.com>
> Date: Thu, 10 Jan 2013 07:41:36 +0100
> Subject: [PATCH 1/1] ipv6: use addrconf_get_prefix_route for prefix route lookup [v2]
> 
> Replace ip6_route_lookup() with addrconf_get_prefix_route() when
> looking up for a prefix route. This ensures that the connected prefix
> is looked up in the main table, and avoids the selection of other
> matching routes located in different tables as well as blackhole
> or prohibited entries.
> 
> In addition, this fixes an Opps introduced by commit 64c6d08e (ipv6:
> del unreachable route when an addr is deleted on lo), that would occur
> when a blackhole or prohibited entry is selected by ip6_route_lookup().
> Such entries have a NULL rt6i_table argument, which is accessed by
> __ip6_del_rt() when trying to lock rt6i_table->tb6_lock.
> 
> The function addrconf_is_prefix_route() is not used anymore and is
> removed.
> 
> [v2] Minor indentation cleanup and log updates.
> 
> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/addrconf.c |   25 +++++++++++--------------
>  1 files changed, 11 insertions(+), 14 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 29ba4ff..ec3e065 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -154,6 +154,11 @@ static void addrconf_type_change(struct net_device *dev,
>  				 unsigned long event);
>  static int addrconf_ifdown(struct net_device *dev, int how);
>  
> +static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
> +						  int plen,
> +						  const struct net_device *dev,
> +						  u32 flags, u32 noflags);
> +
>  static void addrconf_dad_start(struct inet6_ifaddr *ifp);
>  static void addrconf_dad_timer(unsigned long data);
>  static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
> @@ -250,12 +255,6 @@ static inline bool addrconf_qdisc_ok(const struct net_device *dev)
>  	return !qdisc_tx_is_noop(dev);
>  }
>  
> -/* Check if a route is valid prefix route */
> -static inline int addrconf_is_prefix_route(const struct rt6_info *rt)
> -{
> -	return (rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0;
> -}
> -
>  static void addrconf_del_timer(struct inet6_ifaddr *ifp)
>  {
>  	if (del_timer(&ifp->timer))
> @@ -941,17 +940,15 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
>  	if ((ifp->flags & IFA_F_PERMANENT) && onlink < 1) {
>  		struct in6_addr prefix;
>  		struct rt6_info *rt;
> -		struct net *net = dev_net(ifp->idev->dev);
> -		struct flowi6 fl6 = {};
>  
>  		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
> -		fl6.flowi6_oif = ifp->idev->dev->ifindex;
> -		fl6.daddr = prefix;
> -		rt = (struct rt6_info *)ip6_route_lookup(net, &fl6,
> -							 RT6_LOOKUP_F_IFACE);
>  
> -		if (rt != net->ipv6.ip6_null_entry &&
> -		    addrconf_is_prefix_route(rt)) {
> +		rt = addrconf_get_prefix_route(&prefix,
> +					       ifp->prefix_len,
> +					       ifp->idev->dev,
> +					       0, RTF_GATEWAY | RTF_DEFAULT);
> +
> +		if (rt) {
>  			if (onlink == 0) {
>  				ip6_del_rt(rt);
>  				rt = NULL;
> 

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
