From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/25] netfilter: nf_tables: add message type to transactions
Date: Wed, 21 May 2014 11:43:12 +0200
Message-ID: <1400665402-5835-15-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55999 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752200AbaEUJnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 05:43:46 -0400
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds message type to the transaction to simplify the
commit the and abort routines. Yet another step forward in the
generalisation of the transaction infrastructure.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    2 +
 net/netfilter/nf_tables_api.c     |   74 +++++++++++++++++++++----------------
 2 files changed, 45 insertions(+), 31 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 246dbd4..d8dfb26 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -390,11 +390,13 @@ struct nft_rule {
  *	struct nft_trans - nf_tables object update in transaction
  *
  *	@list: used internally
+ *	@msg_type: message type
  *	@ctx: transaction context
  *	@data: internal information related to the transaction
  */
 struct nft_trans {
 	struct list_head		list;
+	int				msg_type;
 	struct nft_ctx			ctx;
 	char				data[0];
 };
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 17df4b8..34aa3d5 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -105,7 +105,8 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 	ctx->nla   = nla;
 }
 
-static struct nft_trans *nft_trans_alloc(struct nft_ctx *ctx, u32 size)
+static struct nft_trans *nft_trans_alloc(struct nft_ctx *ctx, int msg_type,
+					 u32 size)
 {
 	struct nft_trans *trans;
 
@@ -113,6 +114,7 @@ static struct nft_trans *nft_trans_alloc(struct nft_ctx *ctx, u32 size)
 	if (trans == NULL)
 		return NULL;
 
+	trans->msg_type = msg_type;
 	trans->ctx	= *ctx;
 
 	return trans;
@@ -1576,12 +1578,12 @@ static void nf_tables_rule_destroy(const struct nft_ctx *ctx,
 	kfree(rule);
 }
 
-static struct nft_trans *nft_trans_rule_add(struct nft_ctx *ctx,
+static struct nft_trans *nft_trans_rule_add(struct nft_ctx *ctx, int msg_type,
 					    struct nft_rule *rule)
 {
 	struct nft_trans *trans;
 
-	trans = nft_trans_alloc(ctx, sizeof(struct nft_trans_rule));
+	trans = nft_trans_alloc(ctx, msg_type, sizeof(struct nft_trans_rule));
 	if (trans == NULL)
 		return NULL;
 
@@ -1703,7 +1705,8 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 
 	if (nlh->nlmsg_flags & NLM_F_REPLACE) {
 		if (nft_rule_is_active_next(net, old_rule)) {
-			trans = nft_trans_rule_add(&ctx, old_rule);
+			trans = nft_trans_rule_add(&ctx, NFT_MSG_NEWRULE,
+						   old_rule);
 			if (trans == NULL) {
 				err = -ENOMEM;
 				goto err2;
@@ -1726,7 +1729,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 			list_add_rcu(&rule->list, &chain->rules);
 	}
 
-	if (nft_trans_rule_add(&ctx, rule) == NULL) {
+	if (nft_trans_rule_add(&ctx, NFT_MSG_NEWRULE, rule) == NULL) {
 		err = -ENOMEM;
 		goto err3;
 	}
@@ -1754,7 +1757,7 @@ nf_tables_delrule_one(struct nft_ctx *ctx, struct nft_rule *rule)
 {
 	/* You cannot delete the same rule twice */
 	if (nft_rule_is_active_next(ctx->net, rule)) {
-		if (nft_trans_rule_add(ctx, rule) == NULL)
+		if (nft_trans_rule_add(ctx, NFT_MSG_DELRULE, rule) == NULL)
 			return -ENOMEM;
 		nft_rule_disactivate_next(ctx->net, rule);
 		return 0;
@@ -3114,28 +3117,26 @@ static int nf_tables_commit(struct sk_buff *skb)
 	synchronize_rcu();
 
 	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
-		/* This rule was inactive in the past and just became active.
-		 * Clear the next bit of the genmask since its meaning has
-		 * changed, now it is the future.
-		 */
-		if (nft_rule_is_active(net, nft_trans_rule(trans))) {
-			nft_rule_clear(net, nft_trans_rule(trans));
-			nf_tables_rule_notify(skb, trans->ctx.nlh,
+		switch (trans->msg_type) {
+		case NFT_MSG_NEWRULE:
+			nft_rule_clear(trans->ctx.net, nft_trans_rule(trans));
+			nf_tables_rule_notify(trans->ctx.skb, trans->ctx.nlh,
 					      trans->ctx.table,
 					      trans->ctx.chain,
 					      nft_trans_rule(trans),
 					      NFT_MSG_NEWRULE, 0,
 					      trans->ctx.afi->family);
 			nft_trans_destroy(trans);
-			continue;
+			break;
+		case NFT_MSG_DELRULE:
+			list_del_rcu(&nft_trans_rule(trans)->list);
+			nf_tables_rule_notify(trans->ctx.skb, trans->ctx.nlh,
+					      trans->ctx.table,
+					      trans->ctx.chain,
+					      nft_trans_rule(trans), NFT_MSG_DELRULE, 0,
+					      trans->ctx.afi->family);
+			break;
 		}
-
-		/* This rule is in the past, get rid of it */
-		list_del_rcu(&nft_trans_rule(trans)->list);
-		nf_tables_rule_notify(skb, trans->ctx.nlh,
-				      trans->ctx.table, trans->ctx.chain,
-				      nft_trans_rule(trans), NFT_MSG_DELRULE,
-				      0, trans->ctx.afi->family);
 	}
 
 	/* Make sure we don't see any packet traversing old rules */
@@ -3143,8 +3144,13 @@ static int nf_tables_commit(struct sk_buff *skb)
 
 	/* Now we can safely release unused old rules */
 	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
-		nf_tables_rule_destroy(&trans->ctx, nft_trans_rule(trans));
-		nft_trans_destroy(trans);
+		switch (trans->msg_type) {
+		case NFT_MSG_DELRULE:
+			nf_tables_rule_destroy(&trans->ctx,
+					       nft_trans_rule(trans));
+			nft_trans_destroy(trans);
+			break;
+		}
 	}
 
 	return 0;
@@ -3156,22 +3162,28 @@ static int nf_tables_abort(struct sk_buff *skb)
 	struct nft_trans *trans, *next;
 
 	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
-		if (!nft_rule_is_active_next(net, nft_trans_rule(trans))) {
-			nft_rule_clear(net, nft_trans_rule(trans));
+		switch (trans->msg_type) {
+		case NFT_MSG_NEWRULE:
+			list_del_rcu(&nft_trans_rule(trans)->list);
+			break;
+		case NFT_MSG_DELRULE:
+			nft_rule_clear(trans->ctx.net, nft_trans_rule(trans));
 			nft_trans_destroy(trans);
-			continue;
+			break;
 		}
-
-		/* This rule is inactive, get rid of it */
-		list_del_rcu(&nft_trans_rule(trans)->list);
 	}
 
 	/* Make sure we don't see any packet accessing aborted rules */
 	synchronize_rcu();
 
 	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
-		nf_tables_rule_destroy(&trans->ctx, nft_trans_rule(trans));
-		nft_trans_destroy(trans);
+		switch (trans->msg_type) {
+		case NFT_MSG_NEWRULE:
+			nf_tables_rule_destroy(&trans->ctx,
+					       nft_trans_rule(trans));
+			nft_trans_destroy(trans);
+			break;
+		}
 	}
 
 	return 0;
-- 
1.7.10.4
