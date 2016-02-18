From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] route: check and remove route cache when we get route
Date: Thu, 18 Feb 2016 21:21:19 +0800
Message-ID: <e190b1f6eb762c5770faef080ef6080a6dbdedfb.1455801679.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32891 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946042AbcBRNVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 08:21:24 -0500
Received: by mail-pf0-f196.google.com with SMTP id c10so2110917pfc.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 05:21:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the gc of ipv4 route was removed, the route cached would has
no chance to be removed, and even it has been timeout, it still could
be used, cause no code to check it's expires.

Fix this issue by checking  and removing route cache when we get route.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip_fib.h |  1 +
 net/ipv4/route.c     | 77 ++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 64 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 7029527..4079fc1 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -61,6 +61,7 @@ struct fib_nh_exception {
 	struct rtable __rcu		*fnhe_rth_input;
 	struct rtable __rcu		*fnhe_rth_output;
 	unsigned long			fnhe_stamp;
+	struct rcu_head			rcu;
 };
 
 struct fnhe_hash_bucket {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 85f184e..02c6229 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -129,6 +129,7 @@ static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
 
+static int ip_rt_gc_timeout __read_mostly	= RT_GC_TIMEOUT;
 /*
  *	Interface to generic destination cache.
  */
@@ -755,7 +756,7 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 				struct fib_nh *nh = &FIB_RES_NH(res);
 
 				update_or_create_fnhe(nh, fl4->daddr, new_gw,
-						      0, 0);
+						0, jiffies + ip_rt_gc_timeout);
 			}
 			if (kill_route)
 				rt->dst.obsolete = DST_OBSOLETE_KILL;
@@ -1556,6 +1557,36 @@ static void ip_handle_martian_source(struct net_device *dev,
 #endif
 }
 
+static void ip_del_fnhe(struct fib_nh *nh, __be32 daddr)
+{
+	struct fnhe_hash_bucket *hash;
+	struct fib_nh_exception *fnhe, __rcu **fnhe_p;
+	u32 hval = fnhe_hashfun(daddr);
+
+	spin_lock_bh(&fnhe_lock);
+
+	hash = rcu_dereference_protected(nh->nh_exceptions,
+					 lockdep_is_held(&fnhe_lock));
+	hash += hval;
+
+	fnhe_p = &hash->chain;
+	fnhe = rcu_dereference_protected(*fnhe_p, lockdep_is_held(&fnhe_lock));
+	while (fnhe) {
+		if (fnhe->fnhe_daddr == daddr) {
+			rcu_assign_pointer(*fnhe_p, rcu_dereference_protected(
+				fnhe->fnhe_next, lockdep_is_held(&fnhe_lock)));
+			fnhe_flush_routes(fnhe);
+			kfree_rcu(fnhe, rcu);
+			break;
+		}
+		fnhe_p = &fnhe->fnhe_next;
+		fnhe = rcu_dereference_protected(fnhe->fnhe_next,
+						 lockdep_is_held(&fnhe_lock));
+	}
+
+	spin_unlock_bh(&fnhe_lock);
+}
+
 /* called in rcu_read_lock() section */
 static int __mkroute_input(struct sk_buff *skb,
 			   const struct fib_result *res,
@@ -1609,11 +1640,20 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	fnhe = find_exception(&FIB_RES_NH(*res), daddr);
 	if (do_cache) {
-		if (fnhe)
+		if (fnhe) {
 			rth = rcu_dereference(fnhe->fnhe_rth_input);
-		else
-			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
+			if (rth && rth->dst.expires &&
+			    time_after(jiffies, rth->dst.expires)) {
+				ip_del_fnhe(&FIB_RES_NH(*res), daddr);
+				fnhe = NULL;
+			} else {
+				goto rt_cache;
+			}
+		}
+
+		rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
 
+rt_cache:
 		if (rt_cache_valid(rth)) {
 			skb_dst_set_noref(skb, &rth->dst);
 			goto out;
@@ -2014,19 +2054,29 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		struct fib_nh *nh = &FIB_RES_NH(*res);
 
 		fnhe = find_exception(nh, fl4->daddr);
-		if (fnhe)
+		if (fnhe) {
 			prth = &fnhe->fnhe_rth_output;
-		else {
-			if (unlikely(fl4->flowi4_flags &
-				     FLOWI_FLAG_KNOWN_NH &&
-				     !(nh->nh_gw &&
-				       nh->nh_scope == RT_SCOPE_LINK))) {
-				do_cache = false;
-				goto add;
+			rth = rcu_dereference(*prth);
+			if (rth && rth->dst.expires &&
+			    time_after(jiffies, rth->dst.expires)) {
+				ip_del_fnhe(nh, fl4->daddr);
+				fnhe = NULL;
+			} else {
+				goto rt_cache;
 			}
-			prth = raw_cpu_ptr(nh->nh_pcpu_rth_output);
 		}
+
+		if (unlikely(fl4->flowi4_flags &
+			     FLOWI_FLAG_KNOWN_NH &&
+			     !(nh->nh_gw &&
+			       nh->nh_scope == RT_SCOPE_LINK))) {
+			do_cache = false;
+			goto add;
+		}
+		prth = raw_cpu_ptr(nh->nh_pcpu_rth_output);
 		rth = rcu_dereference(*prth);
+
+rt_cache:
 		if (rt_cache_valid(rth)) {
 			dst_hold(&rth->dst);
 			return rth;
@@ -2569,7 +2619,6 @@ void ip_rt_multicast_event(struct in_device *in_dev)
 }
 
 #ifdef CONFIG_SYSCTL
-static int ip_rt_gc_timeout __read_mostly	= RT_GC_TIMEOUT;
 static int ip_rt_gc_interval __read_mostly  = 60 * HZ;
 static int ip_rt_gc_min_interval __read_mostly	= HZ / 2;
 static int ip_rt_gc_elasticity __read_mostly	= 8;
-- 
2.1.0
