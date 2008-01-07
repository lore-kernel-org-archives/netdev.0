From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH net-2.6.25][NETNS][IPV6] make a subsystem for af_inet6
Date: Mon, 07 Jan 2008 21:44:36 +0100
Message-ID: <47828F34.6020101@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070809070405030702060302"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:36514 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758350AbYAGUxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 15:53:41 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m07KremG124864
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:53:40 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m07KrecF3022954
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 21:53:40 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m07KrdY2028855
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 21:53:40 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070809070405030702060302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit







--------------070809070405030702060302
Content-Type: text/x-patch;
 name="make-af-inet6-a-subsystem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="make-af-inet6-a-subsystem.patch"

Subject: make a subsystem for af_inet6
From: Daniel Lezcano <dlezcano@fr.ibm.com>

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
 	ipv6_sysctl_register();
 #endif
@@ -898,6 +917,8 @@ icmp_fail:
 #ifdef CONFIG_SYSCTL
 	ipv6_sysctl_unregister();
 #endif
+	unregister_pernet_subsys(&inet6_net_ops);
+register_pernet_fail:
 	cleanup_ipv6_mibs();
 out_unregister_sock:
 	sock_unregister(PF_INET6);
@@ -953,6 +974,7 @@ static void __exit inet6_exit(void)
 #ifdef CONFIG_SYSCTL
 	ipv6_sysctl_unregister();
 #endif
+	unregister_pernet_subsys(&inet6_net_ops);
 	cleanup_ipv6_mibs();
 	proto_unregister(&rawv6_prot);
 	proto_unregister(&udplitev6_prot);

--------------070809070405030702060302--
