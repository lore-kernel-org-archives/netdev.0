From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 5/9][NETNS][IPV6] make bindv6only sysctl per namespace
Date: Fri, 04 Jan 2008 12:12:31 +0100
Message-ID: <20080104111431.444295890@localhost.localdomain>
References: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:17037 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbYADLXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:23:12 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m04BNBV0540740
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:11 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BNBeO5058762
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:11 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BMssC027475
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:22:55 GMT
Content-Disposition: inline; filename=sysctl/move-bindv6only-to-netns.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the bindv6only sysctl to the network namespace
structure. Until the ipv6 protocol is not per namespace, the sysctl
variable is always from the initial network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h         |    1 -
 include/net/netns/ipv6.h   |    1 +
 net/ipv6/af_inet6.c        |    4 +---
 net/ipv6/sysctl_net_ipv6.c |    6 +++++-
 4 files changed, 7 insertions(+), 5 deletions(-)

Index: net-2.6.25/include/net/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/ipv6.h
+++ net-2.6.25/include/net/ipv6.h
@@ -109,7 +109,6 @@ struct frag_hdr {
 #include <net/sock.h>
 
 /* sysctls */
-extern int sysctl_ipv6_bindv6only;
 extern int sysctl_mld_max_msf;
 
 #define _DEVINC(statname, modifier, idev, field)			\
Index: net-2.6.25/include/net/netns/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/netns/ipv6.h
+++ net-2.6.25/include/net/netns/ipv6.h
@@ -9,6 +9,7 @@ struct ctl_table_header;
 
 struct netns_sysctl_ipv6 {
 	struct ctl_table_header *table;
+ 	int bindv6only;
 };
 
 struct netns_ipv6 {
Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -66,8 +66,6 @@ MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
 MODULE_LICENSE("GPL");
 
-int sysctl_ipv6_bindv6only __read_mostly;
-
 /* The inetsw6 table contains everything that inet6_create needs to
  * build a new socket.
  */
@@ -193,7 +191,7 @@ lookup_protocol:
 	np->mcast_hops	= -1;
 	np->mc_loop	= 1;
 	np->pmtudisc	= IPV6_PMTUDISC_WANT;
-	np->ipv6only	= sysctl_ipv6_bindv6only;
+	np->ipv6only	= init_net.ipv6.sysctl.bindv6only;
 
 	/* Init the ipv4 part of the socket since we can have sockets
 	 * using v6 API for ipv4.
Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -35,7 +35,7 @@ static ctl_table ipv6_table_template[] =
 	{
 		.ctl_name	= NET_IPV6_BINDV6ONLY,
 		.procname	= "bindv6only",
-		.data		= &sysctl_ipv6_bindv6only,
+		.data		= &init_net.ipv6.sysctl.bindv6only,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
@@ -115,6 +115,10 @@ static int ipv6_sysctl_net_init(struct n
    	ipv6_table[0].child = ipv6_route_table;
    	ipv6_table[1].child = ipv6_icmp_table;
 
+  	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;
+
+	net->ipv6.sysctl.bindv6only = 0;
+
    	net->ipv6.sysctl.table = register_net_sysctl_table(net, ipv6_ctl_path, ipv6_table);
    	if (!net->ipv6.sysctl.table)
    		goto out_ipv6_icmp_table;

-- 
