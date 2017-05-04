From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv4: restore rt->fi for reference counting
Date: Thu,  4 May 2017 14:54:17 -0700
Message-ID: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, edumazet@google.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35894 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751814AbdEDVy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 17:54:28 -0400
Received: by mail-pf0-f193.google.com with SMTP id v14so3618217pfd.3
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 14:54:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 dst could use fi->fib_metrics to store metrics but fib_info
itself is refcnt'ed, so without taking a refcnt fi and
fi->fib_metrics could be freed while dst metrics still points to
it. This triggers use-after-free as reported by Andrey twice.

This patch reverts commit 2860583fe840 ("ipv4: Kill rt->fi") to
restore this reference counting. It is a quick fix for -net and
-stable, for -net-next, as Eric suggested, we can consider doing
reference counting for metrics itself instead of relying on fib_info.

IPv6 is very different, it copies or steals the metrics from mx6_config
in fib6_commit_metrics() so probably doesn't need a refcnt.

Decnet has already done the refcnt'ing, see dn_fib_semantic_match().

Fixes: 2860583fe840 ("ipv4: Kill rt->fi")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/route.h |  1 +
 net/ipv4/route.c    | 18 +++++++++++++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/net/route.h b/include/net/route.h
index 2cc0e14..4335eb7 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -69,6 +69,7 @@ struct rtable {
 
 	struct list_head	rt_uncached;
 	struct uncached_list	*rt_uncached_list;
+	struct fib_info		*fi; /* for refcnt to shared metrics */
 };
 
 static inline bool rt_is_input_route(const struct rtable *rt)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 655d9ee..f647310 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1387,6 +1387,11 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 {
 	struct rtable *rt = (struct rtable *) dst;
 
+	if (rt->fi) {
+		fib_info_put(rt->fi);
+		rt->fi = NULL;
+	}
+
 	if (!list_empty(&rt->rt_uncached)) {
 		struct uncached_list *ul = rt->rt_uncached_list;
 
@@ -1424,6 +1429,16 @@ static bool rt_cache_valid(const struct rtable *rt)
 		!rt_is_expired(rt);
 }
 
+static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
+{
+	if (fi->fib_metrics != (u32 *)dst_default_metrics) {
+		fib_info_hold(fi);
+		rt->fi = fi;
+	}
+
+	dst_init_metrics(&rt->dst, fi->fib_metrics, true);
+}
+
 static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			   const struct fib_result *res,
 			   struct fib_nh_exception *fnhe,
@@ -1438,7 +1453,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			rt->rt_gateway = nh->nh_gw;
 			rt->rt_uses_gateway = 1;
 		}
-		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
+		rt_init_metrics(rt, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
@@ -1490,6 +1505,7 @@ struct rtable *rt_dst_alloc(struct net_device *dev,
 		rt->rt_gateway = 0;
 		rt->rt_uses_gateway = 0;
 		rt->rt_table_id = 0;
+		rt->fi = NULL;
 		INIT_LIST_HEAD(&rt->rt_uncached);
 
 		rt->dst.output = ip_output;
-- 
2.5.5
