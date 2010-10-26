From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Tue, 26 Oct 2010 10:34:28 -0700 (PDT)
Message-ID: <20101026.103428.179941457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.lezcano@free.fr, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754971Ab0JZReF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:34:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Flush the routing cache only of entries that match the
network namespace in which the purge event occurred.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Could I get some testing and performance analysis feedback
on this change?  I don't want it to just die :-)

THanks!

diff --git a/include/net/route.h b/include/net/route.h
index 7e5e73b..8d24761 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -106,7 +106,7 @@ extern int		ip_rt_init(void);
 extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
-extern void		rt_cache_flush_batch(void);
+extern void		rt_cache_flush_batch(struct net *net);
 extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
 extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 36e27c2..828d471 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		rt_cache_flush(dev_net(dev), 0);
 		break;
 	case NETDEV_UNREGISTER_BATCH:
-		rt_cache_flush_batch();
+		rt_cache_flush_batch(dev_net(dev));
 		break;
 	}
 	return NOTIFY_DONE;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d6cb2bf..f6860eb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -712,13 +712,14 @@ static inline int rt_is_expired(struct rtable *rth)
  * Can be called by a softirq or a process.
  * In the later case, we want to be reschedule if necessary
  */
-static void rt_do_flush(int process_context)
+static void rt_do_flush(struct net *net, int process_context)
 {
 	unsigned int i;
 	struct rtable *rth, *next;
-	struct rtable * tail;
 
 	for (i = 0; i <= rt_hash_mask; i++) {
+		struct rtable *list, **pprev;
+
 		if (process_context && need_resched())
 			cond_resched();
 		rth = rt_hash_table[i].chain;
@@ -726,41 +727,28 @@ static void rt_do_flush(int process_context)
 			continue;
 
 		spin_lock_bh(rt_hash_lock_addr(i));
-#ifdef CONFIG_NET_NS
-		{
-		struct rtable ** prev, * p;
 
-		rth = rt_hash_table[i].chain;
+		list = NULL;
+		pprev = &rt_hash_table[i].chain;
+		rth = *pprev;
+		while (rth) {
+			next = rth->dst.rt_next;
+			if (net_eq(dev_net(rth->dst.dev), net)) {
+				*pprev = next;
 
-		/* defer releasing the head of the list after spin_unlock */
-		for (tail = rth; tail; tail = tail->dst.rt_next)
-			if (!rt_is_expired(tail))
-				break;
-		if (rth != tail)
-			rt_hash_table[i].chain = tail;
-
-		/* call rt_free on entries after the tail requiring flush */
-		prev = &rt_hash_table[i].chain;
-		for (p = *prev; p; p = next) {
-			next = p->dst.rt_next;
-			if (!rt_is_expired(p)) {
-				prev = &p->dst.rt_next;
+				rth->dst.rt_next = list;
+				list = rth;
 			} else {
-				*prev = next;
-				rt_free(p);
+				pprev = &rth->dst.rt_next;
 			}
+			rth = next;
 		}
-		}
-#else
-		rth = rt_hash_table[i].chain;
-		rt_hash_table[i].chain = NULL;
-		tail = NULL;
-#endif
+
 		spin_unlock_bh(rt_hash_lock_addr(i));
 
-		for (; rth != tail; rth = next) {
-			next = rth->dst.rt_next;
-			rt_free(rth);
+		for (; list; list = next) {
+			next = list->dst.rt_next;
+			rt_free(list);
 		}
 	}
 }
@@ -906,13 +894,13 @@ void rt_cache_flush(struct net *net, int delay)
 {
 	rt_cache_invalidate(net);
 	if (delay >= 0)
-		rt_do_flush(!in_softirq());
+		rt_do_flush(net, !in_softirq());
 }
 
 /* Flush previous cache invalidated entries from the cache */
-void rt_cache_flush_batch(void)
+void rt_cache_flush_batch(struct net *net)
 {
-	rt_do_flush(!in_softirq());
+	rt_do_flush(net, !in_softirq());
 }
 
 static void rt_emergency_hash_rebuild(struct net *net)
