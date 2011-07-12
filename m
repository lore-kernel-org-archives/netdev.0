From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/5] ipv4: Delete routing cache.
Date: Mon, 11 Jul 2011 22:30:02 -0700 (PDT)
Message-ID: <20110711.223002.581737876855421730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab1GLFaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 01:30:03 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6C5U2os030511
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 22:30:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    1 -
 net/ipv4/fib_frontend.c |    5 -
 net/ipv4/route.c        |  889 +----------------------------------------------
 3 files changed, 19 insertions(+), 876 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index db7b343..8861144 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -114,7 +114,6 @@ extern int		ip_rt_init(void);
 extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
-extern void		rt_cache_flush_batch(struct net *net);
 extern struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 extern struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 					   struct sock *sk);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 92fc5f6..fb15bc6 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1022,11 +1022,6 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		rt_cache_flush(dev_net(dev), 0);
 		break;
 	case NETDEV_UNREGISTER_BATCH:
-		/* The batch unregister is only called on the first
-		 * device in the list of devices being unregistered.
-		 * Therefore we should not pass dev_net(dev) in here.
-		 */
-		rt_cache_flush_batch(NULL);
 		break;
 	}
 	return NOTIFY_DONE;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a8ccd9b..c935853 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -129,7 +129,6 @@ static int ip_rt_gc_elasticity __read_mostly	= 8;
 static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
-static int rt_chain_length_max __read_mostly	= 20;
 
 /*
  *	Interface to generic destination cache.
@@ -142,7 +141,6 @@ static void		 ipv4_dst_destroy(struct dst_entry *dst);
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
-static int rt_garbage_collect(struct dst_ops *ops);
 
 static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			    int how)
@@ -187,7 +185,6 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
-	.gc =			rt_garbage_collect,
 	.check =		ipv4_dst_check,
 	.default_advmss =	ipv4_default_advmss,
 	.default_mtu =		ipv4_default_mtu,
@@ -222,184 +219,30 @@ const __u8 ip_tos2prio[16] = {
 };
 
 
-/*
- * Route cache.
- */
-
-/* The locking scheme is rather straight forward:
- *
- * 1) Read-Copy Update protects the buckets of the central route hash.
- * 2) Only writers remove entries, and they hold the lock
- *    as they look at rtable reference counts.
- * 3) Only readers acquire references to rtable entries,
- *    they do so with atomic increments and with the
- *    lock held.
- */
-
-struct rt_hash_bucket {
-	struct rtable __rcu	*chain;
-};
-
-#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
-	defined(CONFIG_PROVE_LOCKING)
-/*
- * Instead of using one spinlock for each rt_hash_bucket, we use a table of spinlocks
- * The size of this table is a power of two and depends on the number of CPUS.
- * (on lockdep we have a quite big spinlock_t, so keep the size down there)
- */
-#ifdef CONFIG_LOCKDEP
-# define RT_HASH_LOCK_SZ	256
-#else
-# if NR_CPUS >= 32
-#  define RT_HASH_LOCK_SZ	4096
-# elif NR_CPUS >= 16
-#  define RT_HASH_LOCK_SZ	2048
-# elif NR_CPUS >= 8
-#  define RT_HASH_LOCK_SZ	1024
-# elif NR_CPUS >= 4
-#  define RT_HASH_LOCK_SZ	512
-# else
-#  define RT_HASH_LOCK_SZ	256
-# endif
-#endif
-
-static spinlock_t	*rt_hash_locks;
-# define rt_hash_lock_addr(slot) &rt_hash_locks[(slot) & (RT_HASH_LOCK_SZ - 1)]
-
-static __init void rt_hash_lock_init(void)
-{
-	int i;
-
-	rt_hash_locks = kmalloc(sizeof(spinlock_t) * RT_HASH_LOCK_SZ,
-			GFP_KERNEL);
-	if (!rt_hash_locks)
-		panic("IP: failed to allocate rt_hash_locks\n");
-
-	for (i = 0; i < RT_HASH_LOCK_SZ; i++)
-		spin_lock_init(&rt_hash_locks[i]);
-}
-#else
-# define rt_hash_lock_addr(slot) NULL
-
-static inline void rt_hash_lock_init(void)
-{
-}
-#endif
-
-static struct rt_hash_bucket 	*rt_hash_table __read_mostly;
-static unsigned			rt_hash_mask __read_mostly;
-static unsigned int		rt_hash_log  __read_mostly;
-
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
 #define RT_CACHE_STAT_INC(field) __this_cpu_inc(rt_cache_stat.field)
 
-static inline unsigned int rt_hash(__be32 daddr, __be32 saddr, int idx,
-				   int genid)
-{
-	return jhash_3words((__force u32)daddr, (__force u32)saddr,
-			    idx, genid)
-		& rt_hash_mask;
-}
-
 static inline int rt_genid(struct net *net)
 {
 	return atomic_read(&net->ipv4.rt_genid);
 }
 
 #ifdef CONFIG_PROC_FS
-struct rt_cache_iter_state {
-	struct seq_net_private p;
-	int bucket;
-	int genid;
-};
-
-static struct rtable *rt_cache_get_first(struct seq_file *seq)
-{
-	struct rt_cache_iter_state *st = seq->private;
-	struct rtable *r = NULL;
-
-	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
-		if (!rcu_dereference_raw(rt_hash_table[st->bucket].chain))
-			continue;
-		rcu_read_lock_bh();
-		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
-		while (r) {
-			if (dev_net(r->dst.dev) == seq_file_net(seq) &&
-			    r->rt_genid == st->genid)
-				return r;
-			r = rcu_dereference_bh(r->dst.rt_next);
-		}
-		rcu_read_unlock_bh();
-	}
-	return r;
-}
-
-static struct rtable *__rt_cache_get_next(struct seq_file *seq,
-					  struct rtable *r)
-{
-	struct rt_cache_iter_state *st = seq->private;
-
-	r = rcu_dereference_bh(r->dst.rt_next);
-	while (!r) {
-		rcu_read_unlock_bh();
-		do {
-			if (--st->bucket < 0)
-				return NULL;
-		} while (!rcu_dereference_raw(rt_hash_table[st->bucket].chain));
-		rcu_read_lock_bh();
-		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
-	}
-	return r;
-}
-
-static struct rtable *rt_cache_get_next(struct seq_file *seq,
-					struct rtable *r)
-{
-	struct rt_cache_iter_state *st = seq->private;
-	while ((r = __rt_cache_get_next(seq, r)) != NULL) {
-		if (dev_net(r->dst.dev) != seq_file_net(seq))
-			continue;
-		if (r->rt_genid == st->genid)
-			break;
-	}
-	return r;
-}
-
-static struct rtable *rt_cache_get_idx(struct seq_file *seq, loff_t pos)
-{
-	struct rtable *r = rt_cache_get_first(seq);
-
-	if (r)
-		while (pos && (r = rt_cache_get_next(seq, r)))
-			--pos;
-	return pos ? NULL : r;
-}
-
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct rt_cache_iter_state *st = seq->private;
 	if (*pos)
-		return rt_cache_get_idx(seq, *pos - 1);
-	st->genid = rt_genid(seq_file_net(seq));
+		return NULL;
 	return SEQ_START_TOKEN;
 }
 
 static void *rt_cache_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct rtable *r;
-
-	if (v == SEQ_START_TOKEN)
-		r = rt_cache_get_first(seq);
-	else
-		r = rt_cache_get_next(seq, v);
 	++*pos;
-	return r;
+	return NULL;
 }
 
 static void rt_cache_seq_stop(struct seq_file *seq, void *v)
 {
-	if (v && v != SEQ_START_TOKEN)
-		rcu_read_unlock_bh();
 }
 
 static int rt_cache_seq_show(struct seq_file *seq, void *v)
@@ -409,29 +252,6 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			   "Iface\tDestination\tGateway \tFlags\t\tRefCnt\tUse\t"
 			   "Metric\tSource\t\tMTU\tWindow\tIRTT\tTOS\tHHRef\t"
 			   "HHUptod\tSpecDst");
-	else {
-		struct rtable *r = v;
-		int len;
-
-		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
-			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
-			r->dst.dev ? r->dst.dev->name : "*",
-			(__force u32)r->rt_dst,
-			(__force u32)r->rt_gateway,
-			r->rt_flags, atomic_read(&r->dst.__refcnt),
-			r->dst.__use, 0, (__force u32)r->rt_src,
-			dst_metric_advmss(&r->dst) + 40,
-			dst_metric(&r->dst, RTAX_WINDOW),
-			(int)((dst_metric(&r->dst, RTAX_RTT) >> 3) +
-			      dst_metric(&r->dst, RTAX_RTTVAR)),
-			r->rt_key_tos,
-			r->dst.hh ? atomic_read(&r->dst.hh->hh_refcnt) : -1,
-			r->dst.hh ? (r->dst.hh->hh_output ==
-				       dev_queue_xmit) : 0,
-			r->rt_spec_dst, &len);
-
-		seq_printf(seq, "%*s\n", 127 - len, "");
-	}
 	return 0;
 }
 
@@ -444,8 +264,7 @@ static const struct seq_operations rt_cache_seq_ops = {
 
 static int rt_cache_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_net(inode, file, &rt_cache_seq_ops,
-			sizeof(struct rt_cache_iter_state));
+	return seq_open(file, &rt_cache_seq_ops);
 }
 
 static const struct file_operations rt_cache_seq_fops = {
@@ -453,7 +272,7 @@ static const struct file_operations rt_cache_seq_fops = {
 	.open	 = rt_cache_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release_net,
+	.release = seq_release,
 };
 
 
@@ -643,184 +462,12 @@ static inline int ip_rt_proc_init(void)
 }
 #endif /* CONFIG_PROC_FS */
 
-static inline void rt_free(struct rtable *rt)
-{
-	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
-}
-
-static inline void rt_drop(struct rtable *rt)
-{
-	ip_rt_put(rt);
-	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
-}
-
-static inline int rt_fast_clean(struct rtable *rth)
-{
-	/* Kill broadcast/multicast entries very aggresively, if they
-	   collide in hash table with more useful entries */
-	return (rth->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)) &&
-		rt_is_input_route(rth) && rth->dst.rt_next;
-}
-
-static inline int rt_valuable(struct rtable *rth)
-{
-	return (rth->rt_flags & (RTCF_REDIRECTED | RTCF_NOTIFY)) ||
-		(rth->peer && rth->peer->pmtu_expires);
-}
-
-static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
-{
-	unsigned long age;
-	int ret = 0;
-
-	if (atomic_read(&rth->dst.__refcnt))
-		goto out;
-
-	age = jiffies - rth->dst.lastuse;
-	if ((age <= tmo1 && !rt_fast_clean(rth)) ||
-	    (age <= tmo2 && rt_valuable(rth)))
-		goto out;
-	ret = 1;
-out:	return ret;
-}
-
-/* Bits of score are:
- * 31: very valuable
- * 30: not quite useless
- * 29..0: usage counter
- */
-static inline u32 rt_score(struct rtable *rt)
-{
-	u32 score = jiffies - rt->dst.lastuse;
-
-	score = ~score & ~(3<<30);
-
-	if (rt_valuable(rt))
-		score |= (1<<31);
-
-	if (rt_is_output_route(rt) ||
-	    !(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL)))
-		score |= (1<<30);
-
-	return score;
-}
-
-static inline bool rt_caching(const struct net *net)
-{
-	return net->ipv4.current_rt_cache_rebuild_count <=
-		net->ipv4.sysctl_rt_cache_rebuild_count;
-}
-
-static inline bool compare_hash_inputs(const struct rtable *rt1,
-				       const struct rtable *rt2)
-{
-	return ((((__force u32)rt1->rt_key_dst ^ (__force u32)rt2->rt_key_dst) |
-		((__force u32)rt1->rt_key_src ^ (__force u32)rt2->rt_key_src) |
-		(rt1->rt_iif ^ rt2->rt_iif)) == 0);
-}
-
-static inline int compare_keys(struct rtable *rt1, struct rtable *rt2)
-{
-	return (((__force u32)rt1->rt_key_dst ^ (__force u32)rt2->rt_key_dst) |
-		((__force u32)rt1->rt_key_src ^ (__force u32)rt2->rt_key_src) |
-		(rt1->rt_mark ^ rt2->rt_mark) |
-		(rt1->rt_key_tos ^ rt2->rt_key_tos) |
-		(rt1->rt_oif ^ rt2->rt_oif) |
-		(rt1->rt_iif ^ rt2->rt_iif)) == 0;
-}
-
-static inline int compare_netns(struct rtable *rt1, struct rtable *rt2)
-{
-	return net_eq(dev_net(rt1->dst.dev), dev_net(rt2->dst.dev));
-}
-
 static inline int rt_is_expired(struct rtable *rth)
 {
 	return rth->rt_genid != rt_genid(dev_net(rth->dst.dev));
 }
 
 /*
- * Perform a full scan of hash table and free all entries.
- * Can be called by a softirq or a process.
- * In the later case, we want to be reschedule if necessary
- */
-static void rt_do_flush(struct net *net, int process_context)
-{
-	unsigned int i;
-	struct rtable *rth, *next;
-
-	for (i = 0; i <= rt_hash_mask; i++) {
-		struct rtable __rcu **pprev;
-		struct rtable *list;
-
-		if (process_context && need_resched())
-			cond_resched();
-		rth = rcu_dereference_raw(rt_hash_table[i].chain);
-		if (!rth)
-			continue;
-
-		spin_lock_bh(rt_hash_lock_addr(i));
-
-		list = NULL;
-		pprev = &rt_hash_table[i].chain;
-		rth = rcu_dereference_protected(*pprev,
-			lockdep_is_held(rt_hash_lock_addr(i)));
-
-		while (rth) {
-			next = rcu_dereference_protected(rth->dst.rt_next,
-				lockdep_is_held(rt_hash_lock_addr(i)));
-
-			if (!net ||
-			    net_eq(dev_net(rth->dst.dev), net)) {
-				rcu_assign_pointer(*pprev, next);
-				rcu_assign_pointer(rth->dst.rt_next, list);
-				list = rth;
-			} else {
-				pprev = &rth->dst.rt_next;
-			}
-			rth = next;
-		}
-
-		spin_unlock_bh(rt_hash_lock_addr(i));
-
-		for (; list; list = next) {
-			next = rcu_dereference_protected(list->dst.rt_next, 1);
-			rt_free(list);
-		}
-	}
-}
-
-/*
- * While freeing expired entries, we compute average chain length
- * and standard deviation, using fixed-point arithmetic.
- * This to have an estimation of rt_chain_length_max
- *  rt_chain_length_max = max(elasticity, AVG + 4*SD)
- * We use 3 bits for frational part, and 29 (or 61) for magnitude.
- */
-
-#define FRACT_BITS 3
-#define ONE (1UL << FRACT_BITS)
-
-/*
- * Given a hash chain and an item in this hash chain,
- * find if a previous entry has the same hash_inputs
- * (but differs on tos, mark or oif)
- * Returns 0 if an alias is found.
- * Returns ONE if rth has no alias before itself.
- */
-static int has_noalias(const struct rtable *head, const struct rtable *rth)
-{
-	const struct rtable *aux = head;
-
-	while (aux != rth) {
-		if (compare_hash_inputs(aux, rth))
-			return 0;
-		aux = rcu_dereference_protected(aux->dst.rt_next, 1);
-	}
-	return ONE;
-}
-
-/*
  * Perturbation of rt_genid by a small quantity [1..256]
  * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
  * many times (2^24) without giving recent rt_genid.
@@ -841,346 +488,21 @@ static void rt_cache_invalidate(struct net *net)
 void rt_cache_flush(struct net *net, int delay)
 {
 	rt_cache_invalidate(net);
-	if (delay >= 0)
-		rt_do_flush(net, !in_softirq());
-}
-
-/* Flush previous cache invalidated entries from the cache */
-void rt_cache_flush_batch(struct net *net)
-{
-	rt_do_flush(net, !in_softirq());
 }
 
-static void rt_emergency_hash_rebuild(struct net *net)
+static struct rtable *rt_finalize(struct rtable *rt, struct sk_buff *skb)
 {
-	if (net_ratelimit())
-		printk(KERN_WARNING "Route hash chain too long!\n");
-	rt_cache_invalidate(net);
-}
-
-/*
-   Short description of GC goals.
-
-   We want to build algorithm, which will keep routing cache
-   at some equilibrium point, when number of aged off entries
-   is kept approximately equal to newly generated ones.
-
-   Current expiration strength is variable "expire".
-   We try to adjust it dynamically, so that if networking
-   is idle expires is large enough to keep enough of warm entries,
-   and when load increases it reduces to limit cache size.
- */
-
-static int rt_garbage_collect(struct dst_ops *ops)
-{
-	static unsigned long expire = RT_GC_TIMEOUT;
-	static unsigned long last_gc;
-	static int rover;
-	static int equilibrium;
-	struct rtable *rth;
-	struct rtable __rcu **rthp;
-	unsigned long now = jiffies;
-	int goal;
-	int entries = dst_entries_get_fast(&ipv4_dst_ops);
-
-	/*
-	 * Garbage collection is pretty expensive,
-	 * do not make it too frequently.
-	 */
-
-	RT_CACHE_STAT_INC(gc_total);
-
-	if (now - last_gc < ip_rt_gc_min_interval &&
-	    entries < ip_rt_max_size) {
-		RT_CACHE_STAT_INC(gc_ignored);
-		goto out;
-	}
-
-	entries = dst_entries_get_slow(&ipv4_dst_ops);
-	/* Calculate number of entries, which we want to expire now. */
-	goal = entries - (ip_rt_gc_elasticity << rt_hash_log);
-	if (goal <= 0) {
-		if (equilibrium < ipv4_dst_ops.gc_thresh)
-			equilibrium = ipv4_dst_ops.gc_thresh;
-		goal = entries - equilibrium;
-		if (goal > 0) {
-			equilibrium += min_t(unsigned int, goal >> 1, rt_hash_mask + 1);
-			goal = entries - equilibrium;
-		}
-	} else {
-		/* We are in dangerous area. Try to reduce cache really
-		 * aggressively.
-		 */
-		goal = max_t(unsigned int, goal >> 1, rt_hash_mask + 1);
-		equilibrium = entries - goal;
-	}
-
-	if (now - last_gc >= ip_rt_gc_min_interval)
-		last_gc = now;
-
-	if (goal <= 0) {
-		equilibrium += goal;
-		goto work_done;
-	}
-
-	do {
-		int i, k;
-
-		for (i = rt_hash_mask, k = rover; i >= 0; i--) {
-			unsigned long tmo = expire;
-
-			k = (k + 1) & rt_hash_mask;
-			rthp = &rt_hash_table[k].chain;
-			spin_lock_bh(rt_hash_lock_addr(k));
-			while ((rth = rcu_dereference_protected(*rthp,
-					lockdep_is_held(rt_hash_lock_addr(k)))) != NULL) {
-				if (!rt_is_expired(rth) &&
-					!rt_may_expire(rth, tmo, expire)) {
-					tmo >>= 1;
-					rthp = &rth->dst.rt_next;
-					continue;
-				}
-				*rthp = rth->dst.rt_next;
-				rt_free(rth);
-				goal--;
-			}
-			spin_unlock_bh(rt_hash_lock_addr(k));
-			if (goal <= 0)
-				break;
-		}
-		rover = k;
-
-		if (goal <= 0)
-			goto work_done;
-
-		/* Goal is not achieved. We stop process if:
-
-		   - if expire reduced to zero. Otherwise, expire is halfed.
-		   - if table is not full.
-		   - if we are called from interrupt.
-		   - jiffies check is just fallback/debug loop breaker.
-		     We will not spin here for long time in any case.
-		 */
-
-		RT_CACHE_STAT_INC(gc_goal_miss);
-
-		if (expire == 0)
-			break;
-
-		expire >>= 1;
-
-		if (dst_entries_get_fast(&ipv4_dst_ops) < ip_rt_max_size)
-			goto out;
-	} while (!in_softirq() && time_before_eq(jiffies, now));
-
-	if (dst_entries_get_fast(&ipv4_dst_ops) < ip_rt_max_size)
-		goto out;
-	if (dst_entries_get_slow(&ipv4_dst_ops) < ip_rt_max_size)
-		goto out;
-	if (net_ratelimit())
-		printk(KERN_WARNING "dst cache overflow\n");
-	RT_CACHE_STAT_INC(gc_dst_overflow);
-	return 1;
-
-work_done:
-	expire += ip_rt_gc_min_interval;
-	if (expire > ip_rt_gc_timeout ||
-	    dst_entries_get_fast(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh ||
-	    dst_entries_get_slow(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh)
-		expire = ip_rt_gc_timeout;
-out:	return 0;
-}
-
-/*
- * Returns number of entries in a hash chain that have different hash_inputs
- */
-static int slow_chain_length(const struct rtable *head)
-{
-	int length = 0;
-	const struct rtable *rth = head;
-
-	while (rth) {
-		length += has_noalias(head, rth);
-		rth = rcu_dereference_protected(rth->dst.rt_next, 1);
-	}
-	return length >> FRACT_BITS;
-}
-
-static struct rtable *rt_intern_hash(unsigned hash, struct rtable *rt,
-				     struct sk_buff *skb, int ifindex)
-{
-	struct rtable	*rth, *cand;
-	struct rtable __rcu **rthp, **candp;
-	unsigned long	now;
-	u32 		min_score;
-	int		chain_length;
-	int attempts = !in_softirq();
-
-restart:
-	chain_length = 0;
-	min_score = ~(u32)0;
-	cand = NULL;
-	candp = NULL;
-	now = jiffies;
-
-	if (!rt_caching(dev_net(rt->dst.dev))) {
-		/*
-		 * If we're not caching, just tell the caller we
-		 * were successful and don't touch the route.  The
-		 * caller hold the sole reference to the cache entry, and
-		 * it will be released when the caller is done with it.
-		 * If we drop it here, the callers have no way to resolve routes
-		 * when we're not caching.  Instead, just point *rp at rt, so
-		 * the caller gets a single use out of the route
-		 * Note that we do rt_free on this new route entry, so that
-		 * once its refcount hits zero, we are still able to reap it
-		 * (Thanks Alexey)
-		 * Note: To avoid expensive rcu stuff for this uncached dst,
-		 * we set DST_NOCACHE so that dst_release() can free dst without
-		 * waiting a grace period.
-		 */
-
-		rt->dst.flags |= DST_NOCACHE;
-		if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-			int err = arp_bind_neighbour(&rt->dst);
-			if (err) {
-				if (net_ratelimit())
-					printk(KERN_WARNING
-					    "Neighbour table failure & not caching routes.\n");
-				ip_rt_put(rt);
-				return ERR_PTR(err);
-			}
-		}
-
-		goto skip_hashing;
-	}
-
-	rthp = &rt_hash_table[hash].chain;
-
-	spin_lock_bh(rt_hash_lock_addr(hash));
-	while ((rth = rcu_dereference_protected(*rthp,
-			lockdep_is_held(rt_hash_lock_addr(hash)))) != NULL) {
-		if (rt_is_expired(rth)) {
-			*rthp = rth->dst.rt_next;
-			rt_free(rth);
-			continue;
-		}
-		if (compare_keys(rth, rt) && compare_netns(rth, rt)) {
-			/* Put it first */
-			*rthp = rth->dst.rt_next;
-			/*
-			 * Since lookup is lockfree, the deletion
-			 * must be visible to another weakly ordered CPU before
-			 * the insertion at the start of the hash chain.
-			 */
-			rcu_assign_pointer(rth->dst.rt_next,
-					   rt_hash_table[hash].chain);
-			/*
-			 * Since lookup is lockfree, the update writes
-			 * must be ordered for consistency on SMP.
-			 */
-			rcu_assign_pointer(rt_hash_table[hash].chain, rth);
-
-			dst_use(&rth->dst, now);
-			spin_unlock_bh(rt_hash_lock_addr(hash));
-
-			rt_drop(rt);
-			if (skb)
-				skb_dst_set(skb, &rth->dst);
-			return rth;
-		}
-
-		if (!atomic_read(&rth->dst.__refcnt)) {
-			u32 score = rt_score(rth);
-
-			if (score <= min_score) {
-				cand = rth;
-				candp = rthp;
-				min_score = score;
-			}
-		}
-
-		chain_length++;
-
-		rthp = &rth->dst.rt_next;
-	}
-
-	if (cand) {
-		/* ip_rt_gc_elasticity used to be average length of chain
-		 * length, when exceeded gc becomes really aggressive.
-		 *
-		 * The second limit is less certain. At the moment it allows
-		 * only 2 entries per bucket. We will see.
-		 */
-		if (chain_length > ip_rt_gc_elasticity) {
-			*candp = cand->dst.rt_next;
-			rt_free(cand);
-		}
-	} else {
-		if (chain_length > rt_chain_length_max &&
-		    slow_chain_length(rt_hash_table[hash].chain) > rt_chain_length_max) {
-			struct net *net = dev_net(rt->dst.dev);
-			int num = ++net->ipv4.current_rt_cache_rebuild_count;
-			if (!rt_caching(net)) {
-				printk(KERN_WARNING "%s: %d rebuilds is over limit, route caching disabled\n",
-					rt->dst.dev->name, num);
-			}
-			rt_emergency_hash_rebuild(net);
-			spin_unlock_bh(rt_hash_lock_addr(hash));
-
-			hash = rt_hash(rt->rt_key_dst, rt->rt_key_src,
-					ifindex, rt_genid(net));
-			goto restart;
-		}
-	}
-
-	/* Try to bind route to arp only if it is output
-	   route or unicast forwarding path.
-	 */
 	if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
 		int err = arp_bind_neighbour(&rt->dst);
 		if (err) {
-			spin_unlock_bh(rt_hash_lock_addr(hash));
-
-			if (err != -ENOBUFS) {
-				rt_drop(rt);
-				return ERR_PTR(err);
-			}
-
-			/* Neighbour tables are full and nothing
-			   can be released. Try to shrink route cache,
-			   it is most likely it holds some neighbour records.
-			 */
-			if (attempts-- > 0) {
-				int saved_elasticity = ip_rt_gc_elasticity;
-				int saved_int = ip_rt_gc_min_interval;
-				ip_rt_gc_elasticity	= 1;
-				ip_rt_gc_min_interval	= 0;
-				rt_garbage_collect(&ipv4_dst_ops);
-				ip_rt_gc_min_interval	= saved_int;
-				ip_rt_gc_elasticity	= saved_elasticity;
-				goto restart;
-			}
-
 			if (net_ratelimit())
-				printk(KERN_WARNING "ipv4: Neighbour table overflow.\n");
-			rt_drop(rt);
-			return ERR_PTR(-ENOBUFS);
+				printk(KERN_WARNING
+				       "Neighbour table failure & not caching routes.\n");
+			ip_rt_put(rt);
+			return ERR_PTR(err);
 		}
 	}
 
-	rt->dst.rt_next = rt_hash_table[hash].chain;
-
-	/*
-	 * Since lookup is lockfree, we must make sure
-	 * previous writes to rt are committed to memory
-	 * before making rt visible to other CPUS.
-	 */
-	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
-
-	spin_unlock_bh(rt_hash_lock_addr(hash));
-
-skip_hashing:
 	if (skb)
 		skb_dst_set(skb, &rt->dst);
 	return rt;
@@ -1248,26 +570,6 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 }
 EXPORT_SYMBOL(__ip_select_ident);
 
-static void rt_del(unsigned hash, struct rtable *rt)
-{
-	struct rtable __rcu **rthp;
-	struct rtable *aux;
-
-	rthp = &rt_hash_table[hash].chain;
-	spin_lock_bh(rt_hash_lock_addr(hash));
-	ip_rt_put(rt);
-	while ((aux = rcu_dereference_protected(*rthp,
-			lockdep_is_held(rt_hash_lock_addr(hash)))) != NULL) {
-		if (aux == rt || rt_is_expired(aux)) {
-			*rthp = aux->dst.rt_next;
-			rt_free(aux);
-			continue;
-		}
-		rthp = &aux->dst.rt_next;
-	}
-	spin_unlock_bh(rt_hash_lock_addr(hash));
-}
-
 /* called in rcu_read_lock() section */
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
@@ -1343,10 +645,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 			ip_rt_put(rt);
 			ret = NULL;
 		} else if (rt->rt_flags & RTCF_REDIRECTED) {
-			unsigned hash = rt_hash(rt->rt_key_dst, rt->rt_key_src,
-						rt->rt_oif,
-						rt_genid(dev_net(dst->dev)));
-			rt_del(hash, rt);
+			ip_rt_put(rt);
 			ret = NULL;
 		} else if (rt->peer && peer_pmtu_expired(rt->peer)) {
 			dst_metric_set(dst, RTAX_MTU, rt->peer->pmtu_orig);
@@ -1827,7 +1126,7 @@ static struct rtable *rt_dst_alloc(struct net_device *dev,
 				   bool nopolicy, bool noxfrm)
 {
 	return dst_alloc(&ipv4_dst_ops, dev, 1, -1,
-			 DST_HOST |
+			 DST_HOST | DST_NOCACHE |
 			 (nopolicy ? DST_NOPOLICY : 0) |
 			 (noxfrm ? DST_NOXFRM : 0));
 }
@@ -1836,7 +1135,6 @@ static struct rtable *rt_dst_alloc(struct net_device *dev,
 static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 				u8 tos, struct net_device *dev, int our)
 {
-	unsigned int hash;
 	struct rtable *rth;
 	__be32 spec_dst;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
@@ -1900,8 +1198,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	RT_CACHE_STAT_INC(in_slow_mc);
 
-	hash = rt_hash(daddr, saddr, dev->ifindex, rt_genid(dev_net(dev)));
-	rth = rt_intern_hash(hash, rth, skb, dev->ifindex);
+	rth = rt_finalize(rth, skb);
 	return IS_ERR(rth) ? PTR_ERR(rth) : 0;
 
 e_nobufs:
@@ -2044,7 +1341,6 @@ static int ip_mkroute_input(struct sk_buff *skb,
 {
 	struct rtable* rth = NULL;
 	int err;
-	unsigned hash;
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1)
@@ -2056,10 +1352,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	if (err)
 		return err;
 
-	/* put it into the cache */
-	hash = rt_hash(daddr, saddr, fl4->flowi4_iif,
-		       rt_genid(dev_net(rth->dst.dev)));
-	rth = rt_intern_hash(hash, rth, skb, fl4->flowi4_iif);
+	rth = rt_finalize(rth, skb);
 	if (IS_ERR(rth))
 		return PTR_ERR(rth);
 	return 0;
@@ -2085,7 +1378,6 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	unsigned	flags = 0;
 	u32		itag = 0;
 	struct rtable * rth;
-	unsigned	hash;
 	__be32		spec_dst;
 	int		err = -EINVAL;
 	struct net    * net = dev_net(dev);
@@ -2212,8 +1504,7 @@ local_input:
 		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
-	hash = rt_hash(daddr, saddr, fl4.flowi4_iif, rt_genid(net));
-	rth = rt_intern_hash(hash, rth, skb, fl4.flowi4_iif);
+	rth = rt_finalize(rth, skb);
 	err = 0;
 	if (IS_ERR(rth))
 		err = PTR_ERR(rth);
@@ -2260,47 +1551,10 @@ martian_source_keep_err:
 int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			   u8 tos, struct net_device *dev, bool noref)
 {
-	struct rtable * rth;
-	unsigned	hash;
-	int iif = dev->ifindex;
-	struct net *net;
 	int res;
 
-	net = dev_net(dev);
-
 	rcu_read_lock();
 
-	if (!rt_caching(net))
-		goto skip_cache;
-
-	tos &= IPTOS_RT_MASK;
-	hash = rt_hash(daddr, saddr, iif, rt_genid(net));
-
-	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
-	     rth = rcu_dereference(rth->dst.rt_next)) {
-		if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
-		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
-		     (rth->rt_iif ^ iif) |
-		     rth->rt_oif |
-		     (rth->rt_key_tos ^ tos)) == 0 &&
-		    rth->rt_mark == skb->mark &&
-		    net_eq(dev_net(rth->dst.dev), net) &&
-		    !rt_is_expired(rth)) {
-			if (noref) {
-				dst_use_noref(&rth->dst, jiffies);
-				skb_dst_set_noref(skb, &rth->dst);
-			} else {
-				dst_use(&rth->dst, jiffies);
-				skb_dst_set(skb, &rth->dst);
-			}
-			RT_CACHE_STAT_INC(in_hit);
-			rcu_read_unlock();
-			return 0;
-		}
-		RT_CACHE_STAT_INC(in_hlist_search);
-	}
-
-skip_cache:
 	/* Multicast recognition logic is moved from route cache to here.
 	   The problem was that too many Ethernet cards have broken/missing
 	   hardware multicast filters :-( As result the host on multicasting
@@ -2443,10 +1697,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 /*
  * Major route resolver routine.
- * called with rcu_read_lock();
  */
 
-static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
+struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 {
 	struct net_device *dev_out = NULL;
 	u32 tos	= RT_FL_TOS(fl4);
@@ -2626,57 +1879,13 @@ static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 make_route:
 	rth = __mkroute_output(&res, fl4, orig_daddr, orig_saddr, orig_oif,
 			       dev_out, flags);
-	if (!IS_ERR(rth)) {
-		unsigned int hash;
-
-		hash = rt_hash(orig_daddr, orig_saddr, orig_oif,
-			       rt_genid(dev_net(dev_out)));
-		rth = rt_intern_hash(hash, rth, NULL, orig_oif);
-	}
+	if (!IS_ERR(rth))
+		rth = rt_finalize(rth, NULL);
 
 out:
 	rcu_read_unlock();
 	return rth;
 }
-
-struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
-{
-	struct rtable *rth;
-	unsigned int hash;
-
-	if (!rt_caching(net))
-		goto slow_output;
-
-	hash = rt_hash(flp4->daddr, flp4->saddr, flp4->flowi4_oif, rt_genid(net));
-
-	rcu_read_lock_bh();
-	for (rth = rcu_dereference_bh(rt_hash_table[hash].chain); rth;
-		rth = rcu_dereference_bh(rth->dst.rt_next)) {
-		if (rth->rt_key_dst == flp4->daddr &&
-		    rth->rt_key_src == flp4->saddr &&
-		    rt_is_output_route(rth) &&
-		    rth->rt_oif == flp4->flowi4_oif &&
-		    rth->rt_mark == flp4->flowi4_mark &&
-		    !((rth->rt_key_tos ^ flp4->flowi4_tos) &
-			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
-		    net_eq(dev_net(rth->dst.dev), net) &&
-		    !rt_is_expired(rth)) {
-			dst_use(&rth->dst, jiffies);
-			RT_CACHE_STAT_INC(out_hit);
-			rcu_read_unlock_bh();
-			if (!flp4->saddr)
-				flp4->saddr = rth->rt_src;
-			if (!flp4->daddr)
-				flp4->daddr = rth->rt_dst;
-			return rth;
-		}
-		RT_CACHE_STAT_INC(out_hlist_search);
-	}
-	rcu_read_unlock_bh();
-
-slow_output:
-	return ip_route_output_slow(net, flp4);
-}
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
 static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 cookie)
@@ -2975,43 +2184,6 @@ errout_free:
 
 int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 {
-	struct rtable *rt;
-	int h, s_h;
-	int idx, s_idx;
-	struct net *net;
-
-	net = sock_net(skb->sk);
-
-	s_h = cb->args[0];
-	if (s_h < 0)
-		s_h = 0;
-	s_idx = idx = cb->args[1];
-	for (h = s_h; h <= rt_hash_mask; h++, s_idx = 0) {
-		if (!rt_hash_table[h].chain)
-			continue;
-		rcu_read_lock_bh();
-		for (rt = rcu_dereference_bh(rt_hash_table[h].chain), idx = 0; rt;
-		     rt = rcu_dereference_bh(rt->dst.rt_next), idx++) {
-			if (!net_eq(dev_net(rt->dst.dev), net) || idx < s_idx)
-				continue;
-			if (rt_is_expired(rt))
-				continue;
-			skb_dst_set_noref(skb, &rt->dst);
-			if (rt_fill_info(net, skb, NETLINK_CB(cb->skb).pid,
-					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
-					 1, NLM_F_MULTI) <= 0) {
-				skb_dst_drop(skb);
-				rcu_read_unlock_bh();
-				goto done;
-			}
-			skb_dst_drop(skb);
-		}
-		rcu_read_unlock_bh();
-	}
-
-done:
-	cb->args[0] = h;
-	cb->args[1] = idx;
 	return skb->len;
 }
 
@@ -3246,16 +2418,6 @@ static __net_initdata struct pernet_operations rt_genid_ops = {
 struct ip_rt_acct __percpu *ip_rt_acct __read_mostly;
 #endif /* CONFIG_IP_ROUTE_CLASSID */
 
-static __initdata unsigned long rhash_entries;
-static int __init set_rhash_entries(char *str)
-{
-	if (!str)
-		return 0;
-	rhash_entries = simple_strtoul(str, &str, 0);
-	return 1;
-}
-__setup("rhash_entries=", set_rhash_entries);
-
 int __init ip_rt_init(void)
 {
 	int rc = 0;
@@ -3278,21 +2440,8 @@ int __init ip_rt_init(void)
 	if (dst_entries_init(&ipv4_dst_blackhole_ops) < 0)
 		panic("IP: failed to allocate ipv4_dst_blackhole_ops counter\n");
 
-	rt_hash_table = (struct rt_hash_bucket *)
-		alloc_large_system_hash("IP route cache",
-					sizeof(struct rt_hash_bucket),
-					rhash_entries,
-					(totalram_pages >= 128 * 1024) ?
-					15 : 17,
-					0,
-					&rt_hash_log,
-					&rt_hash_mask,
-					rhash_entries ? 0 : 512 * 1024);
-	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash_bucket));
-	rt_hash_lock_init();
-
-	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
-	ip_rt_max_size = (rt_hash_mask + 1) * 16;
+	ipv4_dst_ops.gc_thresh = ~0;
+	ip_rt_max_size = INT_MAX;
 
 	devinet_init();
 	ip_fib_init();
-- 
1.7.5.4

