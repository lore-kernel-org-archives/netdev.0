From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 11/19] net ipv6: Don't use sysctl tables with .child entries.
Date: Thu, 19 Apr 2012 16:37:09 -0700
Message-ID: <m1ipgvfg4a.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58601 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050Ab2DSXdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:33:09 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The sysctl core no longer natively understands sysctl tables
with .child entries.

Split the ipv6_table to remove the .child entries.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/netns/ipv6.h   |    4 ++-
 net/ipv6/sysctl_net_ipv6.c |   47 +++++++++++++++++++++----------------------
 2 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 81abfcb..b42be53 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -12,7 +12,9 @@ struct ctl_table_header;
 
 struct netns_sysctl_ipv6 {
 #ifdef CONFIG_SYSCTL
-	struct ctl_table_header *table;
+	struct ctl_table_header *hdr;
+	struct ctl_table_header *route_hdr;
+	struct ctl_table_header *icmp_hdr;
 	struct ctl_table_header *frags_hdr;
 #endif
 	int bindv6only;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index cf1e96a..a52d820 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -18,18 +18,6 @@
 
 static ctl_table ipv6_table_template[] = {
 	{
-		.procname	= "route",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= ipv6_route_table_template
-	},
-	{
-		.procname	= "icmp",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= ipv6_icmp_table_template
-	},
-	{
 		.procname	= "bindv6only",
 		.data		= &init_net.ipv6.sysctl.bindv6only,
 		.maxlen		= sizeof(int),
@@ -69,28 +57,37 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 			     GFP_KERNEL);
 	if (!ipv6_table)
 		goto out;
+	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
 		goto out_ipv6_table;
-	ipv6_table[0].child = ipv6_route_table;
 
 	ipv6_icmp_table = ipv6_icmp_sysctl_init(net);
 	if (!ipv6_icmp_table)
 		goto out_ipv6_route_table;
-	ipv6_table[1].child = ipv6_icmp_table;
 
-	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;
-
-	net->ipv6.sysctl.table = register_net_sysctl_table(net, net_ipv6_ctl_path,
-							   ipv6_table);
-	if (!net->ipv6.sysctl.table)
+	net->ipv6.sysctl.hdr = register_net_sysctl(net, "net/ipv6", ipv6_table);
+	if (!net->ipv6.sysctl.hdr)
 		goto out_ipv6_icmp_table;
 
+	net->ipv6.sysctl.route_hdr =
+		register_net_sysctl(net, "net/ipv6/route", ipv6_route_table);
+	if (!net->ipv6.sysctl.route_hdr)
+		goto out_unregister_ipv6_table;
+
+	net->ipv6.sysctl.icmp_hdr =
+		register_net_sysctl(net, "net/ipv6/icmp", ipv6_icmp_table);
+	if (!net->ipv6.sysctl.icmp_hdr)
+		goto out_unregister_route_table;
+
 	err = 0;
 out:
 	return err;
-
+out_unregister_route_table:
+	unregister_net_sysctl_table(net->ipv6.sysctl.route_hdr);
+out_unregister_ipv6_table:
+	unregister_net_sysctl_table(net->ipv6.sysctl.hdr);
 out_ipv6_icmp_table:
 	kfree(ipv6_icmp_table);
 out_ipv6_route_table:
@@ -106,11 +103,13 @@ static void __net_exit ipv6_sysctl_net_exit(struct net *net)
 	struct ctl_table *ipv6_route_table;
 	struct ctl_table *ipv6_icmp_table;
 
-	ipv6_table = net->ipv6.sysctl.table->ctl_table_arg;
-	ipv6_route_table = ipv6_table[0].child;
-	ipv6_icmp_table = ipv6_table[1].child;
+	ipv6_table = net->ipv6.sysctl.hdr->ctl_table_arg;
+	ipv6_route_table = net->ipv6.sysctl.route_hdr->ctl_table_arg;
+	ipv6_icmp_table = net->ipv6.sysctl.icmp_hdr->ctl_table_arg;
 
-	unregister_net_sysctl_table(net->ipv6.sysctl.table);
+	unregister_net_sysctl_table(net->ipv6.sysctl.icmp_hdr);
+	unregister_net_sysctl_table(net->ipv6.sysctl.route_hdr);
+	unregister_net_sysctl_table(net->ipv6.sysctl.hdr);
 
 	kfree(ipv6_table);
 	kfree(ipv6_route_table);
-- 
1.7.2.5
