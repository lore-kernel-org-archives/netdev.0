From: Bob Copeland <me@bobcopeland.com>
Subject: [PATCH 2/2] mac80211: mesh: convert path table to rhashtable
Date: Wed,  2 Mar 2016 10:09:20 -0500
Message-ID: <1456931360-2846-2-git-send-email-me@bobcopeland.com>
References: <1456931360-2846-1-git-send-email-me@bobcopeland.com>
Cc: linux-wireless@vger.kernel.org, Bob Copeland <me@bobcopeland.com>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:33084 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358AbcCBPJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 10:09:39 -0500
Received: by mail-ig0-f193.google.com with SMTP id hb3so5125101igb.0
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 07:09:39 -0800 (PST)
In-Reply-To: <1456931360-2846-1-git-send-email-me@bobcopeland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the time since the mesh path table was implemented as an
RCU-traversable, dynamically growing hash table, a generic RCU
hashtable implementation was added to the kernel.

Switch the mesh path table over to rhashtable to remove some code
and also gain some features like automatic shrinking.

Cc: Thomas Graf <tgraf@suug.ch>
Cc: netdev@vger.kernel.org
Signed-off-by: Bob Copeland <me@bobcopeland.com>
---
 net/mac80211/ieee80211_i.h  |  11 +-
 net/mac80211/mesh.c         |   6 -
 net/mac80211/mesh.h         |  31 +-
 net/mac80211/mesh_pathtbl.c | 786 ++++++++++++++------------------------------
 4 files changed, 259 insertions(+), 575 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index db7f0dbebc4b..c8945e2d8a86 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -697,17 +697,10 @@ struct ieee80211_if_mesh {
 	/* offset from skb->data while building IE */
 	int meshconf_offset;
 
-	struct mesh_table __rcu *mesh_paths;
-	struct mesh_table __rcu *mpp_paths; /* Store paths for MPP&MAP */
+	struct mesh_table *mesh_paths;
+	struct mesh_table *mpp_paths; /* Store paths for MPP&MAP */
 	int mesh_paths_generation;
 	int mpp_paths_generation;
-
-	/* Protects assignment of the mesh_paths/mpp_paths table
-	 * pointer for resize against reading it for add/delete
-	 * of individual paths.  Pure readers (lookups) just use
-	 * RCU.
-	 */
-	rwlock_t pathtbl_resize_lock;
 };
 
 #ifdef CONFIG_MAC80211_MESH
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index c92af2a7714d..a216c439b6f2 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -1347,12 +1347,6 @@ void ieee80211_mesh_work(struct ieee80211_sub_if_data *sdata)
 		       ifmsh->last_preq + msecs_to_jiffies(ifmsh->mshcfg.dot11MeshHWMPpreqMinInterval)))
 		mesh_path_start_discovery(sdata);
 
-	if (test_and_clear_bit(MESH_WORK_GROW_MPATH_TABLE, &ifmsh->wrkq_flags))
-		mesh_mpath_table_grow(sdata);
-
-	if (test_and_clear_bit(MESH_WORK_GROW_MPP_TABLE, &ifmsh->wrkq_flags))
-		mesh_mpp_table_grow(sdata);
-
 	if (test_and_clear_bit(MESH_WORK_HOUSEKEEPING, &ifmsh->wrkq_flags))
 		ieee80211_mesh_housekeeping(sdata);
 
diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
index f3cc3917e048..cc6854db156e 100644
--- a/net/mac80211/mesh.h
+++ b/net/mac80211/mesh.h
@@ -51,10 +51,6 @@ enum mesh_path_flags {
  *
  *
  * @MESH_WORK_HOUSEKEEPING: run the periodic mesh housekeeping tasks
- * @MESH_WORK_GROW_MPATH_TABLE: the mesh path table is full and needs
- * to grow.
- * @MESH_WORK_GROW_MPP_TABLE: the mesh portals table is full and needs to
- * grow
  * @MESH_WORK_ROOT: the mesh root station needs to send a frame
  * @MESH_WORK_DRIFT_ADJUST: time to compensate for clock drift relative to other
  * mesh nodes
@@ -62,8 +58,6 @@ enum mesh_path_flags {
  */
 enum mesh_deferred_task_flags {
 	MESH_WORK_HOUSEKEEPING,
-	MESH_WORK_GROW_MPATH_TABLE,
-	MESH_WORK_GROW_MPP_TABLE,
 	MESH_WORK_ROOT,
 	MESH_WORK_DRIFT_ADJUST,
 	MESH_WORK_MBSS_CHANGED,
@@ -105,6 +99,7 @@ enum mesh_deferred_task_flags {
 struct mesh_path {
 	u8 dst[ETH_ALEN];
 	u8 mpp[ETH_ALEN];	/* used for MPP or MAP */
+	struct rhash_head rhash;
 	struct hlist_node gate_list;
 	struct ieee80211_sub_if_data *sdata;
 	struct sta_info __rcu *next_hop;
@@ -129,34 +124,17 @@ struct mesh_path {
 /**
  * struct mesh_table
  *
- * @hash_buckets: array of hash buckets of the table
- * @hashwlock: array of locks to protect write operations, one per bucket
- * @hash_mask: 2^size_order - 1, used to compute hash idx
- * @hash_rnd: random value used for hash computations
  * @entries: number of entries in the table
- * @free_node: function to free nodes of the table
- * @copy_node: function to copy nodes of the table
- * @size_order: determines size of the table, there will be 2^size_order hash
- *	buckets
  * @known_gates: list of known mesh gates and their mpaths by the station. The
  * gate's mpath may or may not be resolved and active.
- *
- * rcu_head: RCU head to free the table
+ * @rhash: the rhashtable containing struct mesh_paths, keyed by dest addr
  */
 struct mesh_table {
-	/* Number of buckets will be 2^N */
-	struct hlist_head *hash_buckets;
-	spinlock_t *hashwlock;		/* One per bucket, for add/del */
-	unsigned int hash_mask;		/* (2^size_order) - 1 */
-	__u32 hash_rnd;			/* Used for hash generation */
 	atomic_t entries;		/* Up to MAX_MESH_NEIGHBOURS */
-	void (*free_node) (struct hlist_node *p, bool free_leafs);
-	int (*copy_node) (struct hlist_node *p, struct mesh_table *newtbl);
-	int size_order;
 	struct hlist_head *known_gates;
 	spinlock_t gates_lock;
 
-	struct rcu_head rcu_head;
+	struct rhashtable rhead;
 };
 
 /* Recent multicast cache */
@@ -300,9 +278,6 @@ void mesh_rx_plink_frame(struct ieee80211_sub_if_data *sdata,
 void mesh_sta_cleanup(struct sta_info *sta);
 
 /* Private interfaces */
-/* Mesh tables */
-void mesh_mpath_table_grow(struct ieee80211_sub_if_data *sdata);
-void mesh_mpp_table_grow(struct ieee80211_sub_if_data *sdata);
 /* Mesh paths */
 int mesh_path_error_tx(struct ieee80211_sub_if_data *sdata,
 		       u8 ttl, const u8 *target, u32 target_sn,
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index e4daf4b94eaf..7455397f8c3b 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -18,11 +18,20 @@
 #include "ieee80211_i.h"
 #include "mesh.h"
 
-/* There will be initially 2^INIT_PATHS_SIZE_ORDER buckets */
-#define INIT_PATHS_SIZE_ORDER	2
+static u32 mesh_table_hash(const void *addr, u32 len, u32 seed)
+{
+	/* Use last four bytes of hw addr as hash index */
+	return jhash_1word(*(u32 *)(addr+2), seed);
+}
 
-/* Keep the mean chain length below this constant */
-#define MEAN_CHAIN_LEN		2
+static const struct rhashtable_params mesh_rht_params = {
+	.nelem_hint = 2,
+	.automatic_shrinking = true,
+	.key_len = ETH_ALEN,
+	.key_offset = offsetof(struct mesh_path, dst),
+	.head_offset = offsetof(struct mesh_path, rhash),
+	.hashfn = mesh_table_hash,
+};
 
 static inline bool mpath_expired(struct mesh_path *mpath)
 {
@@ -31,157 +40,47 @@ static inline bool mpath_expired(struct mesh_path *mpath)
 	       !(mpath->flags & MESH_PATH_FIXED);
 }
 
-struct mpath_node {
-	struct hlist_node list;
-	struct rcu_head rcu;
-	/* This indirection allows two different tables to point to the same
-	 * mesh_path structure, useful when resizing
-	 */
-	struct mesh_path *mpath;
-};
-
-static inline struct mesh_table *resize_dereference_paths(
-	struct ieee80211_sub_if_data *sdata,
-	struct mesh_table __rcu *table)
+static void mesh_path_reclaim(struct rcu_head *rp)
 {
-	return rcu_dereference_protected(table,
-		lockdep_is_held(&sdata->u.mesh.pathtbl_resize_lock));
-}
+	struct mesh_path *mpath = container_of(rp, struct mesh_path, rcu);
 
-static inline struct mesh_table *resize_dereference_mesh_paths(
-		struct ieee80211_sub_if_data *sdata)
-{
-	return resize_dereference_paths(sdata, sdata->u.mesh.mesh_paths);
+	del_timer_sync(&mpath->timer);
+	kfree(mpath);
 }
 
-static inline struct mesh_table *resize_dereference_mpp_paths(
-		struct ieee80211_sub_if_data *sdata)
+static void mesh_path_rht_free(void *ptr, void *unused_arg)
 {
-	return resize_dereference_paths(sdata, sdata->u.mesh.mpp_paths);
+	struct mesh_path *mpath = ptr;
+	call_rcu(&mpath->rcu, mesh_path_reclaim);
 }
 
-/*
- * CAREFUL -- "tbl" must not be an expression,
- * in particular not an rcu_dereference(), since
- * it's used twice. So it is illegal to do
- *	for_each_mesh_entry(rcu_dereference(...), ...)
- */
-#define for_each_mesh_entry(tbl, node, i) \
-	for (i = 0; i <= tbl->hash_mask; i++) \
-		hlist_for_each_entry_rcu(node, &tbl->hash_buckets[i], list)
-
-
-static struct mesh_table *mesh_table_alloc(int size_order)
+static struct mesh_table *mesh_table_alloc(void)
 {
-	int i;
 	struct mesh_table *newtbl;
 
 	newtbl = kmalloc(sizeof(struct mesh_table), GFP_ATOMIC);
 	if (!newtbl)
 		return NULL;
 
-	newtbl->hash_buckets = kzalloc(sizeof(struct hlist_head) *
-			(1 << size_order), GFP_ATOMIC);
-
-	if (!newtbl->hash_buckets) {
+	newtbl->known_gates = kzalloc(sizeof(struct hlist_head), GFP_ATOMIC);
+	if (!newtbl->known_gates) {
 		kfree(newtbl);
 		return NULL;
 	}
-
-	newtbl->hashwlock = kmalloc(sizeof(spinlock_t) *
-			(1 << size_order), GFP_ATOMIC);
-	if (!newtbl->hashwlock) {
-		kfree(newtbl->hash_buckets);
-		kfree(newtbl);
-		return NULL;
-	}
-
-	newtbl->size_order = size_order;
-	newtbl->hash_mask = (1 << size_order) - 1;
+	INIT_HLIST_HEAD(newtbl->known_gates);
 	atomic_set(&newtbl->entries,  0);
-	get_random_bytes(&newtbl->hash_rnd,
-			sizeof(newtbl->hash_rnd));
-	for (i = 0; i <= newtbl->hash_mask; i++)
-		spin_lock_init(&newtbl->hashwlock[i]);
 	spin_lock_init(&newtbl->gates_lock);
 
 	return newtbl;
 }
 
-static void __mesh_table_free(struct mesh_table *tbl)
+static void mesh_table_free(struct mesh_table *tbl)
 {
-	kfree(tbl->hash_buckets);
-	kfree(tbl->hashwlock);
+	rhashtable_free_and_destroy(&tbl->rhead,
+				    mesh_path_rht_free, NULL);
 	kfree(tbl);
 }
 
-static void mesh_table_free(struct mesh_table *tbl, bool free_leafs)
-{
-	struct hlist_head *mesh_hash;
-	struct hlist_node *p, *q;
-	struct mesh_path *gate;
-	int i;
-
-	mesh_hash = tbl->hash_buckets;
-	if (free_leafs) {
-		spin_lock_bh(&tbl->gates_lock);
-		hlist_for_each_entry_safe(gate, q,
-					  tbl->known_gates, gate_list)
-			hlist_del(&gate->gate_list);
-		kfree(tbl->known_gates);
-		spin_unlock_bh(&tbl->gates_lock);
-	}
-	for (i = 0; i <= tbl->hash_mask; i++) {
-		spin_lock_bh(&tbl->hashwlock[i]);
-		hlist_for_each_safe(p, q, &mesh_hash[i]) {
-			tbl->free_node(p, free_leafs);
-			atomic_dec(&tbl->entries);
-		}
-		spin_unlock_bh(&tbl->hashwlock[i]);
-	}
-
-	__mesh_table_free(tbl);
-}
-
-static int mesh_table_grow(struct mesh_table *oldtbl,
-			   struct mesh_table *newtbl)
-{
-	struct hlist_head *oldhash;
-	struct hlist_node *p, *q;
-	int i;
-
-	if (atomic_read(&oldtbl->entries)
-			< MEAN_CHAIN_LEN * (oldtbl->hash_mask + 1))
-		return -EAGAIN;
-
-	newtbl->free_node = oldtbl->free_node;
-	newtbl->copy_node = oldtbl->copy_node;
-	newtbl->known_gates = oldtbl->known_gates;
-	atomic_set(&newtbl->entries, atomic_read(&oldtbl->entries));
-
-	oldhash = oldtbl->hash_buckets;
-	for (i = 0; i <= oldtbl->hash_mask; i++)
-		hlist_for_each(p, &oldhash[i])
-			if (oldtbl->copy_node(p, newtbl) < 0)
-				goto errcopy;
-
-	return 0;
-
-errcopy:
-	for (i = 0; i <= newtbl->hash_mask; i++) {
-		hlist_for_each_safe(p, q, &newtbl->hash_buckets[i])
-			oldtbl->free_node(p, 0);
-	}
-	return -ENOMEM;
-}
-
-static u32 mesh_table_hash(const u8 *addr, struct mesh_table *tbl)
-{
-	/* Use last four bytes of hw addr as hash index */
-	return jhash_1word(*(u32 *)(addr+2), tbl->hash_rnd) & tbl->hash_mask;
-}
-
-
 /**
  *
  * mesh_path_assign_nexthop - update mesh path next hop
@@ -324,22 +223,15 @@ static struct mesh_path *mpath_lookup(struct mesh_table *tbl, const u8 *dst,
 				      struct ieee80211_sub_if_data *sdata)
 {
 	struct mesh_path *mpath;
-	struct hlist_head *bucket;
-	struct mpath_node *node;
-
-	bucket = &tbl->hash_buckets[mesh_table_hash(dst, tbl)];
-	hlist_for_each_entry_rcu(node, bucket, list) {
-		mpath = node->mpath;
-		if (ether_addr_equal(dst, mpath->dst)) {
-			if (mpath_expired(mpath)) {
-				spin_lock_bh(&mpath->state_lock);
-				mpath->flags &= ~MESH_PATH_ACTIVE;
-				spin_unlock_bh(&mpath->state_lock);
-			}
-			return mpath;
-		}
+
+	mpath = rhashtable_lookup_fast(&tbl->rhead, dst, mesh_rht_params);
+
+	if (mpath && mpath_expired(mpath)) {
+		spin_lock_bh(&mpath->state_lock);
+		mpath->flags &= ~MESH_PATH_ACTIVE;
+		spin_unlock_bh(&mpath->state_lock);
 	}
-	return NULL;
+	return mpath;
 }
 
 /**
@@ -354,17 +246,52 @@ static struct mesh_path *mpath_lookup(struct mesh_table *tbl, const u8 *dst,
 struct mesh_path *
 mesh_path_lookup(struct ieee80211_sub_if_data *sdata, const u8 *dst)
 {
-	return mpath_lookup(rcu_dereference(sdata->u.mesh.mesh_paths), dst,
-			    sdata);
+	return mpath_lookup(sdata->u.mesh.mesh_paths, dst, sdata);
 }
 
 struct mesh_path *
 mpp_path_lookup(struct ieee80211_sub_if_data *sdata, const u8 *dst)
 {
-	return mpath_lookup(rcu_dereference(sdata->u.mesh.mpp_paths), dst,
-			    sdata);
+	return mpath_lookup(sdata->u.mesh.mpp_paths, dst, sdata);
 }
 
+static struct mesh_path *
+__mesh_path_lookup_by_idx(struct mesh_table *tbl, int idx)
+{
+	int i = 0, ret;
+	struct mesh_path *mpath = NULL;
+	struct rhashtable_iter iter;
+
+	ret = rhashtable_walk_init(&tbl->rhead, &iter, GFP_ATOMIC);
+	if (ret)
+		return NULL;
+
+	ret = rhashtable_walk_start(&iter);
+	if (ret && ret != -EAGAIN)
+		goto err;
+
+	while ((mpath = rhashtable_walk_next(&iter))) {
+		if (IS_ERR(mpath) && PTR_ERR(mpath) == -EAGAIN)
+			continue;
+		if (IS_ERR(mpath))
+			break;
+		if (i++ == idx)
+			break;
+	}
+err:
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
+
+	if (IS_ERR(mpath) || !mpath)
+		return NULL;
+
+	if (mpath_expired(mpath)) {
+		spin_lock_bh(&mpath->state_lock);
+		mpath->flags &= ~MESH_PATH_ACTIVE;
+		spin_unlock_bh(&mpath->state_lock);
+	}
+	return mpath;
+}
 
 /**
  * mesh_path_lookup_by_idx - look up a path in the mesh path table by its index
@@ -378,23 +305,7 @@ mpp_path_lookup(struct ieee80211_sub_if_data *sdata, const u8 *dst)
 struct mesh_path *
 mesh_path_lookup_by_idx(struct ieee80211_sub_if_data *sdata, int idx)
 {
-	struct mesh_table *tbl = rcu_dereference(sdata->u.mesh.mesh_paths);
-	struct mpath_node *node;
-	int i;
-	int j = 0;
-
-	for_each_mesh_entry(tbl, node, i) {
-		if (j++ == idx) {
-			if (mpath_expired(node->mpath)) {
-				spin_lock_bh(&node->mpath->state_lock);
-				node->mpath->flags &= ~MESH_PATH_ACTIVE;
-				spin_unlock_bh(&node->mpath->state_lock);
-			}
-			return node->mpath;
-		}
-	}
-
-	return NULL;
+	return __mesh_path_lookup_by_idx(sdata->u.mesh.mesh_paths, idx);
 }
 
 /**
@@ -409,17 +320,7 @@ mesh_path_lookup_by_idx(struct ieee80211_sub_if_data *sdata, int idx)
 struct mesh_path *
 mpp_path_lookup_by_idx(struct ieee80211_sub_if_data *sdata, int idx)
 {
-	struct mesh_table *tbl = rcu_dereference(sdata->u.mesh.mpp_paths);
-	struct mpath_node *node;
-	int i;
-	int j = 0;
-
-	for_each_mesh_entry(tbl, node, i) {
-		if (j++ == idx)
-			return node->mpath;
-	}
-
-	return NULL;
+	return __mesh_path_lookup_by_idx(sdata->u.mesh.mpp_paths, idx);
 }
 
 /**
@@ -432,7 +333,7 @@ int mesh_path_add_gate(struct mesh_path *mpath)
 	int err;
 
 	rcu_read_lock();
-	tbl = rcu_dereference(mpath->sdata->u.mesh.mesh_paths);
+	tbl = mpath->sdata->u.mesh.mesh_paths;
 
 	spin_lock_bh(&mpath->state_lock);
 	if (mpath->is_gate) {
@@ -526,15 +427,9 @@ struct mesh_path *mesh_path_new(struct ieee80211_sub_if_data *sdata,
 struct mesh_path *mesh_path_add(struct ieee80211_sub_if_data *sdata,
 				const u8 *dst)
 {
-	struct ieee80211_if_mesh *ifmsh = &sdata->u.mesh;
-	struct ieee80211_local *local = sdata->local;
 	struct mesh_table *tbl;
 	struct mesh_path *mpath, *new_mpath;
-	struct mpath_node *node, *new_node;
-	struct hlist_head *bucket;
-	int grow = 0;
-	int err;
-	u32 hash_idx;
+	int ret;
 
 	if (ether_addr_equal(dst, sdata->vif.addr))
 		/* never add ourselves as neighbours */
@@ -546,116 +441,44 @@ struct mesh_path *mesh_path_add(struct ieee80211_sub_if_data *sdata,
 	if (atomic_add_unless(&sdata->u.mesh.mpaths, 1, MESH_MAX_MPATHS) == 0)
 		return ERR_PTR(-ENOSPC);
 
-	read_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	tbl = resize_dereference_mesh_paths(sdata);
-
-	hash_idx = mesh_table_hash(dst, tbl);
-	bucket = &tbl->hash_buckets[hash_idx];
-
-	spin_lock(&tbl->hashwlock[hash_idx]);
-
-	hlist_for_each_entry(node, bucket, list) {
-		mpath = node->mpath;
-		if (ether_addr_equal(dst, mpath->dst))
-			goto found;
-	}
-
-	err = -ENOMEM;
 	new_mpath = mesh_path_new(sdata, dst, GFP_ATOMIC);
 	if (!new_mpath)
-		goto err_path_alloc;
-
-	new_node = kmalloc(sizeof(struct mpath_node), GFP_ATOMIC);
-	if (!new_node)
-		goto err_node_alloc;
-
-	new_node->mpath = new_mpath;
-	hlist_add_head_rcu(&new_node->list, bucket);
-	if (atomic_inc_return(&tbl->entries) >=
-	    MEAN_CHAIN_LEN * (tbl->hash_mask + 1))
-		grow = 1;
-
-	sdata->u.mesh.mesh_paths_generation++;
-
-	if (grow) {
-		set_bit(MESH_WORK_GROW_MPATH_TABLE,  &ifmsh->wrkq_flags);
-		ieee80211_queue_work(&local->hw, &sdata->work);
-	}
-	mpath = new_mpath;
-found:
-	spin_unlock(&tbl->hashwlock[hash_idx]);
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	return mpath;
-
-err_node_alloc:
-	kfree(new_mpath);
-err_path_alloc:
-	atomic_dec(&sdata->u.mesh.mpaths);
-	spin_unlock(&tbl->hashwlock[hash_idx]);
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	return ERR_PTR(err);
-}
-
-static void mesh_table_free_rcu(struct rcu_head *rcu)
-{
-	struct mesh_table *tbl = container_of(rcu, struct mesh_table, rcu_head);
-
-	mesh_table_free(tbl, false);
-}
-
-void mesh_mpath_table_grow(struct ieee80211_sub_if_data *sdata)
-{
-	struct mesh_table *oldtbl, *newtbl;
+		return ERR_PTR(-ENOMEM);
 
-	write_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	oldtbl = resize_dereference_mesh_paths(sdata);
-	newtbl = mesh_table_alloc(oldtbl->size_order + 1);
-	if (!newtbl)
-		goto out;
-	if (mesh_table_grow(oldtbl, newtbl) < 0) {
-		__mesh_table_free(newtbl);
-		goto out;
-	}
-	rcu_assign_pointer(sdata->u.mesh.mesh_paths, newtbl);
+	tbl = sdata->u.mesh.mesh_paths;
+	do {
+		ret = rhashtable_lookup_insert_fast(&tbl->rhead,
+						    &new_mpath->rhash,
+						    mesh_rht_params);
 
-	call_rcu(&oldtbl->rcu_head, mesh_table_free_rcu);
+		if (ret == -EEXIST)
+			mpath = rhashtable_lookup_fast(&tbl->rhead,
+						       dst,
+						       mesh_rht_params);
 
- out:
-	write_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-}
+	} while (unlikely(ret == -EEXIST && !mpath));
 
-void mesh_mpp_table_grow(struct ieee80211_sub_if_data *sdata)
-{
-	struct mesh_table *oldtbl, *newtbl;
+	if (ret && ret != -EEXIST)
+		return ERR_PTR(ret);
 
-	write_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	oldtbl = resize_dereference_mpp_paths(sdata);
-	newtbl = mesh_table_alloc(oldtbl->size_order + 1);
-	if (!newtbl)
-		goto out;
-	if (mesh_table_grow(oldtbl, newtbl) < 0) {
-		__mesh_table_free(newtbl);
-		goto out;
+	/* At this point either new_mpath was added, or we found a
+	 * matching entry already in the table; in the latter case
+	 * free the unnecessary new entry.
+	 */
+	if (ret == -EEXIST) {
+		kfree(new_mpath);
+		new_mpath = mpath;
 	}
-	rcu_assign_pointer(sdata->u.mesh.mpp_paths, newtbl);
-	call_rcu(&oldtbl->rcu_head, mesh_table_free_rcu);
-
- out:
-	write_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
+	sdata->u.mesh.mesh_paths_generation++;
+	return new_mpath;
 }
 
 int mpp_path_add(struct ieee80211_sub_if_data *sdata,
 		 const u8 *dst, const u8 *mpp)
 {
-	struct ieee80211_if_mesh *ifmsh = &sdata->u.mesh;
-	struct ieee80211_local *local = sdata->local;
 	struct mesh_table *tbl;
-	struct mesh_path *mpath, *new_mpath;
-	struct mpath_node *node, *new_node;
-	struct hlist_head *bucket;
-	int grow = 0;
-	int err = 0;
-	u32 hash_idx;
+	struct mesh_path *new_mpath;
+	int ret;
 
 	if (ether_addr_equal(dst, sdata->vif.addr))
 		/* never add ourselves as neighbours */
@@ -664,56 +487,19 @@ int mpp_path_add(struct ieee80211_sub_if_data *sdata,
 	if (is_multicast_ether_addr(dst))
 		return -ENOTSUPP;
 
-	err = -ENOMEM;
 	new_mpath = mesh_path_new(sdata, dst, GFP_ATOMIC);
-	if (!new_mpath)
-		goto err_path_alloc;
 
-	new_node = kmalloc(sizeof(struct mpath_node), GFP_ATOMIC);
-	if (!new_node)
-		goto err_node_alloc;
+	if (!new_mpath)
+		return -ENOMEM;
 
 	memcpy(new_mpath->mpp, mpp, ETH_ALEN);
-	new_node->mpath = new_mpath;
-	read_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	tbl = resize_dereference_mpp_paths(sdata);
-
-	hash_idx = mesh_table_hash(dst, tbl);
-	bucket = &tbl->hash_buckets[hash_idx];
-
-	spin_lock(&tbl->hashwlock[hash_idx]);
-
-	err = -EEXIST;
-	hlist_for_each_entry(node, bucket, list) {
-		mpath = node->mpath;
-		if (ether_addr_equal(dst, mpath->dst))
-			goto err_exists;
-	}
-
-	hlist_add_head_rcu(&new_node->list, bucket);
-	if (atomic_inc_return(&tbl->entries) >=
-	    MEAN_CHAIN_LEN * (tbl->hash_mask + 1))
-		grow = 1;
-
-	spin_unlock(&tbl->hashwlock[hash_idx]);
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
+	tbl = sdata->u.mesh.mpp_paths;
+	ret = rhashtable_lookup_insert_fast(&tbl->rhead,
+					    &new_mpath->rhash,
+					    mesh_rht_params);
 
 	sdata->u.mesh.mpp_paths_generation++;
-
-	if (grow) {
-		set_bit(MESH_WORK_GROW_MPP_TABLE,  &ifmsh->wrkq_flags);
-		ieee80211_queue_work(&local->hw, &sdata->work);
-	}
-	return 0;
-
-err_exists:
-	spin_unlock(&tbl->hashwlock[hash_idx]);
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	kfree(new_node);
-err_node_alloc:
-	kfree(new_mpath);
-err_path_alloc:
-	return err;
+	return ret;
 }
 
 
@@ -727,17 +513,26 @@ err_path_alloc:
  */
 void mesh_plink_broken(struct sta_info *sta)
 {
-	struct mesh_table *tbl;
+	struct ieee80211_sub_if_data *sdata = sta->sdata;
+	struct mesh_table *tbl = sdata->u.mesh.mesh_paths;
 	static const u8 bcast[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 	struct mesh_path *mpath;
-	struct mpath_node *node;
-	struct ieee80211_sub_if_data *sdata = sta->sdata;
-	int i;
+	struct rhashtable_iter iter;
+	int ret;
 
-	rcu_read_lock();
-	tbl = rcu_dereference(sdata->u.mesh.mesh_paths);
-	for_each_mesh_entry(tbl, node, i) {
-		mpath = node->mpath;
+	ret = rhashtable_walk_init(&tbl->rhead, &iter, GFP_ATOMIC);
+	if (ret)
+		return;
+
+	ret = rhashtable_walk_start(&iter);
+	if (ret && ret != -EAGAIN)
+		goto out;
+
+	while ((mpath = rhashtable_walk_next(&iter))) {
+		if (IS_ERR(mpath) && PTR_ERR(mpath) == -EAGAIN)
+			continue;
+		if (IS_ERR(mpath))
+			break;
 		if (rcu_access_pointer(mpath->next_hop) == sta &&
 		    mpath->flags & MESH_PATH_ACTIVE &&
 		    !(mpath->flags & MESH_PATH_FIXED)) {
@@ -751,30 +546,20 @@ void mesh_plink_broken(struct sta_info *sta)
 				WLAN_REASON_MESH_PATH_DEST_UNREACHABLE, bcast);
 		}
 	}
-	rcu_read_unlock();
-}
-
-static void mesh_path_node_reclaim(struct rcu_head *rp)
-{
-	struct mpath_node *node = container_of(rp, struct mpath_node, rcu);
-
-	del_timer_sync(&node->mpath->timer);
-	kfree(node->mpath);
-	kfree(node);
+out:
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
 }
 
-/* needs to be called with the corresponding hashwlock taken */
-static void __mesh_path_del(struct mesh_table *tbl, struct mpath_node *node)
+static void __mesh_path_del(struct mesh_table *tbl, struct mesh_path *mpath)
 {
-	struct mesh_path *mpath = node->mpath;
-	struct ieee80211_sub_if_data *sdata = node->mpath->sdata;
+	struct ieee80211_sub_if_data *sdata = mpath->sdata;
 
+	rhashtable_remove_fast(&tbl->rhead, &mpath->rhash, mesh_rht_params);
 	spin_lock_bh(&mpath->state_lock);
 	mpath->flags |= MESH_PATH_RESOLVING;
-	if (mpath->is_gate)
-		mesh_gate_del(tbl, mpath);
-	hlist_del_rcu(&node->list);
-	call_rcu(&node->rcu, mesh_path_node_reclaim);
+	mesh_gate_del(tbl, mpath);
+	call_rcu(&mpath->rcu, mesh_path_reclaim);
 	spin_unlock_bh(&mpath->state_lock);
 	atomic_dec(&sdata->u.mesh.mpaths);
 	atomic_dec(&tbl->entries);
@@ -794,63 +579,87 @@ static void __mesh_path_del(struct mesh_table *tbl, struct mpath_node *node)
 void mesh_path_flush_by_nexthop(struct sta_info *sta)
 {
 	struct ieee80211_sub_if_data *sdata = sta->sdata;
-	struct mesh_table *tbl;
+	struct mesh_table *tbl = sdata->u.mesh.mesh_paths;
 	struct mesh_path *mpath;
-	struct mpath_node *node;
-	int i;
+	struct rhashtable_iter iter;
+	int ret;
 
-	rcu_read_lock();
-	read_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	tbl = resize_dereference_mesh_paths(sdata);
-	for_each_mesh_entry(tbl, node, i) {
-		mpath = node->mpath;
-		if (rcu_access_pointer(mpath->next_hop) == sta) {
-			spin_lock(&tbl->hashwlock[i]);
-			__mesh_path_del(tbl, node);
-			spin_unlock(&tbl->hashwlock[i]);
-		}
+	ret = rhashtable_walk_init(&tbl->rhead, &iter, GFP_ATOMIC);
+	if (ret)
+		return;
+
+	ret = rhashtable_walk_start(&iter);
+	if (ret && ret != -EAGAIN)
+		goto out;
+
+	while ((mpath = rhashtable_walk_next(&iter))) {
+		if (IS_ERR(mpath) && PTR_ERR(mpath) == -EAGAIN)
+			continue;
+		if (IS_ERR(mpath))
+			break;
+
+		if (rcu_access_pointer(mpath->next_hop) == sta)
+			__mesh_path_del(tbl, mpath);
 	}
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	rcu_read_unlock();
+out:
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
 }
 
 static void mpp_flush_by_proxy(struct ieee80211_sub_if_data *sdata,
 			       const u8 *proxy)
 {
-	struct mesh_table *tbl;
-	struct mesh_path *mpp;
-	struct mpath_node *node;
-	int i;
+	struct mesh_table *tbl = sdata->u.mesh.mpp_paths;
+	struct mesh_path *mpath;
+	struct rhashtable_iter iter;
+	int ret;
 
-	rcu_read_lock();
-	read_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	tbl = resize_dereference_mpp_paths(sdata);
-	for_each_mesh_entry(tbl, node, i) {
-		mpp = node->mpath;
-		if (ether_addr_equal(mpp->mpp, proxy)) {
-			spin_lock(&tbl->hashwlock[i]);
-			__mesh_path_del(tbl, node);
-			spin_unlock(&tbl->hashwlock[i]);
-		}
+	ret = rhashtable_walk_init(&tbl->rhead, &iter, GFP_ATOMIC);
+	if (ret)
+		return;
+
+	ret = rhashtable_walk_start(&iter);
+	if (ret && ret != -EAGAIN)
+		goto out;
+
+	while ((mpath = rhashtable_walk_next(&iter))) {
+		if (IS_ERR(mpath) && PTR_ERR(mpath) == -EAGAIN)
+			continue;
+		if (IS_ERR(mpath))
+			break;
+
+		if (ether_addr_equal(mpath->mpp, proxy))
+			__mesh_path_del(tbl, mpath);
 	}
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	rcu_read_unlock();
+out:
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
 }
 
-static void table_flush_by_iface(struct mesh_table *tbl,
-				 struct ieee80211_sub_if_data *sdata)
+static void table_flush_by_iface(struct mesh_table *tbl)
 {
 	struct mesh_path *mpath;
-	struct mpath_node *node;
-	int i;
-
-	WARN_ON(!rcu_read_lock_held());
-	for_each_mesh_entry(tbl, node, i) {
-		mpath = node->mpath;
-		spin_lock_bh(&tbl->hashwlock[i]);
-		__mesh_path_del(tbl, node);
-		spin_unlock_bh(&tbl->hashwlock[i]);
+	struct rhashtable_iter iter;
+	int ret;
+
+	ret = rhashtable_walk_init(&tbl->rhead, &iter, GFP_ATOMIC);
+	if (ret)
+		return;
+
+	ret = rhashtable_walk_start(&iter);
+	if (ret && ret != -EAGAIN)
+		goto out;
+
+	while ((mpath = rhashtable_walk_next(&iter))) {
+		if (IS_ERR(mpath) && PTR_ERR(mpath) == -EAGAIN)
+			continue;
+		if (IS_ERR(mpath))
+			break;
+		__mesh_path_del(tbl, mpath);
 	}
+out:
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
 }
 
 /**
@@ -863,16 +672,8 @@ static void table_flush_by_iface(struct mesh_table *tbl,
  */
 void mesh_path_flush_by_iface(struct ieee80211_sub_if_data *sdata)
 {
-	struct mesh_table *tbl;
-
-	rcu_read_lock();
-	read_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	tbl = resize_dereference_mesh_paths(sdata);
-	table_flush_by_iface(tbl, sdata);
-	tbl = resize_dereference_mpp_paths(sdata);
-	table_flush_by_iface(tbl, sdata);
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	rcu_read_unlock();
+	table_flush_by_iface(sdata->u.mesh.mesh_paths);
+	table_flush_by_iface(sdata->u.mesh.mpp_paths);
 }
 
 /**
@@ -884,36 +685,25 @@ void mesh_path_flush_by_iface(struct ieee80211_sub_if_data *sdata)
  *
  * Returns: 0 if successful
  */
-static int table_path_del(struct mesh_table __rcu *rcu_tbl,
+static int table_path_del(struct mesh_table *tbl,
 			  struct ieee80211_sub_if_data *sdata,
 			  const u8 *addr)
 {
-	struct mesh_table *tbl;
 	struct mesh_path *mpath;
-	struct mpath_node *node;
-	struct hlist_head *bucket;
-	int hash_idx;
-	int err = 0;
-
-	tbl = resize_dereference_paths(sdata, rcu_tbl);
-	hash_idx = mesh_table_hash(addr, tbl);
-	bucket = &tbl->hash_buckets[hash_idx];
-
-	spin_lock(&tbl->hashwlock[hash_idx]);
-	hlist_for_each_entry(node, bucket, list) {
-		mpath = node->mpath;
-		if (ether_addr_equal(addr, mpath->dst)) {
-			__mesh_path_del(tbl, node);
-			goto enddel;
-		}
+
+	rcu_read_lock();
+	mpath = rhashtable_lookup_fast(&tbl->rhead, addr, mesh_rht_params);
+	if (!mpath) {
+		rcu_read_unlock();
+		return -ENXIO;
 	}
 
-	err = -ENXIO;
-enddel:
-	spin_unlock(&tbl->hashwlock[hash_idx]);
-	return err;
+	__mesh_path_del(tbl, mpath);
+	rcu_read_unlock();
+	return 0;
 }
 
+
 /**
  * mesh_path_del - delete a mesh path from the table
  *
@@ -924,36 +714,13 @@ enddel:
  */
 int mesh_path_del(struct ieee80211_sub_if_data *sdata, const u8 *addr)
 {
-	int err = 0;
+	int err;
 
 	/* flush relevant mpp entries first */
 	mpp_flush_by_proxy(sdata, addr);
 
-	read_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
 	err = table_path_del(sdata->u.mesh.mesh_paths, sdata, addr);
 	sdata->u.mesh.mesh_paths_generation++;
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-
-	return err;
-}
-
-/**
- * mpp_path_del - delete a mesh proxy path from the table
- *
- * @addr: addr address (ETH_ALEN length)
- * @sdata: local subif
- *
- * Returns: 0 if successful
- */
-static int mpp_path_del(struct ieee80211_sub_if_data *sdata, const u8 *addr)
-{
-	int err = 0;
-
-	read_lock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-	err = table_path_del(sdata->u.mesh.mpp_paths, sdata, addr);
-	sdata->u.mesh.mpp_paths_generation++;
-	read_unlock_bh(&sdata->u.mesh.pathtbl_resize_lock);
-
 	return err;
 }
 
@@ -987,18 +754,17 @@ int mesh_path_send_to_gates(struct mesh_path *mpath)
 	struct ieee80211_sub_if_data *sdata = mpath->sdata;
 	struct mesh_table *tbl;
 	struct mesh_path *from_mpath = mpath;
-	struct mesh_path *gate = NULL;
+	struct mesh_path *gate;
 	bool copy = false;
 	struct hlist_head *known_gates;
 
-	rcu_read_lock();
-	tbl = rcu_dereference(sdata->u.mesh.mesh_paths);
+	tbl = sdata->u.mesh.mesh_paths;
 	known_gates = tbl->known_gates;
-	rcu_read_unlock();
 
 	if (!known_gates)
 		return -EHOSTUNREACH;
 
+	rcu_read_lock();
 	hlist_for_each_entry_rcu(gate, known_gates, gate_list) {
 		if (gate->flags & MESH_PATH_ACTIVE) {
 			mpath_dbg(sdata, "Forwarding to %pM\n", gate->dst);
@@ -1016,6 +782,7 @@ int mesh_path_send_to_gates(struct mesh_path *mpath)
 		mpath_dbg(sdata, "Sending to %pM\n", gate->dst);
 		mesh_path_tx_pending(gate);
 	}
+	rcu_read_unlock();
 
 	return (from_mpath == mpath) ? -EHOSTUNREACH : 0;
 }
@@ -1072,118 +839,73 @@ void mesh_path_fix_nexthop(struct mesh_path *mpath, struct sta_info *next_hop)
 	mesh_path_tx_pending(mpath);
 }
 
-static void mesh_path_node_free(struct hlist_node *p, bool free_leafs)
-{
-	struct mesh_path *mpath;
-	struct mpath_node *node = hlist_entry(p, struct mpath_node, list);
-	mpath = node->mpath;
-	hlist_del_rcu(p);
-	if (free_leafs) {
-		del_timer_sync(&mpath->timer);
-		kfree(mpath);
-	}
-	kfree(node);
-}
-
-static int mesh_path_node_copy(struct hlist_node *p, struct mesh_table *newtbl)
-{
-	struct mesh_path *mpath;
-	struct mpath_node *node, *new_node;
-	u32 hash_idx;
-
-	new_node = kmalloc(sizeof(struct mpath_node), GFP_ATOMIC);
-	if (new_node == NULL)
-		return -ENOMEM;
-
-	node = hlist_entry(p, struct mpath_node, list);
-	mpath = node->mpath;
-	new_node->mpath = mpath;
-	hash_idx = mesh_table_hash(mpath->dst, newtbl);
-	hlist_add_head(&new_node->list,
-			&newtbl->hash_buckets[hash_idx]);
-	return 0;
-}
-
 int mesh_pathtbl_init(struct ieee80211_sub_if_data *sdata)
 {
 	struct mesh_table *tbl_path, *tbl_mpp;
 	int ret;
 
-	tbl_path = mesh_table_alloc(INIT_PATHS_SIZE_ORDER);
+	tbl_path = mesh_table_alloc();
 	if (!tbl_path)
 		return -ENOMEM;
-	tbl_path->free_node = &mesh_path_node_free;
-	tbl_path->copy_node = &mesh_path_node_copy;
-	tbl_path->known_gates = kzalloc(sizeof(struct hlist_head), GFP_ATOMIC);
-	if (!tbl_path->known_gates) {
-		ret = -ENOMEM;
-		goto free_path;
-	}
-	INIT_HLIST_HEAD(tbl_path->known_gates);
 
-
-	tbl_mpp = mesh_table_alloc(INIT_PATHS_SIZE_ORDER);
+	tbl_mpp = mesh_table_alloc();
 	if (!tbl_mpp) {
 		ret = -ENOMEM;
 		goto free_path;
 	}
-	tbl_mpp->free_node = &mesh_path_node_free;
-	tbl_mpp->copy_node = &mesh_path_node_copy;
-	tbl_mpp->known_gates = kzalloc(sizeof(struct hlist_head), GFP_ATOMIC);
-	if (!tbl_mpp->known_gates) {
-		ret = -ENOMEM;
-		goto free_mpp;
-	}
-	INIT_HLIST_HEAD(tbl_mpp->known_gates);
 
-	rwlock_init(&sdata->u.mesh.pathtbl_resize_lock);
+	rhashtable_init(&tbl_path->rhead, &mesh_rht_params);
+	rhashtable_init(&tbl_mpp->rhead, &mesh_rht_params);
 
-	/* Need no locking since this is during init */
-	RCU_INIT_POINTER(sdata->u.mesh.mesh_paths, tbl_path);
-	RCU_INIT_POINTER(sdata->u.mesh.mpp_paths, tbl_mpp);
+	sdata->u.mesh.mesh_paths = tbl_path;
+	sdata->u.mesh.mpp_paths = tbl_mpp;
 
 	return 0;
 
-free_mpp:
-	mesh_table_free(tbl_mpp, true);
 free_path:
-	mesh_table_free(tbl_path, true);
+	mesh_table_free(tbl_path);
 	return ret;
 }
 
-void mesh_path_expire(struct ieee80211_sub_if_data *sdata)
+static
+void mesh_path_tbl_expire(struct ieee80211_sub_if_data *sdata,
+			  struct mesh_table *tbl)
 {
-	struct mesh_table *tbl;
 	struct mesh_path *mpath;
-	struct mpath_node *node;
-	int i;
+	struct rhashtable_iter iter;
+	int ret;
 
-	rcu_read_lock();
-	tbl = rcu_dereference(sdata->u.mesh.mesh_paths);
-	for_each_mesh_entry(tbl, node, i) {
-		mpath = node->mpath;
+	ret = rhashtable_walk_init(&tbl->rhead, &iter, GFP_KERNEL);
+	if (ret)
+		return;
+
+	ret = rhashtable_walk_start(&iter);
+	if (ret && ret != -EAGAIN)
+		goto out;
+
+	while ((mpath = rhashtable_walk_next(&iter))) {
+		if (IS_ERR(mpath) && PTR_ERR(mpath) == -EAGAIN)
+			continue;
+		if (IS_ERR(mpath))
+			break;
 		if ((!(mpath->flags & MESH_PATH_RESOLVING)) &&
 		    (!(mpath->flags & MESH_PATH_FIXED)) &&
 		     time_after(jiffies, mpath->exp_time + MESH_PATH_EXPIRE))
-			mesh_path_del(sdata, mpath->dst);
-	}
-
-	tbl = rcu_dereference(sdata->u.mesh.mpp_paths);
-	for_each_mesh_entry(tbl, node, i) {
-		mpath = node->mpath;
-		if ((!(mpath->flags & MESH_PATH_FIXED)) &&
-		    time_after(jiffies, mpath->exp_time + MESH_PATH_EXPIRE))
-			mpp_path_del(sdata, mpath->dst);
+			__mesh_path_del(tbl, mpath);
 	}
+out:
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
+}
 
-	rcu_read_unlock();
+void mesh_path_expire(struct ieee80211_sub_if_data *sdata)
+{
+	mesh_path_tbl_expire(sdata, sdata->u.mesh.mesh_paths);
+	mesh_path_tbl_expire(sdata, sdata->u.mesh.mpp_paths);
 }
 
 void mesh_pathtbl_unregister(struct ieee80211_sub_if_data *sdata)
 {
-	/* no need for locking during exit path */
-	mesh_table_free(rcu_dereference_protected(sdata->u.mesh.mesh_paths, 1),
-			true);
-	mesh_table_free(rcu_dereference_protected(sdata->u.mesh.mpp_paths, 1),
-			true);
+	mesh_table_free(sdata->u.mesh.mesh_paths);
+	mesh_table_free(sdata->u.mesh.mpp_paths);
 }
-- 
2.6.1
