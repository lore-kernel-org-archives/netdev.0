From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH] qlge: Fix MSI/legacy single interrupt bug.
Date: Mon, 20 Oct 2008 10:30:26 -0700
Message-ID: <20081020173026.GA27501@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.70.193.117] ([198.70.193.117]:15162 "EHLO
	avexch1.qlogic.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752282AbYJTRwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 13:52:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip can issue spurious interrupts for single interrupt modes. We use disable to clear the condition and allow processing to continue. Also got rid of legacy specific code since it now needs to be done on MSI single irq also.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    5 +--
 drivers/net/qlge/qlge_main.c |   89 +++++++++++++++++++++--------------------
 2 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 38116f9..ba2e1c5 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1375,7 +1375,6 @@ struct ql_adapter {
 	spinlock_t adapter_lock;
 	spinlock_t hw_lock;
 	spinlock_t stats_lock;
-	spinlock_t legacy_lock;	/* used for maintaining legacy intr sync */
 
 	/* PCI Bus Relative Register Addresses */
 	void __iomem *reg_base;
@@ -1399,8 +1398,6 @@ struct ql_adapter {
 	struct msix_entry *msi_x_entry;
 	struct intr_context intr_context[MAX_RX_RINGS];
 
-	int (*legacy_check) (struct ql_adapter *);
-
 	int tx_ring_count;	/* One per online CPU. */
 	u32 rss_ring_first_cq_id;/* index of first inbound (rss) rx_ring */
 	u32 rss_ring_count;	/* One per online CPU.  */
@@ -1502,7 +1499,7 @@ void ql_mpi_work(struct work_struct *work);
 void ql_mpi_reset_work(struct work_struct *work);
 int ql_wait_reg_rdy(struct ql_adapter *qdev, u32 reg, u32 bit, u32 ebit);
 void ql_queue_asic_error(struct ql_adapter *qdev);
-void ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
+u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
 void ql_set_ethtool_ops(struct net_device *ndev);
 int ql_read_xgmac_reg64(struct ql_adapter *qdev, u32 reg, u64 *data);
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 4b2caa6..b83a9c9 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -577,41 +577,53 @@ static void ql_disable_interrupts(struct ql_adapter *qdev)
  * incremented everytime we queue a worker and decremented everytime
  * a worker finishes.  Once it hits zero we enable the interrupt.
  */
-void ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
+u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 {
-	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags)))
+	u32 var = 0;
+	unsigned long hw_flags = 0;
+	struct intr_context *ctx = qdev->intr_context + intr;
+
+	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr)) {
+		/* Always enable if we're MSIX multi interrupts and
+		 * it's not the default (zeroeth) interrupt.
+		 */
 		ql_write32(qdev, INTR_EN,
-			   qdev->intr_context[intr].intr_en_mask);
-	else {
-		if (qdev->legacy_check)
-			spin_lock(&qdev->legacy_lock);
-		if (atomic_dec_and_test(&qdev->intr_context[intr].irq_cnt)) {
-			QPRINTK(qdev, INTR, ERR, "Enabling interrupt %d.\n",
-				intr);
-			ql_write32(qdev, INTR_EN,
-				   qdev->intr_context[intr].intr_en_mask);
-		} else {
-			QPRINTK(qdev, INTR, ERR,
-				"Skip enable, other queue(s) are active.\n");
-		}
-		if (qdev->legacy_check)
-			spin_unlock(&qdev->legacy_lock);
+			   ctx->intr_en_mask);
+		var = ql_read32(qdev, STS);
+		return var;
 	}
+
+	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+	if (atomic_dec_and_test(&ctx->irq_cnt)) {
+		ql_write32(qdev, INTR_EN,
+			   ctx->intr_en_mask);
+		var = ql_read32(qdev, STS);
+	}
+	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+	return var;
 }
 
 static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 {
 	u32 var = 0;
+	unsigned long hw_flags;
+	struct intr_context *ctx;
 
-	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags)))
-		goto exit;
-	else if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
+	/* HW disables for us if we're MSIX multi interrupts and
+	 * it's not the default (zeroeth) interrupt.
+	 */
+	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr))
+		return 0;
+
+	ctx = qdev->intr_context + intr;
+	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+	if (!atomic_read(&ctx->irq_cnt)) {
 		ql_write32(qdev, INTR_EN,
-			   qdev->intr_context[intr].intr_dis_mask);
+		ctx->intr_dis_mask);
 		var = ql_read32(qdev, STS);
 	}
-	atomic_inc(&qdev->intr_context[intr].irq_cnt);
-exit:
+	atomic_inc(&ctx->irq_cnt);
+	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	return var;
 }
 
@@ -623,7 +635,9 @@ static void ql_enable_all_completion_interrupts(struct ql_adapter *qdev)
 		 * and enables only if the result is zero.
 		 * So we precharge it here.
 		 */
-		atomic_set(&qdev->intr_context[i].irq_cnt, 1);
+		if (unlikely(!test_bit(QL_MSIX_ENABLED, &qdev->flags) ||
+			i == 0))
+			atomic_set(&qdev->intr_context[i].irq_cnt, 1);
 		ql_enable_completion_interrupt(qdev, i);
 	}
 
@@ -1725,19 +1739,6 @@ static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-/* We check here to see if we're already handling a legacy
- * interrupt.  If we are, then it must belong to another
- * chip with which we're sharing the interrupt line.
- */
-int ql_legacy_check(struct ql_adapter *qdev)
-{
-	int err;
-	spin_lock(&qdev->legacy_lock);
-	err = atomic_read(&qdev->intr_context[0].irq_cnt);
-	spin_unlock(&qdev->legacy_lock);
-	return err;
-}
-
 /* This handles a fatal error, MPI activity, and the default
  * rx_ring in an MSI-X multiple vector environment.
  * In MSI/Legacy environment it also process the rest of
@@ -1752,12 +1753,15 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	int i;
 	int work_done = 0;
 
-	if (qdev->legacy_check && qdev->legacy_check(qdev)) {
-		QPRINTK(qdev, INTR, INFO, "Already busy, not our interrupt.\n");
-		return IRQ_NONE;	/* Not our interrupt */
+	spin_lock(&qdev->hw_lock);
+	if (atomic_read(&qdev->intr_context[0].irq_cnt)) {
+		QPRINTK(qdev, INTR, DEBUG, "Shared Interrupt, Not ours!\n");
+		spin_unlock(&qdev->hw_lock);
+		return IRQ_NONE;
 	}
+	spin_unlock(&qdev->hw_lock);
 
-	var = ql_read32(qdev, STS);
+	var = ql_disable_completion_interrupt(qdev, intr_context->intr);
 
 	/*
 	 * Check for fatal error.
@@ -1823,6 +1827,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 			}
 		}
 	}
+	ql_enable_completion_interrupt(qdev, intr_context->intr);
 	return work_done ? IRQ_HANDLED : IRQ_NONE;
 }
 
@@ -2701,8 +2706,6 @@ msi:
 		}
 	}
 	irq_type = LEG_IRQ;
-	spin_lock_init(&qdev->legacy_lock);
-	qdev->legacy_check = ql_legacy_check;
 	QPRINTK(qdev, IFUP, DEBUG, "Running with legacy interrupts.\n");
 }
 
-- 
1.6.0

