From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Shrink struct dst_entry a bit
Date: Tue, 13 Mar 2007 15:58:10 +0100
Message-ID: <200703131558.10596.dada1@cosmosbay.com>
References: <200703131448.15193.ak@suse.de> <200703131531.14548.ak@suse.de> <200703131544.57757.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Cwr9FwkCUq+xv4G"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:43960 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030565AbXCMO6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 10:58:05 -0400
In-Reply-To: <200703131544.57757.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_Cwr9FwkCUq+xv4G
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 13 March 2007 15:44, Eric Dumazet wrote:

> Also, 'lastuse' could use a u32 too, I even had a patch for this one...

Here is the patch I have here for lastuse u32 conversion, not for inclusion 
yet because not yet tested (only compiled)

[PATCH] NET : abstract lastuse (from struct dst_entry) and convert it to u32

This saves 4 bytes (possibly 8) on 64 bit archs

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_Cwr9FwkCUq+xv4G
Content-Type: text/plain;
  charset="iso-8859-1";
  name="lastuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="lastuse.patch"

diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index c080f61..fb23951 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -89,7 +89,16 @@ static inline u64 get_jiffies_64(void)
 	return (u64)jiffies;
 }
 #endif
-
+/*
+ * On 64bit archs, storing timestamps in 'unsigned long' vars
+ * may consume unecessary memory. Using u32 is ok when deltas
+ * between current jiffie and past timestamps are known to
+ * fit in 32-1 bits. Even with HZ=1000, thats 24 days.
+ */
+static inline u32 get_jiffies_32(void)
+{
+	return (u32)jiffies;
+}
 /*
  *	These inlines deal with timer wrapping correctly. You are 
  *	strongly encouraged to use them
diff --git a/include/net/dst.h b/include/net/dst.h
index e12a8ce..70366b7 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -67,13 +67,13 @@ #define DST_BALANCED            0x10
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 
+
+	struct  dst_ops	        *ops;
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;
 #endif
-
-	struct  dst_ops	        *ops;
 		
-	unsigned long		lastuse;
+	u32			__lastuse;
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
 	union {
@@ -103,11 +103,23 @@ struct dst_ops
 	int			entry_size;
 
 	atomic_t		entries;
-	struct kmem_cache 		*kmem_cachep;
+	struct kmem_cache 	*kmem_cachep;
 };
 
 #ifdef __KERNEL__
 
+static inline void 
+dst_lastuse_set(struct dst_entry *dst)
+{
+	dst->__lastuse = get_jiffies_32();
+}
+
+static inline unsigned long
+dst_lastuse_delta(const struct dst_entry *dst)
+{
+	return get_jiffies_32() - dst->__lastuse;
+}
+
 static inline u32
 dst_metric(const struct dst_entry *dst, int metric)
 {
diff --git a/net/core/dst.c b/net/core/dst.c
index 764bccb..6c0a023 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -136,7 +136,7 @@ void * dst_alloc(struct dst_ops * ops)
 		return NULL;
 	atomic_set(&dst->__refcnt, 0);
 	dst->ops = ops;
-	dst->lastuse = jiffies;
+	dst_lastuse_set(dst);
 	dst->path = dst;
 	dst->input = dst_discard_in;
 	dst->output = dst_discard_out;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 6055074..c3f5264 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -215,7 +215,7 @@ int rtnl_put_cacheinfo(struct sk_buff *s
 		       u32 ts, u32 tsage, long expires, u32 error)
 {
 	struct rta_cacheinfo ci = {
-		.rta_lastuse = jiffies_to_clock_t(jiffies - dst->lastuse),
+		.rta_lastuse = jiffies_to_clock_t(dst_lastuse_delta(dst)),
 		.rta_used = dst->__use,
 		.rta_clntref = atomic_read(&(dst->__refcnt)),
 		.rta_error = error,
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 32a7db3..3d5c46c 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -166,7 +166,7 @@ static void dn_dst_check_expire(unsigned
 		spin_lock(&dn_rt_hash_table[i].lock);
 		while((rt=*rtp) != NULL) {
 			if (atomic_read(&rt->u.dst.__refcnt) ||
-					(now - rt->u.dst.lastuse) < expire) {
+					dst_lastuse_delta(&rt->u.dst) < expire) {
 				rtp = &rt->u.dst.dn_next;
 				continue;
 			}
@@ -187,7 +187,6 @@ static int dn_dst_gc(void)
 {
 	struct dn_route *rt, **rtp;
 	int i;
-	unsigned long now = jiffies;
 	unsigned long expire = 10 * HZ;
 
 	for(i = 0; i <= dn_rt_hash_mask; i++) {
@@ -197,7 +196,7 @@ static int dn_dst_gc(void)
 
 		while((rt=*rtp) != NULL) {
 			if (atomic_read(&rt->u.dst.__refcnt) ||
-					(now - rt->u.dst.lastuse) < expire) {
+					dst_lastuse_delta(&rt->u.dst) < expire) {
 				rtp = &rt->u.dst.dn_next;
 				continue;
 			}
@@ -278,7 +277,6 @@ static inline int compare_keys(struct fl
 static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route **rp)
 {
 	struct dn_route *rth, **rthp;
-	unsigned long now = jiffies;
 
 	rthp = &dn_rt_hash_table[hash].chain;
 
@@ -293,7 +291,7 @@ static int dn_insert_route(struct dn_rou
 
 			rth->u.dst.__use++;
 			dst_hold(&rth->u.dst);
-			rth->u.dst.lastuse = now;
+			dst_lastuse_set(&rth->u.dst);
 			spin_unlock_bh(&dn_rt_hash_table[hash].lock);
 
 			dnrt_drop(rt);
@@ -308,7 +306,7 @@ static int dn_insert_route(struct dn_rou
 
 	dst_hold(&rt->u.dst);
 	rt->u.dst.__use++;
-	rt->u.dst.lastuse = now;
+	dst_lastuse_set(&rt->u.dst);
 	spin_unlock_bh(&dn_rt_hash_table[hash].lock);
 	*rp = rt;
 	return 0;
@@ -1119,7 +1117,7 @@ make_route:
 	rt->u.dst.neighbour = neigh;
 	neigh = NULL;
 
-	rt->u.dst.lastuse = jiffies;
+	dst_lastuse_set(&rt->u.dst);
 	rt->u.dst.output  = dn_output;
 	rt->u.dst.input   = dn_rt_bug;
 	rt->rt_flags      = flags;
@@ -1175,7 +1173,7 @@ static int __dn_route_output_key(struct 
 			    (flp->mark == rt->fl.mark) &&
 			    (rt->fl.iif == 0) &&
 			    (rt->fl.oif == flp->oif)) {
-				rt->u.dst.lastuse = jiffies;
+				dst_lastuse_set(&rt->u.dst);
 				dst_hold(&rt->u.dst);
 				rt->u.dst.__use++;
 				rcu_read_unlock_bh();
@@ -1380,7 +1378,7 @@ make_route:
 	rt->u.dst.flags = DST_HOST;
 	rt->u.dst.neighbour = neigh;
 	rt->u.dst.dev = out_dev;
-	rt->u.dst.lastuse = jiffies;
+	dst_lastuse_set(&rt->u.dst);
 	rt->u.dst.output = dn_rt_bug;
 	switch(res.type) {
 		case RTN_UNICAST:
@@ -1449,7 +1447,7 @@ int dn_route_input(struct sk_buff *skb)
 		    (rt->fl.oif == 0) &&
 		    (rt->fl.mark == skb->mark) &&
 		    (rt->fl.iif == cb->iif)) {
-			rt->u.dst.lastuse = jiffies;
+			dst_lastuse_set(&rt->u.dst);
 			dst_hold(&rt->u.dst);
 			rt->u.dst.__use++;
 			rcu_read_unlock();
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 2f44e61..6831897 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -343,7 +343,7 @@ static int cleanup_once(unsigned long tt
 	spin_lock_bh(&inet_peer_unused_lock);
 	p = inet_peer_unused_head;
 	if (p != NULL) {
-		__u32 delta = (__u32)jiffies - p->dtime;
+		__u32 delta = get_jiffies_32() - p->dtime;
 		if (delta < ttl) {
 			/* Do not prune fresh entries. */
 			spin_unlock_bh(&inet_peer_unused_lock);
@@ -471,7 +471,7 @@ void inet_putpeer(struct inet_peer *p)
 		p->unused_next = NULL;
 		*inet_peer_unused_tailp = p;
 		inet_peer_unused_tailp = &p->unused_next;
-		p->dtime = (__u32)jiffies;
+		p->dtime = get_jiffies_32();
 	}
 	spin_unlock_bh(&inet_peer_unused_lock);
 }
diff --git a/net/ipv4/multipath_drr.c b/net/ipv4/multipath_drr.c
index 574c735..e318dbd 100644
--- a/net/ipv4/multipath_drr.c
+++ b/net/ipv4/multipath_drr.c
@@ -147,7 +147,7 @@ static void drr_select_route(const struc
 		    multipath_comparekeys(&nh->fl, flp)) {
 			int nh_ifidx = nh->u.dst.dev->ifindex;
 
-			nh->u.dst.lastuse = jiffies;
+			dst_lastuse_set(&nh->u.dst);
 			nh->u.dst.__use++;
 			if (result != NULL)
 				continue;
diff --git a/net/ipv4/multipath_random.c b/net/ipv4/multipath_random.c
index c312785..5355593 100644
--- a/net/ipv4/multipath_random.c
+++ b/net/ipv4/multipath_random.c
@@ -78,7 +78,7 @@ static void random_select_route(const st
 		for (rt = first; rt; rt = rt->u.dst.rt_next) {
 			if ((rt->u.dst.flags & DST_BALANCED) != 0 &&
 			    multipath_comparekeys(&rt->fl, flp)) {
-				rt->u.dst.lastuse = jiffies;
+				dst_lastuse_set(&rt->u.dst);
 
 				if (i == candidate_no)
 					decision = rt;
diff --git a/net/ipv4/multipath_rr.c b/net/ipv4/multipath_rr.c
index 0ad2252..26a55bf 100644
--- a/net/ipv4/multipath_rr.c
+++ b/net/ipv4/multipath_rr.c
@@ -60,7 +60,7 @@ static void rr_select_route(const struct
 	     nh = rcu_dereference(nh->u.dst.rt_next)) {
 		if ((nh->u.dst.flags & DST_BALANCED) != 0 &&
 		    multipath_comparekeys(&nh->fl, flp)) {
-			nh->u.dst.lastuse = jiffies;
+			dst_lastuse_set(&nh->u.dst);
 
 			if (min_use == -1 || nh->u.dst.__use < min_use) {
 				min_use = nh->u.dst.__use;
diff --git a/net/ipv4/multipath_wrandom.c b/net/ipv4/multipath_wrandom.c
index 57c5036..30467d3 100644
--- a/net/ipv4/multipath_wrandom.c
+++ b/net/ipv4/multipath_wrandom.c
@@ -189,7 +189,7 @@ static void wrandom_select_route(const s
 	decision = first;
 	last_mpc = NULL;
 	for (mpc = first_mpc; mpc; mpc = mpc->next) {
-		mpc->rt->u.dst.lastuse = jiffies;
+		dst_lastuse_set(&mpc->rt->u.dst);
 		if (last_power <= selector && selector < mpc->power)
 			decision = mpc->rt;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5841739..cbd6337 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -533,7 +533,7 @@ static int rt_may_expire(struct rtable *
 	    time_after_eq(jiffies, rth->u.dst.expires))
 		goto out;
 
-	age = jiffies - rth->u.dst.lastuse;
+	age = dst_lastuse_delta(&rth->u.dst);
 	ret = 0;
 	if ((age <= tmo1 && !rt_fast_clean(rth)) ||
 	    (age <= tmo2 && rt_valuable(rth)))
@@ -549,7 +549,7 @@ out:	return ret;
  */
 static inline u32 rt_score(struct rtable *rt)
 {
-	u32 score = jiffies - rt->u.dst.lastuse;
+	u32 score = dst_lastuse_delta(&rt->u.dst);
 
 	score = ~score & ~(3<<30);
 
@@ -922,7 +922,6 @@ out:	return 0;
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;
-	unsigned long	now;
 	struct rtable *cand, **candp;
 	u32 		min_score;
 	int		chain_length;
@@ -933,7 +932,6 @@ restart:
 	min_score = ~(u32)0;
 	cand = NULL;
 	candp = NULL;
-	now = jiffies;
 
 	rthp = &rt_hash_table[hash].chain;
 
@@ -962,7 +960,7 @@ #endif
 
 			rth->u.dst.__use++;
 			dst_hold(&rth->u.dst);
-			rth->u.dst.lastuse = now;
+			dst_lastuse_set(&rth->u.dst);
 			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			rt_drop(rt);
@@ -1198,7 +1196,7 @@ void ip_rt_redirect(__be32 old_gw, __be3
 				if (rt->idev)
 					in_dev_hold(rt->idev);
 				rt->u.dst.obsolete	= 0;
-				rt->u.dst.lastuse	= jiffies;
+				dst_lastuse_set(&rt->u.dst);
 				rt->u.dst.path		= &rt->u.dst;
 				rt->u.dst.neighbour	= NULL;
 				rt->u.dst.hh		= NULL;
@@ -2105,7 +2103,7 @@ int ip_route_input(struct sk_buff *skb, 
 		    rth->fl.oif == 0 &&
 		    rth->fl.mark == skb->mark &&
 		    rth->fl.fl4_tos == tos) {
-			rth->u.dst.lastuse = jiffies;
+			dst_lastuse_set(&rth->u.dst);
 			dst_hold(&rth->u.dst);
 			rth->u.dst.__use++;
 			RT_CACHE_STAT_INC(in_hit);
@@ -2581,7 +2579,7 @@ int __ip_route_output_key(struct rtable 
 				return 0;
 			}
 
-			rth->u.dst.lastuse = jiffies;
+			dst_lastuse_set(&rth->u.dst);
 			dst_hold(&rth->u.dst);
 			rth->u.dst.__use++;
 			RT_CACHE_STAT_INC(out_hit);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index f1c32ff..ecc8aa9 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -160,7 +160,7 @@ #endif
 			dev_hold(rt->u.dst.dev);
 		dst_prev->obsolete	= -1;
 		dst_prev->flags	       |= DST_HOST;
-		dst_prev->lastuse	= jiffies;
+		dst_lastuse_set(dst_prev);
 		dst_prev->header_len	= header_len;
 		dst_prev->nfheader_len	= 0;
 		dst_prev->trailer_len	= trailer_len;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index f4d7be7..906cfed 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1425,7 +1425,7 @@ static int fib6_age(struct rt6_info *rt,
 		gc_args.more++;
 	} else if (rt->rt6i_flags & RTF_CACHE) {
 		if (atomic_read(&rt->u.dst.__refcnt) == 0 &&
-		    time_after_eq(now, rt->u.dst.lastuse + gc_args.timeout)) {
+		    dst_lastuse_delta(&rt->u.dst) >= gc_args.timeout) {
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bb2b508..bb7f203 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -528,7 +528,7 @@ out:
 	dst_hold(&rt->u.dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	rt->u.dst.lastuse = jiffies;
+	dst_lastuse_set(&rt->u.dst);
 	rt->u.dst.__use++;
 
 	return rt;
@@ -706,7 +706,7 @@ out:
 	dst_hold(&rt->u.dst);
 	read_unlock_bh(&table->tb6_lock);
 out2:
-	rt->u.dst.lastuse = jiffies;
+	dst_lastuse_set(&rt->u.dst);
 	rt->u.dst.__use++;
 
 	return rt;
@@ -801,7 +801,7 @@ out:
 	dst_hold(&rt->u.dst);
 	read_unlock_bh(&table->tb6_lock);
 out2:
-	rt->u.dst.lastuse = jiffies;
+	dst_lastuse_set(&rt->u.dst);
 	rt->u.dst.__use++;
 	return rt;
 }
@@ -1560,7 +1560,7 @@ static struct rt6_info * ip6_rt_copy(str
 		rt->rt6i_idev = ort->rt6i_idev;
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
-		rt->u.dst.lastuse = jiffies;
+		dst_lastuse_set(&rt->u.dst);
 		rt->rt6i_expires = 0;
 
 		ipv6_addr_copy(&rt->rt6i_gateway, &ort->rt6i_gateway);
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index b93bfb8..f059cbe 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -223,7 +223,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 			dev_hold(rt->u.dst.dev);
 		dst_prev->obsolete	= -1;
 		dst_prev->flags	       |= DST_HOST;
-		dst_prev->lastuse	= jiffies;
+		dst_lastuse_set(dst_prev);
 		dst_prev->header_len	= header_len;
 		dst_prev->nfheader_len	= nfheader_len;
 		dst_prev->trailer_len	= trailer_len;

--Boundary-00=_Cwr9FwkCUq+xv4G--
