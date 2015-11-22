From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 06/13] net: mvneta: enable mixed egress processing using HR timer
Date: Sun, 22 Nov 2015 08:53:52 +0100
Message-ID: <1448178839-3541-7-git-send-email-mw@semihalf.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mixed approach allows using higher interrupt threshold (increased back to
15 packets), useful in high throughput. In case of small amount of data
or very short TX queues HR timer ensures releasing buffers with small
latency.

Along with existing tx_done processing by coalescing interrupts this
commit enables triggering HR timer each time the packets are sent.
Time threshold can also be configured, using ethtool.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
---
 drivers/net/ethernet/marvell/mvneta.c | 89 +++++++++++++++++++++++++++++++++--
 1 file changed, 85 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 9c9e858..f5acaf6 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -21,6 +21,8 @@
 #include <linux/module.h>
 #include <linux/interrupt.h>
 #include <linux/if_vlan.h>
+#include <linux/hrtimer.h>
+#include <linux/ktime.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <linux/io.h>
@@ -226,7 +228,8 @@
 /* Various constants */
 
 /* Coalescing */
-#define MVNETA_TXDONE_COAL_PKTS		1
+#define MVNETA_TXDONE_COAL_PKTS		15
+#define MVNETA_TXDONE_COAL_USEC		100
 #define MVNETA_RX_COAL_PKTS		32
 #define MVNETA_RX_COAL_USEC		100
 
@@ -356,6 +359,11 @@ struct mvneta_port {
 	struct net_device *dev;
 	struct notifier_block cpu_notifier;
 
+	/* Egress finalization */
+	struct tasklet_struct tx_done_tasklet;
+	struct hrtimer tx_done_timer;
+	bool timer_scheduled;
+
 	/* Core clock */
 	struct clk *clk;
 	u8 mcast_count[256];
@@ -481,6 +489,7 @@ struct mvneta_tx_queue {
 	int txq_get_index;
 
 	u32 done_pkts_coal;
+	u32 done_time_coal;
 
 	/* Virtual address of the TX DMA descriptors array */
 	struct mvneta_tx_desc *descs;
@@ -1791,6 +1800,30 @@ error:
 	return -ENOMEM;
 }
 
+/* Trigger HR timer for TX processing */
+static void mvneta_timer_set(struct mvneta_port *pp)
+{
+	ktime_t interval;
+
+	if (!pp->timer_scheduled) {
+		pp->timer_scheduled = true;
+		interval = ktime_set(0, pp->txqs[0].done_time_coal * 1000);
+		hrtimer_start(&pp->tx_done_timer, interval,
+			      HRTIMER_MODE_REL_PINNED);
+	}
+}
+
+/* TX processing HR timer callback */
+static enum hrtimer_restart mvneta_hr_timer_cb(struct hrtimer *timer)
+{
+	struct mvneta_port *pp = container_of(timer, struct mvneta_port,
+					      tx_done_timer);
+
+	tasklet_schedule(&pp->tx_done_tasklet);
+
+	return HRTIMER_NORESTART;
+}
+
 /* Main tx processing */
 static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 {
@@ -1862,10 +1895,13 @@ out:
 		if (txq->count >= txq->tx_stop_threshold)
 			netif_tx_stop_queue(nq);
 
-		if (!skb->xmit_more || netif_xmit_stopped(nq))
+		if (!skb->xmit_more || netif_xmit_stopped(nq)) {
 			mvneta_txq_pend_desc_add(pp, txq, frags);
-		else
+			if (txq->done_time_coal && !pp->timer_scheduled)
+				mvneta_timer_set(pp);
+		} else {
 			txq->pending += frags;
+		}
 
 		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
@@ -1902,6 +1938,7 @@ static void mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done)
 {
 	struct mvneta_tx_queue *txq;
 	struct netdev_queue *nq;
+	unsigned int tx_todo = 0;
 
 	while (cause_tx_done) {
 		txq = mvneta_tx_done_policy(pp, cause_tx_done);
@@ -1909,12 +1946,40 @@ static void mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done)
 		nq = netdev_get_tx_queue(pp->dev, txq->id);
 		__netif_tx_lock(nq, smp_processor_id());
 
-		if (txq->count)
+		if (txq->count) {
 			mvneta_txq_done(pp, txq);
+			tx_todo += txq->count;
+		}
 
 		__netif_tx_unlock(nq);
 		cause_tx_done &= ~((1 << txq->id));
 	}
+
+	if (!pp->txqs[0].done_time_coal)
+		return;
+
+	/* Set the timer in case not all the packets were
+	 * processed. Otherwise attempt to cancel timer.
+	 */
+	if (tx_todo)
+		mvneta_timer_set(pp);
+	else if (pp->timer_scheduled)
+		hrtimer_cancel(&pp->tx_done_timer);
+}
+
+/* TX done processing tasklet */
+static void mvneta_tx_done_proc(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return;
+
+	pp->timer_scheduled = false;
+
+	/* Process all Tx queues */
+	mvneta_tx_done_gbe(pp, (1 << txq_number) - 1);
 }
 
 /* Compute crc8 of the specified address, using a unique algorithm ,
@@ -2910,6 +2975,11 @@ static int mvneta_stop(struct net_device *dev)
 	for_each_present_cpu(cpu)
 		smp_call_function_single(cpu, mvneta_percpu_disable, pp, true);
 	free_percpu_irq(dev->irq, pp->ports);
+
+	hrtimer_cancel(&pp->tx_done_timer);
+	pp->timer_scheduled = false;
+	tasklet_kill(&pp->tx_done_tasklet);
+
 	mvneta_cleanup_rxqs(pp);
 	mvneta_cleanup_txqs(pp);
 
@@ -2967,6 +3037,7 @@ static int mvneta_ethtool_set_coalesce(struct net_device *dev,
 
 	for (queue = 0; queue < txq_number; queue++) {
 		struct mvneta_tx_queue *txq = &pp->txqs[queue];
+		txq->done_time_coal = c->tx_coalesce_usecs;
 		txq->done_pkts_coal = c->tx_max_coalesced_frames;
 		mvneta_tx_done_pkts_coal_set(pp, txq, txq->done_pkts_coal);
 	}
@@ -2983,6 +3054,7 @@ static int mvneta_ethtool_get_coalesce(struct net_device *dev,
 	c->rx_coalesce_usecs        = pp->rxqs[0].time_coal;
 	c->rx_max_coalesced_frames  = pp->rxqs[0].pkts_coal;
 
+	c->tx_coalesce_usecs = pp->txqs[0].done_time_coal;
 	c->tx_max_coalesced_frames =  pp->txqs[0].done_pkts_coal;
 	return 0;
 }
@@ -3146,6 +3218,7 @@ static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 		txq->id = queue;
 		txq->size = pp->tx_ring_size;
 		txq->done_pkts_coal = MVNETA_TXDONE_COAL_PKTS;
+		txq->done_time_coal = MVNETA_TXDONE_COAL_USEC;
 	}
 
 	pp->rxqs = devm_kcalloc(dev, rxq_number, sizeof(struct mvneta_rx_queue),
@@ -3388,6 +3461,14 @@ static int mvneta_probe(struct platform_device *pdev)
 		port->pp = pp;
 	}
 
+	hrtimer_init(&pp->tx_done_timer, CLOCK_MONOTONIC,
+		     HRTIMER_MODE_REL_PINNED);
+	pp->tx_done_timer.function = mvneta_hr_timer_cb;
+	pp->timer_scheduled = false;
+
+	tasklet_init(&pp->tx_done_tasklet, mvneta_tx_done_proc,
+		     (unsigned long)dev);
+
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
 	dev->vlan_features |= dev->features;
-- 
1.8.3.1
