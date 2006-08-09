From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] [IPV4] route: Dynamic hash table sizing.
Date: Wed, 09 Aug 2006 00:53:37 -0700 (PDT)
Message-ID: <20060809.005337.104642177.davem@davemloft.net>
References: <20060809.004920.59469729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21658
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030255AbWHIHyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:54:00 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 51D12AE43C4
	for <netdev@vger.kernel.org>; Wed,  9 Aug 2006 00:53:37 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <20060809.004920.59469729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[IPV4] route: Dynamic hash table sizing.

The algorithm is stupid, this changeset is about infrastructure.

Currently it starts at 16 entries (or whatever rhash_entries was
specified as), and allows growing up to 8MB.

The code can handle both growing and shrinking just fine, the only
tweaks necessary are to the rthash_new_size() function and the places
where rtcache_work is scheduled.

hashdist is now used at run-time so we need to drop the __initdata
tag.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 mm/page_alloc.c  |    2 -
 net/ipv4/route.c |  179 +++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 158 insertions(+), 23 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 54a4f53..3b5358a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2363,7 +2363,7 @@ int percpu_pagelist_fraction_sysctl_hand
 	return 0;
 }
 
-__initdata int hashdist = HASHDIST_DEFAULT;
+int hashdist = HASHDIST_DEFAULT;
 
 #ifdef CONFIG_NUMA
 static int __init set_hashdist(char *str)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a7b4ca2..897e67c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -94,6 +94,9 @@ #include <linux/jhash.h>
 #include <linux/rcupdate.h>
 #include <linux/times.h>
 #include <linux/seqlock.h>
+#include <linux/workqueue.h>
+#include <linux/vmalloc.h>
+#include <linux/mutex.h>
 #include <net/protocol.h>
 #include <net/ip.h>
 #include <net/route.h>
@@ -120,6 +123,7 @@ #define RT_GC_TIMEOUT (300*HZ)
 static int ip_rt_min_delay		= 2 * HZ;
 static int ip_rt_max_delay		= 10 * HZ;
 static int ip_rt_max_size;
+static int ip_rt_hashsz_limit		= (8 * 1024 * 1024) / sizeof(void *);
 static int ip_rt_gc_timeout		= RT_GC_TIMEOUT;
 static int ip_rt_gc_interval		= 60 * HZ;
 static int ip_rt_gc_min_interval	= HZ / 2;
@@ -308,6 +312,135 @@ static void rt_hash_snapshot(struct rt_h
 	} while (read_seqretry(&rt_hash_seq, seq));
 }
 
+static struct rt_hash_bucket *rthash_alloc(unsigned int sz)
+{
+	struct rt_hash_bucket *n;
+
+	if (sz <= PAGE_SIZE)
+		n = kmalloc(sz, GFP_KERNEL);
+	else if (hashdist)
+		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
+	else
+		n = (struct rt_hash_bucket *)
+			__get_free_pages(GFP_KERNEL, get_order(sz));
+
+	if (n)
+		memset(n, 0, sz);
+
+	return n;
+}
+
+static void rthash_free(struct rt_hash_bucket *r, unsigned int sz)
+{
+	if (sz <= PAGE_SIZE)
+		kfree(r);
+	else if (hashdist)
+		vfree(r);
+	else
+		free_pages((unsigned long)r, get_order(sz));
+}
+
+static void rtcache_transfer(struct rtable *list, struct rt_hash_bucket *new_table, unsigned int nhashmask)
+{
+	while (list) {
+		struct rtable *next = list->u.rt_next;
+		struct rt_hash_bucket *ent;
+		int iface = list->fl.iif;
+		unsigned int hash;
+
+		if (!iface)
+			iface = list->fl.oif;
+		hash = __rt_hash_code(list->fl.fl4_dst,
+				      list->fl.fl4_src &
+				      (iface << 5),
+				      nhashmask);
+		ent = &new_table[hash];
+		list->u.rt_next = ent->chain;
+		ent->chain = list;
+
+		list = next;
+	}
+}
+
+static unsigned long rthash_new_size(void)
+{
+	return ((__rt_hash_mask + 1) << 1) *
+		sizeof(struct rt_hash_bucket);
+}
+
+static __inline__ void rt_free(struct rtable *rt)
+{
+	multipath_remove(rt);
+	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
+}
+
+static DEFINE_MUTEX(hash_resize_mutex);
+
+static void rtcache_resize(void *__unused)
+{
+	struct rt_hash_bucket *new, *old;
+	unsigned long nsize;
+	unsigned int nhashmask, ohashmask;
+	int i;
+
+	mutex_lock(&hash_resize_mutex);
+
+	nsize = rthash_new_size();
+	new = rthash_alloc(nsize);
+	if (!new)
+		goto out_unlock;
+
+	write_seqlock_bh(&rt_hash_seq);
+
+	nhashmask = (nsize / sizeof(struct rt_hash_bucket)) - 1U;
+	for (i = __rt_hash_mask; i >= 0; i--) {
+		struct rtable *rth;
+
+		spin_lock_bh(rt_hash_lock_addr(i));
+		rth = __rt_hash_table[i].chain;
+		if (rth)
+			__rt_hash_table[i].chain = NULL;
+		spin_unlock_bh(rt_hash_lock_addr(i));
+
+		rtcache_transfer(rth, new, nhashmask);
+	}
+
+	old = __rt_hash_table;
+	ohashmask = __rt_hash_mask;
+
+	__rt_hash_table = new;
+	__rt_hash_mask = nhashmask;
+
+	/* XXX Do something more intelligent with these things.  */
+	ipv4_dst_ops.gc_thresh = (__rt_hash_mask + 1);
+	ip_rt_max_size = (__rt_hash_mask + 1) * 16;
+
+	write_sequnlock_bh(&rt_hash_seq);
+
+	synchronize_net();
+
+	/* It is possible that some entries got hashed into the old
+	 * table, free any such remnants.  No locking is necessary on
+	 * the chains as this table is no longer viewable by other
+	 * processors.
+	 */
+	for (i = ohashmask; i >= 0; i--) {
+		struct rtable *rth, *next;
+
+		for (rth = old[i].chain; rth; rth = next) {
+			next = rth->u.rt_next;
+			rt_free(rth);
+		}
+	}
+
+	rthash_free(old, (ohashmask + 1) * sizeof(struct rt_hash_bucket));
+
+out_unlock:
+	mutex_unlock(&hash_resize_mutex);
+}
+
+static DECLARE_WORK(rtcache_work, rtcache_resize, NULL);
+
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
 	struct rt_hash_bucket *table;
@@ -540,12 +673,6 @@ static struct file_operations rt_cpu_seq
 
 #endif /* CONFIG_PROC_FS */
   
-static __inline__ void rt_free(struct rtable *rt)
-{
-	multipath_remove(rt);
-	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
-}
-
 static __inline__ void rt_drop(struct rtable *rt)
 {
 	multipath_remove(rt);
@@ -676,7 +803,7 @@ static void rt_check_expire(unsigned lon
 
 	rt_hash_snapshot(&table, &hmask);
 
-	mult = ((u64)ip_rt_gc_interval) << long_log2(hmask + 1);
+	mult = ((u64)(hmask + 1)) << (u64)ip_rt_gc_interval;
 	if (ip_rt_gc_timeout > 1)
 		do_div(mult, ip_rt_gc_timeout);
 	goal = (unsigned int)mult;
@@ -857,7 +984,7 @@ static int rt_garbage_collect(void)
 
 	/* Calculate number of entries, which we want to expire now. */
 	goal = atomic_read(&ipv4_dst_ops.entries) -
-		(ip_rt_gc_elasticity << long_log2(hmask + 1));
+		((hmask + 1) << ip_rt_gc_elasticity);
 	if (goal <= 0) {
 		if (equilibrium < ipv4_dst_ops.gc_thresh)
 			equilibrium = ipv4_dst_ops.gc_thresh;
@@ -971,7 +1098,11 @@ #if RT_CACHE_DEBUG >= 2
 	printk(KERN_DEBUG "expire++ %u %d %d %d\n", expire,
 			atomic_read(&ipv4_dst_ops.entries), goal, rover);
 #endif
-out:	return 0;
+out:
+	if (atomic_read(&ipv4_dst_ops.entries) >= (hmask + 1) &&
+	    (hmask + 1) < ip_rt_hashsz_limit)
+		schedule_work(&rtcache_work);
+	return 0;
 }
 
 static int rt_intern_hash(struct rt_hash_bucket *r, unsigned int hash, struct rtable *rt, struct rtable **rp)
@@ -3201,15 +3332,23 @@ #endif /* CONFIG_NET_CLS_ROUTE */
 static __initdata unsigned long rhash_entries;
 static int __init set_rhash_entries(char *str)
 {
+	unsigned long val;
+
 	if (!str)
 		return 0;
-	rhash_entries = simple_strtoul(str, &str, 0);
+	val = simple_strtoul(str, &str, 0);
+
+	/* Only use it if it's a power-of-2. */
+	if (!(val & (val - 1)))
+		rhash_entries = val;
+
 	return 1;
 }
 __setup("rhash_entries=", set_rhash_entries);
 
 int __init ip_rt_init(void)
 {
+	unsigned long sz;
 	int rc = 0;
 
 	rt_hash_rnd = (int) ((num_physpages ^ (num_physpages>>8)) ^
@@ -3236,22 +3375,18 @@ #endif
 	if (!ipv4_dst_ops.kmem_cachep)
 		panic("IP: failed to allocate ip_dst_cache\n");
 
-	__rt_hash_table = (struct rt_hash_bucket *)
-		alloc_large_system_hash("IP route cache",
-					sizeof(struct rt_hash_bucket),
-					rhash_entries,
-					(num_physpages >= 128 * 1024) ?
-					15 : 17,
-					HASH_HIGHMEM,
-					NULL,
-					&__rt_hash_mask,
-					0);
-	memset(__rt_hash_table, 0, (__rt_hash_mask + 1) * sizeof(struct rt_hash_bucket));
-	rt_hash_lock_init();
+	sz = (rhash_entries ? rhash_entries : 16);
+	sz *= sizeof(struct rt_hash_bucket);
 
+	__rt_hash_table = rthash_alloc(sz);
+	if (!__rt_hash_table)
+		panic("IP: failed to allocate routing cache hash table");
+	__rt_hash_mask = (sz / sizeof(struct rt_hash_bucket)) - 1;
 	ipv4_dst_ops.gc_thresh = (__rt_hash_mask + 1);
 	ip_rt_max_size = (__rt_hash_mask + 1) * 16;
 
+	rt_hash_lock_init();
+
 	devinet_init();
 	ip_fib_init();
 
-- 
1.4.2.rc2.g3e042

