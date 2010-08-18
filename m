From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] slip: fix get_stats() method
Date: Wed, 18 Aug 2010 15:13:08 +0200
Message-ID: <1282137188.2194.74.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:46598 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772Ab0HRNNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:13:13 -0400
Received: by ewy23 with SMTP id 23so311375ewy.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 06:13:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use integrated net_device_stats instead of a static one, and make sure
no transient values are feeded. ndo_get_stats() can be called by
concurrent cpus.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/slip.c |   50 +++++++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index fa434fb..d5a36f5 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -561,36 +561,36 @@ static int sl_change_mtu(struct net_device *dev, int new_mtu)
 static struct net_device_stats *
 sl_get_stats(struct net_device *dev)
 {
-	static struct net_device_stats stats;
+	struct net_device_stats *stats = &dev->stats;
 	struct slip *sl = netdev_priv(dev);
+	unsigned long c_rx_dropped = 0;
 #ifdef SL_INCLUDE_CSLIP
-	struct slcompress *comp;
-#endif
+	unsigned long c_rx_fifo_errors = 0;
+	unsigned long c_tx_fifo_errors = 0;
+	unsigned long c_collisions = 0;
+	struct slcompress *comp = sl->slcomp;
 
-	memset(&stats, 0, sizeof(struct net_device_stats));
-
-	stats.rx_packets     = sl->rx_packets;
-	stats.tx_packets     = sl->tx_packets;
-	stats.rx_bytes	     = sl->rx_bytes;
-	stats.tx_bytes	     = sl->tx_bytes;
-	stats.rx_dropped     = sl->rx_dropped;
-	stats.tx_dropped     = sl->tx_dropped;
-	stats.tx_errors      = sl->tx_errors;
-	stats.rx_errors      = sl->rx_errors;
-	stats.rx_over_errors = sl->rx_over_errors;
-#ifdef SL_INCLUDE_CSLIP
-	stats.rx_fifo_errors = sl->rx_compressed;
-	stats.tx_fifo_errors = sl->tx_compressed;
-	stats.collisions     = sl->tx_misses;
-	comp = sl->slcomp;
 	if (comp) {
-		stats.rx_fifo_errors += comp->sls_i_compressed;
-		stats.rx_dropped     += comp->sls_i_tossed;
-		stats.tx_fifo_errors += comp->sls_o_compressed;
-		stats.collisions     += comp->sls_o_misses;
+		c_rx_fifo_errors = comp->sls_i_compressed;
+		c_rx_dropped     = comp->sls_i_tossed;
+		c_tx_fifo_errors = comp->sls_o_compressed;
+		c_collisions     = comp->sls_o_misses;
 	}
-#endif /* CONFIG_INET */
-	return (&stats);
+	stats->rx_fifo_errors = sl->rx_compressed + c_rx_fifo_errors;
+	stats->tx_fifo_errors = sl->tx_compressed + c_tx_fifo_errors;
+	stats->collisions     = sl->tx_misses + c_collisions;
+#endif
+
+	stats->rx_packets     = sl->rx_packets;
+	stats->tx_packets     = sl->tx_packets;
+	stats->rx_bytes	      = sl->rx_bytes;
+	stats->tx_bytes	      = sl->tx_bytes;
+	stats->rx_dropped     = sl->rx_dropped + c_rx_dropped;
+	stats->tx_dropped     = sl->tx_dropped;
+	stats->tx_errors      = sl->tx_errors;
+	stats->rx_errors      = sl->rx_errors;
+	stats->rx_over_errors = sl->rx_over_errors;
+	return stats;
 }
 
 /* Netdevice register callback */


