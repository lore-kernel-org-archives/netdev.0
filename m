From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4] ipv4: Kill RT_CACHE_DEBUG
Date: Wed, 18 May 2011 18:56:27 -0400 (EDT)
Message-ID: <20110518.185627.1508964615298147724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272Ab1ERW43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:56:29 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4IMuSt7017357
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 15:56:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's way past it's usefulness.  And this gets rid of a bunch
of stray ->rt_{dst,src} references.

Even the comment documenting the macro was inaccurate (stated
default was 1 when it's 0).

If reintroduced, it should be done properly, with dynamic debug
facilities.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h |    7 -------
 net/core/dst.c    |   22 ----------------------
 net/ipv4/route.c  |   22 ----------------------
 3 files changed, 0 insertions(+), 51 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 2588a9a..07a0402 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -16,13 +16,6 @@
 #include <net/neighbour.h>
 #include <asm/processor.h>
 
-/*
- * 0 - no debugging messages
- * 1 - rare events and bugs (default)
- * 2 - trace mode.
- */
-#define RT_CACHE_DEBUG		0
-
 #define DST_GC_MIN	(HZ/10)
 #define DST_GC_INC	(HZ/2)
 #define DST_GC_MAX	(120*HZ)
diff --git a/net/core/dst.c b/net/core/dst.c
index 30f0093..da47a29 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -33,9 +33,6 @@
  * 3) This list is guarded by a mutex,
  *    so that the gc_task and dst_dev_event() can be synchronized.
  */
-#if RT_CACHE_DEBUG >= 2
-static atomic_t			 dst_total = ATOMIC_INIT(0);
-#endif
 
 /*
  * We want to keep lock & list close together
@@ -69,10 +66,6 @@ static void dst_gc_task(struct work_struct *work)
 	unsigned long expires = ~0L;
 	struct dst_entry *dst, *next, head;
 	struct dst_entry *last = &head;
-#if RT_CACHE_DEBUG >= 2
-	ktime_t time_start = ktime_get();
-	struct timespec elapsed;
-#endif
 
 	mutex_lock(&dst_gc_mutex);
 	next = dst_busy_list;
@@ -146,15 +139,6 @@ loop:
 
 	spin_unlock_bh(&dst_garbage.lock);
 	mutex_unlock(&dst_gc_mutex);
-#if RT_CACHE_DEBUG >= 2
-	elapsed = ktime_to_timespec(ktime_sub(ktime_get(), time_start));
-	printk(KERN_DEBUG "dst_total: %d delayed: %d work_perf: %d"
-		" expires: %lu elapsed: %lu us\n",
-		atomic_read(&dst_total), delayed, work_performed,
-		expires,
-		elapsed.tv_sec * USEC_PER_SEC +
-		  elapsed.tv_nsec / NSEC_PER_USEC);
-#endif
 }
 
 int dst_discard(struct sk_buff *skb)
@@ -205,9 +189,6 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst->lastuse = jiffies;
 	dst->flags = flags;
 	dst->next = NULL;
-#if RT_CACHE_DEBUG >= 2
-	atomic_inc(&dst_total);
-#endif
 	dst_entries_add(ops, 1);
 	return dst;
 }
@@ -267,9 +248,6 @@ again:
 		dst->ops->destroy(dst);
 	if (dst->dev)
 		dev_put(dst->dev);
-#if RT_CACHE_DEBUG >= 2
-	atomic_dec(&dst_total);
-#endif
 	kmem_cache_free(dst->ops->kmem_cachep, dst);
 
 	dst = child;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cb93c32..9c5ad86 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -968,10 +968,6 @@ static int rt_garbage_collect(struct dst_ops *ops)
 			break;
 
 		expire >>= 1;
-#if RT_CACHE_DEBUG >= 2
-		printk(KERN_DEBUG "expire>> %u %d %d %d\n", expire,
-				dst_entries_get_fast(&ipv4_dst_ops), goal, i);
-#endif
 
 		if (dst_entries_get_fast(&ipv4_dst_ops) < ip_rt_max_size)
 			goto out;
@@ -992,10 +988,6 @@ work_done:
 	    dst_entries_get_fast(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh ||
 	    dst_entries_get_slow(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh)
 		expire = ip_rt_gc_timeout;
-#if RT_CACHE_DEBUG >= 2
-	printk(KERN_DEBUG "expire++ %u %d %d %d\n", expire,
-			dst_entries_get_fast(&ipv4_dst_ops), goal, rover);
-#endif
 out:	return 0;
 }
 
@@ -1179,16 +1171,6 @@ restart:
 
 	rt->dst.rt_next = rt_hash_table[hash].chain;
 
-#if RT_CACHE_DEBUG >= 2
-	if (rt->dst.rt_next) {
-		struct rtable *trt;
-		printk(KERN_DEBUG "rt_cache @%02x: %pI4",
-		       hash, &rt->rt_dst);
-		for (trt = rt->dst.rt_next; trt; trt = trt->dst.rt_next)
-			printk(" . %pI4", &trt->rt_dst);
-		printk("\n");
-	}
-#endif
 	/*
 	 * Since lookup is lockfree, we must make sure
 	 * previous writes to rt are committed to memory
@@ -1347,10 +1329,6 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 			unsigned hash = rt_hash(rt->rt_key_dst, rt->rt_key_src,
 						rt->rt_oif,
 						rt_genid(dev_net(dst->dev)));
-#if RT_CACHE_DEBUG >= 1
-			printk(KERN_DEBUG "ipv4_negative_advice: redirect to %pI4/%02x dropped\n",
-				&rt->rt_dst, rt->rt_key_tos);
-#endif
 			rt_del(hash, rt);
 			ret = NULL;
 		} else if (rt->peer &&
-- 
1.7.4.4

