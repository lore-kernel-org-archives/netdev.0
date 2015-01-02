From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/9] rhashtable: Convert bucket iterators to take table and index
Date: Fri,  2 Jan 2015 23:00:16 +0100
Message-ID: <c9a23702d3acbce982b6add51c388d71da592cc5.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is in preparation to introduce per bucket spinlocks. It
extends all iterator macros to take the bucket table and bucket
index. It also introduces a new rht_dereference_bucket() to
handle protected accesses to buckets.

It introduces a barrier() to the RCU iterators to the prevent
the compiler from caching the first element.

The lockdep verifier is introduced as stub which always succeeds
and properly implement in the next patch when the locks are
introduced.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 173 ++++++++++++++++++++++++++++++---------------
 lib/rhashtable.c           |  30 +++++---
 net/netfilter/nft_hash.c   |  12 ++--
 net/netlink/af_netlink.c   |  12 ++--
 net/netlink/diag.c         |   4 +-
 5 files changed, 152 insertions(+), 79 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 1b51221..b54e24a 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -87,11 +87,18 @@ struct rhashtable {
 
 #ifdef CONFIG_PROVE_LOCKING
 int lockdep_rht_mutex_is_held(const struct rhashtable *ht);
+int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash);
 #else
 static inline int lockdep_rht_mutex_is_held(const struct rhashtable *ht)
 {
 	return 1;
 }
+
+static inline int lockdep_rht_bucket_is_held(const struct bucket_table *tbl,
+					     u32 hash)
+{
+	return 1;
+}
 #endif /* CONFIG_PROVE_LOCKING */
 
 int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params);
@@ -119,92 +126,144 @@ void rhashtable_destroy(const struct rhashtable *ht);
 #define rht_dereference_rcu(p, ht) \
 	rcu_dereference_check(p, lockdep_rht_mutex_is_held(ht))
 
-#define rht_entry(ptr, type, member) container_of(ptr, type, member)
-#define rht_entry_safe(ptr, type, member) \
-({ \
-	typeof(ptr) __ptr = (ptr); \
-	   __ptr ? rht_entry(__ptr, type, member) : NULL; \
-})
+#define rht_dereference_bucket(p, tbl, hash) \
+	rcu_dereference_protected(p, lockdep_rht_bucket_is_held(tbl, hash))
 
-#define rht_next_entry_safe(pos, ht, member) \
-({ \
-	pos ? rht_entry_safe(rht_dereference((pos)->member.next, ht), \
-			     typeof(*(pos)), member) : NULL; \
-})
+#define rht_dereference_bucket_rcu(p, tbl, hash) \
+	rcu_dereference_check(p, lockdep_rht_bucket_is_held(tbl, hash))
+
+#define rht_entry(tpos, pos, member) \
+	({ tpos = container_of(pos, typeof(*tpos), member); 1; })
 
 /**
- * rht_for_each - iterate over hash chain
- * @pos:	&struct rhash_head to use as a loop cursor.
- * @head:	head of the hash chain (struct rhash_head *)
- * @ht:		pointer to your struct rhashtable
+ * rht_for_each_continue - continue iterating over hash chain
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @head:	the previous &struct rhash_head to continue from
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
  */
-#define rht_for_each(pos, head, ht) \
-	for (pos = rht_dereference(head, ht); \
+#define rht_for_each_continue(pos, head, tbl, hash) \
+	for (pos = rht_dereference_bucket(head, tbl, hash); \
 	     pos; \
-	     pos = rht_dereference((pos)->next, ht))
+	     pos = rht_dereference_bucket((pos)->next, tbl, hash))
+
+/**
+ * rht_for_each - iterate over hash chain
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ */
+#define rht_for_each(pos, tbl, hash) \
+	rht_for_each_continue(pos, (tbl)->buckets[hash], tbl, hash)
+
+/**
+ * rht_for_each_entry_continue - continue iterating over hash chain
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @head:	the previous &struct rhash_head to continue from
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ * @member:	name of the &struct rhash_head within the hashable struct.
+ */
+#define rht_for_each_entry_continue(tpos, pos, head, tbl, hash, member)	\
+	for (pos = rht_dereference_bucket(head, tbl, hash);		\
+	     pos && rht_entry(tpos, pos, member);			\
+	     pos = rht_dereference_bucket((pos)->next, tbl, hash))
 
 /**
  * rht_for_each_entry - iterate over hash chain of given type
- * @pos:	type * to use as a loop cursor.
- * @head:	head of the hash chain (struct rhash_head *)
- * @ht:		pointer to your struct rhashtable
- * @member:	name of the rhash_head within the hashable struct.
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ * @member:	name of the &struct rhash_head within the hashable struct.
  */
-#define rht_for_each_entry(pos, head, ht, member) \
-	for (pos = rht_entry_safe(rht_dereference(head, ht), \
-				   typeof(*(pos)), member); \
-	     pos; \
-	     pos = rht_next_entry_safe(pos, ht, member))
+#define rht_for_each_entry(tpos, pos, tbl, hash, member)		\
+	rht_for_each_entry_continue(tpos, pos, (tbl)->buckets[hash],	\
+				    tbl, hash, member)
 
 /**
  * rht_for_each_entry_safe - safely iterate over hash chain of given type
- * @pos:	type * to use as a loop cursor.
- * @n:		type * to use for temporary next object storage
- * @head:	head of the hash chain (struct rhash_head *)
- * @ht:		pointer to your struct rhashtable
- * @member:	name of the rhash_head within the hashable struct.
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @next:	the &struct rhash_head to use as next in loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ * @member:	name of the &struct rhash_head within the hashable struct.
  *
  * This hash chain list-traversal primitive allows for the looped code to
  * remove the loop cursor from the list.
  */
-#define rht_for_each_entry_safe(pos, n, head, ht, member)		\
-	for (pos = rht_entry_safe(rht_dereference(head, ht), \
-				  typeof(*(pos)), member), \
-	     n = rht_next_entry_safe(pos, ht, member); \
-	     pos; \
-	     pos = n, \
-	     n = rht_next_entry_safe(pos, ht, member))
+#define rht_for_each_entry_safe(tpos, pos, next, tbl, hash, member)	    \
+	for (pos = rht_dereference_bucket((tbl)->buckets[hash], tbl, hash), \
+	     next = pos ? rht_dereference_bucket(pos->next, tbl, hash)      \
+			: NULL;						    \
+	     pos && rht_entry(tpos, pos, member);			    \
+	     pos = next)
+
+/**
+ * rht_for_each_rcu_continue - continue iterating over rcu hash chain
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @head:	the previous &struct rhash_head to continue from
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ *
+ * This hash chain list-traversal primitive may safely run concurrently with
+ * the _rcu mutation primitives such as rhashtable_insert() as long as the
+ * traversal is guarded by rcu_read_lock().
+ */
+#define rht_for_each_rcu_continue(pos, head, tbl, hash)			\
+	for (({barrier(); }),						\
+	     pos = rht_dereference_bucket_rcu(head, tbl, hash);		\
+	     pos;							\
+	     pos = rcu_dereference_raw(pos->next))
 
 /**
  * rht_for_each_rcu - iterate over rcu hash chain
- * @pos:	&struct rhash_head to use as a loop cursor.
- * @head:	head of the hash chain (struct rhash_head *)
- * @ht:		pointer to your struct rhashtable
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
  *
  * This hash chain list-traversal primitive may safely run concurrently with
- * the _rcu fkht mutation primitives such as rht_insert() as long as the
+ * the _rcu mutation primitives such as rhashtable_insert() as long as the
  * traversal is guarded by rcu_read_lock().
  */
-#define rht_for_each_rcu(pos, head, ht) \
-	for (pos = rht_dereference_rcu(head, ht); \
-	     pos; \
-	     pos = rht_dereference_rcu((pos)->next, ht))
+#define rht_for_each_rcu(pos, tbl, hash)				\
+	rht_for_each_rcu_continue(pos, (tbl)->buckets[hash], tbl, hash)
+
+/**
+ * rht_for_each_entry_rcu_continue - continue iterating over rcu hash chain
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @head:	the previous &struct rhash_head to continue from
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ * @member:	name of the &struct rhash_head within the hashable struct.
+ *
+ * This hash chain list-traversal primitive may safely run concurrently with
+ * the _rcu mutation primitives such as rhashtable_insert() as long as the
+ * traversal is guarded by rcu_read_lock().
+ */
+#define rht_for_each_entry_rcu_continue(tpos, pos, head, tbl, hash, member) \
+	for (({barrier(); }),						    \
+	     pos = rht_dereference_bucket_rcu(head, tbl, hash);		    \
+	     pos && rht_entry(tpos, pos, member);			    \
+	     pos = rht_dereference_bucket_rcu(pos->next, tbl, hash))
 
 /**
  * rht_for_each_entry_rcu - iterate over rcu hash chain of given type
- * @pos:	type * to use as a loop cursor.
- * @head:	head of the hash chain (struct rhash_head *)
- * @member:	name of the rhash_head within the hashable struct.
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ * @member:	name of the &struct rhash_head within the hashable struct.
  *
  * This hash chain list-traversal primitive may safely run concurrently with
- * the _rcu fkht mutation primitives such as rht_insert() as long as the
+ * the _rcu mutation primitives such as rhashtable_insert() as long as the
  * traversal is guarded by rcu_read_lock().
  */
-#define rht_for_each_entry_rcu(pos, head, member) \
-	for (pos = rht_entry_safe(rcu_dereference_raw(head), \
-				  typeof(*(pos)), member); \
-	     pos; \
-	     pos = rht_entry_safe(rcu_dereference_raw((pos)->member.next), \
-				  typeof(*(pos)), member))
+#define rht_for_each_entry_rcu(tpos, pos, tbl, hash, member)		\
+	rht_for_each_entry_rcu_continue(tpos, pos, (tbl)->buckets[hash],\
+					tbl, hash, member)
 
 #endif /* _LINUX_RHASHTABLE_H */
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index b658245..ce450d0 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -35,6 +35,12 @@ int lockdep_rht_mutex_is_held(const struct rhashtable *ht)
 	return ht->p.mutex_is_held(ht->p.parent);
 }
 EXPORT_SYMBOL_GPL(lockdep_rht_mutex_is_held);
+
+int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash)
+{
+	return 1;
+}
+EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
 #endif
 
 static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
@@ -141,7 +147,7 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	 * previous node p. Call the previous node p;
 	 */
 	h = head_hashfn(ht, new_tbl, p);
-	rht_for_each(he, p->next, ht) {
+	rht_for_each_continue(he, p->next, old_tbl, n) {
 		if (head_hashfn(ht, new_tbl, he) != h)
 			break;
 		p = he;
@@ -153,7 +159,7 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	 */
 	next = NULL;
 	if (he) {
-		rht_for_each(he, he->next, ht) {
+		rht_for_each_continue(he, he->next, old_tbl, n) {
 			if (head_hashfn(ht, new_tbl, he) == h) {
 				next = he;
 				break;
@@ -208,7 +214,7 @@ int rhashtable_expand(struct rhashtable *ht)
 	 */
 	for (i = 0; i < new_tbl->size; i++) {
 		h = rht_bucket_index(old_tbl, i);
-		rht_for_each(he, old_tbl->buckets[h], ht) {
+		rht_for_each(he, old_tbl, h) {
 			if (head_hashfn(ht, new_tbl, he) == i) {
 				RCU_INIT_POINTER(new_tbl->buckets[i], he);
 				break;
@@ -286,7 +292,7 @@ int rhashtable_shrink(struct rhashtable *ht)
 		 * to the new bucket.
 		 */
 		for (pprev = &ntbl->buckets[i]; *pprev != NULL;
-		     pprev = &rht_dereference(*pprev, ht)->next)
+		     pprev = &rht_dereference_bucket(*pprev, ntbl, i)->next)
 			;
 		RCU_INIT_POINTER(*pprev, tbl->buckets[i + ntbl->size]);
 	}
@@ -386,7 +392,7 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 	h = head_hashfn(ht, tbl, obj);
 
 	pprev = &tbl->buckets[h];
-	rht_for_each(he, tbl->buckets[h], ht) {
+	rht_for_each(he, tbl, h) {
 		if (he != obj) {
 			pprev = &he->next;
 			continue;
@@ -423,7 +429,7 @@ void *rhashtable_lookup(const struct rhashtable *ht, const void *key)
 	BUG_ON(!ht->p.key_len);
 
 	h = key_hashfn(ht, key, ht->p.key_len);
-	rht_for_each_rcu(he, tbl->buckets[h], ht) {
+	rht_for_each_rcu(he, tbl, h) {
 		if (memcmp(rht_obj(ht, he) + ht->p.key_offset, key,
 			   ht->p.key_len))
 			continue;
@@ -457,7 +463,7 @@ void *rhashtable_lookup_compare(const struct rhashtable *ht, const void *key,
 	u32 hash;
 
 	hash = key_hashfn(ht, key, ht->p.key_len);
-	rht_for_each_rcu(he, tbl->buckets[hash], ht) {
+	rht_for_each_rcu(he, tbl, hash) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
 		return rht_obj(ht, he);
@@ -625,6 +631,7 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 static void test_bucket_stats(struct rhashtable *ht, bool quiet)
 {
 	unsigned int cnt, rcu_cnt, i, total = 0;
+	struct rhash_head *pos;
 	struct test_obj *obj;
 	struct bucket_table *tbl;
 
@@ -635,14 +642,14 @@ static void test_bucket_stats(struct rhashtable *ht, bool quiet)
 		if (!quiet)
 			pr_info(" [%#4x/%zu]", i, tbl->size);
 
-		rht_for_each_entry_rcu(obj, tbl->buckets[i], node) {
+		rht_for_each_entry_rcu(obj, pos, tbl, i, node) {
 			cnt++;
 			total++;
 			if (!quiet)
 				pr_cont(" [%p],", obj);
 		}
 
-		rht_for_each_entry_rcu(obj, tbl->buckets[i], node)
+		rht_for_each_entry_rcu(obj, pos, tbl, i, node)
 			rcu_cnt++;
 
 		if (rcu_cnt != cnt)
@@ -664,7 +671,8 @@ static void test_bucket_stats(struct rhashtable *ht, bool quiet)
 static int __init test_rhashtable(struct rhashtable *ht)
 {
 	struct bucket_table *tbl;
-	struct test_obj *obj, *next;
+	struct test_obj *obj;
+	struct rhash_head *pos, *next;
 	int err;
 	unsigned int i;
 
@@ -733,7 +741,7 @@ static int __init test_rhashtable(struct rhashtable *ht)
 error:
 	tbl = rht_dereference_rcu(ht->tbl, ht);
 	for (i = 0; i < tbl->size; i++)
-		rht_for_each_entry_safe(obj, next, tbl->buckets[i], ht, node)
+		rht_for_each_entry_safe(obj, pos, next, tbl, i, node)
 			kfree(obj);
 
 	return err;
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 614ee09..d93f1f4 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -142,7 +142,9 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 
 	tbl = rht_dereference_rcu(priv->tbl, priv);
 	for (i = 0; i < tbl->size; i++) {
-		rht_for_each_entry_rcu(he, tbl->buckets[i], node) {
+		struct rhash_head *pos;
+
+		rht_for_each_entry_rcu(he, pos, tbl, i, node) {
 			if (iter->count < iter->skip)
 				goto cont;
 
@@ -197,15 +199,13 @@ static void nft_hash_destroy(const struct nft_set *set)
 {
 	const struct rhashtable *priv = nft_set_priv(set);
 	const struct bucket_table *tbl = priv->tbl;
-	struct nft_hash_elem *he, *next;
+	struct nft_hash_elem *he;
+	struct rhash_head *pos, *next;
 	unsigned int i;
 
 	for (i = 0; i < tbl->size; i++) {
-		for (he = rht_entry(tbl->buckets[i], struct nft_hash_elem, node);
-		     he != NULL; he = next) {
-			next = rht_entry(he->node.next, struct nft_hash_elem, node);
+		rht_for_each_entry_safe(he, pos, next, tbl, i, node)
 			nft_hash_elem_destroy(set, he);
-		}
 	}
 	rhashtable_destroy(priv);
 }
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a5d7ed6..57449b6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2898,7 +2898,9 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 		const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 
 		for (j = 0; j < tbl->size; j++) {
-			rht_for_each_entry_rcu(nlk, tbl->buckets[j], node) {
+			struct rhash_head *node;
+
+			rht_for_each_entry_rcu(nlk, node, tbl, j, node) {
 				s = (struct sock *)nlk;
 
 				if (sock_net(s) != seq_file_net(seq))
@@ -2926,6 +2928,8 @@ static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
 static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct rhashtable *ht;
+	const struct bucket_table *tbl;
+	struct rhash_head *node;
 	struct netlink_sock *nlk;
 	struct nl_seq_iter *iter;
 	struct net *net;
@@ -2942,17 +2946,17 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	i = iter->link;
 	ht = &nl_table[i].hash;
-	rht_for_each_entry(nlk, nlk->node.next, ht, node)
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+	rht_for_each_entry_rcu_continue(nlk, node, nlk->node.next, tbl, iter->hash_idx, node)
 		if (net_eq(sock_net((struct sock *)nlk), net))
 			return nlk;
 
 	j = iter->hash_idx + 1;
 
 	do {
-		const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 
 		for (; j < tbl->size; j++) {
-			rht_for_each_entry(nlk, tbl->buckets[j], ht, node) {
+			rht_for_each_entry_rcu(nlk, node, tbl, j, node) {
 				if (net_eq(sock_net((struct sock *)nlk), net)) {
 					iter->link = i;
 					iter->hash_idx = j;
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index de8c74a..fcca36d 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -113,7 +113,9 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	req = nlmsg_data(cb->nlh);
 
 	for (i = 0; i < htbl->size; i++) {
-		rht_for_each_entry(nlsk, htbl->buckets[i], ht, node) {
+		struct rhash_head *pos;
+
+		rht_for_each_entry(nlsk, pos, htbl, i, node) {
 			sk = (struct sock *)nlsk;
 
 			if (!net_eq(sock_net(sk), net))
-- 
1.9.3
