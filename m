From: Wei Wang <weiwan@google.com>
Subject: [PATCH net v3] ipv6: add rcu grace period before freeing fib6_node
Date: Mon, 21 Aug 2017 09:47:10 -0700
Message-ID: <20170821164710.134367-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35920 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753551AbdHUQr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 12:47:28 -0400
Received: by mail-pg0-f54.google.com with SMTP id i12so103119334pgr.3
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 09:47:28 -0700 (PDT)
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
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
v3: rebased the change from net-next branch to net branch

v2: removed one extra line

 include/net/ip6_fib.h | 30 +++++++++++++++++++++++++++++-
 net/ipv6/ip6_fib.c    | 20 ++++++++++++++++----
 net/ipv6/route.c      | 14 +++++++++++---
 3 files changed, 56 insertions(+), 8 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 1a88008cc6f5..e9c59db92942 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -70,6 +70,7 @@ struct fib6_node {
 	__u16			fn_flags;
 	int			fn_sernum;
 	struct rt6_info		*rr_ptr;
+	struct rcu_head		rcu;
 };
 
 #ifndef CONFIG_IPV6_SUBTREES
@@ -167,13 +168,40 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
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
index 5cc0ea038198..a5ebf86f6be8 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -148,11 +148,23 @@ static struct fib6_node *node_alloc(void)
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
 static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 {
 	int cpu;
@@ -601,9 +613,9 @@ static struct fib6_node *fib6_add_1(struct fib6_node *root,
 
 		if (!in || !ln) {
 			if (in)
-				node_free(in);
+				node_free_immediate(in);
 			if (ln)
-				node_free(ln);
+				node_free_immediate(ln);
 			return ERR_PTR(-ENOMEM);
 		}
 
@@ -1038,7 +1050,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 				   root, and then (in failure) stale node
 				   in main tree.
 				 */
-				node_free(sfn);
+				node_free_immediate(sfn);
 				err = PTR_ERR(sn);
 				goto failure;
 			}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 94d6a13d47f0..a9d3564caf49 100644
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
