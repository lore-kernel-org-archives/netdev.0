From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 3/3] fib_hash: RCU conversion  phase 2
Date: Fri, 15 Oct 2010 08:56:39 +0200
Message-ID: <1287125799.2659.1845.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48273 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756163Ab0JOG5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 02:57:01 -0400
Received: by wwj40 with SMTP id 40so617079wwj.1
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 23:56:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of fib_hash_lock rwlock.

The fn_zone hash table resize is the noticeable part of this patch.

I added a seqlock per fn_zone, so that readers can restart their lookup
in the (very rare) case a writer expanded the hash table.

Add rcu heads in fib_alias and fib_node, use call_rcu() to defer their
freeing, and use appropriate _rcu list manipulations.

Stress test (160.000.000 udp frames sent, IP route cache disabled to
mimic DDOS attack, FIB_HASH)

Before:
real	0m41.191s
user	0m13.137s
sys	8m55.241s

After:
real	0m38.091s
user	0m13.189s
sys	7m53.018s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_hash.c   |  176 ++++++++++++++++++++++------------------
 net/ipv4/fib_lookup.h |    2 
 2 files changed, 101 insertions(+), 77 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 04f05a9..4f1aafd 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -58,7 +58,8 @@ struct fib_node {
 
 struct fn_zone {
 	struct fn_zone __rcu	*fz_next;	/* Next not empty zone	*/
-	struct hlist_head	*fz_hash;	/* Hash table pointer	*/
+	struct hlist_head __rcu	*fz_hash;	/* Hash table pointer	*/
+	seqlock_t		fz_lock;
 	u32			fz_hashmask;	/* (fz_divisor - 1)	*/
 
 	u8			fz_order;	/* Zone order (0..32)	*/
@@ -92,7 +93,6 @@ static inline __be32 fz_key(__be32 dst, struct fn_zone *fz)
 	return dst & FZ_MASK(fz);
 }
 
-static DEFINE_RWLOCK(fib_hash_lock);
 static unsigned int fib_hash_genid;
 
 #define FZ_MAX_DIVISOR ((PAGE_SIZE<<MAX_ORDER) / sizeof(struct hlist_head))
@@ -101,12 +101,11 @@ static struct hlist_head *fz_hash_alloc(int divisor)
 {
 	unsigned long size = divisor * sizeof(struct hlist_head);
 
-	if (size <= PAGE_SIZE) {
+	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
-	} else {
-		return (struct hlist_head *)
-			__get_free_pages(GFP_KERNEL | __GFP_ZERO, get_order(size));
-	}
+
+	return (struct hlist_head *)
+		__get_free_pages(GFP_KERNEL | __GFP_ZERO, get_order(size));
 }
 
 /* The fib hash lock must be held when this is called. */
@@ -121,12 +120,12 @@ static inline void fn_rebuild_zone(struct fn_zone *fz,
 		struct fib_node *f;
 
 		hlist_for_each_entry_safe(f, node, n, &old_ht[i], fn_hash) {
-			struct hlist_head *new_head;
+			struct hlist_head __rcu *new_head;
 
-			hlist_del(&f->fn_hash);
+			hlist_del_rcu(&f->fn_hash);
 
 			new_head = &fz->fz_hash[fn_hash(f->fn_key, fz)];
-			hlist_add_head(&f->fn_hash, new_head);
+			hlist_add_head_rcu(&f->fn_hash, new_head);
 		}
 	}
 }
@@ -175,32 +174,55 @@ static void fn_rehash_zone(struct fn_zone *fz)
 	ht = fz_hash_alloc(new_divisor);
 
 	if (ht)	{
-		write_lock_bh(&fib_hash_lock);
+		struct fn_zone nfz;
+
+		memcpy(&nfz, fz, sizeof(nfz));
+
+		write_seqlock_bh(&fz->fz_lock);
 		old_ht = fz->fz_hash;
-		fz->fz_hash = ht;
+		nfz.fz_hash = ht;
+		nfz.fz_hashmask = new_hashmask;
+		nfz.fz_divisor = new_divisor;
+		fn_rebuild_zone(&nfz, old_ht, old_divisor);
+		fib_hash_genid++;
+		rcu_assign_pointer(fz->fz_hash, ht);
 		fz->fz_hashmask = new_hashmask;
 		fz->fz_divisor = new_divisor;
-		fn_rebuild_zone(fz, old_ht, old_divisor);
-		fib_hash_genid++;
-		write_unlock_bh(&fib_hash_lock);
+		write_sequnlock_bh(&fz->fz_lock);
 
-		if (old_ht != fz->fz_embedded_hash)
+		if (old_ht != fz->fz_embedded_hash) {
+			synchronize_rcu();
 			fz_hash_free(old_ht, old_divisor);
+		}
 	}
 }
 
-static inline void fn_free_node(struct fib_node * f)
+static void fn_free_node_rcu(struct rcu_head *head)
 {
+	struct fib_node *f = container_of(head, struct fib_node, fn_embedded_alias.rcu);
+
 	kmem_cache_free(fn_hash_kmem, f);
 }
 
+static inline void fn_free_node(struct fib_node *f)
+{
+	call_rcu(&f->fn_embedded_alias.rcu, fn_free_node_rcu);
+}
+
+static void fn_free_alias_rcu(struct rcu_head *head)
+{
+	struct fib_alias *fa = container_of(head, struct fib_alias, rcu);
+
+	kmem_cache_free(fn_alias_kmem, fa);
+}
+
 static inline void fn_free_alias(struct fib_alias *fa, struct fib_node *f)
 {
 	fib_release_info(fa->fa_info);
 	if (fa == &f->fn_embedded_alias)
 		fa->fa_info = NULL;
 	else
-		kmem_cache_free(fn_alias_kmem, fa);
+		call_rcu(&fa->rcu, fn_free_alias_rcu);
 }
 
 static struct fn_zone *
@@ -211,6 +233,7 @@ fn_new_zone(struct fn_hash *table, int z)
 	if (!fz)
 		return NULL;
 
+	seqlock_init(&fz->fz_lock);
 	fz->fz_divisor = z ? EMBEDDED_HASH_SIZE : 1;
 	fz->fz_hashmask = fz->fz_divisor - 1;
 	fz->fz_hash = fz->fz_embedded_hash;
@@ -246,30 +269,34 @@ int fib_table_lookup(struct fib_table *tb,
 	struct fn_hash *t = (struct fn_hash *)tb->tb_data;
 
 	rcu_read_lock();
-	read_lock(&fib_hash_lock);
 	for (fz = rcu_dereference(t->fn_zone_list);
 	     fz != NULL;
 	     fz = rcu_dereference(fz->fz_next)) {
-		struct hlist_head *head;
+		struct hlist_head __rcu *head;
 		struct hlist_node *node;
 		struct fib_node *f;
-		__be32 k = fz_key(flp->fl4_dst, fz);
+		__be32 k;
+		unsigned int seq;
 
-		head = &fz->fz_hash[fn_hash(k, fz)];
-		hlist_for_each_entry(f, node, head, fn_hash) {
-			if (f->fn_key != k)
-				continue;
+		do {
+			seq = read_seqbegin(&fz->fz_lock);
+			k = fz_key(flp->fl4_dst, fz);
+
+			head = &fz->fz_hash[fn_hash(k, fz)];
+			hlist_for_each_entry_rcu(f, node, head, fn_hash) {
+				if (f->fn_key != k)
+					continue;
 
-			err = fib_semantic_match(&f->fn_alias,
+				err = fib_semantic_match(&f->fn_alias,
 						 flp, res,
 						 fz->fz_order, fib_flags);
-			if (err <= 0)
-				goto out;
-		}
+				if (err <= 0)
+					goto out;
+			}
+		} while (read_seqretry(&fz->fz_lock, seq));
 	}
 	err = 1;
 out:
-	read_unlock(&fib_hash_lock);
 	rcu_read_unlock();
 	return err;
 }
@@ -292,11 +319,11 @@ void fib_table_select_default(struct fib_table *tb,
 	last_resort = NULL;
 	order = -1;
 
-	read_lock(&fib_hash_lock);
-	hlist_for_each_entry(f, node, &fz->fz_hash[0], fn_hash) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(f, node, &fz->fz_hash[0], fn_hash) {
 		struct fib_alias *fa;
 
-		list_for_each_entry(fa, &f->fn_alias, fa_list) {
+		list_for_each_entry_rcu(fa, &f->fn_alias, fa_list) {
 			struct fib_info *next_fi = fa->fa_info;
 
 			if (fa->fa_scope != res->scope ||
@@ -340,7 +367,7 @@ void fib_table_select_default(struct fib_table *tb,
 		fib_result_assign(res, last_resort);
 	tb->tb_default = last_idx;
 out:
-	read_unlock(&fib_hash_lock);
+	rcu_read_unlock();
 }
 
 /* Insert node F to FZ. */
@@ -348,7 +375,7 @@ static inline void fib_insert_node(struct fn_zone *fz, struct fib_node *f)
 {
 	struct hlist_head *head = &fz->fz_hash[fn_hash(f->fn_key, fz)];
 
-	hlist_add_head(&f->fn_hash, head);
+	hlist_add_head_rcu(&f->fn_hash, head);
 }
 
 /* Return the node in FZ matching KEY. */
@@ -358,7 +385,7 @@ static struct fib_node *fib_find_node(struct fn_zone *fz, __be32 key)
 	struct hlist_node *node;
 	struct fib_node *f;
 
-	hlist_for_each_entry(f, node, head, fn_hash) {
+	hlist_for_each_entry_rcu(f, node, head, fn_hash) {
 		if (f->fn_key == key)
 			return f;
 	}
@@ -366,6 +393,16 @@ static struct fib_node *fib_find_node(struct fn_zone *fz, __be32 key)
 	return NULL;
 }
 
+
+static struct fib_alias *fib_fast_alloc(struct fib_node *f)
+{
+	struct fib_alias *fa = &f->fn_embedded_alias;
+
+	if (fa->fa_info != NULL)
+		fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
+	return fa;
+}
+
 /* Caller must hold RTNL. */
 int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
@@ -451,7 +488,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		}
 
 		if (cfg->fc_nlflags & NLM_F_REPLACE) {
-			struct fib_info *fi_drop;
 			u8 state;
 
 			fa = fa_first;
@@ -460,21 +496,25 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 					err = 0;
 				goto out;
 			}
-			write_lock_bh(&fib_hash_lock);
-			fi_drop = fa->fa_info;
-			fa->fa_info = fi;
-			fa->fa_type = cfg->fc_type;
-			fa->fa_scope = cfg->fc_scope;
+			err = -ENOBUFS;
+			new_fa = fib_fast_alloc(f);
+			if (new_fa == NULL)
+				goto out;
+
+			new_fa->fa_tos = fa->fa_tos;
+			new_fa->fa_info = fi;
+			new_fa->fa_type = cfg->fc_type;
+			new_fa->fa_scope = cfg->fc_scope;
 			state = fa->fa_state;
-			fa->fa_state &= ~FA_S_ACCESSED;
+			new_fa->fa_state = state & ~FA_S_ACCESSED;
 			fib_hash_genid++;
-			write_unlock_bh(&fib_hash_lock);
+			list_replace_rcu(&fa->fa_list, &new_fa->fa_list);
 
-			fib_release_info(fi_drop);
+			fn_free_alias(fa, f);
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(cfg->fc_nlinfo.nl_net, -1);
-			rtmsg_fib(RTM_NEWROUTE, key, fa, cfg->fc_dst_len, tb->tb_id,
-				  &cfg->fc_nlinfo, NLM_F_REPLACE);
+			rtmsg_fib(RTM_NEWROUTE, key, new_fa, cfg->fc_dst_len,
+				  tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
 			return 0;
 		}
 
@@ -506,12 +546,10 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		f = new_f;
 	}
 
-	new_fa = &f->fn_embedded_alias;
-	if (new_fa->fa_info != NULL) {
-		new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
-		if (new_fa == NULL)
-			goto out;
-	}
+	new_fa = fib_fast_alloc(f);
+	if (new_fa == NULL)
+		goto out;
+
 	new_fa->fa_info = fi;
 	new_fa->fa_tos = tos;
 	new_fa->fa_type = cfg->fc_type;
@@ -522,13 +560,11 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	 * Insert new entry to the list.
 	 */
 
-	write_lock_bh(&fib_hash_lock);
 	if (new_f)
 		fib_insert_node(fz, new_f);
-	list_add_tail(&new_fa->fa_list,
+	list_add_tail_rcu(&new_fa->fa_list,
 		 (fa ? &fa->fa_list : &f->fn_alias));
 	fib_hash_genid++;
-	write_unlock_bh(&fib_hash_lock);
 
 	if (new_f)
 		fz->fz_nent++;
@@ -603,14 +639,12 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 			  tb->tb_id, &cfg->fc_nlinfo, 0);
 
 		kill_fn = 0;
-		write_lock_bh(&fib_hash_lock);
-		list_del(&fa->fa_list);
+		list_del_rcu(&fa->fa_list);
 		if (list_empty(&f->fn_alias)) {
-			hlist_del(&f->fn_hash);
+			hlist_del_rcu(&f->fn_hash);
 			kill_fn = 1;
 		}
 		fib_hash_genid++;
-		write_unlock_bh(&fib_hash_lock);
 
 		if (fa->fa_state & FA_S_ACCESSED)
 			rt_cache_flush(cfg->fc_nlinfo.nl_net, -1);
@@ -641,14 +675,12 @@ static int fn_flush_list(struct fn_zone *fz, int idx)
 			struct fib_info *fi = fa->fa_info;
 
 			if (fi && (fi->fib_flags&RTNH_F_DEAD)) {
-				write_lock_bh(&fib_hash_lock);
-				list_del(&fa->fa_list);
+				list_del_rcu(&fa->fa_list);
 				if (list_empty(&f->fn_alias)) {
-					hlist_del(&f->fn_hash);
+					hlist_del_rcu(&f->fn_hash);
 					kill_f = 1;
 				}
 				fib_hash_genid++;
-				write_unlock_bh(&fib_hash_lock);
 
 				fn_free_alias(fa, f);
 				found++;
@@ -693,10 +725,10 @@ fn_hash_dump_bucket(struct sk_buff *skb, struct netlink_callback *cb,
 
 	s_i = cb->args[4];
 	i = 0;
-	hlist_for_each_entry(f, node, head, fn_hash) {
+	hlist_for_each_entry_rcu(f, node, head, fn_hash) {
 		struct fib_alias *fa;
 
-		list_for_each_entry(fa, &f->fn_alias, fa_list) {
+		list_for_each_entry_rcu(fa, &f->fn_alias, fa_list) {
 			if (i < s_i)
 				goto next;
 
@@ -714,7 +746,7 @@ fn_hash_dump_bucket(struct sk_buff *skb, struct netlink_callback *cb,
 				cb->args[4] = i;
 				return -1;
 			}
-		next:
+next:
 			i++;
 		}
 	}
@@ -755,7 +787,6 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 
 	s_m = cb->args[2];
 	rcu_read_lock();
-	read_lock(&fib_hash_lock);
 	for (fz = rcu_dereference(table->fn_zone_list);
 	     fz != NULL;
 	     fz = rcu_dereference(fz->fz_next), m++) {
@@ -763,14 +794,12 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 			continue;
 		if (fn_hash_dump_zone(skb, cb, tb, fz) < 0) {
 			cb->args[2] = m;
-			read_unlock(&fib_hash_lock);
 			rcu_read_unlock();
 			return -1;
 		}
 		memset(&cb->args[3], 0,
 		       sizeof(cb->args) - 3*sizeof(cb->args[0]));
 	}
-	read_unlock(&fib_hash_lock);
 	rcu_read_unlock();
 	cb->args[2] = m;
 	return skb->len;
@@ -960,13 +989,11 @@ static struct fib_alias *fib_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *fib_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(fib_hash_lock)
 	__acquires(RCU)
 {
 	void *v = NULL;
 
 	rcu_read_lock();
-	read_lock(&fib_hash_lock);
 	if (fib_get_table(seq_file_net(seq), RT_TABLE_MAIN))
 		v = *pos ? fib_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 	return v;
@@ -979,17 +1006,16 @@ static void *fib_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void fib_seq_stop(struct seq_file *seq, void *v)
-	__releases(fib_hash_lock)
 	__releases(RCU)
 {
-	read_unlock(&fib_hash_lock);
 	rcu_read_unlock();
 }
 
 static unsigned fib_flag_trans(int type, __be32 mask, struct fib_info *fi)
 {
 	static const unsigned type2flags[RTN_MAX + 1] = {
-		[7] = RTF_REJECT, [8] = RTF_REJECT,
+		[7] = RTF_REJECT,
+		[8] = RTF_REJECT,
 	};
 	unsigned flags = type2flags[type];
 
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index b9c9a9f..5072d8e 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -12,9 +12,7 @@ struct fib_alias {
 	u8			fa_type;
 	u8			fa_scope;
 	u8			fa_state;
-#ifdef CONFIG_IP_FIB_TRIE
 	struct rcu_head		rcu;
-#endif
 };
 
 #define FA_S_ACCESSED	0x01


