From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] ipv6: prevent useless neigh alloc on PTP
 or lo routes
Date: Thu, 13 Sep 2012 23:51:16 +0200
Message-ID: <1347573076.8555.54.camel@edumazet-glaptop>
References: <1347451266.13103.882.camel@edumazet-glaptop>
	 <1347505193.13103.1340.camel@edumazet-glaptop>
	 <1347506158.13103.1365.camel@edumazet-glaptop>
	 <20120913.171305.713716058425991240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, maze@google.com,
	therbert@google.com, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59196 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882Ab2IMVvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 17:51:21 -0400
Received: by weyx8 with SMTP id x8so1983516wey.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 14:51:20 -0700 (PDT)
In-Reply-To: <20120913.171305.713716058425991240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-13 at 17:13 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 13 Sep 2012 05:15:58 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > We have special handling of SIT devices in addrconf_prefix_route()
> > to avoid allocating a neighbour for each destination.
> > 
> > If routing entry is :
> > 
> > ip -6 route add 2001:db8::/64 dev sit1
> > 
> > Then the kernel will create a new route and neighbour for every new
> > address under 2001:db8::/64 that we send a packet to 
> > (potentially, 2^64 routes and neighbours).
> > 
> > Under load, we immediately get the infamous "Neighbour table overflow"
> > message and machine eventually crash.
> > 
> > This does not happen if we specify a next-hop explicitly, like so:
> > 
> > ip -6 route add 2001:db8::/64 via fe80:: dev sit1
> > 
> > Same problem happens if we use routes to loopback.
> > 
> > Idea of this patch is to move existing SIT related code from
> > addrconf_prefix_route() to a more generic one in ip6_route_add(). 
> > 
> > This permits ip6_pol_route() to clone route instead of calling
> > rt6_alloc_cow() and allocate a neighbour.
> > 
> > Many thanks to Lorenzo for his help and suggestions.
> > 
> > Reported-by: Lorenzo Colitti <lorenzo@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> This patch lacks the desired effect without your clone-caching-removal
> patch, which I will not apply.
> 
> Therefore it doesn't make any sense to apply this either, as it won't
> fix the stated problem.
> 
> Doing a proper conversion of ipv6 to ref-count-less neigh's will solve
> this problem and allow all of the clone/cow caching code to be elided
> for the majority of cases and is the correct approach to these problems.


This seems quite different patches to me. Addressing two problems.

This patch is about not allocating a neighbour for a given route, but
reusing one existing neighbour. What could be possibly wrong with this,
since all neighbours are exactly the sames ?

I understand we can make it better with big surgery later, but right now
it seems quite reasonable.

This is already done (in part) for SIT devices, which are a subclass of
PtP device.

For the other patch, it seems problem was introduced in 2.6.38 when
CLONE_OFFLINK_ROUTE was removed in commit d80bc0fd26.
