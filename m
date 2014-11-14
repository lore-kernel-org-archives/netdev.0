From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/8] netfilter: nf_tables: restore synchronous object release from commit/abort
Date: Fri, 14 Nov 2014 17:58:48 +0100
Message-ID: <1415984329-5569-9-git-send-email-pablo@netfilter.org>
References: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40391 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161390AbaKNQ5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 11:57:21 -0500
In-Reply-To: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing xtables matches and targets, when used from nft_compat, may
sleep from the destroy path, ie. when removing rules. Since the objects
are released via call_rcu from softirq context, this results in lockdep
splats and possible lockups that may be hard to reproduce.

Patrick also indicated that delayed object release via call_rcu can
cause us problems in the ordering of event notifications when anonymous
sets are in place.

So, this patch restores the synchronous object release from the commit
and abort paths. This includes a call to synchronize_rcu() to make sure
that no packets are walking on the objects that are going to be
released. This is slowier though, but it's simple and it resolves the
aforementioned problems.

This is a partial revert of c7c32e7 ("netfilter: nf_tables: defer all
object release via rcu") that was introduced in 3.16 to speed up
interaction with userspace.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    2 --
 net/netfilter/nf_tables_api.c     |   24 ++++++++----------------
 2 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 845c596..3ae969e 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -396,14 +396,12 @@ struct nft_rule {
 /**
  *	struct nft_trans - nf_tables object update in transaction
  *
- *	@rcu_head: rcu head to defer release of transaction data
  *	@list: used internally
  *	@msg_type: message type
  *	@ctx: transaction context
  *	@data: internal information related to the transaction
  */
 struct nft_trans {
-	struct rcu_head			rcu_head;
 	struct list_head		list;
 	int				msg_type;
 	struct nft_ctx			ctx;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 11ab4b0..66e8425 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3484,13 +3484,8 @@ static void nft_chain_commit_update(struct nft_trans *trans)
 	}
 }
 
-/* Schedule objects for release via rcu to make sure no packets are accesing
- * removed rules.
- */
-static void nf_tables_commit_release_rcu(struct rcu_head *rt)
+static void nf_tables_commit_release(struct nft_trans *trans)
 {
-	struct nft_trans *trans = container_of(rt, struct nft_trans, rcu_head);
-
 	switch (trans->msg_type) {
 	case NFT_MSG_DELTABLE:
 		nf_tables_table_destroy(&trans->ctx);
@@ -3612,10 +3607,11 @@ static int nf_tables_commit(struct sk_buff *skb)
 		}
 	}
 
+	synchronize_rcu();
+
 	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
 		list_del(&trans->list);
-		trans->ctx.nla = NULL;
-		call_rcu(&trans->rcu_head, nf_tables_commit_release_rcu);
+		nf_tables_commit_release(trans);
 	}
 
 	nf_tables_gen_notify(net, skb, NFT_MSG_NEWGEN);
@@ -3623,13 +3619,8 @@ static int nf_tables_commit(struct sk_buff *skb)
 	return 0;
 }
 
-/* Schedule objects for release via rcu to make sure no packets are accesing
- * aborted rules.
- */
-static void nf_tables_abort_release_rcu(struct rcu_head *rt)
+static void nf_tables_abort_release(struct nft_trans *trans)
 {
-	struct nft_trans *trans = container_of(rt, struct nft_trans, rcu_head);
-
 	switch (trans->msg_type) {
 	case NFT_MSG_NEWTABLE:
 		nf_tables_table_destroy(&trans->ctx);
@@ -3725,11 +3716,12 @@ static int nf_tables_abort(struct sk_buff *skb)
 		}
 	}
 
+	synchronize_rcu();
+
 	list_for_each_entry_safe_reverse(trans, next,
 					 &net->nft.commit_list, list) {
 		list_del(&trans->list);
-		trans->ctx.nla = NULL;
-		call_rcu(&trans->rcu_head, nf_tables_abort_release_rcu);
+		nf_tables_abort_release(trans);
 	}
 
 	return 0;
-- 
1.7.10.4
