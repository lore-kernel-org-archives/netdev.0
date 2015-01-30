From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/6] rhashtable: Add more lock verification
Date: Fri, 30 Jan 2015 01:20:42 +0100
Message-ID: <51f53f026a88b4e5d395167c6a340f9587832973.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53245 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759027AbbA3AU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 19:20:56 -0500
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Catch hash miscalculations which result in hard to track down race
conditions.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index fa11a2e..f21026a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -347,9 +347,11 @@ static bool hashtable_chain_unzip(struct rhashtable *ht,
 	return !rht_is_a_nulls(p);
 }
 
-static void link_old_to_new(struct bucket_table *new_tbl,
+static void link_old_to_new(struct rhashtable *ht, struct bucket_table *new_tbl,
 			    unsigned int new_hash, struct rhash_head *entry)
 {
+	ASSERT_BUCKET_LOCK(ht, new_tbl, new_hash);
+
 	rcu_assign_pointer(*bucket_tail(new_tbl, new_hash), entry);
 }
 
@@ -405,7 +407,7 @@ int rhashtable_expand(struct rhashtable *ht)
 		lock_buckets(new_tbl, old_tbl, new_hash);
 		rht_for_each(he, old_tbl, old_hash) {
 			if (head_hashfn(ht, new_tbl, he) == new_hash) {
-				link_old_to_new(new_tbl, new_hash, he);
+				link_old_to_new(ht, new_tbl, new_hash, he);
 				break;
 			}
 		}
@@ -494,6 +496,7 @@ int rhashtable_shrink(struct rhashtable *ht)
 
 		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
 				   tbl->buckets[new_hash]);
+		ASSERT_BUCKET_LOCK(ht, tbl, new_hash + new_tbl->size);
 		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
 				   tbl->buckets[new_hash + new_tbl->size]);
 
@@ -551,6 +554,8 @@ static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	struct rhash_head *head = rht_dereference_bucket(tbl->buckets[hash],
 							 tbl, hash);
 
+	ASSERT_BUCKET_LOCK(ht, tbl, hash);
+
 	if (rht_is_a_nulls(head))
 		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
 	else
@@ -635,6 +640,7 @@ restart:
 			continue;
 		}
 
+		ASSERT_BUCKET_LOCK(ht, tbl, hash);
 		rcu_assign_pointer(*pprev, obj->next);
 
 		ret = true;
-- 
1.9.3
