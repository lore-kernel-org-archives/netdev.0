From: Shen Feng <shen@cn.fujitsu.com>
Subject: [PATCH] IPv4/IPv6: update sysctl files
Date: Wed, 08 Apr 2009 10:17:00 +0800
Message-ID: <49DC091C.6070708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52832 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757150AbZDHCRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 22:17:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now the following sysctl files in /proc/sys/net/ipv4 are used by
both IPv4 and IPv6.
tcp_mem  tcp_rmem  tcp_wmem
udp_mem  udp_rmem_min  udp_wmem_min
Putting them in /proc/sys/net/ipv4 is not a good choice.

So move tcp_mem  tcp_rmem  tcp_wmem to /proc/sys/net/tcp and
move udp_mem  udp_rmem_min  udp_wmem_min to /poc/sys/net/udp.

Signed-off-by: Shen Feng <shen@cn.fujitsu.com>
---
 net/ipv4/sysctl_net_ipv4.c |   95 ++++++++++++++++++++++++++++++-------------
 1 files changed, 66 insertions(+), 29 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 4710d21..a520011 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -503,30 +503,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_MEM,
-		.procname	= "tcp_mem",
-		.data		= &sysctl_tcp_mem,
-		.maxlen		= sizeof(sysctl_tcp_mem),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
-		.ctl_name	= NET_TCP_WMEM,
-		.procname	= "tcp_wmem",
-		.data		= &sysctl_tcp_wmem,
-		.maxlen		= sizeof(sysctl_tcp_wmem),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
-		.ctl_name	= NET_TCP_RMEM,
-		.procname	= "tcp_rmem",
-		.data		= &sysctl_tcp_rmem,
-		.maxlen		= sizeof(sysctl_tcp_rmem),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.ctl_name	= NET_TCP_APP_WIN,
 		.procname	= "tcp_app_win",
 		.data		= &sysctl_tcp_app_win,
@@ -712,6 +688,38 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{ .ctl_name = 0 }
+};
+
+static struct ctl_table proc_tcp_table[] = {
+	{
+		.ctl_name	= NET_TCP_MEM,
+		.procname	= "tcp_mem",
+		.data		= &sysctl_tcp_mem,
+		.maxlen		= sizeof(sysctl_tcp_mem),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.ctl_name	= NET_TCP_WMEM,
+		.procname	= "tcp_wmem",
+		.data		= &sysctl_tcp_wmem,
+		.maxlen		= sizeof(sysctl_tcp_wmem),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.ctl_name	= NET_TCP_RMEM,
+		.procname	= "tcp_rmem",
+		.data		= &sysctl_tcp_rmem,
+		.maxlen		= sizeof(sysctl_tcp_rmem),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{},
+};
+
+static struct ctl_table proc_udp_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_mem",
@@ -742,7 +750,7 @@ static struct ctl_table ipv4_table[] = {
 		.strategy	= sysctl_intvec,
 		.extra1		= &zero
 	},
-	{ .ctl_name = 0 }
+	{},
 };
 
 static struct ctl_table ipv4_net_table[] = {
@@ -813,6 +821,20 @@ struct ctl_path net_ipv4_ctl_path[] = {
 };
 EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
 
+struct ctl_path net_tcp_ctl_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "tcp", .ctl_name = CTL_UNNUMBERED, },
+	{},
+};
+EXPORT_SYMBOL_GPL(net_tcp_ctl_path);
+
+struct ctl_path net_udp_ctl_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "udp", .ctl_name = CTL_UNNUMBERED, },
+	{},
+};
+EXPORT_SYMBOL_GPL(net_udp_ctl_path);
+
 static __net_init int ipv4_sysctl_init_net(struct net *net)
 {
 	struct ctl_table *table;
@@ -871,14 +893,29 @@ static __net_initdata struct pernet_operations ipv4_sysctl_ops = {
 
 static __init int sysctl_ipv4_init(void)
 {
-	struct ctl_table_header *hdr;
+	struct ctl_table_header *hdr_ipv4, *hdr_tcp, *hdr_udp;
+
+	hdr_ipv4 = register_sysctl_paths(net_ipv4_ctl_path, ipv4_table);
+	if (hdr_ipv4 == NULL)
+		return -ENOMEM;
 
-	hdr = register_sysctl_paths(net_ipv4_ctl_path, ipv4_table);
-	if (hdr == NULL)
+	hdr_tcp = register_sysctl_paths(net_tcp_ctl_path, proc_tcp_table);
+	if (hdr_tcp == NULL) {
+		unregister_sysctl_table(hdr_ipv4);
 		return -ENOMEM;
+	}
+
+	hdr_udp = register_sysctl_paths(net_udp_ctl_path, proc_udp_table);
+	if (hdr_udp == NULL) {
+		unregister_sysctl_table(hdr_ipv4);
+		unregister_sysctl_table(hdr_tcp);
+		return -ENOMEM;
+	}
 
 	if (register_pernet_subsys(&ipv4_sysctl_ops)) {
-		unregister_sysctl_table(hdr);
+		unregister_sysctl_table(hdr_ipv4);
+		unregister_sysctl_table(hdr_tcp);
+		unregister_sysctl_table(hdr_udp);
 		return -ENOMEM;
 	}
 
-- 
1.6.0.6


