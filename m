From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 3/3] ipv4: Set DST_NOCACHE in rt_dst_alloc().
Date: Thu, 17 Feb 2011 16:34:22 -0800 (PST)
Message-ID: <20110217.163422.45885117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757784Ab1BRAdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:33:45 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4AE6D24C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:34:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of using a read/modify/write in rt_finalize().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 488094d..01b27ff 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -500,11 +500,6 @@ static int rt_garbage_collect(struct dst_ops *ops)
 
 static int rt_finalize(struct rtable *rt, struct rtable **rp, struct sk_buff *skb)
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

