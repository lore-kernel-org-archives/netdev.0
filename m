From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 1/5] qed: Add support for MFW resource locking.
Date: Wed, 26 Apr 2017 09:00:49 -0700
Message-ID: <20170426160053.8356-2-sudarsana.kalluru@cavium.com>
References: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0075.outbound.protection.outlook.com ([104.47.32.75]:21848
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934148AbdDZQB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 12:01:26 -0400
In-Reply-To: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds API for default initialization of the MFW resource
locking.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 12 ++----------
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 30 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h | 18 +++++++++++++++++-
 3 files changed, 49 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index ea7931b..2a3ae00 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2347,9 +2347,6 @@ static int qed_hw_set_resc_info(struct qed_hwfn *p_hwfn)
 	return 0;
 }
 
-#define QED_RESC_ALLOC_LOCK_RETRY_CNT           10
-#define QED_RESC_ALLOC_LOCK_RETRY_INTVL_US      10000	/* 10 msec */
-
 static int qed_hw_get_resc(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
 	struct qed_resc_unlock_params resc_unlock_params;
@@ -2366,13 +2363,8 @@ static int qed_hw_get_resc(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	 * needed, and proceed to the queries. Other failures, including a
 	 * failure to acquire the lock, will cause this function to fail.
 	 */
-	memset(&resc_lock_params, 0, sizeof(resc_lock_params));
-	resc_lock_params.resource = QED_RESC_LOCK_RESC_ALLOC;
-	resc_lock_params.retry_num = QED_RESC_ALLOC_LOCK_RETRY_CNT;
-	resc_lock_params.retry_interval = QED_RESC_ALLOC_LOCK_RETRY_INTVL_US;
-	resc_lock_params.sleep_b4_retry = true;
-	memset(&resc_unlock_params, 0, sizeof(resc_unlock_params));
-	resc_unlock_params.resource = QED_RESC_LOCK_RESC_ALLOC;
+	qed_mcp_resc_lock_default_init(&resc_lock_params, &resc_unlock_params,
+				       QED_RESC_LOCK_RESC_ALLOC, false);
 
 	rc = qed_mcp_resc_lock(p_hwfn, p_ptt, &resc_lock_params);
 	if (rc && rc != -EINVAL) {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index ff6080d..7266b36 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -2615,3 +2615,33 @@ static int qed_mcp_resource_cmd(struct qed_hwfn *p_hwfn,
 
 	return 0;
 }
+
+void qed_mcp_resc_lock_default_init(struct qed_resc_lock_params *p_lock,
+				    struct qed_resc_unlock_params *p_unlock,
+				    enum qed_resc_lock
+				    resource, bool b_is_permanent)
+{
+	if (p_lock) {
+		memset(p_lock, 0, sizeof(*p_lock));
+
+		/* Permanent resources don't require aging, and there's no
+		 * point in trying to acquire them more than once since it's
+		 * unexpected another entity would release them.
+		 */
+		if (b_is_permanent) {
+			p_lock->timeout = QED_MCP_RESC_LOCK_TO_NONE;
+		} else {
+			p_lock->retry_num = QED_MCP_RESC_LOCK_RETRY_CNT_DFLT;
+			p_lock->retry_interval =
+			    QED_MCP_RESC_LOCK_RETRY_VAL_DFLT;
+			p_lock->sleep_b4_retry = true;
+		}
+
+		p_lock->resource = resource;
+	}
+
+	if (p_unlock) {
+		memset(p_unlock, 0, sizeof(*p_unlock));
+		p_unlock->resource = resource;
+	}
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index ac7d406..e8cf597 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -795,7 +795,8 @@ int qed_mcp_ov_update_eswitch(struct qed_hwfn *p_hwfn,
 
 enum qed_resc_lock {
 	QED_RESC_LOCK_DBG_DUMP = QED_MCP_RESC_LOCK_MIN_VAL,
-	QED_RESC_LOCK_RESC_ALLOC = QED_MCP_RESC_LOCK_MAX_VAL
+	QED_RESC_LOCK_RESC_ALLOC = QED_MCP_RESC_LOCK_MAX_VAL,
+	QED_RESC_LOCK_RESC_INVALID
 };
 
 /**
@@ -818,9 +819,11 @@ struct qed_resc_lock_params {
 
 	/* Number of times to retry locking */
 	u8 retry_num;
+#define QED_MCP_RESC_LOCK_RETRY_CNT_DFLT        10
 
 	/* The interval in usec between retries */
 	u16 retry_interval;
+#define QED_MCP_RESC_LOCK_RETRY_VAL_DFLT        10000
 
 	/* Use sleep or delay between retries */
 	bool sleep_b4_retry;
@@ -872,4 +875,17 @@ struct qed_resc_unlock_params {
 		    struct qed_ptt *p_ptt,
 		    struct qed_resc_unlock_params *p_params);
 
+/**
+ * @brief - default initialization for lock/unlock resource structs
+ *
+ * @param p_lock - lock params struct to be initialized; Can be NULL
+ * @param p_unlock - unlock params struct to be initialized; Can be NULL
+ * @param resource - the requested resource
+ * @paral b_is_permanent - disable retries & aging when set
+ */
+void qed_mcp_resc_lock_default_init(struct qed_resc_lock_params *p_lock,
+				    struct qed_resc_unlock_params *p_unlock,
+				    enum qed_resc_lock
+				    resource, bool b_is_permanent);
+
 #endif
-- 
1.8.3.1
