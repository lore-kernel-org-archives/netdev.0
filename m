From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V3 net-next 09/14] net/ena: use napi_complete_done() return value
Date: Fri, 27 Jan 2017 00:18:11 +0200
Message-ID: <1485469096-5271-10-git-send-email-netanel@annapurnalabs.com>
References: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37256 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754228AbdAZWSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 17:18:49 -0500
Received: by mail-wm0-f49.google.com with SMTP id c206so108565061wme.0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 14:18:49 -0800 (PST)
In-Reply-To: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not unamsk interrupts if we are in busy poll mode.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 44 ++++++++++++++++++----------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 606fb5c..d1e1d9d 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1122,26 +1122,40 @@ static int ena_io_poll(struct napi_struct *napi, int budget)
 	tx_work_done = ena_clean_tx_irq(tx_ring, tx_budget);
 	rx_work_done = ena_clean_rx_irq(rx_ring, napi, budget);
 
-	if ((budget > rx_work_done) && (tx_budget > tx_work_done)) {
-		napi_complete_done(napi, rx_work_done);
+	/* If the device is about to reset or down, avoid unmask
+	 * the interrupt and return 0 so NAPI won't reschedule
+	 */
+	if (unlikely(!test_bit(ENA_FLAG_DEV_UP, &tx_ring->adapter->flags) ||
+		     test_bit(ENA_FLAG_TRIGGER_RESET, &tx_ring->adapter->flags))) {
+		napi_complete_done(napi, 0);
+		ret = 0;
 
+	} else if ((budget > rx_work_done) && (tx_budget > tx_work_done)) {
 		napi_comp_call = 1;
-		/* Tx and Rx share the same interrupt vector */
-		if (ena_com_get_adaptive_moderation_enabled(rx_ring->ena_dev))
-			ena_adjust_intr_moderation(rx_ring, tx_ring);
 
-		/* Update intr register: rx intr delay, tx intr delay and
-		 * interrupt unmask
+		/* Update numa and unmask the interrupt only when schedule
+		 * from the interrupt context (vs from sk_busy_loop)
 		 */
-		ena_com_update_intr_reg(&intr_reg,
-					rx_ring->smoothed_interval,
-					tx_ring->smoothed_interval,
-					true);
+		if (napi_complete_done(napi, rx_work_done)) {
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
 
-- 
2.7.4
