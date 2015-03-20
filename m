From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 4/7] netfilter: Convert nft_hash to inlined rhashtable
Date: Fri, 20 Mar 2015 21:57:02 +1100
Message-ID: <E1YYubu-0004ld-Op@gondolin.me.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:48019 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbCTK5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:57:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts nft_hash to the inlined rhashtable interface.

This patch also replaces the call to rhashtable_lookup_compare with
a straight rhashtable_lookup_fast because it's simply doing a memcmp
(in fact nft_hash_lookup already uses memcmp instead of nft_data_cmp).

Furthermore, the compare function is only meant to compare, it is not
supposed to have side-effects.  The current side-effect code can
simply be moved into the nft_hash_get.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netfilter/nft_hash.c |   70 +++++++++++++++++++----------------------------
 1 file changed, 29 insertions(+), 41 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index c82df0a..4585c57 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -29,6 +29,8 @@ struct nft_hash_elem {
 	struct nft_data			data[];
 };
 
+static const struct rhashtable_params nft_hash_params;
+
 static bool nft_hash_lookup(const struct nft_set *set,
 			    const struct nft_data *key,
 			    struct nft_data *data)
@@ -36,7 +38,7 @@ static bool nft_hash_lookup(const struct nft_set *set,
 	struct rhashtable *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
 
-	he = rhashtable_lookup(priv, key);
+	he = rhashtable_lookup_fast(priv, key, nft_hash_params);
 	if (he && set->flags & NFT_SET_MAP)
 		nft_data_copy(data, he->data);
 
@@ -49,6 +51,7 @@ static int nft_hash_insert(const struct nft_set *set,
 	struct rhashtable *priv = nft_set_priv(set);
 	struct nft_hash_elem *he;
 	unsigned int size;
+	int err;
 
 	if (elem->flags != 0)
 		return -EINVAL;
@@ -65,9 +68,11 @@ static int nft_hash_insert(const struct nft_set *set,
 	if (set->flags & NFT_SET_MAP)
 		nft_data_copy(he->data, &elem->data);
 
-	rhashtable_insert(priv, &he->node);
+	err = rhashtable_insert_fast(priv, &he->node, nft_hash_params);
+	if (err)
+		kfree(he);
 
-	return 0;
+	return err;
 }
 
 static void nft_hash_elem_destroy(const struct nft_set *set,
@@ -84,46 +89,26 @@ static void nft_hash_remove(const struct nft_set *set,
 {
 	struct rhashtable *priv = nft_set_priv(set);
 
-	rhashtable_remove(priv, elem->cookie);
+	rhashtable_remove_fast(priv, elem->cookie, nft_hash_params);
 	synchronize_rcu();
 	kfree(elem->cookie);
 }
 
-struct nft_compare_arg {
-	const struct nft_set *set;
-	struct nft_set_elem *elem;
-};
-
-static bool nft_hash_compare(void *ptr, void *arg)
-{
-	struct nft_hash_elem *he = ptr;
-	struct nft_compare_arg *x = arg;
-
-	if (!nft_data_cmp(&he->key, &x->elem->key, x->set->klen)) {
-		x->elem->cookie = he;
-		x->elem->flags = 0;
-		if (x->set->flags & NFT_SET_MAP)
-			nft_data_copy(&x->elem->data, he->data);
-
-		return true;
-	}
-
-	return false;
-}
-
 static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 {
 	struct rhashtable *priv = nft_set_priv(set);
-	struct nft_compare_arg arg = {
-		.set = set,
-		.elem = elem,
-	};
+	struct nft_hash_elem *he;
+
+	he = rhashtable_lookup_fast(priv, &elem->key, nft_hash_params);
+	if (!he)
+		return -ENOENT;
 
-	if (rhashtable_lookup_compare(priv, &elem->key,
-				      &nft_hash_compare, &arg))
-		return 0;
+	elem->cookie = he;
+	elem->flags = 0;
+	if (set->flags & NFT_SET_MAP)
+		nft_data_copy(&elem->data, he->data);
 
-	return -ENOENT;
+	return 0;
 }
 
 static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
@@ -181,18 +166,21 @@ static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 	return sizeof(struct rhashtable);
 }
 
+static const struct rhashtable_params nft_hash_params = {
+	.head_offset = offsetof(struct nft_hash_elem, node),
+	.key_offset = offsetof(struct nft_hash_elem, key),
+	.hashfn = jhash,
+};
+
 static int nft_hash_init(const struct nft_set *set,
 			 const struct nft_set_desc *desc,
 			 const struct nlattr * const tb[])
 {
 	struct rhashtable *priv = nft_set_priv(set);
-	struct rhashtable_params params = {
-		.nelem_hint = desc->size ? : NFT_HASH_ELEMENT_HINT,
-		.head_offset = offsetof(struct nft_hash_elem, node),
-		.key_offset = offsetof(struct nft_hash_elem, key),
-		.key_len = set->klen,
-		.hashfn = jhash,
-	};
+	struct rhashtable_params params = nft_hash_params;
+
+	params.nelem_hint = desc->size ?: NFT_HASH_ELEMENT_HINT;
+	params.key_len = set->klen;
 
 	return rhashtable_init(priv, &params);
 }
