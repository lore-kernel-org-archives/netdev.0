From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 5/7] rhashtable: abstract out function to get hash
Date: Wed, 14 Sep 2016 16:22:54 -0700
Message-ID: <1473895376-347096-6-git-send-email-tom@herbertland.com>
References: <1473895376-347096-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tgraf@suug.ch>, <roopa@cumulusnetworks.com>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48161 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756385AbcINXX1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 19:23:27 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8ENLsP9018429
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 16:23:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 25f0w26707-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 16:23:25 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 32a2c0b27ad211e692ea0002c9dfb610-1d5e3a50 for <netdev@vger.kernel.org>;        Wed,
 14 Sep 2016 16:23:09 -0700
In-Reply-To: <1473895376-347096-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split out most of rht_key_hashfn which is calculating the hash into
its own function. This way the hash function can be called separately to
get the hash value.

Acked-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rhashtable.h | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index fd82584..e398a62 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -208,34 +208,42 @@ static inline unsigned int rht_bucket_index(const struct bucket_table *tbl,
 	return (hash >> RHT_HASH_RESERVED_SPACE) & (tbl->size - 1);
 }
 
-static inline unsigned int rht_key_hashfn(
-	struct rhashtable *ht, const struct bucket_table *tbl,
-	const void *key, const struct rhashtable_params params)
+static inline unsigned int rht_key_get_hash(struct rhashtable *ht,
+	const void *key, const struct rhashtable_params params,
+	unsigned int hash_rnd)
 {
 	unsigned int hash;
 
 	/* params must be equal to ht->p if it isn't constant. */
 	if (!__builtin_constant_p(params.key_len))
-		hash = ht->p.hashfn(key, ht->key_len, tbl->hash_rnd);
+		hash = ht->p.hashfn(key, ht->key_len, hash_rnd);
 	else if (params.key_len) {
 		unsigned int key_len = params.key_len;
 
 		if (params.hashfn)
-			hash = params.hashfn(key, key_len, tbl->hash_rnd);
+			hash = params.hashfn(key, key_len, hash_rnd);
 		else if (key_len & (sizeof(u32) - 1))
-			hash = jhash(key, key_len, tbl->hash_rnd);
+			hash = jhash(key, key_len, hash_rnd);
 		else
-			hash = jhash2(key, key_len / sizeof(u32),
-				      tbl->hash_rnd);
+			hash = jhash2(key, key_len / sizeof(u32), hash_rnd);
 	} else {
 		unsigned int key_len = ht->p.key_len;
 
 		if (params.hashfn)
-			hash = params.hashfn(key, key_len, tbl->hash_rnd);
+			hash = params.hashfn(key, key_len, hash_rnd);
 		else
-			hash = jhash(key, key_len, tbl->hash_rnd);
+			hash = jhash(key, key_len, hash_rnd);
 	}
 
+	return hash;
+}
+
+static inline unsigned int rht_key_hashfn(
+	struct rhashtable *ht, const struct bucket_table *tbl,
+	const void *key, const struct rhashtable_params params)
+{
+	unsigned int hash = rht_key_get_hash(ht, key, params, tbl->hash_rnd);
+
 	return rht_bucket_index(tbl, hash);
 }
 
-- 
2.8.0.rc2
