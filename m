From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: ECMP ipv6 vs ipv4
Date: Wed, 17 Apr 2013 15:16:18 +0200
Message-ID: <1366204578.31353.88.camel@localhost>
References: <1366012728.4975.13.camel@localhost>
	  <516C2212.4030502@6wind.com> <1366044816.4975.27.camel@localhost>
	 <516E6559.4070903@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:36861 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965643Ab3DQNQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 09:16:37 -0400
In-Reply-To: <516E6559.4070903@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-17 at 11:03 +0200, Nicolas Dichtel wrote:

> > Sure, but how do we add nexthop weights and algorithm selection (hash,
> > random) to this API? I personally prefer to have the routing behaviour
> > of ipv4 and ipv6 to be as similar as possible, as the basics are the
> > same anyway.
> You can use something like this:
> 
> $ ip -6 route add 3ffe:304:124:2306::/64 dev eth0 nexthop via 
> fe80::230:1bff:feb4:dd4f weight 1
> $ ip -6 route append 3ffe:304:124:2306::/64 dev eth0 nexthop via 
> fe80::230:1bff:feb4:e05c weight 2
> 
> >
> >>>
> >>> Another one of the flaws is that if I add nexthop weight or algorithm
> >>> (weighted hash or weighted random) I need to add this to the main rt
> >>> node, this seems like an inefficient memory structure, as this needs to
> >>> be added to all the siblings as well.
> >> Nexthop weight (rtnh->rtnh_hops) is not implemented.
> >
> > Yes it is... in my tree, but I want to extend it to also include support
> > for algorithm for hash based, etc.. and to keep it as close to the
> > existing APIs as possible I think the nexthop structure makes the most
> > sense for this.
> >
> >>>
> >>> I propose that we have a nexthop structure to an exclusive route,
> >>> similar what we have for IPv4, where we store the gateway, device and
> >>> weight for all nexthops and the algorithm in the route. This would make
> >>> the netlink API symmetrical again and fixes the n*n inefficiencies when
> >>> adding routes (all siblings need to know about all siblings).
> >>>
> >>> What are your thoughts on this?
> The pro of the current implementation is that you can add or delete a nexthop 
> withtout removing the whole route. You don't need to list again all nexthops 
> each time you want to modify one.

That would also be possible using ip -6 route change, it'll be more
efficient for insertions and more consistent with the IPv4
implementation. Remember that most code is in fact shared between IPv4
and IPv6 implementations for routing protocol suites.

For bird it would be much more convenient to have the same API work for
both as the code is shared (with minor differences). 

The memory structure like below would make sense and you can expand it
as well:

struct ip6_nexthop {
	int               flags; /* algorithm per packet or hash, etc */
	struct list_head  *hops; /* nh_via */
};
struct ip6_nh {
	int              ifindex;
	struct in6_addr  rt6i_gateway;
	char             weight;
	int              flags; /* pervasive, onlink */
};

I'm not sure how to make this map correctly to the append API.. I think
we need to make sure that all APIs either are consistent and symmetrical
or don't work from day 1.

I am willing to implement this, including algorithm support using the
netlink nexthop API, like the IPv4 implementation.. or change the IPv4
implementation, but either way I feel they need to be consistent.


Regards,

Wilco
