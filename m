From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH stable 3.4 v2 2/2] ipv4: avoid parallel route cache gc executions
Date: Thu, 14 Aug 2014 16:44:53 -0300
Message-ID: <973a161edcf9df5d4fcc0e6382c916c6f2458c3b.1408045325.git.mleitner@redhat.com>
References: <547688b69ee9a258cc04e4dad17a90ca6ab182d0.1408045325.git.mleitner@redhat.com>
Cc: hannes@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752402AbaHNTpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 15:45:05 -0400
In-Reply-To: <547688b69ee9a258cc04e4dad17a90ca6ab182d0.1408045325.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rt_intern_hash() has to deal with neighbour cache overflowing,
it triggers the route cache garbage collector in an attempt to free
some references on neighbour entries.

Such call cannot be done async but should also not run in parallel with
an already-running one, so that they don't collapse fighting over the
hash lock entries.

This patch thus blocks parallel executions with spinlocks:
- A call from worker and from rt_intern_hash() are not the same, and
cannot be merged, thus they will wait each other on rt_gc_lock.
- Calls to gc from rt_intern_hash() may happen in parallel but we must
wait for it to finish in order to try again. This dedup and
synchrinozation is then performed by the locking just before calling
__do_rt_garbage_collect().

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Notes:
    v1->v2:
    Addressed David Miller's concern on making rt_intern_hash fail if the
    neighbour cache is full and the async gc is running at that time.
    
    With this patch it will now wait for the async run and then perform the
    aggressive one (with the special parameters) before retrying.

 net/ipv4/route.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9017f2f8aff196b665fc7d4e36116bfda7450011..2389c444f02c753b2e6fea53e76a957adcdafd85 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -986,6 +986,7 @@ static void __do_rt_garbage_collect(int elasticity, int min_interval)
 	static unsigned long last_gc;
 	static int rover;
 	static int equilibrium;
+	static DEFINE_SPINLOCK(rt_gc_lock);
 	struct rtable *rth;
 	struct rtable __rcu **rthp;
 	unsigned long now = jiffies;
@@ -997,6 +998,8 @@ static void __do_rt_garbage_collect(int elasticity, int min_interval)
 	 * do not make it too frequently.
 	 */
 
+	spin_lock(&rt_gc_lock);
+
 	RT_CACHE_STAT_INC(gc_total);
 
 	if (now - last_gc < min_interval &&
@@ -1089,7 +1092,7 @@ static void __do_rt_garbage_collect(int elasticity, int min_interval)
 	if (net_ratelimit())
 		pr_warn("dst cache overflow\n");
 	RT_CACHE_STAT_INC(gc_dst_overflow);
-	return;
+	goto out;
 
 work_done:
 	expire += min_interval;
@@ -1097,7 +1100,8 @@ work_done:
 	    dst_entries_get_fast(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh ||
 	    dst_entries_get_slow(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh)
 		expire = ip_rt_gc_timeout;
-out:	return;
+out:
+	spin_unlock(&rt_gc_lock);
 }
 
 static void __rt_garbage_collect(struct work_struct *w)
@@ -1172,7 +1176,7 @@ static struct rtable *rt_intern_hash(unsigned hash, struct rtable *rt,
 	unsigned long	now;
 	u32 		min_score;
 	int		chain_length;
-	int attempts = !in_softirq();
+	int attempts = 1;
 
 restart:
 	chain_length = 0;
@@ -1308,8 +1312,15 @@ restart:
 			   can be released. Try to shrink route cache,
 			   it is most likely it holds some neighbour records.
 			 */
-			if (attempts-- > 0) {
-				__do_rt_garbage_collect(1, 0);
+			if (!in_softirq() && attempts-- > 0) {
+				static DEFINE_SPINLOCK(lock);
+
+				if (spin_trylock(&lock)) {
+					__do_rt_garbage_collect(1, 0);
+					spin_unlock(&lock);
+				} else {
+					spin_unlock_wait(&lock);
+				}
 				goto restart;
 			}
 
-- 
1.9.3
