From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] bugfix and scalability changes in net/ipv4/route.c
Date: Fri, 24 Jun 2005 12:57:47 +0200
Message-ID: <42BBE72B.5010501@cosmosbay.com>
References: <Pine.LNX.4.62.0506232047450.29103@graphe.net>	<20050623.205447.66178303.davem@davemloft.net>	<Pine.LNX.4.62.0506232057340.29222@graphe.net> <20050623.211140.131918815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060606000907060000060301"
Cc: linux-net@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
In-Reply-To: <20050623.211140.131918815.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060606000907060000060301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

This is based on a previous patch I sent 3 months ago, reduced to only the essential part, since
the previous version got no success in netdev (some people said they were working on this stuff but still no progress)

reminder of the bugfix :

The rt_check_expire() has a serious problem on machines with large
route caches, and a standard HZ value of 1000.

With default values, ie ip_rt_gc_interval = 60*HZ = 60000 ;

the loop count :

     for (t = ip_rt_gc_interval << rt_hash_log; t >= 0;


overflows (t is a 31 bit value) as soon rt_hash_log is >= 16  (65536
slots in route cache hash table).

In this case, rt_check_expire() does nothing at all


Thank you

Eric Dumazet


[NET] Scalability fixes in net/ipv4/route.c, bugfix in rt_check_expire

  - Locking abstraction
  - Spinlocks moved out of rt hash table : Less memory (50%) used by rt hash table. it's a win even on UP.
  - Sizing of spinlocks table depends on NR_CPUS
  - rt hash table allocated using alloc_large_system_hash() function
  - rt_check_expire() fixes (an overflow was possible)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------060606000907060000060301
Content-Type: text/plain;
 name="patch.route"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.route"

--- linux-2.6.12/net/ipv4/route.c	2005-06-17 21:48:29.000000000 +0200
+++ linux-2.6.12-ed/net/ipv4/route.c	2005-06-24 11:10:06.000000000 +0200
@@ -54,6 +54,7 @@
  *		Marc Boucher	:	routing by fwmark
  *	Robert Olsson		:	Added rt_cache statistics
  *	Arnaldo C. Melo		:	Convert proc stuff to seq_file
+ *	Eric Dumazet		:	hashed spinlocks and rt_check_expire() fixes.
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -70,6 +71,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
+#include <linux/bootmem.h>
 #include <linux/string.h>
 #include <linux/socket.h>
 #include <linux/sockios.h>
@@ -201,8 +203,37 @@
 
 struct rt_hash_bucket {
 	struct rtable	*chain;
-	spinlock_t	lock;
-} __attribute__((__aligned__(8)));
+};
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
@@ -575,19 +606,24 @@
 /* This runs via a timer and thus is always in BH context. */
 static void rt_check_expire(unsigned long dummy)
 {
-	static int rover;
-	int i = rover, t;
+	static unsigned int rover;
+	int unsigned i = rover, goal;
 	struct rtable *rth, **rthp;
 	unsigned long now = jiffies;
-
-	for (t = ip_rt_gc_interval << rt_hash_log; t >= 0;
-	     t -= ip_rt_gc_timeout) {
+	u64 mult ;
+	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
+	if (ip_rt_gc_timeout > 1)
+		do_div(mult, ip_rt_gc_timeout);
+	goal = (unsigned int)mult;
+	if (goal > rt_hash_mask) goal = rt_hash_mask + 1;
+	for ( ; goal > 0 ; goal--) {
 		unsigned long tmo = ip_rt_gc_timeout;
 
 		i = (i + 1) & rt_hash_mask;
 		rthp = &rt_hash_table[i].chain;
 
-		spin_lock(&rt_hash_table[i].lock);
+		if (*rthp == 0) continue ;
+		spin_lock(rt_hash_lock_addr(i));
 		while ((rth = *rthp) != NULL) {
 			if (rth->u.dst.expires) {
 				/* Entry is expired even if it is in use */
@@ -620,8 +656,7 @@
  			rt_free(rth);
 #endif /* CONFIG_IP_ROUTE_MULTIPATH_CACHED */
 		}
-		spin_unlock(&rt_hash_table[i].lock);
-
+		spin_unlock(rt_hash_lock_addr(i));
 		/* Fallback loop breaker. */
 		if (time_after(jiffies, now))
 			break;
@@ -643,11 +678,11 @@
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
@@ -780,7 +815,7 @@
 
 			k = (k + 1) & rt_hash_mask;
 			rthp = &rt_hash_table[k].chain;
-			spin_lock_bh(&rt_hash_table[k].lock);
+			spin_lock_bh(rt_hash_lock_addr(k));
 			while ((rth = *rthp) != NULL) {
 				if (!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
@@ -812,7 +847,7 @@
 				goal--;
 #endif /* CONFIG_IP_ROUTE_MULTIPATH_CACHED */
 			}
-			spin_unlock_bh(&rt_hash_table[k].lock);
+			spin_unlock_bh(rt_hash_lock_addr(k));
 			if (goal <= 0)
 				break;
 		}
@@ -882,7 +917,7 @@
 
 	rthp = &rt_hash_table[hash].chain;
 
-	spin_lock_bh(&rt_hash_table[hash].lock);
+	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth = *rthp) != NULL) {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 		if (!(rth->u.dst.flags & DST_BALANCED) &&
@@ -908,7 +943,7 @@
 			rth->u.dst.__use++;
 			dst_hold(&rth->u.dst);
 			rth->u.dst.lastuse = now;
-			spin_unlock_bh(&rt_hash_table[hash].lock);
+			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			rt_drop(rt);
 			*rp = rth;
@@ -949,7 +984,7 @@
 	if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
 		int err = arp_bind_neighbour(&rt->u.dst);
 		if (err) {
-			spin_unlock_bh(&rt_hash_table[hash].lock);
+			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			if (err != -ENOBUFS) {
 				rt_drop(rt);
@@ -990,7 +1025,7 @@
 	}
 #endif
 	rt_hash_table[hash].chain = rt;
-	spin_unlock_bh(&rt_hash_table[hash].lock);
+	spin_unlock_bh(rt_hash_lock_addr(hash));
 	*rp = rt;
 	return 0;
 }
@@ -1058,7 +1093,7 @@
 {
 	struct rtable **rthp;
 
-	spin_lock_bh(&rt_hash_table[hash].lock);
+	spin_lock_bh(rt_hash_lock_addr(hash));
 	ip_rt_put(rt);
 	for (rthp = &rt_hash_table[hash].chain; *rthp;
 	     rthp = &(*rthp)->u.rt_next)
@@ -1067,7 +1102,7 @@
 			rt_free(rt);
 			break;
 		}
-	spin_unlock_bh(&rt_hash_table[hash].lock);
+	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
@@ -3069,12 +3104,14 @@
 
 int __init ip_rt_init(void)
 {
-	int i, order, goal, rc = 0;
+	int rc = 0;
 
 	rt_hash_rnd = (int) ((num_physpages ^ (num_physpages>>8)) ^
 			     (jiffies ^ (jiffies >> 7)));
 
 #ifdef CONFIG_NET_CLS_ROUTE
+	{
+	int order;
 	for (order = 0;
 	     (PAGE_SIZE << order) < 256 * sizeof(struct ip_rt_acct) * NR_CPUS; order++)
 		/* NOTHING */;
@@ -3082,6 +3119,7 @@
 	if (!ip_rt_acct)
 		panic("IP: failed to allocate ip_rt_acct\n");
 	memset(ip_rt_acct, 0, PAGE_SIZE << order);
+	}
 #endif
 
 	ipv4_dst_ops.kmem_cachep = kmem_cache_create("ip_dst_cache",
@@ -3092,39 +3130,22 @@
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
-
-	for (rt_hash_log = 0; (1 << rt_hash_log) != rt_hash_mask; rt_hash_log++)
-		/* NOTHING */;
-
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

--------------060606000907060000060301--
