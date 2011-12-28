From: David Miller <davem@davemloft.net>
Subject: ipv6: Create fast inline ipv6 neigh lookup just like ipv4.
Date: Wed, 28 Dec 2011 15:56:49 -0500 (EST)
Message-ID: <20111228.155649.1898562199068114468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165Ab1L1U4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 15:56:51 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBSKunvo026515
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 12:56:50 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Also, create and use an rt6_bind_neighbour() in net/ipv6/route.c to
consolidate some common logic.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

This gives the ipv6 neigh handling more parity with the ipv4 side.

Eventually when all the pieces fall into place this fast path neigh
lookup will go into the ipv6 packet output path and ipv6 routes will
be neigh-less.

Hopefully, after ipv4 and ipv6, I can coerce the decnet code to do
similar and then we can elimiate the neighbour pointer entirely from
struct dst_entry.

Committed to net-next

 include/net/ndisc.h |   27 +++++++++++++++++++++++++++
 net/ipv6/route.c    |   41 ++++++++++++++++++++++-------------------
 2 files changed, 49 insertions(+), 19 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index e9c3002..e3133c2 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -89,6 +89,33 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
 		(p32[3] * hash_rnd[3]));
 }
 
+static inline struct neighbour *__ipv6_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, const void *pkey)
+{
+	struct neigh_hash_table *nht;
+	const u32 *p32 = pkey;
+	struct neighbour *n;
+	u32 hash_val;
+
+	rcu_read_lock_bh();
+	nht = rcu_dereference_bh(tbl->nht);
+	hash_val = ndisc_hashfn(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
+	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
+	     n != NULL;
+	     n = rcu_dereference_bh(n->next)) {
+		u32 *n32 = (u32 *) n->primary_key;
+		if (n->dev == dev &&
+		    ((n32[0] ^ p32[0]) | (n32[1] ^ p32[1]) |
+		     (n32[2] ^ p32[2]) | (n32[3] ^ p32[3])) == 0) {
+			if (!atomic_inc_not_zero(&n->refcnt))
+				n = NULL;
+			break;
+		}
+	}
+	rcu_read_unlock_bh();
+
+	return n;
+}
+
 extern int			ndisc_init(void);
 
 extern void			ndisc_cleanup(void);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 35b07cc..6bf6094 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -123,7 +123,20 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 
 static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
-	return __neigh_lookup_errno(&nd_tbl, daddr, dst->dev);
+	struct neighbour *n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
+	if (n)
+		return n;
+	return neigh_create(&nd_tbl, daddr, dst->dev);
+}
+
+static int rt6_bind_neighbour(struct rt6_info *rt)
+{
+	struct neighbour *n = ip6_neigh_lookup(&rt->dst, &rt->rt6i_gateway);
+	if (IS_ERR(n))
+		return PTR_ERR(n);
+	dst_set_neighbour(&rt->dst, n);
+
+	return 0;
 }
 
 static struct dst_ops ip6_dst_ops_template = {
@@ -714,7 +727,6 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 	rt = ip6_rt_copy(ort, daddr);
 
 	if (rt) {
-		struct neighbour *neigh;
 		int attempts = !in_softirq();
 
 		if (!(rt->rt6i_flags & RTF_GATEWAY)) {
@@ -734,9 +746,7 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 #endif
 
 	retry:
-		neigh = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway,
-					     rt->rt6i_dev);
-		if (IS_ERR(neigh)) {
+		if (rt6_bind_neighbour(rt)) {
 			struct net *net = dev_net(rt->rt6i_dev);
 			int saved_rt_min_interval =
 				net->ipv6.sysctl.ip6_rt_gc_min_interval;
@@ -762,8 +772,6 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 			dst_free(&rt->dst);
 			return NULL;
 		}
-		dst_set_neighbour(&rt->dst, neigh);
-
 	}
 
 	return rt;
@@ -1078,7 +1086,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (neigh)
 		neigh_hold(neigh);
 	else {
-		neigh = __neigh_lookup_errno(&nd_tbl, &fl6->daddr, dev);
+		neigh = ip6_neigh_lookup(&rt->dst, &fl6->daddr);
 		if (IS_ERR(neigh)) {
 			dst_free(&rt->dst);
 			return ERR_CAST(neigh);
@@ -1389,12 +1397,9 @@ int ip6_route_add(struct fib6_config *cfg)
 		rt->rt6i_prefsrc.plen = 0;
 
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
-		struct neighbour *n = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
-		if (IS_ERR(n)) {
-			err = PTR_ERR(n);
+		err = rt6_bind_neighbour(rt);
+		if (err)
 			goto out;
-		}
-		dst_set_neighbour(&rt->dst, n);
 	}
 
 	rt->rt6i_flags = cfg->fc_flags;
@@ -2057,7 +2062,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
 					    net->loopback_dev, 0);
-	struct neighbour *neigh;
+	int err;
 
 	if (!rt) {
 		if (net_ratelimit())
@@ -2079,13 +2084,11 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 		rt->rt6i_flags |= RTF_ANYCAST;
 	else
 		rt->rt6i_flags |= RTF_LOCAL;
-	neigh = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, rt->rt6i_dev);
-	if (IS_ERR(neigh)) {
+	err = rt6_bind_neighbour(rt);
+	if (err) {
 		dst_free(&rt->dst);
-
-		return ERR_CAST(neigh);
+		return ERR_PTR(err);
 	}
-	dst_set_neighbour(&rt->dst, neigh);
 
 	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
-- 
1.7.7.4
