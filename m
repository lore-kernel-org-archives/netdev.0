From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 6/8] qlge: Add serdes reg blocks dump to firmware dump.
Date: Fri, 15 Jan 2010 15:31:32 -0800
Message-ID: <1263598294-5685-7-git-send-email-ron.mercer@qlogic.com>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758662Ab0AOXiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:13 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c |  417 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 417 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 1812813..87e50d9 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -19,6 +19,318 @@ static u32 ql_read_other_func_reg(struct ql_adapter *qdev,
 	return reg_val;
 }
 
+/* Write a NIC register from the alternate function. */
+static int ql_write_other_func_reg(struct ql_adapter *qdev,
+					u32 reg, u32 reg_val)
+{
+	u32 register_to_read;
+	int status = 0;
+
+	register_to_read = MPI_NIC_REG_BLOCK
+				| MPI_NIC_READ
+				| (qdev->alt_func << MPI_NIC_FUNCTION_SHIFT)
+				| reg;
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
+/* Read out the SERDES registers */
+static int ql_read_serdes_reg(struct ql_adapter *qdev, u32 reg, u32 * data)
+{
+	int status;
+
+	/* wait for reg to come ready */
+	status = ql_wait_reg_rdy(qdev, XG_SERDES_ADDR, XG_SERDES_ADDR_RDY, 0);
+	if (status)
+		goto exit;
+
+	/* set up for reg read */
+	ql_write32(qdev, XG_SERDES_ADDR, reg | PROC_ADDR_R);
+
+	/* wait for reg to come ready */
+	status = ql_wait_reg_rdy(qdev, XG_SERDES_ADDR, XG_SERDES_ADDR_RDY, 0);
+	if (status)
+		goto exit;
+
+	/* get the data */
+	*data = ql_read32(qdev, XG_SERDES_DATA);
+exit:
+	return status;
+}
+
+static void ql_get_both_serdes(struct ql_adapter *qdev, u32 addr,
+			u32 *direct_ptr, u32 *indirect_ptr,
+			unsigned int direct_valid, unsigned int indirect_valid)
+{
+	unsigned int status;
+
+	status = 1;
+	if (direct_valid)
+		status = ql_read_serdes_reg(qdev, addr, direct_ptr);
+	/* Dead fill any failures or invalids. */
+	if (status)
+		*direct_ptr = 0xDEADBEEF;
+
+	status = 1;
+	if (indirect_valid)
+		status = ql_read_other_func_serdes_reg(
+						qdev, addr, indirect_ptr);
+	/* Dead fill any failures or invalids. */
+	if (status)
+		*indirect_ptr = 0xDEADBEEF;
+}
+
+static int ql_get_serdes_regs(struct ql_adapter *qdev,
+				struct ql_mpi_coredump *mpi_coredump)
+{
+	int status;
+	unsigned int xfi_direct_valid, xfi_indirect_valid, xaui_direct_valid;
+	unsigned int xaui_indirect_valid, i;
+	u32 *direct_ptr, temp;
+	u32 *indirect_ptr;
+
+	xfi_direct_valid = xfi_indirect_valid = 0;
+	xaui_direct_valid = xaui_indirect_valid = 1;
+
+	/* The XAUI needs to be read out per port */
+	if (qdev->func & 1) {
+		/* We are NIC 2	*/
+		status = ql_read_other_func_serdes_reg(qdev,
+				XG_SERDES_XAUI_HSS_PCS_START, &temp);
+		if (status)
+			temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
+		if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
+					XG_SERDES_ADDR_XAUI_PWR_DOWN)
+			xaui_indirect_valid = 0;
+
+		status = ql_read_serdes_reg(qdev,
+				XG_SERDES_XAUI_HSS_PCS_START, &temp);
+		if (status)
+			temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
+
+		if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
+					XG_SERDES_ADDR_XAUI_PWR_DOWN)
+			xaui_direct_valid = 0;
+	} else {
+		/* We are NIC 1	*/
+		status = ql_read_other_func_serdes_reg(qdev,
+				XG_SERDES_XAUI_HSS_PCS_START, &temp);
+		if (status)
+			temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
+		if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
+					XG_SERDES_ADDR_XAUI_PWR_DOWN)
+			xaui_indirect_valid = 0;
+
+		status = ql_read_serdes_reg(qdev,
+				XG_SERDES_XAUI_HSS_PCS_START, &temp);
+		if (status)
+			temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
+		if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
+					XG_SERDES_ADDR_XAUI_PWR_DOWN)
+			xaui_direct_valid = 0;
+	}
+
+	/*
+	 * XFI register is shared so only need to read one
+	 * functions and then check the bits.
+	 */
+	status = ql_read_serdes_reg(qdev, XG_SERDES_ADDR_STS, &temp);
+	if (status)
+		temp = 0;
+
+	if ((temp & XG_SERDES_ADDR_XFI1_PWR_UP) ==
+					XG_SERDES_ADDR_XFI1_PWR_UP) {
+		/* now see if i'm NIC 1 or NIC 2 */
+		if (qdev->func & 1)
+			/* I'm NIC 2, so the indirect (NIC1) xfi is up. */
+			xfi_indirect_valid = 1;
+		else
+			xfi_direct_valid = 1;
+	}
+	if ((temp & XG_SERDES_ADDR_XFI2_PWR_UP) ==
+					XG_SERDES_ADDR_XFI2_PWR_UP) {
+		/* now see if i'm NIC 1 or NIC 2 */
+		if (qdev->func & 1)
+			/* I'm NIC 2, so the indirect (NIC1) xfi is up. */
+			xfi_direct_valid = 1;
+		else
+			xfi_indirect_valid = 1;
+	}
+
+	/* Get XAUI_AN register block. */
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
+
+	/* Get XAUI_HSS_PCS register block. */
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
+
+	/* Get XAUI_XFI_AN register block. */
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
+
+	/* Get XAUI_XFI_TRAIN register block. */
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
+
+	/* Get XAUI_XFI_HSS_PCS register block. */
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
+
+	/* Get XAUI_XFI_HSS_TX register block. */
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
+
+	/* Get XAUI_XFI_HSS_RX register block. */
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
+
+	/* Get XAUI_XFI_HSS_PLL register block. */
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
 static int ql_get_ets_regs(struct ql_adapter *qdev, u32 * buf)
 {
 	int status = 0;
@@ -413,6 +725,111 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 			ql_read_other_func_reg(qdev, (i * sizeof(u32)) / 4);
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

