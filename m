From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25 04/10][NETNS][IPV6] make the ipv6 sysctl to be a netns subsystem
Date: Wed, 09 Jan 2008 17:45:37 +0100
Message-ID: <20080109165028.062837076@localhost.localdomain>
References: <20080109164533.695191040@localhost.localdomain>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:26479 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbYAIRA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 12:00:28 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m09H0R9U232354
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:00:27 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09H0RjP4046872
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:00:27 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09H0B7Z025400
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:00:11 GMT
Content-Disposition: inline; filename=sysctl/make-ipv6-sysctl-to-be-a-subsystem.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The initialization of the sysctl for the ipv6 protocol is changed to
a network namespace subsystem. That means when a new network namespace
is created the initialization function for the sysctl will be called.

That do not change the behavior of the sysctl in case of the kernel
with the network namespace disabled.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/sysctl_net_ipv6.c |   23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -91,10 +91,10 @@ EXPORT_SYMBOL_GPL(net_ipv6_ctl_path);
 
 static struct ctl_table_header *ipv6_sysctl_header;
 
-int ipv6_sysctl_register(void)
+static int ipv6_sysctl_net_init(struct net *net)
 {
-	ipv6_sysctl_header = register_sysctl_paths(net_ipv6_ctl_path,
-						   ipv6_table);
+	ipv6_sysctl_header = register_net_sysctl_table(net, net_ipv6_ctl_path,
+						       ipv6_table);
 	if (!ipv6_sysctl_header)
 		return -ENOMEM;
 
@@ -102,7 +102,22 @@ int ipv6_sysctl_register(void)
 
 }
 
+static void ipv6_sysctl_net_exit(struct net *net)
+{
+	unregister_net_sysctl_table(ipv6_sysctl_header);
+}
+
+static struct pernet_operations ipv6_sysctl_net_ops = {
+	.init = ipv6_sysctl_net_init,
+	.exit = ipv6_sysctl_net_exit,
+};
+
+int ipv6_sysctl_register(void)
+{
+	return register_pernet_subsys(&ipv6_sysctl_net_ops);
+}
+
 void ipv6_sysctl_unregister(void)
 {
-	unregister_sysctl_table(ipv6_sysctl_header);
+	unregister_pernet_subsys(&ipv6_sysctl_net_ops);
 }

-- 
