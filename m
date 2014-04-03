From: roy.qing.li@gmail.com
Subject: [PATCH] vlan: unnecessary to check if vlan_pcpu_stats is NULL
Date: Thu,  3 Apr 2014 20:45:25 +0800
Message-ID: <1396529125-1441-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:37535 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbaDCMph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 08:45:37 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so1736891pdi.2
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 05:45:36 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id i10sm24847531pat.36.2014.04.03.05.45.33
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 05:45:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

if allocating memory for vlan_pcpu_stats failed, the device can not be operated

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/8021q/vlan_dev.c |   58 ++++++++++++++++++++++++--------------------------
 1 file changed, 28 insertions(+), 30 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4f3e907..dbab6f1 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -666,38 +666,36 @@ static void vlan_ethtool_get_drvinfo(struct net_device *dev,
 
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
