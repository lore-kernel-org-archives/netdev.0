From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH stable 3.4 2/2] ipv4: avoid parallel route cache gc executions
Date: Mon, 11 Aug 2014 19:41:06 -0300
Message-ID: <ffd56913c060fc717a74b87ba1a154125c9db2c4.1407796232.git.mleitner@redhat.com>
References: <fc0168a71c064457c18f2563371176380d0012c7.1407796232.git.mleitner@redhat.com>
Cc: hannes@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716AbaHKWlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 18:41:39 -0400
In-Reply-To: <fc0168a71c064457c18f2563371176380d0012c7.1407796232.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rt_intern_hash() has to deal with neighbour cache overflowing,
it triggers the route cache garbage collector in an attempt to free
some references on neighbour entries.

Such call cannot be done async but should also not run in parallel with
an already-running one, so that they don't collapse fighting over the
hash lock entries.

This patch thus blocks parallel executions by ignoring the call if
garbage collector is already running on another CPU.

We don't use a spinlock for it because now it runs on a work queue and
we want it to be schedulable in-between the hash indexes.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: Hannes Frederic Sowa <hannes@redhat.com>
---
 net/ipv4/route.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2ad1cdb2c9e45f5ec5a6c1fa9b781657b1c292ec..68153bb86b62b500febd2a134f71348fa78295d9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -986,6 +986,7 @@ static void __do_rt_garbage_collect(int elasticity, int min_interval)
 	static unsigned long last_gc;
 	static int rover;
 	static int equilibrium;
+	static int rt_gc_barrier;
 	struct rtable *rth;
 	struct rtable __rcu **rthp;
 	unsigned long now = jiffies;
@@ -999,6 +1000,12 @@ static void __do_rt_garbage_collect(int elasticity, int min_interval)
 
 	RT_CACHE_STAT_INC(gc_total);
 
+	if (cmpxchg(&rt_gc_barrier, 0, 1) != 0) {
+		/* busy */
+		RT_CACHE_STAT_INC(gc_ignored);
+		return;
+	}
+
 	if (now - last_gc < min_interval &&
 	    entries < ip_rt_max_size) {
 		RT_CACHE_STAT_INC(gc_ignored);
@@ -1089,6 +1096,7 @@ static void __do_rt_garbage_collect(int elasticity, int min_interval)
 	if (net_ratelimit())
 		pr_warn("dst cache overflow\n");
 	RT_CACHE_STAT_INC(gc_dst_overflow);
+	rt_gc_barrier = 0;
 	return;
 
 work_done:
@@ -1097,7 +1105,9 @@ work_done:
 	    dst_entries_get_fast(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh ||
 	    dst_entries_get_slow(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh)
 		expire = ip_rt_gc_timeout;
-out:	return;
+out:
+	rt_gc_barrier = 0;
+	return;
 }
 
 static void __rt_garbage_collect(struct work_struct *w)
-- 
1.9.3
