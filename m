From: David Miller <davem@davemloft.net>
Subject: [PATCH] inet: Consolidate inetpeer_invalidate_tree() interfaces.
Date: Sat, 09 Jun 2012 16:38:07 -0700 (PDT)
Message-ID: <20120609.163807.1569433425793792216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab2FIXiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 19:38:09 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 6097A583F7D
	for <netdev@vger.kernel.org>; Sat,  9 Jun 2012 16:38:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We only need one interface for this operation, since we always know
which inetpeer root we want to flush.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |    3 +--
 net/ipv4/inetpeer.c    |   10 +---------
 net/ipv4/route.c       |    4 ++--
 net/ipv6/route.c       |    2 +-
 4 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 5a96c8e..733edc6 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -113,8 +113,7 @@ static inline struct inet_peer *inet_getpeer_v6(struct net *net,
 extern void inet_putpeer(struct inet_peer *p);
 extern bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
-extern void __inetpeer_invalidate_tree(struct inet_peer_base *);
-extern void inetpeer_invalidate_tree(struct net *net, int family);
+extern void inetpeer_invalidate_tree(struct inet_peer_base *);
 
 /*
  * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index d0d72f8..9d89a38 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -564,7 +564,7 @@ static void inetpeer_inval_rcu(struct rcu_head *head)
 	schedule_delayed_work(&gc_work, gc_delay);
 }
 
-void __inetpeer_invalidate_tree(struct inet_peer_base *base)
+void inetpeer_invalidate_tree(struct inet_peer_base *base)
 {
 	struct inet_peer *old, *new, *prev;
 
@@ -585,12 +585,4 @@ void __inetpeer_invalidate_tree(struct inet_peer_base *base)
 out:
 	write_sequnlock_bh(&base->lock);
 }
-EXPORT_SYMBOL(__inetpeer_invalidate_tree);
-
-void inetpeer_invalidate_tree(struct net *net, int family)
-{
-	struct inet_peer_base *base = family_to_base(net, family);
-
-	__inetpeer_invalidate_tree(base);
-}
 EXPORT_SYMBOL(inetpeer_invalidate_tree);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4cd35c3..cf78343 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -935,7 +935,7 @@ static void rt_cache_invalidate(struct net *net)
 
 	get_random_bytes(&shuffle, sizeof(shuffle));
 	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
-	inetpeer_invalidate_tree(net, AF_INET);
+	inetpeer_invalidate_tree(net->ipv4.peers);
 }
 
 /*
@@ -3401,7 +3401,7 @@ static void __net_exit ipv4_inetpeer_exit(struct net *net)
 	struct inet_peer_base *bp = net->ipv4.peers;
 
 	net->ipv4.peers = NULL;
-	__inetpeer_invalidate_tree(bp);
+	inetpeer_invalidate_tree(bp);
 	kfree(bp);
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3e1e4e0..7f346d7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3012,7 +3012,7 @@ static void __net_exit ipv6_inetpeer_exit(struct net *net)
 	struct inet_peer_base *bp = net->ipv6.peers;
 
 	net->ipv6.peers = NULL;
-	__inetpeer_invalidate_tree(bp);
+	inetpeer_invalidate_tree(bp);
 	kfree(bp);
 }
 
-- 
1.7.10
