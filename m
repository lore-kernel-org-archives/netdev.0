From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/8] qlge: Add probe regs to firmware dump.
Date: Fri, 15 Jan 2010 15:31:29 -0800
Message-ID: <1263598294-5685-4-git-send-email-ron.mercer@qlogic.com>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758447Ab0AOXiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:11 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c |   54 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 1d02614..913ca1e 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -123,6 +123,53 @@ static int ql_get_mpi_regs(struct ql_adapter *qdev, u32 * buf,
 	return status;
 }
 
+/* Read the ASIC probe dump */
+static unsigned int *ql_get_probe(struct ql_adapter *qdev, u32 clock,
+					u32 valid, u32 *buf)
+{
+	u32 module, mux_sel, probe, lo_val, hi_val;
+
+	for (module = 0; module < PRB_MX_ADDR_MAX_MODS; module++) {
+		if (!((valid >> module) & 1))
+			continue;
+		for (mux_sel = 0; mux_sel < PRB_MX_ADDR_MAX_MUX; mux_sel++) {
+			probe = clock
+				| PRB_MX_ADDR_ARE
+				| mux_sel
+				| (module << PRB_MX_ADDR_MOD_SEL_SHIFT);
+			ql_write32(qdev, PRB_MX_ADDR, probe);
+			lo_val = ql_read32(qdev, PRB_MX_DATA);
+			if (mux_sel == 0) {
+				*buf = probe;
+				buf++;
+			}
+			probe |= PRB_MX_ADDR_UP;
+			ql_write32(qdev, PRB_MX_ADDR, probe);
+			hi_val = ql_read32(qdev, PRB_MX_DATA);
+			*buf = lo_val;
+			buf++;
+			*buf = hi_val;
+			buf++;
+		}
+	}
+	return buf;
+}
+
+static int ql_get_probe_dump(struct ql_adapter *qdev, unsigned int *buf)
+{
+	/* First we have to enable the probe mux */
+	ql_write_mpi_reg(qdev, MPI_TEST_FUNC_PRB_CTL, MPI_TEST_FUNC_PRB_EN);
+	buf = ql_get_probe(qdev, PRB_MX_ADDR_SYS_CLOCK,
+			PRB_MX_ADDR_VALID_SYS_MOD, buf);
+	buf = ql_get_probe(qdev, PRB_MX_ADDR_PCI_CLOCK,
+			PRB_MX_ADDR_VALID_PCI_MOD, buf);
+	buf = ql_get_probe(qdev, PRB_MX_ADDR_XGM_CLOCK,
+			PRB_MX_ADDR_VALID_XGM_MOD, buf);
+	buf = ql_get_probe(qdev, PRB_MX_ADDR_FC_CLOCK,
+			PRB_MX_ADDR_VALID_FC_MOD, buf);
+	return 0;
+
+}
 
 /* Read out the routing index registers */
 static int ql_get_routing_index_registers(struct ql_adapter *qdev, u32 *buf)
@@ -558,6 +605,13 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	if (status)
 		goto err;
 
+	ql_build_coredump_seg_header(&mpi_coredump->probe_dump_seg_hdr,
+				PROBE_DUMP_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->probe_dump),
+				"Probe Dump");
+	ql_get_probe_dump(qdev, &mpi_coredump->probe_dump[0]);
+
 	ql_build_coredump_seg_header(&mpi_coredump->routing_reg_seg_hdr,
 				ROUTING_INDEX_SEG_NUM,
 				sizeof(struct mpi_coredump_segment_header)
-- 
1.6.0.2

