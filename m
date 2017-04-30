From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 6/6] qed: output the DPM status and WID count
Date: Sun, 30 Apr 2017 11:49:10 +0300
Message-ID: <1493542150-21826-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ram.Amrani@cavium.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0053.outbound.protection.outlook.com ([104.47.37.53]:23510
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S3000579AbdD3IuC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 04:50:02 -0400
In-Reply-To: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

Output to the RDMA driver whether DPM mode is enabled or disabled in
the HW and if so what is the number of WIDs it supports

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h      | 1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c  | 4 +++-
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 4 ++++
 include/linux/qed/qed_roce_if.h            | 2 ++
 4 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index edf3b68..2ab1aab 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -526,6 +526,7 @@ struct qed_hwfn {
 	struct dbg_tools_data		dbg_info;
 
 	/* PWM region specific data */
+	u16				wid_count;
 	u32				dpi_size;
 	u32				dpi_count;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index c478e07..5f31140 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1354,7 +1354,7 @@ enum QED_ROCE_EDPM_MODE {
 {
 	u32 pwm_regsize, norm_regsize;
 	u32 non_pwm_conn, min_addr_reg1;
-	u32 db_bar_size, n_cpus;
+	u32 db_bar_size, n_cpus = 1;
 	u32 roce_edpm_mode;
 	u32 pf_dems_shift;
 	int rc = 0;
@@ -1415,6 +1415,8 @@ enum QED_ROCE_EDPM_MODE {
 			qed_rdma_dpm_bar(p_hwfn, p_ptt);
 	}
 
+	p_hwfn->wid_count = (u16) n_cpus;
+
 	DP_INFO(p_hwfn,
 		"doorbell bar: normal_region_size=%d, pwm_region_size=%d, dpi_size=%d, dpi_count=%d, roce_edpm=%s\n",
 		norm_regsize,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index f36e3c3..8d6ad87 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -784,6 +784,7 @@ static int qed_rdma_add_user(void *rdma_cxt,
 				    ((out_params->dpi) * p_hwfn->dpi_size);
 
 	out_params->dpi_size = p_hwfn->dpi_size;
+	out_params->wid_count = p_hwfn->wid_count;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Adding user - done, rc = %d\n", rc);
 	return rc;
@@ -856,9 +857,12 @@ static void qed_rdma_cnq_prod_update(void *rdma_cxt, u8 qz_offset, u16 prod)
 static int qed_fill_rdma_dev_info(struct qed_dev *cdev,
 				  struct qed_dev_rdma_info *info)
 {
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+
 	memset(info, 0, sizeof(*info));
 
 	info->rdma_type = QED_RDMA_TYPE_ROCE;
+	info->user_dpm_enabled = (p_hwfn->db_bar_no_edpm == 0);
 
 	qed_fill_dev_info(cdev, &info->common);
 
diff --git a/include/linux/qed/qed_roce_if.h b/include/linux/qed/qed_roce_if.h
index f742d43..cbb2ff0 100644
--- a/include/linux/qed/qed_roce_if.h
+++ b/include/linux/qed/qed_roce_if.h
@@ -240,6 +240,7 @@ struct qed_rdma_add_user_out_params {
 	u64 dpi_addr;
 	u64 dpi_phys_addr;
 	u32 dpi_size;
+	u16 wid_count;
 };
 
 enum roce_mode {
@@ -533,6 +534,7 @@ enum qed_rdma_type {
 struct qed_dev_rdma_info {
 	struct qed_dev_info common;
 	enum qed_rdma_type rdma_type;
+	u8 user_dpm_enabled;
 };
 
 struct qed_rdma_ops {
-- 
1.9.3
