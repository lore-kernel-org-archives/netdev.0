From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 5/5][SYSCTL]: Move some net.core sysctls to RO
 root.
Date: Tue, 19 Feb 2008 15:05:31 +0300
Message-ID: <47BAC60B.10505@openvz.org>
References: <47BAC38F.10100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53505 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbYBSMFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 07:05:38 -0500
In-Reply-To: <47BAC38F.10100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many tables in net/core/sysctl_net_core.c that are
to be read-only. Current implementation duplicates this array
for each namespace just to clear the "write" bits in the
permissions mask.

Keep the writable tables to per-net ctl root and move the others
to the read-only one. This saves some memory in run time and
removes the... ugly code, that prepared the tables.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/core/sysctl_net_core.c |   35 +++++++++++++++++------------------
 1 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 130338f..4e530ce 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -125,14 +125,6 @@ static struct ctl_table net_core_table[] = {
 #endif /* CONFIG_XFRM */
 #endif /* CONFIG_NET */
 	{
-		.ctl_name	= NET_CORE_SOMAXCONN,
-		.procname	= "somaxconn",
-		.data		= &init_net.sysctl_somaxconn,
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
+		.data		= &init_net.sysctl_somaxconn,
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
 
 	net->sysctl_somaxconn = SOMAXCONN;
 
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
+		tbl[0].data = &net->sysctl_somaxconn;
 	}
 
 	net->sysctl_core_hdr = register_net_sysctl_table(net,
@@ -209,6 +207,7 @@ static __net_initdata struct pernet_operations sysctl_core_ops = {
 
 static __init int sysctl_core_init(void)
 {
+	register_init_net_ctl_table(net_core_path, net_core_table);
 	return register_pernet_subsys(&sysctl_core_ops);
 }
 
-- 
1.5.3.4

