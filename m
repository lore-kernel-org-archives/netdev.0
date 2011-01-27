From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Remove route peer binding assertions.
Date: Thu, 27 Jan 2011 14:56:14 -0800 (PST)
Message-ID: <20110127.145614.102546057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753802Ab1A0Wzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:55:39 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 59CDB24C089
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 14:56:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They are bogus.  The basic idea is that I wanted to make sure
that prefixed routes never bind to peers.

The test I used was whether RTF_CACHE was set.

But first of all, the RTF_CACHE flag is set at different spots
depending upon which ip6_rt_copy() caller you're talking about.

I've validated all of the code paths, and even in the future
where we bind peers more aggressively (for route metric COW'ing)
we never bind to prefix'd routes, only fully specified ones.
This even applies when addrconf or icmp6 routes are allocated.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I ran into, and dissected this, while working on the inetpeer
metrics changes.  Committed to net-2.6

 net/ipv6/route.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1534508..28a85fc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -194,7 +194,6 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 		in6_dev_put(idev);
 	}
 	if (peer) {
-		BUG_ON(!(rt->rt6i_flags & RTF_CACHE));
 		rt->rt6i_peer = NULL;
 		inet_putpeer(peer);
 	}
@@ -204,9 +203,6 @@ void rt6_bind_peer(struct rt6_info *rt, int create)
 {
 	struct inet_peer *peer;
 
-	if (WARN_ON(!(rt->rt6i_flags & RTF_CACHE)))
-		return;
-
 	peer = inet_getpeer_v6(&rt->rt6i_dst.addr, create);
 	if (peer && cmpxchg(&rt->rt6i_peer, NULL, peer) != NULL)
 		inet_putpeer(peer);
-- 
1.7.3.4

