From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/18] netfilter: nf_tables: fix racy rule deletion
Date: Fri,  7 Feb 2014 18:41:40 +0100
Message-ID: <1391794904-4017-15-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41444 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbaBGRmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:42:11 -0500
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We may lost race if we flush the rule-set (which happens asynchronously
via call_rcu) and we try to remove the table (that userspace assumes
to be empty).

Fix this by recovering synchronous rule and chain deletion. This was
introduced time ago before we had no batch support, and synchronous
rule deletion performance was not good. Now that we have the batch
support, we can just postpone the purge of old rule in a second step
in the commit phase. All object deletions are synchronous after this
patch.

As a side effect, we save memory as we don't need rcu_head per rule
anymore.

Cc: Patrick McHardy <kaber@trash.net>
Reported-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    4 ----
 net/netfilter/nf_tables_api.c     |   40 +++++++++++++++++++++----------------
 2 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 0f68e47..e7e14ff 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -322,7 +322,6 @@ static inline void *nft_expr_priv(const struct nft_expr *expr)
  *	struct nft_rule - nf_tables rule
  *
  *	@list: used internally
- *	@rcu_head: used internally for rcu
  *	@handle: rule handle
  *	@genmask: generation mask
  *	@dlen: length of expression data
@@ -330,7 +329,6 @@ static inline void *nft_expr_priv(const struct nft_expr *expr)
  */
 struct nft_rule {
 	struct list_head		list;
-	struct rcu_head			rcu_head;
 	u64				handle:46,
 					genmask:2,
 					dlen:16;
@@ -391,7 +389,6 @@ enum nft_chain_flags {
  *
  *	@rules: list of rules in the chain
  *	@list: used internally
- *	@rcu_head: used internally
  *	@net: net namespace that this chain belongs to
  *	@table: table that this chain belongs to
  *	@handle: chain handle
@@ -403,7 +400,6 @@ enum nft_chain_flags {
 struct nft_chain {
 	struct list_head		rules;
 	struct list_head		list;
-	struct rcu_head			rcu_head;
 	struct net			*net;
 	struct nft_table		*table;
 	u64				handle;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 113c469..3a2e480 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1008,10 +1008,8 @@ notify:
 	return 0;
 }
 
-static void nf_tables_rcu_chain_destroy(struct rcu_head *head)
+static void nf_tables_chain_destroy(struct nft_chain *chain)
 {
-	struct nft_chain *chain = container_of(head, struct nft_chain, rcu_head);
-
 	BUG_ON(chain->use > 0);
 
 	if (chain->flags & NFT_BASE_CHAIN) {
@@ -1059,7 +1057,9 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 			       family);
 
 	/* Make sure all rule references are gone before this is released */
-	call_rcu(&chain->rcu_head, nf_tables_rcu_chain_destroy);
+	synchronize_rcu();
+
+	nf_tables_chain_destroy(chain);
 	return 0;
 }
 
@@ -1531,9 +1531,8 @@ err:
 	return err;
 }
 
-static void nf_tables_rcu_rule_destroy(struct rcu_head *head)
+static void nf_tables_rule_destroy(struct nft_rule *rule)
 {
-	struct nft_rule *rule = container_of(head, struct nft_rule, rcu_head);
 	struct nft_expr *expr;
 
 	/*
@@ -1548,11 +1547,6 @@ static void nf_tables_rcu_rule_destroy(struct rcu_head *head)
 	kfree(rule);
 }
 
-static void nf_tables_rule_destroy(struct nft_rule *rule)
-{
-	call_rcu(&rule->rcu_head, nf_tables_rcu_rule_destroy);
-}
-
 #define NFT_RULE_MAXEXPRS	128
 
 static struct nft_expr_info *info;
@@ -1819,9 +1813,6 @@ static int nf_tables_commit(struct sk_buff *skb)
 	synchronize_rcu();
 
 	list_for_each_entry_safe(rupd, tmp, &net->nft.commit_list, list) {
-		/* Delete this rule from the dirty list */
-		list_del(&rupd->list);
-
 		/* This rule was inactive in the past and just became active.
 		 * Clear the next bit of the genmask since its meaning has
 		 * changed, now it is the future.
@@ -1832,6 +1823,7 @@ static int nf_tables_commit(struct sk_buff *skb)
 					      rupd->chain, rupd->rule,
 					      NFT_MSG_NEWRULE, 0,
 					      rupd->family);
+			list_del(&rupd->list);
 			kfree(rupd);
 			continue;
 		}
@@ -1841,7 +1833,15 @@ static int nf_tables_commit(struct sk_buff *skb)
 		nf_tables_rule_notify(skb, rupd->nlh, rupd->table, rupd->chain,
 				      rupd->rule, NFT_MSG_DELRULE, 0,
 				      rupd->family);
+	}
+
+	/* Make sure we don't see any packet traversing old rules */
+	synchronize_rcu();
+
+	/* Now we can safely release unused old rules */
+	list_for_each_entry_safe(rupd, tmp, &net->nft.commit_list, list) {
 		nf_tables_rule_destroy(rupd->rule);
+		list_del(&rupd->list);
 		kfree(rupd);
 	}
 
@@ -1854,20 +1854,26 @@ static int nf_tables_abort(struct sk_buff *skb)
 	struct nft_rule_trans *rupd, *tmp;
 
 	list_for_each_entry_safe(rupd, tmp, &net->nft.commit_list, list) {
-		/* Delete all rules from the dirty list */
-		list_del(&rupd->list);
-
 		if (!nft_rule_is_active_next(net, rupd->rule)) {
 			nft_rule_clear(net, rupd->rule);
+			list_del(&rupd->list);
 			kfree(rupd);
 			continue;
 		}
 
 		/* This rule is inactive, get rid of it */
 		list_del_rcu(&rupd->rule->list);
+	}
+
+	/* Make sure we don't see any packet accessing aborted rules */
+	synchronize_rcu();
+
+	list_for_each_entry_safe(rupd, tmp, &net->nft.commit_list, list) {
 		nf_tables_rule_destroy(rupd->rule);
+		list_del(&rupd->list);
 		kfree(rupd);
 	}
+
 	return 0;
 }
 
-- 
1.7.10.4
