From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/47] netfilter: nf_tables: Allow table names of up to 255 chars
Date: Mon,  4 Sep 2017 00:27:15 +0200
Message-ID: <1504477667-12130-6-git-send-email-pablo@netfilter.org>
References: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51182 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753182AbdICW2N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:28:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id EFF45190F63
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:27:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DE7C82DC8A
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:27:45 +0200 (CEST)
In-Reply-To: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>

Allocate all table names dynamically to allow for arbitrary lengths but
introduce NFT_NAME_MAXLEN as an upper sanity boundary. It's value was
chosen to allow using a domain name as per RFC 1035.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |  2 +-
 include/uapi/linux/netfilter/nf_tables.h |  3 +-
 net/netfilter/nf_tables_api.c            | 49 +++++++++++++++++++++++---------
 net/netfilter/nf_tables_trace.c          |  2 +-
 4 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index bd5be0d691d5..05ecf78ec078 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -957,7 +957,7 @@ struct nft_table {
 	u32				use;
 	u16				flags:14,
 					genmask:2;
-	char				name[NFT_TABLE_MAXNAMELEN];
+	char				*name;
 };
 
 enum nft_af_flags {
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 6f0a950e21c3..0b94e572ef16 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1,7 +1,8 @@
 #ifndef _LINUX_NF_TABLES_H
 #define _LINUX_NF_TABLES_H
 
-#define NFT_TABLE_MAXNAMELEN	32
+#define NFT_NAME_MAXLEN		256
+#define NFT_TABLE_MAXNAMELEN	NFT_NAME_MAXLEN
 #define NFT_CHAIN_MAXNAMELEN	32
 #define NFT_SET_MAXNAMELEN	32
 #define NFT_OBJ_MAXNAMELEN	32
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b77ad0813564..c2e392d5e512 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -726,7 +726,10 @@ static int nf_tables_newtable(struct net *net, struct sock *nlsk,
 	if (table == NULL)
 		goto err2;
 
-	nla_strlcpy(table->name, name, NFT_TABLE_MAXNAMELEN);
+	table->name = nla_strdup(name, GFP_KERNEL);
+	if (table->name == NULL)
+		goto err3;
+
 	INIT_LIST_HEAD(&table->chains);
 	INIT_LIST_HEAD(&table->sets);
 	INIT_LIST_HEAD(&table->objects);
@@ -735,10 +738,12 @@ static int nf_tables_newtable(struct net *net, struct sock *nlsk,
 	nft_ctx_init(&ctx, net, skb, nlh, afi, table, NULL, nla);
 	err = nft_trans_table_add(&ctx, NFT_MSG_NEWTABLE);
 	if (err < 0)
-		goto err3;
+		goto err4;
 
 	list_add_tail_rcu(&table->list, &afi->tables);
 	return 0;
+err4:
+	kfree(table->name);
 err3:
 	kfree(table);
 err2:
@@ -865,6 +870,7 @@ static void nf_tables_table_destroy(struct nft_ctx *ctx)
 {
 	BUG_ON(ctx->table->use > 0);
 
+	kfree(ctx->table->name);
 	kfree(ctx->table);
 	module_put(ctx->afi->owner);
 }
@@ -1972,7 +1978,7 @@ static void nf_tables_rule_notify(const struct nft_ctx *ctx,
 }
 
 struct nft_rule_dump_ctx {
-	char table[NFT_TABLE_MAXNAMELEN];
+	char *table;
 	char chain[NFT_CHAIN_MAXNAMELEN];
 };
 
@@ -1997,7 +2003,7 @@ static int nf_tables_dump_rules(struct sk_buff *skb,
 			continue;
 
 		list_for_each_entry_rcu(table, &afi->tables, list) {
-			if (ctx && ctx->table[0] &&
+			if (ctx && ctx->table &&
 			    strcmp(ctx->table, table->name) != 0)
 				continue;
 
@@ -2037,7 +2043,12 @@ static int nf_tables_dump_rules(struct sk_buff *skb,
 
 static int nf_tables_dump_rules_done(struct netlink_callback *cb)
 {
-	kfree(cb->data);
+	struct nft_rule_dump_ctx *ctx = cb->data;
+
+	if (ctx) {
+		kfree(ctx->table);
+		kfree(ctx);
+	}
 	return 0;
 }
 
@@ -2069,9 +2080,14 @@ static int nf_tables_getrule(struct net *net, struct sock *nlsk,
 			if (!ctx)
 				return -ENOMEM;
 
-			if (nla[NFTA_RULE_TABLE])
-				nla_strlcpy(ctx->table, nla[NFTA_RULE_TABLE],
-					    sizeof(ctx->table));
+			if (nla[NFTA_RULE_TABLE]) {
+				ctx->table = nla_strdup(nla[NFTA_RULE_TABLE],
+							GFP_KERNEL);
+				if (!ctx->table) {
+					kfree(ctx);
+					return -ENOMEM;
+				}
+			}
 			if (nla[NFTA_RULE_CHAIN])
 				nla_strlcpy(ctx->chain, nla[NFTA_RULE_CHAIN],
 					    sizeof(ctx->chain));
@@ -4410,7 +4426,7 @@ static int nf_tables_fill_obj_info(struct sk_buff *skb, struct net *net,
 }
 
 struct nft_obj_filter {
-	char		table[NFT_OBJ_MAXNAMELEN];
+	char		*table;
 	u32		type;
 };
 
@@ -4475,7 +4491,10 @@ static int nf_tables_dump_obj(struct sk_buff *skb, struct netlink_callback *cb)
 
 static int nf_tables_dump_obj_done(struct netlink_callback *cb)
 {
-	kfree(cb->data);
+	struct nft_obj_filter *filter = cb->data;
+
+	kfree(filter->table);
+	kfree(filter);
 
 	return 0;
 }
@@ -4489,9 +4508,13 @@ nft_obj_filter_alloc(const struct nlattr * const nla[])
 	if (!filter)
 		return ERR_PTR(-ENOMEM);
 
-	if (nla[NFTA_OBJ_TABLE])
-		nla_strlcpy(filter->table, nla[NFTA_OBJ_TABLE],
-			    NFT_TABLE_MAXNAMELEN);
+	if (nla[NFTA_OBJ_TABLE]) {
+		filter->table = nla_strdup(nla[NFTA_OBJ_TABLE], GFP_KERNEL);
+		if (!filter->table) {
+			kfree(filter);
+			return ERR_PTR(-ENOMEM);
+		}
+	}
 	if (nla[NFTA_OBJ_TYPE])
 		filter->type = ntohl(nla_get_be32(nla[NFTA_OBJ_TYPE]));
 
diff --git a/net/netfilter/nf_tables_trace.c b/net/netfilter/nf_tables_trace.c
index 0c3a0049e4aa..62787d985e9d 100644
--- a/net/netfilter/nf_tables_trace.c
+++ b/net/netfilter/nf_tables_trace.c
@@ -175,7 +175,7 @@ void nft_trace_notify(struct nft_traceinfo *info)
 		return;
 
 	size = nlmsg_total_size(sizeof(struct nfgenmsg)) +
-		nla_total_size(NFT_TABLE_MAXNAMELEN) +
+		nla_total_size(strlen(info->chain->table->name)) +
 		nla_total_size(NFT_CHAIN_MAXNAMELEN) +
 		nla_total_size_64bit(sizeof(__be64)) +	/* rule handle */
 		nla_total_size(sizeof(__be32)) +	/* trace type */
-- 
2.1.4
