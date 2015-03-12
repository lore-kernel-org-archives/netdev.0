From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] rhashtable: Move masking back into key_hashfn
Date: Thu, 12 Mar 2015 12:30:52 +1100
Message-ID: <E1YVrxc-0003MO-Ht@gondolin.me.apana.org.au>
References: <20150312012944.GA12857@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:37742 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbbCLBay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:30:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts commit c88455ce50ae4224d84960ce2baa53e61580df27
("rhashtable: key_hashfn() must return full hash value") because
the only user of it always masks the hash value.

Signed-off-by: Herbert Xu <herbert.xu@redhat.com>
---

 lib/rhashtable.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index b1c19c5..7661056 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -83,7 +83,8 @@ static u32 obj_raw_hashfn(struct rhashtable *ht,
 static u32 key_hashfn(struct rhashtable *ht, const struct bucket_table *tbl,
 		      const void *key, u32 len)
 {
-	return ht->p.hashfn(key, len, tbl->hash_rnd) >> HASH_RESERVED_SPACE;
+	return rht_bucket_index(tbl, ht->p.hashfn(key, len, tbl->hash_rnd) >>
+				     HASH_RESERVED_SPACE);
 }
 
 static u32 head_hashfn(struct rhashtable *ht,
@@ -622,7 +623,7 @@ void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 	tbl = rht_dereference_rcu(ht->tbl, ht);
 	hash = key_hashfn(ht, tbl, key, ht->p.key_len);
 restart:
-	rht_for_each_rcu(he, tbl, rht_bucket_index(tbl, hash)) {
+	rht_for_each_rcu(he, tbl, hash) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
 		rcu_read_unlock();
