From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 6/6] rhashtable-test: Detect insertion failures
Date: Thu, 30 Apr 2015 22:37:45 +0000
Message-ID: <1430433465-6066-7-git-send-email-tgraf@suug.ch>
References: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35368 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbbD3WiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:38:03 -0400
Received: by pdbqd1 with SMTP id qd1so74270068pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:38:02 -0700 (PDT)
In-Reply-To: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Account for failed inserts due to memory pressure or EBUSY and
ignore failed entries during the consistency check.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/test_rhashtable.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 3a9a3d9..6893e57 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -21,8 +21,8 @@
 #include <linux/rhashtable.h>
 #include <linux/slab.h>
 
-
 #define MAX_ENTRIES	1000000
+#define TEST_INSERT_FAIL INT_MAX
 
 static int entries = 50000;
 module_param(entries, int, 0);
@@ -68,6 +68,9 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 		bool expected = !(i % 2);
 		u32 key = i;
 
+		if (array[i / 2].value == TEST_INSERT_FAIL)
+			expected = false;
+
 		obj = rhashtable_lookup_fast(ht, &key, test_rht_params);
 
 		if (expected && !obj) {
@@ -135,7 +138,7 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 {
 	struct test_obj *obj;
 	int err;
-	unsigned int i;
+	unsigned int i, insert_fails = 0;
 	s64 start, end;
 
 	/*
@@ -150,10 +153,19 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 		obj->value = i * 2;
 
 		err = rhashtable_insert_fast(ht, &obj->node, test_rht_params);
-		if (err)
+		if (err == -ENOMEM || err == -EBUSY) {
+			/* Mark failed inserts but continue */
+			obj->value = TEST_INSERT_FAIL;
+			insert_fails++;
+		} else if (err) {
 			return err;
+		}
 	}
 
+	if (insert_fails)
+		pr_info("  %u insertions failed due to memory pressure\n",
+			insert_fails);
+
 	test_bucket_stats(ht);
 	rcu_read_lock();
 	test_rht_lookup(ht);
@@ -165,10 +177,12 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 	for (i = 0; i < entries; i++) {
 		u32 key = i * 2;
 
-		obj = rhashtable_lookup_fast(ht, &key, test_rht_params);
-		BUG_ON(!obj);
+		if (array[i].value != TEST_INSERT_FAIL) {
+			obj = rhashtable_lookup_fast(ht, &key, test_rht_params);
+			BUG_ON(!obj);
 
-		rhashtable_remove_fast(ht, &obj->node, test_rht_params);
+			rhashtable_remove_fast(ht, &obj->node, test_rht_params);
+		}
 	}
 
 	end = ktime_get_ns();
-- 
1.9.3
