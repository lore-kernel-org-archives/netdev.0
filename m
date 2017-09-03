From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/47] netfilter: nf_tables: Allow set names of up to 255 chars
Date: Mon,  4 Sep 2017 00:27:17 +0200
Message-ID: <1504477667-12130-8-git-send-email-pablo@netfilter.org>
References: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51216 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753270AbdICW2R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:28:17 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B8C01190F62
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:27:49 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AA772B5026
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:27:49 +0200 (CEST)
In-Reply-To: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>

Same conversion as for table names, use NFT_NAME_MAXLEN as upper
boundary as well.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |  2 +-
 include/uapi/linux/netfilter/nf_tables.h |  2 +-
 net/netfilter/nf_tables_api.c            | 18 ++++++++++++++----
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index be1610162ee0..66ba62fa7d90 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -396,7 +396,7 @@ void nft_unregister_set(struct nft_set_type *type);
 struct nft_set {
 	struct list_head		list;
 	struct list_head		bindings;
-	char				name[NFT_SET_MAXNAMELEN];
+	char				*name;
 	u32				ktype;
 	u32				dtype;
 	u32				objtype;
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index d9c03a8608ee..b5e73e80b7b6 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -4,7 +4,7 @@
 #define NFT_NAME_MAXLEN		256
 #define NFT_TABLE_MAXNAMELEN	NFT_NAME_MAXLEN
 #define NFT_CHAIN_MAXNAMELEN	NFT_NAME_MAXLEN
-#define NFT_SET_MAXNAMELEN	32
+#define NFT_SET_MAXNAMELEN	NFT_NAME_MAXLEN
 #define NFT_OBJ_MAXNAMELEN	32
 #define NFT_USERDATA_MAXLEN	256
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 747499039709..e6a07f27b1a3 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2650,7 +2650,7 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 	unsigned long *inuse;
 	unsigned int n = 0, min = 0;
 
-	p = strnchr(name, NFT_SET_MAXNAMELEN, '%');
+	p = strchr(name, '%');
 	if (p != NULL) {
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
@@ -2681,7 +2681,10 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 		free_page((unsigned long)inuse);
 	}
 
-	snprintf(set->name, sizeof(set->name), name, min + n);
+	set->name = kasprintf(GFP_KERNEL, name, min + n);
+	if (!set->name)
+		return -ENOMEM;
+
 	list_for_each_entry(i, &ctx->table->sets, list) {
 		if (!nft_is_active_next(ctx->net, i))
 			continue;
@@ -2958,7 +2961,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 	struct nft_table *table;
 	struct nft_set *set;
 	struct nft_ctx ctx;
-	char name[NFT_SET_MAXNAMELEN];
+	char *name;
 	unsigned int size;
 	bool create;
 	u64 timeout;
@@ -3104,8 +3107,14 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 		goto err1;
 	}
 
-	nla_strlcpy(name, nla[NFTA_SET_NAME], sizeof(set->name));
+	name = nla_strdup(nla[NFTA_SET_NAME], GFP_KERNEL);
+	if (!name) {
+		err = -ENOMEM;
+		goto err2;
+	}
+
 	err = nf_tables_set_alloc_name(&ctx, set, name);
+	kfree(name);
 	if (err < 0)
 		goto err2;
 
@@ -3155,6 +3164,7 @@ static void nft_set_destroy(struct nft_set *set)
 {
 	set->ops->destroy(set);
 	module_put(set->ops->type->owner);
+	kfree(set->name);
 	kvfree(set);
 }
 
-- 
2.1.4
