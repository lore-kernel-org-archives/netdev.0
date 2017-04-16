From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] rhashtable: remove insecure_elasticity
Date: Sun, 16 Apr 2017 02:55:09 +0200
Message-ID: <20170416005509.31784-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:57884 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754504AbdDPAyz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 20:54:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 83e7e4ce9e93c3 ("mac80211: Use rhltable instead of rhashtable")
removed the last user that made use of 'insecure_elasticity' parameter,
i.e. the default of 16 is used everywhere.

Replace it with a constant.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/rhashtable.h | 21 ++++++++++++++++-----
 lib/rhashtable.c           | 17 +----------------
 2 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index e507290cd2c7..ae87dcdf52d2 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -49,6 +49,21 @@
 /* Base bits plus 1 bit for nulls marker */
 #define RHT_HASH_RESERVED_SPACE	(RHT_BASE_BITS + 1)
 
+/* Maximum chain length before rehash
+ *
+ * The maximum (not average) chain length grows with the size of the hash
+ * table, at a rate of (log N)/(log log N).
+ *
+ * The value of 16 is selected so that even if the hash table grew to
+ * 2^32 you would not expect the maximum chain length to exceed it
+ * unless we are under attack (or extremely unlucky).
+ *
+ * As this limit is only to detect attacks, we don't need to set it to a
+ * lower value as you'd need the chain length to vastly exceed 16 to have
+ * any real effect on the system.
+ */
+#define RHT_ELASTICITY	16u
+
 struct rhash_head {
 	struct rhash_head __rcu		*next;
 };
@@ -114,7 +129,6 @@ struct rhashtable;
  * @max_size: Maximum size while expanding
  * @min_size: Minimum size while shrinking
  * @nulls_base: Base value to generate nulls marker
- * @insecure_elasticity: Set to true to disable chain length checks
  * @automatic_shrinking: Enable automatic shrinking of tables
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Hash function (default: jhash2 if !(key_len % 4), or jhash)
@@ -130,7 +144,6 @@ struct rhashtable_params {
 	unsigned int		max_size;
 	unsigned int		min_size;
 	u32			nulls_base;
-	bool			insecure_elasticity;
 	bool			automatic_shrinking;
 	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
@@ -143,7 +156,6 @@ struct rhashtable_params {
  * @tbl: Bucket table
  * @nelems: Number of elements in table
  * @key_len: Key length for hashfn
- * @elasticity: Maximum chain length before rehash
  * @p: Configuration parameters
  * @rhlist: True if this is an rhltable
  * @run_work: Deferred worker to expand/shrink asynchronously
@@ -154,7 +166,6 @@ struct rhashtable {
 	struct bucket_table __rcu	*tbl;
 	atomic_t			nelems;
 	unsigned int			key_len;
-	unsigned int			elasticity;
 	struct rhashtable_params	p;
 	bool				rhlist;
 	struct work_struct		run_work;
@@ -726,7 +737,7 @@ static inline void *__rhashtable_insert_fast(
 		return rhashtable_insert_slow(ht, key, obj);
 	}
 
-	elasticity = ht->elasticity;
+	elasticity = RHT_ELASTICITY;
 	pprev = rht_bucket_insert(ht, tbl, hash);
 	data = ERR_PTR(-ENOMEM);
 	if (!pprev)
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index f8635fd57442..d22a5ef109fb 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -535,7 +535,7 @@ static void *rhashtable_lookup_one(struct rhashtable *ht,
 	struct rhash_head *head;
 	int elasticity;
 
-	elasticity = ht->elasticity;
+	elasticity = RHT_ELASTICITY;
 	pprev = rht_bucket_var(tbl, hash);
 	rht_for_each_continue(head, *pprev, tbl, hash) {
 		struct rhlist_head *list;
@@ -972,21 +972,6 @@ int rhashtable_init(struct rhashtable *ht,
 	if (params->nelem_hint)
 		size = rounded_hashtable_size(&ht->p);
 
-	/* The maximum (not average) chain length grows with the
-	 * size of the hash table, at a rate of (log N)/(log log N).
-	 * The value of 16 is selected so that even if the hash
-	 * table grew to 2^32 you would not expect the maximum
-	 * chain length to exceed it unless we are under attack
-	 * (or extremely unlucky).
-	 *
-	 * As this limit is only to detect attacks, we don't need
-	 * to set it to a lower value as you'd need the chain
-	 * length to vastly exceed 16 to have any real effect
-	 * on the system.
-	 */
-	if (!params->insecure_elasticity)
-		ht->elasticity = 16;
-
 	if (params->locks_mul)
 		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
 	else
-- 
2.10.2
