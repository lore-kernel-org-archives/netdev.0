From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Thu, 17 Mar 2005 20:52:44 +0100
Message-ID: <4239E00C.4080309@cosmosbay.com>
References: <42370997.6010302@cosmosbay.com>	<20050315103253.590c8bfc.davem@davemloft.net>	<42380EC6.60100@cosmosbay.com> <20050316140915.0f6b9528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040704050108060909010704"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050316140915.0f6b9528.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040704050108060909010704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j2HJsE72023785

David S. Miller a =E9crit :
> On Wed, 16 Mar 2005 11:47:34 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>=20
>>The rt_check_expire() has a serious problem on machines with large
>>route caches, and a standard HZ value of 1000.
>>
>>With default values, ie ip_rt_gc_interval =3D 60*HZ =3D 60000 ;
>>
>>the loop count :
>>
>>     for (t =3D ip_rt_gc_interval << rt_hash_log; t >=3D 0;
>>
>>
>>overflows (t is a 31 bit value) as soon rt_hash_log is >=3D 16  (65536
>>slots in route cache hash table)
>=20
>  ...
>=20
>>I am experimenting some changes that I will share when ready.
>=20
>=20
> Good catch, let us know when you have a patch for review.
>=20
>=20

Hi

This is the patch I'm currently running on several machines (with very hi=
gh pressure on route cache)

If you want to comment it before I submit it with a nice looking mail :)

Description :

    - Makes rt_check_expire() do some real work, auto-adapting the timer =
interval (chosen between gc_interval/8 and gc_interval)

    - Move the spinlocks out of tr_hash_table[] to a fixed size table : S=
aves a lot of memory (particulary on UP)

Thank you

Eric Dumazet

--------------040704050108060909010704
Content-Type: text/plain;
 name="diff"
Content-Disposition: inline;
 filename="diff"
Content-Transfer-Encoding: 7bit

diff -Nru linux-2.6.11/net/ipv4/route.c linux-2.6.11-ed/net/ipv4/route.c
--- linux-2.6.11/net/ipv4/route.c	2005-03-17 11:19:45.000000000 +0100
+++ linux-2.6.11-ed/net/ipv4/route.c	2005-03-17 18:33:20.000000000 +0100
@@ -54,6 +54,7 @@
  *		Marc Boucher	:	routing by fwmark
  *	Robert Olsson		:	Added rt_cache statistics
  *	Arnaldo C. Melo		:	Convert proc stuff to seq_file
+ *      Eric Dumazet            :       hashed spinlocks and rt_check_expire() fixes.
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -107,12 +108,13 @@
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
@@ -124,6 +126,7 @@
 static int ip_rt_min_pmtu		= 512 + 20 + 20;
 static int ip_rt_min_advmss		= 256;
 static int ip_rt_secret_interval	= 10 * 60 * HZ;
+static int ip_rt_debug ;
 static unsigned long rt_deadline;
 
 #define RTprint(a...)	printk(KERN_DEBUG a)
@@ -197,8 +200,24 @@
 
 struct rt_hash_bucket {
 	struct rtable	*chain;
-	spinlock_t	lock;
-} __attribute__((__aligned__(8)));
+};
+
+#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
+/*
+ * Instead of using one spinlock for each rt_hash_bucket, we use a table of fixed size spinlocks
+ */
+# define RT_HASH_LOCK_SZ 256
+	static spinlock_t	rt_hash_lock[RT_HASH_LOCK_SZ];
+# define rt_hash_lock_addr(slot) &rt_hash_lock[slot & (RT_HASH_LOCK_SZ - 1)]
+# define rt_hash_lock_init()	{ \
+		int i; \
+		for (i = 0; i < RT_HASH_LOCK_SZ; i++) \
+			spin_lock_init(&rt_hash_lock[i]); \
+		}
+#else
+# define rt_hash_lock_addr(slot) NULL
+# define rt_hash_lock_init()
+#endif
 
 static struct rt_hash_bucket 	*rt_hash_table;
 static unsigned			rt_hash_mask;
@@ -470,7 +489,7 @@
 		rth->u.dst.expires;
 }
 
-static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
+static __inline__ int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
 {
 	unsigned long age;
 	int ret = 0;
@@ -516,45 +535,84 @@
 /* This runs via a timer and thus is always in BH context. */
 static void rt_check_expire(unsigned long dummy)
 {
-	static int rover;
-	int i = rover, t;
+	static unsigned int rover;
+	static unsigned int effective_interval = RT_GC_INTERVAL;
+	static unsigned int cached_gc_interval = RT_GC_INTERVAL;
+	unsigned int i = rover, t;
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
+	/* computes the number of slots we should examin in this run */
+	mult = ((u64)effective_interval) << rt_hash_log;
+	do_div(mult, ip_rt_gc_timeout);
+	t = (unsigned int)mult;
+
+	if (atomic_read(&ipv4_dst_ops.entries) > ip_rt_max_size/8) {
+		t <<= 1; /* be more aggressive */
+		if (atomic_read(&ipv4_dst_ops.entries) > ip_rt_max_size/4) {
+			t <<= 1; /* be more aggressive */
+			if (atomic_read(&ipv4_dst_ops.entries) > ip_rt_max_size/2) {
+				t <<= 1; /* be more aggressive */
+				now++; /* give us one more tick (time) to do our job */
+			}
+		}
+	}
+	if (t > rt_hash_mask) t = rt_hash_mask + 1;
+	t0 = t;
+	for ( ; t > 0; t -= 1) {
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
+	
+				/* Cleanup aged off entries. */
+				*rthp = rth->u.rt_next;
+				freed++;
+				rt_free(rth);
 			}
-
-			/* Cleanup aged off entries. */
-			*rthp = rth->u.rt_next;
-			rt_free(rth);
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
+	if (t) {
+		/* Not enough time to perform our job, try to adjust the timer.
+		 * Firing the timer sooner means less planned work.
+		 * We allow the timer to be 1/8 of the sysctl value.
+		 */
+		effective_interval = (effective_interval + cached_gc_interval/8)/2;
+	}
+	else {
+		/* We finished our job before time limit, try to increase the timer
+		 * The limit is the sysctl value.
+		 */
+		effective_interval = (effective_interval + cached_gc_interval)/2;
+	}
+	if (ip_rt_debug & 1)
+		printk(KERN_WARNING "rt_check_expire() : %u freed, t=%u/%u interval=%u ticks\n", freed, t, t0, effective_interval);
+	mod_timer(&rt_periodic_timer, jiffies + effective_interval);
 }
 
 /* This can run from both BH and non-BH contexts, the latter
@@ -570,11 +628,11 @@
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
@@ -704,7 +762,7 @@
 
 			k = (k + 1) & rt_hash_mask;
 			rthp = &rt_hash_table[k].chain;
-			spin_lock_bh(&rt_hash_table[k].lock);
+			spin_lock_bh(rt_hash_lock_addr(k));
 			while ((rth = *rthp) != NULL) {
 				if (!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
@@ -715,7 +773,7 @@
 				rt_free(rth);
 				goal--;
 			}
-			spin_unlock_bh(&rt_hash_table[k].lock);
+			spin_unlock_bh(rt_hash_lock_addr(k));
 			if (goal <= 0)
 				break;
 		}
@@ -792,7 +850,7 @@
 
 	rthp = &rt_hash_table[hash].chain;
 
-	spin_lock_bh(&rt_hash_table[hash].lock);
+	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth = *rthp) != NULL) {
 		if (compare_keys(&rth->fl, &rt->fl)) {
 			/* Put it first */
@@ -813,7 +871,7 @@
 			rth->u.dst.__use++;
 			dst_hold(&rth->u.dst);
 			rth->u.dst.lastuse = now;
-			spin_unlock_bh(&rt_hash_table[hash].lock);
+			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			rt_drop(rt);
 			*rp = rth;
@@ -854,7 +912,7 @@
 	if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
 		int err = arp_bind_neighbour(&rt->u.dst);
 		if (err) {
-			spin_unlock_bh(&rt_hash_table[hash].lock);
+			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			if (err != -ENOBUFS) {
 				rt_drop(rt);
@@ -895,7 +953,7 @@
 	}
 #endif
 	rt_hash_table[hash].chain = rt;
-	spin_unlock_bh(&rt_hash_table[hash].lock);
+	spin_unlock_bh(rt_hash_lock_addr(hash));
 	*rp = rt;
 	return 0;
 }
@@ -962,7 +1020,7 @@
 {
 	struct rtable **rthp;
 
-	spin_lock_bh(&rt_hash_table[hash].lock);
+	spin_lock_bh(rt_hash_lock_addr(hash));
 	ip_rt_put(rt);
 	for (rthp = &rt_hash_table[hash].chain; *rthp;
 	     rthp = &(*rthp)->u.rt_next)
@@ -971,7 +1029,7 @@
 			rt_free(rt);
 			break;
 		}
-	spin_unlock_bh(&rt_hash_table[hash].lock);
+	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
@@ -2569,6 +2627,23 @@
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
@@ -2718,7 +2793,7 @@
 
 int __init ip_rt_init(void)
 {
-	int i, order, goal, rc = 0;
+	int order, goal, rc = 0;
 
 	rt_hash_rnd = (int) ((num_physpages ^ (num_physpages>>8)) ^
 			     (jiffies ^ (jiffies >> 7)));
@@ -2766,14 +2841,12 @@
 	for (rt_hash_log = 0; (1 << rt_hash_log) != rt_hash_mask; rt_hash_log++)
 		/* NOTHING */;
 
-	rt_hash_mask--;
-	for (i = 0; i <= rt_hash_mask; i++) {
-		spin_lock_init(&rt_hash_table[i].lock);
-		rt_hash_table[i].chain = NULL;
-	}
+	memset(rt_hash_table, 0, rt_hash_mask * sizeof(struct rt_hash_bucket));
+	rt_hash_lock_init();
 
-	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
-	ip_rt_max_size = (rt_hash_mask + 1) * 16;
+	ipv4_dst_ops.gc_thresh = rt_hash_mask;
+	ip_rt_max_size = rt_hash_mask * 16;
+	rt_hash_mask--;
 
 	rt_cache_stat = alloc_percpu(struct rt_cache_stat);
 	if (!rt_cache_stat)
diff -Nru linux-2.6.11/Documentation/filesystems/proc.txt linux-2.6.11-ed/Documentation/filesystems/proc.txt
--- linux-2.6.11/Documentation/filesystems/proc.txt	2005-03-17 18:42:54.000000000 +0100
+++ linux-2.6.11-ed/Documentation/filesystems/proc.txt	2005-03-17 18:42:14.000000000 +0100
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
--- linux-2.6.11/include/linux/sysctl.h	2005-03-17 18:37:13.000000000 +0100
+++ linux-2.6.11-ed/include/linux/sysctl.h	2005-03-17 18:36:57.000000000 +0100
@@ -367,6 +367,8 @@
 	NET_IPV4_ROUTE_MIN_ADVMSS=17,
 	NET_IPV4_ROUTE_SECRET_INTERVAL=18,
 	NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS=19,
+	NET_IPV4_ROUTE_GC_INTERVAL_MS=20,
+	NET_IPV4_ROUTE_GC_DEBUG=21,
 };
 
 enum

--------------040704050108060909010704--
