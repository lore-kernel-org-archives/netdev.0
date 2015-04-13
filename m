From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/21] netfilter: nf_tables: support variable sized data in nft_data_init()
Date: Mon, 13 Apr 2015 21:29:52 +0200
Message-ID: <1428953401-4838-14-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39705 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754599AbbDMT0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:26:00 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add a size argument to nft_data_init() and pass in the available space.
This will be used by the following patches to support variable sized
set element data.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    3 ++-
 net/netfilter/nf_tables_api.c     |   26 ++++++++++++++++----------
 net/netfilter/nft_bitwise.c       |    6 ++++--
 net/netfilter/nft_cmp.c           |    9 ++++++---
 net/netfilter/nft_immediate.c     |    3 ++-
 5 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 1f9b848..160577b 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -110,7 +110,8 @@ struct nft_data_desc {
 	unsigned int			len;
 };
 
-int nft_data_init(const struct nft_ctx *ctx, struct nft_data *data,
+int nft_data_init(const struct nft_ctx *ctx,
+		  struct nft_data *data, unsigned int size,
 		  struct nft_data_desc *desc, const struct nlattr *nla);
 void nft_data_uninit(const struct nft_data *data, enum nft_data_types type);
 int nft_data_dump(struct sk_buff *skb, int attr, const struct nft_data *data,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 03faf76..2b3f88f 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3299,7 +3299,8 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		timeout = set->timeout;
 	}
 
-	err = nft_data_init(ctx, &elem.key, &d1, nla[NFTA_SET_ELEM_KEY]);
+	err = nft_data_init(ctx, &elem.key, sizeof(elem.key), &d1,
+			    nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
 		goto err1;
 	err = -EINVAL;
@@ -3314,7 +3315,8 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	}
 
 	if (nla[NFTA_SET_ELEM_DATA] != NULL) {
-		err = nft_data_init(ctx, &data, &d2, nla[NFTA_SET_ELEM_DATA]);
+		err = nft_data_init(ctx, &data, sizeof(data), &d2,
+				    nla[NFTA_SET_ELEM_DATA]);
 		if (err < 0)
 			goto err2;
 
@@ -3458,7 +3460,8 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 	if (nla[NFTA_SET_ELEM_KEY] == NULL)
 		goto err1;
 
-	err = nft_data_init(ctx, &elem.key, &desc, nla[NFTA_SET_ELEM_KEY]);
+	err = nft_data_init(ctx, &elem.key, sizeof(elem.key), &desc,
+			    nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
 		goto err1;
 
@@ -4339,7 +4342,8 @@ nla_put_failure:
 	return -1;
 }
 
-static int nft_value_init(const struct nft_ctx *ctx, struct nft_data *data,
+static int nft_value_init(const struct nft_ctx *ctx,
+			  struct nft_data *data, unsigned int size,
 			  struct nft_data_desc *desc, const struct nlattr *nla)
 {
 	unsigned int len;
@@ -4347,10 +4351,10 @@ static int nft_value_init(const struct nft_ctx *ctx, struct nft_data *data,
 	len = nla_len(nla);
 	if (len == 0)
 		return -EINVAL;
-	if (len > sizeof(data->data))
+	if (len > size)
 		return -EOVERFLOW;
 
-	nla_memcpy(data->data, nla, sizeof(data->data));
+	nla_memcpy(data->data, nla, len);
 	desc->type = NFT_DATA_VALUE;
 	desc->len  = len;
 	return 0;
@@ -4363,8 +4367,7 @@ static int nft_value_dump(struct sk_buff *skb, const struct nft_data *data,
 }
 
 static const struct nla_policy nft_data_policy[NFTA_DATA_MAX + 1] = {
-	[NFTA_DATA_VALUE]	= { .type = NLA_BINARY,
-				    .len  = FIELD_SIZEOF(struct nft_data, data) },
+	[NFTA_DATA_VALUE]	= { .type = NLA_BINARY },
 	[NFTA_DATA_VERDICT]	= { .type = NLA_NESTED },
 };
 
@@ -4373,6 +4376,7 @@ static const struct nla_policy nft_data_policy[NFTA_DATA_MAX + 1] = {
  *
  *	@ctx: context of the expression using the data
  *	@data: destination struct nft_data
+ *	@size: maximum data length
  *	@desc: data description
  *	@nla: netlink attribute containing data
  *
@@ -4382,7 +4386,8 @@ static const struct nla_policy nft_data_policy[NFTA_DATA_MAX + 1] = {
  *	The caller can indicate that it only wants to accept data of type
  *	NFT_DATA_VALUE by passing NULL for the ctx argument.
  */
-int nft_data_init(const struct nft_ctx *ctx, struct nft_data *data,
+int nft_data_init(const struct nft_ctx *ctx,
+		  struct nft_data *data, unsigned int size,
 		  struct nft_data_desc *desc, const struct nlattr *nla)
 {
 	struct nlattr *tb[NFTA_DATA_MAX + 1];
@@ -4393,7 +4398,8 @@ int nft_data_init(const struct nft_ctx *ctx, struct nft_data *data,
 		return err;
 
 	if (tb[NFTA_DATA_VALUE])
-		return nft_value_init(ctx, data, desc, tb[NFTA_DATA_VALUE]);
+		return nft_value_init(ctx, data, size, desc,
+				      tb[NFTA_DATA_VALUE]);
 	if (tb[NFTA_DATA_VERDICT] && ctx != NULL)
 		return nft_verdict_init(ctx, data, desc, tb[NFTA_DATA_VERDICT]);
 	return -EINVAL;
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index f1a9be2..d71cc18 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -73,13 +73,15 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_data_init(NULL, &priv->mask, &d1, tb[NFTA_BITWISE_MASK]);
+	err = nft_data_init(NULL, &priv->mask, sizeof(priv->mask), &d1,
+			    tb[NFTA_BITWISE_MASK]);
 	if (err < 0)
 		return err;
 	if (d1.len != priv->len)
 		return -EINVAL;
 
-	err = nft_data_init(NULL, &priv->xor, &d2, tb[NFTA_BITWISE_XOR]);
+	err = nft_data_init(NULL, &priv->xor, sizeof(priv->xor), &d2,
+			    tb[NFTA_BITWISE_XOR]);
 	if (err < 0)
 		return err;
 	if (d2.len != priv->len)
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index ffaf214..e25b35d 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -75,7 +75,8 @@ static int nft_cmp_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	struct nft_data_desc desc;
 	int err;
 
-	err = nft_data_init(NULL, &priv->data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_data_init(NULL, &priv->data, sizeof(priv->data), &desc,
+			    tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 
 	priv->sreg = nft_parse_register(tb[NFTA_CMP_SREG]);
@@ -125,7 +126,8 @@ static int nft_cmp_fast_init(const struct nft_ctx *ctx,
 	u32 mask;
 	int err;
 
-	err = nft_data_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_data_init(NULL, &data, sizeof(data), &desc,
+			    tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 
 	priv->sreg = nft_parse_register(tb[NFTA_CMP_SREG]);
@@ -195,7 +197,8 @@ nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 		return ERR_PTR(-EINVAL);
 	}
 
-	err = nft_data_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_data_init(NULL, &data, sizeof(data), &desc,
+			    tb[NFTA_CMP_DATA]);
 	if (err < 0)
 		return ERR_PTR(err);
 
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 1e8e412..db3b746 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -49,7 +49,8 @@ static int nft_immediate_init(const struct nft_ctx *ctx,
 	    tb[NFTA_IMMEDIATE_DATA] == NULL)
 		return -EINVAL;
 
-	err = nft_data_init(ctx, &priv->data, &desc, tb[NFTA_IMMEDIATE_DATA]);
+	err = nft_data_init(ctx, &priv->data, sizeof(priv->data), &desc,
+			    tb[NFTA_IMMEDIATE_DATA]);
 	if (err < 0)
 		return err;
 	priv->dlen = desc.len;
-- 
1.7.10.4
