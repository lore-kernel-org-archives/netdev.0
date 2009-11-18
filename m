From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] veth: Fix veth_get_stats()
Date: Wed, 18 Nov 2009 18:09:39 +0100
Message-ID: <4B042A53.9010301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53027 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757667AbZKRRJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 12:09:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

veth_get_stats() can be called in parallel on several cpus.

It's better to not reset dev->stats as it could give wrong result on
one cpu. Use temporary variables, then store the final results.

Also, we should loop on every possible cpus, not only online cpus,
or cpu hotplug can suddenly give wrong veth stats.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/veth.c |   35 ++++++++++++++++-------------------
 1 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index ade5b34..52af501 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -210,32 +210,29 @@ rx_drop:
 static struct net_device_stats *veth_get_stats(struct net_device *dev)
 {
 	struct veth_priv *priv;
-	struct net_device_stats *dev_stats;
 	int cpu;
-	struct veth_net_stats *stats;
+	struct veth_net_stats *stats, total = {0};
 
 	priv = netdev_priv(dev);
-	dev_stats = &dev->stats;
-
-	dev_stats->rx_packets = 0;
-	dev_stats->tx_packets = 0;
-	dev_stats->rx_bytes = 0;
-	dev_stats->tx_bytes = 0;
-	dev_stats->tx_dropped = 0;
-	dev_stats->rx_dropped = 0;
 
-	for_each_online_cpu(cpu) {
+	for_each_possible_cpu(cpu) {
 		stats = per_cpu_ptr(priv->stats, cpu);
 
-		dev_stats->rx_packets += stats->rx_packets;
-		dev_stats->tx_packets += stats->tx_packets;
-		dev_stats->rx_bytes += stats->rx_bytes;
-		dev_stats->tx_bytes += stats->tx_bytes;
-		dev_stats->tx_dropped += stats->tx_dropped;
-		dev_stats->rx_dropped += stats->rx_dropped;
+		total.rx_packets += stats->rx_packets;
+		total.tx_packets += stats->tx_packets;
+		total.rx_bytes   += stats->rx_bytes;
+		total.tx_bytes   += stats->tx_bytes;
+		total.tx_dropped += stats->tx_dropped;
+		total.rx_dropped += stats->rx_dropped;
 	}
-
-	return dev_stats;
+	dev->stats.rx_packets = total.rx_packets;
+	dev->stats.tx_packets = total.tx_packets;
+	dev->stats.rx_bytes   = total.rx_bytes;
+	dev->stats.tx_bytes   = total.tx_bytes;
+	dev->stats.tx_dropped = total.tx_dropped;
+	dev->stats.rx_dropped = total.rx_dropped;
+
+	return &dev->stats;
 }
 
 static int veth_open(struct net_device *dev)
