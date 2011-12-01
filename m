From: David Miller <davem@davemloft.net>
Subject: nuclear neigh patch
Date: Thu, 01 Dec 2011 15:20:57 -0500 (EST)
Message-ID: <20111201.152057.981138658170403943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab1LAUVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 15:21:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric, how lucky are you feeling today? :-)

Here is a patch that gets rid of the neighbour reference for ipv4 routes.
Neigh entries are computed at packet send time in ip_output.c

Some minor work is needed before we can flat out use something like this,
the main issue being that there are places that assume that if we have
a 'dst' entry then there is a non-NULL neighbour unconditionally available.
Mainly this happens in the infiniband layer.

So we can't create a situation where dst_get_neighbour() might return NULL
just yet.

This is worth sorting out, because then we can get rid of the neigh
pointer entirely from dst entries.

But anyways, if this patch works it would be interesting to see what
it does to the UDP tests on your test machine(s).

diff --git a/include/net/arp.h b/include/net/arp.h
index 4979af8..41152df 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -15,24 +15,33 @@ static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd
 	return val * hash_rnd;
 }
 
-static inline struct neighbour *__ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, u32 key)
+static inline struct neighbour *__ipv4_neigh_lookup_noref(struct neigh_table *tbl, struct net_device *dev, u32 key)
 {
-	struct neigh_hash_table *nht;
+	struct neigh_hash_table *nht = rcu_dereference_bh(tbl->nht);
 	struct neighbour *n;
 	u32 hash_val;
 
-	rcu_read_lock_bh();
-	nht = rcu_dereference_bh(tbl->nht);
+	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
+		key = 0;
+
 	hash_val = arp_hashfn(key, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
 	     n = rcu_dereference_bh(n->next)) {
-		if (n->dev == dev && *(u32 *)n->primary_key == key) {
-			if (!atomic_inc_not_zero(&n->refcnt))
-				n = NULL;
-			break;
-		}
+		if (n->dev == dev && *(u32 *)n->primary_key == key)
+			return n;
 	}
+	return NULL;
+}
+
+static inline struct neighbour *__ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, u32 key)
+{
+	struct neighbour *n;
+
+	rcu_read_lock_bh();
+	n = __ipv4_neigh_lookup_noref(tbl, dev, key);
+	if (n && !atomic_inc_not_zero(&n->refcnt))
+		n = NULL;
 	rcu_read_unlock_bh();
 
 	return n;
diff --git a/include/net/dst.h b/include/net/dst.h
index 6faec1a..15f0bac 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -86,14 +86,25 @@ struct dst_entry {
 	};
 };
 
+static inline struct neighbour *dst_neigh_lookup(const struct dst_entry *dst)
+{
+	return dst->ops->neigh_lookup(dst);
+}
+
 static inline struct neighbour *dst_get_neighbour(struct dst_entry *dst)
 {
-	return rcu_dereference(dst->_neighbour);
+	struct neighbour *n = rcu_dereference(dst->_neighbour);
+	if (!n)
+		n = dst_neigh_lookup(dst);
+	return n;
 }
 
 static inline struct neighbour *dst_get_neighbour_raw(struct dst_entry *dst)
 {
-	return rcu_dereference_raw(dst->_neighbour);
+	struct neighbour *n = rcu_dereference_raw(dst->_neighbour);
+	if (!n)
+		n =  dst_neigh_lookup(dst);
+	return n;
 }
 
 static inline void dst_set_neighbour(struct dst_entry *dst, struct neighbour *neigh)
@@ -398,11 +409,6 @@ static inline void dst_confirm(struct dst_entry *dst)
 	}
 }
 
-static inline struct neighbour *dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
-{
-	return dst->ops->neigh_lookup(dst, daddr);
-}
-
 static inline void dst_link_failure(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index e1c2ee0..3a03d52 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -26,7 +26,7 @@ struct dst_ops {
 	void			(*link_failure)(struct sk_buff *);
 	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
 	int			(*local_out)(struct sk_buff *skb);
-	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst, const void *daddr);
+	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst);
 
 	struct kmem_cache	*kmem_cachep;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0d5e567..72cc41a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -205,15 +205,15 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		skb = skb2;
 	}
 
-	rcu_read_lock();
-	neigh = dst_get_neighbour(dst);
+	rcu_read_lock_bh();
+	neigh = __ipv4_neigh_lookup_noref(&arp_tbl, dev, rt->rt_gateway);
 	if (neigh) {
 		int res = neigh_output(neigh, skb);
 
-		rcu_read_unlock();
+		rcu_read_unlock_bh();
 		return res;
 	}
-	rcu_read_unlock();
+	rcu_read_unlock_bh();
 
 	if (net_ratelimit())
 		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9a20663..885dc3d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -184,7 +184,7 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
-static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr);
+static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst);
 
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
@@ -1010,30 +1010,16 @@ static int slow_chain_length(const struct rtable *head)
 	return length >> FRACT_BITS;
 }
 
-static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst)
 {
-	static const __be32 inaddr_any = 0;
+	struct rtable *rt = (struct rtable *) dst;
 	struct net_device *dev = dst->dev;
-	const __be32 *pkey = daddr;
 	struct neighbour *n;
 
-	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
-		pkey = &inaddr_any;
-
-	n = __ipv4_neigh_lookup(&arp_tbl, dev, *(__force u32 *)pkey);
+	n = __ipv4_neigh_lookup(&arp_tbl, dev, rt->rt_gateway);
 	if (n)
 		return n;
-	return neigh_create(&arp_tbl, pkey, dev);
-}
-
-static int rt_bind_neighbour(struct rtable *rt)
-{
-	struct neighbour *n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
-	if (IS_ERR(n))
-		return PTR_ERR(n);
-	dst_set_neighbour(&rt->dst, n);
-
-	return 0;
+	return neigh_create(&arp_tbl, &rt->rt_gateway, dev);
 }
 
 static struct rtable *rt_intern_hash(unsigned hash, struct rtable *rt,
@@ -1044,7 +1030,6 @@ static struct rtable *rt_intern_hash(unsigned hash, struct rtable *rt,
 	unsigned long	now;
 	u32 		min_score;
 	int		chain_length;
-	int attempts = !in_softirq();
 
 restart:
 	chain_length = 0;
@@ -1071,17 +1056,6 @@ restart:
 		 */
 
 		rt->dst.flags |= DST_NOCACHE;
-		if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-			int err = rt_bind_neighbour(rt);
-			if (err) {
-				if (net_ratelimit())
-					printk(KERN_WARNING
-					    "Neighbour table failure & not caching routes.\n");
-				ip_rt_put(rt);
-				return ERR_PTR(err);
-			}
-		}
-
 		goto skip_hashing;
 	}
 
@@ -1164,41 +1138,6 @@ restart:
 		}
 	}
 
-	/* Try to bind route to arp only if it is output
-	   route or unicast forwarding path.
-	 */
-	if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-		int err = rt_bind_neighbour(rt);
-		if (err) {
-			spin_unlock_bh(rt_hash_lock_addr(hash));
-
-			if (err != -ENOBUFS) {
-				rt_drop(rt);
-				return ERR_PTR(err);
-			}
-
-			/* Neighbour tables are full and nothing
-			   can be released. Try to shrink route cache,
-			   it is most likely it holds some neighbour records.
-			 */
-			if (attempts-- > 0) {
-				int saved_elasticity = ip_rt_gc_elasticity;
-				int saved_int = ip_rt_gc_min_interval;
-				ip_rt_gc_elasticity	= 1;
-				ip_rt_gc_min_interval	= 0;
-				rt_garbage_collect(&ipv4_dst_ops);
-				ip_rt_gc_min_interval	= saved_int;
-				ip_rt_gc_elasticity	= saved_elasticity;
-				goto restart;
-			}
-
-			if (net_ratelimit())
-				printk(KERN_WARNING "ipv4: Neighbour table overflow.\n");
-			rt_drop(rt);
-			return ERR_PTR(-ENOBUFS);
-		}
-	}
-
 	rt->dst.rt_next = rt_hash_table[hash].chain;
 
 	/*
@@ -1308,7 +1247,7 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 
 	rt->rt_gateway = peer->redirect_learned.a4;
 
-	n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
+	n = ipv4_neigh_lookup(&rt->dst);
 	if (IS_ERR(n))
 		return PTR_ERR(n);
 	old_n = xchg(&rt->dst._neighbour, n);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0e381bb..9723e90 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -132,9 +132,11 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
-static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst)
 {
-	return __neigh_lookup_errno(&nd_tbl, daddr, dst->dev);
+	struct rt6_info *rt = (struct rt6_info *) dst;
+
+	return __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dst->dev);
 }
 
 static struct dst_ops ip6_dst_ops_template = {
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4fce1ce..acac0a7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2389,9 +2389,9 @@ static unsigned int xfrm_mtu(const struct dst_entry *dst)
 	return mtu ? : dst_mtu(dst->path);
 }
 
-static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst)
 {
-	return dst_neigh_lookup(dst->path, daddr);
+	return dst_neigh_lookup(dst->path);
 }
 
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
