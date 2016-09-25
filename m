From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/53] netfilter: nft_numgen: rename until attribute by modulus
Date: Mon, 26 Sep 2016 01:06:17 +0200
Message-ID: <1474844823-2026-8-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54532 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941183AbcIYXH1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:27 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CBED7C0B40
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BB449DA842
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9D1ECDA818
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:23 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Garcia Liebana <nevola@gmail.com>

The _until_ attribute is renamed to _modulus_ as the behaviour is similar to
other expresions with number limits (ex. nft_hash).

Renaming is possible because there isn't a kernel release yet with these
changes.

Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  4 ++--
 net/netfilter/nft_numgen.c               | 30 +++++++++++++++---------------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 28ce01d79707..24161e25576d 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1126,13 +1126,13 @@ enum nft_trace_types {
  * enum nft_ng_attributes - nf_tables number generator expression netlink attributes
  *
  * @NFTA_NG_DREG: destination register (NLA_U32)
- * @NFTA_NG_UNTIL: source value to increment the counter until reset (NLA_U32)
+ * @NFTA_NG_MODULUS: maximum counter value (NLA_U32)
  * @NFTA_NG_TYPE: operation type (NLA_U32)
  */
 enum nft_ng_attributes {
 	NFTA_NG_UNSPEC,
 	NFTA_NG_DREG,
-	NFTA_NG_UNTIL,
+	NFTA_NG_MODULUS,
 	NFTA_NG_TYPE,
 	__NFTA_NG_MAX
 };
diff --git a/net/netfilter/nft_numgen.c b/net/netfilter/nft_numgen.c
index 294745ecb0fc..f51a3ede3932 100644
--- a/net/netfilter/nft_numgen.c
+++ b/net/netfilter/nft_numgen.c
@@ -21,7 +21,7 @@ static DEFINE_PER_CPU(struct rnd_state, nft_numgen_prandom_state);
 
 struct nft_ng_inc {
 	enum nft_registers      dreg:8;
-	u32			until;
+	u32			modulus;
 	atomic_t		counter;
 };
 
@@ -34,7 +34,7 @@ static void nft_ng_inc_eval(const struct nft_expr *expr,
 
 	do {
 		oval = atomic_read(&priv->counter);
-		nval = (oval + 1 < priv->until) ? oval + 1 : 0;
+		nval = (oval + 1 < priv->modulus) ? oval + 1 : 0;
 	} while (atomic_cmpxchg(&priv->counter, oval, nval) != oval);
 
 	memcpy(&regs->data[priv->dreg], &priv->counter, sizeof(u32));
@@ -42,7 +42,7 @@ static void nft_ng_inc_eval(const struct nft_expr *expr,
 
 static const struct nla_policy nft_ng_policy[NFTA_NG_MAX + 1] = {
 	[NFTA_NG_DREG]		= { .type = NLA_U32 },
-	[NFTA_NG_UNTIL]		= { .type = NLA_U32 },
+	[NFTA_NG_MODULUS]	= { .type = NLA_U32 },
 	[NFTA_NG_TYPE]		= { .type = NLA_U32 },
 };
 
@@ -52,8 +52,8 @@ static int nft_ng_inc_init(const struct nft_ctx *ctx,
 {
 	struct nft_ng_inc *priv = nft_expr_priv(expr);
 
-	priv->until = ntohl(nla_get_be32(tb[NFTA_NG_UNTIL]));
-	if (priv->until == 0)
+	priv->modulus = ntohl(nla_get_be32(tb[NFTA_NG_MODULUS]));
+	if (priv->modulus == 0)
 		return -ERANGE;
 
 	priv->dreg = nft_parse_register(tb[NFTA_NG_DREG]);
@@ -64,11 +64,11 @@ static int nft_ng_inc_init(const struct nft_ctx *ctx,
 }
 
 static int nft_ng_dump(struct sk_buff *skb, enum nft_registers dreg,
-		       u32 until, enum nft_ng_types type)
+		       u32 modulus, enum nft_ng_types type)
 {
 	if (nft_dump_register(skb, NFTA_NG_DREG, dreg))
 		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_NG_UNTIL, htonl(until)))
+	if (nla_put_be32(skb, NFTA_NG_MODULUS, htonl(modulus)))
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_NG_TYPE, htonl(type)))
 		goto nla_put_failure;
@@ -83,12 +83,12 @@ static int nft_ng_inc_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_ng_inc *priv = nft_expr_priv(expr);
 
-	return nft_ng_dump(skb, priv->dreg, priv->until, NFT_NG_INCREMENTAL);
+	return nft_ng_dump(skb, priv->dreg, priv->modulus, NFT_NG_INCREMENTAL);
 }
 
 struct nft_ng_random {
 	enum nft_registers      dreg:8;
-	u32			until;
+	u32			modulus;
 };
 
 static void nft_ng_random_eval(const struct nft_expr *expr,
@@ -99,7 +99,7 @@ static void nft_ng_random_eval(const struct nft_expr *expr,
 	struct rnd_state *state = this_cpu_ptr(&nft_numgen_prandom_state);
 
 	regs->data[priv->dreg] = reciprocal_scale(prandom_u32_state(state),
-						  priv->until);
+						  priv->modulus);
 }
 
 static int nft_ng_random_init(const struct nft_ctx *ctx,
@@ -108,8 +108,8 @@ static int nft_ng_random_init(const struct nft_ctx *ctx,
 {
 	struct nft_ng_random *priv = nft_expr_priv(expr);
 
-	priv->until = ntohl(nla_get_be32(tb[NFTA_NG_UNTIL]));
-	if (priv->until == 0)
+	priv->modulus = ntohl(nla_get_be32(tb[NFTA_NG_MODULUS]));
+	if (priv->modulus == 0)
 		return -ERANGE;
 
 	prandom_init_once(&nft_numgen_prandom_state);
@@ -124,7 +124,7 @@ static int nft_ng_random_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_ng_random *priv = nft_expr_priv(expr);
 
-	return nft_ng_dump(skb, priv->dreg, priv->until, NFT_NG_RANDOM);
+	return nft_ng_dump(skb, priv->dreg, priv->modulus, NFT_NG_RANDOM);
 }
 
 static struct nft_expr_type nft_ng_type;
@@ -149,8 +149,8 @@ nft_ng_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 {
 	u32 type;
 
-	if (!tb[NFTA_NG_DREG]	||
-	    !tb[NFTA_NG_UNTIL]	||
+	if (!tb[NFTA_NG_DREG]	 ||
+	    !tb[NFTA_NG_MODULUS] ||
 	    !tb[NFTA_NG_TYPE])
 		return ERR_PTR(-EINVAL);
 
-- 
2.1.4
