From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 3/3] net: mvpp2: replace TX coalescing interrupts with hrtimer
Date: Thu,  6 Aug 2015 19:00:30 +0200
Message-ID: <1438880430-5480-4-git-send-email-mw@semihalf.com>
References: <y>
 <1438880430-5480-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, jason@lakedaemon.net,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, alior@marvell.com,
	jaz@semihalf.com, Marcin Wojtas <mw@semihalf.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:35381 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbbHFRAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 13:00:55 -0400
Received: by labkb6 with SMTP id kb6so31077416lab.2
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 10:00:54 -0700 (PDT)
In-Reply-To: <1438880430-5480-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PP2 controller is capable of per-CPU TX processing, which means there are
per-CPU banked register sets and queues. Current version of the driver supports
TX packet coalescing - once on given CPU sent packets amount reaches a threshold
value, an IRQ occurs. However, there is a single interrupt line responsible for
CPU0/1 TX and RX events (the latter is not per-CPU, the hardware does not
support RSS).

When the top-half executes the interrupt cause is not known. This is why in
NAPI poll function, along with RX processing, IRQ cause register on both
CPU's is accessed in order to determine on which of them the TX coalescing
threshold might have been reached. Thus the egress processing and releasing the
buffers is able to take place on the corresponding CPU. Hitherto approach lead
to an illegal usage of on_each_cpu function in softirq context.

The problem is solved by resigning from TX coalescing interrupts and separating
egress finalization from NAPI processing. For that purpose a method of using
hrtimer is introduced. In main transmit function (mvpp2_tx) buffers are released
once a software coalescing threshold is reached. In case not all the data is
processed a timer is set on this CPU - in its interrupt context a tasklet is
scheduled in which all queues are processed. At once only one timer per-CPU can
be running, which is controlled by a dedicated flag.

This commit removes TX processing from NAPI polling function, disables hardware
coalescing and enables hrtimer with tasklet, using new per-CPU port structure
(mvpp2_port_pcpu).

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 177 +++++++++++++++++++++++++----------
 1 file changed, 130 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 3e25d314..d9884fd 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -27,6 +27,8 @@
 #include <linux/of_address.h>
 #include <linux/phy.h>
 #include <linux/clk.h>
+#include <linux/hrtimer.h>
+#include <linux/ktime.h>
 #include <uapi/linux/ppp_defs.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -299,6 +301,7 @@
 
 /* Coalescing */
 #define MVPP2_TXDONE_COAL_PKTS_THRESH	15
+#define MVPP2_TXDONE_HRTIMER_PERIOD_NS	1000000UL
 #define MVPP2_RX_COAL_PKTS		32
 #define MVPP2_RX_COAL_USEC		100
 
@@ -660,6 +663,14 @@ struct mvpp2_pcpu_stats {
 	u64	tx_bytes;
 };
 
+/* Per-CPU port control */
+struct mvpp2_port_pcpu {
+	struct hrtimer tx_done_timer;
+	bool timer_scheduled;
+	/* Tasklet for egress finalization */
+	struct tasklet_struct tx_done_tasklet;
+};
+
 struct mvpp2_port {
 	u8 id;
 
@@ -679,6 +690,9 @@ struct mvpp2_port {
 	u32 pending_cause_rx;
 	struct napi_struct napi;
 
+	/* Per-CPU port control */
+	struct mvpp2_port_pcpu __percpu *pcpu;
+
 	/* Flags */
 	unsigned long flags;
 
@@ -3798,7 +3812,6 @@ static void mvpp2_interrupts_unmask(void *arg)
 
 	mvpp2_write(port->priv, MVPP2_ISR_RX_TX_MASK_REG(port->id),
 		    (MVPP2_CAUSE_MISC_SUM_MASK |
-		     MVPP2_CAUSE_TXQ_OCCUP_DESC_ALL_MASK |
 		     MVPP2_CAUSE_RXQ_OCCUP_DESC_ALL_MASK));
 }
 
@@ -4374,23 +4387,6 @@ static void mvpp2_rx_time_coal_set(struct mvpp2_port *port,
 	rxq->time_coal = usec;
 }
 
-/* Set threshold for TX_DONE pkts coalescing */
-static void mvpp2_tx_done_pkts_coal_set(void *arg)
-{
-	struct mvpp2_port *port = arg;
-	int queue;
-	u32 val;
-
-	for (queue = 0; queue < txq_number; queue++) {
-		struct mvpp2_tx_queue *txq = port->txqs[queue];
-
-		val = (txq->done_pkts_coal << MVPP2_TRANSMITTED_THRESH_OFFSET) &
-		       MVPP2_TRANSMITTED_THRESH_MASK;
-		mvpp2_write(port->priv, MVPP2_TXQ_NUM_REG, txq->id);
-		mvpp2_write(port->priv, MVPP2_TXQ_THRESH_REG, val);
-	}
-}
-
 /* Free Tx queue skbuffs */
 static void mvpp2_txq_bufs_free(struct mvpp2_port *port,
 				struct mvpp2_tx_queue *txq,
@@ -4425,7 +4421,7 @@ static inline struct mvpp2_rx_queue *mvpp2_get_rx_queue(struct mvpp2_port *port,
 static inline struct mvpp2_tx_queue *mvpp2_get_tx_queue(struct mvpp2_port *port,
 							u32 cause)
 {
-	int queue = fls(cause >> 16) - 1;
+	int queue = fls(cause) - 1;
 
 	return port->txqs[queue];
 }
@@ -4452,6 +4448,29 @@ static void mvpp2_txq_done(struct mvpp2_port *port, struct mvpp2_tx_queue *txq,
 			netif_tx_wake_queue(nq);
 }
 
+static unsigned int mvpp2_tx_done(struct mvpp2_port *port, u32 cause)
+{
+	struct mvpp2_tx_queue *txq;
+	struct mvpp2_txq_pcpu *txq_pcpu;
+	unsigned int tx_todo = 0;
+
+	while (cause) {
+		txq = mvpp2_get_tx_queue(port, cause);
+		if (!txq)
+			break;
+
+		txq_pcpu = this_cpu_ptr(txq->pcpu);
+
+		if (txq_pcpu->count) {
+			mvpp2_txq_done(port, txq, txq_pcpu);
+			tx_todo += txq_pcpu->count;
+		}
+
+		cause &= ~(1 << txq->log_id);
+	}
+	return tx_todo;
+}
+
 /* Rx/Tx queue initialization/cleanup methods */
 
 /* Allocate and initialize descriptors for aggr TXQ */
@@ -4812,7 +4831,6 @@ static int mvpp2_setup_txqs(struct mvpp2_port *port)
 			goto err_cleanup;
 	}
 
-	on_each_cpu(mvpp2_tx_done_pkts_coal_set, port, 1);
 	on_each_cpu(mvpp2_txq_sent_counter_clear, port, 1);
 	return 0;
 
@@ -4894,6 +4912,49 @@ static void mvpp2_link_event(struct net_device *dev)
 	}
 }
 
+static void mvpp2_timer_set(struct mvpp2_port_pcpu *port_pcpu)
+{
+	ktime_t interval;
+
+	if (!port_pcpu->timer_scheduled) {
+		port_pcpu->timer_scheduled = true;
+		interval = ktime_set(0, MVPP2_TXDONE_HRTIMER_PERIOD_NS);
+		hrtimer_start(&port_pcpu->tx_done_timer, interval,
+			      HRTIMER_MODE_REL_PINNED);
+	}
+}
+
+static void mvpp2_tx_proc_cb(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct mvpp2_port *port = netdev_priv(dev);
+	struct mvpp2_port_pcpu *port_pcpu = this_cpu_ptr(port->pcpu);
+	unsigned int tx_todo, cause;
+
+	if (!netif_running(dev))
+		return;
+	port_pcpu->timer_scheduled = false;
+
+	/* Process all the Tx queues */
+	cause = (1 << txq_number) - 1;
+	tx_todo = mvpp2_tx_done(port, cause);
+
+	/* Set the timer in case not all the packets were processed */
+	if (tx_todo)
+		mvpp2_timer_set(port_pcpu);
+}
+
+static enum hrtimer_restart mvpp2_hr_timer_cb(struct hrtimer *timer)
+{
+	struct mvpp2_port_pcpu *port_pcpu = container_of(timer,
+							 struct mvpp2_port_pcpu,
+							 tx_done_timer);
+
+	tasklet_schedule(&port_pcpu->tx_done_tasklet);
+
+	return HRTIMER_NORESTART;
+}
+
 /* Main RX/TX processing routines */
 
 /* Display more error info */
@@ -5262,6 +5323,17 @@ out:
 		dev_kfree_skb_any(skb);
 	}
 
+	/* Finalize TX processing */
+	if (txq_pcpu->count >= txq->done_pkts_coal)
+		mvpp2_txq_done(port, txq, txq_pcpu);
+
+	/* Set the timer in case not all frags were processed */
+	if (txq_pcpu->count <= frags && txq_pcpu->count > 0) {
+		struct mvpp2_port_pcpu *port_pcpu = this_cpu_ptr(port->pcpu);
+
+		mvpp2_timer_set(port_pcpu);
+	}
+
 	return NETDEV_TX_OK;
 }
 
@@ -5275,10 +5347,11 @@ static inline void mvpp2_cause_error(struct net_device *dev, int cause)
 		netdev_err(dev, "tx fifo underrun error\n");
 }
 
-static void mvpp2_txq_done_percpu(void *arg)
+static int mvpp2_poll(struct napi_struct *napi, int budget)
 {
-	struct mvpp2_port *port = arg;
-	u32 cause_rx_tx, cause_tx, cause_misc;
+	u32 cause_rx_tx, cause_rx, cause_misc;
+	int rx_done = 0;
+	struct mvpp2_port *port = netdev_priv(napi->dev);
 
 	/* Rx/Tx cause register
 	 *
@@ -5292,7 +5365,7 @@ static void mvpp2_txq_done_percpu(void *arg)
 	 */
 	cause_rx_tx = mvpp2_read(port->priv,
 				 MVPP2_ISR_RX_TX_CAUSE_REG(port->id));
-	cause_tx = cause_rx_tx & MVPP2_CAUSE_TXQ_OCCUP_DESC_ALL_MASK;
+	cause_rx_tx &= ~MVPP2_CAUSE_TXQ_OCCUP_DESC_ALL_MASK;
 	cause_misc = cause_rx_tx & MVPP2_CAUSE_MISC_SUM_MASK;
 
 	if (cause_misc) {
@@ -5304,26 +5377,6 @@ static void mvpp2_txq_done_percpu(void *arg)
 			    cause_rx_tx & ~MVPP2_CAUSE_MISC_SUM_MASK);
 	}
 
-	/* Release TX descriptors */
-	if (cause_tx) {
-		struct mvpp2_tx_queue *txq = mvpp2_get_tx_queue(port, cause_tx);
-		struct mvpp2_txq_pcpu *txq_pcpu = this_cpu_ptr(txq->pcpu);
-
-		if (txq_pcpu->count)
-			mvpp2_txq_done(port, txq, txq_pcpu);
-	}
-}
-
-static int mvpp2_poll(struct napi_struct *napi, int budget)
-{
-	u32 cause_rx_tx, cause_rx;
-	int rx_done = 0;
-	struct mvpp2_port *port = netdev_priv(napi->dev);
-
-	on_each_cpu(mvpp2_txq_done_percpu, port, 1);
-
-	cause_rx_tx = mvpp2_read(port->priv,
-				 MVPP2_ISR_RX_TX_CAUSE_REG(port->id));
 	cause_rx = cause_rx_tx & MVPP2_CAUSE_RXQ_OCCUP_DESC_ALL_MASK;
 
 	/* Process RX packets */
@@ -5568,6 +5621,8 @@ err_cleanup_rxqs:
 static int mvpp2_stop(struct net_device *dev)
 {
 	struct mvpp2_port *port = netdev_priv(dev);
+	struct mvpp2_port_pcpu *port_pcpu;
+	int cpu;
 
 	mvpp2_stop_dev(port);
 	mvpp2_phy_disconnect(port);
@@ -5576,6 +5631,13 @@ static int mvpp2_stop(struct net_device *dev)
 	on_each_cpu(mvpp2_interrupts_mask, port, 1);
 
 	free_irq(port->irq, port);
+	for_each_present_cpu(cpu) {
+		port_pcpu = per_cpu_ptr(port->pcpu, cpu);
+
+		hrtimer_cancel(&port_pcpu->tx_done_timer);
+		port_pcpu->timer_scheduled = false;
+		tasklet_kill(&port_pcpu->tx_done_tasklet);
+	}
 	mvpp2_cleanup_rxqs(port);
 	mvpp2_cleanup_txqs(port);
 
@@ -5791,7 +5853,6 @@ static int mvpp2_ethtool_set_coalesce(struct net_device *dev,
 		txq->done_pkts_coal = c->tx_max_coalesced_frames;
 	}
 
-	on_each_cpu(mvpp2_tx_done_pkts_coal_set, port, 1);
 	return 0;
 }
 
@@ -6042,6 +6103,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 {
 	struct device_node *phy_node;
 	struct mvpp2_port *port;
+	struct mvpp2_port_pcpu *port_pcpu;
 	struct net_device *dev;
 	struct resource *res;
 	const char *dt_mac_addr;
@@ -6051,7 +6113,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	int features;
 	int phy_mode;
 	int priv_common_regs_num = 2;
-	int err, i;
+	int err, i, cpu;
 
 	dev = alloc_etherdev_mqs(sizeof(struct mvpp2_port), txq_number,
 				 rxq_number);
@@ -6142,6 +6204,24 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	}
 	mvpp2_port_power_up(port);
 
+	port->pcpu = alloc_percpu(struct mvpp2_port_pcpu);
+	if (!port->pcpu) {
+		err = -ENOMEM;
+		goto err_free_txq_pcpu;
+	}
+
+	for_each_present_cpu(cpu) {
+		port_pcpu = per_cpu_ptr(port->pcpu, cpu);
+
+		hrtimer_init(&port_pcpu->tx_done_timer, CLOCK_MONOTONIC,
+			     HRTIMER_MODE_REL_PINNED);
+		port_pcpu->tx_done_timer.function = mvpp2_hr_timer_cb;
+		port_pcpu->timer_scheduled = false;
+
+		tasklet_init(&port_pcpu->tx_done_tasklet, mvpp2_tx_proc_cb,
+			     (unsigned long)dev);
+	}
+
 	netif_napi_add(dev, &port->napi, mvpp2_poll, NAPI_POLL_WEIGHT);
 	features = NETIF_F_SG | NETIF_F_IP_CSUM;
 	dev->features = features | NETIF_F_RXCSUM;
@@ -6151,7 +6231,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	err = register_netdev(dev);
 	if (err < 0) {
 		dev_err(&pdev->dev, "failed to register netdev\n");
-		goto err_free_txq_pcpu;
+		goto err_free_port_pcpu;
 	}
 	netdev_info(dev, "Using %s mac address %pM\n", mac_from, dev->dev_addr);
 
@@ -6160,6 +6240,8 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	priv->port_list[id] = port;
 	return 0;
 
+err_free_port_pcpu:
+	free_percpu(port->pcpu);
 err_free_txq_pcpu:
 	for (i = 0; i < txq_number; i++)
 		free_percpu(port->txqs[i]->pcpu);
@@ -6178,6 +6260,7 @@ static void mvpp2_port_remove(struct mvpp2_port *port)
 	int i;
 
 	unregister_netdev(port->dev);
+	free_percpu(port->pcpu);
 	free_percpu(port->stats);
 	for (i = 0; i < txq_number; i++)
 		free_percpu(port->txqs[i]->pcpu);
-- 
1.8.3.1
