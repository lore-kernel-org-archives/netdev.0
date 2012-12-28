From: pablo@netfilter.org
Subject: [PATCH 10/12] netfilter: xt_recent: fix namespace destroy path
Date: Fri, 28 Dec 2012 12:52:49 +0100
Message-ID: <1356695571-3305-11-git-send-email-pablo@netfilter.org>
References: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Vitaly E. Lavrov" <lve@guap.ru>

recent_net_exit() is called before recent_mt_destroy() in the
destroy path of network namespaces. Make sure there are no entries
in the parent proc entry xt_recent before removing it.

Signed-off-by: Vitaly E. Lavrov <lve@guap.ru>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_recent.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 4635c9b..dab053e 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -431,7 +431,8 @@ static void recent_mt_destroy(const struct xt_mtdtor_param *par)
 		list_del(&t->list);
 		spin_unlock_bh(&recent_lock);
 #ifdef CONFIG_PROC_FS
-		remove_proc_entry(t->name, recent_net->xt_recent);
+		if (recent_net->xt_recent != NULL)
+			remove_proc_entry(t->name, recent_net->xt_recent);
 #endif
 		recent_table_flush(t);
 		kfree(t);
@@ -615,6 +616,20 @@ static int __net_init recent_proc_net_init(struct net *net)
 
 static void __net_exit recent_proc_net_exit(struct net *net)
 {
+	struct recent_net *recent_net = recent_pernet(net);
+	struct recent_table *t;
+
+	/* recent_net_exit() is called before recent_mt_destroy(). Make sure
+	 * that the parent xt_recent proc entry is is empty before trying to
+	 * remove it.
+	 */
+	spin_lock_bh(&recent_lock);
+	list_for_each_entry(t, &recent_net->tables, list)
+	        remove_proc_entry(t->name, recent_net->xt_recent);
+
+	recent_net->xt_recent = NULL;
+	spin_unlock_bh(&recent_lock);
+
 	proc_net_remove(net, "xt_recent");
 }
 #else
@@ -638,9 +653,6 @@ static int __net_init recent_net_init(struct net *net)
 
 static void __net_exit recent_net_exit(struct net *net)
 {
-	struct recent_net *recent_net = recent_pernet(net);
-
-	BUG_ON(!list_empty(&recent_net->tables));
 	recent_proc_net_exit(net);
 }
 
-- 
1.7.10.4

