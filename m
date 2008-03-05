From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/9][NETNS][IPV6] Move sysctl initialization later on in the IPv6 init sequence
Date: Wed, 05 Mar 2008 18:56:50 +0100
Message-ID: <20080305180155.253450401@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:50842 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbYCESCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:00 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m25I1x0x076550
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:01:59 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I1xI32044122
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:01:59 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I1wRc018307
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:01:59 GMT
Content-Disposition: inline; filename=ipv6-move-sysctl-initialization-later.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves initialization of IPv6 sysctl stuff at the end of
IPv6 initialization.
This will be helpful for network namespaces where some sysctl entries
depend on per-namespace variables, that need to be allocated and 
initialized before they are referenced by sysctl.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/af_inet6.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

Index: net-2.6.26/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/af_inet6.c
+++ net-2.6.26/net/ipv6/af_inet6.c
@@ -934,12 +934,6 @@ static int __init inet6_init(void)
 	err = register_pernet_subsys(&inet6_net_ops);
 	if (err)
 		goto register_pernet_fail;
-
-#ifdef CONFIG_SYSCTL
-	err = ipv6_sysctl_register();
-	if (err)
-		goto sysctl_fail;
-#endif
 	err = icmpv6_init();
 	if (err)
 		goto icmp_fail;
@@ -1006,9 +1000,19 @@ static int __init inet6_init(void)
 	err = ipv6_packet_init();
 	if (err)
 		goto ipv6_packet_fail;
+
+#ifdef CONFIG_SYSCTL
+	err = ipv6_sysctl_register();
+	if (err)
+		goto sysctl_fail;
+#endif
 out:
 	return err;
 
+#ifdef CONFIG_SYSCTL
+sysctl_fail:
+	ipv6_packet_cleanup();
+#endif
 ipv6_packet_fail:
 	tcpv6_exit();
 tcpv6_fail:
@@ -1050,10 +1054,6 @@ igmp_fail:
 ndisc_fail:
 	icmpv6_cleanup();
 icmp_fail:
-#ifdef CONFIG_SYSCTL
-	ipv6_sysctl_unregister();
-sysctl_fail:
-#endif
 	unregister_pernet_subsys(&inet6_net_ops);
 register_pernet_fail:
 	cleanup_ipv6_mibs();
@@ -1083,6 +1083,9 @@ static void __exit inet6_exit(void)
 	/* Disallow any further netlink messages */
 	rtnl_unregister_all(PF_INET6);
 
+#ifdef CONFIG_SYSCTL
+	ipv6_sysctl_unregister();
+#endif
 	udpv6_exit();
 #ifdef CONFIG_IP_UDPLITE
 	udplitev6_exit();
@@ -1112,9 +1115,7 @@ static void __exit inet6_exit(void)
 	ndisc_cleanup();
 	icmpv6_cleanup();
 	rawv6_exit();
-#ifdef CONFIG_SYSCTL
-	ipv6_sysctl_unregister();
-#endif
+
 	unregister_pernet_subsys(&inet6_net_ops);
 	cleanup_ipv6_mibs();
 	proto_unregister(&rawv6_prot);

-- 
