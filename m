From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/5] ipv6: fib: Convert fib6_age() to dst_neigh_lookup().
Date: Fri, 27 Jan 2012 21:03:40 -0500 (EST)
Message-ID: <20120127.210340.174259351052345262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab2A1CDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 21:03:42 -0500
Received: from localhost (cpe-66-65-56-15.nyc.res.rr.com [66.65.56.15])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0S23f1f009900
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 18:03:42 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In this specific situation we know we are dealing with a gatewayed route
and therefore rt6i_gateway is not going to be in6addr_any even in future
interpretations.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_fib.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index b82bcde..5b27fbc 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1552,11 +1552,20 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 		    time_after_eq(now, rt->dst.lastuse + gc_args.timeout)) {
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
-		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
-			   (!(dst_get_neighbour_noref_raw(&rt->dst)->flags & NTF_ROUTER))) {
-			RT6_TRACE("purging route %p via non-router but gateway\n",
-				  rt);
-			return -1;
+		} else if (rt->rt6i_flags & RTF_GATEWAY) {
+			struct neighbour *neigh;
+			__u8 neigh_flags = 0;
+
+			neigh = dst_neigh_lookup(&rt->dst, &rt->rt6i_gateway);
+			if (neigh) {
+				neigh_flags = neigh->flags;
+				neigh_release(neigh);
+			}
+			if (neigh_flags & NTF_ROUTER) {
+				RT6_TRACE("purging route %p via non-router but gateway\n",
+					  rt);
+				return -1;
+			}
 		}
 		gc_args.more++;
 	}
-- 
1.7.7.5
