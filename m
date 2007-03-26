From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/7] qla3xxx: bugfix: Dropping interrupt under heavy network load.
Date: Mon, 26 Mar 2007 13:42:59 -0700
Message-ID: <11749417831535-git-send-email-ron.mercer@qlogic.com>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:9929 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbXCZUnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 16:43:07 -0400
In-Reply-To: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the rx queue pointer when exiting NAPI poll rather than
at the end of each iteration.  Remove unnecessary PCI flushes
that occurred after every write.  Now write all regs and
flush once.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   71 ++++++++++++++++++++----------------------------
 1 files changed, 30 insertions(+), 41 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 85850d1..24c485e 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1691,6 +1691,27 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 /*
  * Caller holds hw_lock.
  */
+static void ql_update_small_bufq_prod_index(struct ql3_adapter *qdev)
+{
+	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	if (qdev->small_buf_release_cnt >= 16) {
+		while (qdev->small_buf_release_cnt >= 16) {
+			qdev->small_buf_q_producer_index++;
+
+			if (qdev->small_buf_q_producer_index ==
+			    NUM_SBUFQ_ENTRIES)
+				qdev->small_buf_q_producer_index = 0;
+			qdev->small_buf_release_cnt -= 8;
+		}
+		wmb();
+		writel(qdev->small_buf_q_producer_index,
+			&port_regs->CommonRegs.rxSmallQProducerIndex);
+	}
+}
+
+/*
+ * Caller holds hw_lock.
+ */
 static void ql_update_lrg_bufq_prod_index(struct ql3_adapter *qdev)
 {
 	struct bufq_addr_element *lrg_buf_q_ele;
@@ -1732,13 +1753,10 @@ static void ql_update_lrg_bufq_prod_index(struct ql3_adapter *qdev)
 				lrg_buf_q_ele = qdev->lrg_buf_q_virt_addr;
 			}
 		}
-
+		wmb();
 		qdev->lrg_buf_next_free = lrg_buf_q_ele;
-
-		ql_write_common_reg(qdev,
-				    &port_regs->CommonRegs.
-				    rxLargeQProducerIndex,
-				    qdev->lrg_buf_q_producer_index);
+		writel(qdev->lrg_buf_q_producer_index,
+			&port_regs->CommonRegs.rxLargeQProducerIndex);
 	}
 }
 
@@ -1944,16 +1962,12 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 			  int *tx_cleaned, int *rx_cleaned, int work_to_do)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
 	struct net_rsp_iocb *net_rsp;
 	struct net_device *ndev = qdev->ndev;
-	unsigned long hw_flags;
 	int work_done = 0;
 
-	u32 rsp_producer_index = le32_to_cpu(*(qdev->prsp_producer_index));
-
 	/* While there are entries in the completion queue. */
-	while ((rsp_producer_index !=
+	while ((le32_to_cpu(*(qdev->prsp_producer_index)) !=
 		qdev->rsp_consumer_index) && (work_done < work_to_do)) {
 
 		net_rsp = qdev->rsp_current;
@@ -2009,33 +2023,7 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 		work_done = *tx_cleaned + *rx_cleaned;
 	}
 
-	if(work_done) {
-		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-
-		ql_update_lrg_bufq_prod_index(qdev);
-
-		if (qdev->small_buf_release_cnt >= 16) {
-			while (qdev->small_buf_release_cnt >= 16) {
-				qdev->small_buf_q_producer_index++;
-
-				if (qdev->small_buf_q_producer_index ==
-				    NUM_SBUFQ_ENTRIES)
-					qdev->small_buf_q_producer_index = 0;
-				qdev->small_buf_release_cnt -= 8;
-			}
-
-			wmb();
-			ql_write_common_reg(qdev,
-					    &port_regs->CommonRegs.
-					    rxSmallQProducerIndex,
-					    qdev->small_buf_q_producer_index);
-
-		}
-
-		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
-	}
-
-	return *tx_cleaned + *rx_cleaned;
+	return work_done;
 }
 
 static int ql_poll(struct net_device *ndev, int *budget)
@@ -2059,9 +2047,10 @@ quit_polling:
 		netif_rx_complete(ndev);
 
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-		ql_write_common_reg(qdev,
-				    &port_regs->CommonRegs.rspQConsumerIndex,
-				    qdev->rsp_consumer_index);
+		ql_update_small_bufq_prod_index(qdev);
+		ql_update_lrg_bufq_prod_index(qdev);
+		writel(qdev->rsp_consumer_index,
+			    &port_regs->CommonRegs.rspQConsumerIndex);
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 
 		ql_enable_interrupts(qdev);
-- 
1.5.0.rc4.16.g9e258

