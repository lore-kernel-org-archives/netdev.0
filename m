From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/25] netfilter: nf_tables: allow to filter out rules by table and chain
Date: Sat, 23 Jul 2016 13:08:34 +0200
Message-ID: <1469272119-29942-21-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35941 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbcGWLJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:35 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id F2524E7DB1
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:33 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E471FFB468
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:33 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id F14E1FF2D5
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:31 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the table and/or chain attributes are set in a rule dump request,
we filter out the rules based on this selection.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0211eae..13d50e7 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1857,10 +1857,16 @@ err:
 	return err;
 }
 
+struct nft_rule_dump_ctx {
+	char table[NFT_TABLE_MAXNAMELEN];
+	char chain[NFT_CHAIN_MAXNAMELEN];
+};
+
 static int nf_tables_dump_rules(struct sk_buff *skb,
 				struct netlink_callback *cb)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
+	const struct nft_rule_dump_ctx *ctx = cb->data;
 	const struct nft_af_info *afi;
 	const struct nft_table *table;
 	const struct nft_chain *chain;
@@ -1877,7 +1883,15 @@ static int nf_tables_dump_rules(struct sk_buff *skb,
 			continue;
 
 		list_for_each_entry_rcu(table, &afi->tables, list) {
+			if (ctx && ctx->table[0] &&
+			    strcmp(ctx->table, table->name) != 0)
+				continue;
+
 			list_for_each_entry_rcu(chain, &table->chains, list) {
+				if (ctx && ctx->chain[0] &&
+				    strcmp(ctx->chain, chain->name) != 0)
+					continue;
+
 				list_for_each_entry_rcu(rule, &chain->rules, list) {
 					if (!nft_is_active(net, rule))
 						goto cont;
@@ -1907,6 +1921,12 @@ done:
 	return skb->len;
 }
 
+static int nf_tables_dump_rules_done(struct netlink_callback *cb)
+{
+	kfree(cb->data);
+	return 0;
+}
+
 static int nf_tables_getrule(struct net *net, struct sock *nlsk,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
 			     const struct nlattr * const nla[])
@@ -1924,7 +1944,25 @@ static int nf_tables_getrule(struct net *net, struct sock *nlsk,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = nf_tables_dump_rules,
+			.done = nf_tables_dump_rules_done,
 		};
+
+		if (nla[NFTA_RULE_TABLE] || nla[NFTA_RULE_CHAIN]) {
+			struct nft_rule_dump_ctx *ctx;
+
+			ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+			if (!ctx)
+				return -ENOMEM;
+
+			if (nla[NFTA_RULE_TABLE])
+				nla_strlcpy(ctx->table, nla[NFTA_RULE_TABLE],
+					    sizeof(ctx->table));
+			if (nla[NFTA_RULE_CHAIN])
+				nla_strlcpy(ctx->chain, nla[NFTA_RULE_CHAIN],
+					    sizeof(ctx->chain));
+			c.data = ctx;
+		}
+
 		return netlink_dump_start(nlsk, skb, nlh, &c);
 	}
 
-- 
2.1.4
