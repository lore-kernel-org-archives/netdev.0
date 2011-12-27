From: David Miller <davem@davemloft.net>
Subject: The mystery of optimistic ipv6 DAD handling
Date: Tue, 27 Dec 2011 14:06:52 -0500 (EST)
Message-ID: <20111227.140652.1729386263761283235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab1L0TIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 14:08:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This afternoon I audited the neigh attachment logic for ipv6 routes
and found the following gem.

Since the beginning the optimistic DAD support has this code in
ipv6_add_addr():

	/*
	 * part one of RFC 4429, section 3.3
	 * We should not configure an address as
	 * optimistic if we do not yet know the link
	 * layer address of our nexhop router
	 */

	if (dst_get_neighbour_noref_raw(&rt->dst) == NULL)
		ifa->flags &= ~IFA_F_OPTIMISTIC;

(back at inclusion time the test was "rt->rt6i_nexthop == NULL" which
 is the same, we're just hiding it behind a function now so we can
 change the implementation)

But this is never, ever, true.

addrconf_dst_alloc() will never give you a route with a NULL neighbour.

If the neigh lookup fails, it puts the route and returns a pointer error:

	neigh = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, rt->rt6i_dev);
	if (IS_ERR(neigh)) {
		dst_free(&rt->dst);

		return ERR_CAST(neigh);
	}
	dst_set_neighbour(&rt->dst, neigh);

I verified that back in 2.6.21 when the optimistic DAD code went in,
this same logic was present:

	rt->rt6i_nexthop = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
	if (rt->rt6i_nexthop == NULL) {
		dst_free(&rt->u.dst);
		return ERR_PTR(-ENOMEM);
	}

But there's a catch, ndisc_get_neigh() has changed over the years, it used to:

static inline struct neighbour * ndisc_get_neigh(struct net_device *dev, struct in6_addr *addr)                                   
{                                                                                                                                 
                                                                                                                                  
        if (dev)                                                                                                                  
                return __neigh_lookup(&nd_tbl, addr, dev, 1);                                                                     
                                                                                                                                  
        return NULL;                                                                                                              
}                                                                                                                                 

but then it was changed to say:

--------------------
 	if (dev)
-		return __neigh_lookup(&nd_tbl, addr, dev, 1);
+		return __neigh_lookup_errno(&nd_tbl, addr, dev);
 
-	return NULL;
+	return ERR_PTR(-ENODEV);
--------------------

in order to fix a DoS type scenerio where the neighbour cache could quickly fill up,
this is commit:

--------------------
commit 14deae41566b5cdd992c01d0069518ced5227c83
Author: David S. Miller <davem@davemloft.net>
Date:   Sun Jan 4 16:04:39 2009 -0800

    ipv6: Fix sporadic sendmsg -EINVAL when sending to multicast groups.
--------------------

Obviously, this could change the optimistic DaD logic.  However, two things strike me:

1) even beforehand we'd only get a NULL neigh when the device pointer
   is NULL, that can't happen here, rt->rt6i_dev will be non-NULL always
   in these circumstances, it's forced to be net->loopback_dev by the
   ip6_dst_alloc() call made by addrconf_dst_alloc() (the code back
   in 2.6.21 does the same exact thing, just inline)

2) on top of that it's looking up a neighbour using rt->rt6i_gateway
   as the key, that's either bogus or pointless.  As far as I can tell
   it's uninitialized at this point and therefore always all-zeros.

My quick hunch is that the neigh should be looked up based upon 'addr', and
that ipv6_add_addr() should test if the neigh is resolved in order to determine
if the optimistic flag should be cleared.  That matches the logic in the comment
"do not yet know the link layer address of our nexthop router."

Neil, any chance you can help me unravel this?

Thanks.
