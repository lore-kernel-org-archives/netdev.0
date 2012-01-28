From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/5] ipv6: ndisc: Convert to dst_neigh_lookup()
Date: Fri, 27 Jan 2012 21:03:35 -0500 (EST)
Message-ID: <20120127.210335.647690586299704715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab2A1CDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 21:03:37 -0500
Received: from localhost (cpe-66-65-56-15.nyc.res.rr.com [66.65.56.15])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0S23a0f009886
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 18:03:37 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now all code paths grab a local reference to the neigh, so if neigh
is not NULL we unconditionally release it at the end.  The old logic
would only release if we didn't have a non-NULL 'rt'.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ndisc.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d8f02ef..c574ebc 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1223,11 +1223,17 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	rt = rt6_get_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev);
 
-	if (rt)
-		neigh = dst_get_neighbour_noref(&rt->dst);
-
+	if (rt) {
+		neigh = dst_neigh_lookup(&rt->dst, &ipv6_hdr(skb)->saddr);
+		if (!neigh) {
+			ND_PRINTK0(KERN_ERR
+				   "ICMPv6 RA: %s() got default router without neighbour.\n",
+				   __func__);
+			dst_release(&rt->dst);
+			return;
+		}
+	}
 	if (rt && lifetime == 0) {
-		neigh_clone(neigh);
 		ip6_del_rt(rt);
 		rt = NULL;
 	}
@@ -1244,7 +1250,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			return;
 		}
 
-		neigh = dst_get_neighbour_noref(&rt->dst);
+		neigh = dst_neigh_lookup(&rt->dst, &ipv6_hdr(skb)->saddr);
 		if (neigh == NULL) {
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
@@ -1411,7 +1417,7 @@ skip_routeinfo:
 out:
 	if (rt)
 		dst_release(&rt->dst);
-	else if (neigh)
+	if (neigh)
 		neigh_release(neigh);
 }
 
-- 
1.7.7.5
