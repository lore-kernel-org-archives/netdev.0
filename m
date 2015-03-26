From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/15] netfilter: nf_tables: return set extensions from ->lookup()
Date: Thu, 26 Mar 2015 13:07:00 +0100
Message-ID: <1427371622-4466-14-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Return the extension area from the ->lookup() function to allow to
consolidate common actions.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    4 +++-
 net/netfilter/nft_hash.c          |    6 +++---
 net/netfilter/nft_lookup.c        |    6 +++++-
 net/netfilter/nft_rbtree.c        |    7 +++----
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 6ac6332..f190d26 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -200,6 +200,8 @@ struct nft_set_estimate {
 	enum nft_set_class	class;
 };
 
+struct nft_set_ext;
+
 /**
  *	struct nft_set_ops - nf_tables set operations
  *
@@ -218,7 +220,7 @@ struct nft_set_estimate {
 struct nft_set_ops {
 	bool				(*lookup)(const struct nft_set *set,
 						  const struct nft_data *key,
-						  struct nft_data *data);
+						  const struct nft_set_ext **ext);
 	int				(*get)(const struct nft_set *set,
 					       struct nft_set_elem *elem);
 	int				(*insert)(const struct nft_set *set,
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 94bf25d..5bee821 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -66,7 +66,7 @@ static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
 
 static bool nft_hash_lookup(const struct nft_set *set,
 			    const struct nft_data *key,
-			    struct nft_data *data)
+			    const struct nft_set_ext **ext)
 {
 	struct nft_hash *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
@@ -76,8 +76,8 @@ static bool nft_hash_lookup(const struct nft_set *set,
 	};
 
 	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
-	if (he && set->flags & NFT_SET_MAP)
-		nft_data_copy(data, nft_set_ext_data(&he->ext));
+	if (he != NULL)
+		*ext = &he->ext;
 
 	return !!he;
 }
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 9615b8b..a5f30b8 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -31,9 +31,13 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 {
 	const struct nft_lookup *priv = nft_expr_priv(expr);
 	const struct nft_set *set = priv->set;
+	const struct nft_set_ext *ext;
 
-	if (set->ops->lookup(set, &data[priv->sreg], &data[priv->dreg]))
+	if (set->ops->lookup(set, &data[priv->sreg], &ext)) {
+		if (set->flags & NFT_SET_MAP)
+			nft_data_copy(&data[priv->dreg], nft_set_ext_data(ext));
 		return;
+	}
 	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
 }
 
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 332c6af..cbba755 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -31,7 +31,7 @@ struct nft_rbtree_elem {
 
 static bool nft_rbtree_lookup(const struct nft_set *set,
 			      const struct nft_data *key,
-			      struct nft_data *data)
+			      const struct nft_set_ext **ext)
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct nft_rbtree_elem *rbe, *interval = NULL;
@@ -55,10 +55,9 @@ found:
 			    *nft_set_ext_flags(&rbe->ext) &
 			    NFT_SET_ELEM_INTERVAL_END)
 				goto out;
-			if (set->flags & NFT_SET_MAP)
-				nft_data_copy(data, nft_set_ext_data(&rbe->ext));
-
 			spin_unlock_bh(&nft_rbtree_lock);
+
+			*ext = &rbe->ext;
 			return true;
 		}
 	}
-- 
1.7.10.4

