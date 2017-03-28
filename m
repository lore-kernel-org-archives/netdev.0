From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/7] qed: Send pf-flr as part of initialization
Date: Tue, 28 Mar 2017 15:12:53 +0300
Message-ID: <1490703176-429-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41207 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751991AbdC1MNm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 08:13:42 -0400
In-Reply-To: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During HW initialization, driver would set various registers to their
needed values - but it assumes all registers start at their reset-value,
so there's no need to re-configure a register's default value.

This assumption might be incorrect, e.g., in case of preboot driver
running and initializing the driver prior to our driver.

To overcome this, we now ask management firmware to initiate a PF-flr
early during the initialization sequence. That would return everything
in the PF's scope back to default and prevent previous configurations
from still being applied.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c |  9 +++++++++
 drivers/net/ethernet/qlogic/qed/qed_hsi.h |  1 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.c |  8 ++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h | 10 ++++++++++
 4 files changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 759b819..e4b1450 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2280,6 +2280,15 @@ static int qed_hw_prepare_single(struct qed_hwfn *p_hwfn,
 		goto err2;
 	}
 
+	/* Sending a mailbox to the MFW should be done after qed_get_hw_info()
+	 * is called as it sets the ports number in an engine.
+	 */
+	if (IS_LEAD_HWFN(p_hwfn)) {
+		rc = qed_mcp_initiate_pf_flr(p_hwfn, p_hwfn->p_main_ptt);
+		if (rc)
+			DP_NOTICE(p_hwfn, "Failed to initiate PF FLR\n");
+	}
+
 	/* Allocate the init RT array and initialize the init-ops engine */
 	rc = qed_init_alloc(p_hwfn);
 	if (rc)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index bf2b201..2de7aa1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -10093,6 +10093,7 @@ struct public_drv_mb {
 #define DRV_MSG_CODE_BW_UPDATE_ACK		0x32000000
 #define DRV_MSG_CODE_NIG_DRAIN			0x30000000
 #define DRV_MSG_GET_RESOURCE_ALLOC_MSG          0x34000000
+#define DRV_MSG_CODE_INITIATE_PF_FLR            0x02010000
 #define DRV_MSG_CODE_VF_DISABLED_DONE		0xc0000000
 #define DRV_MSG_CODE_CFG_VF_MSIX		0xc0010000
 #define DRV_MSG_CODE_NVM_GET_FILE_ATT		0x00030000
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 1a820b4..490619f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -2263,3 +2263,11 @@ int qed_mcp_get_resc_info(struct qed_hwfn *p_hwfn,
 
 	return 0;
 }
+
+int qed_mcp_initiate_pf_flr(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 mcp_resp, mcp_param;
+
+	return qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_INITIATE_PF_FLR, 0,
+			   &mcp_resp, &mcp_param);
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index f76afec..0056cfe 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -770,4 +770,14 @@ int qed_mcp_get_resc_info(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt,
 			  struct resource_info *p_resc_info,
 			  u32 *p_mcp_resp, u32 *p_mcp_param);
+
+/**
+ * @brief - Initiates PF FLR
+ *
+ *  @param p_hwfn
+ *  @param p_ptt
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_initiate_pf_flr(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 #endif
-- 
1.9.3
