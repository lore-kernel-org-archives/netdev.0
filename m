From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/5] qlge: bugfix: Fix shadow register endian issue.
Date: Tue, 30 Dec 2008 13:12:23 -0800
Message-ID: <1230671545-19084-3-git-send-email-ron.mercer@qlogic.com>
References: <20081230211122.GD16018@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, bhutchings@solarflare.com, hch@infradead.org
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:38470 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbYL3VMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 16:12:25 -0500
In-Reply-To: <20081230211122.GD16018@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shadow registers are consistent memory locations to which the chip
echos ring indexes in little endian format.  These values need to
be endian swapped before referencing.

Note:
The register pointer declaration uses the volatile modifier which
causes warnings in checkpatch.
Per Documentation/volatile-considered-harmful.txt:
  - Pointers to data structures in coherent memory which might be modified
    by I/O devices can, sometimes, legitimately be volatile.  A ring buffer
    used by a network adapter, where that adapter changes pointers to
    indicate which descriptors have been processed, is an example of this
    type of situation.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   17 +----------------
 drivers/net/qlge/qlge_main.c |   12 ++++++------
 2 files changed, 7 insertions(+), 22 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index ba2e1c5..97321bb 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1189,7 +1189,7 @@ struct rx_ring {
 	u32 cq_size;
 	u32 cq_len;
 	u16 cq_id;
-	u32 *prod_idx_sh_reg;	/* Shadowed producer register. */
+	volatile __le32 *prod_idx_sh_reg;	/* Shadowed producer register. */
 	dma_addr_t prod_idx_sh_reg_dma;
 	void __iomem *cnsmr_idx_db_reg;	/* PCI doorbell mem area + 0 */
 	u32 cnsmr_idx;		/* current sw idx */
@@ -1467,21 +1467,6 @@ static inline void ql_write_db_reg(u32 val, void __iomem *addr)
 	mmiowb();
 }
 
-/*
- * Shadow Registers:
- * Outbound queues have a consumer index that is maintained by the chip.
- * Inbound queues have a producer index that is maintained by the chip.
- * For lower overhead, these registers are "shadowed" to host memory
- * which allows the device driver to track the queue progress without
- * PCI reads. When an entry is placed on an inbound queue, the chip will
- * update the relevant index register and then copy the value to the
- * shadow register in host memory.
- */
-static inline unsigned int ql_read_sh_reg(const volatile void  *addr)
-{
-	return *(volatile unsigned int __force *)addr;
-}
-
 extern char qlge_driver_name[];
 extern const char qlge_driver_version[];
 extern const struct ethtool_ops qlge_ethtool_ops;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 9ceedfc..c0e43c5 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1559,7 +1559,7 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
 static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 {
 	struct ql_adapter *qdev = rx_ring->qdev;
-	u32 prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
+	u32 prod = le32_to_cpu(*rx_ring->prod_idx_sh_reg);
 	struct ob_mac_iocb_rsp *net_rsp = NULL;
 	int count = 0;
 
@@ -1585,7 +1585,7 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 		}
 		count++;
 		ql_update_cq(rx_ring);
-		prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
+		prod = le32_to_cpu(*rx_ring->prod_idx_sh_reg);
 	}
 	ql_write_cq_idx(rx_ring);
 	if (netif_queue_stopped(qdev->ndev) && net_rsp != NULL) {
@@ -1605,7 +1605,7 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 {
 	struct ql_adapter *qdev = rx_ring->qdev;
-	u32 prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
+	u32 prod = le32_to_cpu(*rx_ring->prod_idx_sh_reg);
 	struct ql_net_rsp_iocb *net_rsp;
 	int count = 0;
 
@@ -1638,7 +1638,7 @@ static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 		}
 		count++;
 		ql_update_cq(rx_ring);
-		prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
+		prod = le32_to_cpu(*rx_ring->prod_idx_sh_reg);
 		if (count == budget)
 			break;
 	}
@@ -1801,7 +1801,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 * Check the default queue and wake handler if active.
 	 */
 	rx_ring = &qdev->rx_ring[0];
-	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) != rx_ring->cnsmr_idx) {
+	if (le32_to_cpu(*rx_ring->prod_idx_sh_reg) != rx_ring->cnsmr_idx) {
 		QPRINTK(qdev, INTR, INFO, "Waking handler for rx_ring[0].\n");
 		ql_disable_completion_interrupt(qdev, intr_context->intr);
 		queue_delayed_work_on(smp_processor_id(), qdev->q_workqueue,
@@ -1815,7 +1815,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 		 */
 		for (i = 1; i < qdev->rx_ring_count; i++) {
 			rx_ring = &qdev->rx_ring[i];
-			if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
+			if (le32_to_cpu(*rx_ring->prod_idx_sh_reg) !=
 			    rx_ring->cnsmr_idx) {
 				QPRINTK(qdev, INTR, INFO,
 					"Waking handler for rx_ring[%d].\n", i);
-- 
1.6.0

