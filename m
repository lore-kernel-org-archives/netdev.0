From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 5/9] netfilter: nf_tables: add nft_value_init
Date: Tue, 11 Mar 2014 10:19:16 +0100
Message-ID: <1394529560-3490-6-git-send-email-pablo@netfilter.org>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This new function replaces several calls of nft_data_init which
rely on the ctx parameter to know whether the verdict data is
possible or not. This will allows us to pass context during data
initialization, which is required by new classifiers.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c     |   51 ++++++++++++++++++++++++-------------
 net/netfilter/nft_bitwise.c       |    4 +--
 net/netfilter/nft_cmp.c           |    6 ++---
 4 files changed, 40 insertions(+), 23 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index e6bc14d..696a916 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -96,6 +96,8 @@ struct nft_data_desc {
 
 int nft_data_init(const struct nft_ctx *ctx, struct nft_data *data,
 		  struct nft_data_desc *desc, const struct nlattr *nla);
+int nft_value_init(const struct nft_ctx *ctx, struct nft_data *data,
+		   struct nft_data_desc *desc, const struct nlattr *nla);
 void nft_data_uninit(const struct nft_data *data, enum nft_data_types type);
 int nft_data_dump(struct sk_buff *skb, int attr, const struct nft_data *data,
 		  enum nft_data_types type, unsigned int len);
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 33045a5..9879f23 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2760,11 +2760,11 @@ static int nft_add_set_elem(const struct nft_ctx *ctx, struct nft_set *set,
 			return -EINVAL;
 	}
 
-	err = nft_data_init(ctx, &elem.key, &d1, nla[NFTA_SET_ELEM_KEY]);
+	err = nft_value_init(ctx, &elem.key, &d1, nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
 		goto err1;
 	err = -EINVAL;
-	if (d1.type != NFT_DATA_VALUE || d1.len != set->klen)
+	if (d1.len != set->klen)
 		goto err2;
 
 	err = -EEXIST;
@@ -2854,12 +2854,12 @@ static int nft_del_setelem(const struct nft_ctx *ctx, struct nft_set *set,
 	if (nla[NFTA_SET_ELEM_KEY] == NULL)
 		goto err1;
 
-	err = nft_data_init(ctx, &elem.key, &desc, nla[NFTA_SET_ELEM_KEY]);
+	err = nft_value_init(ctx, &elem.key, &desc, nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
 		goto err1;
 
 	err = -EINVAL;
-	if (desc.type != NFT_DATA_VALUE || desc.len != set->klen)
+	if (desc.len != set->klen)
 		goto err2;
 
 	err = set->ops->get(set, &elem);
@@ -3256,8 +3256,9 @@ nla_put_failure:
 	return -1;
 }
 
-static int nft_value_init(const struct nft_ctx *ctx, struct nft_data *data,
-			  struct nft_data_desc *desc, const struct nlattr *nla)
+static int nft_do_value_init(const struct nft_ctx *ctx, struct nft_data *data,
+			     struct nft_data_desc *desc,
+			     const struct nlattr *nla)
 {
 	unsigned int len;
 
@@ -3285,6 +3286,24 @@ static const struct nla_policy nft_data_policy[NFTA_DATA_MAX + 1] = {
 	[NFTA_DATA_VERDICT]	= { .type = NLA_NESTED },
 };
 
+static int nft_do_data_init(const struct nft_ctx *ctx, struct nft_data *data,
+			    struct nft_data_desc *desc,
+			    const struct nlattr *nla, bool allow_verdict)
+{
+	struct nlattr *tb[NFTA_DATA_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(tb, NFTA_DATA_MAX, nla, nft_data_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[NFTA_DATA_VALUE])
+		return nft_do_value_init(ctx, data, desc, tb[NFTA_DATA_VALUE]);
+	if (tb[NFTA_DATA_VERDICT] && allow_verdict)
+		return nft_verdict_init(ctx, data, desc, tb[NFTA_DATA_VERDICT]);
+	return -EINVAL;
+}
+
 /**
  *	nft_data_init - parse nf_tables data netlink attributes
  *
@@ -3302,21 +3321,17 @@ static const struct nla_policy nft_data_policy[NFTA_DATA_MAX + 1] = {
 int nft_data_init(const struct nft_ctx *ctx, struct nft_data *data,
 		  struct nft_data_desc *desc, const struct nlattr *nla)
 {
-	struct nlattr *tb[NFTA_DATA_MAX + 1];
-	int err;
-
-	err = nla_parse_nested(tb, NFTA_DATA_MAX, nla, nft_data_policy);
-	if (err < 0)
-		return err;
-
-	if (tb[NFTA_DATA_VALUE])
-		return nft_value_init(ctx, data, desc, tb[NFTA_DATA_VALUE]);
-	if (tb[NFTA_DATA_VERDICT] && ctx != NULL)
-		return nft_verdict_init(ctx, data, desc, tb[NFTA_DATA_VERDICT]);
-	return -EINVAL;
+	return nft_do_data_init(ctx, data, desc, nla, true);
 }
 EXPORT_SYMBOL_GPL(nft_data_init);
 
+int nft_value_init(const struct nft_ctx *ctx, struct nft_data *data,
+		   struct nft_data_desc *desc, const struct nlattr *nla)
+{
+	return nft_do_data_init(ctx, data, desc, nla, false);
+}
+EXPORT_SYMBOL_GPL(nft_value_init);
+
 /**
  *	nft_data_uninit - release a nft_data item
  *
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 4fb6ee2..5f944fb 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -78,13 +78,13 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 
 	priv->len = ntohl(nla_get_be32(tb[NFTA_BITWISE_LEN]));
 
-	err = nft_data_init(NULL, &priv->mask, &d1, tb[NFTA_BITWISE_MASK]);
+	err = nft_value_init(NULL, &priv->mask, &d1, tb[NFTA_BITWISE_MASK]);
 	if (err < 0)
 		return err;
 	if (d1.len != priv->len)
 		return -EINVAL;
 
-	err = nft_data_init(NULL, &priv->xor, &d2, tb[NFTA_BITWISE_XOR]);
+	err = nft_value_init(NULL, &priv->xor, &d2, tb[NFTA_BITWISE_XOR]);
 	if (err < 0)
 		return err;
 	if (d2.len != priv->len)
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 954925d..7758c1c 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -78,7 +78,7 @@ static int nft_cmp_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
 	priv->op = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
 
-	err = nft_data_init(NULL, &priv->data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_value_init(NULL, &priv->data, &desc, tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 
 	priv->len = desc.len;
@@ -124,7 +124,7 @@ static int nft_cmp_fast_init(const struct nft_ctx *ctx,
 
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
 
-	err = nft_data_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_value_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 	desc.len *= BITS_PER_BYTE;
 
@@ -194,7 +194,7 @@ nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 		return ERR_PTR(-EINVAL);
 	}
 
-	err = nft_data_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_value_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
 	if (err < 0)
 		return ERR_PTR(err);
 
-- 
1.7.10.4

