From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/21] netfilter: nf_tables: introduce nft_validate_register_load()
Date: Mon, 13 Apr 2015 21:29:44 +0200
Message-ID: <1428953401-4838-6-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39662 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbbDMTZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:25:54 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Change nft_validate_input_register() to not only validate the input
register number, but also the length of the load, and rename it to
nft_validate_register_load() to reflect that change.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    3 +--
 net/netfilter/nf_tables_api.c     |   13 +++++++++----
 net/netfilter/nft_bitwise.c       |    5 ++---
 net/netfilter/nft_byteorder.c     |    7 ++-----
 net/netfilter/nft_cmp.c           |   25 +++++++++++++------------
 net/netfilter/nft_ct.c            |    4 +++-
 net/netfilter/nft_dynset.c        |    4 ++--
 net/netfilter/nft_lookup.c        |    2 +-
 net/netfilter/nft_meta.c          |    6 +++++-
 net/netfilter/nft_nat.c           |   26 +++++++++++++++++++-------
 net/netfilter/nft_redir.c         |    7 +++++--
 11 files changed, 62 insertions(+), 40 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index a8d4bd3..9cc3d55 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -112,13 +112,12 @@ static inline enum nft_registers nft_type_to_reg(enum nft_data_types type)
 	return type == NFT_DATA_VERDICT ? NFT_REG_VERDICT : NFT_REG_1;
 }
 
-int nft_validate_input_register(enum nft_registers reg);
+int nft_validate_register_load(enum nft_registers reg, unsigned int len);
 int nft_validate_register_store(const struct nft_ctx *ctx,
 				enum nft_registers reg,
 				const struct nft_data *data,
 				enum nft_data_types type, unsigned int len);
 
-
 /**
  *	struct nft_userdata - user defined data associated with an object
  *
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index f01e89fe..d47f12b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4122,22 +4122,27 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 }
 
 /**
- *	nft_validate_input_register - validate an expressions' input register
+ *	nft_validate_register_load - validate a load from a register
  *
  *	@reg: the register number
+ *	@len: the length of the data
  *
  * 	Validate that the input register is one of the general purpose
- * 	registers.
+ * 	registers and that the length of the load is within the bounds.
  */
-int nft_validate_input_register(enum nft_registers reg)
+int nft_validate_register_load(enum nft_registers reg, unsigned int len)
 {
 	if (reg <= NFT_REG_VERDICT)
 		return -EINVAL;
 	if (reg > NFT_REG_MAX)
 		return -ERANGE;
+	if (len == 0)
+		return -EINVAL;
+	if (len > FIELD_SIZEOF(struct nft_data, data))
+		return -ERANGE;
 	return 0;
 }
-EXPORT_SYMBOL_GPL(nft_validate_input_register);
+EXPORT_SYMBOL_GPL(nft_validate_register_load);
 
 /**
  *	nft_validate_register_store - validate an expressions' register store
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index d312052..60050ee 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -63,10 +63,9 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 	    tb[NFTA_BITWISE_XOR] == NULL)
 		return -EINVAL;
 
-	priv->len = ntohl(nla_get_be32(tb[NFTA_BITWISE_LEN]));
-
+	priv->len  = ntohl(nla_get_be32(tb[NFTA_BITWISE_LEN]));
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_BITWISE_SREG]));
-	err = nft_validate_input_register(priv->sreg);
+	err = nft_validate_register_load(priv->sreg, priv->len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index 848bce0..f34bfbd 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -96,10 +96,6 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 		return -EINVAL;
 	}
 
-	priv->len = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_LEN]));
-	if (priv->len == 0 || priv->len > FIELD_SIZEOF(struct nft_data, data))
-		return -EINVAL;
-
 	priv->size = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_SIZE]));
 	switch (priv->size) {
 	case 2:
@@ -110,7 +106,8 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 	}
 
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_SREG]));
-	err = nft_validate_input_register(priv->sreg);
+	priv->len  = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_LEN]));
+	err = nft_validate_register_load(priv->sreg, priv->len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index e2b3f51..17e9b8b 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -75,12 +75,15 @@ static int nft_cmp_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	struct nft_data_desc desc;
 	int err;
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
-	priv->op = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
-
 	err = nft_data_init(NULL, &priv->data, &desc, tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 
+	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
+	err = nft_validate_register_load(priv->sreg, desc.len);
+	if (err < 0)
+		return err;
+
+	priv->op  = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
 	priv->len = desc.len;
 	return 0;
 }
@@ -122,13 +125,17 @@ static int nft_cmp_fast_init(const struct nft_ctx *ctx,
 	u32 mask;
 	int err;
 
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
-
 	err = nft_data_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
-	desc.len *= BITS_PER_BYTE;
 
+	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
+	err = nft_validate_register_load(priv->sreg, desc.len);
+	if (err < 0)
+		return err;
+
+	desc.len *= BITS_PER_BYTE;
 	mask = nft_cmp_fast_mask(desc.len);
+
 	priv->data = data.data[0] & mask;
 	priv->len  = desc.len;
 	return 0;
@@ -167,7 +174,6 @@ nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 {
 	struct nft_data_desc desc;
 	struct nft_data data;
-	enum nft_registers sreg;
 	enum nft_cmp_ops op;
 	int err;
 
@@ -176,11 +182,6 @@ nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 	    tb[NFTA_CMP_DATA] == NULL)
 		return ERR_PTR(-EINVAL);
 
-	sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
-	err = nft_validate_input_register(sreg);
-	if (err < 0)
-		return ERR_PTR(err);
-
 	op = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
 	switch (op) {
 	case NFT_CMP_EQ:
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index d85f9ad..6bf6ed7 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -324,12 +324,14 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
 	struct nft_ct *priv = nft_expr_priv(expr);
+	unsigned int len;
 	int err;
 
 	priv->key = ntohl(nla_get_be32(tb[NFTA_CT_KEY]));
 	switch (priv->key) {
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	case NFT_CT_MARK:
+		len = FIELD_SIZEOF(struct nf_conn, mark);
 		break;
 #endif
 	default:
@@ -337,7 +339,7 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 	}
 
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CT_SREG]));
-	err = nft_validate_input_register(priv->sreg);
+	err = nft_validate_register_load(priv->sreg, len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index eeb72de..3ea52b7 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -124,7 +124,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	}
 
 	priv->sreg_key = ntohl(nla_get_be32(tb[NFTA_DYNSET_SREG_KEY]));
-	err = nft_validate_input_register(priv->sreg_key);
+	err = nft_validate_register_load(priv->sreg_key, set->klen);;
 	if (err < 0)
 		return err;
 
@@ -135,7 +135,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 			return -EOPNOTSUPP;
 
 		priv->sreg_data = ntohl(nla_get_be32(tb[NFTA_DYNSET_SREG_DATA]));
-		err = nft_validate_input_register(priv->sreg_data);
+		err = nft_validate_register_load(priv->sreg_data, set->dlen);
 		if (err < 0)
 			return err;
 	} else if (set->flags & NFT_SET_MAP)
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 3574543..8fc0d18 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -71,7 +71,7 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 	}
 
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_LOOKUP_SREG]));
-	err = nft_validate_input_register(priv->sreg);
+	err = nft_validate_register_load(priv->sreg, set->klen);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index fbaee1d..0ae6bb7 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -267,20 +267,24 @@ int nft_meta_set_init(const struct nft_ctx *ctx,
 		      const struct nlattr * const tb[])
 {
 	struct nft_meta *priv = nft_expr_priv(expr);
+	unsigned int len;
 	int err;
 
 	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
 	switch (priv->key) {
 	case NFT_META_MARK:
 	case NFT_META_PRIORITY:
+		len = sizeof(u32);
+		break;
 	case NFT_META_NFTRACE:
+		len = sizeof(u8);
 		break;
 	default:
 		return -EOPNOTSUPP;
 	}
 
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_META_SREG]));
-	err = nft_validate_input_register(priv->sreg);
+	err = nft_validate_register_load(priv->sreg, len);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index a0837c6..0897a80 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -119,6 +119,7 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 			const struct nlattr * const tb[])
 {
 	struct nft_nat *priv = nft_expr_priv(expr);
+	unsigned int alen, plen;
 	u32 family;
 	int err;
 
@@ -146,17 +147,25 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 		return -EINVAL;
 
 	family = ntohl(nla_get_be32(tb[NFTA_NAT_FAMILY]));
-	if (family != AF_INET && family != AF_INET6)
-		return -EAFNOSUPPORT;
 	if (family != ctx->afi->family)
 		return -EOPNOTSUPP;
+
+	switch (family) {
+	case NFPROTO_IPV4:
+		alen = FIELD_SIZEOF(struct nf_nat_range, min_addr.ip);
+		break;
+	case NFPROTO_IPV6:
+		alen = FIELD_SIZEOF(struct nf_nat_range, min_addr.ip6);
+		break;
+	default:
+		return -EAFNOSUPPORT;
+	}
 	priv->family = family;
 
 	if (tb[NFTA_NAT_REG_ADDR_MIN]) {
 		priv->sreg_addr_min =
 			ntohl(nla_get_be32(tb[NFTA_NAT_REG_ADDR_MIN]));
-
-		err = nft_validate_input_register(priv->sreg_addr_min);
+		err = nft_validate_register_load(priv->sreg_addr_min, alen);
 		if (err < 0)
 			return err;
 
@@ -164,7 +173,8 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 			priv->sreg_addr_max =
 				ntohl(nla_get_be32(tb[NFTA_NAT_REG_ADDR_MAX]));
 
-			err = nft_validate_input_register(priv->sreg_addr_max);
+			err = nft_validate_register_load(priv->sreg_addr_max,
+							 alen);
 			if (err < 0)
 				return err;
 		} else {
@@ -172,11 +182,12 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 		}
 	}
 
+	plen = FIELD_SIZEOF(struct nf_nat_range, min_addr.all);
 	if (tb[NFTA_NAT_REG_PROTO_MIN]) {
 		priv->sreg_proto_min =
 			ntohl(nla_get_be32(tb[NFTA_NAT_REG_PROTO_MIN]));
 
-		err = nft_validate_input_register(priv->sreg_proto_min);
+		err = nft_validate_register_load(priv->sreg_proto_min, plen);
 		if (err < 0)
 			return err;
 
@@ -184,7 +195,8 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 			priv->sreg_proto_max =
 				ntohl(nla_get_be32(tb[NFTA_NAT_REG_PROTO_MAX]));
 
-			err = nft_validate_input_register(priv->sreg_proto_max);
+			err = nft_validate_register_load(priv->sreg_proto_max,
+							 plen);
 			if (err < 0)
 				return err;
 		} else {
diff --git a/net/netfilter/nft_redir.c b/net/netfilter/nft_redir.c
index d7e9e93..9819466 100644
--- a/net/netfilter/nft_redir.c
+++ b/net/netfilter/nft_redir.c
@@ -44,17 +44,19 @@ int nft_redir_init(const struct nft_ctx *ctx,
 		   const struct nlattr * const tb[])
 {
 	struct nft_redir *priv = nft_expr_priv(expr);
+	unsigned int plen;
 	int err;
 
 	err = nft_redir_validate(ctx, expr, NULL);
 	if (err < 0)
 		return err;
 
+	plen = FIELD_SIZEOF(struct nf_nat_range, min_addr.all);
 	if (tb[NFTA_REDIR_REG_PROTO_MIN]) {
 		priv->sreg_proto_min =
 			ntohl(nla_get_be32(tb[NFTA_REDIR_REG_PROTO_MIN]));
 
-		err = nft_validate_input_register(priv->sreg_proto_min);
+		err = nft_validate_register_load(priv->sreg_proto_min, plen);
 		if (err < 0)
 			return err;
 
@@ -62,7 +64,8 @@ int nft_redir_init(const struct nft_ctx *ctx,
 			priv->sreg_proto_max =
 				ntohl(nla_get_be32(tb[NFTA_REDIR_REG_PROTO_MAX]));
 
-			err = nft_validate_input_register(priv->sreg_proto_max);
+			err = nft_validate_register_load(priv->sreg_proto_max,
+							 plen);
 			if (err < 0)
 				return err;
 		} else {
-- 
1.7.10.4
