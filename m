From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPV4] route cache: Introduce rt_genid for smooth cache invalidation
Date: Wed, 30 Jan 2008 09:08:56 +0100
Message-ID: <47A03098.7060100@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080107040106030705010903"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:59913
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755684AbYA3IJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:09:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080107040106030705010903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Current ip route cache implementation is not suited to large caches.

We can consume a lot of CPU when cache must be invalidated, since we
currently need to evict all cache entries, and this eviction is
sometimes asynchronous. min_delay & max_delay can somewhat control this
asynchronism behavior, but whole thing is a kludge, regularly triggering
infamous soft lockup messages. When entries are still in use, this also
consumes a lot of ram, filling dst_garbage.list.

A better scheme is to use a generation identifier on each entry,
so that cache invalidation can be performed by changing the table
identifier, without having to scan all entries.
No more delayed flushing, no more stalling when secret_interval expires.

Invalidated entries will then be freed at GC time (controled by
ip_rt_gc_timeout or stress), or when an invalidated entry is found
in a chain when an insert is done.
Thus we keep a normal equilibrium.

This patch :
- renames rt_hash_rnd to rt_genid (and makes it an atomic_t)
- Adds a new rt_genid field to 'struct rtable' (filling a hole on 64bit)
- Checks entry->rt_genid at appropriate places :
--- Readers have to ignore invalidated entries.
--- Writers can delete invalidated entries.
- Removes rt_flush_timer timer
- Removes unused /proc/sys/net/ipv4/{min_delay,max_delay}

We even reduce size of route.o

# size net/ipv4/route.o
    text    data     bss     dec     hex filename
   20038    1331     160   21529    5419 net/ipv4/route.o.before
   19991    1203     104   21298    5332 net/ipv4/route.o

Next step will be to audit all rt_cache_flush(0) (aka flushes) users, see
if they can be converted to "invalidate the cache" users.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  Documentation/filesystems/proc.txt |    4
  include/linux/sysctl.h             |    4
  include/net/route.h                |    1
  net/ipv4/route.c                   |  209 +++++++++++----------------
  4 files changed, 92 insertions(+), 126 deletions(-)

--------------080107040106030705010903
Content-Type: text/plain;
 name="rt_genid.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rt_genid.patch"

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 4413a2d..11fe51c 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1919,11 +1919,6 @@ max_size
 Maximum size  of  the routing cache. Old entries will be purged once the cache
 reached has this size.
 
-max_delay, min_delay
---------------------
-
-Delays for flushing the routing cache.
-
 redirect_load, redirect_number
 ------------------------------
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 89faebf..bf4ae4e 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -440,8 +440,8 @@ enum
 
 enum {
 	NET_IPV4_ROUTE_FLUSH=1,
-	NET_IPV4_ROUTE_MIN_DELAY=2,
-	NET_IPV4_ROUTE_MAX_DELAY=3,
+	NET_IPV4_ROUTE_MIN_DELAY=2, /* obsolete since 2.6.25 */
+	NET_IPV4_ROUTE_MAX_DELAY=3, /* obsolete since 2.6.25 */
 	NET_IPV4_ROUTE_GC_THRESH=4,
 	NET_IPV4_ROUTE_MAX_SIZE=5,
 	NET_IPV4_ROUTE_GC_MIN_INTERVAL=6,
diff --git a/include/net/route.h b/include/net/route.h
index 4eabf00..c0675a4 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -61,6 +61,7 @@ struct rtable
 
 	struct in_device	*idev;
 	
+	int			rt_genid;
 	unsigned		rt_flags;
 	__u16			rt_type;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 896c768..922f2ae 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -117,8 +117,6 @@
 
 #define RT_GC_TIMEOUT (300*HZ)
 
-static int ip_rt_min_delay		= 2 * HZ;
-static int ip_rt_max_delay		= 10 * HZ;
 static int ip_rt_max_size;
 static int ip_rt_gc_timeout		= RT_GC_TIMEOUT;
 static int ip_rt_gc_interval		= 60 * HZ;
@@ -133,12 +131,9 @@ static int ip_rt_mtu_expires		= 10 * 60 * HZ;
 static int ip_rt_min_pmtu		= 512 + 20 + 20;
 static int ip_rt_min_advmss		= 256;
 static int ip_rt_secret_interval	= 10 * 60 * HZ;
-static int ip_rt_flush_expected;
-static unsigned long rt_deadline;
 
 #define RTprint(a...)	printk(KERN_DEBUG a)
 
-static struct timer_list rt_flush_timer;
 static void rt_worker_func(struct work_struct *work);
 static DECLARE_DELAYED_WORK(expires_work, rt_worker_func);
 static struct timer_list rt_secret_timer;
@@ -259,19 +254,16 @@ static inline void rt_hash_lock_init(void)
 static struct rt_hash_bucket 	*rt_hash_table;
 static unsigned			rt_hash_mask;
 static unsigned int		rt_hash_log;
-static unsigned int		rt_hash_rnd;
+static atomic_t			rt_genid;
 
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
 #define RT_CACHE_STAT_INC(field) \
 	(__raw_get_cpu_var(rt_cache_stat).field++)
 
-static int rt_intern_hash(unsigned hash, struct rtable *rth,
-				struct rtable **res);
-
 static unsigned int rt_hash_code(u32 daddr, u32 saddr)
 {
-	return (jhash_2words(daddr, saddr, rt_hash_rnd)
-		& rt_hash_mask);
+	return jhash_2words(daddr, saddr, atomic_read(&rt_genid))
+		& rt_hash_mask;
 }
 
 #define rt_hash(daddr, saddr, idx) \
@@ -281,27 +273,28 @@ static unsigned int rt_hash_code(u32 daddr, u32 saddr)
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
 	int bucket;
+	int genid;
 };
 
-static struct rtable *rt_cache_get_first(struct seq_file *seq)
+static struct rtable *rt_cache_get_first(struct rt_cache_iter_state *st)
 {
 	struct rtable *r = NULL;
-	struct rt_cache_iter_state *st = seq->private;
 
 	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
 		rcu_read_lock_bh();
-		r = rt_hash_table[st->bucket].chain;
-		if (r)
-			break;
+		r = rcu_dereference(rt_hash_table[st->bucket].chain);
+		while (r) {
+			if (r->rt_genid == st->genid)
+				return r;
+			r = rcu_dereference(r->u.dst.rt_next);
+		}
 		rcu_read_unlock_bh();
 	}
-	return rcu_dereference(r);
+	return r;
 }
 
-static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
+static struct rtable *rt_cache_get_next(struct rt_cache_iter_state *st, struct rtable *r)
 {
-	struct rt_cache_iter_state *st = seq->private;
-
 	r = r->u.dst.rt_next;
 	while (!r) {
 		rcu_read_unlock_bh();
@@ -313,29 +306,38 @@ static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
 	return rcu_dereference(r);
 }
 
-static struct rtable *rt_cache_get_idx(struct seq_file *seq, loff_t pos)
+static struct rtable *rt_cache_get_idx(struct rt_cache_iter_state *st, loff_t pos)
 {
-	struct rtable *r = rt_cache_get_first(seq);
+	struct rtable *r = rt_cache_get_first(st);
 
 	if (r)
-		while (pos && (r = rt_cache_get_next(seq, r)))
+		while (pos && (r = rt_cache_get_next(st, r))) {
+			if (r->rt_genid != st->genid)
+				continue;
 			--pos;
+		}
 	return pos ? NULL : r;
 }
 
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	return *pos ? rt_cache_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+	struct rt_cache_iter_state *st = seq->private;
+
+	if (*pos)
+		return rt_cache_get_idx(st, *pos - 1);
+	st->genid = atomic_read(&rt_genid);
+	return SEQ_START_TOKEN;
 }
 
 static void *rt_cache_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct rtable *r = NULL;
+	struct rtable *r;
+	struct rt_cache_iter_state *st = seq->private;
 
 	if (v == SEQ_START_TOKEN)
-		r = rt_cache_get_first(seq);
+		r = rt_cache_get_first(st);
 	else
-		r = rt_cache_get_next(seq, v);
+		r = rt_cache_get_next(st, v);
 	++*pos;
 	return r;
 }
@@ -708,6 +710,11 @@ static void rt_check_expire(void)
 			continue;
 		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth = *rthp) != NULL) {
+			if (rth->rt_genid != atomic_read(&rt_genid)) {
+				*rthp = rth->u.dst.rt_next;
+				rt_free(rth);
+				continue;
+			}
 			if (rth->u.dst.expires) {
 				/* Entry is expired even if it is in use */
 				if (time_before_eq(jiffies, rth->u.dst.expires)) {
@@ -732,83 +739,45 @@ static void rt_check_expire(void)
 
 /*
  * rt_worker_func() is run in process context.
- * If a whole flush was scheduled, it is done.
- * Else, we call rt_check_expire() to scan part of the hash table
+ * we call rt_check_expire() to scan part of the hash table
  */
 static void rt_worker_func(struct work_struct *work)
 {
-	if (ip_rt_flush_expected) {
-		ip_rt_flush_expected = 0;
-		rt_do_flush(1);
-	} else
-		rt_check_expire();
+	rt_check_expire();
 	schedule_delayed_work(&expires_work, ip_rt_gc_interval);
 }
 
-/* This can run from both BH and non-BH contexts, the latter
- * in the case of a forced flush event.
+/*
+ * Pertubation of rt_genid by a small quantity [1..256]
+ * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
+ * many times (2^24) without giving recent rt_genid.
+ * Jenkins hash is strong enough that litle changes of rt_genid are OK.
  */
-static void rt_run_flush(unsigned long process_context)
+static void rt_cache_invalidate(void)
 {
-	rt_deadline = 0;
-
-	get_random_bytes(&rt_hash_rnd, 4);
+	unsigned char shuffle;
 
-	rt_do_flush(process_context);
+	get_random_bytes(&shuffle, sizeof(shuffle));
+	atomic_add(shuffle + 1U, &rt_genid);
 }
 
-static DEFINE_SPINLOCK(rt_flush_lock);
-
+/*
+ * delay < 0  : invalidate cache (fast : entries will be deleted later)
+ * delay >= 0 : invalidate & flush cache (can be long)
+ */
 void rt_cache_flush(int delay)
 {
-	unsigned long now = jiffies;
-	int user_mode = !in_softirq();
-
-	if (delay < 0)
-		delay = ip_rt_min_delay;
-
-	spin_lock_bh(&rt_flush_lock);
-
-	if (del_timer(&rt_flush_timer) && delay > 0 && rt_deadline) {
-		long tmo = (long)(rt_deadline - now);
-
-		/* If flush timer is already running
-		   and flush request is not immediate (delay > 0):
-
-		   if deadline is not achieved, prolongate timer to "delay",
-		   otherwise fire it at deadline time.
-		 */
-
-		if (user_mode && tmo < ip_rt_max_delay-ip_rt_min_delay)
-			tmo = 0;
-
-		if (delay > tmo)
-			delay = tmo;
-	}
-
-	if (delay <= 0) {
-		spin_unlock_bh(&rt_flush_lock);
-		rt_run_flush(user_mode);
-		return;
-	}
-
-	if (rt_deadline == 0)
-		rt_deadline = now + ip_rt_max_delay;
-
-	mod_timer(&rt_flush_timer, now+delay);
-	spin_unlock_bh(&rt_flush_lock);
+	rt_cache_invalidate();
+	if (delay >= 0)
+		rt_do_flush(!in_softirq());
 }
 
 /*
- * We change rt_hash_rnd and ask next rt_worker_func() invocation
- * to perform a flush in process context
+ * We change rt_genid and let gc do the cleanup
  */
 static void rt_secret_rebuild(unsigned long dummy)
 {
-	get_random_bytes(&rt_hash_rnd, 4);
-	ip_rt_flush_expected = 1;
-	cancel_delayed_work(&expires_work);
-	schedule_delayed_work(&expires_work, HZ/10);
+	rt_cache_invalidate();
 	mod_timer(&rt_secret_timer, jiffies + ip_rt_secret_interval);
 }
 
@@ -885,7 +854,8 @@ static int rt_garbage_collect(struct dst_ops *ops)
 			rthp = &rt_hash_table[k].chain;
 			spin_lock_bh(rt_hash_lock_addr(k));
 			while ((rth = *rthp) != NULL) {
-				if (!rt_may_expire(rth, tmo, expire)) {
+				if (rth->rt_genid == atomic_read(&rt_genid) &&
+					!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
 					rthp = &rth->u.dst.rt_next;
 					continue;
@@ -966,6 +936,11 @@ restart:
 
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth = *rthp) != NULL) {
+		if (rth->rt_genid != atomic_read(&rt_genid)) {
+			*rthp = rth->u.dst.rt_next;
+			rt_free(rth);
+			continue;
+		}
 		if (compare_keys(&rth->fl, &rt->fl) && compare_netns(rth, rt)) {
 			/* Put it first */
 			*rthp = rth->u.dst.rt_next;
@@ -1131,17 +1106,19 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 
 static void rt_del(unsigned hash, struct rtable *rt)
 {
-	struct rtable **rthp;
+	struct rtable **rthp, *aux;
 
+	rthp = &rt_hash_table[hash].chain;
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	ip_rt_put(rt);
-	for (rthp = &rt_hash_table[hash].chain; *rthp;
-	     rthp = &(*rthp)->u.dst.rt_next)
-		if (*rthp == rt) {
-			*rthp = rt->u.dst.rt_next;
-			rt_free(rt);
-			break;
+	while ((aux = *rthp) != NULL) {
+		if (aux == rt || (aux->rt_genid != atomic_read(&rt_genid))) {
+			*rthp = aux->u.dst.rt_next;
+			rt_free(aux);
+			continue;
 		}
+		rthp = &aux->u.dst.rt_next;
+	}
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
@@ -1186,7 +1163,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				if (rth->fl.fl4_dst != daddr ||
 				    rth->fl.fl4_src != skeys[i] ||
 				    rth->fl.oif != ikeys[k] ||
-				    rth->fl.iif != 0) {
+				    rth->fl.iif != 0 ||
+				    rth->rt_genid != atomic_read(&rt_genid)) {
 					rthp = &rth->u.dst.rt_next;
 					continue;
 				}
@@ -1224,7 +1202,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				rt->u.dst.neighbour	= NULL;
 				rt->u.dst.hh		= NULL;
 				rt->u.dst.xfrm		= NULL;
-
+				rt->rt_genid		= atomic_read(&rt_genid);
 				rt->rt_flags		|= RTCF_REDIRECTED;
 
 				/* Gateway is different ... */
@@ -1445,7 +1423,8 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 			    rth->rt_src  == iph->saddr &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU)) &&
-			    rth->u.dst.dev->nd_net == net) {
+			    rth->u.dst.dev->nd_net == net &&
+			    rth->rt_genid == atomic_read(&rt_genid)) {
 				unsigned short mtu = new_mtu;
 
 				if (new_mtu < 68 || new_mtu >= old_mtu) {
@@ -1680,8 +1659,9 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->fl.oif	= 0;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
-	rth->rt_type	= RTN_MULTICAST;
+	rth->rt_genid	= atomic_read(&rt_genid);
 	rth->rt_flags	= RTCF_MULTICAST;
+	rth->rt_type	= RTN_MULTICAST;
 	if (our) {
 		rth->u.dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
@@ -1820,6 +1800,7 @@ static inline int __mkroute_input(struct sk_buff *skb,
 
 	rth->u.dst.input = ip_forward;
 	rth->u.dst.output = ip_output;
+	rth->rt_genid = atomic_read(&rt_genid);
 
 	rt_set_nexthop(rth, res, itag);
 
@@ -1980,6 +1961,7 @@ local_input:
 		goto e_nobufs;
 
 	rth->u.dst.output= ip_rt_bug;
+	rth->rt_genid = atomic_read(&rt_genid);
 
 	atomic_set(&rth->u.dst.__refcnt, 1);
 	rth->u.dst.flags= DST_HOST;
@@ -2071,7 +2053,8 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->fl.oif == 0 &&
 		    rth->fl.mark == skb->mark &&
 		    rth->fl.fl4_tos == tos &&
-		    rth->u.dst.dev->nd_net == net) {
+		    rth->u.dst.dev->nd_net == net &&
+		    rth->rt_genid == atomic_read(&rt_genid)) {
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();
@@ -2199,6 +2182,7 @@ static inline int __mkroute_output(struct rtable **result,
 	rth->rt_spec_dst= fl->fl4_src;
 
 	rth->u.dst.output=ip_output;
+	rth->rt_genid = atomic_read(&rt_genid);
 
 	RT_CACHE_STAT_INC(out_slow_tot);
 
@@ -2471,7 +2455,8 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 		    rth->fl.mark == flp->mark &&
 		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
-		    rth->u.dst.dev->nd_net == net) {
+		    rth->u.dst.dev->nd_net == net &&
+		    rth->rt_genid == atomic_read(&rt_genid)) {
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
@@ -2525,6 +2510,7 @@ static int ipv4_dst_blackhole(struct rtable **rp, struct flowi *flp, struct sock
 		rt->idev = ort->idev;
 		if (rt->idev)
 			in_dev_hold(rt->idev);
+		rt->rt_genid = atomic_read(&rt_genid);
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
 		rt->rt_dst = ort->rt_dst;
@@ -2779,6 +2765,8 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 		     rt = rcu_dereference(rt->u.dst.rt_next), idx++) {
 			if (idx < s_idx)
 				continue;
+			if (rt->rt_genid != atomic_read(&rt_genid))
+				continue;
 			skb->dst = dst_clone(&rt->u.dst);
 			if (rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
@@ -2848,24 +2836,6 @@ ctl_table ipv4_route_table[] = {
 		.strategy	= &ipv4_sysctl_rtcache_flush_strategy,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_MIN_DELAY,
-		.procname	= "min_delay",
-		.data		= &ip_rt_min_delay,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
-	},
-	{
-		.ctl_name	= NET_IPV4_ROUTE_MAX_DELAY,
-		.procname	= "max_delay",
-		.data		= &ip_rt_max_delay,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
-	},
-	{
 		.ctl_name	= NET_IPV4_ROUTE_GC_THRESH,
 		.procname	= "gc_thresh",
 		.data		= &ipv4_dst_ops.gc_thresh,
@@ -3023,8 +2993,8 @@ int __init ip_rt_init(void)
 {
 	int rc = 0;
 
-	rt_hash_rnd = (int) ((num_physpages ^ (num_physpages>>8)) ^
-			     (jiffies ^ (jiffies >> 7)));
+	atomic_set(&rt_genid, (int) ((num_physpages ^ (num_physpages>>8)) ^
+			     (jiffies ^ (jiffies >> 7))));
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	ip_rt_acct = __alloc_percpu(256 * sizeof(struct ip_rt_acct));
@@ -3057,7 +3027,6 @@ int __init ip_rt_init(void)
 	devinet_init();
 	ip_fib_init();
 
-	setup_timer(&rt_flush_timer, rt_run_flush, 0);
 	setup_timer(&rt_secret_timer, rt_secret_rebuild, 0);
 
 	/* All the timers, started at system startup tend

--------------080107040106030705010903--
