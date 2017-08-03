From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/21] ipv6: fib: Add helpers to hold / drop a reference on rt6_info
Date: Thu,  3 Aug 2017 13:28:25 +0200
Message-ID: <20170803112831.1831-16-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:38393 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752197AbdHCL3C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:29:02 -0400
Received: by mail-wr0-f195.google.com with SMTP id g32so799492wrd.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:29:01 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Similar to commit 1c677b3d2828 ("ipv4: fib: Add fib_info_hold() helper")
and commit b423cb10807b ("ipv4: fib: Export free_fib_info()") add an
helper to hold a reference on rt6_info and export rt6_release() to drop
it and potentially release the route.

This is needed so that drivers capable of FIB offload could hold a
reference on the route before queueing it for offload and drop it after
the route has been programmed to the device's tables.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip6_fib.h | 16 ++++++++++++++++
 net/ipv6/ip6_fib.c    | 12 ++----------
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 0b30521..1d790ea 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -187,6 +187,22 @@ static inline void ip6_rt_put(struct rt6_info *rt)
 	dst_release(&rt->dst);
 }
 
+void rt6_free_pcpu(struct rt6_info *non_pcpu_rt);
+
+static inline void rt6_hold(struct rt6_info *rt)
+{
+	atomic_inc(&rt->rt6i_ref);
+}
+
+static inline void rt6_release(struct rt6_info *rt)
+{
+	if (atomic_dec_and_test(&rt->rt6i_ref)) {
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
index fe193b4..69ed004 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -154,7 +154,7 @@ static void node_free(struct fib6_node *fn)
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
-static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
+void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 {
 	int cpu;
 
@@ -177,15 +177,7 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 	free_percpu(non_pcpu_rt->rt6i_pcpu);
 	non_pcpu_rt->rt6i_pcpu = NULL;
 }
-
-static void rt6_release(struct rt6_info *rt)
-{
-	if (atomic_dec_and_test(&rt->rt6i_ref)) {
-		rt6_free_pcpu(rt);
-		dst_dev_put(&rt->dst);
-		dst_release(&rt->dst);
-	}
-}
+EXPORT_SYMBOL_GPL(rt6_free_pcpu);
 
 static void fib6_link_table(struct net *net, struct fib6_table *tb)
 {
-- 
2.9.3
