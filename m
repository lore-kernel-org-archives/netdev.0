From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: init_timer_deferrable conversion
Date: Mon, 17 Dec 2007 15:29:43 +0100
Message-ID: <20071217152943.10470215.dada1@cosmosbay.com>
References: <Pine.LNX.4.64.0712162149220.4622@mini.warudkars.net>
	<20071217095504.b02241ee.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "parag.warudkar@gmail.com" <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:38456 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752231AbXLQO3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 09:29:47 -0500
In-Reply-To: <20071217095504.b02241ee.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Dec 2007 09:55:04 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> On Sun, 16 Dec 2007 22:00:23 -0500 (EST)
> Parag Warudkar <parag.warudkar@gmail.com> wrote:
> 
> > In my quest to get the wake-ups from idle per second down to bare minimum, 
> > I noticed 3 places in the kernel that could benefit from 
> > using init_timer_deferrable() instead of init_timer() -
> > 
> > a) drivers/net/sky2.c - watchdog_timer. This was showing up high on 
> > Powertop's list of things that cause routine wakeups from idle. After 
> > converting to init_timer_deferrable() the wakeups went down and this one 
> > no longer shows up in powertop's list. 25% reduction.
> > 
> > b) kernel/time/clocksource.c - watchdog_timer - same story as sky2.c
> > 
> > c) net/core/neighbour.c - gc_timer - Most benefit from deferrable timer.
> 
> neigh_periodic_timer() is actually doing almost nothing per round, since it
> looks only one slot of hash table. We could probably convert it to a
> workqueue and scan whole table at once.
> 

Parag, could you please try this patch ?

[NET] ARP : Convert neigh garbage collection from softirq to workqueue

Current neigh_periodic_timer() function is fired by timer IRQ, and
scans one hash bucket out of a potentially big number.

As we are supposed to scan whole hash table in 15 seconds, this means
neigh_periodic_timer() can be fired very often. (depending on the number
of concurrent hash entries we stored in this table)

Converting this to a workqueue permits scaning whole table, minimizing icache
pollution, and firing this work every 15 seconds, independantly of hash table
size.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 include/net/neighbour.h |    4 -
 net/core/neighbour.c    |   89 ++++++++++++++++++--------------------
 2 files changed, 45 insertions(+), 48 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index a4f2618..fdb9251 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -24,6 +24,7 @@
 
 #include <linux/err.h>
 #include <linux/sysctl.h>
+#include <linux/workqueue.h>
 #include <net/rtnetlink.h>
 
 #define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_REACHABLE|NUD_DELAY|NUD_PROBE)
@@ -155,7 +156,7 @@ struct neigh_table
 	int			gc_thresh2;
 	int			gc_thresh3;
 	unsigned long		last_flush;
-	struct timer_list 	gc_timer;
+	struct delayed_work	gc_work;
 	struct timer_list 	proxy_timer;
 	struct sk_buff_head	proxy_queue;
 	atomic_t		entries;
@@ -166,7 +167,6 @@ struct neigh_table
 	struct neighbour	**hash_buckets;
 	unsigned int		hash_mask;
 	__u32			hash_rnd;
-	unsigned int		hash_chain_gc;
 	struct pneigh_entry	**phash_buckets;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry	*pde;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 4b6dd1e..495ab19 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -637,75 +637,74 @@ static void neigh_connect(struct neighbour *neigh)
 		hh->hh_output = neigh->ops->hh_output;
 }
 
-static void neigh_periodic_timer(unsigned long arg)
+static void neigh_periodic_work(struct work_struct *work)
 {
-	struct neigh_table *tbl = (struct neigh_table *)arg;
+	struct neigh_table *tbl = container_of(work, struct neigh_table, gc_work.work);
 	struct neighbour *n, **np;
-	unsigned long expire, now = jiffies;
+	unsigned int i;
 
 	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
 
-	write_lock(&tbl->lock);
+	write_lock_bh(&tbl->lock);
 
 	/*
 	 *	periodically recompute ReachableTime from random function
 	 */
 
-	if (time_after(now, tbl->last_rand + 300 * HZ)) {
+	if (time_after(jiffies, tbl->last_rand + 300 * HZ)) {
 		struct neigh_parms *p;
-		tbl->last_rand = now;
+		tbl->last_rand = jiffies;
 		for (p = &tbl->parms; p; p = p->next)
 			p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
 	}
 
-	np = &tbl->hash_buckets[tbl->hash_chain_gc];
-	tbl->hash_chain_gc = ((tbl->hash_chain_gc + 1) & tbl->hash_mask);
+	for (i = 0 ; i <= tbl->hash_mask; i++) {
+		np = &tbl->hash_buckets[i];
 
-	while ((n = *np) != NULL) {
-		unsigned int state;
+		while ((n = *np) != NULL) {
+			unsigned int state;
 
-		write_lock(&n->lock);
+			write_lock(&n->lock);
 
-		state = n->nud_state;
-		if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
-			write_unlock(&n->lock);
-			goto next_elt;
-		}
+			state = n->nud_state;
+			if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
+				write_unlock(&n->lock);
+				goto next_elt;
+			}
 
-		if (time_before(n->used, n->confirmed))
-			n->used = n->confirmed;
+			if (time_before(n->used, n->confirmed))
+				n->used = n->confirmed;
 
-		if (atomic_read(&n->refcnt) == 1 &&
-		    (state == NUD_FAILED ||
-		     time_after(now, n->used + n->parms->gc_staletime))) {
-			*np = n->next;
-			n->dead = 1;
+			if (atomic_read(&n->refcnt) == 1 &&
+			    (state == NUD_FAILED ||
+			     time_after(jiffies, n->used + n->parms->gc_staletime))) {
+				*np = n->next;
+				n->dead = 1;
+				write_unlock(&n->lock);
+				neigh_cleanup_and_release(n);
+				continue;
+			}
 			write_unlock(&n->lock);
-			neigh_cleanup_and_release(n);
-			continue;
-		}
-		write_unlock(&n->lock);
 
 next_elt:
-		np = &n->next;
+			np = &n->next;
+		}
+		/*
+		 * It's fine to release lock here, even if hash table
+		 * grows while we are preempted.
+		 */
+		write_unlock_bh(&tbl->lock);
+		cond_resched();
+		write_lock_bh(&tbl->lock);
 	}
-
 	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
 	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
 	 * base_reachable_time.
 	 */
-	expire = tbl->parms.base_reachable_time >> 1;
-	expire /= (tbl->hash_mask + 1);
-	if (!expire)
-		expire = 1;
-
-	if (expire>HZ)
-		mod_timer(&tbl->gc_timer, round_jiffies(now + expire));
-	else
-		mod_timer(&tbl->gc_timer, now + expire);
-
-	write_unlock(&tbl->lock);
+	schedule_delayed_work(&tbl->gc_work,
+			      tbl->parms.base_reachable_time >> 1);
+	write_unlock_bh(&tbl->lock);
 }
 
 static __inline__ int neigh_max_probes(struct neighbour *n)
@@ -1370,10 +1369,8 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
 
 	rwlock_init(&tbl->lock);
-	setup_timer(&tbl->gc_timer, neigh_periodic_timer, (unsigned long)tbl);
-	tbl->gc_timer.expires  = now + 1;
-	add_timer(&tbl->gc_timer);
-
+	INIT_DELAYED_WORK_DEFERRABLE(&tbl->gc_work, neigh_periodic_work);
+	schedule_delayed_work(&tbl->gc_work, tbl->parms.reachable_time);
 	setup_timer(&tbl->proxy_timer, neigh_proxy_process, (unsigned long)tbl);
 	skb_queue_head_init_class(&tbl->proxy_queue,
 			&neigh_table_proxy_queue_class);
@@ -1408,7 +1405,8 @@ int neigh_table_clear(struct neigh_table *tbl)
 	struct neigh_table **tp;
 
 	/* It is not clean... Fix it to unload IPv6 module safely */
-	del_timer_sync(&tbl->gc_timer);
+	cancel_delayed_work(&tbl->gc_work);
+	flush_scheduled_work();
 	del_timer_sync(&tbl->proxy_timer);
 	pneigh_queue_purge(&tbl->proxy_queue);
 	neigh_ifdown(tbl, NULL);
@@ -1678,7 +1676,6 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 			.ndtc_last_rand		= jiffies_to_msecs(rand_delta),
 			.ndtc_hash_rnd		= tbl->hash_rnd,
 			.ndtc_hash_mask		= tbl->hash_mask,
-			.ndtc_hash_chain_gc	= tbl->hash_chain_gc,
 			.ndtc_proxy_qlen	= tbl->proxy_queue.qlen,
 		};
 
