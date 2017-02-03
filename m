From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/27] netfilter: nf_tables: Eliminate duplicated code in nf_tables_table_enable()
Date: Fri,  3 Feb 2017 13:25:29 +0100
Message-ID: <1486124738-3013-19-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59012 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753287AbdBCM2u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:50 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7951EC9EC4
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 67562DA808
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9B2FADA817
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:39 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feng <fgao@ikuai8.com>

If something fails in nf_tables_table_enable(), it unregisters the
chains. But the rollback code is the same as nf_tables_table_disable()
almostly, except there is one counter check.  Now create one wrapper
function to eliminate the duplicated codes.

Signed-off-by: Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 48 ++++++++++++++++++++++---------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 6e07c214c208..e6741ac4ccc1 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -576,6 +576,28 @@ static int nf_tables_gettable(struct net *net, struct sock *nlsk,
 	return err;
 }
 
+static void _nf_tables_table_disable(struct net *net,
+				     const struct nft_af_info *afi,
+				     struct nft_table *table,
+				     u32 cnt)
+{
+	struct nft_chain *chain;
+	u32 i = 0;
+
+	list_for_each_entry(chain, &table->chains, list) {
+		if (!nft_is_active_next(net, chain))
+			continue;
+		if (!(chain->flags & NFT_BASE_CHAIN))
+			continue;
+
+		if (cnt && i++ == cnt)
+			break;
+
+		nf_unregister_net_hooks(net, nft_base_chain(chain)->ops,
+					afi->nops);
+	}
+}
+
 static int nf_tables_table_enable(struct net *net,
 				  const struct nft_af_info *afi,
 				  struct nft_table *table)
@@ -598,18 +620,8 @@ static int nf_tables_table_enable(struct net *net,
 	}
 	return 0;
 err:
-	list_for_each_entry(chain, &table->chains, list) {
-		if (!nft_is_active_next(net, chain))
-			continue;
-		if (!(chain->flags & NFT_BASE_CHAIN))
-			continue;
-
-		if (i-- <= 0)
-			break;
-
-		nf_unregister_net_hooks(net, nft_base_chain(chain)->ops,
-					afi->nops);
-	}
+	if (i)
+		_nf_tables_table_disable(net, afi, table, i);
 	return err;
 }
 
@@ -617,17 +629,7 @@ static void nf_tables_table_disable(struct net *net,
 				    const struct nft_af_info *afi,
 				    struct nft_table *table)
 {
-	struct nft_chain *chain;
-
-	list_for_each_entry(chain, &table->chains, list) {
-		if (!nft_is_active_next(net, chain))
-			continue;
-		if (!(chain->flags & NFT_BASE_CHAIN))
-			continue;
-
-		nf_unregister_net_hooks(net, nft_base_chain(chain)->ops,
-					afi->nops);
-	}
+	_nf_tables_table_disable(net, afi, table, 0);
 }
 
 static int nf_tables_updtable(struct nft_ctx *ctx)
-- 
2.1.4
