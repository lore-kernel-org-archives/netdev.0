From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/9][NETNS][IPV6] make ipv6_sysctl_register to return a value
Date: Fri, 04 Jan 2008 12:12:27 +0100
Message-ID: <20080104111425.807489403@localhost.localdomain>
References: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:12772 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbYADLXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:23:15 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m04BNEYW226428
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:14 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BNEf25083358
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:14 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BMvmS027744
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:22:57 GMT
Content-Disposition: inline; filename=sysctl/ipv6-sysctl-register-return-value.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the function ipv6_sysctl_register to return a
value. The af_inet6 init function is now able to handle an error
and catch it from the initialization of the sysctl.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h         |    2 +-
 net/ipv6/af_inet6.c        |    5 ++++-
 net/ipv6/sysctl_net_ipv6.c |    6 +++++-
 3 files changed, 10 insertions(+), 3 deletions(-)

Index: net-2.6.25/include/net/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/ipv6.h
+++ net-2.6.25/include/net/ipv6.h
@@ -620,7 +620,7 @@ static inline int snmp6_unregister_dev(s
 extern ctl_table ipv6_route_table[];
 extern ctl_table ipv6_icmp_table[];
 
-extern void ipv6_sysctl_register(void);
+extern int ipv6_sysctl_register(void);
 extern void ipv6_sysctl_unregister(void);
 #endif
 
Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -783,7 +783,9 @@ static int __init inet6_init(void)
 	 */
 
 #ifdef CONFIG_SYSCTL
-	ipv6_sysctl_register();
+	err = ipv6_sysctl_register();
+	if (err)
+		goto sysctl_fail;
 #endif
 	err = icmpv6_init(&inet6_family_ops);
 	if (err)
@@ -897,6 +899,7 @@ ndisc_fail:
 icmp_fail:
 #ifdef CONFIG_SYSCTL
 	ipv6_sysctl_unregister();
+sysctl_fail:
 #endif
 	cleanup_ipv6_mibs();
 out_unregister_sock:
Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -90,9 +90,13 @@ static struct ctl_path ipv6_ctl_path[] =
 
 static struct ctl_table_header *ipv6_sysctl_header;
 
-void ipv6_sysctl_register(void)
+int ipv6_sysctl_register(void)
 {
 	ipv6_sysctl_header = register_sysctl_paths(ipv6_ctl_path, ipv6_table);
+	if (!ipv6_sysctl_header)
+		return -ENOMEM;
+
+	return 0;
 }
 
 void ipv6_sysctl_unregister(void)

-- 
