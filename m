From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 09/11] qed: Provide MBI information in dev_info
Date: Mon, 22 May 2017 14:32:09 +0300
Message-ID: <1495452731-27171-10-git-send-email-Yuval.Mintz@cavium.com>
References: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0051.outbound.protection.outlook.com ([104.47.42.51]:50136
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932406AbdEVLd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 07:33:29 -0400
In-Reply-To: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

Pass additional information about package installed on persistent memory
so that protocol drivers would be able to log it.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h  |  6 ++++++
 drivers/net/ethernet/qlogic/qed/qed_main.c |  3 +++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c  | 30 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h  | 12 ++++++++++++
 include/linux/qed/qed_if.h                 | 17 +++++++++++++++++
 5 files changed, 68 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 4755d0b..802c162 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -11782,6 +11782,12 @@ struct nvm_cfg1_glob {
 	u32 led_global_settings;
 	u32 generic_cont1;
 	u32 mbi_version;
+#define NVM_CFG1_GLOB_MBI_VERSION_0_MASK		0x000000FF
+#define NVM_CFG1_GLOB_MBI_VERSION_0_OFFSET		0
+#define NVM_CFG1_GLOB_MBI_VERSION_1_MASK		0x0000FF00
+#define NVM_CFG1_GLOB_MBI_VERSION_1_OFFSET		8
+#define NVM_CFG1_GLOB_MBI_VERSION_2_MASK		0x00FF0000
+#define NVM_CFG1_GLOB_MBI_VERSION_2_OFFSET		16
 	u32 mbi_date;
 	u32 misc_sig;
 	u32 device_capabilities;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 3043dcce..b5313c5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -281,6 +281,9 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 			qed_mcp_get_mfw_ver(QED_LEADING_HWFN(cdev), ptt,
 					    &dev_info->mfw_rev, NULL);
 
+			qed_mcp_get_mbi_ver(QED_LEADING_HWFN(cdev), ptt,
+					    &dev_info->mbi_version);
+
 			qed_mcp_get_flash_size(QED_LEADING_HWFN(cdev), ptt,
 					       &dev_info->flash_size);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index b32e819..fc49c75e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1523,6 +1523,36 @@ int qed_mcp_get_mfw_ver(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+int qed_mcp_get_mbi_ver(struct qed_hwfn *p_hwfn,
+			struct qed_ptt *p_ptt, u32 *p_mbi_ver)
+{
+	u32 nvm_cfg_addr, nvm_cfg1_offset, mbi_ver_addr;
+
+	if (IS_VF(p_hwfn->cdev))
+		return -EINVAL;
+
+	/* Read the address of the nvm_cfg */
+	nvm_cfg_addr = qed_rd(p_hwfn, p_ptt, MISC_REG_GEN_PURP_CR0);
+	if (!nvm_cfg_addr) {
+		DP_NOTICE(p_hwfn, "Shared memory not initialized\n");
+		return -EINVAL;
+	}
+
+	/* Read the offset of nvm_cfg1 */
+	nvm_cfg1_offset = qed_rd(p_hwfn, p_ptt, nvm_cfg_addr + 4);
+
+	mbi_ver_addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
+		       offsetof(struct nvm_cfg1, glob) +
+		       offsetof(struct nvm_cfg1_glob, mbi_version);
+	*p_mbi_ver = qed_rd(p_hwfn, p_ptt,
+			    mbi_ver_addr) &
+		     (NVM_CFG1_GLOB_MBI_VERSION_0_MASK |
+		      NVM_CFG1_GLOB_MBI_VERSION_1_MASK |
+		      NVM_CFG1_GLOB_MBI_VERSION_2_MASK);
+
+	return 0;
+}
+
 int qed_mcp_get_media_type(struct qed_dev *cdev, u32 *p_media_type)
 {
 	struct qed_hwfn *p_hwfn = &cdev->hwfns[0];
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 3e5bffe..4024759 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -256,6 +256,18 @@ int qed_mcp_get_mfw_ver(struct qed_hwfn *p_hwfn,
 			u32 *p_mfw_ver, u32 *p_running_bundle_id);
 
 /**
+ * @brief Get the MBI version value
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param p_mbi_ver - A pointer to a variable to be filled with the MBI version.
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_get_mbi_ver(struct qed_hwfn *p_hwfn,
+			struct qed_ptt *p_ptt, u32 *p_mbi_ver);
+
+/**
  * @brief Get media type value of the port.
  *
  * @param cdev      - qed dev pointer
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index ff590cb..b00e675 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -328,6 +328,14 @@ struct qed_dev_info {
 
 	/* MFW version */
 	u32		mfw_rev;
+#define QED_MFW_VERSION_0_MASK		0x000000FF
+#define QED_MFW_VERSION_0_OFFSET	0
+#define QED_MFW_VERSION_1_MASK		0x0000FF00
+#define QED_MFW_VERSION_1_OFFSET	8
+#define QED_MFW_VERSION_2_MASK		0x00FF0000
+#define QED_MFW_VERSION_2_OFFSET	16
+#define QED_MFW_VERSION_3_MASK		0xFF000000
+#define QED_MFW_VERSION_3_OFFSET	24
 
 	u32		flash_size;
 	u8		mf_mode;
@@ -337,6 +345,15 @@ struct qed_dev_info {
 
 	bool wol_support;
 
+	/* MBI version */
+	u32 mbi_version;
+#define QED_MBI_VERSION_0_MASK		0x000000FF
+#define QED_MBI_VERSION_0_OFFSET	0
+#define QED_MBI_VERSION_1_MASK		0x0000FF00
+#define QED_MBI_VERSION_1_OFFSET	8
+#define QED_MBI_VERSION_2_MASK		0x00FF0000
+#define QED_MBI_VERSION_2_OFFSET	16
+
 	enum qed_dev_type dev_type;
 
 	/* Output parameters for qede */
-- 
1.9.3
