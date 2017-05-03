From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/16] netfilter: x_tables: unlock on error in xt_find_table_lock()
Date: Wed,  3 May 2017 11:32:09 +0200
Message-ID: <1493803931-2837-15-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>

According to my static checker we should unlock here before the return.
That seems reasonable to me as well.

Fixes" b9e69e127397 ("netfilter: xtables: don't hook tables by default")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 14857afc9937..f134d384852f 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1051,8 +1051,10 @@ struct xt_table *xt_find_table_lock(struct net *net, u_int8_t af,
 	list_for_each_entry(t, &init_net.xt.tables[af], list) {
 		if (strcmp(t->name, name))
 			continue;
-		if (!try_module_get(t->me))
+		if (!try_module_get(t->me)) {
+			mutex_unlock(&xt[af].mutex);
 			return NULL;
+		}
 
 		mutex_unlock(&xt[af].mutex);
 		if (t->table_init(net) != 0) {
-- 
2.1.4

