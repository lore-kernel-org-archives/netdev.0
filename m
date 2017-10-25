From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 08/12] ipv6: Move dst->from into struct rt6_info.
Date: Wed, 25 Oct 2017 23:04:11 +0900 (KST)
Message-ID: <20171025.230411.1366356534941840708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751975AbdJYOEP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:04:15 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id E8239133F6538
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:04:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The dst->from value is only used by ipv6 routes to track where
a route "came from".

Any time we clone or copy a core ipv6 route in the ipv6 routing
tables, we have the copy/clone's ->from point to the base route.

This is used to handle route expiration properly.

Only ipv6 uses this mechanism, and only ipv6 code references
it.  So it is safe to move it into rt6_info.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h     |  3 +--
 include/net/ip6_fib.h |  9 ++++-----
 net/core/dst.c        |  1 -
 net/ipv6/route.c      | 34 +++++++++++++++++-----------------
 4 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 6c6f0140759d..9ec3fd59c3e7 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -38,7 +38,6 @@ struct dst_entry {
 	unsigned long		_metrics;
 	unsigned long           expires;
 	struct dst_entry	*path;
-	struct dst_entry	*from;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
@@ -87,7 +86,7 @@ struct dst_entry {
 	 * Align __refcnt to a 64 bytes alignment
 	 * (L1_CACHE_SIZE would be too much)
 	 */
-	long			__pad_to_align_refcnt[3];
+	long			__pad_to_align_refcnt[4];
 #endif
 	/*
 	 * __refcnt wants to be on a different cache line from
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 281a922f0c62..44d96a91e745 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -130,6 +130,7 @@ struct rt6_exception {
 struct rt6_info {
 	struct dst_entry		dst;
 	struct rt6_info __rcu		*rt6_next;
+	struct rt6_info			*from;
 
 	/*
 	 * Tail elements of dst_entry (__refcnt etc.)
@@ -204,11 +205,9 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 {
 	struct rt6_info *rt;
 
-	for (rt = rt0; rt && !(rt->rt6i_flags & RTF_EXPIRES);
-	     rt = (struct rt6_info *)rt->dst.from);
+	for (rt = rt0; rt && !(rt->rt6i_flags & RTF_EXPIRES); rt = rt->from);
 	if (rt && rt != rt0)
 		rt0->dst.expires = rt->dst.expires;
-
 	dst_set_expires(&rt0->dst, timeout);
 	rt0->rt6i_flags |= RTF_EXPIRES;
 }
@@ -243,8 +242,8 @@ static inline u32 rt6_get_cookie(const struct rt6_info *rt)
 	u32 cookie = 0;
 
 	if (rt->rt6i_flags & RTF_PCPU ||
-	    (unlikely(!list_empty(&rt->rt6i_uncached)) && rt->dst.from))
-		rt = (struct rt6_info *)(rt->dst.from);
+	    (unlikely(!list_empty(&rt->rt6i_uncached)) && rt->from))
+		rt = rt->from;
 
 	rt6_get_cookie_safe(rt, &cookie);
 
diff --git a/net/core/dst.c b/net/core/dst.c
index 5cf96179e8e0..cf2076c0eb22 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -70,7 +70,6 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	dst_init_metrics(dst, dst_default_metrics.metrics, true);
 	dst->expires = 0UL;
 	dst->path = dst;
-	dst->from = NULL;
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
 #endif
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3c943d252a33..475c57e8fa90 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -186,7 +186,7 @@ static void rt6_uncached_list_flush_dev(struct net *net, struct net_device *dev)
 
 static u32 *rt6_pcpu_cow_metrics(struct rt6_info *rt)
 {
-	return dst_metrics_write_ptr(rt->dst.from);
+	return dst_metrics_write_ptr(&rt->from->dst);
 }
 
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
@@ -391,7 +391,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct rt6_exception_bucket *bucket;
-	struct dst_entry *from = dst->from;
+	struct rt6_info *from = rt->from;
 	struct inet6_dev *idev;
 
 	dst_destroy_metrics_generic(dst);
@@ -409,8 +409,8 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 		kfree(bucket);
 	}
 
-	dst->from = NULL;
-	dst_release(from);
+	rt->from = NULL;
+	dst_release(&from->dst);
 }
 
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -443,9 +443,9 @@ static bool rt6_check_expired(const struct rt6_info *rt)
 	if (rt->rt6i_flags & RTF_EXPIRES) {
 		if (time_after(jiffies, rt->dst.expires))
 			return true;
-	} else if (rt->dst.from) {
+	} else if (rt->from) {
 		return rt->dst.obsolete != DST_OBSOLETE_FORCE_CHK ||
-		       rt6_check_expired((struct rt6_info *)rt->dst.from);
+			rt6_check_expired(rt->from);
 	}
 	return false;
 }
@@ -1049,7 +1049,7 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 	 */
 
 	if (ort->rt6i_flags & (RTF_CACHE | RTF_PCPU))
-		ort = (struct rt6_info *)ort->dst.from;
+		ort = ort->from;
 
 	rcu_read_lock();
 	dev = ip6_rt_get_dev_rcu(ort);
@@ -1269,7 +1269,7 @@ static int rt6_insert_exception(struct rt6_info *nrt,
 
 	/* ort can't be a cache or pcpu route */
 	if (ort->rt6i_flags & (RTF_CACHE | RTF_PCPU))
-		ort = (struct rt6_info *)ort->dst.from;
+		ort = ort->from;
 	WARN_ON_ONCE(ort->rt6i_flags & (RTF_CACHE | RTF_PCPU));
 
 	spin_lock_bh(&rt6_exception_lock);
@@ -1410,8 +1410,8 @@ static struct rt6_info *rt6_find_cached_rt(struct rt6_info *rt,
 /* Remove the passed in cached rt from the hash table that contains it */
 int rt6_remove_exception_rt(struct rt6_info *rt)
 {
-	struct rt6_info *from = (struct rt6_info *)rt->dst.from;
 	struct rt6_exception_bucket *bucket;
+	struct rt6_info *from = rt->from;
 	struct in6_addr *src_key = NULL;
 	struct rt6_exception *rt6_ex;
 	int err;
@@ -1455,8 +1455,8 @@ int rt6_remove_exception_rt(struct rt6_info *rt)
  */
 static void rt6_update_exception_stamp_rt(struct rt6_info *rt)
 {
-	struct rt6_info *from = (struct rt6_info *)rt->dst.from;
 	struct rt6_exception_bucket *bucket;
+	struct rt6_info *from = rt->from;
 	struct in6_addr *src_key = NULL;
 	struct rt6_exception *rt6_ex;
 
@@ -1924,9 +1924,9 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 
 static void rt6_dst_from_metrics_check(struct rt6_info *rt)
 {
-	if (rt->dst.from &&
-	    dst_metrics_ptr(&rt->dst) != dst_metrics_ptr(rt->dst.from))
-		dst_init_metrics(&rt->dst, dst_metrics_ptr(rt->dst.from), true);
+	if (rt->from &&
+	    dst_metrics_ptr(&rt->dst) != dst_metrics_ptr(&rt->from->dst))
+		dst_init_metrics(&rt->dst, dst_metrics_ptr(&rt->from->dst), true);
 }
 
 static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
@@ -1946,7 +1946,7 @@ static struct dst_entry *rt6_dst_from_check(struct rt6_info *rt, u32 cookie)
 {
 	if (!__rt6_check_expired(rt) &&
 	    rt->dst.obsolete == DST_OBSOLETE_FORCE_CHK &&
-	    rt6_check((struct rt6_info *)(rt->dst.from), cookie))
+	    rt6_check(rt->from, cookie))
 		return &rt->dst;
 	else
 		return NULL;
@@ -1966,7 +1966,7 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	rt6_dst_from_metrics_check(rt);
 
 	if (rt->rt6i_flags & RTF_PCPU ||
-	    (unlikely(!list_empty(&rt->rt6i_uncached)) && rt->dst.from))
+	    (unlikely(!list_empty(&rt->rt6i_uncached)) && rt->from))
 		return rt6_dst_from_check(rt, cookie);
 	else
 		return rt6_check(rt, cookie);
@@ -3043,11 +3043,11 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 
 static void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 {
-	BUG_ON(from->dst.from);
+	BUG_ON(from->from);
 
 	rt->rt6i_flags &= ~RTF_EXPIRES;
 	dst_hold(&from->dst);
-	rt->dst.from = &from->dst;
+	rt->from = from;
 	dst_init_metrics(&rt->dst, dst_metrics_ptr(&from->dst), true);
 }
 
-- 
2.13.6
