From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] netfilter: Use rhashtable walk iterator
Date: Wed, 04 Feb 2015 07:33:25 +1100
Message-ID: <E1YIkA1-00063n-QT@gondolin.me.apana.org.au>
References: <20150203203213.GA23177@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42102 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161144AbbBCUdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 15:33:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gets rid of the manual rhashtable walk in nft_hash
which touches rhashtable internals that should not be exposed.
It does so by using the rhashtable iterator primitives.

Note that I'm leaving nft_hash_destroy alone since it's only
invoked on shutdown and it shouldn't be affected by changes
to rhashtable internals (or at least not what I'm planning to
change).
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netfilter/nft_hash.c |   53 +++++++++++++++++++++++++++++++----------------
 1 file changed, 36 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 75887d7..61e6c40 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -130,31 +130,50 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			  struct nft_set_iter *iter)
 {
 	struct rhashtable *priv = nft_set_priv(set);
-	const struct bucket_table *tbl;
 	const struct nft_hash_elem *he;
+	struct rhashtable_iter hti;
 	struct nft_set_elem elem;
-	unsigned int i;
+	int err;
 
-	tbl = rht_dereference_rcu(priv->tbl, priv);
-	for (i = 0; i < tbl->size; i++) {
-		struct rhash_head *pos;
+	err = rhashtable_walk_init(priv, &hti);
+	iter->err = err;
+	if (err)
+		return;
+
+	err = rhashtable_walk_start(&hti);
+	if (err && err != -EAGAIN) {
+		iter->err = err;
+		goto out;
+	}
 
-		rht_for_each_entry_rcu(he, pos, tbl, i, node) {
-			if (iter->count < iter->skip)
-				goto cont;
+	while ((he = rhashtable_walk_next(&hti))) {
+		if (IS_ERR(he)) {
+			err = PTR_ERR(he);
+			if (err != -EAGAIN) {
+				iter->err = err;
+				goto out;
+			}
+		}
+
+		if (iter->count < iter->skip)
+			goto cont;
+
+		memcpy(&elem.key, &he->key, sizeof(elem.key));
+		if (set->flags & NFT_SET_MAP)
+			memcpy(&elem.data, he->data, sizeof(elem.data));
+		elem.flags = 0;
 
-			memcpy(&elem.key, &he->key, sizeof(elem.key));
-			if (set->flags & NFT_SET_MAP)
-				memcpy(&elem.data, he->data, sizeof(elem.data));
-			elem.flags = 0;
+		iter->err = iter->fn(ctx, set, iter, &elem);
+		if (iter->err < 0)
+			goto out;
 
-			iter->err = iter->fn(ctx, set, iter, &elem);
-			if (iter->err < 0)
-				return;
 cont:
-			iter->count++;
-		}
+		iter->count++;
 	}
+
+out:
+	rhashtable_walk_stop(&hti);
+	rhashtable_walk_exit(&hti);
 }
 
 static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
