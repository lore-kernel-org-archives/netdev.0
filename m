From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 4/6] rhashtable: abstract out function to get hash
Date: Fri, 9 Sep 2016 16:19:55 -0700
Message-ID: <1473463197-3076903-5-git-send-email-tom@herbertland.com>
References: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56324 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755540AbcIIXU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:20:26 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u89NJvVG016385
        for <netdev@vger.kernel.org>; Fri, 9 Sep 2016 16:20:26 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25c3j88tsw-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:20:26 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 fcaffea876e311e6a98f0002c992ebde-df6eca50 for <netdev@vger.kernel.org>;        Fri,
 09 Sep 2016 16:20:25 -0700
In-Reply-To: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split out most of rht_key_hashfn which is calculating the hash into
its own function. This way the hash function can be called separately to
get the hash value.

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
