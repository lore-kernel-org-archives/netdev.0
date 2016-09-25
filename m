From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/53] netfilter: nft_numgen: add number generation offset
Date: Mon, 26 Sep 2016 01:06:37 +0200
Message-ID: <1474844823-2026-28-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laura Garcia Liebana <nevola@gmail.com>

Add support of an offset value for incremental counter and random. With
this option the sysadmin is able to start the counter to a certain value
and then apply the generated number.

Example:

	meta mark set numgen inc mod 2 offset 100

This will generate marks with the serie 100, 101, 100, 101, ...

Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nft_numgen.c               | 32 ++++++++++++++++++++++++++------
 2 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index bc0eb6a1066d..bcfb892ff148 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1136,12 +1136,14 @@ enum nft_trace_types {
  * @NFTA_NG_DREG: destination register (NLA_U32)
  * @NFTA_NG_MODULUS: maximum counter value (NLA_U32)
  * @NFTA_NG_TYPE: operation type (NLA_U32)
+ * @NFTA_NG_OFFSET: offset to be added to the counter (NLA_U32)
  */
 enum nft_ng_attributes {
 	NFTA_NG_UNSPEC,
 	NFTA_NG_DREG,
 	NFTA_NG_MODULUS,
 	NFTA_NG_TYPE,
+	NFTA_NG_OFFSET,
 	__NFTA_NG_MAX
 };
 #define NFTA_NG_MAX	(__NFTA_NG_MAX - 1)
diff --git a/net/netfilter/nft_numgen.c b/net/netfilter/nft_numgen.c
index f173ebec30a7..55bc5ab78d4a 100644
--- a/net/netfilter/nft_numgen.c
+++ b/net/netfilter/nft_numgen.c
@@ -23,6 +23,7 @@ struct nft_ng_inc {
 	enum nft_registers      dreg:8;
 	u32			modulus;
 	atomic_t		counter;
+	u32			offset;
 };
 
 static void nft_ng_inc_eval(const struct nft_expr *expr,
@@ -37,13 +38,14 @@ static void nft_ng_inc_eval(const struct nft_expr *expr,
 		nval = (oval + 1 < priv->modulus) ? oval + 1 : 0;
 	} while (atomic_cmpxchg(&priv->counter, oval, nval) != oval);
 
-	regs->data[priv->dreg] = nval;
+	regs->data[priv->dreg] = nval + priv->offset;
 }
 
 static const struct nla_policy nft_ng_policy[NFTA_NG_MAX + 1] = {
 	[NFTA_NG_DREG]		= { .type = NLA_U32 },
 	[NFTA_NG_MODULUS]	= { .type = NLA_U32 },
 	[NFTA_NG_TYPE]		= { .type = NLA_U32 },
+	[NFTA_NG_OFFSET]	= { .type = NLA_U32 },
 };
 
 static int nft_ng_inc_init(const struct nft_ctx *ctx,
@@ -52,10 +54,16 @@ static int nft_ng_inc_init(const struct nft_ctx *ctx,
 {
 	struct nft_ng_inc *priv = nft_expr_priv(expr);
 
+	if (tb[NFTA_NG_OFFSET])
+		priv->offset = ntohl(nla_get_be32(tb[NFTA_NG_OFFSET]));
+
 	priv->modulus = ntohl(nla_get_be32(tb[NFTA_NG_MODULUS]));
 	if (priv->modulus == 0)
 		return -ERANGE;
 
+	if (priv->offset + priv->modulus - 1 < priv->offset)
+		return -EOVERFLOW;
+
 	priv->dreg = nft_parse_register(tb[NFTA_NG_DREG]);
 	atomic_set(&priv->counter, 0);
 
@@ -64,7 +72,7 @@ static int nft_ng_inc_init(const struct nft_ctx *ctx,
 }
 
 static int nft_ng_dump(struct sk_buff *skb, enum nft_registers dreg,
-		       u32 modulus, enum nft_ng_types type)
+		       u32 modulus, enum nft_ng_types type, u32 offset)
 {
 	if (nft_dump_register(skb, NFTA_NG_DREG, dreg))
 		goto nla_put_failure;
@@ -72,6 +80,8 @@ static int nft_ng_dump(struct sk_buff *skb, enum nft_registers dreg,
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_NG_TYPE, htonl(type)))
 		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_NG_OFFSET, htonl(offset)))
+		goto nla_put_failure;
 
 	return 0;
 
@@ -83,12 +93,14 @@ static int nft_ng_inc_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_ng_inc *priv = nft_expr_priv(expr);
 
-	return nft_ng_dump(skb, priv->dreg, priv->modulus, NFT_NG_INCREMENTAL);
+	return nft_ng_dump(skb, priv->dreg, priv->modulus, NFT_NG_INCREMENTAL,
+			   priv->offset);
 }
 
 struct nft_ng_random {
 	enum nft_registers      dreg:8;
 	u32			modulus;
+	u32			offset;
 };
 
 static void nft_ng_random_eval(const struct nft_expr *expr,
@@ -97,9 +109,10 @@ static void nft_ng_random_eval(const struct nft_expr *expr,
 {
 	struct nft_ng_random *priv = nft_expr_priv(expr);
 	struct rnd_state *state = this_cpu_ptr(&nft_numgen_prandom_state);
+	u32 val;
 
-	regs->data[priv->dreg] = reciprocal_scale(prandom_u32_state(state),
-						  priv->modulus);
+	val = reciprocal_scale(prandom_u32_state(state), priv->modulus);
+	regs->data[priv->dreg] = val + priv->offset;
 }
 
 static int nft_ng_random_init(const struct nft_ctx *ctx,
@@ -108,10 +121,16 @@ static int nft_ng_random_init(const struct nft_ctx *ctx,
 {
 	struct nft_ng_random *priv = nft_expr_priv(expr);
 
+	if (tb[NFTA_NG_OFFSET])
+		priv->offset = ntohl(nla_get_be32(tb[NFTA_NG_OFFSET]));
+
 	priv->modulus = ntohl(nla_get_be32(tb[NFTA_NG_MODULUS]));
 	if (priv->modulus == 0)
 		return -ERANGE;
 
+	if (priv->offset + priv->modulus - 1 < priv->offset)
+		return -EOVERFLOW;
+
 	prandom_init_once(&nft_numgen_prandom_state);
 
 	priv->dreg = nft_parse_register(tb[NFTA_NG_DREG]);
@@ -124,7 +143,8 @@ static int nft_ng_random_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_ng_random *priv = nft_expr_priv(expr);
 
-	return nft_ng_dump(skb, priv->dreg, priv->modulus, NFT_NG_RANDOM);
+	return nft_ng_dump(skb, priv->dreg, priv->modulus, NFT_NG_RANDOM,
+			   priv->offset);
 }
 
 static struct nft_expr_type nft_ng_type;
-- 
2.1.4

