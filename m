From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 05/11] bnx2: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:16 +0100
Message-ID: <1418135842-21389-6-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-HSGLinuxNICDev@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:53186 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755936AbaLIOjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:39:20 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt
handlers.

No actual testing done, only compiled.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: Dept-HSGLinuxNICDev@qlogic.com
---
 drivers/net/ethernet/broadcom/bnx2.c | 24 ++++++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2.h |  4 ++++
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 823d01c5684c..675d90849d10 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -39,6 +39,7 @@
 #include <linux/mii.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
+#include <linux/netpoll.h>
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/checksum.h>
@@ -864,6 +865,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 		&bnapi->status_blk.msi->status_tx_quick_consumer_index0;
 	bnapi->hw_rx_cons_ptr =
 		&bnapi->status_blk.msi->status_rx_quick_consumer_index0;
+	netpoll_irq_lock_init(&bnapi->netpoll_lock);
 	if (bp->flags & BNX2_FLAG_MSIX_CAP) {
 		for (i = 1; i < bp->irq_nvecs; i++) {
 			struct status_block_msix *sblk;
@@ -876,6 +878,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 				&sblk->status_tx_quick_consumer_index;
 			bnapi->hw_rx_cons_ptr =
 				&sblk->status_rx_quick_consumer_index;
+			netpoll_irq_lock_init(&bnapi->netpoll_lock);
 			bnapi->int_num = i << 24;
 		}
 	}
@@ -3302,6 +3305,7 @@ bnx2_msi(int irq, void *dev_instance)
 	struct bnx2_napi *bnapi = dev_instance;
 	struct bnx2 *bp = bnapi->bp;
 
+	netpoll_irq_lock(&bnapi->netpoll_lock);
 	prefetch(bnapi->status_blk.msi);
 	BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 		BNX2_PCICFG_INT_ACK_CMD_USE_INT_HC_PARAM |
@@ -3309,10 +3313,12 @@ bnx2_msi(int irq, void *dev_instance)
 
 	/* Return here if interrupt is disabled. */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
-		return IRQ_HANDLED;
+		goto out;
 
 	napi_schedule(&bnapi->napi);
 
+out:
+	netpoll_irq_unlock(&bnapi->netpoll_lock);
 	return IRQ_HANDLED;
 }
 
@@ -3322,14 +3328,17 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 	struct bnx2_napi *bnapi = dev_instance;
 	struct bnx2 *bp = bnapi->bp;
 
+	netpoll_irq_lock(&bnapi->netpoll_lock);
 	prefetch(bnapi->status_blk.msi);
 
 	/* Return here if interrupt is disabled. */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
-		return IRQ_HANDLED;
+		goto out;
 
 	napi_schedule(&bnapi->napi);
 
+out:
+	netpoll_irq_unlock(&bnapi->netpoll_lock);
 	return IRQ_HANDLED;
 }
 
@@ -3340,6 +3349,7 @@ bnx2_interrupt(int irq, void *dev_instance)
 	struct bnx2 *bp = bnapi->bp;
 	struct status_block *sblk = bnapi->status_blk.msi;
 
+	netpoll_irq_lock(&bnapi->netpoll_lock);
 	/* When using INTx, it is possible for the interrupt to arrive
 	 * at the CPU before the status block posted prior to the
 	 * interrupt. Reading a register will flush the status block.
@@ -3348,8 +3358,10 @@ bnx2_interrupt(int irq, void *dev_instance)
 	 */
 	if ((sblk->status_idx == bnapi->last_status_idx) &&
 	    (BNX2_RD(bp, BNX2_PCICFG_MISC_STATUS) &
-	     BNX2_PCICFG_MISC_STATUS_INTA_VALUE))
+	     BNX2_PCICFG_MISC_STATUS_INTA_VALUE)) {
+		netpoll_irq_unlock(&bnapi->netpoll_lock);
 		return IRQ_NONE;
+	}
 
 	BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 		BNX2_PCICFG_INT_ACK_CMD_USE_INT_HC_PARAM |
@@ -3362,13 +3374,15 @@ bnx2_interrupt(int irq, void *dev_instance)
 
 	/* Return here if interrupt is shared and is disabled. */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
-		return IRQ_HANDLED;
+		goto out;
 
 	if (napi_schedule_prep(&bnapi->napi)) {
 		bnapi->last_status_idx = sblk->status_idx;
 		__napi_schedule(&bnapi->napi);
 	}
 
+out:
+	netpoll_irq_unlock(&bnapi->netpoll_lock);
 	return IRQ_HANDLED;
 }
 
@@ -7915,9 +7929,7 @@ poll_bnx2(struct net_device *dev)
 	for (i = 0; i < bp->irq_nvecs; i++) {
 		struct bnx2_irq *irq = &bp->irq_tbl[i];
 
-		disable_irq(irq->vector);
 		irq->handler(irq->vector, &bp->bnx2_napi[i]);
-		enable_irq(irq->vector);
 	}
 }
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 28df35d35893..a9ee8c2e1847 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -14,6 +14,8 @@
 #ifndef BNX2_H
 #define BNX2_H
 
+#include <linux/netpoll.h>
+
 /* Hardware data structures and register definitions automatically
  * generated from RTL code. Do not modify.
  */
@@ -6780,6 +6782,8 @@ struct bnx2_napi {
 
 	struct bnx2_rx_ring_info	rx_ring;
 	struct bnx2_tx_ring_info	tx_ring;
+
+	struct netpoll_irq_lock netpoll_lock;
 };
 
 struct bnx2 {
-- 
2.1.3
