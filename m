From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next v2 4/6] net: call udp_tunnel_get_rx_info when NETIF_F_RX_UDP_TUNNEL_PORT is toggled
Date: Fri, 21 Jul 2017 12:49:31 +0200
Message-ID: <ce54b439dc83faa9cb17dfe07c3f10ea764fcdac.1500632570.git.sd@queasysnail.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753642AbdGUKt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 06:49:59 -0400
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_RX_UDP_TUNNEL_PORT is special, in that we need to do more than
just flip the bit in dev->features. When disabling we must also clear
currently offloaded ports from the device, and when enabling we must
tell the device to offload the ports it can.

Because vxlan stores its sockets in a hashtable and they are inserted at
the head of per-bucket lists, switching the feature off and then on can
result in a different set of ports being offloaded (depending on the
HW's limits).

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/core/dev.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9081134adc0d..8ea6b4b42611 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -144,6 +144,7 @@
 #include <linux/netfilter_ingress.h>
 #include <linux/crash_dump.h>
 #include <linux/sctp.h>
+#include <net/udp_tunnel.h>
 
 #include "net-sysfs.h"
 
@@ -7327,8 +7328,27 @@ int __netdev_update_features(struct net_device *dev)
 	netdev_for_each_lower_dev(dev, lower, iter)
 		netdev_sync_lower_features(dev, lower, features);
 
-	if (!err)
+	if (!err) {
+		netdev_features_t diff = features ^ dev->features;
+
+		if (diff & NETIF_F_RX_UDP_TUNNEL_PORT) {
+			/* udp_tunnel_{get,drop}_rx_info both need
+			 * NETIF_F_RX_UDP_TUNNEL_PORT enabled on the
+			 * device, or they won't do anything.
+			 * Thus we need to update dev->features
+			 * *before* calling udp_tunnel_get_rx_info,
+			 * but *after* calling udp_tunnel_drop_rx_info.
+			 */
+			if (features & NETIF_F_RX_UDP_TUNNEL_PORT) {
+				dev->features = features;
+				udp_tunnel_get_rx_info(dev);
+			} else {
+				udp_tunnel_drop_rx_info(dev);
+			}
+		}
+
 		dev->features = features;
+	}
 
 	return err < 0 ? 0 : 1;
 }
-- 
2.13.2
