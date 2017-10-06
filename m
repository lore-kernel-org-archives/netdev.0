From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 06/16] ipv6: prepare fib6_age() for exception table
Date: Fri,  6 Oct 2017 12:06:01 -0700
Message-ID: <20171006190611.110633-7-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
 <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com>
 <20171006190611.110633-6-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:45165 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdJFTGn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:43 -0400
Received: by mail-pg0-f54.google.com with SMTP id b192so7301847pga.2
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:43 -0700 (PDT)
In-Reply-To: <20171006190611.110633-6-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

If all dst cache entries are stored in the exception table under the
main route, we have to go through them during fib6_age() when doing
garbage collecting.
Introduce a new function rt6_age_exception() which goes through all dst
entries in the exception table and remove those entries that are expired.
This function is called in fib6_age() so that all dst caches are also
garbage collected.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip6_fib.h   | 13 +++++++++++
 include/net/ip6_route.h |  2 ++
 net/ipv6/ip6_fib.c      | 26 ++++++++-------------
 net/ipv6/route.c        | 60 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 84 insertions(+), 17 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index c4864c1e8f13..11a79ef87a28 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -29,6 +29,14 @@
 #define FIB6_TABLE_HASHSZ 1
 #endif
 
+#define RT6_DEBUG 2
+
+#if RT6_DEBUG >= 3
+#define RT6_TRACE(x...) pr_debug(x)
+#else
+#define RT6_TRACE(x...) do { ; } while (0)
+#endif
+
 struct rt6_info;
 
 struct fib6_config {
@@ -75,6 +83,11 @@ struct fib6_node {
 	struct rcu_head		rcu;
 };
 
+struct fib6_gc_args {
+	int			timeout;
+	int			more;
+};
+
 #ifndef CONFIG_IPV6_SUBTREES
 #define FIB6_SUBTREE(fn)	NULL
 #else
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 3315605f34c9..a0087fb9864b 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -97,6 +97,8 @@ int ip6_del_rt(struct rt6_info *);
 
 void rt6_flush_exceptions(struct rt6_info *rt);
 int rt6_remove_exception_rt(struct rt6_info *rt);
+void rt6_age_exceptions(struct rt6_info *rt, struct fib6_gc_args *gc_args,
+			unsigned long now);
 
 static inline int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
 				      const struct in6_addr *daddr,
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0ba4fbb2f855..3afbe50f2779 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -38,14 +38,6 @@
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
 
-#define RT6_DEBUG 2
-
-#if RT6_DEBUG >= 3
-#define RT6_TRACE(x...) pr_debug(x)
-#else
-#define RT6_TRACE(x...) do { ; } while (0)
-#endif
-
 static struct kmem_cache *fib6_node_kmem __read_mostly;
 
 struct fib6_cleaner {
@@ -1890,12 +1882,6 @@ static void fib6_flush_trees(struct net *net)
  *	Garbage collection
  */
 
-struct fib6_gc_args
-{
-	int			timeout;
-	int			more;
-};
-
 static int fib6_age(struct rt6_info *rt, void *arg)
 {
 	struct fib6_gc_args *gc_args = arg;
@@ -1904,9 +1890,6 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 	/*
 	 *	check addrconf expiration here.
 	 *	Routes are expired even if they are in use.
-	 *
-	 *	Also age clones. Note, that clones are aged out
-	 *	only if they are not in use now.
 	 */
 
 	if (rt->rt6i_flags & RTF_EXPIRES && rt->dst.expires) {
@@ -1915,6 +1898,9 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 			return -1;
 		}
 		gc_args->more++;
+	/* The following part will soon be removed when the exception
+	 * table is hooked up to store all cached routes.
+	 */
 	} else if (rt->rt6i_flags & RTF_CACHE) {
 		if (time_after_eq(now, rt->dst.lastuse + gc_args->timeout))
 			rt->dst.obsolete = DST_OBSOLETE_KILL;
@@ -1940,6 +1926,12 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 		gc_args->more++;
 	}
 
+	/*	Also age clones in the exception table.
+	 *	Note, that clones are aged out
+	 *	only if they are not in use now.
+	 */
+	rt6_age_exceptions(rt, gc_args, now);
+
 	return 0;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e8e901589564..d2dd55f58b5d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1528,6 +1528,66 @@ static void rt6_exceptions_clean_tohost(struct rt6_info *rt,
 	spin_unlock_bh(&rt6_exception_lock);
 }
 
+static void rt6_age_examine_exception(struct rt6_exception_bucket *bucket,
+				      struct rt6_exception *rt6_ex,
+				      struct fib6_gc_args *gc_args,
+				      unsigned long now)
+{
+	struct rt6_info *rt = rt6_ex->rt6i;
+
+	if (atomic_read(&rt->dst.__refcnt) == 1 &&
+	    time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
+		RT6_TRACE("aging clone %p\n", rt);
+		rt6_remove_exception(bucket, rt6_ex);
+		return;
+	} else if (rt->rt6i_flags & RTF_GATEWAY) {
+		struct neighbour *neigh;
+		__u8 neigh_flags = 0;
+
+		neigh = dst_neigh_lookup(&rt->dst, &rt->rt6i_gateway);
+		if (neigh) {
+			neigh_flags = neigh->flags;
+			neigh_release(neigh);
+		}
+		if (!(neigh_flags & NTF_ROUTER)) {
+			RT6_TRACE("purging route %p via non-router but gateway\n",
+				  rt);
+			rt6_remove_exception(bucket, rt6_ex);
+			return;
+		}
+	}
+	gc_args->more++;
+}
+
+void rt6_age_exceptions(struct rt6_info *rt,
+			struct fib6_gc_args *gc_args,
+			unsigned long now)
+{
+	struct rt6_exception_bucket *bucket;
+	struct rt6_exception *rt6_ex;
+	struct hlist_node *tmp;
+	int i;
+
+	if (!rcu_access_pointer(rt->rt6i_exception_bucket))
+		return;
+
+	spin_lock_bh(&rt6_exception_lock);
+	bucket = rcu_dereference_protected(rt->rt6i_exception_bucket,
+				    lockdep_is_held(&rt6_exception_lock));
+
+	if (bucket) {
+		for (i = 0; i < FIB6_EXCEPTION_BUCKET_SIZE; i++) {
+			hlist_for_each_entry_safe(rt6_ex, tmp,
+						  &bucket->chain, hlist) {
+				rt6_age_examine_exception(bucket, rt6_ex,
+							  gc_args, now);
+			}
+			bucket++;
+		}
+	}
+	spin_unlock_bh(&rt6_exception_lock);
+}
+
 struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			       int oif, struct flowi6 *fl6, int flags)
 {
-- 
2.14.2.920.gcf0c67979c-goog
