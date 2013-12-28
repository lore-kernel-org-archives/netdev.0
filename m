From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/8] netfilter: nf_tables: fix dumping with large number of sets
Date: Sat, 28 Dec 2013 23:03:05 +0100
Message-ID: <1388268187-11569-7-git-send-email-pablo@netfilter.org>
References: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If not table name is specified, the dumping of the existing sets
may be incomplete with a sufficiently large number of sets and
tables. This patch fixes missing reset of the cursors after
finding the location of the last object that has been included
in the previous multi-part message.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index f93b7d0..d9fcd27 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2098,17 +2098,21 @@ static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff *skb,
 				   struct netlink_callback *cb)
 {
 	const struct nft_set *set;
-	unsigned int idx = 0, s_idx = cb->args[0];
+	unsigned int idx, s_idx = cb->args[0];
 	struct nft_table *table, *cur_table = (struct nft_table *)cb->args[2];
 
 	if (cb->args[1])
 		return skb->len;
 
 	list_for_each_entry(table, &ctx->afi->tables, list) {
-		if (cur_table && cur_table != table)
-			continue;
+		if (cur_table) {
+			if (cur_table != table)
+				continue;
 
+			cur_table = NULL;
+		}
 		ctx->table = table;
+		idx = 0;
 		list_for_each_entry(set, &ctx->table->sets, list) {
 			if (idx < s_idx)
 				goto cont;
-- 
1.7.10.4

