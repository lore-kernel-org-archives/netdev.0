From: <netanel@amazon.com>
Subject: [PATCH net-next 2/8] net: ena: fix bug that might cause hang after consecutive open/close interface.
Date: Sat, 10 Jun 2017 01:13:51 +0300
Message-ID: <1497046437-20390-3-git-send-email-netanel@amazon.com>
References: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:49748 "EHLO
        smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFIWO2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 18:14:28 -0400
In-Reply-To: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Fixing a bug that the driver does not unmask the IO interrupts
in ndo_open():
occasionally, the MSI-X interrupt (for one or more IO queues)
can be masked when ndo_close() was called.
If that is followed by ndo open(),
then the MSI-X will be still masked so no interrupt
will be received by the driver.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 41 ++++++++++++++++++----------
 1 file changed, 26 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 7c1214d..0e3c60c7 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1078,6 +1078,26 @@ inline void ena_adjust_intr_moderation(struct ena_ring *rx_ring,
 	rx_ring->per_napi_bytes = 0;
 }
 
+static inline void ena_unmask_interrupt(struct ena_ring *tx_ring,
+					struct ena_ring *rx_ring)
+{
+	struct ena_eth_io_intr_reg intr_reg;
+
+	/* Update intr register: rx intr delay,
+	 * tx intr delay and interrupt unmask
+	 */
+	ena_com_update_intr_reg(&intr_reg,
+				rx_ring->smoothed_interval,
+				tx_ring->smoothed_interval,
+				true);
+
+	/* It is a shared MSI-X.
+	 * Tx and Rx CQ have pointer to it.
+	 * So we use one of them to reach the intr reg
+	 */
+	ena_com_unmask_intr(rx_ring->ena_com_io_cq, &intr_reg);
+}
+
 static inline void ena_update_ring_numa_node(struct ena_ring *tx_ring,
 					     struct ena_ring *rx_ring)
 {
@@ -1108,7 +1128,6 @@ static int ena_io_poll(struct napi_struct *napi, int budget)
 {
 	struct ena_napi *ena_napi = container_of(napi, struct ena_napi, napi);
 	struct ena_ring *tx_ring, *rx_ring;
-	struct ena_eth_io_intr_reg intr_reg;
 
 	u32 tx_work_done;
 	u32 rx_work_done;
@@ -1149,22 +1168,9 @@ static int ena_io_poll(struct napi_struct *napi, int budget)
 			if (ena_com_get_adaptive_moderation_enabled(rx_ring->ena_dev))
 				ena_adjust_intr_moderation(rx_ring, tx_ring);
 
-			/* Update intr register: rx intr delay,
-			 * tx intr delay and interrupt unmask
-			 */
-			ena_com_update_intr_reg(&intr_reg,
-						rx_ring->smoothed_interval,
-						tx_ring->smoothed_interval,
-						true);
-
-			/* It is a shared MSI-X.
-			 * Tx and Rx CQ have pointer to it.
-			 * So we use one of them to reach the intr reg
-			 */
-			ena_com_unmask_intr(rx_ring->ena_com_io_cq, &intr_reg);
+			ena_unmask_interrupt(tx_ring, rx_ring);
 		}
 
-
 		ena_update_ring_numa_node(tx_ring, rx_ring);
 
 		ret = rx_work_done;
@@ -1485,6 +1491,11 @@ static int ena_up_complete(struct ena_adapter *adapter)
 
 	ena_napi_enable_all(adapter);
 
+	/* Enable completion queues interrupt */
+	for (i = 0; i < adapter->num_queues; i++)
+		ena_unmask_interrupt(&adapter->tx_ring[i],
+				     &adapter->rx_ring[i]);
+
 	/* schedule napi in case we had pending packets
 	 * from the last time we disable napi
 	 */
-- 
2.7.4
