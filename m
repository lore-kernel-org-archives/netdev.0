From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/16] Metrics restructuring.
Date: Tue, 10 Jul 2012 08:07:03 -0700 (PDT)
Message-ID: <20120710.080703.916560084659556593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab2GJPHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:06 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 1CCEE586620
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series works towards the goal of minimizing the amount
of things that can change in an ipv4 route.

In a regime where the routing cache is removed, route changes will
lead to cloning in the FIB tables or similar.

The largest trigger of route metrics writes, TCP, now has it's own
cache of dynamic metric state.  The timewait timestamps are stored
there now as well.

As a result of that, pre-cowing metrics is no longer necessary,
and therefore FLOWI_FLAG_PRECOW_METRICS is removed.

Redirect and PMTU handling is moved back into the ipv4 routes.  I'm
sorry for all the headaches trying to do this in the inetpeer has
caused, it was the wrong approach for sure.

Since metrics become read-only for ipv4 we no longer need the inetpeer
hung off of the ipv4 routes either.  So those disappear too.

Also, timewait sockets no longer need to hold onto an inetpeer either.

After this series, we still have some details to resolve wrt. PMTU and
redirects for a route-cache-less system:

1) With just the plain route cache removal, PMTU will continue to
   work mostly fine.  This is because of how the local route users
   call down into the PMTU update code with the route they already
   hold.

   However, if we wish to cache pre-computed routes in fib_info
   nexthops (which we want for performance), then we need to add
   route cloning for PMTU events.

2) Redirects require more work.  First, redirects must be changed to
   be handled like PMTU.  Wherein we call down into the sockets and
   other entities, and then they call back into the routing code with
   the route they were using.

   So we'll be adding an ->update_nexthop() method alongside
   ->update_pmtu().

   And then, like for PMTU, we'll need cloning support once we start
   caching routes in the fib_info nexthops.

But that's it, we can completely pull the trigger and remove the
routing cache with minimal disruptions.

As it is, this patch series alone helps a lot of things.  For one,
routing cache entry creation should be a lot faster, because we no
longer do inetpeer lookups (even to check if an entry exists).

This patch series also opens the door for non-DST_HOST ipv4 routes,
because nothing fundamentally cares about rt->rt_dst any more.  It
can be removed with the base routing cache removal patch.  In fact,
that was the primary goal of this patch series.

Signed-off-by: David S. Miller <davem@davemloft.net>
