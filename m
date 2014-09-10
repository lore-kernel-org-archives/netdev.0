From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/25] netfilter: nf_tables: add helper to unregister chain hooks
Date: Wed, 10 Sep 2014 17:10:31 +0200
Message-ID: <1410361842-4656-15-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55907 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbaIJPKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 11:10:24 -0400
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

This patch adds a helper function to unregister chain hooks in the chain
deletion path. Basically, a code factorization.

The new function is useful in follow-up patches.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 3664bab..90e3496 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -127,6 +127,15 @@ static void nft_trans_destroy(struct nft_trans *trans)
 	kfree(trans);
 }
 
+static void nf_tables_unregister_hooks(const struct nft_table *table,
+				       const struct nft_chain *chain,
+				       unsigned int hook_nops)
+{
+	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
+	    chain->flags & NFT_BASE_CHAIN)
+		nf_unregister_hooks(nft_base_chain(chain)->ops, hook_nops);
+}
+
 /*
  * Tables
  */
@@ -1157,11 +1166,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	list_add_tail_rcu(&chain->list, &table->chains);
 	return 0;
 err2:
-	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
-	    chain->flags & NFT_BASE_CHAIN) {
-		nf_unregister_hooks(nft_base_chain(chain)->ops,
-				    afi->nops);
-	}
+	nf_tables_unregister_hooks(table, chain, afi->nops);
 err1:
 	nf_tables_chain_destroy(chain);
 	return err;
@@ -3368,11 +3373,9 @@ static int nf_tables_commit(struct sk_buff *skb)
 			break;
 		case NFT_MSG_DELCHAIN:
 			nf_tables_chain_notify(&trans->ctx, NFT_MSG_DELCHAIN);
-			if (!(trans->ctx.table->flags & NFT_TABLE_F_DORMANT) &&
-			    trans->ctx.chain->flags & NFT_BASE_CHAIN) {
-				nf_unregister_hooks(nft_base_chain(trans->ctx.chain)->ops,
-						    trans->ctx.afi->nops);
-			}
+			nf_tables_unregister_hooks(trans->ctx.table,
+						   trans->ctx.chain,
+						   trans->ctx.afi->nops);
 			break;
 		case NFT_MSG_NEWRULE:
 			nft_rule_clear(trans->ctx.net, nft_trans_rule(trans));
@@ -3495,11 +3498,9 @@ static int nf_tables_abort(struct sk_buff *skb)
 			} else {
 				trans->ctx.table->use--;
 				list_del_rcu(&trans->ctx.chain->list);
-				if (!(trans->ctx.table->flags & NFT_TABLE_F_DORMANT) &&
-				    trans->ctx.chain->flags & NFT_BASE_CHAIN) {
-					nf_unregister_hooks(nft_base_chain(trans->ctx.chain)->ops,
-							    trans->ctx.afi->nops);
-				}
+				nf_tables_unregister_hooks(trans->ctx.table,
+							   trans->ctx.chain,
+							   trans->ctx.afi->nops);
 			}
 			break;
 		case NFT_MSG_DELCHAIN:
-- 
1.7.10.4
