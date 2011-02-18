From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/7] ipv4: Move rcu_read_{lock,unlock}() into
 ip_route_output_slow().
Date: Thu, 17 Feb 2011 16:11:59 -0800 (PST)
Message-ID: <20110217.161159.68144325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57118
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752840Ab1BRALX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:11:23 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B235224C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:11:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Simplifies tail of __ip_route_output_key().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 849be48..b2b3c9e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2456,6 +2456,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 	res.r		= NULL;
 #endif
 
+	rcu_read_lock();
 	if (oldflp->fl4_src) {
 		err = -EINVAL;
 		if (ipv4_is_multicast(oldflp->fl4_src) ||
@@ -2617,15 +2618,16 @@ make_route:
 		err = rt_intern_hash(hash, rth, rp, NULL, oldflp->oif);
 	}
 
-out:	return err;
+out:
+	rcu_read_unlock();
+	return err;
 }
 
 int __ip_route_output_key(struct net *net, struct rtable **rp,
 			  const struct flowi *flp)
 {
-	unsigned int hash;
-	int res;
 	struct rtable *rth;
+	unsigned int hash;
 
 	if (!rt_caching(net))
 		goto slow_output;
@@ -2655,10 +2657,7 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 	rcu_read_unlock_bh();
 
 slow_output:
-	rcu_read_lock();
-	res = ip_route_output_slow(net, rp, flp);
-	rcu_read_unlock();
-	return res;
+	return ip_route_output_slow(net, rp, flp);
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
-- 
1.7.4.1

