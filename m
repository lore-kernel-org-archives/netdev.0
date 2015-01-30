From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/6] rhashtable: Avoid bucket cross reference after removal
Date: Fri, 30 Jan 2015 01:20:43 +0100
Message-ID: <798abd3e30a540af0b099a56378566d23719b190.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53255 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759061AbbA3AU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 19:20:58 -0500
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During a resize, when two buckets in the larger table map to
a single bucket in the smaller table and the new table has already
been (partially) linked to the old table. Removal of an element
may result the bucket in the larger table to point to entries
which all hash to a different value than the bucket index. Thus
causing two buckets to point to the same sub chain after unzipping.
This is not illegal *during* the resize phase but after it has
completed.

Keep the old table around until all of the unzipping is done to
allow the removal code to only search for matching hashed entries
during this special period.

Reported-by: Ying Xue <ying.xue@windriver.com>
Fixes: 97defe1ecf86 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index f21026a..74b9284 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -414,12 +414,6 @@ int rhashtable_expand(struct rhashtable *ht)
 		unlock_buckets(new_tbl, old_tbl, new_hash);
 	}
 
-	/* Publish the new table pointer. Lookups may now traverse
-	 * the new table, but they will not benefit from any
-	 * additional efficiency until later steps unzip the buckets.
-	 */
-	rcu_assign_pointer(ht->tbl, new_tbl);
-
 	/* Unzip interleaved hash chains */
 	while (!complete && !ht->being_destroyed) {
 		/* Wait for readers. All new readers will see the new
@@ -445,6 +439,7 @@ int rhashtable_expand(struct rhashtable *ht)
 	}
 
 	synchronize_rcu();
+	rcu_assign_pointer(ht->tbl, new_tbl);
 
 	bucket_table_free(old_tbl);
 	return 0;
@@ -621,7 +616,7 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 {
 	struct bucket_table *tbl, *new_tbl, *old_tbl;
 	struct rhash_head __rcu **pprev;
-	struct rhash_head *he;
+	struct rhash_head *he, *he2;
 	unsigned int hash, new_hash;
 	bool ret = false;
 
@@ -641,8 +636,21 @@ restart:
 		}
 
 		ASSERT_BUCKET_LOCK(ht, tbl, hash);
-		rcu_assign_pointer(*pprev, obj->next);
 
+		if (unlikely(new_tbl != tbl)) {
+			rht_for_each_continue(he2, he->next, tbl, hash) {
+				if (head_hashfn(ht, tbl, he2) == hash) {
+					rcu_assign_pointer(*pprev, he2);
+					goto found;
+				}
+			}
+
+			INIT_RHT_NULLS_HEAD(*pprev, ht, hash);
+		} else {
+			rcu_assign_pointer(*pprev, obj->next);
+		}
+
+found:
 		ret = true;
 		break;
 	}
-- 
1.9.3
