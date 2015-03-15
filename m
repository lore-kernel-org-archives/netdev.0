From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of lookup_compare
Date: Sun, 15 Mar 2015 21:44:32 +1100
Message-ID: <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:54953 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbbCOKoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of rhashtable_lookup_compare in nft_hash is gratuitous
since the comparison function is just doing memcmp.  Furthermore,
there is cruft embedded in the comparson function that should
instead be moved into the caller of the lookup.

This patch moves that cruft over and replacces the call to
rhashtable_lookup_compare with rhashtable_lookup.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netfilter/nft_hash.c |   40 ++++++++++------------------------------
 1 file changed, 10 insertions(+), 30 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index c82df0a..1fcae5e 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -89,41 +89,21 @@ static void nft_hash_remove(const struct nft_set *set,
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
 
-	if (rhashtable_lookup_compare(priv, &elem->key,
-				      &nft_hash_compare, &arg))
-		return 0;
+	he = rhashtable_lookup(priv, &elem->key);
+	if (!he)
+		return -ENOENT;
 
-	return -ENOENT;
+	elem->cookie = he;
+	elem->flags = 0;
+	if (set->flags & NFT_SET_MAP)
+		nft_data_copy(&elem->data, he->data);
+
+	return 0;
 }
 
 static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
