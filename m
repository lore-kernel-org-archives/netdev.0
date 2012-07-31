From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] ipv4: percpu nh_rth_output cache
Date: Tue, 31 Jul 2012 17:45:30 +0200
Message-ID: <1343749530.21269.336.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43569 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054Ab2GaPpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 11:45:34 -0400
Received: by bkwj10 with SMTP id j10so3357460bkw.19
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 08:45:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Input path is mostly run under RCU and doesnt touch dst refcnt

But output path on forwarding or UDP workloads hits
badly dst refcount, and we have lot of false sharing, for example
in ipv4_mtu() when reading rt->rt_pmtu

Using a percpu cache for nh_rth_output gives a nice performance
increase at a small cost.

24 udpflood test on my 24 cpu machine (dummy0 output device)
(each process sends 1.000.000 udp frames, 24 processes are started)

before : 5.24 s
after : 2.06 s
For reference, time on linux-3.5 : 6.60 s

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: use __this_cpu_ptr() and slighly better annotations to avoid
ugly casts

On top on previous "ipv4: Restore old dst_free() behavior" patch

We probably can remove all paddings in struct dst_entry

 include/net/ip_fib.h     |    3 ++-
 net/ipv4/fib_semantics.c |   20 +++++++++++++++++++-
 net/ipv4/route.c         |   18 +++++++++++++-----
 3 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e521a03..e331746 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -21,6 +21,7 @@
 #include <linux/rcupdate.h>
 #include <net/fib_rules.h>
 #include <net/inetpeer.h>
+#include <linux/percpu.h>
 
 struct fib_config {
 	u8			fc_dst_len;
@@ -81,7 +82,7 @@ struct fib_nh {
 	__be32			nh_gw;
 	__be32			nh_saddr;
 	int			nh_saddr_genid;
-	struct rtable __rcu	*nh_rth_output;
+	struct rtable __rcu * __percpu *nh_pcpu_rth_output;
 	struct rtable __rcu	*nh_rth_input;
 	struct fnhe_hash_bucket	*nh_exceptions;
 };
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 625cf18..fe2ca02 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -176,6 +176,23 @@ static void rt_nexthop_free(struct rtable __rcu **rtp)
 	dst_free(&rt->dst);
 }
 
+static void rt_nexthop_free_cpus(struct rtable __rcu * __percpu *rtp)
+{
+	int cpu;
+
+	if (!rtp)
+		return;
+
+	for_each_possible_cpu(cpu) {
+		struct rtable *rt;
+
+		rt = rcu_dereference_protected(*per_cpu_ptr(rtp, cpu), 1);
+		if (rt)
+			dst_free(&rt->dst);
+	}
+	free_percpu(rtp);
+}
+
 /* Release a nexthop info record */
 static void free_fib_info_rcu(struct rcu_head *head)
 {
@@ -186,7 +203,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
 			dev_put(nexthop_nh->nh_dev);
 		if (nexthop_nh->nh_exceptions)
 			free_nh_exceptions(nexthop_nh);
-		rt_nexthop_free(&nexthop_nh->nh_rth_output);
+		rt_nexthop_free_cpus(nexthop_nh->nh_pcpu_rth_output);
 		rt_nexthop_free(&nexthop_nh->nh_rth_input);
 	} endfor_nexthops(fi);
 
@@ -817,6 +834,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	fi->fib_nhs = nhs;
 	change_nexthops(fi) {
 		nexthop_nh->nh_parent = fi;
+		nexthop_nh->nh_pcpu_rth_output = alloc_percpu(struct rtable __rcu *);
 	} endfor_nexthops(fi)
 
 	if (cfg->fc_mx) {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2bd1074..4f6276c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1206,11 +1206,15 @@ static inline void rt_free(struct rtable *rt)
 
 static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 {
-	struct rtable *orig, *prev, **p = (struct rtable **)&nh->nh_rth_output;
+	struct rtable *orig, *prev, **p;
 
-	if (rt_is_input_route(rt))
+	if (rt_is_input_route(rt)) {
 		p = (struct rtable **)&nh->nh_rth_input;
-
+	} else {
+		if (!nh->nh_pcpu_rth_output)
+			goto nocache;
+		p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
+	}
 	orig = *p;
 
 	prev = cmpxchg(p, orig, rt);
@@ -1223,6 +1227,7 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 		 * unsuccessful at storing this route into the cache
 		 * we really need to set it.
 		 */
+nocache:
 		rt->dst.flags |= DST_NOCACHE;
 	}
 }
@@ -1749,8 +1754,11 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	fnhe = NULL;
 	if (fi) {
 		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
-		if (!fnhe) {
-			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_output);
+		if (!fnhe && FIB_RES_NH(*res).nh_pcpu_rth_output) {
+			struct rtable __rcu **prth;
+
+			prth = __this_cpu_ptr(FIB_RES_NH(*res).nh_pcpu_rth_output);
+			rth = rcu_dereference(*prth);
 			if (rt_cache_valid(rth)) {
 				dst_hold(&rth->dst);
 				return rth;
