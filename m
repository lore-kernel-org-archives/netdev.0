From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: systemport: Fix 64-bit statistics dependency
Date: Mon, 18 Sep 2017 16:31:30 -0700
Message-ID: <20170918233130.5740-1-f.fainelli@gmail.com>
Cc: edumazet@google.com, davem@davemloft.net, jqiaoulk@gmail.com,
        kiki-good@hotmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34764 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdIRXbh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 19:31:37 -0400
Received: by mail-wm0-f67.google.com with SMTP id i131so2297071wma.1
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 16:31:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several problems with commit 10377ba7673d ("net: systemport:
Support 64bit statistics", first one got fixed in 7095c973453e ("net:
systemport: Fix 64-bit stats deadlock").

The second problem is that this specific code updates the
stats64.tx_{packets,bytes} from ndo_get_stats64() and that is what we
are returning to ethtool -S. If we are not running a tool that involves
calling ndo_get_stats64(), then we won't get updated ethtool stats.

The solution to this is to update the stats from both call sites,
factoring that into a specific function, While at it, don't just check
the sizeof() but also the type of the statistics in order to use the
64-bit stats seqlock.

Fixes: 10377ba7673d ("net: systemport: Support 64bit statistics"
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 52 ++++++++++++++++++------------
 1 file changed, 32 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index c3c53f6cd9e6..83eec9a8c275 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -432,6 +432,27 @@ static void bcm_sysport_update_mib_counters(struct bcm_sysport_priv *priv)
 	netif_dbg(priv, hw, priv->netdev, "updated MIB counters\n");
 }
 
+static void bcm_sysport_update_tx_stats(struct bcm_sysport_priv *priv,
+					u64 *tx_bytes, u64 *tx_packets)
+{
+	struct bcm_sysport_tx_ring *ring;
+	u64 bytes = 0, packets = 0;
+	unsigned int start;
+	unsigned int q;
+
+	for (q = 0; q < priv->netdev->num_tx_queues; q++) {
+		ring = &priv->tx_rings[q];
+		do {
+			start = u64_stats_fetch_begin_irq(&priv->syncp);
+			bytes = ring->bytes;
+			packets = ring->packets;
+		} while (u64_stats_fetch_retry_irq(&priv->syncp, start));
+
+		*tx_bytes += bytes;
+		*tx_packets += packets;
+	}
+}
+
 static void bcm_sysport_get_stats(struct net_device *dev,
 				  struct ethtool_stats *stats, u64 *data)
 {
@@ -439,11 +460,16 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 	struct bcm_sysport_stats64 *stats64 = &priv->stats64;
 	struct u64_stats_sync *syncp = &priv->syncp;
 	struct bcm_sysport_tx_ring *ring;
+	u64 tx_bytes = 0, tx_packets = 0;
 	unsigned int start;
 	int i, j;
 
-	if (netif_running(dev))
+	if (netif_running(dev)) {
 		bcm_sysport_update_mib_counters(priv);
+		bcm_sysport_update_tx_stats(priv, &tx_bytes, &tx_packets);
+		stats64->tx_bytes = tx_bytes;
+		stats64->tx_packets = tx_packets;
+	}
 
 	for (i =  0, j = 0; i < BCM_SYSPORT_STATS_LEN; i++) {
 		const struct bcm_sysport_stats *s;
@@ -461,12 +487,13 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 			continue;
 		p += s->stat_offset;
 
-		if (s->stat_sizeof == sizeof(u64))
+		if (s->stat_sizeof == sizeof(u64) &&
+		    s->type == BCM_SYSPORT_STAT_NETDEV64) {
 			do {
 				start = u64_stats_fetch_begin_irq(syncp);
 				data[i] = *(u64 *)p;
 			} while (u64_stats_fetch_retry_irq(syncp, start));
-		else
+		} else
 			data[i] = *(u32 *)p;
 		j++;
 	}
@@ -1716,27 +1743,12 @@ static void bcm_sysport_get_stats64(struct net_device *dev,
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	struct bcm_sysport_stats64 *stats64 = &priv->stats64;
-	struct bcm_sysport_tx_ring *ring;
-	u64 tx_packets = 0, tx_bytes = 0;
 	unsigned int start;
-	unsigned int q;
 
 	netdev_stats_to_stats64(stats, &dev->stats);
 
-	for (q = 0; q < dev->num_tx_queues; q++) {
-		ring = &priv->tx_rings[q];
-		do {
-			start = u64_stats_fetch_begin_irq(&priv->syncp);
-			tx_bytes = ring->bytes;
-			tx_packets = ring->packets;
-		} while (u64_stats_fetch_retry_irq(&priv->syncp, start));
-
-		stats->tx_bytes += tx_bytes;
-		stats->tx_packets += tx_packets;
-	}
-
-	stats64->tx_bytes = stats->tx_bytes;
-	stats64->tx_packets = stats->tx_packets;
+	bcm_sysport_update_tx_stats(priv, &stats->tx_bytes,
+				    &stats->tx_packets);
 
 	do {
 		start = u64_stats_fetch_begin_irq(&priv->syncp);
-- 
2.9.3
