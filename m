From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 7/8] qlge: Add xgmac reg blocks to firwmare dump.
Date: Fri, 15 Jan 2010 15:31:33 -0800
Message-ID: <1263598294-5685-8-git-send-email-ron.mercer@qlogic.com>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758614Ab0AOXiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:13 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c |   87 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 87 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 87e50d9..ec4349a 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -331,6 +331,76 @@ static int ql_get_serdes_regs(struct ql_adapter *qdev,
 	return 0;
 }
 
+static int ql_read_other_func_xgmac_reg(struct ql_adapter *qdev, u32 reg,
+							u32 *data)
+{
+	int status = 0;
+
+	/* wait for reg to come ready */
+	status = ql_wait_other_func_reg_rdy(qdev, XGMAC_ADDR / 4,
+						XGMAC_ADDR_RDY, XGMAC_ADDR_XME);
+	if (status)
+		goto exit;
+
+	/* set up for reg read */
+	ql_write_other_func_reg(qdev, XGMAC_ADDR / 4, reg | XGMAC_ADDR_R);
+
+	/* wait for reg to come ready */
+	status = ql_wait_other_func_reg_rdy(qdev, XGMAC_ADDR / 4,
+						XGMAC_ADDR_RDY, XGMAC_ADDR_XME);
+	if (status)
+		goto exit;
+
+	/* get the data */
+	*data = ql_read_other_func_reg(qdev, XGMAC_DATA / 4);
+exit:
+	return status;
+}
+
+/* Read the 400 xgmac control/statistics registers
+ * skipping unused locations.
+ */
+static int ql_get_xgmac_regs(struct ql_adapter *qdev, u32 * buf,
+					unsigned int other_function)
+{
+	int status = 0;
+	int i;
+
+	for (i = PAUSE_SRC_LO; i < XGMAC_REGISTER_END; i += 4, buf++) {
+		/* We're reading 400 xgmac registers, but we filter out
+		 * serveral locations that are non-responsive to reads.
+		 */
+		if ((i == 0x00000114) ||
+			(i == 0x00000118) ||
+			(i == 0x0000013c) ||
+			(i == 0x00000140) ||
+			(i > 0x00000150 && i < 0x000001fc) ||
+			(i > 0x00000278 && i < 0x000002a0) ||
+			(i > 0x000002c0 && i < 0x000002cf) ||
+			(i > 0x000002dc && i < 0x000002f0) ||
+			(i > 0x000003c8 && i < 0x00000400) ||
+			(i > 0x00000400 && i < 0x00000410) ||
+			(i > 0x00000410 && i < 0x00000420) ||
+			(i > 0x00000420 && i < 0x00000430) ||
+			(i > 0x00000430 && i < 0x00000440) ||
+			(i > 0x00000440 && i < 0x00000450) ||
+			(i > 0x00000450 && i < 0x00000500) ||
+			(i > 0x0000054c && i < 0x00000568) ||
+			(i > 0x000005c8 && i < 0x00000600)) {
+			if (other_function)
+				status =
+				ql_read_other_func_xgmac_reg(qdev, i, buf);
+			else
+				status = ql_read_xgmac_reg(qdev, i, buf);
+
+			if (status)
+				*buf = 0xdeadbeef;
+			break;
+		}
+	}
+	return status;
+}
+
 static int ql_get_ets_regs(struct ql_adapter *qdev, u32 * buf)
 {
 	int status = 0;
@@ -706,6 +776,17 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 			sizeof(struct mpi_coredump_segment_header) +
 			sizeof(mpi_coredump->nic2_regs), "NIC2 Registers");
 
+	/* Get XGMac registers. (Segment 18, Rev C. step 21) */
+	ql_build_coredump_seg_header(&mpi_coredump->xgmac1_seg_hdr,
+			NIC1_XGMAC_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->xgmac1), "NIC1 XGMac Registers");
+
+	ql_build_coredump_seg_header(&mpi_coredump->xgmac2_seg_hdr,
+			NIC2_XGMAC_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->xgmac2), "NIC2 XGMac Registers");
+
 	if (qdev->func & 1) {
 		/* Odd means our function is NIC 2 */
 		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
@@ -715,6 +796,9 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
 			mpi_coredump->nic_regs[i] =
 			ql_read_other_func_reg(qdev, (i * sizeof(u32)) / 4);
+
+		ql_get_xgmac_regs(qdev, &mpi_coredump->xgmac2[0], 0);
+		ql_get_xgmac_regs(qdev, &mpi_coredump->xgmac1[0], 1);
 	} else {
 		/* Even means our function is NIC 1 */
 		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
@@ -723,6 +807,9 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
 			mpi_coredump->nic2_regs[i] =
 			ql_read_other_func_reg(qdev, (i * sizeof(u32)) / 4);
+
+		ql_get_xgmac_regs(qdev, &mpi_coredump->xgmac1[0], 0);
+		ql_get_xgmac_regs(qdev, &mpi_coredump->xgmac2[0], 1);
 	}
 
 	/* Rev C. Step 20a */
-- 
1.6.0.2

