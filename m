From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2 net-next-2.6] net: add dev_txq_stats_fold() helper
Date: Mon, 16 Nov 2009 14:36:51 +0100
Message-ID: <4B015573.9090502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42454 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbZKPNgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:36:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers ndo_get_stats() method need to perform txqueue stats folding.

Move folding from dev_get_stats() to a new dev_txq_stats_fold() function

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    1 
 net/core/dev.c            |   48 +++++++++++++++++++++---------------
 2 files changed, 30 insertions(+), 19 deletions(-)



diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7043f85..c8fa462 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1941,6 +1941,7 @@ extern void		netdev_features_change(struct net_device *dev);
 extern void		dev_load(struct net *net, const char *name);
 extern void		dev_mcast_init(void);
 extern const struct net_device_stats *dev_get_stats(struct net_device *dev);
+extern void		dev_txq_stats_fold(const struct net_device *dev, struct net_device_stats *stats);
 
 extern int		netdev_max_backlog;
 extern int		weight_p;
diff --git a/net/core/dev.c b/net/core/dev.c
index 4b24d79..49417ba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5168,6 +5168,32 @@ void netdev_run_todo(void)
 }
 
 /**
+ *	dev_txq_stats_fold - fold tx_queues stats
+ *	@dev: device to get statistics from
+ *	@stats: struct net_device_stats to hold results
+ */
+void dev_txq_stats_fold(const struct net_device *dev,
+			struct net_device_stats *stats)
+{
+	unsigned long tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
+	unsigned int i;
+	struct netdev_queue *txq;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		txq = netdev_get_tx_queue(dev, i);
+		tx_bytes   += txq->tx_bytes;
+		tx_packets += txq->tx_packets;
+		tx_dropped += txq->tx_dropped;
+	}
+	if (tx_bytes || tx_packets || tx_dropped) {
+		stats->tx_bytes   = tx_bytes;
+		stats->tx_packets = tx_packets;
+		stats->tx_dropped = tx_dropped;
+	}
+}
+EXPORT_SYMBOL(dev_txq_stats_fold);
+
+/**
  *	dev_get_stats	- get network device statistics
  *	@dev: device to get statistics from
  *
@@ -5181,25 +5207,9 @@ const struct net_device_stats *dev_get_stats(struct net_device *dev)
 
 	if (ops->ndo_get_stats)
 		return ops->ndo_get_stats(dev);
-	else {
-		unsigned long tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
-		struct net_device_stats *stats = &dev->stats;
-		unsigned int i;
-		struct netdev_queue *txq;
-
-		for (i = 0; i < dev->num_tx_queues; i++) {
-			txq = netdev_get_tx_queue(dev, i);
-			tx_bytes   += txq->tx_bytes;
-			tx_packets += txq->tx_packets;
-			tx_dropped += txq->tx_dropped;
-		}
-		if (tx_bytes || tx_packets || tx_dropped) {
-			stats->tx_bytes   = tx_bytes;
-			stats->tx_packets = tx_packets;
-			stats->tx_dropped = tx_dropped;
-		}
-		return stats;
-	}
+
+	dev_txq_stats_fold(dev, &dev->stats);
+	return &dev->stats;
 }
 EXPORT_SYMBOL(dev_get_stats);
 
