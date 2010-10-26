From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] fib_hash: fix rcu sparse and logical errors
Date: Tue, 26 Oct 2010 15:24:16 +0200
Message-ID: <1288099456.3169.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:40970 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab0JZNYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 09:24:21 -0400
Received: by wwi18 with SMTP id 18so251589wwi.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 06:24:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While fixing CONFIG_SPARSE_RCU_POINTER errors, I had to fix accesses to
fz->fz_hash for real.

-	&fz->fz_hash[fn_hash(f->fn_key, fz)]
+	rcu_dereference(fz->fz_hash) + fn_hash(f->fn_key, fz)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_hash.c |   36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 43e1c59..b232375 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -120,11 +120,12 @@ static inline void fn_rebuild_zone(struct fn_zone *fz,
 		struct fib_node *f;
 
 		hlist_for_each_entry_safe(f, node, n, &old_ht[i], fn_hash) {
-			struct hlist_head __rcu *new_head;
+			struct hlist_head *new_head;
 
 			hlist_del_rcu(&f->fn_hash);
 
-			new_head = &fz->fz_hash[fn_hash(f->fn_key, fz)];
+			new_head = rcu_dereference_protected(fz->fz_hash, 1) +
+				   fn_hash(f->fn_key, fz);
 			hlist_add_head_rcu(&f->fn_hash, new_head);
 		}
 	}
@@ -179,8 +180,8 @@ static void fn_rehash_zone(struct fn_zone *fz)
 		memcpy(&nfz, fz, sizeof(nfz));
 
 		write_seqlock_bh(&fz->fz_lock);
-		old_ht = fz->fz_hash;
-		nfz.fz_hash = ht;
+		old_ht = rcu_dereference_protected(fz->fz_hash, 1);
+		RCU_INIT_POINTER(nfz.fz_hash, ht);
 		nfz.fz_hashmask = new_hashmask;
 		nfz.fz_divisor = new_divisor;
 		fn_rebuild_zone(&nfz, old_ht, old_divisor);
@@ -236,7 +237,7 @@ fn_new_zone(struct fn_hash *table, int z)
 	seqlock_init(&fz->fz_lock);
 	fz->fz_divisor = z ? EMBEDDED_HASH_SIZE : 1;
 	fz->fz_hashmask = fz->fz_divisor - 1;
-	fz->fz_hash = fz->fz_embedded_hash;
+	RCU_INIT_POINTER(fz->fz_hash, fz->fz_embedded_hash);
 	fz->fz_order = z;
 	fz->fz_revorder = 32 - z;
 	fz->fz_mask = inet_make_mask(z);
@@ -272,7 +273,7 @@ int fib_table_lookup(struct fib_table *tb,
 	for (fz = rcu_dereference(t->fn_zone_list);
 	     fz != NULL;
 	     fz = rcu_dereference(fz->fz_next)) {
-		struct hlist_head __rcu *head;
+		struct hlist_head *head;
 		struct hlist_node *node;
 		struct fib_node *f;
 		__be32 k;
@@ -282,7 +283,7 @@ int fib_table_lookup(struct fib_table *tb,
 			seq = read_seqbegin(&fz->fz_lock);
 			k = fz_key(flp->fl4_dst, fz);
 
-			head = &fz->fz_hash[fn_hash(k, fz)];
+			head = rcu_dereference(fz->fz_hash) + fn_hash(k, fz);
 			hlist_for_each_entry_rcu(f, node, head, fn_hash) {
 				if (f->fn_key != k)
 					continue;
@@ -311,6 +312,7 @@ void fib_table_select_default(struct fib_table *tb,
 	struct fib_info *last_resort;
 	struct fn_hash *t = (struct fn_hash *)tb->tb_data;
 	struct fn_zone *fz = t->fn_zones[0];
+	struct hlist_head *head;
 
 	if (fz == NULL)
 		return;
@@ -320,7 +322,8 @@ void fib_table_select_default(struct fib_table *tb,
 	order = -1;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(f, node, &fz->fz_hash[0], fn_hash) {
+	head = rcu_dereference(fz->fz_hash);
+	hlist_for_each_entry_rcu(f, node, head, fn_hash) {
 		struct fib_alias *fa;
 
 		list_for_each_entry_rcu(fa, &f->fn_alias, fa_list) {
@@ -374,7 +377,7 @@ out:
 /* Insert node F to FZ. */
 static inline void fib_insert_node(struct fn_zone *fz, struct fib_node *f)
 {
-	struct hlist_head *head = &fz->fz_hash[fn_hash(f->fn_key, fz)];
+	struct hlist_head *head = rtnl_dereference(fz->fz_hash) + fn_hash(f->fn_key, fz);
 
 	hlist_add_head_rcu(&f->fn_hash, head);
 }
@@ -382,7 +385,7 @@ static inline void fib_insert_node(struct fn_zone *fz, struct fib_node *f)
 /* Return the node in FZ matching KEY. */
 static struct fib_node *fib_find_node(struct fn_zone *fz, __be32 key)
 {
-	struct hlist_head *head = &fz->fz_hash[fn_hash(key, fz)];
+	struct hlist_head *head = rtnl_dereference(fz->fz_hash) + fn_hash(key, fz);
 	struct hlist_node *node;
 	struct fib_node *f;
 
@@ -662,7 +665,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 
 static int fn_flush_list(struct fn_zone *fz, int idx)
 {
-	struct hlist_head *head = &fz->fz_hash[idx];
+	struct hlist_head *head = rtnl_dereference(fz->fz_hash) + idx;
 	struct hlist_node *node, *n;
 	struct fib_node *f;
 	int found = 0;
@@ -761,14 +764,15 @@ fn_hash_dump_zone(struct sk_buff *skb, struct netlink_callback *cb,
 		   struct fn_zone *fz)
 {
 	int h, s_h;
+	struct hlist_head *head = rcu_dereference(fz->fz_hash);
 
-	if (fz->fz_hash == NULL)
+	if (head == NULL)
 		return skb->len;
 	s_h = cb->args[3];
 	for (h = s_h; h < fz->fz_divisor; h++) {
-		if (hlist_empty(&fz->fz_hash[h]))
+		if (hlist_empty(head + h))
 			continue;
-		if (fn_hash_dump_bucket(skb, cb, tb, fz, &fz->fz_hash[h]) < 0) {
+		if (fn_hash_dump_bucket(skb, cb, tb, fz, head + h) < 0) {
 			cb->args[3] = h;
 			return -1;
 		}
@@ -872,7 +876,7 @@ static struct fib_alias *fib_get_first(struct seq_file *seq)
 		if (!iter->zone->fz_nent)
 			continue;
 
-		iter->hash_head = iter->zone->fz_hash;
+		iter->hash_head = rcu_dereference(iter->zone->fz_hash);
 		maxslot = iter->zone->fz_divisor;
 
 		for (iter->bucket = 0; iter->bucket < maxslot;
@@ -957,7 +961,7 @@ static struct fib_alias *fib_get_next(struct seq_file *seq)
 			goto out;
 
 		iter->bucket = 0;
-		iter->hash_head = iter->zone->fz_hash;
+		iter->hash_head = rcu_dereference(iter->zone->fz_hash);
 
 		hlist_for_each_entry(fn, node, iter->hash_head, fn_hash) {
 			list_for_each_entry(fa, &fn->fn_alias, fa_list) {


