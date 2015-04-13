From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/21] netfilter: nf_tables: convert sets to u32 data pointers
Date: Mon, 13 Apr 2015 21:29:49 +0200
Message-ID: <1428953401-4838-11-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39689 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754577AbbDMTZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:25:58 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Simple conversion to use u32 pointers to the beginning of the data
area to keep follow up patches smaller.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    4 ++--
 net/netfilter/nft_hash.c          |   11 +++++------
 net/netfilter/nft_rbtree.c        |    3 +--
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index fca0b5d..efcf46d 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -231,10 +231,10 @@ struct nft_expr;
  */
 struct nft_set_ops {
 	bool				(*lookup)(const struct nft_set *set,
-						  const struct nft_data *key,
+						  const u32 *key,
 						  const struct nft_set_ext **ext);
 	bool				(*update)(struct nft_set *set,
-						  const struct nft_data *key,
+						  const u32 *key,
 						  void *(*new)(struct nft_set *,
 							       const struct nft_expr *,
 							       struct nft_regs *),
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 26ba4e1..767df41 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -36,7 +36,7 @@ struct nft_hash_elem {
 
 struct nft_hash_cmp_arg {
 	const struct nft_set		*set;
-	const struct nft_data		*key;
+	const u32			*key;
 	u8				genmask;
 };
 
@@ -71,8 +71,7 @@ static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
 	return 0;
 }
 
-static bool nft_hash_lookup(const struct nft_set *set,
-			    const struct nft_data *key,
+static bool nft_hash_lookup(const struct nft_set *set, const u32 *key,
 			    const struct nft_set_ext **ext)
 {
 	struct nft_hash *priv = nft_set_priv(set);
@@ -90,7 +89,7 @@ static bool nft_hash_lookup(const struct nft_set *set,
 	return !!he;
 }
 
-static bool nft_hash_update(struct nft_set *set, const struct nft_data *key,
+static bool nft_hash_update(struct nft_set *set, const u32 *key,
 			    void *(*new)(struct nft_set *,
 					 const struct nft_expr *,
 					 struct nft_regs *regs),
@@ -134,7 +133,7 @@ static int nft_hash_insert(const struct nft_set *set,
 	struct nft_hash_cmp_arg arg = {
 		.genmask = nft_genmask_next(read_pnet(&set->pnet)),
 		.set	 = set,
-		.key	 = &elem->key,
+		.key	 = elem->key.data,
 	};
 
 	return rhashtable_lookup_insert_key(&priv->ht, &arg, &he->node,
@@ -158,7 +157,7 @@ static void *nft_hash_deactivate(const struct nft_set *set,
 	struct nft_hash_cmp_arg arg = {
 		.genmask = nft_genmask_next(read_pnet(&set->pnet)),
 		.set	 = set,
-		.key	 = &elem->key,
+		.key	 = elem->key.data,
 	};
 
 	rcu_read_lock();
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index b398f1a..b888e0c 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -30,8 +30,7 @@ struct nft_rbtree_elem {
 };
 
 
-static bool nft_rbtree_lookup(const struct nft_set *set,
-			      const struct nft_data *key,
+static bool nft_rbtree_lookup(const struct nft_set *set, const u32 *key,
 			      const struct nft_set_ext **ext)
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
-- 
1.7.10.4
