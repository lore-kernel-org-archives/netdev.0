From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 9/9] gre: RX path for GRE/UDP Generic UDP
 Encapsulation
Date: Wed, 16 Jul 2014 21:16:12 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162055430.29560@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:58640 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbaGQEQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:16:14 -0400
Received: by mail-ig0-f202.google.com with SMTP id r2so226282igi.3
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:16:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested with TCP_RR netperf and 200 streams:

  No GUE
    71.01% CPU utilization
    180/257/381 90/95/99% latencies
    1.03838e+06 tps

  With GUE
    73.73% CPU utilization
    182/261/369 90/95/99% latencies
    1.01568e+06 tps

  GRE with GUE and UDP RSS
    94.49% CPU utilization
    156/248/461 90/95/99% latencies
    1.15948e+06 tps

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ip_gre.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 8053b3b..363e4ec 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -47,6 +47,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/gre.h>
+#include <net/gue.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -115,6 +116,8 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+GUE_TUNNEL_PARMS("GRE", 0)
+
 static struct rtnl_link_ops ipgre_link_ops __read_mostly;
 static int ipgre_tunnel_init(struct net_device *dev);
 
@@ -814,8 +817,14 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto tap_ops_failed;
 
+	err = open_gue_port(IPPROTO_GRE);
+	if (err < 0)
+		goto gue_udp_port_failed;
+
 	return 0;
 
+gue_udp_port_failed:
+	rtnl_link_unregister(&ipgre_tap_ops);
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
@@ -829,6 +838,7 @@ pnet_tap_faied:
 
 static void __exit ipgre_fini(void)
 {
+	close_gue_port();
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
 	gre_cisco_unregister(&ipgre_protocol);
-- 
2.0.0.526.g5318336
