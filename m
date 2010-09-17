From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: add rcu annotations in route.c
Date: Fri, 17 Sep 2010 17:59:19 +0200
Message-ID: <1284739159.3391.95.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39893 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab0IQP7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 11:59:24 -0400
Received: by wwb39 with SMTP id 39so1018555wwb.1
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 08:59:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use __rcu attribute where appropriate.

Use rcu_dereference_raw() in contexts where no lock is held.

Use rcu_dereference_check() in contexts where the chain spinlock is
held.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
tested with CONFIG_PROVE_RCU=y

 include/net/dst.h |    2 
 net/ipv4/route.c  |  182 ++++++++++++++++++++++++++------------------
 2 files changed, 110 insertions(+), 74 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 81d1413..ce4a9b9 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -94,7 +94,7 @@ struct dst_entry {
 	unsigned long		lastuse;
 	union {
 		struct dst_entry *next;
-		struct rtable    *rt_next;
+		struct rtable __rcu *rt_next;
 		struct rt6_info   *rt6_next;
 		struct dn_route  *dn_next;
 	};
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e24d48d..d011911 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -199,7 +199,7 @@ const __u8 ip_tos2prio[16] = {
  */
 
 struct rt_hash_bucket {
-	struct rtable	*chain;
+	struct rtable __rcu	*chain;
 };
 
 #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
@@ -249,7 +249,7 @@ static inline void rt_hash_lock_init(void)
 #endif
 
 static struct rt_hash_bucket 	*rt_hash_table __read_mostly;
-static unsigned			rt_hash_mask __read_mostly;
+static unsigned int		rt_hash_mask __read_mostly;
 static unsigned int		rt_hash_log  __read_mostly;
 
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
@@ -281,7 +281,7 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 	struct rtable *r = NULL;
 
 	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
-		if (!rt_hash_table[st->bucket].chain)
+		if (!rcu_dereference_raw(rt_hash_table[st->bucket].chain))
 			continue;
 		rcu_read_lock_bh();
 		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
@@ -301,23 +301,24 @@ static struct rtable *__rt_cache_get_next(struct seq_file *seq,
 {
 	struct rt_cache_iter_state *st = seq->private;
 
-	r = r->dst.rt_next;
+	r = rcu_dereference_bh(r->dst.rt_next);
 	while (!r) {
 		rcu_read_unlock_bh();
 		do {
 			if (--st->bucket < 0)
 				return NULL;
-		} while (!rt_hash_table[st->bucket].chain);
+		} while (!rcu_dereference_raw(rt_hash_table[st->bucket].chain));
 		rcu_read_lock_bh();
-		r = rt_hash_table[st->bucket].chain;
+		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
 	}
-	return rcu_dereference_bh(r);
+	return r;
 }
 
 static struct rtable *rt_cache_get_next(struct seq_file *seq,
 					struct rtable *r)
 {
 	struct rt_cache_iter_state *st = seq->private;
+
 	while ((r = __rt_cache_get_next(seq, r)) != NULL) {
 		if (dev_net(r->dst.dev) != seq_file_net(seq))
 			continue;
@@ -340,6 +341,7 @@ static struct rtable *rt_cache_get_idx(struct seq_file *seq, loff_t pos)
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct rt_cache_iter_state *st = seq->private;
+
 	if (*pos)
 		return rt_cache_get_idx(seq, *pos - 1);
 	st->genid = rt_genid(seq_file_net(seq));
@@ -622,7 +624,7 @@ static inline int rt_fast_clean(struct rtable *rth)
 	/* Kill broadcast/multicast entries very aggresively, if they
 	   collide in hash table with more useful entries */
 	return (rth->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)) &&
-		rth->fl.iif && rth->dst.rt_next;
+		rth->fl.iif && rcu_dereference_raw(rth->dst.rt_next);
 }
 
 static inline int rt_valuable(struct rtable *rth)
@@ -708,6 +710,9 @@ static inline int rt_is_expired(struct rtable *rth)
 	return rth->rt_genid != rt_genid(dev_net(rth->dst.dev));
 }
 
+#define rt_safederef(X, LOCKP) \
+	rcu_dereference_check(X, lockdep_is_held(LOCKP))
+
 /*
  * Perform a full scan of hash table and free all entries.
  * Can be called by a softirq or a process.
@@ -716,51 +721,55 @@ static inline int rt_is_expired(struct rtable *rth)
 static void rt_do_flush(int process_context)
 {
 	unsigned int i;
-	struct rtable *rth, *next;
-	struct rtable * tail;
+	struct rtable *rth, *next, *tail;
+	spinlock_t *lockp;
 
 	for (i = 0; i <= rt_hash_mask; i++) {
 		if (process_context && need_resched())
 			cond_resched();
-		rth = rt_hash_table[i].chain;
+		rth = rcu_dereference_raw(rt_hash_table[i].chain);
 		if (!rth)
 			continue;
 
-		spin_lock_bh(rt_hash_lock_addr(i));
+		lockp = rt_hash_lock_addr(i);
+		spin_lock_bh(lockp);
 #ifdef CONFIG_NET_NS
 		{
-		struct rtable ** prev, * p;
+		struct rtable __rcu **prev;
+		struct rtable *p;
 
-		rth = rt_hash_table[i].chain;
+		rth = rt_safederef(rt_hash_table[i].chain, lockp);
 
 		/* defer releasing the head of the list after spin_unlock */
-		for (tail = rth; tail; tail = tail->dst.rt_next)
+		for (tail = rth; tail != NULL;
+		     tail = rt_safederef(tail->dst.rt_next, lockp))
 			if (!rt_is_expired(tail))
 				break;
+
 		if (rth != tail)
-			rt_hash_table[i].chain = tail;
+			rcu_assign_pointer(rt_hash_table[i].chain, tail);
 
 		/* call rt_free on entries after the tail requiring flush */
 		prev = &rt_hash_table[i].chain;
-		for (p = *prev; p; p = next) {
-			next = p->dst.rt_next;
+		for (p = rt_safederef(*prev, lockp); p; p = next) {
+			next = rt_safederef(p->dst.rt_next, lockp);
 			if (!rt_is_expired(p)) {
 				prev = &p->dst.rt_next;
 			} else {
-				*prev = next;
+				rcu_assign_pointer(*prev, next);
 				rt_free(p);
 			}
 		}
 		}
 #else
-		rth = rt_hash_table[i].chain;
-		rt_hash_table[i].chain = NULL;
+		rth = rt_safederef(rt_hash_table[i].chain, lockp);
+		rcu_assign_pointer(rt_hash_table[i].chain, NULL);
 		tail = NULL;
 #endif
-		spin_unlock_bh(rt_hash_lock_addr(i));
+		spin_unlock_bh(lockp);
 
 		for (; rth != tail; rth = next) {
-			next = rth->dst.rt_next;
+			next = rcu_dereference_raw(rth->dst.rt_next);
 			rt_free(rth);
 		}
 	}
@@ -784,14 +793,15 @@ static void rt_do_flush(int process_context)
  * Returns 0 if an alias is found.
  * Returns ONE if rth has no alias before itself.
  */
-static int has_noalias(const struct rtable *head, const struct rtable *rth)
+static int has_noalias(const struct rtable *head, const struct rtable *rth,
+		       spinlock_t *lockp)
 {
 	const struct rtable *aux = head;
 
 	while (aux != rth) {
 		if (compare_hash_inputs(&aux->fl, &rth->fl))
 			return 0;
-		aux = aux->dst.rt_next;
+		aux = rt_safederef(aux->dst.rt_next, lockp);
 	}
 	return ONE;
 }
@@ -800,7 +810,8 @@ static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i = rover, goal;
-	struct rtable *rth, **rthp;
+	struct rtable *rth;
+	struct rtable __rcu **rthp;
 	unsigned long samples = 0;
 	unsigned long sum = 0, sum2 = 0;
 	unsigned long delta;
@@ -817,6 +828,7 @@ static void rt_check_expire(void)
 	for (; goal > 0; goal--) {
 		unsigned long tmo = ip_rt_gc_timeout;
 		unsigned long length;
+		spinlock_t *lockp;
 
 		i = (i + 1) & rt_hash_mask;
 		rthp = &rt_hash_table[i].chain;
@@ -826,14 +838,16 @@ static void rt_check_expire(void)
 
 		samples++;
 
-		if (*rthp == NULL)
+		if (rcu_dereference_raw(*rthp) == NULL)
 			continue;
 		length = 0;
-		spin_lock_bh(rt_hash_lock_addr(i));
-		while ((rth = *rthp) != NULL) {
-			prefetch(rth->dst.rt_next);
+		lockp = rt_hash_lock_addr(i);
+		spin_lock_bh(lockp);
+		while ((rth = rt_safederef(*rthp, lockp)) != NULL) {
+			prefetch(rcu_dereference_raw(rth->dst.rt_next));
 			if (rt_is_expired(rth)) {
-				*rthp = rth->dst.rt_next;
+				rcu_assign_pointer(*rthp,
+					rt_safederef(rth->dst.rt_next, lockp));
 				rt_free(rth);
 				continue;
 			}
@@ -851,17 +865,18 @@ nofree:
 					 * attributes don't unfairly skew
 					 * the length computation
 					 */
-					length += has_noalias(rt_hash_table[i].chain, rth);
+					length += has_noalias(rt_hash_table[i].chain, rth, lockp);
 					continue;
 				}
 			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
 				goto nofree;
 
 			/* Cleanup aged off entries. */
-			*rthp = rth->dst.rt_next;
+			rcu_assign_pointer(*rthp,
+				rt_safederef(rth->dst.rt_next, lockp));
 			rt_free(rth);
 		}
-		spin_unlock_bh(rt_hash_lock_addr(i));
+		spin_unlock_bh(lockp);
 		sum += length;
 		sum2 += length*length;
 	}
@@ -942,7 +957,8 @@ static int rt_garbage_collect(struct dst_ops *ops)
 	static unsigned long last_gc;
 	static int rover;
 	static int equilibrium;
-	struct rtable *rth, **rthp;
+	struct rtable *rth;
+	struct rtable __rcu **rthp;
 	unsigned long now = jiffies;
 	int goal;
 
@@ -991,22 +1007,25 @@ static int rt_garbage_collect(struct dst_ops *ops)
 
 		for (i = rt_hash_mask, k = rover; i >= 0; i--) {
 			unsigned long tmo = expire;
+			spinlock_t *lockp;
 
 			k = (k + 1) & rt_hash_mask;
 			rthp = &rt_hash_table[k].chain;
-			spin_lock_bh(rt_hash_lock_addr(k));
-			while ((rth = *rthp) != NULL) {
+			lockp = rt_hash_lock_addr(k);
+			spin_lock_bh(lockp);
+			while ((rth = rt_safederef(*rthp, lockp)) != NULL) {
 				if (!rt_is_expired(rth) &&
 					!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
 					rthp = &rth->dst.rt_next;
 					continue;
 				}
-				*rthp = rth->dst.rt_next;
+				rcu_assign_pointer(*rthp,
+					rt_safederef(rth->dst.rt_next, lockp));
 				rt_free(rth);
 				goal--;
 			}
-			spin_unlock_bh(rt_hash_lock_addr(k));
+			spin_unlock_bh(lockp);
 			if (goal <= 0)
 				break;
 		}
@@ -1061,27 +1080,30 @@ out:	return 0;
 /*
  * Returns number of entries in a hash chain that have different hash_inputs
  */
-static int slow_chain_length(const struct rtable *head)
+static int slow_chain_length(const struct rtable *head, spinlock_t *lockp)
 {
 	int length = 0;
 	const struct rtable *rth = head;
 
 	while (rth) {
-		length += has_noalias(head, rth);
-		rth = rth->dst.rt_next;
+		length += has_noalias(head, rth, lockp);
+		rth = rt_safederef(rth->dst.rt_next, lockp);
 	}
 	return length >> FRACT_BITS;
 }
 
-static int rt_intern_hash(unsigned hash, struct rtable *rt,
+static int rt_intern_hash(unsigned int hash, struct rtable *rt,
 			  struct rtable **rp, struct sk_buff *skb, int ifindex)
 {
-	struct rtable	*rth, **rthp;
+	struct rtable	*rth;
+	struct rtable __rcu **rthp;
 	unsigned long	now;
-	struct rtable *cand, **candp;
+	struct rtable *cand;
+	struct rtable __rcu **candp;
 	u32 		min_score;
 	int		chain_length;
 	int attempts = !in_softirq();
+	spinlock_t	*lockp;
 
 restart:
 	chain_length = 0;
@@ -1124,23 +1146,26 @@ restart:
 
 	rthp = &rt_hash_table[hash].chain;
 
-	spin_lock_bh(rt_hash_lock_addr(hash));
-	while ((rth = *rthp) != NULL) {
+	lockp = rt_hash_lock_addr(hash);
+	spin_lock_bh(lockp);
+	while ((rth = rt_safederef(*rthp, lockp)) != NULL) {
 		if (rt_is_expired(rth)) {
-			*rthp = rth->dst.rt_next;
+			rcu_assign_pointer(*rthp,
+				rt_safederef(rth->dst.rt_next, lockp));
 			rt_free(rth);
 			continue;
 		}
 		if (compare_keys(&rth->fl, &rt->fl) && compare_netns(rth, rt)) {
 			/* Put it first */
-			*rthp = rth->dst.rt_next;
+			rcu_assign_pointer(*rthp,
+				rt_safederef(rth->dst.rt_next, lockp));
 			/*
 			 * Since lookup is lockfree, the deletion
 			 * must be visible to another weakly ordered CPU before
 			 * the insertion at the start of the hash chain.
 			 */
 			rcu_assign_pointer(rth->dst.rt_next,
-					   rt_hash_table[hash].chain);
+				rt_safederef(rt_hash_table[hash].chain, lockp));
 			/*
 			 * Since lookup is lockfree, the update writes
 			 * must be ordered for consistency on SMP.
@@ -1148,7 +1173,7 @@ restart:
 			rcu_assign_pointer(rt_hash_table[hash].chain, rth);
 
 			dst_use(&rth->dst, now);
-			spin_unlock_bh(rt_hash_lock_addr(hash));
+			spin_unlock_bh(lockp);
 
 			rt_drop(rt);
 			if (rp)
@@ -1181,12 +1206,15 @@ restart:
 		 * only 2 entries per bucket. We will see.
 		 */
 		if (chain_length > ip_rt_gc_elasticity) {
-			*candp = cand->dst.rt_next;
+			rcu_assign_pointer(*candp,
+				rt_safederef(cand->dst.rt_next, lockp));
 			rt_free(cand);
 		}
 	} else {
 		if (chain_length > rt_chain_length_max &&
-		    slow_chain_length(rt_hash_table[hash].chain) > rt_chain_length_max) {
+		    slow_chain_length(rt_safederef(rt_hash_table[hash].chain,
+							  lockp),
+				      lockp) > rt_chain_length_max) {
 			struct net *net = dev_net(rt->dst.dev);
 			int num = ++net->ipv4.current_rt_cache_rebuild_count;
 			if (!rt_caching(net)) {
@@ -1194,7 +1222,7 @@ restart:
 					rt->dst.dev->name, num);
 			}
 			rt_emergency_hash_rebuild(net);
-			spin_unlock_bh(rt_hash_lock_addr(hash));
+			spin_unlock_bh(lockp);
 
 			hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
 					ifindex, rt_genid(net));
@@ -1208,7 +1236,7 @@ restart:
 	if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
 		int err = arp_bind_neighbour(&rt->dst);
 		if (err) {
-			spin_unlock_bh(rt_hash_lock_addr(hash));
+			spin_unlock_bh(lockp);
 
 			if (err != -ENOBUFS) {
 				rt_drop(rt);
@@ -1237,14 +1265,17 @@ restart:
 		}
 	}
 
-	rt->dst.rt_next = rt_hash_table[hash].chain;
+	rcu_assign_pointer(rt->dst.rt_next,
+		rt_safederef(rt_hash_table[hash].chain, lockp));
 
 #if RT_CACHE_DEBUG >= 2
-	if (rt->dst.rt_next) {
+	if (rt_safederef(rt->dst.rt_next, lockp)) {
 		struct rtable *trt;
 		printk(KERN_DEBUG "rt_cache @%02x: %pI4",
 		       hash, &rt->rt_dst);
-		for (trt = rt->dst.rt_next; trt; trt = trt->dst.rt_next)
+		for (trt = rt_safederef(rt->dst.rt_next, lockp);
+		     trt;
+		     trt = rt_safederef(trt->dst.rt_next, lockp))
 			printk(" . %pI4", &trt->rt_dst);
 		printk("\n");
 	}
@@ -1256,7 +1287,7 @@ restart:
 	 */
 	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
 
-	spin_unlock_bh(rt_hash_lock_addr(hash));
+	spin_unlock_bh(lockp);
 
 skip_hashing:
 	if (rp)
@@ -1319,22 +1350,26 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 }
 EXPORT_SYMBOL(__ip_select_ident);
 
-static void rt_del(unsigned hash, struct rtable *rt)
+static void rt_del(unsigned int hash, struct rtable *rt)
 {
-	struct rtable **rthp, *aux;
+	struct rtable __rcu **rthp;
+	struct rtable *aux;
+	spinlock_t *lockp = rt_hash_lock_addr(hash);
 
 	rthp = &rt_hash_table[hash].chain;
-	spin_lock_bh(rt_hash_lock_addr(hash));
+
+	spin_lock_bh(lockp);
 	ip_rt_put(rt);
-	while ((aux = *rthp) != NULL) {
+	while ((aux = rt_safederef(*rthp, lockp)) != NULL) {
 		if (aux == rt || rt_is_expired(aux)) {
-			*rthp = aux->dst.rt_next;
+			rcu_assign_pointer(*rthp,
+				rt_safederef(aux->dst.rt_next, lockp));
 			rt_free(aux);
 			continue;
 		}
 		rthp = &aux->dst.rt_next;
 	}
-	spin_unlock_bh(rt_hash_lock_addr(hash));
+	spin_unlock_bh(lockp);
 }
 
 /* called in rcu_read_lock() section */
@@ -1343,7 +1378,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 {
 	int i, k;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	struct rtable *rth, **rthp;
+	struct rtable *rth;
+	struct rtable __rcu **rthp;
 	__be32  skeys[2] = { saddr, 0 };
 	int  ikeys[2] = { dev->ifindex, 0 };
 	struct netevent_redirect netevent;
@@ -1373,10 +1409,10 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 
 	for (i = 0; i < 2; i++) {
 		for (k = 0; k < 2; k++) {
-			unsigned hash = rt_hash(daddr, skeys[i], ikeys[k],
+			unsigned int hash = rt_hash(daddr, skeys[i], ikeys[k],
 						rt_genid(net));
 
-			rthp=&rt_hash_table[hash].chain;
+			rthp = &rt_hash_table[hash].chain;
 
 			while ((rth = rcu_dereference(*rthp)) != NULL) {
 				struct rtable *rt;
@@ -1484,7 +1520,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
 			   (rt->dst.expires &&
 			    time_after_eq(jiffies, rt->dst.expires))) {
-			unsigned hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
+			unsigned int hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
 						rt->fl.oif,
 						rt_genid(dev_net(dst->dev)));
 #if RT_CACHE_DEBUG >= 1
@@ -2052,7 +2088,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
-	struct rtable* rth = NULL;
+	struct rtable *rth = NULL;
 	int err;
 	unsigned hash;
 
@@ -2097,12 +2133,12 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			    .iif = dev->ifindex };
 	unsigned	flags = 0;
 	u32		itag = 0;
-	struct rtable * rth;
+	struct rtable	*rth;
 	unsigned	hash;
 	__be32		spec_dst;
 	int		err = -EINVAL;
 	int		free_res = 0;
-	struct net    * net = dev_net(dev);
+	struct net	*net = dev_net(dev);
 
 	/* IP on this device is disabled. */
 
@@ -2696,7 +2732,7 @@ out:	return err;
 int __ip_route_output_key(struct net *net, struct rtable **rp,
 			  const struct flowi *flp)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct rtable *rth;
 
 	if (!rt_caching(net))


