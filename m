From: "David S. Miller" <davem@davemloft.net>
Subject: [5/6]: Dynamic neigh hash table growth
Date: Thu, 23 Sep 2004 22:51:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923225127.10b0ef68.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This implements dynamic growth of neigh tbl->hash_buckets[]
which is extremely simple now that all the accesses sit
in one file.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 17:31:14-07:00 davem@nuts.davemloft.net 
#   [NET]: Grow neigh hash table dynamically.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/neighbour.c
#   2004/09/23 17:30:42-07:00 davem@nuts.davemloft.net +82 -18
#   [NET]: Grow neigh hash table dynamically.
# 
# include/net/neighbour.h
#   2004/09/23 17:30:42-07:00 davem@nuts.davemloft.net +1 -0
#   [NET]: Grow neigh hash table dynamically.
# 
diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-23 22:26:58 -07:00
+++ b/include/net/neighbour.h	2004-09-23 22:26:58 -07:00
@@ -174,6 +174,7 @@
 	kmem_cache_t		*kmem_cachep;
 	struct neigh_statistics	stats;
 	struct neighbour	**hash_buckets;
+	unsigned int		hash_mask;
 	struct pneigh_entry	**phash_buckets;
 };
 
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-23 22:26:58 -07:00
+++ b/net/core/neighbour.c	2004-09-23 22:26:58 -07:00
@@ -47,7 +47,6 @@
 #define NEIGH_PRINTK2 NEIGH_PRINTK
 #endif
 
-#define NEIGH_HASHMASK		0x1F
 #define PNEIGH_HASHMASK		0xF
 
 static void neigh_timer_handler(unsigned long arg);
@@ -116,7 +115,7 @@
 	int shrunk = 0;
 	int i;
 
-	for (i = 0; i <= NEIGH_HASHMASK; i++) {
+	for (i = 0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
@@ -180,7 +179,7 @@
 
 	write_lock_bh(&tbl->lock);
 
-	for (i=0; i <= NEIGH_HASHMASK; i++) {
+	for (i=0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
@@ -207,7 +206,7 @@
 
 	write_lock_bh(&tbl->lock);
 
-	for (i = 0; i <= NEIGH_HASHMASK; i++) {
+	for (i = 0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n, **np = &tbl->hash_buckets[i];
 
 		while ((n = *np) != NULL) {
@@ -289,12 +288,75 @@
 	return n;
 }
 
+static struct neighbour **neigh_hash_alloc(unsigned int entries)
+{
+	unsigned long size = entries * sizeof(struct neighbour *);
+	struct neighbour **ret;
+
+	if (size <= PAGE_SIZE) {
+		ret = kmalloc(size, GFP_KERNEL);
+	} else {
+		ret = (struct neighbour **)
+			__get_free_pages(GFP_KERNEL, get_order(size));
+	}
+	if (ret)
+		memset(ret, 0, size);
+
+	return ret;
+}
+
+static void neigh_hash_free(struct neighbour **hash, unsigned int entries)
+{
+	unsigned long size = entries * sizeof(struct neighbour *);
+
+	if (size <= PAGE_SIZE)
+		kfree(hash);
+	else
+		free_pages((unsigned long)hash, get_order(size));
+}
+
+static void neigh_hash_grow(struct neigh_table *tbl, unsigned long new_entries)
+{
+	struct neighbour **new_hash, **old_hash;
+	unsigned int i, new_hash_mask, old_entries;
+
+	BUG_ON(new_entries & (new_entries - 1));
+	new_hash = neigh_hash_alloc(new_entries);
+	if (!new_hash)
+		return;
+
+	old_entries = tbl->hash_mask + 1;
+	new_hash_mask = new_entries - 1;
+	old_hash = tbl->hash_buckets;
+
+	write_lock_bh(&tbl->lock);
+	for (i = 0; i < old_entries; i++) {
+		struct neighbour *n, *next;
+
+		next = NULL;
+		for (n = old_hash[i]; n; n = next) {
+			unsigned int hash_val = tbl->hash(n->primary_key, n->dev);
+
+			hash_val &= new_hash_mask;
+			next = n->next;
+
+			n->next = new_hash[hash_val];
+			new_hash[hash_val] = n;
+		}
+	}
+	tbl->hash_buckets = new_hash;
+	tbl->hash_mask = new_hash_mask;
+	write_unlock_bh(&tbl->lock);
+
+	neigh_hash_free(old_hash, old_entries);
+}
+
 struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 			       struct net_device *dev)
 {
 	struct neighbour *n;
 	int key_len = tbl->key_len;
-	u32 hash_val = tbl->hash(pkey, dev) & NEIGH_HASHMASK;
+	u32 hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
 
 	read_lock_bh(&tbl->lock);
 	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
@@ -311,7 +373,7 @@
 {
 	struct neighbour *n;
 	int key_len = tbl->key_len;
-	u32 hash_val = tbl->hash(pkey, NULL) & NEIGH_HASHMASK;
+	u32 hash_val = tbl->hash(pkey, NULL) & tbl->hash_mask;
 
 	read_lock_bh(&tbl->lock);
 	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
@@ -337,6 +399,9 @@
 		goto out;
 	}
 
+	if (tbl->entries > (tbl->hash_mask + 1))
+		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
+
 	memcpy(n->primary_key, pkey, key_len);
 	n->dev = dev;
 	dev_hold(dev);
@@ -356,7 +421,7 @@
 
 	n->confirmed = jiffies - (n->parms->base_reachable_time << 1);
 
-	hash_val = tbl->hash(pkey, dev) & NEIGH_HASHMASK;
+	hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
 
 	write_lock_bh(&tbl->lock);
 	if (n->parms->dead) {
@@ -583,7 +648,7 @@
 				neigh_rand_reach_time(p->base_reachable_time);
 	}
 
-	for (i = 0; i <= NEIGH_HASHMASK; i++) {
+	for (i = 0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
@@ -1225,7 +1290,7 @@
 void neigh_table_init(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
-	unsigned long hsize, phsize;
+	unsigned long phsize;
 
 	atomic_set(&tbl->parms.refcnt, 1);
 	INIT_RCU_HEAD(&tbl->parms.rcu_head);
@@ -1241,8 +1306,8 @@
 	if (!tbl->kmem_cachep)
 		panic("cannot create neighbour cache");
 
-	hsize = (NEIGH_HASHMASK + 1) * sizeof(struct neighbour *);
-	tbl->hash_buckets = kmalloc(hsize, GFP_KERNEL);
+	tbl->hash_mask = 0x1f;
+	tbl->hash_buckets = neigh_hash_alloc(tbl->hash_mask + 1);
 
 	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
 	tbl->phash_buckets = kmalloc(phsize, GFP_KERNEL);
@@ -1250,7 +1315,6 @@
 	if (!tbl->hash_buckets || !tbl->phash_buckets)
 		panic("cannot allocate neighbour cache hashes");
 
-	memset(tbl->hash_buckets, 0, hsize);
 	memset(tbl->phash_buckets, 0, phsize);
 
 	tbl->lock	       = RW_LOCK_UNLOCKED;
@@ -1294,7 +1358,7 @@
 	}
 	write_unlock(&neigh_tbl_lock);
 
-	kfree(tbl->hash_buckets);
+	neigh_hash_free(tbl->hash_buckets, tbl->hash_mask + 1);
 	tbl->hash_buckets = NULL;
 
 	kfree(tbl->phash_buckets);
@@ -1479,7 +1543,7 @@
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
 
-	for (h = 0; h <= NEIGH_HASHMASK; h++) {
+	for (h = 0; h <= tbl->hash_mask; h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
@@ -1534,7 +1598,7 @@
 	int chain;
 
 	read_lock_bh(&tbl->lock);
-	for (chain = 0; chain <= NEIGH_HASHMASK; chain++) {
+	for (chain = 0; chain <= tbl->hash_mask; chain++) {
 		struct neighbour *n;
 
 		for (n = tbl->hash_buckets[chain]; n; n = n->next)
@@ -1550,7 +1614,7 @@
 {
 	int chain;
 
-	for (chain = 0; chain <= NEIGH_HASHMASK; chain++) {
+	for (chain = 0; chain <= tbl->hash_mask; chain++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[chain];
@@ -1582,7 +1646,7 @@
 	int bucket = state->bucket;
 
 	state->flags &= ~NEIGH_SEQ_IS_PNEIGH;
-	for (bucket = 0; bucket <= NEIGH_HASHMASK; bucket++) {
+	for (bucket = 0; bucket <= tbl->hash_mask; bucket++) {
 		n = tbl->hash_buckets[bucket];
 
 		while (n) {
@@ -1644,7 +1708,7 @@
 		if (n)
 			break;
 
-		if (++state->bucket > NEIGH_HASHMASK)
+		if (++state->bucket > tbl->hash_mask)
 			break;
 
 		n = tbl->hash_buckets[state->bucket];
