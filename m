From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Use universal hash for NDISC.
Date: Wed, 28 Dec 2011 15:14:49 -0500 (EST)
Message-ID: <20111228.151449.565478155723952140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339Ab1L1UPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 15:15:04 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBSKF0c1024040
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 12:15:02 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In order to perform a proper universal hash on a vector of integers,
we have to use different universal hashes on each vector element.

Which means we need 4 different hash randoms for ipv6.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next

 include/net/arp.h       |    2 +-
 include/net/ndisc.h     |    9 +++++++++
 include/net/neighbour.h |    6 ++++--
 net/core/neighbour.c    |   13 ++++++++++---
 net/decnet/dn_neigh.c   |    4 ++--
 net/ipv4/arp.c          |    6 +++---
 net/ipv6/ndisc.c        |   13 +++----------
 7 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 4979af8..0013dc8 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -23,7 +23,7 @@ static inline struct neighbour *__ipv4_neigh_lookup(struct neigh_table *tbl, str
 
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
-	hash_val = arp_hashfn(key, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
+	hash_val = arp_hashfn(key, dev, nht->hash_rnd[0]) >> (32 - nht->hash_shift);
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
 	     n = rcu_dereference_bh(n->next)) {
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index c977c37..e9c3002 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -79,6 +79,15 @@ struct nd_opt_hdr {
 	__u8		nd_opt_len;
 } __packed;
 
+static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, __u32 *hash_rnd)
+{
+	const u32 *p32 = pkey;
+
+	return (((p32[0] ^ dev->ifindex) * hash_rnd[0]) +
+		(p32[1] * hash_rnd[1]) +
+		(p32[2] * hash_rnd[2]) +
+		(p32[3] * hash_rnd[3]));
+}
 
 extern int			ndisc_init(void);
 
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index e31f0a8..34c996f 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -139,10 +139,12 @@ struct pneigh_entry {
  *	neighbour table manipulation
  */
 
+#define NEIGH_NUM_HASH_RND	4
+
 struct neigh_hash_table {
 	struct neighbour __rcu	**hash_buckets;
 	unsigned int		hash_shift;
-	__u32			hash_rnd;
+	__u32			hash_rnd[NEIGH_NUM_HASH_RND];
 	struct rcu_head		rcu;
 };
 
@@ -154,7 +156,7 @@ struct neigh_table {
 	int			key_len;
 	__u32			(*hash)(const void *pkey,
 					const struct net_device *dev,
-					__u32 hash_rnd);
+					__u32 *hash_rnd);
 	int			(*constructor)(struct neighbour *);
 	int			(*pconstructor)(struct pneigh_entry *);
 	void			(*pdestructor)(struct pneigh_entry *);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 4af151e..e287346 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -322,11 +322,18 @@ out_entries:
 	goto out;
 }
 
+static void neigh_get_hash_rnd(u32 *x)
+{
+	get_random_bytes(x, sizeof(*x));
+	*x |= 1;
+}
+
 static struct neigh_hash_table *neigh_hash_alloc(unsigned int shift)
 {
 	size_t size = (1 << shift) * sizeof(struct neighbour *);
 	struct neigh_hash_table *ret;
 	struct neighbour __rcu **buckets;
+	int i;
 
 	ret = kmalloc(sizeof(*ret), GFP_ATOMIC);
 	if (!ret)
@@ -343,8 +350,8 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int shift)
 	}
 	ret->hash_buckets = buckets;
 	ret->hash_shift = shift;
-	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
-	ret->hash_rnd |= 1;
+	for (i = 0; i < NEIGH_NUM_HASH_RND; i++)
+		neigh_get_hash_rnd(&ret->hash_rnd[i]);
 	return ret;
 }
 
@@ -1828,7 +1835,7 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 
 		rcu_read_lock_bh();
 		nht = rcu_dereference_bh(tbl->nht);
-		ndc.ndtc_hash_rnd = nht->hash_rnd;
+		ndc.ndtc_hash_rnd = nht->hash_rnd[0];
 		ndc.ndtc_hash_mask = ((1 << nht->hash_shift) - 1);
 		rcu_read_unlock_bh();
 
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 7d2fff2..befe426 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -88,9 +88,9 @@ static const struct neigh_ops dn_phase3_ops = {
 
 static u32 dn_neigh_hash(const void *pkey,
 			 const struct net_device *dev,
-			 __u32 hash_rnd)
+			 __u32 *hash_rnd)
 {
-	return jhash_2words(*(__u16 *)pkey, 0, hash_rnd);
+	return jhash_2words(*(__u16 *)pkey, 0, hash_rnd[0]);
 }
 
 struct neigh_table dn_neigh_table = {
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 381a087..59402be 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -121,7 +121,7 @@
 /*
  *	Interface to generic neighbour cache.
  */
-static u32 arp_hash(const void *pkey, const struct net_device *dev, __u32 rnd);
+static u32 arp_hash(const void *pkey, const struct net_device *dev, __u32 *hash_rnd);
 static int arp_constructor(struct neighbour *neigh);
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb);
 static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb);
@@ -215,9 +215,9 @@ int arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir)
 
 static u32 arp_hash(const void *pkey,
 		    const struct net_device *dev,
-		    __u32 hash_rnd)
+		    __u32 *hash_rnd)
 {
-	return arp_hashfn(*(u32 *)pkey, dev, hash_rnd);
+	return arp_hashfn(*(u32 *)pkey, dev, *hash_rnd);
 }
 
 static int arp_constructor(struct neighbour *neigh)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f3e50c2..538a619 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -93,7 +93,7 @@
 
 static u32 ndisc_hash(const void *pkey,
 		      const struct net_device *dev,
-		      __u32 rnd);
+		      __u32 *hash_rnd);
 static int ndisc_constructor(struct neighbour *neigh);
 static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb);
 static void ndisc_error_report(struct neighbour *neigh, struct sk_buff *skb);
@@ -349,16 +349,9 @@ EXPORT_SYMBOL(ndisc_mc_map);
 
 static u32 ndisc_hash(const void *pkey,
 		      const struct net_device *dev,
-		      __u32 hash_rnd)
+		      __u32 *hash_rnd)
 {
-	const u32 *p32 = pkey;
-	u32 addr_hash, i;
-
-	addr_hash = 0;
-	for (i = 0; i < (sizeof(struct in6_addr) / sizeof(u32)); i++)
-		addr_hash ^= *p32++;
-
-	return jhash_2words(addr_hash, dev->ifindex, hash_rnd);
+	return ndisc_hashfn(pkey, dev, hash_rnd);
 }
 
 static int ndisc_constructor(struct neighbour *neigh)
-- 
1.7.7.4
