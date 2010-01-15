From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 5/8] qlge: Add alternate function's reg dump to fw dump.
Date: Fri, 15 Jan 2010 15:31:31 -0800
Message-ID: <1263598294-5685-6-git-send-email-ron.mercer@qlogic.com>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758659Ab0AOXiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:12 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get the 2nd (other) nic function register values.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 833cfd7..1812813 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -1,5 +1,23 @@
 #include "qlge.h"
 
+/* Read a NIC register from the alternate function. */
+static u32 ql_read_other_func_reg(struct ql_adapter *qdev,
+						u32 reg)
+{
+	u32 register_to_read;
+	u32 reg_val;
+	unsigned int status = 0;
+
+	register_to_read = MPI_NIC_REG_BLOCK
+				| MPI_NIC_READ
+				| (qdev->alt_func << MPI_NIC_FUNCTION_SHIFT)
+				| reg;
+	status = ql_read_mpi_reg(qdev, register_to_read, &reg_val);
+	if (status != 0)
+		return 0xffffffff;
+
+	return reg_val;
+}
 
 static int ql_get_ets_regs(struct ql_adapter *qdev, u32 * buf)
 {
@@ -371,16 +389,28 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 			sizeof(struct mpi_coredump_segment_header) +
 			sizeof(mpi_coredump->nic_regs), "NIC1 Registers");
 
+	ql_build_coredump_seg_header(&mpi_coredump->nic2_regs_seg_hdr,
+			NIC2_CONTROL_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->nic2_regs), "NIC2 Registers");
+
 	if (qdev->func & 1) {
 		/* Odd means our function is NIC 2 */
 		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
 			mpi_coredump->nic2_regs[i] =
 					 ql_read32(qdev, i * sizeof(u32));
+
+		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
+			mpi_coredump->nic_regs[i] =
+			ql_read_other_func_reg(qdev, (i * sizeof(u32)) / 4);
 	} else {
 		/* Even means our function is NIC 1 */
 		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
 			mpi_coredump->nic_regs[i] =
 					ql_read32(qdev, i * sizeof(u32));
+		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
+			mpi_coredump->nic2_regs[i] =
+			ql_read_other_func_reg(qdev, (i * sizeof(u32)) / 4);
 	}
 
 	ql_build_coredump_seg_header(&mpi_coredump->core_regs_seg_hdr,
-- 
1.6.0.2

