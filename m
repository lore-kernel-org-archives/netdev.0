From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/26] netfilter: nf_tables: add support for inverted logic in nft_lookup
Date: Wed,  6 Jul 2016 16:24:03 +0200
Message-ID: <1467815048-2240-22-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34319 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932295AbcGFO1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 10:27:01 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id CD9F417DB67
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:59 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BAEB2CA0FF
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:59 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9CF4DFAB53
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:55 +0200 (CEST)
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

Introduce a new configuration option for this expression, which allows users
to invert the logic of set lookups.

In _init() we will now return EINVAL if NFT_LOOKUP_F_INV is in anyway
related to a map lookup.

The code in the _eval() function has been untangled and updated to sopport the
XOR of options, as we should consider 4 cases:
 * lookup false, invert false -> NFT_BREAK
 * lookup false, invert true -> return w/o NFT_BREAK
 * lookup true, invert false -> return w/o NFT_BREAK
 * lookup true, invert true -> NFT_BREAK

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  6 ++++++
 net/netfilter/nft_lookup.c               | 37 +++++++++++++++++++++++++++-----
 2 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 6a4dbe0..01751fa 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -546,6 +546,10 @@ enum nft_cmp_attributes {
 };
 #define NFTA_CMP_MAX		(__NFTA_CMP_MAX - 1)
 
+enum nft_lookup_flags {
+	NFT_LOOKUP_F_INV = (1 << 0),
+};
+
 /**
  * enum nft_lookup_attributes - nf_tables set lookup expression netlink attributes
  *
@@ -553,6 +557,7 @@ enum nft_cmp_attributes {
  * @NFTA_LOOKUP_SREG: source register of the data to look for (NLA_U32: nft_registers)
  * @NFTA_LOOKUP_DREG: destination register (NLA_U32: nft_registers)
  * @NFTA_LOOKUP_SET_ID: uniquely identifies a set in a transaction (NLA_U32)
+ * @NFTA_LOOKUP_FLAGS: flags (NLA_U32: enum nft_lookup_flags)
  */
 enum nft_lookup_attributes {
 	NFTA_LOOKUP_UNSPEC,
@@ -560,6 +565,7 @@ enum nft_lookup_attributes {
 	NFTA_LOOKUP_SREG,
 	NFTA_LOOKUP_DREG,
 	NFTA_LOOKUP_SET_ID,
+	NFTA_LOOKUP_FLAGS,
 	__NFTA_LOOKUP_MAX
 };
 #define NFTA_LOOKUP_MAX		(__NFTA_LOOKUP_MAX - 1)
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 8a102cf..b8d18f5 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -22,6 +22,7 @@ struct nft_lookup {
 	struct nft_set			*set;
 	enum nft_registers		sreg:8;
 	enum nft_registers		dreg:8;
+	bool				invert;
 	struct nft_set_binding		binding;
 };
 
@@ -32,14 +33,20 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 	const struct nft_lookup *priv = nft_expr_priv(expr);
 	const struct nft_set *set = priv->set;
 	const struct nft_set_ext *ext;
+	bool found;
 
-	if (set->ops->lookup(set, &regs->data[priv->sreg], &ext)) {
-		if (set->flags & NFT_SET_MAP)
-			nft_data_copy(&regs->data[priv->dreg],
-				      nft_set_ext_data(ext), set->dlen);
+	found = set->ops->lookup(set, &regs->data[priv->sreg], &ext) ^
+		priv->invert;
+
+	if (!found) {
+		regs->verdict.code = NFT_BREAK;
 		return;
 	}
-	regs->verdict.code = NFT_BREAK;
+
+	if (found && set->flags & NFT_SET_MAP)
+		nft_data_copy(&regs->data[priv->dreg],
+			      nft_set_ext_data(ext), set->dlen);
+
 }
 
 static const struct nla_policy nft_lookup_policy[NFTA_LOOKUP_MAX + 1] = {
@@ -47,6 +54,7 @@ static const struct nla_policy nft_lookup_policy[NFTA_LOOKUP_MAX + 1] = {
 	[NFTA_LOOKUP_SET_ID]	= { .type = NLA_U32 },
 	[NFTA_LOOKUP_SREG]	= { .type = NLA_U32 },
 	[NFTA_LOOKUP_DREG]	= { .type = NLA_U32 },
+	[NFTA_LOOKUP_FLAGS]	= { .type = NLA_U32 },
 };
 
 static int nft_lookup_init(const struct nft_ctx *ctx,
@@ -56,6 +64,7 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 	struct nft_lookup *priv = nft_expr_priv(expr);
 	u8 genmask = nft_genmask_next(ctx->net);
 	struct nft_set *set;
+	u32 flags;
 	int err;
 
 	if (tb[NFTA_LOOKUP_SET] == NULL ||
@@ -81,7 +90,22 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
+	if (tb[NFTA_LOOKUP_FLAGS]) {
+		flags = ntohl(nla_get_be32(tb[NFTA_LOOKUP_FLAGS]));
+
+		if (flags & ~NFT_LOOKUP_F_INV)
+			return -EINVAL;
+
+		if (flags & NFT_LOOKUP_F_INV) {
+			if (set->flags & NFT_SET_MAP)
+				return -EINVAL;
+			priv->invert = true;
+		}
+	}
+
 	if (tb[NFTA_LOOKUP_DREG] != NULL) {
+		if (priv->invert)
+			return -EINVAL;
 		if (!(set->flags & NFT_SET_MAP))
 			return -EINVAL;
 
@@ -114,6 +138,7 @@ static void nft_lookup_destroy(const struct nft_ctx *ctx,
 static int nft_lookup_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_lookup *priv = nft_expr_priv(expr);
+	u32 flags = priv->invert ? NFT_LOOKUP_F_INV : 0;
 
 	if (nla_put_string(skb, NFTA_LOOKUP_SET, priv->set->name))
 		goto nla_put_failure;
@@ -122,6 +147,8 @@ static int nft_lookup_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	if (priv->set->flags & NFT_SET_MAP)
 		if (nft_dump_register(skb, NFTA_LOOKUP_DREG, priv->dreg))
 			goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_LOOKUP_FLAGS, htonl(flags)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
2.1.4
