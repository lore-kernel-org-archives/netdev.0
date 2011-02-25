From: David Miller <davem@davemloft.net>
Subject: route embedding
Date: Fri, 25 Feb 2011 13:13:30 -0800 (PST)
Message-ID: <20110225.131330.179945183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38315
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753076Ab1BYVMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 16:12:53 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 79F1C24C088
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 13:13:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So out of curiosity I took some cycle counts on my Niagara2 for three
different cases of output route resolution.  1) full routing cache
2) routing cache removed and 3) fib_table_lookup() on RT_TABLE_MAIN.

ip_route_output_key() stock net-next-2.6:		463 cycles
ip_route_output_key() cache removed, no optimizations:	3832 cycles
fib_table_lookup() on RT_TABLE_MAIN:			489 cycles

(For reference, doing two fib_table_look() calls, one on RT_TABLE_LOCAL
 then one on RT_TABLE_MAIN, costs about 800 cycles)

Most of the cost with the routing cache removed is quite silly in
nature:

1) As mentioned the other week, we do two fib_table_lookup() calls,
   one on RT_TABLE_LOCAL and one on RT_TABLE_MAIN.

   I think this could be consolidated into one lookup, and I'm running
   with that assumption in mind.

2) Allocating and freeing up the one-time dst_entry, as well as
   initializing all of it's state, has costs too.

To test out my theories about #1 and #2 above I wrote some quick hacks
against the tree with the routing cache removed, each change is
cumulative and depends upon the previous changes being present:

1) Remove struct flowi from struct rtable and just have it contain the
   necessary keys.  Replacing the struct flowi are:

	__be32	rt_key_dst;
	__be32	rt_key_src;
	...
	__u8	rt_tos;
	...
	int	rt_iif;
	int	rt_oif;
	__u32	rt_mark;

   Result: 3932 cycles

   Strangely this made things 100 cycles slower, but bear with me.

   Also, in a routing-cache-less world, these values are almost
   entirely superfluous.  All of these values can be reconstituted
   in the code paths that currently read them.

2) Expand dst_alloc() arguments so that more explicit initializations
   can be specified, dst_alloc()'s function signature now looks like:

	void *dst_alloc(struct dst_ops * ops, struct net_device *dev,
			int initial_ref, int initial_obsolete, int flags);

   Result: 3905 cycles

3) We currently write nearly every byte of the dst_entry objects twice
   when we create them, this is because we use kmem_cache_zalloc().

   So I changed dst_alloc() to use plain kmem_cache_alloc() and added
   explicit initialization to even struct members that start as zero,
   and then propagated the same kinds of changes into decnet, ipv4,
   and ipv6.

   Result: 3481 cycles.

   So, a pretty nice result.

4) I have a hack patch that puts all routes into RT_TABLE_MAIN and never
   uses RT_TABLE_LOCAL, then I force all fib_lookup() calls to consult
   RT_TABLE_MAIN only.  Thus reducing the number of fib_table_lookup()
   calls for output route resolution to one.

   Result: 3454 cycles.

   Not as much improvement as we would like, but it is something.

Anyways, this series of tests shows that object allocation, initialization,
et al. hold some non-trivial costs.

So I wrote a test where route object references are provided by the
caller (think inside of sk_buff, a socket, on the stack, etc.) and we
use a structure that gets rid of all the aspects which are irrelevant
without global dst caching.

The structure might look something like this for ipv4:

struct net_route {
        struct net_device       *dev;
        unsigned long           _metrics;
        struct neighbour        *neighbour;
        struct hh_cache         *hh;
        atomic_t                __refcnt;
};

struct ipv4_route {
        struct net_route        base;

        int                     rt_genid;

        __be32                  rt_dst;
        __be32                  rt_src;
        __u16                   rt_type;
        __u8                    rt_tos;

        int                     rt_iif;
        int                     rt_oif;
        __u32                   rt_mark;

        __be32                  rt_gateway;
        __be32                  rt_spec_dst;

        u32                     rt_peer_genid;
        struct inet_peer        *peer;
        struct fib_info         *fi;
};

Then I cycle counted a test which essentially does a fib_table_lookup() on
RT_TABLE_MAIN and then uses the result to fill in an ipv4_route object, it
looks like:

	table = fib_get_table(&init_net, RT_TABLE_MAIN);
	if (!table) {
		... error handling ...
	}
        err = fib_table_lookup(table, fl, &res, FIB_LOOKUP_NOREF);
        if (err)
                return err;

        rt->rt_genid = atomic_read(&gen_id);
	rt->rt_dst = fl->fl4_dst;
        rt->rt_src = fl->fl4_src;
        rt->rt_type = res.type;
        rt->rt_tos = fl->fl4_tos;
	rt->rt_iif = fl->iif;
        rt->rt_oif = fl->oif;
        rt->rt_mark = fl->mark;
	rt->rt_gateway = FIB_RES_GW(res);
        rt->rt_spec_dst = fl->fl4_src;
        rt->rt_peer_genid = 0;
        rt->peer = NULL;
        rt->fi = NULL;

And this costs about 500 cycles.

The idea is that we would move to a model where the route information
lives embedded inside of a containing object (the user), either the
socket or the sk_buff itself in the most common cases.

Of course, we would need to make amends to handle strings or bundles
of routes such as those created by IPSEC.  We could take care of this
by simply using the embedded storage plus a pointer.  The pointer
could point to an externally allocated object such as an IPSEC bundle,
instead of the embedded route memory.

There are a few funnies to attend to wrt. reference counting.  For the
embedded case we could likely get away with using the containing
object's reference counting to refcount the route (win).  Then the
issue is how to deal properly with cases where the route pointer
"escapes", as is currently handled by dst_clone().  We could either
take another reference to the route's containing object, or we could
simply COW the route object.

Anyways I think this would make our routing implementation not only perform
independent of traffic patterns, but also be within a few clock cycles of
the performance we get right now.
