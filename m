From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/53] netfilter: nft_hash: Add hash offset value
Date: Mon, 26 Sep 2016 01:06:23 +0200
Message-ID: <1474844823-2026-14-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laura Garcia Liebana <nevola@gmail.com>

Add support to pass through an offset to the hash value. With this
feature, the sysadmin is able to generate a hash with a given
offset value.

Example:

	meta mark set jhash ip saddr mod 2 seed 0xabcd offset 100

This option generates marks according to the source address from 100 to
101.

Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>
---
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nft_hash.c                 | 17 +++++++++++++----
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 24161e25576d..8c653bbd1ead 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -731,6 +731,7 @@ enum nft_meta_keys {
  * @NFTA_HASH_LEN: source data length (NLA_U32)
  * @NFTA_HASH_MODULUS: modulus value (NLA_U32)
  * @NFTA_HASH_SEED: seed value (NLA_U32)
+ * @NFTA_HASH_OFFSET: add this offset value to hash result (NLA_U32)
  */
 enum nft_hash_attributes {
 	NFTA_HASH_UNSPEC,
@@ -739,6 +740,7 @@ enum nft_hash_attributes {
 	NFTA_HASH_LEN,
 	NFTA_HASH_MODULUS,
 	NFTA_HASH_SEED,
+	NFTA_HASH_OFFSET,
 	__NFTA_HASH_MAX,
 };
 #define NFTA_HASH_MAX	(__NFTA_HASH_MAX - 1)
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 764251d31e46..bd12f7a801c2 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -23,6 +23,7 @@ struct nft_hash {
 	u8			len;
 	u32			modulus;
 	u32			seed;
+	u32			offset;
 };
 
 static void nft_hash_eval(const struct nft_expr *expr,
@@ -31,10 +32,10 @@ static void nft_hash_eval(const struct nft_expr *expr,
 {
 	struct nft_hash *priv = nft_expr_priv(expr);
 	const void *data = &regs->data[priv->sreg];
+	u32 h;
 
-	regs->data[priv->dreg] =
-		reciprocal_scale(jhash(data, priv->len, priv->seed),
-				 priv->modulus);
+	h = reciprocal_scale(jhash(data, priv->len, priv->seed), priv->modulus);
+	regs->data[priv->dreg] = h + priv->offset;
 }
 
 static const struct nla_policy nft_hash_policy[NFTA_HASH_MAX + 1] = {
@@ -59,6 +60,9 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 	    !tb[NFTA_HASH_MODULUS])
 		return -EINVAL;
 
+	if (tb[NFTA_HASH_OFFSET])
+		priv->offset = ntohl(nla_get_be32(tb[NFTA_HASH_OFFSET]));
+
 	priv->sreg = nft_parse_register(tb[NFTA_HASH_SREG]);
 	priv->dreg = nft_parse_register(tb[NFTA_HASH_DREG]);
 
@@ -72,6 +76,9 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 	if (priv->modulus <= 1)
 		return -ERANGE;
 
+	if (priv->offset + priv->modulus - 1 < U32_MAX)
+		return -EOVERFLOW;
+
 	priv->seed = ntohl(nla_get_be32(tb[NFTA_HASH_SEED]));
 
 	return nft_validate_register_load(priv->sreg, len) &&
@@ -94,7 +101,9 @@ static int nft_hash_dump(struct sk_buff *skb,
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_HASH_SEED, htonl(priv->seed)))
 		goto nla_put_failure;
-
+	if (priv->offset != 0)
+		if (nla_put_be32(skb, NFTA_HASH_OFFSET, htonl(priv->offset)))
+			goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
2.1.4

