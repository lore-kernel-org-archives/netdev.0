From: David Miller <davem@davemloft.net>
Subject: [PATCH v4 RFC 3/8] ipv4: Set DST_NOCACHE in rt_dst_alloc().
Date: Sat, 12 Mar 2011 16:36:28 -0800 (PST)
Message-ID: <20110312.163628.241930412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55595
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756243Ab1CMAfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 19:35:50 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 32B1724C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 16:36:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of using a read/modify/write in rt_finalize().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7e8720f..6036476 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -492,11 +492,6 @@ void rt_cache_flush(struct net *net, int delay)
 
 static struct rtable *rt_finalize(struct rtable *rt, struct sk_buff *skb)
 {
-	/* To avoid expensive rcu stuff for this uncached dst, we set
-	 * DST_NOCACHE so that dst_release() can free dst without
-	 * waiting a grace period.
-	 */
-	rt->dst.flags |= DST_NOCACHE;
 	if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
 		int err = arp_bind_neighbour(&rt->dst);
 		if (err) {
@@ -1114,7 +1109,11 @@ static struct rtable *rt_dst_alloc(bool nopolicy, bool noxfrm)
 	if (rt) {
 		rt->dst.obsolete = -1;
 
-		rt->dst.flags = DST_HOST |
+		/* To avoid expensive rcu stuff for this uncached dst, we set
+		 * DST_NOCACHE so that dst_release() can free dst without
+		 * waiting a grace period.
+		 */
+		rt->dst.flags = DST_NOCACHE | DST_HOST |
 			(nopolicy ? DST_NOPOLICY : 0) |
 			(noxfrm ? DST_NOXFRM : 0);
 	}
-- 
1.7.4.1

