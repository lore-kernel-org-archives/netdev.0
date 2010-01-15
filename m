From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 4/8] qlge: Add RAM dump to firmware dump.
Date: Fri, 15 Jan 2010 15:31:30 -0800
Message-ID: <1263598294-5685-5-git-send-email-ron.mercer@qlogic.com>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758657Ab0AOXiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:12 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h     |    3 ++
 drivers/net/qlge/qlge_dbg.c |   35 ++++++++++++++++++++
 drivers/net/qlge/qlge_mpi.c |   76 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index bbdd388..05feb03 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2225,6 +2225,9 @@ int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data);
 int ql_write_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 data);
 int ql_unpause_mpi_risc(struct ql_adapter *qdev);
 int ql_pause_mpi_risc(struct ql_adapter *qdev);
+int ql_hard_reset_mpi_risc(struct ql_adapter *qdev);
+int ql_dump_risc_ram_area(struct ql_adapter *qdev, void *buf,
+		u32 ram_addr, int word_count);
 int ql_core_dump(struct ql_adapter *qdev,
 		struct ql_mpi_coredump *mpi_coredump);
 int ql_mb_about_fw(struct ql_adapter *qdev);
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 913ca1e..833cfd7 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -647,6 +647,41 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 			"Failed RISC unpause. Status = 0x%.08x\n", status);
 		goto err;
 	}
+
+	/* Reset the RISC so we can dump RAM */
+	status = ql_hard_reset_mpi_risc(qdev);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed RISC reset. Status = 0x%.08x\n", status);
+		goto err;
+	}
+
+	ql_build_coredump_seg_header(&mpi_coredump->code_ram_seg_hdr,
+				WCS_RAM_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->code_ram),
+				"WCS RAM");
+	status = ql_dump_risc_ram_area(qdev, &mpi_coredump->code_ram[0],
+					CODE_RAM_ADDR, CODE_RAM_CNT);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed Dump of CODE RAM. Status = 0x%.08x\n", status);
+		goto err;
+	}
+
+	/* Insert the segment header */
+	ql_build_coredump_seg_header(&mpi_coredump->memc_ram_seg_hdr,
+				MEMC_RAM_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->memc_ram),
+				"MEMC RAM");
+	status = ql_dump_risc_ram_area(qdev, &mpi_coredump->memc_ram[0],
+					MEMC_RAM_ADDR, MEMC_RAM_CNT);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed Dump of MEMC RAM. Status = 0x%.08x\n", status);
+		goto err;
+	}
 err:
 	ql_sem_unlock(qdev, SEM_PROC_REG_MASK); /* does flush too */
 	return status;
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 242b1ea..3304eb7 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -30,6 +30,25 @@ int ql_pause_mpi_risc(struct ql_adapter *qdev)
 	return (count == 0) ? -ETIMEDOUT : 0;
 }
 
+int ql_hard_reset_mpi_risc(struct ql_adapter *qdev)
+{
+	u32 tmp;
+	int count = UDELAY_COUNT;
+
+	/* Reset the RISC */
+	ql_write32(qdev, CSR, CSR_CMD_SET_RST);
+	do {
+		tmp = ql_read32(qdev, CSR);
+		if (tmp & CSR_RR) {
+			ql_write32(qdev, CSR, CSR_CMD_CLR_RST);
+			break;
+		}
+		mdelay(UDELAY_DELAY);
+		count--;
+	} while (count);
+	return (count == 0) ? -ETIMEDOUT : 0;
+}
+
 int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data)
 {
 	int status;
@@ -728,6 +747,63 @@ int ql_mb_set_port_cfg(struct ql_adapter *qdev)
 	return status;
 }
 
+int ql_mb_dump_ram(struct ql_adapter *qdev, u64 req_dma, u32 addr,
+	u32 size)
+{
+	int status = 0;
+	struct mbox_params mbc;
+	struct mbox_params *mbcp = &mbc;
+
+	memset(mbcp, 0, sizeof(struct mbox_params));
+
+	mbcp->in_count = 9;
+	mbcp->out_count = 1;
+
+	mbcp->mbox_in[0] = MB_CMD_DUMP_RISC_RAM;
+	mbcp->mbox_in[1] = LSW(addr);
+	mbcp->mbox_in[2] = MSW(req_dma);
+	mbcp->mbox_in[3] = LSW(req_dma);
+	mbcp->mbox_in[4] = MSW(size);
+	mbcp->mbox_in[5] = LSW(size);
+	mbcp->mbox_in[6] = MSW(MSD(req_dma));
+	mbcp->mbox_in[7] = LSW(MSD(req_dma));
+	mbcp->mbox_in[8] = MSW(addr);
+
+
+	status = ql_mailbox_command(qdev, mbcp);
+	if (status)
+		return status;
+
+	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed to dump risc RAM.\n");
+		status = -EIO;
+	}
+	return status;
+}
+
+/* Issue a mailbox command to dump RISC RAM. */
+int ql_dump_risc_ram_area(struct ql_adapter *qdev, void *buf,
+		u32 ram_addr, int word_count)
+{
+	int status;
+	char *my_buf;
+	dma_addr_t buf_dma;
+
+	my_buf = pci_alloc_consistent(qdev->pdev, word_count * sizeof(u32),
+					&buf_dma);
+	if (!my_buf)
+		return -EIO;
+
+	status = ql_mb_dump_ram(qdev, buf_dma, ram_addr, word_count);
+	if (!status)
+		memcpy(buf, my_buf, word_count * sizeof(u32));
+
+	pci_free_consistent(qdev->pdev, word_count * sizeof(u32), my_buf,
+				buf_dma);
+	return status;
+}
+
 /* Get link settings and maximum frame size settings
  * for the current port.
  * Most likely will block.
-- 
1.6.0.2

