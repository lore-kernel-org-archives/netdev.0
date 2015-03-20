From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 5/7] test_rhashtable: Use inlined rhashtable interface
Date: Fri, 20 Mar 2015 21:57:04 +1100
Message-ID: <E1YYubw-0004lu-0C@gondolin.me.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41569 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbbCTK5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:57:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts test_rhashtable to the inlined rhashtable
interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/test_rhashtable.c |   33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 2bc403d..a2ba6ad 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -38,6 +38,16 @@ struct test_obj {
 	struct rhash_head	node;
 };
 
+static const struct rhashtable_params test_rht_params = {
+	.nelem_hint = TEST_HT_SIZE,
+	.head_offset = offsetof(struct test_obj, node),
+	.key_offset = offsetof(struct test_obj, value),
+	.key_len = sizeof(int),
+	.hashfn = jhash,
+	.max_size = 2, /* we expand/shrink manually here */
+	.nulls_base = (3U << RHT_BASE_SHIFT),
+};
+
 static int __init test_rht_lookup(struct rhashtable *ht)
 {
 	unsigned int i;
@@ -47,7 +57,7 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 		bool expected = !(i % 2);
 		u32 key = i;
 
-		obj = rhashtable_lookup(ht, &key);
+		obj = rhashtable_lookup_fast(ht, &key, test_rht_params);
 
 		if (expected && !obj) {
 			pr_warn("Test failed: Could not find key %u\n", key);
@@ -133,7 +143,11 @@ static int __init test_rhashtable(struct rhashtable *ht)
 		obj->ptr = TEST_PTR;
 		obj->value = i * 2;
 
-		rhashtable_insert(ht, &obj->node);
+		err = rhashtable_insert_fast(ht, &obj->node, test_rht_params);
+		if (err) {
+			kfree(obj);
+			goto error;
+		}
 	}
 
 	rcu_read_lock();
@@ -173,10 +187,10 @@ static int __init test_rhashtable(struct rhashtable *ht)
 	for (i = 0; i < TEST_ENTRIES; i++) {
 		u32 key = i * 2;
 
-		obj = rhashtable_lookup(ht, &key);
+		obj = rhashtable_lookup_fast(ht, &key, test_rht_params);
 		BUG_ON(!obj);
 
-		rhashtable_remove(ht, &obj->node);
+		rhashtable_remove_fast(ht, &obj->node, test_rht_params);
 		kfree(obj);
 	}
 
@@ -195,20 +209,11 @@ static struct rhashtable ht;
 
 static int __init test_rht_init(void)
 {
-	struct rhashtable_params params = {
-		.nelem_hint = TEST_HT_SIZE,
-		.head_offset = offsetof(struct test_obj, node),
-		.key_offset = offsetof(struct test_obj, value),
-		.key_len = sizeof(int),
-		.hashfn = jhash,
-		.max_size = 2, /* we expand/shrink manually here */
-		.nulls_base = (3U << RHT_BASE_SHIFT),
-	};
 	int err;
 
 	pr_info("Running resizable hashtable tests...\n");
 
-	err = rhashtable_init(&ht, &params);
+	err = rhashtable_init(&ht, &test_rht_params);
 	if (err < 0) {
 		pr_warn("Test failed: Unable to initialize hashtable: %d\n",
 			err);
