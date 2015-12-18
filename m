From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/23] netfilter: nft_payload: add packet mangling support
Date: Fri, 18 Dec 2015 21:26:39 +0100
Message-ID: <1450470409-31427-14-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Add support for mangling packet payload. Checksum for the specified base
header is updated automatically if requested, however no updates for any
kind of pseudo headers are supported, meaning no stateless NAT is supported.

For checksum updates different checksumming methods can be specified. The
currently supported methods are NONE for no checksum updates, and INET for
internet type checksums.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h   |   9 +++
 include/uapi/linux/netfilter/nf_tables.h |  17 ++++
 net/netfilter/nft_payload.c              | 135 +++++++++++++++++++++++++++++--
 3 files changed, 155 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index c6f400c..4ff5424 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -47,6 +47,15 @@ struct nft_payload {
 	enum nft_registers	dreg:8;
 };
 
+struct nft_payload_set {
+	enum nft_payload_bases	base:8;
+	u8			offset;
+	u8			len;
+	enum nft_registers	sreg:8;
+	u8			csum_type;
+	u8			csum_offset;
+};
+
 extern const struct nft_expr_ops nft_payload_fast_ops;
 
 int nft_payload_module_init(void);
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index d8c8a7c..5f3ecec 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -598,12 +598,26 @@ enum nft_payload_bases {
 };
 
 /**
+ * enum nft_payload_csum_types - nf_tables payload expression checksum types
+ *
+ * @NFT_PAYLOAD_CSUM_NONE: no checksumming
+ * @NFT_PAYLOAD_CSUM_INET: internet checksum (RFC 791)
+ */
+enum nft_payload_csum_types {
+	NFT_PAYLOAD_CSUM_NONE,
+	NFT_PAYLOAD_CSUM_INET,
+};
+
+/**
  * enum nft_payload_attributes - nf_tables payload expression netlink attributes
  *
  * @NFTA_PAYLOAD_DREG: destination register to load data into (NLA_U32: nft_registers)
  * @NFTA_PAYLOAD_BASE: payload base (NLA_U32: nft_payload_bases)
  * @NFTA_PAYLOAD_OFFSET: payload offset relative to base (NLA_U32)
  * @NFTA_PAYLOAD_LEN: payload length (NLA_U32)
+ * @NFTA_PAYLOAD_SREG: source register to load data from (NLA_U32: nft_registers)
+ * @NFTA_PAYLOAD_CSUM_TYPE: checksum type (NLA_U32)
+ * @NFTA_PAYLOAD_CSUM_OFFSET: checksum offset relative to base (NLA_U32)
  */
 enum nft_payload_attributes {
 	NFTA_PAYLOAD_UNSPEC,
@@ -611,6 +625,9 @@ enum nft_payload_attributes {
 	NFTA_PAYLOAD_BASE,
 	NFTA_PAYLOAD_OFFSET,
 	NFTA_PAYLOAD_LEN,
+	NFTA_PAYLOAD_SREG,
+	NFTA_PAYLOAD_CSUM_TYPE,
+	NFTA_PAYLOAD_CSUM_OFFSET,
 	__NFTA_PAYLOAD_MAX
 };
 #define NFTA_PAYLOAD_MAX	(__NFTA_PAYLOAD_MAX - 1)
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 09b4b07..12cd4bf 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -107,10 +107,13 @@ err:
 }
 
 static const struct nla_policy nft_payload_policy[NFTA_PAYLOAD_MAX + 1] = {
-	[NFTA_PAYLOAD_DREG]	= { .type = NLA_U32 },
-	[NFTA_PAYLOAD_BASE]	= { .type = NLA_U32 },
-	[NFTA_PAYLOAD_OFFSET]	= { .type = NLA_U32 },
-	[NFTA_PAYLOAD_LEN]	= { .type = NLA_U32 },
+	[NFTA_PAYLOAD_SREG]		= { .type = NLA_U32 },
+	[NFTA_PAYLOAD_DREG]		= { .type = NLA_U32 },
+	[NFTA_PAYLOAD_BASE]		= { .type = NLA_U32 },
+	[NFTA_PAYLOAD_OFFSET]		= { .type = NLA_U32 },
+	[NFTA_PAYLOAD_LEN]		= { .type = NLA_U32 },
+	[NFTA_PAYLOAD_CSUM_TYPE]	= { .type = NLA_U32 },
+	[NFTA_PAYLOAD_CSUM_OFFSET]	= { .type = NLA_U32 },
 };
 
 static int nft_payload_init(const struct nft_ctx *ctx,
@@ -160,6 +163,118 @@ const struct nft_expr_ops nft_payload_fast_ops = {
 	.dump		= nft_payload_dump,
 };
 
+static void nft_payload_set_eval(const struct nft_expr *expr,
+				 struct nft_regs *regs,
+				 const struct nft_pktinfo *pkt)
+{
+	const struct nft_payload_set *priv = nft_expr_priv(expr);
+	struct sk_buff *skb = pkt->skb;
+	const u32 *src = &regs->data[priv->sreg];
+	int offset, csum_offset;
+	__wsum fsum, tsum;
+	__sum16 sum;
+
+	switch (priv->base) {
+	case NFT_PAYLOAD_LL_HEADER:
+		if (!skb_mac_header_was_set(skb))
+			goto err;
+		offset = skb_mac_header(skb) - skb->data;
+		break;
+	case NFT_PAYLOAD_NETWORK_HEADER:
+		offset = skb_network_offset(skb);
+		break;
+	case NFT_PAYLOAD_TRANSPORT_HEADER:
+		offset = pkt->xt.thoff;
+		break;
+	default:
+		BUG();
+	}
+
+	csum_offset = offset + priv->csum_offset;
+	offset += priv->offset;
+
+	if (priv->csum_type == NFT_PAYLOAD_CSUM_INET &&
+	    (priv->base != NFT_PAYLOAD_TRANSPORT_HEADER ||
+	     skb->ip_summed != CHECKSUM_PARTIAL)) {
+		if (skb_copy_bits(skb, csum_offset, &sum, sizeof(sum)) < 0)
+			goto err;
+
+		fsum = skb_checksum(skb, offset, priv->len, 0);
+		tsum = csum_partial(src, priv->len, 0);
+		sum = csum_fold(csum_add(csum_sub(~csum_unfold(sum), fsum),
+					 tsum));
+		if (sum == 0)
+			sum = CSUM_MANGLED_0;
+
+		if (!skb_make_writable(skb, csum_offset + sizeof(sum)) ||
+		    skb_store_bits(skb, csum_offset, &sum, sizeof(sum)) < 0)
+			goto err;
+	}
+
+	if (!skb_make_writable(skb, max(offset + priv->len, 0)) ||
+	    skb_store_bits(skb, offset, src, priv->len) < 0)
+		goto err;
+
+	return;
+err:
+	regs->verdict.code = NFT_BREAK;
+}
+
+static int nft_payload_set_init(const struct nft_ctx *ctx,
+				const struct nft_expr *expr,
+				const struct nlattr * const tb[])
+{
+	struct nft_payload_set *priv = nft_expr_priv(expr);
+
+	priv->base        = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_BASE]));
+	priv->offset      = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_OFFSET]));
+	priv->len         = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_LEN]));
+	priv->sreg        = nft_parse_register(tb[NFTA_PAYLOAD_SREG]);
+
+	if (tb[NFTA_PAYLOAD_CSUM_TYPE])
+		priv->csum_type =
+			ntohl(nla_get_be32(tb[NFTA_PAYLOAD_CSUM_TYPE]));
+	if (tb[NFTA_PAYLOAD_CSUM_OFFSET])
+		priv->csum_offset =
+			ntohl(nla_get_be32(tb[NFTA_PAYLOAD_CSUM_OFFSET]));
+
+	switch (priv->csum_type) {
+	case NFT_PAYLOAD_CSUM_NONE:
+	case NFT_PAYLOAD_CSUM_INET:
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return nft_validate_register_load(priv->sreg, priv->len);
+}
+
+static int nft_payload_set_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_payload_set *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_PAYLOAD_SREG, priv->sreg) ||
+	    nla_put_be32(skb, NFTA_PAYLOAD_BASE, htonl(priv->base)) ||
+	    nla_put_be32(skb, NFTA_PAYLOAD_OFFSET, htonl(priv->offset)) ||
+	    nla_put_be32(skb, NFTA_PAYLOAD_LEN, htonl(priv->len)) ||
+	    nla_put_be32(skb, NFTA_PAYLOAD_CSUM_TYPE, htonl(priv->csum_type)) ||
+	    nla_put_be32(skb, NFTA_PAYLOAD_CSUM_OFFSET,
+			 htonl(priv->csum_offset)))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static const struct nft_expr_ops nft_payload_set_ops = {
+	.type		= &nft_payload_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_payload_set)),
+	.eval		= nft_payload_set_eval,
+	.init		= nft_payload_set_init,
+	.dump		= nft_payload_set_dump,
+};
+
 static const struct nft_expr_ops *
 nft_payload_select_ops(const struct nft_ctx *ctx,
 		       const struct nlattr * const tb[])
@@ -167,8 +282,7 @@ nft_payload_select_ops(const struct nft_ctx *ctx,
 	enum nft_payload_bases base;
 	unsigned int offset, len;
 
-	if (tb[NFTA_PAYLOAD_DREG] == NULL ||
-	    tb[NFTA_PAYLOAD_BASE] == NULL ||
+	if (tb[NFTA_PAYLOAD_BASE] == NULL ||
 	    tb[NFTA_PAYLOAD_OFFSET] == NULL ||
 	    tb[NFTA_PAYLOAD_LEN] == NULL)
 		return ERR_PTR(-EINVAL);
@@ -183,6 +297,15 @@ nft_payload_select_ops(const struct nft_ctx *ctx,
 		return ERR_PTR(-EOPNOTSUPP);
 	}
 
+	if (tb[NFTA_PAYLOAD_SREG] != NULL) {
+		if (tb[NFTA_PAYLOAD_DREG] != NULL)
+			return ERR_PTR(-EINVAL);
+		return &nft_payload_set_ops;
+	}
+
+	if (tb[NFTA_PAYLOAD_DREG] == NULL)
+		return ERR_PTR(-EINVAL);
+
 	offset = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_OFFSET]));
 	len    = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_LEN]));
 
-- 
2.1.4

