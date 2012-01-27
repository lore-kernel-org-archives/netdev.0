From: Brent Cook <bcook@breakingpoint.com>
Subject: Re: [PATCH 1/2] ipv4/ipv6: Prepare for new route gateway semantics.
Date: Fri, 27 Jan 2012 12:59:51 -0600
Message-ID: <201201271259.51534.bcook@breakingpoint.com>
References: <20120126.155544.2054995753871805122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.breakingpoint.com ([65.36.7.12]:36088 "EHLO
	mail.breakingpoint.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab2A0S77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 13:59:59 -0500
In-Reply-To: <20120126.155544.2054995753871805122.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, January 26, 2012 02:55:44 PM David Miller wrote:
> In the future the ipv4/ipv6 route gateway will take on two types
> of values:
> 
> 1) INADDR_ANY/IN6ADDR_ANY, for local network routes, and in this case
>    the neighbour must be obtained using the destination address in
>    ipv4/ipv6 header as the lookup key.
> 
> 2) Everything else, the actual nexthop route address.
> 
> So if the gateway is not inaddr-any we use it, otherwise we must use
> the packet's destination address.

Under what cases would this be expected to help keep the # of lookup keys at a 
minimum? I tried some experiments with these changes against a topology like 
this:

6RD CE         Router         Linux 6RD BR            IPv6 Server
1.1.1.200  ->  1.0.0.1  -> 1.0.0.2 - 2001:1234:1  ->  2001:1234:2

Behind the 6RD CE, we simulate a few thousand hosts connecting to the server.

This seems to still have the effect of adding a few thousand neighbor entries, 
one for each packet the IPv6 server sends to one of the IPv6 addresses behind 
the CE.

The addresses modulate as follows:

2001:5678::1 - 2001:5678::ffff

I might have expected the nexthop route address for packets directed to the 
tunneled IPv6 hosts to be the same for all destination IPs. Would it be 
helpful for me to dig in and find out what the lookup key ends up being in 
this case?

> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/route.c |    5 +++++
>  net/ipv6/route.c |   16 +++++++++++++++-
>  2 files changed, 20 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index bcacf54..4eeb8ce 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1117,10 +1117,15 @@ static struct neighbour *ipv4_neigh_lookup(const
> struct dst_entry *dst, const vo static const __be32 inaddr_any = 0;
>  	struct net_device *dev = dst->dev;
>  	const __be32 *pkey = daddr;
> +	const struct rtable *rt;
>  	struct neighbour *n;
> 
> +	rt = (const struct rtable *) dst;
> +
>  	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
>  		pkey = &inaddr_any;
> +	else if (rt->rt_gateway)
> +		pkey = (const __be32 *) &rt->rt_gateway;
> 
>  	n = __ipv4_neigh_lookup(&arp_tbl, dev, *(__force u32 *)pkey);
>  	if (n)
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 8c2e3ab..7d7f306 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -121,9 +121,23 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst,
> unsigned long old) return p;
>  }
> 
> +static inline const void *choose_neigh_daddr(struct rt6_info *rt, const
> void *daddr) +{
> +	struct in6_addr *p = &rt->rt6i_gateway;
> +
> +	if (p->s6_addr32[0] | p->s6_addr32[1] |
> +	    p->s6_addr32[2] | p->s6_addr32[3])
> +		return (const void *) p;
> +	return daddr;
> +}
> +
>  static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
> const void *daddr) {
> -	struct neighbour *n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
> +	struct rt6_info *rt = (struct rt6_info *) dst;
> +	struct neighbour *n;
> +
> +	daddr = choose_neigh_daddr(rt, daddr);
> +	n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
>  	if (n)
>  		return n;
>  	return neigh_create(&nd_tbl, daddr, dst->dev);
