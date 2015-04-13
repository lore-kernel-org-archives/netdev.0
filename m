From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/21] netfilter: nft_dynset: dynamic stateful expression instantiation
Date: Mon, 13 Apr 2015 21:29:59 +0200
Message-ID: <1428953401-4838-21-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39738 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754622AbbDMT0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:26:05 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Support instantiating stateful expressions based on a template that
are associated with dynamically created set entries. The expressions
are evaluated when adding or updating the set element.

This allows to maintain per flow state using the existing set
infrastructure and expression types, with arbitrary definitions of
a flow.

Usage is currently restricted to anonymous sets, meaning only a single
binding can exist, since the desired semantics of multiple independant
bindings haven't been defined so far.

Examples (userspace syntax is still WIP):

1. Limit the rate of new SSH connections per host, similar to iptables
   hashlimit:

	flow ip saddr timeout 60s \
	limit 10/second \
	accept

2. Account network traffic between each set of /24 networks:

	flow ip saddr & 255.255.255.0 . ip daddr & 255.255.255.0 \
	counter

3. Account traffic to each host per user:

	flow skuid . ip daddr \
	counter

4. Account traffic for each combination of source address and TCP flags:

	flow ip saddr . tcp flags \
	counter

The resulting set content after a Xmas-scan look like this:

{
	192.168.122.1 . fin | psh | urg : counter packets 1001 bytes 40040,
	192.168.122.1 . ack : counter packets 74 bytes 3848,
	192.168.122.1 . psh | ack : counter packets 35 bytes 3144
}

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nft_dynset.c               |   54 +++++++++++++++++++++++++++---
 2 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 4894238..5fa1cd0 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -567,6 +567,7 @@ enum nft_dynset_ops {
  * @NFTA_DYNSET_SREG_KEY: source register of the key (NLA_U32)
  * @NFTA_DYNSET_SREG_DATA: source register of the data (NLA_U32)
  * @NFTA_DYNSET_TIMEOUT: timeout value for the new element (NLA_U64)
+ * @NFTA_DYNSET_EXPR: expression (NLA_NESTED: nft_expr_attributes)
  */
 enum nft_dynset_attributes {
 	NFTA_DYNSET_UNSPEC,
@@ -576,6 +577,7 @@ enum nft_dynset_attributes {
 	NFTA_DYNSET_SREG_KEY,
 	NFTA_DYNSET_SREG_DATA,
 	NFTA_DYNSET_TIMEOUT,
+	NFTA_DYNSET_EXPR,
 	__NFTA_DYNSET_MAX,
 };
 #define NFTA_DYNSET_MAX		(__NFTA_DYNSET_MAX - 1)
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 03699d5..513a8ef 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -23,6 +23,7 @@ struct nft_dynset {
 	enum nft_registers		sreg_key:8;
 	enum nft_registers		sreg_data:8;
 	u64				timeout;
+	struct nft_expr			*expr;
 	struct nft_set_binding		binding;
 };
 
@@ -30,6 +31,7 @@ static void *nft_dynset_new(struct nft_set *set, const struct nft_expr *expr,
 			    struct nft_regs *regs)
 {
 	const struct nft_dynset *priv = nft_expr_priv(expr);
+	struct nft_set_ext *ext;
 	u64 timeout;
 	void *elem;
 
@@ -44,7 +46,13 @@ static void *nft_dynset_new(struct nft_set *set, const struct nft_expr *expr,
 	if (elem == NULL) {
 		if (set->size)
 			atomic_dec(&set->nelems);
+		return NULL;
 	}
+
+	ext = nft_set_elem_ext(set, elem);
+	if (priv->expr != NULL)
+		nft_expr_clone(nft_set_ext_expr(ext), priv->expr);
+
 	return elem;
 }
 
@@ -55,18 +63,27 @@ static void nft_dynset_eval(const struct nft_expr *expr,
 	const struct nft_dynset *priv = nft_expr_priv(expr);
 	struct nft_set *set = priv->set;
 	const struct nft_set_ext *ext;
+	const struct nft_expr *sexpr;
 	u64 timeout;
 
 	if (set->ops->update(set, &regs->data[priv->sreg_key], nft_dynset_new,
 			     expr, regs, &ext)) {
+		sexpr = NULL;
+		if (nft_set_ext_exists(ext, NFT_SET_EXT_EXPR))
+			sexpr = nft_set_ext_expr(ext);
+
 		if (priv->op == NFT_DYNSET_OP_UPDATE &&
 		    nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION)) {
 			timeout = priv->timeout ? : set->timeout;
 			*nft_set_ext_expiration(ext) = jiffies + timeout;
-			return;
-		}
-	}
+		} else if (sexpr == NULL)
+			goto out;
 
+		if (sexpr != NULL)
+			sexpr->ops->eval(sexpr, regs, pkt);
+		return;
+	}
+out:
 	regs->verdict.code = NFT_BREAK;
 }
 
@@ -77,6 +94,7 @@ static const struct nla_policy nft_dynset_policy[NFTA_DYNSET_MAX + 1] = {
 	[NFTA_DYNSET_SREG_KEY]	= { .type = NLA_U32 },
 	[NFTA_DYNSET_SREG_DATA]	= { .type = NLA_U32 },
 	[NFTA_DYNSET_TIMEOUT]	= { .type = NLA_U64 },
+	[NFTA_DYNSET_EXPR]	= { .type = NLA_NESTED },
 };
 
 static int nft_dynset_init(const struct nft_ctx *ctx,
@@ -142,10 +160,29 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	} else if (set->flags & NFT_SET_MAP)
 		return -EINVAL;
 
+	if (tb[NFTA_DYNSET_EXPR] != NULL) {
+		if (!(set->flags & NFT_SET_EVAL))
+			return -EINVAL;
+		if (!(set->flags & NFT_SET_ANONYMOUS))
+			return -EOPNOTSUPP;
+
+		priv->expr = nft_expr_init(ctx, tb[NFTA_DYNSET_EXPR]);
+		if (IS_ERR(priv->expr))
+			return PTR_ERR(priv->expr);
+
+		err = -EOPNOTSUPP;
+		if (!(priv->expr->ops->type->flags & NFT_EXPR_STATEFUL))
+			goto err1;
+	} else if (set->flags & NFT_SET_EVAL)
+		return -EINVAL;
+
 	nft_set_ext_prepare(&priv->tmpl);
 	nft_set_ext_add_length(&priv->tmpl, NFT_SET_EXT_KEY, set->klen);
 	if (set->flags & NFT_SET_MAP)
 		nft_set_ext_add_length(&priv->tmpl, NFT_SET_EXT_DATA, set->dlen);
+	if (priv->expr != NULL)
+		nft_set_ext_add_length(&priv->tmpl, NFT_SET_EXT_EXPR,
+				       priv->expr->ops->size);
 	if (set->flags & NFT_SET_TIMEOUT) {
 		if (timeout || set->timeout)
 			nft_set_ext_add(&priv->tmpl, NFT_SET_EXT_EXPIRATION);
@@ -155,10 +192,15 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 
 	err = nf_tables_bind_set(ctx, set, &priv->binding);
 	if (err < 0)
-		return err;
+		goto err1;
 
 	priv->set = set;
 	return 0;
+
+err1:
+	if (priv->expr != NULL)
+		nft_expr_destroy(ctx, priv->expr);
+	return err;
 }
 
 static void nft_dynset_destroy(const struct nft_ctx *ctx,
@@ -167,6 +209,8 @@ static void nft_dynset_destroy(const struct nft_ctx *ctx,
 	struct nft_dynset *priv = nft_expr_priv(expr);
 
 	nf_tables_unbind_set(ctx, priv->set, &priv->binding);
+	if (priv->expr != NULL)
+		nft_expr_destroy(ctx, priv->expr);
 }
 
 static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
@@ -184,6 +228,8 @@ static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 	if (nla_put_be64(skb, NFTA_DYNSET_TIMEOUT, cpu_to_be64(priv->timeout)))
 		goto nla_put_failure;
+	if (priv->expr && nft_expr_dump(skb, NFTA_DYNSET_EXPR, priv->expr))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.10.4
