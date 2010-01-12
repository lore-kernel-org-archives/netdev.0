From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/8] qlge: Add data for firmware dump.
Date: Mon, 11 Jan 2010 17:12:58 -0800
Message-ID: <1263258785-5112-2-git-send-email-ron.mercer@qlogic.com>
References: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47621 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab0ALBTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 20:19:44 -0500
In-Reply-To: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |  285 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 284 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index ee0e2bd..0094263 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -75,6 +75,16 @@
 #define TX_DESC_PER_OAL 0
 #endif
 
+/* Word shifting for converting 64-bit
+ * address to a series of 16-bit words.
+ * This is used for some MPI firmware
+ * mailbox commands.
+ */
+#define LSW(x)  ((u16)(x))
+#define MSW(x)  ((u16)((u32)(x) >> 16))
+#define LSD(x)  ((u32)((u64)(x)))
+#define MSD(x)  ((u32)((((u64)(x)) >> 16) >> 16))
+
 /* MPI test register definitions. This register
  * is used for determining alternate NIC function's
  * PCI->func number.
@@ -464,7 +474,7 @@ enum {
 	MDIO_PORT = 0x00000440,
 	MDIO_STATUS = 0x00000450,
 
-	/* XGMAC AUX statistics  registers */
+	XGMAC_REGISTER_END = 0x00000740,
 };
 
 /*
@@ -664,6 +674,14 @@ enum {
 };
 
 /*
+ * Serdes Address Register (XG_SERDES_ADDR) bit definitions.
+ */
+enum {
+	XG_SERDES_ADDR_RDY = (1 << 31),
+	XG_SERDES_ADDR_R = (1 << 30),
+};
+
+/*
  * Control Register Set Map
  */
 enum {
@@ -1538,6 +1556,60 @@ enum {
 
 };
 
+/* Probe dump constants */
+/* 64 probes, 8 bytes per probe + 4 bytes to list the probe ID */
+#define PROBE_DATA_LENGTH_WORDS ((64*2) + 1)
+#define NUMBER_OF_PROBES 34
+#define NUMBER_ROUTING_REG_ENTRIES 48
+#define WORDS_PER_ROUTING_REG_ENTRY 4
+#define MAC_PROTOCOL_REGISTER_WORDS ((512 * 3) + (32 * 2) + (4096 * 1) + \
+(4096 * 1) + (4 * 2) + (8 * 2) + (16 * 1) + (4 * 1) + (4 * 4) + (4 * 1))
+
+/* Save both the address and data register */
+#define WORDS_PER_MAC_PROT_ENTRY 2
+#define MAX_SEMAPHORE_FUNCTIONS 5
+#define WQC_WORD_SIZE 6
+#define NUMBER_OF_WQCS 128
+#define CQC_WORD_SIZE 13
+#define NUMBER_OF_CQCS 128
+
+#define MPI_READ 0x00000000
+#define REG_BLOCK 0x00020000
+#define TEST_LOGIC_FUNC_PORT_CONFIG 0x1002
+#define NIC1_FUNCTION_ENABLE 0x00000001
+#define NIC1_FUNCTION_MASK 0x0000000e
+#define NIC1_FUNCTION_SHIFT 1
+#define NIC2_FUNCTION_ENABLE 0x00000010
+#define NIC2_FUNCTION_MASK 0x000000e0
+#define NIC2_FUNCTION_SHIFT 5
+#define FC1_FUNCTION_ENABLE 0x00000100
+#define FC1_FUNCTION_MASK 0x00000e00
+#define FC1_FUNCTION_SHIFT 9
+#define FC2_FUNCTION_ENABLE 0x00001000
+#define FC2_FUNCTION_MASK 0x0000e000
+#define FC2_FUNCTION_SHIFT 13
+#define FUNCTION_SHIFT 6
+
+#define XFI1_POWERED_UP 0x00000005
+#define XFI2_POWERED_UP	0x0000000A
+#define XAUI_POWERED_DOWN 0x00000001
+
+#define RISC_124 0x0003007c
+#define RISC_127 0x0003007f
+#define SHADOW_OFFSET 0xb0000000
+
+#define SYS_CLOCK (0x00)
+#define PCI_CLOCK (0x80)
+#define FC_CLOCK (0x140)
+#define XGM_CLOCK (0x180)
+#define ADDRESS_REGISTER_ENABLE 0x00010000
+#define UP 0x00008000
+#define MAX_MUX	0x40
+#define MAX_MODULES 0x1F
+#define RS_AND_ADR 0x06000000
+#define RS_ONLY	0x04000000
+#define NUM_TYPES 10
+
 struct ql_nic_misc {
 	u32 rx_ring_count;
 	u32 tx_ring_count;
@@ -1579,6 +1651,214 @@ struct ql_reg_dump {
 	u32 ets[8+2];
 };
 
+struct ql_mpi_coredump {
+	/* segment 0 */
+	struct mpi_coredump_global_header mpi_global_header;
+
+	/* segment 1 */
+	struct mpi_coredump_segment_header core_regs_seg_hdr;
+	u32 mpi_core_regs[MPI_CORE_REGS_CNT];
+	u32 mpi_core_sh_regs[MPI_CORE_SH_REGS_CNT];
+
+	/* segment 2 */
+	struct mpi_coredump_segment_header test_logic_regs_seg_hdr;
+	u32 test_logic_regs[TEST_REGS_CNT];
+
+	/* segment 3 */
+	struct mpi_coredump_segment_header rmii_regs_seg_hdr;
+	u32 rmii_regs[RMII_REGS_CNT];
+
+	/* segment 4 */
+	struct mpi_coredump_segment_header fcmac1_regs_seg_hdr;
+	u32 fcmac1_regs[FCMAC_REGS_CNT];
+
+	/* segment 5 */
+	struct mpi_coredump_segment_header fcmac2_regs_seg_hdr;
+	u32 fcmac2_regs[FCMAC_REGS_CNT];
+
+	/* segment 6 */
+	struct mpi_coredump_segment_header fc1_mbx_regs_seg_hdr;
+	u32 fc1_mbx_regs[FC_MBX_REGS_CNT];
+
+	/* segment 7 */
+	struct mpi_coredump_segment_header ide_regs_seg_hdr;
+	u32 ide_regs[IDE_REGS_CNT];
+
+	/* segment 8 */
+	struct mpi_coredump_segment_header nic1_mbx_regs_seg_hdr;
+	u32 nic1_mbx_regs[NIC_MBX_REGS_CNT];
+
+	/* segment 9 */
+	struct mpi_coredump_segment_header smbus_regs_seg_hdr;
+	u32 smbus_regs[SMBUS_REGS_CNT];
+
+	/* segment 10 */
+	struct mpi_coredump_segment_header fc2_mbx_regs_seg_hdr;
+	u32 fc2_mbx_regs[FC_MBX_REGS_CNT];
+
+	/* segment 11 */
+	struct mpi_coredump_segment_header nic2_mbx_regs_seg_hdr;
+	u32 nic2_mbx_regs[NIC_MBX_REGS_CNT];
+
+	/* segment 12 */
+	struct mpi_coredump_segment_header i2c_regs_seg_hdr;
+	u32 i2c_regs[I2C_REGS_CNT];
+	/* segment 13 */
+	struct mpi_coredump_segment_header memc_regs_seg_hdr;
+	u32 memc_regs[MEMC_REGS_CNT];
+
+	/* segment 14 */
+	struct mpi_coredump_segment_header pbus_regs_seg_hdr;
+	u32 pbus_regs[PBUS_REGS_CNT];
+
+	/* segment 15 */
+	struct mpi_coredump_segment_header mde_regs_seg_hdr;
+	u32 mde_regs[MDE_REGS_CNT];
+
+	/* segment 16 */
+	struct mpi_coredump_segment_header nic_regs_seg_hdr;
+	u32 nic_regs[64];
+
+	/* segment 17 */
+	struct mpi_coredump_segment_header nic2_regs_seg_hdr;
+	u32 nic2_regs[64];
+
+	/* segment 18 */
+	struct mpi_coredump_segment_header xgmac1_seg_hdr;
+	u32 xgmac1[XGMAC_REGISTER_END / 4];
+
+	/* segment 19 */
+	struct mpi_coredump_segment_header xgmac2_seg_hdr;
+	u32 xgmac2[XGMAC_REGISTER_END / 4];
+
+	/* segment 20 */
+	struct mpi_coredump_segment_header code_ram_seg_hdr;
+	u32 code_ram[CODE_RAM_CNT];
+
+	/* segment 21 */
+	struct mpi_coredump_segment_header memc_ram_seg_hdr;
+	u32 memc_ram[MEMC_RAM_CNT];
+
+	/* segment 22 */
+	struct mpi_coredump_segment_header xaui_an_hdr;
+	u32 serdes_xaui_an[14];
+
+	/* segment 23 */
+	struct mpi_coredump_segment_header xaui_hss_pcs_hdr;
+	u32 serdes_xaui_hss_pcs[33];
+
+	/* segment 24 */
+	struct mpi_coredump_segment_header xfi_an_hdr;
+	u32 serdes_xfi_an[14];
+
+	/* segment 25 */
+	struct mpi_coredump_segment_header xfi_train_hdr;
+	u32 serdes_xfi_train[12];
+
+	/* segment 26 */
+	struct mpi_coredump_segment_header xfi_hss_pcs_hdr;
+	u32 serdes_xfi_hss_pcs[15];
+
+	/* segment 27 */
+	struct mpi_coredump_segment_header xfi_hss_tx_hdr;
+	u32 serdes_xfi_hss_tx[32];
+
+	/* segment 28 */
+	struct mpi_coredump_segment_header xfi_hss_rx_hdr;
+	u32 serdes_xfi_hss_rx[32];
+
+	/* segment 29 */
+	struct mpi_coredump_segment_header xfi_hss_pll_hdr;
+	u32 serdes_xfi_hss_pll[32];
+
+	/* segment 30 */
+	struct mpi_coredump_segment_header misc_nic_seg_hdr;
+	struct ql_nic_misc misc_nic_info;
+
+	/* segment 31 */
+	/* one interrupt state for each CQ */
+	struct mpi_coredump_segment_header intr_states_seg_hdr;
+	u32 intr_states[MAX_RX_RINGS];
+
+	/* segment 32 */
+	/* 3 cam words each for 16 unicast,
+	 * 2 cam words for each of 32 multicast.
+	 */
+	struct mpi_coredump_segment_header cam_entries_seg_hdr;
+	u32 cam_entries[(16 * 3) + (32 * 3)];
+
+	/* segment 33 */
+	struct mpi_coredump_segment_header nic_routing_words_seg_hdr;
+	u32 nic_routing_words[16];
+
+	/* segment 34 */
+	struct mpi_coredump_segment_header ets_seg_hdr;
+	u32 ets[8+2];
+
+	/* segment 35 */
+	struct mpi_coredump_segment_header probe_dump_seg_hdr;
+	u32 probe_dump[PROBE_DATA_LENGTH_WORDS * NUMBER_OF_PROBES];
+
+	/* segment 36 */
+	struct mpi_coredump_segment_header routing_reg_seg_hdr;
+	u32 routing_regs[NUMBER_ROUTING_REG_ENTRIES *
+				WORDS_PER_ROUTING_REG_ENTRY];
+
+	/* segment 37 */
+	struct mpi_coredump_segment_header mac_prot_reg_seg_hdr;
+	u32 mac_prot_regs[MAC_PROTOCOL_REGISTER_WORDS *
+				WORDS_PER_MAC_PROT_ENTRY];
+
+	/* segment 38 */
+	struct mpi_coredump_segment_header xaui2_an_hdr;
+	u32 serdes2_xaui_an[14];
+
+	/* segment 39 */
+	struct mpi_coredump_segment_header xaui2_hss_pcs_hdr;
+	u32 serdes2_xaui_hss_pcs[33];
+
+	/* segment 40 */
+	struct mpi_coredump_segment_header xfi2_an_hdr;
+	u32 serdes2_xfi_an[14];
+
+	/* segment 41 */
+	struct mpi_coredump_segment_header xfi2_train_hdr;
+	u32 serdes2_xfi_train[12];
+
+	/* segment 42 */
+	struct mpi_coredump_segment_header xfi2_hss_pcs_hdr;
+	u32 serdes2_xfi_hss_pcs[15];
+
+	/* segment 43 */
+	struct mpi_coredump_segment_header xfi2_hss_tx_hdr;
+	u32 serdes2_xfi_hss_tx[32];
+
+	/* segment 44 */
+	struct mpi_coredump_segment_header xfi2_hss_rx_hdr;
+	u32 serdes2_xfi_hss_rx[32];
+
+	/* segment 45 */
+	struct mpi_coredump_segment_header xfi2_hss_pll_hdr;
+	u32 serdes2_xfi_hss_pll[32];
+
+	/* segment 50 */
+	/* semaphore register for all 5 functions */
+	struct mpi_coredump_segment_header sem_regs_seg_hdr;
+	u32 sem_regs[MAX_SEMAPHORE_FUNCTIONS];
+
+	struct mpi_coredump_segment_header wqc1_seg_hdr;
+	u32 wqc1[WQC_WORD_SIZE * NUMBER_OF_WQCS];
+
+	struct mpi_coredump_segment_header cqc1_seg_hdr;
+	u32 cqc1[CQC_WORD_SIZE * NUMBER_OF_CQCS];
+
+	struct mpi_coredump_segment_header wqc2_seg_hdr;
+	u32 wqc2[WQC_WORD_SIZE * NUMBER_OF_WQCS];
+
+	struct mpi_coredump_segment_header cqc2_seg_hdr;
+	u32 cqc2[CQC_WORD_SIZE * NUMBER_OF_CQCS];
+};
+
 /*
  * intr_context structure is used during initialization
  * to hook the interrupts.  It is also used in a single
@@ -1735,6 +2015,8 @@ struct ql_adapter {
 	u32 port_link_up;
 	u32 port_init;
 	u32 link_status;
+	struct ql_mpi_coredump *mpi_coredump;
+	u32 core_is_dumped;
 	u32 link_config;
 	u32 led_config;
 	u32 max_frame_size;
@@ -1747,6 +2029,7 @@ struct ql_adapter {
 	struct delayed_work mpi_work;
 	struct delayed_work mpi_port_cfg_work;
 	struct delayed_work mpi_idc_work;
+	struct delayed_work mpi_core_to_log;
 	struct completion ide_completion;
 	struct nic_operations *nic_ops;
 	u16 device_id;
-- 
1.6.0.2

