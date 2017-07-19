From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/17] ipv6: fib: Allow non-FIB users to take reference on route
Date: Wed, 19 Jul 2017 09:02:26 +0200
Message-ID: <20170719070232.28457-12-jiri@resnulli.us>
References: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35792 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752834AbdGSHCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:02:51 -0400
Received: by mail-wm0-f67.google.com with SMTP id n64so1048171wmg.2
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:51 -0700 (PDT)
In-Reply-To: <20170719070232.28457-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Listeners of the FIB notification chain are expected to be able to take
and release a reference on notified IPv6 routes. This is needed in the
case of drivers capable of offloading these routes to a capable device.

Since notifications are sent in an atomic context, these drivers need to
take a reference on the route, prepare a work item to offload the route
and release the reference at the end of the work.

Currently, rt6i_ref is used to indicate in how many FIB nodes a route
appears. Different code paths rely on rt6i_ref being 0 to indicate the
route is no longer used by the FIB.

For example, whenever a route is deleted or replaced, fib6_purge_rt() is
run to make sure the route is no longer present in intermediate nodes. A
BUG_ON() at the end of the function is executed in case the reference
count isn't 1, as it's only supposed to appear in the non-intermediate
node from which it's going to be deleted.

Instead of changing the semantics of rt6i_ref, a new reference count is
added, so that external users could also take a reference on routes
without modifying rt6i_ref.

To make sure external users don't release routes used by the FIB, the
reference count is set to 1 upon creation of a route and decremented by
the FIB upon rt6_release().

The reference count is atomic, as it's not protected by any locks and
placed in the 40 bytes hole after the existing rt6i_ref.

rt6_free_pcpu() is exported so that modules could invoke rt6_put().
Similar to commit b423cb10807b ("ipv4: fib: Export free_fib_info()").

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip6_fib.h | 17 +++++++++++++++++
 net/ipv6/ip6_fib.c    | 10 ++++------
 net/ipv6/route.c      |  4 ++++
 3 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 0b30521..e8ecd08 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -119,6 +119,7 @@ struct rt6_info {
 	unsigned int			rt6i_nsiblings;
 
 	atomic_t			rt6i_ref;
+	refcount_t			rt6i_extref;
 
 	/* These are in a separate cache line. */
 	struct rt6key			rt6i_dst ____cacheline_aligned_in_smp;
@@ -187,6 +188,22 @@ static inline void ip6_rt_put(struct rt6_info *rt)
 	dst_release(&rt->dst);
 }
 
+void rt6_free_pcpu(struct rt6_info *non_pcpu_rt);
+
+static inline void rt6_get(struct rt6_info *rt)
+{
+	refcount_inc(&rt->rt6i_extref);
+}
+
+static inline void rt6_put(struct rt6_info *rt)
+{
+	if (refcount_dec_and_test(&rt->rt6i_extref)) {
+		rt6_free_pcpu(rt);
+		dst_dev_put(&rt->dst);
+		dst_release(&rt->dst);
+	}
+}
+
 enum fib6_walk_state {
 #ifdef CONFIG_IPV6_SUBTREES
 	FWS_S,
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 719c1048..99ca785 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -154,7 +154,7 @@ static void node_free(struct fib6_node *fn)
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
-static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
+void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 {
 	int cpu;
 
@@ -177,14 +177,12 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 	free_percpu(non_pcpu_rt->rt6i_pcpu);
 	non_pcpu_rt->rt6i_pcpu = NULL;
 }
+EXPORT_SYMBOL_GPL(rt6_free_pcpu);
 
 static void rt6_release(struct rt6_info *rt)
 {
-	if (atomic_dec_and_test(&rt->rt6i_ref)) {
-		rt6_free_pcpu(rt);
-		dst_dev_put(&rt->dst);
-		dst_release(&rt->dst);
-	}
+	if (atomic_dec_and_test(&rt->rt6i_ref))
+		rt6_put(rt);
 }
 
 static void fib6_link_table(struct net *net, struct fib6_table *tb)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 924e02d..cabe0c6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -345,6 +345,10 @@ static void rt6_info_init(struct rt6_info *rt)
 	memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 	INIT_LIST_HEAD(&rt->rt6i_siblings);
 	INIT_LIST_HEAD(&rt->rt6i_uncached);
+	/* Make sure route can't be released as long as it's used by
+	 * the FIB.
+	 */
+	refcount_set(&rt->rt6i_extref, 1);
 }
 
 /* allocate dst with ip6_dst_ops */
-- 
2.9.3
