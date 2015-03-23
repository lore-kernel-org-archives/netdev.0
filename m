From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] netfilter: nf_tables: consolidate error path of nf_tables_newtable()
Date: Mon, 23 Mar 2015 12:36:20 +0100
Message-ID: <1427110584-5190-5-git-send-email-pablo@netfilter.org>
References: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ea51833..a072d87 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -687,11 +687,10 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	if (!try_module_get(afi->owner))
 		return -EAFNOSUPPORT;
 
+	err = -ENOMEM;
 	table = kzalloc(sizeof(*table), GFP_KERNEL);
-	if (table == NULL) {
-		module_put(afi->owner);
-		return -ENOMEM;
-	}
+	if (table == NULL)
+		goto err1;
 
 	nla_strlcpy(table->name, name, NFT_TABLE_MAXNAMELEN);
 	INIT_LIST_HEAD(&table->chains);
@@ -700,13 +699,16 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 
 	nft_ctx_init(&ctx, skb, nlh, afi, table, NULL, nla);
 	err = nft_trans_table_add(&ctx, NFT_MSG_NEWTABLE);
-	if (err < 0) {
-		kfree(table);
-		module_put(afi->owner);
-		return err;
-	}
+	if (err < 0)
+		goto err2;
+
 	list_add_tail_rcu(&table->list, &afi->tables);
 	return 0;
+err2:
+	kfree(table);
+err1:
+	module_put(afi->owner);
+	return err;
 }
 
 static int nft_flush_table(struct nft_ctx *ctx)
-- 
1.7.10.4

