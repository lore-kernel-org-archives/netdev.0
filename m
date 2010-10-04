From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net neigh: RCU conversion of neigh hash table
Date: Mon, 04 Oct 2010 18:15:44 +0200
Message-ID: <1286208944.18293.349.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60439 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237Ab0JDQPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 12:15:49 -0400
Received: by fxm4 with SMTP id 4so38580fxm.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 09:15:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

This is the first step for RCU conversion of neigh code.

Next patches will convert hash_buckets[] and "struct neighbour" to RCU
protected objects.

Thanks

[PATCH net-next] net neigh: RCU conversion of neigh hash table

Instead of storing hash_buckets, hash_mask and hash_rnd in "struct
neigh_table", a new structure is defined :

struct neigh_hash_table {
       struct neighbour        **hash_buckets;
       unsigned int            hash_mask;
       __u32                   hash_rnd;
       struct rcu_head         rcu;
};

And "struct neigh_table" has an RCU protected pointer to such a
neigh_hash_table.

This means the signature of (*hash)() function changed: We need to add a
third parameter with the actual hash_rnd value, since this is not
anymore a neigh_table field.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/neighbour.h |   16 ++
 net/atm/clip.c          |    4 
 net/core/neighbour.c    |  219 +++++++++++++++++++++++---------------
 net/decnet/dn_neigh.c   |   13 +-
 net/ipv4/arp.c          |    8 -
 net/ipv6/ndisc.c        |   10 +
 6 files changed, 170 insertions(+), 100 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 7d08fd1..37845da 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -138,13 +138,22 @@ struct pneigh_entry {
  *	neighbour table manipulation
  */
 
+struct neigh_hash_table {
+	struct neighbour	**hash_buckets;
+	unsigned int		hash_mask;
+	__u32			hash_rnd;
+	struct rcu_head		rcu;
+};
+
 
 struct neigh_table {
 	struct neigh_table	*next;
 	int			family;
 	int			entry_size;
 	int			key_len;
-	__u32			(*hash)(const void *pkey, const struct net_device *);
+	__u32			(*hash)(const void *pkey,
+					const struct net_device *dev,
+					__u32 hash_rnd);
 	int			(*constructor)(struct neighbour *);
 	int			(*pconstructor)(struct pneigh_entry *);
 	void			(*pdestructor)(struct pneigh_entry *);
@@ -165,9 +174,7 @@ struct neigh_table {
 	unsigned long		last_rand;
 	struct kmem_cache	*kmem_cachep;
 	struct neigh_statistics	__percpu *stats;
-	struct neighbour	**hash_buckets;
-	unsigned int		hash_mask;
-	__u32			hash_rnd;
+	struct neigh_hash_table __rcu *nht;
 	struct pneigh_entry	**phash_buckets;
 };
 
@@ -237,6 +244,7 @@ extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pneigh_en
 struct neigh_seq_state {
 	struct seq_net_private p;
 	struct neigh_table *tbl;
+	struct neigh_hash_table *nht;
 	void *(*neigh_sub_iter)(struct neigh_seq_state *state,
 				struct neighbour *n, loff_t *pos);
 	unsigned int bucket;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 95fdd11..ff956d1 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -310,9 +310,9 @@ static int clip_constructor(struct neighbour *neigh)
 	return 0;
 }
 
-static u32 clip_hash(const void *pkey, const struct net_device *dev)
+static u32 clip_hash(const void *pkey, const struct net_device *dev, __u32 rnd)
 {
-	return jhash_2words(*(u32 *) pkey, dev->ifindex, clip_tbl.hash_rnd);
+	return jhash_2words(*(u32 *) pkey, dev->ifindex, rnd);
 }
 
 static struct neigh_table clip_tbl = {
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d6996e0..dd8920e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -131,14 +131,17 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 {
 	int shrunk = 0;
 	int i;
+	struct neigh_hash_table *nht;
 
 	NEIGH_CACHE_STAT_INC(tbl, forced_gc_runs);
 
 	write_lock_bh(&tbl->lock);
-	for (i = 0; i <= tbl->hash_mask; i++) {
+	nht = rcu_dereference_protected(tbl->nht,
+					lockdep_is_held(&tbl->lock));
+	for (i = 0; i <= nht->hash_mask; i++) {
 		struct neighbour *n, **np;
 
-		np = &tbl->hash_buckets[i];
+		np = &nht->hash_buckets[i];
 		while ((n = *np) != NULL) {
 			/* Neighbour record may be discarded if:
 			 * - nobody refers to it.
@@ -199,9 +202,13 @@ static void pneigh_queue_purge(struct sk_buff_head *list)
 static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 {
 	int i;
+	struct neigh_hash_table *nht;
 
-	for (i = 0; i <= tbl->hash_mask; i++) {
-		struct neighbour *n, **np = &tbl->hash_buckets[i];
+	nht = rcu_dereference_protected(tbl->nht,
+					lockdep_is_held(&tbl->lock));
+
+	for (i = 0; i <= nht->hash_mask; i++) {
+		struct neighbour *n, **np = &nht->hash_buckets[i];
 
 		while ((n = *np) != NULL) {
 			if (dev && n->dev != dev) {
@@ -297,64 +304,81 @@ out_entries:
 	goto out;
 }
 
-static struct neighbour **neigh_hash_alloc(unsigned int entries)
+static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
 {
-	unsigned long size = entries * sizeof(struct neighbour *);
-	struct neighbour **ret;
+	size_t size = entries * sizeof(struct neighbour *);
+	struct neigh_hash_table *ret;
+	struct neighbour **buckets;
 
-	if (size <= PAGE_SIZE) {
-		ret = kzalloc(size, GFP_ATOMIC);
-	} else {
-		ret = (struct neighbour **)
-		      __get_free_pages(GFP_ATOMIC|__GFP_ZERO, get_order(size));
+	ret = kmalloc(sizeof(*ret), GFP_ATOMIC);
+	if (!ret)
+		return NULL;
+	if (size <= PAGE_SIZE)
+		buckets = kzalloc(size, GFP_ATOMIC);
+	else
+		buckets = (struct neighbour **)
+			  __get_free_pages(GFP_ATOMIC | __GFP_ZERO,
+					   get_order(size));
+	if (!buckets) {
+		kfree(ret);
+		return NULL;
 	}
+	ret->hash_buckets = buckets;
+	ret->hash_mask = entries - 1;
+	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
 	return ret;
 }
 
-static void neigh_hash_free(struct neighbour **hash, unsigned int entries)
+static void neigh_hash_free_rcu(struct rcu_head *head)
 {
-	unsigned long size = entries * sizeof(struct neighbour *);
+	struct neigh_hash_table *nht = container_of(head,
+						    struct neigh_hash_table,
+						    rcu);
+	size_t size = (nht->hash_mask + 1) * sizeof(struct neighbour *);
+	struct neighbour **buckets = nht->hash_buckets;
 
 	if (size <= PAGE_SIZE)
-		kfree(hash);
+		kfree(buckets);
 	else
-		free_pages((unsigned long)hash, get_order(size));
+		free_pages((unsigned long)buckets, get_order(size));
+	kfree(nht);
 }
 
-static void neigh_hash_grow(struct neigh_table *tbl, unsigned long new_entries)
+static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
+						unsigned long new_entries)
 {
-	struct neighbour **new_hash, **old_hash;
-	unsigned int i, new_hash_mask, old_entries;
+	unsigned int i, hash;
+	struct neigh_hash_table *new_nht, *old_nht;
 
 	NEIGH_CACHE_STAT_INC(tbl, hash_grows);
 
 	BUG_ON(!is_power_of_2(new_entries));
-	new_hash = neigh_hash_alloc(new_entries);
-	if (!new_hash)
-		return;
+	old_nht = rcu_dereference_protected(tbl->nht,
+					    lockdep_is_held(&tbl->lock));
+	new_nht = neigh_hash_alloc(new_entries);
+	if (!new_nht)
+		return old_nht;
 
-	old_entries = tbl->hash_mask + 1;
-	new_hash_mask = new_entries - 1;
-	old_hash = tbl->hash_buckets;
-
-	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
-	for (i = 0; i < old_entries; i++) {
+	for (i = 0; i <= old_nht->hash_mask; i++) {
 		struct neighbour *n, *next;
 
-		for (n = old_hash[i]; n; n = next) {
-			unsigned int hash_val = tbl->hash(n->primary_key, n->dev);
+		for (n = old_nht->hash_buckets[i];
+		     n != NULL;
+		     n = next) {
+			hash = tbl->hash(n->primary_key, n->dev,
+					 new_nht->hash_rnd);
 
-			hash_val &= new_hash_mask;
+			hash &= new_nht->hash_mask;
 			next = n->next;
 
-			n->next = new_hash[hash_val];
-			new_hash[hash_val] = n;
+			n->next = new_nht->hash_buckets[hash];
+			new_nht->hash_buckets[hash] = n;
 		}
 	}
-	tbl->hash_buckets = new_hash;
-	tbl->hash_mask = new_hash_mask;
 
-	neigh_hash_free(old_hash, old_entries);
+	rcu_assign_pointer(tbl->nht, new_nht);
+	call_rcu(&old_nht->rcu, neigh_hash_free_rcu);
+	return new_nht;
 }
 
 struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
@@ -363,19 +387,23 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 	struct neighbour *n;
 	int key_len = tbl->key_len;
 	u32 hash_val;
+	struct neigh_hash_table *nht;
 
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
-	read_lock_bh(&tbl->lock);
-	hash_val = tbl->hash(pkey, dev);
-	for (n = tbl->hash_buckets[hash_val & tbl->hash_mask]; n; n = n->next) {
+	rcu_read_lock_bh();
+	nht = rcu_dereference_bh(tbl->nht);
+	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) & nht->hash_mask;
+	read_lock(&tbl->lock);
+	for (n = nht->hash_buckets[hash_val]; n; n = n->next) {
 		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
 		}
 	}
-	read_unlock_bh(&tbl->lock);
+	read_unlock(&tbl->lock);
+	rcu_read_unlock_bh();
 	return n;
 }
 EXPORT_SYMBOL(neigh_lookup);
@@ -386,12 +414,15 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 	struct neighbour *n;
 	int key_len = tbl->key_len;
 	u32 hash_val;
+	struct neigh_hash_table *nht;
 
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
-	read_lock_bh(&tbl->lock);
-	hash_val = tbl->hash(pkey, NULL);
-	for (n = tbl->hash_buckets[hash_val & tbl->hash_mask]; n; n = n->next) {
+	rcu_read_lock_bh();
+	nht = rcu_dereference_bh(tbl->nht);
+	hash_val = tbl->hash(pkey, NULL, nht->hash_rnd) & nht->hash_mask;
+	read_lock(&tbl->lock);
+	for (n = nht->hash_buckets[hash_val]; n; n = n->next) {
 		if (!memcmp(n->primary_key, pkey, key_len) &&
 		    net_eq(dev_net(n->dev), net)) {
 			neigh_hold(n);
@@ -399,7 +430,8 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 			break;
 		}
 	}
-	read_unlock_bh(&tbl->lock);
+	read_unlock(&tbl->lock);
+	rcu_read_unlock_bh();
 	return n;
 }
 EXPORT_SYMBOL(neigh_lookup_nodev);
@@ -411,6 +443,7 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 	int key_len = tbl->key_len;
 	int error;
 	struct neighbour *n1, *rc, *n = neigh_alloc(tbl);
+	struct neigh_hash_table *nht;
 
 	if (!n) {
 		rc = ERR_PTR(-ENOBUFS);
@@ -437,18 +470,20 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 	n->confirmed = jiffies - (n->parms->base_reachable_time << 1);
 
 	write_lock_bh(&tbl->lock);
+	nht = rcu_dereference_protected(tbl->nht,
+					lockdep_is_held(&tbl->lock));
 
-	if (atomic_read(&tbl->entries) > (tbl->hash_mask + 1))
-		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
+	if (atomic_read(&tbl->entries) > (nht->hash_mask + 1))
+		nht = neigh_hash_grow(tbl, (nht->hash_mask + 1) << 1);
 
-	hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
+	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) & nht->hash_mask;
 
 	if (n->parms->dead) {
 		rc = ERR_PTR(-EINVAL);
 		goto out_tbl_unlock;
 	}
 
-	for (n1 = tbl->hash_buckets[hash_val]; n1; n1 = n1->next) {
+	for (n1 = nht->hash_buckets[hash_val]; n1; n1 = n1->next) {
 		if (dev == n1->dev && !memcmp(n1->primary_key, pkey, key_len)) {
 			neigh_hold(n1);
 			rc = n1;
@@ -456,8 +491,8 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 		}
 	}
 
-	n->next = tbl->hash_buckets[hash_val];
-	tbl->hash_buckets[hash_val] = n;
+	n->next = nht->hash_buckets[hash_val];
+	nht->hash_buckets[hash_val] = n;
 	n->dead = 0;
 	neigh_hold(n);
 	write_unlock_bh(&tbl->lock);
@@ -698,10 +733,13 @@ static void neigh_periodic_work(struct work_struct *work)
 	struct neigh_table *tbl = container_of(work, struct neigh_table, gc_work.work);
 	struct neighbour *n, **np;
 	unsigned int i;
+	struct neigh_hash_table *nht;
 
 	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
 
 	write_lock_bh(&tbl->lock);
+	nht = rcu_dereference_protected(tbl->nht,
+					lockdep_is_held(&tbl->lock));
 
 	/*
 	 *	periodically recompute ReachableTime from random function
@@ -715,8 +753,8 @@ static void neigh_periodic_work(struct work_struct *work)
 				neigh_rand_reach_time(p->base_reachable_time);
 	}
 
-	for (i = 0 ; i <= tbl->hash_mask; i++) {
-		np = &tbl->hash_buckets[i];
+	for (i = 0 ; i <= nht->hash_mask; i++) {
+		np = &nht->hash_buckets[i];
 
 		while ((n = *np) != NULL) {
 			unsigned int state;
@@ -1438,17 +1476,14 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 		panic("cannot create neighbour proc dir entry");
 #endif
 
-	tbl->hash_mask = 1;
-	tbl->hash_buckets = neigh_hash_alloc(tbl->hash_mask + 1);
+	tbl->nht = neigh_hash_alloc(8);
 
 	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
 	tbl->phash_buckets = kzalloc(phsize, GFP_KERNEL);
 
-	if (!tbl->hash_buckets || !tbl->phash_buckets)
+	if (!tbl->nht || !tbl->phash_buckets)
 		panic("cannot allocate neighbour cache hashes");
 
-	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
-
 	rwlock_init(&tbl->lock);
 	INIT_DELAYED_WORK_DEFERRABLE(&tbl->gc_work, neigh_periodic_work);
 	schedule_delayed_work(&tbl->gc_work, tbl->parms.reachable_time);
@@ -1504,8 +1539,8 @@ int neigh_table_clear(struct neigh_table *tbl)
 	}
 	write_unlock(&neigh_tbl_lock);
 
-	neigh_hash_free(tbl->hash_buckets, tbl->hash_mask + 1);
-	tbl->hash_buckets = NULL;
+	call_rcu(&tbl->nht->rcu, neigh_hash_free_rcu);
+	tbl->nht = NULL;
 
 	kfree(tbl->phash_buckets);
 	tbl->phash_buckets = NULL;
@@ -1745,18 +1780,22 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 		unsigned long now = jiffies;
 		unsigned int flush_delta = now - tbl->last_flush;
 		unsigned int rand_delta = now - tbl->last_rand;
-
+		struct neigh_hash_table *nht;
 		struct ndt_config ndc = {
 			.ndtc_key_len		= tbl->key_len,
 			.ndtc_entry_size	= tbl->entry_size,
 			.ndtc_entries		= atomic_read(&tbl->entries),
 			.ndtc_last_flush	= jiffies_to_msecs(flush_delta),
 			.ndtc_last_rand		= jiffies_to_msecs(rand_delta),
-			.ndtc_hash_rnd		= tbl->hash_rnd,
-			.ndtc_hash_mask		= tbl->hash_mask,
 			.ndtc_proxy_qlen	= tbl->proxy_queue.qlen,
 		};
 
+		rcu_read_lock_bh();
+		nht = rcu_dereference_bh(tbl->nht);
+		ndc.ndtc_hash_rnd = nht->hash_rnd;
+		ndc.ndtc_hash_mask = nht->hash_mask;
+		rcu_read_unlock_bh();
+
 		NLA_PUT(skb, NDTA_CONFIG, sizeof(ndc), &ndc);
 	}
 
@@ -2088,14 +2127,18 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 	struct neighbour *n;
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
+	struct neigh_hash_table *nht;
 
-	read_lock_bh(&tbl->lock);
-	for (h = 0; h <= tbl->hash_mask; h++) {
+	rcu_read_lock_bh();
+	nht = rcu_dereference_bh(tbl->nht);
+
+	read_lock(&tbl->lock);
+	for (h = 0; h <= nht->hash_mask; h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
 			s_idx = 0;
-		for (n = tbl->hash_buckets[h], idx = 0; n; n = n->next) {
+		for (n = nht->hash_buckets[h], idx = 0; n; n = n->next) {
 			if (!net_eq(dev_net(n->dev), net))
 				continue;
 			if (idx < s_idx)
@@ -2104,7 +2147,6 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
 					    NLM_F_MULTI) <= 0) {
-				read_unlock_bh(&tbl->lock);
 				rc = -1;
 				goto out;
 			}
@@ -2112,9 +2154,10 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			idx++;
 		}
 	}
-	read_unlock_bh(&tbl->lock);
 	rc = skb->len;
 out:
+	read_unlock(&tbl->lock);
+	rcu_read_unlock_bh();
 	cb->args[1] = h;
 	cb->args[2] = idx;
 	return rc;
@@ -2147,15 +2190,20 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie)
 {
 	int chain;
+	struct neigh_hash_table *nht;
 
-	read_lock_bh(&tbl->lock);
-	for (chain = 0; chain <= tbl->hash_mask; chain++) {
+	rcu_read_lock_bh();
+	nht = rcu_dereference_bh(tbl->nht);
+
+	read_lock(&tbl->lock);
+	for (chain = 0; chain <= nht->hash_mask; chain++) {
 		struct neighbour *n;
 
-		for (n = tbl->hash_buckets[chain]; n; n = n->next)
+		for (n = nht->hash_buckets[chain]; n; n = n->next)
 			cb(n, cookie);
 	}
-	read_unlock_bh(&tbl->lock);
+	read_unlock(&tbl->lock);
+	rcu_read_unlock_bh();
 }
 EXPORT_SYMBOL(neigh_for_each);
 
@@ -2164,11 +2212,14 @@ void __neigh_for_each_release(struct neigh_table *tbl,
 			      int (*cb)(struct neighbour *))
 {
 	int chain;
+	struct neigh_hash_table *nht;
 
-	for (chain = 0; chain <= tbl->hash_mask; chain++) {
+	nht = rcu_dereference_protected(tbl->nht,
+					lockdep_is_held(&tbl->lock));
+	for (chain = 0; chain <= nht->hash_mask; chain++) {
 		struct neighbour *n, **np;
 
-		np = &tbl->hash_buckets[chain];
+		np = &nht->hash_buckets[chain];
 		while ((n = *np) != NULL) {
 			int release;
 
@@ -2193,13 +2244,13 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
 	struct net *net = seq_file_net(seq);
-	struct neigh_table *tbl = state->tbl;
+	struct neigh_hash_table *nht = state->nht;
 	struct neighbour *n = NULL;
 	int bucket = state->bucket;
 
 	state->flags &= ~NEIGH_SEQ_IS_PNEIGH;
-	for (bucket = 0; bucket <= tbl->hash_mask; bucket++) {
-		n = tbl->hash_buckets[bucket];
+	for (bucket = 0; bucket <= nht->hash_mask; bucket++) {
+		n = nht->hash_buckets[bucket];
 
 		while (n) {
 			if (!net_eq(dev_net(n->dev), net))
@@ -2234,7 +2285,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 {
 	struct neigh_seq_state *state = seq->private;
 	struct net *net = seq_file_net(seq);
-	struct neigh_table *tbl = state->tbl;
+	struct neigh_hash_table *nht = state->nht;
 
 	if (state->neigh_sub_iter) {
 		void *v = state->neigh_sub_iter(state, n, pos);
@@ -2265,10 +2316,10 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 		if (n)
 			break;
 
-		if (++state->bucket > tbl->hash_mask)
+		if (++state->bucket > nht->hash_mask)
 			break;
 
-		n = tbl->hash_buckets[state->bucket];
+		n = nht->hash_buckets[state->bucket];
 	}
 
 	if (n && pos)
@@ -2367,6 +2418,7 @@ static void *neigh_get_idx_any(struct seq_file *seq, loff_t *pos)
 
 void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl, unsigned int neigh_seq_flags)
 	__acquires(tbl->lock)
+	__acquires(rcu_bh)
 {
 	struct neigh_seq_state *state = seq->private;
 
@@ -2374,8 +2426,9 @@ void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl
 	state->bucket = 0;
 	state->flags = (neigh_seq_flags & ~NEIGH_SEQ_IS_PNEIGH);
 
-	read_lock_bh(&tbl->lock);
-
+	rcu_read_lock_bh();
+	state->nht = rcu_dereference_bh(tbl->nht);
+	read_lock(&tbl->lock);
 	return *pos ? neigh_get_idx_any(seq, pos) : SEQ_START_TOKEN;
 }
 EXPORT_SYMBOL(neigh_seq_start);
@@ -2409,11 +2462,13 @@ EXPORT_SYMBOL(neigh_seq_next);
 
 void neigh_seq_stop(struct seq_file *seq, void *v)
 	__releases(tbl->lock)
+	__releases(rcu_bh)
 {
 	struct neigh_seq_state *state = seq->private;
 	struct neigh_table *tbl = state->tbl;
 
-	read_unlock_bh(&tbl->lock);
+	read_unlock(&tbl->lock);
+	rcu_read_unlock_bh();
 }
 EXPORT_SYMBOL(neigh_seq_stop);
 
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 0363bb9..a085dbc 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -48,7 +48,6 @@
 #include <net/dn_neigh.h>
 #include <net/dn_route.h>
 
-static u32 dn_neigh_hash(const void *pkey, const struct net_device *dev);
 static int dn_neigh_construct(struct neighbour *);
 static void dn_long_error_report(struct neighbour *, struct sk_buff *);
 static void dn_short_error_report(struct neighbour *, struct sk_buff *);
@@ -93,6 +92,13 @@ static const struct neigh_ops dn_phase3_ops = {
 	.queue_xmit =		dev_queue_xmit
 };
 
+static u32 dn_neigh_hash(const void *pkey,
+			 const struct net_device *dev,
+			 __u32 hash_rnd)
+{
+	return jhash_2words(*(__u16 *)pkey, 0, hash_rnd);
+}
+
 struct neigh_table dn_neigh_table = {
 	.family =			PF_DECnet,
 	.entry_size =			sizeof(struct dn_neigh),
@@ -122,11 +128,6 @@ struct neigh_table dn_neigh_table = {
 	.gc_thresh3 =			1024,
 };
 
-static u32 dn_neigh_hash(const void *pkey, const struct net_device *dev)
-{
-	return jhash_2words(*(__u16 *)pkey, 0, dn_neigh_table.hash_rnd);
-}
-
 static int dn_neigh_construct(struct neighbour *neigh)
 {
 	struct net_device *dev = neigh->dev;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d9031ad..f353095 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -127,7 +127,7 @@ EXPORT_SYMBOL(clip_tbl_hook);
 /*
  *	Interface to generic neighbour cache.
  */
-static u32 arp_hash(const void *pkey, const struct net_device *dev);
+static u32 arp_hash(const void *pkey, const struct net_device *dev, __u32 rnd);
 static int arp_constructor(struct neighbour *neigh);
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb);
 static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb);
@@ -225,9 +225,11 @@ int arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir)
 }
 
 
-static u32 arp_hash(const void *pkey, const struct net_device *dev)
+static u32 arp_hash(const void *pkey,
+		    const struct net_device *dev,
+		    __u32 hash_rnd)
 {
-	return jhash_2words(*(u32 *)pkey, dev->ifindex, arp_tbl.hash_rnd);
+	return jhash_2words(*(u32 *)pkey, dev->ifindex, hash_rnd);
 }
 
 static int arp_constructor(struct neighbour *neigh)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b3dd844..998d6d2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -91,7 +91,9 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 
-static u32 ndisc_hash(const void *pkey, const struct net_device *dev);
+static u32 ndisc_hash(const void *pkey,
+		      const struct net_device *dev,
+		      __u32 rnd);
 static int ndisc_constructor(struct neighbour *neigh);
 static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb);
 static void ndisc_error_report(struct neighbour *neigh, struct sk_buff *skb);
@@ -350,7 +352,9 @@ int ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int d
 
 EXPORT_SYMBOL(ndisc_mc_map);
 
-static u32 ndisc_hash(const void *pkey, const struct net_device *dev)
+static u32 ndisc_hash(const void *pkey,
+		      const struct net_device *dev,
+		      __u32 hash_rnd)
 {
 	const u32 *p32 = pkey;
 	u32 addr_hash, i;
@@ -359,7 +363,7 @@ static u32 ndisc_hash(const void *pkey, const struct net_device *dev)
 	for (i = 0; i < (sizeof(struct in6_addr) / sizeof(u32)); i++)
 		addr_hash ^= *p32++;
 
-	return jhash_2words(addr_hash, dev->ifindex, nd_tbl.hash_rnd);
+	return jhash_2words(addr_hash, dev->ifindex, hash_rnd);
 }
 
 static int ndisc_constructor(struct neighbour *neigh)


