From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/13] netfilter: nf_tables: nft_meta module get/set ops
Date: Mon,  6 Jan 2014 14:46:34 +0100
Message-ID: <1389016002-9116-6-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>

This patch adds kernel support for the meta expression in get/set
flavour. The set operation indicates that a given packet has to be
set with a property, currently one of mark, priority, nftrace.
The get op is what was currently working: evaluate the given
packet property.

In the nftrace case, the value is always 1. Such behaviour is copied
from net/netfilter/xt_TRACE.c

The NFTA_META_DREG and NFTA_META_SREG attributes are mutually
exclusives.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 +
 net/netfilter/nft_meta.c                 |  146 +++++++++++++++++++++++++-----
 2 files changed, 125 insertions(+), 23 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index b25481e..aa86a152 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -555,11 +555,13 @@ enum nft_meta_keys {
  *
  * @NFTA_META_DREG: destination register (NLA_U32)
  * @NFTA_META_KEY: meta data item to load (NLA_U32: nft_meta_keys)
+ * @NFTA_META_SREG: source register (NLA_U32)
  */
 enum nft_meta_attributes {
 	NFTA_META_UNSPEC,
 	NFTA_META_DREG,
 	NFTA_META_KEY,
+	NFTA_META_SREG,
 	__NFTA_META_MAX
 };
 #define NFTA_META_MAX		(__NFTA_META_MAX - 1)
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 8c28220..1ceaaa6 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -21,12 +21,15 @@
 
 struct nft_meta {
 	enum nft_meta_keys	key:8;
-	enum nft_registers	dreg:8;
+	union {
+		enum nft_registers	dreg:8;
+		enum nft_registers	sreg:8;
+	};
 };
 
-static void nft_meta_eval(const struct nft_expr *expr,
-			  struct nft_data data[NFT_REG_MAX + 1],
-			  const struct nft_pktinfo *pkt)
+static void nft_meta_get_eval(const struct nft_expr *expr,
+			      struct nft_data data[NFT_REG_MAX + 1],
+			      const struct nft_pktinfo *pkt)
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
@@ -132,23 +135,50 @@ err:
 	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
 }
 
+static void nft_meta_set_eval(const struct nft_expr *expr,
+			      struct nft_data data[NFT_REG_MAX + 1],
+			      const struct nft_pktinfo *pkt)
+{
+	const struct nft_meta *meta = nft_expr_priv(expr);
+	struct sk_buff *skb = pkt->skb;
+	u32 value = data[meta->sreg].data[0];
+
+	switch (meta->key) {
+	case NFT_META_MARK:
+		skb->mark = value;
+		break;
+	case NFT_META_PRIORITY:
+		skb->priority = value;
+		break;
+	case NFT_META_NFTRACE:
+		skb->nf_trace = 1;
+		break;
+	default:
+		WARN_ON(1);
+	}
+}
+
 static const struct nla_policy nft_meta_policy[NFTA_META_MAX + 1] = {
 	[NFTA_META_DREG]	= { .type = NLA_U32 },
 	[NFTA_META_KEY]		= { .type = NLA_U32 },
+	[NFTA_META_SREG]	= { .type = NLA_U32 },
 };
 
-static int nft_meta_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
-			 const struct nlattr * const tb[])
+static int nft_meta_init_validate_set(uint32_t key)
 {
-	struct nft_meta *priv = nft_expr_priv(expr);
-	int err;
-
-	if (tb[NFTA_META_DREG] == NULL ||
-	    tb[NFTA_META_KEY] == NULL)
-		return -EINVAL;
+	switch (key) {
+	case NFT_META_MARK:
+	case NFT_META_PRIORITY:
+	case NFT_META_NFTRACE:
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
 
-	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
-	switch (priv->key) {
+static int nft_meta_init_validate_get(uint32_t key)
+{
+	switch (key) {
 	case NFT_META_LEN:
 	case NFT_META_PROTOCOL:
 	case NFT_META_PRIORITY:
@@ -167,26 +197,69 @@ static int nft_meta_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 #ifdef CONFIG_NETWORK_SECMARK
 	case NFT_META_SECMARK:
 #endif
-		break;
+		return 0;
 	default:
 		return -EOPNOTSUPP;
 	}
 
-	priv->dreg = ntohl(nla_get_be32(tb[NFTA_META_DREG]));
-	err = nft_validate_output_register(priv->dreg);
+}
+
+static int nft_meta_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+			 const struct nlattr * const tb[])
+{
+	struct nft_meta *priv = nft_expr_priv(expr);
+	int err;
+
+	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
+
+	if (tb[NFTA_META_DREG]) {
+		err = nft_meta_init_validate_get(priv->key);
+		if (err < 0)
+			return err;
+
+		priv->dreg = ntohl(nla_get_be32(tb[NFTA_META_DREG]));
+		err = nft_validate_output_register(priv->dreg);
+		if (err < 0)
+			return err;
+
+		return nft_validate_data_load(ctx, priv->dreg, NULL,
+					      NFT_DATA_VALUE);
+	}
+
+	err = nft_meta_init_validate_set(priv->key);
 	if (err < 0)
 		return err;
-	return nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
+
+	priv->sreg = ntohl(nla_get_be32(tb[NFTA_META_SREG]));
+
+	return 0;
 }
 
-static int nft_meta_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_meta_get_dump(struct sk_buff *skb,
+			     const struct nft_expr *expr)
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 
+	if (nla_put_be32(skb, NFTA_META_KEY, htonl(priv->key)))
+		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_META_DREG, htonl(priv->dreg)))
 		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static int nft_meta_set_dump(struct sk_buff *skb,
+			     const struct nft_expr *expr)
+{
+	const struct nft_meta *priv = nft_expr_priv(expr);
+
 	if (nla_put_be32(skb, NFTA_META_KEY, htonl(priv->key)))
 		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_META_SREG, htonl(priv->sreg)))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -194,17 +267,44 @@ nla_put_failure:
 }
 
 static struct nft_expr_type nft_meta_type;
-static const struct nft_expr_ops nft_meta_ops = {
+static const struct nft_expr_ops nft_meta_get_ops = {
 	.type		= &nft_meta_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_meta)),
-	.eval		= nft_meta_eval,
+	.eval		= nft_meta_get_eval,
 	.init		= nft_meta_init,
-	.dump		= nft_meta_dump,
+	.dump		= nft_meta_get_dump,
 };
 
+static const struct nft_expr_ops nft_meta_set_ops = {
+	.type		= &nft_meta_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_meta)),
+	.eval		= nft_meta_set_eval,
+	.init		= nft_meta_init,
+	.dump		= nft_meta_set_dump,
+};
+
+static const struct nft_expr_ops *
+nft_meta_select_ops(const struct nft_ctx *ctx,
+		    const struct nlattr * const tb[])
+{
+	if (tb[NFTA_META_KEY] == NULL)
+		return ERR_PTR(-EINVAL);
+
+	if (tb[NFTA_META_DREG] && tb[NFTA_META_SREG])
+		return ERR_PTR(-EINVAL);
+
+	if (tb[NFTA_META_DREG])
+		return &nft_meta_get_ops;
+
+	if (tb[NFTA_META_SREG])
+		return &nft_meta_set_ops;
+
+	return ERR_PTR(-EINVAL);
+}
+
 static struct nft_expr_type nft_meta_type __read_mostly = {
 	.name		= "meta",
-	.ops		= &nft_meta_ops,
+	.select_ops	= &nft_meta_select_ops,
 	.policy		= nft_meta_policy,
 	.maxattr	= NFTA_META_MAX,
 	.owner		= THIS_MODULE,
-- 
1.7.10.4

