From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2] lib/rhashtable: allow users to set the minimum shifts of shrinking
Date: Thu, 28 Aug 2014 09:45:24 +0800
Message-ID: <1409190324-27828-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35914 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932384AbaH1Bp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 21:45:57 -0400
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
v2: Translate HASH_MIN_SIZE to .min_shift in rhashtable_init() by
Thomas's suggestion.

 include/linux/rhashtable.h |    2 ++
 lib/rhashtable.c           |   15 +++++++++++----
 2 files changed, 13 insertions(+), 4 deletions(-)

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
index a2c7881..85a4ac2 100644
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
@@ -557,6 +558,7 @@ static size_t rounded_hashtable_size(unsigned int nelem)
  */
 int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 {
+	size_t min_shift = ilog2(HASH_MIN_SIZE);
 	struct bucket_table *tbl;
 	size_t size;
 
@@ -566,8 +568,13 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	    (!params->key_len && !params->obj_hashfn))
 		return -EINVAL;
 
+	if (params->min_shift)
+		params->min_shift = max(params->min_shift, min_shift);
+	else
+		params->min_shift = min_shift;
+
 	if (params->nelem_hint)
-		size = rounded_hashtable_size(params->nelem_hint);
+		size = rounded_hashtable_size(params);
 
 	tbl = bucket_table_alloc(size, GFP_KERNEL);
 	if (tbl == NULL)
-- 
1.7.9.5
