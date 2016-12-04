From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] net_sched: gen_estimator: complete rewrite of
 rate estimators
Date: Sun, 04 Dec 2016 09:48:16 -0800
Message-ID: <1480873696.18162.470.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480835273.18162.457.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480835882.18162.462.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1480835882.18162.462.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

1) Old code was hard to maintain, due to complex lock chains.
   (We probably will be able to remove some kfree_rcu() in callers)

2) Using a single timer to update all estimators does not scale.

3) Code was buggy on 32bit kernel (WRITE_ONCE() on 64bit quantity
   is not supposed to work well)

In this rewrite :

- I removed the RB tree that had to be scanned in
  gen_estimator_active(). qdisc dumps should be much faster.

- Each estimator has its own timer.

- Estimations are maintained in net_rate_estimator structure,
  instead of dirtying the qdisc. Minor, but part of the simplification.

- Reading the estimator uses RCU and a seqcount to provide proper
  support for 32bit kernels.

- We reduce memory need when estimators are not used, since
  we store a pointer, instead of the bytes/packets counters.

- xt_rateest_mt() no longer has to grab a spinlock.
  (In the future, xt_rateest_tg() could be switched to per cpu counters)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v3: Renamed some parameters to please make htmldocs
v2: Removed unwanted changes to tcp_output.c

 include/net/act_api.h              |    2 
 include/net/gen_stats.h            |   17 -
 include/net/netfilter/xt_rateest.h |   10 
 include/net/sch_generic.h          |    2 
 net/core/gen_estimator.c           |  299 +++++++++------------------
 net/core/gen_stats.c               |   20 -
 net/netfilter/xt_RATEEST.c         |    4 
 net/netfilter/xt_rateest.c         |   28 +-
 net/sched/act_api.c                |    9 
 net/sched/act_police.c             |   21 +
 net/sched/sch_api.c                |    2 
 net/sched/sch_cbq.c                |    6 
 net/sched/sch_drr.c                |    6 
 net/sched/sch_generic.c            |    2 
 net/sched/sch_hfsc.c               |    6 
 net/sched/sch_htb.c                |    6 
 net/sched/sch_qfq.c                |    8 
 17 files changed, 182 insertions(+), 266 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 9dddf77a69ccbcb003cfa66bcc0de337f78f3dae..1d716449209e4753a297c61a287077a1eb96e6d8 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -36,7 +36,7 @@ struct tc_action {
 	struct tcf_t			tcfa_tm;
 	struct gnet_stats_basic_packed	tcfa_bstats;
 	struct gnet_stats_queue		tcfa_qstats;
-	struct gnet_stats_rate_est64	tcfa_rate_est;
+	struct net_rate_estimator __rcu *tcfa_rate_est;
 	spinlock_t			tcfa_lock;
 	struct rcu_head			tcfa_rcu;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index 231e121cc7d9c72075e7e6dde3655d631f64a1c4..8b7aa370e7a4af61fcb71ed751dba72ebead6143 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -11,6 +11,8 @@ struct gnet_stats_basic_cpu {
 	struct u64_stats_sync syncp;
 };
 
+struct net_rate_estimator;
+
 struct gnet_dump {
 	spinlock_t *      lock;
 	struct sk_buff *  skb;
@@ -42,8 +44,7 @@ void __gnet_stats_copy_basic(const seqcount_t *running,
 			     struct gnet_stats_basic_cpu __percpu *cpu,
 			     struct gnet_stats_basic_packed *b);
 int gnet_stats_copy_rate_est(struct gnet_dump *d,
-			     const struct gnet_stats_basic_packed *b,
-			     struct gnet_stats_rate_est64 *r);
+			     struct net_rate_estimator __rcu **ptr);
 int gnet_stats_copy_queue(struct gnet_dump *d,
 			  struct gnet_stats_queue __percpu *cpu_q,
 			  struct gnet_stats_queue *q, __u32 qlen);
@@ -53,16 +54,16 @@ int gnet_stats_finish_copy(struct gnet_dump *d);
 
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 		      struct gnet_stats_basic_cpu __percpu *cpu_bstats,
-		      struct gnet_stats_rate_est64 *rate_est,
+		      struct net_rate_estimator __rcu **rate_est,
 		      spinlock_t *stats_lock,
 		      seqcount_t *running, struct nlattr *opt);
-void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
-			struct gnet_stats_rate_est64 *rate_est);
+void gen_kill_estimator(struct net_rate_estimator __rcu **ptr);
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
 			  struct gnet_stats_basic_cpu __percpu *cpu_bstats,
-			  struct gnet_stats_rate_est64 *rate_est,
+			  struct net_rate_estimator __rcu **ptr,
 			  spinlock_t *stats_lock,
 			  seqcount_t *running, struct nlattr *opt);
-bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
-			  const struct gnet_stats_rate_est64 *rate_est);
+bool gen_estimator_active(struct net_rate_estimator __rcu **ptr);
+bool gen_estimator_read(struct net_rate_estimator __rcu **ptr,
+			struct gnet_stats_rate_est64 *sample);
 #endif
diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilter/xt_rateest.h
index 79f45e19f31eaa54deb8437ef4b883bec78def84..130e58361f998ecdf361910b196e69778224d955 100644
--- a/include/net/netfilter/xt_rateest.h
+++ b/include/net/netfilter/xt_rateest.h
@@ -1,19 +1,23 @@
 #ifndef _XT_RATEEST_H
 #define _XT_RATEEST_H
 
+#include <net/gen_stats.h>
+
 struct xt_rateest {
 	/* keep lock and bstats on same cache line to speedup xt_rateest_tg() */
 	struct gnet_stats_basic_packed	bstats;
 	spinlock_t			lock;
-	/* keep rstats and lock on same cache line to speedup xt_rateest_mt() */
-	struct gnet_stats_rate_est64	rstats;
+
 
 	/* following fields not accessed in hot path */
+	unsigned int			refcnt;
 	struct hlist_node		list;
 	char				name[IFNAMSIZ];
-	unsigned int			refcnt;
 	struct gnet_estimator		params;
 	struct rcu_head			rcu;
+
+	/* keep this field far away to speedup xt_rateest_mt() */
+	struct net_rate_estimator __rcu *rate_est;
 };
 
 struct xt_rateest *xt_rateest_lookup(const char *name);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e6aa0a249672a802dce583166f4f808154b77a96..498f81b229a4565e140f1a054ce931e80361e8b2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -76,7 +76,7 @@ struct Qdisc {
 
 	struct netdev_queue	*dev_queue;
 
-	struct gnet_stats_rate_est64	rate_est;
+	struct net_rate_estimator __rcu *rate_est;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue	__percpu *cpu_qstats;
 
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 0993844faeeaefb221ea619fd9d796600b82fbb9..101b5d0e2142e6a813f6b524a59945379f02bcb3 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -7,6 +7,7 @@
  *		2 of the License, or (at your option) any later version.
  *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ *		Eric Dumazet <edumazet@google.com>
  *
  * Changes:
  *              Jamal Hadi Salim - moved it to net/core and reshulfed
@@ -30,171 +31,79 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
-#include <linux/rbtree.h>
 #include <linux/slab.h>
+#include <linux/seqlock.h>
 #include <net/sock.h>
 #include <net/gen_stats.h>
 
-/*
-   This code is NOT intended to be used for statistics collection,
-   its purpose is to provide a base for statistical multiplexing
-   for controlled load service.
-   If you need only statistics, run a user level daemon which
-   periodically reads byte counters.
-
-   Unfortunately, rate estimation is not a very easy task.
-   F.e. I did not find a simple way to estimate the current peak rate
-   and even failed to formulate the problem 8)8)
-
-   So I preferred not to built an estimator into the scheduler,
-   but run this task separately.
-   Ideally, it should be kernel thread(s), but for now it runs
-   from timers, which puts apparent top bounds on the number of rated
-   flows, has minimal overhead on small, but is enough
-   to handle controlled load service, sets of aggregates.
-
-   We measure rate over A=(1<<interval) seconds and evaluate EWMA:
-
-   avrate = avrate*(1-W) + rate*W
-
-   where W is chosen as negative power of 2: W = 2^(-ewma_log)
-
-   The resulting time constant is:
-
-   T = A/(-ln(1-W))
-
-
-   NOTES.
-
-   * avbps and avpps are scaled by 2^5.
-   * both values are reported as 32 bit unsigned values. bps can
-     overflow for fast links : max speed being 34360Mbit/sec
-   * Minimal interval is HZ/4=250msec (it is the greatest common divisor
-     for HZ=100 and HZ=1024 8)), maximal interval
-     is (HZ*2^EST_MAX_INTERVAL)/4 = 8sec. Shorter intervals
-     are too expensive, longer ones can be implemented
-     at user level painlessly.
+/* This code is NOT intended to be used for statistics collection,
+ * its purpose is to provide a base for statistical multiplexing
+ * for controlled load service.
+ * If you need only statistics, run a user level daemon which
+ * periodically reads byte counters.
  */
 
-#define EST_MAX_INTERVAL	5
-
-struct gen_estimator {
-	struct list_head	list;
+struct net_rate_estimator {
 	struct gnet_stats_basic_packed	*bstats;
-	struct gnet_stats_rate_est64	*rate_est;
 	spinlock_t		*stats_lock;
 	seqcount_t		*running;
-	int			ewma_log;
+	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
+	u8			ewma_log;
+	u8			intvl_log; /* period : (250ms << intvl_log) */
+
+	seqcount_t		seq;
 	u32			last_packets;
-	unsigned long		avpps;
 	u64			last_bytes;
+
+	u64			avpps;
 	u64			avbps;
-	struct rcu_head		e_rcu;
-	struct rb_node		node;
-	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
-	struct rcu_head		head;
-};
 
-struct gen_estimator_head {
-	unsigned long		next_jiffies;
-	struct timer_list	timer;
-	struct list_head	list;
+	unsigned long           next_jiffies;
+	struct timer_list       timer;
+	struct rcu_head		rcu;
 };
 
-static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
-
-/* Protects against NULL dereference */
-static DEFINE_RWLOCK(est_lock);
-
-/* Protects against soft lockup during large deletion */
-static struct rb_root est_root = RB_ROOT;
-static DEFINE_SPINLOCK(est_tree_lock);
-
-static void est_timer(unsigned long arg)
+static void est_fetch_counters(struct net_rate_estimator *e,
+			       struct gnet_stats_basic_packed *b)
 {
-	int idx = (int)arg;
-	struct gen_estimator *e;
+	if (e->stats_lock)
+		spin_lock(e->stats_lock);
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(e, &elist[idx].list, list) {
-		struct gnet_stats_basic_packed b = {0};
-		unsigned long rate;
-		u64 brate;
-
-		if (e->stats_lock)
-			spin_lock(e->stats_lock);
-		read_lock(&est_lock);
-		if (e->bstats == NULL)
-			goto skip;
-
-		__gnet_stats_copy_basic(e->running, &b, e->cpu_bstats, e->bstats);
-
-		brate = (b.bytes - e->last_bytes)<<(7 - idx);
-		e->last_bytes = b.bytes;
-		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
-		WRITE_ONCE(e->rate_est->bps, (e->avbps + 0xF) >> 5);
-
-		rate = b.packets - e->last_packets;
-		rate <<= (7 - idx);
-		e->last_packets = b.packets;
-		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
-		WRITE_ONCE(e->rate_est->pps, (e->avpps + 0xF) >> 5);
-skip:
-		read_unlock(&est_lock);
-		if (e->stats_lock)
-			spin_unlock(e->stats_lock);
-	}
+	__gnet_stats_copy_basic(e->running, b, e->cpu_bstats, e->bstats);
 
-	if (!list_empty(&elist[idx].list)) {
-		elist[idx].next_jiffies += ((HZ/4) << idx);
+	if (e->stats_lock)
+		spin_unlock(e->stats_lock);
 
-		if (unlikely(time_after_eq(jiffies, elist[idx].next_jiffies))) {
-			/* Ouch... timer was delayed. */
-			elist[idx].next_jiffies = jiffies + 1;
-		}
-		mod_timer(&elist[idx].timer, elist[idx].next_jiffies);
-	}
-	rcu_read_unlock();
 }
 
-static void gen_add_node(struct gen_estimator *est)
+static void est_timer(unsigned long arg)
 {
-	struct rb_node **p = &est_root.rb_node, *parent = NULL;
+	struct net_rate_estimator *est = (struct net_rate_estimator *)arg;
+	struct gnet_stats_basic_packed b;
+	u64 rate, brate;
 
-	while (*p) {
-		struct gen_estimator *e;
+	est_fetch_counters(est, &b);
+	brate = (b.bytes - est->last_bytes) << (8 - est->ewma_log);
+	brate -= (est->avbps >> est->ewma_log);
 
-		parent = *p;
-		e = rb_entry(parent, struct gen_estimator, node);
+	rate = (u64)(b.packets - est->last_packets) << (8 - est->ewma_log);
+	rate -= (est->avpps >> est->ewma_log);
 
-		if (est->bstats > e->bstats)
-			p = &parent->rb_right;
-		else
-			p = &parent->rb_left;
-	}
-	rb_link_node(&est->node, parent, p);
-	rb_insert_color(&est->node, &est_root);
-}
-
-static
-struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats,
-				    const struct gnet_stats_rate_est64 *rate_est)
-{
-	struct rb_node *p = est_root.rb_node;
+	write_seqcount_begin(&est->seq);
+	est->avbps += brate;
+	est->avpps += rate;
+	write_seqcount_end(&est->seq);
 
-	while (p) {
-		struct gen_estimator *e;
+	est->last_bytes = b.bytes;
+	est->last_packets = b.packets;
 
-		e = rb_entry(p, struct gen_estimator, node);
+	est->next_jiffies += ((HZ/4) << est->intvl_log);
 
-		if (bstats > e->bstats)
-			p = p->rb_right;
-		else if (bstats < e->bstats || rate_est != e->rate_est)
-			p = p->rb_left;
-		else
-			return e;
+	if (unlikely(time_after_eq(jiffies, est->next_jiffies))) {
+		/* Ouch... timer was delayed. */
+		est->next_jiffies = jiffies + 1;
 	}
-	return NULL;
+	mod_timer(&est->timer, est->next_jiffies);
 }
 
 /**
@@ -217,84 +126,76 @@ struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats
  */
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 		      struct gnet_stats_basic_cpu __percpu *cpu_bstats,
-		      struct gnet_stats_rate_est64 *rate_est,
+		      struct net_rate_estimator __rcu **rate_est,
 		      spinlock_t *stats_lock,
 		      seqcount_t *running,
 		      struct nlattr *opt)
 {
-	struct gen_estimator *est;
 	struct gnet_estimator *parm = nla_data(opt);
-	struct gnet_stats_basic_packed b = {0};
-	int idx;
+	struct net_rate_estimator *old, *est;
+	struct gnet_stats_basic_packed b;
+	int intvl_log;
 
 	if (nla_len(opt) < sizeof(*parm))
 		return -EINVAL;
 
+	/* allowed timer periods are :
+	 * -2 : 250ms,   -1 : 500ms,    0 : 1 sec
+	 *  1 : 2 sec,    2 : 4 sec,    3 : 8 sec
+	 */
 	if (parm->interval < -2 || parm->interval > 3)
 		return -EINVAL;
 
 	est = kzalloc(sizeof(*est), GFP_KERNEL);
-	if (est == NULL)
+	if (!est)
 		return -ENOBUFS;
 
-	__gnet_stats_copy_basic(running, &b, cpu_bstats, bstats);
-
-	idx = parm->interval + 2;
+	seqcount_init(&est->seq);
+	intvl_log = parm->interval + 2;
 	est->bstats = bstats;
-	est->rate_est = rate_est;
 	est->stats_lock = stats_lock;
 	est->running  = running;
 	est->ewma_log = parm->ewma_log;
-	est->last_bytes = b.bytes;
-	est->avbps = rate_est->bps<<5;
-	est->last_packets = b.packets;
-	est->avpps = rate_est->pps<<10;
+	est->intvl_log = intvl_log;
 	est->cpu_bstats = cpu_bstats;
 
-	spin_lock_bh(&est_tree_lock);
-	if (!elist[idx].timer.function) {
-		INIT_LIST_HEAD(&elist[idx].list);
-		setup_timer(&elist[idx].timer, est_timer, idx);
+	est_fetch_counters(est, &b);
+	est->last_bytes = b.bytes;
+	est->last_packets = b.packets;
+	old = rcu_dereference_protected(*rate_est, 1);
+	if (old) {
+		del_timer_sync(&old->timer);
+		est->avbps = old->avbps;
+		est->avpps = old->avpps;
 	}
 
-	if (list_empty(&elist[idx].list)) {
-		elist[idx].next_jiffies = jiffies + ((HZ/4) << idx);
-		mod_timer(&elist[idx].timer, elist[idx].next_jiffies);
-	}
-	list_add_rcu(&est->list, &elist[idx].list);
-	gen_add_node(est);
-	spin_unlock_bh(&est_tree_lock);
+	est->next_jiffies = jiffies + ((HZ/4) << intvl_log);
+	setup_timer(&est->timer, est_timer, (unsigned long)est);
+	mod_timer(&est->timer, est->next_jiffies);
 
+	rcu_assign_pointer(*rate_est, est);
+	if (old)
+		kfree_rcu(old, rcu);
 	return 0;
 }
 EXPORT_SYMBOL(gen_new_estimator);
 
 /**
  * gen_kill_estimator - remove a rate estimator
- * @bstats: basic statistics
- * @rate_est: rate estimator statistics
+ * @rate_est: rate estimator
  *
- * Removes the rate estimator specified by &bstats and &rate_est.
+ * Removes the rate estimator.
  *
- * Note : Caller should respect an RCU grace period before freeing stats_lock
  */
-void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
-			struct gnet_stats_rate_est64 *rate_est)
+void gen_kill_estimator(struct net_rate_estimator __rcu **rate_est)
 {
-	struct gen_estimator *e;
-
-	spin_lock_bh(&est_tree_lock);
-	while ((e = gen_find_node(bstats, rate_est))) {
-		rb_erase(&e->node, &est_root);
+	struct net_rate_estimator *est;
 
-		write_lock(&est_lock);
-		e->bstats = NULL;
-		write_unlock(&est_lock);
-
-		list_del_rcu(&e->list);
-		kfree_rcu(e, e_rcu);
+	est = xchg((__force struct net_rate_estimator **)rate_est, NULL);
+	if (est) {
+		del_timer_sync(&est->timer);
+		kfree_rcu(est, rcu);
 	}
-	spin_unlock_bh(&est_tree_lock);
 }
 EXPORT_SYMBOL(gen_kill_estimator);
 
@@ -314,33 +215,47 @@ EXPORT_SYMBOL(gen_kill_estimator);
  */
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
 			  struct gnet_stats_basic_cpu __percpu *cpu_bstats,
-			  struct gnet_stats_rate_est64 *rate_est,
+			  struct net_rate_estimator __rcu **rate_est,
 			  spinlock_t *stats_lock,
 			  seqcount_t *running, struct nlattr *opt)
 {
-	gen_kill_estimator(bstats, rate_est);
-	return gen_new_estimator(bstats, cpu_bstats, rate_est, stats_lock, running, opt);
+	return gen_new_estimator(bstats, cpu_bstats, rate_est,
+				 stats_lock, running, opt);
 }
 EXPORT_SYMBOL(gen_replace_estimator);
 
 /**
  * gen_estimator_active - test if estimator is currently in use
- * @bstats: basic statistics
- * @rate_est: rate estimator statistics
+ * @rate_est: rate estimator
  *
  * Returns true if estimator is active, and false if not.
  */
-bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
-			  const struct gnet_stats_rate_est64 *rate_est)
+bool gen_estimator_active(struct net_rate_estimator __rcu **rate_est)
 {
-	bool res;
+	return !!rcu_access_pointer(*rate_est);
+}
+EXPORT_SYMBOL(gen_estimator_active);
 
-	ASSERT_RTNL();
+bool gen_estimator_read(struct net_rate_estimator __rcu **rate_est,
+			struct gnet_stats_rate_est64 *sample)
+{
+	struct net_rate_estimator *est;
+	unsigned seq;
+
+	rcu_read_lock();
+	est = rcu_dereference(*rate_est);
+	if (!est) {
+		rcu_read_unlock();
+		return false;
+	}
 
-	spin_lock_bh(&est_tree_lock);
-	res = gen_find_node(bstats, rate_est) != NULL;
-	spin_unlock_bh(&est_tree_lock);
+	do {
+		seq = read_seqcount_begin(&est->seq);
+		sample->bps = est->avbps >> 8;
+		sample->pps = est->avpps >> 8;
+	} while (read_seqcount_retry(&est->seq, seq));
 
-	return res;
+	rcu_read_unlock();
+	return true;
 }
-EXPORT_SYMBOL(gen_estimator_active);
+EXPORT_SYMBOL(gen_estimator_read);
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 508e051304fb62627e61b5065b2325edd1b84f2e..87f28557b3298f30b1cf79dccf3bc6b761cd6623 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -194,8 +194,7 @@ EXPORT_SYMBOL(gnet_stats_copy_basic);
 /**
  * gnet_stats_copy_rate_est - copy rate estimator statistics into statistics TLV
  * @d: dumping handle
- * @b: basic statistics
- * @r: rate estimator statistics
+ * @rate_est: rate estimator
  *
  * Appends the rate estimator statistics to the top level TLV created by
  * gnet_stats_start_copy().
@@ -205,18 +204,17 @@ EXPORT_SYMBOL(gnet_stats_copy_basic);
  */
 int
 gnet_stats_copy_rate_est(struct gnet_dump *d,
-			 const struct gnet_stats_basic_packed *b,
-			 struct gnet_stats_rate_est64 *r)
+			 struct net_rate_estimator __rcu **rate_est)
 {
+	struct gnet_stats_rate_est64 sample;
 	struct gnet_stats_rate_est est;
 	int res;
 
-	if (b && !gen_estimator_active(b, r))
+	if (!gen_estimator_read(rate_est, &sample))
 		return 0;
-
-	est.bps = min_t(u64, UINT_MAX, r->bps);
+	est.bps = min_t(u64, UINT_MAX, sample.bps);
 	/* we have some time before reaching 2^32 packets per second */
-	est.pps = r->pps;
+	est.pps = sample.pps;
 
 	if (d->compat_tc_stats) {
 		d->tc_stats.bps = est.bps;
@@ -226,11 +224,11 @@ gnet_stats_copy_rate_est(struct gnet_dump *d,
 	if (d->tail) {
 		res = gnet_stats_copy(d, TCA_STATS_RATE_EST, &est, sizeof(est),
 				      TCA_STATS_PAD);
-		if (res < 0 || est.bps == r->bps)
+		if (res < 0 || est.bps == sample.bps)
 			return res;
 		/* emit 64bit stats only if needed */
-		return gnet_stats_copy(d, TCA_STATS_RATE_EST64, r, sizeof(*r),
-				       TCA_STATS_PAD);
+		return gnet_stats_copy(d, TCA_STATS_RATE_EST64, &sample,
+				       sizeof(sample), TCA_STATS_PAD);
 	}
 
 	return 0;
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index dbd6c4a12b97435d2937c92fd79a035fd5828965..91a373a3f534de8d8641341c33c08d8fc49cbd29 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -63,7 +63,7 @@ void xt_rateest_put(struct xt_rateest *est)
 	mutex_lock(&xt_rateest_mutex);
 	if (--est->refcnt == 0) {
 		hlist_del(&est->list);
-		gen_kill_estimator(&est->bstats, &est->rstats);
+		gen_kill_estimator(&est->rate_est);
 		/*
 		 * gen_estimator est_timer() might access est->lock or bstats,
 		 * wait a RCU grace period before freeing 'est'
@@ -132,7 +132,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 	cfg.est.interval	= info->interval;
 	cfg.est.ewma_log	= info->ewma_log;
 
-	ret = gen_new_estimator(&est->bstats, NULL, &est->rstats,
+	ret = gen_new_estimator(&est->bstats, NULL, &est->rate_est,
 				&est->lock, NULL, &cfg.opt);
 	if (ret < 0)
 		goto err2;
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 7720b036d76a84c949080c8c32827b604c80da64..1db02f6fca54d7eb5d60c2d8c5cb8ab11656fbcb 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -18,35 +18,33 @@ static bool
 xt_rateest_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_rateest_match_info *info = par->matchinfo;
-	struct gnet_stats_rate_est64 *r;
+	struct gnet_stats_rate_est64 sample = {0};
 	u_int32_t bps1, bps2, pps1, pps2;
 	bool ret = true;
 
-	spin_lock_bh(&info->est1->lock);
-	r = &info->est1->rstats;
+	gen_estimator_read(&info->est1->rate_est, &sample);
+
 	if (info->flags & XT_RATEEST_MATCH_DELTA) {
-		bps1 = info->bps1 >= r->bps ? info->bps1 - r->bps : 0;
-		pps1 = info->pps1 >= r->pps ? info->pps1 - r->pps : 0;
+		bps1 = info->bps1 >= sample.bps ? info->bps1 - sample.bps : 0;
+		pps1 = info->pps1 >= sample.pps ? info->pps1 - sample.pps : 0;
 	} else {
-		bps1 = r->bps;
-		pps1 = r->pps;
+		bps1 = sample.bps;
+		pps1 = sample.pps;
 	}
-	spin_unlock_bh(&info->est1->lock);
 
 	if (info->flags & XT_RATEEST_MATCH_ABS) {
 		bps2 = info->bps2;
 		pps2 = info->pps2;
 	} else {
-		spin_lock_bh(&info->est2->lock);
-		r = &info->est2->rstats;
+		gen_estimator_read(&info->est2->rate_est, &sample);
+
 		if (info->flags & XT_RATEEST_MATCH_DELTA) {
-			bps2 = info->bps2 >= r->bps ? info->bps2 - r->bps : 0;
-			pps2 = info->pps2 >= r->pps ? info->pps2 - r->pps : 0;
+			bps2 = info->bps2 >= sample.bps ? info->bps2 - sample.bps : 0;
+			pps2 = info->pps2 >= sample.pps ? info->pps2 - sample.pps : 0;
 		} else {
-			bps2 = r->bps;
-			pps2 = r->pps;
+			bps2 = sample.bps;
+			pps2 = sample.pps;
 		}
-		spin_unlock_bh(&info->est2->lock);
 	}
 
 	switch (info->mode) {
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index f893d180da1caa3b6dd1cc8773920beb1885f9b0..2095c83ce7730d49550103a8efad943d28815617 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -41,8 +41,7 @@ static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *p)
 	spin_lock_bh(&hinfo->lock);
 	hlist_del(&p->tcfa_head);
 	spin_unlock_bh(&hinfo->lock);
-	gen_kill_estimator(&p->tcfa_bstats,
-			   &p->tcfa_rate_est);
+	gen_kill_estimator(&p->tcfa_rate_est);
 	/*
 	 * gen_estimator est_timer() might access p->tcfa_lock
 	 * or bstats, wait a RCU grace period before freeing p
@@ -237,8 +236,7 @@ EXPORT_SYMBOL(tcf_hash_check);
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
 {
 	if (est)
-		gen_kill_estimator(&a->tcfa_bstats,
-				   &a->tcfa_rate_est);
+		gen_kill_estimator(&a->tcfa_rate_est);
 	call_rcu(&a->tcfa_rcu, free_tcf);
 }
 EXPORT_SYMBOL(tcf_hash_cleanup);
@@ -670,8 +668,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *p,
 		goto errout;
 
 	if (gnet_stats_copy_basic(NULL, &d, p->cpu_bstats, &p->tcfa_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &p->tcfa_bstats,
-				     &p->tcfa_rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &p->tcfa_rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, p->cpu_qstats,
 				  &p->tcfa_qstats,
 				  p->tcfa_qstats.qlen) < 0)
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index c990b73a6c85151862c30971bd3787d20dbcecd1..0ba91d1ce99480c4817684dbe0b4fde61811e03e 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -142,8 +142,7 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 			goto failure_unlock;
 	} else if (tb[TCA_POLICE_AVRATE] &&
 		   (ret == ACT_P_CREATED ||
-		    !gen_estimator_active(&police->tcf_bstats,
-					  &police->tcf_rate_est))) {
+		    !gen_estimator_active(&police->tcf_rate_est))) {
 		err = -EINVAL;
 		goto failure_unlock;
 	}
@@ -216,13 +215,17 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 	bstats_update(&police->tcf_bstats, skb);
 	tcf_lastuse_update(&police->tcf_tm);
 
-	if (police->tcfp_ewma_rate &&
-	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
-		police->tcf_qstats.overlimits++;
-		if (police->tcf_action == TC_ACT_SHOT)
-			police->tcf_qstats.drops++;
-		spin_unlock(&police->tcf_lock);
-		return police->tcf_action;
+	if (police->tcfp_ewma_rate) {
+		struct gnet_stats_rate_est64 sample;
+
+		if (!gen_estimator_read(&police->tcf_rate_est, &sample) ||
+		    sample.bps >= police->tcfp_ewma_rate) {
+			police->tcf_qstats.overlimits++;
+			if (police->tcf_action == TC_ACT_SHOT)
+				police->tcf_qstats.drops++;
+			spin_unlock(&police->tcf_lock);
+			return police->tcf_action;
+		}
 	}
 
 	if (qdisc_pkt_len(skb) <= police->tcfp_mtu) {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f337f1bdd1d4a4cac738f9fe1fbd42e5984174fe..d7b93429f0cca61ff489536b4247f31f3690fdd8 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1395,7 +1395,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 
 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(q),
 				  &d, cpu_bstats, &q->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &q->bstats, &q->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, cpu_qstats, &q->qstats, qlen) < 0)
 		goto nla_put_failure;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index beb554aa8cfbb4acb5d89511b5e0030b4c9cf26e..9ffe1c220b02848032474fa7b9b2c2f09d40b110 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -122,7 +122,7 @@ struct cbq_class {
 	psched_time_t		penalized;
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est64 rate_est;
+	struct net_rate_estimator __rcu *rate_est;
 	struct tc_cbq_xstats	xstats;
 
 	struct tcf_proto __rcu	*filter_list;
@@ -1346,7 +1346,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
 				  d, NULL, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl->qstats, cl->q->q.qlen) < 0)
 		return -1;
 
@@ -1405,7 +1405,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 	tcf_destroy_chain(&cl->filter_list);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->rate_est);
 	if (cl != &q->link)
 		kfree(cl);
 }
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 8af5c59eef848db47cc33a878296693dabb44955..bb4cbdf7500482b170eef6e7923cf2f2259e52b5 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -25,7 +25,7 @@ struct drr_class {
 
 	struct gnet_stats_basic_packed		bstats;
 	struct gnet_stats_queue		qstats;
-	struct gnet_stats_rate_est64	rate_est;
+	struct net_rate_estimator __rcu *rate_est;
 	struct list_head		alist;
 	struct Qdisc			*qdisc;
 
@@ -142,7 +142,7 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 static void drr_destroy_class(struct Qdisc *sch, struct drr_class *cl)
 {
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->rate_est);
 	qdisc_destroy(cl->qdisc);
 	kfree(cl);
 }
@@ -283,7 +283,7 @@ static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
 				  d, NULL, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl->qdisc->qstats, qlen) < 0)
 		return -1;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6cfb6e9038c28187cc888cebf004e61270f00871..6eb9c8e88519a36fc3ef82be7c7f1dbe0ef1e13c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -709,7 +709,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 
 	qdisc_put_stab(rtnl_dereference(qdisc->stab));
 #endif
-	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
+	gen_kill_estimator(&qdisc->rate_est);
 	if (ops->reset)
 		ops->reset(qdisc);
 	if (ops->destroy)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 000f1d36128e1abfc0657bce779a7df852f66384..3ffaa6fb0990f0aa31487a2f1829b1f1accf8b21 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -114,7 +114,7 @@ struct hfsc_class {
 
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est64 rate_est;
+	struct net_rate_estimator __rcu *rate_est;
 	struct tcf_proto __rcu *filter_list; /* filter list */
 	unsigned int	filter_cnt;	/* filter count */
 	unsigned int	level;		/* class level in hierarchy */
@@ -1091,7 +1091,7 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 
 	tcf_destroy_chain(&cl->filter_list);
 	qdisc_destroy(cl->qdisc);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->rate_est);
 	if (cl != &q->root)
 		kfree(cl);
 }
@@ -1348,7 +1348,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.rtwork  = cl->cl_cumul;
 
 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch), d, NULL, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl->qstats, cl->qdisc->q.qlen) < 0)
 		return -1;
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 9926fe4f3b6f7db9aeba22fbbfae3d47c4e2af60..760f39e7caeeb91b6c34d561f64f1ed97c884a32 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -111,7 +111,7 @@ struct htb_class {
 	unsigned int		children;
 	struct htb_class	*parent;	/* parent class */
 
-	struct gnet_stats_rate_est64 rate_est;
+	struct net_rate_estimator __rcu *rate_est;
 
 	/*
 	 * Written often fields
@@ -1145,7 +1145,7 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 
 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
 				  d, NULL, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &qs, qlen) < 0)
 		return -1;
 
@@ -1228,7 +1228,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		WARN_ON(!cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->rate_est);
 	tcf_destroy_chain(&cl->filter_list);
 	kfree(cl);
 }
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index ca0516e6f74356f47dffcc2262f233ee50f0c47c..f9e712ce2d15ce9280c31d2f75d62b84034ae51d 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -137,7 +137,7 @@ struct qfq_class {
 
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est64 rate_est;
+	struct net_rate_estimator __rcu *rate_est;
 	struct Qdisc *qdisc;
 	struct list_head alist;		/* Link for active-classes list. */
 	struct qfq_aggregate *agg;	/* Parent aggregate. */
@@ -508,7 +508,7 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		new_agg = kzalloc(sizeof(*new_agg), GFP_KERNEL);
 		if (new_agg == NULL) {
 			err = -ENOBUFS;
-			gen_kill_estimator(&cl->bstats, &cl->rate_est);
+			gen_kill_estimator(&cl->rate_est);
 			goto destroy_class;
 		}
 		sch_tree_lock(sch);
@@ -533,7 +533,7 @@ static void qfq_destroy_class(struct Qdisc *sch, struct qfq_class *cl)
 	struct qfq_sched *q = qdisc_priv(sch);
 
 	qfq_rm_from_agg(q, cl);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->rate_est);
 	qdisc_destroy(cl->qdisc);
 	kfree(cl);
 }
@@ -667,7 +667,7 @@ static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
 				  d, NULL, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL,
 				  &cl->qdisc->qstats, cl->qdisc->q.qlen) < 0)
 		return -1;


