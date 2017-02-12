From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/21] netfilter: nf_tables: add NFTA_RULE_ID attribute
Date: Sun, 12 Feb 2017 20:42:51 +0100
Message-ID: <1486928573-24773-20-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60516 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751404AbdBLTnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 14:43:25 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5FCBCBA6ED
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:24 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4E0DDDA725
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:24 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2A40EDA842
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:22 +0100 (CET)
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new attribute allows us to uniquely identify a rule in transaction.
Robots may trigger an insertion followed by deletion in a batch, in that
scenario we still don't have a public rule handle that we can use to
delete the rule. This is similar to the NFTA_SET_ID attribute that
allows us to refer to an anonymous set from a batch.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |  3 +++
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nf_tables_api.c            | 26 ++++++++++++++++++++++++++
 3 files changed, 31 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 21ce50e6d0c5..ac84686aaafb 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -1202,10 +1202,13 @@ struct nft_trans {
 
 struct nft_trans_rule {
 	struct nft_rule			*rule;
+	u32				rule_id;
 };
 
 #define nft_trans_rule(trans)	\
 	(((struct nft_trans_rule *)trans->data)->rule)
+#define nft_trans_rule_id(trans)	\
+	(((struct nft_trans_rule *)trans->data)->rule_id)
 
 struct nft_trans_set {
 	struct nft_set			*set;
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 207951516ede..05215d30fe5c 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -207,6 +207,7 @@ enum nft_chain_attributes {
  * @NFTA_RULE_COMPAT: compatibility specifications of the rule (NLA_NESTED: nft_rule_compat_attributes)
  * @NFTA_RULE_POSITION: numeric handle of the previous rule (NLA_U64)
  * @NFTA_RULE_USERDATA: user data (NLA_BINARY, NFT_USERDATA_MAXLEN)
+ * @NFTA_RULE_ID: uniquely identifies a rule in a transaction (NLA_U32)
  */
 enum nft_rule_attributes {
 	NFTA_RULE_UNSPEC,
@@ -218,6 +219,7 @@ enum nft_rule_attributes {
 	NFTA_RULE_POSITION,
 	NFTA_RULE_USERDATA,
 	NFTA_RULE_PAD,
+	NFTA_RULE_ID,
 	__NFTA_RULE_MAX
 };
 #define NFTA_RULE_MAX		(__NFTA_RULE_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 71c60a04b66b..6c782532615f 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -240,6 +240,10 @@ static struct nft_trans *nft_trans_rule_add(struct nft_ctx *ctx, int msg_type,
 	if (trans == NULL)
 		return NULL;
 
+	if (msg_type == NFT_MSG_NEWRULE && ctx->nla[NFTA_RULE_ID] != NULL) {
+		nft_trans_rule_id(trans) =
+			ntohl(nla_get_be32(ctx->nla[NFTA_RULE_ID]));
+	}
 	nft_trans_rule(trans) = rule;
 	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
 
@@ -2293,6 +2297,22 @@ static int nf_tables_newrule(struct net *net, struct sock *nlsk,
 	return err;
 }
 
+static struct nft_rule *nft_rule_lookup_byid(const struct net *net,
+					     const struct nlattr *nla)
+{
+	u32 id = ntohl(nla_get_be32(nla));
+	struct nft_trans *trans;
+
+	list_for_each_entry(trans, &net->nft.commit_list, list) {
+		struct nft_rule *rule = nft_trans_rule(trans);
+
+		if (trans->msg_type == NFT_MSG_NEWRULE &&
+		    id == nft_trans_rule_id(trans))
+			return rule;
+	}
+	return ERR_PTR(-ENOENT);
+}
+
 static int nf_tables_delrule(struct net *net, struct sock *nlsk,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
 			     const struct nlattr * const nla[])
@@ -2331,6 +2351,12 @@ static int nf_tables_delrule(struct net *net, struct sock *nlsk,
 				return PTR_ERR(rule);
 
 			err = nft_delrule(&ctx, rule);
+		} else if (nla[NFTA_RULE_ID]) {
+			rule = nft_rule_lookup_byid(net, nla[NFTA_RULE_ID]);
+			if (IS_ERR(rule))
+				return PTR_ERR(rule);
+
+			err = nft_delrule(&ctx, rule);
 		} else {
 			err = nft_delrule_by_chain(&ctx);
 		}
-- 
2.1.4
