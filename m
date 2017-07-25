From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 3/8] net: mvpp2: introduce per-port nrxqs/ntxqs variables
Date: Tue, 25 Jul 2017 17:55:04 +0200
Message-ID: <20170725155509.10574-4-thomas.petazzoni@free-electrons.com>
References: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Cc: Russell King <linux@arm.linux.org.uk>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:60423 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752568AbdGYPzc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 11:55:32 -0400
In-Reply-To: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the global variables rxq_number and txq_number hold the
number of per-port TXQs and RXQs. Until now, such numbers were
constant regardless of the driver configuration. As we are going to
introduce different modes for TX and RX queues, these numbers will
depend on the configuration (PPv2.1 vs. PPv2.2, exact queue
distribution logic).

Therefore, as a preparation, we move the number of RXQs and TXQs in
the 'struct mvpp2_port' structure, next to the RXQs and TXQs
descriptor arrays.

For now, they remain initialized to the same default values as
rxq_number/txq_number used to be initialized, but this will change in
future commits.

The only non-mechanical change in this patch is that the check to
verify hardware constraints on the number of RXQs and TXQs is moved
from mvpp2_probe() to mvpp2_port_probe(), since it's now in
mvpp2_port_probe() that we initialize the per-port count of RXQ and
TXQ.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 83 ++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index eb8853f..8479269 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -837,7 +837,9 @@ struct mvpp2_port {
 	void __iomem *base;
 
 	struct mvpp2_rx_queue **rxqs;
+	unsigned int nrxqs;
 	struct mvpp2_tx_queue **txqs;
+	unsigned int ntxqs;
 	struct net_device *dev;
 
 	int pkt_size;
@@ -1131,13 +1133,6 @@ struct mvpp2_bm_pool {
 	u32 port_map;
 };
 
-/* Static declaractions */
-
-/* Number of RXQs used by single port */
-static int rxq_number = MVPP2_DEFAULT_RXQ;
-/* Number of TXQs used by single port */
-static int txq_number = MVPP2_MAX_TXQ;
-
 #define MVPP2_DRIVER_NAME "mvpp2"
 #define MVPP2_DRIVER_VERSION "1.0"
 
@@ -4139,7 +4134,7 @@ static int mvpp2_swf_bm_pool_init(struct mvpp2_port *port)
 
 		port->pool_long->port_map |= (1 << port->id);
 
-		for (rxq = 0; rxq < rxq_number; rxq++)
+		for (rxq = 0; rxq < port->nrxqs; rxq++)
 			mvpp2_rxq_long_pool_set(port, rxq, port->pool_long->id);
 	}
 
@@ -4153,7 +4148,7 @@ static int mvpp2_swf_bm_pool_init(struct mvpp2_port *port)
 
 		port->pool_short->port_map |= (1 << port->id);
 
-		for (rxq = 0; rxq < rxq_number; rxq++)
+		for (rxq = 0; rxq < port->nrxqs; rxq++)
 			mvpp2_rxq_short_pool_set(port, rxq,
 						 port->pool_short->id);
 	}
@@ -4678,7 +4673,7 @@ static void mvpp2_defaults_set(struct mvpp2_port *port)
 		    MVPP2_RX_LOW_LATENCY_PKT_SIZE(256));
 
 	/* Enable Rx cache snoop */
-	for (lrxq = 0; lrxq < rxq_number; lrxq++) {
+	for (lrxq = 0; lrxq < port->nrxqs; lrxq++) {
 		queue = port->rxqs[lrxq]->id;
 		val = mvpp2_read(port->priv, MVPP2_RXQ_CONFIG_REG(queue));
 		val |= MVPP2_SNOOP_PKT_SIZE_MASK |
@@ -4696,7 +4691,7 @@ static void mvpp2_ingress_enable(struct mvpp2_port *port)
 	u32 val;
 	int lrxq, queue;
 
-	for (lrxq = 0; lrxq < rxq_number; lrxq++) {
+	for (lrxq = 0; lrxq < port->nrxqs; lrxq++) {
 		queue = port->rxqs[lrxq]->id;
 		val = mvpp2_read(port->priv, MVPP2_RXQ_CONFIG_REG(queue));
 		val &= ~MVPP2_RXQ_DISABLE_MASK;
@@ -4709,7 +4704,7 @@ static void mvpp2_ingress_disable(struct mvpp2_port *port)
 	u32 val;
 	int lrxq, queue;
 
-	for (lrxq = 0; lrxq < rxq_number; lrxq++) {
+	for (lrxq = 0; lrxq < port->nrxqs; lrxq++) {
 		queue = port->rxqs[lrxq]->id;
 		val = mvpp2_read(port->priv, MVPP2_RXQ_CONFIG_REG(queue));
 		val |= MVPP2_RXQ_DISABLE_MASK;
@@ -4728,7 +4723,7 @@ static void mvpp2_egress_enable(struct mvpp2_port *port)
 
 	/* Enable all initialized TXs. */
 	qmap = 0;
-	for (queue = 0; queue < txq_number; queue++) {
+	for (queue = 0; queue < port->ntxqs; queue++) {
 		struct mvpp2_tx_queue *txq = port->txqs[queue];
 
 		if (txq->descs)
@@ -5014,7 +5009,7 @@ static void mvpp2_txq_sent_counter_clear(void *arg)
 	struct mvpp2_port *port = arg;
 	int queue;
 
-	for (queue = 0; queue < txq_number; queue++) {
+	for (queue = 0; queue < port->ntxqs; queue++) {
 		int id = port->txqs[queue]->id;
 
 		mvpp2_percpu_read(port->priv, smp_processor_id(),
@@ -5055,7 +5050,7 @@ static void mvpp2_txp_max_tx_size_set(struct mvpp2_port *port)
 		mvpp2_write(port->priv, MVPP2_TXP_SCHED_TOKEN_SIZE_REG, val);
 	}
 
-	for (txq = 0; txq < txq_number; txq++) {
+	for (txq = 0; txq < port->ntxqs; txq++) {
 		val = mvpp2_read(port->priv,
 				 MVPP2_TXQ_SCHED_TOKEN_SIZE_REG(txq));
 		size = val & MVPP2_TXQ_TOKEN_SIZE_MAX;
@@ -5531,7 +5526,7 @@ static void mvpp2_cleanup_txqs(struct mvpp2_port *port)
 	val |= MVPP2_TX_PORT_FLUSH_MASK(port->id);
 	mvpp2_write(port->priv, MVPP2_TX_PORT_FLUSH_REG, val);
 
-	for (queue = 0; queue < txq_number; queue++) {
+	for (queue = 0; queue < port->ntxqs; queue++) {
 		txq = port->txqs[queue];
 		mvpp2_txq_clean(port, txq);
 		mvpp2_txq_deinit(port, txq);
@@ -5548,7 +5543,7 @@ static void mvpp2_cleanup_rxqs(struct mvpp2_port *port)
 {
 	int queue;
 
-	for (queue = 0; queue < rxq_number; queue++)
+	for (queue = 0; queue < port->nrxqs; queue++)
 		mvpp2_rxq_deinit(port, port->rxqs[queue]);
 }
 
@@ -5557,7 +5552,7 @@ static int mvpp2_setup_rxqs(struct mvpp2_port *port)
 {
 	int queue, err;
 
-	for (queue = 0; queue < rxq_number; queue++) {
+	for (queue = 0; queue < port->nrxqs; queue++) {
 		err = mvpp2_rxq_init(port, port->rxqs[queue]);
 		if (err)
 			goto err_cleanup;
@@ -5575,7 +5570,7 @@ static int mvpp2_setup_txqs(struct mvpp2_port *port)
 	struct mvpp2_tx_queue *txq;
 	int queue, err;
 
-	for (queue = 0; queue < txq_number; queue++) {
+	for (queue = 0; queue < port->ntxqs; queue++) {
 		txq = port->txqs[queue];
 		err = mvpp2_txq_init(port, txq);
 		if (err)
@@ -5741,7 +5736,7 @@ static void mvpp2_tx_proc_cb(unsigned long data)
 	port_pcpu->timer_scheduled = false;
 
 	/* Process all the Tx queues */
-	cause = (1 << txq_number) - 1;
+	cause = (1 << port->ntxqs) - 1;
 	tx_todo = mvpp2_tx_done(port, cause);
 
 	/* Set the timer in case not all the packets were processed */
@@ -6624,7 +6619,7 @@ static int mvpp2_ethtool_set_coalesce(struct net_device *dev,
 	struct mvpp2_port *port = netdev_priv(dev);
 	int queue;
 
-	for (queue = 0; queue < rxq_number; queue++) {
+	for (queue = 0; queue < port->nrxqs; queue++) {
 		struct mvpp2_rx_queue *rxq = port->rxqs[queue];
 
 		rxq->time_coal = c->rx_coalesce_usecs;
@@ -6633,7 +6628,7 @@ static int mvpp2_ethtool_set_coalesce(struct net_device *dev,
 		mvpp2_rx_time_coal_set(port, rxq);
 	}
 
-	for (queue = 0; queue < txq_number; queue++) {
+	for (queue = 0; queue < port->ntxqs; queue++) {
 		struct mvpp2_tx_queue *txq = port->txqs[queue];
 
 		txq->done_pkts_coal = c->tx_max_coalesced_frames;
@@ -6769,15 +6764,20 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	struct mvpp2_txq_pcpu *txq_pcpu;
 	int queue, cpu, err;
 
-	if (port->first_rxq + rxq_number >
+	/* Checks for hardware constraints */
+	if (port->first_rxq + port->nrxqs >
 	    MVPP2_MAX_PORTS * priv->max_port_rxqs)
 		return -EINVAL;
 
+	if (port->nrxqs % 4 || (port->nrxqs > priv->max_port_rxqs) ||
+	    (port->ntxqs > MVPP2_MAX_TXQ))
+		return -EINVAL;
+
 	/* Disable port */
 	mvpp2_egress_disable(port);
 	mvpp2_port_disable(port);
 
-	port->txqs = devm_kcalloc(dev, txq_number, sizeof(*port->txqs),
+	port->txqs = devm_kcalloc(dev, port->ntxqs, sizeof(*port->txqs),
 				  GFP_KERNEL);
 	if (!port->txqs)
 		return -ENOMEM;
@@ -6785,7 +6785,7 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	/* Associate physical Tx queues to this port and initialize.
 	 * The mapping is predefined.
 	 */
-	for (queue = 0; queue < txq_number; queue++) {
+	for (queue = 0; queue < port->ntxqs; queue++) {
 		int queue_phy_id = mvpp2_txq_phys(port->id, queue);
 		struct mvpp2_tx_queue *txq;
 
@@ -6812,7 +6812,7 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 		port->txqs[queue] = txq;
 	}
 
-	port->rxqs = devm_kcalloc(dev, rxq_number, sizeof(*port->rxqs),
+	port->rxqs = devm_kcalloc(dev, port->nrxqs, sizeof(*port->rxqs),
 				  GFP_KERNEL);
 	if (!port->rxqs) {
 		err = -ENOMEM;
@@ -6820,7 +6820,7 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	}
 
 	/* Allocate and initialize Rx queue for this port */
-	for (queue = 0; queue < rxq_number; queue++) {
+	for (queue = 0; queue < port->nrxqs; queue++) {
 		struct mvpp2_rx_queue *rxq;
 
 		/* Map physical Rx queue to port's logical Rx queue */
@@ -6840,19 +6840,19 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	/* Configure Rx queue group interrupt for this port */
 	if (priv->hw_version == MVPP21) {
 		mvpp2_write(priv, MVPP21_ISR_RXQ_GROUP_REG(port->id),
-			    rxq_number);
+			    port->nrxqs);
 	} else {
 		u32 val;
 
 		val = (port->id << MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_OFFSET);
 		mvpp2_write(priv, MVPP22_ISR_RXQ_GROUP_INDEX_REG, val);
 
-		val = (rxq_number << MVPP22_ISR_RXQ_SUB_GROUP_SIZE_OFFSET);
+		val = (port->nrxqs << MVPP22_ISR_RXQ_SUB_GROUP_SIZE_OFFSET);
 		mvpp2_write(priv, MVPP22_ISR_RXQ_SUB_GROUP_CONFIG_REG, val);
 	}
 
 	/* Create Rx descriptor rings */
-	for (queue = 0; queue < rxq_number; queue++) {
+	for (queue = 0; queue < port->nrxqs; queue++) {
 		struct mvpp2_rx_queue *rxq = port->rxqs[queue];
 
 		rxq->size = port->rx_ring_size;
@@ -6880,7 +6880,7 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	return 0;
 
 err_free_percpu:
-	for (queue = 0; queue < txq_number; queue++) {
+	for (queue = 0; queue < port->ntxqs; queue++) {
 		if (!port->txqs[queue])
 			continue;
 		free_percpu(port->txqs[queue]->pcpu);
@@ -6901,12 +6901,16 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	const char *dt_mac_addr;
 	const char *mac_from;
 	char hw_mac_addr[ETH_ALEN];
+	unsigned int ntxqs, nrxqs;
 	u32 id;
 	int features;
 	int phy_mode;
 	int err, i, cpu;
 
-	dev = alloc_etherdev_mqs(sizeof(*port), txq_number, rxq_number);
+	ntxqs = MVPP2_MAX_TXQ;
+	nrxqs = MVPP2_DEFAULT_RXQ;
+
+	dev = alloc_etherdev_mqs(sizeof(*port), ntxqs, nrxqs);
 	if (!dev)
 		return -ENOMEM;
 
@@ -6930,6 +6934,8 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	dev->ethtool_ops = &mvpp2_eth_tool_ops;
 
 	port = netdev_priv(dev);
+	port->ntxqs = ntxqs;
+	port->nrxqs = nrxqs;
 
 	if (of_get_property(port_node, "interrupt-names", NULL)) {
 		port->irq = of_irq_get_byname(port_node, "rx-shared");
@@ -6962,7 +6968,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	port->priv = priv;
 	port->id = id;
 	if (priv->hw_version == MVPP21)
-		port->first_rxq = port->id * rxq_number;
+		port->first_rxq = port->id * port->nrxqs;
 	else
 		port->first_rxq = port->id * priv->max_port_rxqs;
 
@@ -7070,7 +7076,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 err_free_port_pcpu:
 	free_percpu(port->pcpu);
 err_free_txq_pcpu:
-	for (i = 0; i < txq_number; i++)
+	for (i = 0; i < port->ntxqs; i++)
 		free_percpu(port->txqs[i]->pcpu);
 err_free_stats:
 	free_percpu(port->stats);
@@ -7091,7 +7097,7 @@ static void mvpp2_port_remove(struct mvpp2_port *port)
 	of_node_put(port->phy_node);
 	free_percpu(port->pcpu);
 	free_percpu(port->stats);
-	for (i = 0; i < txq_number; i++)
+	for (i = 0; i < port->ntxqs; i++)
 		free_percpu(port->txqs[i]->pcpu);
 	irq_dispose_mapping(port->irq);
 	free_netdev(port->dev);
@@ -7208,13 +7214,6 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	int err, i;
 	u32 val;
 
-	/* Checks for hardware constraints */
-	if (rxq_number % 4 || (rxq_number > priv->max_port_rxqs) ||
-	    (txq_number > MVPP2_MAX_TXQ)) {
-		dev_err(&pdev->dev, "invalid queue size parameter\n");
-		return -EINVAL;
-	}
-
 	/* MBUS windows configuration */
 	dram_target_info = mv_mbus_dram_info();
 	if (dram_target_info)
-- 
2.9.4
