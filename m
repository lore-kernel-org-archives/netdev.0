From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 6/6][IPV6]: Register some net/ipv6/ core sysctls
 at read-only root.
Date: Mon, 19 May 2008 20:06:36 +0400
Message-ID: <4831A58C.8010401@openvz.org>
References: <4831A1D6.4090503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47380 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbYESQJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 12:09:03 -0400
In-Reply-To: <4831A1D6.4090503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some sysctls left to be switched to read-only,
but they are all in ipv6, so complete with them.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sysctl_net_ipv6.c |   29 ++++++++++++++++++++++-------
 1 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 3804dcb..5c99274 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -37,6 +37,10 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table ipv6_table[] = {
 	{
 		.ctl_name	= NET_IPV6_MLD_MAX_MSF,
 		.procname	= "mld_max_msf",
@@ -80,12 +84,6 @@ static int ipv6_sysctl_net_init(struct net *net)
 
 	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;
 
-	/* We don't want this value to be per namespace, it should be global
-	   to all namespaces, so make it read-only when we are not in the
-	   init network namespace */
-	if (net != &init_net)
-		ipv6_table[3].mode = 0444;
-
 	net->ipv6.sysctl.table = register_net_sysctl_table(net, net_ipv6_ctl_path,
 							   ipv6_table);
 	if (!net->ipv6.sysctl.table)
@@ -126,12 +124,29 @@ static struct pernet_operations ipv6_sysctl_net_ops = {
 	.exit = ipv6_sysctl_net_exit,
 };
 
+static struct ctl_table_header *ip6_header;
+
 int ipv6_sysctl_register(void)
 {
-	return register_pernet_subsys(&ipv6_sysctl_net_ops);
+	int err = -ENOMEM;;
+
+	ip6_header = register_net_sysctl_rotable(net_ipv6_ctl_path, ipv6_table);
+	if (ip6_header == NULL)
+		goto out;
+
+	err = register_pernet_subsys(&ipv6_sysctl_net_ops);
+	if (err)
+		goto err_pernet;
+out:
+	return err;
+
+err_pernet:
+	unregister_net_sysctl_table(ip6_header);
+	goto out;
 }
 
 void ipv6_sysctl_unregister(void)
 {
+	unregister_net_sysctl_table(ip6_header);
 	unregister_pernet_subsys(&ipv6_sysctl_net_ops);
 }
-- 
1.5.3.4

