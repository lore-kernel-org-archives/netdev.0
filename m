From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Cache routes in nexthop exception entries.
Date: Tue, 31 Jul 2012 15:20:09 -0700 (PDT)
Message-ID: <20120731.152009.1922072870797066400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab2GaWUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 18:20:11 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 6B059582E8E
	for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 15:20:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

This is just a respin of what I posted the other day, against Eric's
fixes of today.  Pushed to 'net'.

 include/net/ip_fib.h     |    1 +
 net/ipv4/fib_semantics.c |   39 ++++++++++--------
 net/ipv4/route.c         |  103 +++++++++++++++++++++++++---------------------
 3 files changed, 79 insertions(+), 64 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e331746..926142e 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -55,6 +55,7 @@ struct fib_nh_exception {
 	u32				fnhe_pmtu;
 	__be32				fnhe_gw;
 	unsigned long			fnhe_expires;
+	struct rtable __rcu		*fnhe_rth;
 	unsigned long			fnhe_stamp;
 };
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index fe2ca02..da80dc1 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -140,6 +140,21 @@ const struct fib_prop fib_props[RTN_MAX + 1] = {
 	},
 };
 
+static void rt_fibinfo_free(struct rtable __rcu **rtp)
+{
+	struct rtable *rt = rcu_dereference_protected(*rtp, 1);
+
+	if (!rt)
+		return;
+
+	/* Not even needed : RCU_INIT_POINTER(*rtp, NULL);
+	 * because we waited an RCU grace period before calling
+	 * free_fib_info_rcu()
+	 */
+
+	dst_free(&rt->dst);
+}
+
 static void free_nh_exceptions(struct fib_nh *nh)
 {
 	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
@@ -153,6 +168,9 @@ static void free_nh_exceptions(struct fib_nh *nh)
 			struct fib_nh_exception *next;
 			
 			next = rcu_dereference_protected(fnhe->fnhe_next, 1);
+
+			rt_fibinfo_free(&fnhe->fnhe_rth);
+
 			kfree(fnhe);
 
 			fnhe = next;
@@ -161,22 +179,7 @@ static void free_nh_exceptions(struct fib_nh *nh)
 	kfree(hash);
 }
 
-static void rt_nexthop_free(struct rtable __rcu **rtp)
-{
-	struct rtable *rt = rcu_dereference_protected(*rtp, 1);
-
-	if (!rt)
-		return;
-
-	/* Not even needed : RCU_INIT_POINTER(*rtp, NULL);
-	 * because we waited an RCU grace period before calling
-	 * free_fib_info_rcu()
-	 */
-
-	dst_free(&rt->dst);
-}
-
-static void rt_nexthop_free_cpus(struct rtable __rcu * __percpu *rtp)
+static void rt_fibinfo_free_cpus(struct rtable __rcu * __percpu *rtp)
 {
 	int cpu;
 
@@ -203,8 +206,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 			dev_put(nexthop_nh->nh_dev);
 		if (nexthop_nh->nh_exceptions)
 			free_nh_exceptions(nexthop_nh);
-		rt_nexthop_free_cpus(nexthop_nh->nh_pcpu_rth_output);
-		rt_nexthop_free(&nexthop_nh->nh_rth_input);
+		rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
+		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4f6276c..b102eeb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -587,11 +587,17 @@ static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 		build_sk_flow_key(fl4, sk);
 }
 
-static DEFINE_SEQLOCK(fnhe_seqlock);
+static inline void rt_free(struct rtable *rt)
+{
+	call_rcu(&rt->dst.rcu_head, dst_rcu_free);
+}
+
+static DEFINE_SPINLOCK(fnhe_lock);
 
 static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash)
 {
 	struct fib_nh_exception *fnhe, *oldest;
+	struct rtable *orig;
 
 	oldest = rcu_dereference(hash->chain);
 	for (fnhe = rcu_dereference(oldest->fnhe_next); fnhe;
@@ -599,6 +605,11 @@ static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash)
 		if (time_before(fnhe->fnhe_stamp, oldest->fnhe_stamp))
 			oldest = fnhe;
 	}
+	orig = rcu_dereference(oldest->fnhe_rth);
+	if (orig) {
+		RCU_INIT_POINTER(oldest->fnhe_rth, NULL);
+		rt_free(orig);
+	}
 	return oldest;
 }
 
@@ -620,7 +631,7 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
 	int depth;
 	u32 hval = fnhe_hashfun(daddr);
 
-	write_seqlock_bh(&fnhe_seqlock);
+	spin_lock_bh(&fnhe_lock);
 
 	hash = nh->nh_exceptions;
 	if (!hash) {
@@ -667,7 +678,7 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
 	fnhe->fnhe_stamp = jiffies;
 
 out_unlock:
-	write_sequnlock_bh(&fnhe_seqlock);
+	spin_unlock_bh(&fnhe_lock);
 	return;
 }
 
@@ -1167,41 +1178,40 @@ static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
 static void rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 			      __be32 daddr)
 {
-	__be32 fnhe_daddr, gw;
-	unsigned long expires;
-	unsigned int seq;
-	u32 pmtu;
-
-restart:
-	seq = read_seqbegin(&fnhe_seqlock);
-	fnhe_daddr = fnhe->fnhe_daddr;
-	gw = fnhe->fnhe_gw;
-	pmtu = fnhe->fnhe_pmtu;
-	expires = fnhe->fnhe_expires;
-	if (read_seqretry(&fnhe_seqlock, seq))
-		goto restart;
-
-	if (daddr != fnhe_daddr)
-		return;
+	spin_lock_bh(&fnhe_lock);
 
-	if (pmtu) {
-		unsigned long diff = expires - jiffies;
+	if (daddr == fnhe->fnhe_daddr) {
+		struct rtable *orig;
 
-		if (time_before(jiffies, expires)) {
-			rt->rt_pmtu = pmtu;
-			dst_set_expires(&rt->dst, diff);
+		if (fnhe->fnhe_pmtu) {
+			unsigned long expires = fnhe->fnhe_expires;
+			unsigned long diff = expires - jiffies;
+
+			if (time_before(jiffies, expires)) {
+				rt->rt_pmtu = fnhe->fnhe_pmtu;
+				dst_set_expires(&rt->dst, diff);
+			}
+		}
+		if (fnhe->fnhe_gw) {
+			rt->rt_flags |= RTCF_REDIRECTED;
+			rt->rt_gateway = fnhe->fnhe_gw;
 		}
-	}
-	if (gw) {
-		rt->rt_flags |= RTCF_REDIRECTED;
-		rt->rt_gateway = gw;
-	}
-	fnhe->fnhe_stamp = jiffies;
-}
 
-static inline void rt_free(struct rtable *rt)
-{
-	call_rcu(&rt->dst.rcu_head, dst_rcu_free);
+		orig = rcu_dereference(fnhe->fnhe_rth);
+		rcu_assign_pointer(fnhe->fnhe_rth, rt);
+		if (orig)
+			rt_free(orig);
+
+		fnhe->fnhe_stamp = jiffies;
+	} else {
+		/* Routes we intend to cache in nexthop exception have
+		 * the DST_NOCACHE bit clear.  However, if we are
+		 * unsuccessful at storing this route into the cache
+		 * we really need to set it.
+		 */
+		rt->dst.flags |= DST_NOCACHE;
+	}
+	spin_unlock_bh(&fnhe_lock);
 }
 
 static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
@@ -1249,13 +1259,13 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 
 		if (nh->nh_gw && nh->nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = nh->nh_gw;
-		if (unlikely(fnhe))
-			rt_bind_exception(rt, fnhe, daddr);
 		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
-		if (!(rt->dst.flags & DST_NOCACHE))
+		if (unlikely(fnhe))
+			rt_bind_exception(rt, fnhe, daddr);
+		else if (!(rt->dst.flags & DST_NOCACHE))
 			rt_cache_route(nh, rt);
 	}
 
@@ -1753,22 +1763,23 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	fnhe = NULL;
 	if (fi) {
-		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
-		if (!fnhe && FIB_RES_NH(*res).nh_pcpu_rth_output) {
-			struct rtable __rcu **prth;
+		struct rtable __rcu **prth;
 
+		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
+		if (fnhe)
+			prth = &fnhe->fnhe_rth;
+		else
 			prth = __this_cpu_ptr(FIB_RES_NH(*res).nh_pcpu_rth_output);
-			rth = rcu_dereference(*prth);
-			if (rt_cache_valid(rth)) {
-				dst_hold(&rth->dst);
-				return rth;
-			}
+		rth = rcu_dereference(*prth);
+		if (rt_cache_valid(rth)) {
+			dst_hold(&rth->dst);
+			return rth;
 		}
 	}
 	rth = rt_dst_alloc(dev_out,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(in_dev, NOXFRM),
-			   fi && !fnhe);
+			   fi);
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-- 
1.7.10.4
