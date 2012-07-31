From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Cache routes in nexthop exception entries.
Date: Mon, 30 Jul 2012 18:23:28 -0700 (PDT)
Message-ID: <20120730.182328.939620011280921405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123Ab2GaBX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 21:23:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |  1 +
 net/ipv4/fib_semantics.c |  4 +++
 net/ipv4/route.c         | 82 ++++++++++++++++++++++++++----------------------
 3 files changed, 49 insertions(+), 38 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e69c3a4..c4770fc 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -54,6 +54,7 @@ struct fib_nh_exception {
 	u32				fnhe_pmtu;
 	__be32				fnhe_gw;
 	unsigned long			fnhe_expires;
+	struct rtable			*fnhe_rth;
 	unsigned long			fnhe_stamp;
 };
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index e55171f..eaccdb5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -153,6 +153,10 @@ static void free_nh_exceptions(struct fib_nh *nh)
 			struct fib_nh_exception *next;
 			
 			next = rcu_dereference_protected(fnhe->fnhe_next, 1);
+
+			if (fnhe->fnhe_rth)
+				dst_release(&fnhe->fnhe_rth->dst);
+
 			kfree(fnhe);
 
 			fnhe = next;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d6eabcf..e2abb0d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -587,7 +587,7 @@ static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 		build_sk_flow_key(fl4, sk);
 }
 
-static DEFINE_SEQLOCK(fnhe_seqlock);
+static DEFINE_SPINLOCK(fnhe_lock);
 
 static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash)
 {
@@ -599,6 +599,10 @@ static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash)
 		if (time_before(fnhe->fnhe_stamp, oldest->fnhe_stamp))
 			oldest = fnhe;
 	}
+	if (oldest->fnhe_rth) {
+		dst_release(&oldest->fnhe_rth->dst);
+		oldest->fnhe_rth = NULL;
+	}
 	return oldest;
 }
 
@@ -620,7 +624,7 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
 	int depth;
 	u32 hval = fnhe_hashfun(daddr);
 
-	write_seqlock_bh(&fnhe_seqlock);
+	spin_lock_bh(&fnhe_lock);
 
 	hash = nh->nh_exceptions;
 	if (!hash) {
@@ -667,7 +671,7 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
 	fnhe->fnhe_stamp = jiffies;
 
 out_unlock:
-	write_sequnlock_bh(&fnhe_seqlock);
+	spin_unlock_bh(&fnhe_lock);
 	return;
 }
 
@@ -1167,36 +1171,37 @@ static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
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
+
+	if (daddr == fnhe->fnhe_daddr) {
+		struct rtable *orig;
 
-	if (pmtu) {
-		unsigned long diff = expires - jiffies;
+		if (fnhe->fnhe_pmtu) {
+			unsigned long expires = fnhe->fnhe_expires;
+			unsigned long diff = expires - jiffies;
 
-		if (time_before(jiffies, expires)) {
-			rt->rt_pmtu = pmtu;
-			dst_set_expires(&rt->dst, diff);
+			if (time_before(jiffies, expires)) {
+				rt->rt_pmtu = fnhe->fnhe_pmtu;
+				dst_set_expires(&rt->dst, diff);
+			}
 		}
+		if (fnhe->fnhe_gw) {
+			rt->rt_flags |= RTCF_REDIRECTED;
+			rt->rt_gateway = fnhe->fnhe_gw;
+		}
+
+		orig = fnhe->fnhe_rth;
+		if (orig)
+			dst_release(&orig->dst);
+
+		rt->dst.flags |= DST_RCU_FREE;
+		dst_hold(&rt->dst);
+		fnhe->fnhe_rth = rt;
+
+		fnhe->fnhe_stamp = jiffies;
 	}
-	if (gw) {
-		rt->rt_flags |= RTCF_REDIRECTED;
-		rt->rt_gateway = gw;
-	}
-	fnhe->fnhe_stamp = jiffies;
+
+	spin_unlock_bh(&fnhe_lock);
 }
 
 static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
@@ -1236,13 +1241,13 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 
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
 
@@ -1741,18 +1746,19 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	fnhe = NULL;
 	if (fi) {
 		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
-		if (!fnhe) {
+		if (fnhe)
+			rth = fnhe->fnhe_rth;
+		else
 			rth = FIB_RES_NH(*res).nh_rth_output;
-			if (rt_cache_valid(rth)) {
-				dst_hold(&rth->dst);
-				return rth;
-			}
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
1.7.11.2
