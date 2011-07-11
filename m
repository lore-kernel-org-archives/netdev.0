From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] neigh: Store hash shift instead of mask.
Date: Mon, 11 Jul 2011 01:48:41 -0700 (PDT)
Message-ID: <20110711.014841.1004194674075047305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: roland@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757456Ab1GKItA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 04:49:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And mask the hash function result by simply shifting
down the "->hash_shift" most significant bits.

Currently which bits we use is arbitrary since jhash
produces entropy evenly across the whole hash function
result.

But soon we'll be using universal hashing functions,
and in those cases more entropy exists in the higher
bits than the lower bits, because they use multiplies.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/neighbour.h |    2 +-
 net/core/neighbour.c    |   47 +++++++++++++++++++++++------------------------
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 4014b62..6fe8c2c 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -142,7 +142,7 @@ struct pneigh_entry {
 
 struct neigh_hash_table {
 	struct neighbour __rcu	**hash_buckets;
-	unsigned int		hash_mask;
+	unsigned int		hash_shift;
 	__u32			hash_rnd;
 	struct rcu_head		rcu;
 };
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ceb505b..4d5fc94 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -137,7 +137,7 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 	write_lock_bh(&tbl->lock);
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
-	for (i = 0; i <= nht->hash_mask; i++) {
+	for (i = 0; i < (1 << nht->hash_shift); i++) {
 		struct neighbour *n;
 		struct neighbour __rcu **np;
 
@@ -210,7 +210,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 
-	for (i = 0; i <= nht->hash_mask; i++) {
+	for (i = 0; i < (1 << nht->hash_shift); i++) {
 		struct neighbour *n;
 		struct neighbour __rcu **np = &nht->hash_buckets[i];
 
@@ -312,9 +312,9 @@ out_entries:
 	goto out;
 }
 
-static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
+static struct neigh_hash_table *neigh_hash_alloc(unsigned int shift)
 {
-	size_t size = entries * sizeof(struct neighbour *);
+	size_t size = (1 << shift) * sizeof(struct neighbour *);
 	struct neigh_hash_table *ret;
 	struct neighbour __rcu **buckets;
 
@@ -332,7 +332,7 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
 		return NULL;
 	}
 	ret->hash_buckets = buckets;
-	ret->hash_mask = entries - 1;
+	ret->hash_shift = shift;
 	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
 	return ret;
 }
@@ -342,7 +342,7 @@ static void neigh_hash_free_rcu(struct rcu_head *head)
 	struct neigh_hash_table *nht = container_of(head,
 						    struct neigh_hash_table,
 						    rcu);
-	size_t size = (nht->hash_mask + 1) * sizeof(struct neighbour *);
+	size_t size = (1 << nht->hash_shift) * sizeof(struct neighbour *);
 	struct neighbour __rcu **buckets = nht->hash_buckets;
 
 	if (size <= PAGE_SIZE)
@@ -353,21 +353,20 @@ static void neigh_hash_free_rcu(struct rcu_head *head)
 }
 
 static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
-						unsigned long new_entries)
+						unsigned long new_shift)
 {
 	unsigned int i, hash;
 	struct neigh_hash_table *new_nht, *old_nht;
 
 	NEIGH_CACHE_STAT_INC(tbl, hash_grows);
 
-	BUG_ON(!is_power_of_2(new_entries));
 	old_nht = rcu_dereference_protected(tbl->nht,
 					    lockdep_is_held(&tbl->lock));
-	new_nht = neigh_hash_alloc(new_entries);
+	new_nht = neigh_hash_alloc(new_shift);
 	if (!new_nht)
 		return old_nht;
 
-	for (i = 0; i <= old_nht->hash_mask; i++) {
+	for (i = 0; i < (1 << old_nht->hash_shift); i++) {
 		struct neighbour *n, *next;
 
 		for (n = rcu_dereference_protected(old_nht->hash_buckets[i],
@@ -377,7 +376,7 @@ static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
 			hash = tbl->hash(n->primary_key, n->dev,
 					 new_nht->hash_rnd);
 
-			hash &= new_nht->hash_mask;
+			hash >>= (32 - new_nht->hash_shift);
 			next = rcu_dereference_protected(n->next,
 						lockdep_is_held(&tbl->lock));
 
@@ -406,7 +405,7 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
-	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) & nht->hash_mask;
+	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
 
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
@@ -436,7 +435,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
-	hash_val = tbl->hash(pkey, NULL, nht->hash_rnd) & nht->hash_mask;
+	hash_val = tbl->hash(pkey, NULL, nht->hash_rnd) >> (32 - nht->hash_shift);
 
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
@@ -492,10 +491,10 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 
-	if (atomic_read(&tbl->entries) > (nht->hash_mask + 1))
-		nht = neigh_hash_grow(tbl, (nht->hash_mask + 1) << 1);
+	if (atomic_read(&tbl->entries) > (1 << nht->hash_shift))
+		nht = neigh_hash_grow(tbl, nht->hash_shift + 1);
 
-	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) & nht->hash_mask;
+	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
 
 	if (n->parms->dead) {
 		rc = ERR_PTR(-EINVAL);
@@ -784,7 +783,7 @@ static void neigh_periodic_work(struct work_struct *work)
 				neigh_rand_reach_time(p->base_reachable_time);
 	}
 
-	for (i = 0 ; i <= nht->hash_mask; i++) {
+	for (i = 0 ; i < (1 << nht->hash_shift); i++) {
 		np = &nht->hash_buckets[i];
 
 		while ((n = rcu_dereference_protected(*np,
@@ -1540,7 +1539,7 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 		panic("cannot create neighbour proc dir entry");
 #endif
 
-	RCU_INIT_POINTER(tbl->nht, neigh_hash_alloc(8));
+	RCU_INIT_POINTER(tbl->nht, neigh_hash_alloc(3));
 
 	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
 	tbl->phash_buckets = kzalloc(phsize, GFP_KERNEL);
@@ -1857,7 +1856,7 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 		rcu_read_lock_bh();
 		nht = rcu_dereference_bh(tbl->nht);
 		ndc.ndtc_hash_rnd = nht->hash_rnd;
-		ndc.ndtc_hash_mask = nht->hash_mask;
+		ndc.ndtc_hash_mask = ((1 << nht->hash_shift) - 1);
 		rcu_read_unlock_bh();
 
 		NLA_PUT(skb, NDTA_CONFIG, sizeof(ndc), &ndc);
@@ -2200,7 +2199,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 
-	for (h = 0; h <= nht->hash_mask; h++) {
+	for (h = 0; h < (1 << nht->hash_shift); h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
@@ -2264,7 +2263,7 @@ void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void
 	nht = rcu_dereference_bh(tbl->nht);
 
 	read_lock(&tbl->lock); /* avoid resizes */
-	for (chain = 0; chain <= nht->hash_mask; chain++) {
+	for (chain = 0; chain < (1 << nht->hash_shift); chain++) {
 		struct neighbour *n;
 
 		for (n = rcu_dereference_bh(nht->hash_buckets[chain]);
@@ -2286,7 +2285,7 @@ void __neigh_for_each_release(struct neigh_table *tbl,
 
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
-	for (chain = 0; chain <= nht->hash_mask; chain++) {
+	for (chain = 0; chain < (1 << nht->hash_shift); chain++) {
 		struct neighbour *n;
 		struct neighbour __rcu **np;
 
@@ -2323,7 +2322,7 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 	int bucket = state->bucket;
 
 	state->flags &= ~NEIGH_SEQ_IS_PNEIGH;
-	for (bucket = 0; bucket <= nht->hash_mask; bucket++) {
+	for (bucket = 0; bucket < (1 << nht->hash_shift); bucket++) {
 		n = rcu_dereference_bh(nht->hash_buckets[bucket]);
 
 		while (n) {
@@ -2390,7 +2389,7 @@ next:
 		if (n)
 			break;
 
-		if (++state->bucket > nht->hash_mask)
+		if (++state->bucket >= (1 << nht->hash_shift))
 			break;
 
 		n = rcu_dereference_bh(nht->hash_buckets[state->bucket]);
-- 
1.7.6

