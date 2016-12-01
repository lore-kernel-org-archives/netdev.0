From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next v2] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Thu, 01 Dec 2016 06:30:31 +0100
Message-ID: <1480570231.706104.804624113.3D4FA7FA@webmail.messagingengine.com>
References: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be>
 <20161130.144946.28181822717893867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60872 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751003AbcLAFac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 00:30:32 -0500
In-Reply-To: <20161130.144946.28181822717893867.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016, at 20:49, David Miller wrote:
> From: David Lebrun <david.lebrun@uclouvain.be>
> Date: Tue, 29 Nov 2016 18:15:18 +0100
> 
> > When multiple nexthops are available for a given route, the routing engine
> > chooses a nexthop by computing the flow hash through get_hash_from_flowi6
> > and by taking that value modulo the number of nexthops. The resulting value
> > indexes the nexthop to select. This method causes issues when a new nexthop
> > is added or one is removed (e.g. link failure). In that case, the number
> > of nexthops changes and potentially all the flows get re-routed to another
> > nexthop.
> > 
> > This patch implements a consistent hash method to select the nexthop in
> > case of ECMP. The idea is to generate K slices (or intervals) for each
> > route with multiple nexthops. The nexthops are randomly assigned to those
> > slices, in a uniform manner. The number K is configurable through a sysctl
> > net.ipv6.route.ecmp_slices and is always an exponent of 2. To select the
> > nexthop, the algorithm takes the flow hash and computes an index which is
> > the flow hash modulo K. As K = 2^x, the modulo can be computed using a
> > simple binary AND operation (idx = hash & (K - 1)). The resulting index
> > references the selected nexthop. The lookup time complexity is thus O(1).
> > 
> > When a nexthop is added, it steals K/N slices from the other nexthops,
> > where N is the new number of nexthops. The slices are stolen randomly and
> > uniformly from the other nexthops. When a nexthop is removed, the orphan
> > slices are randomly reassigned to the other nexthops.
> > 
> > The number of slices for a route also fixes the maximum number of nexthops
> > possible for that route.
> > 
> > Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> 
> Interesting approach, but like Hannes I worry about the memory
> consumption
> bounds.
> 
> Limiting to 1<<16 is interesting, but if you can limit to 1<<8 (256
> nexthops) maybe the state requirement can be compressed even further?

>From what I have heard the user space DPDK-alike implementations of
consistent hashing actually use as much memory as possible (2^32) to
consistently steer the flow to the target, so every u32 flow hash value
has a unique corresponding mapping. The slice size doesn't affect the
number of nexthops (that is limited by the datatype in the array, which
is in this patch a u8), thus limiting us to 256 nexthops we could refer
to independently of the slice size. Lowering the slices means that the
algorithm becomes inaccurate as more flows map to one nexthop selector,
thus causing more inconsistent routing decisions to be made when changes
happen.

> We can always increase this if necessary in the future if someone
> reports a reasonable use case that really needs it.  Let's start
> simple and small first.

If people really rely on consistent hashing for load balancers setups
where the backends don't synchronize their state across their server
(the IPv6 anycast use case), they would probably always want to go with
the full sized state table, as every update on this map would cause user
errors and inconsistent state on the backend.

Thus, I think that we should also allow for maximum allocations,
wherever they come from, as it is already out there and deployed.

Bye,
Hannes
