From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [RFC PATCH 1/2] net: mvneta: Associate RX queues with each CPU
Date: Fri,  6 Nov 2015 19:35:10 +0100
Message-ID: <1446834911-29910-2-git-send-email-gregory.clement@free-electrons.com>
References: <1446834911-29910-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446834911-29910-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We enable the percpu interrupt for all the CPU and we just associate a
CPU to a few queue at the neta level. The mapping between the CPUs and
the queues is static. The queues are associated to the CPU module the
number of CPUs. However currently we only use on RX queue for a given
Ethernet port.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 150 ++++++++++++++++++++++++++--------
 1 file changed, 115 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 20a2363f9e40..c38326b848f9 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -109,9 +109,16 @@
 #define MVNETA_CPU_MAP(cpu)                      (0x2540 + ((cpu) << 2))
 #define      MVNETA_CPU_RXQ_ACCESS_ALL_MASK      0x000000ff
 #define      MVNETA_CPU_TXQ_ACCESS_ALL_MASK      0x0000ff00
+#define      MVNETA_CPU_RXQ_ACCESS(rxq)		 BIT(rxq)
 #define MVNETA_RXQ_TIME_COAL_REG(q)              (0x2580 + ((q) << 2))
 
-/* Exception Interrupt Port/Queue Cause register */
+/* Exception Interrupt Port/Queue Cause register
+ *
+ * Their behavior depend of the mapping done using the PCPX2Q
+ * registers. For a given CPU if the bit associated to a queue is not
+ * set, then for the register a read from this CPU will always return
+ * 0 and a write won't do anything
+ */
 
 #define MVNETA_INTR_NEW_CAUSE                    0x25a0
 #define MVNETA_INTR_NEW_MASK                     0x25a4
@@ -818,7 +825,13 @@ static void mvneta_port_up(struct mvneta_port *pp)
 	mvreg_write(pp, MVNETA_TXQ_CMD, q_map);
 
 	/* Enable all initialized RXQs. */
-	mvreg_write(pp, MVNETA_RXQ_CMD, BIT(pp->rxq_def));
+	for (queue = 0; queue < rxq_number; queue++) {
+		struct mvneta_rx_queue *rxq = &pp->rxqs[queue];
+
+		if (rxq->descs != NULL)
+			q_map |= (1 << queue);
+	}
+	mvreg_write(pp, MVNETA_RXQ_CMD, q_map);
 }
 
 /* Stop the Ethernet port activity */
@@ -986,6 +999,7 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	int cpu;
 	int queue;
 	u32 val;
+	int max_cpu = num_present_cpus();
 
 	/* Clear all Cause registers */
 	mvreg_write(pp, MVNETA_INTR_NEW_CAUSE, 0);
@@ -1001,13 +1015,23 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	/* Enable MBUS Retry bit16 */
 	mvreg_write(pp, MVNETA_MBUS_RETRY, 0x20);
 
-	/* Set CPU queue access map - all CPUs have access to all RX
-	 * queues and to all TX queues
+	/* Set CPU queue access map. CPUs are assigned to the RX
+	 * queues modulo their number and all the TX queues are
+	 * assigned to the CPU associated to the default RX queue.
 	 */
-	for_each_present_cpu(cpu)
-		mvreg_write(pp, MVNETA_CPU_MAP(cpu),
-			    (MVNETA_CPU_RXQ_ACCESS_ALL_MASK |
-			     MVNETA_CPU_TXQ_ACCESS_ALL_MASK));
+	for_each_present_cpu(cpu) {
+		int rxq_map = 0, txq_map = 0;
+		int rxq;
+
+		for (rxq = 0; rxq < rxq_number; rxq++)
+			if ((rxq % max_cpu) == cpu)
+				rxq_map |= MVNETA_CPU_RXQ_ACCESS(rxq);
+
+		if (cpu == rxq_def)
+			txq_map = MVNETA_CPU_TXQ_ACCESS_ALL_MASK;
+
+		mvreg_write(pp, MVNETA_CPU_MAP(cpu), rxq_map | txq_map);
+	}
 
 	/* Reset RX and TX DMAs */
 	mvreg_write(pp, MVNETA_PORT_RX_RESET, MVNETA_PORT_RX_DMA_RESET);
@@ -2149,6 +2173,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 {
 	int rx_done = 0;
 	u32 cause_rx_tx;
+	int rx_queue;
 	struct mvneta_port *pp = netdev_priv(napi->dev);
 	struct mvneta_pcpu_port *port = this_cpu_ptr(pp->ports);
 
@@ -2180,8 +2205,15 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	/* For the case where the last mvneta_poll did not process all
 	 * RX packets
 	 */
+	rx_queue = fls(((cause_rx_tx >> 8) & 0xff));
+
 	cause_rx_tx |= port->cause_rx_tx;
-	rx_done = mvneta_rx(pp, budget, &pp->rxqs[pp->rxq_def]);
+
+	if (rx_queue) {
+		rx_queue = rx_queue - 1;
+		rx_done = mvneta_rx(pp, budget, &pp->rxqs[rx_queue]);
+	}
+
 	budget -= rx_done;
 
 	if (budget > 0) {
@@ -2394,19 +2426,27 @@ static void mvneta_cleanup_txqs(struct mvneta_port *pp)
 /* Cleanup all Rx queues */
 static void mvneta_cleanup_rxqs(struct mvneta_port *pp)
 {
-	mvneta_rxq_deinit(pp, &pp->rxqs[pp->rxq_def]);
+	int queue;
+
+	for (queue = 0; queue < txq_number; queue++)
+		mvneta_rxq_deinit(pp, &pp->rxqs[queue]);
 }
 
 
 /* Init all Rx queues */
 static int mvneta_setup_rxqs(struct mvneta_port *pp)
 {
-	int err = mvneta_rxq_init(pp, &pp->rxqs[pp->rxq_def]);
-	if (err) {
-		netdev_err(pp->dev, "%s: can't create rxq=%d\n",
-			   __func__, pp->rxq_def);
-		mvneta_cleanup_rxqs(pp);
-		return err;
+	int queue;
+
+	for (queue = 0; queue < rxq_number; queue++) {
+		int err = mvneta_rxq_init(pp, &pp->rxqs[queue]);
+
+		if (err) {
+			netdev_err(pp->dev, "%s: can't create rxq=%d\n",
+				   __func__, queue);
+			mvneta_cleanup_rxqs(pp);
+			return err;
+		}
 	}
 
 	return 0;
@@ -2430,6 +2470,19 @@ static int mvneta_setup_txqs(struct mvneta_port *pp)
 	return 0;
 }
 
+static void mvneta_percpu_unmask_interrupt(void *arg)
+{
+	struct mvneta_port *pp = arg;
+
+	/* All the queue are unmasked, but actually only the ones
+	 * maped to this CPU will be unmasked
+	 */
+	mvreg_write(pp, MVNETA_INTR_NEW_MASK,
+		    MVNETA_RX_INTR_MASK_ALL |
+		    MVNETA_TX_INTR_MASK_ALL |
+		    MVNETA_MISCINTR_INTR_MASK);
+}
+
 static void mvneta_start_dev(struct mvneta_port *pp)
 {
 	unsigned int cpu;
@@ -2447,11 +2500,10 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 		napi_enable(&port->napi);
 	}
 
-	/* Unmask interrupts */
-	mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-		    MVNETA_RX_INTR_MASK(rxq_number) |
-		    MVNETA_TX_INTR_MASK(txq_number) |
-		    MVNETA_MISCINTR_INTR_MASK);
+	/* Unmask interrupts. It has to be done from each CPU */
+	for_each_online_cpu(cpu)
+		smp_call_function_single(cpu, mvneta_percpu_unmask_interrupt,
+					 pp, true);
 	mvreg_write(pp, MVNETA_INTR_MISC_MASK,
 		    MVNETA_CAUSE_PHY_STATUS_CHANGE |
 		    MVNETA_CAUSE_LINK_CHANGE |
@@ -2727,22 +2779,35 @@ static void mvneta_percpu_disable(void *arg)
 
 static void mvneta_percpu_elect(struct mvneta_port *pp)
 {
-	int online_cpu_idx, cpu, i = 0;
+	int online_cpu_idx, max_cpu, cpu, i = 0;
 
 	online_cpu_idx = pp->rxq_def % num_online_cpus();
+	max_cpu = num_present_cpus();
 
 	for_each_online_cpu(cpu) {
-		if (i == online_cpu_idx)
-			/* Enable per-CPU interrupt on the one CPU we
-			 * just elected
+		int rxq_map = 0, txq_map = 0;
+		int rxq;
+
+		for (rxq = 0; rxq < rxq_number; rxq++)
+			if ((rxq % max_cpu) == cpu)
+				rxq_map |= MVNETA_CPU_RXQ_ACCESS(rxq);
+
+		if (i == online_cpu_idx) {
+			/* Map the default receive queue and transmit
+			 * queue to the elected CPU
 			 */
-			smp_call_function_single(cpu, mvneta_percpu_enable,
-						pp, true);
-		else
-			/* Disable per-CPU interrupt on all the other CPU */
-			smp_call_function_single(cpu, mvneta_percpu_disable,
-						pp, true);
+			rxq_map |= MVNETA_CPU_RXQ_ACCESS(pp->rxq_def);
+			txq_map = MVNETA_CPU_TXQ_ACCESS_ALL_MASK;
+		}
+		mvreg_write(pp, MVNETA_CPU_MAP(cpu), rxq_map | txq_map);
+
+		/* Update the interrupt mask on each CPU according the
+		 * new mapping
+		 */
+		smp_call_function_single(cpu, mvneta_percpu_unmask_interrupt,
+					 pp, true);
 		i++;
+
 	}
 };
 
@@ -2777,12 +2842,22 @@ static int mvneta_percpu_notifier(struct notifier_block *nfb,
 		mvreg_write(pp, MVNETA_INTR_MISC_MASK, 0);
 		napi_enable(&port->napi);
 
+
+		/* Enable per-CPU interrupts on the CPU that is
+		 * brought up.
+		 */
+		smp_call_function_single(cpu, mvneta_percpu_enable,
+					 pp, true);
+
 		/* Enable per-CPU interrupt on the one CPU we care
 		 * about.
 		 */
 		mvneta_percpu_elect(pp);
 
-		/* Unmask all ethernet port interrupts */
+		/* Unmask all ethernet port interrupts, as this
+		 * notifier is called for each CPU then the CPU to
+		 * Queue mapping is applied
+		 */
 		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
 			MVNETA_RX_INTR_MASK(rxq_number) |
 			MVNETA_TX_INTR_MASK(txq_number) |
@@ -2833,7 +2908,7 @@ static int mvneta_percpu_notifier(struct notifier_block *nfb,
 static int mvneta_open(struct net_device *dev)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
-	int ret;
+	int ret, cpu;
 
 	pp->pkt_size = MVNETA_RX_PKT_SIZE(pp->dev->mtu);
 	pp->frag_size = SKB_DATA_ALIGN(MVNETA_RX_BUF_SIZE(pp->pkt_size)) +
@@ -2863,8 +2938,13 @@ static int mvneta_open(struct net_device *dev)
 	 */
 	mvneta_percpu_disable(pp);
 
-	/* Elect a CPU to handle our RX queue interrupt */
-	mvneta_percpu_elect(pp);
+	/* Enable per-CPU interrupt on all the CPU to handle our RX
+	 * queue interrupts
+	 */
+	for_each_online_cpu(cpu)
+		smp_call_function_single(cpu, mvneta_percpu_enable,
+					 pp, true);
+
 
 	/* Register a CPU notifier to handle the case where our CPU
 	 * might be taken offline.
-- 
2.5.0
