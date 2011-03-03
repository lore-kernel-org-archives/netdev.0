From: David Miller <davem@davemloft.net>
Subject: [v3 RFC PATCH 3/8] ipv4: Set DST_NOCACHE in rt_dst_alloc().
Date: Wed, 02 Mar 2011 17:01:59 -0800 (PST)
Message-ID: <20110302.170159.27813493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48856
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754713Ab1CCBBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 20:01:22 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9416E24C087
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 17:01:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of using a read/modify/write in rt_finalize().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index dac8adc..efefefa 100644
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
@@ -1103,7 +1098,11 @@ static struct rtable *rt_dst_alloc(bool nopolicy, bool noxfrm)
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

