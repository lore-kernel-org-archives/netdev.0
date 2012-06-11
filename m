From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/5] inet: Add family scope inetpeer flushes.
Date: Mon, 11 Jun 2012 02:29:14 -0700 (PDT)
Message-ID: <20120611.022914.1186235469011169799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab2FKJ3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 05:29:15 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 66E1858426D
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 02:29:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This implementation can deal with having many inetpeer roots, which is
a necessary prerequisite for per-FIB table rooted peer tables.

Each family (AF_INET, AF_INET6) has a sequence number which we bump
when we get a family invalidation request.

Each peer lookup cheaply checks whether the flush sequence of the
root we are using is out of date, and if so flushes it and updates
the sequence number.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |    2 ++
 net/ipv4/inetpeer.c    |   28 ++++++++++++++++++++++++++++
 net/ipv4/route.c       |    2 +-
 3 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index d432489..e15c086 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -68,6 +68,7 @@ struct inet_peer {
 struct inet_peer_base {
 	struct inet_peer __rcu	*root;
 	seqlock_t		lock;
+	u32			flush_seq;
 	int			total;
 };
 
@@ -168,6 +169,7 @@ extern void inet_putpeer(struct inet_peer *p);
 extern bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
 extern void inetpeer_invalidate_tree(struct inet_peer_base *);
+extern void inetpeer_invalidate_family(int family);
 
 /*
  * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index e4cba56..cac02ad 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -86,10 +86,36 @@ void inet_peer_base_init(struct inet_peer_base *bp)
 {
 	bp->root = peer_avl_empty_rcu;
 	seqlock_init(&bp->lock);
+	bp->flush_seq = ~0U;
 	bp->total = 0;
 }
 EXPORT_SYMBOL_GPL(inet_peer_base_init);
 
+static atomic_t v4_seq = ATOMIC_INIT(0);
+static atomic_t v6_seq = ATOMIC_INIT(0);
+
+static atomic_t *inetpeer_seq_ptr(int family)
+{
+	return (family == AF_INET ? &v4_seq : &v6_seq);
+}
+
+static inline void flush_check(struct inet_peer_base *base, int family)
+{
+	atomic_t *fp = inetpeer_seq_ptr(family);
+
+	if (unlikely(base->flush_seq != atomic_read(fp))) {
+		inetpeer_invalidate_tree(base);
+		base->flush_seq = atomic_read(fp);
+	}
+}
+
+void inetpeer_invalidate_family(int family)
+{
+	atomic_t *fp = inetpeer_seq_ptr(family);
+
+	atomic_inc(fp);
+}
+
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
 /* Exported for sysctl_net_ipv4.  */
@@ -437,6 +463,8 @@ struct inet_peer *inet_getpeer(struct inet_peer_base *base,
 	unsigned int sequence;
 	int invalidated, gccnt = 0;
 
+	flush_check(base, daddr->family);
+
 	/* Attempt a lockless lookup first.
 	 * Because of a concurrent writer, we might not find an existing entry.
 	 */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4f5834c..456a947 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -935,7 +935,7 @@ static void rt_cache_invalidate(struct net *net)
 
 	get_random_bytes(&shuffle, sizeof(shuffle));
 	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
-	inetpeer_invalidate_tree(net->ipv4.peers);
+	inetpeer_invalidate_family(AF_INET);
 }
 
 /*
-- 
1.7.10
