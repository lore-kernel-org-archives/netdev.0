From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/26] netfilter: nf_tables: add generation mask to sets
Date: Wed,  6 Jul 2016 16:23:58 +0200
Message-ID: <1467815048-2240-17-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34233 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754820AbcGFO0w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 10:26:52 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id B942717DB71
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A6ADFFAB4E
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D8E586449C
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:46 +0200 (CEST)
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to ("netfilter: nf_tables: add generation mask to tables").

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  8 +++--
 net/netfilter/nf_tables_api.c     | 68 +++++++++++++++++++++++----------------
 net/netfilter/nft_dynset.c        |  7 ++--
 net/netfilter/nft_lookup.c        |  6 ++--
 4 files changed, 54 insertions(+), 35 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index b023e28..07a5ba4 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -296,6 +296,7 @@ void nft_unregister_set(struct nft_set_ops *ops);
  * 	@ops: set ops
  * 	@pnet: network namespace
  * 	@flags: set flags
+ *	@genmask: generation mask
  * 	@klen: key length
  * 	@dlen: data length
  * 	@data: private set data
@@ -317,7 +318,8 @@ struct nft_set {
 	/* runtime data below here */
 	const struct nft_set_ops	*ops ____cacheline_aligned;
 	possible_net_t			pnet;
-	u16				flags;
+	u16				flags:14,
+					genmask:2;
 	u8				klen;
 	u8				dlen;
 	unsigned char			data[]
@@ -335,9 +337,9 @@ static inline struct nft_set *nft_set_container_of(const void *priv)
 }
 
 struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
-				     const struct nlattr *nla);
+				     const struct nlattr *nla, u8 genmask);
 struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
-					  const struct nlattr *nla);
+					  const struct nlattr *nla, u8 genmask);
 
 static inline unsigned long nft_set_gc_interval(const struct nft_set *set)
 {
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index cae88f8..3316bce 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -289,9 +289,6 @@ static int nft_delrule_by_chain(struct nft_ctx *ctx)
 	return 0;
 }
 
-/* Internal set flag */
-#define NFT_SET_INACTIVE	(1 << 15)
-
 static int nft_trans_set_add(struct nft_ctx *ctx, int msg_type,
 			     struct nft_set *set)
 {
@@ -304,7 +301,7 @@ static int nft_trans_set_add(struct nft_ctx *ctx, int msg_type,
 	if (msg_type == NFT_MSG_NEWSET && ctx->nla[NFTA_SET_ID] != NULL) {
 		nft_trans_set_id(trans) =
 			ntohl(nla_get_be32(ctx->nla[NFTA_SET_ID]));
-		set->flags |= NFT_SET_INACTIVE;
+		nft_activate_next(ctx->net, set);
 	}
 	nft_trans_set(trans) = set;
 	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
@@ -320,7 +317,7 @@ static int nft_delset(struct nft_ctx *ctx, struct nft_set *set)
 	if (err < 0)
 		return err;
 
-	list_del_rcu(&set->list);
+	nft_deactivate_next(ctx->net, set);
 	ctx->table->use--;
 
 	return err;
@@ -741,6 +738,9 @@ static int nft_flush_table(struct nft_ctx *ctx)
 	}
 
 	list_for_each_entry_safe(set, ns, &ctx->table->sets, list) {
+		if (!nft_is_active_next(ctx->net, set))
+			continue;
+
 		if (set->flags & NFT_SET_ANONYMOUS &&
 		    !list_empty(&set->bindings))
 			continue;
@@ -2367,7 +2367,7 @@ static int nft_ctx_init_from_setattr(struct nft_ctx *ctx, struct net *net,
 }
 
 struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
-				     const struct nlattr *nla)
+				     const struct nlattr *nla, u8 genmask)
 {
 	struct nft_set *set;
 
@@ -2375,22 +2375,27 @@ struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
 		return ERR_PTR(-EINVAL);
 
 	list_for_each_entry(set, &table->sets, list) {
-		if (!nla_strcmp(nla, set->name))
+		if (!nla_strcmp(nla, set->name) &&
+		    nft_active_genmask(set, genmask))
 			return set;
 	}
 	return ERR_PTR(-ENOENT);
 }
 
 struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
-					  const struct nlattr *nla)
+					  const struct nlattr *nla,
+					  u8 genmask)
 {
 	struct nft_trans *trans;
 	u32 id = ntohl(nla_get_be32(nla));
 
 	list_for_each_entry(trans, &net->nft.commit_list, list) {
+		struct nft_set *set = nft_trans_set(trans);
+
 		if (trans->msg_type == NFT_MSG_NEWSET &&
-		    id == nft_trans_set_id(trans))
-			return nft_trans_set(trans);
+		    id == nft_trans_set_id(trans) &&
+		    nft_active_genmask(set, genmask))
+			return set;
 	}
 	return ERR_PTR(-ENOENT);
 }
@@ -2415,6 +2420,8 @@ cont:
 		list_for_each_entry(i, &ctx->table->sets, list) {
 			int tmp;
 
+			if (!nft_is_active_next(ctx->net, set))
+				continue;
 			if (!sscanf(i->name, name, &tmp))
 				continue;
 			if (tmp < min || tmp >= min + BITS_PER_BYTE * PAGE_SIZE)
@@ -2434,6 +2441,8 @@ cont:
 
 	snprintf(set->name, sizeof(set->name), name, min + n);
 	list_for_each_entry(i, &ctx->table->sets, list) {
+		if (!nft_is_active_next(ctx->net, i))
+			continue;
 		if (!strcmp(set->name, i->name))
 			return -ENFILE;
 	}
@@ -2582,6 +2591,8 @@ static int nf_tables_dump_sets(struct sk_buff *skb, struct netlink_callback *cb)
 			list_for_each_entry_rcu(set, &table->sets, list) {
 				if (idx < s_idx)
 					goto cont;
+				if (!nft_is_active(net, set))
+					goto cont;
 
 				ctx_set = *ctx;
 				ctx_set.table = table;
@@ -2651,11 +2662,9 @@ static int nf_tables_getset(struct net *net, struct sock *nlsk,
 	if (nfmsg->nfgen_family == NFPROTO_UNSPEC)
 		return -EAFNOSUPPORT;
 
-	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME]);
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME], genmask);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
-	if (set->flags & NFT_SET_INACTIVE)
-		return -ENOENT;
 
 	skb2 = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb2 == NULL)
@@ -2798,7 +2807,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 
 	nft_ctx_init(&ctx, net, skb, nlh, afi, table, NULL, nla);
 
-	set = nf_tables_set_lookup(table, nla[NFTA_SET_NAME]);
+	set = nf_tables_set_lookup(table, nla[NFTA_SET_NAME], genmask);
 	if (IS_ERR(set)) {
 		if (PTR_ERR(set) != -ENOENT)
 			return PTR_ERR(set);
@@ -2911,7 +2920,7 @@ static int nf_tables_delset(struct net *net, struct sock *nlsk,
 	if (err < 0)
 		return err;
 
-	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME]);
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME], genmask);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
 	if (!list_empty(&set->bindings))
@@ -2980,7 +2989,7 @@ void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
 	list_del_rcu(&binding->list);
 
 	if (list_empty(&set->bindings) && set->flags & NFT_SET_ANONYMOUS &&
-	    !(set->flags & NFT_SET_INACTIVE))
+	    nft_is_active(ctx->net, set))
 		nf_tables_set_destroy(ctx, set);
 }
 
@@ -3166,11 +3175,10 @@ static int nf_tables_dump_set(struct sk_buff *skb, struct netlink_callback *cb)
 	if (err < 0)
 		return err;
 
-	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET]);
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET],
+				   genmask);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
-	if (set->flags & NFT_SET_INACTIVE)
-		return -ENOENT;
 
 	event  = NFT_MSG_NEWSETELEM;
 	event |= NFNL_SUBSYS_NFTABLES << 8;
@@ -3232,11 +3240,10 @@ static int nf_tables_getsetelem(struct net *net, struct sock *nlsk,
 	if (err < 0)
 		return err;
 
-	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET]);
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET],
+				   genmask);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
-	if (set->flags & NFT_SET_INACTIVE)
-		return -ENOENT;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
@@ -3567,11 +3574,13 @@ static int nf_tables_newsetelem(struct net *net, struct sock *nlsk,
 	if (err < 0)
 		return err;
 
-	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET]);
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET],
+				   genmask);
 	if (IS_ERR(set)) {
 		if (nla[NFTA_SET_ELEM_LIST_SET_ID]) {
 			set = nf_tables_set_lookup_byid(net,
-					nla[NFTA_SET_ELEM_LIST_SET_ID]);
+					nla[NFTA_SET_ELEM_LIST_SET_ID],
+					genmask);
 		}
 		if (IS_ERR(set))
 			return PTR_ERR(set);
@@ -3690,7 +3699,8 @@ static int nf_tables_delsetelem(struct net *net, struct sock *nlsk,
 	if (err < 0)
 		return err;
 
-	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET]);
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET],
+				   genmask);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
 	if (!list_empty(&set->bindings) && set->flags & NFT_SET_CONSTANT)
@@ -4003,7 +4013,7 @@ static int nf_tables_commit(struct net *net, struct sk_buff *skb)
 					      NFT_MSG_DELRULE);
 			break;
 		case NFT_MSG_NEWSET:
-			nft_trans_set(trans)->flags &= ~NFT_SET_INACTIVE;
+			nft_clear(net, nft_trans_set(trans));
 			/* This avoids hitting -EBUSY when deleting the table
 			 * from the transaction.
 			 */
@@ -4016,6 +4026,7 @@ static int nf_tables_commit(struct net *net, struct sk_buff *skb)
 			nft_trans_destroy(trans);
 			break;
 		case NFT_MSG_DELSET:
+			list_del_rcu(&nft_trans_set(trans)->list);
 			nf_tables_set_notify(&trans->ctx, nft_trans_set(trans),
 					     NFT_MSG_DELSET, GFP_KERNEL);
 			break;
@@ -4134,8 +4145,7 @@ static int nf_tables_abort(struct net *net, struct sk_buff *skb)
 			break;
 		case NFT_MSG_DELSET:
 			trans->ctx.table->use++;
-			list_add_tail_rcu(&nft_trans_set(trans)->list,
-					  &trans->ctx.table->sets);
+			nft_clear(trans->ctx.net, nft_trans_set(trans));
 			nft_trans_destroy(trans);
 			break;
 		case NFT_MSG_NEWSETELEM:
@@ -4282,6 +4292,8 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 	}
 
 	list_for_each_entry(set, &ctx->table->sets, list) {
+		if (!nft_is_active_next(ctx->net, set))
+			continue;
 		if (!(set->flags & NFT_SET_MAP) ||
 		    set->dtype != NFT_DATA_VERDICT)
 			continue;
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 78d4914..0af2669 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -103,6 +103,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
 	struct nft_dynset *priv = nft_expr_priv(expr);
+	u8 genmask = nft_genmask_next(ctx->net);
 	struct nft_set *set;
 	u64 timeout;
 	int err;
@@ -112,11 +113,13 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	    tb[NFTA_DYNSET_SREG_KEY] == NULL)
 		return -EINVAL;
 
-	set = nf_tables_set_lookup(ctx->table, tb[NFTA_DYNSET_SET_NAME]);
+	set = nf_tables_set_lookup(ctx->table, tb[NFTA_DYNSET_SET_NAME],
+				   genmask);
 	if (IS_ERR(set)) {
 		if (tb[NFTA_DYNSET_SET_ID])
 			set = nf_tables_set_lookup_byid(ctx->net,
-							tb[NFTA_DYNSET_SET_ID]);
+							tb[NFTA_DYNSET_SET_ID],
+							genmask);
 		if (IS_ERR(set))
 			return PTR_ERR(set);
 	}
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index b3c31ef..8a102cf 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -54,6 +54,7 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
 	struct nft_lookup *priv = nft_expr_priv(expr);
+	u8 genmask = nft_genmask_next(ctx->net);
 	struct nft_set *set;
 	int err;
 
@@ -61,11 +62,12 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 	    tb[NFTA_LOOKUP_SREG] == NULL)
 		return -EINVAL;
 
-	set = nf_tables_set_lookup(ctx->table, tb[NFTA_LOOKUP_SET]);
+	set = nf_tables_set_lookup(ctx->table, tb[NFTA_LOOKUP_SET], genmask);
 	if (IS_ERR(set)) {
 		if (tb[NFTA_LOOKUP_SET_ID]) {
 			set = nf_tables_set_lookup_byid(ctx->net,
-							tb[NFTA_LOOKUP_SET_ID]);
+							tb[NFTA_LOOKUP_SET_ID],
+							genmask);
 		}
 		if (IS_ERR(set))
 			return PTR_ERR(set);
-- 
2.1.4
