From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 4/9][NETNS][IPV6] make multiple instance of sysctl tables
Date: Fri, 04 Jan 2008 12:12:30 +0100
Message-ID: <20080104111429.872434045@localhost.localdomain>
References: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:22384 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbYADLWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:22:52 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m04BMptq142134
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:22:51 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BMoOg2621678
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 12:22:50 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BMoWD010677
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 12:22:50 +0100
Content-Disposition: inline; filename=sysctl/make-ipv6-sysctl-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each network namespace wants its own set of sysctl value, eg. we should
not be able from a namespace to set a sysctl value for another namespace
, especially for the initial network namespace.

This patch duplicates the sysctl table when we register a new network
namespace for ipv6. The duplicated table are postfixed with the "template"
word to notify the developper the table is cloned.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h         |    4 +-
 include/net/netns/ipv6.h   |    9 ++++++
 net/ipv6/icmp.c            |   12 +++++++-
 net/ipv6/route.c           |   11 ++++++-
 net/ipv6/sysctl_net_ipv6.c |   67 +++++++++++++++++++++++++++++++++++++--------
 5 files changed, 88 insertions(+), 15 deletions(-)

Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -14,20 +14,23 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
-static ctl_table ipv6_table[] = {
+extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
+extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
+
+static ctl_table ipv6_table_template[] = {
 	{
 		.ctl_name	= NET_IPV6_ROUTE,
 		.procname	= "route",
 		.maxlen		= 0,
 		.mode		= 0555,
-		.child		= ipv6_route_table
+		.child		= ipv6_route_table_template
 	},
 	{
 		.ctl_name	= NET_IPV6_ICMP,
 		.procname	= "icmp",
 		.maxlen		= 0,
 		.mode		= 0555,
-		.child		= ipv6_icmp_table
+		.child		= ipv6_icmp_table_template
 	},
 	{
 		.ctl_name	= NET_IPV6_BINDV6ONLY,
@@ -88,20 +91,62 @@ static struct ctl_path ipv6_ctl_path[] =
 	{ },
 };
 
-static struct ctl_table_header *ipv6_sysctl_header;
-
 static int ipv6_sysctl_net_init(struct net *net)
 {
-	ipv6_sysctl_header = register_net_sysctl_table(net, ipv6_ctl_path, ipv6_table);
-	if (!ipv6_sysctl_header)
-		return -ENOMEM;
-
-	return 0;
+   	struct ctl_table *ipv6_table;
+   	struct ctl_table *ipv6_route_table;
+   	struct ctl_table *ipv6_icmp_table;
+   	int err;
+
+   	err = -ENOMEM;
+   	ipv6_table = kmemdup(ipv6_table_template, sizeof(ipv6_table_template),
+   			     GFP_KERNEL);
+   	if (!ipv6_table)
+   		goto out;
+
+	ipv6_route_table = ipv6_route_sysctl_init(net);
+	if (!ipv6_route_table)
+		goto out_ipv6_table;
+
+   	ipv6_icmp_table = ipv6_icmp_sysctl_init(net);
+   	if (!ipv6_icmp_table)
+   		goto out_ipv6_route_table;
+
+   	ipv6_table[0].child = ipv6_route_table;
+   	ipv6_table[1].child = ipv6_icmp_table;
+
+   	net->ipv6.sysctl.table = register_net_sysctl_table(net, ipv6_ctl_path, ipv6_table);
+   	if (!net->ipv6.sysctl.table)
+   		goto out_ipv6_icmp_table;
+
+   	err = 0;
+out:
+   	return err;
+
+out_ipv6_icmp_table:
+   	kfree(ipv6_icmp_table);
+out_ipv6_route_table:
+   	kfree(ipv6_route_table);
+out_ipv6_table:
+   	kfree(ipv6_table);
+   	goto out;
 }
 
 static void ipv6_sysctl_net_exit(struct net *net)
 {
-	unregister_net_sysctl_table(ipv6_sysctl_header);
+   	struct ctl_table *ipv6_table;
+   	struct ctl_table *ipv6_route_table;
+   	struct ctl_table *ipv6_icmp_table;
+
+   	ipv6_table = net->ipv6.sysctl.table->ctl_table_arg;
+   	ipv6_route_table = ipv6_table[0].child;
+   	ipv6_icmp_table = ipv6_table[1].child;
+
+   	unregister_net_sysctl_table(net->ipv6.sysctl.table);
+
+   	kfree(ipv6_table);
+   	kfree(ipv6_route_table);
+   	kfree(ipv6_icmp_table);
 }
 
 static struct pernet_operations ipv6_sysctl_net_ops = {
Index: net-2.6.25/include/net/netns/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/netns/ipv6.h
+++ net-2.6.25/include/net/netns/ipv6.h
@@ -5,6 +5,15 @@
 #ifndef __NETNS_IPV6_H__
 #define __NETNS_IPV6_H__
 
+struct ctl_table_header;
+
+struct netns_sysctl_ipv6 {
+	struct ctl_table_header *table;
+};
+
 struct netns_ipv6 {
+#ifdef CONFIG_SYSCTL
+	struct netns_sysctl_ipv6 sysctl;
+#endif
 };
 #endif
Index: net-2.6.25/include/net/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/ipv6.h
+++ net-2.6.25/include/net/ipv6.h
@@ -617,8 +617,8 @@ static inline int snmp6_unregister_dev(s
 #endif
 
 #ifdef CONFIG_SYSCTL
-extern ctl_table ipv6_route_table[];
-extern ctl_table ipv6_icmp_table[];
+extern ctl_table ipv6_route_table_template[];
+extern ctl_table ipv6_icmp_table_template[];
 
 extern int ipv6_sysctl_register(void);
 extern void ipv6_sysctl_unregister(void);
Index: net-2.6.25/net/ipv6/icmp.c
===================================================================
--- net-2.6.25.orig/net/ipv6/icmp.c
+++ net-2.6.25/net/ipv6/icmp.c
@@ -909,7 +909,7 @@ int icmpv6_err_convert(int type, int cod
 EXPORT_SYMBOL(icmpv6_err_convert);
 
 #ifdef CONFIG_SYSCTL
-ctl_table ipv6_icmp_table[] = {
+ctl_table ipv6_icmp_table_template[] = {
 	{
 		.ctl_name	= NET_IPV6_ICMP_RATELIMIT,
 		.procname	= "ratelimit",
@@ -920,5 +920,15 @@ ctl_table ipv6_icmp_table[] = {
 	},
 	{ .ctl_name = 0 },
 };
+
+struct ctl_table *ipv6_icmp_sysctl_init(struct net *net)
+{
+	struct ctl_table *table;
+
+   	table = kmemdup(ipv6_icmp_table_template,
+			sizeof(ipv6_icmp_table_template),
+			GFP_KERNEL);
+	return table;
+}
 #endif
 
Index: net-2.6.25/net/ipv6/route.c
===================================================================
--- net-2.6.25.orig/net/ipv6/route.c
+++ net-2.6.25/net/ipv6/route.c
@@ -2404,7 +2404,7 @@ int ipv6_sysctl_rtcache_flush(ctl_table 
 		return -EINVAL;
 }
 
-ctl_table ipv6_route_table[] = {
+ctl_table ipv6_route_table_template[] = {
 	{
 		.procname	=	"flush",
 		.data		=	&flush_delay,
@@ -2494,6 +2494,15 @@ ctl_table ipv6_route_table[] = {
 	{ .ctl_name = 0 }
 };
 
+struct ctl_table *ipv6_route_sysctl_init(struct net *net)
+{
+	struct ctl_table *table;
+
+   	table = kmemdup(ipv6_route_table_template,
+			sizeof(ipv6_route_table_template),
+			GFP_KERNEL);
+	return table;
+}
 #endif
 
 int __init ip6_route_init(void)

-- 
