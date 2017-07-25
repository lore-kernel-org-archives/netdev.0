From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 5/8] net: mvpp2: introduce queue_vector concept
Date: Tue, 25 Jul 2017 17:55:06 +0200
Message-ID: <20170725155509.10574-6-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([62.4.15.54]:60460 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbdGYPzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 11:55:41 -0400
In-Reply-To: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to the introduction of TX interrupts and improved RX
queue distribution, this commit introduces the concept of "queue
vector". A queue vector represents a number of RX and/or TX queues,
and an associated NAPI instance and interrupt.

This commit currently only creates a single queue_vector, so there are
no changes in behavior, but it paves the way for additional
queue_vector in the next commits.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 250 +++++++++++++++++++++++++----------
 1 file changed, 178 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 7d37869..a8d448b 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -749,6 +749,7 @@ enum mvpp2_prs_l3_cast {
 #define MVPP22_ADDR_SPACE_SZ		SZ_64K
 
 #define MVPP2_MAX_THREADS		8
+#define MVPP2_MAX_QVECS			MVPP2_MAX_THREADS
 
 enum mvpp2_bm_type {
 	MVPP2_BM_FREE,
@@ -821,6 +822,18 @@ struct mvpp2_port_pcpu {
 	struct tasklet_struct tx_done_tasklet;
 };
 
+struct mvpp2_queue_vector {
+	int irq;
+	struct napi_struct napi;
+	enum { MVPP2_QUEUE_VECTOR_SHARED, MVPP2_QUEUE_VECTOR_PRIVATE } type;
+	int sw_thread_id;
+	u16 sw_thread_mask;
+	int first_rxq;
+	int nrxqs;
+	u32 pending_cause_rx;
+	struct mvpp2_port *port;
+};
+
 struct mvpp2_port {
 	u8 id;
 
@@ -829,7 +842,6 @@ struct mvpp2_port {
 	 */
 	int gop_id;
 
-	int irq;
 	int link_irq;
 
 	struct mvpp2 *priv;
@@ -845,9 +857,6 @@ struct mvpp2_port {
 
 	int pkt_size;
 
-	u32 pending_cause_rx;
-	struct napi_struct napi;
-
 	/* Per-CPU port control */
 	struct mvpp2_port_pcpu __percpu *pcpu;
 
@@ -869,6 +878,9 @@ struct mvpp2_port {
 
 	/* Index of first port's physical RXQ */
 	u8 first_rxq;
+
+	struct mvpp2_queue_vector qvecs[MVPP2_MAX_QVECS];
+	unsigned int nqvecs;
 };
 
 /* The mvpp2_tx_desc and mvpp2_rx_desc structures describe the
@@ -4190,22 +4202,40 @@ static int mvpp2_bm_update_mtu(struct net_device *dev, int mtu)
 
 static inline void mvpp2_interrupts_enable(struct mvpp2_port *port)
 {
-	int cpu, cpu_mask = 0;
+	int i, sw_thread_mask = 0;
+
+	for (i = 0; i < port->nqvecs; i++)
+		sw_thread_mask |= port->qvecs[i].sw_thread_mask;
 
-	for_each_present_cpu(cpu)
-		cpu_mask |= 1 << cpu;
 	mvpp2_write(port->priv, MVPP2_ISR_ENABLE_REG(port->id),
-		    MVPP2_ISR_ENABLE_INTERRUPT(cpu_mask));
+		    MVPP2_ISR_ENABLE_INTERRUPT(sw_thread_mask));
 }
 
 static inline void mvpp2_interrupts_disable(struct mvpp2_port *port)
 {
-	int cpu, cpu_mask = 0;
+	int i, sw_thread_mask = 0;
+
+	for (i = 0; i < port->nqvecs; i++)
+		sw_thread_mask |= port->qvecs[i].sw_thread_mask;
+
+	mvpp2_write(port->priv, MVPP2_ISR_ENABLE_REG(port->id),
+		    MVPP2_ISR_DISABLE_INTERRUPT(sw_thread_mask));
+}
+
+static inline void mvpp2_qvec_interrupt_enable(struct mvpp2_queue_vector *qvec)
+{
+	struct mvpp2_port *port = qvec->port;
+
+	mvpp2_write(port->priv, MVPP2_ISR_ENABLE_REG(port->id),
+		    MVPP2_ISR_ENABLE_INTERRUPT(qvec->sw_thread_mask));
+}
+
+static inline void mvpp2_qvec_interrupt_disable(struct mvpp2_queue_vector *qvec)
+{
+	struct mvpp2_port *port = qvec->port;
 
-	for_each_present_cpu(cpu)
-		cpu_mask |= 1 << cpu;
 	mvpp2_write(port->priv, MVPP2_ISR_ENABLE_REG(port->id),
-		    MVPP2_ISR_DISABLE_INTERRUPT(cpu_mask));
+		    MVPP2_ISR_DISABLE_INTERRUPT(qvec->sw_thread_mask));
 }
 
 /* Mask the current CPU's Rx/Tx interrupts
@@ -5589,11 +5619,11 @@ static int mvpp2_setup_txqs(struct mvpp2_port *port)
 /* The callback for per-port interrupt */
 static irqreturn_t mvpp2_isr(int irq, void *dev_id)
 {
-	struct mvpp2_port *port = (struct mvpp2_port *)dev_id;
+	struct mvpp2_queue_vector *qv = dev_id;
 
-	mvpp2_interrupts_disable(port);
+	mvpp2_qvec_interrupt_disable(qv);
 
-	napi_schedule(&port->napi);
+	napi_schedule(&qv->napi);
 
 	return IRQ_HANDLED;
 }
@@ -5850,8 +5880,8 @@ static u32 mvpp2_skb_tx_csum(struct mvpp2_port *port, struct sk_buff *skb)
 }
 
 /* Main rx processing */
-static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
-		    struct mvpp2_rx_queue *rxq)
+static int mvpp2_rx(struct mvpp2_port *port, struct napi_struct *napi,
+		    int rx_todo, struct mvpp2_rx_queue *rxq)
 {
 	struct net_device *dev = port->dev;
 	int rx_received;
@@ -5929,7 +5959,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		skb->protocol = eth_type_trans(skb, dev);
 		mvpp2_rx_csum(port, rx_status, skb);
 
-		napi_gro_receive(&port->napi, skb);
+		napi_gro_receive(napi, skb);
 	}
 
 	if (rcvd_pkts) {
@@ -6138,8 +6168,11 @@ static int mvpp2_poll(struct napi_struct *napi, int budget)
 	u32 cause_rx_tx, cause_rx, cause_misc;
 	int rx_done = 0;
 	struct mvpp2_port *port = netdev_priv(napi->dev);
+	struct mvpp2_queue_vector *qv;
 	int cpu = smp_processor_id();
 
+	qv = container_of(napi, struct mvpp2_queue_vector, napi);
+
 	/* Rx/Tx cause register
 	 *
 	 * Bits 0-15: each bit indicates received packets on the Rx queue
@@ -6168,7 +6201,7 @@ static int mvpp2_poll(struct napi_struct *napi, int budget)
 	cause_rx = cause_rx_tx & MVPP2_CAUSE_RXQ_OCCUP_DESC_ALL_MASK;
 
 	/* Process RX packets */
-	cause_rx |= port->pending_cause_rx;
+	cause_rx |= qv->pending_cause_rx;
 	while (cause_rx && budget > 0) {
 		int count;
 		struct mvpp2_rx_queue *rxq;
@@ -6177,7 +6210,7 @@ static int mvpp2_poll(struct napi_struct *napi, int budget)
 		if (!rxq)
 			break;
 
-		count = mvpp2_rx(port, budget, rxq);
+		count = mvpp2_rx(port, napi, budget, rxq);
 		rx_done += count;
 		budget -= count;
 		if (budget > 0) {
@@ -6193,9 +6226,9 @@ static int mvpp2_poll(struct napi_struct *napi, int budget)
 		cause_rx = 0;
 		napi_complete_done(napi, rx_done);
 
-		mvpp2_interrupts_enable(port);
+		mvpp2_qvec_interrupt_enable(qv);
 	}
-	port->pending_cause_rx = cause_rx;
+	qv->pending_cause_rx = cause_rx;
 	return rx_done;
 }
 
@@ -6203,11 +6236,13 @@ static int mvpp2_poll(struct napi_struct *napi, int budget)
 static void mvpp2_start_dev(struct mvpp2_port *port)
 {
 	struct net_device *ndev = port->dev;
+	int i;
 
 	mvpp2_gmac_max_rx_size_set(port);
 	mvpp2_txp_max_tx_size_set(port);
 
-	napi_enable(&port->napi);
+	for (i = 0; i < port->nqvecs; i++)
+		napi_enable(&port->qvecs[i].napi);
 
 	/* Enable interrupts on all CPUs */
 	mvpp2_interrupts_enable(port);
@@ -6226,6 +6261,7 @@ static void mvpp2_start_dev(struct mvpp2_port *port)
 static void mvpp2_stop_dev(struct mvpp2_port *port)
 {
 	struct net_device *ndev = port->dev;
+	int i;
 
 	/* Stop new packets from arriving to RXQs */
 	mvpp2_ingress_disable(port);
@@ -6235,7 +6271,8 @@ static void mvpp2_stop_dev(struct mvpp2_port *port)
 	/* Disable interrupts on all CPUs */
 	mvpp2_interrupts_disable(port);
 
-	napi_disable(&port->napi);
+	for (i = 0; i < port->nqvecs; i++)
+		napi_disable(&port->qvecs[i].napi);
 
 	netif_carrier_off(port->dev);
 	netif_tx_stop_all_queues(port->dev);
@@ -6341,6 +6378,40 @@ static void mvpp2_phy_disconnect(struct mvpp2_port *port)
 	phy_disconnect(ndev->phydev);
 }
 
+static int mvpp2_irqs_init(struct mvpp2_port *port)
+{
+	int err, i;
+
+	for (i = 0; i < port->nqvecs; i++) {
+		struct mvpp2_queue_vector *qv = port->qvecs + i;
+
+		err = request_irq(qv->irq, mvpp2_isr, 0, port->dev->name, qv);
+		if (err)
+			goto err;
+	}
+
+	return 0;
+err:
+	for (i = 0; i < port->nqvecs; i++) {
+		struct mvpp2_queue_vector *qv = port->qvecs + i;
+
+		free_irq(qv->irq, qv);
+	}
+
+	return err;
+}
+
+static void mvpp2_irqs_deinit(struct mvpp2_port *port)
+{
+	int i;
+
+	for (i = 0; i < port->nqvecs; i++) {
+		struct mvpp2_queue_vector *qv = port->qvecs + i;
+
+		free_irq(qv->irq, qv);
+	}
+}
+
 static int mvpp2_open(struct net_device *dev)
 {
 	struct mvpp2_port *port = netdev_priv(dev);
@@ -6384,9 +6455,9 @@ static int mvpp2_open(struct net_device *dev)
 		goto err_cleanup_rxqs;
 	}
 
-	err = request_irq(port->irq, mvpp2_isr, 0, dev->name, port);
+	err = mvpp2_irqs_init(port);
 	if (err) {
-		netdev_err(port->dev, "cannot request IRQ %d\n", port->irq);
+		netdev_err(port->dev, "cannot init IRQs\n");
 		goto err_cleanup_txqs;
 	}
 
@@ -6419,7 +6490,7 @@ static int mvpp2_open(struct net_device *dev)
 err_free_link_irq:
 	free_irq(port->link_irq, port);
 err_free_irq:
-	free_irq(port->irq, port);
+	mvpp2_irqs_deinit(port);
 err_cleanup_txqs:
 	mvpp2_cleanup_txqs(port);
 err_cleanup_rxqs:
@@ -6439,7 +6510,7 @@ static int mvpp2_stop(struct net_device *dev)
 	/* Mask interrupts on all CPUs */
 	on_each_cpu(mvpp2_interrupts_mask, port, 1);
 
-	free_irq(port->irq, port);
+	mvpp2_irqs_deinit(port);
 	for_each_present_cpu(cpu) {
 		port_pcpu = per_cpu_ptr(port->pcpu, cpu);
 
@@ -6757,6 +6828,66 @@ static const struct ethtool_ops mvpp2_eth_tool_ops = {
 	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
+static int mvpp2_queue_vectors_init(struct mvpp2_port *port,
+				    struct device_node *port_node)
+{
+	struct mvpp2_queue_vector *v = &port->qvecs[0];
+
+	v->first_rxq = 0;
+	v->nrxqs = port->nrxqs;
+	v->type = MVPP2_QUEUE_VECTOR_SHARED;
+	v->sw_thread_id = 0;
+	v->sw_thread_mask = *cpumask_bits(cpu_online_mask);
+	v->port = port;
+	v->irq = irq_of_parse_and_map(port_node, 0);
+	if (v->irq <= 0)
+		return -EINVAL;
+	netif_napi_add(port->dev, &v->napi, mvpp2_poll,
+		       NAPI_POLL_WEIGHT);
+
+	port->nqvecs = 1;
+
+	return 0;
+}
+
+static void mvpp2_queue_vectors_deinit(struct mvpp2_port *port)
+{
+	int i;
+
+	for (i = 0; i < port->nqvecs; i++)
+		irq_dispose_mapping(port->qvecs[i].irq);
+}
+
+/* Configure Rx queue group interrupt for this port */
+static void mvpp2_rx_irqs_setup(struct mvpp2_port *port)
+{
+	struct mvpp2 *priv = port->priv;
+	u32 val;
+	int i;
+
+	if (priv->hw_version == MVPP21) {
+		mvpp2_write(priv, MVPP21_ISR_RXQ_GROUP_REG(port->id),
+			    port->nrxqs);
+		return;
+	}
+
+	/* Handle the more complicated PPv2.2 case */
+	for (i = 0; i < port->nqvecs; i++) {
+		struct mvpp2_queue_vector *qv = port->qvecs + i;
+
+		if (!qv->nrxqs)
+			continue;
+
+		val = qv->sw_thread_id;
+		val |= port->id << MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_OFFSET;
+		mvpp2_write(priv, MVPP22_ISR_RXQ_GROUP_INDEX_REG, val);
+
+		val = qv->first_rxq;
+		val |= qv->nrxqs << MVPP22_ISR_RXQ_SUB_GROUP_SIZE_OFFSET;
+		mvpp2_write(priv, MVPP22_ISR_RXQ_SUB_GROUP_CONFIG_REG, val);
+	}
+}
+
 /* Initialize port HW */
 static int mvpp2_port_init(struct mvpp2_port *port)
 {
@@ -6838,19 +6969,7 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 		port->rxqs[queue] = rxq;
 	}
 
-	/* Configure Rx queue group interrupt for this port */
-	if (priv->hw_version == MVPP21) {
-		mvpp2_write(priv, MVPP21_ISR_RXQ_GROUP_REG(port->id),
-			    port->nrxqs);
-	} else {
-		u32 val;
-
-		val = (port->id << MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_OFFSET);
-		mvpp2_write(priv, MVPP22_ISR_RXQ_GROUP_INDEX_REG, val);
-
-		val = (port->nrxqs << MVPP22_ISR_RXQ_SUB_GROUP_SIZE_OFFSET);
-		mvpp2_write(priv, MVPP22_ISR_RXQ_SUB_GROUP_CONFIG_REG, val);
-	}
+	mvpp2_rx_irqs_setup(port);
 
 	/* Create Rx descriptor rings */
 	for (queue = 0; queue < port->nrxqs; queue++) {
@@ -6935,33 +7054,22 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	dev->ethtool_ops = &mvpp2_eth_tool_ops;
 
 	port = netdev_priv(dev);
+	port->dev = dev;
 	port->ntxqs = ntxqs;
 	port->nrxqs = nrxqs;
 
-	if (of_get_property(port_node, "interrupt-names", NULL)) {
-		port->irq = of_irq_get_byname(port_node, "rx-shared");
-		if (port->irq <= 0) {
-			err = (port->irq == -EPROBE_DEFER) ?
-			      -EPROBE_DEFER : -EINVAL;
-			goto err_free_netdev;
-		}
-
-		port->link_irq = of_irq_get_byname(port_node, "link");
-		if (port->link_irq == -EPROBE_DEFER) {
-			err = -EPROBE_DEFER;
-			goto err_free_irq;
-		}
-		if (port->link_irq <= 0)
-			/* the link irq is optional */
-			port->link_irq = 0;
-	} else {
-		/* kept for dt compatibility */
-		port->irq = irq_of_parse_and_map(port_node, 0);
-		if (port->irq <= 0) {
-			err = -EINVAL;
-			goto err_free_netdev;
-		}
+	port->link_irq = of_irq_get_byname(port_node, "link");
+	if (port->link_irq == -EPROBE_DEFER) {
+		err = -EPROBE_DEFER;
+		goto err_free_netdev;
 	}
+	if (port->link_irq <= 0)
+		/* the link irq is optional */
+		port->link_irq = 0;
+
+	err = mvpp2_queue_vectors_init(port, port_node);
+	if (err)
+		goto err_free_netdev;
 
 	if (of_property_read_bool(port_node, "marvell,loopback"))
 		port->flags |= MVPP2_F_LOOPBACK;
@@ -6981,14 +7089,14 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		port->base = devm_ioremap_resource(&pdev->dev, res);
 		if (IS_ERR(port->base)) {
 			err = PTR_ERR(port->base);
-			goto err_free_irq;
+			goto err_deinit_qvecs;
 		}
 	} else {
 		if (of_property_read_u32(port_node, "gop-port-id",
 					 &port->gop_id)) {
 			err = -EINVAL;
 			dev_err(&pdev->dev, "missing gop-port-id value\n");
-			goto err_free_irq;
+			goto err_deinit_qvecs;
 		}
 
 		port->base = priv->iface_base + MVPP22_GMAC_BASE(port->gop_id);
@@ -6998,7 +7106,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	port->stats = netdev_alloc_pcpu_stats(struct mvpp2_pcpu_stats);
 	if (!port->stats) {
 		err = -ENOMEM;
-		goto err_free_irq;
+		goto err_deinit_qvecs;
 	}
 
 	dt_mac_addr = of_get_mac_address(port_node);
@@ -7019,7 +7127,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 
 	port->tx_ring_size = MVPP2_MAX_TXD;
 	port->rx_ring_size = MVPP2_MAX_RXD;
-	port->dev = dev;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = mvpp2_port_init(port);
@@ -7053,7 +7160,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 			     (unsigned long)dev);
 	}
 
-	netif_napi_add(dev, &port->napi, mvpp2_poll, NAPI_POLL_WEIGHT);
 	features = NETIF_F_SG | NETIF_F_IP_CSUM;
 	dev->features = features | NETIF_F_RXCSUM;
 	dev->hw_features |= features | NETIF_F_RXCSUM | NETIF_F_GRO;
@@ -7081,8 +7187,8 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		free_percpu(port->txqs[i]->pcpu);
 err_free_stats:
 	free_percpu(port->stats);
-err_free_irq:
-	irq_dispose_mapping(port->irq);
+err_deinit_qvecs:
+	mvpp2_queue_vectors_deinit(port);
 err_free_netdev:
 	of_node_put(phy_node);
 	free_netdev(dev);
@@ -7100,7 +7206,7 @@ static void mvpp2_port_remove(struct mvpp2_port *port)
 	free_percpu(port->stats);
 	for (i = 0; i < port->ntxqs; i++)
 		free_percpu(port->txqs[i]->pcpu);
-	irq_dispose_mapping(port->irq);
+	mvpp2_queue_vectors_deinit(port);
 	free_netdev(port->dev);
 }
 
-- 
2.9.4
