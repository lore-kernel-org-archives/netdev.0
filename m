From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next v2] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Wed, 30 Nov 2016 04:52:32 +0100
Message-ID: <1480477952.3702850.803295033.367FD66D@webmail.messagingengine.com>
References: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Lebrun <david.lebrun@uclouvain.be>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60047 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752099AbcK3Dwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 22:52:33 -0500
In-Reply-To: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Nov 29, 2016, at 18:15, David Lebrun wrote:
> When multiple nexthops are available for a given route, the routing
> engine
> chooses a nexthop by computing the flow hash through get_hash_from_flowi6
> and by taking that value modulo the number of nexthops. The resulting
> value
> indexes the nexthop to select. This method causes issues when a new
> nexthop
> is added or one is removed (e.g. link failure). In that case, the number
> of nexthops changes and potentially all the flows get re-routed to
> another
> nexthop.
> 
> This patch implements a consistent hash method to select the nexthop in
> case of ECMP. The idea is to generate K slices (or intervals) for each
> route with multiple nexthops. The nexthops are randomly assigned to those
> slices, in a uniform manner. The number K is configurable through a
> sysctl
> net.ipv6.route.ecmp_slices and is always an exponent of 2. To select the
> nexthop, the algorithm takes the flow hash and computes an index which is
> the flow hash modulo K. As K = 2^x, the modulo can be computed using a
> simple binary AND operation (idx = hash & (K - 1)). The resulting index
> references the selected nexthop. The lookup time complexity is thus O(1).
> 
> When a nexthop is added, it steals K/N slices from the other nexthops,
> where N is the new number of nexthops. The slices are stolen randomly and
> uniformly from the other nexthops. When a nexthop is removed, the orphan
> slices are randomly reassigned to the other nexthops.
> 
> The number of slices for a route also fixes the maximum number of
> nexthops
> possible for that route.

In the worst case this causes 2GB (order 19) allocations (x == 31) to
happen in GFP_ATOMIC (due to write lock) context and could cause update
failures to the routing table due to fragmentation. Are you sure the
upper limit of 31 is reasonable? I would very much prefer an upper limit
of below or equal 25 for x to stay within the bounds of the slab
allocators (which is still a lot and probably causes errors!).
Unfortunately because of the nature of the sysctl you can't really
create its own cache for it. :/

Also by design, one day this should all be RCU and having that much data
outstanding worries me a bit during routing table mutation.

I am a fan of consistent hashing but I am not so sure if it belongs into
a generic ECMP implementation or into its own ipvs or netfilter module
where you specifically know how much memory to burn for it.

Also please convert the sysctl to a netlink attribute if you pursue this
because if I change the sysctl while my quagga is hammering the routing
table I would like to know which nodes allocate what amount of memory.

Bye,
Hannes
