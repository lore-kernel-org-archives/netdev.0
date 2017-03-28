From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 5/7] qed: Support management-based resource locking
Date: Tue, 28 Mar 2017 15:12:54 +0300
Message-ID: <1490703176-429-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41210 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752028AbdC1MNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 08:13:50 -0400
In-Reply-To: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

Global locking can't properly be used to synchronize between different
PFs in all scenarios, as those instances might reside in different
logical partitions [e.g., when a PF is assigned via PDA to some VM].

The management firmware provides a generic infrastructure for
device locks. For each 'resource', it's guaranteed it could be acquired
by at most a single PF at any given time [or by management firmware].

This patch adds the necessary logic in qed for utilizing said
infrastructure, implementing lock/unlock internal APIs.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h |  28 +++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 176 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |  65 +++++++++++
 3 files changed, 269 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 2de7aa1..4346399 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -10119,6 +10119,33 @@ struct public_drv_mb {
 
 #define DRV_MSG_CODE_BIST_TEST			0x001e0000
 #define DRV_MSG_CODE_SET_LED_MODE		0x00200000
+#define DRV_MSG_CODE_RESOURCE_CMD	0x00230000
+
+#define RESOURCE_CMD_REQ_RESC_MASK		0x0000001F
+#define RESOURCE_CMD_REQ_RESC_SHIFT		0
+#define RESOURCE_CMD_REQ_OPCODE_MASK		0x000000E0
+#define RESOURCE_CMD_REQ_OPCODE_SHIFT		5
+#define RESOURCE_OPCODE_REQ			1
+#define RESOURCE_OPCODE_REQ_WO_AGING		2
+#define RESOURCE_OPCODE_REQ_W_AGING		3
+#define RESOURCE_OPCODE_RELEASE			4
+#define RESOURCE_OPCODE_FORCE_RELEASE		5
+#define RESOURCE_CMD_REQ_AGE_MASK		0x0000FF00
+#define RESOURCE_CMD_REQ_AGE_SHIFT		8
+
+#define RESOURCE_CMD_RSP_OWNER_MASK		0x000000FF
+#define RESOURCE_CMD_RSP_OWNER_SHIFT		0
+#define RESOURCE_CMD_RSP_OPCODE_MASK		0x00000700
+#define RESOURCE_CMD_RSP_OPCODE_SHIFT		8
+#define RESOURCE_OPCODE_GNT			1
+#define RESOURCE_OPCODE_BUSY			2
+#define RESOURCE_OPCODE_RELEASED		3
+#define RESOURCE_OPCODE_RELEASED_PREVIOUS	4
+#define RESOURCE_OPCODE_WRONG_OWNER		5
+#define RESOURCE_OPCODE_UNKNOWN_CMD		255
+
+#define RESOURCE_DUMP				0
+
 #define DRV_MSG_CODE_GET_PF_RDMA_PROTOCOL	0x002b0000
 #define DRV_MSG_CODE_OS_WOL			0x002e0000
 
@@ -10207,6 +10234,7 @@ struct public_drv_mb {
 
 	u32 fw_mb_header;
 #define FW_MSG_CODE_MASK			0xffff0000
+#define FW_MSG_CODE_UNSUPPORTED                 0x00000000
 #define FW_MSG_CODE_DRV_LOAD_ENGINE		0x10100000
 #define FW_MSG_CODE_DRV_LOAD_PORT		0x10110000
 #define FW_MSG_CODE_DRV_LOAD_FUNCTION		0x10120000
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 490619f..ddcbc24 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -2271,3 +2271,179 @@ int qed_mcp_initiate_pf_flr(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	return qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_INITIATE_PF_FLR, 0,
 			   &mcp_resp, &mcp_param);
 }
+
+static int qed_mcp_resource_cmd(struct qed_hwfn *p_hwfn,
+				struct qed_ptt *p_ptt,
+				u32 param, u32 *p_mcp_resp, u32 *p_mcp_param)
+{
+	int rc;
+
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_RESOURCE_CMD, param,
+			 p_mcp_resp, p_mcp_param);
+	if (rc)
+		return rc;
+
+	if (*p_mcp_resp == FW_MSG_CODE_UNSUPPORTED) {
+		DP_INFO(p_hwfn,
+			"The resource command is unsupported by the MFW\n");
+		return -EINVAL;
+	}
+
+	if (*p_mcp_param == RESOURCE_OPCODE_UNKNOWN_CMD) {
+		u8 opcode = QED_MFW_GET_FIELD(param, RESOURCE_CMD_REQ_OPCODE);
+
+		DP_NOTICE(p_hwfn,
+			  "The resource command is unknown to the MFW [param 0x%08x, opcode %d]\n",
+			  param, opcode);
+		return -EINVAL;
+	}
+
+	return rc;
+}
+
+int
+__qed_mcp_resc_lock(struct qed_hwfn *p_hwfn,
+		    struct qed_ptt *p_ptt,
+		    struct qed_resc_lock_params *p_params)
+{
+	u32 param = 0, mcp_resp, mcp_param;
+	u8 opcode;
+	int rc;
+
+	switch (p_params->timeout) {
+	case QED_MCP_RESC_LOCK_TO_DEFAULT:
+		opcode = RESOURCE_OPCODE_REQ;
+		p_params->timeout = 0;
+		break;
+	case QED_MCP_RESC_LOCK_TO_NONE:
+		opcode = RESOURCE_OPCODE_REQ_WO_AGING;
+		p_params->timeout = 0;
+		break;
+	default:
+		opcode = RESOURCE_OPCODE_REQ_W_AGING;
+		break;
+	}
+
+	QED_MFW_SET_FIELD(param, RESOURCE_CMD_REQ_RESC, p_params->resource);
+	QED_MFW_SET_FIELD(param, RESOURCE_CMD_REQ_OPCODE, opcode);
+	QED_MFW_SET_FIELD(param, RESOURCE_CMD_REQ_AGE, p_params->timeout);
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_SP,
+		   "Resource lock request: param 0x%08x [age %d, opcode %d, resource %d]\n",
+		   param, p_params->timeout, opcode, p_params->resource);
+
+	/* Attempt to acquire the resource */
+	rc = qed_mcp_resource_cmd(p_hwfn, p_ptt, param, &mcp_resp, &mcp_param);
+	if (rc)
+		return rc;
+
+	/* Analyze the response */
+	p_params->owner = QED_MFW_GET_FIELD(mcp_param, RESOURCE_CMD_RSP_OWNER);
+	opcode = QED_MFW_GET_FIELD(mcp_param, RESOURCE_CMD_RSP_OPCODE);
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_SP,
+		   "Resource lock response: mcp_param 0x%08x [opcode %d, owner %d]\n",
+		   mcp_param, opcode, p_params->owner);
+
+	switch (opcode) {
+	case RESOURCE_OPCODE_GNT:
+		p_params->b_granted = true;
+		break;
+	case RESOURCE_OPCODE_BUSY:
+		p_params->b_granted = false;
+		break;
+	default:
+		DP_NOTICE(p_hwfn,
+			  "Unexpected opcode in resource lock response [mcp_param 0x%08x, opcode %d]\n",
+			  mcp_param, opcode);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int
+qed_mcp_resc_lock(struct qed_hwfn *p_hwfn,
+		  struct qed_ptt *p_ptt, struct qed_resc_lock_params *p_params)
+{
+	u32 retry_cnt = 0;
+	int rc;
+
+	do {
+		/* No need for an interval before the first iteration */
+		if (retry_cnt) {
+			if (p_params->sleep_b4_retry) {
+				u16 retry_interval_in_ms =
+				    DIV_ROUND_UP(p_params->retry_interval,
+						 1000);
+
+				msleep(retry_interval_in_ms);
+			} else {
+				udelay(p_params->retry_interval);
+			}
+		}
+
+		rc = __qed_mcp_resc_lock(p_hwfn, p_ptt, p_params);
+		if (rc)
+			return rc;
+
+		if (p_params->b_granted)
+			break;
+	} while (retry_cnt++ < p_params->retry_num);
+
+	return 0;
+}
+
+int
+qed_mcp_resc_unlock(struct qed_hwfn *p_hwfn,
+		    struct qed_ptt *p_ptt,
+		    struct qed_resc_unlock_params *p_params)
+{
+	u32 param = 0, mcp_resp, mcp_param;
+	u8 opcode;
+	int rc;
+
+	opcode = p_params->b_force ? RESOURCE_OPCODE_FORCE_RELEASE
+				   : RESOURCE_OPCODE_RELEASE;
+	QED_MFW_SET_FIELD(param, RESOURCE_CMD_REQ_RESC, p_params->resource);
+	QED_MFW_SET_FIELD(param, RESOURCE_CMD_REQ_OPCODE, opcode);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SP,
+		   "Resource unlock request: param 0x%08x [opcode %d, resource %d]\n",
+		   param, opcode, p_params->resource);
+
+	/* Attempt to release the resource */
+	rc = qed_mcp_resource_cmd(p_hwfn, p_ptt, param, &mcp_resp, &mcp_param);
+	if (rc)
+		return rc;
+
+	/* Analyze the response */
+	opcode = QED_MFW_GET_FIELD(mcp_param, RESOURCE_CMD_RSP_OPCODE);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SP,
+		   "Resource unlock response: mcp_param 0x%08x [opcode %d]\n",
+		   mcp_param, opcode);
+
+	switch (opcode) {
+	case RESOURCE_OPCODE_RELEASED_PREVIOUS:
+		DP_INFO(p_hwfn,
+			"Resource unlock request for an already released resource [%d]\n",
+			p_params->resource);
+		/* Fallthrough */
+	case RESOURCE_OPCODE_RELEASED:
+		p_params->b_released = true;
+		break;
+	case RESOURCE_OPCODE_WRONG_OWNER:
+		p_params->b_released = false;
+		break;
+	default:
+		DP_NOTICE(p_hwfn,
+			  "Unexpected opcode in resource unlock response [mcp_param 0x%08x, opcode %d]\n",
+			  mcp_param, opcode);
+		return -EINVAL;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 0056cfe..8673ac1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -780,4 +780,69 @@ int qed_mcp_get_resc_info(struct qed_hwfn *p_hwfn,
  * @return int - 0 - operation was successful.
  */
 int qed_mcp_initiate_pf_flr(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
+struct qed_resc_lock_params {
+	/* Resource number [valid values are 0..31] */
+	u8 resource;
+
+	/* Lock timeout value in seconds [default, none or 1..254] */
+	u8 timeout;
+#define QED_MCP_RESC_LOCK_TO_DEFAULT    0
+#define QED_MCP_RESC_LOCK_TO_NONE       255
+
+	/* Number of times to retry locking */
+	u8 retry_num;
+
+	/* The interval in usec between retries */
+	u16 retry_interval;
+
+	/* Use sleep or delay between retries */
+	bool sleep_b4_retry;
+
+	/* Will be set as true if the resource is free and granted */
+	bool b_granted;
+
+	/* Will be filled with the resource owner.
+	 * [0..15 = PF0-15, 16 = MFW]
+	 */
+	u8 owner;
+};
+
+/**
+ * @brief Acquires MFW generic resource lock
+ *
+ *  @param p_hwfn
+ *  @param p_ptt
+ *  @param p_params
+ *
+ * @return int - 0 - operation was successful.
+ */
+int
+qed_mcp_resc_lock(struct qed_hwfn *p_hwfn,
+		  struct qed_ptt *p_ptt, struct qed_resc_lock_params *p_params);
+
+struct qed_resc_unlock_params {
+	/* Resource number [valid values are 0..31] */
+	u8 resource;
+
+	/* Allow to release a resource even if belongs to another PF */
+	bool b_force;
+
+	/* Will be set as true if the resource is released */
+	bool b_released;
+};
+
+/**
+ * @brief Releases MFW generic resource lock
+ *
+ *  @param p_hwfn
+ *  @param p_ptt
+ *  @param p_params
+ *
+ * @return int - 0 - operation was successful.
+ */
+int
+qed_mcp_resc_unlock(struct qed_hwfn *p_hwfn,
+		    struct qed_ptt *p_ptt,
+		    struct qed_resc_unlock_params *p_params);
+
 #endif
-- 
1.9.3
