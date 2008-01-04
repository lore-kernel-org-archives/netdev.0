From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/9][NETNS][IPV6] make the ipv6 sysctl to be a netns subsystem
Date: Fri, 04 Jan 2008 12:12:28 +0100
Message-ID: <20080104111427.232574214@localhost.localdomain>
References: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:17042 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbYADLXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:23:16 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m04BNFMT516326
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:15 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BNFqC4739188
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:15 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BMwct018349
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:22:58 GMT
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
 net/ipv6/sysctl_net_ipv6.c |   21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -90,16 +90,31 @@ static struct ctl_path ipv6_ctl_path[] =
 
 static struct ctl_table_header *ipv6_sysctl_header;
 
-int ipv6_sysctl_register(void)
+static int ipv6_sysctl_net_init(struct net *net)
 {
-	ipv6_sysctl_header = register_sysctl_paths(ipv6_ctl_path, ipv6_table);
+	ipv6_sysctl_header = register_net_sysctl_table(net, ipv6_ctl_path, ipv6_table);
 	if (!ipv6_sysctl_header)
 		return -ENOMEM;
 
 	return 0;
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
