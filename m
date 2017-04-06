From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 3/8] qed: Configure cacheline size in HW
Date: Thu, 6 Apr 2017 15:58:30 +0300
Message-ID: <1491483515-13502-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53185 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756577AbdDFM7J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:59:09 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

Default HW configuration is optimal for an architecture where cache
line size is 64B.

During chip initialization, properly initialize the cache line size
in HW to avoid possible redundant PCI transactions.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c      | 53 ++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |  1 +
 2 files changed, 54 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2df83be..c5f4886 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1192,6 +1192,57 @@ static void qed_init_cau_rt_data(struct qed_dev *cdev)
 	}
 }
 
+static void qed_init_cache_line_size(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt)
+{
+	u32 val, wr_mbs, cache_line_size;
+
+	val = qed_rd(p_hwfn, p_ptt, PSWRQ2_REG_WR_MBS0);
+	switch (val) {
+	case 0:
+		wr_mbs = 128;
+		break;
+	case 1:
+		wr_mbs = 256;
+		break;
+	case 2:
+		wr_mbs = 512;
+		break;
+	default:
+		DP_INFO(p_hwfn,
+			"Unexpected value of PSWRQ2_REG_WR_MBS0 [0x%x]. Avoid configuring PGLUE_B_REG_CACHE_LINE_SIZE.\n",
+			val);
+		return;
+	}
+
+	cache_line_size = min_t(u32, L1_CACHE_BYTES, wr_mbs);
+	switch (cache_line_size) {
+	case 32:
+		val = 0;
+		break;
+	case 64:
+		val = 1;
+		break;
+	case 128:
+		val = 2;
+		break;
+	case 256:
+		val = 3;
+		break;
+	default:
+		DP_INFO(p_hwfn,
+			"Unexpected value of cache line size [0x%x]. Avoid configuring PGLUE_B_REG_CACHE_LINE_SIZE.\n",
+			cache_line_size);
+	}
+
+	if (L1_CACHE_BYTES > wr_mbs)
+		DP_INFO(p_hwfn,
+			"The cache line size for padding is suboptimal for performance [OS cache line size 0x%x, wr mbs 0x%x]\n",
+			L1_CACHE_BYTES, wr_mbs);
+
+	STORE_RT_REG(p_hwfn, PGLUE_REG_B_CACHE_LINE_SIZE_RT_OFFSET, val);
+}
+
 static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 			      struct qed_ptt *p_ptt, int hw_mode)
 {
@@ -1240,6 +1291,8 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 	qed_wr(p_hwfn, p_ptt, NIG_REG_STORM_OUT_EN, 0);
 	qed_port_unpretend(p_hwfn, p_ptt);
 
+	qed_init_cache_line_size(p_hwfn, p_ptt);
+
 	rc = qed_init_run(p_hwfn, p_ptt, PHASE_ENGINE, ANY_PHASE_ID, hw_mode);
 	if (rc)
 		return rc;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index 6d4ac7e..e65397360 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -1551,6 +1551,7 @@
 #define NIG_REG_TSGEN_FREE_CNT_VALUE_LSB 0x5088a8UL
 #define NIG_REG_TSGEN_FREE_CNT_VALUE_MSB 0x5088acUL
 #define NIG_REG_PTP_LATCH_OSTS_PKT_TIME 0x509040UL
+#define PSWRQ2_REG_WR_MBS0 0x240400UL
 
 #define PGLUE_B_REG_PGL_ADDR_E8_F0_K2 0x2aaf98UL
 #define PGLUE_B_REG_PGL_ADDR_EC_F0_K2 0x2aaf9cUL
-- 
1.9.3
