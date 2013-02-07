From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 01/10] netfilter: make /proc/net/netfilter pernet
Date: Thu, 7 Feb 2013 15:49:41 +0800
Message-ID: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lve-ke3WRBg/xIg@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now,only init net has directroy /proc/net/netfilter,
this patch make this proc dentry pernet.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/net/netns/x_tables.h |  3 +++
 net/netfilter/core.c         | 40 ++++++++++++++++++++++++++++++++++------
 2 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
index c24060e..aa6a545 100644
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -9,6 +9,9 @@ struct ebt_table;
 struct netns_xt {
 	struct list_head tables[NFPROTO_NUMPROTO];
 	bool notrack_deprecated_warning;
+#if defined CONFIG_PROC_FS
+	struct proc_dir_entry *proc_netfilter;
+#endif
 #if defined(CONFIG_BRIDGE_NF_EBTABLES) || \
     defined(CONFIG_BRIDGE_NF_EBTABLES_MODULE)
 	struct ebt_table *broute_table;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a9c488b..2038673 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -281,6 +281,35 @@ struct proc_dir_entry *proc_net_netfilter;
 EXPORT_SYMBOL(proc_net_netfilter);
 #endif
 
+static int __net_init netfilter_net_init(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	net->xt.proc_netfilter = proc_net_mkdir(net,
+						"netfilter",
+						net->proc_net);
+	if (net_eq(net, &init_net)) {
+		if (!net->xt.proc_netfilter)
+			panic("cannot create netfilter proc entry");
+		else
+			proc_net_netfilter = net->xt.proc_netfilter;
+	} else if (!net->xt.proc_netfilter) {
+		pr_err("cannot create netfilter proc entry");
+		return -EINVAL;
+	}
+#endif
+	return 0;
+}
+
+static void __net_exit netfilter_net_exit(struct net *net)
+{
+	remove_proc_entry("netfilter", net->proc_net);
+}
+
+static struct pernet_operations netfilter_net_ops = {
+	.init = netfilter_net_init,
+	.exit = netfilter_net_exit,
+};
+
 void __init netfilter_init(void)
 {
 	int i, h;
@@ -289,12 +318,11 @@ void __init netfilter_init(void)
 			INIT_LIST_HEAD(&nf_hooks[i][h]);
 	}
 
-#ifdef CONFIG_PROC_FS
-	proc_net_netfilter = proc_mkdir("netfilter", init_net.proc_net);
-	if (!proc_net_netfilter)
-		panic("cannot create netfilter proc entry");
-#endif
+	if (register_pernet_subsys(&netfilter_net_ops) < 0)
+		return;
 
-	if (netfilter_log_init() < 0)
+	if (netfilter_log_init() < 0) {
+		unregister_pernet_subsys(&netfilter_net_ops);
 		panic("cannot initialize nf_log");
+	}
 }
-- 
1.7.11.7
