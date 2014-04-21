From: roy.qing.li@gmail.com
Subject: [PATCH] vlan: unnecessary to check if vlan_pcpu_stats is NULL
Date: Mon, 21 Apr 2014 19:49:08 +0800
Message-ID: <1398080948-31851-1-git-send-email-roy.qing.li@gmail.com>
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:63960 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaDULtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 07:49:12 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so3604527pdj.18
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 04:49:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

if allocating memory for vlan_pcpu_stats failed, the device can not be operated

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/8021q/vlan_dev.c |   58 ++++++++++++++++++++++++--------------------------
 1 file changed, 28 insertions(+), 30 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 6f142f0..0cc60ad 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -670,38 +670,36 @@ static void vlan_ethtool_get_drvinfo(struct net_device *dev,
 
 static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
+	struct vlan_pcpu_stats *p;
+	u32 rx_errors = 0, tx_dropped = 0;
+	int i;
 
-	if (vlan_dev_priv(dev)->vlan_pcpu_stats) {
-		struct vlan_pcpu_stats *p;
-		u32 rx_errors = 0, tx_dropped = 0;
-		int i;
-
-		for_each_possible_cpu(i) {
-			u64 rxpackets, rxbytes, rxmulticast, txpackets, txbytes;
-			unsigned int start;
-
-			p = per_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats, i);
-			do {
-				start = u64_stats_fetch_begin_irq(&p->syncp);
-				rxpackets	= p->rx_packets;
-				rxbytes		= p->rx_bytes;
-				rxmulticast	= p->rx_multicast;
-				txpackets	= p->tx_packets;
-				txbytes		= p->tx_bytes;
-			} while (u64_stats_fetch_retry_irq(&p->syncp, start));
-
-			stats->rx_packets	+= rxpackets;
-			stats->rx_bytes		+= rxbytes;
-			stats->multicast	+= rxmulticast;
-			stats->tx_packets	+= txpackets;
-			stats->tx_bytes		+= txbytes;
-			/* rx_errors & tx_dropped are u32 */
-			rx_errors	+= p->rx_errors;
-			tx_dropped	+= p->tx_dropped;
-		}
-		stats->rx_errors  = rx_errors;
-		stats->tx_dropped = tx_dropped;
+	for_each_possible_cpu(i) {
+		u64 rxpackets, rxbytes, rxmulticast, txpackets, txbytes;
+		unsigned int start;
+
+		p = per_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&p->syncp);
+			rxpackets	= p->rx_packets;
+			rxbytes		= p->rx_bytes;
+			rxmulticast	= p->rx_multicast;
+			txpackets	= p->tx_packets;
+			txbytes		= p->tx_bytes;
+		} while (u64_stats_fetch_retry_irq(&p->syncp, start));
+
+		stats->rx_packets	+= rxpackets;
+		stats->rx_bytes		+= rxbytes;
+		stats->multicast	+= rxmulticast;
+		stats->tx_packets	+= txpackets;
+		stats->tx_bytes		+= txbytes;
+		/* rx_errors & tx_dropped are u32 */
+		rx_errors	+= p->rx_errors;
+		tx_dropped	+= p->tx_dropped;
 	}
+	stats->rx_errors  = rx_errors;
+	stats->tx_dropped = tx_dropped;
+
 	return stats;
 }
 
-- 
1.7.10.4
