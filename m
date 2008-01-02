From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/9][NETNS][IPV6] make the ipv6 sysctl to be a netns subsystem
Date: Wed, 02 Jan 2008 13:25:50 +0100
Message-ID: <20080102122805.293889108@localhost.localdomain>
References: <20080102122548.629622062@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:33838 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbYABMgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 07:36:08 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m02Ca7ma513216
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 12:36:07 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m02Ca75V2908354
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 13:36:07 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m02Ca6E5003987
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 13:36:07 +0100
Content-Disposition: inline; filename=make-ipv6-sysctl-to-be-a-subsystem.patch
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
