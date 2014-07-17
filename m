From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 7/9] ipv6: RX path for sit/UDP Generic UDP
 Encapsulation
Date: Wed, 16 Jul 2014 21:15:48 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162055250.28953@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:49008 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbaGQEWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:22:14 -0400
Received: by mail-oi0-f74.google.com with SMTP id a141so101097oig.3
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:22:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested with TCP_RR netperf and 200 streams:

  No GUE
    65.83% CPU utilization
    198/277/401 90/95/99% latencies
    941478 tps

  With GUE
    73.17% CPU utilization
    195/279/407 90/95/99% latencies
    955398 tps

  With GUE and UDP RSS
    93.81% CPU utilization
    167/266/497 90/95/99% latencies
    1.07711e+06 tps

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/sit.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 4a7adb0..a9bfac5 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -55,6 +55,7 @@
 #include <net/dsfield.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/gue.h>
 
 /*
    This version of net/ipv6/sit.c is cloned of net/ipv4/ip_gre.c
@@ -69,6 +70,8 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+GUE_TUNNEL_PARMS("IPv6", 0)
+
 static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 static void ipip6_dev_free(struct net_device *dev);
@@ -1796,6 +1799,7 @@ static struct pernet_operations sit_net_ops = {
 
 static void __exit sit_cleanup(void)
 {
+	close_gue_port();
 	rtnl_link_unregister(&sit_link_ops);
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
@@ -1827,9 +1831,15 @@ static int __init sit_init(void)
 	if (err < 0)
 		goto rtnl_link_failed;
 
+	err = open_gue_port(IPPROTO_IPV6);
+	if (err < 0)
+		goto gue_udp_port_failed;
+
 out:
 	return err;
 
+gue_udp_port_failed:
+	rtnl_link_unregister(&sit_link_ops);
 rtnl_link_failed:
 	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 xfrm_tunnel4_failed:
-- 
2.0.0.526.g5318336
