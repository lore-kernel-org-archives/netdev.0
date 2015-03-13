From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3 net-next] rhashtable: Use spin_lock_bh_nested() consistently
Date: Fri, 13 Mar 2015 15:45:20 +0100
Message-ID: <ad7f4c80fc041ae4aae4e2ed5294ba1f218e6afb.1426257747.git.tgraf@suug.ch>
References: <cover.1426257747.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59829 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbCMOpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:45:31 -0400
In-Reply-To: <cover.1426257747.git.tgraf@suug.ch>
In-Reply-To: <cover.1426257747.git.tgraf@suug.ch>
References: <cover.1426257747.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No change in behaviour as the outer lock already disables softirq
but it prevents bugs down the line as this lock logically requires
the BH variant.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 963aa03..4de97e1f 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -233,7 +233,7 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 
 	new_bucket_lock = bucket_lock(new_tbl, new_hash);
 
-	spin_lock_nested(new_bucket_lock, SINGLE_DEPTH_NESTING);
+	spin_lock_bh_nested(new_bucket_lock, SINGLE_DEPTH_NESTING);
 	head = rht_dereference_bucket(new_tbl->buckets[new_hash],
 				      new_tbl, new_hash);
 
@@ -243,7 +243,7 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 		RCU_INIT_POINTER(entry->next, head);
 
 	rcu_assign_pointer(new_tbl->buckets[new_hash], entry);
-	spin_unlock(new_bucket_lock);
+	spin_unlock_bh(new_bucket_lock);
 
 	rcu_assign_pointer(*pprev, next);
 
@@ -404,7 +404,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	tbl = rht_dereference_rcu(old_tbl->future_tbl, ht) ?: old_tbl;
 	if (tbl != old_tbl) {
 		hash = head_hashfn(ht, tbl, obj);
-		spin_lock_nested(bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
+		spin_lock_bh_nested(bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
 	}
 
 	if (compare &&
@@ -431,7 +431,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 
 exit:
 	if (tbl != old_tbl)
-		spin_unlock(bucket_lock(tbl, hash));
+		spin_unlock_bh(bucket_lock(tbl, hash));
 
 	spin_unlock_bh(old_lock);
 
-- 
1.9.3
