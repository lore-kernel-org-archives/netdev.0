From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] rhashtable: Check for count misatch in selftest
Date: Mon, 15 Sep 2014 14:18:01 +0200
Message-ID: <b905d7fc4d43095b000150511cf95a490909f2f1.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, john.r.fastabend@intel.com,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47314 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbaIOMSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 08:18:10 -0400
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index c133d82..c10df45 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -648,15 +648,14 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 	return 0;
 }
 
-static void test_bucket_stats(struct rhashtable *ht,
-				     struct bucket_table *tbl,
-				     bool quiet)
+static void test_bucket_stats(struct rhashtable *ht, struct bucket_table *tbl,
+			      bool quiet)
 {
-	unsigned int cnt, i, total = 0;
+	unsigned int cnt, rcu_cnt, i, total = 0;
 	struct test_obj *obj;
 
 	for (i = 0; i < tbl->size; i++) {
-		cnt = 0;
+		rcu_cnt = cnt = 0;
 
 		if (!quiet)
 			pr_info(" [%#4x/%zu]", i, tbl->size);
@@ -668,6 +667,13 @@ static void test_bucket_stats(struct rhashtable *ht,
 				pr_cont(" [%p],", obj);
 		}
 
+		rht_for_each_rcu(pos, tbl, i)
+			rcu_cnt++;
+
+		if (rcu_cnt != cnt)
+			pr_warn("Test failed: Chain count mismach %d != %d",
+				cnt, rcu_cnt);
+
 		if (!quiet)
 			pr_cont("\n  [%#x] first element: %p, chain length: %u\n",
 				i, tbl->buckets[i], cnt);
@@ -675,6 +681,9 @@ static void test_bucket_stats(struct rhashtable *ht,
 
 	pr_info("  Traversal complete: counted=%u, nelems=%zu, entries=%d\n",
 		total, ht->nelems, TEST_ENTRIES);
+
+	if (total != ht->nelems || total != TEST_ENTRIES)
+		pr_warn("Test failed: Total count mismatch ^^^");
 }
 
 static int __init test_rhashtable(struct rhashtable *ht)
-- 
1.9.3
