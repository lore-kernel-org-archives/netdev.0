From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Mon, 31 Jul 2006 16:55:50 +0300
Message-ID: <44CE0BE6.1070108@tcs.hut.fi>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.495778268@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:41738 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S932244AbWGaNzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 09:55:52 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060726221849.495778268@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

> Adds the framework to support multiple IPv6 routing tables.
> Currently all automatically generated routes are put into the
> same table. This could be changed at a later point after
> considering the produced locking overhead.

Hi Thomes, some minor comments below.

> When locating routes for redirects only the main table is
> searched for now. Since policy rules will not be reversible
> it is unclear whether it makes sense to change this.

This is a good point. You are absolutely correct about the policy rules.

IIRC, I initially looked through all the tables, but skipped this
behavior when I rewrote the code for 2.6.11. Currently I'm once again
in favor of looping through them all. This is IMO at least closer to the
spirit of RFC 2461 section 8.3. where a host SHOULD update its
destination cache upon receiving a redirect. If we don't look through
all tables, we can't ensure this happens.

> Index: net-2.6.git/include/net/ip6_fib.h
> ===================================================================
> --- net-2.6.git.orig/include/net/ip6_fib.h
> +++ net-2.6.git/include/net/ip6_fib.h

<snip>

> @@ -143,12 +146,41 @@ struct rt6_statistics {
>  
>  typedef void			(*f_pnode)(struct fib6_node *fn, void *);
>  
> -extern struct fib6_node		ip6_routing_table;
> +struct fib6_table {
> +	struct hlist_node	tb6_hlist;
> +	u32			tb6_id;
> +	rwlock_t		tb6_lock;
> +	struct fib6_node	tb6_root;
> +};
> +
> +#define RT6_TABLE_UNSPEC	RT_TABLE_UNSPEC
> +#define RT6_TABLE_MAIN		RT_TABLE_MAIN
> +#define RT6_TABLE_LOCAL		RT6_TABLE_MAIN
> +#define RT6_TABLE_DFLT		RT6_TABLE_MAIN
> +#define RT6_TABLE_INFO		RT6_TABLE_MAIN

IMO it's a bit inconsistent to define a separate table entry for Route
Information generated routes, but not Prefix Information based ones.
What do you say about adding a RT6_TABLE_PRFX?

> Index: net-2.6.git/net/ipv6/route.c
> ===================================================================
> --- net-2.6.git.orig/net/ipv6/route.c
> +++ net-2.6.git/net/ipv6/route.c

<snip>

> @@ -1435,12 +1523,15 @@ static struct rt6_info *rt6_add_route_in
>  struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *dev)
>  {	
>  	struct rt6_info *rt;
> -	struct fib6_node *fn;
> +	struct fib6_table *table;
>  
> -	fn = &ip6_routing_table;
> +	/* TODO: It might be better to search all tables */
> +	table = fib6_get_table(RT6_TABLE_DFLT);

As long as the table for default routes is RT6_TABLE_DFLT and can't be
configured by the user, I think the correct behavior is just to search
RT6_TABLE_DFLT.

Otherwise it looks very good!

Regards,
Ville
