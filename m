From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/6] rhashtable: key_hashfn() must return full hash value
Date: Fri, 30 Jan 2015 01:20:38 +0100
Message-ID: <19e5f15060e51b8330cf37e60c733ba35234b769.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53180 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758835AbbA3AUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 19:20:50 -0500
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
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
index bc2d0d8..7413697 100644
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
