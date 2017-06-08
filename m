From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 2/5] net: mvpp2: use {get,put}_cpu() instead of smp_processor_id()
Date: Thu,  8 Jun 2017 17:27:24 +0200
Message-ID: <1496935647-29670-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Marc Zyngier <marc.zyngier@arm.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34616 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751782AbdFHP2P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:28:15 -0400
In-Reply-To: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smp_processor_id() should not be used in migration-enabled contexts. We
originally thought it was OK in the specific situation of this driver,
but it was wrong, and calling smp_processor_id() in a migration-enabled
context prints a big fat warning when CONFIG_DEBUG_PREEMPT=y.

Therefore, this commit replaces the smp_processor_id() in
migration-enabled contexts by the appropriate get_cpu/put_cpu sections.

Reported-by: Marc Zyngier <marc.zyngier@arm.com>
Fixes: a786841df72e ("net: mvpp2: handle register mapping and access for PPv2.2")
Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 27 +++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index cff45e3..fb6e9dc 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3715,7 +3715,7 @@ static void mvpp2_bm_bufs_get_addrs(struct device *dev, struct mvpp2 *priv,
 				    dma_addr_t *dma_addr,
 				    phys_addr_t *phys_addr)
 {
-	int cpu = smp_processor_id();
+	int cpu = get_cpu();
 
 	*dma_addr = mvpp2_percpu_read(priv, cpu,
 				      MVPP2_BM_PHY_ALLOC_REG(bm_pool->id));
@@ -3736,6 +3736,8 @@ static void mvpp2_bm_bufs_get_addrs(struct device *dev, struct mvpp2 *priv,
 		if (sizeof(phys_addr_t) == 8)
 			*phys_addr |= (u64)phys_addr_highbits << 32;
 	}
+
+	put_cpu();
 }
 
 /* Free all buffers from the pool */
@@ -3921,7 +3923,7 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 				     dma_addr_t buf_dma_addr,
 				     phys_addr_t buf_phys_addr)
 {
-	int cpu = smp_processor_id();
+	int cpu = get_cpu();
 
 	if (port->priv->hw_version == MVPP22) {
 		u32 val = 0;
@@ -3948,6 +3950,8 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 			   MVPP2_BM_VIRT_RLS_REG, buf_phys_addr);
 	mvpp2_percpu_write(port->priv, cpu,
 			   MVPP2_BM_PHY_RLS_REG(pool), buf_dma_addr);
+
+	put_cpu();
 }
 
 /* Refill BM pool */
@@ -4730,7 +4734,7 @@ static void mvpp2_txp_max_tx_size_set(struct mvpp2_port *port)
 static void mvpp2_rx_pkts_coal_set(struct mvpp2_port *port,
 				   struct mvpp2_rx_queue *rxq)
 {
-	int cpu = smp_processor_id();
+	int cpu = get_cpu();
 
 	if (rxq->pkts_coal > MVPP2_OCCUPIED_THRESH_MASK)
 		rxq->pkts_coal = MVPP2_OCCUPIED_THRESH_MASK;
@@ -4738,6 +4742,8 @@ static void mvpp2_rx_pkts_coal_set(struct mvpp2_port *port,
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_NUM_REG, rxq->id);
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_THRESH_REG,
 			   rxq->pkts_coal);
+
+	put_cpu();
 }
 
 static u32 mvpp2_usec_to_cycles(u32 usec, unsigned long clk_hz)
@@ -4918,7 +4924,7 @@ static int mvpp2_rxq_init(struct mvpp2_port *port,
 	mvpp2_write(port->priv, MVPP2_RXQ_STATUS_REG(rxq->id), 0);
 
 	/* Set Rx descriptors queue starting address - indirect access */
-	cpu = smp_processor_id();
+	cpu = get_cpu();
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_NUM_REG, rxq->id);
 	if (port->priv->hw_version == MVPP21)
 		rxq_dma = rxq->descs_dma;
@@ -4927,6 +4933,7 @@ static int mvpp2_rxq_init(struct mvpp2_port *port,
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_DESC_ADDR_REG, rxq_dma);
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_DESC_SIZE_REG, rxq->size);
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_INDEX_REG, 0);
+	put_cpu();
 
 	/* Set Offset */
 	mvpp2_rxq_offset_set(port, rxq->id, NET_SKB_PAD);
@@ -4989,10 +4996,11 @@ static void mvpp2_rxq_deinit(struct mvpp2_port *port,
 	 * free descriptor number
 	 */
 	mvpp2_write(port->priv, MVPP2_RXQ_STATUS_REG(rxq->id), 0);
-	cpu = smp_processor_id();
+	cpu = get_cpu();
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_NUM_REG, rxq->id);
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_DESC_ADDR_REG, 0);
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_RXQ_DESC_SIZE_REG, 0);
+	put_cpu();
 }
 
 /* Create and initialize a Tx queue */
@@ -5015,7 +5023,7 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 	txq->last_desc = txq->size - 1;
 
 	/* Set Tx descriptors queue starting address - indirect access */
-	cpu = smp_processor_id();
+	cpu = get_cpu();
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_TXQ_NUM_REG, txq->id);
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_TXQ_DESC_ADDR_REG,
 			   txq->descs_dma);
@@ -5040,6 +5048,7 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_TXQ_PREF_BUF_REG,
 			   MVPP2_PREF_BUF_PTR(desc) | MVPP2_PREF_BUF_SIZE_16 |
 			   MVPP2_PREF_BUF_THRESH(desc_per_txq / 2));
+	put_cpu();
 
 	/* WRR / EJP configuration - indirect access */
 	tx_port_num = mvpp2_egress_port(port);
@@ -5110,10 +5119,11 @@ static void mvpp2_txq_deinit(struct mvpp2_port *port,
 	mvpp2_write(port->priv, MVPP2_TXQ_SCHED_TOKEN_CNTR_REG(txq->id), 0);
 
 	/* Set Tx descriptors queue starting address and size */
-	cpu = smp_processor_id();
+	cpu = get_cpu();
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_TXQ_NUM_REG, txq->id);
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_TXQ_DESC_ADDR_REG, 0);
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_TXQ_DESC_SIZE_REG, 0);
+	put_cpu();
 }
 
 /* Cleanup Tx ports */
@@ -5123,7 +5133,7 @@ static void mvpp2_txq_clean(struct mvpp2_port *port, struct mvpp2_tx_queue *txq)
 	int delay, pending, cpu;
 	u32 val;
 
-	cpu = smp_processor_id();
+	cpu = get_cpu();
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_TXQ_NUM_REG, txq->id);
 	val = mvpp2_percpu_read(port->priv, cpu, MVPP2_TXQ_PREF_BUF_REG);
 	val |= MVPP2_TXQ_DRAIN_EN_MASK;
@@ -5150,6 +5160,7 @@ static void mvpp2_txq_clean(struct mvpp2_port *port, struct mvpp2_tx_queue *txq)
 
 	val &= ~MVPP2_TXQ_DRAIN_EN_MASK;
 	mvpp2_percpu_write(port->priv, cpu, MVPP2_TXQ_PREF_BUF_REG, val);
+	put_cpu();
 
 	for_each_present_cpu(cpu) {
 		txq_pcpu = per_cpu_ptr(txq->pcpu, cpu);
-- 
2.7.4
