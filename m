From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/3] rhashtable: don't test for shrink on insert, expansion on delete
Date: Fri, 20 Feb 2015 00:53:37 +0100
Message-ID: <55e6cbcc9c4b7a831d72d3e3ec39c024f494f9e2.1424389682.git.daniel@iogearbox.net>
References: <cover.1424389682.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, johunt@akamai.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ying Xue <ying.xue@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59408 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbbBSXxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 18:53:53 -0500
In-Reply-To: <cover.1424389682.git.daniel@iogearbox.net>
In-Reply-To: <cover.1424389682.git.daniel@iogearbox.net>
References: <cover.1424389682.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore pre 54c5b7d311c8 behaviour and only probe for expansions on inserts
and shrinks on deletes. Currently, it will happen that on initial inserts
into a sparse hash table, we may i.e. shrink it first simply because it's
not fully populated yet, only to later realize that we need to grow again.

This however is counter intuitive, e.g. an initial default size of 64
elements is already small enough, and in case an elements size hint is given
to the hash table by a user, we should avoid unnecessary expansion steps,
so a shrink is clearly unintended here.

Fixes: 54c5b7d311c8 ("rhashtable: introduce rhashtable_wakeup_worker helper function")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Ying Xue <ying.xue@windriver.com>
---
 lib/rhashtable.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 9cc4c4a..38f7879 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -537,16 +537,25 @@ unlock:
 	mutex_unlock(&ht->mutex);
 }
 
-static void rhashtable_wakeup_worker(struct rhashtable *ht)
+static void rhashtable_probe_expand(struct rhashtable *ht)
 {
-	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
-	struct bucket_table *new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	size_t size = tbl->size;
+	const struct bucket_table *new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 
 	/* Only adjust the table if no resizing is currently in progress. */
-	if (tbl == new_tbl &&
-	    ((ht->p.grow_decision && ht->p.grow_decision(ht, size)) ||
-	     (ht->p.shrink_decision && ht->p.shrink_decision(ht, size))))
+	if (tbl == new_tbl && ht->p.grow_decision &&
+	    ht->p.grow_decision(ht, tbl->size))
+		schedule_work(&ht->run_work);
+}
+
+static void rhashtable_probe_shrink(struct rhashtable *ht)
+{
+	const struct bucket_table *new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
+
+	/* Only adjust the table if no resizing is currently in progress. */
+	if (tbl == new_tbl && ht->p.shrink_decision &&
+	    ht->p.shrink_decision(ht, tbl->size))
 		schedule_work(&ht->run_work);
 }
 
@@ -569,7 +578,7 @@ static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 
 	atomic_inc(&ht->nelems);
 
-	rhashtable_wakeup_worker(ht);
+	rhashtable_probe_expand(ht);
 }
 
 /**
@@ -682,7 +691,7 @@ found:
 
 	if (ret) {
 		atomic_dec(&ht->nelems);
-		rhashtable_wakeup_worker(ht);
+		rhashtable_probe_shrink(ht);
 	}
 
 	rcu_read_unlock();
-- 
1.9.3
