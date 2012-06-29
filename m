From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 5/6] qlge: Categorize receive frame errors from firmware.
Date: Fri, 29 Jun 2012 14:24:49 -0400
Message-ID: <1340994290-28832-6-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, Ron@linux-zupk.site,
	"Mercer <ron.mercer"@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:47342 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932120Ab2F2Sln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 14:41:43 -0400
In-Reply-To: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h         |    8 ++++
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |   14 +++++++
 drivers/net/ethernet/qlogic/qlge/qlge_main.c    |   46 ++++++++++++++++++----
 3 files changed, 59 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index 5a639df..e81bbb7 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -1535,6 +1535,14 @@ struct nic_stats {
 	u64 rx_1024_to_1518_pkts;
 	u64 rx_1519_to_max_pkts;
 	u64 rx_len_err_pkts;
+	/* Receive Mac Err stats */
+	u64 rx_code_err;
+	u64 rx_oversize_err;
+	u64 rx_undersize_err;
+	u64 rx_preamble_err;
+	u64 rx_frame_len_err;
+	u64 rx_crc_err;
+	u64 rx_err_count;
 	/*
 	 * These stats come from offset 500h to 5C8h
 	 * in the XGMAC register.
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 966bd96..bbc4136 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -226,6 +226,13 @@ static char ql_stats_str_arr[][ETH_GSTRING_LEN] = {
 	{"rx_1024_to_1518_pkts"},
 	{"rx_1519_to_max_pkts"},
 	{"rx_len_err_pkts"},
+	{"rx_code_err"},
+	{"rx_oversize_err"},
+	{"rx_undersize_err"},
+	{"rx_preamble_err"},
+	{"rx_frame_len_err"},
+	{"rx_crc_err"},
+	{"rx_err_count"},
 	{"tx_cbfc_pause_frames0"},
 	{"tx_cbfc_pause_frames1"},
 	{"tx_cbfc_pause_frames2"},
@@ -320,6 +327,13 @@ ql_get_ethtool_stats(struct net_device *ndev,
 	*data++ = s->rx_1024_to_1518_pkts;
 	*data++ = s->rx_1519_to_max_pkts;
 	*data++ = s->rx_len_err_pkts;
+	*data++ = s->rx_code_err;
+	*data++ = s->rx_oversize_err;
+	*data++ = s->rx_undersize_err;
+	*data++ = s->rx_preamble_err;
+	*data++ = s->rx_frame_len_err;
+	*data++ = s->rx_crc_err;
+	*data++ = s->rx_err_count;
 	*data++ = s->tx_cbfc_pause_frames0;
 	*data++ = s->tx_cbfc_pause_frames1;
 	*data++ = s->tx_cbfc_pause_frames2;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index aa514c5..0f56148 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1433,6 +1433,34 @@ map_error:
 	return NETDEV_TX_BUSY;
 }
 
+/* Categorizing receive firmware frame errors */
+static void ql_categorize_rx_err(struct ql_adapter *qdev, u8 rx_err)
+{
+	qdev->nic_stats.rx_err_count++;
+
+	switch (rx_err & IB_MAC_IOCB_RSP_ERR_MASK) {
+	case IB_MAC_IOCB_RSP_ERR_CODE_ERR:
+		qdev->nic_stats.rx_code_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_OVERSIZE:
+		qdev->nic_stats.rx_oversize_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_UNDERSIZE:
+		qdev->nic_stats.rx_undersize_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_PREAMBLE:
+		qdev->nic_stats.rx_preamble_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_FRAME_LEN:
+		qdev->nic_stats.rx_frame_len_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_CRC:
+		qdev->nic_stats.rx_crc_err++;
+	default:
+		break;
+	}
+}
+
 /* Process an inbound completion from an rx ring. */
 static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 					struct rx_ring *rx_ring,
@@ -1446,6 +1474,12 @@ static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 
 	napi->dev = qdev->ndev;
 
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2);
+		put_page(lbq_desc->p.pg_chunk.page);
+		return;
+	}
+
 	skb = napi_get_frags(napi);
 	if (!skb) {
 		netif_err(qdev, drv, qdev->ndev,
@@ -1502,9 +1536,7 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_info(qdev, drv, qdev->ndev,
-			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
-		rx_ring->rx_errors++;
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2);
 		goto err_out;
 	}
 
@@ -1595,10 +1627,8 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_info(qdev, drv, qdev->ndev,
-			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2);
 		dev_kfree_skb_any(skb);
-		rx_ring->rx_errors++;
 		return;
 	}
 
@@ -1910,10 +1940,8 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_info(qdev, drv, qdev->ndev,
-			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2);
 		dev_kfree_skb_any(skb);
-		rx_ring->rx_errors++;
 		return;
 	}
 
-- 
1.7.1
