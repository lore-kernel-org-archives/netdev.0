From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 10/10] qed: Cache alignemnt padding to match host
Date: Sun, 28 May 2017 18:02:00 +0300
Message-ID: <1495983720-10853-11-git-send-email-Yuval.Mintz@cavium.com>
References: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0077.outbound.protection.outlook.com ([104.47.36.77]:31424
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751098AbdE1PEO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 11:04:14 -0400
In-Reply-To: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve PCI performance by adjusting padding sizes to match those of the
host machine's cacheline.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c      | 15 +++++++++++++--
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |  1 +
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 072d950..d73e3c2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1227,6 +1227,10 @@ static void qed_init_cache_line_size(struct qed_hwfn *p_hwfn,
 			L1_CACHE_BYTES, wr_mbs);
 
 	STORE_RT_REG(p_hwfn, PGLUE_REG_B_CACHE_LINE_SIZE_RT_OFFSET, val);
+	if (val > 0) {
+		STORE_RT_REG(p_hwfn, PSWRQ2_REG_DRAM_ALIGN_WR_RT_OFFSET, val);
+		STORE_RT_REG(p_hwfn, PSWRQ2_REG_DRAM_ALIGN_RD_RT_OFFSET, val);
+	}
 }
 
 static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
@@ -1433,8 +1437,15 @@ enum QED_ROCE_EDPM_MODE {
 static int qed_hw_init_port(struct qed_hwfn *p_hwfn,
 			    struct qed_ptt *p_ptt, int hw_mode)
 {
-	return qed_init_run(p_hwfn, p_ptt, PHASE_PORT,
-			    p_hwfn->port_id, hw_mode);
+	int rc = 0;
+
+	rc = qed_init_run(p_hwfn, p_ptt, PHASE_PORT, p_hwfn->port_id, hw_mode);
+	if (rc)
+		return rc;
+
+	qed_wr(p_hwfn, p_ptt, PGLUE_B_REG_MASTER_WRITE_PAD_ENABLE, 0);
+
+	return 0;
 }
 
 static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index 6abf918..67172d7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -1559,6 +1559,7 @@
 #define PGLUE_B_REG_PGL_ADDR_EC_F0_K2 0x2aaf9cUL
 #define PGLUE_B_REG_PGL_ADDR_F0_F0_K2 0x2aafa0UL
 #define PGLUE_B_REG_PGL_ADDR_F4_F0_K2 0x2aafa4UL
+#define PGLUE_B_REG_MASTER_WRITE_PAD_ENABLE 0x2aae30UL
 #define NIG_REG_TSGEN_FREECNT_UPDATE_K2 0x509008UL
 #define CNIG_REG_NIG_PORT0_CONF_K2 0x218200UL
 
-- 
1.9.3
