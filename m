From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/3] rhashtable: allow lookup function to have compare function agument
Date: Mon, 13 Jul 2015 17:39:12 -0700
Message-ID: <1436834353-1851565-3-git-send-email-tom@herbertland.com>
References: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45644 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752952AbbGNAjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 20:39:39 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6E0dc7T022449
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 17:39:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vmph4rc5x-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 17:39:39 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 c872e82429c011e5a6c30002c991e86a-26cd52b0 for <netdev@vger.kernel.org>;	Mon,
 13 Jul 2015 17:39:27 -0700
In-Reply-To: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added rhashtable_lookup_fast_cmpfn which does a lookup in an rhash table
with the compare function being taken from an argument. This allows
different compare functions to be used on the same table.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rhashtable.h | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 8e27159..05171c3 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -526,9 +526,10 @@ static inline int rhashtable_compare(struct rhashtable_compare_arg *arg,
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
@@ -544,8 +545,8 @@ static inline void *rhashtable_lookup_fast(
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
@@ -563,6 +564,14 @@ restart:
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
 struct rht_insert_pos {
 	struct rhash_head __rcu *head;
 	struct rhash_head __rcu **pos;
-- 
1.8.1
