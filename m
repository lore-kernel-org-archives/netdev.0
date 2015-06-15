From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 31/32] netfilter: nf_tables: add nft_register_basechain() and nft_unregister_basechain()
Date: Mon, 15 Jun 2015 23:26:28 +0200
Message-ID: <1434403589-24796-32-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This wrapper functions take care of hook registration for basechains.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   52 +++++++++++++++++++++++++++++------------
 1 file changed, 37 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 900c81a..c66dc62 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -127,13 +127,38 @@ static void nft_trans_destroy(struct nft_trans *trans)
 	kfree(trans);
 }
 
+static int nft_register_basechain(struct nft_base_chain *basechain,
+				  unsigned int hook_nops)
+{
+	return nf_register_hooks(basechain->ops, hook_nops);
+}
+
+static void nft_unregister_basechain(struct nft_base_chain *basechain,
+				     unsigned int hook_nops)
+{
+	nf_unregister_hooks(basechain->ops, hook_nops);
+}
+
+static int nf_tables_register_hooks(const struct nft_table *table,
+				    struct nft_chain *chain,
+				    unsigned int hook_nops)
+{
+	if (table->flags & NFT_TABLE_F_DORMANT ||
+	    !(chain->flags & NFT_BASE_CHAIN))
+		return 0;
+
+	return nft_register_basechain(nft_base_chain(chain), hook_nops);
+}
+
 static void nf_tables_unregister_hooks(const struct nft_table *table,
-				       const struct nft_chain *chain,
+				       struct nft_chain *chain,
 				       unsigned int hook_nops)
 {
-	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
-	    chain->flags & NFT_BASE_CHAIN)
-		nf_unregister_hooks(nft_base_chain(chain)->ops, hook_nops);
+	if (table->flags & NFT_TABLE_F_DORMANT ||
+	    !(chain->flags & NFT_BASE_CHAIN))
+		return;
+
+	nft_unregister_basechain(nft_base_chain(chain), hook_nops);
 }
 
 /* Internal table flags */
@@ -560,7 +585,7 @@ static int nf_tables_table_enable(const struct nft_af_info *afi,
 		if (!(chain->flags & NFT_BASE_CHAIN))
 			continue;
 
-		err = nf_register_hooks(nft_base_chain(chain)->ops, afi->nops);
+		err = nft_register_basechain(nft_base_chain(chain), afi->nops);
 		if (err < 0)
 			goto err;
 
@@ -575,20 +600,20 @@ err:
 		if (i-- <= 0)
 			break;
 
-		nf_unregister_hooks(nft_base_chain(chain)->ops, afi->nops);
+		nft_unregister_basechain(nft_base_chain(chain), afi->nops);
 	}
 	return err;
 }
 
 static void nf_tables_table_disable(const struct nft_af_info *afi,
-				   struct nft_table *table)
+				    struct nft_table *table)
 {
 	struct nft_chain *chain;
 
 	list_for_each_entry(chain, &table->chains, list) {
 		if (chain->flags & NFT_BASE_CHAIN)
-			nf_unregister_hooks(nft_base_chain(chain)->ops,
-					    afi->nops);
+			nft_unregister_basechain(nft_base_chain(chain),
+						 afi->nops);
 	}
 }
 
@@ -1421,12 +1446,9 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	chain->table = table;
 	nla_strlcpy(chain->name, name, NFT_CHAIN_MAXNAMELEN);
 
-	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
-	    chain->flags & NFT_BASE_CHAIN) {
-		err = nf_register_hooks(nft_base_chain(chain)->ops, afi->nops);
-		if (err < 0)
-			goto err1;
-	}
+	err = nf_tables_register_hooks(table, chain, afi->nops);
+	if (err < 0)
+		goto err1;
 
 	nft_ctx_init(&ctx, skb, nlh, afi, table, chain, nla);
 	err = nft_trans_chain_add(&ctx, NFT_MSG_NEWCHAIN);
-- 
1.7.10.4

