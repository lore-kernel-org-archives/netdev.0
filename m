From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 11/13] qla3xxx: bugfix tx reset after stress conditions.
Date: Mon, 26 Feb 2007 11:06:41 -0800
Message-ID: <11725168041139-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030464AbXBZTHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:49 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To Reproduce the Problem:
To reproduce this panic consistently, we run an intensive network
application like 'netperf' and then switch to a different console.
After waiting for a couple of seconds, you will see a tx reset has occured.

Reason:
We enable interrupts even if we were not running.

Solution:
Now we will enable interrupts only after we are ready to give up the poll
routine.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   69 +++++++++++++++++++++++++++++--------------------
 1 files changed, 41 insertions(+), 28 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 63522ea..bc9109a 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1939,10 +1939,11 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 	struct net_rsp_iocb *net_rsp;
 	struct net_device *ndev = qdev->ndev;
 	unsigned long hw_flags;
+	int work_done = 0;
 
 	/* While there are entries in the completion queue. */
 	while ((cpu_to_le32(*(qdev->prsp_producer_index)) !=
-		qdev->rsp_consumer_index) && (*rx_cleaned < work_to_do)) {
+		qdev->rsp_consumer_index) && (work_done < work_to_do)) {
 
 		net_rsp = qdev->rsp_current;
 		switch (net_rsp->opcode) {
@@ -1993,37 +1994,41 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 		} else {
 			qdev->rsp_current++;
 		}
+
+		work_done = *tx_cleaned + *rx_cleaned;
 	}
 
-	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+	if(work_done) {
+		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 
-	ql_update_lrg_bufq_prod_index(qdev);
+		ql_update_lrg_bufq_prod_index(qdev);
 
-	if (qdev->small_buf_release_cnt >= 16) {
-		while (qdev->small_buf_release_cnt >= 16) {
-			qdev->small_buf_q_producer_index++;
+		if (qdev->small_buf_release_cnt >= 16) {
+			while (qdev->small_buf_release_cnt >= 16) {
+				qdev->small_buf_q_producer_index++;
 
-			if (qdev->small_buf_q_producer_index ==
-			    NUM_SBUFQ_ENTRIES)
-				qdev->small_buf_q_producer_index = 0;
-			qdev->small_buf_release_cnt -= 8;
-		}
+				if (qdev->small_buf_q_producer_index ==
+				    NUM_SBUFQ_ENTRIES)
+					qdev->small_buf_q_producer_index = 0;
+				qdev->small_buf_release_cnt -= 8;
+			}
 
-		ql_write_common_reg(qdev,
-				    &port_regs->CommonRegs.
-				    rxSmallQProducerIndex,
-				    qdev->small_buf_q_producer_index);
-	}
+			wmb();
+			ql_write_common_reg(qdev,
+					    &port_regs->CommonRegs.
+					    rxSmallQProducerIndex,
+					    qdev->small_buf_q_producer_index);
 
-	ql_write_common_reg(qdev,
-			    &port_regs->CommonRegs.rspQConsumerIndex,
-			    qdev->rsp_consumer_index);
-	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+		}
 
-	if (unlikely(netif_queue_stopped(qdev->ndev))) {
-		if (netif_queue_stopped(qdev->ndev) &&
-		    (atomic_read(&qdev->tx_count) > (NUM_REQ_Q_ENTRIES / 4)))
-			netif_wake_queue(qdev->ndev);
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+
+		if (unlikely(netif_queue_stopped(qdev->ndev))) {
+			if (netif_queue_stopped(qdev->ndev) &&
+			    (atomic_read(&qdev->tx_count) > 
+			     (NUM_REQ_Q_ENTRIES / 4)))
+				netif_wake_queue(qdev->ndev);
+		}
 	}
 
 	return *tx_cleaned + *rx_cleaned;
@@ -2034,6 +2039,8 @@ static int ql_poll(struct net_device *ndev, int *budget)
 	struct ql3_adapter *qdev = netdev_priv(ndev);
 	int work_to_do = min(*budget, ndev->quota);
 	int rx_cleaned = 0, tx_cleaned = 0;
+	unsigned long hw_flags;
+	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
 
 	if (!netif_carrier_ok(ndev))
 		goto quit_polling;
@@ -2045,6 +2052,13 @@ static int ql_poll(struct net_device *ndev, int *budget)
 	if ((!tx_cleaned && !rx_cleaned) || !netif_running(ndev)) {
 quit_polling:
 		netif_rx_complete(ndev);
+
+		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+		ql_write_common_reg(qdev,
+				    &port_regs->CommonRegs.rspQConsumerIndex,
+				    qdev->rsp_consumer_index);
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+
 		ql_enable_interrupts(qdev);
 		return 0;
 	}
@@ -2097,11 +2111,10 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 		queue_delayed_work(qdev->workqueue, &qdev->reset_work, 0);
 		spin_unlock(&qdev->adapter_lock);
 	} else if (value & ISP_IMR_DISABLE_CMPL_INT) {
-		ql_disable_interrupts(qdev);
-		if (likely(netif_rx_schedule_prep(ndev)))
+		if (likely(netif_rx_schedule_prep(ndev))) {
+			ql_disable_interrupts(qdev);
 			__netif_rx_schedule(ndev);
-		else
-			ql_enable_interrupts(qdev);
+		}
 	} else {
 		return IRQ_NONE;
 	}
-- 
1.5.0.rc4.16.g9e258

