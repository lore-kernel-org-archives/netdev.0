From: Harish Patil <harish.patil@qlogic.com>
Subject: [PATCH net-next 1/2] qlcnic: Enhance Tx timeout debug data collection.
Date: Fri, 27 Jun 2014 19:01:38 -0400
Message-ID: <1403910099-2835-2-git-send-email-harish.patil@qlogic.com>
References: <1403910099-2835-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:2019 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752488AbaF0XcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:32:25 -0400
In-Reply-To: <1403910099-2835-1-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

- Collect a firmware dump on first Tx timeout if netif_msg_tx_err() is set
- Log Receive and Status ring info on Tx timeout, in addition to Tx ring info
- Log additional Tx ring info if netif_msg_tx_err() is set

Signed-off-by: Harish Patil <harish.patil@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 41 ++++++++++++++++++++----
 1 file changed, 35 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 4fc1867..f8de2ae 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2980,17 +2980,43 @@ static inline void dump_tx_ring_desc(struct qlcnic_host_tx_ring *tx_ring)
 	}
 }
 
-static void qlcnic_dump_tx_rings(struct qlcnic_adapter *adapter)
+static void qlcnic_dump_rings(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
 
 	if (!netdev || !netif_running(netdev))
 		return;
 
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+		if (!rds_ring)
+			continue;
+		netdev_info(netdev,
+			    "rds_ring=%d crb_rcv_producer=%d producer=%u num_desc=%u\n",
+			     ring, readl(rds_ring->crb_rcv_producer),
+			     rds_ring->producer, rds_ring->num_desc);
+	}
+
+	for (ring = 0; ring < adapter->drv_sds_rings; ring++) {
+		sds_ring = &(recv_ctx->sds_rings[ring]);
+		if (!sds_ring)
+			continue;
+		netdev_info(netdev,
+			    "sds_ring=%d crb_sts_consumer=%d consumer=%u crb_intr_mask=%d num_desc=%u\n",
+			    ring, readl(sds_ring->crb_sts_consumer),
+			    sds_ring->consumer, readl(sds_ring->crb_intr_mask),
+			    sds_ring->num_desc);
+	}
+
 	for (ring = 0; ring < adapter->drv_tx_rings; ring++) {
 		tx_ring = &adapter->tx_ring[ring];
+		if (!tx_ring)
+			continue;
 		netdev_info(netdev, "Tx ring=%d Context Id=0x%x\n",
 			    ring, tx_ring->ctx_id);
 		netdev_info(netdev,
@@ -3013,9 +3039,10 @@ static void qlcnic_dump_tx_rings(struct qlcnic_adapter *adapter)
 		netdev_info(netdev, "Total desc=%d, Available desc=%d\n",
 			    tx_ring->num_desc, qlcnic_tx_avail(tx_ring));
 
-		if (netif_msg_tx_done(adapter->ahw))
+		if (netif_msg_tx_err(adapter->ahw))
 			dump_tx_ring_desc(tx_ring);
 	}
+
 }
 
 static void qlcnic_tx_timeout(struct net_device *netdev)
@@ -3025,16 +3052,18 @@ static void qlcnic_tx_timeout(struct net_device *netdev)
 	if (test_bit(__QLCNIC_RESETTING, &adapter->state))
 		return;
 
-	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS) {
-		netdev_info(netdev, "Tx timeout, reset the adapter.\n");
+	qlcnic_dump_rings(adapter);
+
+	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS ||
+	    netif_msg_tx_err(adapter->ahw)) {
+		netdev_err(netdev, "Tx timeout, reset the adapter.\n");
 		if (qlcnic_82xx_check(adapter))
 			adapter->need_fw_reset = 1;
 		else if (qlcnic_83xx_check(adapter))
 			qlcnic_83xx_idc_request_reset(adapter,
 						      QLCNIC_FORCE_FW_DUMP_KEY);
 	} else {
-		netdev_info(netdev, "Tx timeout, reset adapter context.\n");
-		qlcnic_dump_tx_rings(adapter);
+		netdev_err(netdev, "Tx timeout, reset adapter context.\n");
 		adapter->ahw->reset_context = 1;
 	}
 }
-- 
1.8.1.4
