From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 3/5] cxgb4/cxg4vf/csiostor: Cleanup MC, MA and CIM related register defines
Date: Mon,  5 Jan 2015 16:30:45 +0530
Message-ID: <1420455647-23094-4-git-send-email-hariprasad@chelsio.com>
References: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, praveenm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420455647-23094-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch cleanups all MC, MA and CIM related macros/register defines that are
defined in t4_regs.h and the affected files.

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c       |  206 +++++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h     |  501 +++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h |    4 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c   |   14 +-
 drivers/scsi/csiostor/csio_hw.c                  |  125 +++---
 drivers/scsi/csiostor/csio_hw_t4.c               |   32 +-
 drivers/scsi/csiostor/csio_hw_t5.c               |   36 +-
 drivers/scsi/csiostor/csio_mb.c                  |   49 ++-
 8 files changed, 588 insertions(+), 379 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 9f8cd56..c9777e0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -265,8 +265,8 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 	u64 res;
 	int i, ms, delay_idx;
 	const __be64 *p = cmd;
-	u32 data_reg = PF_REG(mbox, CIM_PF_MAILBOX_DATA);
-	u32 ctl_reg = PF_REG(mbox, CIM_PF_MAILBOX_CTRL);
+	u32 data_reg = PF_REG(mbox, CIM_PF_MAILBOX_DATA_A);
+	u32 ctl_reg = PF_REG(mbox, CIM_PF_MAILBOX_CTRL_A);
 
 	if ((size & 15) || size > MBOX_LEN)
 		return -EINVAL;
@@ -278,9 +278,9 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 	if (adap->pdev->error_state != pci_channel_io_normal)
 		return -EIO;
 
-	v = MBOWNER_GET(t4_read_reg(adap, ctl_reg));
+	v = MBOWNER_G(t4_read_reg(adap, ctl_reg));
 	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
-		v = MBOWNER_GET(t4_read_reg(adap, ctl_reg));
+		v = MBOWNER_G(t4_read_reg(adap, ctl_reg));
 
 	if (v != MBOX_OWNER_DRV)
 		return v ? -EBUSY : -ETIMEDOUT;
@@ -288,7 +288,7 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 	for (i = 0; i < size; i += 8)
 		t4_write_reg64(adap, data_reg + i, be64_to_cpu(*p++));
 
-	t4_write_reg(adap, ctl_reg, MBMSGVALID | MBOWNER(MBOX_OWNER_FW));
+	t4_write_reg(adap, ctl_reg, MBMSGVALID_F | MBOWNER_V(MBOX_OWNER_FW));
 	t4_read_reg(adap, ctl_reg);          /* flush write */
 
 	delay_idx = 0;
@@ -304,8 +304,8 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 			mdelay(ms);
 
 		v = t4_read_reg(adap, ctl_reg);
-		if (MBOWNER_GET(v) == MBOX_OWNER_DRV) {
-			if (!(v & MBMSGVALID)) {
+		if (MBOWNER_G(v) == MBOX_OWNER_DRV) {
+			if (!(v & MBMSGVALID_F)) {
 				t4_write_reg(adap, ctl_reg, 0);
 				continue;
 			}
@@ -351,27 +351,27 @@ int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
 	u32 mc_bist_status_rdata, mc_bist_data_pattern;
 
 	if (is_t4(adap->params.chip)) {
-		mc_bist_cmd = MC_BIST_CMD;
-		mc_bist_cmd_addr = MC_BIST_CMD_ADDR;
-		mc_bist_cmd_len = MC_BIST_CMD_LEN;
-		mc_bist_status_rdata = MC_BIST_STATUS_RDATA;
-		mc_bist_data_pattern = MC_BIST_DATA_PATTERN;
+		mc_bist_cmd = MC_BIST_CMD_A;
+		mc_bist_cmd_addr = MC_BIST_CMD_ADDR_A;
+		mc_bist_cmd_len = MC_BIST_CMD_LEN_A;
+		mc_bist_status_rdata = MC_BIST_STATUS_RDATA_A;
+		mc_bist_data_pattern = MC_BIST_DATA_PATTERN_A;
 	} else {
-		mc_bist_cmd = MC_REG(MC_P_BIST_CMD, idx);
-		mc_bist_cmd_addr = MC_REG(MC_P_BIST_CMD_ADDR, idx);
-		mc_bist_cmd_len = MC_REG(MC_P_BIST_CMD_LEN, idx);
-		mc_bist_status_rdata = MC_REG(MC_P_BIST_STATUS_RDATA, idx);
-		mc_bist_data_pattern = MC_REG(MC_P_BIST_DATA_PATTERN, idx);
+		mc_bist_cmd = MC_REG(MC_P_BIST_CMD_A, idx);
+		mc_bist_cmd_addr = MC_REG(MC_P_BIST_CMD_ADDR_A, idx);
+		mc_bist_cmd_len = MC_REG(MC_P_BIST_CMD_LEN_A, idx);
+		mc_bist_status_rdata = MC_REG(MC_P_BIST_STATUS_RDATA_A, idx);
+		mc_bist_data_pattern = MC_REG(MC_P_BIST_DATA_PATTERN_A, idx);
 	}
 
-	if (t4_read_reg(adap, mc_bist_cmd) & START_BIST)
+	if (t4_read_reg(adap, mc_bist_cmd) & START_BIST_F)
 		return -EBUSY;
 	t4_write_reg(adap, mc_bist_cmd_addr, addr & ~0x3fU);
 	t4_write_reg(adap, mc_bist_cmd_len, 64);
 	t4_write_reg(adap, mc_bist_data_pattern, 0xc);
-	t4_write_reg(adap, mc_bist_cmd, BIST_OPCODE(1) | START_BIST |
-		     BIST_CMD_GAP(1));
-	i = t4_wait_op_done(adap, mc_bist_cmd, START_BIST, 0, 10, 1);
+	t4_write_reg(adap, mc_bist_cmd, BIST_OPCODE_V(1) | START_BIST_F |
+		     BIST_CMD_GAP_V(1));
+	i = t4_wait_op_done(adap, mc_bist_cmd, START_BIST_F, 0, 10, 1);
 	if (i)
 		return i;
 
@@ -404,31 +404,31 @@ int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
 	u32 edc_bist_cmd_data_pattern, edc_bist_status_rdata;
 
 	if (is_t4(adap->params.chip)) {
-		edc_bist_cmd = EDC_REG(EDC_BIST_CMD, idx);
-		edc_bist_cmd_addr = EDC_REG(EDC_BIST_CMD_ADDR, idx);
-		edc_bist_cmd_len = EDC_REG(EDC_BIST_CMD_LEN, idx);
-		edc_bist_cmd_data_pattern = EDC_REG(EDC_BIST_DATA_PATTERN,
-						    idx);
-		edc_bist_status_rdata = EDC_REG(EDC_BIST_STATUS_RDATA,
+		edc_bist_cmd = EDC_REG(EDC_BIST_CMD_A, idx);
+		edc_bist_cmd_addr = EDC_REG(EDC_BIST_CMD_ADDR_A, idx);
+		edc_bist_cmd_len = EDC_REG(EDC_BIST_CMD_LEN_A, idx);
+		edc_bist_cmd_data_pattern = EDC_REG(EDC_BIST_DATA_PATTERN_A,
 						    idx);
+		edc_bist_status_rdata = EDC_REG(EDC_BIST_STATUS_RDATA_A,
+						idx);
 	} else {
-		edc_bist_cmd = EDC_REG_T5(EDC_H_BIST_CMD, idx);
-		edc_bist_cmd_addr = EDC_REG_T5(EDC_H_BIST_CMD_ADDR, idx);
-		edc_bist_cmd_len = EDC_REG_T5(EDC_H_BIST_CMD_LEN, idx);
+		edc_bist_cmd = EDC_REG_T5(EDC_H_BIST_CMD_A, idx);
+		edc_bist_cmd_addr = EDC_REG_T5(EDC_H_BIST_CMD_ADDR_A, idx);
+		edc_bist_cmd_len = EDC_REG_T5(EDC_H_BIST_CMD_LEN_A, idx);
 		edc_bist_cmd_data_pattern =
-			EDC_REG_T5(EDC_H_BIST_DATA_PATTERN, idx);
+			EDC_REG_T5(EDC_H_BIST_DATA_PATTERN_A, idx);
 		edc_bist_status_rdata =
-			 EDC_REG_T5(EDC_H_BIST_STATUS_RDATA, idx);
+			 EDC_REG_T5(EDC_H_BIST_STATUS_RDATA_A, idx);
 	}
 
-	if (t4_read_reg(adap, edc_bist_cmd) & START_BIST)
+	if (t4_read_reg(adap, edc_bist_cmd) & START_BIST_F)
 		return -EBUSY;
 	t4_write_reg(adap, edc_bist_cmd_addr, addr & ~0x3fU);
 	t4_write_reg(adap, edc_bist_cmd_len, 64);
 	t4_write_reg(adap, edc_bist_cmd_data_pattern, 0xc);
 	t4_write_reg(adap, edc_bist_cmd,
-		     BIST_OPCODE(1) | BIST_CMD_GAP(1) | START_BIST);
-	i = t4_wait_op_done(adap, edc_bist_cmd, START_BIST, 0, 10, 1);
+		     BIST_OPCODE_V(1) | BIST_CMD_GAP_V(1) | START_BIST_F);
+	i = t4_wait_op_done(adap, edc_bist_cmd, START_BIST_F, 0, 10, 1);
 	if (i)
 		return i;
 
@@ -1543,50 +1543,55 @@ static void sge_intr_handler(struct adapter *adapter)
 		t4_fatal_err(adapter);
 }
 
+#define CIM_OBQ_INTR (OBQULP0PARERR_F | OBQULP1PARERR_F | OBQULP2PARERR_F |\
+		      OBQULP3PARERR_F | OBQSGEPARERR_F | OBQNCSIPARERR_F)
+#define CIM_IBQ_INTR (IBQTP0PARERR_F | IBQTP1PARERR_F | IBQULPPARERR_F |\
+		      IBQSGEHIPARERR_F | IBQSGELOPARERR_F | IBQNCSIPARERR_F)
+
 /*
  * CIM interrupt handler.
  */
 static void cim_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info cim_intr_info[] = {
-		{ PREFDROPINT, "CIM control register prefetch drop", -1, 1 },
-		{ OBQPARERR, "CIM OBQ parity error", -1, 1 },
-		{ IBQPARERR, "CIM IBQ parity error", -1, 1 },
-		{ MBUPPARERR, "CIM mailbox uP parity error", -1, 1 },
-		{ MBHOSTPARERR, "CIM mailbox host parity error", -1, 1 },
-		{ TIEQINPARERRINT, "CIM TIEQ outgoing parity error", -1, 1 },
-		{ TIEQOUTPARERRINT, "CIM TIEQ incoming parity error", -1, 1 },
+		{ PREFDROPINT_F, "CIM control register prefetch drop", -1, 1 },
+		{ CIM_OBQ_INTR, "CIM OBQ parity error", -1, 1 },
+		{ CIM_IBQ_INTR, "CIM IBQ parity error", -1, 1 },
+		{ MBUPPARERR_F, "CIM mailbox uP parity error", -1, 1 },
+		{ MBHOSTPARERR_F, "CIM mailbox host parity error", -1, 1 },
+		{ TIEQINPARERRINT_F, "CIM TIEQ outgoing parity error", -1, 1 },
+		{ TIEQOUTPARERRINT_F, "CIM TIEQ incoming parity error", -1, 1 },
 		{ 0 }
 	};
 	static const struct intr_info cim_upintr_info[] = {
-		{ RSVDSPACEINT, "CIM reserved space access", -1, 1 },
-		{ ILLTRANSINT, "CIM illegal transaction", -1, 1 },
-		{ ILLWRINT, "CIM illegal write", -1, 1 },
-		{ ILLRDINT, "CIM illegal read", -1, 1 },
-		{ ILLRDBEINT, "CIM illegal read BE", -1, 1 },
-		{ ILLWRBEINT, "CIM illegal write BE", -1, 1 },
-		{ SGLRDBOOTINT, "CIM single read from boot space", -1, 1 },
-		{ SGLWRBOOTINT, "CIM single write to boot space", -1, 1 },
-		{ BLKWRBOOTINT, "CIM block write to boot space", -1, 1 },
-		{ SGLRDFLASHINT, "CIM single read from flash space", -1, 1 },
-		{ SGLWRFLASHINT, "CIM single write to flash space", -1, 1 },
-		{ BLKWRFLASHINT, "CIM block write to flash space", -1, 1 },
-		{ SGLRDEEPROMINT, "CIM single EEPROM read", -1, 1 },
-		{ SGLWREEPROMINT, "CIM single EEPROM write", -1, 1 },
-		{ BLKRDEEPROMINT, "CIM block EEPROM read", -1, 1 },
-		{ BLKWREEPROMINT, "CIM block EEPROM write", -1, 1 },
-		{ SGLRDCTLINT , "CIM single read from CTL space", -1, 1 },
-		{ SGLWRCTLINT , "CIM single write to CTL space", -1, 1 },
-		{ BLKRDCTLINT , "CIM block read from CTL space", -1, 1 },
-		{ BLKWRCTLINT , "CIM block write to CTL space", -1, 1 },
-		{ SGLRDPLINT , "CIM single read from PL space", -1, 1 },
-		{ SGLWRPLINT , "CIM single write to PL space", -1, 1 },
-		{ BLKRDPLINT , "CIM block read from PL space", -1, 1 },
-		{ BLKWRPLINT , "CIM block write to PL space", -1, 1 },
-		{ REQOVRLOOKUPINT , "CIM request FIFO overwrite", -1, 1 },
-		{ RSPOVRLOOKUPINT , "CIM response FIFO overwrite", -1, 1 },
-		{ TIMEOUTINT , "CIM PIF timeout", -1, 1 },
-		{ TIMEOUTMAINT , "CIM PIF MA timeout", -1, 1 },
+		{ RSVDSPACEINT_F, "CIM reserved space access", -1, 1 },
+		{ ILLTRANSINT_F, "CIM illegal transaction", -1, 1 },
+		{ ILLWRINT_F, "CIM illegal write", -1, 1 },
+		{ ILLRDINT_F, "CIM illegal read", -1, 1 },
+		{ ILLRDBEINT_F, "CIM illegal read BE", -1, 1 },
+		{ ILLWRBEINT_F, "CIM illegal write BE", -1, 1 },
+		{ SGLRDBOOTINT_F, "CIM single read from boot space", -1, 1 },
+		{ SGLWRBOOTINT_F, "CIM single write to boot space", -1, 1 },
+		{ BLKWRBOOTINT_F, "CIM block write to boot space", -1, 1 },
+		{ SGLRDFLASHINT_F, "CIM single read from flash space", -1, 1 },
+		{ SGLWRFLASHINT_F, "CIM single write to flash space", -1, 1 },
+		{ BLKWRFLASHINT_F, "CIM block write to flash space", -1, 1 },
+		{ SGLRDEEPROMINT_F, "CIM single EEPROM read", -1, 1 },
+		{ SGLWREEPROMINT_F, "CIM single EEPROM write", -1, 1 },
+		{ BLKRDEEPROMINT_F, "CIM block EEPROM read", -1, 1 },
+		{ BLKWREEPROMINT_F, "CIM block EEPROM write", -1, 1 },
+		{ SGLRDCTLINT_F, "CIM single read from CTL space", -1, 1 },
+		{ SGLWRCTLINT_F, "CIM single write to CTL space", -1, 1 },
+		{ BLKRDCTLINT_F, "CIM block read from CTL space", -1, 1 },
+		{ BLKWRCTLINT_F, "CIM block write to CTL space", -1, 1 },
+		{ SGLRDPLINT_F, "CIM single read from PL space", -1, 1 },
+		{ SGLWRPLINT_F, "CIM single write to PL space", -1, 1 },
+		{ BLKRDPLINT_F, "CIM block read from PL space", -1, 1 },
+		{ BLKWRPLINT_F, "CIM block write to PL space", -1, 1 },
+		{ REQOVRLOOKUPINT_F, "CIM request FIFO overwrite", -1, 1 },
+		{ RSPOVRLOOKUPINT_F, "CIM response FIFO overwrite", -1, 1 },
+		{ TIMEOUTINT_F, "CIM PIF timeout", -1, 1 },
+		{ TIMEOUTMAINT_F, "CIM PIF MA timeout", -1, 1 },
 		{ 0 }
 	};
 
@@ -1595,9 +1600,9 @@ static void cim_intr_handler(struct adapter *adapter)
 	if (t4_read_reg(adapter, PCIE_FW_A) & PCIE_FW_ERR_F)
 		t4_report_fw_error(adapter);
 
-	fat = t4_handle_intr_status(adapter, CIM_HOST_INT_CAUSE,
+	fat = t4_handle_intr_status(adapter, CIM_HOST_INT_CAUSE_A,
 				    cim_intr_info) +
-	      t4_handle_intr_status(adapter, CIM_HOST_UPACC_INT_CAUSE,
+	      t4_handle_intr_status(adapter, CIM_HOST_UPACC_INT_CAUSE_A,
 				    cim_upintr_info);
 	if (fat)
 		t4_fatal_err(adapter);
@@ -1786,7 +1791,8 @@ static void mps_intr_handler(struct adapter *adapter)
 		t4_fatal_err(adapter);
 }
 
-#define MEM_INT_MASK (PERR_INT_CAUSE | ECC_CE_INT_CAUSE | ECC_UE_INT_CAUSE)
+#define MEM_INT_MASK (PERR_INT_CAUSE_F | ECC_CE_INT_CAUSE_F | \
+		      ECC_UE_INT_CAUSE_F)
 
 /*
  * EDC/MC interrupt handler.
@@ -1798,40 +1804,40 @@ static void mem_intr_handler(struct adapter *adapter, int idx)
 	unsigned int addr, cnt_addr, v;
 
 	if (idx <= MEM_EDC1) {
-		addr = EDC_REG(EDC_INT_CAUSE, idx);
-		cnt_addr = EDC_REG(EDC_ECC_STATUS, idx);
+		addr = EDC_REG(EDC_INT_CAUSE_A, idx);
+		cnt_addr = EDC_REG(EDC_ECC_STATUS_A, idx);
 	} else if (idx == MEM_MC) {
 		if (is_t4(adapter->params.chip)) {
-			addr = MC_INT_CAUSE;
-			cnt_addr = MC_ECC_STATUS;
+			addr = MC_INT_CAUSE_A;
+			cnt_addr = MC_ECC_STATUS_A;
 		} else {
-			addr = MC_P_INT_CAUSE;
-			cnt_addr = MC_P_ECC_STATUS;
+			addr = MC_P_INT_CAUSE_A;
+			cnt_addr = MC_P_ECC_STATUS_A;
 		}
 	} else {
-		addr = MC_REG(MC_P_INT_CAUSE, 1);
-		cnt_addr = MC_REG(MC_P_ECC_STATUS, 1);
+		addr = MC_REG(MC_P_INT_CAUSE_A, 1);
+		cnt_addr = MC_REG(MC_P_ECC_STATUS_A, 1);
 	}
 
 	v = t4_read_reg(adapter, addr) & MEM_INT_MASK;
-	if (v & PERR_INT_CAUSE)
+	if (v & PERR_INT_CAUSE_F)
 		dev_alert(adapter->pdev_dev, "%s FIFO parity error\n",
 			  name[idx]);
-	if (v & ECC_CE_INT_CAUSE) {
-		u32 cnt = ECC_CECNT_GET(t4_read_reg(adapter, cnt_addr));
+	if (v & ECC_CE_INT_CAUSE_F) {
+		u32 cnt = ECC_CECNT_G(t4_read_reg(adapter, cnt_addr));
 
-		t4_write_reg(adapter, cnt_addr, ECC_CECNT_MASK);
+		t4_write_reg(adapter, cnt_addr, ECC_CECNT_V(ECC_CECNT_M));
 		if (printk_ratelimit())
 			dev_warn(adapter->pdev_dev,
 				 "%u %s correctable ECC data error%s\n",
 				 cnt, name[idx], cnt > 1 ? "s" : "");
 	}
-	if (v & ECC_UE_INT_CAUSE)
+	if (v & ECC_UE_INT_CAUSE_F)
 		dev_alert(adapter->pdev_dev,
 			  "%s uncorrectable ECC data error\n", name[idx]);
 
 	t4_write_reg(adapter, addr, v);
-	if (v & (PERR_INT_CAUSE | ECC_UE_INT_CAUSE))
+	if (v & (PERR_INT_CAUSE_F | ECC_UE_INT_CAUSE_F))
 		t4_fatal_err(adapter);
 }
 
@@ -1840,26 +1846,26 @@ static void mem_intr_handler(struct adapter *adapter, int idx)
  */
 static void ma_intr_handler(struct adapter *adap)
 {
-	u32 v, status = t4_read_reg(adap, MA_INT_CAUSE);
+	u32 v, status = t4_read_reg(adap, MA_INT_CAUSE_A);
 
-	if (status & MEM_PERR_INT_CAUSE) {
+	if (status & MEM_PERR_INT_CAUSE_F) {
 		dev_alert(adap->pdev_dev,
 			  "MA parity error, parity status %#x\n",
-			  t4_read_reg(adap, MA_PARITY_ERROR_STATUS));
+			  t4_read_reg(adap, MA_PARITY_ERROR_STATUS1_A));
 		if (is_t5(adap->params.chip))
 			dev_alert(adap->pdev_dev,
 				  "MA parity error, parity status %#x\n",
 				  t4_read_reg(adap,
-					      MA_PARITY_ERROR_STATUS2));
+					      MA_PARITY_ERROR_STATUS2_A));
 	}
-	if (status & MEM_WRAP_INT_CAUSE) {
-		v = t4_read_reg(adap, MA_INT_WRAP_STATUS);
+	if (status & MEM_WRAP_INT_CAUSE_F) {
+		v = t4_read_reg(adap, MA_INT_WRAP_STATUS_A);
 		dev_alert(adap->pdev_dev, "MA address wrap-around error by "
 			  "client %u to address %#x\n",
-			  MEM_WRAP_CLIENT_NUM_GET(v),
-			  MEM_WRAP_ADDRESS_GET(v) << 4);
+			  MEM_WRAP_CLIENT_NUM_G(v),
+			  MEM_WRAP_ADDRESS_G(v) << 4);
 	}
-	t4_write_reg(adap, MA_INT_CAUSE, status);
+	t4_write_reg(adap, MA_INT_CAUSE_A, status);
 	t4_fatal_err(adap);
 }
 
@@ -3007,7 +3013,7 @@ static int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force)
 	 * rather than a RESET ... if it's new enough to understand that ...
 	 */
 	if (ret == 0 || force) {
-		t4_set_reg_field(adap, CIM_BOOT_CFG, UPCRST, UPCRST);
+		t4_set_reg_field(adap, CIM_BOOT_CFG_A, UPCRST_F, UPCRST_F);
 		t4_set_reg_field(adap, PCIE_FW_A, PCIE_FW_HALT_F,
 				 PCIE_FW_HALT_F);
 	}
@@ -3058,7 +3064,7 @@ static int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
 		 * hitting the chip with a hammer.
 		 */
 		if (mbox <= PCIE_FW_MASTER_M) {
-			t4_set_reg_field(adap, CIM_BOOT_CFG, UPCRST, 0);
+			t4_set_reg_field(adap, CIM_BOOT_CFG_A, UPCRST_F, 0);
 			msleep(100);
 			if (t4_fw_reset(adap, mbox,
 					PIORST | PIORSTMODE) == 0)
@@ -3070,7 +3076,7 @@ static int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
 	} else {
 		int ms;
 
-		t4_set_reg_field(adap, CIM_BOOT_CFG, UPCRST, 0);
+		t4_set_reg_field(adap, CIM_BOOT_CFG_A, UPCRST_F, 0);
 		for (ms = 0; ms < FW_CMD_MAX_TIMEOUT; ) {
 			if (!(t4_read_reg(adap, PCIE_FW_A) & PCIE_FW_HALT_F))
 				return 0;
@@ -3973,7 +3979,7 @@ static int get_flash_params(struct adapter *adap)
 		return -EINVAL;
 	adap->params.sf_size = 1 << info;
 	adap->params.sf_fw_start =
-		t4_read_reg(adap, CIM_BOOT_CFG) & BOOTADDR_MASK;
+		t4_read_reg(adap, CIM_BOOT_CFG_A) & BOOTADDR_M;
 
 	if (adap->params.sf_size < FLASH_MIN_SIZE)
 		dev_warn(adap->pdev_dev, "WARNING!!! FLASH size %#x < %#x!!!\n",
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 9b73824..4b66818 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -788,41 +788,54 @@
 #define TDUE_V(x) ((x) << TDUE_S)
 #define TDUE_F    TDUE_V(1U)
 
-#define MC_INT_CAUSE 0x7518
-#define MC_P_INT_CAUSE 0x41318
-#define  ECC_UE_INT_CAUSE 0x00000004U
-#define  ECC_CE_INT_CAUSE 0x00000002U
-#define  PERR_INT_CAUSE   0x00000001U
-
-#define MC_ECC_STATUS 0x751c
-#define MC_P_ECC_STATUS 0x4131c
-#define  ECC_CECNT_MASK   0xffff0000U
-#define  ECC_CECNT_SHIFT  16
-#define  ECC_CECNT(x)     ((x) << ECC_CECNT_SHIFT)
-#define  ECC_CECNT_GET(x) (((x) & ECC_CECNT_MASK) >> ECC_CECNT_SHIFT)
-#define  ECC_UECNT_MASK   0x0000ffffU
-#define  ECC_UECNT_SHIFT  0
-#define  ECC_UECNT(x)     ((x) << ECC_UECNT_SHIFT)
-#define  ECC_UECNT_GET(x) (((x) & ECC_UECNT_MASK) >> ECC_UECNT_SHIFT)
-
-#define MC_BIST_CMD 0x7600
-#define  START_BIST          0x80000000U
-#define  BIST_CMD_GAP_MASK   0x0000ff00U
-#define  BIST_CMD_GAP_SHIFT  8
-#define  BIST_CMD_GAP(x)     ((x) << BIST_CMD_GAP_SHIFT)
-#define  BIST_OPCODE_MASK    0x00000003U
-#define  BIST_OPCODE_SHIFT   0
-#define  BIST_OPCODE(x)      ((x) << BIST_OPCODE_SHIFT)
-
-#define MC_BIST_CMD_ADDR 0x7604
-#define MC_BIST_CMD_LEN 0x7608
-#define MC_BIST_DATA_PATTERN 0x760c
-#define  BIST_DATA_TYPE_MASK   0x0000000fU
-#define  BIST_DATA_TYPE_SHIFT  0
-#define  BIST_DATA_TYPE(x)     ((x) << BIST_DATA_TYPE_SHIFT)
-
-#define MC_BIST_STATUS_RDATA 0x7688
+/* registers for module MC */
+#define MC_INT_CAUSE_A		0x7518
+#define MC_P_INT_CAUSE_A	0x41318
 
+#define ECC_UE_INT_CAUSE_S    2
+#define ECC_UE_INT_CAUSE_V(x) ((x) << ECC_UE_INT_CAUSE_S)
+#define ECC_UE_INT_CAUSE_F    ECC_UE_INT_CAUSE_V(1U)
+
+#define ECC_CE_INT_CAUSE_S    1
+#define ECC_CE_INT_CAUSE_V(x) ((x) << ECC_CE_INT_CAUSE_S)
+#define ECC_CE_INT_CAUSE_F    ECC_CE_INT_CAUSE_V(1U)
+
+#define PERR_INT_CAUSE_S    0
+#define PERR_INT_CAUSE_V(x) ((x) << PERR_INT_CAUSE_S)
+#define PERR_INT_CAUSE_F    PERR_INT_CAUSE_V(1U)
+
+#define MC_ECC_STATUS_A		0x751c
+#define MC_P_ECC_STATUS_A	0x4131c
+
+#define ECC_CECNT_S    16
+#define ECC_CECNT_M    0xffffU
+#define ECC_CECNT_V(x) ((x) << ECC_CECNT_S)
+#define ECC_CECNT_G(x) (((x) >> ECC_CECNT_S) & ECC_CECNT_M)
+
+#define ECC_UECNT_S    0
+#define ECC_UECNT_M    0xffffU
+#define ECC_UECNT_V(x) ((x) << ECC_UECNT_S)
+#define ECC_UECNT_G(x) (((x) >> ECC_UECNT_S) & ECC_UECNT_M)
+
+#define MC_BIST_CMD_A 0x7600
+
+#define START_BIST_S    31
+#define START_BIST_V(x) ((x) << START_BIST_S)
+#define START_BIST_F    START_BIST_V(1U)
+
+#define BIST_CMD_GAP_S    8
+#define BIST_CMD_GAP_V(x) ((x) << BIST_CMD_GAP_S)
+
+#define BIST_OPCODE_S    0
+#define BIST_OPCODE_V(x) ((x) << BIST_OPCODE_S)
+
+#define MC_BIST_CMD_ADDR_A 0x7604
+#define MC_BIST_CMD_LEN_A 0x7608
+#define MC_BIST_DATA_PATTERN_A 0x760c
+
+#define MC_BIST_STATUS_RDATA_A 0x7688
+
+/* registers for module MA */
 #define MA_EDRAM0_BAR_A 0x77c0
 
 #define EDRAM0_SIZE_S    0
@@ -880,109 +893,294 @@
 #define EXT_MEM0_ENABLE_V(x) ((x) << EXT_MEM0_ENABLE_S)
 #define EXT_MEM0_ENABLE_F    EXT_MEM0_ENABLE_V(1U)
 
-#define MA_INT_CAUSE 0x77e0
-#define  MEM_PERR_INT_CAUSE 0x00000002U
-#define  MEM_WRAP_INT_CAUSE 0x00000001U
-
-#define MA_INT_WRAP_STATUS 0x77e4
-#define  MEM_WRAP_ADDRESS_MASK   0xfffffff0U
-#define  MEM_WRAP_ADDRESS_SHIFT  4
-#define  MEM_WRAP_ADDRESS_GET(x) (((x) & MEM_WRAP_ADDRESS_MASK) >> MEM_WRAP_ADDRESS_SHIFT)
-#define  MEM_WRAP_CLIENT_NUM_MASK   0x0000000fU
-#define  MEM_WRAP_CLIENT_NUM_SHIFT  0
-#define  MEM_WRAP_CLIENT_NUM_GET(x) (((x) & MEM_WRAP_CLIENT_NUM_MASK) >> MEM_WRAP_CLIENT_NUM_SHIFT)
-#define MA_PARITY_ERROR_STATUS 0x77f4
-#define MA_PARITY_ERROR_STATUS2 0x7804
-
-#define EDC_0_BASE_ADDR 0x7900
-
-#define EDC_BIST_CMD 0x7904
-#define EDC_BIST_CMD_ADDR 0x7908
-#define EDC_BIST_CMD_LEN 0x790c
-#define EDC_BIST_DATA_PATTERN 0x7910
-#define EDC_BIST_STATUS_RDATA 0x7928
-#define EDC_INT_CAUSE 0x7978
-#define  ECC_UE_PAR     0x00000020U
-#define  ECC_CE_PAR     0x00000010U
-#define  PERR_PAR_CAUSE 0x00000008U
-
-#define EDC_ECC_STATUS 0x797c
-
-#define EDC_1_BASE_ADDR 0x7980
-
-#define CIM_BOOT_CFG 0x7b00
-#define  BOOTADDR_MASK 0xffffff00U
-#define  UPCRST        0x1U
-
-#define CIM_PF_MAILBOX_DATA 0x240
-#define CIM_PF_MAILBOX_CTRL 0x280
-#define  MBMSGVALID     0x00000008U
-#define  MBINTREQ       0x00000004U
-#define  MBOWNER_MASK   0x00000003U
-#define  MBOWNER_SHIFT  0
-#define  MBOWNER(x)     ((x) << MBOWNER_SHIFT)
-#define  MBOWNER_GET(x) (((x) & MBOWNER_MASK) >> MBOWNER_SHIFT)
-
-#define CIM_PF_HOST_INT_ENABLE 0x288
-#define  MBMSGRDYINTEN(x) ((x) << 19)
-
-#define CIM_PF_HOST_INT_CAUSE 0x28c
-#define  MBMSGRDYINT 0x00080000U
-
-#define CIM_HOST_INT_CAUSE 0x7b2c
-#define  TIEQOUTPARERRINT  0x00100000U
-#define  TIEQINPARERRINT   0x00080000U
-#define  MBHOSTPARERR      0x00040000U
-#define  MBUPPARERR        0x00020000U
-#define  IBQPARERR         0x0001f800U
-#define  IBQTP0PARERR      0x00010000U
-#define  IBQTP1PARERR      0x00008000U
-#define  IBQULPPARERR      0x00004000U
-#define  IBQSGELOPARERR    0x00002000U
-#define  IBQSGEHIPARERR    0x00001000U
-#define  IBQNCSIPARERR     0x00000800U
-#define  OBQPARERR         0x000007e0U
-#define  OBQULP0PARERR     0x00000400U
-#define  OBQULP1PARERR     0x00000200U
-#define  OBQULP2PARERR     0x00000100U
-#define  OBQULP3PARERR     0x00000080U
-#define  OBQSGEPARERR      0x00000040U
-#define  OBQNCSIPARERR     0x00000020U
-#define  PREFDROPINT       0x00000002U
-#define  UPACCNONZERO      0x00000001U
-
-#define CIM_HOST_UPACC_INT_CAUSE 0x7b34
-#define  EEPROMWRINT      0x40000000U
-#define  TIMEOUTMAINT     0x20000000U
-#define  TIMEOUTINT       0x10000000U
-#define  RSPOVRLOOKUPINT  0x08000000U
-#define  REQOVRLOOKUPINT  0x04000000U
-#define  BLKWRPLINT       0x02000000U
-#define  BLKRDPLINT       0x01000000U
-#define  SGLWRPLINT       0x00800000U
-#define  SGLRDPLINT       0x00400000U
-#define  BLKWRCTLINT      0x00200000U
-#define  BLKRDCTLINT      0x00100000U
-#define  SGLWRCTLINT      0x00080000U
-#define  SGLRDCTLINT      0x00040000U
-#define  BLKWREEPROMINT   0x00020000U
-#define  BLKRDEEPROMINT   0x00010000U
-#define  SGLWREEPROMINT   0x00008000U
-#define  SGLRDEEPROMINT   0x00004000U
-#define  BLKWRFLASHINT    0x00002000U
-#define  BLKRDFLASHINT    0x00001000U
-#define  SGLWRFLASHINT    0x00000800U
-#define  SGLRDFLASHINT    0x00000400U
-#define  BLKWRBOOTINT     0x00000200U
-#define  BLKRDBOOTINT     0x00000100U
-#define  SGLWRBOOTINT     0x00000080U
-#define  SGLRDBOOTINT     0x00000040U
-#define  ILLWRBEINT       0x00000020U
-#define  ILLRDBEINT       0x00000010U
-#define  ILLRDINT         0x00000008U
-#define  ILLWRINT         0x00000004U
-#define  ILLTRANSINT      0x00000002U
-#define  RSVDSPACEINT     0x00000001U
+#define MA_INT_CAUSE_A	0x77e0
+
+#define MEM_PERR_INT_CAUSE_S    1
+#define MEM_PERR_INT_CAUSE_V(x) ((x) << MEM_PERR_INT_CAUSE_S)
+#define MEM_PERR_INT_CAUSE_F    MEM_PERR_INT_CAUSE_V(1U)
+
+#define MEM_WRAP_INT_CAUSE_S    0
+#define MEM_WRAP_INT_CAUSE_V(x) ((x) << MEM_WRAP_INT_CAUSE_S)
+#define MEM_WRAP_INT_CAUSE_F    MEM_WRAP_INT_CAUSE_V(1U)
+
+#define MA_INT_WRAP_STATUS_A	0x77e4
+
+#define MEM_WRAP_ADDRESS_S    4
+#define MEM_WRAP_ADDRESS_M    0xfffffffU
+#define MEM_WRAP_ADDRESS_G(x) (((x) >> MEM_WRAP_ADDRESS_S) & MEM_WRAP_ADDRESS_M)
+
+#define MEM_WRAP_CLIENT_NUM_S    0
+#define MEM_WRAP_CLIENT_NUM_M    0xfU
+#define MEM_WRAP_CLIENT_NUM_G(x) \
+	(((x) >> MEM_WRAP_CLIENT_NUM_S) & MEM_WRAP_CLIENT_NUM_M)
+
+#define MA_PARITY_ERROR_STATUS_A	0x77f4
+#define MA_PARITY_ERROR_STATUS1_A	0x77f4
+#define MA_PARITY_ERROR_STATUS2_A	0x7804
+
+/* registers for module EDC_0 */
+#define EDC_0_BASE_ADDR		0x7900
+
+#define EDC_BIST_CMD_A		0x7904
+#define EDC_BIST_CMD_ADDR_A	0x7908
+#define EDC_BIST_CMD_LEN_A	0x790c
+#define EDC_BIST_DATA_PATTERN_A 0x7910
+#define EDC_BIST_STATUS_RDATA_A	0x7928
+#define EDC_INT_CAUSE_A		0x7978
+
+#define ECC_UE_PAR_S    5
+#define ECC_UE_PAR_V(x) ((x) << ECC_UE_PAR_S)
+#define ECC_UE_PAR_F    ECC_UE_PAR_V(1U)
+
+#define ECC_CE_PAR_S    4
+#define ECC_CE_PAR_V(x) ((x) << ECC_CE_PAR_S)
+#define ECC_CE_PAR_F    ECC_CE_PAR_V(1U)
+
+#define PERR_PAR_CAUSE_S    3
+#define PERR_PAR_CAUSE_V(x) ((x) << PERR_PAR_CAUSE_S)
+#define PERR_PAR_CAUSE_F    PERR_PAR_CAUSE_V(1U)
+
+#define EDC_ECC_STATUS_A	0x797c
+
+/* registers for module EDC_1 */
+#define EDC_1_BASE_ADDR	0x7980
+
+/* registers for module CIM */
+#define CIM_BOOT_CFG_A 0x7b00
+
+#define  BOOTADDR_M	0xffffff00U
+
+#define UPCRST_S    0
+#define UPCRST_V(x) ((x) << UPCRST_S)
+#define UPCRST_F    UPCRST_V(1U)
+
+#define CIM_PF_MAILBOX_DATA_A 0x240
+#define CIM_PF_MAILBOX_CTRL_A 0x280
+
+#define MBMSGVALID_S    3
+#define MBMSGVALID_V(x) ((x) << MBMSGVALID_S)
+#define MBMSGVALID_F    MBMSGVALID_V(1U)
+
+#define MBINTREQ_S    2
+#define MBINTREQ_V(x) ((x) << MBINTREQ_S)
+#define MBINTREQ_F    MBINTREQ_V(1U)
+
+#define MBOWNER_S    0
+#define MBOWNER_M    0x3U
+#define MBOWNER_V(x) ((x) << MBOWNER_S)
+#define MBOWNER_G(x) (((x) >> MBOWNER_S) & MBOWNER_M)
+
+#define CIM_PF_HOST_INT_ENABLE_A 0x288
+
+#define MBMSGRDYINTEN_S    19
+#define MBMSGRDYINTEN_V(x) ((x) << MBMSGRDYINTEN_S)
+#define MBMSGRDYINTEN_F    MBMSGRDYINTEN_V(1U)
+
+#define CIM_PF_HOST_INT_CAUSE_A 0x28c
+
+#define MBMSGRDYINT_S    19
+#define MBMSGRDYINT_V(x) ((x) << MBMSGRDYINT_S)
+#define MBMSGRDYINT_F    MBMSGRDYINT_V(1U)
+
+#define CIM_HOST_INT_CAUSE_A 0x7b2c
+
+#define TIEQOUTPARERRINT_S    20
+#define TIEQOUTPARERRINT_V(x) ((x) << TIEQOUTPARERRINT_S)
+#define TIEQOUTPARERRINT_F    TIEQOUTPARERRINT_V(1U)
+
+#define TIEQINPARERRINT_S    19
+#define TIEQINPARERRINT_V(x) ((x) << TIEQINPARERRINT_S)
+#define TIEQINPARERRINT_F    TIEQINPARERRINT_V(1U)
+
+#define PREFDROPINT_S    1
+#define PREFDROPINT_V(x) ((x) << PREFDROPINT_S)
+#define PREFDROPINT_F    PREFDROPINT_V(1U)
+
+#define UPACCNONZERO_S    0
+#define UPACCNONZERO_V(x) ((x) << UPACCNONZERO_S)
+#define UPACCNONZERO_F    UPACCNONZERO_V(1U)
+
+#define MBHOSTPARERR_S    18
+#define MBHOSTPARERR_V(x) ((x) << MBHOSTPARERR_S)
+#define MBHOSTPARERR_F    MBHOSTPARERR_V(1U)
+
+#define MBUPPARERR_S    17
+#define MBUPPARERR_V(x) ((x) << MBUPPARERR_S)
+#define MBUPPARERR_F    MBUPPARERR_V(1U)
+
+#define IBQTP0PARERR_S    16
+#define IBQTP0PARERR_V(x) ((x) << IBQTP0PARERR_S)
+#define IBQTP0PARERR_F    IBQTP0PARERR_V(1U)
+
+#define IBQTP1PARERR_S    15
+#define IBQTP1PARERR_V(x) ((x) << IBQTP1PARERR_S)
+#define IBQTP1PARERR_F    IBQTP1PARERR_V(1U)
+
+#define IBQULPPARERR_S    14
+#define IBQULPPARERR_V(x) ((x) << IBQULPPARERR_S)
+#define IBQULPPARERR_F    IBQULPPARERR_V(1U)
+
+#define IBQSGELOPARERR_S    13
+#define IBQSGELOPARERR_V(x) ((x) << IBQSGELOPARERR_S)
+#define IBQSGELOPARERR_F    IBQSGELOPARERR_V(1U)
+
+#define IBQSGEHIPARERR_S    12
+#define IBQSGEHIPARERR_V(x) ((x) << IBQSGEHIPARERR_S)
+#define IBQSGEHIPARERR_F    IBQSGEHIPARERR_V(1U)
+
+#define IBQNCSIPARERR_S    11
+#define IBQNCSIPARERR_V(x) ((x) << IBQNCSIPARERR_S)
+#define IBQNCSIPARERR_F    IBQNCSIPARERR_V(1U)
+
+#define OBQULP0PARERR_S    10
+#define OBQULP0PARERR_V(x) ((x) << OBQULP0PARERR_S)
+#define OBQULP0PARERR_F    OBQULP0PARERR_V(1U)
+
+#define OBQULP1PARERR_S    9
+#define OBQULP1PARERR_V(x) ((x) << OBQULP1PARERR_S)
+#define OBQULP1PARERR_F    OBQULP1PARERR_V(1U)
+
+#define OBQULP2PARERR_S    8
+#define OBQULP2PARERR_V(x) ((x) << OBQULP2PARERR_S)
+#define OBQULP2PARERR_F    OBQULP2PARERR_V(1U)
+
+#define OBQULP3PARERR_S    7
+#define OBQULP3PARERR_V(x) ((x) << OBQULP3PARERR_S)
+#define OBQULP3PARERR_F    OBQULP3PARERR_V(1U)
+
+#define OBQSGEPARERR_S    6
+#define OBQSGEPARERR_V(x) ((x) << OBQSGEPARERR_S)
+#define OBQSGEPARERR_F    OBQSGEPARERR_V(1U)
+
+#define OBQNCSIPARERR_S    5
+#define OBQNCSIPARERR_V(x) ((x) << OBQNCSIPARERR_S)
+#define OBQNCSIPARERR_F    OBQNCSIPARERR_V(1U)
+
+#define CIM_HOST_UPACC_INT_CAUSE_A 0x7b34
+
+#define EEPROMWRINT_S    30
+#define EEPROMWRINT_V(x) ((x) << EEPROMWRINT_S)
+#define EEPROMWRINT_F    EEPROMWRINT_V(1U)
+
+#define TIMEOUTMAINT_S    29
+#define TIMEOUTMAINT_V(x) ((x) << TIMEOUTMAINT_S)
+#define TIMEOUTMAINT_F    TIMEOUTMAINT_V(1U)
+
+#define TIMEOUTINT_S    28
+#define TIMEOUTINT_V(x) ((x) << TIMEOUTINT_S)
+#define TIMEOUTINT_F    TIMEOUTINT_V(1U)
+
+#define RSPOVRLOOKUPINT_S    27
+#define RSPOVRLOOKUPINT_V(x) ((x) << RSPOVRLOOKUPINT_S)
+#define RSPOVRLOOKUPINT_F    RSPOVRLOOKUPINT_V(1U)
+
+#define REQOVRLOOKUPINT_S    26
+#define REQOVRLOOKUPINT_V(x) ((x) << REQOVRLOOKUPINT_S)
+#define REQOVRLOOKUPINT_F    REQOVRLOOKUPINT_V(1U)
+
+#define BLKWRPLINT_S    25
+#define BLKWRPLINT_V(x) ((x) << BLKWRPLINT_S)
+#define BLKWRPLINT_F    BLKWRPLINT_V(1U)
+
+#define BLKRDPLINT_S    24
+#define BLKRDPLINT_V(x) ((x) << BLKRDPLINT_S)
+#define BLKRDPLINT_F    BLKRDPLINT_V(1U)
+
+#define SGLWRPLINT_S    23
+#define SGLWRPLINT_V(x) ((x) << SGLWRPLINT_S)
+#define SGLWRPLINT_F    SGLWRPLINT_V(1U)
+
+#define SGLRDPLINT_S    22
+#define SGLRDPLINT_V(x) ((x) << SGLRDPLINT_S)
+#define SGLRDPLINT_F    SGLRDPLINT_V(1U)
+
+#define BLKWRCTLINT_S    21
+#define BLKWRCTLINT_V(x) ((x) << BLKWRCTLINT_S)
+#define BLKWRCTLINT_F    BLKWRCTLINT_V(1U)
+
+#define BLKRDCTLINT_S    20
+#define BLKRDCTLINT_V(x) ((x) << BLKRDCTLINT_S)
+#define BLKRDCTLINT_F    BLKRDCTLINT_V(1U)
+
+#define SGLWRCTLINT_S    19
+#define SGLWRCTLINT_V(x) ((x) << SGLWRCTLINT_S)
+#define SGLWRCTLINT_F    SGLWRCTLINT_V(1U)
+
+#define SGLRDCTLINT_S    18
+#define SGLRDCTLINT_V(x) ((x) << SGLRDCTLINT_S)
+#define SGLRDCTLINT_F    SGLRDCTLINT_V(1U)
+
+#define BLKWREEPROMINT_S    17
+#define BLKWREEPROMINT_V(x) ((x) << BLKWREEPROMINT_S)
+#define BLKWREEPROMINT_F    BLKWREEPROMINT_V(1U)
+
+#define BLKRDEEPROMINT_S    16
+#define BLKRDEEPROMINT_V(x) ((x) << BLKRDEEPROMINT_S)
+#define BLKRDEEPROMINT_F    BLKRDEEPROMINT_V(1U)
+
+#define SGLWREEPROMINT_S    15
+#define SGLWREEPROMINT_V(x) ((x) << SGLWREEPROMINT_S)
+#define SGLWREEPROMINT_F    SGLWREEPROMINT_V(1U)
+
+#define SGLRDEEPROMINT_S    14
+#define SGLRDEEPROMINT_V(x) ((x) << SGLRDEEPROMINT_S)
+#define SGLRDEEPROMINT_F    SGLRDEEPROMINT_V(1U)
+
+#define BLKWRFLASHINT_S    13
+#define BLKWRFLASHINT_V(x) ((x) << BLKWRFLASHINT_S)
+#define BLKWRFLASHINT_F    BLKWRFLASHINT_V(1U)
+
+#define BLKRDFLASHINT_S    12
+#define BLKRDFLASHINT_V(x) ((x) << BLKRDFLASHINT_S)
+#define BLKRDFLASHINT_F    BLKRDFLASHINT_V(1U)
+
+#define SGLWRFLASHINT_S    11
+#define SGLWRFLASHINT_V(x) ((x) << SGLWRFLASHINT_S)
+#define SGLWRFLASHINT_F    SGLWRFLASHINT_V(1U)
+
+#define SGLRDFLASHINT_S    10
+#define SGLRDFLASHINT_V(x) ((x) << SGLRDFLASHINT_S)
+#define SGLRDFLASHINT_F    SGLRDFLASHINT_V(1U)
+
+#define BLKWRBOOTINT_S    9
+#define BLKWRBOOTINT_V(x) ((x) << BLKWRBOOTINT_S)
+#define BLKWRBOOTINT_F    BLKWRBOOTINT_V(1U)
+
+#define BLKRDBOOTINT_S    8
+#define BLKRDBOOTINT_V(x) ((x) << BLKRDBOOTINT_S)
+#define BLKRDBOOTINT_F    BLKRDBOOTINT_V(1U)
+
+#define SGLWRBOOTINT_S    7
+#define SGLWRBOOTINT_V(x) ((x) << SGLWRBOOTINT_S)
+#define SGLWRBOOTINT_F    SGLWRBOOTINT_V(1U)
+
+#define SGLRDBOOTINT_S    6
+#define SGLRDBOOTINT_V(x) ((x) << SGLRDBOOTINT_S)
+#define SGLRDBOOTINT_F    SGLRDBOOTINT_V(1U)
+
+#define ILLWRBEINT_S    5
+#define ILLWRBEINT_V(x) ((x) << ILLWRBEINT_S)
+#define ILLWRBEINT_F    ILLWRBEINT_V(1U)
+
+#define ILLRDBEINT_S    4
+#define ILLRDBEINT_V(x) ((x) << ILLRDBEINT_S)
+#define ILLRDBEINT_F    ILLRDBEINT_V(1U)
+
+#define ILLRDINT_S    3
+#define ILLRDINT_V(x) ((x) << ILLRDINT_S)
+#define ILLRDINT_F    ILLRDINT_V(1U)
+
+#define ILLWRINT_S    2
+#define ILLWRINT_V(x) ((x) << ILLWRINT_S)
+#define ILLWRINT_F    ILLWRINT_V(1U)
+
+#define ILLTRANSINT_S    1
+#define ILLTRANSINT_V(x) ((x) << ILLTRANSINT_S)
+#define ILLTRANSINT_F    ILLTRANSINT_V(1U)
+
+#define RSVDSPACEINT_S    0
+#define RSVDSPACEINT_V(x) ((x) << RSVDSPACEINT_S)
+#define RSVDSPACEINT_F    RSVDSPACEINT_V(1U)
 
 #define TP_OUT_CONFIG 0x7d04
 #define  VLANEXTENABLE_MASK  0x0000f000U
@@ -1634,19 +1832,22 @@
 #define MC_STRIDE (MC_1_BASE_ADDR - MC_0_BASE_ADDR)
 #define MC_REG(reg, idx) (reg + MC_STRIDE * idx)
 
-#define MC_P_BIST_CMD 0x41400
-#define MC_P_BIST_CMD_ADDR 0x41404
-#define MC_P_BIST_CMD_LEN 0x41408
-#define MC_P_BIST_DATA_PATTERN 0x4140c
-#define MC_P_BIST_STATUS_RDATA 0x41488
-#define EDC_T50_BASE_ADDR 0x50000
-#define EDC_H_BIST_CMD 0x50004
-#define EDC_H_BIST_CMD_ADDR 0x50008
-#define EDC_H_BIST_CMD_LEN 0x5000c
-#define EDC_H_BIST_DATA_PATTERN 0x50010
-#define EDC_H_BIST_STATUS_RDATA 0x50028
-
-#define EDC_T51_BASE_ADDR 0x50800
+#define MC_P_BIST_CMD_A			0x41400
+#define MC_P_BIST_CMD_ADDR_A		0x41404
+#define MC_P_BIST_CMD_LEN_A		0x41408
+#define MC_P_BIST_DATA_PATTERN_A	0x4140c
+#define MC_P_BIST_STATUS_RDATA_A	0x41488
+
+#define EDC_T50_BASE_ADDR		0x50000
+
+#define EDC_H_BIST_CMD_A		0x50004
+#define EDC_H_BIST_CMD_ADDR_A		0x50008
+#define EDC_H_BIST_CMD_LEN_A		0x5000c
+#define EDC_H_BIST_DATA_PATTERN_A	0x50010
+#define EDC_H_BIST_STATUS_RDATA_A	0x50028
+
+#define EDC_T51_BASE_ADDR		0x50800
+
 #define EDC_STRIDE_T5 (EDC_T51_BASE_ADDR - EDC_T50_BASE_ADDR)
 #define EDC_REG_T5(reg, idx) (reg + EDC_STRIDE_T5 * idx)
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h
index c7b127d..b516b12 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h
@@ -64,8 +64,8 @@
  * Mailbox Data in the fixed CIM PF map and the programmable VF map must
  * match.  However, it's a useful convention ...
  */
-#if T4VF_MBDATA_BASE_ADDR != CIM_PF_MAILBOX_DATA
-#error T4VF_MBDATA_BASE_ADDR must match CIM_PF_MAILBOX_DATA!
+#if T4VF_MBDATA_BASE_ADDR != CIM_PF_MAILBOX_DATA_A
+#error T4VF_MBDATA_BASE_ADDR must match CIM_PF_MAILBOX_DATA_A!
 #endif
 
 /*
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index fa60f71..5e83c18 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -138,9 +138,9 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	 * Loop trying to get ownership of the mailbox.  Return an error
 	 * if we can't gain ownership.
 	 */
-	v = MBOWNER_GET(t4_read_reg(adapter, mbox_ctl));
+	v = MBOWNER_G(t4_read_reg(adapter, mbox_ctl));
 	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
-		v = MBOWNER_GET(t4_read_reg(adapter, mbox_ctl));
+		v = MBOWNER_G(t4_read_reg(adapter, mbox_ctl));
 	if (v != MBOX_OWNER_DRV)
 		return v == MBOX_OWNER_FW ? -EBUSY : -ETIMEDOUT;
 
@@ -162,7 +162,7 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	t4_read_reg(adapter, mbox_data);         /* flush write */
 
 	t4_write_reg(adapter, mbox_ctl,
-		     MBMSGVALID | MBOWNER(MBOX_OWNER_FW));
+		     MBMSGVALID_F | MBOWNER_V(MBOX_OWNER_FW));
 	t4_read_reg(adapter, mbox_ctl);          /* flush write */
 
 	/*
@@ -184,14 +184,14 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 		 * If we're the owner, see if this is the reply we wanted.
 		 */
 		v = t4_read_reg(adapter, mbox_ctl);
-		if (MBOWNER_GET(v) == MBOX_OWNER_DRV) {
+		if (MBOWNER_G(v) == MBOX_OWNER_DRV) {
 			/*
 			 * If the Message Valid bit isn't on, revoke ownership
 			 * of the mailbox and continue waiting for our reply.
 			 */
-			if ((v & MBMSGVALID) == 0) {
+			if ((v & MBMSGVALID_F) == 0) {
 				t4_write_reg(adapter, mbox_ctl,
-					     MBOWNER(MBOX_OWNER_NONE));
+					     MBOWNER_V(MBOX_OWNER_NONE));
 				continue;
 			}
 
@@ -217,7 +217,7 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 					 & FW_CMD_REQUEST_F) != 0);
 			}
 			t4_write_reg(adapter, mbox_ctl,
-				     MBOWNER(MBOX_OWNER_NONE));
+				     MBOWNER_V(MBOX_OWNER_NONE));
 			return -FW_CMD_RETVAL_G(v);
 		}
 	}
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 04ec586..257dc8d 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -1193,7 +1193,7 @@ csio_hw_fw_halt(struct csio_hw *hw, uint32_t mbox, int32_t force)
 	 * rather than a RESET ... if it's new enough to understand that ...
 	 */
 	if (retval == 0 || force) {
-		csio_set_reg_field(hw, CIM_BOOT_CFG, UPCRST, UPCRST);
+		csio_set_reg_field(hw, CIM_BOOT_CFG_A, UPCRST_F, UPCRST_F);
 		csio_set_reg_field(hw, PCIE_FW_A, PCIE_FW_HALT_F,
 				   PCIE_FW_HALT_F);
 	}
@@ -1245,7 +1245,7 @@ csio_hw_fw_restart(struct csio_hw *hw, uint32_t mbox, int32_t reset)
 		 * hitting the chip with a hammer.
 		 */
 		if (mbox <= PCIE_FW_MASTER_M) {
-			csio_set_reg_field(hw, CIM_BOOT_CFG, UPCRST, 0);
+			csio_set_reg_field(hw, CIM_BOOT_CFG_A, UPCRST_F, 0);
 			msleep(100);
 			if (csio_do_reset(hw, true) == 0)
 				return 0;
@@ -1256,7 +1256,7 @@ csio_hw_fw_restart(struct csio_hw *hw, uint32_t mbox, int32_t reset)
 	} else {
 		int ms;
 
-		csio_set_reg_field(hw, CIM_BOOT_CFG, UPCRST, 0);
+		csio_set_reg_field(hw, CIM_BOOT_CFG_A, UPCRST_F, 0);
 		for (ms = 0; ms < FW_CMD_MAX_TIMEOUT; ) {
 			if (!(csio_rd_reg32(hw, PCIE_FW_A) & PCIE_FW_HALT_F))
 				return 0;
@@ -2741,10 +2741,10 @@ static void csio_sge_intr_handler(struct csio_hw *hw)
 		csio_hw_fatal_err(hw);
 }
 
-#define CIM_OBQ_INTR (OBQULP0PARERR | OBQULP1PARERR | OBQULP2PARERR |\
-		      OBQULP3PARERR | OBQSGEPARERR | OBQNCSIPARERR)
-#define CIM_IBQ_INTR (IBQTP0PARERR | IBQTP1PARERR | IBQULPPARERR |\
-		      IBQSGEHIPARERR | IBQSGELOPARERR | IBQNCSIPARERR)
+#define CIM_OBQ_INTR (OBQULP0PARERR_F | OBQULP1PARERR_F | OBQULP2PARERR_F |\
+		      OBQULP3PARERR_F | OBQSGEPARERR_F | OBQNCSIPARERR_F)
+#define CIM_IBQ_INTR (IBQTP0PARERR_F | IBQTP1PARERR_F | IBQULPPARERR_F |\
+		      IBQSGEHIPARERR_F | IBQSGELOPARERR_F | IBQNCSIPARERR_F)
 
 /*
  * CIM interrupt handler.
@@ -2752,53 +2752,53 @@ static void csio_sge_intr_handler(struct csio_hw *hw)
 static void csio_cim_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info cim_intr_info[] = {
-		{ PREFDROPINT, "CIM control register prefetch drop", -1, 1 },
+		{ PREFDROPINT_F, "CIM control register prefetch drop", -1, 1 },
 		{ CIM_OBQ_INTR, "CIM OBQ parity error", -1, 1 },
 		{ CIM_IBQ_INTR, "CIM IBQ parity error", -1, 1 },
-		{ MBUPPARERR, "CIM mailbox uP parity error", -1, 1 },
-		{ MBHOSTPARERR, "CIM mailbox host parity error", -1, 1 },
-		{ TIEQINPARERRINT, "CIM TIEQ outgoing parity error", -1, 1 },
-		{ TIEQOUTPARERRINT, "CIM TIEQ incoming parity error", -1, 1 },
+		{ MBUPPARERR_F, "CIM mailbox uP parity error", -1, 1 },
+		{ MBHOSTPARERR_F, "CIM mailbox host parity error", -1, 1 },
+		{ TIEQINPARERRINT_F, "CIM TIEQ outgoing parity error", -1, 1 },
+		{ TIEQOUTPARERRINT_F, "CIM TIEQ incoming parity error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 	static struct intr_info cim_upintr_info[] = {
-		{ RSVDSPACEINT, "CIM reserved space access", -1, 1 },
-		{ ILLTRANSINT, "CIM illegal transaction", -1, 1 },
-		{ ILLWRINT, "CIM illegal write", -1, 1 },
-		{ ILLRDINT, "CIM illegal read", -1, 1 },
-		{ ILLRDBEINT, "CIM illegal read BE", -1, 1 },
-		{ ILLWRBEINT, "CIM illegal write BE", -1, 1 },
-		{ SGLRDBOOTINT, "CIM single read from boot space", -1, 1 },
-		{ SGLWRBOOTINT, "CIM single write to boot space", -1, 1 },
-		{ BLKWRBOOTINT, "CIM block write to boot space", -1, 1 },
-		{ SGLRDFLASHINT, "CIM single read from flash space", -1, 1 },
-		{ SGLWRFLASHINT, "CIM single write to flash space", -1, 1 },
-		{ BLKWRFLASHINT, "CIM block write to flash space", -1, 1 },
-		{ SGLRDEEPROMINT, "CIM single EEPROM read", -1, 1 },
-		{ SGLWREEPROMINT, "CIM single EEPROM write", -1, 1 },
-		{ BLKRDEEPROMINT, "CIM block EEPROM read", -1, 1 },
-		{ BLKWREEPROMINT, "CIM block EEPROM write", -1, 1 },
-		{ SGLRDCTLINT , "CIM single read from CTL space", -1, 1 },
-		{ SGLWRCTLINT , "CIM single write to CTL space", -1, 1 },
-		{ BLKRDCTLINT , "CIM block read from CTL space", -1, 1 },
-		{ BLKWRCTLINT , "CIM block write to CTL space", -1, 1 },
-		{ SGLRDPLINT , "CIM single read from PL space", -1, 1 },
-		{ SGLWRPLINT , "CIM single write to PL space", -1, 1 },
-		{ BLKRDPLINT , "CIM block read from PL space", -1, 1 },
-		{ BLKWRPLINT , "CIM block write to PL space", -1, 1 },
-		{ REQOVRLOOKUPINT , "CIM request FIFO overwrite", -1, 1 },
-		{ RSPOVRLOOKUPINT , "CIM response FIFO overwrite", -1, 1 },
-		{ TIMEOUTINT , "CIM PIF timeout", -1, 1 },
-		{ TIMEOUTMAINT , "CIM PIF MA timeout", -1, 1 },
+		{ RSVDSPACEINT_F, "CIM reserved space access", -1, 1 },
+		{ ILLTRANSINT_F, "CIM illegal transaction", -1, 1 },
+		{ ILLWRINT_F, "CIM illegal write", -1, 1 },
+		{ ILLRDINT_F, "CIM illegal read", -1, 1 },
+		{ ILLRDBEINT_F, "CIM illegal read BE", -1, 1 },
+		{ ILLWRBEINT_F, "CIM illegal write BE", -1, 1 },
+		{ SGLRDBOOTINT_F, "CIM single read from boot space", -1, 1 },
+		{ SGLWRBOOTINT_F, "CIM single write to boot space", -1, 1 },
+		{ BLKWRBOOTINT_F, "CIM block write to boot space", -1, 1 },
+		{ SGLRDFLASHINT_F, "CIM single read from flash space", -1, 1 },
+		{ SGLWRFLASHINT_F, "CIM single write to flash space", -1, 1 },
+		{ BLKWRFLASHINT_F, "CIM block write to flash space", -1, 1 },
+		{ SGLRDEEPROMINT_F, "CIM single EEPROM read", -1, 1 },
+		{ SGLWREEPROMINT_F, "CIM single EEPROM write", -1, 1 },
+		{ BLKRDEEPROMINT_F, "CIM block EEPROM read", -1, 1 },
+		{ BLKWREEPROMINT_F, "CIM block EEPROM write", -1, 1 },
+		{ SGLRDCTLINT_F, "CIM single read from CTL space", -1, 1 },
+		{ SGLWRCTLINT_F, "CIM single write to CTL space", -1, 1 },
+		{ BLKRDCTLINT_F, "CIM block read from CTL space", -1, 1 },
+		{ BLKWRCTLINT_F, "CIM block write to CTL space", -1, 1 },
+		{ SGLRDPLINT_F, "CIM single read from PL space", -1, 1 },
+		{ SGLWRPLINT_F, "CIM single write to PL space", -1, 1 },
+		{ BLKRDPLINT_F, "CIM block read from PL space", -1, 1 },
+		{ BLKWRPLINT_F, "CIM block write to PL space", -1, 1 },
+		{ REQOVRLOOKUPINT_F, "CIM request FIFO overwrite", -1, 1 },
+		{ RSPOVRLOOKUPINT_F, "CIM response FIFO overwrite", -1, 1 },
+		{ TIMEOUTINT_F, "CIM PIF timeout", -1, 1 },
+		{ TIMEOUTMAINT_F, "CIM PIF MA timeout", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
 	int fat;
 
-	fat = csio_handle_intr_status(hw, CIM_HOST_INT_CAUSE,
-				    cim_intr_info) +
-	      csio_handle_intr_status(hw, CIM_HOST_UPACC_INT_CAUSE,
-				    cim_upintr_info);
+	fat = csio_handle_intr_status(hw, CIM_HOST_INT_CAUSE_A,
+				      cim_intr_info) +
+	      csio_handle_intr_status(hw, CIM_HOST_UPACC_INT_CAUSE_A,
+				      cim_upintr_info);
 	if (fat)
 		csio_hw_fatal_err(hw);
 }
@@ -2987,7 +2987,8 @@ static void csio_mps_intr_handler(struct csio_hw *hw)
 		csio_hw_fatal_err(hw);
 }
 
-#define MEM_INT_MASK (PERR_INT_CAUSE | ECC_CE_INT_CAUSE | ECC_UE_INT_CAUSE)
+#define MEM_INT_MASK (PERR_INT_CAUSE_F | ECC_CE_INT_CAUSE_F | \
+		      ECC_UE_INT_CAUSE_F)
 
 /*
  * EDC/MC interrupt handler.
@@ -2999,28 +3000,28 @@ static void csio_mem_intr_handler(struct csio_hw *hw, int idx)
 	unsigned int addr, cnt_addr, v;
 
 	if (idx <= MEM_EDC1) {
-		addr = EDC_REG(EDC_INT_CAUSE, idx);
-		cnt_addr = EDC_REG(EDC_ECC_STATUS, idx);
+		addr = EDC_REG(EDC_INT_CAUSE_A, idx);
+		cnt_addr = EDC_REG(EDC_ECC_STATUS_A, idx);
 	} else {
-		addr = MC_INT_CAUSE;
-		cnt_addr = MC_ECC_STATUS;
+		addr = MC_INT_CAUSE_A;
+		cnt_addr = MC_ECC_STATUS_A;
 	}
 
 	v = csio_rd_reg32(hw, addr) & MEM_INT_MASK;
-	if (v & PERR_INT_CAUSE)
+	if (v & PERR_INT_CAUSE_F)
 		csio_fatal(hw, "%s FIFO parity error\n", name[idx]);
-	if (v & ECC_CE_INT_CAUSE) {
-		uint32_t cnt = ECC_CECNT_GET(csio_rd_reg32(hw, cnt_addr));
+	if (v & ECC_CE_INT_CAUSE_F) {
+		uint32_t cnt = ECC_CECNT_G(csio_rd_reg32(hw, cnt_addr));
 
-		csio_wr_reg32(hw, ECC_CECNT_MASK, cnt_addr);
+		csio_wr_reg32(hw, ECC_CECNT_V(ECC_CECNT_M), cnt_addr);
 		csio_warn(hw, "%u %s correctable ECC data error%s\n",
 			    cnt, name[idx], cnt > 1 ? "s" : "");
 	}
-	if (v & ECC_UE_INT_CAUSE)
+	if (v & ECC_UE_INT_CAUSE_F)
 		csio_fatal(hw, "%s uncorrectable ECC data error\n", name[idx]);
 
 	csio_wr_reg32(hw, v, addr);
-	if (v & (PERR_INT_CAUSE | ECC_UE_INT_CAUSE))
+	if (v & (PERR_INT_CAUSE_F | ECC_UE_INT_CAUSE_F))
 		csio_hw_fatal_err(hw);
 }
 
@@ -3029,18 +3030,18 @@ static void csio_mem_intr_handler(struct csio_hw *hw, int idx)
  */
 static void csio_ma_intr_handler(struct csio_hw *hw)
 {
-	uint32_t v, status = csio_rd_reg32(hw, MA_INT_CAUSE);
+	uint32_t v, status = csio_rd_reg32(hw, MA_INT_CAUSE_A);
 
-	if (status & MEM_PERR_INT_CAUSE)
+	if (status & MEM_PERR_INT_CAUSE_F)
 		csio_fatal(hw, "MA parity error, parity status %#x\n",
-			    csio_rd_reg32(hw, MA_PARITY_ERROR_STATUS));
-	if (status & MEM_WRAP_INT_CAUSE) {
-		v = csio_rd_reg32(hw, MA_INT_WRAP_STATUS);
+			    csio_rd_reg32(hw, MA_PARITY_ERROR_STATUS_A));
+	if (status & MEM_WRAP_INT_CAUSE_F) {
+		v = csio_rd_reg32(hw, MA_INT_WRAP_STATUS_A);
 		csio_fatal(hw,
 		   "MA address wrap-around error by client %u to address %#x\n",
-		   MEM_WRAP_CLIENT_NUM_GET(v), MEM_WRAP_ADDRESS_GET(v) << 4);
+		   MEM_WRAP_CLIENT_NUM_G(v), MEM_WRAP_ADDRESS_G(v) << 4);
 	}
-	csio_wr_reg32(hw, status, MA_INT_CAUSE);
+	csio_wr_reg32(hw, status, MA_INT_CAUSE_A);
 	csio_hw_fatal_err(hw);
 }
 
diff --git a/drivers/scsi/csiostor/csio_hw_t4.c b/drivers/scsi/csiostor/csio_hw_t4.c
index d0dac67..14884e4 100644
--- a/drivers/scsi/csiostor/csio_hw_t4.c
+++ b/drivers/scsi/csiostor/csio_hw_t4.c
@@ -209,19 +209,19 @@ csio_t4_mc_read(struct csio_hw *hw, int idx, uint32_t addr, __be32 *data,
 {
 	int i;
 
-	if (csio_rd_reg32(hw, MC_BIST_CMD) & START_BIST)
+	if (csio_rd_reg32(hw, MC_BIST_CMD_A) & START_BIST_F)
 		return -EBUSY;
-	csio_wr_reg32(hw, addr & ~0x3fU, MC_BIST_CMD_ADDR);
-	csio_wr_reg32(hw, 64, MC_BIST_CMD_LEN);
-	csio_wr_reg32(hw, 0xc, MC_BIST_DATA_PATTERN);
-	csio_wr_reg32(hw, BIST_OPCODE(1) | START_BIST | BIST_CMD_GAP(1),
-		      MC_BIST_CMD);
-	i = csio_hw_wait_op_done_val(hw, MC_BIST_CMD, START_BIST,
+	csio_wr_reg32(hw, addr & ~0x3fU, MC_BIST_CMD_ADDR_A);
+	csio_wr_reg32(hw, 64, MC_BIST_CMD_LEN_A);
+	csio_wr_reg32(hw, 0xc, MC_BIST_DATA_PATTERN_A);
+	csio_wr_reg32(hw, BIST_OPCODE_V(1) | START_BIST_F | BIST_CMD_GAP_V(1),
+		      MC_BIST_CMD_A);
+	i = csio_hw_wait_op_done_val(hw, MC_BIST_CMD_A, START_BIST_F,
 				     0, 10, 1, NULL);
 	if (i)
 		return i;
 
-#define MC_DATA(i) MC_BIST_STATUS_REG(MC_BIST_STATUS_RDATA, i)
+#define MC_DATA(i) MC_BIST_STATUS_REG(MC_BIST_STATUS_RDATA_A, i)
 
 	for (i = 15; i >= 0; i--)
 		*data++ = htonl(csio_rd_reg32(hw, MC_DATA(i)));
@@ -250,19 +250,19 @@ csio_t4_edc_read(struct csio_hw *hw, int idx, uint32_t addr, __be32 *data,
 	int i;
 
 	idx *= EDC_STRIDE;
-	if (csio_rd_reg32(hw, EDC_BIST_CMD + idx) & START_BIST)
+	if (csio_rd_reg32(hw, EDC_BIST_CMD_A + idx) & START_BIST_F)
 		return -EBUSY;
-	csio_wr_reg32(hw, addr & ~0x3fU, EDC_BIST_CMD_ADDR + idx);
-	csio_wr_reg32(hw, 64, EDC_BIST_CMD_LEN + idx);
-	csio_wr_reg32(hw, 0xc, EDC_BIST_DATA_PATTERN + idx);
-	csio_wr_reg32(hw, BIST_OPCODE(1) | BIST_CMD_GAP(1) | START_BIST,
-		      EDC_BIST_CMD + idx);
-	i = csio_hw_wait_op_done_val(hw, EDC_BIST_CMD + idx, START_BIST,
+	csio_wr_reg32(hw, addr & ~0x3fU, EDC_BIST_CMD_ADDR_A + idx);
+	csio_wr_reg32(hw, 64, EDC_BIST_CMD_LEN_A + idx);
+	csio_wr_reg32(hw, 0xc, EDC_BIST_DATA_PATTERN_A + idx);
+	csio_wr_reg32(hw, BIST_OPCODE_V(1) | BIST_CMD_GAP_V(1) | START_BIST_F,
+		      EDC_BIST_CMD_A + idx);
+	i = csio_hw_wait_op_done_val(hw, EDC_BIST_CMD_A + idx, START_BIST_F,
 				     0, 10, 1, NULL);
 	if (i)
 		return i;
 
-#define EDC_DATA(i) (EDC_BIST_STATUS_REG(EDC_BIST_STATUS_RDATA, i) + idx)
+#define EDC_DATA(i) (EDC_BIST_STATUS_REG(EDC_BIST_STATUS_RDATA_A, i) + idx)
 
 	for (i = 15; i >= 0; i--)
 		*data++ = htonl(csio_rd_reg32(hw, EDC_DATA(i)));
diff --git a/drivers/scsi/csiostor/csio_hw_t5.c b/drivers/scsi/csiostor/csio_hw_t5.c
index 99a7dca..3267f4f 100644
--- a/drivers/scsi/csiostor/csio_hw_t5.c
+++ b/drivers/scsi/csiostor/csio_hw_t5.c
@@ -177,25 +177,25 @@ csio_t5_mc_read(struct csio_hw *hw, int idx, uint32_t addr, __be32 *data,
 	uint32_t mc_bist_cmd_reg, mc_bist_cmd_addr_reg, mc_bist_cmd_len_reg;
 	uint32_t mc_bist_status_rdata_reg, mc_bist_data_pattern_reg;
 
-	mc_bist_cmd_reg = MC_REG(MC_P_BIST_CMD, idx);
-	mc_bist_cmd_addr_reg = MC_REG(MC_P_BIST_CMD_ADDR, idx);
-	mc_bist_cmd_len_reg = MC_REG(MC_P_BIST_CMD_LEN, idx);
-	mc_bist_status_rdata_reg = MC_REG(MC_P_BIST_STATUS_RDATA, idx);
-	mc_bist_data_pattern_reg = MC_REG(MC_P_BIST_DATA_PATTERN, idx);
+	mc_bist_cmd_reg = MC_REG(MC_P_BIST_CMD_A, idx);
+	mc_bist_cmd_addr_reg = MC_REG(MC_P_BIST_CMD_ADDR_A, idx);
+	mc_bist_cmd_len_reg = MC_REG(MC_P_BIST_CMD_LEN_A, idx);
+	mc_bist_status_rdata_reg = MC_REG(MC_P_BIST_STATUS_RDATA_A, idx);
+	mc_bist_data_pattern_reg = MC_REG(MC_P_BIST_DATA_PATTERN_A, idx);
 
-	if (csio_rd_reg32(hw, mc_bist_cmd_reg) & START_BIST)
+	if (csio_rd_reg32(hw, mc_bist_cmd_reg) & START_BIST_F)
 		return -EBUSY;
 	csio_wr_reg32(hw, addr & ~0x3fU, mc_bist_cmd_addr_reg);
 	csio_wr_reg32(hw, 64, mc_bist_cmd_len_reg);
 	csio_wr_reg32(hw, 0xc, mc_bist_data_pattern_reg);
-	csio_wr_reg32(hw, BIST_OPCODE(1) | START_BIST |  BIST_CMD_GAP(1),
+	csio_wr_reg32(hw, BIST_OPCODE_V(1) | START_BIST_F |  BIST_CMD_GAP_V(1),
 		      mc_bist_cmd_reg);
-	i = csio_hw_wait_op_done_val(hw, mc_bist_cmd_reg, START_BIST,
+	i = csio_hw_wait_op_done_val(hw, mc_bist_cmd_reg, START_BIST_F,
 				     0, 10, 1, NULL);
 	if (i)
 		return i;
 
-#define MC_DATA(i) MC_BIST_STATUS_REG(MC_BIST_STATUS_RDATA, i)
+#define MC_DATA(i) MC_BIST_STATUS_REG(MC_BIST_STATUS_RDATA_A, i)
 
 	for (i = 15; i >= 0; i--)
 		*data++ = htonl(csio_rd_reg32(hw, MC_DATA(i)));
@@ -231,27 +231,27 @@ csio_t5_edc_read(struct csio_hw *hw, int idx, uint32_t addr, __be32 *data,
 #define EDC_STRIDE_T5 (EDC_T51_BASE_ADDR - EDC_T50_BASE_ADDR)
 #define EDC_REG_T5(reg, idx) (reg + EDC_STRIDE_T5 * idx)
 
-	edc_bist_cmd_reg = EDC_REG_T5(EDC_H_BIST_CMD, idx);
-	edc_bist_cmd_addr_reg = EDC_REG_T5(EDC_H_BIST_CMD_ADDR, idx);
-	edc_bist_cmd_len_reg = EDC_REG_T5(EDC_H_BIST_CMD_LEN, idx);
-	edc_bist_cmd_data_pattern = EDC_REG_T5(EDC_H_BIST_DATA_PATTERN, idx);
-	edc_bist_status_rdata_reg = EDC_REG_T5(EDC_H_BIST_STATUS_RDATA, idx);
+	edc_bist_cmd_reg = EDC_REG_T5(EDC_H_BIST_CMD_A, idx);
+	edc_bist_cmd_addr_reg = EDC_REG_T5(EDC_H_BIST_CMD_ADDR_A, idx);
+	edc_bist_cmd_len_reg = EDC_REG_T5(EDC_H_BIST_CMD_LEN_A, idx);
+	edc_bist_cmd_data_pattern = EDC_REG_T5(EDC_H_BIST_DATA_PATTERN_A, idx);
+	edc_bist_status_rdata_reg = EDC_REG_T5(EDC_H_BIST_STATUS_RDATA_A, idx);
 #undef EDC_REG_T5
 #undef EDC_STRIDE_T5
 
-	if (csio_rd_reg32(hw, edc_bist_cmd_reg) & START_BIST)
+	if (csio_rd_reg32(hw, edc_bist_cmd_reg) & START_BIST_F)
 		return -EBUSY;
 	csio_wr_reg32(hw, addr & ~0x3fU, edc_bist_cmd_addr_reg);
 	csio_wr_reg32(hw, 64, edc_bist_cmd_len_reg);
 	csio_wr_reg32(hw, 0xc, edc_bist_cmd_data_pattern);
-	csio_wr_reg32(hw, BIST_OPCODE(1) | START_BIST |  BIST_CMD_GAP(1),
+	csio_wr_reg32(hw, BIST_OPCODE_V(1) | START_BIST_F |  BIST_CMD_GAP_V(1),
 		      edc_bist_cmd_reg);
-	i = csio_hw_wait_op_done_val(hw, edc_bist_cmd_reg, START_BIST,
+	i = csio_hw_wait_op_done_val(hw, edc_bist_cmd_reg, START_BIST_F,
 				     0, 10, 1, NULL);
 	if (i)
 		return i;
 
-#define EDC_DATA(i) (EDC_BIST_STATUS_REG(EDC_BIST_STATUS_RDATA, i) + idx)
+#define EDC_DATA(i) (EDC_BIST_STATUS_REG(EDC_BIST_STATUS_RDATA_A, i) + idx)
 
 	for (i = 15; i >= 0; i--)
 		*data++ = htonl(csio_rd_reg32(hw, EDC_DATA(i)));
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index 08c265c..cb53985 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -1104,8 +1104,8 @@ csio_mb_process_portparams_rsp(struct csio_hw *hw,
 void
 csio_mb_intr_enable(struct csio_hw *hw)
 {
-	csio_wr_reg32(hw, MBMSGRDYINTEN(1), MYPF_REG(CIM_PF_HOST_INT_ENABLE));
-	csio_rd_reg32(hw, MYPF_REG(CIM_PF_HOST_INT_ENABLE));
+	csio_wr_reg32(hw, MBMSGRDYINTEN_F, MYPF_REG(CIM_PF_HOST_INT_ENABLE_A));
+	csio_rd_reg32(hw, MYPF_REG(CIM_PF_HOST_INT_ENABLE_A));
 }
 
 /*
@@ -1117,8 +1117,9 @@ csio_mb_intr_enable(struct csio_hw *hw)
 void
 csio_mb_intr_disable(struct csio_hw *hw)
 {
-	csio_wr_reg32(hw, MBMSGRDYINTEN(0), MYPF_REG(CIM_PF_HOST_INT_ENABLE));
-	csio_rd_reg32(hw, MYPF_REG(CIM_PF_HOST_INT_ENABLE));
+	csio_wr_reg32(hw, MBMSGRDYINTEN_V(0),
+		      MYPF_REG(CIM_PF_HOST_INT_ENABLE_A));
+	csio_rd_reg32(hw, MYPF_REG(CIM_PF_HOST_INT_ENABLE_A));
 }
 
 static void
@@ -1153,8 +1154,8 @@ csio_mb_debug_cmd_handler(struct csio_hw *hw)
 {
 	int i;
 	__be64 cmd[CSIO_MB_MAX_REGS];
-	uint32_t ctl_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_CTRL);
-	uint32_t data_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_DATA);
+	uint32_t ctl_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_CTRL_A);
+	uint32_t data_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_DATA_A);
 	int size = sizeof(struct fw_debug_cmd);
 
 	/* Copy mailbox data */
@@ -1164,8 +1165,8 @@ csio_mb_debug_cmd_handler(struct csio_hw *hw)
 	csio_mb_dump_fw_dbg(hw, cmd);
 
 	/* Notify FW of mailbox by setting owner as UP */
-	csio_wr_reg32(hw, MBMSGVALID | MBINTREQ | MBOWNER(CSIO_MBOWNER_FW),
-		      ctl_reg);
+	csio_wr_reg32(hw, MBMSGVALID_F | MBINTREQ_F |
+		      MBOWNER_V(CSIO_MBOWNER_FW), ctl_reg);
 
 	csio_rd_reg32(hw, ctl_reg);
 	wmb();
@@ -1187,8 +1188,8 @@ csio_mb_issue(struct csio_hw *hw, struct csio_mb *mbp)
 	__be64 *cmd = mbp->mb;
 	__be64 hdr;
 	struct csio_mbm	*mbm = &hw->mbm;
-	uint32_t ctl_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_CTRL);
-	uint32_t data_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_DATA);
+	uint32_t ctl_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_CTRL_A);
+	uint32_t data_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_DATA_A);
 	int size = mbp->mb_size;
 	int rv = -EINVAL;
 	struct fw_cmd_hdr *fw_hdr;
@@ -1224,12 +1225,12 @@ csio_mb_issue(struct csio_hw *hw, struct csio_mb *mbp)
 	}
 
 	/* Now get ownership of mailbox */
-	owner = MBOWNER_GET(csio_rd_reg32(hw, ctl_reg));
+	owner = MBOWNER_G(csio_rd_reg32(hw, ctl_reg));
 
 	if (!csio_mb_is_host_owner(owner)) {
 
 		for (i = 0; (owner == CSIO_MBOWNER_NONE) && (i < 3); i++)
-			owner = MBOWNER_GET(csio_rd_reg32(hw, ctl_reg));
+			owner = MBOWNER_G(csio_rd_reg32(hw, ctl_reg));
 		/*
 		 * Mailbox unavailable. In immediate mode, fail the command.
 		 * In other modes, enqueue the request.
@@ -1271,10 +1272,10 @@ csio_mb_issue(struct csio_hw *hw, struct csio_mb *mbp)
 	if (mbp->mb_cbfn != NULL) {
 		mbm->mcurrent = mbp;
 		mod_timer(&mbm->timer, jiffies + msecs_to_jiffies(mbp->tmo));
-		csio_wr_reg32(hw, MBMSGVALID | MBINTREQ |
-			      MBOWNER(CSIO_MBOWNER_FW), ctl_reg);
+		csio_wr_reg32(hw, MBMSGVALID_F | MBINTREQ_F |
+			      MBOWNER_V(CSIO_MBOWNER_FW), ctl_reg);
 	} else
-		csio_wr_reg32(hw, MBMSGVALID | MBOWNER(CSIO_MBOWNER_FW),
+		csio_wr_reg32(hw, MBMSGVALID_F | MBOWNER_V(CSIO_MBOWNER_FW),
 			      ctl_reg);
 
 	/* Flush posted writes */
@@ -1294,9 +1295,9 @@ csio_mb_issue(struct csio_hw *hw, struct csio_mb *mbp)
 
 		/* Check for response */
 		ctl = csio_rd_reg32(hw, ctl_reg);
-		if (csio_mb_is_host_owner(MBOWNER_GET(ctl))) {
+		if (csio_mb_is_host_owner(MBOWNER_G(ctl))) {
 
-			if (!(ctl & MBMSGVALID)) {
+			if (!(ctl & MBMSGVALID_F)) {
 				csio_wr_reg32(hw, 0, ctl_reg);
 				continue;
 			}
@@ -1457,16 +1458,16 @@ csio_mb_isr_handler(struct csio_hw *hw)
 	__be64			*cmd;
 	uint32_t		ctl, cim_cause, pl_cause;
 	int			i;
-	uint32_t		ctl_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_CTRL);
-	uint32_t		data_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_DATA);
+	uint32_t	ctl_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_CTRL_A);
+	uint32_t	data_reg = PF_REG(hw->pfn, CIM_PF_MAILBOX_DATA_A);
 	int			size;
 	__be64			hdr;
 	struct fw_cmd_hdr	*fw_hdr;
 
 	pl_cause = csio_rd_reg32(hw, MYPF_REG(PL_PF_INT_CAUSE));
-	cim_cause = csio_rd_reg32(hw, MYPF_REG(CIM_PF_HOST_INT_CAUSE));
+	cim_cause = csio_rd_reg32(hw, MYPF_REG(CIM_PF_HOST_INT_CAUSE_A));
 
-	if (!(pl_cause & PFCIM) || !(cim_cause & MBMSGRDYINT)) {
+	if (!(pl_cause & PFCIM) || !(cim_cause & MBMSGRDYINT_F)) {
 		CSIO_INC_STATS(hw, n_mbint_unexp);
 		return -EINVAL;
 	}
@@ -1477,16 +1478,16 @@ csio_mb_isr_handler(struct csio_hw *hw)
 	 * the upper level cause register. In other words, CIM-cause
 	 * first followed by PL-Cause next.
 	 */
-	csio_wr_reg32(hw, MBMSGRDYINT, MYPF_REG(CIM_PF_HOST_INT_CAUSE));
+	csio_wr_reg32(hw, MBMSGRDYINT_F, MYPF_REG(CIM_PF_HOST_INT_CAUSE_A));
 	csio_wr_reg32(hw, PFCIM, MYPF_REG(PL_PF_INT_CAUSE));
 
 	ctl = csio_rd_reg32(hw, ctl_reg);
 
-	if (csio_mb_is_host_owner(MBOWNER_GET(ctl))) {
+	if (csio_mb_is_host_owner(MBOWNER_G(ctl))) {
 
 		CSIO_DUMP_MB(hw, hw->pfn, data_reg);
 
-		if (!(ctl & MBMSGVALID)) {
+		if (!(ctl & MBMSGVALID_F)) {
 			csio_warn(hw,
 				  "Stray mailbox interrupt recvd,"
 				  " mailbox data not valid\n");
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
