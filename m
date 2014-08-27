From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH RFC] lib/rhashtable: allow users to set the minimum shifts of shrinking
Date: Wed, 27 Aug 2014 16:57:31 +0800
Message-ID: <1409129851-11630-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36800 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbaH0I6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 04:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the resizeable hash table size is allowed to shrink a too smaller
size - HASH_MIN_SIZE(4) although users initially specify a rather big
size when table is created. Especially when the number of objects
saved in the table keeps a small value in comparison with the initial
setting of table size during a quite long time, lots of actions of
expanding and shrinking are involved with objects being inserted or
removed from table. However, as synchronize_rcu() has to be called
during expanding and shrinking, these unnecessary actions would
seriously hit users' performance.

Therefore, we should permit users to set the minimum table size
through configuring the minimum of number of shifts when table is
created according to users specific requirement.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/linux/rhashtable.h |    2 ++
 lib/rhashtable.c           |   16 ++++++++++++----
 2 files changed, 14 insertions(+), 4 deletions(-)

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
index a2c7881..1466e2d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -293,12 +293,15 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
 int rhashtable_shrink(struct rhashtable *ht, gfp_t flags)
 {
 	struct bucket_table *ntbl, *tbl = rht_dereference(ht->tbl, ht);
+	size_t min_shift = ilog2(HASH_MIN_SIZE);
 	struct rhash_head __rcu **pprev;
 	unsigned int i;
 
 	ASSERT_RHT_MUTEX(ht);
 
-	if (tbl->size <= HASH_MIN_SIZE)
+	if (ht->p.min_shift)
+		min_shift = max(ht->p.min_shift, min_shift);
+	if (ht->shift <= min_shift)
 		return 0;
 
 	ntbl = bucket_table_alloc(tbl->size / 2, flags);
@@ -506,9 +509,14 @@ void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
 
-static size_t rounded_hashtable_size(unsigned int nelem)
+static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
-	return max(roundup_pow_of_two(nelem * 4 / 3), HASH_MIN_SIZE);
+	size_t size = HASH_MIN_SIZE;
+
+	if (params->min_shift)
+		size = max((1UL << params->min_shift), HASH_MIN_SIZE);
+
+	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3), size);
 }
 
 /**
@@ -567,7 +575,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 		return -EINVAL;
 
 	if (params->nelem_hint)
-		size = rounded_hashtable_size(params->nelem_hint);
+		size = rounded_hashtable_size(params);
 
 	tbl = bucket_table_alloc(size, GFP_KERNEL);
 	if (tbl == NULL)
-- 
1.7.9.5
