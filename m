From: <netanel@amazon.com>
Subject: [PATCH net-next 8/8] net: ena: bug fix in lost tx packets detection mechanism
Date: Fri, 9 Jun 2017 09:55:25 +0300
Message-ID: <1496991325-551-10-git-send-email-netanel@amazon.com>
References: <1496991325-551-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:42557 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751528AbdFIG4z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 02:56:55 -0400
In-Reply-To: <1496991325-551-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

check_for_missing_tx_completions() is called from a timer
task and looking for lost tx packets.
The old implementation accumulate all the lost tx packets
and did not check if those packets were retrieved on a later stage.
This cause to a situation where the driver reset
the device for no reason.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_ethtool.c |  1 -
 drivers/net/ethernet/amazon/ena/ena_netdev.c  | 66 +++++++++++++++------------
 drivers/net/ethernet/amazon/ena/ena_netdev.h  | 14 +++++-
 3 files changed, 50 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_ethtool.c b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
index 533b2fb..3ee55e2 100644
--- a/drivers/net/ethernet/amazon/ena/ena_ethtool.c
+++ b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
@@ -80,7 +80,6 @@ static const struct ena_stats ena_stats_tx_strings[] = {
 	ENA_STAT_TX_ENTRY(tx_poll),
 	ENA_STAT_TX_ENTRY(doorbells),
 	ENA_STAT_TX_ENTRY(prepare_ctx_err),
-	ENA_STAT_TX_ENTRY(missing_tx_comp),
 	ENA_STAT_TX_ENTRY(bad_req_id),
 };
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 3c366bf..4f16ed3 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1995,6 +1995,7 @@ static netdev_tx_t ena_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_info->tx_descs = nb_hw_desc;
 	tx_info->last_jiffies = jiffies;
+	tx_info->print_once = 0;
 
 	tx_ring->next_to_use = ENA_TX_RING_IDX_NEXT(next_to_use,
 		tx_ring->ring_size);
@@ -2564,13 +2565,44 @@ static void ena_fw_reset_device(struct work_struct *work)
 		"Reset attempt failed. Can not reset the device\n");
 }
 
-static void check_for_missing_tx_completions(struct ena_adapter *adapter)
+static int check_missing_comp_in_queue(struct ena_adapter *adapter,
+				       struct ena_ring *tx_ring)
 {
 	struct ena_tx_buffer *tx_buf;
 	unsigned long last_jiffies;
+	u32 missed_tx = 0;
+	int i;
+
+	for (i = 0; i < tx_ring->ring_size; i++) {
+		tx_buf = &tx_ring->tx_buffer_info[i];
+		last_jiffies = tx_buf->last_jiffies;
+		if (unlikely(last_jiffies &&
+			     time_is_before_jiffies(last_jiffies + TX_TIMEOUT))) {
+			if (!tx_buf->print_once)
+				netif_notice(adapter, tx_err, adapter->netdev,
+					     "Found a Tx that wasn't completed on time, qid %d, index %d.\n",
+					     tx_ring->qid, i);
+
+			tx_buf->print_once = 1;
+			missed_tx++;
+
+			if (unlikely(missed_tx > MAX_NUM_OF_TIMEOUTED_PACKETS)) {
+				netif_err(adapter, tx_err, adapter->netdev,
+					  "The number of lost tx completions is above the threshold (%d > %d). Reset the device\n",
+					  missed_tx, MAX_NUM_OF_TIMEOUTED_PACKETS);
+				set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
+				return -EIO;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static void check_for_missing_tx_completions(struct ena_adapter *adapter)
+{
 	struct ena_ring *tx_ring;
-	int i, j, budget;
-	u32 missed_tx;
+	int i, budget, rc;
 
 	/* Make sure the driver doesn't turn the device in other process */
 	smp_rmb();
@@ -2586,31 +2618,9 @@ static void check_for_missing_tx_completions(struct ena_adapter *adapter)
 	for (i = adapter->last_monitored_tx_qid; i < adapter->num_queues; i++) {
 		tx_ring = &adapter->tx_ring[i];
 
-		for (j = 0; j < tx_ring->ring_size; j++) {
-			tx_buf = &tx_ring->tx_buffer_info[j];
-			last_jiffies = tx_buf->last_jiffies;
-			if (unlikely(last_jiffies && time_is_before_jiffies(last_jiffies + TX_TIMEOUT))) {
-				netif_notice(adapter, tx_err, adapter->netdev,
-					     "Found a Tx that wasn't completed on time, qid %d, index %d.\n",
-					     tx_ring->qid, j);
-
-				u64_stats_update_begin(&tx_ring->syncp);
-				missed_tx = tx_ring->tx_stats.missing_tx_comp++;
-				u64_stats_update_end(&tx_ring->syncp);
-
-				/* Clear last jiffies so the lost buffer won't
-				 * be counted twice.
-				 */
-				tx_buf->last_jiffies = 0;
-
-				if (unlikely(missed_tx > MAX_NUM_OF_TIMEOUTED_PACKETS)) {
-					netif_err(adapter, tx_err, adapter->netdev,
-						  "The number of lost tx completion is above the threshold (%d > %d). Reset the device\n",
-						  missed_tx, MAX_NUM_OF_TIMEOUTED_PACKETS);
-					set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
-				}
-			}
-		}
+		rc = check_missing_comp_in_queue(adapter, tx_ring);
+		if (unlikely(rc))
+			return;
 
 		budget--;
 		if (!budget)
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index 8828f1d..88b5e56 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -146,7 +146,18 @@ struct ena_tx_buffer {
 	u32 tx_descs;
 	/* num of buffers used by this skb */
 	u32 num_of_bufs;
-	/* Save the last jiffies to detect missing tx packets */
+
+	/* Used for detect missing tx packets to limit the number of prints */
+	u32 print_once;
+	/* Save the last jiffies to detect missing tx packets
+	 *
+	 * sets to non zero value on ena_start_xmit and set to zero on
+	 * napi and timer_Service_routine.
+	 *
+	 * while this value is not protected by lock,
+	 * a given packet is not expected to be handled by ena_start_xmit
+	 * and by napi/timer_service at the same time.
+	 */
 	unsigned long last_jiffies;
 	struct ena_com_buf bufs[ENA_PKT_MAX_BUFS];
 } ____cacheline_aligned;
@@ -170,7 +181,6 @@ struct ena_stats_tx {
 	u64 napi_comp;
 	u64 tx_poll;
 	u64 doorbells;
-	u64 missing_tx_comp;
 	u64 bad_req_id;
 };
 
-- 
2.7.4
