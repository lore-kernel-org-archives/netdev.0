From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25 02/10][NETNS][IPV6] make a subsystem for af_inet6
Date: Wed, 09 Jan 2008 17:45:35 +0100
Message-ID: <20080109165026.025193934@localhost.localdomain>
References: <20080109164533.695191040@localhost.localdomain>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:12981 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbYAIQ7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 11:59:53 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m09GxqHs087644
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 16:59:52 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09GxqRX2150584
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:59:52 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09Gxp7s021830
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:59:52 +0100
Content-Disposition: inline; filename=make-af-inet6-a-subsystem.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add a network namespace subsystem for the af_inet6 module. 
It does nothing right now, but one of its purpose is to receive the 
different variables for sysctl in order to initialize them.

When the sysctl variable will be moved to the network namespace structure,
they will be no longer initialized as global static variables, so we must
find a place to initialize them. Because the sysctl can be disabled, it 
has no sense to store them in the sysctl_net_ipv6 file.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/af_inet6.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -719,6 +719,21 @@ static void cleanup_ipv6_mibs(void)
 	snmp_mib_free((void **)udplite_stats_in6);
 }
 
+static int inet6_net_init(struct net *net)
+{
+	return 0;
+}
+
+static void inet6_net_exit(struct net *net)
+{
+	return;
+}
+
+static struct pernet_operations inet6_net_ops = {
+	.init = inet6_net_init,
+	.exit = inet6_net_exit,
+};
+
 static int __init inet6_init(void)
 {
 	struct sk_buff *dummy_skb;
@@ -782,6 +797,10 @@ static int __init inet6_init(void)
 	 *	able to communicate via both network protocols.
 	 */
 
+	err = register_pernet_subsys(&inet6_net_ops);
+	if (err)
+		goto register_pernet_fail;
+
 #ifdef CONFIG_SYSCTL
 	err = ipv6_sysctl_register();
 	if (err)
@@ -901,6 +920,8 @@ icmp_fail:
 	ipv6_sysctl_unregister();
 sysctl_fail:
 #endif
+	unregister_pernet_subsys(&inet6_net_ops);
+register_pernet_fail:
 	cleanup_ipv6_mibs();
 out_unregister_sock:
 	sock_unregister(PF_INET6);
@@ -956,6 +977,7 @@ static void __exit inet6_exit(void)
 #ifdef CONFIG_SYSCTL
 	ipv6_sysctl_unregister();
 #endif
+	unregister_pernet_subsys(&inet6_net_ops);
 	cleanup_ipv6_mibs();
 	proto_unregister(&rawv6_prot);
 	proto_unregister(&udplitev6_prot);

-- 
