From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Mon, 28 Nov 2016 11:22:48 -0500 (EST)
Message-ID: <20161128.112248.2198395724649783009.davem@davemloft.net>
References: <1480017556-25988-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60544 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932468AbcK1QWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 11:22:55 -0500
In-Reply-To: <1480017556-25988-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Thu, 24 Nov 2016 20:59:16 +0100

> When multiple nexthops are available for a given route, the routing engine
> chooses a nexthop by computing the flow hash through get_hash_from_flowi6
> and by taking that value modulo the number of nexthops. The resulting value
> indexes the nexthop to select. This method causes issues when a new nexthop
> is added or one is removed (e.g. link failure). In that case, the number
> of nexthops changes and potentially all the flows get re-routed to another
> nexthop.
> 
> This patch implements a consistent hash method to select the nexthop in
> case of ECMP. The idea is to generate N random numbers (__u32) for each
> nexthop, where N is configurable. In order to select a nexthop, we find the
> number that is directly higher than the flow hash (which is also __u32).
> The nexthop associated to the number is then selected. The lookup method
> performs a binary search over the sorted array of numbers, which yields a
> time complexity of O(log n), where n is the number of nexthops times the
> number of random values generated for each number.
> 
> This feature can be enabled through the CONFIG_IPV6_MULTIPATH_CONSISTENT
> option and the number of random values generated for each nexthop is
> defined through CONFIG_IPV6_MPCONSIST_BUCKETSIZE.
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Thanks for trying to solve this problem.

But we really don't want this to be Kconfig gated.  If we decide to
support this it should be a run-time selectable option.  Every
distribution on the planet is going to turn your Kconfig option on, so
whatever you think we might be saving by putting this behind Kconfig
checks won't be realized for large swaths of the userbase.

I also question how necessary %100 consistent hashing of ECMP really
is.

If we can do something at extremely low cost and arrive at a very low
disruption rate, honestly that's probably good enough.

I assume you've looked over RFC2992.  A low disrutpion algorithm is
described there and if we could just get rid of the divide it might
be extremely desirable.
