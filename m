From: <netanel@amazon.com>
Subject: [PATCH net-next 6/8] net: ena: fix theoretical Rx hang on low memory systems
Date: Fri, 9 Jun 2017 00:46:33 +0300
Message-ID: <1496958410-4220-7-git-send-email-netanel@amazon.com>
References: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6002.amazon.com ([52.95.49.90]:28001 "EHLO
        smtp-fw-6002.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdFHVsA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 17:48:00 -0400
In-Reply-To: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

For the rare case where the device runs out of free rx buffer
descriptors (in case of pressure on kernel  memory),
and the napi handler continuously fail to refill new Rx descriptors
until device rx queue totally runs out of all free rx buffers
to post incoming packet, leading to a deadlock:
* The device won't send interrupts since all the new
Rx packets will be dropped.
* The napi handler won't try to allocate new Rx descriptors
since allocation is part of NAPI that's not being invoked any more

The fix involves detecting this scenario and rescheduling NAPI
(to refill buffers) by the keepalive/watchdog task.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_ethtool.c |  1 +
 drivers/net/ethernet/amazon/ena/ena_netdev.c  | 55 +++++++++++++++++++++++++++
 drivers/net/ethernet/amazon/ena/ena_netdev.h  |  2 +
 3 files changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_ethtool.c b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
index 67b2338f..533b2fb 100644
--- a/drivers/net/ethernet/amazon/ena/ena_ethtool.c
+++ b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
@@ -94,6 +94,7 @@ static const struct ena_stats ena_stats_rx_strings[] = {
 	ENA_STAT_RX_ENTRY(dma_mapping_err),
 	ENA_STAT_RX_ENTRY(bad_desc_num),
 	ENA_STAT_RX_ENTRY(rx_copybreak_pkt),
+	ENA_STAT_RX_ENTRY(empty_rx_ring),
 };
 
 static const struct ena_stats ena_stats_ena_com_strings[] = {
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 4e9fbdd..3c366bf 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -190,6 +190,7 @@ static void ena_init_io_rings(struct ena_adapter *adapter)
 		rxr->sgl_size = adapter->max_rx_sgl_size;
 		rxr->smoothed_interval =
 			ena_com_get_nonadaptive_moderation_interval_rx(ena_dev);
+		rxr->empty_rx_queue = 0;
 	}
 }
 
@@ -2619,6 +2620,58 @@ static void check_for_missing_tx_completions(struct ena_adapter *adapter)
 	adapter->last_monitored_tx_qid = i % adapter->num_queues;
 }
 
+/* trigger napi schedule after 2 consecutive detections */
+#define EMPTY_RX_REFILL 2
+/* For the rare case where the device runs out of Rx descriptors and the
+ * napi handler failed to refill new Rx descriptors (due to a lack of memory
+ * for example).
+ * This case will lead to a deadlock:
+ * The device won't send interrupts since all the new Rx packets will be dropped
+ * The napi handler won't allocate new Rx descriptors so the device will be
+ * able to send new packets.
+ *
+ * This scenario can happen when the kernel's vm.min_free_kbytes is too small.
+ * It is recommended to have at least 512MB, with a minimum of 128MB for
+ * constrained environment).
+ *
+ * When such a situation is detected - Reschedule napi
+ */
+static void check_for_empty_rx_ring(struct ena_adapter *adapter)
+{
+	struct ena_ring *rx_ring;
+	int i, refill_required;
+
+	if (!test_bit(ENA_FLAG_DEV_UP, &adapter->flags))
+		return;
+
+	if (test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))
+		return;
+
+	for (i = 0; i < adapter->num_queues; i++) {
+		rx_ring = &adapter->rx_ring[i];
+
+		refill_required =
+			ena_com_sq_empty_space(rx_ring->ena_com_io_sq);
+		if (unlikely(refill_required == (rx_ring->ring_size - 1))) {
+			rx_ring->empty_rx_queue++;
+
+			if (rx_ring->empty_rx_queue >= EMPTY_RX_REFILL) {
+				u64_stats_update_begin(&rx_ring->syncp);
+				rx_ring->rx_stats.empty_rx_ring++;
+				u64_stats_update_end(&rx_ring->syncp);
+
+				netif_err(adapter, drv, adapter->netdev,
+					  "trigger refill for ring %d\n", i);
+
+				napi_schedule(rx_ring->napi);
+				rx_ring->empty_rx_queue = 0;
+			}
+		} else {
+			rx_ring->empty_rx_queue = 0;
+		}
+	}
+}
+
 /* Check for keep alive expiration */
 static void check_for_missing_keep_alive(struct ena_adapter *adapter)
 {
@@ -2673,6 +2726,8 @@ static void ena_timer_service(unsigned long data)
 
 	check_for_missing_tx_completions(adapter);
 
+	check_for_empty_rx_ring(adapter);
+
 	if (debug_area)
 		ena_dump_stats_to_buf(adapter, debug_area);
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index 0e22bce..8828f1d 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -184,6 +184,7 @@ struct ena_stats_rx {
 	u64 dma_mapping_err;
 	u64 bad_desc_num;
 	u64 rx_copybreak_pkt;
+	u64 empty_rx_ring;
 };
 
 struct ena_ring {
@@ -231,6 +232,7 @@ struct ena_ring {
 		struct ena_stats_tx tx_stats;
 		struct ena_stats_rx rx_stats;
 	};
+	int empty_rx_queue;
 } ____cacheline_aligned;
 
 struct ena_stats_dev {
-- 
2.7.4
