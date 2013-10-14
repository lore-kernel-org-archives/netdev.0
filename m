From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/17] netfilter: nfnetlink: add batch support and use it from nf_tables
Date: Mon, 14 Oct 2013 18:38:56 +0200
Message-ID: <1381768738-17739-16-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34874 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757321Ab3JNQjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:39 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a batch support to nfnetlink. Basically, it adds
two new control messages:

* NFNL_MSG_BATCH_BEGIN, that indicates the beginning of a batch,
  the nfgenmsg->res_id indicates the nfnetlink subsystem ID.

* NFNL_MSG_BATCH_END, that results in the invocation of the
  ss->commit callback function. If not specified or an error
  ocurred in the batch, the ss->abort function is invoked
  instead.

The end message represents the commit operation in nftables, the
lack of end message results in an abort. This patch also adds the
.call_batch function that is only called from the batch receival
path.

This patch adds atomic rule updates and dumps based on
bitmask generations. This allows to atomically commit a set of
rule-set updates incrementally without altering the internal
state of existing nf_tables expressions/matches/targets.

The idea consists of using a generation cursor of 1 bit and
a bitmask of 2 bits per rule. Assuming the gencursor is 0,
then the genmask (expressed as a bitmask) can be interpreted
as:

00 active in the present, will be active in the next generation.
01 inactive in the present, will be active in the next generation.
10 active in the present, will be deleted in the next generation.
 ^
 gencursor

Once you invoke the transition to the next generation, the global
gencursor is updated:

00 active in the present, will be active in the next generation.
01 active in the present, needs to zero its future, it becomes 00.
10 inactive in the present, delete now.
^
gencursor

If a dump is in progress and nf_tables enters a new generation,
the dump will stop and return -EBUSY to let userspace know that
it has to retry again. In order to invalidate dumps, a global
genctr counter is increased everytime nf_tables enters a new
generation.

This new operation can be used from the user-space utility
that controls the firewall, eg.

nft -f restore

The rule updates contained in `file' will be applied atomically.

cat file
-----
add filter INPUT ip saddr 1.1.1.1 counter accept #1
del filter INPUT ip daddr 2.2.2.2 counter drop   #2
-EOF-

Note that the rule 1 will be inactive until the transition to the
next generation, the rule 2 will be evicted in the next generation.

There is a penalty during the rule update due to the branch
misprediction in the packet matching framework. But that should be
quickly resolved once the iteration over the commit list that
contain rules that require updates is finished.

Event notification happens once the rule-set update has been
committed. So we skip notifications is case the rule-set update
is aborted, which can happen in case that the rule-set is tested
to apply correctly.

This patch squashed the following patches from Pablo:

* nf_tables: atomic rule updates and dumps
* nf_tables: get rid of per rule list_head for commits
* nf_tables: use per netns commit list
* nfnetlink: add batch support and use it from nf_tables
* nf_tables: all rule updates are transactional
* nf_tables: attach replacement rule after stale one
* nf_tables: do not allow deletion/replacement of stale rules
* nf_tables: remove unused NFTA_RULE_FLAGS

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink.h      |    5 +
 include/net/netfilter/nf_tables.h        |   25 +++-
 include/net/netns/nftables.h             |    3 +
 include/uapi/linux/netfilter/nfnetlink.h |    4 +
 net/netfilter/nf_tables_api.c            |  202 +++++++++++++++++++++++++++---
 net/netfilter/nf_tables_core.c           |   10 ++
 net/netfilter/nfnetlink.c                |  175 +++++++++++++++++++++++++-
 7 files changed, 401 insertions(+), 23 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 4f68cd7..28c7436 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -14,6 +14,9 @@ struct nfnl_callback {
 	int (*call_rcu)(struct sock *nl, struct sk_buff *skb, 
 		    const struct nlmsghdr *nlh,
 		    const struct nlattr * const cda[]);
+	int (*call_batch)(struct sock *nl, struct sk_buff *skb,
+			  const struct nlmsghdr *nlh,
+			  const struct nlattr * const cda[]);
 	const struct nla_policy *policy;	/* netlink attribute policy */
 	const u_int16_t attr_count;		/* number of nlattr's */
 };
@@ -23,6 +26,8 @@ struct nfnetlink_subsystem {
 	__u8 subsys_id;			/* nfnetlink subsystem ID */
 	__u8 cb_count;			/* number of callbacks */
 	const struct nfnl_callback *cb;	/* callback for individual types */
+	int (*commit)(struct sk_buff *skb);
+	int (*abort)(struct sk_buff *skb);
 };
 
 int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index d3272e9..975ad3c 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -323,18 +323,39 @@ static inline void *nft_expr_priv(const struct nft_expr *expr)
  *	@list: used internally
  *	@rcu_head: used internally for rcu
  *	@handle: rule handle
+ *	@genmask: generation mask
  *	@dlen: length of expression data
  *	@data: expression data
  */
 struct nft_rule {
 	struct list_head		list;
 	struct rcu_head			rcu_head;
-	u64				handle:48,
+	u64				handle:46,
+					genmask:2,
 					dlen:16;
 	unsigned char			data[]
 		__attribute__((aligned(__alignof__(struct nft_expr))));
 };
 
+/**
+ *	struct nft_rule_trans - nf_tables rule update in transaction
+ *
+ *	@list: used internally
+ *	@rule: rule that needs to be updated
+ *	@chain: chain that this rule belongs to
+ *	@table: table for which this chain applies
+ *	@nlh: netlink header of the message that contain this update
+ *	@family: family expressesed as AF_*
+ */
+struct nft_rule_trans {
+	struct list_head		list;
+	struct nft_rule			*rule;
+	const struct nft_chain		*chain;
+	const struct nft_table		*table;
+	const struct nlmsghdr		*nlh;
+	u8				family;
+};
+
 static inline struct nft_expr *nft_expr_first(const struct nft_rule *rule)
 {
 	return (struct nft_expr *)&rule->data[0];
@@ -370,6 +391,7 @@ enum nft_chain_flags {
  *	@rules: list of rules in the chain
  *	@list: used internally
  *	@rcu_head: used internally
+ *	@net: net namespace that this chain belongs to
  *	@handle: chain handle
  *	@flags: bitmask of enum nft_chain_flags
  *	@use: number of jump references to this chain
@@ -380,6 +402,7 @@ struct nft_chain {
 	struct list_head		rules;
 	struct list_head		list;
 	struct rcu_head			rcu_head;
+	struct net			*net;
 	u64				handle;
 	u8				flags;
 	u16				use;
diff --git a/include/net/netns/nftables.h b/include/net/netns/nftables.h
index a98b1c5..08a4248 100644
--- a/include/net/netns/nftables.h
+++ b/include/net/netns/nftables.h
@@ -7,9 +7,12 @@ struct nft_af_info;
 
 struct netns_nftables {
 	struct list_head	af_info;
+	struct list_head	commit_list;
 	struct nft_af_info	*ipv4;
 	struct nft_af_info	*ipv6;
 	struct nft_af_info	*bridge;
+	u8			gencursor;
+	u8			genctr;
 };
 
 #endif
diff --git a/include/uapi/linux/netfilter/nfnetlink.h b/include/uapi/linux/netfilter/nfnetlink.h
index 2889594..596ddd4 100644
--- a/include/uapi/linux/netfilter/nfnetlink.h
+++ b/include/uapi/linux/netfilter/nfnetlink.h
@@ -57,4 +57,8 @@ struct nfgenmsg {
 #define NFNL_SUBSYS_NFT_COMPAT		11
 #define NFNL_SUBSYS_COUNT		12
 
+/* Reserved control nfnetlink messages */
+#define NFNL_MSG_BATCH_BEGIN		NLMSG_MIN_TYPE
+#define NFNL_MSG_BATCH_END		NLMSG_MIN_TYPE+1
+
 #endif /* _UAPI_NFNETLINK_H */
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0f14066..79e1418 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -978,6 +978,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 	INIT_LIST_HEAD(&chain->rules);
 	chain->handle = nf_tables_alloc_handle(table);
+	chain->net = net;
 	nla_strlcpy(chain->name, name, NFT_CHAIN_MAXNAMELEN);
 
 	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
@@ -1371,6 +1372,41 @@ err:
 	return err;
 }
 
+static inline bool
+nft_rule_is_active(struct net *net, const struct nft_rule *rule)
+{
+	return (rule->genmask & (1 << net->nft.gencursor)) == 0;
+}
+
+static inline int gencursor_next(struct net *net)
+{
+	return net->nft.gencursor+1 == 1 ? 1 : 0;
+}
+
+static inline int
+nft_rule_is_active_next(struct net *net, const struct nft_rule *rule)
+{
+	return (rule->genmask & (1 << gencursor_next(net))) == 0;
+}
+
+static inline void
+nft_rule_activate_next(struct net *net, struct nft_rule *rule)
+{
+	/* Now inactive, will be active in the future */
+	rule->genmask = (1 << net->nft.gencursor);
+}
+
+static inline void
+nft_rule_disactivate_next(struct net *net, struct nft_rule *rule)
+{
+	rule->genmask = (1 << gencursor_next(net));
+}
+
+static inline void nft_rule_clear(struct net *net, struct nft_rule *rule)
+{
+	rule->genmask = 0;
+}
+
 static int nf_tables_dump_rules(struct sk_buff *skb,
 				struct netlink_callback *cb)
 {
@@ -1382,6 +1418,8 @@ static int nf_tables_dump_rules(struct sk_buff *skb,
 	unsigned int idx = 0, s_idx = cb->args[0];
 	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
+	u8 genctr = ACCESS_ONCE(net->nft.genctr);
+	u8 gencursor = ACCESS_ONCE(net->nft.gencursor);
 
 	list_for_each_entry(afi, &net->nft.af_info, list) {
 		if (family != NFPROTO_UNSPEC && family != afi->family)
@@ -1390,6 +1428,8 @@ static int nf_tables_dump_rules(struct sk_buff *skb,
 		list_for_each_entry(table, &afi->tables, list) {
 			list_for_each_entry(chain, &table->chains, list) {
 				list_for_each_entry(rule, &chain->rules, list) {
+					if (!nft_rule_is_active(net, rule))
+						goto cont;
 					if (idx < s_idx)
 						goto cont;
 					if (idx > s_idx)
@@ -1408,6 +1448,10 @@ cont:
 		}
 	}
 done:
+	/* Invalidate this dump, a transition to the new generation happened */
+	if (gencursor != net->nft.gencursor || genctr != net->nft.genctr)
+		return -EBUSY;
+
 	cb->args[0] = idx;
 	return skb->len;
 }
@@ -1492,6 +1536,25 @@ static void nf_tables_rule_destroy(struct nft_rule *rule)
 
 static struct nft_expr_info *info;
 
+static struct nft_rule_trans *
+nf_tables_trans_add(struct nft_rule *rule, const struct nft_ctx *ctx)
+{
+	struct nft_rule_trans *rupd;
+
+	rupd = kmalloc(sizeof(struct nft_rule_trans), GFP_KERNEL);
+	if (rupd == NULL)
+	       return NULL;
+
+	rupd->chain = ctx->chain;
+	rupd->table = ctx->table;
+	rupd->rule = rule;
+	rupd->family = ctx->afi->family;
+	rupd->nlh = ctx->nlh;
+	list_add_tail(&rupd->list, &ctx->net->nft.commit_list);
+
+	return rupd;
+}
+
 static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 			     const struct nlmsghdr *nlh,
 			     const struct nlattr * const nla[])
@@ -1502,6 +1565,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_table *table;
 	struct nft_chain *chain;
 	struct nft_rule *rule, *old_rule = NULL;
+	struct nft_rule_trans *repl = NULL;
 	struct nft_expr *expr;
 	struct nft_ctx ctx;
 	struct nlattr *tmp;
@@ -1576,6 +1640,8 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	if (rule == NULL)
 		goto err1;
 
+	nft_rule_activate_next(net, rule);
+
 	rule->handle = handle;
 	rule->dlen   = size;
 
@@ -1589,8 +1655,18 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	}
 
 	if (nlh->nlmsg_flags & NLM_F_REPLACE) {
-		list_replace_rcu(&old_rule->list, &rule->list);
-		nf_tables_rule_destroy(old_rule);
+		if (nft_rule_is_active_next(net, old_rule)) {
+			repl = nf_tables_trans_add(old_rule, &ctx);
+			if (repl == NULL) {
+				err = -ENOMEM;
+				goto err2;
+			}
+			nft_rule_disactivate_next(net, old_rule);
+			list_add_tail(&rule->list, &old_rule->list);
+		} else {
+			err = -ENOENT;
+			goto err2;
+		}
 	} else if (nlh->nlmsg_flags & NLM_F_APPEND)
 		if (old_rule)
 			list_add_rcu(&rule->list, &old_rule->list);
@@ -1603,11 +1679,20 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 			list_add_rcu(&rule->list, &chain->rules);
 	}
 
-	nf_tables_rule_notify(skb, nlh, table, chain, rule, NFT_MSG_NEWRULE,
-			      nlh->nlmsg_flags & (NLM_F_APPEND | NLM_F_REPLACE),
-			      nfmsg->nfgen_family);
+	if (nf_tables_trans_add(rule, &ctx) == NULL) {
+		err = -ENOMEM;
+		goto err3;
+	}
 	return 0;
 
+err3:
+	list_del_rcu(&rule->list);
+	if (repl) {
+		list_del_rcu(&repl->rule->list);
+		list_del(&repl->list);
+		nft_rule_clear(net, repl->rule);
+		kfree(repl);
+	}
 err2:
 	nf_tables_rule_destroy(rule);
 err1:
@@ -1618,6 +1703,19 @@ err1:
 	return err;
 }
 
+static int
+nf_tables_delrule_one(struct nft_ctx *ctx, struct nft_rule *rule)
+{
+	/* You cannot delete the same rule twice */
+	if (nft_rule_is_active_next(ctx->net, rule)) {
+		if (nf_tables_trans_add(rule, ctx) == NULL)
+			return -ENOMEM;
+		nft_rule_disactivate_next(ctx->net, rule);
+		return 0;
+	}
+	return -ENOENT;
+}
+
 static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 			     const struct nlmsghdr *nlh,
 			     const struct nlattr * const nla[])
@@ -1628,7 +1726,8 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 	const struct nft_table *table;
 	struct nft_chain *chain;
 	struct nft_rule *rule, *tmp;
-	int family = nfmsg->nfgen_family;
+	int family = nfmsg->nfgen_family, err = 0;
+	struct nft_ctx ctx;
 
 	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
@@ -1642,31 +1741,95 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(chain))
 		return PTR_ERR(chain);
 
+	nft_ctx_init(&ctx, skb, nlh, afi, table, chain, nla);
+
 	if (nla[NFTA_RULE_HANDLE]) {
 		rule = nf_tables_rule_lookup(chain, nla[NFTA_RULE_HANDLE]);
 		if (IS_ERR(rule))
 			return PTR_ERR(rule);
 
-		/* List removal must be visible before destroying expressions */
-		list_del_rcu(&rule->list);
-
-		nf_tables_rule_notify(skb, nlh, table, chain, rule,
-				      NFT_MSG_DELRULE, 0, family);
-		nf_tables_rule_destroy(rule);
+		err = nf_tables_delrule_one(&ctx, rule);
 	} else {
 		/* Remove all rules in this chain */
 		list_for_each_entry_safe(rule, tmp, &chain->rules, list) {
-			list_del_rcu(&rule->list);
+			err = nf_tables_delrule_one(&ctx, rule);
+			if (err < 0)
+				break;
+		}
+	}
+
+	return err;
+}
+
+static int nf_tables_commit(struct sk_buff *skb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nft_rule_trans *rupd, *tmp;
 
-			nf_tables_rule_notify(skb, nlh, table, chain, rule,
-					      NFT_MSG_DELRULE, 0, family);
-			nf_tables_rule_destroy(rule);
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
+	list_for_each_entry_safe(rupd, tmp, &net->nft.commit_list, list) {
+		/* Delete this rule from the dirty list */
+		list_del(&rupd->list);
+
+		/* This rule was inactive in the past and just became active.
+		 * Clear the next bit of the genmask since its meaning has
+		 * changed, now it is the future.
+		 */
+		if (nft_rule_is_active(net, rupd->rule)) {
+			nft_rule_clear(net, rupd->rule);
+			nf_tables_rule_notify(skb, rupd->nlh, rupd->table,
+					      rupd->chain, rupd->rule,
+					      NFT_MSG_NEWRULE, 0,
+					      rupd->family);
+			kfree(rupd);
+			continue;
 		}
+
+		/* This rule is in the past, get rid of it */
+		list_del_rcu(&rupd->rule->list);
+		nf_tables_rule_notify(skb, rupd->nlh, rupd->table, rupd->chain,
+				      rupd->rule, NFT_MSG_DELRULE, 0,
+				      rupd->family);
+		nf_tables_rule_destroy(rupd->rule);
+		kfree(rupd);
 	}
 
 	return 0;
 }
 
+static int nf_tables_abort(struct sk_buff *skb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nft_rule_trans *rupd, *tmp;
+
+	list_for_each_entry_safe(rupd, tmp, &net->nft.commit_list, list) {
+		/* Delete all rules from the dirty list */
+		list_del(&rupd->list);
+
+		if (!nft_rule_is_active_next(net, rupd->rule)) {
+			nft_rule_clear(net, rupd->rule);
+			kfree(rupd);
+			continue;
+		}
+
+		/* This rule is inactive, get rid of it */
+		list_del_rcu(&rupd->rule->list);
+		nf_tables_rule_destroy(rupd->rule);
+		kfree(rupd);
+	}
+	return 0;
+}
+
 /*
  * Sets
  */
@@ -2634,7 +2797,7 @@ static const struct nfnl_callback nf_tables_cb[NFT_MSG_MAX] = {
 		.policy		= nft_chain_policy,
 	},
 	[NFT_MSG_NEWRULE] = {
-		.call		= nf_tables_newrule,
+		.call_batch	= nf_tables_newrule,
 		.attr_count	= NFTA_RULE_MAX,
 		.policy		= nft_rule_policy,
 	},
@@ -2644,7 +2807,7 @@ static const struct nfnl_callback nf_tables_cb[NFT_MSG_MAX] = {
 		.policy		= nft_rule_policy,
 	},
 	[NFT_MSG_DELRULE] = {
-		.call		= nf_tables_delrule,
+		.call_batch	= nf_tables_delrule,
 		.attr_count	= NFTA_RULE_MAX,
 		.policy		= nft_rule_policy,
 	},
@@ -2685,6 +2848,8 @@ static const struct nfnetlink_subsystem nf_tables_subsys = {
 	.subsys_id	= NFNL_SUBSYS_NFTABLES,
 	.cb_count	= NFT_MSG_MAX,
 	.cb		= nf_tables_cb,
+	.commit		= nf_tables_commit,
+	.abort		= nf_tables_abort,
 };
 
 /*
@@ -3056,6 +3221,7 @@ EXPORT_SYMBOL_GPL(nft_data_dump);
 static int nf_tables_init_net(struct net *net)
 {
 	INIT_LIST_HEAD(&net->nft.af_info);
+	INIT_LIST_HEAD(&net->nft.commit_list);
 	return 0;
 }
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 3c13007..d581ef6 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -88,12 +88,22 @@ nft_do_chain_pktinfo(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 	struct nft_data data[NFT_REG_MAX + 1];
 	unsigned int stackptr = 0;
 	struct nft_jumpstack jumpstack[NFT_JUMP_STACK_SIZE];
+	/*
+	 * Cache cursor to avoid problems in case that the cursor is updated
+	 * while traversing the ruleset.
+	 */
+	unsigned int gencursor = ACCESS_ONCE(chain->net->nft.gencursor);
 
 do_chain:
 	rule = list_entry(&chain->rules, struct nft_rule, list);
 next_rule:
 	data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
 	list_for_each_entry_continue_rcu(rule, &chain->rules, list) {
+
+		/* This rule is not active, skip. */
+		if (unlikely(rule->genmask & (1 << gencursor)))
+			continue;
+
 		nft_rule_for_each_expr(expr, last, rule) {
 			if (expr->ops == &nft_cmp_fast_ops)
 				nft_cmp_fast_eval(expr, data);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 572d87d..027f16a 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -147,9 +147,6 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	const struct nfnetlink_subsystem *ss;
 	int type, err;
 
-	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
-		return -EPERM;
-
 	/* All the messages must at least contain nfgenmsg */
 	if (nlmsg_len(nlh) < sizeof(struct nfgenmsg))
 		return 0;
@@ -217,9 +214,179 @@ replay:
 	}
 }
 
+static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
+				u_int16_t subsys_id)
+{
+	struct sk_buff *nskb, *oskb = skb;
+	struct net *net = sock_net(skb->sk);
+	const struct nfnetlink_subsystem *ss;
+	const struct nfnl_callback *nc;
+	bool success = true, done = false;
+	int err;
+
+	if (subsys_id >= NFNL_SUBSYS_COUNT)
+		return netlink_ack(skb, nlh, -EINVAL);
+replay:
+	nskb = netlink_skb_clone(oskb, GFP_KERNEL);
+	if (!nskb)
+		return netlink_ack(oskb, nlh, -ENOMEM);
+
+	nskb->sk = oskb->sk;
+	skb = nskb;
+
+	nfnl_lock(subsys_id);
+	ss = rcu_dereference_protected(table[subsys_id].subsys,
+				       lockdep_is_held(&table[subsys_id].mutex));
+	if (!ss) {
+#ifdef CONFIG_MODULES
+		nfnl_unlock(subsys_id);
+		request_module("nfnetlink-subsys-%d", subsys_id);
+		nfnl_lock(subsys_id);
+		ss = rcu_dereference_protected(table[subsys_id].subsys,
+					       lockdep_is_held(&table[subsys_id].mutex));
+		if (!ss)
+#endif
+		{
+			nfnl_unlock(subsys_id);
+			kfree_skb(nskb);
+			return netlink_ack(skb, nlh, -EOPNOTSUPP);
+		}
+	}
+
+	if (!ss->commit || !ss->abort) {
+		nfnl_unlock(subsys_id);
+		kfree_skb(nskb);
+		return netlink_ack(skb, nlh, -EOPNOTSUPP);
+	}
+
+	while (skb->len >= nlmsg_total_size(0)) {
+		int msglen, type;
+
+		nlh = nlmsg_hdr(skb);
+		err = 0;
+
+		if (nlh->nlmsg_len < NLMSG_HDRLEN) {
+			err = -EINVAL;
+			goto ack;
+		}
+
+		/* Only requests are handled by the kernel */
+		if (!(nlh->nlmsg_flags & NLM_F_REQUEST)) {
+			err = -EINVAL;
+			goto ack;
+		}
+
+		type = nlh->nlmsg_type;
+		if (type == NFNL_MSG_BATCH_BEGIN) {
+			/* Malformed: Batch begin twice */
+			success = false;
+			goto done;
+		} else if (type == NFNL_MSG_BATCH_END) {
+			done = true;
+			goto done;
+		} else if (type < NLMSG_MIN_TYPE) {
+			err = -EINVAL;
+			goto ack;
+		}
+
+		/* We only accept a batch with messages for the same
+		 * subsystem.
+		 */
+		if (NFNL_SUBSYS_ID(type) != subsys_id) {
+			err = -EINVAL;
+			goto ack;
+		}
+
+		nc = nfnetlink_find_client(type, ss);
+		if (!nc) {
+			err = -EINVAL;
+			goto ack;
+		}
+
+		{
+			int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
+			u_int8_t cb_id = NFNL_MSG_TYPE(nlh->nlmsg_type);
+			struct nlattr *cda[ss->cb[cb_id].attr_count + 1];
+			struct nlattr *attr = (void *)nlh + min_len;
+			int attrlen = nlh->nlmsg_len - min_len;
+
+			err = nla_parse(cda, ss->cb[cb_id].attr_count,
+					attr, attrlen, ss->cb[cb_id].policy);
+			if (err < 0)
+				goto ack;
+
+			if (nc->call_batch) {
+				err = nc->call_batch(net->nfnl, skb, nlh,
+						     (const struct nlattr **)cda);
+			}
+
+			/* The lock was released to autoload some module, we
+			 * have to abort and start from scratch using the
+			 * original skb.
+			 */
+			if (err == -EAGAIN) {
+				ss->abort(skb);
+				nfnl_unlock(subsys_id);
+				kfree_skb(nskb);
+				goto replay;
+			}
+		}
+ack:
+		if (nlh->nlmsg_flags & NLM_F_ACK || err) {
+			/* We don't stop processing the batch on errors, thus,
+			 * userspace gets all the errors that the batch
+			 * triggers.
+			 */
+			netlink_ack(skb, nlh, err);
+			if (err)
+				success = false;
+		}
+
+		msglen = NLMSG_ALIGN(nlh->nlmsg_len);
+		if (msglen > skb->len)
+			msglen = skb->len;
+		skb_pull(skb, msglen);
+	}
+done:
+	if (success && done)
+		ss->commit(skb);
+	else
+		ss->abort(skb);
+
+	nfnl_unlock(subsys_id);
+	kfree_skb(nskb);
+}
+
 static void nfnetlink_rcv(struct sk_buff *skb)
 {
-	netlink_rcv_skb(skb, &nfnetlink_rcv_msg);
+	struct nlmsghdr *nlh = nlmsg_hdr(skb);
+	struct net *net = sock_net(skb->sk);
+	int msglen;
+
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+		return netlink_ack(skb, nlh, -EPERM);
+
+	if (nlh->nlmsg_len < NLMSG_HDRLEN ||
+	    skb->len < nlh->nlmsg_len)
+		return;
+
+	if (nlh->nlmsg_type == NFNL_MSG_BATCH_BEGIN) {
+		struct nfgenmsg *nfgenmsg;
+
+		msglen = NLMSG_ALIGN(nlh->nlmsg_len);
+		if (msglen > skb->len)
+			msglen = skb->len;
+
+		if (nlh->nlmsg_len < NLMSG_HDRLEN ||
+		    skb->len < NLMSG_HDRLEN + sizeof(struct nfgenmsg))
+			return;
+
+		nfgenmsg = nlmsg_data(nlh);
+		skb_pull(skb, msglen);
+		nfnetlink_rcv_batch(skb, nlh, nfgenmsg->res_id);
+	} else {
+		netlink_rcv_skb(skb, &nfnetlink_rcv_msg);
+	}
 }
 
 #ifdef CONFIG_MODULES
-- 
1.7.10.4
