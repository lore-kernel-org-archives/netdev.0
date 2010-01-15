From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/8] qlge: Add basic firmware dump.
Date: Fri, 15 Jan 2010 15:31:28 -0800
Message-ID: <1263598294-5685-3-git-send-email-ron.mercer@qlogic.com>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758655Ab0AOXiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:10 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding the infrstructure and basic data for the firmware
core dump.
The firmware coredump is turned OFF by default.  There will be no
memory allocations for data dumps to the log.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    6 +
 drivers/net/qlge/qlge_dbg.c  |  523 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/qlge/qlge_main.c |   20 ++
 drivers/net/qlge/qlge_mpi.c  |   73 ++++++
 4 files changed, 622 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index a265325..bbdd388 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2211,6 +2211,7 @@ extern int ql_write_cfg(struct ql_adapter *qdev, void *ptr, int size, u32 bit,
 void ql_queue_fw_error(struct ql_adapter *qdev);
 void ql_mpi_work(struct work_struct *work);
 void ql_mpi_reset_work(struct work_struct *work);
+void ql_mpi_core_to_log(struct work_struct *work);
 int ql_wait_reg_rdy(struct ql_adapter *qdev, u32 reg, u32 bit, u32 ebit);
 void ql_queue_asic_error(struct ql_adapter *qdev);
 u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
@@ -2221,6 +2222,11 @@ void ql_mpi_port_cfg_work(struct work_struct *work);
 int ql_mb_get_fw_state(struct ql_adapter *qdev);
 int ql_cam_route_initialize(struct ql_adapter *qdev);
 int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data);
+int ql_write_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 data);
+int ql_unpause_mpi_risc(struct ql_adapter *qdev);
+int ql_pause_mpi_risc(struct ql_adapter *qdev);
+int ql_core_dump(struct ql_adapter *qdev,
+		struct ql_mpi_coredump *mpi_coredump);
 int ql_mb_about_fw(struct ql_adapter *qdev);
 int ql_wol(struct ql_adapter *qdev);
 int ql_mb_wol_set_magic(struct ql_adapter *qdev, u32 enable_wol);
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 9f58c47..1d02614 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -91,6 +91,179 @@ err:
 	return status;
 }
 
+/* Read the MPI Processor shadow registers */
+static int ql_get_mpi_shadow_regs(struct ql_adapter *qdev, u32 * buf)
+{
+	u32 i;
+	int status;
+
+	for (i = 0; i < MPI_CORE_SH_REGS_CNT; i++, buf++) {
+		status = ql_write_mpi_reg(qdev, RISC_124,
+				(SHADOW_OFFSET | i << SHADOW_REG_SHIFT));
+		if (status)
+			goto end;
+		status = ql_read_mpi_reg(qdev, RISC_127, buf);
+		if (status)
+			goto end;
+	}
+end:
+	return status;
+}
+
+/* Read the MPI Processor core registers */
+static int ql_get_mpi_regs(struct ql_adapter *qdev, u32 * buf,
+				u32 offset, u32 count)
+{
+	int i, status = 0;
+	for (i = 0; i < count; i++, buf++) {
+		status = ql_read_mpi_reg(qdev, offset + i, buf);
+		if (status)
+			return status;
+	}
+	return status;
+}
+
+
+/* Read out the routing index registers */
+static int ql_get_routing_index_registers(struct ql_adapter *qdev, u32 *buf)
+{
+	int status;
+	u32 type, index, index_max;
+	u32 result_index;
+	u32 result_data;
+	u32 val;
+
+	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
+	if (status)
+		return status;
+
+	for (type = 0; type < 4; type++) {
+		if (type < 2)
+			index_max = 8;
+		else
+			index_max = 16;
+		for (index = 0; index < index_max; index++) {
+			val = RT_IDX_RS
+				| (type << RT_IDX_TYPE_SHIFT)
+				| (index << RT_IDX_IDX_SHIFT);
+			ql_write32(qdev, RT_IDX, val);
+			result_index = 0;
+			while ((result_index & RT_IDX_MR) == 0)
+				result_index = ql_read32(qdev, RT_IDX);
+			result_data = ql_read32(qdev, RT_DATA);
+			*buf = type;
+			buf++;
+			*buf = index;
+			buf++;
+			*buf = result_index;
+			buf++;
+			*buf = result_data;
+			buf++;
+		}
+	}
+	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
+	return status;
+}
+
+/* Read out the MAC protocol registers */
+static void ql_get_mac_protocol_registers(struct ql_adapter *qdev, u32 *buf)
+{
+	u32 result_index, result_data;
+	u32 type;
+	u32 index;
+	u32 offset;
+	u32 val;
+	u32 initial_val = MAC_ADDR_RS;
+	u32 max_index;
+	u32 max_offset;
+
+	for (type = 0; type < MAC_ADDR_TYPE_COUNT; type++) {
+		switch (type) {
+
+		case 0: /* CAM */
+			initial_val |= MAC_ADDR_ADR;
+			max_index = MAC_ADDR_MAX_CAM_ENTRIES;
+			max_offset = MAC_ADDR_MAX_CAM_WCOUNT;
+			break;
+		case 1: /* Multicast MAC Address */
+			max_index = MAC_ADDR_MAX_CAM_WCOUNT;
+			max_offset = MAC_ADDR_MAX_CAM_WCOUNT;
+			break;
+		case 2: /* VLAN filter mask */
+		case 3: /* MC filter mask */
+			max_index = MAC_ADDR_MAX_CAM_WCOUNT;
+			max_offset = MAC_ADDR_MAX_CAM_WCOUNT;
+			break;
+		case 4: /* FC MAC addresses */
+			max_index = MAC_ADDR_MAX_FC_MAC_ENTRIES;
+			max_offset = MAC_ADDR_MAX_FC_MAC_WCOUNT;
+			break;
+		case 5: /* Mgmt MAC addresses */
+			max_index = MAC_ADDR_MAX_MGMT_MAC_ENTRIES;
+			max_offset = MAC_ADDR_MAX_MGMT_MAC_WCOUNT;
+			break;
+		case 6: /* Mgmt VLAN addresses */
+			max_index = MAC_ADDR_MAX_MGMT_VLAN_ENTRIES;
+			max_offset = MAC_ADDR_MAX_MGMT_VLAN_WCOUNT;
+			break;
+		case 7: /* Mgmt IPv4 address */
+			max_index = MAC_ADDR_MAX_MGMT_V4_ENTRIES;
+			max_offset = MAC_ADDR_MAX_MGMT_V4_WCOUNT;
+			break;
+		case 8: /* Mgmt IPv6 address */
+			max_index = MAC_ADDR_MAX_MGMT_V6_ENTRIES;
+			max_offset = MAC_ADDR_MAX_MGMT_V6_WCOUNT;
+			break;
+		case 9: /* Mgmt TCP/UDP Dest port */
+			max_index = MAC_ADDR_MAX_MGMT_TU_DP_ENTRIES;
+			max_offset = MAC_ADDR_MAX_MGMT_TU_DP_WCOUNT;
+			break;
+		default:
+			printk(KERN_ERR"Bad type!!! 0x%08x\n", type);
+			max_index = 0;
+			max_offset = 0;
+			break;
+		}
+		for (index = 0; index < max_index; index++) {
+			for (offset = 0; offset < max_offset; offset++) {
+				val = initial_val
+					| (type << MAC_ADDR_TYPE_SHIFT)
+					| (index << MAC_ADDR_IDX_SHIFT)
+					| (offset);
+				ql_write32(qdev, MAC_ADDR_IDX, val);
+				result_index = 0;
+				while ((result_index & MAC_ADDR_MR) == 0) {
+					result_index = ql_read32(qdev,
+								MAC_ADDR_IDX);
+				}
+				result_data = ql_read32(qdev, MAC_ADDR_DATA);
+				*buf = result_index;
+				buf++;
+				*buf = result_data;
+				buf++;
+			}
+		}
+	}
+}
+
+static void ql_get_sem_registers(struct ql_adapter *qdev, u32 *buf)
+{
+	u32 func_num, reg, reg_val;
+	int status;
+
+	for (func_num = 0; func_num < MAX_SEMAPHORE_FUNCTIONS ; func_num++) {
+		reg = MPI_NIC_REG_BLOCK
+			| (func_num << MPI_NIC_FUNCTION_SHIFT)
+			| (SEM / 4);
+		status = ql_read_mpi_reg(qdev, reg, &reg_val);
+		*buf = reg_val;
+		/* if the read failed then dead fill the element. */
+		if (!status)
+			*buf = 0xdeadbeef;
+		buf++;
+	}
+}
+
 /* Create a coredump segment header */
 static void ql_build_coredump_seg_header(
 		struct mpi_coredump_segment_header *seg_hdr,
@@ -103,6 +276,329 @@ static void ql_build_coredump_seg_header(
 	memcpy(seg_hdr->description, desc, (sizeof(seg_hdr->description)) - 1);
 }
 
+/*
+ * This function should be called when a coredump / probedump
+ * is to be extracted from the HBA. It is assumed there is a
+ * qdev structure that contains the base address of the register
+ * space for this function as well as a coredump structure that
+ * will contain the dump.
+ */
+int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
+{
+	int status;
+	int i;
+
+	if (!mpi_coredump) {
+		QPRINTK(qdev, DRV, ERR,
+			"No memory available.\n");
+		return -ENOMEM;
+	}
+
+	/* Try to get the spinlock, but dont worry if
+	 * it isn't available.  If the firmware died it
+	 * might be holding the sem.
+	 */
+	ql_sem_spinlock(qdev, SEM_PROC_REG_MASK);
+
+	status = ql_pause_mpi_risc(qdev);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed RISC pause. Status = 0x%.08x\n", status);
+		goto err;
+	}
+
+	/* Insert the global header */
+	memset(&(mpi_coredump->mpi_global_header), 0,
+		sizeof(struct mpi_coredump_global_header));
+	mpi_coredump->mpi_global_header.cookie = MPI_COREDUMP_COOKIE;
+	mpi_coredump->mpi_global_header.headerSize =
+		sizeof(struct mpi_coredump_global_header);
+	mpi_coredump->mpi_global_header.imageSize =
+		sizeof(struct ql_mpi_coredump);
+	memcpy(mpi_coredump->mpi_global_header.idString, "MPI Coredump",
+		sizeof(mpi_coredump->mpi_global_header.idString));
+
+	/* Get generic NIC reg dump */
+	ql_build_coredump_seg_header(&mpi_coredump->nic_regs_seg_hdr,
+			NIC1_CONTROL_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->nic_regs), "NIC1 Registers");
+
+	if (qdev->func & 1) {
+		/* Odd means our function is NIC 2 */
+		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
+			mpi_coredump->nic2_regs[i] =
+					 ql_read32(qdev, i * sizeof(u32));
+	} else {
+		/* Even means our function is NIC 1 */
+		for (i = 0; i < NIC_REGS_DUMP_WORD_COUNT; i++)
+			mpi_coredump->nic_regs[i] =
+					ql_read32(qdev, i * sizeof(u32));
+	}
+
+	ql_build_coredump_seg_header(&mpi_coredump->core_regs_seg_hdr,
+				CORE_SEG_NUM,
+				sizeof(mpi_coredump->core_regs_seg_hdr) +
+				sizeof(mpi_coredump->mpi_core_regs) +
+				sizeof(mpi_coredump->mpi_core_sh_regs),
+				"Core Registers");
+
+	/* Get the MPI Core Registers */
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->mpi_core_regs[0],
+				 MPI_CORE_REGS_ADDR, MPI_CORE_REGS_CNT);
+	if (status)
+		goto err;
+	/* Get the 16 MPI shadow registers */
+	status = ql_get_mpi_shadow_regs(qdev,
+					&mpi_coredump->mpi_core_sh_regs[0]);
+	if (status)
+		goto err;
+
+	/* Get the Test Logic Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->test_logic_regs_seg_hdr,
+				TEST_LOGIC_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->test_logic_regs),
+				"Test Logic Regs");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->test_logic_regs[0],
+				 TEST_REGS_ADDR, TEST_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the RMII Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->rmii_regs_seg_hdr,
+				RMII_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->rmii_regs),
+				"RMII Registers");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->rmii_regs[0],
+				 RMII_REGS_ADDR, RMII_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the FCMAC1 Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->fcmac1_regs_seg_hdr,
+				FCMAC1_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->fcmac1_regs),
+				"FCMAC1 Registers");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->fcmac1_regs[0],
+				 FCMAC1_REGS_ADDR, FCMAC_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the FCMAC2 Registers */
+
+	ql_build_coredump_seg_header(&mpi_coredump->fcmac2_regs_seg_hdr,
+				FCMAC2_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->fcmac2_regs),
+				"FCMAC2 Registers");
+
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->fcmac2_regs[0],
+				 FCMAC2_REGS_ADDR, FCMAC_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the FC1 MBX Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->fc1_mbx_regs_seg_hdr,
+				FC1_MBOX_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->fc1_mbx_regs),
+				"FC1 MBox Regs");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->fc1_mbx_regs[0],
+				 FC1_MBX_REGS_ADDR, FC_MBX_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the IDE Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->ide_regs_seg_hdr,
+				IDE_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->ide_regs),
+				"IDE Registers");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->ide_regs[0],
+				 IDE_REGS_ADDR, IDE_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the NIC1 MBX Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->nic1_mbx_regs_seg_hdr,
+				NIC1_MBOX_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->nic1_mbx_regs),
+				"NIC1 MBox Regs");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->nic1_mbx_regs[0],
+				 NIC1_MBX_REGS_ADDR, NIC_MBX_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the SMBus Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->smbus_regs_seg_hdr,
+				SMBUS_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->smbus_regs),
+				"SMBus Registers");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->smbus_regs[0],
+				 SMBUS_REGS_ADDR, SMBUS_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the FC2 MBX Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->fc2_mbx_regs_seg_hdr,
+				FC2_MBOX_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->fc2_mbx_regs),
+				"FC2 MBox Regs");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->fc2_mbx_regs[0],
+				 FC2_MBX_REGS_ADDR, FC_MBX_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the NIC2 MBX Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->nic2_mbx_regs_seg_hdr,
+				NIC2_MBOX_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->nic2_mbx_regs),
+				"NIC2 MBox Regs");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->nic2_mbx_regs[0],
+				 NIC2_MBX_REGS_ADDR, NIC_MBX_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the I2C Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->i2c_regs_seg_hdr,
+				I2C_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->i2c_regs),
+				"I2C Registers");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->i2c_regs[0],
+				 I2C_REGS_ADDR, I2C_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the MEMC Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->memc_regs_seg_hdr,
+				MEMC_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->memc_regs),
+				"MEMC Registers");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->memc_regs[0],
+				 MEMC_REGS_ADDR, MEMC_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the PBus Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->pbus_regs_seg_hdr,
+				PBUS_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->pbus_regs),
+				"PBUS Registers");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->pbus_regs[0],
+				 PBUS_REGS_ADDR, PBUS_REGS_CNT);
+	if (status)
+		goto err;
+
+	/* Get the MDE Registers */
+	ql_build_coredump_seg_header(&mpi_coredump->mde_regs_seg_hdr,
+				MDE_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->mde_regs),
+				"MDE Registers");
+	status = ql_get_mpi_regs(qdev, &mpi_coredump->mde_regs[0],
+				 MDE_REGS_ADDR, MDE_REGS_CNT);
+	if (status)
+		goto err;
+
+	ql_build_coredump_seg_header(&mpi_coredump->misc_nic_seg_hdr,
+				MISC_NIC_INFO_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->misc_nic_info),
+				"MISC NIC INFO");
+	mpi_coredump->misc_nic_info.rx_ring_count = qdev->rx_ring_count;
+	mpi_coredump->misc_nic_info.tx_ring_count = qdev->tx_ring_count;
+	mpi_coredump->misc_nic_info.intr_count = qdev->intr_count;
+	mpi_coredump->misc_nic_info.function = qdev->func;
+
+	/* Segment 31 */
+	/* Get indexed register values. */
+	ql_build_coredump_seg_header(&mpi_coredump->intr_states_seg_hdr,
+				INTR_STATES_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->intr_states),
+				"INTR States");
+	ql_get_intr_states(qdev, &mpi_coredump->intr_states[0]);
+
+	ql_build_coredump_seg_header(&mpi_coredump->cam_entries_seg_hdr,
+				CAM_ENTRIES_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->cam_entries),
+				"CAM Entries");
+	status = ql_get_cam_entries(qdev, &mpi_coredump->cam_entries[0]);
+	if (status)
+		goto err;
+
+	ql_build_coredump_seg_header(&mpi_coredump->nic_routing_words_seg_hdr,
+				ROUTING_WORDS_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->nic_routing_words),
+				"Routing Words");
+	status = ql_get_routing_entries(qdev,
+			 &mpi_coredump->nic_routing_words[0]);
+	if (status)
+		goto err;
+
+	/* Segment 34 (Rev C. step 23) */
+	ql_build_coredump_seg_header(&mpi_coredump->ets_seg_hdr,
+				ETS_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->ets),
+				"ETS Registers");
+	status = ql_get_ets_regs(qdev, &mpi_coredump->ets[0]);
+	if (status)
+		goto err;
+
+	ql_build_coredump_seg_header(&mpi_coredump->routing_reg_seg_hdr,
+				ROUTING_INDEX_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->routing_regs),
+				"Routing Regs");
+	status = ql_get_routing_index_registers(qdev,
+					&mpi_coredump->routing_regs[0]);
+	if (status)
+		goto err;
+
+	ql_build_coredump_seg_header(&mpi_coredump->mac_prot_reg_seg_hdr,
+				MAC_PROTOCOL_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->mac_prot_regs),
+				"MAC Prot Regs");
+	ql_get_mac_protocol_registers(qdev, &mpi_coredump->mac_prot_regs[0]);
+
+	/* Get the semaphore registers for all 5 functions */
+	ql_build_coredump_seg_header(&mpi_coredump->sem_regs_seg_hdr,
+			SEM_REGS_SEG_NUM,
+			sizeof(struct mpi_coredump_segment_header) +
+			sizeof(mpi_coredump->sem_regs),	"Sem Registers");
+
+	ql_get_sem_registers(qdev, &mpi_coredump->sem_regs[0]);
+
+	/* Prevent the mpi restarting while we dump the memory.*/
+	ql_write_mpi_reg(qdev, MPI_TEST_FUNC_RST_STS, MPI_TEST_FUNC_RST_FRC);
+
+	/* clear the pause */
+	status = ql_unpause_mpi_risc(qdev);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed RISC unpause. Status = 0x%.08x\n", status);
+		goto err;
+	}
+err:
+	ql_sem_unlock(qdev, SEM_PROC_REG_MASK); /* does flush too */
+	return status;
+
+}
+
 void ql_gen_reg_dump(struct ql_adapter *qdev,
 			struct ql_reg_dump *mpi_coredump)
 {
@@ -180,6 +676,33 @@ void ql_gen_reg_dump(struct ql_adapter *qdev,
 		return;
 }
 
+/* Coredump to messages log file using separate worker thread */
+void ql_mpi_core_to_log(struct work_struct *work)
+{
+	struct ql_adapter *qdev =
+		container_of(work, struct ql_adapter, mpi_core_to_log.work);
+	u32 *tmp, count;
+	int i;
+
+	count = sizeof(struct ql_mpi_coredump) / sizeof(u32);
+	tmp = (u32 *)qdev->mpi_coredump;
+	QPRINTK(qdev, DRV, DEBUG, "Core is dumping to log file!\n");
+
+	for (i = 0; i < count; i += 8) {
+		printk(KERN_ERR "%.08x: %.08x %.08x %.08x %.08x %.08x "
+			"%.08x %.08x %.08x \n", i,
+			tmp[i + 0],
+			tmp[i + 1],
+			tmp[i + 2],
+			tmp[i + 3],
+			tmp[i + 4],
+			tmp[i + 5],
+			tmp[i + 6],
+			tmp[i + 7]);
+		msleep(5);
+	}
+}
+
 #ifdef QL_REG_DUMP
 static void ql_dump_intr_states(struct ql_adapter *qdev)
 {
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 167a3da..e588923 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -73,6 +73,13 @@ static int qlge_irq_type = MSIX_IRQ;
 module_param(qlge_irq_type, int, MSIX_IRQ);
 MODULE_PARM_DESC(qlge_irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");
 
+static int qlge_mpi_coredump;
+module_param(qlge_mpi_coredump, int, 0);
+MODULE_PARM_DESC(qlge_mpi_coredump,
+		"Option to enable MPI firmware dump. "
+		"Default is OFF - Do Not allocate memory. "
+		"Do not perform firmware coredump.");
+
 static DEFINE_PCI_DEVICE_TABLE(qlge_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8012)},
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8000)},
@@ -3842,6 +3849,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
 	cancel_delayed_work_sync(&qdev->mpi_idc_work);
+	cancel_delayed_work_sync(&qdev->mpi_core_to_log);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 
 	for (i = 0; i < qdev->rss_ring_count; i++)
@@ -4398,6 +4406,7 @@ static void ql_release_all(struct pci_dev *pdev)
 		iounmap(qdev->reg_base);
 	if (qdev->doorbell_area)
 		iounmap(qdev->doorbell_area);
+	vfree(qdev->mpi_coredump);
 	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -4479,6 +4488,15 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	spin_lock_init(&qdev->hw_lock);
 	spin_lock_init(&qdev->stats_lock);
 
+	if (qlge_mpi_coredump) {
+		qdev->mpi_coredump =
+			vmalloc(sizeof(struct ql_mpi_coredump));
+		if (qdev->mpi_coredump == NULL) {
+			dev_err(&pdev->dev, "Coredump alloc failed.\n");
+			err = -ENOMEM;
+			goto err_out;
+		}
+	}
 	/* make sure the EEPROM is good */
 	err = qdev->nic_ops->get_flash(qdev);
 	if (err) {
@@ -4508,6 +4526,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
 	INIT_DELAYED_WORK(&qdev->mpi_port_cfg_work, ql_mpi_port_cfg_work);
 	INIT_DELAYED_WORK(&qdev->mpi_idc_work, ql_mpi_idc_work);
+	INIT_DELAYED_WORK(&qdev->mpi_core_to_log, ql_mpi_core_to_log);
 	init_completion(&qdev->ide_completion);
 
 	if (!cards_found) {
@@ -4630,6 +4649,7 @@ static void ql_eeh_close(struct net_device *ndev)
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
 	cancel_delayed_work_sync(&qdev->mpi_idc_work);
+	cancel_delayed_work_sync(&qdev->mpi_core_to_log);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 
 	for (i = 0; i < qdev->rss_ring_count; i++)
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index e2b2286..242b1ea 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -1,5 +1,35 @@
 #include "qlge.h"
 
+int ql_unpause_mpi_risc(struct ql_adapter *qdev)
+{
+	u32 tmp;
+
+	/* Un-pause the RISC */
+	tmp = ql_read32(qdev, CSR);
+	if (!(tmp & CSR_RP))
+		return -EIO;
+
+	ql_write32(qdev, CSR, CSR_CMD_CLR_PAUSE);
+	return 0;
+}
+
+int ql_pause_mpi_risc(struct ql_adapter *qdev)
+{
+	u32 tmp;
+	int count = UDELAY_COUNT;
+
+	/* Pause the RISC */
+	ql_write32(qdev, CSR, CSR_CMD_SET_PAUSE);
+	do {
+		tmp = ql_read32(qdev, CSR);
+		if (tmp & CSR_RP)
+			break;
+		mdelay(UDELAY_DELAY);
+		count--;
+	} while (count);
+	return (count == 0) ? -ETIMEDOUT : 0;
+}
+
 int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data)
 {
 	int status;
@@ -45,6 +75,35 @@ int ql_soft_reset_mpi_risc(struct ql_adapter *qdev)
 	return status;
 }
 
+/* Determine if we are in charge of the firwmare. If
+ * we are the lower of the 2 NIC pcie functions, or if
+ * we are the higher function and the lower function
+ * is not enabled.
+ */
+int ql_own_firmware(struct ql_adapter *qdev)
+{
+	u32 temp;
+
+	/* If we are the lower of the 2 NIC functions
+	 * on the chip the we are responsible for
+	 * core dump and firmware reset after an error.
+	 */
+	if (qdev->func < qdev->alt_func)
+		return 1;
+
+	/* If we are the higher of the 2 NIC functions
+	 * on the chip and the lower function is not
+	 * enabled, then we are responsible for
+	 * core dump and firmware reset after an error.
+	 */
+	temp =  ql_read32(qdev, STS);
+	if (!(temp & (1 << (8 + qdev->alt_func))))
+		return 1;
+
+	return 0;
+
+}
+
 static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int i, status;
@@ -1143,5 +1202,19 @@ void ql_mpi_reset_work(struct work_struct *work)
 	cancel_delayed_work_sync(&qdev->mpi_work);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 	cancel_delayed_work_sync(&qdev->mpi_idc_work);
+	/* If we're not the dominant NIC function,
+	 * then there is nothing to do.
+	 */
+	if (!ql_own_firmware(qdev)) {
+		QPRINTK(qdev, DRV, ERR, "Don't own firmware!\n");
+		return;
+	}
+
+	if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
+		QPRINTK(qdev, DRV, ERR, "Core is dumped!\n");
+		qdev->core_is_dumped = 1;
+		queue_delayed_work(qdev->workqueue,
+			&qdev->mpi_core_to_log, 5 * HZ);
+	}
 	ql_soft_reset_mpi_risc(qdev);
 }
-- 
1.6.0.2

