From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3 net-next] rhashtable: Avoid calculating hash again to unlock
Date: Fri, 13 Mar 2015 15:45:19 +0100
Message-ID: <533e5f99a1fc96e557baf4322bda126530236862.1426257747.git.tgraf@suug.ch>
References: <cover.1426257747.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59812 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbbCMOp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:45:29 -0400
In-Reply-To: <cover.1426257747.git.tgraf@suug.ch>
In-Reply-To: <cover.1426257747.git.tgraf@suug.ch>
References: <cover.1426257747.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caching the lock pointer avoids having to hash on the object
again to unlock the bucket locks.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 9d53a46..963aa03 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -384,14 +384,16 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	struct rhash_head *head;
 	bool no_resize_running;
 	unsigned hash;
+	spinlock_t *old_lock;
 	bool success = true;
 
 	rcu_read_lock();
 
 	old_tbl = rht_dereference_rcu(ht->tbl, ht);
 	hash = head_hashfn(ht, old_tbl, obj);
+	old_lock = bucket_lock(old_tbl, hash);
 
-	spin_lock_bh(bucket_lock(old_tbl, hash));
+	spin_lock_bh(old_lock);
 
 	/* Because we have already taken the bucket lock in old_tbl,
 	 * if we find that future_tbl is not yet visible then that
@@ -428,13 +430,10 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 		schedule_work(&ht->run_work);
 
 exit:
-	if (tbl != old_tbl) {
-		hash = head_hashfn(ht, tbl, obj);
+	if (tbl != old_tbl)
 		spin_unlock(bucket_lock(tbl, hash));
-	}
 
-	hash = head_hashfn(ht, old_tbl, obj);
-	spin_unlock_bh(bucket_lock(old_tbl, hash));
+	spin_unlock_bh(old_lock);
 
 	rcu_read_unlock();
 
-- 
1.9.3
