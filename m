From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/21] netfilter: nf_tables: kill nft_validate_output_register()
Date: Mon, 13 Apr 2015 21:29:43 +0200
Message-ID: <1428953401-4838-5-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

All users of nft_validate_register_store() first invoke
nft_validate_output_register(). There is in fact no use for using it
on its own, so simplify the code by folding the functionality into
nft_validate_register_store() and kill it.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h      |    1 -
 net/bridge/netfilter/nft_meta_bridge.c |   13 ++-----------
 net/netfilter/nf_tables_api.c          |   23 +++++------------------
 net/netfilter/nft_bitwise.c            |    4 ----
 net/netfilter/nft_byteorder.c          |   11 ++---------
 net/netfilter/nft_ct.c                 |    4 ----
 net/netfilter/nft_exthdr.c             |    6 +-----
 net/netfilter/nft_immediate.c          |    6 +-----
 net/netfilter/nft_lookup.c             |    4 ----
 net/netfilter/nft_meta.c               |   13 ++-----------
 net/netfilter/nft_payload.c            |    6 +-----
 11 files changed, 14 insertions(+), 77 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 7251f20..a8d4bd3 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -113,7 +113,6 @@ static inline enum nft_registers nft_type_to_reg(enum nft_data_types type)
 }
 
 int nft_validate_input_register(enum nft_registers reg);
-int nft_validate_output_register(enum nft_registers reg);
 int nft_validate_register_store(const struct nft_ctx *ctx,
 				enum nft_registers reg,
 				const struct nft_data *data,
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index ee9e0b7..54d9847 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -54,7 +54,6 @@ static int nft_meta_bridge_get_init(const struct nft_ctx *ctx,
 {
 	struct nft_meta *priv = nft_expr_priv(expr);
 	unsigned int len;
-	int err;
 
 	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
 	switch (priv->key) {
@@ -67,16 +66,8 @@ static int nft_meta_bridge_get_init(const struct nft_ctx *ctx,
 	}
 
 	priv->dreg = ntohl(nla_get_be32(tb[NFTA_META_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
-
-	err = nft_validate_register_store(ctx, priv->dreg, NULL,
-					  NFT_DATA_VALUE, len);
-	if (err < 0)
-		return err;
-
-	return 0;
+	return nft_validate_register_store(ctx, priv->dreg, NULL,
+					   NFT_DATA_VALUE, len);
 }
 
 static struct nft_expr_type nft_meta_bridge_type;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index c96070e..f01e89fe 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4140,24 +4140,6 @@ int nft_validate_input_register(enum nft_registers reg)
 EXPORT_SYMBOL_GPL(nft_validate_input_register);
 
 /**
- *	nft_validate_output_register - validate an expressions' output register
- *
- *	@reg: the register number
- *
- * 	Validate that the output register is one of the general purpose
- * 	registers or the verdict register.
- */
-int nft_validate_output_register(enum nft_registers reg)
-{
-	if (reg < NFT_REG_VERDICT)
-		return -EINVAL;
-	if (reg > NFT_REG_MAX)
-		return -ERANGE;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(nft_validate_output_register);
-
-/**
  *	nft_validate_register_store - validate an expressions' register store
  *
  *	@ctx: context of the expression performing the load
@@ -4198,10 +4180,15 @@ int nft_validate_register_store(const struct nft_ctx *ctx,
 
 		return 0;
 	default:
+		if (reg < NFT_REG_1)
+			return -EINVAL;
+		if (reg > NFT_REG_MAX)
+			return -ERANGE;
 		if (len == 0)
 			return -EINVAL;
 		if (len > FIELD_SIZEOF(struct nft_data, data))
 			return -ERANGE;
+
 		if (data != NULL && type != NFT_DATA_VALUE)
 			return -EINVAL;
 		return 0;
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index afad27c..d312052 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -71,10 +71,6 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 		return err;
 
 	priv->dreg = ntohl(nla_get_be32(tb[NFTA_BITWISE_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
-
 	err = nft_validate_register_store(ctx, priv->dreg, NULL,
 					  NFT_DATA_VALUE, priv->len);
 	if (err < 0)
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index 03bfb75..848bce0 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -115,15 +115,8 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 		return err;
 
 	priv->dreg = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
-	err = nft_validate_register_store(ctx, priv->dreg, NULL,
-					  NFT_DATA_VALUE, priv->len);
-	if (err < 0)
-		return err;
-
-	return 0;
+	return nft_validate_register_store(ctx, priv->dreg, NULL,
+					   NFT_DATA_VALUE, priv->len);
 }
 
 static int nft_byteorder_dump(struct sk_buff *skb, const struct nft_expr *expr)
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index e23ddb6..d85f9ad 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -307,10 +307,6 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 	}
 
 	priv->dreg = ntohl(nla_get_be32(tb[NFTA_CT_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
-
 	err = nft_validate_register_store(ctx, priv->dreg, NULL,
 					  NFT_DATA_VALUE, len);
 	if (err < 0)
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index ab16a38..8c4981c 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -58,7 +58,6 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
-	int err;
 
 	if (tb[NFTA_EXTHDR_DREG] == NULL ||
 	    tb[NFTA_EXTHDR_TYPE] == NULL ||
@@ -69,11 +68,8 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 	priv->type   = nla_get_u8(tb[NFTA_EXTHDR_TYPE]);
 	priv->offset = ntohl(nla_get_be32(tb[NFTA_EXTHDR_OFFSET]));
 	priv->len    = ntohl(nla_get_be32(tb[NFTA_EXTHDR_LEN]));
+	priv->dreg   = ntohl(nla_get_be32(tb[NFTA_EXTHDR_DREG]));
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_EXTHDR_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, priv->len);
 }
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index d058a93..a164c04 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -49,16 +49,12 @@ static int nft_immediate_init(const struct nft_ctx *ctx,
 	    tb[NFTA_IMMEDIATE_DATA] == NULL)
 		return -EINVAL;
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_IMMEDIATE_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
-
 	err = nft_data_init(ctx, &priv->data, &desc, tb[NFTA_IMMEDIATE_DATA]);
 	if (err < 0)
 		return err;
 	priv->dlen = desc.len;
 
+	priv->dreg = ntohl(nla_get_be32(tb[NFTA_IMMEDIATE_DREG]));
 	err = nft_validate_register_store(ctx, priv->dreg, &priv->data,
 					  desc.type, desc.len);
 	if (err < 0)
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 3e4d8ef..3574543 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -80,10 +80,6 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 			return -EINVAL;
 
 		priv->dreg = ntohl(nla_get_be32(tb[NFTA_LOOKUP_DREG]));
-		err = nft_validate_output_register(priv->dreg);
-		if (err < 0)
-			return err;
-
 		err = nft_validate_register_store(ctx, priv->dreg, NULL,
 						  set->dtype, set->dlen);
 		if (err < 0)
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index b733755..fbaee1d 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -218,7 +218,6 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 {
 	struct nft_meta *priv = nft_expr_priv(expr);
 	unsigned int len;
-	int err;
 
 	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
 	switch (priv->key) {
@@ -258,16 +257,8 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 	}
 
 	priv->dreg = ntohl(nla_get_be32(tb[NFTA_META_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
-
-	err = nft_validate_register_store(ctx, priv->dreg, NULL,
-					  NFT_DATA_VALUE, len);
-	if (err < 0)
-		return err;
-
-	return 0;
+	return nft_validate_register_store(ctx, priv->dreg, NULL,
+					   NFT_DATA_VALUE, len);
 }
 EXPORT_SYMBOL_GPL(nft_meta_get_init);
 
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 9c7ad4b..b2a9ef9 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -62,16 +62,12 @@ static int nft_payload_init(const struct nft_ctx *ctx,
 			    const struct nlattr * const tb[])
 {
 	struct nft_payload *priv = nft_expr_priv(expr);
-	int err;
 
 	priv->base   = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_BASE]));
 	priv->offset = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_OFFSET]));
 	priv->len    = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_LEN]));
+	priv->dreg   = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_DREG]));
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_DREG]));
-	err = nft_validate_output_register(priv->dreg);
-	if (err < 0)
-		return err;
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, priv->len);
 }
-- 
1.7.10.4

