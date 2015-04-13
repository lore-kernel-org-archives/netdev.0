From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/21] netfilter: nf_tables: validate len in nft_validate_data_load()
Date: Mon, 13 Apr 2015 21:29:40 +0200
Message-ID: <1428953401-4838-2-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

For values spanning multiple registers, we need to validate that enough
space is available from the destination register onwards. Add a len
argument to nft_validate_data_load() and consolidate the existing length
validations in preparation of that.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h      |    2 +-
 net/bridge/netfilter/nft_meta_bridge.c |    5 +++-
 net/netfilter/nf_tables_api.c          |   18 ++++++++----
 net/netfilter/nft_bitwise.c            |    8 ++++--
 net/netfilter/nft_byteorder.c          |   27 +++++++++---------
 net/netfilter/nft_ct.c                 |   48 +++++++++++++++++++++++++++-----
 net/netfilter/nft_exthdr.c             |    6 ++--
 net/netfilter/nft_immediate.c          |    3 +-
 net/netfilter/nft_meta.c               |   19 +++++++++----
 net/netfilter/nft_payload.c            |    7 ++---
 10 files changed, 97 insertions(+), 46 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index d6a2f0e..f491243 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -116,7 +116,7 @@ int nft_validate_input_register(enum nft_registers reg);
 int nft_validate_output_register(enum nft_registers reg);
 int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
 			   const struct nft_data *data,
-			   enum nft_data_types type);
+			   enum nft_data_types type, unsigned int len);
 
 
 /**
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 4f02109..2011b89 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -53,12 +53,14 @@ static int nft_meta_bridge_get_init(const struct nft_ctx *ctx,
 				    const struct nlattr * const tb[])
 {
 	struct nft_meta *priv = nft_expr_priv(expr);
+	unsigned int len;
 	int err;
 
 	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
 	switch (priv->key) {
 	case NFT_META_BRI_IIFNAME:
 	case NFT_META_BRI_OIFNAME:
+		len = IFNAMSIZ;
 		break;
 	default:
 		return nft_meta_get_init(ctx, expr, tb);
@@ -69,7 +71,8 @@ static int nft_meta_bridge_get_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
+	err = nft_validate_data_load(ctx, priv->dreg, NULL,
+				     NFT_DATA_VALUE, len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0b96fa0..564f9ed 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2799,7 +2799,8 @@ static int nf_tables_bind_check_setelem(const struct nft_ctx *ctx,
 	dreg = nft_type_to_reg(set->dtype);
 	return nft_validate_data_load(ctx, dreg, nft_set_ext_data(ext),
 				      set->dtype == NFT_DATA_VERDICT ?
-				      NFT_DATA_VERDICT : NFT_DATA_VALUE);
+				      NFT_DATA_VERDICT : NFT_DATA_VALUE,
+				      set->dlen);
 }
 
 int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
@@ -3334,7 +3335,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 				continue;
 
 			err = nft_validate_data_load(&bind_ctx, dreg,
-						     &data, d2.type);
+						     &data, d2.type, d2.len);
 			if (err < 0)
 				goto err3;
 		}
@@ -4162,15 +4163,16 @@ EXPORT_SYMBOL_GPL(nft_validate_output_register);
  * 	@reg: the destination register number
  * 	@data: the data to load
  * 	@type: the data type
+ * 	@len: the length of the data
  *
  * 	Validate that a data load uses the appropriate data type for
- * 	the destination register. A value of NULL for the data means
- * 	that its runtime gathered data, which is always of type
- * 	NFT_DATA_VALUE.
+ * 	the destination register and the length is within the bounds.
+ * 	A value of NULL for the data means that its runtime gathered
+ * 	data, which is always of type NFT_DATA_VALUE.
  */
 int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
 			   const struct nft_data *data,
-			   enum nft_data_types type)
+			   enum nft_data_types type, unsigned int len)
 {
 	int err;
 
@@ -4193,6 +4195,10 @@ int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
 
 		return 0;
 	default:
+		if (len == 0)
+			return -EINVAL;
+		if (len > FIELD_SIZEOF(struct nft_data, data))
+			return -ERANGE;
 		if (data != NULL && type != NFT_DATA_VALUE)
 			return -EINVAL;
 		return 0;
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 4fb6ee2..fcd951f 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -63,6 +63,8 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 	    tb[NFTA_BITWISE_XOR] == NULL)
 		return -EINVAL;
 
+	priv->len = ntohl(nla_get_be32(tb[NFTA_BITWISE_LEN]));
+
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_BITWISE_SREG]));
 	err = nft_validate_input_register(priv->sreg);
 	if (err < 0)
@@ -72,12 +74,12 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 	err = nft_validate_output_register(priv->dreg);
 	if (err < 0)
 		return err;
-	err = nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
+
+	err = nft_validate_data_load(ctx, priv->dreg, NULL,
+				     NFT_DATA_VALUE, priv->len);
 	if (err < 0)
 		return err;
 
-	priv->len = ntohl(nla_get_be32(tb[NFTA_BITWISE_LEN]));
-
 	err = nft_data_init(NULL, &priv->mask, &d1, tb[NFTA_BITWISE_MASK]);
 	if (err < 0)
 		return err;
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index c39ed8d..183f133 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -87,19 +87,6 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 	    tb[NFTA_BYTEORDER_OP] == NULL)
 		return -EINVAL;
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_SREG]));
-	err = nft_validate_input_register(priv->sreg);
-	if (err < 0)
-		return err;
-
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
-	err = nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
-	if (err < 0)
-		return err;
-
 	priv->op = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_OP]));
 	switch (priv->op) {
 	case NFT_BYTEORDER_NTOH:
@@ -122,6 +109,20 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 		return -EINVAL;
 	}
 
+	priv->sreg = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_SREG]));
+	err = nft_validate_input_register(priv->sreg);
+	if (err < 0)
+		return err;
+
+	priv->dreg = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_DREG]));
+	err = nft_validate_output_register(priv->dreg);
+	if (err < 0)
+		return err;
+	err = nft_validate_data_load(ctx, priv->dreg, NULL,
+				     NFT_DATA_VALUE, priv->len);
+	if (err < 0)
+		return err;
+
 	return 0;
 }
 
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 18d520e..ce368de 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -95,8 +95,6 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		helper = rcu_dereference(help->helper);
 		if (helper == NULL)
 			goto err;
-		if (strlen(helper->name) >= sizeof(dest->data))
-			goto err;
 		strncpy((char *)dest->data, helper->name, sizeof(dest->data));
 		return;
 #ifdef CONFIG_NF_CONNTRACK_LABELS
@@ -109,9 +107,7 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 			return;
 		}
 
-		BUILD_BUG_ON(NF_CT_LABELS_MAX_SIZE > sizeof(dest->data));
 		size = labels->words * sizeof(long);
-
 		memcpy(dest->data, labels->bits, size);
 		if (size < sizeof(dest->data))
 			memset(((char *) dest->data) + size, 0,
@@ -228,12 +224,17 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
 	struct nft_ct *priv = nft_expr_priv(expr);
+	unsigned int len;
 	int err;
 
 	priv->key = ntohl(nla_get_be32(tb[NFTA_CT_KEY]));
 	switch (priv->key) {
-	case NFT_CT_STATE:
 	case NFT_CT_DIRECTION:
+		if (tb[NFTA_CT_DIRECTION] != NULL)
+			return -EINVAL;
+		len = sizeof(u8);
+		break;
+	case NFT_CT_STATE:
 	case NFT_CT_STATUS:
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	case NFT_CT_MARK:
@@ -241,22 +242,54 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	case NFT_CT_SECMARK:
 #endif
+	case NFT_CT_EXPIRATION:
+		if (tb[NFTA_CT_DIRECTION] != NULL)
+			return -EINVAL;
+		len = sizeof(u32);
+		break;
 #ifdef CONFIG_NF_CONNTRACK_LABELS
 	case NFT_CT_LABELS:
+		if (tb[NFTA_CT_DIRECTION] != NULL)
+			return -EINVAL;
+		len = NF_CT_LABELS_MAX_SIZE;
+		break;
 #endif
-	case NFT_CT_EXPIRATION:
 	case NFT_CT_HELPER:
 		if (tb[NFTA_CT_DIRECTION] != NULL)
 			return -EINVAL;
+		len = NF_CT_HELPER_NAME_LEN;
 		break;
+
 	case NFT_CT_L3PROTOCOL:
 	case NFT_CT_PROTOCOL:
+		if (tb[NFTA_CT_DIRECTION] == NULL)
+			return -EINVAL;
+		len = sizeof(u8);
+		break;
 	case NFT_CT_SRC:
 	case NFT_CT_DST:
+		if (tb[NFTA_CT_DIRECTION] == NULL)
+			return -EINVAL;
+
+		switch (ctx->afi->family) {
+		case NFPROTO_IPV4:
+			len = FIELD_SIZEOF(struct nf_conntrack_tuple,
+					   src.u3.ip);
+			break;
+		case NFPROTO_IPV6:
+		case NFPROTO_INET:
+			len = FIELD_SIZEOF(struct nf_conntrack_tuple,
+					   src.u3.ip6);
+			break;
+		default:
+			return -EAFNOSUPPORT;
+		}
+		break;
 	case NFT_CT_PROTO_SRC:
 	case NFT_CT_PROTO_DST:
 		if (tb[NFTA_CT_DIRECTION] == NULL)
 			return -EINVAL;
+		len = FIELD_SIZEOF(struct nf_conntrack_tuple, src.u.all);
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -278,7 +311,8 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
+	err = nft_validate_data_load(ctx, priv->dreg, NULL,
+				     NFT_DATA_VALUE, len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 55c939f..a0a3227 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -69,15 +69,13 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 	priv->type   = nla_get_u8(tb[NFTA_EXTHDR_TYPE]);
 	priv->offset = ntohl(nla_get_be32(tb[NFTA_EXTHDR_OFFSET]));
 	priv->len    = ntohl(nla_get_be32(tb[NFTA_EXTHDR_LEN]));
-	if (priv->len == 0 ||
-	    priv->len > FIELD_SIZEOF(struct nft_data, data))
-		return -EINVAL;
 
 	priv->dreg = ntohl(nla_get_be32(tb[NFTA_EXTHDR_DREG]));
 	err = nft_validate_output_register(priv->dreg);
 	if (err < 0)
 		return err;
-	return nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
+	return nft_validate_data_load(ctx, priv->dreg, NULL,
+				      NFT_DATA_VALUE, priv->len);
 }
 
 static int nft_exthdr_dump(struct sk_buff *skb, const struct nft_expr *expr)
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 810385e..1970d8d 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -59,7 +59,8 @@ static int nft_immediate_init(const struct nft_ctx *ctx,
 		return err;
 	priv->dlen = desc.len;
 
-	err = nft_validate_data_load(ctx, priv->dreg, &priv->data, desc.type);
+	err = nft_validate_data_load(ctx, priv->dreg, &priv->data,
+				     desc.type, desc.len);
 	if (err < 0)
 		goto err1;
 
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index d79ce88..d4bdd77 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -217,22 +217,23 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 		      const struct nlattr * const tb[])
 {
 	struct nft_meta *priv = nft_expr_priv(expr);
+	unsigned int len;
 	int err;
 
 	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
 	switch (priv->key) {
-	case NFT_META_LEN:
 	case NFT_META_PROTOCOL:
+	case NFT_META_IIFTYPE:
+	case NFT_META_OIFTYPE:
+		len = sizeof(u16);
+		break;
 	case NFT_META_NFPROTO:
 	case NFT_META_L4PROTO:
+	case NFT_META_LEN:
 	case NFT_META_PRIORITY:
 	case NFT_META_MARK:
 	case NFT_META_IIF:
 	case NFT_META_OIF:
-	case NFT_META_IIFNAME:
-	case NFT_META_OIFNAME:
-	case NFT_META_IIFTYPE:
-	case NFT_META_OIFTYPE:
 	case NFT_META_SKUID:
 	case NFT_META_SKGID:
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -246,6 +247,11 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 	case NFT_META_IIFGROUP:
 	case NFT_META_OIFGROUP:
 	case NFT_META_CGROUP:
+		len = sizeof(u32);
+		break;
+	case NFT_META_IIFNAME:
+	case NFT_META_OIFNAME:
+		len = IFNAMSIZ;
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -256,7 +262,8 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
+	err = nft_validate_data_load(ctx, priv->dreg, NULL,
+				     NFT_DATA_VALUE, len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 85daa84..7bed3e0 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -72,7 +72,8 @@ static int nft_payload_init(const struct nft_ctx *ctx,
 	err = nft_validate_output_register(priv->dreg);
 	if (err < 0)
 		return err;
-	return nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
+	return nft_validate_data_load(ctx, priv->dreg, NULL,
+				      NFT_DATA_VALUE, priv->len);
 }
 
 static int nft_payload_dump(struct sk_buff *skb, const struct nft_expr *expr)
@@ -131,9 +132,7 @@ nft_payload_select_ops(const struct nft_ctx *ctx,
 	}
 
 	offset = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_OFFSET]));
-	len = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_LEN]));
-	if (len == 0 || len > FIELD_SIZEOF(struct nft_data, data))
-		return ERR_PTR(-EINVAL);
+	len    = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_LEN]));
 
 	if (len <= 4 && is_power_of_2(len) && IS_ALIGNED(offset, len) &&
 	    base != NFT_PAYLOAD_LL_HEADER)
-- 
1.7.10.4

