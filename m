From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/5] qlge: Get rid of volatile usage for shadow register.
Date: Fri,  9 Jan 2009 13:31:49 -0800
Message-ID: <1231536713-24538-1-git-send-email-ron.mercer@qlogic.com>
References: <20090109213045.GD10803@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58231 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758017AbZAIVcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 16:32:00 -0500
In-Reply-To: <20090109213045.GD10803@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Putting back ql_read_sh_reg() function and using rmb() instead of
volatile.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   22 ++++++++++++++++++++--
 drivers/net/qlge/qlge_dbg.c  |   14 ++++++++------
 drivers/net/qlge/qlge_main.c |   12 ++++++------
 3 files changed, 34 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 459663a..4cb3647 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1145,7 +1145,7 @@ struct tx_ring {
 	struct wqicb wqicb;	/* structure used to inform chip of new queue */
 	void *wq_base;		/* pci_alloc:virtual addr for tx */
 	dma_addr_t wq_base_dma;	/* pci_alloc:dma addr for tx */
-	u32 *cnsmr_idx_sh_reg;	/* shadow copy of consumer idx */
+	__le32 *cnsmr_idx_sh_reg;	/* shadow copy of consumer idx */
 	dma_addr_t cnsmr_idx_sh_reg_dma;	/* dma-shadow copy of consumer */
 	u32 wq_size;		/* size in bytes of queue area */
 	u32 wq_len;		/* number of entries in queue */
@@ -1181,7 +1181,7 @@ struct rx_ring {
 	u32 cq_size;
 	u32 cq_len;
 	u16 cq_id;
-	volatile __le32 *prod_idx_sh_reg;	/* Shadowed producer register. */
+	__le32 *prod_idx_sh_reg;	/* Shadowed producer register. */
 	dma_addr_t prod_idx_sh_reg_dma;
 	void __iomem *cnsmr_idx_db_reg;	/* PCI doorbell mem area + 0 */
 	u32 cnsmr_idx;		/* current sw idx */
@@ -1459,6 +1459,24 @@ static inline void ql_write_db_reg(u32 val, void __iomem *addr)
 	mmiowb();
 }
 
+/*
+ * Shadow Registers:
+ * Outbound queues have a consumer index that is maintained by the chip.
+ * Inbound queues have a producer index that is maintained by the chip.
+ * For lower overhead, these registers are "shadowed" to host memory
+ * which allows the device driver to track the queue progress without
+ * PCI reads. When an entry is placed on an inbound queue, the chip will
+ * update the relevant index register and then copy the value to the
+ * shadow register in host memory.
+ */
+static inline u32 ql_read_sh_reg(__le32  *addr)
+{
+	u32 reg;
+	reg =  le32_to_cpu(*addr);
+	rmb();
+	return reg;
+}
+
 extern char qlge_driver_name[];
 extern const char qlge_driver_version[];
 extern const struct ethtool_ops qlge_ethtool_ops;
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 3f5e02d..e705ea5 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -455,10 +455,11 @@ void ql_dump_tx_ring(struct tx_ring *tx_ring)
 	printk(KERN_ERR PFX "tx_ring->base = %p.\n", tx_ring->wq_base);
 	printk(KERN_ERR PFX "tx_ring->base_dma = 0x%llx.\n",
 	       (unsigned long long) tx_ring->wq_base_dma);
-	printk(KERN_ERR PFX "tx_ring->cnsmr_idx_sh_reg = %p.\n",
-	       tx_ring->cnsmr_idx_sh_reg);
-	printk(KERN_ERR PFX "tx_ring->cnsmr_idx_sh_reg_dma = 0x%llx.\n",
-	       (unsigned long long) tx_ring->cnsmr_idx_sh_reg_dma);
+	printk(KERN_ERR PFX
+	       "tx_ring->cnsmr_idx_sh_reg, addr = 0x%p, value = %d.\n",
+	       tx_ring->cnsmr_idx_sh_reg,
+	       tx_ring->cnsmr_idx_sh_reg
+			? ql_read_sh_reg(tx_ring->cnsmr_idx_sh_reg) : 0);
 	printk(KERN_ERR PFX "tx_ring->size = %d.\n", tx_ring->wq_size);
 	printk(KERN_ERR PFX "tx_ring->len = %d.\n", tx_ring->wq_len);
 	printk(KERN_ERR PFX "tx_ring->prod_idx_db_reg = %p.\n",
@@ -558,9 +559,10 @@ void ql_dump_rx_ring(struct rx_ring *rx_ring)
 	printk(KERN_ERR PFX "rx_ring->cq_size = %d.\n", rx_ring->cq_size);
 	printk(KERN_ERR PFX "rx_ring->cq_len = %d.\n", rx_ring->cq_len);
 	printk(KERN_ERR PFX
-	       "rx_ring->prod_idx_sh_reg, addr = %p, value = %d.\n",
+	       "rx_ring->prod_idx_sh_reg, addr = 0x%p, value = %d.\n",
 	       rx_ring->prod_idx_sh_reg,
-	       rx_ring->prod_idx_sh_reg ? *(rx_ring->prod_idx_sh_reg) : 0);
+	       rx_ring->prod_idx_sh_reg
+			? ql_read_sh_reg(rx_ring->prod_idx_sh_reg) : 0);
 	printk(KERN_ERR PFX "rx_ring->prod_idx_sh_reg_dma = %llx.\n",
 	       (unsigned long long) rx_ring->prod_idx_sh_reg_dma);
 	printk(KERN_ERR PFX "rx_ring->cnsmr_idx_db_reg = %p.\n",
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index f4c0160..983c953 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1545,7 +1545,7 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
 static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 {
 	struct ql_adapter *qdev = rx_ring->qdev;
-	u32 prod = le32_to_cpu(*rx_ring->prod_idx_sh_reg);
+	u32 prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
 	struct ob_mac_iocb_rsp *net_rsp = NULL;
 	int count = 0;
 
@@ -1571,7 +1571,7 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 		}
 		count++;
 		ql_update_cq(rx_ring);
-		prod = le32_to_cpu(*rx_ring->prod_idx_sh_reg);
+		prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
 	}
 	ql_write_cq_idx(rx_ring);
 	if (netif_queue_stopped(qdev->ndev) && net_rsp != NULL) {
@@ -1591,7 +1591,7 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 {
 	struct ql_adapter *qdev = rx_ring->qdev;
-	u32 prod = le32_to_cpu(*rx_ring->prod_idx_sh_reg);
+	u32 prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
 	struct ql_net_rsp_iocb *net_rsp;
 	int count = 0;
 
@@ -1624,7 +1624,7 @@ static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 		}
 		count++;
 		ql_update_cq(rx_ring);
-		prod = le32_to_cpu(*rx_ring->prod_idx_sh_reg);
+		prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
 		if (count == budget)
 			break;
 	}
@@ -1787,7 +1787,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 * Check the default queue and wake handler if active.
 	 */
 	rx_ring = &qdev->rx_ring[0];
-	if (le32_to_cpu(*rx_ring->prod_idx_sh_reg) != rx_ring->cnsmr_idx) {
+	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) != rx_ring->cnsmr_idx) {
 		QPRINTK(qdev, INTR, INFO, "Waking handler for rx_ring[0].\n");
 		ql_disable_completion_interrupt(qdev, intr_context->intr);
 		queue_delayed_work_on(smp_processor_id(), qdev->q_workqueue,
@@ -1801,7 +1801,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 		 */
 		for (i = 1; i < qdev->rx_ring_count; i++) {
 			rx_ring = &qdev->rx_ring[i];
-			if (le32_to_cpu(*rx_ring->prod_idx_sh_reg) !=
+			if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
 			    rx_ring->cnsmr_idx) {
 				QPRINTK(qdev, INTR, INFO,
 					"Waking handler for rx_ring[%d].\n", i);
-- 
1.6.0

