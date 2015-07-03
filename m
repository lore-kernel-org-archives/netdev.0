From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 4/6] net: mvneta: Handle per-cpu interrupts
Date: Fri,  3 Jul 2015 16:25:49 +0200
Message-ID: <1435933551-28696-5-git-send-email-maxime.ripard@free-electrons.com>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that our interrupt controller is allowing us to use per-CPU interrupts,
actually use it in the mvneta driver.

This involves obviously reworking the driver to have a CPU-local NAPI
structure, and report for incoming packet using that structure.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 85 ++++++++++++++++++++++++-----------
 1 file changed, 58 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b7717375ec4d..aedd21ed9532 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -285,7 +285,21 @@ struct mvneta_pcpu_stats {
 	u64	tx_bytes;
 };
 
+struct mvneta_pcpu_port {
+	/* Pointer to the shared port */
+	struct mvneta_port	*pp;
+
+	/* Pointer to the CPU-local NAPI struct */
+	struct napi_struct	napi;
+
+	/* Cause of the previous interrupt */
+	u32			cause_rx_tx;
+};
+
 struct mvneta_port {
+	struct mvneta_pcpu_port __percpu	*ports;
+	struct mvneta_pcpu_stats __percpu	*stats;
+
 	int pkt_size;
 	unsigned int frag_size;
 	void __iomem *base;
@@ -293,15 +307,11 @@ struct mvneta_port {
 	struct mvneta_tx_queue *txqs;
 	struct net_device *dev;
 
-	u32 cause_rx_tx;
-	struct napi_struct napi;
-
 	/* Core clock */
 	struct clk *clk;
 	u8 mcast_count[256];
 	u16 tx_ring_size;
 	u16 rx_ring_size;
-	struct mvneta_pcpu_stats *stats;
 
 	struct mii_bus *mii_bus;
 	struct phy_device *phy_dev;
@@ -1454,6 +1464,7 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		     struct mvneta_rx_queue *rxq)
 {
+	struct mvneta_pcpu_port *port = this_cpu_ptr(pp->ports);
 	struct net_device *dev = pp->dev;
 	int rx_done, rx_filled;
 	u32 rcvd_pkts = 0;
@@ -1508,7 +1519,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 
 			skb->protocol = eth_type_trans(skb, dev);
 			mvneta_rx_csum(pp, rx_status, skb);
-			napi_gro_receive(&pp->napi, skb);
+			napi_gro_receive(&port->napi, skb);
 
 			rcvd_pkts++;
 			rcvd_bytes += rx_bytes;
@@ -1535,7 +1546,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 
 		mvneta_rx_csum(pp, rx_status, skb);
 
-		napi_gro_receive(&pp->napi, skb);
+		napi_gro_receive(&port->napi, skb);
 
 		/* Refill processing */
 		err = mvneta_rx_refill(pp, rx_desc);
@@ -2054,12 +2065,11 @@ static void mvneta_set_rx_mode(struct net_device *dev)
 /* Interrupt handling - the callback for request_irq() */
 static irqreturn_t mvneta_isr(int irq, void *dev_id)
 {
-	struct mvneta_port *pp = (struct mvneta_port *)dev_id;
+	struct mvneta_pcpu_port *port = (struct mvneta_pcpu_port *)dev_id;
 
-	/* Mask all interrupts */
-	mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
+	disable_percpu_irq(port->pp->dev->irq);
 
-	napi_schedule(&pp->napi);
+	napi_schedule(&port->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2097,11 +2107,11 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 {
 	int rx_done = 0;
 	u32 cause_rx_tx;
-	unsigned long flags;
 	struct mvneta_port *pp = netdev_priv(napi->dev);
+	struct mvneta_pcpu_port *port = this_cpu_ptr(pp->ports);
 
 	if (!netif_running(pp->dev)) {
-		napi_complete(napi);
+		napi_complete(&port->napi);
 		return rx_done;
 	}
 
@@ -2128,7 +2138,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	/* For the case where the last mvneta_poll did not process all
 	 * RX packets
 	 */
-	cause_rx_tx |= pp->cause_rx_tx;
+	cause_rx_tx |= port->cause_rx_tx;
 	if (rxq_number > 1) {
 		while ((cause_rx_tx & MVNETA_RX_INTR_MASK_ALL) && (budget > 0)) {
 			int count;
@@ -2159,16 +2169,11 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 
 	if (budget > 0) {
 		cause_rx_tx = 0;
-		napi_complete(napi);
-		local_irq_save(flags);
-		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-			    MVNETA_RX_INTR_MASK(rxq_number) |
-			    MVNETA_TX_INTR_MASK(txq_number) |
-			    MVNETA_MISCINTR_INTR_MASK);
-		local_irq_restore(flags);
+		napi_complete(&port->napi);
+		enable_percpu_irq(pp->dev->irq, 0);
 	}
 
-	pp->cause_rx_tx = cause_rx_tx;
+	port->cause_rx_tx = cause_rx_tx;
 	return rx_done;
 }
 
@@ -2417,6 +2422,8 @@ static int mvneta_setup_txqs(struct mvneta_port *pp)
 
 static void mvneta_start_dev(struct mvneta_port *pp)
 {
+	unsigned int cpu;
+
 	mvneta_max_rx_size_set(pp, pp->pkt_size);
 	mvneta_txq_max_tx_size_set(pp, pp->pkt_size);
 
@@ -2424,7 +2431,10 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 	mvneta_port_enable(pp);
 
 	/* Enable polling on the port */
-	napi_enable(&pp->napi);
+	for_each_present_cpu(cpu) {
+		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
+		napi_enable(&port->napi);
+	}
 
 	/* Unmask interrupts */
 	mvreg_write(pp, MVNETA_INTR_NEW_MASK,
@@ -2442,9 +2452,14 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 
 static void mvneta_stop_dev(struct mvneta_port *pp)
 {
+	unsigned int cpu;
+
 	phy_stop(pp->phy_dev);
 
-	napi_disable(&pp->napi);
+	for_each_present_cpu(cpu) {
+		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
+		napi_disable(&port->napi);
+	}
 
 	netif_carrier_off(pp->dev);
 
@@ -2683,8 +2698,8 @@ static int mvneta_open(struct net_device *dev)
 		goto err_cleanup_rxqs;
 
 	/* Connect to port interrupt line */
-	ret = request_irq(pp->dev->irq, mvneta_isr, 0,
-			  MVNETA_DRIVER_NAME, pp);
+	ret = request_percpu_irq(pp->dev->irq, mvneta_isr,
+				 MVNETA_DRIVER_NAME, pp->ports);
 	if (ret) {
 		netdev_err(pp->dev, "cannot request irq %d\n", pp->dev->irq);
 		goto err_cleanup_txqs;
@@ -3005,6 +3020,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	int phy_mode;
 	int fixed_phy = 0;
 	int err;
+	int cpu;
 
 	/* Our multiqueue support is not complete, so for now, only
 	 * allow the usage of the first RX queue
@@ -3079,11 +3095,18 @@ static int mvneta_probe(struct platform_device *pdev)
 		goto err_clk;
 	}
 
+	/* Alloc per-cpu port structure */
+	pp->ports = alloc_percpu(struct mvneta_pcpu_port);
+	if (!pp->ports) {
+		err = -ENOMEM;
+		goto err_clk;
+	}
+
 	/* Alloc per-cpu stats */
 	pp->stats = netdev_alloc_pcpu_stats(struct mvneta_pcpu_stats);
 	if (!pp->stats) {
 		err = -ENOMEM;
-		goto err_clk;
+		goto err_free_ports;
 	}
 
 	dt_mac_addr = of_get_mac_address(dn);
@@ -3121,7 +3144,12 @@ static int mvneta_probe(struct platform_device *pdev)
 	if (dram_target_info)
 		mvneta_conf_mbus_windows(pp, dram_target_info);
 
-	netif_napi_add(dev, &pp->napi, mvneta_poll, NAPI_POLL_WEIGHT);
+	for_each_present_cpu(cpu) {
+		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
+
+		netif_napi_add(dev, &port->napi, mvneta_poll, NAPI_POLL_WEIGHT);
+		port->pp = pp;
+	}
 
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
@@ -3150,6 +3178,8 @@ static int mvneta_probe(struct platform_device *pdev)
 
 err_free_stats:
 	free_percpu(pp->stats);
+err_free_ports:
+	free_percpu(pp->ports);
 err_clk:
 	clk_disable_unprepare(pp->clk);
 err_put_phy_node:
@@ -3169,6 +3199,7 @@ static int mvneta_remove(struct platform_device *pdev)
 
 	unregister_netdev(dev);
 	clk_disable_unprepare(pp->clk);
+	free_percpu(pp->ports);
 	free_percpu(pp->stats);
 	irq_dispose_mapping(dev->irq);
 	of_node_put(pp->phy_node);
-- 
2.4.5
