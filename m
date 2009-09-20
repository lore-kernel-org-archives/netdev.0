From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netdev: stats on multiqueue possible bug
Date: Sat, 19 Sep 2009 22:26:08 -0700
Message-ID: <20090919222608.5fdf80b8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33756 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798AbZITF0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2009 01:26:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, I think you were trying to optimize something here that
doesn't need optimization.

If transmit stats (all) wrap to zero, then the stats would not
be set correctly. Move local variable into loop as well.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2009-09-19 15:19:13.902495560 -0700
+++ b/net/core/dev.c	2009-09-19 15:48:21.126458728 -0700
@@ -5079,19 +5079,19 @@ const struct net_device_stats *dev_get_s
 		unsigned long tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
 		struct net_device_stats *stats = &dev->stats;
 		unsigned int i;
-		struct netdev_queue *txq;
 
 		for (i = 0; i < dev->num_tx_queues; i++) {
-			txq = netdev_get_tx_queue(dev, i);
+			const struct netdev_queue *txq
+				 = netdev_get_tx_queue(dev, i);
 			tx_bytes   += txq->tx_bytes;
 			tx_packets += txq->tx_packets;
 			tx_dropped += txq->tx_dropped;
 		}
-		if (tx_bytes || tx_packets || tx_dropped) {
-			stats->tx_bytes   = tx_bytes;
-			stats->tx_packets = tx_packets;
-			stats->tx_dropped = tx_dropped;
-		}
+
+		stats->tx_bytes   = tx_bytes;
+		stats->tx_packets = tx_packets;
+		stats->tx_dropped = tx_dropped;
+
 		return stats;
 	}
 }
