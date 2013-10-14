From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/17] netfilter: nf_tables: add support for dormant tables
Date: Mon, 14 Oct 2013 18:38:52 +0200
Message-ID: <1381768738-17739-12-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34784 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757257Ab3JNQjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:22 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows you to temporarily disable an entire table.
You can change the state of a dormant table via NFT_MSG_NEWTABLE
messages. Using this operation you can wake up a table, so their
chains are registered.

This provides atomicity at chain level. Thus, the rule-set of one
chain is applied at once, avoiding any possible intermediate state
in every chain. Still, the chains that belongs to a table are
registered consecutively. This also allows you to have inactive
tables in the kernel.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |   11 ++++
 net/netfilter/nf_tables_api.c            |   97 +++++++++++++++++++++++++++---
 2 files changed, 101 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 1563875..a9c4bce 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -97,13 +97,24 @@ enum nft_hook_attributes {
 #define NFTA_HOOK_MAX		(__NFTA_HOOK_MAX - 1)
 
 /**
+ * enum nft_table_flags - nf_tables table flags
+ *
+ * @NFT_TABLE_F_DORMANT: this table is not active
+ */
+enum nft_table_flags {
+	NFT_TABLE_F_DORMANT	= 0x1,
+};
+
+/**
  * enum nft_table_attributes - nf_tables table netlink attributes
  *
  * @NFTA_TABLE_NAME: name of the table (NLA_STRING)
+ * @NFTA_TABLE_FLAGS: bitmask of enum nft_table_flags (NLA_U32)
  */
 enum nft_table_attributes {
 	NFTA_TABLE_UNSPEC,
 	NFTA_TABLE_NAME,
+	NFTA_TABLE_FLAGS,
 	__NFTA_TABLE_MAX
 };
 #define NFTA_TABLE_MAX		(__NFTA_TABLE_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 61e017b..a4dd7ce 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -158,6 +158,7 @@ static int nf_tables_chain_type_lookup(const struct nft_af_info *afi,
 
 static const struct nla_policy nft_table_policy[NFTA_TABLE_MAX + 1] = {
 	[NFTA_TABLE_NAME]	= { .type = NLA_STRING },
+	[NFTA_TABLE_FLAGS]	= { .type = NLA_U32 },
 };
 
 static int nf_tables_fill_table_info(struct sk_buff *skb, u32 portid, u32 seq,
@@ -177,7 +178,8 @@ static int nf_tables_fill_table_info(struct sk_buff *skb, u32 portid, u32 seq,
 	nfmsg->version		= NFNETLINK_V0;
 	nfmsg->res_id		= 0;
 
-	if (nla_put_string(skb, NFTA_TABLE_NAME, table->name))
+	if (nla_put_string(skb, NFTA_TABLE_NAME, table->name) ||
+	    nla_put_be32(skb, NFTA_TABLE_FLAGS, htonl(table->flags)))
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
@@ -301,6 +303,74 @@ err:
 	return err;
 }
 
+static int nf_tables_table_enable(struct nft_table *table)
+{
+	struct nft_chain *chain;
+	int err, i = 0;
+
+	list_for_each_entry(chain, &table->chains, list) {
+		err = nf_register_hook(&nft_base_chain(chain)->ops);
+		if (err < 0)
+			goto err;
+
+		i++;
+	}
+	return 0;
+err:
+	list_for_each_entry(chain, &table->chains, list) {
+		if (i-- <= 0)
+			break;
+
+		nf_unregister_hook(&nft_base_chain(chain)->ops);
+	}
+	return err;
+}
+
+static int nf_tables_table_disable(struct nft_table *table)
+{
+	struct nft_chain *chain;
+
+	list_for_each_entry(chain, &table->chains, list)
+		nf_unregister_hook(&nft_base_chain(chain)->ops);
+
+	return 0;
+}
+
+static int nf_tables_updtable(struct sock *nlsk, struct sk_buff *skb,
+			      const struct nlmsghdr *nlh,
+			      const struct nlattr * const nla[],
+			      struct nft_af_info *afi, struct nft_table *table)
+{
+	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
+	int family = nfmsg->nfgen_family, ret = 0;
+
+	if (nla[NFTA_TABLE_FLAGS]) {
+		__be32 flags;
+
+		flags = ntohl(nla_get_be32(nla[NFTA_TABLE_FLAGS]));
+		if (flags & ~NFT_TABLE_F_DORMANT)
+			return -EINVAL;
+
+		if ((flags & NFT_TABLE_F_DORMANT) &&
+		    !(table->flags & NFT_TABLE_F_DORMANT)) {
+			ret = nf_tables_table_disable(table);
+			if (ret >= 0)
+				table->flags |= NFT_TABLE_F_DORMANT;
+		} else if (!(flags & NFT_TABLE_F_DORMANT) &&
+			   table->flags & NFT_TABLE_F_DORMANT) {
+			ret = nf_tables_table_enable(table);
+			if (ret >= 0)
+				table->flags &= ~NFT_TABLE_F_DORMANT;
+		}
+		if (ret < 0)
+			goto err;
+	}
+
+	nf_tables_table_notify(skb, nlh, table, NFT_MSG_NEWTABLE, family);
+err:
+	return ret;
+}
+
 static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
 			      const struct nlattr * const nla[])
@@ -328,7 +398,7 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 			return -EEXIST;
 		if (nlh->nlmsg_flags & NLM_F_REPLACE)
 			return -EOPNOTSUPP;
-		return 0;
+		return nf_tables_updtable(nlsk, skb, nlh, nla, afi, table);
 	}
 
 	table = kzalloc(sizeof(*table) + nla_len(name), GFP_KERNEL);
@@ -339,6 +409,18 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	INIT_LIST_HEAD(&table->chains);
 	INIT_LIST_HEAD(&table->sets);
 
+	if (nla[NFTA_TABLE_FLAGS]) {
+		__be32 flags;
+
+		flags = ntohl(nla_get_be32(nla[NFTA_TABLE_FLAGS]));
+		if (flags & ~NFT_TABLE_F_DORMANT) {
+			kfree(table);
+			return -EINVAL;
+		}
+
+		table->flags |= flags;
+	}
+
 	list_add_tail(&table->list, &afi->tables);
 	nf_tables_table_notify(skb, nlh, table, NFT_MSG_NEWTABLE, family);
 	return 0;
@@ -890,10 +972,8 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	chain->handle = nf_tables_alloc_handle(table);
 	nla_strlcpy(chain->name, name, NFT_CHAIN_MAXNAMELEN);
 
-	list_add_tail(&chain->list, &table->chains);
-	table->use++;
-
-	if (chain->flags & NFT_BASE_CHAIN) {
+	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
+	    chain->flags & NFT_BASE_CHAIN) {
 		err = nf_register_hook(&nft_base_chain(chain)->ops);
 		if (err < 0) {
 			free_percpu(basechain->stats);
@@ -901,6 +981,8 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			return err;
 		}
 	}
+	list_add_tail(&chain->list, &table->chains);
+	table->use++;
 notify:
 	nf_tables_chain_notify(skb, nlh, table, chain, NFT_MSG_NEWCHAIN,
 			       family);
@@ -948,7 +1030,8 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 	list_del(&chain->list);
 	table->use--;
 
-	if (chain->flags & NFT_BASE_CHAIN)
+	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
+	    chain->flags & NFT_BASE_CHAIN)
 		nf_unregister_hook(&nft_base_chain(chain)->ops);
 
 	nf_tables_chain_notify(skb, nlh, table, chain, NFT_MSG_DELCHAIN,
-- 
1.7.10.4
