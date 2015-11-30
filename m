From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/6] qed: Add support for changing LED state
Date: Mon, 30 Nov 2015 12:25:03 +0200
Message-ID: <1448879106-12321-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Sudarsana.Kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:44347 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613AbbK3K0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 05:26:17 -0500
In-Reply-To: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

Physical LEDs are being controlled by the management FW.
This adds the qed functionality required to request management FW to
change the LED configuration, as well as the necessary APIs for this
functionality to later be used by the protocol drivers.

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h  |  6 ++++++
 drivers/net/ethernet/qlogic/qed/qed_main.c | 18 ++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c  | 27 +++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h  | 13 +++++++++++++
 include/linux/qed/qed_if.h                 | 17 +++++++++++++++++
 5 files changed, 81 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index b2f8e85..264e954 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -3993,6 +3993,8 @@ struct public_drv_mb {
 #define DRV_MSG_CODE_PHY_CORE_WRITE             0x000e0000
 #define DRV_MSG_CODE_SET_VERSION                0x000f0000
 
+#define DRV_MSG_CODE_SET_LED_MODE               0x00200000
+
 #define DRV_MSG_SEQ_NUMBER_MASK                 0x0000ffff
 
 	u32 drv_mb_param;
@@ -4044,6 +4046,10 @@ struct public_drv_mb {
 #define DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_SHIFT   8
 #define DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_MASK    0x0000FF00
 
+#define DRV_MB_PARAM_SET_LED_MODE_OPER          0x0
+#define DRV_MB_PARAM_SET_LED_MODE_ON            0x1
+#define DRV_MB_PARAM_SET_LED_MODE_OFF           0x2
+
 	u32 fw_mb_header;
 #define FW_MSG_CODE_MASK                        0xffff0000
 #define FW_MSG_CODE_DRV_LOAD_ENGINE             0x10100000
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 947c7af..6b02e11 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1135,6 +1135,23 @@ static int qed_drain(struct qed_dev *cdev)
 	return 0;
 }
 
+static int qed_set_led(struct qed_dev *cdev, enum qed_led_mode mode)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_ptt *ptt;
+	int status = 0;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return -EAGAIN;
+
+	status = qed_mcp_set_led(hwfn, ptt, mode);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return status;
+}
+
 const struct qed_common_ops qed_common_ops_pass = {
 	.probe = &qed_probe,
 	.remove = &qed_remove,
@@ -1155,6 +1172,7 @@ const struct qed_common_ops qed_common_ops_pass = {
 	.update_msglvl = &qed_init_dp,
 	.chain_alloc = &qed_chain_alloc,
 	.chain_free = &qed_chain_free,
+	.set_led = &qed_set_led,
 };
 
 u32 qed_get_protocol_version(enum qed_protocol protocol)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 20d048c..ba1b1f1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -858,3 +858,30 @@ qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
 
 	return 0;
 }
+
+int qed_mcp_set_led(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+		    enum qed_led_mode mode)
+{
+	u32 resp = 0, param = 0, drv_mb_param;
+	int rc;
+
+	switch (mode) {
+	case QED_LED_MODE_ON:
+		drv_mb_param = DRV_MB_PARAM_SET_LED_MODE_ON;
+		break;
+	case QED_LED_MODE_OFF:
+		drv_mb_param = DRV_MB_PARAM_SET_LED_MODE_OFF;
+		break;
+	case QED_LED_MODE_RESTORE:
+		drv_mb_param = DRV_MB_PARAM_SET_LED_MODE_OPER;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Invalid LED mode %d\n", mode);
+		return -EINVAL;
+	}
+
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_SET_LED_MODE,
+			 drv_mb_param, &resp, &param);
+
+	return rc;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index dbaae58..506197d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -224,6 +224,19 @@ qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
 			 struct qed_ptt *p_ptt,
 			 struct qed_mcp_drv_version *p_ver);
 
+/**
+ * @brief Set LED status
+ *
+ *  @param p_hwfn
+ *  @param p_ptt
+ *  @param mode - LED mode
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_set_led(struct qed_hwfn *p_hwfn,
+		    struct qed_ptt *p_ptt,
+		    enum qed_led_mode mode);
+
 /* Using hwfn number (and not pf_num) is required since in CMT mode,
  * same pf_num may be used by two different hwfn
  * TODO - this shouldn't really be in .h file, but until all fields
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index dc9a1353..d4a32e8 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -25,6 +25,12 @@
 #include <linux/qed/common_hsi.h>
 #include <linux/qed/qed_chain.h>
 
+enum qed_led_mode {
+	QED_LED_MODE_OFF,
+	QED_LED_MODE_ON,
+	QED_LED_MODE_RESTORE
+};
+
 #define DIRECT_REG_WR(reg_addr, val) writel((u32)val, \
 					    (void __iomem *)(reg_addr))
 
@@ -252,6 +258,17 @@ struct qed_common_ops {
 
 	void		(*chain_free)(struct qed_dev *cdev,
 				      struct qed_chain *p_chain);
+
+/**
+ * @brief set_led - Configure LED mode
+ *
+ * @param cdev
+ * @param mode - LED mode
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*set_led)(struct qed_dev *cdev,
+		       enum qed_led_mode mode);
 };
 
 /**
-- 
1.9.3
