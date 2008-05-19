From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 2/6][NETNS]: Register net/core/ sysctls at read-only
 root.
Date: Mon, 19 May 2008 19:55:01 +0400
Message-ID: <4831A2D5.8060503@openvz.org>
References: <4831A1D6.4090503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33867 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756720AbYESP51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 11:57:27 -0400
In-Reply-To: <4831A1D6.4090503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the net/core/xxx sysctls are read-only now, but this
goal is achieved with excessive memory consumption in each
namespace - the whole table is cloned and most of the entries
in it are ~= 0222.

Split it into two parts and register (the largest) one at the
read-only root.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/core/sysctl_net_core.c |   39 +++++++++++++++++++--------------------
 1 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 5fc8010..a570e2a 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -125,14 +125,6 @@ static struct ctl_table net_core_table[] = {
 #endif /* CONFIG_XFRM */
 #endif /* CONFIG_NET */
 	{
-		.ctl_name	= NET_CORE_SOMAXCONN,
-		.procname	= "somaxconn",
-		.data		= &init_net.core.sysctl_somaxconn,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-	{
 		.ctl_name	= NET_CORE_BUDGET,
 		.procname	= "netdev_budget",
 		.data		= &netdev_budget,
@@ -151,6 +143,18 @@ static struct ctl_table net_core_table[] = {
 	{ .ctl_name = 0 }
 };
 
+static struct ctl_table netns_core_table[] = {
+	{
+		.ctl_name	= NET_CORE_SOMAXCONN,
+		.procname	= "somaxconn",
+		.data		= &init_net.core.sysctl_somaxconn,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+	{ .ctl_name = 0 }
+};
+
 static __net_initdata struct ctl_path net_core_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
 	{ .procname = "core", .ctl_name = NET_CORE, },
@@ -159,23 +163,17 @@ static __net_initdata struct ctl_path net_core_path[] = {
 
 static __net_init int sysctl_core_net_init(struct net *net)
 {
-	struct ctl_table *tbl, *tmp;
+	struct ctl_table *tbl;
 
 	net->core.sysctl_somaxconn = SOMAXCONN;
 
-	tbl = net_core_table;
+	tbl = netns_core_table;
 	if (net != &init_net) {
-		tbl = kmemdup(tbl, sizeof(net_core_table), GFP_KERNEL);
+		tbl = kmemdup(tbl, sizeof(netns_core_table), GFP_KERNEL);
 		if (tbl == NULL)
 			goto err_dup;
 
-		for (tmp = tbl; tmp->procname; tmp++) {
-			if (tmp->data >= (void *)&init_net &&
-					tmp->data < (void *)(&init_net + 1))
-				tmp->data += (char *)net - (char *)&init_net;
-			else
-				tmp->mode &= ~0222;
-		}
+		tbl[0].data = &net->core.sysctl_somaxconn;
 	}
 
 	net->core.sysctl_hdr = register_net_sysctl_table(net,
@@ -186,7 +184,7 @@ static __net_init int sysctl_core_net_init(struct net *net)
 	return 0;
 
 err_reg:
-	if (tbl != net_core_table)
+	if (tbl != netns_core_table)
 		kfree(tbl);
 err_dup:
 	return -ENOMEM;
@@ -198,7 +196,7 @@ static __net_exit void sysctl_core_net_exit(struct net *net)
 
 	tbl = net->core.sysctl_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->core.sysctl_hdr);
-	BUG_ON(tbl == net_core_table);
+	BUG_ON(tbl == netns_core_table);
 	kfree(tbl);
 }
 
@@ -209,6 +207,7 @@ static __net_initdata struct pernet_operations sysctl_core_ops = {
 
 static __init int sysctl_core_init(void)
 {
+	register_net_sysctl_rotable(net_core_path, net_core_table);
 	return register_pernet_subsys(&sysctl_core_ops);
 }
 
-- 
1.5.3.4

