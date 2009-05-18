From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 1/2] net: add tx_packets/tx_bytes/tx_dropped counters in struct
 netdev_queue
Date: Mon, 18 May 2009 12:34:33 +0200
Message-ID: <4A1139B9.6040505@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51286 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbZERKee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 06:34:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

offsetof(struct net_device, features)=0x44
offsetof(struct net_device, stats.tx_packets)=0x54
offsetof(struct net_device, stats.tx_bytes)=0x5c
offsetof(struct net_device, stats.tx_dropped)=0x6c

Network drivers that touch dev->stats.tx_packets/stats.tx_bytes in their
tx path can slow down SMP operations, since they dirty a cache line
that should stay shared (dev->features is needed in rx and tx paths)

We could move away stats field in net_device but it wont help that much.
(Two cache lines dirtied in tx path, we can do one only)

Better solution is to add tx_packets/tx_bytes/tx_dropped in struct
netdev_queue because this structure is already touched in tx path and
counters updates will then be free (no increase in size)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   23 ++++++++++++++++++++---
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cd547d0..4623e9f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -474,6 +474,9 @@ struct netdev_queue {
 	 * please use this field instead of dev->trans_start
 	 */
 	unsigned long		trans_start;
+	unsigned long		tx_bytes;
+	unsigned long		tx_packets;
+	unsigned long		tx_dropped;
 } ____cacheline_aligned_in_smp;
 
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 14dd725..a43b510 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4943,13 +4943,30 @@ void netdev_run_todo(void)
  *	the internal statistics structure is used.
  */
 const struct net_device_stats *dev_get_stats(struct net_device *dev)
- {
+{
 	const struct net_device_ops *ops = dev->netdev_ops;
 
 	if (ops->ndo_get_stats)
 		return ops->ndo_get_stats(dev);
-	else
-		return &dev->stats;
+	else {
+		unsigned long tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
+		struct net_device_stats *stats = &dev->stats;
+		unsigned int i;
+		struct netdev_queue *txq;
+
+		for (i = 0; i < dev->num_tx_queues; i++) {
+			txq = netdev_get_tx_queue(dev, i);
+			tx_bytes   += txq->tx_bytes;
+			tx_packets += txq->tx_packets;
+			tx_dropped += txq->tx_dropped;
+		}
+		if (tx_bytes || tx_packets || tx_dropped) {
+			stats->tx_bytes   = tx_bytes;
+			stats->tx_packets = tx_packets;
+			stats->tx_dropped = tx_dropped;
+		}
+		return stats;
+	}
 }
 EXPORT_SYMBOL(dev_get_stats);
 
 
