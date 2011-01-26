From: David Miller <davem@davemloft.net>
Subject: [PATCH] xfrm6: Don't forget to propagate peer into ipsec route.
Date: Wed, 26 Jan 2011 13:42:45 -0800 (PST)
Message-ID: <20110126.134245.183064022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754140Ab1AZVmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 16:42:11 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E5C2724C088
	for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 13:42:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Like ipv4, we have to propagate the ipv6 route peer into
the ipsec top-level route during instantiation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I noticed this oversight while going back to work on route metrics
COW'ing.  Committed to net-2.6

 net/ipv6/xfrm6_policy.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 7e74023..da87428 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -98,6 +98,10 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	if (!xdst->u.rt6.rt6i_idev)
 		return -ENODEV;
 
+	xdst->u.rt6.rt6i_peer = rt->rt6i_peer;
+	if (rt->rt6i_peer)
+		atomic_inc(&rt->rt6i_peer->refcnt);
+
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
 	xdst->u.rt6.rt6i_flags = rt->rt6i_flags & (RTF_ANYCAST |
@@ -216,6 +220,8 @@ static void xfrm6_dst_destroy(struct dst_entry *dst)
 
 	if (likely(xdst->u.rt6.rt6i_idev))
 		in6_dev_put(xdst->u.rt6.rt6i_idev);
+	if (likely(xdst->u.rt6.rt6i_peer))
+		inet_putpeer(xdst->u.rt6.rt6i_peer);
 	xfrm_dst_destroy(xdst);
 }
 
-- 
1.7.3.4

