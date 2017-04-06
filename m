From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 7/8] qed: Provide iSCSI statistics to management
Date: Thu, 6 Apr 2017 15:58:34 +0300
Message-ID: <1491483515-13502-8-git-send-email-Yuval.Mintz@cavium.com>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53268 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752033AbdDFNBR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:01:17 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Management firmware can query for some basic iSCSI-related statistics.
Provide those just as we do for other protocols.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 20 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iscsi.h | 14 +++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_main.c  |  5 +++++
 3 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index 417691c..339c91d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -1324,6 +1324,26 @@ static int qed_iscsi_stats(struct qed_dev *cdev, struct qed_iscsi_stats *stats)
 	return qed_iscsi_get_stats(QED_LEADING_HWFN(cdev), stats);
 }
 
+void qed_get_protocol_stats_iscsi(struct qed_dev *cdev,
+				  struct qed_mcp_iscsi_stats *stats)
+{
+	struct qed_iscsi_stats proto_stats;
+
+	/* Retrieve FW statistics */
+	memset(&proto_stats, 0, sizeof(proto_stats));
+	if (qed_iscsi_stats(cdev, &proto_stats)) {
+		DP_VERBOSE(cdev, QED_MSG_STORAGE,
+			   "Failed to collect ISCSI statistics\n");
+		return;
+	}
+
+	/* Translate FW statistics into struct */
+	stats->rx_pdus = proto_stats.iscsi_rx_total_pdu_cnt;
+	stats->tx_pdus = proto_stats.iscsi_tx_total_pdu_cnt;
+	stats->rx_bytes = proto_stats.iscsi_rx_bytes_cnt;
+	stats->tx_bytes = proto_stats.iscsi_tx_bytes_cnt;
+}
+
 static const struct qed_iscsi_ops qed_iscsi_ops_pass = {
 	.common = &qed_common_ops_pass,
 	.ll2 = &qed_ll2_ops_pass,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.h b/drivers/net/ethernet/qlogic/qed/qed_iscsi.h
index 20c187f..ae98f77 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.h
@@ -64,13 +64,25 @@ void qed_iscsi_setup(struct qed_hwfn *p_hwfn,
 
 void qed_iscsi_free(struct qed_hwfn *p_hwfn,
 		    struct qed_iscsi_info *p_iscsi_info);
+
+/**
+ * @brief - Fills provided statistics struct with statistics.
+ *
+ * @param cdev
+ * @param stats - points to struct that will be filled with statistics.
+ */
+void qed_get_protocol_stats_iscsi(struct qed_dev *cdev,
+				  struct qed_mcp_iscsi_stats *stats);
 #else /* IS_ENABLED(CONFIG_QED_ISCSI) */
 static inline struct qed_iscsi_info *qed_iscsi_alloc(
 		struct qed_hwfn *p_hwfn) { return NULL; }
 static inline void qed_iscsi_setup(struct qed_hwfn *p_hwfn,
 				   struct qed_iscsi_info *p_iscsi_info) {}
 static inline void qed_iscsi_free(struct qed_hwfn *p_hwfn,
-				  struct qed_iscsi_info *p_iscsi_info) {}
+				 struct qed_iscsi_info *p_iscsi_info) {}
+static inline void
+qed_get_protocol_stats_iscsi(struct qed_dev *cdev,
+			     struct qed_mcp_iscsi_stats *stats) {}
 #endif /* IS_ENABLED(CONFIG_QED_ISCSI) */
 
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 634e7a2..110ed76 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -55,6 +55,8 @@
 #include "qed_dev_api.h"
 #include "qed_ll2.h"
 #include "qed_fcoe.h"
+#include "qed_iscsi.h"
+
 #include "qed_mcp.h"
 #include "qed_hw.h"
 #include "qed_selftest.h"
@@ -1678,6 +1680,9 @@ void qed_get_protocol_stats(struct qed_dev *cdev,
 	case QED_MCP_FCOE_STATS:
 		qed_get_protocol_stats_fcoe(cdev, &stats->fcoe_stats);
 		break;
+	case QED_MCP_ISCSI_STATS:
+		qed_get_protocol_stats_iscsi(cdev, &stats->iscsi_stats);
+		break;
 	default:
 		DP_ERR(cdev, "Invalid protocol type = %d\n", type);
 		return;
-- 
1.9.3
