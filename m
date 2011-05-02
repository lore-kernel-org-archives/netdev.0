From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next-2.6] ipv4: Make sure flowi4->{saddr,daddr} are
 always set.
Date: Mon, 02 May 2011 14:38:19 -0700 (PDT)
Message-ID: <20110502.143819.71100912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932503Ab1EBViv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 17:38:51 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 42B8624C088
	for <netdev@vger.kernel.org>; Mon,  2 May 2011 14:38:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Slow path output route resolution always makes sure that
->{saddr,daddr} are set, and also if we trigger into IPSEC resolution
we initialize them as well, because xfrm_lookup() expects them to be
fully resolved.

But if we hit the fast path and flowi4->flowi4_proto is zero, we won't
do this initialization.

Therefore, move the IPSEC path initialization to the route cache
lookup fast path to make sure these are always set.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 93f71be..64f360d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2675,6 +2675,10 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
+			if (!flp4->saddr)
+				flp4->saddr = rth->rt_src;
+			if (!flp4->daddr)
+				flp4->daddr = rth->rt_dst;
 			return rth;
 		}
 		RT_CACHE_STAT_INC(out_hlist_search);
@@ -2772,15 +2776,10 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 	if (IS_ERR(rt))
 		return rt;
 
-	if (flp4->flowi4_proto) {
-		if (!flp4->saddr)
-			flp4->saddr = rt->rt_src;
-		if (!flp4->daddr)
-			flp4->daddr = rt->rt_dst;
+	if (flp4->flowi4_proto)
 		rt = (struct rtable *) xfrm_lookup(net, &rt->dst,
 						   flowi4_to_flowi(flp4),
 						   sk, 0);
-	}
 
 	return rt;
 }
-- 
1.7.4.5

