From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/15] netfilter: nft_hash: restore struct nft_hash
Date: Thu, 26 Mar 2015 13:06:54 +0100
Message-ID: <1427371622-4466-8-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Following patches will add new private members, restore struct nft_hash
as preparation.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c |   37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index f9ce219..a517f84 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -23,6 +23,10 @@
 /* We target a hash table size of 4, element hint is 75% of final size */
 #define NFT_HASH_ELEMENT_HINT 3
 
+struct nft_hash {
+	struct rhashtable		ht;
+};
+
 struct nft_hash_elem {
 	struct rhash_head		node;
 	struct nft_data			key;
@@ -35,10 +39,10 @@ static bool nft_hash_lookup(const struct nft_set *set,
 			    const struct nft_data *key,
 			    struct nft_data *data)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
 
-	he = rhashtable_lookup_fast(priv, key, nft_hash_params);
+	he = rhashtable_lookup_fast(&priv->ht, key, nft_hash_params);
 	if (he && set->flags & NFT_SET_MAP)
 		nft_data_copy(data, he->data);
 
@@ -48,7 +52,7 @@ static bool nft_hash_lookup(const struct nft_set *set,
 static int nft_hash_insert(const struct nft_set *set,
 			   const struct nft_set_elem *elem)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	struct nft_hash_elem *he;
 	unsigned int size;
 	int err;
@@ -68,7 +72,7 @@ static int nft_hash_insert(const struct nft_set *set,
 	if (set->flags & NFT_SET_MAP)
 		nft_data_copy(he->data, &elem->data);
 
-	err = rhashtable_insert_fast(priv, &he->node, nft_hash_params);
+	err = rhashtable_insert_fast(&priv->ht, &he->node, nft_hash_params);
 	if (err)
 		kfree(he);
 
@@ -87,19 +91,19 @@ static void nft_hash_elem_destroy(const struct nft_set *set,
 static void nft_hash_remove(const struct nft_set *set,
 			    const struct nft_set_elem *elem)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 
-	rhashtable_remove_fast(priv, elem->cookie, nft_hash_params);
+	rhashtable_remove_fast(&priv->ht, elem->cookie, nft_hash_params);
 	synchronize_rcu();
 	kfree(elem->cookie);
 }
 
 static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	struct nft_hash_elem *he;
 
-	he = rhashtable_lookup_fast(priv, &elem->key, nft_hash_params);
+	he = rhashtable_lookup_fast(&priv->ht, &elem->key, nft_hash_params);
 	if (!he)
 		return -ENOENT;
 
@@ -114,13 +118,13 @@ static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			  struct nft_set_iter *iter)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
 	struct rhashtable_iter hti;
 	struct nft_set_elem elem;
 	int err;
 
-	err = rhashtable_walk_init(priv, &hti);
+	err = rhashtable_walk_init(&priv->ht, &hti);
 	iter->err = err;
 	if (err)
 		return;
@@ -165,7 +169,7 @@ out:
 
 static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 {
-	return sizeof(struct rhashtable);
+	return sizeof(struct nft_hash);
 }
 
 static const struct rhashtable_params nft_hash_params = {
@@ -179,13 +183,13 @@ static int nft_hash_init(const struct nft_set *set,
 			 const struct nft_set_desc *desc,
 			 const struct nlattr * const tb[])
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	struct rhashtable_params params = nft_hash_params;
 
 	params.nelem_hint = desc->size ?: NFT_HASH_ELEMENT_HINT;
 	params.key_len = set->klen;
 
-	return rhashtable_init(priv, &params);
+	return rhashtable_init(&priv->ht, &params);
 }
 
 static void nft_free_element(void *ptr, void *arg)
@@ -195,8 +199,9 @@ static void nft_free_element(void *ptr, void *arg)
 
 static void nft_hash_destroy(const struct nft_set *set)
 {
-	rhashtable_free_and_destroy(nft_set_priv(set), nft_free_element,
-				    (void *)set);
+	struct nft_hash *priv = nft_set_priv(set);
+
+	rhashtable_free_and_destroy(&priv->ht, nft_free_element, (void *)set);
 }
 
 static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
@@ -209,7 +214,7 @@ static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 		esize += FIELD_SIZEOF(struct nft_hash_elem, data[0]);
 
 	if (desc->size) {
-		est->size = sizeof(struct rhashtable) +
+		est->size = sizeof(struct nft_hash) +
 			    roundup_pow_of_two(desc->size * 4 / 3) *
 			    sizeof(struct nft_hash_elem *) +
 			    desc->size * esize;
-- 
1.7.10.4

