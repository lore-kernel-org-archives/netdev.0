From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/6] [NET-NEXT]qlge: Clean up and fix MSI and legacy irq handling.
Date: Sat, 11 Oct 2008 10:17:08 -0700
Message-ID: <1223745433-26440-1-git-send-email-ron.mercer@qlogic.com>
References: <20081011171614.GA26384@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:13301 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760535AbYJKRRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 13:17:15 -0400
In-Reply-To: <20081011171614.GA26384@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    3 +-
 drivers/net/qlge/qlge_main.c |   97 +++++++++++++++++++++---------------------
 drivers/net/qlge/qlge_mpi.c  |    1 -
 3 files changed, 50 insertions(+), 51 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index c37ea43..cc246f8 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1375,7 +1375,6 @@ struct ql_adapter {
 	spinlock_t adapter_lock;
 	spinlock_t hw_lock;
 	spinlock_t stats_lock;
-	spinlock_t legacy_lock;	/* used for maintaining legacy intr sync */
 
 	/* PCI Bus Relative Register Addresses */
 	void __iomem *reg_base;
@@ -1502,7 +1501,7 @@ void ql_mpi_work(struct work_struct *work);
 void ql_mpi_reset_work(struct work_struct *work);
 int ql_wait_reg_rdy(struct ql_adapter *qdev, u32 reg, u32 bit, u32 ebit);
 void ql_queue_asic_error(struct ql_adapter *qdev);
-void ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
+u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
 void ql_set_ethtool_ops(struct net_device *ndev);
 int ql_read_xgmac_reg64(struct ql_adapter *qdev, u32 reg, u64 *data);
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3af822b..77a66e5 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -577,40 +577,43 @@ static void ql_disable_interrupts(struct ql_adapter *qdev)
  * incremented everytime we queue a worker and decremented everytime
  * a worker finishes.  Once it hits zero we enable the interrupt.
  */
-void ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
+u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 {
-	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags)))
+	u32 var = 0;
+	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr)) {
 		ql_write32(qdev, INTR_EN,
 			   qdev->intr_context[intr].intr_en_mask);
-	else {
-		if (qdev->legacy_check)
-			spin_lock(&qdev->legacy_lock);
+       	var = ql_read32(qdev, STS);
+	} else {
+		unsigned long hw_flags=0;
+		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 		if (atomic_dec_and_test(&qdev->intr_context[intr].irq_cnt)) {
-			QPRINTK(qdev, INTR, ERR, "Enabling interrupt %d.\n",
-				intr);
 			ql_write32(qdev, INTR_EN,
 				   qdev->intr_context[intr].intr_en_mask);
-		} else {
-			QPRINTK(qdev, INTR, ERR,
-				"Skip enable, other queue(s) are active.\n");
+       		var = ql_read32(qdev, STS);
 		}
-		if (qdev->legacy_check)
-			spin_unlock(&qdev->legacy_lock);
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	}
+	return var;
 }
 
 static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 {
 	u32 var = 0;
 
-	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags)))
+	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr))
 		goto exit;
-	else if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
-		ql_write32(qdev, INTR_EN,
-			   qdev->intr_context[intr].intr_dis_mask);
-		var = ql_read32(qdev, STS);
-	}
-	atomic_inc(&qdev->intr_context[intr].irq_cnt);
+	else {
+		unsigned long hw_flags = 0;
+		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+              if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
+		       ql_write32(qdev, INTR_EN,
+			          qdev->intr_context[intr].intr_dis_mask);
+       		var = ql_read32(qdev, STS);
+	       }
+       	atomic_inc(&qdev->intr_context[intr].irq_cnt);
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+       }
 exit:
 	return var;
 }
@@ -623,7 +626,8 @@ static void ql_enable_all_completion_interrupts(struct ql_adapter *qdev)
 		 * and enables only if the result is zero.
 		 * So we precharge it here.
 		 */
-		atomic_set(&qdev->intr_context[i].irq_cnt, 1);
+		if (unlikely(!test_bit(QL_MSIX_ENABLED, &qdev->flags) || i==0))
+			atomic_set(&qdev->intr_context[i].irq_cnt, 1);
 		ql_enable_completion_interrupt(qdev, i);
 	}
 
@@ -1725,19 +1729,6 @@ static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
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
@@ -1752,12 +1743,15 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	int i;
 	int work_done = 0;
 
-	if (qdev->legacy_check && qdev->legacy_check(qdev)) {
-		QPRINTK(qdev, INTR, INFO, "Already busy, not our interrupt.\n");
-		return IRQ_NONE;	/* Not our interrupt */
+	spin_lock(&qdev->hw_lock);
+	if(atomic_read(&qdev->intr_context[0].irq_cnt)) {
+		QPRINTK(qdev, INTR, DEBUG, "Shared Interrupt, Not ours!\n");
+		spin_unlock(&qdev->hw_lock);
+		return IRQ_NONE;
 	}
+	spin_unlock(&qdev->hw_lock);
 
-	var = ql_read32(qdev, STS);
+	var = ql_disable_completion_interrupt(qdev, intr_context->intr);
 
 	/*
 	 * Check for fatal error.
@@ -1791,22 +1785,23 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 */
 	rx_ring = &qdev->rx_ring[0];
 	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) != rx_ring->cnsmr_idx) {
-		QPRINTK(qdev, INTR, INFO, "Waking handler for rx_ring[0].\n");
+		QPRINTK(qdev, INTR, DEBUG, "Waking handler for rx_ring[0].\n");
 		ql_disable_completion_interrupt(qdev, intr_context->intr);
 		queue_delayed_work_on(smp_processor_id(), qdev->q_workqueue,
 				      &rx_ring->rx_work, 0);
 		work_done++;
 	}
 
+
+	/*
+	 * Start the DPC for each active queue.
+	 */
 	if (!test_bit(QL_MSIX_ENABLED, &qdev->flags)) {
-		/*
-		 * Start the DPC for each active queue.
-		 */
 		for (i = 1; i < qdev->rx_ring_count; i++) {
 			rx_ring = &qdev->rx_ring[i];
 			if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
 			    rx_ring->cnsmr_idx) {
-				QPRINTK(qdev, INTR, INFO,
+				QPRINTK(qdev, INTR, DEBUG,
 					"Waking handler for rx_ring[%d].\n", i);
 				ql_disable_completion_interrupt(qdev,
 								intr_context->
@@ -1823,6 +1818,8 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 			}
 		}
 	}
+	ql_enable_completion_interrupt(qdev, intr_context->intr);
+
 	return work_done ? IRQ_HANDLED : IRQ_NONE;
 }
 
@@ -2701,8 +2698,6 @@ msi:
 		}
 	}
 	irq_type = LEG_IRQ;
-	spin_lock_init(&qdev->legacy_lock);
-	qdev->legacy_check = ql_legacy_check;
 	QPRINTK(qdev, IFUP, DEBUG, "Running with legacy interrupts.\n");
 }
 
@@ -2791,8 +2786,13 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 		/*
 		 * Single interrupt means one handler for all rings.
 		 */
-		intr_context->handler = qlge_isr;
-		sprintf(intr_context->name, "%s-single_irq", qdev->ndev->name);
+		if (likely(test_bit(QL_MSI_ENABLED, &qdev->flags))) {
+			intr_context->handler = qlge_isr;
+			sprintf(intr_context->name, "%s-msi-single_irq", qdev->ndev->name);
+		} else {
+			intr_context->handler = qlge_isr;
+			sprintf(intr_context->name, "%s-legacy-single_irq", qdev->ndev->name);
+		}
 		for (i = 0; i < qdev->rx_ring_count; i++)
 			qdev->rx_ring[i].irq = 0;
 	}
@@ -2865,7 +2865,8 @@ static int ql_request_irq(struct ql_adapter *qdev)
 				"%s: dev_id = 0x%p.\n", __func__,
 			       &qdev->rx_ring[0]);
 			status =
-			    request_irq(pdev->irq, qlge_isr,
+			    request_irq(pdev->irq,
+					intr_context->handler,
 					test_bit(QL_MSI_ENABLED,
 						 &qdev->
 						 flags) ? 0 : IRQF_SHARED,
@@ -3310,7 +3311,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	 * completion handler rx_rings.
 	 */
 	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
-
 	if (ql_alloc_ring_cb(qdev))
 		return -ENOMEM;
 
@@ -3411,6 +3411,7 @@ static int qlge_open(struct net_device *ndev)
 error_up:
 	ql_release_adapter_resources(qdev);
 	ql_free_ring_cb(qdev);
+	QL_DUMP_ALL(qdev);
 	return err;
 }
 
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 24fe344..6bd3fad 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -132,7 +132,6 @@ void ql_mpi_work(struct work_struct *work)
 		default:
 			/* Clear the MPI firmware status. */
 			ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
-			break;
 		}
 	}
 	ql_enable_completion_interrupt(qdev, 0);
-- 
1.6.0

