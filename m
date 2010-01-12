From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 5/8] qlge: Add alternate function's reg dump to fw dump.
Date: Mon, 11 Jan 2010 17:13:02 -0800
Message-ID: <1263258785-5112-6-git-send-email-ron.mercer@qlogic.com>
References: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47651 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab0ALBTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 20:19:46 -0500
In-Reply-To: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get the 2nd (other) nic functions register values.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c |   79 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 48ff0fd..63822f7 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -1,5 +1,69 @@
 #include "qlge.h"
 
+static u32 ql_get_other_func_num(struct ql_adapter *qdev)
+{
+	u32 other_function;
+	int status;
+	u32 test_logic;
+	u32 nic1_function_num = 0xffffffff;
+	u32 nic2_function_num = 0xffffffff;
+	u32 fc1_function_num = 0xffffffff;
+	u32 fc2_function_num = 0xffffffff;
+
+	status = ql_read_mpi_reg(qdev, TEST_LOGIC_FUNC_PORT_CONFIG,
+					&test_logic);
+	if (status)
+		return 0xffffffff;
+
+	/* First, establish the function number of the other PCI function */
+	if (test_logic & FC1_FUNCTION_ENABLE)
+		fc1_function_num = (test_logic & FC1_FUNCTION_MASK) >>
+					FC1_FUNCTION_SHIFT;
+	if (test_logic & FC2_FUNCTION_ENABLE)
+		fc2_function_num = (test_logic & FC2_FUNCTION_MASK) >>
+					FC2_FUNCTION_SHIFT;
+	if (test_logic & NIC1_FUNCTION_ENABLE)
+		nic1_function_num = (test_logic & NIC1_FUNCTION_MASK) >>
+					NIC1_FUNCTION_SHIFT;
+	if (test_logic & NIC2_FUNCTION_ENABLE)
+		nic2_function_num = (test_logic & NIC2_FUNCTION_MASK) >>
+					NIC2_FUNCTION_SHIFT;
+	if (qdev->func == nic1_function_num)
+		other_function = nic2_function_num;
+	else
+		other_function = nic1_function_num;
+
+	return other_function;
+}
+
+static u32 ql_read_other_func_reg(struct ql_adapter *qdev,
+						u32 reg)
+{
+	u32 other_function;
+	u32 register_to_read;
+	u32 reg_val;
+	unsigned int status = 0;
+
+	other_function = ql_get_other_func_num(qdev);
+
+	/* The other function is not enabled so we don't need
+	 * to read anything out of it.
+	 */
+	if (other_function == 0xffffffff)
+		return other_function;
+
+	/* The other function is there so now we need to
+	 * read the requested register.
+	 */
+	register_to_read = REG_BLOCK | MPI_READ |
+				(other_function << FUNCTION_SHIFT) | reg;
+	status = ql_read_mpi_reg(qdev, register_to_read, &reg_val);
+	if (status != 0)
+		return 0xffffffff;
+
+	return reg_val;
+}
+
 /* Read out the SERDES registers */
 int ql_read_serdes_reg(struct ql_adapter *qdev, u32 reg, u32 * data)
 {
@@ -521,16 +585,31 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 			sizeof(struct mpi_coredump_segment_header) +
 			sizeof(mpi_coredump->nic_regs), "NIC1 Registers");
 
+	ql_build_coredump_seg_header(&mpi_coredump->nic2_regs_seg_hdr,
+			NIC2_CONTROL_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->nic2_regs), "NIC2 Registers");
+
 	if (qdev->func & 1) {
 		/* Odd means our function is NIC 2 */
 		for (i = 0; i < 64; i++)
 			mpi_coredump->nic2_regs[i] =
 					 ql_read32(qdev, i * sizeof(u32));
+
+		for (i = 0; i < 64; i++)
+			mpi_coredump->nic_regs[i] =
+			ql_read_other_func_reg(qdev, (i * sizeof(u32)) / 4);
+
 	} else {
 		/* Even means our function is NIC 1 */
 		for (i = 0; i < 64; i++)
 			mpi_coredump->nic_regs[i] =
 					ql_read32(qdev, i * sizeof(u32));
+
+		for (i = 0; i < 64; i++)
+			mpi_coredump->nic2_regs[i] =
+			ql_read_other_func_reg(qdev, (i * sizeof(u32)) / 4);
+
 	}
 
 	ql_build_coredump_seg_header(&mpi_coredump->core_regs_seg_hdr,
-- 
1.6.0.2

