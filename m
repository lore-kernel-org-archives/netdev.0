From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/21] netfilter: nf_tables: kill nft_data_cmp()
Date: Mon, 13 Apr 2015 21:29:48 +0200
Message-ID: <1428953401-4838-10-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39681 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754403AbbDMTZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:25:57 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Only needlessly complicates things due to requiring specific argument
types. Use memcmp directly.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    7 -------
 net/netfilter/nft_cmp.c           |    2 +-
 net/netfilter/nft_hash.c          |    2 +-
 net/netfilter/nft_rbtree.c        |   11 +++++------
 4 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 81cd816..fca0b5d 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -69,13 +69,6 @@ struct nft_regs {
 	};
 };
 
-static inline int nft_data_cmp(const struct nft_data *d1,
-			       const struct nft_data *d2,
-			       unsigned int len)
-{
-	return memcmp(d1->data, d2->data, len);
-}
-
 static inline void nft_data_copy(struct nft_data *dst,
 				 const struct nft_data *src)
 {
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 59391e6..b7e1c58 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -31,7 +31,7 @@ static void nft_cmp_eval(const struct nft_expr *expr,
 	const struct nft_cmp_expr *priv = nft_expr_priv(expr);
 	int d;
 
-	d = nft_data_cmp(&regs->data[priv->sreg], &priv->data, priv->len);
+	d = memcmp(&regs->data[priv->sreg], &priv->data, priv->len);
 	switch (priv->op) {
 	case NFT_CMP_EQ:
 		if (d != 0)
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index b1101f7..26ba4e1 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -62,7 +62,7 @@ static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
 	const struct nft_hash_cmp_arg *x = arg->key;
 	const struct nft_hash_elem *he = ptr;
 
-	if (nft_data_cmp(nft_set_ext_key(&he->ext), x->key, x->set->klen))
+	if (memcmp(nft_set_ext_key(&he->ext), x->key, x->set->klen))
 		return 1;
 	if (nft_set_elem_expired(&he->ext))
 		return 1;
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 42d0ca4..b398f1a 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -45,7 +45,7 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
-		d = nft_data_cmp(nft_set_ext_key(&rbe->ext), key, set->klen);
+		d = memcmp(nft_set_ext_key(&rbe->ext), key, set->klen);
 		if (d < 0) {
 			parent = parent->rb_left;
 			interval = rbe;
@@ -91,9 +91,9 @@ static int __nft_rbtree_insert(const struct nft_set *set,
 	while (*p != NULL) {
 		parent = *p;
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
-		d = nft_data_cmp(nft_set_ext_key(&rbe->ext),
-				 nft_set_ext_key(&new->ext),
-				 set->klen);
+		d = memcmp(nft_set_ext_key(&rbe->ext),
+			   nft_set_ext_key(&new->ext),
+			   set->klen);
 		if (d < 0)
 			p = &parent->rb_left;
 		else if (d > 0)
@@ -153,8 +153,7 @@ static void *nft_rbtree_deactivate(const struct nft_set *set,
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
-		d = nft_data_cmp(nft_set_ext_key(&rbe->ext), &elem->key,
-				 set->klen);
+		d = memcmp(nft_set_ext_key(&rbe->ext), &elem->key, set->klen);
 		if (d < 0)
 			parent = parent->rb_left;
 		else if (d > 0)
-- 
1.7.10.4
