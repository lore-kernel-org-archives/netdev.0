From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 6/8] qlge: Add serdes reg dump to firmware dump.
Date: Mon, 11 Jan 2010 17:13:03 -0800
Message-ID: <1263258785-5112-7-git-send-email-ron.mercer@qlogic.com>
References: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47640 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab0ALBTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 20:19:45 -0500
In-Reply-To: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c |  382 ++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 381 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 63822f7..6416fc3 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -64,8 +64,81 @@ static u32 ql_read_other_func_reg(struct ql_adapter *qdev,
 	return reg_val;
 }
 
+static int ql_write_other_func_reg(struct ql_adapter *qdev,
+					u32 reg, u32 reg_val)
+{
+	u32 other_function;
+	u32 register_to_read;
+	int status = 0;
+
+	other_function = ql_get_other_func_num(qdev);
+
+	/*
+	 * The other function is not enabled so we don't
+	 * need to read anything out of it.
+	 */
+	if (other_function == 0xffffffff)
+		return -1;
+
+	/*
+	 * The other function is there so now we need
+	 * to read the requested register.
+	 */
+	register_to_read = REG_BLOCK | MPI_READ |
+				(other_function << FUNCTION_SHIFT) | reg;
+	status = ql_write_mpi_reg(qdev, register_to_read, reg_val);
+
+	return status;
+}
+
+static int ql_wait_other_func_reg_rdy(struct ql_adapter *qdev, u32 reg,
+					u32 bit, u32 err_bit)
+{
+	u32 temp;
+	int count = 10;
+
+	while (count) {
+		temp = ql_read_other_func_reg(qdev, reg);
+
+		/* check for errors */
+		if (temp & err_bit)
+			return -1;
+		else if (temp & bit)
+			return 0;
+		mdelay(10);
+		count--;
+	}
+	return -1;
+}
+
+static int ql_read_other_func_serdes_reg(struct ql_adapter *qdev, u32 reg,
+							u32 *data)
+{
+	int status;
+
+	/* wait for reg to come ready */
+	status = ql_wait_other_func_reg_rdy(qdev, XG_SERDES_ADDR / 4,
+						XG_SERDES_ADDR_RDY, 0);
+	if (status)
+		goto exit;
+
+	/* set up for reg read */
+	ql_write_other_func_reg(qdev, XG_SERDES_ADDR/4, reg | PROC_ADDR_R);
+
+	/* wait for reg to come ready */
+	status = ql_wait_other_func_reg_rdy(qdev, XG_SERDES_ADDR / 4,
+						XG_SERDES_ADDR_RDY, 0);
+	if (status)
+		goto exit;
+
+	/* get the data */
+	*data = ql_read_other_func_reg(qdev, (XG_SERDES_DATA / 4));
+exit:
+	return status;
+}
+
 /* Read out the SERDES registers */
-int ql_read_serdes_reg(struct ql_adapter *qdev, u32 reg, u32 * data)
+static int ql_read_serdes_reg(struct ql_adapter *qdev, u32 reg, u32 * data)
 {
 	int status;
 
@@ -88,6 +161,208 @@ exit:
 	return status;
 }
 
+static void ql_get_both_serdes(struct ql_adapter *qdev, u32 addr,
+			u32 *direct_ptr, u32 *indirect_ptr,
+			unsigned int direct_valid, unsigned int indirect_valid)
+{
+	unsigned int status;
+
+	status = 0xffffffff;
+	if (direct_valid)
+		status = ql_read_serdes_reg(qdev, addr, direct_ptr);
+
+	if (status)
+		*direct_ptr = 0xDEADBEEF;
+
+	status = 0xffffffff;
+	if (indirect_valid)
+		status = ql_read_other_func_serdes_reg(
+						qdev, addr, indirect_ptr);
+
+	if (status)
+		*indirect_ptr = 0xDEADBEEF;
+}
+
+static int ql_get_serdes_regs(struct ql_adapter *qdev,
+				struct ql_mpi_coredump *mpi_coredump)
+{
+	int status;
+	unsigned int xfi_direct_valid, xfi_indirect_valid, xaui_direct_valid;
+	unsigned int xaui_indirect_valid, xaui_reg, i;
+	u32 *direct_ptr, temp;
+	u32 *indirect_ptr;
+
+	xfi_direct_valid = xfi_indirect_valid = 0;
+	xaui_direct_valid = xaui_indirect_valid = 1;
+
+	/* The XAUI needs to be read out per port */
+	xaui_reg = 0x800;
+	if (qdev->func & 1) {
+		/* We are NIC 2	*/
+		status = ql_read_other_func_serdes_reg(qdev, xaui_reg, &temp);
+		if (status)
+			temp = XAUI_POWERED_DOWN;
+		if ((temp & XAUI_POWERED_DOWN) == XAUI_POWERED_DOWN)
+			xaui_indirect_valid = 0;
+
+		status = ql_read_serdes_reg(qdev, xaui_reg, &temp);
+		if (status)
+			temp = XAUI_POWERED_DOWN;
+
+		if ((temp & XAUI_POWERED_DOWN) == XAUI_POWERED_DOWN)
+			xaui_direct_valid = 0;
+	} else {
+		/* We are NIC 1	*/
+		status = ql_read_other_func_serdes_reg(qdev, xaui_reg, &temp);
+		if (status)
+			temp = XAUI_POWERED_DOWN;
+		if ((temp & XAUI_POWERED_DOWN) == XAUI_POWERED_DOWN)
+			xaui_indirect_valid = 0;
+
+		status = ql_read_serdes_reg(qdev, xaui_reg, &temp);
+		if (status)
+			temp = XAUI_POWERED_DOWN;
+		if ((temp & XAUI_POWERED_DOWN) == XAUI_POWERED_DOWN)
+			xaui_direct_valid = 0;
+	}
+
+	/*
+	 * XFI register is shared so only need to read one
+	 * functions and then check the bits.
+	 */
+	status = ql_read_serdes_reg(qdev, 0x1E06, &temp);
+	if (status)
+		temp = 0;
+
+	if ((temp & XFI1_POWERED_UP) == XFI1_POWERED_UP) {
+		/* now see if i'm NIC 1 or NIC 2 */
+		if (qdev->func & 1)
+			/* I'm NIC 2, so the indirect (NIC1) xfi is up. */
+			xfi_indirect_valid = 1;
+		else
+			xfi_direct_valid = 1;
+	}
+	if ((temp & XFI2_POWERED_UP) == XFI2_POWERED_UP) {
+		/* now see if i'm NIC 1 or NIC 2 */
+		if (qdev->func & 1)
+			/* I'm NIC 2, so the indirect (NIC1) xfi is up. */
+			xfi_direct_valid = 1;
+		else
+			xfi_indirect_valid = 1;
+	}
+
+	if (qdev->func & 1) {
+		/* Function 2 is direct	*/
+		direct_ptr = mpi_coredump->serdes2_xaui_an;
+		indirect_ptr = mpi_coredump->serdes_xaui_an;
+	} else {
+		/* Function 1 is direct	*/
+		direct_ptr = mpi_coredump->serdes_xaui_an;
+		indirect_ptr = mpi_coredump->serdes2_xaui_an;
+	}
+
+	for (i = 0; i <= 0x000000034; i += 4, direct_ptr++, indirect_ptr++)
+		ql_get_both_serdes(qdev, i, direct_ptr, indirect_ptr,
+					xaui_direct_valid, xaui_indirect_valid);
+	if (qdev->func & 1) {
+		direct_ptr =
+			mpi_coredump->serdes2_xaui_hss_pcs;
+		indirect_ptr =
+			mpi_coredump->serdes_xaui_hss_pcs;
+	} else {
+		direct_ptr =
+			mpi_coredump->serdes_xaui_hss_pcs;
+		indirect_ptr =
+			mpi_coredump->serdes2_xaui_hss_pcs;
+	}
+
+	for (i = 0x800; i <= 0x880; i += 4, direct_ptr++, indirect_ptr++)
+		ql_get_both_serdes(qdev, i, direct_ptr, indirect_ptr,
+					xaui_direct_valid, xaui_indirect_valid);
+	if (qdev->func & 1) {
+		direct_ptr = mpi_coredump->serdes2_xfi_an;
+		indirect_ptr = mpi_coredump->serdes_xfi_an;
+	} else {
+		direct_ptr = mpi_coredump->serdes_xfi_an;
+		indirect_ptr = mpi_coredump->serdes2_xfi_an;
+	}
+
+	for (i = 0x1000; i <= 0x1034; i += 4, direct_ptr++, indirect_ptr++)
+		ql_get_both_serdes(qdev, i, direct_ptr, indirect_ptr,
+					xfi_direct_valid, xfi_indirect_valid);
+	if (qdev->func & 1) {
+		direct_ptr = mpi_coredump->serdes2_xfi_train;
+		indirect_ptr =
+			mpi_coredump->serdes_xfi_train;
+	} else {
+		direct_ptr = mpi_coredump->serdes_xfi_train;
+		indirect_ptr =
+			mpi_coredump->serdes2_xfi_train;
+	}
+
+	for (i = 0x1050; i <= 0x107c; i += 4, direct_ptr++, indirect_ptr++)
+		ql_get_both_serdes(qdev, i, direct_ptr, indirect_ptr,
+					xfi_direct_valid, xfi_indirect_valid);
+	if (qdev->func & 1) {
+		direct_ptr =
+			mpi_coredump->serdes2_xfi_hss_pcs;
+		indirect_ptr =
+			mpi_coredump->serdes_xfi_hss_pcs;
+	} else {
+		direct_ptr =
+			mpi_coredump->serdes_xfi_hss_pcs;
+		indirect_ptr =
+			mpi_coredump->serdes2_xfi_hss_pcs;
+	}
+
+	for (i = 0x1800; i <= 0x1838; i += 4, direct_ptr++, indirect_ptr++)
+		ql_get_both_serdes(qdev, i, direct_ptr, indirect_ptr,
+					xfi_direct_valid, xfi_indirect_valid);
+	if (qdev->func & 1) {
+		direct_ptr =
+			mpi_coredump->serdes2_xfi_hss_tx;
+		indirect_ptr =
+			mpi_coredump->serdes_xfi_hss_tx;
+	} else {
+		direct_ptr = mpi_coredump->serdes_xfi_hss_tx;
+		indirect_ptr =
+			mpi_coredump->serdes2_xfi_hss_tx;
+	}
+	for (i = 0x1c00; i <= 0x1c1f; i++, direct_ptr++, indirect_ptr++)
+		ql_get_both_serdes(qdev, i, direct_ptr, indirect_ptr,
+					xfi_direct_valid, xfi_indirect_valid);
+	if (qdev->func & 1) {
+		direct_ptr =
+			mpi_coredump->serdes2_xfi_hss_rx;
+		indirect_ptr =
+			mpi_coredump->serdes_xfi_hss_rx;
+	} else {
+		direct_ptr = mpi_coredump->serdes_xfi_hss_rx;
+		indirect_ptr =
+			mpi_coredump->serdes2_xfi_hss_rx;
+	}
+
+	for (i = 0x1c40; i <= 0x1c5f; i++, direct_ptr++, indirect_ptr++)
+		ql_get_both_serdes(qdev, i, direct_ptr, indirect_ptr,
+					xfi_direct_valid, xfi_indirect_valid);
+
+	if (qdev->func & 1) {
+		direct_ptr =
+			mpi_coredump->serdes2_xfi_hss_pll;
+		indirect_ptr =
+			mpi_coredump->serdes_xfi_hss_pll;
+	} else {
+		direct_ptr =
+			mpi_coredump->serdes_xfi_hss_pll;
+		indirect_ptr =
+			mpi_coredump->serdes2_xfi_hss_pll;
+	}
+	for (i = 0x1e00; i <= 0x1e1f; i++, direct_ptr++, indirect_ptr++)
+		ql_get_both_serdes(qdev, i, direct_ptr, indirect_ptr,
+					xfi_direct_valid, xfi_indirect_valid);
+	return 0;
+}
+
 /* Read out the ETS registers */
 static int ql_get_ets_regs(struct ql_adapter *qdev, u32 * buf)
 {
@@ -612,6 +887,111 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 
 	}
 
+	/* Rev C. Step 20a */
+	ql_build_coredump_seg_header(&mpi_coredump->xaui_an_hdr,
+			XAUI_AN_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes_xaui_an),
+			"XAUI AN Registers");
+
+	/* Rev C. Step 20b */
+	ql_build_coredump_seg_header(&mpi_coredump->xaui_hss_pcs_hdr,
+			XAUI_HSS_PCS_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes_xaui_hss_pcs),
+			"XAUI HSS PCS Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi_an_hdr, XFI_AN_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes_xfi_an),
+			"XFI AN Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi_train_hdr,
+			XFI_TRAIN_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes_xfi_train),
+			"XFI TRAIN Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi_hss_pcs_hdr,
+			XFI_HSS_PCS_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes_xfi_hss_pcs),
+			"XFI HSS PCS Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi_hss_tx_hdr,
+			XFI_HSS_TX_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes_xfi_hss_tx),
+			"XFI HSS TX Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi_hss_rx_hdr,
+			XFI_HSS_RX_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes_xfi_hss_rx),
+			"XFI HSS RX Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi_hss_pll_hdr,
+			XFI_HSS_PLL_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes_xfi_hss_pll),
+			"XFI HSS PLL Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xaui2_an_hdr,
+			XAUI2_AN_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes2_xaui_an),
+			"XAUI2 AN Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xaui2_hss_pcs_hdr,
+			XAUI2_HSS_PCS_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes2_xaui_hss_pcs),
+			"XAUI2 HSS PCS Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi2_an_hdr,
+			XFI2_AN_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes2_xfi_an),
+			"XFI2 AN Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi2_train_hdr,
+			XFI2_TRAIN_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes2_xfi_train),
+			"XFI2 TRAIN Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi2_hss_pcs_hdr,
+			XFI2_HSS_PCS_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes2_xfi_hss_pcs),
+			"XFI2 HSS PCS Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi2_hss_tx_hdr,
+			XFI2_HSS_TX_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes2_xfi_hss_tx),
+			"XFI2 HSS TX Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi2_hss_rx_hdr,
+			XFI2_HSS_RX_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes2_xfi_hss_rx),
+			"XFI2 HSS RX Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xfi2_hss_pll_hdr,
+			XFI2_HSS_PLL_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->serdes2_xfi_hss_pll),
+			"XFI2 HSS PLL Registers");
+
+	status = ql_get_serdes_regs(qdev, mpi_coredump);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed Dump of Serdes Registers. Status = 0x%.08x\n",
+			status);
+		goto err;
+	}
+
 	ql_build_coredump_seg_header(&mpi_coredump->core_regs_seg_hdr,
 				CORE_SEG_NUM,
 				sizeof(mpi_coredump->core_regs_seg_hdr) +
-- 
1.6.0.2

