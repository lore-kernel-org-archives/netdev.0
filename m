From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ifb: add multiqueue operation
Date: Mon, 06 Jul 2015 22:05:28 +0200
Message-ID: <1436213128.4571.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35689 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbbGFUFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 16:05:33 -0400
Received: by wiga1 with SMTP id a1so238514053wig.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 13:05:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add multiqueue capabilities to ifb netdevice.

This removes last bottleneck for ingress when mq qdisc can be used
to shard load from multiple RX queues on physical device.

Tested:

# netem based setup, installed at receiver side
ETH=eth0
IFB=ifb10
EST="est 1sec 4sec" # Optional rate estimator
RTT_HALF=2ms
#REORDER=20us
#LOSS="loss 1"
TXQ=8

ip link add ifb10 numtxqueues $TXQ type ifb
ip link set dev $IFB up

tc qdisc add dev $ETH ingress 2>/dev/null

tc filter add dev $ETH parent ffff: \
   protocol ip u32 match u32 0 0 flowid 1:1 \
	action mirred egress redirect dev $IFB

tc qdisc del dev $IFB root 2>/dev/null

tc qdisc add dev $IFB root handle 1: mq
for i in `seq 1 $TXQ`
do
 slot=$( printf %x $(( i )) )
 tc qd add dev $IFB parent 1:$slot $EST netem \
	limit 100000 delay $RTT_HALF $REORDER $LOSS
done

lpaa24:~# tc -s -d qd sh dev ifb10
qdisc mq 1: root 
 Sent 316544766 bytes 5265927 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 98880b 1648p requeues 0 
qdisc netem 8002: parent 1:1 limit 100000 delay 2.0ms
 Sent 39601416 bytes 658721 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 38235Kbit 79657pps backlog 12240b 204p requeues 0 
qdisc netem 8003: parent 1:2 limit 100000 delay 2.0ms
 Sent 39472866 bytes 657227 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 38234Kbit 79655pps backlog 10620b 176p requeues 0 
qdisc netem 8004: parent 1:3 limit 100000 delay 2.0ms
 Sent 39703417 bytes 659699 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 38320Kbit 79831pps backlog 12780b 213p requeues 0 
qdisc netem 8005: parent 1:4 limit 100000 delay 2.0ms
 Sent 39565149 bytes 658011 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 38174Kbit 79530pps backlog 11880b 198p requeues 0 
qdisc netem 8006: parent 1:5 limit 100000 delay 2.0ms
 Sent 39506078 bytes 657354 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 38195Kbit 79571pps backlog 12480b 208p requeues 0 
qdisc netem 8007: parent 1:6 limit 100000 delay 2.0ms
 Sent 39675994 bytes 658849 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 38323Kbit 79838pps backlog 12600b 210p requeues 0 
qdisc netem 8008: parent 1:7 limit 100000 delay 2.0ms
 Sent 39532042 bytes 658367 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 38177Kbit 79536pps backlog 13140b 219p requeues 0 
qdisc netem 8009: parent 1:8 limit 100000 delay 2.0ms
 Sent 39488164 bytes 657705 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 38192Kbit 79568pps backlog 13Kb 222p requeues 0 


Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 drivers/net/ifb.c |  207 +++++++++++++++++++++++++-------------------
 1 file changed, 120 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 94570aace241..cc56fac3c3f8 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -38,69 +38,68 @@
 #include <net/net_namespace.h>
 
 #define TX_Q_LIMIT    32
-struct ifb_private {
+struct ifb_q_private {
+	struct net_device	*dev;
 	struct tasklet_struct   ifb_tasklet;
-	int     tasklet_pending;
-
-	struct u64_stats_sync	rsync;
+	int			tasklet_pending;
+	int			txqnum;
 	struct sk_buff_head     rq;
-	u64 rx_packets;
-	u64 rx_bytes;
+	u64			rx_packets;
+	u64			rx_bytes;
+	struct u64_stats_sync	rsync;
 
 	struct u64_stats_sync	tsync;
+	u64			tx_packets;
+	u64			tx_bytes;
 	struct sk_buff_head     tq;
-	u64 tx_packets;
-	u64 tx_bytes;
-};
+} ____cacheline_aligned_in_smp;
 
-static int numifbs = 2;
+struct ifb_dev_private {
+	struct ifb_q_private *tx_private;
+};
 
-static void ri_tasklet(unsigned long dev);
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev);
 static int ifb_open(struct net_device *dev);
 static int ifb_close(struct net_device *dev);
 
-static void ri_tasklet(unsigned long dev)
+static void ifb_ri_tasklet(unsigned long _txp)
 {
-	struct net_device *_dev = (struct net_device *)dev;
-	struct ifb_private *dp = netdev_priv(_dev);
+	struct ifb_q_private *txp = (struct ifb_q_private *)_txp;
 	struct netdev_queue *txq;
 	struct sk_buff *skb;
 
-	txq = netdev_get_tx_queue(_dev, 0);
-	if ((skb = skb_peek(&dp->tq)) == NULL) {
-		if (__netif_tx_trylock(txq)) {
-			skb_queue_splice_tail_init(&dp->rq, &dp->tq);
-			__netif_tx_unlock(txq);
-		} else {
-			/* reschedule */
+	txq = netdev_get_tx_queue(txp->dev, txp->txqnum);
+	skb = skb_peek(&txp->tq);
+	if (!skb) {
+		if (!__netif_tx_trylock(txq))
 			goto resched;
-		}
+		skb_queue_splice_tail_init(&txp->rq, &txp->tq);
+		__netif_tx_unlock(txq);
 	}
 
-	while ((skb = __skb_dequeue(&dp->tq)) != NULL) {
+	while ((skb = __skb_dequeue(&txp->tq)) != NULL) {
 		u32 from = G_TC_FROM(skb->tc_verd);
 
 		skb->tc_verd = 0;
 		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
 
-		u64_stats_update_begin(&dp->tsync);
-		dp->tx_packets++;
-		dp->tx_bytes += skb->len;
-		u64_stats_update_end(&dp->tsync);
+		u64_stats_update_begin(&txp->tsync);
+		txp->tx_packets++;
+		txp->tx_bytes += skb->len;
+		u64_stats_update_end(&txp->tsync);
 
 		rcu_read_lock();
-		skb->dev = dev_get_by_index_rcu(dev_net(_dev), skb->skb_iif);
+		skb->dev = dev_get_by_index_rcu(dev_net(txp->dev), skb->skb_iif);
 		if (!skb->dev) {
 			rcu_read_unlock();
 			dev_kfree_skb(skb);
-			_dev->stats.tx_dropped++;
-			if (skb_queue_len(&dp->tq) != 0)
+			txp->dev->stats.tx_dropped++;
+			if (skb_queue_len(&txp->tq) != 0)
 				goto resched;
 			break;
 		}
 		rcu_read_unlock();
-		skb->skb_iif = _dev->ifindex;
+		skb->skb_iif = txp->dev->ifindex;
 
 		if (from & AT_EGRESS) {
 			dev_queue_xmit(skb);
@@ -112,10 +111,11 @@ static void ri_tasklet(unsigned long dev)
 	}
 
 	if (__netif_tx_trylock(txq)) {
-		if ((skb = skb_peek(&dp->rq)) == NULL) {
-			dp->tasklet_pending = 0;
-			if (netif_queue_stopped(_dev))
-				netif_wake_queue(_dev);
+		skb = skb_peek(&txp->rq);
+		if (!skb) {
+			txp->tasklet_pending = 0;
+			if (netif_tx_queue_stopped(txq))
+				netif_tx_wake_queue(txq);
 		} else {
 			__netif_tx_unlock(txq);
 			goto resched;
@@ -123,8 +123,8 @@ static void ri_tasklet(unsigned long dev)
 		__netif_tx_unlock(txq);
 	} else {
 resched:
-		dp->tasklet_pending = 1;
-		tasklet_schedule(&dp->ifb_tasklet);
+		txp->tasklet_pending = 1;
+		tasklet_schedule(&txp->ifb_tasklet);
 	}
 
 }
@@ -132,29 +132,58 @@ resched:
 static struct rtnl_link_stats64 *ifb_stats64(struct net_device *dev,
 					     struct rtnl_link_stats64 *stats)
 {
-	struct ifb_private *dp = netdev_priv(dev);
+	struct ifb_dev_private *dp = netdev_priv(dev);
+	struct ifb_q_private *txp = dp->tx_private;
 	unsigned int start;
-
-	do {
-		start = u64_stats_fetch_begin_irq(&dp->rsync);
-		stats->rx_packets = dp->rx_packets;
-		stats->rx_bytes = dp->rx_bytes;
-	} while (u64_stats_fetch_retry_irq(&dp->rsync, start));
-
-	do {
-		start = u64_stats_fetch_begin_irq(&dp->tsync);
-
-		stats->tx_packets = dp->tx_packets;
-		stats->tx_bytes = dp->tx_bytes;
-
-	} while (u64_stats_fetch_retry_irq(&dp->tsync, start));
-
+	u64 packets, bytes;
+	int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++,txp++) {
+		do {
+			start = u64_stats_fetch_begin_irq(&txp->rsync);
+			packets = txp->rx_packets;
+			bytes = txp->rx_bytes;
+		} while (u64_stats_fetch_retry_irq(&txp->rsync, start));
+		stats->rx_packets += packets;
+		stats->rx_bytes += bytes;
+
+		do {
+			start = u64_stats_fetch_begin_irq(&txp->tsync);
+			packets = txp->tx_packets;
+			bytes = txp->tx_bytes;
+		} while (u64_stats_fetch_retry_irq(&txp->tsync, start));
+		stats->tx_packets += packets;
+		stats->tx_bytes += bytes;
+	}
 	stats->rx_dropped = dev->stats.rx_dropped;
 	stats->tx_dropped = dev->stats.tx_dropped;
 
 	return stats;
 }
 
+static int ifb_dev_init(struct net_device *dev)
+{
+	struct ifb_dev_private *dp = netdev_priv(dev);
+	struct ifb_q_private *txp;
+	int i;
+
+	txp = kcalloc(dev->num_tx_queues, sizeof(*txp), GFP_KERNEL);
+	if (!txp)
+		return -ENOMEM;
+	dp->tx_private = txp;
+	for (i = 0; i < dev->num_tx_queues; i++,txp++) {
+		txp->txqnum = i;
+		txp->dev = dev;
+		__skb_queue_head_init(&txp->rq);
+		__skb_queue_head_init(&txp->tq);
+		u64_stats_init(&txp->rsync);
+		u64_stats_init(&txp->tsync);
+		tasklet_init(&txp->ifb_tasklet, ifb_ri_tasklet,
+			     (unsigned long)txp);
+		netif_tx_start_queue(netdev_get_tx_queue(dev, i));
+	}
+	return 0;
+}
 
 static const struct net_device_ops ifb_netdev_ops = {
 	.ndo_open	= ifb_open,
@@ -162,6 +191,7 @@ static const struct net_device_ops ifb_netdev_ops = {
 	.ndo_get_stats64 = ifb_stats64,
 	.ndo_start_xmit	= ifb_xmit,
 	.ndo_validate_addr = eth_validate_addr,
+	.ndo_init	= ifb_dev_init,
 };
 
 #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
@@ -169,10 +199,24 @@ static const struct net_device_ops ifb_netdev_ops = {
 		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_CTAG_TX		| \
 		      NETIF_F_HW_VLAN_STAG_TX)
 
+static void ifb_dev_free(struct net_device *dev)
+{
+	struct ifb_dev_private *dp = netdev_priv(dev);
+	struct ifb_q_private *txp = dp->tx_private;
+	int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++,txp++) {
+		tasklet_kill(&txp->ifb_tasklet);
+		__skb_queue_purge(&txp->rq);
+		__skb_queue_purge(&txp->tq);
+	}
+	kfree(dp->tx_private);
+	free_netdev(dev);
+}
+
 static void ifb_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
-	dev->destructor = free_netdev;
 	dev->netdev_ops = &ifb_netdev_ops;
 
 	/* Fill in device structure with ethernet-generic values. */
@@ -188,17 +232,19 @@ static void ifb_setup(struct net_device *dev)
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	netif_keep_dst(dev);
 	eth_hw_addr_random(dev);
+	dev->destructor = ifb_dev_free;
 }
 
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ifb_private *dp = netdev_priv(dev);
+	struct ifb_dev_private *dp = netdev_priv(dev);
 	u32 from = G_TC_FROM(skb->tc_verd);
+	struct ifb_q_private *txp = dp->tx_private + skb_get_queue_mapping(skb);
 
-	u64_stats_update_begin(&dp->rsync);
-	dp->rx_packets++;
-	dp->rx_bytes += skb->len;
-	u64_stats_update_end(&dp->rsync);
+	u64_stats_update_begin(&txp->rsync);
+	txp->rx_packets++;
+	txp->rx_bytes += skb->len;
+	u64_stats_update_end(&txp->rsync);
 
 	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
 		dev_kfree_skb(skb);
@@ -206,14 +252,13 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len) {
-		netif_stop_queue(dev);
-	}
+	if (skb_queue_len(&txp->rq) >= dev->tx_queue_len)
+		netif_tx_stop_queue(netdev_get_tx_queue(dev, txp->txqnum));
 
-	__skb_queue_tail(&dp->rq, skb);
-	if (!dp->tasklet_pending) {
-		dp->tasklet_pending = 1;
-		tasklet_schedule(&dp->ifb_tasklet);
+	__skb_queue_tail(&txp->rq, skb);
+	if (!txp->tasklet_pending) {
+		txp->tasklet_pending = 1;
+		tasklet_schedule(&txp->ifb_tasklet);
 	}
 
 	return NETDEV_TX_OK;
@@ -221,24 +266,13 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static int ifb_close(struct net_device *dev)
 {
-	struct ifb_private *dp = netdev_priv(dev);
-
-	tasklet_kill(&dp->ifb_tasklet);
-	netif_stop_queue(dev);
-	__skb_queue_purge(&dp->rq);
-	__skb_queue_purge(&dp->tq);
+	netif_tx_stop_all_queues(dev);
 	return 0;
 }
 
 static int ifb_open(struct net_device *dev)
 {
-	struct ifb_private *dp = netdev_priv(dev);
-
-	tasklet_init(&dp->ifb_tasklet, ri_tasklet, (unsigned long)dev);
-	__skb_queue_head_init(&dp->rq);
-	__skb_queue_head_init(&dp->tq);
-	netif_start_queue(dev);
-
+	netif_tx_start_all_queues(dev);
 	return 0;
 }
 
@@ -255,31 +289,30 @@ static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 	.kind		= "ifb",
-	.priv_size	= sizeof(struct ifb_private),
+	.priv_size	= sizeof(struct ifb_dev_private),
 	.setup		= ifb_setup,
 	.validate	= ifb_validate,
 };
 
-/* Number of ifb devices to be set up by this module. */
+/* Number of ifb devices to be set up by this module.
+ * Note that these legacy devices have one queue.
+ * Prefer something like : ip link add ifb10 numtxqueues 8 type ifb
+ */
+static int numifbs = 2;
 module_param(numifbs, int, 0);
 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
-	struct ifb_private *dp;
 	int err;
 
-	dev_ifb = alloc_netdev(sizeof(struct ifb_private), "ifb%d",
+	dev_ifb = alloc_netdev(sizeof(struct ifb_dev_private), "ifb%d",
 			       NET_NAME_UNKNOWN, ifb_setup);
 
 	if (!dev_ifb)
 		return -ENOMEM;
 
-	dp = netdev_priv(dev_ifb);
-	u64_stats_init(&dp->rsync);
-	u64_stats_init(&dp->tsync);
-
 	dev_ifb->rtnl_link_ops = &ifb_link_ops;
 	err = register_netdevice(dev_ifb);
 	if (err < 0)
