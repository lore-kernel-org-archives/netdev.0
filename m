From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 1/3] qed: add infrastructure for device self tests.
Date: Thu, 28 Apr 2016 20:20:52 -0400
Message-ID: <1461889254-10534-2-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>, <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59083 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752927AbcD2BDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 21:03:41 -0400
In-Reply-To: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the functionality and APIs needed for selftests.
It adds the ability to configure the link-mode which is required for the
implementation of loopback tests. It adds the APIs for clock test,
register test, interrupt test and memory test.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/Makefile          |  3 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         | 13 ++++
 drivers/net/ethernet/qlogic/qed/qed_main.c        | 28 +++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         | 42 +++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h         | 22 +++++++
 drivers/net/ethernet/qlogic/qed/qed_selftest.c    | 76 +++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_selftest.h    | 40 ++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sp.h          | 10 +++
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 21 +++++++
 include/linux/qed/qed_if.h                        | 47 ++++++++++++++
 10 files changed, 301 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_selftest.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_selftest.h

diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index 5c2fd57..aafa669 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_QED) := qed.o
 
 qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
-	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o qed_l2.o
+	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o qed_l2.o \
+	 qed_selftest.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 5aa78a9..c4fae71 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -3857,6 +3857,7 @@ struct public_drv_mb {
 #define DRV_MSG_CODE_PHY_CORE_WRITE             0x000e0000
 #define DRV_MSG_CODE_SET_VERSION                0x000f0000
 
+#define DRV_MSG_CODE_BIST_TEST                  0x001e0000
 #define DRV_MSG_CODE_SET_LED_MODE               0x00200000
 
 #define DRV_MSG_SEQ_NUMBER_MASK                 0x0000ffff
@@ -3914,6 +3915,18 @@ struct public_drv_mb {
 #define DRV_MB_PARAM_SET_LED_MODE_ON            0x1
 #define DRV_MB_PARAM_SET_LED_MODE_OFF           0x2
 
+#define DRV_MB_PARAM_BIST_UNKNOWN_TEST          0
+#define DRV_MB_PARAM_BIST_REGISTER_TEST         1
+#define DRV_MB_PARAM_BIST_CLOCK_TEST            2
+
+#define DRV_MB_PARAM_BIST_RC_UNKNOWN            0
+#define DRV_MB_PARAM_BIST_RC_PASSED             1
+#define DRV_MB_PARAM_BIST_RC_FAILED             2
+#define DRV_MB_PARAM_BIST_RC_INVALID_PARAMETER          3
+
+#define DRV_MB_PARAM_BIST_TEST_INDEX_SHIFT      0
+#define DRV_MB_PARAM_BIST_TEST_INDEX_MASK       0x000000FF
+
 	u32 fw_mb_header;
 #define FW_MSG_CODE_MASK                        0xffff0000
 #define FW_MSG_CODE_DRV_LOAD_ENGINE             0x10100000
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 1918b83..1b758bd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -28,6 +28,7 @@
 #include "qed_dev_api.h"
 #include "qed_mcp.h"
 #include "qed_hw.h"
+#include "qed_selftest.h"
 
 static char version[] =
 	"QLogic FastLinQ 4xxxx Core Module qed " DRV_MODULE_VERSION "\n";
@@ -976,6 +977,25 @@ static int qed_set_link(struct qed_dev *cdev,
 		else
 			link_params->pause.forced_tx = false;
 	}
+	if (params->override_flags & QED_LINK_OVERRIDE_LOOPBACK_MODE) {
+		switch (params->loopback_mode) {
+		case QED_LINK_LOOPBACK_INT_PHY:
+			link_params->loopback_mode = PMM_LOOPBACK_INT_PHY;
+			break;
+		case QED_LINK_LOOPBACK_EXT_PHY:
+			link_params->loopback_mode = PMM_LOOPBACK_EXT_PHY;
+			break;
+		case QED_LINK_LOOPBACK_EXT:
+			link_params->loopback_mode = PMM_LOOPBACK_EXT;
+			break;
+		case QED_LINK_LOOPBACK_MAC:
+			link_params->loopback_mode = PMM_LOOPBACK_MAC;
+			break;
+		default:
+			link_params->loopback_mode = PMM_LOOPBACK_NONE;
+			break;
+		}
+	}
 
 	rc = qed_mcp_set_link(hwfn, ptt, params->link_up);
 
@@ -1182,7 +1202,15 @@ static int qed_set_led(struct qed_dev *cdev, enum qed_led_mode mode)
 	return status;
 }
 
+struct qed_selftest_ops qed_selftest_ops_pass = {
+	.selftest_memory = &qed_selftest_memory,
+	.selftest_interrupt = &qed_selftest_interrupt,
+	.selftest_register = &qed_selftest_register,
+	.selftest_clock = &qed_selftest_clock,
+};
+
 const struct qed_common_ops qed_common_ops_pass = {
+	.selftest = &qed_selftest_ops_pass,
 	.probe = &qed_probe,
 	.remove = &qed_remove,
 	.set_power_state = &qed_set_power_state,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index cb46dbd..2f8309d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1017,3 +1017,45 @@ int qed_mcp_set_led(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 
 	return rc;
 }
+
+int qed_mcp_bist_register_test(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 drv_mb_param = 0, rsp, param;
+	int rc = 0;
+
+	drv_mb_param = (DRV_MB_PARAM_BIST_REGISTER_TEST <<
+			DRV_MB_PARAM_BIST_TEST_INDEX_SHIFT);
+
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_BIST_TEST,
+			 drv_mb_param, &rsp, &param);
+
+	if (rc)
+		return rc;
+
+	if (((rsp & FW_MSG_CODE_MASK) != FW_MSG_CODE_OK) ||
+	    (param != DRV_MB_PARAM_BIST_RC_PASSED))
+		rc = -EAGAIN;
+
+	return rc;
+}
+
+int qed_mcp_bist_clock_test(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 drv_mb_param, rsp, param;
+	int rc = 0;
+
+	drv_mb_param = (DRV_MB_PARAM_BIST_CLOCK_TEST <<
+			DRV_MB_PARAM_BIST_TEST_INDEX_SHIFT);
+
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_BIST_TEST,
+			 drv_mb_param, &rsp, &param);
+
+	if (rc)
+		return rc;
+
+	if (((rsp & FW_MSG_CODE_MASK) != FW_MSG_CODE_OK) ||
+	    (param != DRV_MB_PARAM_BIST_RC_PASSED))
+		rc = -EAGAIN;
+
+	return rc;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 608bcb2..5f218ee 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -245,6 +245,28 @@ int qed_mcp_set_led(struct qed_hwfn *p_hwfn,
 		    struct qed_ptt *p_ptt,
 		    enum qed_led_mode mode);
 
+/**
+ * @brief Bist register test
+ *
+ *  @param p_hwfn    - hw function
+ *  @param p_ptt     - PTT required for register access
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_bist_register_test(struct qed_hwfn *p_hwfn,
+			       struct qed_ptt *p_ptt);
+
+/**
+ * @brief Bist clock test
+ *
+ *  @param p_hwfn    - hw function
+ *  @param p_ptt     - PTT required for register access
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_bist_clock_test(struct qed_hwfn *p_hwfn,
+			    struct qed_ptt *p_ptt);
+
 /* Using hwfn number (and not pf_num) is required since in CMT mode,
  * same pf_num may be used by two different hwfn
  * TODO - this shouldn't really be in .h file, but until all fields
diff --git a/drivers/net/ethernet/qlogic/qed/qed_selftest.c b/drivers/net/ethernet/qlogic/qed/qed_selftest.c
new file mode 100644
index 0000000..a342bfe
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_selftest.c
@@ -0,0 +1,76 @@
+#include "qed.h"
+#include "qed_dev_api.h"
+#include "qed_mcp.h"
+#include "qed_sp.h"
+
+int qed_selftest_memory(struct qed_dev *cdev)
+{
+	int rc = 0, i;
+
+	for_each_hwfn(cdev, i) {
+		rc = qed_sp_heartbeat_ramrod(&cdev->hwfns[i]);
+		if (rc)
+			return rc;
+	}
+
+	return rc;
+}
+
+int qed_selftest_interrupt(struct qed_dev *cdev)
+{
+	int rc = 0, i;
+
+	for_each_hwfn(cdev, i) {
+		rc = qed_sp_heartbeat_ramrod(&cdev->hwfns[i]);
+		if (rc)
+			return rc;
+	}
+
+	return rc;
+}
+
+int qed_selftest_register(struct qed_dev *cdev)
+{
+	struct qed_hwfn *p_hwfn;
+	struct qed_ptt *p_ptt;
+	int rc = 0, i;
+
+	/* although performed by MCP, this test is per engine */
+	for_each_hwfn(cdev, i) {
+		p_hwfn = &cdev->hwfns[i];
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt) {
+			DP_ERR(p_hwfn, "failed to acquire ptt\n");
+			return -EBUSY;
+		}
+		rc = qed_mcp_bist_register_test(p_hwfn, p_ptt);
+		qed_ptt_release(p_hwfn, p_ptt);
+		if (rc)
+			break;
+	}
+
+	return rc;
+}
+
+int qed_selftest_clock(struct qed_dev *cdev)
+{
+	struct qed_hwfn *p_hwfn;
+	struct qed_ptt *p_ptt;
+	int rc = 0, i;
+
+	/* although performed by MCP, this test is per engine */
+	for_each_hwfn(cdev, i) {
+		p_hwfn = &cdev->hwfns[i];
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt) {
+			DP_ERR(p_hwfn, "failed to acquire ptt\n");
+			return -EBUSY;
+		}
+		rc = qed_mcp_bist_clock_test(p_hwfn, p_ptt);
+		qed_ptt_release(p_hwfn, p_ptt);
+		if (rc)
+			break;
+	}
+
+	return rc;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_selftest.h b/drivers/net/ethernet/qlogic/qed/qed_selftest.h
new file mode 100644
index 0000000..50eb0b49
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_selftest.h
@@ -0,0 +1,40 @@
+#ifndef _QED_SELFTEST_API_H
+#define _QED_SELFTEST_API_H
+#include <linux/types.h>
+
+/**
+ * @brief qed_selftest_memory - Perform memory test
+ *
+ * @param cdev
+ *
+ * @return int
+ */
+int qed_selftest_memory(struct qed_dev *cdev);
+
+/**
+ * @brief qed_selftest_interrupt - Perform interrupt test
+ *
+ * @param cdev
+ *
+ * @return int
+ */
+int qed_selftest_interrupt(struct qed_dev *cdev);
+
+/**
+ * @brief qed_selftest_register - Perform register test
+ *
+ * @param cdev
+ *
+ * @return int
+ */
+int qed_selftest_register(struct qed_dev *cdev);
+
+/**
+ * @brief qed_selftest_clock - Perform clock test
+ *
+ * @param cdev
+ *
+ * @return int
+ */
+int qed_selftest_clock(struct qed_dev *cdev);
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index 4b91cb3..eec137f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -369,4 +369,14 @@ int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
 			      struct qed_tunn_update_params *p_tunn,
 			      enum spq_mode comp_mode,
 			      struct qed_spq_comp_cb *p_comp_data);
+/**
+ * @brief qed_sp_heartbeat_ramrod - Send empty Ramrod
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+
+int qed_sp_heartbeat_ramrod(struct qed_hwfn *p_hwfn);
+
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 7ccd96e..9f9bc10 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -428,3 +428,24 @@ int qed_sp_pf_stop(struct qed_hwfn *p_hwfn)
 
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
+
+int qed_sp_heartbeat_ramrod(struct qed_hwfn *p_hwfn)
+{
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	int rc;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 COMMON_RAMROD_EMPTY, PROTOCOLID_COMMON,
+				 &init_data);
+	if (rc)
+		return rc;
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index e5de42b..d72c832 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -110,6 +110,7 @@ struct qed_link_params {
 #define QED_LINK_OVERRIDE_SPEED_ADV_SPEEDS      BIT(1)
 #define QED_LINK_OVERRIDE_SPEED_FORCED_SPEED    BIT(2)
 #define QED_LINK_OVERRIDE_PAUSE_CONFIG          BIT(3)
+#define QED_LINK_OVERRIDE_LOOPBACK_MODE         BIT(4)
 	u32	override_flags;
 	bool	autoneg;
 	u32	adv_speeds;
@@ -118,6 +119,12 @@ struct qed_link_params {
 #define QED_LINK_PAUSE_RX_ENABLE                BIT(1)
 #define QED_LINK_PAUSE_TX_ENABLE                BIT(2)
 	u32	pause_config;
+#define QED_LINK_LOOPBACK_NONE                  BIT(0)
+#define QED_LINK_LOOPBACK_INT_PHY               BIT(1)
+#define QED_LINK_LOOPBACK_EXT_PHY               BIT(2)
+#define QED_LINK_LOOPBACK_EXT                   BIT(3)
+#define QED_LINK_LOOPBACK_MAC                   BIT(4)
+	u32	loopback_mode;
 };
 
 struct qed_link_output {
@@ -158,7 +165,47 @@ struct qed_common_cb_ops {
 			       struct qed_link_output	*link);
 };
 
+struct qed_selftest_ops {
+/**
+ * @brief selftest_interrupt - Perform interrupt test
+ *
+ * @param cdev
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*selftest_interrupt)(struct qed_dev *cdev);
+
+/**
+ * @brief selftest_memory - Perform memory test
+ *
+ * @param cdev
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*selftest_memory)(struct qed_dev *cdev);
+
+/**
+ * @brief selftest_register - Perform register test
+ *
+ * @param cdev
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*selftest_register)(struct qed_dev *cdev);
+
+/**
+ * @brief selftest_clock - Perform clock test
+ *
+ * @param cdev
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*selftest_clock)(struct qed_dev *cdev);
+};
+
 struct qed_common_ops {
+	struct qed_selftest_ops *selftest;
+
 	struct qed_dev*	(*probe)(struct pci_dev *dev,
 				 enum qed_protocol protocol,
 				 u32 dp_module, u8 dp_level);
-- 
1.8.3.1
