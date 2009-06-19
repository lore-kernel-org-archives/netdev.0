From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] fix NULL pointer + success return in route lookup path
Date: Fri, 19 Jun 2009 13:18:14 -0400
Message-ID: <20090619171814.GE18237@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mbizon@freebox.fr, dada1@cosmosbay.com, kuznet@ms2.inr.ac.ru,
	davem@davemloft.net, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39111 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbZFSRS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 13:18:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't drop route if we're not caching	

	I recently got a report of an oops on a route lookup.  Maxime was
testing what would happen if route caching was turned off (doing so by setting
making rt_caching always return 0), and found that it triggered an oops.  I
looked at it and found that the problem stemmed from the fact that the route
lookup routines were returning success from their lookup paths (which is good),
but never set the **rp pointer to anything (which is bad).  This happens because
in rt_intern_hash, if rt_caching returns false, we call rt_drop and return 0.
This almost emulates slient success.  What we should be doing is assigning *rp =
rt and _not_ dropping the route.  This way, during slow path lookups, when we
create a new route cache entry, we don't immediately discard it, rather we just
don't add it into the cache hash table, but we let this one lookup use it for
the purpose of this route request.  Maxime has tested and reports it prevents
the oops.  There is still a subsequent routing issue that I'm looking into
further, but I'm confident that, even if its related to this same path, this
patch makes sense to take.

Regards
Neil
    
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 route.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cd76b3c..65b3a8b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1085,8 +1085,16 @@ restart:
 	now = jiffies;
 
 	if (!rt_caching(dev_net(rt->u.dst.dev))) {
-		rt_drop(rt);
-		return 0;
+		/*
+		 * If we're not caching, just tell the caller we
+		 * were successful and don't touch the route.  The
+		 * caller hold the sole reference to the cache entry, and
+		 * it will be released when the caller is done with it.
+		 * If we drop it here, the callers have no way to resolve routes
+		 * when we're not caching.  Instead, just point *rp at rt, so
+		 * the caller gets a single use out of the route
+		 */
+		goto report_and_exit;
 	}
 
 	rthp = &rt_hash_table[hash].chain;
@@ -1217,6 +1225,8 @@ restart:
 	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
 
 	spin_unlock_bh(rt_hash_lock_addr(hash));
+
+report_and_exit:
 	if (rp)
 		*rp = rt;
 	else
