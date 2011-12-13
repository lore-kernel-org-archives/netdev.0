From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv6: If neigh lookup fails during icmp6 dst
 allocation, propagate error.
Date: Tue, 13 Dec 2011 17:38:48 -0500 (EST)
Message-ID: <20111213.173848.752183482333371118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab1LMWiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 17:38:50 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBDMcmIU023093
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 14:38:49 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't just succeed with a route that has a NULL neighbour attached.
This follows the behavior of addrconf_dst_alloc().

Allowing this kind of route to end up with a NULL neigh attached will
result in packet drops on output until the route is somehow
invalidated, since nothing will meanwhile try to lookup the neigh
again.

A statistic is bumped for the case where we see a neigh-less route on
output, but the resulting packet drop is otherwise silent in nature,
and frankly it's a hard error for this to happen and ipv6 should do
what ipv4 does which is say something in the kernel logs.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d98cf41..4bf362b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1089,8 +1089,10 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 		neigh_hold(neigh);
 	else {
 		neigh = __neigh_lookup_errno(&nd_tbl, &fl6->daddr, dev);
-		if (IS_ERR(neigh))
-			neigh = NULL;
+		if (IS_ERR(neigh)) {
+			dst_free(&rt->dst);
+			return ERR_CAST(neigh);
+		}
 	}
 
 	rt->dst.flags |= DST_HOST;
-- 
1.7.7.4
