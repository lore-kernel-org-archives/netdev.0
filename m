From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/12] netfilter: nf_tables: limit maximum table name length to 32 bytes
Date: Mon,  9 Mar 2015 18:14:31 +0100
Message-ID: <1425921275-9171-9-git-send-email-pablo@netfilter.org>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47226 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545AbbCIRLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:11:09 -0400
In-Reply-To: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the same as we use for chain names, it should be enough.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |    2 +-
 include/uapi/linux/netfilter/nf_tables.h |    1 +
 net/netfilter/nf_tables_api.c            |    7 ++++---
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 04188b4..a143aca 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -535,7 +535,7 @@ struct nft_table {
 	u64				hgenerator;
 	u32				use;
 	u16				flags;
-	char				name[];
+	char				name[NFT_TABLE_MAXNAMELEN];
 };
 
 /**
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 832bc46..b978393 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_NF_TABLES_H
 #define _LINUX_NF_TABLES_H
 
+#define NFT_TABLE_MAXNAMELEN	32
 #define NFT_CHAIN_MAXNAMELEN	32
 #define NFT_USERDATA_MAXLEN	256
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 199fd0f..284b20c 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -401,7 +401,8 @@ nf_tables_chain_type_lookup(const struct nft_af_info *afi,
 }
 
 static const struct nla_policy nft_table_policy[NFTA_TABLE_MAX + 1] = {
-	[NFTA_TABLE_NAME]	= { .type = NLA_STRING },
+	[NFTA_TABLE_NAME]	= { .type = NLA_STRING,
+				    .len = NFT_TABLE_MAXNAMELEN - 1 },
 	[NFTA_TABLE_FLAGS]	= { .type = NLA_U32 },
 };
 
@@ -686,13 +687,13 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	if (!try_module_get(afi->owner))
 		return -EAFNOSUPPORT;
 
-	table = kzalloc(sizeof(*table) + nla_len(name), GFP_KERNEL);
+	table = kzalloc(sizeof(*table), GFP_KERNEL);
 	if (table == NULL) {
 		module_put(afi->owner);
 		return -ENOMEM;
 	}
 
-	nla_strlcpy(table->name, name, nla_len(name));
+	nla_strlcpy(table->name, name, NFT_TABLE_MAXNAMELEN);
 	INIT_LIST_HEAD(&table->chains);
 	INIT_LIST_HEAD(&table->sets);
 	table->flags = flags;
-- 
1.7.10.4
