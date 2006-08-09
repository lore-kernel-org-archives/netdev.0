From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2]: [IPV4] route: Locking infrastructure for dynamic
 routing cache sizing.
Date: Wed, 09 Aug 2006 00:53:10 -0700 (PDT)
Message-ID: <20060809.005310.108740577.davem@davemloft.net>
References: <20060809.004920.59469729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21146
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964961AbWHIHx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:53:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 25651AE43C3
	for <netdev@vger.kernel.org>; Wed,  9 Aug 2006 00:53:10 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <20060809.004920.59469729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[IPV4] route: Locking infrastructure for dynamic routing cache sizing.

The basic idea is to wrap captures of the hash table base and hash
mask inside of a seqlock sequence.

The rest of the locking remains unchanged.

Furthermore, rt_hash_table and rt_hash_mask have two-underscores
prepended to their names in order to show that they must be accessed
in a special way.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |  259 ++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 172 insertions(+), 87 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 19bd49d..a7b4ca2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -93,6 +93,7 @@ #include <linux/random.h>
 #include <linux/jhash.h>
 #include <linux/rcupdate.h>
 #include <linux/times.h>
+#include <linux/seqlock.h>
 #include <net/protocol.h>
 #include <net/ip.h>
 #include <net/route.h>
@@ -243,37 +244,86 @@ # define rt_hash_lock_addr(slot) NULL
 # define rt_hash_lock_init()
 #endif
 
-static struct rt_hash_bucket 	*rt_hash_table;
-static unsigned			rt_hash_mask;
-static int			rt_hash_log;
-static unsigned int		rt_hash_rnd;
+static seqlock_t rt_hash_seq __read_mostly =
+	__SEQLOCK_UNLOCKED(rt_hash_seq);
+static struct rt_hash_bucket 	*__rt_hash_table __read_mostly;
+static unsigned			__rt_hash_mask __read_mostly;
+static unsigned int		rt_hash_rnd __read_mostly;
 
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
 #define RT_CACHE_STAT_INC(field) \
 	(__raw_get_cpu_var(rt_cache_stat).field++)
 
-static int rt_intern_hash(unsigned hash, struct rtable *rth,
-				struct rtable **res);
-
-static unsigned int rt_hash_code(u32 daddr, u32 saddr)
+static unsigned int __rt_hash_code(u32 daddr, u32 saddr, unsigned int hash_mask)
 {
 	return (jhash_2words(daddr, saddr, rt_hash_rnd)
-		& rt_hash_mask);
+		& hash_mask);
+}
+
+/* XXX hash table resizing will need to work in three phases
+ * XXX first do the initial transfer to the new table
+ * XXX then instantiate the new table and synchronize_net
+ * XXX finally purge any remnants that got inserted into the old table
+ */
+static struct rt_hash_bucket *rt_get_bucket(u32 daddr, u32 saddr, unsigned int *hp)
+{
+	struct rt_hash_bucket *r;
+	unsigned long seq;
+
+	do {
+		unsigned int hash;
+
+		seq = read_seqbegin(&rt_hash_seq);
+		*hp = hash = __rt_hash_code(daddr, saddr, __rt_hash_mask);
+		r = &__rt_hash_table[hash];
+	} while (read_seqretry(&rt_hash_seq, seq));
+
+	return r;
+}
+
+static struct rt_hash_bucket *rt_get_bucket_nohash(u32 daddr, u32 saddr)
+{
+	struct rt_hash_bucket *r;
+	unsigned long seq;
+
+	do {
+		unsigned int hash;
+
+		seq = read_seqbegin(&rt_hash_seq);
+		hash = __rt_hash_code(daddr, saddr, __rt_hash_mask);
+		r = &__rt_hash_table[hash];
+	} while (read_seqretry(&rt_hash_seq, seq));
+
+	return r;
+}
+
+static void rt_hash_snapshot(struct rt_hash_bucket **table, unsigned int *hmask)
+{
+	unsigned long seq;
+
+	do {
+		seq = read_seqbegin(&rt_hash_seq);
+		*hmask = __rt_hash_mask;
+		*table = __rt_hash_table;
+	} while (read_seqretry(&rt_hash_seq, seq));
 }
 
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
+	struct rt_hash_bucket *table;
 	int bucket;
 };
 
 static struct rtable *rt_cache_get_first(struct seq_file *seq)
 {
-	struct rtable *r = NULL;
 	struct rt_cache_iter_state *st = seq->private;
+	struct rtable *r = NULL;
+	unsigned int hmask;
 
-	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
+	rt_hash_snapshot(&st->table, &hmask);
+	for (st->bucket = hmask; st->bucket >= 0; --st->bucket) {
 		rcu_read_lock_bh();
-		r = rt_hash_table[st->bucket].chain;
+		r = st->table[st->bucket].chain;
 		if (r)
 			break;
 		rcu_read_unlock_bh();
@@ -291,7 +341,7 @@ static struct rtable *rt_cache_get_next(
 		if (--st->bucket < 0)
 			break;
 		rcu_read_lock_bh();
-		r = rt_hash_table[st->bucket].chain;
+		r = st->table[st->bucket].chain;
 	}
 	return r;
 }
@@ -620,18 +670,23 @@ static void rt_check_expire(unsigned lon
 	unsigned int i = rover, goal;
 	struct rtable *rth, **rthp;
 	unsigned long now = jiffies;
+	struct rt_hash_bucket *table;
+	unsigned int hmask;
 	u64 mult;
 
-	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
+	rt_hash_snapshot(&table, &hmask);
+
+	mult = ((u64)ip_rt_gc_interval) << long_log2(hmask + 1);
 	if (ip_rt_gc_timeout > 1)
 		do_div(mult, ip_rt_gc_timeout);
 	goal = (unsigned int)mult;
-	if (goal > rt_hash_mask) goal = rt_hash_mask + 1;
+	if (goal > hmask + 1)
+		goal = hmask + 1;
 	for (; goal > 0; goal--) {
 		unsigned long tmo = ip_rt_gc_timeout;
 
-		i = (i + 1) & rt_hash_mask;
-		rthp = &rt_hash_table[i].chain;
+		i = (i + 1) & hmask;
+		rthp = &table[i].chain;
 
 		if (*rthp == 0)
 			continue;
@@ -655,7 +710,7 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 			/* remove all related balanced entries if necessary */
 			if (rth->u.dst.flags & DST_BALANCED) {
 				rthp = rt_remove_balanced_route(
-					&rt_hash_table[i].chain,
+					&table[i].chain,
 					rth, NULL);
 				if (!rthp)
 					break;
@@ -683,18 +738,21 @@ #endif /* CONFIG_IP_ROUTE_MULTIPATH_CACH
  */
 static void rt_run_flush(unsigned long dummy)
 {
-	int i;
 	struct rtable *rth, *next;
+	struct rt_hash_bucket *table;
+	unsigned int hmask;
+	int i;
 
 	rt_deadline = 0;
 
 	get_random_bytes(&rt_hash_rnd, 4);
 
-	for (i = rt_hash_mask; i >= 0; i--) {
+	rt_hash_snapshot(&table, &hmask);
+	for (i = hmask; i >= 0; i--) {
 		spin_lock_bh(rt_hash_lock_addr(i));
-		rth = rt_hash_table[i].chain;
+		rth = table[i].chain;
 		if (rth)
-			rt_hash_table[i].chain = NULL;
+			table[i].chain = NULL;
 		spin_unlock_bh(rt_hash_lock_addr(i));
 
 		for (; rth; rth = next) {
@@ -777,7 +835,9 @@ static int rt_garbage_collect(void)
 	static int rover;
 	static int equilibrium;
 	struct rtable *rth, **rthp;
+	struct rt_hash_bucket *table;
 	unsigned long now = jiffies;
+	unsigned int hmask;
 	int goal;
 
 	/*
@@ -793,22 +853,24 @@ static int rt_garbage_collect(void)
 		goto out;
 	}
 
+	rt_hash_snapshot(&table, &hmask);
+
 	/* Calculate number of entries, which we want to expire now. */
 	goal = atomic_read(&ipv4_dst_ops.entries) -
-		(ip_rt_gc_elasticity << rt_hash_log);
+		(ip_rt_gc_elasticity << long_log2(hmask + 1));
 	if (goal <= 0) {
 		if (equilibrium < ipv4_dst_ops.gc_thresh)
 			equilibrium = ipv4_dst_ops.gc_thresh;
 		goal = atomic_read(&ipv4_dst_ops.entries) - equilibrium;
 		if (goal > 0) {
-			equilibrium += min_t(unsigned int, goal / 2, rt_hash_mask + 1);
+			equilibrium += min_t(unsigned int, goal / 2, hmask + 1);
 			goal = atomic_read(&ipv4_dst_ops.entries) - equilibrium;
 		}
 	} else {
 		/* We are in dangerous area. Try to reduce cache really
 		 * aggressively.
 		 */
-		goal = max_t(unsigned int, goal / 2, rt_hash_mask + 1);
+		goal = max_t(unsigned int, goal / 2, hmask + 1);
 		equilibrium = atomic_read(&ipv4_dst_ops.entries) - goal;
 	}
 
@@ -823,11 +885,11 @@ static int rt_garbage_collect(void)
 	do {
 		int i, k;
 
-		for (i = rt_hash_mask, k = rover; i >= 0; i--) {
+		for (i = hmask, k = rover; i >= 0; i--) {
 			unsigned long tmo = expire;
 
-			k = (k + 1) & rt_hash_mask;
-			rthp = &rt_hash_table[k].chain;
+			k = (k + 1) & hmask;
+			rthp = &table[k].chain;
 			spin_lock_bh(rt_hash_lock_addr(k));
 			while ((rth = *rthp) != NULL) {
 				if (!rt_may_expire(rth, tmo, expire)) {
@@ -843,7 +905,7 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 					int r;
 
 					rthp = rt_remove_balanced_route(
-						&rt_hash_table[k].chain,
+						&table[k].chain,
 						rth,
 						&r);
 					goal -= r;
@@ -912,7 +974,7 @@ #endif
 out:	return 0;
 }
 
-static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
+static int rt_intern_hash(struct rt_hash_bucket *r, unsigned int hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;
 	unsigned long	now;
@@ -928,7 +990,7 @@ restart:
 	candp = NULL;
 	now = jiffies;
 
-	rthp = &rt_hash_table[hash].chain;
+	rthp = &r->chain;
 
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth = *rthp) != NULL) {
@@ -945,13 +1007,12 @@ #endif
 			 * must be visible to another weakly ordered CPU before
 			 * the insertion at the start of the hash chain.
 			 */
-			rcu_assign_pointer(rth->u.rt_next,
-					   rt_hash_table[hash].chain);
+			rcu_assign_pointer(rth->u.rt_next, r->chain);
 			/*
 			 * Since lookup is lockfree, the update writes
 			 * must be ordered for consistency on SMP.
 			 */
-			rcu_assign_pointer(rt_hash_table[hash].chain, rth);
+			rcu_assign_pointer(r->chain, rth);
 
 			rth->u.dst.__use++;
 			dst_hold(&rth->u.dst);
@@ -1026,7 +1087,7 @@ #endif
 		}
 	}
 
-	rt->u.rt_next = rt_hash_table[hash].chain;
+	rt->u.rt_next = r->chain;
 #if RT_CACHE_DEBUG >= 2
 	if (rt->u.rt_next) {
 		struct rtable *trt;
@@ -1037,7 +1098,7 @@ #if RT_CACHE_DEBUG >= 2
 		printk("\n");
 	}
 #endif
-	rt_hash_table[hash].chain = rt;
+	r->chain = rt;
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 	*rp = rt;
 	return 0;
@@ -1102,19 +1163,19 @@ void __ip_select_ident(struct iphdr *iph
 	ip_select_fb_ident(iph);
 }
 
-static void rt_del(unsigned hash, struct rtable *rt)
+static void rt_del(struct rt_hash_bucket *r, unsigned int hash, struct rtable *rt)
 {
 	struct rtable **rthp;
 
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	ip_rt_put(rt);
-	for (rthp = &rt_hash_table[hash].chain; *rthp;
-	     rthp = &(*rthp)->u.rt_next)
+	for (rthp = &r->chain; *rthp; rthp = &(*rthp)->u.rt_next) {
 		if (*rthp == rt) {
 			*rthp = rt->u.rt_next;
 			rt_free(rt);
 			break;
 		}
+	}
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
@@ -1147,10 +1208,14 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 
 	for (i = 0; i < 2; i++) {
 		for (k = 0; k < 2; k++) {
-			unsigned hash = rt_hash_code(daddr,
-						     skeys[i] ^ (ikeys[k] << 5));
+			struct rt_hash_bucket *r;
+			unsigned int hash;
+
+			r = rt_get_bucket(daddr,
+					  skeys[i] ^ (ikeys[k] << 5),
+					  &hash);
 
-			rthp=&rt_hash_table[hash].chain;
+			rthp=&r->chain;
 
 			rcu_read_lock();
 			while ((rth = rcu_dereference(*rthp)) != NULL) {
@@ -1224,8 +1289,8 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 				call_netevent_notifiers(NETEVENT_REDIRECT, 
 						        &netevent);
 
-				rt_del(hash, rth);
-				if (!rt_intern_hash(hash, rt, &rt))
+				rt_del(r, hash, rth);
+				if (!rt_intern_hash(r, hash, rt, &rt))
 					ip_rt_put(rt);
 				goto do_next;
 			}
@@ -1260,15 +1325,18 @@ static struct dst_entry *ipv4_negative_a
 			ret = NULL;
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
 			   rt->u.dst.expires) {
-			unsigned hash = rt_hash_code(rt->fl.fl4_dst,
-						     rt->fl.fl4_src ^
-							(rt->fl.oif << 5));
+			struct rt_hash_bucket *r;
+			unsigned int hash;
+			r = rt_get_bucket(rt->fl.fl4_dst,
+					  rt->fl.fl4_src ^
+					  (rt->fl.oif << 5),
+					  &hash);
 #if RT_CACHE_DEBUG >= 1
 			printk(KERN_DEBUG "ip_rt_advice: redirect to "
 					  "%u.%u.%u.%u/%02x dropped\n",
 				NIPQUAD(rt->rt_dst), rt->fl.fl4_tos);
 #endif
-			rt_del(hash, rt);
+			rt_del(r, hash, rt);
 			ret = NULL;
 		}
 	}
@@ -1405,10 +1473,12 @@ unsigned short ip_rt_frag_needed(struct 
 		return 0;
 
 	for (i = 0; i < 2; i++) {
-		unsigned hash = rt_hash_code(daddr, skeys[i]);
+		struct rt_hash_bucket *r;
+
+		r = rt_get_bucket_nohash(daddr, skeys[i]);
 
 		rcu_read_lock();
-		for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
+		for (rth = rcu_dereference(r->chain); rth;
 		     rth = rcu_dereference(rth->u.rt_next)) {
 			if (rth->fl.fl4_dst == daddr &&
 			    rth->fl.fl4_src == skeys[i] &&
@@ -1599,8 +1669,9 @@ #endif
 static int ip_route_input_mc(struct sk_buff *skb, u32 daddr, u32 saddr,
 				u8 tos, struct net_device *dev, int our)
 {
-	unsigned hash;
 	struct rtable *rth;
+	struct rt_hash_bucket *r;
+	unsigned int hash;
 	u32 spec_dst;
 	struct in_device *in_dev = in_dev_get(dev);
 	u32 itag = 0;
@@ -1665,8 +1736,8 @@ #endif
 	RT_CACHE_STAT_INC(in_slow_mc);
 
 	in_dev_put(in_dev);
-	hash = rt_hash_code(daddr, saddr ^ (dev->ifindex << 5));
-	return rt_intern_hash(hash, rth, (struct rtable**) &skb->dst);
+	r = rt_get_bucket(daddr, saddr ^ (dev->ifindex << 5), &hash);
+	return rt_intern_hash(r, hash, rth, (struct rtable**) &skb->dst);
 
 e_nobufs:
 	in_dev_put(in_dev);
@@ -1816,8 +1887,9 @@ static inline int ip_mkroute_input_def(s
 				       u32 daddr, u32 saddr, u32 tos)
 {
 	struct rtable* rth = NULL;
+	struct rt_hash_bucket *r;
+	unsigned int hash;
 	int err;
-	unsigned hash;
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1 && fl->oif == 0)
@@ -1830,8 +1902,8 @@ #endif
 		return err;
 
 	/* put it into the cache */
-	hash = rt_hash_code(daddr, saddr ^ (fl->iif << 5));
-	return rt_intern_hash(hash, rth, (struct rtable**)&skb->dst);	
+	r = rt_get_bucket(daddr, saddr ^ (fl->iif << 5), &hash);
+	return rt_intern_hash(r, hash, rth, (struct rtable**)&skb->dst);
 }
 
 static inline int ip_mkroute_input(struct sk_buff *skb, 
@@ -1844,7 +1916,6 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 	struct rtable* rth = NULL, *rtres;
 	unsigned char hop, hopcount;
 	int err = -EINVAL;
-	unsigned int hash;
 
 	if (res->fi)
 		hopcount = res->fi->fib_nhs;
@@ -1858,6 +1929,9 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 	
 	/* add all alternatives to the routing cache */
 	for (hop = 0; hop < hopcount; hop++) {
+		struct rt_hash_bucket *r;
+		unsigned int hash;
+
 		res->nh_sel = hop;
 
 		/* put reference to previous result */
@@ -1871,8 +1945,8 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 			return err;
 
 		/* put it into the cache */
-		hash = rt_hash_code(daddr, saddr ^ (fl->iif << 5));
-		err = rt_intern_hash(hash, rth, &rtres);
+		r = rt_get_bucket(daddr, saddr ^ (fl->iif << 5), &hash);
+		err = rt_intern_hash(r, hash, rth, &rtres);
 		if (err)
 			return err;
 
@@ -1919,7 +1993,8 @@ #endif
 	unsigned	flags = 0;
 	u32		itag = 0;
 	struct rtable * rth;
-	unsigned	hash;
+	struct rt_hash_bucket *r;
+	unsigned int hash;
 	u32		spec_dst;
 	int		err = -EINVAL;
 	int		free_res = 0;
@@ -2048,8 +2123,8 @@ #endif
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
 	rth->rt_type	= res.type;
-	hash = rt_hash_code(daddr, saddr ^ (fl.iif << 5));
-	err = rt_intern_hash(hash, rth, (struct rtable**)&skb->dst);
+	r = rt_get_bucket(daddr, saddr ^ (fl.iif << 5), &hash);
+	err = rt_intern_hash(r, hash, rth, (struct rtable**)&skb->dst);
 	goto done;
 
 no_route:
@@ -2090,15 +2165,15 @@ martian_source:
 int ip_route_input(struct sk_buff *skb, u32 daddr, u32 saddr,
 		   u8 tos, struct net_device *dev)
 {
-	struct rtable * rth;
-	unsigned	hash;
+	struct rt_hash_bucket *r;
+	struct rtable *rth;
 	int iif = dev->ifindex;
 
 	tos &= IPTOS_RT_MASK;
-	hash = rt_hash_code(daddr, saddr ^ (iif << 5));
+	r = rt_get_bucket_nohash(daddr, saddr ^ (iif << 5));
 
 	rcu_read_lock();
-	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
+	for (rth = rcu_dereference(r->chain); rth;
 	     rth = rcu_dereference(rth->u.rt_next)) {
 		if (rth->fl.fl4_dst == daddr &&
 		    rth->fl.fl4_src == saddr &&
@@ -2291,11 +2366,15 @@ static inline int ip_mkroute_output_def(
 {
 	struct rtable *rth = NULL;
 	int err = __mkroute_output(&rth, res, fl, oldflp, dev_out, flags);
-	unsigned hash;
+
 	if (err == 0) {
-		hash = rt_hash_code(oldflp->fl4_dst, 
-				    oldflp->fl4_src ^ (oldflp->oif << 5));
-		err = rt_intern_hash(hash, rth, rp);
+		struct rt_hash_bucket *r;
+		unsigned int hash;
+
+		r = rt_get_bucket(oldflp->fl4_dst,
+				  oldflp->fl4_src ^ (oldflp->oif << 5),
+				  &hash);
+		err = rt_intern_hash(r, hash, rth, rp);
 	}
 	
 	return err;
@@ -2310,7 +2389,6 @@ static inline int ip_mkroute_output(stru
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 	unsigned char hop;
-	unsigned hash;
 	int err = -EINVAL;
 	struct rtable *rth = NULL;
 
@@ -2319,6 +2397,8 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 
 		for (hop = 0; hop < hopcount; hop++) {
 			struct net_device *dev2nexthop;
+			struct rt_hash_bucket *r;
+			unsigned int hash;
 
 			res->nh_sel = hop;
 
@@ -2336,10 +2416,10 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 			if (err != 0)
 				goto cleanup;
 
-			hash = rt_hash_code(oldflp->fl4_dst, 
-					    oldflp->fl4_src ^
-					    (oldflp->oif << 5));
-			err = rt_intern_hash(hash, rth, rp);
+			r = rt_get_bucket(oldflp->fl4_dst,
+					  oldflp->fl4_src ^
+					  (oldflp->oif << 5), &hash);
+			err = rt_intern_hash(r, hash, rth, rp);
 
 			/* forward hop information to multipath impl. */
 			multipath_set_nhinfo(rth,
@@ -2564,13 +2644,13 @@ out:	return err;
 
 int __ip_route_output_key(struct rtable **rp, const struct flowi *flp)
 {
-	unsigned hash;
+	struct rt_hash_bucket *r;
 	struct rtable *rth;
 
-	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5));
+	r = rt_get_bucket_nohash(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5));
 
 	rcu_read_lock_bh();
-	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
+	for (rth = rcu_dereference(r->chain); rth;
 		rth = rcu_dereference(rth->u.rt_next)) {
 		if (rth->fl.fl4_dst == flp->fl4_dst &&
 		    rth->fl.fl4_src == flp->fl4_src &&
@@ -2820,18 +2900,23 @@ out_free:
 
 int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 {
+	struct rt_hash_bucket *table;
 	struct rtable *rt;
+	unsigned int hmask;
 	int h, s_h;
 	int idx, s_idx;
 
+	rt_hash_snapshot(&table, &hmask);
+
 	s_h = cb->args[0];
 	s_idx = idx = cb->args[1];
-	for (h = 0; h <= rt_hash_mask; h++) {
-		if (h < s_h) continue;
+	for (h = 0; h <= hmask; h++) {
+		if (h < s_h)
+			continue;
 		if (h > s_h)
 			s_idx = 0;
 		rcu_read_lock_bh();
-		for (rt = rcu_dereference(rt_hash_table[h].chain), idx = 0; rt;
+		for (rt = rcu_dereference(table[h].chain), idx = 0; rt;
 		     rt = rcu_dereference(rt->u.rt_next), idx++) {
 			if (idx < s_idx)
 				continue;
@@ -3151,21 +3236,21 @@ #endif
 	if (!ipv4_dst_ops.kmem_cachep)
 		panic("IP: failed to allocate ip_dst_cache\n");
 
-	rt_hash_table = (struct rt_hash_bucket *)
+	__rt_hash_table = (struct rt_hash_bucket *)
 		alloc_large_system_hash("IP route cache",
 					sizeof(struct rt_hash_bucket),
 					rhash_entries,
 					(num_physpages >= 128 * 1024) ?
 					15 : 17,
 					HASH_HIGHMEM,
-					&rt_hash_log,
-					&rt_hash_mask,
+					NULL,
+					&__rt_hash_mask,
 					0);
-	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash_bucket));
+	memset(__rt_hash_table, 0, (__rt_hash_mask + 1) * sizeof(struct rt_hash_bucket));
 	rt_hash_lock_init();
 
-	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
-	ip_rt_max_size = (rt_hash_mask + 1) * 16;
+	ipv4_dst_ops.gc_thresh = (__rt_hash_mask + 1);
+	ip_rt_max_size = (__rt_hash_mask + 1) * 16;
 
 	devinet_init();
 	ip_fib_init();
-- 
1.4.2.rc2.g3e042

