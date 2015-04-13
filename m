From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/21] netfilter: nf_tables: rename nft_validate_data_load()
Date: Mon, 13 Apr 2015 21:29:41 +0200
Message-ID: <1428953401-4838-3-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The existing name is ambiguous, data is loaded as well when we read from
a register. Rename to nft_validate_register_store() for clarity and
consistency with the upcoming patch to introduce its counterpart,
nft_validate_register_load().

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h      |    7 ++++---
 net/bridge/netfilter/nft_meta_bridge.c |    4 ++--
 net/netfilter/nf_tables_api.c          |   24 +++++++++++++-----------
 net/netfilter/nft_bitwise.c            |    4 ++--
 net/netfilter/nft_byteorder.c          |    4 ++--
 net/netfilter/nft_ct.c                 |    4 ++--
 net/netfilter/nft_exthdr.c             |    4 ++--
 net/netfilter/nft_immediate.c          |    4 ++--
 net/netfilter/nft_meta.c               |    4 ++--
 net/netfilter/nft_payload.c            |    4 ++--
 10 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f491243..7251f20 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -114,9 +114,10 @@ static inline enum nft_registers nft_type_to_reg(enum nft_data_types type)
 
 int nft_validate_input_register(enum nft_registers reg);
 int nft_validate_output_register(enum nft_registers reg);
-int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
-			   const struct nft_data *data,
-			   enum nft_data_types type, unsigned int len);
+int nft_validate_register_store(const struct nft_ctx *ctx,
+				enum nft_registers reg,
+				const struct nft_data *data,
+				enum nft_data_types type, unsigned int len);
 
 
 /**
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 2011b89..ee9e0b7 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -71,8 +71,8 @@ static int nft_meta_bridge_get_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_validate_data_load(ctx, priv->dreg, NULL,
-				     NFT_DATA_VALUE, len);
+	err = nft_validate_register_store(ctx, priv->dreg, NULL,
+					  NFT_DATA_VALUE, len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 564f9ed..a1e4a92 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2797,10 +2797,10 @@ static int nf_tables_bind_check_setelem(const struct nft_ctx *ctx,
 	enum nft_registers dreg;
 
 	dreg = nft_type_to_reg(set->dtype);
-	return nft_validate_data_load(ctx, dreg, nft_set_ext_data(ext),
-				      set->dtype == NFT_DATA_VERDICT ?
-				      NFT_DATA_VERDICT : NFT_DATA_VALUE,
-				      set->dlen);
+	return nft_validate_register_store(ctx, dreg, nft_set_ext_data(ext),
+					   set->dtype == NFT_DATA_VERDICT ?
+					   NFT_DATA_VERDICT : NFT_DATA_VALUE,
+					   set->dlen);
 }
 
 int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
@@ -3334,8 +3334,9 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 			if (!(binding->flags & NFT_SET_MAP))
 				continue;
 
-			err = nft_validate_data_load(&bind_ctx, dreg,
-						     &data, d2.type, d2.len);
+			err = nft_validate_register_store(&bind_ctx, dreg,
+							  &data,
+							  d2.type, d2.len);
 			if (err < 0)
 				goto err3;
 		}
@@ -4157,7 +4158,7 @@ int nft_validate_output_register(enum nft_registers reg)
 EXPORT_SYMBOL_GPL(nft_validate_output_register);
 
 /**
- *	nft_validate_data_load - validate an expressions' data load
+ *	nft_validate_register_store - validate an expressions' register store
  *
  *	@ctx: context of the expression performing the load
  * 	@reg: the destination register number
@@ -4170,9 +4171,10 @@ EXPORT_SYMBOL_GPL(nft_validate_output_register);
  * 	A value of NULL for the data means that its runtime gathered
  * 	data, which is always of type NFT_DATA_VALUE.
  */
-int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
-			   const struct nft_data *data,
-			   enum nft_data_types type, unsigned int len)
+int nft_validate_register_store(const struct nft_ctx *ctx,
+				enum nft_registers reg,
+				const struct nft_data *data,
+				enum nft_data_types type, unsigned int len)
 {
 	int err;
 
@@ -4204,7 +4206,7 @@ int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
 		return 0;
 	}
 }
-EXPORT_SYMBOL_GPL(nft_validate_data_load);
+EXPORT_SYMBOL_GPL(nft_validate_register_store);
 
 static const struct nla_policy nft_verdict_policy[NFTA_VERDICT_MAX + 1] = {
 	[NFTA_VERDICT_CODE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index fcd951f..afad27c 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -75,8 +75,8 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_validate_data_load(ctx, priv->dreg, NULL,
-				     NFT_DATA_VALUE, priv->len);
+	err = nft_validate_register_store(ctx, priv->dreg, NULL,
+					  NFT_DATA_VALUE, priv->len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index 183f133..03bfb75 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -118,8 +118,8 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 	err = nft_validate_output_register(priv->dreg);
 	if (err < 0)
 		return err;
-	err = nft_validate_data_load(ctx, priv->dreg, NULL,
-				     NFT_DATA_VALUE, priv->len);
+	err = nft_validate_register_store(ctx, priv->dreg, NULL,
+					  NFT_DATA_VALUE, priv->len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index ce368de..e23ddb6 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -311,8 +311,8 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_validate_data_load(ctx, priv->dreg, NULL,
-				     NFT_DATA_VALUE, len);
+	err = nft_validate_register_store(ctx, priv->dreg, NULL,
+					  NFT_DATA_VALUE, len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index a0a3227..ab16a38 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -74,8 +74,8 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 	err = nft_validate_output_register(priv->dreg);
 	if (err < 0)
 		return err;
-	return nft_validate_data_load(ctx, priv->dreg, NULL,
-				      NFT_DATA_VALUE, priv->len);
+	return nft_validate_register_store(ctx, priv->dreg, NULL,
+					   NFT_DATA_VALUE, priv->len);
 }
 
 static int nft_exthdr_dump(struct sk_buff *skb, const struct nft_expr *expr)
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 1970d8d..d058a93 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -59,8 +59,8 @@ static int nft_immediate_init(const struct nft_ctx *ctx,
 		return err;
 	priv->dlen = desc.len;
 
-	err = nft_validate_data_load(ctx, priv->dreg, &priv->data,
-				     desc.type, desc.len);
+	err = nft_validate_register_store(ctx, priv->dreg, &priv->data,
+					  desc.type, desc.len);
 	if (err < 0)
 		goto err1;
 
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index d4bdd77..b733755 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -262,8 +262,8 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_validate_data_load(ctx, priv->dreg, NULL,
-				     NFT_DATA_VALUE, len);
+	err = nft_validate_register_store(ctx, priv->dreg, NULL,
+					  NFT_DATA_VALUE, len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 7bed3e0..9c7ad4b 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -72,8 +72,8 @@ static int nft_payload_init(const struct nft_ctx *ctx,
 	err = nft_validate_output_register(priv->dreg);
 	if (err < 0)
 		return err;
-	return nft_validate_data_load(ctx, priv->dreg, NULL,
-				      NFT_DATA_VALUE, priv->len);
+	return nft_validate_register_store(ctx, priv->dreg, NULL,
+					   NFT_DATA_VALUE, priv->len);
 }
 
 static int nft_payload_dump(struct sk_buff *skb, const struct nft_expr *expr)
-- 
1.7.10.4

