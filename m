From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V2 net 10/20] net/ena: remove redundant logic in napi callback for busy poll mode
Date: Sun,  4 Dec 2016 15:19:28 +0200
Message-ID: <1480857578-5065-11-git-send-email-netanel@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sk_busy_loop can call the napi callback few million times a sec.
For each call there is unmask interrupt.
We want to reduce the number of unmasks.

Add an atomic variable that will tell the napi handler if
it was called from irq context or not.
Unmask the interrupt only from irq context.

A schenario where the driver left with missed unmask isn't feasible.
when ena_intr_msix_io is called the driver have 2 options:
1)Before napi completes and call napi_complete_done
2)After calling napi_complete_done

In the former case the napi will unmask the interrupt as needed.
In the latter case napi_complete_done will remove napi from the schedule
list so napi will be rescheduled (by ena_intr_msix_io) and interrupt
will be unmasked as desire in the 2nd napi call.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 46 +++++++++++++++++++---------
 drivers/net/ethernet/amazon/ena/ena_netdev.h |  1 +
 2 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index bb7eeea..5625007 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1129,26 +1129,41 @@ static int ena_io_poll(struct napi_struct *napi, int budget)
 	tx_work_done = ena_clean_tx_irq(tx_ring, tx_budget);
 	rx_work_done = ena_clean_rx_irq(rx_ring, napi, budget);
 
-	if ((budget > rx_work_done) && (tx_budget > tx_work_done)) {
+	/* If the device is about to reset or down, avoid unmask
+	 * the interrupt and return 0 so NAPI won't reschedule
+	 */
+	if (unlikely(!test_bit(ENA_FLAG_DEV_UP, &tx_ring->adapter->flags) ||
+		     test_bit(ENA_FLAG_TRIGGER_RESET, &tx_ring->adapter->flags))) {
+		napi_complete_done(napi, 0);
+		ret = 0;
+
+	} else if ((budget > rx_work_done) && (tx_budget > tx_work_done)) {
 		napi_complete_done(napi, rx_work_done);
 
 		napi_comp_call = 1;
-		/* Tx and Rx share the same interrupt vector */
-		if (ena_com_get_adaptive_moderation_enabled(rx_ring->ena_dev))
-			ena_adjust_intr_moderation(rx_ring, tx_ring);
-
-		/* Update intr register: rx intr delay, tx intr delay and
-		 * interrupt unmask
+		/* Update numa and unmask the interrupt only when schedule
+		 * from the interrupt context (vs from sk_busy_loop)
 		 */
-		ena_com_update_intr_reg(&intr_reg,
-					rx_ring->smoothed_interval,
-					tx_ring->smoothed_interval,
-					true);
+		if (atomic_cmpxchg(&ena_napi->unmask_interrupt, 1, 0)) {
+			/* Tx and Rx share the same interrupt vector */
+			if (ena_com_get_adaptive_moderation_enabled(rx_ring->ena_dev))
+				ena_adjust_intr_moderation(rx_ring, tx_ring);
+
+			/* Update intr register: rx intr delay,
+			 * tx intr delay and interrupt unmask
+			 */
+			ena_com_update_intr_reg(&intr_reg,
+						rx_ring->smoothed_interval,
+						tx_ring->smoothed_interval,
+						true);
+
+			/* It is a shared MSI-X.
+			 * Tx and Rx CQ have pointer to it.
+			 * So we use one of them to reach the intr reg
+			 */
+			ena_com_unmask_intr(rx_ring->ena_com_io_cq, &intr_reg);
+		}
 
-		/* It is a shared MSI-X. Tx and Rx CQ have pointer to it.
-		 * So we use one of them to reach the intr reg
-		 */
-		ena_com_unmask_intr(rx_ring->ena_com_io_cq, &intr_reg);
 
 		ena_update_ring_numa_node(tx_ring, rx_ring);
 
@@ -1186,6 +1201,7 @@ static irqreturn_t ena_intr_msix_io(int irq, void *data)
 {
 	struct ena_napi *ena_napi = data;
 
+	atomic_set(&ena_napi->unmask_interrupt, 1);
 	napi_schedule(&ena_napi->napi);
 
 	return IRQ_HANDLED;
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index 2897fab..c081fd3 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -135,6 +135,7 @@ struct ena_napi {
 	struct napi_struct napi ____cacheline_aligned;
 	struct ena_ring *tx_ring;
 	struct ena_ring *rx_ring;
+	atomic_t unmask_interrupt;
 	u32 qid;
 };
 
-- 
2.7.4
