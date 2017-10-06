From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 02/16] ipv6: introduce a hash table to store dst cache
Date: Fri,  6 Oct 2017 12:05:57 -0700
Message-ID: <20171006190611.110633-3-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:54670 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdJFTGh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:37 -0400
Received: by mail-pg0-f51.google.com with SMTP id c137so10379689pga.11
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:37 -0700 (PDT)
In-Reply-To: <20171006190611.110633-2-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Add a hash table into struct rt6_info in order to store dst caches
created by pmtu discovery and ip redirect in ipv6 routing code.
APIs to add dst cache, delete dst cache, find dst cache and update
dst cache in the hash table are implemented and will be used in later
commits.
This is a preparation work to move all cache routes into the exception
table instead of getting inserted into the fib6 tree.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip6_fib.h   |  19 +++
 include/net/ip6_route.h |   3 +
 net/ipv6/route.c        | 341 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 363 insertions(+)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 152b7b14a5a5..c4864c1e8f13 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -98,6 +98,22 @@ struct rt6key {
 
 struct fib6_table;
 
+struct rt6_exception_bucket {
+	struct hlist_head	chain;
+	int			depth;
+};
+
+struct rt6_exception {
+	struct hlist_node	hlist;
+	struct rt6_info		*rt6i;
+	unsigned long		stamp;
+	struct rcu_head		rcu;
+};
+
+#define FIB6_EXCEPTION_BUCKET_SIZE_SHIFT 10
+#define FIB6_EXCEPTION_BUCKET_SIZE (1 << FIB6_EXCEPTION_BUCKET_SIZE_SHIFT)
+#define FIB6_MAX_DEPTH 5
+
 struct rt6_info {
 	struct dst_entry		dst;
 
@@ -134,12 +150,15 @@ struct rt6_info {
 
 	struct inet6_dev		*rt6i_idev;
 	struct rt6_info * __percpu	*rt6i_pcpu;
+	struct rt6_exception_bucket __rcu *rt6i_exception_bucket;
 
 	u32				rt6i_metric;
 	u32				rt6i_pmtu;
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
 	u8				rt6i_protocol;
+	u8				exception_bucket_flushed:1,
+					unused:7;
 };
 
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index ee96f402cb75..3315605f34c9 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -95,6 +95,9 @@ int ip6_route_add(struct fib6_config *cfg, struct netlink_ext_ack *extack);
 int ip6_ins_rt(struct rt6_info *);
 int ip6_del_rt(struct rt6_info *);
 
+void rt6_flush_exceptions(struct rt6_info *rt);
+int rt6_remove_exception_rt(struct rt6_info *rt);
+
 static inline int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
 				      const struct in6_addr *daddr,
 				      unsigned int prefs,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 26cc9f483b6d..dc5e70975966 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -44,6 +44,7 @@
 #include <linux/seq_file.h>
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
+#include <linux/jhash.h>
 #include <net/net_namespace.h>
 #include <net/snmp.h>
 #include <net/ipv6.h>
@@ -104,6 +105,9 @@ static int rt6_fill_node(struct net *net,
 			 struct in6_addr *dst, struct in6_addr *src,
 			 int iif, int type, u32 portid, u32 seq,
 			 unsigned int flags);
+static struct rt6_info *rt6_find_cached_rt(struct rt6_info *rt,
+					   struct in6_addr *daddr,
+					   struct in6_addr *saddr);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_add_route_info(struct net *net,
@@ -392,6 +396,7 @@ EXPORT_SYMBOL(ip6_dst_alloc);
 static void ip6_dst_destroy(struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
+	struct rt6_exception_bucket *bucket;
 	struct dst_entry *from = dst->from;
 	struct inet6_dev *idev;
 
@@ -404,6 +409,11 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
 	}
+	bucket = rcu_dereference_protected(rt->rt6i_exception_bucket, 1);
+	if (bucket) {
+		rt->rt6i_exception_bucket = NULL;
+		kfree(bucket);
+	}
 
 	dst->from = NULL;
 	dst_release(from);
@@ -1091,6 +1101,337 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 	return pcpu_rt;
 }
 
+/* exception hash table implementation
+ */
+static DEFINE_SPINLOCK(rt6_exception_lock);
+
+/* Remove rt6_ex from hash table and free the memory
+ * Caller must hold rt6_exception_lock
+ */
+static void rt6_remove_exception(struct rt6_exception_bucket *bucket,
+				 struct rt6_exception *rt6_ex)
+{
+	if (!bucket || !rt6_ex)
+		return;
+	rt6_ex->rt6i->rt6i_node = NULL;
+	hlist_del_rcu(&rt6_ex->hlist);
+	rt6_release(rt6_ex->rt6i);
+	kfree_rcu(rt6_ex, rcu);
+	WARN_ON_ONCE(!bucket->depth);
+	bucket->depth--;
+}
+
+/* Remove oldest rt6_ex in bucket and free the memory
+ * Caller must hold rt6_exception_lock
+ */
+static void rt6_exception_remove_oldest(struct rt6_exception_bucket *bucket)
+{
+	struct rt6_exception *rt6_ex, *oldest = NULL;
+
+	if (!bucket)
+		return;
+
+	hlist_for_each_entry(rt6_ex, &bucket->chain, hlist) {
+		if (!oldest || time_before(rt6_ex->stamp, oldest->stamp))
+			oldest = rt6_ex;
+	}
+	rt6_remove_exception(bucket, oldest);
+}
+
+static u32 rt6_exception_hash(const struct in6_addr *dst,
+			      const struct in6_addr *src)
+{
+	static u32 seed __read_mostly;
+	u32 val;
+
+	net_get_random_once(&seed, sizeof(seed));
+	val = jhash(dst, sizeof(*dst), seed);
+
+#ifdef CONFIG_IPV6_SUBTREES
+	if (src)
+		val = jhash(src, sizeof(*src), val);
+#endif
+	return hash_32(val, FIB6_EXCEPTION_BUCKET_SIZE_SHIFT);
+}
+
+/* Helper function to find the cached rt in the hash table
+ * and update bucket pointer to point to the bucket for this
+ * (daddr, saddr) pair
+ * Caller must hold rt6_exception_lock
+ */
+static struct rt6_exception *
+__rt6_find_exception_spinlock(struct rt6_exception_bucket **bucket,
+			      const struct in6_addr *daddr,
+			      const struct in6_addr *saddr)
+{
+	struct rt6_exception *rt6_ex;
+	u32 hval;
+
+	if (!(*bucket) || !daddr)
+		return NULL;
+
+	hval = rt6_exception_hash(daddr, saddr);
+	*bucket += hval;
+
+	hlist_for_each_entry(rt6_ex, &(*bucket)->chain, hlist) {
+		struct rt6_info *rt6 = rt6_ex->rt6i;
+		bool matched = ipv6_addr_equal(daddr, &rt6->rt6i_dst.addr);
+
+#ifdef CONFIG_IPV6_SUBTREES
+		if (matched && saddr)
+			matched = ipv6_addr_equal(saddr, &rt6->rt6i_src.addr);
+#endif
+		if (matched)
+			return rt6_ex;
+	}
+	return NULL;
+}
+
+/* Helper function to find the cached rt in the hash table
+ * and update bucket pointer to point to the bucket for this
+ * (daddr, saddr) pair
+ * Caller must hold rcu_read_lock()
+ */
+static struct rt6_exception *
+__rt6_find_exception_rcu(struct rt6_exception_bucket **bucket,
+			 const struct in6_addr *daddr,
+			 const struct in6_addr *saddr)
+{
+	struct rt6_exception *rt6_ex;
+	u32 hval;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	if (!(*bucket) || !daddr)
+		return NULL;
+
+	hval = rt6_exception_hash(daddr, saddr);
+	*bucket += hval;
+
+	hlist_for_each_entry_rcu(rt6_ex, &(*bucket)->chain, hlist) {
+		struct rt6_info *rt6 = rt6_ex->rt6i;
+		bool matched = ipv6_addr_equal(daddr, &rt6->rt6i_dst.addr);
+
+#ifdef CONFIG_IPV6_SUBTREES
+		if (matched && saddr)
+			matched = ipv6_addr_equal(saddr, &rt6->rt6i_src.addr);
+#endif
+		if (matched)
+			return rt6_ex;
+	}
+	return NULL;
+}
+
+static int rt6_insert_exception(struct rt6_info *nrt,
+				struct rt6_info *ort)
+{
+	struct rt6_exception_bucket *bucket;
+	struct in6_addr *src_key = NULL;
+	struct rt6_exception *rt6_ex;
+	int err = 0;
+
+	/* ort can't be a cache or pcpu route */
+	if (ort->rt6i_flags & (RTF_CACHE | RTF_PCPU))
+		ort = (struct rt6_info *)ort->dst.from;
+	WARN_ON_ONCE(ort->rt6i_flags & (RTF_CACHE | RTF_PCPU));
+
+	spin_lock_bh(&rt6_exception_lock);
+
+	if (ort->exception_bucket_flushed) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	bucket = rcu_dereference_protected(ort->rt6i_exception_bucket,
+					lockdep_is_held(&rt6_exception_lock));
+	if (!bucket) {
+		bucket = kcalloc(FIB6_EXCEPTION_BUCKET_SIZE, sizeof(*bucket),
+				 GFP_ATOMIC);
+		if (!bucket) {
+			err = -ENOMEM;
+			goto out;
+		}
+		rcu_assign_pointer(ort->rt6i_exception_bucket, bucket);
+	}
+
+#ifdef CONFIG_IPV6_SUBTREES
+	/* rt6i_src.plen != 0 indicates ort is in subtree
+	 * and exception table is indexed by a hash of
+	 * both rt6i_dst and rt6i_src.
+	 * Otherwise, the exception table is indexed by
+	 * a hash of only rt6i_dst.
+	 */
+	if (ort->rt6i_src.plen)
+		src_key = &nrt->rt6i_src.addr;
+#endif
+	rt6_ex = __rt6_find_exception_spinlock(&bucket, &nrt->rt6i_dst.addr,
+					       src_key);
+	if (rt6_ex)
+		rt6_remove_exception(bucket, rt6_ex);
+
+	rt6_ex = kzalloc(sizeof(*rt6_ex), GFP_ATOMIC);
+	if (!rt6_ex) {
+		err = -ENOMEM;
+		goto out;
+	}
+	rt6_ex->rt6i = nrt;
+	rt6_ex->stamp = jiffies;
+	atomic_inc(&nrt->rt6i_ref);
+	nrt->rt6i_node = ort->rt6i_node;
+	hlist_add_head_rcu(&rt6_ex->hlist, &bucket->chain);
+	bucket->depth++;
+
+	if (bucket->depth > FIB6_MAX_DEPTH)
+		rt6_exception_remove_oldest(bucket);
+
+out:
+	spin_unlock_bh(&rt6_exception_lock);
+
+	/* Update fn->fn_sernum to invalidate all cached dst */
+	if (!err)
+		fib6_update_sernum(ort);
+
+	return err;
+}
+
+void rt6_flush_exceptions(struct rt6_info *rt)
+{
+	struct rt6_exception_bucket *bucket;
+	struct rt6_exception *rt6_ex;
+	struct hlist_node *tmp;
+	int i;
+
+	spin_lock_bh(&rt6_exception_lock);
+	/* Prevent rt6_insert_exception() to recreate the bucket list */
+	rt->exception_bucket_flushed = 1;
+
+	bucket = rcu_dereference_protected(rt->rt6i_exception_bucket,
+				    lockdep_is_held(&rt6_exception_lock));
+	if (!bucket)
+		goto out;
+
+	for (i = 0; i < FIB6_EXCEPTION_BUCKET_SIZE; i++) {
+		hlist_for_each_entry_safe(rt6_ex, tmp, &bucket->chain, hlist)
+			rt6_remove_exception(bucket, rt6_ex);
+		WARN_ON_ONCE(bucket->depth);
+		bucket++;
+	}
+
+out:
+	spin_unlock_bh(&rt6_exception_lock);
+}
+
+/* Find cached rt in the hash table inside passed in rt
+ * Caller has to hold rcu_read_lock()
+ */
+static struct rt6_info *rt6_find_cached_rt(struct rt6_info *rt,
+					   struct in6_addr *daddr,
+					   struct in6_addr *saddr)
+{
+	struct rt6_exception_bucket *bucket;
+	struct in6_addr *src_key = NULL;
+	struct rt6_exception *rt6_ex;
+	struct rt6_info *res = NULL;
+
+	bucket = rcu_dereference(rt->rt6i_exception_bucket);
+
+#ifdef CONFIG_IPV6_SUBTREES
+	/* rt6i_src.plen != 0 indicates rt is in subtree
+	 * and exception table is indexed by a hash of
+	 * both rt6i_dst and rt6i_src.
+	 * Otherwise, the exception table is indexed by
+	 * a hash of only rt6i_dst.
+	 */
+	if (rt->rt6i_src.plen)
+		src_key = saddr;
+#endif
+	rt6_ex = __rt6_find_exception_rcu(&bucket, daddr, src_key);
+
+	if (rt6_ex && !rt6_check_expired(rt6_ex->rt6i))
+		res = rt6_ex->rt6i;
+
+	return res;
+}
+
+/* Remove the passed in cached rt from the hash table that contains it */
+int rt6_remove_exception_rt(struct rt6_info *rt)
+{
+	struct rt6_info *from = (struct rt6_info *)rt->dst.from;
+	struct rt6_exception_bucket *bucket;
+	struct in6_addr *src_key = NULL;
+	struct rt6_exception *rt6_ex;
+	int err;
+
+	if (!from ||
+	    !(rt->rt6i_flags | RTF_CACHE))
+		return -EINVAL;
+
+	if (!rcu_access_pointer(from->rt6i_exception_bucket))
+		return -ENOENT;
+
+	spin_lock_bh(&rt6_exception_lock);
+	bucket = rcu_dereference_protected(from->rt6i_exception_bucket,
+				    lockdep_is_held(&rt6_exception_lock));
+#ifdef CONFIG_IPV6_SUBTREES
+	/* rt6i_src.plen != 0 indicates 'from' is in subtree
+	 * and exception table is indexed by a hash of
+	 * both rt6i_dst and rt6i_src.
+	 * Otherwise, the exception table is indexed by
+	 * a hash of only rt6i_dst.
+	 */
+	if (from->rt6i_src.plen)
+		src_key = &rt->rt6i_src.addr;
+#endif
+	rt6_ex = __rt6_find_exception_spinlock(&bucket,
+					       &rt->rt6i_dst.addr,
+					       src_key);
+	if (rt6_ex) {
+		rt6_remove_exception(bucket, rt6_ex);
+		err = 0;
+	} else {
+		err = -ENOENT;
+	}
+
+	spin_unlock_bh(&rt6_exception_lock);
+	return err;
+}
+
+/* Find rt6_ex which contains the passed in rt cache and
+ * refresh its stamp
+ */
+static void rt6_update_exception_stamp_rt(struct rt6_info *rt)
+{
+	struct rt6_info *from = (struct rt6_info *)rt->dst.from;
+	struct rt6_exception_bucket *bucket;
+	struct in6_addr *src_key = NULL;
+	struct rt6_exception *rt6_ex;
+
+	if (!from ||
+	    !(rt->rt6i_flags | RTF_CACHE))
+		return;
+
+	rcu_read_lock();
+	bucket = rcu_dereference(from->rt6i_exception_bucket);
+
+#ifdef CONFIG_IPV6_SUBTREES
+	/* rt6i_src.plen != 0 indicates 'from' is in subtree
+	 * and exception table is indexed by a hash of
+	 * both rt6i_dst and rt6i_src.
+	 * Otherwise, the exception table is indexed by
+	 * a hash of only rt6i_dst.
+	 */
+	if (from->rt6i_src.plen)
+		src_key = &rt->rt6i_src.addr;
+#endif
+	rt6_ex = __rt6_find_exception_rcu(&bucket,
+					  &rt->rt6i_dst.addr,
+					  src_key);
+	if (rt6_ex)
+		rt6_ex->stamp = jiffies;
+
+	rcu_read_unlock();
+}
+
 struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			       int oif, struct flowi6 *fl6, int flags)
 {
-- 
2.14.2.920.gcf0c67979c-goog
