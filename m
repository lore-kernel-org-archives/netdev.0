From: David Miller <davem@davemloft.net>
Subject: Re: The mystery of optimistic ipv6 DAD handling
Date: Tue, 27 Dec 2011 14:53:05 -0500 (EST)
Message-ID: <20111227.145305.229364634255751368.davem@davemloft.net>
References: <20111227.140652.1729386263761283235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab1L0TyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 14:54:14 -0500
In-Reply-To: <20111227.140652.1729386263761283235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 27 Dec 2011 14:06:52 -0500 (EST)

> However, two things strike me:
> 
> 1) even beforehand we'd only get a NULL neigh when the device pointer
>    is NULL, that can't happen here, rt->rt6i_dev will be non-NULL always
>    in these circumstances, it's forced to be net->loopback_dev by the
>    ip6_dst_alloc() call made by addrconf_dst_alloc() (the code back
>    in 2.6.21 does the same exact thing, just inline)
> 
> 2) on top of that it's looking up a neighbour using rt->rt6i_gateway
>    as the key, that's either bogus or pointless.  As far as I can tell
>    it's uninitialized at this point and therefore always all-zeros.
> 
> My quick hunch is that the neigh should be looked up based upon 'addr', and
> that ipv6_add_addr() should test if the neigh is resolved in order to determine
> if the optimistic flag should be cleared.  That matches the logic in the comment
> "do not yet know the link layer address of our nexthop router."
> 
> Neil, any chance you can help me unravel this?

So the fundamental thing is that these addrconf routes are mainly for
for input and looping back traffic on output.

We create the addrconf route "to us", for input.  That's why the lookup
key is the ipv6 address we are configuring on the interface.

For output, the neigh is "don't care".  It goes to the loopback device
and for loopback ->hard_header is NULL so
net/ipv6/ndisc.c:ndisc_constructor() directly hooks up
neigh->ops->queue_xmit as the neigh->output method, which is
dev_queue_xmit().  So it doesn't matter that we lookup the neigh in
addrconf_dst_alloc() using the all-zeros rt->rt6i_gateway.

So this route and it's neigh have nothing to do with link layer
address of any nexthop gatway(s) in this interface.

Therefore the test is completely wrong, and all I can determine is
that we should flat out remove it.  It never triggers anyways.

Perhaps we should find another appropriate spot to put this kind of
test, but in this spot and against this route object seems totally not
right.

Neil, what say you?

--------------------
ipv6: Remove optimistic DAD flag test in ipv6_add_addr()

The route we have here is for the address being added to the interface,
ie. for input packet processing.

Therefore using that route to determine whether an output nexthop gateway
is known and resolved doesn't make any sense.

So, simply remove this test, it never triggered anyways.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 59a9d0e..85421cc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -650,16 +650,6 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 
 	ifa->rt = rt;
 
-	/*
-	 * part one of RFC 4429, section 3.3
-	 * We should not configure an address as
-	 * optimistic if we do not yet know the link
-	 * layer address of our nexhop router
-	 */
-
-	if (dst_get_neighbour_noref_raw(&rt->dst) == NULL)
-		ifa->flags &= ~IFA_F_OPTIMISTIC;
-
 	ifa->idev = idev;
 	in6_dev_hold(idev);
 	/* For caller */
