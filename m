From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/9] netfilter: nf_tables: simplify set dump through netlink
Date: Thu, 31 Jul 2014 21:27:01 +0200
Message-ID: <1406834828-8500-3-git-send-email-pablo@netfilter.org>
References: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35650 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbaGaT1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 15:27:10 -0400
In-Reply-To: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses the cb->data pointer that allows us to store the
context when dumping the set list. Thus, we don't need to parse the
original netlink message containing the dump request for each recvmsg()
call when dumping the set list. The different function flavours
depending on the dump criteria has been also merged into one single
generic function. This saves us ~100 lines of code.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |  131 +++++++++--------------------------------
 1 file changed, 27 insertions(+), 104 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 8746ff9..ecffb26 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2247,80 +2247,7 @@ err:
 	return err;
 }
 
-static int nf_tables_dump_sets_table(struct nft_ctx *ctx, struct sk_buff *skb,
-				     struct netlink_callback *cb)
-{
-	const struct nft_set *set;
-	unsigned int idx = 0, s_idx = cb->args[0];
-
-	if (cb->args[1])
-		return skb->len;
-
-	rcu_read_lock();
-	cb->seq = ctx->net->nft.base_seq;
-
-	list_for_each_entry_rcu(set, &ctx->table->sets, list) {
-		if (idx < s_idx)
-			goto cont;
-		if (nf_tables_fill_set(skb, ctx, set, NFT_MSG_NEWSET,
-				       NLM_F_MULTI) < 0) {
-			cb->args[0] = idx;
-			goto done;
-		}
-		nl_dump_check_consistent(cb, nlmsg_hdr(skb));
-cont:
-		idx++;
-	}
-	cb->args[1] = 1;
-done:
-	rcu_read_unlock();
-	return skb->len;
-}
-
-static int nf_tables_dump_sets_family(struct nft_ctx *ctx, struct sk_buff *skb,
-				      struct netlink_callback *cb)
-{
-	const struct nft_set *set;
-	unsigned int idx, s_idx = cb->args[0];
-	struct nft_table *table, *cur_table = (struct nft_table *)cb->args[2];
-
-	if (cb->args[1])
-		return skb->len;
-
-	rcu_read_lock();
-	cb->seq = ctx->net->nft.base_seq;
-
-	list_for_each_entry_rcu(table, &ctx->afi->tables, list) {
-		if (cur_table) {
-			if (cur_table != table)
-				continue;
-
-			cur_table = NULL;
-		}
-		ctx->table = table;
-		idx = 0;
-		list_for_each_entry_rcu(set, &ctx->table->sets, list) {
-			if (idx < s_idx)
-				goto cont;
-			if (nf_tables_fill_set(skb, ctx, set, NFT_MSG_NEWSET,
-					       NLM_F_MULTI) < 0) {
-				cb->args[0] = idx;
-				cb->args[2] = (unsigned long) table;
-				goto done;
-			}
-			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
-cont:
-			idx++;
-		}
-	}
-	cb->args[1] = 1;
-done:
-	rcu_read_unlock();
-	return skb->len;
-}
-
-static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff *skb,
-				   struct netlink_callback *cb)
+static int nf_tables_dump_sets(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	const struct nft_set *set;
 	unsigned int idx, s_idx = cb->args[0];
@@ -2328,6 +2255,7 @@ static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff *skb,
 	struct nft_table *table, *cur_table = (struct nft_table *)cb->args[2];
 	struct net *net = sock_net(skb->sk);
 	int cur_family = cb->args[3];
+	struct nft_ctx *ctx = cb->data, ctx_set;
 
 	if (cb->args[1])
 		return skb->len;
@@ -2336,28 +2264,34 @@ static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff *skb,
 	cb->seq = net->nft.base_seq;
 
 	list_for_each_entry_rcu(afi, &net->nft.af_info, list) {
+		if (ctx->afi && ctx->afi != afi)
+			continue;
+
 		if (cur_family) {
 			if (afi->family != cur_family)
 				continue;
 
 			cur_family = 0;
 		}
-
 		list_for_each_entry_rcu(table, &afi->tables, list) {
+			if (ctx->table && ctx->table != table)
+				continue;
+
 			if (cur_table) {
 				if (cur_table != table)
 					continue;
 
 				cur_table = NULL;
 			}
-
-			ctx->table = table;
-			ctx->afi = afi;
 			idx = 0;
-			list_for_each_entry_rcu(set, &ctx->table->sets, list) {
+			list_for_each_entry_rcu(set, &table->sets, list) {
 				if (idx < s_idx)
 					goto cont;
-				if (nf_tables_fill_set(skb, ctx, set,
+
+				ctx_set = *ctx;
+				ctx_set.table = table;
+				ctx_set.afi = afi;
+				if (nf_tables_fill_set(skb, &ctx_set, set,
 						       NFT_MSG_NEWSET,
 						       NLM_F_MULTI) < 0) {
 					cb->args[0] = idx;
@@ -2379,31 +2313,10 @@ done:
 	return skb->len;
 }
 
-static int nf_tables_dump_sets(struct sk_buff *skb, struct netlink_callback *cb)
+static int nf_tables_dump_sets_done(struct netlink_callback *cb)
 {
-	const struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
-	struct nlattr *nla[NFTA_SET_MAX + 1];
-	struct nft_ctx ctx;
-	int err, ret;
-
-	err = nlmsg_parse(cb->nlh, sizeof(*nfmsg), nla, NFTA_SET_MAX,
-			  nft_set_policy);
-	if (err < 0)
-		return err;
-
-	err = nft_ctx_init_from_setattr(&ctx, cb->skb, cb->nlh, (void *)nla);
-	if (err < 0)
-		return err;
-
-	if (ctx.table == NULL) {
-		if (ctx.afi == NULL)
-			ret = nf_tables_dump_sets_all(&ctx, skb, cb);
-		else
-			ret = nf_tables_dump_sets_family(&ctx, skb, cb);
-	} else
-		ret = nf_tables_dump_sets_table(&ctx, skb, cb);
-
-	return ret;
+	kfree(cb->data);
+	return 0;
 }
 
 #define NFT_SET_INACTIVE	(1 << 15)	/* Internal set flag */
@@ -2426,7 +2339,17 @@ static int nf_tables_getset(struct sock *nlsk, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = nf_tables_dump_sets,
+			.done = nf_tables_dump_sets_done,
 		};
+		struct nft_ctx *ctx_dump;
+
+		ctx_dump = kmalloc(sizeof(*ctx_dump), GFP_KERNEL);
+		if (ctx_dump == NULL)
+			return -ENOMEM;
+
+		*ctx_dump = ctx;
+		c.data = ctx_dump;
+
 		return netlink_dump_start(nlsk, skb, nlh, &c);
 	}
 
-- 
1.7.10.4
