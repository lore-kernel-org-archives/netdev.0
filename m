From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 2/3] qede: Add support for per-queue stats.
Date: Tue, 16 Aug 2016 10:51:02 -0400
Message-ID: <1471359063-6193-3-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1471359063-6193-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:33886 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753386AbcHPPeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 11:34:20 -0400
In-Reply-To: <1471359063-6193-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  3 ++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 63 ++++++++++++++++++++-----
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  4 ++
 3 files changed, 57 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 9060c2a..81a63cf 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -237,6 +237,7 @@ struct qede_rx_queue {
 	u16			num_rx_buffers;
 	u16			rxq_id;
 
+	u64			rcv_pkts;
 	u64			rx_hw_errors;
 	u64			rx_alloc_errors;
 	u64			rx_ip_frags;
@@ -265,6 +266,8 @@ struct qede_tx_queue {
 	union db_prod		tx_db;
 
 	u16			num_tx_buffers;
+	u64			xmit_pkts;
+	u64			stopped_cnt;
 };
 
 #define BD_UNMAP_ADDR(bd)		HILO_U64(le32_to_cpu((bd)->addr.hi), \
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 93493e8..ed3d4c1 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -35,6 +35,7 @@ static const struct {
 	u64 offset;
 	char string[ETH_GSTRING_LEN];
 } qede_rqstats_arr[] = {
+	QEDE_RQSTAT(rcv_pkts),
 	QEDE_RQSTAT(rx_hw_errors),
 	QEDE_RQSTAT(rx_alloc_errors),
 	QEDE_RQSTAT(rx_ip_frags),
@@ -44,6 +45,24 @@ static const struct {
 #define QEDE_RQSTATS_DATA(dev, sindex, rqindex) \
 	(*((u64 *)(((char *)(dev->fp_array[(rqindex)].rxq)) +\
 		    qede_rqstats_arr[(sindex)].offset)))
+#define QEDE_TQSTAT_OFFSET(stat_name) \
+	(offsetof(struct qede_tx_queue, stat_name))
+#define QEDE_TQSTAT_STRING(stat_name) (#stat_name)
+#define QEDE_TQSTAT(stat_name) \
+	{QEDE_TQSTAT_OFFSET(stat_name), QEDE_TQSTAT_STRING(stat_name)}
+#define QEDE_NUM_TQSTATS ARRAY_SIZE(qede_tqstats_arr)
+static const struct {
+	u64 offset;
+	char string[ETH_GSTRING_LEN];
+} qede_tqstats_arr[] = {
+	QEDE_TQSTAT(xmit_pkts),
+	QEDE_TQSTAT(stopped_cnt),
+};
+
+#define QEDE_TQSTATS_DATA(dev, sindex, tssid, tcid) \
+	(*((u64 *)(((u64)(&dev->fp_array[tssid].txqs[tcid])) +\
+		   qede_tqstats_arr[(sindex)].offset)))
+
 static const struct {
 	u64 offset;
 	char string[ETH_GSTRING_LEN];
@@ -153,17 +172,29 @@ static void qede_get_strings_stats(struct qede_dev *edev, u8 *buf)
 {
 	int i, j, k;
 
+	for (i = 0, k = 0; i < edev->num_rss; i++) {
+		int tc;
+
+		for (j = 0; j < QEDE_NUM_RQSTATS; j++)
+			sprintf(buf + (k + j) * ETH_GSTRING_LEN,
+				"%d:   %s", i, qede_rqstats_arr[j].string);
+		k += QEDE_NUM_RQSTATS;
+		for (tc = 0; tc < edev->num_tc; tc++) {
+			for (j = 0; j < QEDE_NUM_TQSTATS; j++)
+				sprintf(buf + (k + j) * ETH_GSTRING_LEN,
+					"%d.%d: %s", i, tc,
+					qede_tqstats_arr[j].string);
+			k += QEDE_NUM_TQSTATS;
+		}
+	}
+
 	for (i = 0, j = 0; i < QEDE_NUM_STATS; i++) {
 		if (IS_VF(edev) && qede_stats_arr[i].pf_only)
 			continue;
-		strcpy(buf + j * ETH_GSTRING_LEN,
+		strcpy(buf + (k + j) * ETH_GSTRING_LEN,
 		       qede_stats_arr[i].string);
 		j++;
 	}
-
-	for (k = 0; k < QEDE_NUM_RQSTATS; k++, j++)
-		strcpy(buf + j * ETH_GSTRING_LEN,
-		       qede_rqstats_arr[k].string);
 }
 
 static void qede_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
@@ -199,19 +230,24 @@ static void qede_get_ethtool_stats(struct net_device *dev,
 
 	mutex_lock(&edev->qede_lock);
 
+	for (qid = 0; qid < edev->num_rss; qid++) {
+		int tc;
+
+		for (sidx = 0; sidx < QEDE_NUM_RQSTATS; sidx++)
+			buf[cnt++] = QEDE_RQSTATS_DATA(edev, sidx, qid);
+		for (tc = 0; tc < edev->num_tc; tc++) {
+			for (sidx = 0; sidx < QEDE_NUM_TQSTATS; sidx++)
+				buf[cnt++] = QEDE_TQSTATS_DATA(edev, sidx, qid,
+							       tc);
+		}
+	}
+
 	for (sidx = 0; sidx < QEDE_NUM_STATS; sidx++) {
 		if (IS_VF(edev) && qede_stats_arr[sidx].pf_only)
 			continue;
 		buf[cnt++] = QEDE_STATS_DATA(edev, sidx);
 	}
 
-	for (sidx = 0; sidx < QEDE_NUM_RQSTATS; sidx++) {
-		buf[cnt] = 0;
-		for (qid = 0; qid < edev->num_rss; qid++)
-			buf[cnt] += QEDE_RQSTATS_DATA(edev, sidx, qid);
-		cnt++;
-	}
-
 	mutex_unlock(&edev->qede_lock);
 }
 
@@ -229,7 +265,8 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
 				if (qede_stats_arr[i].pf_only)
 					num_stats--;
 		}
-		return num_stats + QEDE_NUM_RQSTATS;
+		return num_stats +  edev->num_rss *
+			(QEDE_NUM_RQSTATS + QEDE_NUM_TQSTATS * edev->num_tc);
 	case ETH_SS_PRIV_FLAGS:
 		return QEDE_PRI_FLAG_LEN;
 	case ETH_SS_TEST:
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 516f48e..898a6f1 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -728,6 +728,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 	if (unlikely(qed_chain_get_elem_left(&txq->tx_pbl)
 		      < (MAX_SKB_FRAGS + 1))) {
 		netif_tx_stop_queue(netdev_txq);
+		txq->stopped_cnt++;
 		DP_VERBOSE(edev, NETIF_MSG_TX_QUEUED,
 			   "Stop queue was called\n");
 		/* paired memory barrier is in qede_tx_int(), we have to keep
@@ -788,6 +789,7 @@ static int qede_tx_int(struct qede_dev *edev,
 		bytes_compl += len;
 		pkts_compl++;
 		txq->sw_tx_cons++;
+		txq->xmit_pkts++;
 	}
 
 	netdev_tx_completed_queue(netdev_txq, pkts_compl, bytes_compl);
@@ -1601,6 +1603,8 @@ next_cqe: /* don't consume bd rx buffer */
 	/* Update producers */
 	qede_update_rx_prod(edev, rxq);
 
+	rxq->rcv_pkts += rx_pkt;
+
 	return rx_pkt;
 }
 
-- 
1.8.3.1
