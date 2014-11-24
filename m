From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable: Check for count mismatch while iterating in selftest
Date: Mon, 24 Nov 2014 12:37:58 +0100
Message-ID: <20668a4b2ff01138f5b1d5b3b59650790e504c00.1416828807.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40497 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbaKXLiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 06:38:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Verify whether both the lock and RCU protected iterators see all
test entries before and after expanding and shrinking has been
performed. Also verify whether the number of entries in the hashtable
remains stable during expansion and shrinking.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e5f5e69..c7e987a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -653,15 +653,15 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 	return 0;
 }
 
-static void test_bucket_stats(struct rhashtable *ht,
-				     struct bucket_table *tbl,
-				     bool quiet)
+static void test_bucket_stats(struct rhashtable *ht, bool quiet)
 {
-	unsigned int cnt, i, total = 0;
+	unsigned int cnt, rcu_cnt, i, total = 0;
 	struct test_obj *obj;
+	struct bucket_table *tbl;
 
+	tbl = rht_dereference_rcu(ht->tbl, ht);
 	for (i = 0; i < tbl->size; i++) {
-		cnt = 0;
+		rcu_cnt = cnt = 0;
 
 		if (!quiet)
 			pr_info(" [%#4x/%zu]", i, tbl->size);
@@ -673,6 +673,13 @@ static void test_bucket_stats(struct rhashtable *ht,
 				pr_cont(" [%p],", obj);
 		}
 
+		rht_for_each_entry_rcu(obj, tbl->buckets[i], node)
+			rcu_cnt++;
+
+		if (rcu_cnt != cnt)
+			pr_warn("Test failed: Chain count mismach %d != %d",
+				cnt, rcu_cnt);
+
 		if (!quiet)
 			pr_cont("\n  [%#x] first element: %p, chain length: %u\n",
 				i, tbl->buckets[i], cnt);
@@ -680,6 +687,9 @@ static void test_bucket_stats(struct rhashtable *ht,
 
 	pr_info("  Traversal complete: counted=%u, nelems=%zu, entries=%d\n",
 		total, ht->nelems, TEST_ENTRIES);
+
+	if (total != ht->nelems || total != TEST_ENTRIES)
+		pr_warn("Test failed: Total count mismatch ^^^");
 }
 
 static int __init test_rhashtable(struct rhashtable *ht)
@@ -710,8 +720,7 @@ static int __init test_rhashtable(struct rhashtable *ht)
 	}
 
 	rcu_read_lock();
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-	test_bucket_stats(ht, tbl, true);
+	test_bucket_stats(ht, true);
 	test_rht_lookup(ht);
 	rcu_read_unlock();
 
@@ -735,6 +744,10 @@ static int __init test_rhashtable(struct rhashtable *ht)
 		rcu_read_unlock();
 	}
 
+	rcu_read_lock();
+	test_bucket_stats(ht, true);
+	rcu_read_unlock();
+
 	pr_info("  Deleting %d keys\n", TEST_ENTRIES);
 	for (i = 0; i < TEST_ENTRIES; i++) {
 		u32 key = i * 2;
-- 
1.9.3
