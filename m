From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next v2] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Wed, 30 Nov 2016 14:49:46 -0500 (EST)
Message-ID: <20161130.144946.28181822717893867.davem@davemloft.net>
References: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40898 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754505AbcK3Ttr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:49:47 -0500
In-Reply-To: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Tue, 29 Nov 2016 18:15:18 +0100

> When multiple nexthops are available for a given route, the routing engine
> chooses a nexthop by computing the flow hash through get_hash_from_flowi6
> and by taking that value modulo the number of nexthops. The resulting value
> indexes the nexthop to select. This method causes issues when a new nexthop
> is added or one is removed (e.g. link failure). In that case, the number
> of nexthops changes and potentially all the flows get re-routed to another
> nexthop.
> 
> This patch implements a consistent hash method to select the nexthop in
> case of ECMP. The idea is to generate K slices (or intervals) for each
> route with multiple nexthops. The nexthops are randomly assigned to those
> slices, in a uniform manner. The number K is configurable through a sysctl
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
> The number of slices for a route also fixes the maximum number of nexthops
> possible for that route.
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Interesting approach, but like Hannes I worry about the memory consumption
bounds.

Limiting to 1<<16 is interesting, but if you can limit to 1<<8 (256
nexthops) maybe the state requirement can be compressed even further?

We can always increase this if necessary in the future if someone
reports a reasonable use case that really needs it.  Let's start
simple and small first.
