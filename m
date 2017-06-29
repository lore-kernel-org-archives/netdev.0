From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/29] netfilter: nft_set_hash: add lookup variant for fixed size hashtable
Date: Fri, 30 Jun 2017 00:53:16 +0200
Message-ID: <1498776807-11124-19-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides a faster variant of the lookup function for 2 and 4
byte keys. Optimizing the one byte case is not worth, as the set backend
selection will always select the bitmap set type for such case.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_hash.c | 60 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 58 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index b2eab94362d6..0fa01d772c5e 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -409,6 +409,38 @@ static bool nft_hash_lookup(const struct net *net, const struct nft_set *set,
 	return false;
 }
 
+/* nft_hash_select_ops() makes sure key size can be either 2 or 4 bytes . */
+static inline u32 nft_hash_key(const u32 *key, u32 klen)
+{
+	if (klen == 4)
+		return *key;
+
+	return *(u16 *)key;
+}
+
+static bool nft_hash_lookup_fast(const struct net *net,
+				 const struct nft_set *set,
+				 const u32 *key, const struct nft_set_ext **ext)
+{
+	struct nft_hash *priv = nft_set_priv(set);
+	u8 genmask = nft_genmask_cur(net);
+	const struct nft_hash_elem *he;
+	u32 hash, k1, k2;
+
+	k1 = nft_hash_key(key, set->klen);
+	hash = jhash_1word(k1, priv->seed);
+	hash = reciprocal_scale(hash, priv->buckets);
+	hlist_for_each_entry_rcu(he, &priv->table[hash], node) {
+		k2 = nft_hash_key(nft_set_ext_key(&he->ext)->data, set->klen);
+		if (k1 == k2 &&
+		    nft_set_elem_active(&he->ext, genmask)) {
+			*ext = &he->ext;
+			return true;
+		}
+	}
+	return false;
+}
+
 static int nft_hash_insert(const struct net *net, const struct nft_set *set,
 			   const struct nft_set_elem *elem,
 			   struct nft_set_ext **ext)
@@ -588,12 +620,36 @@ static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.features	= NFT_SET_MAP | NFT_SET_OBJECT,
 };
 
+static struct nft_set_ops nft_hash_fast_ops __read_mostly = {
+	.type		= &nft_hash_type,
+	.privsize       = nft_hash_privsize,
+	.elemsize	= offsetof(struct nft_hash_elem, ext),
+	.estimate	= nft_hash_estimate,
+	.init		= nft_hash_init,
+	.destroy	= nft_hash_destroy,
+	.insert		= nft_hash_insert,
+	.activate	= nft_hash_activate,
+	.deactivate	= nft_hash_deactivate,
+	.flush		= nft_hash_flush,
+	.remove		= nft_hash_remove,
+	.lookup		= nft_hash_lookup_fast,
+	.walk		= nft_hash_walk,
+	.features	= NFT_SET_MAP | NFT_SET_OBJECT,
+};
+
 static const struct nft_set_ops *
 nft_hash_select_ops(const struct nft_ctx *ctx, const struct nft_set_desc *desc,
 		    u32 flags)
 {
-	if (desc->size)
-		return &nft_hash_ops;
+	if (desc->size) {
+		switch (desc->klen) {
+		case 2:
+		case 4:
+			return &nft_hash_fast_ops;
+		default:
+			return &nft_hash_ops;
+		}
+	}
 
 	return &nft_rhash_ops;
 }
-- 
2.1.4

