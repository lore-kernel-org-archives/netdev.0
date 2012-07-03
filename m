From: David Miller <davem@davemloft.net>
Subject: [PATCH 01/19] ipv4: Make neigh lookups directly in output packet
 path.
Date: Tue, 03 Jul 2012 02:45:51 -0700 (PDT)
Message-ID: <20120703.024551.225805852403806417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab2GCJpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:45:52 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 9A71258411C
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:45:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Do not use the dst cached neigh, we'll be getting rid of that.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h       |   28 +++++++++++++++++++---------
 include/net/neighbour.h |   11 +++++++++--
 net/core/neighbour.c    |   12 +++++++-----
 net/ipv4/ip_output.c    |   12 ++++++++----
 net/ipv4/route.c        |    6 +-----
 5 files changed, 44 insertions(+), 25 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 4a1f3fb..4617d98 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -15,24 +15,34 @@ static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd
 	return val * hash_rnd;
 }
 
-static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32 key)
+static inline struct neighbour *__ipv4_neigh_lookup_noref(struct net_device *dev, u32 key)
 {
-	struct neigh_hash_table *nht;
+	struct neigh_hash_table *nht = rcu_dereference_bh(arp_tbl.nht);
 	struct neighbour *n;
 	u32 hash_val;
 
-	rcu_read_lock_bh();
-	nht = rcu_dereference_bh(arp_tbl.nht);
+	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
+		key = 0;
+
 	hash_val = arp_hashfn(key, dev, nht->hash_rnd[0]) >> (32 - nht->hash_shift);
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
+
+	return NULL;
+}
+
+static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32 key)
+{
+	struct neighbour *n;
+
+	rcu_read_lock_bh();
+	n = __ipv4_neigh_lookup_noref(dev, key);
+	if (n && !atomic_inc_not_zero(&n->refcnt))
+		n = NULL;
 	rcu_read_unlock_bh();
 
 	return n;
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 6cdfeed..e1d18bd 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -202,9 +202,16 @@ extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
 extern struct neighbour *	neigh_lookup_nodev(struct neigh_table *tbl,
 						   struct net *net,
 						   const void *pkey);
-extern struct neighbour *	neigh_create(struct neigh_table *tbl,
+extern struct neighbour *	__neigh_create(struct neigh_table *tbl,
+					       const void *pkey,
+					       struct net_device *dev,
+					       bool want_ref);
+static inline struct neighbour *neigh_create(struct neigh_table *tbl,
 					     const void *pkey,
-					     struct net_device *dev);
+					     struct net_device *dev)
+{
+	return __neigh_create(tbl, pkey, dev, true);
+}
 extern void			neigh_destroy(struct neighbour *neigh);
 extern int			__neigh_event_send(struct neighbour *neigh, struct sk_buff *skb);
 extern int			neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d81d026..a793af9 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -474,8 +474,8 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 }
 EXPORT_SYMBOL(neigh_lookup_nodev);
 
-struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
-			       struct net_device *dev)
+struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
+				 struct net_device *dev, bool want_ref)
 {
 	u32 hash_val;
 	int key_len = tbl->key_len;
@@ -535,14 +535,16 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 	     n1 = rcu_dereference_protected(n1->next,
 			lockdep_is_held(&tbl->lock))) {
 		if (dev == n1->dev && !memcmp(n1->primary_key, pkey, key_len)) {
-			neigh_hold(n1);
+			if (want_ref)
+				neigh_hold(n1);
 			rc = n1;
 			goto out_tbl_unlock;
 		}
 	}
 
 	n->dead = 0;
-	neigh_hold(n);
+	if (want_ref)
+		neigh_hold(n);
 	rcu_assign_pointer(n->next,
 			   rcu_dereference_protected(nht->hash_buckets[hash_val],
 						     lockdep_is_held(&tbl->lock)));
@@ -558,7 +560,7 @@ out_neigh_release:
 	neigh_release(n);
 	goto out;
 }
-EXPORT_SYMBOL(neigh_create);
+EXPORT_SYMBOL(__neigh_create);
 
 static u32 pneigh_hash(const void *pkey, int key_len)
 {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 2630900..6e9a266 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -170,6 +170,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	struct net_device *dev = dst->dev;
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
 	struct neighbour *neigh;
+	u32 nexthop;
 
 	if (rt->rt_type == RTN_MULTICAST) {
 		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUTMCAST, skb->len);
@@ -191,15 +192,18 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		skb = skb2;
 	}
 
-	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(dst);
+	rcu_read_lock_bh();
+	nexthop = rt->rt_gateway ? rt->rt_gateway : ip_hdr(skb)->daddr;
+	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
+	if (unlikely(!neigh))
+		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
 	if (neigh) {
 		int res = neigh_output(neigh, skb);
 
-		rcu_read_unlock();
+		rcu_read_unlock_bh();
 		return res;
 	}
-	rcu_read_unlock();
+	rcu_read_unlock_bh();
 
 	net_dbg_ratelimited("%s: No header cache and no neighbour!\n",
 			    __func__);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6a5afc7..2f40363 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1098,17 +1098,13 @@ static int slow_chain_length(const struct rtable *head)
 
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
-	static const __be32 inaddr_any = 0;
 	struct net_device *dev = dst->dev;
 	const __be32 *pkey = daddr;
 	const struct rtable *rt;
 	struct neighbour *n;
 
 	rt = (const struct rtable *) dst;
-
-	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
-		pkey = &inaddr_any;
-	else if (rt->rt_gateway)
+	if (rt->rt_gateway)
 		pkey = (const __be32 *) &rt->rt_gateway;
 
 	n = __ipv4_neigh_lookup(dev, *(__force u32 *)pkey);
-- 
1.7.10
