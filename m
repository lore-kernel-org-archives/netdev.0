From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/53] netfilter: nf_tables: add nft_is_base_chain() helper
Date: Mon,  1 May 2017 12:46:31 +0200
Message-ID: <1493635640-24325-5-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49632 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S3000701AbdEAKrh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:47:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9C3891F4B92
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8E514DA870
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 44AA1FF14F
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:28 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new helper function allows us to check if this is a basechain.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  5 +++++
 net/netfilter/nf_tables_api.c     | 30 +++++++++++++++---------------
 net/netfilter/nf_tables_netdev.c  |  2 +-
 net/netfilter/nft_compat.c        | 11 ++++++-----
 4 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f713a053f89d..028faec8fc27 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -911,6 +911,11 @@ static inline struct nft_base_chain *nft_base_chain(const struct nft_chain *chai
 	return container_of(chain, struct nft_base_chain, chain);
 }
 
+static inline bool nft_is_base_chain(const struct nft_chain *chain)
+{
+	return chain->flags & NFT_BASE_CHAIN;
+}
+
 int __nft_release_basechain(struct nft_ctx *ctx);
 
 unsigned int nft_do_chain(struct nft_pktinfo *pkt, void *priv);
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2d822d2fd830..bf52acfe4eff 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -144,7 +144,7 @@ static int nf_tables_register_hooks(struct net *net,
 				    unsigned int hook_nops)
 {
 	if (table->flags & NFT_TABLE_F_DORMANT ||
-	    !(chain->flags & NFT_BASE_CHAIN))
+	    !nft_is_base_chain(chain))
 		return 0;
 
 	return nf_register_net_hooks(net, nft_base_chain(chain)->ops,
@@ -157,7 +157,7 @@ static void nf_tables_unregister_hooks(struct net *net,
 				       unsigned int hook_nops)
 {
 	if (table->flags & NFT_TABLE_F_DORMANT ||
-	    !(chain->flags & NFT_BASE_CHAIN))
+	    !nft_is_base_chain(chain))
 		return;
 
 	nf_unregister_net_hooks(net, nft_base_chain(chain)->ops, hook_nops);
@@ -587,7 +587,7 @@ static void _nf_tables_table_disable(struct net *net,
 	list_for_each_entry(chain, &table->chains, list) {
 		if (!nft_is_active_next(net, chain))
 			continue;
-		if (!(chain->flags & NFT_BASE_CHAIN))
+		if (!nft_is_base_chain(chain))
 			continue;
 
 		if (cnt && i++ == cnt)
@@ -608,7 +608,7 @@ static int nf_tables_table_enable(struct net *net,
 	list_for_each_entry(chain, &table->chains, list) {
 		if (!nft_is_active_next(net, chain))
 			continue;
-		if (!(chain->flags & NFT_BASE_CHAIN))
+		if (!nft_is_base_chain(chain))
 			continue;
 
 		err = nf_register_net_hooks(net, nft_base_chain(chain)->ops,
@@ -1007,7 +1007,7 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, struct net *net,
 	if (nla_put_string(skb, NFTA_CHAIN_NAME, chain->name))
 		goto nla_put_failure;
 
-	if (chain->flags & NFT_BASE_CHAIN) {
+	if (nft_is_base_chain(chain)) {
 		const struct nft_base_chain *basechain = nft_base_chain(chain);
 		const struct nf_hook_ops *ops = &basechain->ops[0];
 		struct nlattr *nest;
@@ -1226,7 +1226,7 @@ static void nf_tables_chain_destroy(struct nft_chain *chain)
 {
 	BUG_ON(chain->use > 0);
 
-	if (chain->flags & NFT_BASE_CHAIN) {
+	if (nft_is_base_chain(chain)) {
 		struct nft_base_chain *basechain = nft_base_chain(chain);
 
 		module_put(basechain->type->owner);
@@ -1364,8 +1364,8 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 	}
 
 	if (nla[NFTA_CHAIN_POLICY]) {
-		if ((chain != NULL &&
-		    !(chain->flags & NFT_BASE_CHAIN)))
+		if (chain != NULL &&
+		    !nft_is_base_chain(chain))
 			return -EOPNOTSUPP;
 
 		if (chain == NULL &&
@@ -1396,7 +1396,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 			struct nft_chain_hook hook;
 			struct nf_hook_ops *ops;
 
-			if (!(chain->flags & NFT_BASE_CHAIN))
+			if (!nft_is_base_chain(chain))
 				return -EBUSY;
 
 			err = nft_chain_parse_hook(net, nla, afi, &hook,
@@ -1433,7 +1433,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 		}
 
 		if (nla[NFTA_CHAIN_COUNTERS]) {
-			if (!(chain->flags & NFT_BASE_CHAIN))
+			if (!nft_is_base_chain(chain))
 				return -EOPNOTSUPP;
 
 			stats = nft_stats_alloc(nla[NFTA_CHAIN_COUNTERS]);
@@ -4708,7 +4708,7 @@ static void nft_chain_commit_update(struct nft_trans *trans)
 	if (nft_trans_chain_name(trans)[0])
 		strcpy(trans->ctx.chain->name, nft_trans_chain_name(trans));
 
-	if (!(trans->ctx.chain->flags & NFT_BASE_CHAIN))
+	if (!nft_is_base_chain(trans->ctx.chain))
 		return;
 
 	basechain = nft_base_chain(trans->ctx.chain);
@@ -5022,7 +5022,7 @@ int nft_chain_validate_dependency(const struct nft_chain *chain,
 {
 	const struct nft_base_chain *basechain;
 
-	if (chain->flags & NFT_BASE_CHAIN) {
+	if (nft_is_base_chain(chain)) {
 		basechain = nft_base_chain(chain);
 		if (basechain->type->type != type)
 			return -EOPNOTSUPP;
@@ -5036,7 +5036,7 @@ int nft_chain_validate_hooks(const struct nft_chain *chain,
 {
 	struct nft_base_chain *basechain;
 
-	if (chain->flags & NFT_BASE_CHAIN) {
+	if (nft_is_base_chain(chain)) {
 		basechain = nft_base_chain(chain);
 
 		if ((1 << basechain->ops[0].hooknum) & hook_flags)
@@ -5345,7 +5345,7 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 					       tb[NFTA_VERDICT_CHAIN], genmask);
 		if (IS_ERR(chain))
 			return PTR_ERR(chain);
-		if (chain->flags & NFT_BASE_CHAIN)
+		if (nft_is_base_chain(chain))
 			return -EOPNOTSUPP;
 
 		chain->use++;
@@ -5518,7 +5518,7 @@ int __nft_release_basechain(struct nft_ctx *ctx)
 {
 	struct nft_rule *rule, *nr;
 
-	BUG_ON(!(ctx->chain->flags & NFT_BASE_CHAIN));
+	BUG_ON(!nft_is_base_chain(ctx->chain));
 
 	nf_tables_unregister_hooks(ctx->net, ctx->chain->table, ctx->chain,
 				   ctx->afi->nops);
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 9e2ae424b640..403432988313 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -128,7 +128,7 @@ static int nf_tables_netdev_event(struct notifier_block *this,
 		list_for_each_entry(table, &afi->tables, list) {
 			ctx.table = table;
 			list_for_each_entry_safe(chain, nr, &table->chains, list) {
-				if (!(chain->flags & NFT_BASE_CHAIN))
+				if (!nft_is_base_chain(chain))
 					continue;
 
 				ctx.chain = chain;
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index fab6bf3f955e..f443f9d22faf 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -42,7 +42,8 @@ static int nft_compat_chain_validate_dependency(const char *tablename,
 {
 	const struct nft_base_chain *basechain;
 
-	if (!tablename || !(chain->flags & NFT_BASE_CHAIN))
+	if (!tablename ||
+	    !nft_is_base_chain(chain))
 		return 0;
 
 	basechain = nft_base_chain(chain);
@@ -165,7 +166,7 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 	par->entryinfo	= entry;
 	par->target	= target;
 	par->targinfo	= info;
-	if (ctx->chain->flags & NFT_BASE_CHAIN) {
+	if (nft_is_base_chain(ctx->chain)) {
 		const struct nft_base_chain *basechain =
 						nft_base_chain(ctx->chain);
 		const struct nf_hook_ops *ops = &basechain->ops[0];
@@ -298,7 +299,7 @@ static int nft_target_validate(const struct nft_ctx *ctx,
 	unsigned int hook_mask = 0;
 	int ret;
 
-	if (ctx->chain->flags & NFT_BASE_CHAIN) {
+	if (nft_is_base_chain(ctx->chain)) {
 		const struct nft_base_chain *basechain =
 						nft_base_chain(ctx->chain);
 		const struct nf_hook_ops *ops = &basechain->ops[0];
@@ -379,7 +380,7 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 	par->entryinfo	= entry;
 	par->match	= match;
 	par->matchinfo	= info;
-	if (ctx->chain->flags & NFT_BASE_CHAIN) {
+	if (nft_is_base_chain(ctx->chain)) {
 		const struct nft_base_chain *basechain =
 						nft_base_chain(ctx->chain);
 		const struct nf_hook_ops *ops = &basechain->ops[0];
@@ -477,7 +478,7 @@ static int nft_match_validate(const struct nft_ctx *ctx,
 	unsigned int hook_mask = 0;
 	int ret;
 
-	if (ctx->chain->flags & NFT_BASE_CHAIN) {
+	if (nft_is_base_chain(ctx->chain)) {
 		const struct nft_base_chain *basechain =
 						nft_base_chain(ctx->chain);
 		const struct nf_hook_ops *ops = &basechain->ops[0];
-- 
2.1.4
