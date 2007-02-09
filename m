From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH] [ipv6]: adjust inet6_exit() cleanup sequence against inet6_init()
Date: Fri, 9 Feb 2007 17:34:24 +0800
Message-ID: <20070209093424.GA7078@joejin-pc.cn.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	joe.jin@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30732 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946269AbXBIJgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 04:36:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch for adjust inet6_exit() to inverse sequence to inet6_init().

At ipv6_init, it first create proc_root/net/dev_snmp6 entry by call
ipv6_misc_proc_init(), then call addrconf_init() to create the corresponding
device entry at this directory, but at inet6_exit, ipv6_misc_proc_exit()
called first, then call addrconf_init().

Signed-off-by: Joe Jin <joe.jin@oracle.com>

--- linux-2.6.20/net/ipv6/af_inet6.c.orig	2007-02-09 14:05:10.000000000 +0800
+++ linux-2.6.20/net/ipv6/af_inet6.c	2007-02-09 14:21:54.000000000 +0800
@@ -930,25 +930,28 @@
 {
 	/* First of all disallow new sockets creation. */
 	sock_unregister(PF_INET6);
-#ifdef CONFIG_PROC_FS
-	if6_proc_exit();
-	ac6_proc_exit();
- 	ipv6_misc_proc_exit();
- 	udp6_proc_exit();
- 	udplite6_proc_exit();
- 	tcp6_proc_exit();
- 	raw6_proc_exit();
-#endif
+	
+	/* Cleanup code parts. */
+	ipv6_packet_cleanup();
 #ifdef CONFIG_IPV6_MIP6
 	mip6_fini();
 #endif
-	/* Cleanup code parts. */
-	ip6_flowlabel_cleanup();
 	addrconf_cleanup();
+	ip6_flowlabel_cleanup();
 	ip6_route_cleanup();
-	ipv6_packet_cleanup();
-	igmp6_cleanup();
+#ifdef CONFIG_PROC_FS
+
+	/* Cleanup code parts. */
+	if6_proc_exit();
+	ac6_proc_exit();
+	ipv6_misc_proc_exit();
+	udplite6_proc_exit();
+	udp6_proc_exit();
+	tcp6_proc_exit();
+	raw6_proc_exit();
+#endif
 	ipv6_netfilter_fini();
+	igmp6_cleanup();
 	ndisc_cleanup();
 	icmpv6_cleanup();
 #ifdef CONFIG_SYSCTL
@@ -956,6 +959,7 @@
 #endif
 	cleanup_ipv6_mibs();
 	proto_unregister(&rawv6_prot);
+	proto_unregister(&udplitev6_prot);
 	proto_unregister(&udpv6_prot);
 	proto_unregister(&tcpv6_prot);
 }
