From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 8/9] ipip: RX path for IPIP/UDP Generic UDP
 Encapsulation
Date: Wed, 16 Jul 2014 21:15:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162056020.30101@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:37335 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaGQEQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:16:00 -0400
Received: by mail-pd0-f202.google.com with SMTP id w10so498030pde.5
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:16:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested with TCP_RR netperf and 200 streams:

  No GUE
    70.86% CPU utilization
    179/253/359 90/95/99% latencies
    1.05203e+06 tps

  With GUE
    73.62% CPU utilization
    183/265/389 90/95/99% latencies
    1.02159e+06 tps

  With GUE and UDP RSS
    94.62% CPU utilization
    155/247/458 90/95/99% latencies
    1.16926e+06 tps

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ipip.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 91a1c89..75578fa 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -116,11 +116,14 @@
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/gue.h>
 
 static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+GUE_TUNNEL_PARMS("IPIP", 0)
+
 static int ipip_net_id __read_mostly;
 
 static int ipip_tunnel_init(struct net_device *dev);
@@ -470,9 +473,15 @@ static int __init ipip_init(void)
 	if (err < 0)
 		goto rtnl_link_failed;
 
+	err = open_gue_port(IPPROTO_IPIP);
+	if (err < 0)
+		goto gue_udp_port_failed;
+
 out:
 	return err;
 
+gue_udp_port_failed:
+	rtnl_link_unregister(&ipip_link_ops);
 rtnl_link_failed:
 	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 xfrm_tunnel_failed:
@@ -482,6 +491,7 @@ xfrm_tunnel_failed:
 
 static void __exit ipip_fini(void)
 {
+	close_gue_port();
 	rtnl_link_unregister(&ipip_link_ops);
 	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
 		pr_info("%s: can't deregister tunnel\n", __func__);
-- 
2.0.0.526.g5318336
