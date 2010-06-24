From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 3/4] macvlan: 64 bit rx counters
Date: Thu, 24 Jun 2010 12:54:21 +0200
Message-ID: <1277376861.2816.284.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:63104 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800Ab0FXKyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 06:54:47 -0400
Received: by wwi17 with SMTP id 17so93458wwi.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 03:54:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use u64_stats_sync infrastructure to implement 64bit stats.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/macvlan.c      |   37 +++++++++++++++++++++--------------
 include/linux/if_macvlan.h |   19 +++++++++++------
 2 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index e096875..e6d626e 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -431,29 +431,38 @@ static void macvlan_uninit(struct net_device *dev)
 	free_percpu(vlan->rx_stats);
 }
 
-static struct net_device_stats *macvlan_dev_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev)
 {
-	struct net_device_stats *stats = &dev->stats;
+	struct rtnl_link_stats64 *stats = &dev->stats64;
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
-	dev_txq_stats_fold(dev, stats);
+	dev_txq_stats_fold(dev, &dev->stats);
 
 	if (vlan->rx_stats) {
-		struct macvlan_rx_stats *p, rx = {0};
+		struct macvlan_rx_stats *p, accum = {0};
+		u64 rx_packets, rx_bytes, rx_multicast;
+		unsigned int start;
 		int i;
 
 		for_each_possible_cpu(i) {
 			p = per_cpu_ptr(vlan->rx_stats, i);
-			rx.rx_packets += p->rx_packets;
-			rx.rx_bytes   += p->rx_bytes;
-			rx.rx_errors  += p->rx_errors;
-			rx.multicast  += p->multicast;
+			do {
+				start = u64_stats_fetch_begin_bh(&p->syncp);
+				rx_packets	= p->rx_packets;
+				rx_bytes	= p->rx_bytes;
+				rx_multicast	= p->rx_multicast;
+			} while (u64_stats_fetch_retry_bh(&p->syncp, start));
+			accum.rx_packets	+= rx_packets;
+			accum.rx_bytes		+= rx_bytes;
+			accum.rx_multicast	+= rx_multicast;
+			/* rx_errors is an ulong, updated without syncp protection */
+			accum.rx_errors		+= p->rx_errors;
 		}
-		stats->rx_packets = rx.rx_packets;
-		stats->rx_bytes   = rx.rx_bytes;
-		stats->rx_errors  = rx.rx_errors;
-		stats->rx_dropped = rx.rx_errors;
-		stats->multicast  = rx.multicast;
+		stats->rx_packets = accum.rx_packets;
+		stats->rx_bytes   = accum.rx_bytes;
+		stats->rx_errors  = accum.rx_errors;
+		stats->rx_dropped = accum.rx_errors;
+		stats->multicast  = accum.rx_multicast;
 	}
 	return stats;
 }
@@ -502,7 +511,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_change_rx_flags	= macvlan_change_rx_flags,
 	.ndo_set_mac_address	= macvlan_set_mac_address,
 	.ndo_set_multicast_list	= macvlan_set_multicast_list,
-	.ndo_get_stats		= macvlan_dev_get_stats,
+	.ndo_get_stats64	= macvlan_dev_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index c26a0e4..e24ce6e 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -6,6 +6,7 @@
 #include <linux/netdevice.h>
 #include <linux/netlink.h>
 #include <net/netlink.h>
+#include <linux/u64_stats_sync.h>
 
 #if defined(CONFIG_MACVTAP) || defined(CONFIG_MACVTAP_MODULE)
 struct socket *macvtap_get_socket(struct file *);
@@ -27,14 +28,16 @@ struct macvtap_queue;
  *	struct macvlan_rx_stats - MACVLAN percpu rx stats
  *	@rx_packets: number of received packets
  *	@rx_bytes: number of received bytes
- *	@multicast: number of received multicast packets
+ *	@rx_multicast: number of received multicast packets
+ *	@syncp: synchronization point for 64bit counters
  *	@rx_errors: number of errors
  */
 struct macvlan_rx_stats {
-	unsigned long rx_packets;
-	unsigned long rx_bytes;
-	unsigned long multicast;
-	unsigned long rx_errors;
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			rx_multicast;
+	struct u64_stats_sync	syncp;
+	unsigned long		rx_errors;
 };
 
 struct macvlan_dev {
@@ -56,12 +59,14 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 {
 	struct macvlan_rx_stats *rx_stats;
 
-	rx_stats = per_cpu_ptr(vlan->rx_stats, smp_processor_id());
+	rx_stats = this_cpu_ptr(vlan->rx_stats);
 	if (likely(success)) {
+		u64_stats_update_begin(&rx_stats->syncp);
 		rx_stats->rx_packets++;;
 		rx_stats->rx_bytes += len;
 		if (multicast)
-			rx_stats->multicast++;
+			rx_stats->rx_multicast++;
+		u64_stats_update_end(&rx_stats->syncp);
 	} else {
 		rx_stats->rx_errors++;
 	}


