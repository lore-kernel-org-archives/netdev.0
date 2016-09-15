From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 5/7] rhashtable: abstract out function to get hash
Date: Thu, 15 Sep 2016 14:19:19 -0700
Message-ID: <1473974361-2275254-6-git-send-email-tom@herbertland.com>
References: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <roopa@cumulusnetworks.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59739 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755676AbcIOVTl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 17:19:41 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FL9M8V004190
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 14:19:40 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25g21krnaf-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 14:19:40 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 1bbdc50a7b8a11e692b624be05956610-7afe0a50 for <netdev@vger.kernel.org>;        Thu,
 15 Sep 2016 14:19:38 -0700
In-Reply-To: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
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
