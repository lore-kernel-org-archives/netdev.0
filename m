From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] rhashtable: Remove obj_raw_hashfn
Date: Thu, 12 Mar 2015 12:30:56 +1100
Message-ID: <E1YVrxg-0003NF-2u@gondolin.me.apana.org.au>
References: <20150312012944.GA12857@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53363 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbbCLBa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:30:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the only caller of obj_raw_hashfn is head_hashfn, we can
simply kill it and fold it into the latter.

This patch also moves the common shift from head_hashfn/key_hashfn
into rht_bucket_index.

Signed-off-by: Herbert Xu <herbert.xu@redhat.com>
---

 lib/rhashtable.c |   25 +++++++------------------
 1 file changed, 7 insertions(+), 18 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 91b52da..5f9af45 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -63,36 +63,25 @@ static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
 
 static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
 {
-	return hash & (tbl->size - 1);
-}
-
-static u32 obj_raw_hashfn(struct rhashtable *ht,
-			  const struct bucket_table *tbl, const void *ptr)
-{
-	u32 hash;
-
-	if (unlikely(!ht->p.key_len))
-		hash = ht->p.obj_hashfn(ptr, tbl->hash_rnd);
-	else
-		hash = ht->p.hashfn(ptr + ht->p.key_offset, ht->p.key_len,
-				    tbl->hash_rnd);
-
-	return hash >> HASH_RESERVED_SPACE;
+	return (hash >> HASH_RESERVED_SPACE) & (tbl->size - 1);
 }
 
 static u32 key_hashfn(struct rhashtable *ht, const struct bucket_table *tbl,
 		      const void *key)
 {
 	return rht_bucket_index(tbl, ht->p.hashfn(key, ht->p.key_len,
-						  tbl->hash_rnd) >>
-				     HASH_RESERVED_SPACE);
+						  tbl->hash_rnd));
 }
 
 static u32 head_hashfn(struct rhashtable *ht,
 		       const struct bucket_table *tbl,
 		       const struct rhash_head *he)
 {
-	return rht_bucket_index(tbl, obj_raw_hashfn(ht, tbl, rht_obj(ht, he)));
+	const char *ptr = rht_obj(ht, he);
+
+	return likely(ht->p.key_len) ?
+	       key_hashfn(ht, tbl, ptr + ht->p.key_offset) :
+	       rht_bucket_index(tbl, ht->p.obj_hashfn(ptr, tbl->hash_rnd));
 }
 
 #ifdef CONFIG_PROVE_LOCKING
