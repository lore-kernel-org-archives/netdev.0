From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 2/4] cxgb4: Add support to dump edc bist status
Date: Tue,  4 Aug 2015 14:36:18 +0530
Message-ID: <1438679180-25930-3-git-send-email-hariprasad@chelsio.com>
References: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5966 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755087AbbHDDvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 23:51:54 -0400
In-Reply-To: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to dump edc bist status for ECC data errors

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c   | 39 ++++++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |  5 ++--
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 800bd48..b193295 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -345,6 +345,43 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 				       FW_CMD_MAX_TIMEOUT);
 }
 
+static int t4_edc_err_read(struct adapter *adap, int idx)
+{
+	u32 edc_ecc_err_addr_reg;
+	u32 rdata_reg;
+
+	if (is_t4(adap->params.chip)) {
+		CH_WARN(adap, "%s: T4 NOT supported.\n", __func__);
+		return 0;
+	}
+	if (idx != 0 && idx != 1) {
+		CH_WARN(adap, "%s: idx %d NOT supported.\n", __func__, idx);
+		return 0;
+	}
+
+	edc_ecc_err_addr_reg = EDC_T5_REG(EDC_H_ECC_ERR_ADDR_A, idx);
+	rdata_reg = EDC_T5_REG(EDC_H_BIST_STATUS_RDATA_A, idx);
+
+	CH_WARN(adap,
+		"edc%d err addr 0x%x: 0x%x.\n",
+		idx, edc_ecc_err_addr_reg,
+		t4_read_reg(adap, edc_ecc_err_addr_reg));
+	CH_WARN(adap,
+		"bist: 0x%x, status %llx %llx %llx %llx %llx %llx %llx %llx %llx.\n",
+		rdata_reg,
+		(unsigned long long)t4_read_reg64(adap, rdata_reg),
+		(unsigned long long)t4_read_reg64(adap, rdata_reg + 8),
+		(unsigned long long)t4_read_reg64(adap, rdata_reg + 16),
+		(unsigned long long)t4_read_reg64(adap, rdata_reg + 24),
+		(unsigned long long)t4_read_reg64(adap, rdata_reg + 32),
+		(unsigned long long)t4_read_reg64(adap, rdata_reg + 40),
+		(unsigned long long)t4_read_reg64(adap, rdata_reg + 48),
+		(unsigned long long)t4_read_reg64(adap, rdata_reg + 56),
+		(unsigned long long)t4_read_reg64(adap, rdata_reg + 64));
+
+	return 0;
+}
+
 /**
  *	t4_memory_rw - read/write EDC 0, EDC 1 or MC via PCIE memory window
  *	@adap: the adapter
@@ -3283,6 +3320,8 @@ static void mem_intr_handler(struct adapter *adapter, int idx)
 	if (v & ECC_CE_INT_CAUSE_F) {
 		u32 cnt = ECC_CECNT_G(t4_read_reg(adapter, cnt_addr));
 
+		t4_edc_err_read(adapter, idx);
+
 		t4_write_reg(adapter, cnt_addr, ECC_CECNT_V(ECC_CECNT_M));
 		if (printk_ratelimit())
 			dev_warn(adapter->pdev_dev,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 0626868..13ce018 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2867,10 +2867,11 @@
 #define EDC_H_BIST_DATA_PATTERN_A	0x50010
 #define EDC_H_BIST_STATUS_RDATA_A	0x50028
 
+#define EDC_H_ECC_ERR_ADDR_A		0x50084
 #define EDC_T51_BASE_ADDR		0x50800
 
-#define EDC_STRIDE_T5 (EDC_T51_BASE_ADDR - EDC_T50_BASE_ADDR)
-#define EDC_REG_T5(reg, idx) (reg + EDC_STRIDE_T5 * idx)
+#define EDC_T5_STRIDE (EDC_T51_BASE_ADDR - EDC_T50_BASE_ADDR)
+#define EDC_T5_REG(reg, idx) (reg + EDC_T5_STRIDE * idx)
 
 #define PL_VF_REV_A 0x4
 #define PL_VF_WHOAMI_A 0x0
-- 
2.3.4
