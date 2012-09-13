From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv6: prevent useless neigh alloc on PTP
 or lo routes
Date: Thu, 13 Sep 2012 17:13:05 -0400 (EDT)
Message-ID: <20120913.171305.713716058425991240.davem@davemloft.net>
References: <1347451266.13103.882.camel@edumazet-glaptop>
	<1347505193.13103.1340.camel@edumazet-glaptop>
	<1347506158.13103.1365.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, maze@google.com,
	therbert@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997Ab2IMVNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 17:13:07 -0400
In-Reply-To: <1347506158.13103.1365.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Sep 2012 05:15:58 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> We have special handling of SIT devices in addrconf_prefix_route()
> to avoid allocating a neighbour for each destination.
> 
> If routing entry is :
> 
> ip -6 route add 2001:db8::/64 dev sit1
> 
> Then the kernel will create a new route and neighbour for every new
> address under 2001:db8::/64 that we send a packet to 
> (potentially, 2^64 routes and neighbours).
> 
> Under load, we immediately get the infamous "Neighbour table overflow"
> message and machine eventually crash.
> 
> This does not happen if we specify a next-hop explicitly, like so:
> 
> ip -6 route add 2001:db8::/64 via fe80:: dev sit1
> 
> Same problem happens if we use routes to loopback.
> 
> Idea of this patch is to move existing SIT related code from
> addrconf_prefix_route() to a more generic one in ip6_route_add(). 
> 
> This permits ip6_pol_route() to clone route instead of calling
> rt6_alloc_cow() and allocate a neighbour.
> 
> Many thanks to Lorenzo for his help and suggestions.
> 
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This patch lacks the desired effect without your clone-caching-removal
patch, which I will not apply.

Therefore it doesn't make any sense to apply this either, as it won't
fix the stated problem.

Doing a proper conversion of ipv6 to ref-count-less neigh's will solve
this problem and allow all of the clone/cow caching code to be elided
for the majority of cases and is the correct approach to these problems.
