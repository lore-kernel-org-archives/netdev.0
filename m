From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 5/6] rhashtable-test: Use walker to test bucket statistics
Date: Thu, 30 Apr 2015 22:37:44 +0000
Message-ID: <1430433465-6066-6-git-send-email-tgraf@suug.ch>
References: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35351 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbD3WiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:38:02 -0400
Received: by pdbqd1 with SMTP id qd1so74269754pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:38:01 -0700 (PDT)
In-Reply-To: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As resizes may continue to run in the background, use walker to
ensure we see all entries. Also print the encountered number
of rehashes queued up while traversing.

This may lead to warnings due to entries being seen multiple
times. We consider them non-fatal.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/test_rhashtable.c | 60 +++++++++++++++++++++++++--------------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 935693e..3a9a3d9 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -89,41 +89,43 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 	return 0;
 }
 
-static void test_bucket_stats(struct rhashtable *ht, bool quiet)
+static void test_bucket_stats(struct rhashtable *ht)
 {
-	unsigned int cnt, rcu_cnt, i, total = 0;
+	unsigned int err, total = 0, chain_len = 0;
+	struct rhashtable_iter hti;
 	struct rhash_head *pos;
-	struct test_obj *obj;
-	struct bucket_table *tbl;
 
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-	for (i = 0; i < tbl->size; i++) {
-		rcu_cnt = cnt = 0;
+	err = rhashtable_walk_init(ht, &hti);
+	if (err) {
+		pr_warn("Test failed: allocation error");
+		return;
+	}
 
-		if (!quiet)
-			pr_info(" [%#4x/%u]", i, tbl->size);
+	err = rhashtable_walk_start(&hti);
+	if (err && err != -EAGAIN) {
+		pr_warn("Test failed: iterator failed: %d\n", err);
+		return;
+	}
 
-		rht_for_each_entry_rcu(obj, pos, tbl, i, node) {
-			cnt++;
-			total++;
-			if (!quiet)
-				pr_cont(" [%p],", obj);
+	while ((pos = rhashtable_walk_next(&hti))) {
+		if (PTR_ERR(pos) == -EAGAIN) {
+			pr_info("Info: encountered resize\n");
+			chain_len++;
+			continue;
+		} else if (IS_ERR(pos)) {
+			pr_warn("Test failed: rhashtable_walk_next() error: %ld\n",
+				PTR_ERR(pos));
+			break;
 		}
 
-		rht_for_each_entry_rcu(obj, pos, tbl, i, node)
-			rcu_cnt++;
-
-		if (rcu_cnt != cnt)
-			pr_warn("Test failed: Chain count mismach %d != %d",
-				cnt, rcu_cnt);
-
-		if (!quiet)
-			pr_cont("\n  [%#x] first element: %p, chain length: %u\n",
-				i, tbl->buckets[i], cnt);
+		total++;
 	}
 
-	pr_info("  Traversal complete: counted=%u, nelems=%u, entries=%d\n",
-		total, atomic_read(&ht->nelems), entries);
+	rhashtable_walk_stop(&hti);
+	rhashtable_walk_exit(&hti);
+
+	pr_info("  Traversal complete: counted=%u, nelems=%u, entries=%d, table-jumps=%u\n",
+		total, atomic_read(&ht->nelems), entries, chain_len);
 
 	if (total != atomic_read(&ht->nelems) || total != entries)
 		pr_warn("Test failed: Total count mismatch ^^^");
@@ -152,14 +154,12 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 			return err;
 	}
 
+	test_bucket_stats(ht);
 	rcu_read_lock();
-	test_bucket_stats(ht, true);
 	test_rht_lookup(ht);
 	rcu_read_unlock();
 
-	rcu_read_lock();
-	test_bucket_stats(ht, true);
-	rcu_read_unlock();
+	test_bucket_stats(ht);
 
 	pr_info("  Deleting %d keys\n", entries);
 	for (i = 0; i < entries; i++) {
-- 
1.9.3
