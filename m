From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/25] netfilter: nf_tables: relocate commit and abort routines in the source file
Date: Wed, 21 May 2014 11:43:11 +0200
Message-ID: <1400665402-5835-14-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the commit and abort routines to the bottom of the source code
file. This change is required by the follow up patches that add the
set, chain and table transaction support.

This patch is just a cleanup to access several functions without
having to declare their prototypes.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |  160 ++++++++++++++++++++---------------------
 1 file changed, 80 insertions(+), 80 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 424a6f3..17df4b8 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1827,86 +1827,6 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 	return err;
 }
 
-static int nf_tables_commit(struct sk_buff *skb)
-{
-	struct net *net = sock_net(skb->sk);
-	struct nft_trans *trans, *next;
-
-	/* Bump generation counter, invalidate any dump in progress */
-	net->nft.genctr++;
-
-	/* A new generation has just started */
-	net->nft.gencursor = gencursor_next(net);
-
-	/* Make sure all packets have left the previous generation before
-	 * purging old rules.
-	 */
-	synchronize_rcu();
-
-	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
-		/* This rule was inactive in the past and just became active.
-		 * Clear the next bit of the genmask since its meaning has
-		 * changed, now it is the future.
-		 */
-		if (nft_rule_is_active(net, nft_trans_rule(trans))) {
-			nft_rule_clear(net, nft_trans_rule(trans));
-			nf_tables_rule_notify(skb, trans->ctx.nlh,
-					      trans->ctx.table,
-					      trans->ctx.chain,
-					      nft_trans_rule(trans),
-					      NFT_MSG_NEWRULE, 0,
-					      trans->ctx.afi->family);
-			nft_trans_destroy(trans);
-			continue;
-		}
-
-		/* This rule is in the past, get rid of it */
-		list_del_rcu(&nft_trans_rule(trans)->list);
-		nf_tables_rule_notify(skb, trans->ctx.nlh,
-				      trans->ctx.table, trans->ctx.chain,
-				      nft_trans_rule(trans), NFT_MSG_DELRULE,
-				      0, trans->ctx.afi->family);
-	}
-
-	/* Make sure we don't see any packet traversing old rules */
-	synchronize_rcu();
-
-	/* Now we can safely release unused old rules */
-	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
-		nf_tables_rule_destroy(&trans->ctx, nft_trans_rule(trans));
-		nft_trans_destroy(trans);
-	}
-
-	return 0;
-}
-
-static int nf_tables_abort(struct sk_buff *skb)
-{
-	struct net *net = sock_net(skb->sk);
-	struct nft_trans *trans, *next;
-
-	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
-		if (!nft_rule_is_active_next(net, nft_trans_rule(trans))) {
-			nft_rule_clear(net, nft_trans_rule(trans));
-			nft_trans_destroy(trans);
-			continue;
-		}
-
-		/* This rule is inactive, get rid of it */
-		list_del_rcu(&nft_trans_rule(trans)->list);
-	}
-
-	/* Make sure we don't see any packet accessing aborted rules */
-	synchronize_rcu();
-
-	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
-		nf_tables_rule_destroy(&trans->ctx, nft_trans_rule(trans));
-		nft_trans_destroy(trans);
-	}
-
-	return 0;
-}
-
 /*
  * Sets
  */
@@ -3177,6 +3097,86 @@ static const struct nfnl_callback nf_tables_cb[NFT_MSG_MAX] = {
 	},
 };
 
+static int nf_tables_commit(struct sk_buff *skb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nft_trans *trans, *next;
+
+	/* Bump generation counter, invalidate any dump in progress */
+	net->nft.genctr++;
+
+	/* A new generation has just started */
+	net->nft.gencursor = gencursor_next(net);
+
+	/* Make sure all packets have left the previous generation before
+	 * purging old rules.
+	 */
+	synchronize_rcu();
+
+	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
+		/* This rule was inactive in the past and just became active.
+		 * Clear the next bit of the genmask since its meaning has
+		 * changed, now it is the future.
+		 */
+		if (nft_rule_is_active(net, nft_trans_rule(trans))) {
+			nft_rule_clear(net, nft_trans_rule(trans));
+			nf_tables_rule_notify(skb, trans->ctx.nlh,
+					      trans->ctx.table,
+					      trans->ctx.chain,
+					      nft_trans_rule(trans),
+					      NFT_MSG_NEWRULE, 0,
+					      trans->ctx.afi->family);
+			nft_trans_destroy(trans);
+			continue;
+		}
+
+		/* This rule is in the past, get rid of it */
+		list_del_rcu(&nft_trans_rule(trans)->list);
+		nf_tables_rule_notify(skb, trans->ctx.nlh,
+				      trans->ctx.table, trans->ctx.chain,
+				      nft_trans_rule(trans), NFT_MSG_DELRULE,
+				      0, trans->ctx.afi->family);
+	}
+
+	/* Make sure we don't see any packet traversing old rules */
+	synchronize_rcu();
+
+	/* Now we can safely release unused old rules */
+	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
+		nf_tables_rule_destroy(&trans->ctx, nft_trans_rule(trans));
+		nft_trans_destroy(trans);
+	}
+
+	return 0;
+}
+
+static int nf_tables_abort(struct sk_buff *skb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nft_trans *trans, *next;
+
+	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
+		if (!nft_rule_is_active_next(net, nft_trans_rule(trans))) {
+			nft_rule_clear(net, nft_trans_rule(trans));
+			nft_trans_destroy(trans);
+			continue;
+		}
+
+		/* This rule is inactive, get rid of it */
+		list_del_rcu(&nft_trans_rule(trans)->list);
+	}
+
+	/* Make sure we don't see any packet accessing aborted rules */
+	synchronize_rcu();
+
+	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
+		nf_tables_rule_destroy(&trans->ctx, nft_trans_rule(trans));
+		nft_trans_destroy(trans);
+	}
+
+	return 0;
+}
+
 static const struct nfnetlink_subsystem nf_tables_subsys = {
 	.name		= "nf_tables",
 	.subsys_id	= NFNL_SUBSYS_NFTABLES,
-- 
1.7.10.4

