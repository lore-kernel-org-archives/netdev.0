From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/7] netfilter: nft_compat: validate chain type in match/target
Date: Mon, 20 Oct 2014 10:10:36 +0200
Message-ID: <1413792639-3954-5-git-send-email-pablo@netfilter.org>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40032 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813AbaJTIJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 04:09:17 -0400
In-Reply-To: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to validate the real chain type to ensure that matches/targets
are not used out from their scope (eg. MASQUERADE in nat chain type).
The existing validation relies on the table name, but this is not
sufficient since userspace can fool us by using the appropriate table
name with a different chain type.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |   75 ++++++++++++++++++++++++++++++++++++++------
 1 file changed, 66 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 44ae273..0480f57 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -19,9 +19,52 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
-#include <asm/uaccess.h> /* for set_fs */
 #include <net/netfilter/nf_tables.h>
 
+static const struct {
+       const char	*name;
+       u8		type;
+} table_to_chaintype[] = {
+       { "filter",     NFT_CHAIN_T_DEFAULT },
+       { "raw",        NFT_CHAIN_T_DEFAULT },
+       { "security",   NFT_CHAIN_T_DEFAULT },
+       { "mangle",     NFT_CHAIN_T_ROUTE },
+       { "nat",        NFT_CHAIN_T_NAT },
+       { },
+};
+
+static int nft_compat_table_to_chaintype(const char *table)
+{
+	int i;
+
+	for (i = 0; table_to_chaintype[i].name != NULL; i++) {
+		if (strcmp(table_to_chaintype[i].name, table) == 0)
+			return table_to_chaintype[i].type;
+	}
+
+	return -1;
+}
+
+static int nft_compat_chain_validate_dependency(const char *tablename,
+						const struct nft_chain *chain)
+{
+	enum nft_chain_type type;
+	const struct nft_base_chain *basechain;
+
+	if (!tablename || !(chain->flags & NFT_BASE_CHAIN))
+		return 0;
+
+	type = nft_compat_table_to_chaintype(tablename);
+	if (type < 0)
+		return -EINVAL;
+
+	basechain = nft_base_chain(chain);
+	if (basechain->type->type != type)
+		return -EINVAL;
+
+	return 0;
+}
+
 union nft_entry {
 	struct ipt_entry e4;
 	struct ip6t_entry e6;
@@ -153,6 +196,10 @@ nft_target_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	union nft_entry e = {};
 	int ret;
 
+	ret = nft_compat_chain_validate_dependency(target->table, ctx->chain);
+	if (ret < 0)
+		goto err;
+
 	target_compat_from_user(target, nla_data(tb[NFTA_TARGET_INFO]), info);
 
 	if (ctx->nla[NFTA_RULE_COMPAT]) {
@@ -218,6 +265,7 @@ static int nft_target_validate(const struct nft_ctx *ctx,
 {
 	struct xt_target *target = expr->ops->data;
 	unsigned int hook_mask = 0;
+	int ret;
 
 	if (ctx->chain->flags & NFT_BASE_CHAIN) {
 		const struct nft_base_chain *basechain =
@@ -225,11 +273,13 @@ static int nft_target_validate(const struct nft_ctx *ctx,
 		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		hook_mask = 1 << ops->hooknum;
-		if (hook_mask & target->hooks)
-			return 0;
+		if (!(hook_mask & target->hooks))
+			return -EINVAL;
 
-		/* This target is being called from an invalid chain */
-		return -EINVAL;
+		ret = nft_compat_chain_validate_dependency(target->table,
+							   ctx->chain);
+		if (ret < 0)
+			return ret;
 	}
 	return 0;
 }
@@ -324,6 +374,10 @@ nft_match_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	union nft_entry e = {};
 	int ret;
 
+	ret = nft_compat_chain_validate_dependency(match->name, ctx->chain);
+	if (ret < 0)
+		goto err;
+
 	match_compat_from_user(match, nla_data(tb[NFTA_MATCH_INFO]), info);
 
 	if (ctx->nla[NFTA_RULE_COMPAT]) {
@@ -383,6 +437,7 @@ static int nft_match_validate(const struct nft_ctx *ctx,
 {
 	struct xt_match *match = expr->ops->data;
 	unsigned int hook_mask = 0;
+	int ret;
 
 	if (ctx->chain->flags & NFT_BASE_CHAIN) {
 		const struct nft_base_chain *basechain =
@@ -390,11 +445,13 @@ static int nft_match_validate(const struct nft_ctx *ctx,
 		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		hook_mask = 1 << ops->hooknum;
-		if (hook_mask & match->hooks)
-			return 0;
+		if (!(hook_mask & match->hooks))
+			return -EINVAL;
 
-		/* This match is being called from an invalid chain */
-		return -EINVAL;
+		ret = nft_compat_chain_validate_dependency(match->name,
+							   ctx->chain);
+		if (ret < 0)
+			return ret;
 	}
 	return 0;
 }
-- 
1.7.10.4
