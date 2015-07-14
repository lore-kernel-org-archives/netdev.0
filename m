From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 1/3] rhashtable: Allow lookup function to have compare function agument
Date: Tue, 14 Jul 2015 16:45:47 -0700
Message-ID: <1436917549-3666965-2-git-send-email-tom@herbertland.com>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <tgraf@suug.ch>,
	<herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:63551 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752558AbbGNXqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 19:46:09 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6ENfNoo021945
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:46:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vnbcsg4dm-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:46:09 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 7f830ad22a8211e59dab24be0595f910-e5fd3270 for <netdev@vger.kernel.org>;	Tue,
 14 Jul 2015 16:46:08 -0700
In-Reply-To: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added rhashtable_lookup_fast_cmpfn which does a lookup in an rhash table
with the compare function being taken from an argument. This allows
different compare functions to be used on the same table.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rhashtable.h | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 843ceca..78a4e9b 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -513,19 +513,21 @@ static inline int rhashtable_compare(struct rhashtable_compare_arg *arg,
 }
 
 /**
- * rhashtable_lookup_fast - search hash table, inlined version
+ * rhashtable_lookup_fast_cmpfn - search hash table, inlined version
  * @ht:		hash table
  * @key:	the pointer to the key
  * @params:	hash table parameters
+ * @obj_cmpfn:	compare function
  *
  * Computes the hash value for the key and traverses the bucket chain looking
  * for a entry with an identical key. The first matching entry is returned.
  *
  * Returns the first entry on which the compare function returned true.
  */
-static inline void *rhashtable_lookup_fast(
+static inline void *rhashtable_lookup_fast_cmpfn(
 	struct rhashtable *ht, const void *key,
-	const struct rhashtable_params params)
+	const struct rhashtable_params params,
+	rht_obj_cmpfn_t obj_cmpfn)
 {
 	struct rhashtable_compare_arg arg = {
 		.ht = ht,
@@ -541,8 +543,8 @@ static inline void *rhashtable_lookup_fast(
 restart:
 	hash = rht_key_hashfn(ht, tbl, key, params);
 	rht_for_each_rcu(he, tbl, hash) {
-		if (params.obj_cmpfn ?
-		    params.obj_cmpfn(&arg, rht_obj(ht, he)) :
+		if (obj_cmpfn ?
+		    obj_cmpfn(&arg, rht_obj(ht, he)) :
 		    rhashtable_compare(&arg, rht_obj(ht, he)))
 			continue;
 		rcu_read_unlock();
@@ -560,6 +562,14 @@ restart:
 	return NULL;
 }
 
+static inline void *rhashtable_lookup_fast(
+	struct rhashtable *ht, const void *key,
+	const struct rhashtable_params params)
+{
+	return rhashtable_lookup_fast_cmpfn(ht, key, params,
+					    params.obj_cmpfn);
+}
+
 /* Internal function, please use rhashtable_insert_fast() instead */
 static inline int __rhashtable_insert_fast(
 	struct rhashtable *ht, const void *key, struct rhash_head *obj,
-- 
1.8.1
