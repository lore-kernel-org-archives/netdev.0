From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] ipv6: add rcu grace period before freeing fib6_node
Date: Fri, 18 Aug 2017 17:36:55 -0700
Message-ID: <20170819003655.64903-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36603 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdHSAhA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 20:37:00 -0400
Received: by mail-pg0-f42.google.com with SMTP id i12so73603025pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 17:37:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

We currently keep rt->rt6i_node pointing to the fib6_node for the route.
And some functions make use of this pointer to dereference the fib6_node
from rt structure, e.g. rt6_check(). However, as there is neither
refcount nor rcu taken when dereferencing rt->rt6i_node, it could
potentially cause crashes as rt->rt6i_node could be set to NULL by other
CPUs when doing a route deletion.
This patch introduces an rcu grace period before freeing fib6_node and
makes sure the functions that dereference it takes rcu_read_lock().

Note: there is no "Fixes" tag because this bug was there in a very
early stage.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip6_fib.h | 31 ++++++++++++++++++++++++++++++-
 net/ipv6/ip6_fib.c    | 20 ++++++++++++++++----
 net/ipv6/route.c      | 14 +++++++++++---
 3 files changed, 57 insertions(+), 8 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 71c1646298ae..5691faf6b495 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -72,6 +72,7 @@ struct fib6_node {
 	__u16			fn_flags;
 	int			fn_sernum;
 	struct rt6_info		*rr_ptr;
+	struct rcu_head		rcu;
 };
 
 #ifndef CONFIG_IPV6_SUBTREES
@@ -171,13 +172,41 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 	rt0->rt6i_flags |= RTF_EXPIRES;
 }
 
+/* Function to safely get fn->sernum for passed in rt
+ * and store result in passed in cookie.
+ * Return true if we can get cookie safely
+ * Return false if not
+ */
+static inline bool rt6_get_cookie_safe(const struct rt6_info *rt,
+				       u32 *cookie)
+{
+	struct fib6_node *fn;
+	bool status = false;
+
+	rcu_read_lock();
+	fn = rcu_dereference(rt->rt6i_node);
+
+	if (fn) {
+		*cookie = fn->fn_sernum;
+		status = true;
+	}
+
+	rcu_read_unlock();
+	return status;
+
+}
+
 static inline u32 rt6_get_cookie(const struct rt6_info *rt)
 {
+	u32 cookie = 0;
+
 	if (rt->rt6i_flags & RTF_PCPU ||
 	    (unlikely(!list_empty(&rt->rt6i_uncached)) && rt->dst.from))
 		rt = (struct rt6_info *)(rt->dst.from);
 
-	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+	rt6_get_cookie_safe(rt, &cookie);
+
+	return cookie;
 }
 
 static inline void ip6_rt_put(struct rt6_info *rt)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 549aacc3cb2c..a9821c230e4e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -149,11 +149,23 @@ static struct fib6_node *node_alloc(void)
 	return fn;
 }
 
-static void node_free(struct fib6_node *fn)
+static void node_free_immediate(struct fib6_node *fn)
+{
+	kmem_cache_free(fib6_node_kmem, fn);
+}
+
+static void node_free_rcu(struct rcu_head *head)
 {
+	struct fib6_node *fn = container_of(head, struct fib6_node, rcu);
+
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
+static void node_free(struct fib6_node *fn)
+{
+	call_rcu(&fn->rcu, node_free_rcu);
+}
+
 void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 {
 	int cpu;
@@ -697,9 +709,9 @@ static struct fib6_node *fib6_add_1(struct fib6_node *root,
 
 		if (!in || !ln) {
 			if (in)
-				node_free(in);
+				node_free_immediate(in);
 			if (ln)
-				node_free(ln);
+				node_free_immediate(ln);
 			return ERR_PTR(-ENOMEM);
 		}
 
@@ -1138,7 +1150,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 				   root, and then (in failure) stale node
 				   in main tree.
 				 */
-				node_free(sfn);
+				node_free_immediate(sfn);
 				err = PTR_ERR(sn);
 				goto failure;
 			}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bec12ae3e6b7..4de2d793c4b8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1289,7 +1289,9 @@ static void rt6_dst_from_metrics_check(struct rt6_info *rt)
 
 static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
 {
-	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
+	u32 rt_cookie;
+
+	if (!rt6_get_cookie_safe(rt, &rt_cookie) || rt_cookie != cookie)
 		return NULL;
 
 	if (rt6_check_expired(rt))
@@ -1357,8 +1359,14 @@ static void ip6_link_failure(struct sk_buff *skb)
 		if (rt->rt6i_flags & RTF_CACHE) {
 			if (dst_hold_safe(&rt->dst))
 				ip6_del_rt(rt);
-		} else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAULT)) {
-			rt->rt6i_node->fn_sernum = -1;
+		} else {
+			struct fib6_node *fn;
+
+			rcu_read_lock();
+			fn = rcu_dereference(rt->rt6i_node);
+			if (fn && (rt->rt6i_flags & RTF_DEFAULT))
+				fn->fn_sernum = -1;
+			rcu_read_unlock();
 		}
 	}
 }
-- 
2.14.1.480.gb18f417b89-goog
