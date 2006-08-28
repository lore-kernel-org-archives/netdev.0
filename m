From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/6] neighbour: convert pneigh hash table to hlist
Date: Mon, 28 Aug 2006 16:07:51 -0700
Message-ID: <20060828230915.373089618@localhost.localdomain>
References: <20060828230748.827712918@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10626 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751580AbWH1XMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:12:30 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=hlist2.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the pneigh_entry table to hlist from list.h
to allow for easier later conversion to RCU.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 include/net/neighbour.h |    6 ++--
 net/core/neighbour.c    |   58 ++++++++++++++++++++++++------------------------
 2 files changed, 33 insertions(+), 31 deletions(-)

--- net-2.6.19.orig/include/net/neighbour.h
+++ net-2.6.19/include/net/neighbour.h
@@ -124,8 +124,8 @@ struct neigh_ops
 
 struct pneigh_entry
 {
-	struct pneigh_entry	*next;
-	struct net_device		*dev;
+	struct hlist_node	hlist;
+	struct net_device	*dev;
 	u8			key[0];
 };
 
@@ -165,7 +165,7 @@ struct neigh_table
 	unsigned int		hash_mask;
 	__u32			hash_rnd;
 	unsigned int		hash_chain_gc;
-	struct pneigh_entry	**phash_buckets;
+	struct hlist_head	*phash_buckets;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry	*pde;
 #endif
--- net-2.6.19.orig/net/core/neighbour.c
+++ net-2.6.19/net/core/neighbour.c
@@ -455,6 +455,7 @@ struct pneigh_entry * pneigh_lookup(stru
 				    struct net_device *dev, int creat)
 {
 	struct pneigh_entry *n;
+	struct hlist_node *tmp;
 	int key_len = tbl->key_len;
 	u32 hash_val = *(u32 *)(pkey + key_len - 4);
 
@@ -465,7 +466,7 @@ struct pneigh_entry * pneigh_lookup(stru
 
 	read_lock_bh(&tbl->lock);
 
-	for (n = tbl->phash_buckets[hash_val]; n; n = n->next) {
+	hlist_for_each_entry(n, tmp, &tbl->phash_buckets[hash_val], hlist) {
 		if (!memcmp(n->key, pkey, key_len) &&
 		    (n->dev == dev || !n->dev)) {
 			read_unlock_bh(&tbl->lock);
@@ -495,8 +496,7 @@ struct pneigh_entry * pneigh_lookup(stru
 	}
 
 	write_lock_bh(&tbl->lock);
-	n->next = tbl->phash_buckets[hash_val];
-	tbl->phash_buckets[hash_val] = n;
+	hlist_add_head(&n->hlist, &tbl->phash_buckets[hash_val]);
 	write_unlock_bh(&tbl->lock);
 out:
 	return n;
@@ -506,7 +506,8 @@ out:
 int pneigh_delete(struct neigh_table *tbl, const void *pkey,
 		  struct net_device *dev)
 {
-	struct pneigh_entry *n, **np;
+	struct pneigh_entry *n;
+	struct hlist_node *tmp;
 	int key_len = tbl->key_len;
 	u32 hash_val = *(u32 *)(pkey + key_len - 4);
 
@@ -516,10 +517,9 @@ int pneigh_delete(struct neigh_table *tb
 	hash_val &= PNEIGH_HASHMASK;
 
 	write_lock_bh(&tbl->lock);
-	for (np = &tbl->phash_buckets[hash_val]; (n = *np) != NULL;
-	     np = &n->next) {
+	hlist_for_each_entry(n, tmp, &tbl->phash_buckets[hash_val], hlist) {
 		if (!memcmp(n->key, pkey, key_len) && n->dev == dev) {
-			*np = n->next;
+			hlist_del(&n->hlist);
 			write_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
 				tbl->pdestructor(n);
@@ -535,22 +535,21 @@ int pneigh_delete(struct neigh_table *tb
 
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 {
-	struct pneigh_entry *n, **np;
 	u32 h;
 
 	for (h = 0; h <= PNEIGH_HASHMASK; h++) {
-		np = &tbl->phash_buckets[h];
-		while ((n = *np) != NULL) {
+		struct pneigh_entry *n;
+		struct hlist_node *tmp, *nxt;
+
+		hlist_for_each_entry_safe(n, tmp, nxt, &tbl->phash_buckets[h], hlist) {
 			if (!dev || n->dev == dev) {
-				*np = n->next;
+				hlist_del(&n->hlist);
 				if (tbl->pdestructor)
 					tbl->pdestructor(n);
 				if (n->dev)
 					dev_put(n->dev);
 				kfree(n);
-				continue;
 			}
-			np = &n->next;
 		}
 	}
 	return -ENOENT;
@@ -1332,7 +1331,6 @@ void neigh_parms_destroy(struct neigh_pa
 void neigh_table_init_no_netlink(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
-	unsigned long phsize;
 
 	atomic_set(&tbl->parms.refcnt, 1);
 	INIT_RCU_HEAD(&tbl->parms.rcu_head);
@@ -1359,8 +1357,8 @@ void neigh_table_init_no_netlink(struct 
 	tbl->hash_mask = 1;
 	tbl->hash_buckets = neigh_hash_alloc(tbl->hash_mask + 1);
 
-	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
-	tbl->phash_buckets = kzalloc(phsize, GFP_KERNEL);
+	tbl->phash_buckets = kcalloc(PNEIGH_HASHMASK + 1, sizeof(struct hlist_head),
+				     GFP_KERNEL);
 
 	if (!tbl->hash_buckets || !tbl->phash_buckets)
 		panic("cannot allocate neighbour cache hashes");
@@ -2188,18 +2186,18 @@ static struct pneigh_entry *pneigh_get_f
 {
 	struct neigh_seq_state *state = seq->private;
 	struct neigh_table *tbl = state->tbl;
-	struct pneigh_entry *pn = NULL;
+	struct hlist_node *pn = NULL;
 	int bucket = state->bucket;
 
 	state->flags |= NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
-		pn = tbl->phash_buckets[bucket];
+		pn = tbl->phash_buckets[bucket].first;
 		if (pn)
 			break;
 	}
 	state->bucket = bucket;
 
-	return pn;
+	return pn ? hlist_entry(pn, struct pneigh_entry, hlist) : NULL;
 }
 
 static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
@@ -2208,20 +2206,24 @@ static struct pneigh_entry *pneigh_get_n
 {
 	struct neigh_seq_state *state = seq->private;
 	struct neigh_table *tbl = state->tbl;
+	struct hlist_node *tmp = &pn->hlist;
 
-	pn = pn->next;
-	while (!pn) {
-		if (++state->bucket > PNEIGH_HASHMASK)
-			break;
-		pn = tbl->phash_buckets[state->bucket];
-		if (pn)
-			break;
+	tmp = tmp->next;
+	if (tmp)
+		goto found;
+
+	while (++state->bucket < PNEIGH_HASHMASK) {
+		tmp = tbl->phash_buckets[state->bucket].first;
+		if (tmp)
+			goto found;
 	}
+	return NULL;
 
-	if (pn && pos)
+found:
+	if (pos)
 		--(*pos);
 
-	return pn;
+	return hlist_entry(tmp, struct pneigh_entry, hlist);
 }
 
 static struct pneigh_entry *pneigh_get_idx(struct seq_file *seq, loff_t *pos)

--
Stephen Hemminger <shemminger@osdl.org>


