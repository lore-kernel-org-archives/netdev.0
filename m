From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 1/2] neigh: Factor out ___neigh_lookup_noref
Date: Tue, 03 Mar 2015 17:10:44 -0600
Message-ID: <87bnk9y8wb.fsf_-_@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41025 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223AbbCCXOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 18:14:19 -0500
In-Reply-To: <87h9u1y8y8.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 03 Mar 2015 17:09:35 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While looking at the mpls code I found myself writing yet another
version of neigh_lookup_noref.  We currently have __ipv4_lookup_noref
and __ipv6_lookup_noref.

So to make my work a little easier and to make it a smidge easier to
verify/maintain the mpls code in the future I stopped and wrote
___neigh_lookup_noref.  Then I rewote __ipv4_lookup_noref and
__ipv6_lookup_noref in terms of this new function.  I tested my new
version by verifying that the same code is generated in
ip_finish_output2 and ip6_finish_output2 where these functions are
inlined.

To get to ___neigh_lookup_noref I added a new neighbour cache table
function key_eq.  So that the static size of the key would be
available.

I also added __neigh_lookup_noref for people who want to to lookup
a neighbour table entry quickly but don't know which neibhgour table
they are going to look up.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/arp.h       | 19 ++++--------------
 include/net/ndisc.h     | 19 +-----------------
 include/net/neighbour.h | 52 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/neighbour.c    | 20 +++++--------------
 net/decnet/dn_neigh.c   |  6 ++++++
 net/ipv4/arp.c          |  9 ++++++++-
 net/ipv6/ndisc.c        |  7 +++++++
 7 files changed, 83 insertions(+), 49 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 21ee1860abbc..5e0f891d476c 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -9,28 +9,17 @@
 
 extern struct neigh_table arp_tbl;
 
-static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
+static inline u32 arp_hashfn(const void *pkey, const struct net_device *dev, u32 *hash_rnd)
 {
+	u32 key = *(const u32 *)pkey;
 	u32 val = key ^ hash32_ptr(dev);
 
-	return val * hash_rnd;
+	return val * hash_rnd[0];
 }
 
 static inline struct neighbour *__ipv4_neigh_lookup_noref(struct net_device *dev, u32 key)
 {
-	struct neigh_hash_table *nht = rcu_dereference_bh(arp_tbl.nht);
-	struct neighbour *n;
-	u32 hash_val;
-
-	hash_val = arp_hashfn(key, dev, nht->hash_rnd[0]) >> (32 - nht->hash_shift);
-	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
-	     n != NULL;
-	     n = rcu_dereference_bh(n->next)) {
-		if (n->dev == dev && *(u32 *)n->primary_key == key)
-			return n;
-	}
-
-	return NULL;
+	return ___neigh_lookup_noref(&arp_tbl, neigh_key_eq32, arp_hashfn, &key, dev);
 }
 
 static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32 key)
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 6bbda34d5e59..b3a7751251b4 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -156,24 +156,7 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
 
 static inline struct neighbour *__ipv6_neigh_lookup_noref(struct net_device *dev, const void *pkey)
 {
-	struct neigh_hash_table *nht;
-	const u32 *p32 = pkey;
-	struct neighbour *n;
-	u32 hash_val;
-
-	nht = rcu_dereference_bh(nd_tbl.nht);
-	hash_val = ndisc_hashfn(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
-	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
-	     n != NULL;
-	     n = rcu_dereference_bh(n->next)) {
-		u32 *n32 = (u32 *) n->primary_key;
-		if (n->dev == dev &&
-		    ((n32[0] ^ p32[0]) | (n32[1] ^ p32[1]) |
-		     (n32[2] ^ p32[2]) | (n32[3] ^ p32[3])) == 0)
-			return n;
-	}
-
-	return NULL;
+	return ___neigh_lookup_noref(&nd_tbl, neigh_key_eq128, ndisc_hashfn, pkey, dev);
 }
 
 static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, const void *pkey)
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 9f912e4d4232..14e3f017966b 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -197,6 +197,7 @@ struct neigh_table {
 	__u32			(*hash)(const void *pkey,
 					const struct net_device *dev,
 					__u32 *hash_rnd);
+	bool			(*key_eq)(const struct neighbour *, const void *pkey);
 	int			(*constructor)(struct neighbour *);
 	int			(*pconstructor)(struct pneigh_entry *);
 	void			(*pdestructor)(struct pneigh_entry *);
@@ -247,6 +248,57 @@ static inline void *neighbour_priv(const struct neighbour *n)
 #define NEIGH_UPDATE_F_ISROUTER			0x40000000
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
+
+static inline bool neigh_key_eq16(const struct neighbour *n, const void *pkey)
+{
+	return *(const u16 *)n->primary_key == *(const u16 *)pkey;
+}
+
+static inline bool neigh_key_eq32(const struct neighbour *n, const void *pkey)
+{
+	return *(const u32 *)n->primary_key == *(const u32 *)pkey;
+}
+
+static inline bool neigh_key_eq128(const struct neighbour *n, const void *pkey)
+{
+	const u32 *n32 = (const u32 *)n->primary_key;
+	const u32 *p32 = pkey;
+
+	return ((n32[0] ^ p32[0]) | (n32[1] ^ p32[1]) |
+		(n32[2] ^ p32[2]) | (n32[3] ^ p32[3])) == 0;
+}
+
+static inline struct neighbour *___neigh_lookup_noref(
+	struct neigh_table *tbl,
+	bool (*key_eq)(const struct neighbour *n, const void *pkey),
+	__u32 (*hash)(const void *pkey,
+		      const struct net_device *dev,
+		      __u32 *hash_rnd),
+	const void *pkey,
+	struct net_device *dev)
+{
+	struct neigh_hash_table *nht = rcu_dereference_bh(tbl->nht);
+	struct neighbour *n;
+	u32 hash_val;
+
+	hash_val = hash(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
+	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
+	     n != NULL;
+	     n = rcu_dereference_bh(n->next)) {
+		if (n->dev == dev && key_eq(n, pkey))
+			return n;
+	}
+
+	return NULL;
+}
+
+static inline struct neighbour *__neigh_lookup_noref(struct neigh_table *tbl,
+						     const void *pkey,
+						     struct net_device *dev)
+{
+	return ___neigh_lookup_noref(tbl, tbl->key_eq, tbl->hash, pkey, dev);
+}
+
 void neigh_table_init(int index, struct neigh_table *tbl);
 int neigh_table_clear(int index, struct neigh_table *tbl);
 struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 0f48ea3affed..fe3c6eac5805 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -397,25 +397,15 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 			       struct net_device *dev)
 {
 	struct neighbour *n;
-	int key_len = tbl->key_len;
-	u32 hash_val;
-	struct neigh_hash_table *nht;
 
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
 	rcu_read_lock_bh();
-	nht = rcu_dereference_bh(tbl->nht);
-	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
-
-	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
-	     n != NULL;
-	     n = rcu_dereference_bh(n->next)) {
-		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
-			if (!atomic_inc_not_zero(&n->refcnt))
-				n = NULL;
-			NEIGH_CACHE_STAT_INC(tbl, hits);
-			break;
-		}
+	n = __neigh_lookup_noref(tbl, pkey, dev);
+	if (n) {
+		if (!atomic_inc_not_zero(&n->refcnt))
+			n = NULL;
+		NEIGH_CACHE_STAT_INC(tbl, hits);
 	}
 
 	rcu_read_unlock_bh();
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index f123c6c6748c..ee7d1cef0027 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -93,12 +93,18 @@ static u32 dn_neigh_hash(const void *pkey,
 	return jhash_2words(*(__u16 *)pkey, 0, hash_rnd[0]);
 }
 
+static bool dn_key_eq(const struct neighbour *neigh, const void *pkey)
+{
+	return neigh_key_eq16(neigh, pkey);
+}
+
 struct neigh_table dn_neigh_table = {
 	.family =			PF_DECnet,
 	.entry_size =			NEIGH_ENTRY_SIZE(sizeof(struct dn_neigh)),
 	.key_len =			sizeof(__le16),
 	.protocol =			cpu_to_be16(ETH_P_DNA_RT),
 	.hash =				dn_neigh_hash,
+	.key_eq =			dn_key_eq,
 	.constructor =			dn_neigh_construct,
 	.id =				"dn_neigh_cache",
 	.parms ={
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 6b8aad6a0d7d..5f5c674e130a 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -122,6 +122,7 @@
  *	Interface to generic neighbour cache.
  */
 static u32 arp_hash(const void *pkey, const struct net_device *dev, __u32 *hash_rnd);
+static bool arp_key_eq(const struct neighbour *n, const void *pkey);
 static int arp_constructor(struct neighbour *neigh);
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb);
 static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb);
@@ -154,6 +155,7 @@ struct neigh_table arp_tbl = {
 	.key_len	= 4,
 	.protocol	= cpu_to_be16(ETH_P_IP),
 	.hash		= arp_hash,
+	.key_eq		= arp_key_eq,
 	.constructor	= arp_constructor,
 	.proxy_redo	= parp_redo,
 	.id		= "arp_cache",
@@ -209,7 +211,12 @@ static u32 arp_hash(const void *pkey,
 		    const struct net_device *dev,
 		    __u32 *hash_rnd)
 {
-	return arp_hashfn(*(u32 *)pkey, dev, *hash_rnd);
+	return arp_hashfn(pkey, dev, hash_rnd);
+}
+
+static bool arp_key_eq(const struct neighbour *neigh, const void *pkey)
+{
+	return neigh_key_eq32(neigh, pkey);
 }
 
 static int arp_constructor(struct neighbour *neigh)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e363bbc2420d..247ad7c298f7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -84,6 +84,7 @@ do {								\
 static u32 ndisc_hash(const void *pkey,
 		      const struct net_device *dev,
 		      __u32 *hash_rnd);
+static bool ndisc_key_eq(const struct neighbour *neigh, const void *pkey);
 static int ndisc_constructor(struct neighbour *neigh);
 static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb);
 static void ndisc_error_report(struct neighbour *neigh, struct sk_buff *skb);
@@ -119,6 +120,7 @@ struct neigh_table nd_tbl = {
 	.key_len =	sizeof(struct in6_addr),
 	.protocol =	cpu_to_be16(ETH_P_IPV6),
 	.hash =		ndisc_hash,
+	.key_eq =	ndisc_key_eq,
 	.constructor =	ndisc_constructor,
 	.pconstructor =	pndisc_constructor,
 	.pdestructor =	pndisc_destructor,
@@ -295,6 +297,11 @@ static u32 ndisc_hash(const void *pkey,
 	return ndisc_hashfn(pkey, dev, hash_rnd);
 }
 
+static bool ndisc_key_eq(const struct neighbour *n, const void *pkey)
+{
+	return neigh_key_eq128(n, pkey);
+}
+
 static int ndisc_constructor(struct neighbour *neigh)
 {
 	struct in6_addr *addr = (struct in6_addr *)&neigh->primary_key;
-- 
2.2.1
