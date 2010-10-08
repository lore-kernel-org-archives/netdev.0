From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net dst: use a percpu_counter to track entries
Date: Fri, 08 Oct 2010 18:37:34 +0200
Message-ID: <1286555854.2959.605.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:50001 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145Ab0JHQhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:37:40 -0400
Received: by wwb31 with SMTP id 31so240263wwb.1
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 09:37:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct dst_ops tracks number of allocated dst in an atomic_t field,
subject to high cache line contention in stress workload.

Switch to a percpu_counter, to reduce number of time we need to dirty a
central location. Place it on a separate cache line to avoid dirtying
read only fields.

Stress test :

(Sending 160.000.000 UDP frames,
IP route cache disabled, dual E5540 @2.53GHz,
32bit kernel, FIB_TRIE, SLUB/NUMA)

Before:

real    0m51.179s
user    0m15.329s
sys     10m15.942s

After:

real	0m45.570s
user	0m15.525s
sys	9m56.669s

With a small reordering of struct neighbour fields, subject of a
following patch, (to separate refcnt from other read mostly fields)

real	0m41.841s
user	0m15.261s
sys	8m45.949s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/dst_ops.h     |   37 +++++++++++++++++++++++++++++++++++-
 net/bridge/br_netfilter.c |   11 ++++++++--
 net/core/dst.c            |    6 ++---
 net/decnet/dn_route.c     |    3 +-
 net/ipv4/route.c          |   36 +++++++++++++++++++++--------------
 net/ipv4/xfrm4_policy.c   |    4 +--
 net/ipv6/route.c          |   28 +++++++++++++++++++--------
 net/ipv6/xfrm6_policy.c   |   10 +++++----
 8 files changed, 100 insertions(+), 35 deletions(-)

diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index d1ff9b7..1fa5306 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -1,6 +1,7 @@
 #ifndef _NET_DST_OPS_H
 #define _NET_DST_OPS_H
 #include <linux/types.h>
+#include <linux/percpu_counter.h>
 
 struct dst_entry;
 struct kmem_cachep;
@@ -22,7 +23,41 @@ struct dst_ops {
 	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
 	int			(*local_out)(struct sk_buff *skb);
 
-	atomic_t		entries;
 	struct kmem_cache	*kmem_cachep;
+
+	struct percpu_counter	pcpuc_entries ____cacheline_aligned_in_smp;
 };
+
+static inline int dst_entries_get_fast(struct dst_ops *dst)
+{
+	return percpu_counter_read_positive(&dst->pcpuc_entries);
+}
+
+static inline int dst_entries_get_slow(struct dst_ops *dst)
+{
+	int res;
+
+	local_bh_disable();
+	res = percpu_counter_sum_positive(&dst->pcpuc_entries);
+	local_bh_enable();
+	return res;
+}
+
+static inline void dst_entries_add(struct dst_ops *dst, int val)
+{
+	local_bh_disable();
+	percpu_counter_add(&dst->pcpuc_entries, val);
+	local_bh_enable();
+}
+
+static inline int dst_entries_init(struct dst_ops *dst)
+{
+	return percpu_counter_init(&dst->pcpuc_entries, 0);
+}
+
+static inline void dst_entries_destroy(struct dst_ops *dst)
+{
+	percpu_counter_destroy(&dst->pcpuc_entries);
+}
+
 #endif
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 77f7b5f..7f9ce96 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -106,7 +106,6 @@ static struct dst_ops fake_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
 	.update_pmtu =		fake_update_pmtu,
-	.entries =		ATOMIC_INIT(0),
 };
 
 /*
@@ -1003,15 +1002,22 @@ int __init br_netfilter_init(void)
 {
 	int ret;
 
-	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	ret = dst_entries_init(&fake_dst_ops);
 	if (ret < 0)
 		return ret;
+
+	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	if (ret < 0) {
+		dst_entries_destroy(&fake_dst_ops);
+		return ret;
+	}
 #ifdef CONFIG_SYSCTL
 	brnf_sysctl_header = register_sysctl_paths(brnf_path, brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
 		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+		dst_entries_destroy(&fake_dst_ops);
 		return -ENOMEM;
 	}
 #endif
@@ -1025,4 +1031,5 @@ void br_netfilter_fini(void)
 #ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(brnf_sysctl_header);
 #endif
+	dst_entries_destroy(&fake_dst_ops);
 }
diff --git a/net/core/dst.c b/net/core/dst.c
index 6c41b1f..eebcf4f 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -168,7 +168,7 @@ void *dst_alloc(struct dst_ops *ops)
 {
 	struct dst_entry *dst;
 
-	if (ops->gc && atomic_read(&ops->entries) > ops->gc_thresh) {
+	if (ops->gc && dst_entries_get_fast(ops) > ops->gc_thresh) {
 		if (ops->gc(ops))
 			return NULL;
 	}
@@ -183,7 +183,7 @@ void *dst_alloc(struct dst_ops *ops)
 #if RT_CACHE_DEBUG >= 2
 	atomic_inc(&dst_total);
 #endif
-	atomic_inc(&ops->entries);
+	dst_entries_add(ops, 1);
 	return dst;
 }
 EXPORT_SYMBOL(dst_alloc);
@@ -236,7 +236,7 @@ again:
 		neigh_release(neigh);
 	}
 
-	atomic_dec(&dst->ops->entries);
+	dst_entries_add(dst->ops, -1);
 
 	if (dst->ops->destroy)
 		dst->ops->destroy(dst);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 6585ea6..df0f3e5 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -132,7 +132,6 @@ static struct dst_ops dn_dst_ops = {
 	.negative_advice =	dn_dst_negative_advice,
 	.link_failure =		dn_dst_link_failure,
 	.update_pmtu =		dn_dst_update_pmtu,
-	.entries =		ATOMIC_INIT(0),
 };
 
 static __inline__ unsigned dn_hash(__le16 src, __le16 dst)
@@ -1758,6 +1757,7 @@ void __init dn_route_init(void)
 	dn_dst_ops.kmem_cachep =
 		kmem_cache_create("dn_dst_cache", sizeof(struct dn_route), 0,
 				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+	dst_entries_init(&dn_dst_ops);
 	setup_timer(&dn_route_timer, dn_dst_check_expire, 0);
 	dn_route_timer.expires = jiffies + decnet_dst_gc_interval * HZ;
 	add_timer(&dn_route_timer);
@@ -1816,5 +1816,6 @@ void __exit dn_route_cleanup(void)
 	dn_run_flush(0);
 
 	proc_net_remove(&init_net, "decnet_cache");
+	dst_entries_destroy(&dn_dst_ops);
 }
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7864d0c..831c6d4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -159,7 +159,6 @@ static struct dst_ops ipv4_dst_ops = {
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
 	.local_out =		__ip_local_out,
-	.entries =		ATOMIC_INIT(0),
 };
 
 #define ECN_OR_COST(class)	TC_PRIO_##class
@@ -466,7 +465,7 @@ static int rt_cpu_seq_show(struct seq_file *seq, void *v)
 
 	seq_printf(seq,"%08x  %08x %08x %08x %08x %08x %08x %08x "
 		   " %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
-		   atomic_read(&ipv4_dst_ops.entries),
+		   dst_entries_get_slow(&ipv4_dst_ops),
 		   st->in_hit,
 		   st->in_slow_tot,
 		   st->in_slow_mc,
@@ -945,6 +944,7 @@ static int rt_garbage_collect(struct dst_ops *ops)
 	struct rtable *rth, **rthp;
 	unsigned long now = jiffies;
 	int goal;
+	int entries = dst_entries_get_fast(&ipv4_dst_ops);
 
 	/*
 	 * Garbage collection is pretty expensive,
@@ -954,28 +954,28 @@ static int rt_garbage_collect(struct dst_ops *ops)
 	RT_CACHE_STAT_INC(gc_total);
 
 	if (now - last_gc < ip_rt_gc_min_interval &&
-	    atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size) {
+	    entries < ip_rt_max_size) {
 		RT_CACHE_STAT_INC(gc_ignored);
 		goto out;
 	}
 
+	entries = dst_entries_get_slow(&ipv4_dst_ops);
 	/* Calculate number of entries, which we want to expire now. */
-	goal = atomic_read(&ipv4_dst_ops.entries) -
-		(ip_rt_gc_elasticity << rt_hash_log);
+	goal = entries - (ip_rt_gc_elasticity << rt_hash_log);
 	if (goal <= 0) {
 		if (equilibrium < ipv4_dst_ops.gc_thresh)
 			equilibrium = ipv4_dst_ops.gc_thresh;
-		goal = atomic_read(&ipv4_dst_ops.entries) - equilibrium;
+		goal = entries - equilibrium;
 		if (goal > 0) {
 			equilibrium += min_t(unsigned int, goal >> 1, rt_hash_mask + 1);
-			goal = atomic_read(&ipv4_dst_ops.entries) - equilibrium;
+			goal = entries - equilibrium;
 		}
 	} else {
 		/* We are in dangerous area. Try to reduce cache really
 		 * aggressively.
 		 */
 		goal = max_t(unsigned int, goal >> 1, rt_hash_mask + 1);
-		equilibrium = atomic_read(&ipv4_dst_ops.entries) - goal;
+		equilibrium = entries - goal;
 	}
 
 	if (now - last_gc >= ip_rt_gc_min_interval)
@@ -1032,14 +1032,16 @@ static int rt_garbage_collect(struct dst_ops *ops)
 		expire >>= 1;
 #if RT_CACHE_DEBUG >= 2
 		printk(KERN_DEBUG "expire>> %u %d %d %d\n", expire,
-				atomic_read(&ipv4_dst_ops.entries), goal, i);
+				dst_entries_get_fast(&ipv4_dst_ops), goal, i);
 #endif
 
-		if (atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size)
+		if (dst_entries_get_fast(&ipv4_dst_ops) < ip_rt_max_size)
 			goto out;
 	} while (!in_softirq() && time_before_eq(jiffies, now));
 
-	if (atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size)
+	if (dst_entries_get_fast(&ipv4_dst_ops) < ip_rt_max_size)
+		goto out;
+	if (dst_entries_get_slow(&ipv4_dst_ops) < ip_rt_max_size)
 		goto out;
 	if (net_ratelimit())
 		printk(KERN_WARNING "dst cache overflow\n");
@@ -1049,11 +1051,12 @@ static int rt_garbage_collect(struct dst_ops *ops)
 work_done:
 	expire += ip_rt_gc_min_interval;
 	if (expire > ip_rt_gc_timeout ||
-	    atomic_read(&ipv4_dst_ops.entries) < ipv4_dst_ops.gc_thresh)
+	    dst_entries_get_fast(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh ||
+	    dst_entries_get_slow(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh)
 		expire = ip_rt_gc_timeout;
 #if RT_CACHE_DEBUG >= 2
 	printk(KERN_DEBUG "expire++ %u %d %d %d\n", expire,
-			atomic_read(&ipv4_dst_ops.entries), goal, rover);
+			dst_entries_get_fast(&ipv4_dst_ops), goal, rover);
 #endif
 out:	return 0;
 }
@@ -2719,7 +2722,6 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.destroy		=	ipv4_dst_destroy,
 	.check			=	ipv4_blackhole_dst_check,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
-	.entries		=	ATOMIC_INIT(0),
 };
 
 
@@ -3289,6 +3291,12 @@ int __init ip_rt_init(void)
 
 	ipv4_dst_blackhole_ops.kmem_cachep = ipv4_dst_ops.kmem_cachep;
 
+	if (dst_entries_init(&ipv4_dst_ops) < 0)
+		panic("IP: failed to allocate ipv4_dst_ops counter\n");
+
+	if (dst_entries_init(&ipv4_dst_blackhole_ops) < 0)
+		panic("IP: failed to allocate ipv4_dst_blackhole_ops counter\n");
+
 	rt_hash_table = (struct rt_hash_bucket *)
 		alloc_large_system_hash("IP route cache",
 					sizeof(struct rt_hash_bucket),
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index a580349..4464f3b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -174,7 +174,7 @@ static inline int xfrm4_garbage_collect(struct dst_ops *ops)
 	struct net *net = container_of(ops, struct net, xfrm.xfrm4_dst_ops);
 
 	xfrm4_policy_afinfo.garbage_collect(net);
-	return (atomic_read(&ops->entries) > ops->gc_thresh * 2);
+	return (dst_entries_get_slow(ops) > ops->gc_thresh * 2);
 }
 
 static void xfrm4_update_pmtu(struct dst_entry *dst, u32 mtu)
@@ -232,7 +232,6 @@ static struct dst_ops xfrm4_dst_ops = {
 	.ifdown =		xfrm4_dst_ifdown,
 	.local_out =		__ip_local_out,
 	.gc_thresh =		1024,
-	.entries =		ATOMIC_INIT(0),
 };
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
@@ -288,6 +287,7 @@ void __init xfrm4_init(int rt_max_size)
 	 * and start cleaning when were 1/2 full
 	 */
 	xfrm4_dst_ops.gc_thresh = rt_max_size/2;
+	dst_entries_init(&xfrm4_dst_ops);
 
 	xfrm4_state_init();
 	xfrm4_policy_init();
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 17e2179..25661f9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -109,7 +109,6 @@ static struct dst_ops ip6_dst_ops_template = {
 	.link_failure		=	ip6_link_failure,
 	.update_pmtu		=	ip6_rt_update_pmtu,
 	.local_out		=	__ip6_local_out,
-	.entries		=	ATOMIC_INIT(0),
 };
 
 static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
@@ -122,7 +121,6 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.destroy		=	ip6_dst_destroy,
 	.check			=	ip6_dst_check,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
-	.entries		=	ATOMIC_INIT(0),
 };
 
 static struct rt6_info ip6_null_entry_template = {
@@ -1058,19 +1056,22 @@ static int ip6_dst_gc(struct dst_ops *ops)
 	int rt_elasticity = net->ipv6.sysctl.ip6_rt_gc_elasticity;
 	int rt_gc_timeout = net->ipv6.sysctl.ip6_rt_gc_timeout;
 	unsigned long rt_last_gc = net->ipv6.ip6_rt_last_gc;
+	int entries;
 
+	entries = dst_entries_get_fast(ops);
 	if (time_after(rt_last_gc + rt_min_interval, now) &&
-	    atomic_read(&ops->entries) <= rt_max_size)
+	    entries <= rt_max_size)
 		goto out;
 
 	net->ipv6.ip6_rt_gc_expire++;
 	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net);
 	net->ipv6.ip6_rt_last_gc = now;
-	if (atomic_read(&ops->entries) < ops->gc_thresh)
+	entries = dst_entries_get_slow(ops);
+	if (entries < ops->gc_thresh)
 		net->ipv6.ip6_rt_gc_expire = rt_gc_timeout>>1;
 out:
 	net->ipv6.ip6_rt_gc_expire -= net->ipv6.ip6_rt_gc_expire>>rt_elasticity;
-	return atomic_read(&ops->entries) > rt_max_size;
+	return entries > rt_max_size;
 }
 
 /* Clean host part of a prefix. Not necessary in radix tree,
@@ -2524,7 +2525,7 @@ static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 		   net->ipv6.rt6_stats->fib_rt_alloc,
 		   net->ipv6.rt6_stats->fib_rt_entries,
 		   net->ipv6.rt6_stats->fib_rt_cache,
-		   atomic_read(&net->ipv6.ip6_dst_ops.entries),
+		   dst_entries_get_slow(&net->ipv6.ip6_dst_ops),
 		   net->ipv6.rt6_stats->fib_discarded_routes);
 
 	return 0;
@@ -2666,11 +2667,14 @@ static int __net_init ip6_route_net_init(struct net *net)
 	memcpy(&net->ipv6.ip6_dst_ops, &ip6_dst_ops_template,
 	       sizeof(net->ipv6.ip6_dst_ops));
 
+	if (dst_entries_init(&net->ipv6.ip6_dst_ops) < 0)
+		goto out_ip6_dst_ops;
+
 	net->ipv6.ip6_null_entry = kmemdup(&ip6_null_entry_template,
 					   sizeof(*net->ipv6.ip6_null_entry),
 					   GFP_KERNEL);
 	if (!net->ipv6.ip6_null_entry)
-		goto out_ip6_dst_ops;
+		goto out_ip6_dst_entries;
 	net->ipv6.ip6_null_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_null_entry;
 	net->ipv6.ip6_null_entry->dst.ops = &net->ipv6.ip6_dst_ops;
@@ -2720,6 +2724,8 @@ out_ip6_prohibit_entry:
 out_ip6_null_entry:
 	kfree(net->ipv6.ip6_null_entry);
 #endif
+out_ip6_dst_entries:
+	dst_entries_destroy(&net->ipv6.ip6_dst_ops);
 out_ip6_dst_ops:
 	goto out;
 }
@@ -2758,10 +2764,14 @@ int __init ip6_route_init(void)
 	if (!ip6_dst_ops_template.kmem_cachep)
 		goto out;
 
-	ret = register_pernet_subsys(&ip6_route_net_ops);
+	ret = dst_entries_init(&ip6_dst_blackhole_ops);
 	if (ret)
 		goto out_kmem_cache;
 
+	ret = register_pernet_subsys(&ip6_route_net_ops);
+	if (ret)
+		goto out_dst_entries;
+
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops_template.kmem_cachep;
 
 	/* Registering of the loopback is done before this portion of code,
@@ -2808,6 +2818,8 @@ out_fib6_init:
 	fib6_gc_cleanup();
 out_register_subsys:
 	unregister_pernet_subsys(&ip6_route_net_ops);
+out_dst_entries:
+	dst_entries_destroy(&ip6_dst_blackhole_ops);
 out_kmem_cache:
 	kmem_cache_destroy(ip6_dst_ops_template.kmem_cachep);
 	goto out;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 39676ea..7e74023 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -199,7 +199,7 @@ static inline int xfrm6_garbage_collect(struct dst_ops *ops)
 	struct net *net = container_of(ops, struct net, xfrm.xfrm6_dst_ops);
 
 	xfrm6_policy_afinfo.garbage_collect(net);
-	return atomic_read(&ops->entries) > ops->gc_thresh * 2;
+	return dst_entries_get_fast(ops) > ops->gc_thresh * 2;
 }
 
 static void xfrm6_update_pmtu(struct dst_entry *dst, u32 mtu)
@@ -255,7 +255,6 @@ static struct dst_ops xfrm6_dst_ops = {
 	.ifdown =		xfrm6_dst_ifdown,
 	.local_out =		__ip6_local_out,
 	.gc_thresh =		1024,
-	.entries =		ATOMIC_INIT(0),
 };
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
@@ -312,11 +311,13 @@ int __init xfrm6_init(void)
 	 */
 	gc_thresh = FIB6_TABLE_HASHSZ * 8;
 	xfrm6_dst_ops.gc_thresh = (gc_thresh < 1024) ? 1024 : gc_thresh;
+	dst_entries_init(&xfrm6_dst_ops);
 
 	ret = xfrm6_policy_init();
-	if (ret)
+	if (ret) {
+		dst_entries_destroy(&xfrm6_dst_ops);
 		goto out;
-
+	}
 	ret = xfrm6_state_init();
 	if (ret)
 		goto out_policy;
@@ -341,4 +342,5 @@ void xfrm6_fini(void)
 	//xfrm6_input_fini();
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
+	dst_entries_destroy(&xfrm6_dst_ops);
 }


