From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [BNX2X][PATCH 7/8] bnx2x_self_test.h
Date: Sun, 07 Oct 2007 18:25:12 +0200
Message-ID: <47090868.9030202@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2345 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753075AbXJGQYC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 12:24:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bnx2x_self_test.h
This file contains a self-test derived from HW specs, and the code that 
prints HW/FW/BC assert codes.

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com 
<mailto:eliezert@broadcom.com>>
---
drivers/net/bnx2x_self_test.h | 1387 
+++++++++++++++++++++++++++++++++++++++++
1 files changed, 1387 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_self_test.h b/drivers/net/bnx2x_self_test.h
new file mode 100644
index 0000000..b1d62e7
--- /dev/null
+++ b/drivers/net/bnx2x_self_test.h
@@ -0,0 +1,1387 @@
+/* bnx2x_self_test.h: Broadcom Everest network driver.
+ *
+ * Copyright (c) 2007 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+/* self test */
+static int bnx2x_idle_chk(struct bnx2x *bp)
+{
+ u32 val, i, val2;
+ u32 errors = 0;
+ u32 warnings = 0;
+ u32 varr[32];
+ u32 usem_foc_credits[4] = {26, 78, 16, 32};
+ u32 xsem_foc_credits[4] = {0, 24, 12, 102};
+ u32 csem_foc_credits[4] = {16, 18, 48, 14};
+ u32 tsem_foc_credits[4] = { 52, 24, 12, 32};
+ u32 foc_num = 0;
+ u8  err_pkt = 0;
+ u32 pci_reg;
+/* Disable timer scans for port 0,1 */
+/*     is_enable_timer0 = lm_disable_timer(pdev, 0); */
+/*     is_enable_timer1 = lm_disable_timer(pdev, 1); */
+
+
+/* Check errors on PCI configuration space ucorr_err_status 0x114 */
+/* check port 0 */
+ val = REG_RD(bp, GRCBASE_PXPCS, 0x2114);
+ if ((val & 0x1FF010) != 0x0) {
+ BNX2X_ERR("Error PCIE IP function %d,"
+    " ucorr_err_status is not 0x0. Equal to 0x%x\n",
+    bp->port, val);
+ err_pkt = 1;
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_PXPCS, 0x2120);
+ if (((val & 0x31C1) != 0x2000) && ((val & 0x31C1) != 0)) {
+ BNX2X_ERR("Error PCIE IP function %d,"
+    " corr_err_status is not 0x2000. Equal to 0x%x\n",
+    bp->port, val);
+ err_pkt = 1;
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_PXPCS, 0x2814);
+ if ((val != 0x40100) && (val != 0)) {
+ BNX2X_ERR("Error PCIE IP function %d,"
+    " attentions register is not 0x40100. Equal to 0x%x\n",
+    bp->port, val);
+ err_pkt = 1;
+ errors++;
+ }
+
+ if (err_pkt) {
+ pci_reg = 0x212c;
+ for (i = 0; i < 4; i++) {
+ val = REG_RD(bp, GRCBASE_PXPCS, pci_reg+i*4);
+ BNX2X_ERR("Error PCIE IP function %d,"
+    " error packet header %d  Equal to 0x%x\n",
+    bp->port, i, val);
+ }
+ }
+
+/* Check that all VQs in PXP are empty */
+ varr[0] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ0_ENTRY_CNT);
+ varr[1] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ1_ENTRY_CNT);
+ varr[2] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ2_ENTRY_CNT);
+ varr[3] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ3_ENTRY_CNT);
+ varr[4] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ4_ENTRY_CNT);
+ varr[5] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ5_ENTRY_CNT);
+ varr[6] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ6_ENTRY_CNT);
+ varr[7] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ7_ENTRY_CNT);
+ varr[8] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ8_ENTRY_CNT);
+ varr[9] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ9_ENTRY_CNT);
+ varr[10] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ10_ENTRY_CNT);
+ varr[11] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ11_ENTRY_CNT);
+ varr[12] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ12_ENTRY_CNT);
+ varr[13] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ13_ENTRY_CNT);
+ varr[14] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ14_ENTRY_CNT);
+ varr[15] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ15_ENTRY_CNT);
+ varr[16] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ16_ENTRY_CNT);
+ varr[17] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ17_ENTRY_CNT);
+ varr[18] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ18_ENTRY_CNT);
+ varr[19] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ19_ENTRY_CNT);
+ varr[20] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ20_ENTRY_CNT);
+ varr[21] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ21_ENTRY_CNT);
+ varr[22] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ22_ENTRY_CNT);
+ varr[23] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ23_ENTRY_CNT);
+ varr[24] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ24_ENTRY_CNT);
+ varr[25] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ25_ENTRY_CNT);
+ varr[26] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ26_ENTRY_CNT);
+ varr[27] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ27_ENTRY_CNT);
+ varr[28] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ28_ENTRY_CNT);
+ varr[29] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ29_ENTRY_CNT);
+ varr[30] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ30_ENTRY_CNT);
+ varr[31] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_VQ31_ENTRY_CNT);
+
+ for (i = 0; i < 32; i++) {
+ if (varr[i] != 0) {
+ if ((i == 3) && (varr[i] <= 2)) {
+ continue;
+ } else {
+ BNX2X_ERR("Error, PXP, VQ%d is not empty."
+   " Fill level equal to %d\n",
+   i, varr[i]);
+ errors++;
+ }
+ }
+ }
+
+/* Check that PXP2 register rq_ufifo_num_of_entry is 0 */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_UFIFO_NUM_OF_ENTRY);
+ if (val != 0) {
+ BNX2X_ERR("Error, PXP, rq_ufifo_num_of_entry is not zero."
+   " value equals %d\n", val);
+ errors++;
+ }
+
+ /* Check that rq_rbc_done is 1 */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_RBC_DONE);
+ if (val != 1) {
+ BNX2X_ERR("Error, PXP, rq_rbc_done is not 1."
+   " value equals %d\n", val);
+ errors++;
+ }
+
+ /* Check that rq_cfg_done is 1 */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_CFG_DONE);
+ if (val != 1) {
+ BNX2X_ERR("Error, PXP, rq_cfg_done is not 1. "
+   "value equals %d\n", val);
+ errors++;
+ }
+
+ /* Check that rq_read_credit and rq_write_credit are 3 */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_PSWRQ_BW_CREDIT);
+ if (val != 0x1B) {
+ BNX2X_ERR("Error, PXP, rq_read_credit and rq_write_credit "
+   "are not 3. value equals %d\n", val);
+ errors++;
+ }
+
+ /* Check that rd_start_init is 1 */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_START_INIT);
+ if (val != 1) {
+ BNX2X_ERR("Error, PXP, rd_start_init is not 1."
+   " value equals %d\n", val);
+ errors++;
+ }
+
+/* Check that rd_init_done is 1 */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_INIT_DONE);
+ if (val != 1) {
+ BNX2X_ERR("Error, PXP, rd_init_done is not 1. "
+   "value equals %d\n", val);
+ errors++;
+ }
+
+/*  Check that rd_sr_cnt equals rd_sr_num_cfg */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_SR_CNT);
+ val2 = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_SR_NUM_CFG);
+ if (val != (val2-1)) {
+ BNX2X_ERR("Warning, PXP, rd_sr_cnt != rd_sr_num_cfg-1."
+   " values are %d %d\n", val, val2);
+ warnings++;
+ }
+
+/* Check that rd_blk_cnt equals rd_blk_num_cfg */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_BLK_CNT);
+ val2 = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_BLK_NUM_CFG);
+ if (val != val2) {
+ BNX2X_ERR("Error, PXP, rd_blk_cnt is not equal to "
+   "rd_blk_num_cfg. values are %d %d\n", val, val2);
+ errors++;
+ }
+/* Check that delivery ports are idle */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_PORT_IS_IDLE_0);
+ if (val != 1) {
+ BNX2X_ERR("Error PXP2 P0, All delivery ports are not idle."
+   " Equal to  %d\n", val);
+ errors++;
+ }
+
+/* Check that delivery ports are idle */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_PORT_IS_IDLE_1);
+ if (val != 1) {
+ BNX2X_ERR("Error PXP2 P1, All delivery ports are not idle."
+   " Equal to  %d\n", val);
+ errors++;
+ }
+
+/* Check that rd_almost_full is 0 */
+ varr[0] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_0);
+ varr[1] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_1);
+ varr[2] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_2);
+ varr[3] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_3);
+ varr[4] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_4);
+ varr[5] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_5);
+ varr[6] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_6);
+ varr[7] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_7);
+ varr[8] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_8);
+ varr[9] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_9);
+ varr[10] = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_ALMOST_FULL_10);
+ for (i = 0;i < 11; i++) {
+ if (varr[i] != 0) {
+ BNX2X_ERR("Error, PXP, rd_almost_full_%d is not zero."
+   " Value is %d\n", i, varr[i]);
+ errors++;
+ }
+ }
+
+ /* Check that host i/f data and descriptor FIFOs are empty */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_HST_HEADER_FIFO_STATUS);
+ if (val != 0) {
+ BNX2X_ERR("Error PXP2 HST, header FIFO status is not"
+   " empty and is equal to %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_HST_DATA_FIFO_STATUS);
+ if (val != 0) {
+ BNX2X_ERR("Error PXP2 HST, data FIFO status is not"
+   " empty and is equal to %d\n", val);
+ errors++;
+ }
+
+ /* Check that pgl_write_blocked and pgl_read_blocked is 0 */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_PGL_WRITE_BLOCKED);
+ if (val != 0) {
+ BNX2X_ERR("Error PXP2 pgl_write_blocked is not zero and is"
+   " equal to %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_PGL_READ_BLOCKED);
+ if (val != 0) {
+ BNX2X_ERR("Error PXP2 pgl_read_blocked is not zero and is "
+   "equal to %d\n", val);
+ errors++;
+ }
+
+/* Check that the HST I/F arbiter is idle*/
+ val = REG_RD(bp, GRCBASE_PXP, PXP_REGISTERS_HST_ARB_IS_IDLE);
+ if (val != 1) {
+ BNX2X_ERR("Error PXP HST, arbiter is not idle! %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_PXP, PXP_REGISTERS_HST_CLIENTS_WAITING_TO_ARB);
+ if (val != 0) {
+ BNX2X_ERR("Error PXP HST, one of the clients is"
+   " waiting for delivery: 0x%x\n", val);
+ errors++;
+ }
+
+/* On PXP2 (glue) check that tag_is_ready is equal to 1
+   and that data_is_ready is equal to 0*/
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_PGL_TXR_CDTS);
+ if (((val>>5)&1) != 1) {
+ BNX2X_ERR("Error, PXP2: Tag is not ready.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_PGL_TXW_CDTS);
+ if (((val>>17)&1) != 0) {
+ BNX2X_ERR("Error, PXP2 There is data which is ready.\n");
+ errors++;
+ }
+
+/* Check that all SR are unused (counter equal to 127)*/
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_SR_CNT);
+ if (val < 123) {
+ BNX2X_ERR("Error, PXP2, The number of unused SRs < 123."
+   " Equal to %d\n", val);
+ errors++;
+ }
+
+/* Check that all read blocks are unused */
+ val = REG_RD(bp, GRCBASE_PXP2, PXP2_REGISTERS_RD_BLK_CNT);
+ if (val < 156) {
+ BNX2X_ERR("Error, PXP2, The number of unused Read blocks "
+   "< 156. Equal to %d\n", val);
+ errors++;
+ }
+/* Check that DMAE registers go_co..c15 are zero */
+ varr[0] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C0);
+ varr[1] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C1);
+ varr[2] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C2);
+ varr[3] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C3);
+ varr[4] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C4);
+ varr[5] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C5);
+ varr[6] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C6);
+ varr[7] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C7);
+ varr[8] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C8);
+ varr[9] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C9);
+ varr[10] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C10);
+ varr[11] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C11);
+ varr[12] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C12);
+ varr[13] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C13);
+ varr[14] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C14);
+ varr[15] = REG_RD(bp, GRCBASE_DMAE, DMAE_REGISTERS_GO_C15);
+ for (i = 0;i < 16; i++) {
+ if (varr[i] != 0) {
+ BNX2X_ERR("Error, DMAE, GO_C%d is not empty. "
+   "Value is %d\n", i, varr[i]);
+ errors++;
+ }
+ }
+
+/* Check that all AC counters are empty (expect leading connection 0) */
+ for (i = 0; i < CFC_REGISTERS_ACTIVITY_COUNTER_SIZE ; i++) {
+ val = REG_RD(bp, GRCBASE_CFC,
+      CFC_REGISTERS_ACTIVITY_COUNTER + i*4);
+ if ((val != 0) && (i != 0)) {
+ BNX2X_ERR("Error, CFC: LCID %d, AC is not zero. "
+   "AC equal to %d\n", i, val);
+ errors++;
+ }
+ }
+
+/* Check that all QM queues are empty */
+ for (i = 0; i < 64 ; i++) {
+ val = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_QTASKCTR_0 + i*4);
+ if (val != 0) {
+ BNX2X_ERR("Error, QM: Q %d, Queue is not empty. "
+   "Fill level is: %d\n", i, val);
+ errors++;
+ }
+ }
+
+/* Check that all VOQ 0 credit is full */
+ val = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_VOQINITCREDIT_0);
+ val2 = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_VOQCREDIT_0);
+ if (val2 != val) {
+ BNX2X_ERR("Error, QM: VOQ0, VOQ credit not equal to initial"
+   " credit. credit: %d, initial credit: %d\n",
+   val2, val);
+ errors++;
+ }
+
+/* Check that all VOQ 1 credit is full */
+ val = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_VOQINITCREDIT_1);
+ val2 = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_VOQCREDIT_1);
+ if (val2 != val) {
+ BNX2X_ERR("Error, QM: VOQ1, VOQ credit not equal to initial"
+   " credit. credit: %d, initial credit: %d\n",
+   val2, val);
+ errors++;
+ }
+
+/* Check that all VOQ 4 credit is full */
+ /* Check that all VOQ 1 credit is full */
+ val = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_VOQINITCREDIT_4);
+ val2 = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_VOQCREDIT_4);
+ if (val2 != val) {
+ BNX2X_ERR("Error, QM: VOQ4, VOQ credit not equal to initial."
+   " credit: %d, initial credit: %d\n", val2, val);
+ errors++;
+ }
+
+/* Check that all byte credit for port 0 credit is full */
+ val = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_BYTECRDINITVAL);
+ val2 = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_PORT0BYTECRD);
+ if (val2 != val) {
+ BNX2X_ERR("Error, QM: port0, Byte credit not equal to initial"
+   " credit. credit: %d, initial credit: %d\n",
+   val2, val);
+ errors++;
+ }
+
+/* Check that all byte credit for port 1 credit is full */
+ val2 = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_PORT1BYTECRD);
+ if (val2 != val) {
+ BNX2X_ERR("Error, QM: port1, Byte credit not equal to initial "
+   "credit. credit: %d, initial credit: %d\n",
+   val2, val);
+ errors++;
+ }
+
+/* Check that XXq lock tables are empt */
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_CAM_OCCUP);
+ if (val != 0) {
+ BNX2X_ERR("Error, CCM: CAM is not empty. "
+   "Occupancy equal to: %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_CAM_OCCUP);
+ if (val != 0) {
+ BNX2X_ERR("Error, XCM: CAM is not empty. "
+   "Occupancy equal to: %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_CAM_OCCUP);
+ if (val != 0) {
+ BNX2X_ERR("Error, TCM: CAM is not empty. "
+   "Occupancy equal to: %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_CAM_OCCUP);
+ if (val != 0) {
+ BNX2X_ERR("Error, UCM: CAM is not empty. "
+   "Occupancy equal to: %d\n", val);
+ errors++;
+ }
+
+/* Check that BRB1 is empty:   */
+ val = REG_RD(bp, GRCBASE_BRB1, BRB1_REGISTERS_NUM_OF_FULL_BLOCKS);
+ if (val != 0) {
+ BNX2X_ERR("Error, BRB: is not empty. Occupancy equal to:"
+   " %d\n", val);
+ errors++;
+ }
+
+/* SEMI checks */
+/* 1. check thread ready is equal to 0 */
+ val = REG_RD(bp, GRCBASE_TSEM, TSEM_REGISTERS_SLEEP_THREADS_VALID);
+ if (val != 0) {
+ BNX2X_ERR("Error, TSEM: There are slebping threads. "
+   "Slebp mask is equal to: %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_XSEM, XSEM_REGISTERS_SLEEP_THREADS_VALID);
+ if (val != 0) {
+ BNX2X_ERR("Error, XSEM: There are slebping threads."
+   " Slebp mask is equal to: %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_USEM, USEM_REGISTERS_SLEEP_THREADS_VALID);
+ if (val != 0) {
+ BNX2X_ERR("Error, USEM: There are slebping threads."
+   " Slebp mask is equal to: %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CSEM, CSEM_REGISTERS_SLEEP_THREADS_VALID);
+ if (val != 0) {
+ BNX2X_ERR("Error, CSEM: There are slebping threads."
+   " Slebp mask is equal to: %d\n", val);
+ errors++;
+ }
+
+/* 2. check external store fifo is empty */
+
+ val = REG_RD(bp, GRCBASE_TSEM, TSEM_REGISTERS_SLOW_EXT_STORE_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, TSEM: External store FIFO is not empty\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_XSEM, XSEM_REGISTERS_SLOW_EXT_STORE_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, XSEM: External store FIFO is not empty\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_USEM, USEM_REGISTERS_SLOW_EXT_STORE_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, USEM: External store FIFO is not empty\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CSEM, CSEM_REGISTERS_SLOW_EXT_STORE_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, CSEM: External store FIFO is not empty\n");
+ errors++;
+ }
+
+/*SDM checks*/
+/*1. Input queue empty
+#set name [format "%sSDM_REGISTERS_QUEUE_EMPTY" $ins]
+#set level [reg_read -n $name]
+#if {$level != 1 } {
+#    puts "Error, $ins-SDM: Parser input queue is not empty."
+#    incr errors
+#}*/
+
+/*2. Parser serial FIFO check*/
+ val = REG_RD(bp, GRCBASE_TSDM, TSDM_REGISTERS_SYNC_PARSER_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, TSDM: Parser serial FIFO is not empty.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_XSDM, XSDM_REGISTERS_SYNC_PARSER_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, XSDM: Parser serial FIFO is not empty.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_USDM, USDM_REGISTERS_SYNC_PARSER_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, USDM: Parser serial FIFO is not empty.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CSDM, CSDM_REGISTERS_SYNC_PARSER_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, CSDM: Parser serial FIFO is not empty.\n");
+ errors++;
+ }
+
+/*3. Parser serial FIFO check */
+
+ val = REG_RD(bp, GRCBASE_TSDM, TSDM_REGISTERS_SYNC_SYNC_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, TSDM: Parser SYNC serial FIFO "
+   "is not empty.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_XSDM, XSDM_REGISTERS_SYNC_SYNC_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, XSDM: Parser SYNC serial FIFO "
+   "is not empty.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_USDM, USDM_REGISTERS_SYNC_SYNC_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, USDM: Parser SYNC serial FIFO "
+   "is not empty.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CSDM, CSDM_REGISTERS_SYNC_SYNC_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, CSDM: Parser SYNC serial FIFO "
+   "is not empty.\n");
+ errors++;
+ }
+
+/*4. pxp_ctrl rd_data fifo  empty in sdm_dma_rsp block*/
+ val = REG_RD(bp, GRCBASE_TSDM, TSDM_REGISTERS_RSP_PXP_CTRL_RDATA_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, TSDM: pxp_ctrl rd_data fifo  not empty in "
+   "sdm_dma_rsp block.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_XSDM, XSDM_REGISTERS_RSP_PXP_CTRL_RDATA_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, XSDM: pxp_ctrl rd_data fifo  not empty in "
+   "sdm_dma_rsp block.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_USDM, USDM_REGISTERS_RSP_PXP_CTRL_RDATA_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, USDM: pxp_ctrl rd_data fifo  not empty in "
+   "sdm_dma_rsp block.\n");
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CSDM, CSDM_REGISTERS_RSP_PXP_CTRL_RDATA_EMPTY);
+ if (val != 1) {
+ BNX2X_ERR("Error, CSDM: pxp_ctrl rd_data fifo  not empty in "
+   "sdm_dma_rsp block.\n");
+ errors++;
+ }
+
+/*DORQ fill level check */
+ val = REG_RD(bp, GRCBASE_DQ, DORQ_REGISTERS_DQ_FILL_LVLF);
+ if (val != 0) {
+ BNX2X_ERR("Error, DORQ: DORQ is not empty. Occupancy equal to:"
+   " %d.\n", val);
+ errors++;
+ }
+
+/*Check that all interrupt statuses are zero.*/
+ val = REG_RD(bp, GRCBASE_CFC, CFC_REGISTERS_CFC_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, CFC: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CDU, CDU_REGISTERS_CDU_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, CDU: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_CCM_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, CCM: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_XCM_INT_STS);
+ if (val != 0x0) {
+ BNX2X_ERR("Error, XCM: Interrupt status is not 0x0. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_TCM_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, TCM: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_UCM_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, UCM: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_PBF_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, PBF: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_TIMERS, TM_REGISTERS_TM_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, TIMERS: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_DQ, DORQ_REGISTERS_DORQ_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, DORQ: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_SRCH, SRC_REGISTERS_SRC_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, SRC: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_PRS_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, PRS: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_BRB1, BRB1_REGISTERS_BRB1_INT_STS);
+ if ((val & ~0xFC00) != 0) {
+ BNX2X_ERR("Error, BRB1: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+/* Check pxp PORT 0 interrupts */
+ val = REG_RD(bp, GRCBASE_PXP, PXP_REGISTERS_PXP_INT_STS_0);
+ if (val != 0) {
+ BNX2X_ERR("Error, PXP 0: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+/* Check pxp PORT 1 interrupts */
+ val = REG_RD(bp, GRCBASE_PXP, PXP_REGISTERS_PXP_INT_STS_1);
+ if (val != 0) {
+ BNX2X_ERR("Error, PXP 1: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+/* Check UPB interrupts */
+ val = REG_RD(bp, GRCBASE_UPB, PB_REGISTERS_PB_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, PB: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+/* Check XPB interrupts */
+ val = REG_RD(bp, GRCBASE_XPB, PB_REGISTERS_PB_INT_STS);
+ if (val != 0) {
+ BNX2X_ERR("Error, PB: Interrupt status is not zero. "
+   "Pending interrupts equal to 0x%x.\n", val);
+ errors++;
+ }
+
+/*Check credits of the DORQ to the XCM*/
+ val = REG_RD(bp, GRCBASE_DQ, DORQ_REGISTERS_RSPA_CRD_CNT);
+ if (val != 2) {
+ BNX2X_ERR("Error DORQ, Credit to XCM is not full. "
+   "Value is %d\n", val);
+ errors++;
+ }
+
+/*Check credits of the DORQ to the UCM*/
+ val = REG_RD(bp, GRCBASE_DQ, DORQ_REGISTERS_RSPA_CRD_CNT);
+ if (val != 2) {
+ BNX2X_ERR("Error DORQ, Credit to UCM is not full."
+   " Value is %d\n", val);
+ errors++;
+ }
+
+/* Check there are no QM VOQ and byte credit errors*/
+ val = REG_RD(bp, GRCBASE_QM, QM_REGISTERS_VOQCRDERRREG);
+ if (val != 0) {
+ BNX2X_ERR("Error QM, Credit error register is not zero"
+   "(byte or credit overflow/underflow). Value is %d\n",
+    val);
+ errors++;
+ }
+/* Check that CFC num_lcid_inside is <=2 */
+ val = REG_RD(bp, GRCBASE_CFC, CFC_REGISTERS_NUM_LCIDS_INSIDE);
+ if (val > 2) {
+ BNX2X_ERR("Error CFC, num_lcid_inside is larger than 2. "
+   "Value is %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CFC, CFC_REGISTERS_ERROR_VECTOR);
+ if (val != 0) {
+ BNX2X_ERR("Error CFC, error vector is not zero. Value is %d\n",
+   val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CFC, CFC_REGISTERS_NUM_LCIDS_ARRIVING);
+ if (val != 0) {
+ BNX2X_ERR("Error CFC, number of arriving LCIDs is not zero. "
+   "Value is %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CFC, CFC_REGISTERS_NUM_LCIDS_ALLOC);
+ if (val != 0) {
+ BNX2X_ERR("Error CFC, number of alloc LCIDs is not zero. "
+   "Value is %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CFC, CFC_REGISTERS_NUM_LCIDS_LEAVING);
+ if (val != 0) {
+ BNX2X_ERR("Error CFC, number of leaving LCIDs is not zero. "
+   "Value is %d\n", val);
+ errors++;
+ }
+
+
+ val = REG_RD(bp, GRCBASE_CFC, CFC_REGISTERS_NUM_LCIDS_LEAVING);
+ if (val != 0) {
+ BNX2X_ERR("Error CFC, number of leaving LCIDs is not zero. "
+   "Value is %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_DQ, DORQ_REGISTERS_DQ_FULL_ST);
+ if (val != 0) {
+ BNX2X_ERR("Error DORQ_REGISTERS_DQ_FULL_ST is not zero "
+   "Value is %d\n", val);
+ errors++;
+ }
+
+ /* Check AEU registers (func 0) */
+ val = REG_RD(bp, GRCBASE_MISC,
+      MISC_REGISTERS_AEU_AFTER_INVERT_1_FUNC_0);
+ if ((val & ~0xCFFC) != 0) {
+ BNX2X_ERR("Warning MISC_REGISTERS_AEU_AFTER_INVERT_1_FUNC_0"
+   " after mask !=0 (%x). no support of "
+   "UNICORE in driver yet\n", (val & ~0xCFFC));
+ warnings++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC,
+      MISC_REGISTERS_AEU_AFTER_INVERT_2_FUNC_0);
+ if (val != 0) {
+ BNX2X_ERR("Error MISC_REGISTERS_AEU_AFTER_INVERT_2_FUNC_0"
+   " is not zero. Value is %x\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC,
+      MISC_REGISTERS_AEU_AFTER_INVERT_3_FUNC_0);
+ if ((val & ~0xC2000000) != 0) {
+ BNX2X_ERR("Error MISC_REGISTERS_AEU_AFTER_INVERT_3_FUNC_0 !=0 "
+   "(%x). no MCP code.\n", (val & ~0xC2000000));
+ warnings++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC,
+      MISC_REGISTERS_AEU_AFTER_INVERT_4_FUNC_0);
+ if ((val & ~0xFFFFFF) != 0) {
+ BNX2X_ERR("Error MISC_REGISTERS_AEU_AFTER_INVERT_4_FUNC_0"
+   " after mask is not zero. Value is %x\n",
+   (val & ~0xFFFFF));
+ warnings++;
+ }
+
+ /* Check AEU registers (func 1) */
+ val = REG_RD(bp, GRCBASE_MISC,
+      MISC_REGISTERS_AEU_AFTER_INVERT_1_FUNC_1);
+ if ((val & ~0xCFFC) != 0) {
+ BNX2X_ERR("Warning MISC_REGISTERS_AEU_AFTER_INVERT_1_FUNC_1"
+   " after mask !=0 (%x)\n", (val & ~0xCFFC));
+ warnings++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC,
+      MISC_REGISTERS_AEU_AFTER_INVERT_2_FUNC_1);
+ if (val != 0) {
+ BNX2X_ERR("Error MISC_REGISTERS_AEU_AFTER_INVERT_2_FUNC_1"
+   " is not zero. Value is %x\n", val);
+ warnings++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC,
+      MISC_REGISTERS_AEU_AFTER_INVERT_3_FUNC_1);
+ if ((val & ~0xC2000000) != 0) {
+ BNX2X_ERR("Error MISC_REGISTERS_AEU_AFTER_INVERT_3_FUNC_1"
+   " !=0 (%x). no MCP code.\n", (val & ~0xC2000000));
+ warnings++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC,
+      MISC_REGISTERS_AEU_AFTER_INVERT_4_FUNC_1);
+ if ((val & ~0xFFFFFF) != 0) {
+ BNX2X_ERR("Error MISC_REGISTERS_AEU_AFTER_INVERT_4_FUNC_1"
+   " after mask is not zero. Value is %x\n",
+   (val & ~0xFFFFF));
+ warnings++;
+ }
+
+ /* Check AEU registers (MCP) */
+ val = REG_RD(bp, GRCBASE_MISC, MISC_REGISTERS_AEU_AFTER_INVERT_1_MCP);
+ if ((val & ~0xCFFC) != 0) {
+ BNX2X_ERR("Warning MISC_REGISTERS_AEU_AFTER_INVERT_1_MCP"
+   " after mask !=0 (%x).\n", (val & ~0xCFFC));
+ warnings++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC, MISC_REGISTERS_AEU_AFTER_INVERT_2_MCP);
+ if (val != 0) {
+ BNX2X_ERR("Warning MISC_REGISTERS_AEU_AFTER_INVERT_2_MCP is"
+   " not zero. Value is %x\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC, MISC_REGISTERS_AEU_AFTER_INVERT_3_MCP);
+ if ((val & ~0xC2000000) != 0) {
+ BNX2X_ERR("Warning MISC_REGISTERS_AEU_AFTER_INVERT_3_MCP !=0 "
+   "(%x). no MCP code.\n", (val & ~0xC2000000));
+ warnings++;
+ }
+ val = REG_RD(bp, GRCBASE_MISC, MISC_REGISTERS_AEU_AFTER_INVERT_4_MCP);
+ if ((val & ~0xFFFFFF) != 0) {
+ BNX2X_ERR("Error MISC_REGISTERS_AEU_AFTER_INVERT_4_MCP"
+   " after mask is not zero. Value is %x\n",
+   (val & ~0xFFFFF));
+ warnings++;
+ }
+
+ /* Add idle checks for PBF block */
+ if (!REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_DISABLE_NEW_TASK_PROC_P0)) {
+ val = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P0_CREDIT);
+ val2 = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P0_INIT_CRD);
+ if (val != val2) {
+ BNX2X_ERR("Error PBF, PBF_REGISTERS_P0_CREDIT %d "
+   "differs PBF_REGISTERS_P0_INIT_CRD %d\n",
+    val, val2);
+ errors++;
+ }
+ }
+
+ if (!REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_DISABLE_NEW_TASK_PROC_P1)) {
+ val = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P1_CREDIT);
+ val2 = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P1_INIT_CRD);
+ if (val != val2) {
+ BNX2X_ERR("Error PBF, PBF_REGISTERS_P1_CREDIT %d"
+   " differs PBF_REGISTERS_P1_INIT_CRD %d\n",
+   val, val2);
+ errors++;
+ }
+ }
+
+ val = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P4_CREDIT);
+ val2 = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P4_INIT_CRD);
+ if (val != val2) {
+ BNX2X_ERR("Error PBF, PBF_REGISTERS_P4_CREDIT %d differs"
+   " PBF_REGISTERS_P4_INIT_CRD %d\n", val, val2);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P0_TASK_CNT);
+ if (val != 0) {
+ BNX2X_ERR("Error PBF, PBF_REGISTERS_P0_TASK_CNT is not zero."
+   " Value is %d \n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P1_TASK_CNT);
+ if (val != 0) {
+ BNX2X_ERR("Error PBF, PBF_REGISTERS_P1_TASK_CNT is not zero."
+   " Value is %d \n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P4_TASK_CNT);
+ if (val != 0) {
+ BNX2X_ERR("Error PBF, PBF_REGISTERS_P4_TASK_CNT is not zero."
+   " Value is %d \n", val);
+ errors++;
+ }
+
+ /* Extra checks for XCM blocks */
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_CFC_INIT_CRD);
+ if (val != 1) {
+ BNX2X_ERR("Error XCM, XCM_REGISTERS_CFC_INIT_CRD != 1,"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_XQM_INIT_CRD);
+ if (val != 32) {
+ BNX2X_ERR("Error XCM, XCM_REGISTERS_XQM_INIT_CRD != 32,"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_TM_INIT_CRD);
+ if (val != 4) {
+ BNX2X_ERR("Error XCM, XCM_REGISTERS_TM_INIT_CRD different "
+   "than 4,Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_FIC0_INIT_CRD);
+ if (val != 64) {
+ BNX2X_ERR("Error XCM, XCM_REGISTERS_FIC0_INIT_CRD different"
+   " than 64, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_FIC1_INIT_CRD);
+ if (val != 64) {
+ BNX2X_ERR("Error XCM, XCM_REGISTERS_FIC1_INIT_CRD different"
+   " than 64, Value is %d\n", val);
+ errors++;
+ }
+ /* Extra checks for UCM blocks */
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_CFC_INIT_CRD);
+ if (val != 1) {
+ BNX2X_ERR("Error UCM, UCM_REGISTERS_CFC_INIT_CRD different"
+   " than 1, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_UQM_INIT_CRD);
+ if (val != 32) {
+ BNX2X_ERR("Error UCM, UCM_REGISTERS_UQM_INIT_CRD different"
+   " than 32, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_TM_INIT_CRD);
+ if (val != 4) {
+ BNX2X_ERR("Error UCM, UCM_REGISTERS_TM_INIT_CRD different"
+   " than 4, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_FIC0_INIT_CRD);
+ if (val != 64) {
+ BNX2X_ERR("Error UCM, UCM_REGISTERS_FIC0_INIT_CRD different"
+   " than 64, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_FIC1_INIT_CRD);
+ if (val != 64) {
+ BNX2X_ERR("Error UCM, UCM_REGISTERS_FIC1_INIT_CRD different"
+   " than 64, Value is %d\n", val);
+ errors++;
+ }
+ /*  Extra checks for TCM blocks */
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_CFC_INIT_CRD);
+ if (val != 1) {
+ BNX2X_ERR("Error TCM, TCM_REGISTERS_CFC_INIT_CRD different "
+   "than 1, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_TQM_INIT_CRD);
+ if (val != 32) {
+ BNX2X_ERR("Error TCM, TCM_REGISTERS_TQM_INIT_CRD different "
+   "than 32, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_FIC0_INIT_CRD);
+ if (val != 64) {
+ BNX2X_ERR("Error TCM, TCM_REGISTERS_FIC0_INIT_CRD different"
+   " than 64, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_FIC1_INIT_CRD);
+ if (val != 64) {
+ BNX2X_ERR("Error TCM, TCM_REGISTERS_FIC1_INIT_CRD different"
+   " than 64, Value is %d\n", val);
+ errors++;
+ }
+ /* Extra checks for CCM blocks */
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_CFC_INIT_CRD);
+ if (val != 1) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_CFC_INIT_CRD different"
+   " than 1, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_CQM_INIT_CRD);
+ if (val != 32) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_TQM_INIT_CRD different"
+   " than 32, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_FIC0_INIT_CRD);
+ if (val != 64) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_FIC0_INIT_CRD different"
+   " than 64, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_FIC1_INIT_CRD);
+ if (val != 64) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_FIC1_INIT_CRD different"
+   " than 64, Value is %d\n", val);
+ errors++;
+ }
+ /* Extra checks for FOC credits */
+ for (foc_num = 0; foc_num < 4; foc_num++) {
+ val = REG_RD(bp, GRCBASE_USEM,
+      (USEM_REGISTERS_FAST_MEMORY +
+       0x18000+foc_num*0x40));
+ if (val != usem_foc_credits[foc_num]) {
+ BNX2X_ERR("Error USEM, FOC%d_CREDIT different than %d,"
+   " Value is %d\n",
+   foc_num, usem_foc_credits[foc_num], val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_XSEM,
+      (XSEM_REGISTERS_FAST_MEMORY +
+       0x18000 + foc_num*0x40));
+ if (val != xsem_foc_credits[foc_num]) {
+ BNX2X_ERR("Error XSEM, FOC%d_CREDIT different than %d,"
+   " Value is %d\n",
+   foc_num, xsem_foc_credits[foc_num], val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CSEM,
+      (CSEM_REGISTERS_FAST_MEMORY +
+       0x18000 + foc_num*0x40));
+ if (val != csem_foc_credits[foc_num]) {
+ BNX2X_ERR("Error CSEM, FOC%d_CREDIT different than %d,"
+   " Value is %d\n",
+   foc_num, csem_foc_credits[foc_num], val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_TSEM,
+      (TSEM_REGISTERS_FAST_MEMORY +
+       0x18000 + foc_num*0x40));
+ if (val != tsem_foc_credits[foc_num]) {
+ BNX2X_ERR("Error TSEM, FOC%d_CREDIT different than %d, "
+   "Value is %d\n",
+   foc_num, tsem_foc_credits[foc_num], val);
+ errors++;
+ }
+ }
+
+ /* Extra PRS checks */
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_TSDM_CURRENT_CREDIT);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_TSDM_CURRENT_CREDIT "
+   "different than 0,"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_TCM_CURRENT_CREDIT);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_TCM_CURRENT_CREDIT "
+   "different than 0,"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_CFC_LD_CURRENT_CREDIT);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_CFC_LD_CURRENT_CREDIT "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_CFC_SEARCH_CURRENT_CREDIT);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_CFC_SEARCH_CURRENT_CREDIT "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_SRC_CURRENT_CREDIT);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_SRC_CURRENT_CREDIT "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_PENDING_BRB_PRS_RQ);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_PENDING_BRB_PRS_RQ "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_PENDING_BRB_CAC0_RQ);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_PENDING_BRB_CAC0_RQ "
+   "different than 0,Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_PENDING_BRB_CAC1_RQ);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_PENDING_BRB_CAC1_RQ "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_PENDING_BRB_CAC2_RQ);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_PENDING_BRB_CAC2_RQ "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_PENDING_BRB_CAC3_RQ);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_PENDING_BRB_CAC3_RQ "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_PENDING_BRB_CAC4_RQ);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_PENDING_BRB_CAC0_RQ "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_PENDING_BRB_CAC4_RQ);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_PENDING_BRB_CAC0_RQ "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_SERIAL_NUM_STATUS_LSB);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_SERIAL_NUM_STATUS_LSB "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_SERIAL_NUM_STATUS_MSB);
+ if (val != 0) {
+ BNX2X_ERR("Error PRS, PRS_REGISTERS_SERIAL_NUM_STATUS_MSB "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+
+ val = REG_RD(bp, GRCBASE_CDU, CDU_REGISTERS_ERROR_DATA);
+ if (val != 0) {
+ BNX2X_ERR("Error CDU, CDU_REGISTERS_ERROR_DATA "
+   "Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_STORM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_STORM_LENGTH_MIS"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_CSDM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_CSDM_LENGTH_MIS "
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_TSEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_TSEM_LENGTH_MIS"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_XSEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_XSEM_LENGTH_MIS"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_CCM, CCM_REGISTERS_USEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_USEM_LENGTH_MIS"
+   "Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, CCM_REGISTERS_PBF_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, CCM_REGISTERS_PBF_LENGTH_MIS"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_STORM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, TCM_REGISTERS_STORM_LENGTH_MIS"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_TSDM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, TCM_REGISTERS_TSDM_LENGTH_MIS"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_PRS_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, TCM_REGISTERS_PRS_LENGTH_MIS"
+   "Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_PBF_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, TCM_REGISTERS_PBF_LENGTH_MIS"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_USEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, TCM_REGISTERS_USEM_LENGTH_MIS"
+   " Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_USEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, TCM_REGISTERS_USEM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_TCM, TCM_REGISTERS_CSEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, TCM_REGISTERS_CSEM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_STORM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, UCM_REGISTERS_STORM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_USDM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, UCM_REGISTERS_USDM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_TSEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, UCM_REGISTERS_TSEM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_CSEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, UCM_REGISTERS_CSEM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_XSEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, UCM_REGISTERS_XSEM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_UCM, UCM_REGISTERS_DORQ_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, UCM_REGISTERS_DORQ_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_STORM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_STORM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_XSDM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_XSDM_LENGTH_MIS "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_TSEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_TSEM_LENGTH_MIS "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_CSEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_CSEM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_USEM_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_USEM_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_DORQ_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_DORQ_LENGTH_MIS"
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_DORQ_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_DORQ_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_PBF_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_PBF_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_NIG0_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_NIG0_LENGTH_MIS"
+   " different than 0, Value is %d\n", val);
+ errors++;
+ }
+ val = REG_RD(bp, GRCBASE_XCM, XCM_REGISTERS_NIG1_LENGTH_MIS);
+ if (val != 0) {
+ BNX2X_ERR("Error CCM, XCM_REGISTERS_NIG1_LENGTH_MIS "
+   "different than 0, Value is %d\n", val);
+ errors++;
+ }
+
+ if (errors == 0) {
+ BNX2X_ERR("completed successfuly (with %d warnings)\n",
+   warnings);
+ } else {
+ BNX2X_ERR("failed (with %d errors, %d warnings)\n",
+   errors, warnings);
+ }
+ return errors;
+}
+
+static int bnx2x_mc_assert(struct bnx2x *bp)
+{
+ u8 i, j;
+ int rc = 0;
+ char last_idx;
+ const char storm[] = {"XTCU"};
+ const u32 intmem_base[] = {
+ BAR_XSTRORM_INTMEM,
+ BAR_TSTRORM_INTMEM,
+ BAR_CSTRORM_INTMEM,
+ BAR_USTRORM_INTMEM
+ };
+
+ /* Go through all instances of all SEMIs */
+ for (i = 0; i < 4; i++) {
+ last_idx = REG_RD8(bp, XSTORM_ASSERT_LIST_INDEX_OFFSET,
+    intmem_base[i]);
+ BNX2X_ERR("DATA %cSTORM_ASSERT_LIST_INDEX 0x%x\n",
+   storm[i], last_idx);
+
+ /* print the asserts */
+#define STROM_ASSERT_ARRAY_SIZE 50
+ for (j = 0; j < STROM_ASSERT_ARRAY_SIZE; j++) {
+ u32 row0, row1, row2, row3;
+ row0 = REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j),
+       intmem_base[i]);
+ row1 = REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 4,
+       intmem_base[i]);
+ row2 = REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 8,
+       intmem_base[i]);
+ row3 = REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 12,
+       intmem_base[i]);
+
+ if (row0 != COMMON_ASM_INVALID_ASSERT_OPCODE) {
+ BNX2X_ERR("DATA %cSTORM_ASSERT_INDEX 0x%x ="
+   " 0x%08x 0x%08x 0x%08x 0x%08x\n",
+   storm[i], j, row3, row2, row1, row0);
+ rc++;
+ } else {
+ break;
+ }
+ }
+ }
+ return rc;
+}
+
-- 
1.4.2



