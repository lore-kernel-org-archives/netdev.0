From: fgao@ikuai8.com
Subject: [PATCH net-next v2 1/1] driver: veth: Refine the statistics codes of veth driver
Date: Thu,  3 Nov 2016 21:03:57 +0800
Message-ID: <1478178237-23020-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, cwang@twopensource.com, vijayp@vijayp.ca,
        ej@evanjones.ca, pabeni@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:39055 "EHLO smtpbg291.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756753AbcKCNN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 09:13:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The dropped count of veth is located in struct veth_priv, but other
statistics like packets and bytes are in another struct pcpu_vstats.
Now keep these three counters in the same struct.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Use right "peer" instead of "dev";
 v1: Initial version

 drivers/net/veth.c | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0520952a..0d669b4 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -26,12 +26,12 @@
 struct pcpu_vstats {
 	u64			packets;
 	u64			bytes;
+	u64			dropped;
 	struct u64_stats_sync	syncp;
 };
 
 struct veth_priv {
 	struct net_device __rcu	*peer;
-	atomic64_t		dropped;
 	unsigned		requested_headroom;
 };
 
@@ -108,6 +108,8 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct veth_priv *priv = netdev_priv(dev);
 	struct net_device *rcv;
 	int length = skb->len;
+	struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
+	int ret = NET_RX_DROP;
 
 	rcu_read_lock();
 	rcv = rcu_dereference(priv->peer);
@@ -116,17 +118,16 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 	}
 
-	if (likely(dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
-		struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
-
-		u64_stats_update_begin(&stats->syncp);
+	ret = dev_forward_skb(rcv, skb);
+drop:
+	u64_stats_update_begin(&stats->syncp);
+	if (likely(ret == NET_RX_SUCCESS)) {
 		stats->bytes += length;
 		stats->packets++;
-		u64_stats_update_end(&stats->syncp);
 	} else {
-drop:
-		atomic64_inc(&priv->dropped);
+		stats->dropped++;
 	}
+	u64_stats_update_end(&stats->syncp);
 	rcu_read_unlock();
 	return NETDEV_TX_OK;
 }
@@ -135,27 +136,28 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
  * general routines
  */
 
-static u64 veth_stats_one(struct pcpu_vstats *result, struct net_device *dev)
+static void veth_stats_one(struct pcpu_vstats *result, struct net_device *dev)
 {
-	struct veth_priv *priv = netdev_priv(dev);
 	int cpu;
 
 	result->packets = 0;
 	result->bytes = 0;
+	result->dropped = 0;
 	for_each_possible_cpu(cpu) {
 		struct pcpu_vstats *stats = per_cpu_ptr(dev->vstats, cpu);
-		u64 packets, bytes;
+		u64 packets, bytes, dropped;
 		unsigned int start;
 
 		do {
 			start = u64_stats_fetch_begin_irq(&stats->syncp);
 			packets = stats->packets;
 			bytes = stats->bytes;
+			dropped = stats->dropped;
 		} while (u64_stats_fetch_retry_irq(&stats->syncp, start));
 		result->packets += packets;
 		result->bytes += bytes;
+		result->dropped += dropped;
 	}
-	return atomic64_read(&priv->dropped);
 }
 
 static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
@@ -165,16 +167,18 @@ static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
 	struct net_device *peer;
 	struct pcpu_vstats one;
 
-	tot->tx_dropped = veth_stats_one(&one, dev);
+	veth_stats_one(&one, dev);
 	tot->tx_bytes = one.bytes;
 	tot->tx_packets = one.packets;
+	tot->tx_dropped = one.dropped;
 
 	rcu_read_lock();
 	peer = rcu_dereference(priv->peer);
 	if (peer) {
-		tot->rx_dropped = veth_stats_one(&one, peer);
+		veth_stats_one(&one, peer);
 		tot->rx_bytes = one.bytes;
 		tot->rx_packets = one.packets;
+		tot->rx_dropped = one.dropped;
 	}
 	rcu_read_unlock();
 
-- 
1.9.1
