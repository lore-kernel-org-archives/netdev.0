From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v3] lib/rhashtable: allow user to set the minimum shifts of shrinking
Date: Sat, 30 Aug 2014 14:48:26 +0800
Message-ID: <1409381306-7036-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54545 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbaH3GtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 02:49:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although rhashtable library allows user to specify a quiet big size
for user's created hash table, the table may be shrunk to a
very small size - HASH_MIN_SIZE(4) after object is removed from
the table at the first time. Subsequently, even if the total amount
of objects saved in the table is quite lower than user's initial
setting in a long time, the hash table size is still dynamically
adjusted by rhashtable_shrink() or rhashtable_expand() each time
object is inserted or removed from the table. However, as
synchronize_rcu() has to be called when table is shrunk or
expanded by the two functions, we should permit user to set the
minimum table size through configuring the minimum number of shifts
according to user specific requirement, avoiding these expensive
actions of shrinking or expanding because of calling synchronize_rcu().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/linux/rhashtable.h |    2 ++
 lib/rhashtable.c           |   11 +++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 36826c0..fb298e9d 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -44,6 +44,7 @@ struct rhashtable;
  * @head_offset: Offset of rhash_head in struct to be hashed
  * @hash_rnd: Seed to use while hashing
  * @max_shift: Maximum number of shifts while expanding
+ * @min_shift: Minimum number of shifts while shrinking
  * @hashfn: Function to hash key
  * @obj_hashfn: Function to hash object
  * @grow_decision: If defined, may return true if table should expand
@@ -57,6 +58,7 @@ struct rhashtable_params {
 	size_t			head_offset;
 	u32			hash_rnd;
 	size_t			max_shift;
+	size_t			min_shift;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
 	bool			(*grow_decision)(const struct rhashtable *ht,
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index a2c7881..5c616fe 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -298,7 +298,7 @@ int rhashtable_shrink(struct rhashtable *ht, gfp_t flags)
 
 	ASSERT_RHT_MUTEX(ht);
 
-	if (tbl->size <= HASH_MIN_SIZE)
+	if (ht->shift <= ht->p.min_shift)
 		return 0;
 
 	ntbl = bucket_table_alloc(tbl->size / 2, flags);
@@ -506,9 +506,10 @@ void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
 
-static size_t rounded_hashtable_size(unsigned int nelem)
+static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
-	return max(roundup_pow_of_two(nelem * 4 / 3), HASH_MIN_SIZE);
+	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
+		   1UL << params->min_shift);
 }
 
 /**
@@ -566,8 +567,10 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	    (!params->key_len && !params->obj_hashfn))
 		return -EINVAL;
 
+	params->min_shift = max(params->min_shift, ilog2(HASH_MIN_SIZE));
+
 	if (params->nelem_hint)
-		size = rounded_hashtable_size(params->nelem_hint);
+		size = rounded_hashtable_size(params);
 
 	tbl = bucket_table_alloc(size, GFP_KERNEL);
 	if (tbl == NULL)
-- 
1.7.9.5
