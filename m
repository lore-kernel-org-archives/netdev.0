From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sat, 02 Apr 2005 01:21:49 +0200
Message-ID: <424DD78D.7070001@cosmosbay.com>
References: <42370997.6010302@cosmosbay.com>	<20050315103253.590c8bfc.davem@davemloft.net>	<42380EC6.60100@cosmosbay.com>	<20050316140915.0f6b9528.davem@davemloft.net>	<4239E00C.4080309@cosmosbay.com>	<20050331221352.13695124.davem@davemloft.net>	<424D5D34.4030800@cosmosbay.com>	<20050401122802.7c71afbc.davem@davemloft.net>	<424DB7A1.8090803@cosmosbay.com>	<20050401130832.1f972a3b.davem@davemloft.net>	<424DC08A.3020204@cosmosbay.com> <20050401143442.62ed8bb9.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090807070004040008080507"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050401143442.62ed8bb9.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090807070004040008080507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j31NNYpT008027

David S. Miller a =E9crit :
> On Fri, 01 Apr 2005 23:43:38 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>=20
>>Are you OK if I also use alloc_large_system_hash() to allocate
>>rt_hash_table, instead of the current method ? This new method is used
>>in net/ipv4/tcp.c for tcp_ehash and tcp_bhash and permits NUMA tuning.
>=20
>=20
> Sure, that's fine.
>=20
> BTW, please line-wrap your emails. :-/
>=20
>=20

:-)

OK this patch includes everything...

  - Locking abstraction
  - rt_check_expire() fixes
  - New gc_interval_ms sysctl to be able to have timer gc_interval < 1 se=
cond
  - New gc_debug sysctl to let sysadmin tune gc
  - Less memory used by hash table (spinlocks moved to a smaller table)
  - sizing of spinlocks table depends on NR_CPUS
  - hash table allocated using alloc_large_system_hash() function
  - header fix for /proc/net/stat/rt_cache

Thank you
Eric



--------------090807070004040008080507
Content-Type: text/plain;
 name="diff"
Content-Disposition: inline;
 filename="diff"
Content-Transfer-Encoding: 7bit

diff -Nru linux-2.6.11/net/ipv4/route.c linux-2.6.11-ed/net/ipv4/route.c
--- linux-2.6.11/net/ipv4/route.c	2005-03-02 08:38:38.000000000 +0100
+++ linux-2.6.11-ed/net/ipv4/route.c	2005-04-02 01:10:37.000000000 +0200
@@ -54,6 +54,8 @@
  *		Marc Boucher	:	routing by fwmark
  *	Robert Olsson		:	Added rt_cache statistics
  *	Arnaldo C. Melo		:	Convert proc stuff to seq_file
+ *      Eric Dumazet            :       hashed spinlocks and rt_check_expire() fixes.
+ *				:	bugfix in rt_cpu_seq_show()
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -70,6 +72,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
+#include <linux/bootmem.h>
 #include <linux/string.h>
 #include <linux/socket.h>
 #include <linux/sockios.h>
@@ -107,12 +110,13 @@
 #define IP_MAX_MTU	0xFFF0
 
 #define RT_GC_TIMEOUT (300*HZ)
+#define RT_GC_INTERVAL (RT_GC_TIMEOUT/10) /* rt_check_expire() scans 1/10 of the table each round */
 
 static int ip_rt_min_delay		= 2 * HZ;
 static int ip_rt_max_delay		= 10 * HZ;
 static int ip_rt_max_size;
 static int ip_rt_gc_timeout		= RT_GC_TIMEOUT;
-static int ip_rt_gc_interval		= 60 * HZ;
+static int ip_rt_gc_interval		= RT_GC_INTERVAL;
 static int ip_rt_gc_min_interval	= HZ / 2;
 static int ip_rt_redirect_number	= 9;
 static int ip_rt_redirect_load		= HZ / 50;
@@ -124,6 +128,7 @@
 static int ip_rt_min_pmtu		= 512 + 20 + 20;
 static int ip_rt_min_advmss		= 256;
 static int ip_rt_secret_interval	= 10 * 60 * HZ;
+static int ip_rt_debug;
 static unsigned long rt_deadline;
 
 #define RTprint(a...)	printk(KERN_DEBUG a)
@@ -197,8 +202,38 @@
 
 struct rt_hash_bucket {
 	struct rtable	*chain;
-	spinlock_t	lock;
-} __attribute__((__aligned__(8)));
+};
+
+#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
+/*
+ * Instead of using one spinlock for each rt_hash_bucket, we use a table of spinlocks
+ * The size of this table is a power of two and depends on the number of CPUS.
+ */
+#if NR_CPUS >= 32
+#define RT_HASH_LOCK_SZ	4096
+#elif NR_CPUS >= 16
+#define RT_HASH_LOCK_SZ	2048
+#elif NR_CPUS >= 8
+#define RT_HASH_LOCK_SZ	1024
+#elif NR_CPUS >= 4
+#define RT_HASH_LOCK_SZ	512
+#else
+#define RT_HASH_LOCK_SZ	256
+#endif
+
+	static spinlock_t	*rt_hash_locks;
+# define rt_hash_lock_addr(slot) &rt_hash_locks[slot & (RT_HASH_LOCK_SZ - 1)]
+# define rt_hash_lock_init()	{ \
+		int i; \
+		rt_hash_locks = kmalloc(sizeof(spinlock_t) * RT_HASH_LOCK_SZ, GFP_KERNEL); \
+		if (!rt_hash_locks) panic("IP: failed to allocate rt_hash_locks\n"); \
+		for (i = 0; i < RT_HASH_LOCK_SZ; i++) \
+			spin_lock_init(&rt_hash_locks[i]); \
+		}
+#else
+# define rt_hash_lock_addr(slot) NULL
+# define rt_hash_lock_init()
+#endif
 
 static struct rt_hash_bucket 	*rt_hash_table;
 static unsigned			rt_hash_mask;
@@ -393,7 +428,7 @@
 	struct rt_cache_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
+		seq_printf(seq, "entries  in_hit in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
 		return 0;
 	}
 	
@@ -470,7 +505,7 @@
 		rth->u.dst.expires;
 }
 
-static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
+static __inline__ int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
 {
 	unsigned long age;
 	int ret = 0;
@@ -516,45 +551,93 @@
 /* This runs via a timer and thus is always in BH context. */
 static void rt_check_expire(unsigned long dummy)
 {
-	static int rover;
-	int i = rover, t;
+	static unsigned int rover;
+	static unsigned int effective_interval = RT_GC_INTERVAL;
+	static unsigned int cached_gc_interval = RT_GC_INTERVAL;
+	unsigned int i, goal;
 	struct rtable *rth, **rthp;
 	unsigned long now = jiffies;
+	unsigned int freed = 0 , t0;
+	u64 mult;
 
-	for (t = ip_rt_gc_interval << rt_hash_log; t >= 0;
-	     t -= ip_rt_gc_timeout) {
-		unsigned long tmo = ip_rt_gc_timeout;
-
+	if (cached_gc_interval != ip_rt_gc_interval) { /* ip_rt_gc_interval may have changed with sysctl */
+		cached_gc_interval = ip_rt_gc_interval;
+		effective_interval = cached_gc_interval;
+	}
+	/* Computes the number of slots we should examin in this run :
+	 * We want to perform a full scan every ip_rt_gc_timeout, and
+	 * the timer is started every 'effective_interval' ticks.
+	 * so goal = (number_of_slots) * (effective_interval / ip_rt_gc_timeout)
+	 */
+	mult = ((u64)effective_interval) << rt_hash_log;
+	do_div(mult, ip_rt_gc_timeout);
+	goal = (unsigned int)mult;
+
+	i = atomic_read(&ipv4_dst_ops.entries) << 3;
+	if (i > ip_rt_max_size) {
+		goal <<= 1; /* be more aggressive */
+		i >>= 1;
+		if (i > ip_rt_max_size) {
+			goal <<= 1; /* be more aggressive */
+			i >>= 1;
+			if (i > ip_rt_max_size) {
+				goal <<= 1; /* be more aggressive */
+				now++; /* give us one more tick (time) to do our job */
+			}
+		}
+	}
+	if (goal > rt_hash_mask) goal = rt_hash_mask + 1;
+	t0 = goal;
+	i = rover;
+	for ( ; goal > 0; goal--) {
 		i = (i + 1) & rt_hash_mask;
 		rthp = &rt_hash_table[i].chain;
-
-		spin_lock(&rt_hash_table[i].lock);
-		while ((rth = *rthp) != NULL) {
-			if (rth->u.dst.expires) {
-				/* Entry is expired even if it is in use */
-				if (time_before_eq(now, rth->u.dst.expires)) {
+		if (*rthp) {
+			unsigned long tmo = ip_rt_gc_timeout;
+			spin_lock(rt_hash_lock_addr(i));
+			while ((rth = *rthp) != NULL) {
+				if (rth->u.dst.expires) {
+					/* Entry is expired even if it is in use */
+					if (time_before_eq(now, rth->u.dst.expires)) {
+						tmo >>= 1;
+						rthp = &rth->u.rt_next;
+						continue;
+					}
+				} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
 					tmo >>= 1;
 					rthp = &rth->u.rt_next;
 					continue;
 				}
-			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
-				tmo >>= 1;
-				rthp = &rth->u.rt_next;
-				continue;
-			}
 
-			/* Cleanup aged off entries. */
-			*rthp = rth->u.rt_next;
-			rt_free(rth);
+				/* Cleanup aged off entries. */
+				*rthp = rth->u.rt_next;
+				freed++;
+				rt_free(rth);
+			}
+			spin_unlock(rt_hash_lock_addr(i));
 		}
-		spin_unlock(&rt_hash_table[i].lock);
-
 		/* Fallback loop breaker. */
 		if (time_after(jiffies, now))
 			break;
 	}
 	rover = i;
-	mod_timer(&rt_periodic_timer, now + ip_rt_gc_interval);
+	if (goal != 0) {
+		/* Not enough time to perform our job, try to adjust the timer.
+		 * Firing the timer sooner means less planned work.
+		 * We allow the timer to be 1/8 of the sysctl value.
+		 */
+		effective_interval = (effective_interval + cached_gc_interval/8)/2;
+	}
+	else {
+		/* We finished our job before time limit, try to increase the timer
+		 * The limit is the sysctl value, we use a weight of 3/1 to
+		 * increase slowly.
+		 */
+		effective_interval = (3*effective_interval + cached_gc_interval + 3)/4;
+	}
+	if (ip_rt_debug & 1)
+		printk(KERN_WARNING "rt_check_expire() : %u freed, goal=%u/%u, interval=%u ticks\n", freed, goal, t0, effective_interval);
+	mod_timer(&rt_periodic_timer, jiffies + effective_interval);
 }
 
 /* This can run from both BH and non-BH contexts, the latter
@@ -570,11 +653,11 @@
 	get_random_bytes(&rt_hash_rnd, 4);
 
 	for (i = rt_hash_mask; i >= 0; i--) {
-		spin_lock_bh(&rt_hash_table[i].lock);
+		spin_lock_bh(rt_hash_lock_addr(i));
 		rth = rt_hash_table[i].chain;
 		if (rth)
 			rt_hash_table[i].chain = NULL;
-		spin_unlock_bh(&rt_hash_table[i].lock);
+		spin_unlock_bh(rt_hash_lock_addr(i));
 
 		for (; rth; rth = next) {
 			next = rth->u.rt_next;
@@ -704,7 +787,7 @@
 
 			k = (k + 1) & rt_hash_mask;
 			rthp = &rt_hash_table[k].chain;
-			spin_lock_bh(&rt_hash_table[k].lock);
+			spin_lock_bh(rt_hash_lock_addr(k));
 			while ((rth = *rthp) != NULL) {
 				if (!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
@@ -715,7 +798,7 @@
 				rt_free(rth);
 				goal--;
 			}
-			spin_unlock_bh(&rt_hash_table[k].lock);
+			spin_unlock_bh(rt_hash_lock_addr(k));
 			if (goal <= 0)
 				break;
 		}
@@ -792,7 +875,7 @@
 
 	rthp = &rt_hash_table[hash].chain;
 
-	spin_lock_bh(&rt_hash_table[hash].lock);
+	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth = *rthp) != NULL) {
 		if (compare_keys(&rth->fl, &rt->fl)) {
 			/* Put it first */
@@ -813,7 +896,7 @@
 			rth->u.dst.__use++;
 			dst_hold(&rth->u.dst);
 			rth->u.dst.lastuse = now;
-			spin_unlock_bh(&rt_hash_table[hash].lock);
+			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			rt_drop(rt);
 			*rp = rth;
@@ -854,7 +937,7 @@
 	if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
 		int err = arp_bind_neighbour(&rt->u.dst);
 		if (err) {
-			spin_unlock_bh(&rt_hash_table[hash].lock);
+			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			if (err != -ENOBUFS) {
 				rt_drop(rt);
@@ -895,7 +978,7 @@
 	}
 #endif
 	rt_hash_table[hash].chain = rt;
-	spin_unlock_bh(&rt_hash_table[hash].lock);
+	spin_unlock_bh(rt_hash_lock_addr(hash));
 	*rp = rt;
 	return 0;
 }
@@ -962,7 +1045,7 @@
 {
 	struct rtable **rthp;
 
-	spin_lock_bh(&rt_hash_table[hash].lock);
+	spin_lock_bh(rt_hash_lock_addr(hash));
 	ip_rt_put(rt);
 	for (rthp = &rt_hash_table[hash].chain; *rthp;
 	     rthp = &(*rthp)->u.rt_next)
@@ -971,7 +1054,7 @@
 			rt_free(rt);
 			break;
 		}
-	spin_unlock_bh(&rt_hash_table[hash].lock);
+	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
@@ -2569,6 +2652,23 @@
 		.strategy	= &sysctl_jiffies,
 	},
 	{
+		.ctl_name	= NET_IPV4_ROUTE_GC_INTERVAL_MS,
+		.procname	= "gc_interval_ms",
+		.data		= &ip_rt_gc_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_ms_jiffies,
+		.strategy	= &sysctl_ms_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_ROUTE_GC_DEBUG,
+		.procname	= "gc_debug",
+		.data		= &ip_rt_debug,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= NET_IPV4_ROUTE_REDIRECT_LOAD,
 		.procname	= "redirect_load",
 		.data		= &ip_rt_redirect_load,
@@ -2718,12 +2818,13 @@
 
 int __init ip_rt_init(void)
 {
-	int i, order, goal, rc = 0;
 
 	rt_hash_rnd = (int) ((num_physpages ^ (num_physpages>>8)) ^
 			     (jiffies ^ (jiffies >> 7)));
 
 #ifdef CONFIG_NET_CLS_ROUTE
+	{
+	int order;
 	for (order = 0;
 	     (PAGE_SIZE << order) < 256 * sizeof(struct ip_rt_acct) * NR_CPUS; order++)
 		/* NOTHING */;
@@ -2731,6 +2832,7 @@
 	if (!ip_rt_acct)
 		panic("IP: failed to allocate ip_rt_acct\n");
 	memset(ip_rt_acct, 0, PAGE_SIZE << order);
+	}
 #endif
 
 	ipv4_dst_ops.kmem_cachep = kmem_cache_create("ip_dst_cache",
@@ -2741,39 +2843,24 @@
 	if (!ipv4_dst_ops.kmem_cachep)
 		panic("IP: failed to allocate ip_dst_cache\n");
 
-	goal = num_physpages >> (26 - PAGE_SHIFT);
-	if (rhash_entries)
-		goal = (rhash_entries * sizeof(struct rt_hash_bucket)) >> PAGE_SHIFT;
-	for (order = 0; (1UL << order) < goal; order++)
-		/* NOTHING */;
-
-	do {
-		rt_hash_mask = (1UL << order) * PAGE_SIZE /
-			sizeof(struct rt_hash_bucket);
-		while (rt_hash_mask & (rt_hash_mask - 1))
-			rt_hash_mask--;
-		rt_hash_table = (struct rt_hash_bucket *)
-			__get_free_pages(GFP_ATOMIC, order);
-	} while (rt_hash_table == NULL && --order > 0);
-
-	if (!rt_hash_table)
-		panic("Failed to allocate IP route cache hash table\n");
-
-	printk(KERN_INFO "IP: routing cache hash table of %u buckets, %ldKbytes\n",
-	       rt_hash_mask,
-	       (long) (rt_hash_mask * sizeof(struct rt_hash_bucket)) / 1024);
+	rt_hash_table = (struct rt_hash_bucket *)
+		alloc_large_system_hash("IP route cache",
+					sizeof(struct rt_hash_bucket),
+					rhash_entries,
+					(num_physpages >= 128 * 1024) ?
+						(27 - PAGE_SHIFT) :
+						(29 - PAGE_SHIFT),
+					HASH_HIGHMEM,
+					&rt_hash_log,
+					&rt_hash_mask,
+					0);
 
-	for (rt_hash_log = 0; (1 << rt_hash_log) != rt_hash_mask; rt_hash_log++)
-		/* NOTHING */;
+	memset(rt_hash_table, 0, rt_hash_mask * sizeof(struct rt_hash_bucket));
+	rt_hash_lock_init();
 
+	ipv4_dst_ops.gc_thresh = rt_hash_mask;
+	ip_rt_max_size = rt_hash_mask * 16;
 	rt_hash_mask--;
-	for (i = 0; i <= rt_hash_mask; i++) {
-		spin_lock_init(&rt_hash_table[i].lock);
-		rt_hash_table[i].chain = NULL;
-	}
-
-	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
-	ip_rt_max_size = (rt_hash_mask + 1) * 16;
 
 	rt_cache_stat = alloc_percpu(struct rt_cache_stat);
 	if (!rt_cache_stat)
@@ -2819,7 +2906,7 @@
 	xfrm_init();
 	xfrm4_init();
 #endif
-	return rc;
+	return 0;
 }
 
 EXPORT_SYMBOL(__ip_select_ident);
diff -Nru linux-2.6.11/Documentation/filesystems/proc.txt linux-2.6.11-ed/Documentation/filesystems/proc.txt
--- linux-2.6.11/Documentation/filesystems/proc.txt	2005-04-02 01:19:15.000000000 +0200
+++ linux-2.6.11-ed/Documentation/filesystems/proc.txt	2005-04-02 01:19:04.000000000 +0200
@@ -1709,12 +1709,13 @@
 
 Writing to this file results in a flush of the routing cache.
 
-gc_elasticity, gc_interval, gc_min_interval_ms, gc_timeout, gc_thresh
+gc_elasticity, gc_interval_ms, gc_min_interval_ms, gc_timeout, gc_thresh, gc_debug
 ---------------------------------------------------------------------
 
 Values to  control  the  frequency  and  behavior  of  the  garbage collection
 algorithm for the routing cache. gc_min_interval is deprecated and replaced
-by gc_min_interval_ms.
+by gc_min_interval_ms. gc_interval is deprecated and replaced by
+gc_interval_ms. gc_debug enables some printk()
 
 
 max_size
diff -Nru linux-2.6.11/include/linux/sysctl.h linux-2.6.11-ed/include/linux/sysctl.h
--- linux-2.6.11/include/linux/sysctl.h	2005-03-02 08:38:10.000000000 +0100
+++ linux-2.6.11-ed/include/linux/sysctl.h	2005-04-02 00:43:11.000000000 +0200
@@ -367,6 +367,8 @@
 	NET_IPV4_ROUTE_MIN_ADVMSS=17,
 	NET_IPV4_ROUTE_SECRET_INTERVAL=18,
 	NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS=19,
+	NET_IPV4_ROUTE_GC_INTERVAL_MS=20,
+	NET_IPV4_ROUTE_GC_DEBUG=21,
 };
 
 enum

--------------090807070004040008080507--
