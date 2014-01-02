From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC 5/7] net: Support for direct GRE/GUE RX encapsulation
Date: Thu, 2 Jan 2014 14:18:46 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021413250.32428@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hkchu@google.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:47264 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbaABWSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:18:47 -0500
Received: by mail-ie0-f202.google.com with SMTP id lx4so3336889iec.5
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:18:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a module parameter for a GRE/UDP port and opens the GUE UDP port
at initialization.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ip_gre.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index e559e90..786fd59 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -47,6 +47,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/gre.h>
+#include <net/gue.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -115,6 +116,13 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+#if defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE)
+static int gre_udp_port = 0;
+module_param(gre_udp_port, int, 0);
+MODULE_PARM_DESC(gre_udp_port, "GRE/UDP port");
+static struct socket *gue_sock = NULL;
+#endif
+
 static struct rtnl_link_ops ipgre_link_ops __read_mostly;
 static int ipgre_tunnel_init(struct net_device *dev);
 
@@ -784,6 +792,26 @@ static struct pernet_operations ipgre_tap_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
+static int open_gre_gue_port(void)
+{
+#if defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE)
+	if (gre_udp_port)
+		return gue_open_direct_port(gre_udp_port, IPPROTO_GRE,
+					    &gue_sock);
+#endif
+	return 0;
+}
+
+static void close_gre_gue_port(void)
+{
+#if defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE)
+	if (gue_sock) {
+		gue_close_port(gue_sock);
+		gue_sock = NULL;
+	}
+#endif
+}
+
 static int __init ipgre_init(void)
 {
 	int err;
@@ -812,8 +840,14 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto tap_ops_failed;
 
+	err = open_gre_gue_port();
+	if (err < 0)
+		goto gre_udp_port_failed;
+
 	return 0;
 
+gre_udp_port_failed:
+	rtnl_link_unregister(&ipgre_tap_ops);
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
@@ -827,6 +861,7 @@ pnet_tap_faied:
 
 static void __exit ipgre_fini(void)
 {
+	close_gre_gue_port();
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
 	gre_cisco_unregister(&ipgre_protocol);
-- 
1.8.5.1
