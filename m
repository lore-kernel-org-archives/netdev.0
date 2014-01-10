From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/23] netfilter: nf_tables: take AF module reference when creating a table
Date: Fri, 10 Jan 2014 01:35:39 +0100
Message-ID: <1389314142-17969-21-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The table refers to data of the AF module, so we need to make sure the
module isn't unloaded while the table exists.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 88f9c94..c352614 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -430,9 +430,14 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 			return -EINVAL;
 	}
 
+	if (!try_module_get(afi->owner))
+		return -EAFNOSUPPORT;
+
 	table = kzalloc(sizeof(*table) + nla_len(name), GFP_KERNEL);
-	if (table == NULL)
+	if (table == NULL) {
+		module_put(afi->owner);
 		return -ENOMEM;
+	}
 
 	nla_strlcpy(table->name, name, nla_len(name));
 	INIT_LIST_HEAD(&table->chains);
@@ -468,6 +473,7 @@ static int nf_tables_deltable(struct sock *nlsk, struct sk_buff *skb,
 	list_del(&table->list);
 	nf_tables_table_notify(skb, nlh, table, NFT_MSG_DELTABLE, family);
 	kfree(table);
+	module_put(afi->owner);
 	return 0;
 }
 
-- 
1.7.10.4

