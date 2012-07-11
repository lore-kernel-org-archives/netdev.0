From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 7/9] qlge: Moving low level frame error to ethtool statistics.
Date: Tue, 10 Jul 2012 20:57:37 -0400
Message-ID: <1341968259-18931-8-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22791 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753855Ab2GKBOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:14:38 -0400
In-Reply-To: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h         |    8 +++
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |   14 +++++
 drivers/net/ethernet/qlogic/qlge/qlge_main.c    |   63 +++++++++++++----------
 3 files changed, 58 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index ae7dddc..e384bbd 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -1536,6 +1536,14 @@ struct nic_stats {
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
index 4c141da..d505abe 100644
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
index cf6887a..9d218b0 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1433,6 +1433,36 @@ map_error:
 	return NETDEV_TX_BUSY;
 }
 
+/* Categorizing receive firmware frame errors */
+static void ql_categorize_rx_err(struct ql_adapter *qdev, u8 rx_err)
+{
+	struct nic_stats *stats = &qdev->nic_stats;
+
+	stats->rx_err_count++;
+
+	switch (rx_err & IB_MAC_IOCB_RSP_ERR_MASK) {
+	case IB_MAC_IOCB_RSP_ERR_CODE_ERR:
+		stats->rx_code_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_OVERSIZE:
+		stats->rx_oversize_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_UNDERSIZE:
+		stats->rx_undersize_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_PREAMBLE:
+		stats->rx_preamble_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_FRAME_LEN:
+		stats->rx_frame_len_err++;
+		break;
+	case IB_MAC_IOCB_RSP_ERR_CRC:
+		stats->rx_crc_err++;
+	default:
+		break;
+	}
+}
+
 /* Process an inbound completion from an rx ring. */
 static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 					struct rx_ring *rx_ring,
@@ -1499,15 +1529,6 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 	addr = lbq_desc->p.pg_chunk.va;
 	prefetch(addr);
 
-
-	/* Frame error, so drop the packet. */
-	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_info(qdev, drv, qdev->ndev,
-			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
-		rx_ring->rx_errors++;
-		goto err_out;
-	}
-
 	/* The max framesize filter on this chip is set higher than
 	 * MTU since FCoE uses 2k frames.
 	 */
@@ -1593,15 +1614,6 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 	memcpy(skb_put(new_skb, length), skb->data, length);
 	skb = new_skb;
 
-	/* Frame error, so drop the packet. */
-	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_info(qdev, drv, qdev->ndev,
-			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
-		dev_kfree_skb_any(skb);
-		rx_ring->rx_errors++;
-		return;
-	}
-
 	/* loopback self test for ethtool */
 	if (test_bit(QL_SELFTEST, &qdev->flags)) {
 		ql_check_lb_frame(qdev, skb);
@@ -1908,15 +1920,6 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 		return;
 	}
 
-	/* Frame error, so drop the packet. */
-	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_info(qdev, drv, qdev->ndev,
-			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
-		dev_kfree_skb_any(skb);
-		rx_ring->rx_errors++;
-		return;
-	}
-
 	/* The max framesize filter on this chip is set higher than
 	 * MTU since FCoE uses 2k frames.
 	 */
@@ -1999,6 +2002,12 @@ static unsigned long ql_process_mac_rx_intr(struct ql_adapter *qdev,
 
 	QL_DUMP_IB_MAC_RSP(ib_mac_rsp);
 
+	/* Frame error, so drop the packet. */
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2);
+		return (unsigned long)length;
+	}
+
 	if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV) {
 		/* The data and headers are split into
 		 * separate buffers.
-- 
1.7.1
