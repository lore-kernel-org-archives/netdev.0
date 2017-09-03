From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/47] netfilter: nf_tables: Allow object names of up to 255 chars
Date: Mon,  4 Sep 2017 00:27:18 +0200
Message-ID: <1504477667-12130-9-git-send-email-pablo@netfilter.org>
References: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51220 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753182AbdICW2S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:28:18 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 58AC4190F63
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:27:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 47E30B5027
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:27:51 +0200 (CEST)
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
 net/netfilter/nf_tables_api.c            | 11 +++++++++--
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 66ba62fa7d90..f9795fe394f3 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -1016,7 +1016,7 @@ int nft_verdict_dump(struct sk_buff *skb, int type,
  */
 struct nft_object {
 	struct list_head		list;
-	char				name[NFT_OBJ_MAXNAMELEN];
+	char				*name;
 	struct nft_table		*table;
 	u32				genmask:2,
 					use:30;
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index b5e73e80b7b6..be25cf69295b 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -5,7 +5,7 @@
 #define NFT_TABLE_MAXNAMELEN	NFT_NAME_MAXLEN
 #define NFT_CHAIN_MAXNAMELEN	NFT_NAME_MAXLEN
 #define NFT_SET_MAXNAMELEN	NFT_NAME_MAXLEN
-#define NFT_OBJ_MAXNAMELEN	32
+#define NFT_OBJ_MAXNAMELEN	NFT_NAME_MAXLEN
 #define NFT_USERDATA_MAXLEN	256
 
 /**
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index e6a07f27b1a3..149785ff1c7b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4402,15 +4402,21 @@ static int nf_tables_newobj(struct net *net, struct sock *nlsk,
 		goto err1;
 	}
 	obj->table = table;
-	nla_strlcpy(obj->name, nla[NFTA_OBJ_NAME], NFT_OBJ_MAXNAMELEN);
+	obj->name = nla_strdup(nla[NFTA_OBJ_NAME], GFP_KERNEL);
+	if (!obj->name) {
+		err = -ENOMEM;
+		goto err2;
+	}
 
 	err = nft_trans_obj_add(&ctx, NFT_MSG_NEWOBJ, obj);
 	if (err < 0)
-		goto err2;
+		goto err3;
 
 	list_add_tail_rcu(&obj->list, &table->objects);
 	table->use++;
 	return 0;
+err3:
+	kfree(obj->name);
 err2:
 	if (obj->type->destroy)
 		obj->type->destroy(obj);
@@ -4626,6 +4632,7 @@ static void nft_obj_destroy(struct nft_object *obj)
 		obj->type->destroy(obj);
 
 	module_put(obj->type->owner);
+	kfree(obj->name);
 	kfree(obj);
 }
 
-- 
2.1.4
