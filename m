From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] rhashtable: remove insecure_max_entries param
Date: Tue, 25 Apr 2017 11:41:34 +0200
Message-ID: <20170425094134.21885-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:47860 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1428728AbdDYJlW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 05:41:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

no users in the tree, insecure_max_entries is always set to
ht->p.max_size * 2 in rhtashtable_init().

Replace only spot that uses it with a ht->p.max_size check.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/rhashtable.h | 6 ++----
 lib/rhashtable.c           | 6 ------
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index ae87dcdf52d2..ae93b65d13d7 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -125,7 +125,6 @@ struct rhashtable;
  * @key_len: Length of key
  * @key_offset: Offset of key in struct to be hashed
  * @head_offset: Offset of rhash_head in struct to be hashed
- * @insecure_max_entries: Maximum number of entries (may be exceeded)
  * @max_size: Maximum size while expanding
  * @min_size: Minimum size while shrinking
  * @nulls_base: Base value to generate nulls marker
@@ -140,7 +139,6 @@ struct rhashtable_params {
 	size_t			key_len;
 	size_t			key_offset;
 	size_t			head_offset;
-	unsigned int		insecure_max_entries;
 	unsigned int		max_size;
 	unsigned int		min_size;
 	u32			nulls_base;
@@ -329,8 +327,8 @@ static inline bool rht_grow_above_100(const struct rhashtable *ht,
 static inline bool rht_grow_above_max(const struct rhashtable *ht,
 				      const struct bucket_table *tbl)
 {
-	return ht->p.insecure_max_entries &&
-	       atomic_read(&ht->nelems) >= ht->p.insecure_max_entries;
+	return ht->p.max_size &&
+	       (atomic_read(&ht->nelems) / 2u) >= ht->p.max_size;
 }
 
 /* The bucket lock is selected based on the hash and protects mutations
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index d22a5ef109fb..f3b82e0d417b 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -961,12 +961,6 @@ int rhashtable_init(struct rhashtable *ht,
 	if (params->max_size)
 		ht->p.max_size = rounddown_pow_of_two(params->max_size);
 
-	if (params->insecure_max_entries)
-		ht->p.insecure_max_entries =
-			rounddown_pow_of_two(params->insecure_max_entries);
-	else
-		ht->p.insecure_max_entries = ht->p.max_size * 2;
-
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
 	if (params->nelem_hint)
-- 
2.10.2
