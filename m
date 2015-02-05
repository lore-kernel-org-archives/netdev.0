From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/6] rhashtable: key_hashfn() must return full hash value
Date: Thu,  5 Feb 2015 02:03:31 +0100
Message-ID: <a2afae2230881e0d21045247d2ab11d382eea203.1423097592.git.tgraf@suug.ch>
References: <cover.1423097592.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41018 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756151AbbBEBDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:03:42 -0500
In-Reply-To: <cover.1423097592.git.tgraf@suug.ch>
In-Reply-To: <cover.1423097592.git.tgraf@suug.ch>
References: <cover.1423097592.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The value computed by key_hashfn() is used by rhashtable_lookup_compare()
to traverse both tables during a resize. key_hashfn() must therefore
return the hash value without the buckets mask applied so it can be
masked to the size of each individual table.

Fixes: 97defe1ecf86 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 0579191..71fd0dd 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -94,13 +94,7 @@ static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
 
 static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
 {
-	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
-	u32 hash;
-
-	hash = ht->p.hashfn(key, len, ht->p.hash_rnd);
-	hash >>= HASH_RESERVED_SPACE;
-
-	return rht_bucket_index(tbl, hash);
+	return ht->p.hashfn(key, len, ht->p.hash_rnd) >> HASH_RESERVED_SPACE;
 }
 
 static u32 head_hashfn(const struct rhashtable *ht,
-- 
1.9.3
