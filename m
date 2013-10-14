From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/17] netfilter: nf_tables: add insert operation
Date: Mon, 14 Oct 2013 18:38:55 +0200
Message-ID: <1381768738-17739-15-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34812 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757308Ab3JNQjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:25 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>

This patch adds a new rule attribute NFTA_RULE_POSITION which is
used to store the position of a rule relatively to the others.
By providing the create command and specifying the position, the
rule is inserted after the rule with the handle equal to the
provided position.

Regarding notification, the position attribute specifies the
handle of the previous rule to make sure we don't point to any
stale rule in notifications coming from the commit path.

This patch includes the following fix from Pablo:

* nf_tables: fix rule deletion event reporting

Signed-off-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c            |   38 +++++++++++++++++++++++++-----
 2 files changed, 34 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 7d4a199..fbfd229 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -153,6 +153,7 @@ enum nft_chain_attributes {
  * @NFTA_RULE_HANDLE: numeric handle of the rule (NLA_U64)
  * @NFTA_RULE_EXPRESSIONS: list of expressions (NLA_NESTED: nft_expr_attributes)
  * @NFTA_RULE_COMPAT: compatibility specifications of the rule (NLA_NESTED: nft_rule_compat_attributes)
+ * @NFTA_RULE_POSITION: numeric handle of the previous rule (NLA_U64)
  */
 enum nft_rule_attributes {
 	NFTA_RULE_UNSPEC,
@@ -161,6 +162,7 @@ enum nft_rule_attributes {
 	NFTA_RULE_HANDLE,
 	NFTA_RULE_EXPRESSIONS,
 	NFTA_RULE_COMPAT,
+	NFTA_RULE_POSITION,
 	__NFTA_RULE_MAX
 };
 #define NFTA_RULE_MAX		(__NFTA_RULE_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index e1ee850..0f14066 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1273,6 +1273,7 @@ static const struct nla_policy nft_rule_policy[NFTA_RULE_MAX + 1] = {
 	[NFTA_RULE_HANDLE]	= { .type = NLA_U64 },
 	[NFTA_RULE_EXPRESSIONS]	= { .type = NLA_NESTED },
 	[NFTA_RULE_COMPAT]	= { .type = NLA_NESTED },
+	[NFTA_RULE_POSITION]	= { .type = NLA_U64 },
 };
 
 static int nf_tables_fill_rule_info(struct sk_buff *skb, u32 portid, u32 seq,
@@ -1285,9 +1286,10 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, u32 portid, u32 seq,
 	struct nfgenmsg *nfmsg;
 	const struct nft_expr *expr, *next;
 	struct nlattr *list;
+	const struct nft_rule *prule;
+	int type = event | NFNL_SUBSYS_NFTABLES << 8;
 
-	event |= NFNL_SUBSYS_NFTABLES << 8;
-	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg),
+	nlh = nlmsg_put(skb, portid, seq, type, sizeof(struct nfgenmsg),
 			flags);
 	if (nlh == NULL)
 		goto nla_put_failure;
@@ -1304,6 +1306,13 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, u32 portid, u32 seq,
 	if (nla_put_be64(skb, NFTA_RULE_HANDLE, cpu_to_be64(rule->handle)))
 		goto nla_put_failure;
 
+	if ((event != NFT_MSG_DELRULE) && (rule->list.prev != &chain->rules)) {
+		prule = list_entry(rule->list.prev, struct nft_rule, list);
+		if (nla_put_be64(skb, NFTA_RULE_POSITION,
+				 cpu_to_be64(prule->handle)))
+			goto nla_put_failure;
+	}
+
 	list = nla_nest_start(skb, NFTA_RULE_EXPRESSIONS);
 	if (list == NULL)
 		goto nla_put_failure;
@@ -1499,7 +1508,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	unsigned int size, i, n;
 	int err, rem;
 	bool create;
-	u64 handle;
+	u64 handle, pos_handle;
 
 	create = nlh->nlmsg_flags & NLM_F_CREATE ? true : false;
 
@@ -1533,6 +1542,16 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 		handle = nf_tables_alloc_handle(table);
 	}
 
+	if (nla[NFTA_RULE_POSITION]) {
+		if (!(nlh->nlmsg_flags & NLM_F_CREATE))
+			return -EOPNOTSUPP;
+
+		pos_handle = be64_to_cpu(nla_get_be64(nla[NFTA_RULE_POSITION]));
+		old_rule = __nf_tables_rule_lookup(chain, pos_handle);
+		if (IS_ERR(old_rule))
+			return PTR_ERR(old_rule);
+	}
+
 	nft_ctx_init(&ctx, skb, nlh, afi, table, chain, nla);
 
 	n = 0;
@@ -1573,9 +1592,16 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 		list_replace_rcu(&old_rule->list, &rule->list);
 		nf_tables_rule_destroy(old_rule);
 	} else if (nlh->nlmsg_flags & NLM_F_APPEND)
-		list_add_tail_rcu(&rule->list, &chain->rules);
-	else
-		list_add_rcu(&rule->list, &chain->rules);
+		if (old_rule)
+			list_add_rcu(&rule->list, &old_rule->list);
+		else
+			list_add_tail_rcu(&rule->list, &chain->rules);
+	else {
+		if (old_rule)
+			list_add_tail_rcu(&rule->list, &old_rule->list);
+		else
+			list_add_rcu(&rule->list, &chain->rules);
+	}
 
 	nf_tables_rule_notify(skb, nlh, table, chain, rule, NFT_MSG_NEWRULE,
 			      nlh->nlmsg_flags & (NLM_F_APPEND | NLM_F_REPLACE),
-- 
1.7.10.4
