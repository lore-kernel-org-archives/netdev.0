From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/23] netfilter: nf_tables: add support for multi family tables
Date: Fri, 10 Jan 2014 01:35:23 +0100
Message-ID: <1389314142-17969-5-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51514 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756872AbaAJAgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:05 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add support to register chains to multiple hooks for different address
families for mixed IPv4/IPv6 tables.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_tables.h       |    9 +++++-
 net/bridge/netfilter/nf_tables_bridge.c |    1 +
 net/ipv4/netfilter/nf_tables_arp.c      |    1 +
 net/ipv4/netfilter/nf_tables_ipv4.c     |    1 +
 net/ipv6/netfilter/nf_tables_ipv6.c     |    1 +
 net/netfilter/nf_tables_api.c           |   49 ++++++++++++++++++-------------
 net/netfilter/nft_compat.c              |    8 ++---
 7 files changed, 45 insertions(+), 25 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index c9e6316..f066f25 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -422,6 +422,8 @@ struct nft_stats {
 	u64 pkts;
 };
 
+#define NFT_HOOK_OPS_MAX		2
+
 /**
  *	struct nft_base_chain - nf_tables base chain
  *
@@ -432,7 +434,7 @@ struct nft_stats {
  *	@chain: the chain
  */
 struct nft_base_chain {
-	struct nf_hook_ops		ops;
+	struct nf_hook_ops		ops[NFT_HOOK_OPS_MAX];
 	enum nft_chain_type		type;
 	u8				policy;
 	struct nft_stats __percpu	*stats;
@@ -476,6 +478,8 @@ struct nft_table {
  *	@nhooks: number of hooks in this family
  *	@owner: module owner
  *	@tables: used internally
+ *	@nops: number of hook ops in this family
+ *	@hook_ops_init: initialization function for chain hook ops
  *	@hooks: hookfn overrides for packet validation
  */
 struct nft_af_info {
@@ -484,6 +488,9 @@ struct nft_af_info {
 	unsigned int			nhooks;
 	struct module			*owner;
 	struct list_head		tables;
+	unsigned int			nops;
+	void				(*hook_ops_init)(struct nf_hook_ops *,
+							 unsigned int);
 	nf_hookfn			*hooks[NF_MAX_HOOKS];
 };
 
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index c5fdd9a..003c1e9 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -32,6 +32,7 @@ static struct nft_af_info nft_af_bridge __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.nhooks		= NF_BR_NUMHOOKS,
 	.owner		= THIS_MODULE,
+	.nops		= 1,
 	.hooks		= {
 		[NF_BR_LOCAL_IN]	= nft_do_chain_bridge,
 		[NF_BR_FORWARD]		= nft_do_chain_bridge,
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 31bb778..36d27fc 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -32,6 +32,7 @@ static struct nft_af_info nft_af_arp __read_mostly = {
 	.family		= NFPROTO_ARP,
 	.nhooks		= NF_ARP_NUMHOOKS,
 	.owner		= THIS_MODULE,
+	.nops		= 1,
 	.hooks		= {
 		[NF_ARP_IN]		= nft_do_chain_arp,
 		[NF_ARP_OUT]		= nft_do_chain_arp,
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index ed7e15a..177c3bc 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -52,6 +52,7 @@ static struct nft_af_info nft_af_ipv4 __read_mostly = {
 	.family		= NFPROTO_IPV4,
 	.nhooks		= NF_INET_NUMHOOKS,
 	.owner		= THIS_MODULE,
+	.nops		= 1,
 	.hooks		= {
 		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv4,
 		[NF_INET_LOCAL_OUT]	= nft_ipv4_output,
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 54a2bcd..642280e 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -51,6 +51,7 @@ static struct nft_af_info nft_af_ipv6 __read_mostly = {
 	.family		= NFPROTO_IPV6,
 	.nhooks		= NF_INET_NUMHOOKS,
 	.owner		= THIS_MODULE,
+	.nops		= 1,
 	.hooks		= {
 		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv6,
 		[NF_INET_LOCAL_OUT]	= nft_ipv6_output,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index d568626..572d88d 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -307,7 +307,8 @@ err:
 	return err;
 }
 
-static int nf_tables_table_enable(struct nft_table *table)
+static int nf_tables_table_enable(const struct nft_af_info *afi,
+				  struct nft_table *table)
 {
 	struct nft_chain *chain;
 	int err, i = 0;
@@ -316,7 +317,7 @@ static int nf_tables_table_enable(struct nft_table *table)
 		if (!(chain->flags & NFT_BASE_CHAIN))
 			continue;
 
-		err = nf_register_hook(&nft_base_chain(chain)->ops);
+		err = nf_register_hooks(nft_base_chain(chain)->ops, afi->nops);
 		if (err < 0)
 			goto err;
 
@@ -331,18 +332,20 @@ err:
 		if (i-- <= 0)
 			break;
 
-		nf_unregister_hook(&nft_base_chain(chain)->ops);
+		nf_unregister_hooks(nft_base_chain(chain)->ops, afi->nops);
 	}
 	return err;
 }
 
-static int nf_tables_table_disable(struct nft_table *table)
+static int nf_tables_table_disable(const struct nft_af_info *afi,
+				   struct nft_table *table)
 {
 	struct nft_chain *chain;
 
 	list_for_each_entry(chain, &table->chains, list) {
 		if (chain->flags & NFT_BASE_CHAIN)
-			nf_unregister_hook(&nft_base_chain(chain)->ops);
+			nf_unregister_hooks(nft_base_chain(chain)->ops,
+					    afi->nops);
 	}
 
 	return 0;
@@ -365,12 +368,12 @@ static int nf_tables_updtable(struct sock *nlsk, struct sk_buff *skb,
 
 		if ((flags & NFT_TABLE_F_DORMANT) &&
 		    !(table->flags & NFT_TABLE_F_DORMANT)) {
-			ret = nf_tables_table_disable(table);
+			ret = nf_tables_table_disable(afi, table);
 			if (ret >= 0)
 				table->flags |= NFT_TABLE_F_DORMANT;
 		} else if (!(flags & NFT_TABLE_F_DORMANT) &&
 			   table->flags & NFT_TABLE_F_DORMANT) {
-			ret = nf_tables_table_enable(table);
+			ret = nf_tables_table_enable(afi, table);
 			if (ret >= 0)
 				table->flags &= ~NFT_TABLE_F_DORMANT;
 		}
@@ -598,7 +601,7 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, u32 portid, u32 seq,
 
 	if (chain->flags & NFT_BASE_CHAIN) {
 		const struct nft_base_chain *basechain = nft_base_chain(chain);
-		const struct nf_hook_ops *ops = &basechain->ops;
+		const struct nf_hook_ops *ops = &basechain->ops[0];
 		struct nlattr *nest;
 
 		nest = nla_nest_start(skb, NFTA_CHAIN_HOOK);
@@ -832,6 +835,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	u64 handle = 0;
+	unsigned int i;
 	int err;
 	bool create;
 
@@ -904,7 +908,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	if (nla[NFTA_CHAIN_HOOK]) {
 		struct nf_hook_ops *ops;
 		nf_hookfn *hookfn;
-		u32 hooknum;
+		u32 hooknum, priority;
 		int type = NFT_CHAIN_T_DEFAULT;
 
 		if (nla[NFTA_CHAIN_TYPE]) {
@@ -926,6 +930,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		hooknum = ntohl(nla_get_be32(ha[NFTA_HOOK_HOOKNUM]));
 		if (hooknum >= afi->nhooks)
 			return -EINVAL;
+		priority = ntohl(nla_get_be32(ha[NFTA_HOOK_PRIORITY]));
 
 		if (!(chain_type[family][type]->hook_mask & (1 << hooknum)))
 			return -EOPNOTSUPP;
@@ -938,15 +943,19 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		basechain->type = type;
 		chain = &basechain->chain;
 
-		ops = &basechain->ops;
-		ops->pf		= family;
-		ops->owner	= afi->owner;
-		ops->hooknum	= ntohl(nla_get_be32(ha[NFTA_HOOK_HOOKNUM]));
-		ops->priority	= ntohl(nla_get_be32(ha[NFTA_HOOK_PRIORITY]));
-		ops->priv	= chain;
-		ops->hook	= afi->hooks[ops->hooknum];
-		if (hookfn)
-			ops->hook = hookfn;
+		for (i = 0; i < afi->nops; i++) {
+			ops = &basechain->ops[i];
+			ops->pf		= family;
+			ops->owner	= afi->owner;
+			ops->hooknum	= hooknum;
+			ops->priority	= priority;
+			ops->priv	= chain;
+			ops->hook	= afi->hooks[ops->hooknum];
+			if (hookfn)
+				ops->hook = hookfn;
+			if (afi->hook_ops_init)
+				afi->hook_ops_init(ops, i);
+		}
 
 		chain->flags |= NFT_BASE_CHAIN;
 
@@ -993,7 +1002,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
 	    chain->flags & NFT_BASE_CHAIN) {
-		err = nf_register_hook(&nft_base_chain(chain)->ops);
+		err = nf_register_hooks(nft_base_chain(chain)->ops, afi->nops);
 		if (err < 0) {
 			free_percpu(basechain->stats);
 			kfree(basechain);
@@ -1052,7 +1061,7 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 
 	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
 	    chain->flags & NFT_BASE_CHAIN)
-		nf_unregister_hook(&nft_base_chain(chain)->ops);
+		nf_unregister_hooks(nft_base_chain(chain)->ops, afi->nops);
 
 	nf_tables_chain_notify(skb, nlh, table, chain, NFT_MSG_DELCHAIN,
 			       family);
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index da0c1f4..82cb823 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -92,7 +92,7 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 	if (ctx->chain->flags & NFT_BASE_CHAIN) {
 		const struct nft_base_chain *basechain =
 						nft_base_chain(ctx->chain);
-		const struct nf_hook_ops *ops = &basechain->ops;
+		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		par->hook_mask = 1 << ops->hooknum;
 	}
@@ -253,7 +253,7 @@ static int nft_target_validate(const struct nft_ctx *ctx,
 	if (ctx->chain->flags & NFT_BASE_CHAIN) {
 		const struct nft_base_chain *basechain =
 						nft_base_chain(ctx->chain);
-		const struct nf_hook_ops *ops = &basechain->ops;
+		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		hook_mask = 1 << ops->hooknum;
 		if (hook_mask & target->hooks)
@@ -323,7 +323,7 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 	if (ctx->chain->flags & NFT_BASE_CHAIN) {
 		const struct nft_base_chain *basechain =
 						nft_base_chain(ctx->chain);
-		const struct nf_hook_ops *ops = &basechain->ops;
+		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		par->hook_mask = 1 << ops->hooknum;
 	}
@@ -449,7 +449,7 @@ static int nft_match_validate(const struct nft_ctx *ctx,
 	if (ctx->chain->flags & NFT_BASE_CHAIN) {
 		const struct nft_base_chain *basechain =
 						nft_base_chain(ctx->chain);
-		const struct nf_hook_ops *ops = &basechain->ops;
+		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		hook_mask = 1 << ops->hooknum;
 		if (hook_mask & match->hooks)
-- 
1.7.10.4
