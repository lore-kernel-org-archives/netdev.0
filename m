From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 2/5] qed: Add support for PTP resource locking.
Date: Wed, 26 Apr 2017 09:00:50 -0700
Message-ID: <20170426160053.8356-3-sudarsana.kalluru@cavium.com>
References: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0084.outbound.protection.outlook.com ([104.47.41.84]:25890
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1760711AbdDZQBk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 12:01:40 -0400
In-Reply-To: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds support for per-port resource lock in favour of PTP.
PTP module acquires/releases the MFW resource lock while enabling/
disabling the PTP on the interface. The PF instance which has the
ownership of this resource lock will get the exclusive access to the
PTP clock functionality on the port.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     |  1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 14 +++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |  4 ++
 drivers/net/ethernet/qlogic/qed/qed_ptp.c | 87 +++++++++++++++++++++++++++++++
 4 files changed, 106 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 8a8f139..3f8d07b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -767,6 +767,7 @@ void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev,
 
 void qed_clean_wfq_db(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 int qed_device_num_engines(struct qed_dev *cdev);
+int qed_device_get_port_id(struct qed_dev *cdev);
 
 #define QED_LEADING_HWFN(dev)   (&dev->hwfns[0])
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2a3ae00..aa1a4d5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -4064,3 +4064,17 @@ int qed_device_num_engines(struct qed_dev *cdev)
 {
 	return QED_IS_BB(cdev) ? 2 : 1;
 }
+
+static int qed_device_num_ports(struct qed_dev *cdev)
+{
+	/* in CMT always only one port */
+	if (cdev->num_hwfns > 1)
+		return 1;
+
+	return cdev->num_ports_in_engines * qed_device_num_engines(cdev);
+}
+
+int qed_device_get_port_id(struct qed_dev *cdev)
+{
+	return (QED_LEADING_HWFN(cdev)->abs_pf_id) % qed_device_num_ports(cdev);
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index e8cf597..5ae35d6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -795,6 +795,10 @@ int qed_mcp_ov_update_eswitch(struct qed_hwfn *p_hwfn,
 
 enum qed_resc_lock {
 	QED_RESC_LOCK_DBG_DUMP = QED_MCP_RESC_LOCK_MIN_VAL,
+	QED_RESC_LOCK_PTP_PORT0,
+	QED_RESC_LOCK_PTP_PORT1,
+	QED_RESC_LOCK_PTP_PORT2,
+	QED_RESC_LOCK_PTP_PORT3,
 	QED_RESC_LOCK_RESC_ALLOC = QED_MCP_RESC_LOCK_MAX_VAL,
 	QED_RESC_LOCK_RESC_INVALID
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ptp.c b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
index 80c9c0b..26a9baf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ptp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
@@ -34,6 +34,7 @@
 #include "qed_dev_api.h"
 #include "qed_hw.h"
 #include "qed_l2.h"
+#include "qed_mcp.h"
 #include "qed_ptp.h"
 #include "qed_reg_addr.h"
 
@@ -45,6 +46,82 @@
 #define QED_DRIFT_CNTR_DIRECTION_SHIFT		31
 #define QED_TIMESTAMP_MASK			BIT(16)
 
+static enum qed_resc_lock qed_ptcdev_to_resc(struct qed_hwfn *p_hwfn)
+{
+	switch (qed_device_get_port_id(p_hwfn->cdev)) {
+	case 0:
+		return QED_RESC_LOCK_PTP_PORT0;
+	case 1:
+		return QED_RESC_LOCK_PTP_PORT1;
+	case 2:
+		return QED_RESC_LOCK_PTP_PORT2;
+	case 3:
+		return QED_RESC_LOCK_PTP_PORT3;
+	default:
+		return QED_RESC_LOCK_RESC_INVALID;
+	}
+}
+
+static int qed_ptp_res_lock(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct qed_resc_lock_params params;
+	enum qed_resc_lock resource;
+	int rc;
+
+	resource = qed_ptcdev_to_resc(p_hwfn);
+	if (resource == QED_RESC_LOCK_RESC_INVALID)
+		return -EINVAL;
+
+	qed_mcp_resc_lock_default_init(&params, NULL, resource, true);
+
+	rc = qed_mcp_resc_lock(p_hwfn, p_ptt, &params);
+	if (rc && rc != -EINVAL) {
+		return rc;
+	} else if (rc == -EINVAL) {
+		/* MFW doesn't support resource locking, first PF on the port
+		 * has lock ownership.
+		 */
+		if (p_hwfn->abs_pf_id < p_hwfn->cdev->num_ports_in_engines)
+			return 0;
+
+		DP_INFO(p_hwfn, "PF doesn't have lock ownership\n");
+		return -EBUSY;
+	} else if (!rc && !params.b_granted) {
+		DP_INFO(p_hwfn, "Failed to acquire ptp resource lock\n");
+		return -EBUSY;
+	}
+
+	return rc;
+}
+
+static int qed_ptp_res_unlock(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct qed_resc_unlock_params params;
+	enum qed_resc_lock resource;
+	int rc;
+
+	resource = qed_ptcdev_to_resc(p_hwfn);
+	if (resource == QED_RESC_LOCK_RESC_INVALID)
+		return -EINVAL;
+
+	qed_mcp_resc_lock_default_init(NULL, &params, resource, true);
+
+	rc = qed_mcp_resc_unlock(p_hwfn, p_ptt, &params);
+	if (rc == -EINVAL) {
+		/* MFW doesn't support locking, first PF has lock ownership */
+		if (p_hwfn->abs_pf_id < p_hwfn->cdev->num_ports_in_engines) {
+			rc = 0;
+		} else {
+			DP_INFO(p_hwfn, "PF doesn't have lock ownership\n");
+			return -EINVAL;
+		}
+	} else if (rc) {
+		DP_INFO(p_hwfn, "Failed to release the ptp resource lock\n");
+	}
+
+	return rc;
+}
+
 /* Read Rx timestamp */
 static int qed_ptp_hw_read_rx_ts(struct qed_dev *cdev, u64 *timestamp)
 {
@@ -249,6 +326,14 @@ static int qed_ptp_hw_enable(struct qed_dev *cdev)
 {
 	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
 	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
+	int rc;
+
+	rc = qed_ptp_res_lock(p_hwfn, p_ptt);
+	if (rc) {
+		DP_INFO(p_hwfn,
+			"Couldn't acquire the resource lock, skip ptp enable for this PF\n");
+		return rc;
+	}
 
 	/* Reset PTP event detection rules - will be configured in the IOCTL */
 	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_PARAM_MASK, 0x7FF);
@@ -305,6 +390,8 @@ static int qed_ptp_hw_disable(struct qed_dev *cdev)
 	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
 	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
 
+	qed_ptp_res_unlock(p_hwfn, p_ptt);
+
 	/* Reset PTP event detection rules */
 	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_PARAM_MASK, 0x7FF);
 	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_RULE_MASK, 0x3FFF);
-- 
1.8.3.1
