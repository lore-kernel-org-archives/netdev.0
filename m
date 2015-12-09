From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next v3 4/4] net: mvneta: Configure XPS support
Date: Wed,  9 Dec 2015 18:23:51 +0100
Message-ID: <1449681831-2798-5-git-send-email-gregory.clement@free-electrons.com>
References: <1449681831-2798-1-git-send-email-gregory.clement@free-electrons.com>
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
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449681831-2798-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this patch each CPU is associated with its own set of TX queues.

It also setup the XPS with an initial configuration which set the
affinity matching the hardware configuration.

Suggested-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 56 ++++++++++++++++++++++++++++-------
 1 file changed, 45 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e0dba6869605..b08fe580957e 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -110,6 +110,7 @@
 #define      MVNETA_CPU_RXQ_ACCESS_ALL_MASK      0x000000ff
 #define      MVNETA_CPU_TXQ_ACCESS_ALL_MASK      0x0000ff00
 #define      MVNETA_CPU_RXQ_ACCESS(rxq)		 BIT(rxq)
+#define      MVNETA_CPU_TXQ_ACCESS(txq)		 BIT(txq + 8)
 #define MVNETA_RXQ_TIME_COAL_REG(q)              (0x2580 + ((q) << 2))
 
 /* Exception Interrupt Port/Queue Cause register
@@ -512,6 +513,9 @@ struct mvneta_tx_queue {
 
 	/* DMA address of TSO headers */
 	dma_addr_t tso_hdrs_phys;
+
+	/* Affinity mask for CPUs*/
+	cpumask_t affinity_mask;
 };
 
 struct mvneta_rx_queue {
@@ -1022,20 +1026,30 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	/* Enable MBUS Retry bit16 */
 	mvreg_write(pp, MVNETA_MBUS_RETRY, 0x20);
 
-	/* Set CPU queue access map. CPUs are assigned to the RX
-	 * queues modulo their number and all the TX queues are
-	 * assigned to the CPU associated to the default RX queue.
+	/* Set CPU queue access map. CPUs are assigned to the RX and
+	 * TX queues modulo their number. If there is only one TX
+	 * queue then it is assigned to the CPU associated to the
+	 * default RX queue.
 	 */
 	for_each_present_cpu(cpu) {
 		int rxq_map = 0, txq_map = 0;
-		int rxq;
+		int rxq, txq;
 
 		for (rxq = 0; rxq < rxq_number; rxq++)
 			if ((rxq % max_cpu) == cpu)
 				rxq_map |= MVNETA_CPU_RXQ_ACCESS(rxq);
 
-		if (cpu == pp->rxq_def)
-			txq_map = MVNETA_CPU_TXQ_ACCESS_ALL_MASK;
+		for (txq = 0; txq < txq_number; txq++)
+			if ((txq % max_cpu) == cpu)
+				txq_map |= MVNETA_CPU_TXQ_ACCESS(txq);
+
+		/* With only one TX queue we configure a special case
+		 * which will allow to get all the irq on a single
+		 * CPU
+		 */
+		if (txq_number == 1)
+			txq_map = (cpu == pp->rxq_def) ?
+				MVNETA_CPU_TXQ_ACCESS(1) : 0;
 
 		mvreg_write(pp, MVNETA_CPU_MAP(cpu), rxq_map | txq_map);
 	}
@@ -2337,6 +2351,8 @@ static void mvneta_rxq_deinit(struct mvneta_port *pp,
 static int mvneta_txq_init(struct mvneta_port *pp,
 			   struct mvneta_tx_queue *txq)
 {
+	int cpu;
+
 	txq->size = pp->tx_ring_size;
 
 	/* A queue must always have room for at least one skb.
@@ -2389,6 +2405,14 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 	}
 	mvneta_tx_done_pkts_coal_set(pp, txq, txq->done_pkts_coal);
 
+	/* Setup XPS mapping */
+	if (txq_number > 1)
+		cpu = txq->id % num_present_cpus();
+	else
+		cpu = pp->rxq_def % num_present_cpus();
+	cpumask_set_cpu(cpu, &txq->affinity_mask);
+	netif_set_xps_queue(pp->dev, &txq->affinity_mask, txq->id);
+
 	return 0;
 }
 
@@ -2811,13 +2835,23 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 			if ((rxq % max_cpu) == cpu)
 				rxq_map |= MVNETA_CPU_RXQ_ACCESS(rxq);
 
-		if (i == online_cpu_idx) {
-			/* Map the default receive queue and transmit
-			 * queue to the elected CPU
+		if (i == online_cpu_idx)
+			/* Map the default receive queue queue to the
+			 * elected CPU
 			 */
 			rxq_map |= MVNETA_CPU_RXQ_ACCESS(pp->rxq_def);
-			txq_map = MVNETA_CPU_TXQ_ACCESS_ALL_MASK;
-		}
+
+		/* We update the TX queue map only if we have one
+		 * queue. In this case we associate the TX queue to
+		 * the CPU bound to the default RX queue
+		 */
+		if (txq_number == 1)
+			txq_map = (i == online_cpu_idx) ?
+				MVNETA_CPU_TXQ_ACCESS(1) : 0;
+		else
+			txq_map = mvreg_read(pp, MVNETA_CPU_MAP(cpu)) &
+				MVNETA_CPU_TXQ_ACCESS_ALL_MASK;
+
 		mvreg_write(pp, MVNETA_CPU_MAP(cpu), rxq_map | txq_map);
 
 		/* Update the interrupt mask on each CPU according the
-- 
2.5.0
