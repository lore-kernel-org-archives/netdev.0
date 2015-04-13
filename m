From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/21] netfilter: nf_tables: add register parsing/dumping helpers
Date: Mon, 13 Apr 2015 21:29:50 +0200
Message-ID: <1428953401-4838-12-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39694 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754585AbbDMTZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:25:59 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add helper functions to parse and dump register values in netlink attributes.
These helpers will later be changed to take care of translation between the
old 128 bit and the new 32 bit register numbers.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h      |    3 +++
 net/bridge/netfilter/nft_meta_bridge.c |    2 +-
 net/netfilter/nf_tables_api.c          |   12 ++++++++++++
 net/netfilter/nft_bitwise.c            |    8 ++++----
 net/netfilter/nft_byteorder.c          |    8 ++++----
 net/netfilter/nft_cmp.c                |    8 ++++----
 net/netfilter/nft_ct.c                 |    8 ++++----
 net/netfilter/nft_dynset.c             |    8 ++++----
 net/netfilter/nft_exthdr.c             |    4 ++--
 net/netfilter/nft_immediate.c          |    4 ++--
 net/netfilter/nft_lookup.c             |    8 ++++----
 net/netfilter/nft_meta.c               |    8 ++++----
 net/netfilter/nft_nat.c                |   24 ++++++++++++------------
 net/netfilter/nft_payload.c            |    4 ++--
 net/netfilter/nft_redir.c              |   12 ++++++------
 15 files changed, 68 insertions(+), 53 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index efcf46d..f8f27a4 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -128,6 +128,9 @@ static inline enum nft_registers nft_type_to_reg(enum nft_data_types type)
 	return type == NFT_DATA_VERDICT ? NFT_REG_VERDICT : NFT_REG_1;
 }
 
+unsigned int nft_parse_register(const struct nlattr *attr);
+int nft_dump_register(struct sk_buff *skb, unsigned int attr, unsigned int reg);
+
 int nft_validate_register_load(enum nft_registers reg, unsigned int len);
 int nft_validate_register_store(const struct nft_ctx *ctx,
 				enum nft_registers reg,
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 6184b15..99dab70 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -65,7 +65,7 @@ static int nft_meta_bridge_get_init(const struct nft_ctx *ctx,
 		return nft_meta_get_init(ctx, expr, tb);
 	}
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_META_DREG]));
+	priv->dreg = nft_parse_register(tb[NFTA_META_DREG]);
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, len);
 }
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0bb16a1..a25fd19 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4122,6 +4122,18 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 	return 0;
 }
 
+unsigned int nft_parse_register(const struct nlattr *attr)
+{
+	return ntohl(nla_get_be32(attr));
+}
+EXPORT_SYMBOL_GPL(nft_parse_register);
+
+int nft_dump_register(struct sk_buff *skb, unsigned int attr, unsigned int reg)
+{
+	return nla_put_be32(skb, attr, htonl(reg));
+}
+EXPORT_SYMBOL_GPL(nft_dump_register);
+
 /**
  *	nft_validate_register_load - validate a load from a register
  *
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index d55b545..aa11470 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -62,12 +62,12 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 		return -EINVAL;
 
 	priv->len  = ntohl(nla_get_be32(tb[NFTA_BITWISE_LEN]));
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_BITWISE_SREG]));
+	priv->sreg = nft_parse_register(tb[NFTA_BITWISE_SREG]);
 	err = nft_validate_register_load(priv->sreg, priv->len);
 	if (err < 0)
 		return err;
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_BITWISE_DREG]));
+	priv->dreg = nft_parse_register(tb[NFTA_BITWISE_DREG]);
 	err = nft_validate_register_store(ctx, priv->dreg, NULL,
 					  NFT_DATA_VALUE, priv->len);
 	if (err < 0)
@@ -92,9 +92,9 @@ static int nft_bitwise_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_bitwise *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_BITWISE_SREG, htonl(priv->sreg)))
+	if (nft_dump_register(skb, NFTA_BITWISE_SREG, priv->sreg))
 		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_BITWISE_DREG, htonl(priv->dreg)))
+	if (nft_dump_register(skb, NFTA_BITWISE_DREG, priv->dreg))
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_BITWISE_LEN, htonl(priv->len)))
 		goto nla_put_failure;
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index d6290db..2ee3e57 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -106,13 +106,13 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 		return -EINVAL;
 	}
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_SREG]));
+	priv->sreg = nft_parse_register(tb[NFTA_BYTEORDER_SREG]);
 	priv->len  = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_LEN]));
 	err = nft_validate_register_load(priv->sreg, priv->len);
 	if (err < 0)
 		return err;
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_DREG]));
+	priv->dreg = nft_parse_register(tb[NFTA_BYTEORDER_DREG]);
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, priv->len);
 }
@@ -121,9 +121,9 @@ static int nft_byteorder_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_byteorder *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_BYTEORDER_SREG, htonl(priv->sreg)))
+	if (nft_dump_register(skb, NFTA_BYTEORDER_SREG, priv->sreg))
 		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_BYTEORDER_DREG, htonl(priv->dreg)))
+	if (nft_dump_register(skb, NFTA_BYTEORDER_DREG, priv->dreg))
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_BYTEORDER_OP, htonl(priv->op)))
 		goto nla_put_failure;
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index b7e1c58..ffaf214 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -78,7 +78,7 @@ static int nft_cmp_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	err = nft_data_init(NULL, &priv->data, &desc, tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
+	priv->sreg = nft_parse_register(tb[NFTA_CMP_SREG]);
 	err = nft_validate_register_load(priv->sreg, desc.len);
 	if (err < 0)
 		return err;
@@ -92,7 +92,7 @@ static int nft_cmp_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_cmp_expr *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_CMP_SREG, htonl(priv->sreg)))
+	if (nft_dump_register(skb, NFTA_CMP_SREG, priv->sreg))
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_CMP_OP, htonl(priv->op)))
 		goto nla_put_failure;
@@ -128,7 +128,7 @@ static int nft_cmp_fast_init(const struct nft_ctx *ctx,
 	err = nft_data_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
+	priv->sreg = nft_parse_register(tb[NFTA_CMP_SREG]);
 	err = nft_validate_register_load(priv->sreg, desc.len);
 	if (err < 0)
 		return err;
@@ -146,7 +146,7 @@ static int nft_cmp_fast_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
 	struct nft_data data;
 
-	if (nla_put_be32(skb, NFTA_CMP_SREG, htonl(priv->sreg)))
+	if (nft_dump_register(skb, NFTA_CMP_SREG, priv->sreg))
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_CMP_OP, htonl(NFT_CMP_EQ)))
 		goto nla_put_failure;
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 0166f28c..fab8e75 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -306,7 +306,7 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 		}
 	}
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_CT_DREG]));
+	priv->dreg = nft_parse_register(tb[NFTA_CT_DREG]);
 	err = nft_validate_register_store(ctx, priv->dreg, NULL,
 					  NFT_DATA_VALUE, len);
 	if (err < 0)
@@ -338,7 +338,7 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 		return -EOPNOTSUPP;
 	}
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CT_SREG]));
+	priv->sreg = nft_parse_register(tb[NFTA_CT_SREG]);
 	err = nft_validate_register_load(priv->sreg, len);
 	if (err < 0)
 		return err;
@@ -360,7 +360,7 @@ static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_CT_DREG, htonl(priv->dreg)))
+	if (nft_dump_register(skb, NFTA_CT_DREG, priv->dreg))
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_CT_KEY, htonl(priv->key)))
 		goto nla_put_failure;
@@ -387,7 +387,7 @@ static int nft_ct_set_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_CT_SREG, htonl(priv->sreg)))
+	if (nft_dump_register(skb, NFTA_CT_SREG, priv->sreg))
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_CT_KEY, htonl(priv->key)))
 		goto nla_put_failure;
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index e398f6d..03699d5 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -124,7 +124,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 		timeout = be64_to_cpu(nla_get_be64(tb[NFTA_DYNSET_TIMEOUT]));
 	}
 
-	priv->sreg_key = ntohl(nla_get_be32(tb[NFTA_DYNSET_SREG_KEY]));
+	priv->sreg_key = nft_parse_register(tb[NFTA_DYNSET_SREG_KEY]);
 	err = nft_validate_register_load(priv->sreg_key, set->klen);;
 	if (err < 0)
 		return err;
@@ -135,7 +135,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 		if (set->dtype == NFT_DATA_VERDICT)
 			return -EOPNOTSUPP;
 
-		priv->sreg_data = ntohl(nla_get_be32(tb[NFTA_DYNSET_SREG_DATA]));
+		priv->sreg_data = nft_parse_register(tb[NFTA_DYNSET_SREG_DATA]);
 		err = nft_validate_register_load(priv->sreg_data, set->dlen);
 		if (err < 0)
 			return err;
@@ -173,10 +173,10 @@ static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_dynset *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_DYNSET_SREG_KEY, htonl(priv->sreg_key)))
+	if (nft_dump_register(skb, NFTA_DYNSET_SREG_KEY, priv->sreg_key))
 		goto nla_put_failure;
 	if (priv->set->flags & NFT_SET_MAP &&
-	    nla_put_be32(skb, NFTA_DYNSET_SREG_DATA, htonl(priv->sreg_data)))
+	    nft_dump_register(skb, NFTA_DYNSET_SREG_DATA, priv->sreg_data))
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_DYNSET_OP, htonl(priv->op)))
 		goto nla_put_failure;
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index a85db75..098ffee 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -68,7 +68,7 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 	priv->type   = nla_get_u8(tb[NFTA_EXTHDR_TYPE]);
 	priv->offset = ntohl(nla_get_be32(tb[NFTA_EXTHDR_OFFSET]));
 	priv->len    = ntohl(nla_get_be32(tb[NFTA_EXTHDR_LEN]));
-	priv->dreg   = ntohl(nla_get_be32(tb[NFTA_EXTHDR_DREG]));
+	priv->dreg   = nft_parse_register(tb[NFTA_EXTHDR_DREG]);
 
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, priv->len);
@@ -78,7 +78,7 @@ static int nft_exthdr_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_exthdr *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_EXTHDR_DREG, htonl(priv->dreg)))
+	if (nft_dump_register(skb, NFTA_EXTHDR_DREG, priv->dreg))
 		goto nla_put_failure;
 	if (nla_put_u8(skb, NFTA_EXTHDR_TYPE, priv->type))
 		goto nla_put_failure;
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 29cc739..0682f60 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -54,7 +54,7 @@ static int nft_immediate_init(const struct nft_ctx *ctx,
 		return err;
 	priv->dlen = desc.len;
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_IMMEDIATE_DREG]));
+	priv->dreg = nft_parse_register(tb[NFTA_IMMEDIATE_DREG]);
 	err = nft_validate_register_store(ctx, priv->dreg, &priv->data,
 					  desc.type, desc.len);
 	if (err < 0)
@@ -78,7 +78,7 @@ static int nft_immediate_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_immediate_expr *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_IMMEDIATE_DREG, htonl(priv->dreg)))
+	if (nft_dump_register(skb, NFTA_IMMEDIATE_DREG, priv->dreg))
 		goto nla_put_failure;
 
 	return nft_data_dump(skb, NFTA_IMMEDIATE_DATA, &priv->data,
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 01dba68..fc7afff 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -71,7 +71,7 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 			return PTR_ERR(set);
 	}
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_LOOKUP_SREG]));
+	priv->sreg = nft_parse_register(tb[NFTA_LOOKUP_SREG]);
 	err = nft_validate_register_load(priv->sreg, set->klen);
 	if (err < 0)
 		return err;
@@ -80,7 +80,7 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 		if (!(set->flags & NFT_SET_MAP))
 			return -EINVAL;
 
-		priv->dreg = ntohl(nla_get_be32(tb[NFTA_LOOKUP_DREG]));
+		priv->dreg = nft_parse_register(tb[NFTA_LOOKUP_DREG]);
 		err = nft_validate_register_store(ctx, priv->dreg, NULL,
 						  set->dtype, set->dlen);
 		if (err < 0)
@@ -112,10 +112,10 @@ static int nft_lookup_dump(struct sk_buff *skb, const struct nft_expr *expr)
 
 	if (nla_put_string(skb, NFTA_LOOKUP_SET, priv->set->name))
 		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_LOOKUP_SREG, htonl(priv->sreg)))
+	if (nft_dump_register(skb, NFTA_LOOKUP_SREG, priv->sreg))
 		goto nla_put_failure;
 	if (priv->set->flags & NFT_SET_MAP)
-		if (nla_put_be32(skb, NFTA_LOOKUP_DREG, htonl(priv->dreg)))
+		if (nft_dump_register(skb, NFTA_LOOKUP_DREG, priv->dreg))
 			goto nla_put_failure;
 	return 0;
 
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index a6da806..5f744eb 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -254,7 +254,7 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 		return -EOPNOTSUPP;
 	}
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_META_DREG]));
+	priv->dreg = nft_parse_register(tb[NFTA_META_DREG]);
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, len);
 }
@@ -281,7 +281,7 @@ int nft_meta_set_init(const struct nft_ctx *ctx,
 		return -EOPNOTSUPP;
 	}
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_META_SREG]));
+	priv->sreg = nft_parse_register(tb[NFTA_META_SREG]);
 	err = nft_validate_register_load(priv->sreg, len);
 	if (err < 0)
 		return err;
@@ -297,7 +297,7 @@ int nft_meta_get_dump(struct sk_buff *skb,
 
 	if (nla_put_be32(skb, NFTA_META_KEY, htonl(priv->key)))
 		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_META_DREG, htonl(priv->dreg)))
+	if (nft_dump_register(skb, NFTA_META_DREG, priv->dreg))
 		goto nla_put_failure;
 	return 0;
 
@@ -313,7 +313,7 @@ int nft_meta_set_dump(struct sk_buff *skb,
 
 	if (nla_put_be32(skb, NFTA_META_KEY, htonl(priv->key)))
 		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_META_SREG, htonl(priv->sreg)))
+	if (nft_dump_register(skb, NFTA_META_SREG, priv->sreg))
 		goto nla_put_failure;
 
 	return 0;
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index b723311..065cbda 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -163,14 +163,14 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 
 	if (tb[NFTA_NAT_REG_ADDR_MIN]) {
 		priv->sreg_addr_min =
-			ntohl(nla_get_be32(tb[NFTA_NAT_REG_ADDR_MIN]));
+			nft_parse_register(tb[NFTA_NAT_REG_ADDR_MIN]);
 		err = nft_validate_register_load(priv->sreg_addr_min, alen);
 		if (err < 0)
 			return err;
 
 		if (tb[NFTA_NAT_REG_ADDR_MAX]) {
 			priv->sreg_addr_max =
-				ntohl(nla_get_be32(tb[NFTA_NAT_REG_ADDR_MAX]));
+				nft_parse_register(tb[NFTA_NAT_REG_ADDR_MAX]);
 
 			err = nft_validate_register_load(priv->sreg_addr_max,
 							 alen);
@@ -184,7 +184,7 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	plen = FIELD_SIZEOF(struct nf_nat_range, min_addr.all);
 	if (tb[NFTA_NAT_REG_PROTO_MIN]) {
 		priv->sreg_proto_min =
-			ntohl(nla_get_be32(tb[NFTA_NAT_REG_PROTO_MIN]));
+			nft_parse_register(tb[NFTA_NAT_REG_PROTO_MIN]);
 
 		err = nft_validate_register_load(priv->sreg_proto_min, plen);
 		if (err < 0)
@@ -192,7 +192,7 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 
 		if (tb[NFTA_NAT_REG_PROTO_MAX]) {
 			priv->sreg_proto_max =
-				ntohl(nla_get_be32(tb[NFTA_NAT_REG_PROTO_MAX]));
+				nft_parse_register(tb[NFTA_NAT_REG_PROTO_MAX]);
 
 			err = nft_validate_register_load(priv->sreg_proto_max,
 							 plen);
@@ -231,18 +231,18 @@ static int nft_nat_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 
 	if (priv->sreg_addr_min) {
-		if (nla_put_be32(skb, NFTA_NAT_REG_ADDR_MIN,
-				 htonl(priv->sreg_addr_min)) ||
-		    nla_put_be32(skb, NFTA_NAT_REG_ADDR_MAX,
-				 htonl(priv->sreg_addr_max)))
+		if (nft_dump_register(skb, NFTA_NAT_REG_ADDR_MIN,
+				      priv->sreg_addr_min) ||
+		    nft_dump_register(skb, NFTA_NAT_REG_ADDR_MAX,
+				      priv->sreg_addr_max))
 			goto nla_put_failure;
 	}
 
 	if (priv->sreg_proto_min) {
-		if (nla_put_be32(skb, NFTA_NAT_REG_PROTO_MIN,
-				 htonl(priv->sreg_proto_min)) ||
-		    nla_put_be32(skb, NFTA_NAT_REG_PROTO_MAX,
-				 htonl(priv->sreg_proto_max)))
+		if (nft_dump_register(skb, NFTA_NAT_REG_PROTO_MIN,
+				      priv->sreg_proto_min) ||
+		    nft_dump_register(skb, NFTA_NAT_REG_PROTO_MAX,
+				      priv->sreg_proto_max))
 			goto nla_put_failure;
 	}
 
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 6bb0592..5fa9973 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -66,7 +66,7 @@ static int nft_payload_init(const struct nft_ctx *ctx,
 	priv->base   = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_BASE]));
 	priv->offset = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_OFFSET]));
 	priv->len    = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_LEN]));
-	priv->dreg   = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_DREG]));
+	priv->dreg   = nft_parse_register(tb[NFTA_PAYLOAD_DREG]);
 
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, priv->len);
@@ -76,7 +76,7 @@ static int nft_payload_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_payload *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_PAYLOAD_DREG, htonl(priv->dreg)) ||
+	if (nft_dump_register(skb, NFTA_PAYLOAD_DREG, priv->dreg) ||
 	    nla_put_be32(skb, NFTA_PAYLOAD_BASE, htonl(priv->base)) ||
 	    nla_put_be32(skb, NFTA_PAYLOAD_OFFSET, htonl(priv->offset)) ||
 	    nla_put_be32(skb, NFTA_PAYLOAD_LEN, htonl(priv->len)))
diff --git a/net/netfilter/nft_redir.c b/net/netfilter/nft_redir.c
index 9819466..03f7bf4 100644
--- a/net/netfilter/nft_redir.c
+++ b/net/netfilter/nft_redir.c
@@ -54,7 +54,7 @@ int nft_redir_init(const struct nft_ctx *ctx,
 	plen = FIELD_SIZEOF(struct nf_nat_range, min_addr.all);
 	if (tb[NFTA_REDIR_REG_PROTO_MIN]) {
 		priv->sreg_proto_min =
-			ntohl(nla_get_be32(tb[NFTA_REDIR_REG_PROTO_MIN]));
+			nft_parse_register(tb[NFTA_REDIR_REG_PROTO_MIN]);
 
 		err = nft_validate_register_load(priv->sreg_proto_min, plen);
 		if (err < 0)
@@ -62,7 +62,7 @@ int nft_redir_init(const struct nft_ctx *ctx,
 
 		if (tb[NFTA_REDIR_REG_PROTO_MAX]) {
 			priv->sreg_proto_max =
-				ntohl(nla_get_be32(tb[NFTA_REDIR_REG_PROTO_MAX]));
+				nft_parse_register(tb[NFTA_REDIR_REG_PROTO_MAX]);
 
 			err = nft_validate_register_load(priv->sreg_proto_max,
 							 plen);
@@ -88,11 +88,11 @@ int nft_redir_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	const struct nft_redir *priv = nft_expr_priv(expr);
 
 	if (priv->sreg_proto_min) {
-		if (nla_put_be32(skb, NFTA_REDIR_REG_PROTO_MIN,
-				 htonl(priv->sreg_proto_min)))
+		if (nft_dump_register(skb, NFTA_REDIR_REG_PROTO_MIN,
+				      priv->sreg_proto_min))
 			goto nla_put_failure;
-		if (nla_put_be32(skb, NFTA_REDIR_REG_PROTO_MAX,
-				 htonl(priv->sreg_proto_max)))
+		if (nft_dump_register(skb, NFTA_REDIR_REG_PROTO_MAX,
+				      priv->sreg_proto_max))
 			goto nla_put_failure;
 	}
 
-- 
1.7.10.4
