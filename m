From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 5/6] qed: align DPI configuration to HW requirements
Date: Sun, 30 Apr 2017 11:49:09 +0300
Message-ID: <1493542150-21826-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ram.Amrani@cavium.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0071.outbound.protection.outlook.com ([104.47.38.71]:17717
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2999273AbdD3Itv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 04:49:51 -0400
In-Reply-To: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

When calculating doorbell BAR partitioning round up the number of
CPUs to the nearest power of 2 so the size of the DPI (per user
section) configured in the hardware will be stored properly and
not truncated.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     |  1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 12 +++++-------
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index c07191c..edf3b68 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -72,6 +72,7 @@
 #define QED_WFQ_UNIT	100
 
 #define QED_WID_SIZE            (1024)
+#define QED_MIN_WIDS		(4)
 #define QED_PF_DEMS_SIZE        (4)
 
 /* cau states */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index aa1a4d5..c478e07 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1318,17 +1318,15 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 qed_hw_init_dpi_size(struct qed_hwfn *p_hwfn,
 		     struct qed_ptt *p_ptt, u32 pwm_region_size, u32 n_cpus)
 {
-	u32 dpi_page_size_1, dpi_page_size_2, dpi_page_size;
-	u32 dpi_bit_shift, dpi_count;
+	u32 dpi_bit_shift, dpi_count, dpi_page_size;
 	u32 min_dpis;
+	u32 n_wids;
 
 	/* Calculate DPI size */
-	dpi_page_size_1 = QED_WID_SIZE * n_cpus;
-	dpi_page_size_2 = max_t(u32, QED_WID_SIZE, PAGE_SIZE);
-	dpi_page_size = max_t(u32, dpi_page_size_1, dpi_page_size_2);
-	dpi_page_size = roundup_pow_of_two(dpi_page_size);
+	n_wids = max_t(u32, QED_MIN_WIDS, n_cpus);
+	dpi_page_size = QED_WID_SIZE * roundup_pow_of_two(n_wids);
+	dpi_page_size = (dpi_page_size + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1);
 	dpi_bit_shift = ilog2(dpi_page_size / 4096);
-
 	dpi_count = pwm_region_size / dpi_page_size;
 
 	min_dpis = p_hwfn->pf_params.rdma_pf_params.min_dpis;
-- 
1.9.3
