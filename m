From: pablo@netfilter.org
Subject: [PATCH 11/12] netfilter: xt_hashlimit: fix namespace destroy path
Date: Fri, 28 Dec 2012 12:52:50 +0100
Message-ID: <1356695571-3305-12-git-send-email-pablo@netfilter.org>
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
 net/netfilter/xt_hashlimit.c |   29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index cc430f9..a9d7af9 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -329,7 +329,10 @@ static void htable_destroy(struct xt_hashlimit_htable *hinfo)
 		parent = hashlimit_net->ipt_hashlimit;
 	else
 		parent = hashlimit_net->ip6t_hashlimit;
-	remove_proc_entry(hinfo->pde->name, parent);
+
+	if(parent != NULL)
+		remove_proc_entry(hinfo->pde->name, parent);
+
 	htable_selective_cleanup(hinfo, select_all);
 	vfree(hinfo);
 }
@@ -873,6 +876,27 @@ static int __net_init hashlimit_proc_net_init(struct net *net)
 
 static void __net_exit hashlimit_proc_net_exit(struct net *net)
 {
+	struct xt_hashlimit_htable *hinfo;
+	struct hlist_node *pos;
+	struct proc_dir_entry *pde;
+	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
+
+	/* recent_net_exit() is called before recent_mt_destroy(). Make sure
+	 * that the parent xt_recent proc entry is is empty before trying to
+	 * remove it.
+	 */
+	mutex_lock(&hashlimit_mutex);
+	pde = hashlimit_net->ipt_hashlimit;
+	if (pde == NULL)
+		pde = hashlimit_net->ip6t_hashlimit;
+
+	hlist_for_each_entry(hinfo, pos, &hashlimit_net->htables, node)
+		remove_proc_entry(hinfo->pde->name, pde);
+
+	hashlimit_net->ipt_hashlimit = NULL;
+	hashlimit_net->ip6t_hashlimit = NULL;
+	mutex_unlock(&hashlimit_mutex);
+
 	proc_net_remove(net, "ipt_hashlimit");
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	proc_net_remove(net, "ip6t_hashlimit");
@@ -889,9 +913,6 @@ static int __net_init hashlimit_net_init(struct net *net)
 
 static void __net_exit hashlimit_net_exit(struct net *net)
 {
-	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
-
-	BUG_ON(!hlist_empty(&hashlimit_net->htables));
 	hashlimit_proc_net_exit(net);
 }
 
-- 
1.7.10.4

