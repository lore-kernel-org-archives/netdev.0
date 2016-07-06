From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/26] netfilter: nf_tables: get rid of NFT_BASECHAIN_DISABLED
Date: Wed,  6 Jul 2016 16:24:02 +0200
Message-ID: <1467815048-2240-21-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This flag was introduced to restore rulesets from the new netdev
family, but since 5ebe0b0eec9d6f7 ("netfilter: nf_tables: destroy
basechain and rules on netdevice removal") the ruleset is released
once the netdev is gone.

This also removes nft_register_basechain() and
nft_unregister_basechain() since they have no clients anymore after
this rework.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  1 -
 net/netfilter/nf_tables_api.c     | 62 ++++++++++++++++-----------------------
 2 files changed, 25 insertions(+), 38 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 07a5ba4..1ea19a6 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -798,7 +798,6 @@ struct nft_stats {
 };
 
 #define NFT_HOOK_OPS_MAX		2
-#define NFT_BASECHAIN_DISABLED		(1 << 0)
 
 /**
  *	struct nft_base_chain - nf_tables base chain
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 3316bce..92c9fae 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -131,29 +131,8 @@ static void nft_trans_destroy(struct nft_trans *trans)
 	kfree(trans);
 }
 
-static int nft_register_basechain(struct nft_base_chain *basechain,
-				  unsigned int hook_nops)
-{
-	struct net *net = read_pnet(&basechain->pnet);
-
-	if (basechain->flags & NFT_BASECHAIN_DISABLED)
-		return 0;
-
-	return nf_register_net_hooks(net, basechain->ops, hook_nops);
-}
-
-static void nft_unregister_basechain(struct nft_base_chain *basechain,
-				     unsigned int hook_nops)
-{
-	struct net *net = read_pnet(&basechain->pnet);
-
-	if (basechain->flags & NFT_BASECHAIN_DISABLED)
-		return;
-
-	nf_unregister_net_hooks(net, basechain->ops, hook_nops);
-}
-
-static int nf_tables_register_hooks(const struct nft_table *table,
+static int nf_tables_register_hooks(struct net *net,
+				    const struct nft_table *table,
 				    struct nft_chain *chain,
 				    unsigned int hook_nops)
 {
@@ -161,10 +140,12 @@ static int nf_tables_register_hooks(const struct nft_table *table,
 	    !(chain->flags & NFT_BASE_CHAIN))
 		return 0;
 
-	return nft_register_basechain(nft_base_chain(chain), hook_nops);
+	return nf_register_net_hooks(net, nft_base_chain(chain)->ops,
+				     hook_nops);
 }
 
-static void nf_tables_unregister_hooks(const struct nft_table *table,
+static void nf_tables_unregister_hooks(struct net *net,
+				       const struct nft_table *table,
 				       struct nft_chain *chain,
 				       unsigned int hook_nops)
 {
@@ -172,7 +153,7 @@ static void nf_tables_unregister_hooks(const struct nft_table *table,
 	    !(chain->flags & NFT_BASE_CHAIN))
 		return;
 
-	nft_unregister_basechain(nft_base_chain(chain), hook_nops);
+	nf_unregister_net_hooks(net, nft_base_chain(chain)->ops, hook_nops);
 }
 
 static int nft_trans_table_add(struct nft_ctx *ctx, int msg_type)
@@ -569,7 +550,8 @@ static int nf_tables_table_enable(struct net *net,
 		if (!(chain->flags & NFT_BASE_CHAIN))
 			continue;
 
-		err = nft_register_basechain(nft_base_chain(chain), afi->nops);
+		err = nf_register_net_hooks(net, nft_base_chain(chain)->ops,
+					    afi->nops);
 		if (err < 0)
 			goto err;
 
@@ -586,7 +568,8 @@ err:
 		if (i-- <= 0)
 			break;
 
-		nft_unregister_basechain(nft_base_chain(chain), afi->nops);
+		nf_unregister_net_hooks(net, nft_base_chain(chain)->ops,
+					afi->nops);
 	}
 	return err;
 }
@@ -600,9 +583,11 @@ static void nf_tables_table_disable(struct net *net,
 	list_for_each_entry(chain, &table->chains, list) {
 		if (!nft_is_active_next(net, chain))
 			continue;
-		if (chain->flags & NFT_BASE_CHAIN)
-			nft_unregister_basechain(nft_base_chain(chain),
-						 afi->nops);
+		if (!(chain->flags & NFT_BASE_CHAIN))
+			continue;
+
+		nf_unregister_net_hooks(net, nft_base_chain(chain)->ops,
+					afi->nops);
 	}
 }
 
@@ -1451,7 +1436,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 	chain->table = table;
 	nla_strlcpy(chain->name, name, NFT_CHAIN_MAXNAMELEN);
 
-	err = nf_tables_register_hooks(table, chain, afi->nops);
+	err = nf_tables_register_hooks(net, table, chain, afi->nops);
 	if (err < 0)
 		goto err1;
 
@@ -1464,7 +1449,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 	list_add_tail_rcu(&chain->list, &table->chains);
 	return 0;
 err2:
-	nf_tables_unregister_hooks(table, chain, afi->nops);
+	nf_tables_unregister_hooks(net, table, chain, afi->nops);
 err1:
 	nf_tables_chain_destroy(chain);
 	return err;
@@ -3995,7 +3980,8 @@ static int nf_tables_commit(struct net *net, struct sk_buff *skb)
 		case NFT_MSG_DELCHAIN:
 			list_del_rcu(&trans->ctx.chain->list);
 			nf_tables_chain_notify(&trans->ctx, NFT_MSG_DELCHAIN);
-			nf_tables_unregister_hooks(trans->ctx.table,
+			nf_tables_unregister_hooks(trans->ctx.net,
+						   trans->ctx.table,
 						   trans->ctx.chain,
 						   trans->ctx.afi->nops);
 			break;
@@ -4120,7 +4106,8 @@ static int nf_tables_abort(struct net *net, struct sk_buff *skb)
 			} else {
 				trans->ctx.table->use--;
 				list_del_rcu(&trans->ctx.chain->list);
-				nf_tables_unregister_hooks(trans->ctx.table,
+				nf_tables_unregister_hooks(trans->ctx.net,
+							   trans->ctx.table,
 							   trans->ctx.chain,
 							   trans->ctx.afi->nops);
 			}
@@ -4662,7 +4649,7 @@ int __nft_release_basechain(struct nft_ctx *ctx)
 
 	BUG_ON(!(ctx->chain->flags & NFT_BASE_CHAIN));
 
-	nf_tables_unregister_hooks(ctx->chain->table, ctx->chain,
+	nf_tables_unregister_hooks(ctx->net, ctx->chain->table, ctx->chain,
 				   ctx->afi->nops);
 	list_for_each_entry_safe(rule, nr, &ctx->chain->rules, list) {
 		list_del(&rule->list);
@@ -4691,7 +4678,8 @@ static void __nft_release_afinfo(struct net *net, struct nft_af_info *afi)
 
 	list_for_each_entry_safe(table, nt, &afi->tables, list) {
 		list_for_each_entry(chain, &table->chains, list)
-			nf_tables_unregister_hooks(table, chain, afi->nops);
+			nf_tables_unregister_hooks(net, table, chain,
+						   afi->nops);
 		/* No packets are walking on these chains anymore. */
 		ctx.table = table;
 		list_for_each_entry(chain, &table->chains, list) {
-- 
2.1.4

