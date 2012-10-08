From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net v2 3/6] ipv4: make sure nh_pcpu_rth_output is always allocated
Date: Tue,  9 Oct 2012 00:41:17 +0300
Message-ID: <1349732480-19978-4-git-send-email-ja@ssi.bg>
References: <1349732480-19978-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44336 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690Ab2JHVgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 17:36:02 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q98LfYp2020022
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2012 00:41:34 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q98LfYpf020021
	for netdev@vger.kernel.org; Tue, 9 Oct 2012 00:41:34 +0300
In-Reply-To: <1349732480-19978-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Avoid checking nh_pcpu_rth_output in fast path,
abort fib_info creation on alloc_percpu failure.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_semantics.c |    2 ++
 net/ipv4/route.c         |    3 ---
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 2677530..71b125c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -840,6 +840,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	change_nexthops(fi) {
 		nexthop_nh->nh_parent = fi;
 		nexthop_nh->nh_pcpu_rth_output = alloc_percpu(struct rtable __rcu *);
+		if (!nexthop_nh->nh_pcpu_rth_output)
+			goto failure;
 	} endfor_nexthops(fi)
 
 	if (cfg->fc_mx) {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b90da1b..5b0180f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1207,8 +1207,6 @@ static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 	if (rt_is_input_route(rt)) {
 		p = (struct rtable **)&nh->nh_rth_input;
 	} else {
-		if (!nh->nh_pcpu_rth_output)
-			goto nocache;
 		p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
 	}
 	orig = *p;
@@ -1223,7 +1221,6 @@ static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 		 * unsuccessful at storing this route into the cache
 		 * we really need to set it.
 		 */
-nocache:
 		rt->dst.flags |= DST_NOCACHE;
 		ret = false;
 	}
-- 
1.7.3.4
