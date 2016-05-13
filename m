From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 4/5] drivers: net: xgene: fix statistics counters race condition
Date: Fri, 13 May 2016 16:53:00 -0700
Message-ID: <1463183581-30475-5-git-send-email-isubramanian@apm.com>
References: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36232 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbcEMXwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:52:11 -0400
Received: by mail-pf0-f169.google.com with SMTP id c189so48691601pfb.3
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:52:10 -0700 (PDT)
In-Reply-To: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the race condition on updating the statistics
counters by moving the counters to the ring structure.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   | 19 ++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |  2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 41 +++++++++++++++++-------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h | 10 ++++++
 4 files changed, 53 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 457f745..2f5638f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -219,27 +219,30 @@ void xgene_enet_parse_error(struct xgene_enet_desc_ring *ring,
 			    struct xgene_enet_pdata *pdata,
 			    enum xgene_enet_err_code status)
 {
-	struct rtnl_link_stats64 *stats = &pdata->stats;
-
 	switch (status) {
 	case INGRESS_CRC:
-		stats->rx_crc_errors++;
+		ring->rx_crc_errors++;
+		ring->rx_dropped++;
 		break;
 	case INGRESS_CHECKSUM:
 	case INGRESS_CHECKSUM_COMPUTE:
-		stats->rx_errors++;
+		ring->rx_errors++;
+		ring->rx_dropped++;
 		break;
 	case INGRESS_TRUNC_FRAME:
-		stats->rx_frame_errors++;
+		ring->rx_frame_errors++;
+		ring->rx_dropped++;
 		break;
 	case INGRESS_PKT_LEN:
-		stats->rx_length_errors++;
+		ring->rx_length_errors++;
+		ring->rx_dropped++;
 		break;
 	case INGRESS_PKT_UNDER:
-		stats->rx_frame_errors++;
+		ring->rx_frame_errors++;
+		ring->rx_dropped++;
 		break;
 	case INGRESS_FIFO_OVERRUN:
-		stats->rx_fifo_errors++;
+		ring->rx_fifo_errors++;
 		break;
 	default:
 		break;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index ba7da98..ecfeffe 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -201,6 +201,8 @@ enum xgene_enet_rm {
 #define USERINFO_LEN			32
 #define FPQNUM_POS			32
 #define FPQNUM_LEN			12
+#define ELERR_POS                       46
+#define ELERR_LEN                       2
 #define NV_POS				50
 #define NV_LEN				1
 #define LL_POS				51
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index e75d1a9..d208b17 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -443,8 +443,8 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	pdata->stats.tx_packets++;
-	pdata->stats.tx_bytes += skb->len;
+	tx_ring->tx_packets++;
+	tx_ring->tx_bytes += skb->len;
 
 	pdata->ring_ops->wr_cmd(tx_ring, count);
 	return NETDEV_TX_OK;
@@ -483,12 +483,12 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 	skb = buf_pool->rx_skb[skb_index];
 
 	/* checking for error */
-	status = GET_VAL(LERR, le64_to_cpu(raw_desc->m0));
+	status = (GET_VAL(ELERR, le64_to_cpu(raw_desc->m0)) << LERR_LEN) ||
+		  GET_VAL(LERR, le64_to_cpu(raw_desc->m0));
 	if (unlikely(status > 2)) {
 		dev_kfree_skb_any(skb);
 		xgene_enet_parse_error(rx_ring, netdev_priv(rx_ring->ndev),
 				       status);
-		pdata->stats.rx_dropped++;
 		ret = -EIO;
 		goto out;
 	}
@@ -506,8 +506,8 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 		xgene_enet_skip_csum(skb);
 	}
 
-	pdata->stats.rx_packets++;
-	pdata->stats.rx_bytes += datalen;
+	rx_ring->rx_packets++;
+	rx_ring->rx_bytes += datalen;
 	napi_gro_receive(&rx_ring->napi, skb);
 out:
 	if (--rx_ring->nbufpool == 0) {
@@ -1127,12 +1127,31 @@ static struct rtnl_link_stats64 *xgene_enet_get_stats64(
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct rtnl_link_stats64 *stats = &pdata->stats;
+	struct xgene_enet_desc_ring *ring;
+	int i;
+
+	memset(stats, 0, sizeof(struct rtnl_link_stats64));
+	for (i = 0; i < pdata->txq_cnt; i++) {
+		ring = pdata->tx_ring[i];
+		if (ring) {
+			stats->tx_packets += ring->tx_packets;
+			stats->tx_bytes += ring->tx_bytes;
+		}
+	}
 
-	stats->rx_errors += stats->rx_length_errors +
-			    stats->rx_crc_errors +
-			    stats->rx_frame_errors +
-			    stats->rx_fifo_errors;
-	memcpy(storage, &pdata->stats, sizeof(struct rtnl_link_stats64));
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		ring = pdata->rx_ring[i];
+		if (ring) {
+			stats->rx_packets += ring->rx_packets;
+			stats->rx_bytes += ring->rx_bytes;
+			stats->rx_errors += ring->rx_length_errors +
+				ring->rx_crc_errors +
+				ring->rx_frame_errors +
+				ring->rx_fifo_errors;
+			stats->rx_dropped += ring->rx_dropped;
+		}
+	}
+	memcpy(storage, stats, sizeof(struct rtnl_link_stats64));
 
 	return storage;
 }
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index cc40c30..092fbec 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -121,6 +121,16 @@ struct xgene_enet_desc_ring {
 		struct xgene_enet_raw_desc16 *raw_desc16;
 	};
 	__le64 *exp_bufs;
+	u64 tx_packets;
+	u64 tx_bytes;
+	u64 rx_packets;
+	u64 rx_bytes;
+	u64 rx_dropped;
+	u64 rx_errors;
+	u64 rx_length_errors;
+	u64 rx_crc_errors;
+	u64 rx_frame_errors;
+	u64 rx_fifo_errors;
 };
 
 struct xgene_mac_ops {
-- 
1.9.1
