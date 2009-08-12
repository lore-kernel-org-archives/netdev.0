From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 32/36] bnx2x: Re-factor the initialization code
Date: Wed, 12 Aug 2009 21:24:14 +0300
Message-ID: <1250101454.27379.184.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700AbZHLSZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving the code to a more logical place and beautifying it. No real change in
behavior.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h          |   28 +++-
 drivers/net/bnx2x_init.h     |  320 ++++++--------------------------
 drivers/net/bnx2x_init_ops.h |  419 ++++++++++++++++++++++++------------------
 drivers/net/bnx2x_main.c     |   79 ++++++--
 drivers/net/bnx2x_reg.h      |  113 +++++++++++
 5 files changed, 495 insertions(+), 464 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index a231780..97bc5e0 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -116,16 +116,22 @@
 #define REG_RD_DMAE(bp, offset, valp, len32) \
 	do { \
 		bnx2x_read_dmae(bp, offset, len32);\
-		memcpy(valp, bnx2x_sp(bp, wb_data[0]), len32 * 4); \
+		memcpy(valp, bnx2x_sp(bp, wb_data[0]), (len32) * 4); \
 	} while (0)
 
 #define REG_WR_DMAE(bp, offset, valp, len32) \
 	do { \
-		memcpy(bnx2x_sp(bp, wb_data[0]), valp, len32 * 4); \
+		memcpy(bnx2x_sp(bp, wb_data[0]), valp, (len32) * 4); \
 		bnx2x_write_dmae(bp, bnx2x_sp_mapping(bp, wb_data), \
 				 offset, len32); \
 	} while (0)
 
+#define VIRT_WR_DMAE_LEN(bp, data, addr, len32) \
+	do { \
+		memcpy(GUNZIP_BUF(bp), data, (len32) * 4); \
+		bnx2x_write_big_buf_wb(bp, addr, len32); \
+	} while (0)
+
 #define SHMEM_ADDR(bp, field)		(bp->common.shmem_base + \
 					 offsetof(struct shmem_region, field))
 #define SHMEM_RD(bp, field)		REG_RD(bp, SHMEM_ADDR(bp, field))
@@ -988,6 +994,9 @@ struct bnx2x {
 	dma_addr_t		gunzip_mapping;
 	int			gunzip_outlen;
 #define FW_BUF_SIZE			0x8000
+#define GUNZIP_BUF(bp)			(bp->gunzip_buf)
+#define GUNZIP_PHYS(bp)			(bp->gunzip_mapping)
+#define GUNZIP_OUTLEN(bp)		(bp->gunzip_outlen)
 
 	struct raw_op          *init_ops;
 	/* Init blocks offsets inside init_ops */
@@ -1003,6 +1012,18 @@ struct bnx2x {
 	const u8               *xsem_pram_data;
 	const u8               *csem_int_table_data;
 	const u8               *csem_pram_data;
+#define INIT_OPS(bp)			(bp->init_ops)
+#define INIT_OPS_OFFSETS(bp)		(bp->init_ops_offsets)
+#define INIT_DATA(bp)			(bp->init_data)
+#define INIT_TSEM_INT_TABLE_DATA(bp)	(bp->tsem_int_table_data)
+#define INIT_TSEM_PRAM_DATA(bp)		(bp->tsem_pram_data)
+#define INIT_USEM_INT_TABLE_DATA(bp)	(bp->usem_int_table_data)
+#define INIT_USEM_PRAM_DATA(bp)		(bp->usem_pram_data)
+#define INIT_XSEM_INT_TABLE_DATA(bp)	(bp->xsem_int_table_data)
+#define INIT_XSEM_PRAM_DATA(bp)		(bp->xsem_pram_data)
+#define INIT_CSEM_INT_TABLE_DATA(bp)	(bp->csem_int_table_data)
+#define INIT_CSEM_PRAM_DATA(bp)		(bp->csem_pram_data)
+
         const struct firmware  *firmware;
 };
 
@@ -1030,6 +1051,9 @@ int bnx2x_get_gpio(struct bnx2x *bp, int gpio_num, u8 port);
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 int bnx2x_set_gpio_int(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 u32 bnx2x_fw_command(struct bnx2x *bp, u32 command);
+void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
+void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
+			       u32 addr, u32 len);
 
 static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 			   int wait)
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 3ba4d88..65b26cb 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -15,24 +15,11 @@
 #ifndef BNX2X_INIT_H
 #define BNX2X_INIT_H
 
-#define COMMON				0x1
-#define PORT0				0x2
-#define PORT1				0x4
-
-#define INIT_EMULATION			0x1
-#define INIT_FPGA			0x2
-#define INIT_ASIC			0x4
-#define INIT_HARDWARE			0x7
-
-#define TSTORM_INTMEM_ADDR		TSEM_REG_FAST_MEMORY
-#define CSTORM_INTMEM_ADDR		CSEM_REG_FAST_MEMORY
-#define XSTORM_INTMEM_ADDR		XSEM_REG_FAST_MEMORY
-#define USTORM_INTMEM_ADDR		USEM_REG_FAST_MEMORY
 /* RAM0 size in bytes */
 #define STORM_INTMEM_SIZE_E1		0x5800
 #define STORM_INTMEM_SIZE_E1H		0x10000
-#define STORM_INTMEM_SIZE(bp)	((CHIP_IS_E1H(bp) ? STORM_INTMEM_SIZE_E1H : \
-						    STORM_INTMEM_SIZE_E1) / 4)
+#define STORM_INTMEM_SIZE(bp) ((CHIP_IS_E1(bp) ? STORM_INTMEM_SIZE_E1 : \
+						    STORM_INTMEM_SIZE_E1H) / 4)
 
 
 /* Init operation types and structures */
@@ -53,65 +40,68 @@
 #define OP_WR_ASIC		0xc /* write single register on ASIC */
 
 /* Init stages */
-#define COMMON_STAGE            0
-#define PORT0_STAGE     	1
-#define PORT1_STAGE     	2
-/* Never reorder FUNCx stages !!! */
-#define FUNC0_STAGE     	3
-#define FUNC1_STAGE     	4
-#define FUNC2_STAGE     	5
-#define FUNC3_STAGE     	6
-#define FUNC4_STAGE     	7
-#define FUNC5_STAGE     	8
-#define FUNC6_STAGE     	9
-#define FUNC7_STAGE     	10
-#define STAGE_IDX_MAX   	11
-
-#define STAGE_START     	0
-#define STAGE_END       	1
+/* Never reorder stages !!! */
+#define COMMON_STAGE		0
+#define PORT0_STAGE		1
+#define PORT1_STAGE		2
+#define FUNC0_STAGE		3
+#define FUNC1_STAGE		4
+#define FUNC2_STAGE		5
+#define FUNC3_STAGE		6
+#define FUNC4_STAGE		7
+#define FUNC5_STAGE		8
+#define FUNC6_STAGE		9
+#define FUNC7_STAGE		10
+#define STAGE_IDX_MAX		11
+
+#define STAGE_START		0
+#define STAGE_END		1
 
 
 /* Indices of blocks */
-#define PRS_BLOCK               0
-#define SRCH_BLOCK              1
-#define TSDM_BLOCK              2
-#define TCM_BLOCK               3
-#define BRB1_BLOCK              4
-#define TSEM_BLOCK              5
-#define PXPCS_BLOCK             6
-#define EMAC0_BLOCK             7
-#define EMAC1_BLOCK             8
-#define DBU_BLOCK               9
-#define MISC_BLOCK              10
-#define DBG_BLOCK               11
-#define NIG_BLOCK               12
-#define MCP_BLOCK               13
-#define UPB_BLOCK               14
-#define CSDM_BLOCK              15
-#define USDM_BLOCK              16
-#define CCM_BLOCK               17
-#define UCM_BLOCK               18
-#define USEM_BLOCK              19
-#define CSEM_BLOCK              20
-#define XPB_BLOCK               21
-#define DQ_BLOCK                22
-#define TIMERS_BLOCK            23
-#define XSDM_BLOCK              24
-#define QM_BLOCK                25
-#define PBF_BLOCK               26
-#define XCM_BLOCK               27
-#define XSEM_BLOCK              28
-#define CDU_BLOCK               29
-#define DMAE_BLOCK              30
-#define PXP_BLOCK               31
-#define CFC_BLOCK               32
-#define HC_BLOCK                33
-#define PXP2_BLOCK              34
-#define MISC_AEU_BLOCK          35
+#define PRS_BLOCK		0
+#define SRCH_BLOCK		1
+#define TSDM_BLOCK		2
+#define TCM_BLOCK		3
+#define BRB1_BLOCK		4
+#define TSEM_BLOCK		5
+#define PXPCS_BLOCK		6
+#define EMAC0_BLOCK		7
+#define EMAC1_BLOCK		8
+#define DBU_BLOCK		9
+#define MISC_BLOCK		10
+#define DBG_BLOCK		11
+#define NIG_BLOCK		12
+#define MCP_BLOCK		13
+#define UPB_BLOCK		14
+#define CSDM_BLOCK		15
+#define USDM_BLOCK		16
+#define CCM_BLOCK		17
+#define UCM_BLOCK		18
+#define USEM_BLOCK		19
+#define CSEM_BLOCK		20
+#define XPB_BLOCK		21
+#define DQ_BLOCK		22
+#define TIMERS_BLOCK		23
+#define XSDM_BLOCK		24
+#define QM_BLOCK		25
+#define PBF_BLOCK		26
+#define XCM_BLOCK		27
+#define XSEM_BLOCK		28
+#define CDU_BLOCK		29
+#define DMAE_BLOCK		30
+#define PXP_BLOCK		31
+#define CFC_BLOCK		32
+#define HC_BLOCK		33
+#define PXP2_BLOCK		34
+#define MISC_AEU_BLOCK		35
+#define PGLUE_B_BLOCK		36
+#define IGU_BLOCK		37
+
 
 /* Returns the index of start or end of a specific block stage in ops array*/
 #define BLOCK_OPS_IDX(block, stage, end) \
-       (2*(((block)*STAGE_IDX_MAX) + (stage)) + (end))
+			(2*(((block)*STAGE_IDX_MAX) + (stage)) + (end))
 
 
 struct raw_op {
@@ -158,199 +148,5 @@ union init_op {
 	struct raw_op		raw;
 };
 
-/****************************************************************************
-* PXP
-****************************************************************************/
-/*
- * This code configures the PCI read/write arbiter
- * which implements a weighted round robin
- * between the virtual queues in the chip.
- *
- * The values were derived for each PCI max payload and max request size.
- * since max payload and max request size are only known at run time,
- * this is done as a separate init stage.
- */
-
-#define NUM_WR_Q			13
-#define NUM_RD_Q			29
-#define MAX_RD_ORD			3
-#define MAX_WR_ORD			2
-
-/* configuration for one arbiter queue */
-struct arb_line {
-	int l;
-	int add;
-	int ubound;
-};
-
-/* derived configuration for each read queue for each max request size */
-static const struct arb_line read_arb_data[NUM_RD_Q][MAX_RD_ORD + 1] = {
-/* 1 */	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25}, {64, 64, 41} },
-	{ {4, 8,  4},  {4,  8,  4},  {4,  8,  4},  {4,  8,  4}  },
-	{ {4, 3,  3},  {4,  3,  3},  {4,  3,  3},  {4,  3,  3}  },
-	{ {8, 3,  6},  {16, 3,  11}, {16, 3,  11}, {16, 3,  11} },
-	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25}, {64, 64, 41} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
-/* 10 */{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-/* 20 */{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
-	{ {8, 64, 25}, {16, 64, 41}, {32, 64, 81}, {64, 64, 120} }
-};
-
-/* derived configuration for each write queue for each max request size */
-static const struct arb_line write_arb_data[NUM_WR_Q][MAX_WR_ORD + 1] = {
-/* 1 */	{ {4, 6,  3},  {4,  6,  3},  {4,  6,  3} },
-	{ {4, 2,  3},  {4,  2,  3},  {4,  2,  3} },
-	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
-	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
-	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
-	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
-	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25} },
-	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
-	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
-/* 10 */{ {8, 9,  6},  {16, 9,  11}, {32, 9,  21} },
-	{ {8, 47, 19}, {16, 47, 19}, {32, 47, 21} },
-	{ {8, 9,  6},  {16, 9,  11}, {16, 9,  11} },
-	{ {8, 64, 25}, {16, 64, 41}, {32, 64, 81} }
-};
-
-/* register addresses for read queues */
-static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
-/* 1 */	{PXP2_REG_RQ_BW_RD_L0, PXP2_REG_RQ_BW_RD_ADD0,
-		PXP2_REG_RQ_BW_RD_UBOUND0},
-	{PXP2_REG_PSWRQ_BW_L1, PXP2_REG_PSWRQ_BW_ADD1,
-		PXP2_REG_PSWRQ_BW_UB1},
-	{PXP2_REG_PSWRQ_BW_L2, PXP2_REG_PSWRQ_BW_ADD2,
-		PXP2_REG_PSWRQ_BW_UB2},
-	{PXP2_REG_PSWRQ_BW_L3, PXP2_REG_PSWRQ_BW_ADD3,
-		PXP2_REG_PSWRQ_BW_UB3},
-	{PXP2_REG_RQ_BW_RD_L4, PXP2_REG_RQ_BW_RD_ADD4,
-		PXP2_REG_RQ_BW_RD_UBOUND4},
-	{PXP2_REG_RQ_BW_RD_L5, PXP2_REG_RQ_BW_RD_ADD5,
-		PXP2_REG_RQ_BW_RD_UBOUND5},
-	{PXP2_REG_PSWRQ_BW_L6, PXP2_REG_PSWRQ_BW_ADD6,
-		PXP2_REG_PSWRQ_BW_UB6},
-	{PXP2_REG_PSWRQ_BW_L7, PXP2_REG_PSWRQ_BW_ADD7,
-		PXP2_REG_PSWRQ_BW_UB7},
-	{PXP2_REG_PSWRQ_BW_L8, PXP2_REG_PSWRQ_BW_ADD8,
-		PXP2_REG_PSWRQ_BW_UB8},
-/* 10 */{PXP2_REG_PSWRQ_BW_L9, PXP2_REG_PSWRQ_BW_ADD9,
-		PXP2_REG_PSWRQ_BW_UB9},
-	{PXP2_REG_PSWRQ_BW_L10, PXP2_REG_PSWRQ_BW_ADD10,
-		PXP2_REG_PSWRQ_BW_UB10},
-	{PXP2_REG_PSWRQ_BW_L11, PXP2_REG_PSWRQ_BW_ADD11,
-		PXP2_REG_PSWRQ_BW_UB11},
-	{PXP2_REG_RQ_BW_RD_L12, PXP2_REG_RQ_BW_RD_ADD12,
-		PXP2_REG_RQ_BW_RD_UBOUND12},
-	{PXP2_REG_RQ_BW_RD_L13, PXP2_REG_RQ_BW_RD_ADD13,
-		PXP2_REG_RQ_BW_RD_UBOUND13},
-	{PXP2_REG_RQ_BW_RD_L14, PXP2_REG_RQ_BW_RD_ADD14,
-		PXP2_REG_RQ_BW_RD_UBOUND14},
-	{PXP2_REG_RQ_BW_RD_L15, PXP2_REG_RQ_BW_RD_ADD15,
-		PXP2_REG_RQ_BW_RD_UBOUND15},
-	{PXP2_REG_RQ_BW_RD_L16, PXP2_REG_RQ_BW_RD_ADD16,
-		PXP2_REG_RQ_BW_RD_UBOUND16},
-	{PXP2_REG_RQ_BW_RD_L17, PXP2_REG_RQ_BW_RD_ADD17,
-		PXP2_REG_RQ_BW_RD_UBOUND17},
-	{PXP2_REG_RQ_BW_RD_L18, PXP2_REG_RQ_BW_RD_ADD18,
-		PXP2_REG_RQ_BW_RD_UBOUND18},
-/* 20 */{PXP2_REG_RQ_BW_RD_L19, PXP2_REG_RQ_BW_RD_ADD19,
-		PXP2_REG_RQ_BW_RD_UBOUND19},
-	{PXP2_REG_RQ_BW_RD_L20, PXP2_REG_RQ_BW_RD_ADD20,
-		PXP2_REG_RQ_BW_RD_UBOUND20},
-	{PXP2_REG_RQ_BW_RD_L22, PXP2_REG_RQ_BW_RD_ADD22,
-		PXP2_REG_RQ_BW_RD_UBOUND22},
-	{PXP2_REG_RQ_BW_RD_L23, PXP2_REG_RQ_BW_RD_ADD23,
-		PXP2_REG_RQ_BW_RD_UBOUND23},
-	{PXP2_REG_RQ_BW_RD_L24, PXP2_REG_RQ_BW_RD_ADD24,
-		PXP2_REG_RQ_BW_RD_UBOUND24},
-	{PXP2_REG_RQ_BW_RD_L25, PXP2_REG_RQ_BW_RD_ADD25,
-		PXP2_REG_RQ_BW_RD_UBOUND25},
-	{PXP2_REG_RQ_BW_RD_L26, PXP2_REG_RQ_BW_RD_ADD26,
-		PXP2_REG_RQ_BW_RD_UBOUND26},
-	{PXP2_REG_RQ_BW_RD_L27, PXP2_REG_RQ_BW_RD_ADD27,
-		PXP2_REG_RQ_BW_RD_UBOUND27},
-	{PXP2_REG_PSWRQ_BW_L28, PXP2_REG_PSWRQ_BW_ADD28,
-		PXP2_REG_PSWRQ_BW_UB28}
-};
-
-/* register addresses for write queues */
-static const struct arb_line write_arb_addr[NUM_WR_Q-1] = {
-/* 1 */	{PXP2_REG_PSWRQ_BW_L1, PXP2_REG_PSWRQ_BW_ADD1,
-		PXP2_REG_PSWRQ_BW_UB1},
-	{PXP2_REG_PSWRQ_BW_L2, PXP2_REG_PSWRQ_BW_ADD2,
-		PXP2_REG_PSWRQ_BW_UB2},
-	{PXP2_REG_PSWRQ_BW_L3, PXP2_REG_PSWRQ_BW_ADD3,
-		PXP2_REG_PSWRQ_BW_UB3},
-	{PXP2_REG_PSWRQ_BW_L6, PXP2_REG_PSWRQ_BW_ADD6,
-		PXP2_REG_PSWRQ_BW_UB6},
-	{PXP2_REG_PSWRQ_BW_L7, PXP2_REG_PSWRQ_BW_ADD7,
-		PXP2_REG_PSWRQ_BW_UB7},
-	{PXP2_REG_PSWRQ_BW_L8, PXP2_REG_PSWRQ_BW_ADD8,
-		PXP2_REG_PSWRQ_BW_UB8},
-	{PXP2_REG_PSWRQ_BW_L9, PXP2_REG_PSWRQ_BW_ADD9,
-		PXP2_REG_PSWRQ_BW_UB9},
-	{PXP2_REG_PSWRQ_BW_L10, PXP2_REG_PSWRQ_BW_ADD10,
-		PXP2_REG_PSWRQ_BW_UB10},
-	{PXP2_REG_PSWRQ_BW_L11, PXP2_REG_PSWRQ_BW_ADD11,
-		PXP2_REG_PSWRQ_BW_UB11},
-/* 10 */{PXP2_REG_PSWRQ_BW_L28, PXP2_REG_PSWRQ_BW_ADD28,
-		PXP2_REG_PSWRQ_BW_UB28},
-	{PXP2_REG_RQ_BW_WR_L29, PXP2_REG_RQ_BW_WR_ADD29,
-		PXP2_REG_RQ_BW_WR_UBOUND29},
-	{PXP2_REG_RQ_BW_WR_L30, PXP2_REG_RQ_BW_WR_ADD30,
-		PXP2_REG_RQ_BW_WR_UBOUND30}
-};
-
-
-/****************************************************************************
-* CDU
-****************************************************************************/
-
-#define CDU_REGION_NUMBER_XCM_AG	2
-#define CDU_REGION_NUMBER_UCM_AG	4
-
-/**
- * String-to-compress [31:8] = CID (all 24 bits)
- * String-to-compress [7:4] = Region
- * String-to-compress [3:0] = Type
- */
-#define CDU_VALID_DATA(_cid, _region, _type) \
-		(((_cid) << 8) | (((_region) & 0xf) << 4) | (((_type) & 0xf)))
-#define CDU_CRC8(_cid, _region, _type) \
-			calc_crc8(CDU_VALID_DATA(_cid, _region, _type), 0xff)
-#define CDU_RSRVD_VALUE_TYPE_A(_cid, _region, _type) \
-			(0x80 | (CDU_CRC8(_cid, _region, _type) & 0x7f))
-#define CDU_RSRVD_VALUE_TYPE_B(_crc, _type) \
-	(0x80 | ((_type) & 0xf << 3) | (CDU_CRC8(_cid, _region, _type) & 0x7))
-#define CDU_RSRVD_INVALIDATE_CONTEXT_VALUE(_val)	((_val) & ~0x80)
-
-
-/* registers addresses are not in order
-   so these arrays help simplify the code */
-static const int cm_blocks[9] = {
-	MISC_BLOCK, TCM_BLOCK,  UCM_BLOCK,  CCM_BLOCK, XCM_BLOCK,
-	TSEM_BLOCK, USEM_BLOCK, CSEM_BLOCK, XSEM_BLOCK
-};
-
 #endif /* BNX2X_INIT_H */
 
diff --git a/drivers/net/bnx2x_init_ops.h b/drivers/net/bnx2x_init_ops.h
index 32552b9..38b970a 100644
--- a/drivers/net/bnx2x_init_ops.h
+++ b/drivers/net/bnx2x_init_ops.h
@@ -11,85 +11,68 @@
  * Maintained by: Eilon Greenstein <eilong@broadcom.com>
  * Written by: Vladislav Zolotarov <vladz@broadcom.com>
  */
+
 #ifndef BNX2X_INIT_OPS_H
 #define BNX2X_INIT_OPS_H
 
-static void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
 static int bnx2x_gunzip(struct bnx2x *bp, const u8 *zbuf, int len);
 
+
 static void bnx2x_init_str_wr(struct bnx2x *bp, u32 addr, const u32 *data,
 			      u32 len)
 {
-	int i;
+	u32 i;
 
-	for (i = 0; i < len; i++) {
+	for (i = 0; i < len; i++)
 		REG_WR(bp, addr + i*4, data[i]);
-		if (!(i % 10000)) {
-			touch_softlockup_watchdog();
-			cpu_relax();
-		}
-	}
 }
 
 static void bnx2x_init_ind_wr(struct bnx2x *bp, u32 addr, const u32 *data,
-			      u16 len)
+			      u32 len)
 {
-	int i;
+	u32 i;
 
-	for (i = 0; i < len; i++) {
+	for (i = 0; i < len; i++)
 		REG_WR_IND(bp, addr + i*4, data[i]);
-		if (!(i % 10000)) {
-			touch_softlockup_watchdog();
-			cpu_relax();
-		}
-	}
 }
 
 static void bnx2x_write_big_buf(struct bnx2x *bp, u32 addr, u32 len)
 {
-	int offset = 0;
-
-	if (bp->dmae_ready) {
-		while (len > DMAE_LEN32_WR_MAX) {
-			bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
-					 addr + offset, DMAE_LEN32_WR_MAX);
-			offset += DMAE_LEN32_WR_MAX * 4;
-			len -= DMAE_LEN32_WR_MAX;
-		}
-		bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
-				 addr + offset, len);
-	} else
-		bnx2x_init_str_wr(bp, addr, bp->gunzip_buf, len);
+	if (bp->dmae_ready)
+		bnx2x_write_dmae_phys_len(bp, GUNZIP_PHYS(bp), addr, len);
+	else
+		bnx2x_init_str_wr(bp, addr, GUNZIP_BUF(bp), len);
 }
 
 static void bnx2x_init_fill(struct bnx2x *bp, u32 addr, int fill, u32 len)
 {
-	u32 buf_len = (((len * 4) > FW_BUF_SIZE) ? FW_BUF_SIZE : (len * 4));
-	u32 buf_len32 = buf_len / 4;
-	int i;
+	u32 buf_len = (((len*4) > FW_BUF_SIZE) ? FW_BUF_SIZE : (len*4));
+	u32 buf_len32 = buf_len/4;
+	u32 i;
 
-	memset(bp->gunzip_buf, fill, buf_len);
+	memset(GUNZIP_BUF(bp), (u8)fill, buf_len);
 
 	for (i = 0; i < len; i += buf_len32) {
 		u32 cur_len = min(buf_len32, len - i);
 
-		bnx2x_write_big_buf(bp, addr + i * 4, cur_len);
+		bnx2x_write_big_buf(bp, addr + i*4, cur_len);
 	}
 }
 
 static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr, const u32 *data,
 			     u32 len64)
 {
-	u32 buf_len32 = FW_BUF_SIZE / 4;
-	u32 len = len64 * 2;
+	u32 buf_len32 = FW_BUF_SIZE/4;
+	u32 len = len64*2;
 	u64 data64 = 0;
-	int i;
+	u32 i;
 
 	/* 64 bit value is in a blob: first low DWORD, then high DWORD */
 	data64 = HILO_U64((*(data + 1)), (*data));
+
 	len64 = min((u32)(FW_BUF_SIZE/8), len64);
 	for (i = 0; i < len64; i++) {
-		u64 *pdata = ((u64 *)(bp->gunzip_buf)) + i;
+		u64 *pdata = ((u64 *)(GUNZIP_BUF(bp))) + i;
 
 		*pdata = data64;
 	}
@@ -97,7 +80,7 @@ static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr, const u32 *data,
 	for (i = 0; i < len; i += buf_len32) {
 		u32 cur_len = min(buf_len32, len - i);
 
-		bnx2x_write_big_buf(bp, addr + i * 4, cur_len);
+		bnx2x_write_big_buf(bp, addr + i*4, cur_len);
 	}
 }
 
@@ -118,97 +101,81 @@ static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr, const u32 *data,
 static const u8 *bnx2x_sel_blob(struct bnx2x *bp, u32 addr, const u8 *data)
 {
 	IF_IS_INT_TABLE_ADDR(TSEM_REG_INT_TABLE, addr)
-		data = bp->tsem_int_table_data;
-	else IF_IS_INT_TABLE_ADDR(CSEM_REG_INT_TABLE, addr)
-		data = bp->csem_int_table_data;
-	else IF_IS_INT_TABLE_ADDR(USEM_REG_INT_TABLE, addr)
-		data = bp->usem_int_table_data;
-	else IF_IS_INT_TABLE_ADDR(XSEM_REG_INT_TABLE, addr)
-		data = bp->xsem_int_table_data;
-	else IF_IS_PRAM_ADDR(TSEM_REG_PRAM, addr)
-		data = bp->tsem_pram_data;
-	else IF_IS_PRAM_ADDR(CSEM_REG_PRAM, addr)
-		data = bp->csem_pram_data;
-	else IF_IS_PRAM_ADDR(USEM_REG_PRAM, addr)
-		data = bp->usem_pram_data;
-	else IF_IS_PRAM_ADDR(XSEM_REG_PRAM, addr)
-		data = bp->xsem_pram_data;
+		data = INIT_TSEM_INT_TABLE_DATA(bp);
+	else
+		IF_IS_INT_TABLE_ADDR(CSEM_REG_INT_TABLE, addr)
+			data = INIT_CSEM_INT_TABLE_DATA(bp);
+	else
+		IF_IS_INT_TABLE_ADDR(USEM_REG_INT_TABLE, addr)
+			data = INIT_USEM_INT_TABLE_DATA(bp);
+	else
+		IF_IS_INT_TABLE_ADDR(XSEM_REG_INT_TABLE, addr)
+			data = INIT_XSEM_INT_TABLE_DATA(bp);
+	else
+		IF_IS_PRAM_ADDR(TSEM_REG_PRAM, addr)
+			data = INIT_TSEM_PRAM_DATA(bp);
+	else
+		IF_IS_PRAM_ADDR(CSEM_REG_PRAM, addr)
+			data = INIT_CSEM_PRAM_DATA(bp);
+	else
+		IF_IS_PRAM_ADDR(USEM_REG_PRAM, addr)
+			data = INIT_USEM_PRAM_DATA(bp);
+	else
+		IF_IS_PRAM_ADDR(XSEM_REG_PRAM, addr)
+			data = INIT_XSEM_PRAM_DATA(bp);
 
 	return data;
 }
 
 static void bnx2x_write_big_buf_wb(struct bnx2x *bp, u32 addr, u32 len)
 {
-	int offset = 0;
-
-	if (bp->dmae_ready) {
-		while (len > DMAE_LEN32_WR_MAX) {
-			bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
-					 addr + offset, DMAE_LEN32_WR_MAX);
-			offset += DMAE_LEN32_WR_MAX * 4;
-			len -= DMAE_LEN32_WR_MAX;
-		}
-		bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
-				 addr + offset, len);
-	} else
-		bnx2x_init_ind_wr(bp, addr, bp->gunzip_buf, len);
+	if (bp->dmae_ready)
+		bnx2x_write_dmae_phys_len(bp, GUNZIP_PHYS(bp), addr, len);
+	else
+		bnx2x_init_ind_wr(bp, addr, GUNZIP_BUF(bp), len);
 }
 
 static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 			     u32 len)
 {
-	/* This is needed for NO_ZIP mode, currently supported
-	   in little endian mode only */
-	data = (const u32*)bnx2x_sel_blob(bp, addr, (const u8*)data);
+	data = (const u32 *)bnx2x_sel_blob(bp, addr, (const u8 *)data);
 
-	if ((len * 4) > FW_BUF_SIZE) {
-		BNX2X_ERR("LARGE DMAE OPERATION ! "
-			  "addr 0x%x  len 0x%x\n", addr, len*4);
-		return;
-	}
-	memcpy(bp->gunzip_buf, data, len * 4);
-
-	bnx2x_write_big_buf_wb(bp, addr, len);
+	if (bp->dmae_ready)
+		VIRT_WR_DMAE_LEN(bp, data, addr, len);
+	else
+		bnx2x_init_ind_wr(bp, addr, data, len);
 }
 
-static void bnx2x_init_wr_zp(struct bnx2x *bp, u32 addr,
-			     u32 len, u32 blob_off)
+static void bnx2x_init_wr_zp(struct bnx2x *bp, u32 addr, u32 len, u32 blob_off)
 {
-	int rc, i;
-        const u8 *data = NULL;
+	const u8 *data = NULL;
+	int rc;
+	u32 i;
 
-	data = bnx2x_sel_blob(bp, addr, data) + 4*blob_off;
-
-	if (data == NULL) {
-		panic("Blob not found for addr 0x%x\n", addr);
-		return;
-	}
+	data = bnx2x_sel_blob(bp, addr, data) + blob_off*4;
 
 	rc = bnx2x_gunzip(bp, data, len);
-	if (rc) {
-		BNX2X_ERR("gunzip failed ! addr 0x%x rc %d\n", addr, rc);
-		BNX2X_ERR("blob_offset=0x%x\n", blob_off);
+	if (rc)
 		return;
-	}
 
 	/* gunzip_outlen is in dwords */
-	len = bp->gunzip_outlen;
+	len = GUNZIP_OUTLEN(bp);
 	for (i = 0; i < len; i++)
-		((u32 *)bp->gunzip_buf)[i] =
-			cpu_to_le32(((u32 *)bp->gunzip_buf)[i]);
+		((u32 *)GUNZIP_BUF(bp))[i] =
+				cpu_to_le32(((u32 *)GUNZIP_BUF(bp))[i]);
 
 	bnx2x_write_big_buf_wb(bp, addr, len);
 }
 
 static void bnx2x_init_block(struct bnx2x *bp, u32 block, u32 stage)
 {
-	int hw_wr, i;
 	u16 op_start =
-		bp->init_ops_offsets[BLOCK_OPS_IDX(block,stage,STAGE_START)];
+		INIT_OPS_OFFSETS(bp)[BLOCK_OPS_IDX(block, stage, STAGE_START)];
 	u16 op_end =
-		bp->init_ops_offsets[BLOCK_OPS_IDX(block,stage,STAGE_END)];
+		INIT_OPS_OFFSETS(bp)[BLOCK_OPS_IDX(block, stage, STAGE_END)];
 	union init_op *op;
-	u32 op_type, addr, len;
+	int hw_wr;
+	u32 i, op_type, addr, len;
 	const u32 *data, *data_base;
 
 	/* If empty block */
@@ -222,11 +189,11 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 block, u32 stage)
 	else
 		hw_wr = OP_WR_ASIC;
 
-	data_base = bp->init_data;
+	data_base = INIT_DATA(bp);
 
 	for (i = op_start; i < op_end; i++) {
 
-		op = (union init_op *)&(bp->init_ops[i]);
+		op = (union init_op *)&(INIT_OPS(bp)[i]);
 
 		op_type = op->str_wr.op;
 		addr = op->str_wr.offset;
@@ -234,7 +201,7 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 block, u32 stage)
 		data = data_base + op->str_wr.data_off;
 
 		/* HW/EMUL specific */
-		if (unlikely((op_type > OP_WB) && (op_type == hw_wr)))
+		if ((op_type > OP_WB) && (op_type == hw_wr))
 			op_type = OP_WR;
 
 		switch (op_type) {
@@ -265,35 +232,179 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 block, u32 stage)
 			break;
 		default:
 			/* happens whenever an op is of a diff HW */
-#if 0
-			DP(NETIF_MSG_HW, "skipping init operation  "
-			   "index %d[%d:%d]: type %d  addr 0x%x  "
-			   "len %d(0x%x)\n",
-			   i, op_start, op_end, op_type, addr, len, len);
-#endif
 			break;
 		}
 	}
 }
 
-/* PXP */
-static void bnx2x_init_pxp(struct bnx2x *bp)
+
+/****************************************************************************
+* PXP Arbiter
+****************************************************************************/
+/*
+ * This code configures the PCI read/write arbiter
+ * which implements a weighted round robin
+ * between the virtual queues in the chip.
+ *
+ * The values were derived for each PCI max payload and max request size.
+ * since max payload and max request size are only known at run time,
+ * this is done as a separate init stage.
+ */
+
+#define NUM_WR_Q			13
+#define NUM_RD_Q			29
+#define MAX_RD_ORD			3
+#define MAX_WR_ORD			2
+
+/* configuration for one arbiter queue */
+struct arb_line {
+	int l;
+	int add;
+	int ubound;
+};
+
+/* derived configuration for each read queue for each max request size */
+static const struct arb_line read_arb_data[NUM_RD_Q][MAX_RD_ORD + 1] = {
+/* 1 */	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25}, {64, 64, 41} },
+	{ {4, 8,  4},  {4,  8,  4},  {4,  8,  4},  {4,  8,  4}  },
+	{ {4, 3,  3},  {4,  3,  3},  {4,  3,  3},  {4,  3,  3}  },
+	{ {8, 3,  6},  {16, 3,  11}, {16, 3,  11}, {16, 3,  11} },
+	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25}, {64, 64, 41} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
+/* 10 */{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 64, 6},  {16, 64, 11}, {32, 64, 21}, {32, 64, 21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+/* 20 */{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 64, 25}, {16, 64, 41}, {32, 64, 81}, {64, 64, 120} }
+};
+
+/* derived configuration for each write queue for each max request size */
+static const struct arb_line write_arb_data[NUM_WR_Q][MAX_WR_ORD + 1] = {
+/* 1 */	{ {4, 6,  3},  {4,  6,  3},  {4,  6,  3} },
+	{ {4, 2,  3},  {4,  2,  3},  {4,  2,  3} },
+	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
+	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
+	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
+	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
+	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25} },
+	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
+	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
+/* 10 */{ {8, 9,  6},  {16, 9,  11}, {32, 9,  21} },
+	{ {8, 47, 19}, {16, 47, 19}, {32, 47, 21} },
+	{ {8, 9,  6},  {16, 9,  11}, {16, 9,  11} },
+	{ {8, 64, 25}, {16, 64, 41}, {32, 64, 81} }
+};
+
+/* register addresses for read queues */
+static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
+/* 1 */	{PXP2_REG_RQ_BW_RD_L0, PXP2_REG_RQ_BW_RD_ADD0,
+		PXP2_REG_RQ_BW_RD_UBOUND0},
+	{PXP2_REG_PSWRQ_BW_L1, PXP2_REG_PSWRQ_BW_ADD1,
+		PXP2_REG_PSWRQ_BW_UB1},
+	{PXP2_REG_PSWRQ_BW_L2, PXP2_REG_PSWRQ_BW_ADD2,
+		PXP2_REG_PSWRQ_BW_UB2},
+	{PXP2_REG_PSWRQ_BW_L3, PXP2_REG_PSWRQ_BW_ADD3,
+		PXP2_REG_PSWRQ_BW_UB3},
+	{PXP2_REG_RQ_BW_RD_L4, PXP2_REG_RQ_BW_RD_ADD4,
+		PXP2_REG_RQ_BW_RD_UBOUND4},
+	{PXP2_REG_RQ_BW_RD_L5, PXP2_REG_RQ_BW_RD_ADD5,
+		PXP2_REG_RQ_BW_RD_UBOUND5},
+	{PXP2_REG_PSWRQ_BW_L6, PXP2_REG_PSWRQ_BW_ADD6,
+		PXP2_REG_PSWRQ_BW_UB6},
+	{PXP2_REG_PSWRQ_BW_L7, PXP2_REG_PSWRQ_BW_ADD7,
+		PXP2_REG_PSWRQ_BW_UB7},
+	{PXP2_REG_PSWRQ_BW_L8, PXP2_REG_PSWRQ_BW_ADD8,
+		PXP2_REG_PSWRQ_BW_UB8},
+/* 10 */{PXP2_REG_PSWRQ_BW_L9, PXP2_REG_PSWRQ_BW_ADD9,
+		PXP2_REG_PSWRQ_BW_UB9},
+	{PXP2_REG_PSWRQ_BW_L10, PXP2_REG_PSWRQ_BW_ADD10,
+		PXP2_REG_PSWRQ_BW_UB10},
+	{PXP2_REG_PSWRQ_BW_L11, PXP2_REG_PSWRQ_BW_ADD11,
+		PXP2_REG_PSWRQ_BW_UB11},
+	{PXP2_REG_RQ_BW_RD_L12, PXP2_REG_RQ_BW_RD_ADD12,
+		PXP2_REG_RQ_BW_RD_UBOUND12},
+	{PXP2_REG_RQ_BW_RD_L13, PXP2_REG_RQ_BW_RD_ADD13,
+		PXP2_REG_RQ_BW_RD_UBOUND13},
+	{PXP2_REG_RQ_BW_RD_L14, PXP2_REG_RQ_BW_RD_ADD14,
+		PXP2_REG_RQ_BW_RD_UBOUND14},
+	{PXP2_REG_RQ_BW_RD_L15, PXP2_REG_RQ_BW_RD_ADD15,
+		PXP2_REG_RQ_BW_RD_UBOUND15},
+	{PXP2_REG_RQ_BW_RD_L16, PXP2_REG_RQ_BW_RD_ADD16,
+		PXP2_REG_RQ_BW_RD_UBOUND16},
+	{PXP2_REG_RQ_BW_RD_L17, PXP2_REG_RQ_BW_RD_ADD17,
+		PXP2_REG_RQ_BW_RD_UBOUND17},
+	{PXP2_REG_RQ_BW_RD_L18, PXP2_REG_RQ_BW_RD_ADD18,
+		PXP2_REG_RQ_BW_RD_UBOUND18},
+/* 20 */{PXP2_REG_RQ_BW_RD_L19, PXP2_REG_RQ_BW_RD_ADD19,
+		PXP2_REG_RQ_BW_RD_UBOUND19},
+	{PXP2_REG_RQ_BW_RD_L20, PXP2_REG_RQ_BW_RD_ADD20,
+		PXP2_REG_RQ_BW_RD_UBOUND20},
+	{PXP2_REG_RQ_BW_RD_L22, PXP2_REG_RQ_BW_RD_ADD22,
+		PXP2_REG_RQ_BW_RD_UBOUND22},
+	{PXP2_REG_RQ_BW_RD_L23, PXP2_REG_RQ_BW_RD_ADD23,
+		PXP2_REG_RQ_BW_RD_UBOUND23},
+	{PXP2_REG_RQ_BW_RD_L24, PXP2_REG_RQ_BW_RD_ADD24,
+		PXP2_REG_RQ_BW_RD_UBOUND24},
+	{PXP2_REG_RQ_BW_RD_L25, PXP2_REG_RQ_BW_RD_ADD25,
+		PXP2_REG_RQ_BW_RD_UBOUND25},
+	{PXP2_REG_RQ_BW_RD_L26, PXP2_REG_RQ_BW_RD_ADD26,
+		PXP2_REG_RQ_BW_RD_UBOUND26},
+	{PXP2_REG_RQ_BW_RD_L27, PXP2_REG_RQ_BW_RD_ADD27,
+		PXP2_REG_RQ_BW_RD_UBOUND27},
+	{PXP2_REG_PSWRQ_BW_L28, PXP2_REG_PSWRQ_BW_ADD28,
+		PXP2_REG_PSWRQ_BW_UB28}
+};
+
+/* register addresses for write queues */
+static const struct arb_line write_arb_addr[NUM_WR_Q-1] = {
+/* 1 */	{PXP2_REG_PSWRQ_BW_L1, PXP2_REG_PSWRQ_BW_ADD1,
+		PXP2_REG_PSWRQ_BW_UB1},
+	{PXP2_REG_PSWRQ_BW_L2, PXP2_REG_PSWRQ_BW_ADD2,
+		PXP2_REG_PSWRQ_BW_UB2},
+	{PXP2_REG_PSWRQ_BW_L3, PXP2_REG_PSWRQ_BW_ADD3,
+		PXP2_REG_PSWRQ_BW_UB3},
+	{PXP2_REG_PSWRQ_BW_L6, PXP2_REG_PSWRQ_BW_ADD6,
+		PXP2_REG_PSWRQ_BW_UB6},
+	{PXP2_REG_PSWRQ_BW_L7, PXP2_REG_PSWRQ_BW_ADD7,
+		PXP2_REG_PSWRQ_BW_UB7},
+	{PXP2_REG_PSWRQ_BW_L8, PXP2_REG_PSWRQ_BW_ADD8,
+		PXP2_REG_PSWRQ_BW_UB8},
+	{PXP2_REG_PSWRQ_BW_L9, PXP2_REG_PSWRQ_BW_ADD9,
+		PXP2_REG_PSWRQ_BW_UB9},
+	{PXP2_REG_PSWRQ_BW_L10, PXP2_REG_PSWRQ_BW_ADD10,
+		PXP2_REG_PSWRQ_BW_UB10},
+	{PXP2_REG_PSWRQ_BW_L11, PXP2_REG_PSWRQ_BW_ADD11,
+		PXP2_REG_PSWRQ_BW_UB11},
+/* 10 */{PXP2_REG_PSWRQ_BW_L28, PXP2_REG_PSWRQ_BW_ADD28,
+		PXP2_REG_PSWRQ_BW_UB28},
+	{PXP2_REG_RQ_BW_WR_L29, PXP2_REG_RQ_BW_WR_ADD29,
+		PXP2_REG_RQ_BW_WR_UBOUND29},
+	{PXP2_REG_RQ_BW_WR_L30, PXP2_REG_RQ_BW_WR_ADD30,
+		PXP2_REG_RQ_BW_WR_UBOUND30}
+};
+
+static void bnx2x_init_pxp_arb(struct bnx2x *bp, int r_order, int w_order)
 {
-	u16 devctl;
-	int r_order, w_order;
 	u32 val, i;
 
-	pci_read_config_word(bp->pdev,
-			     bp->pcie_cap + PCI_EXP_DEVCTL, &devctl);
-	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", devctl);
-	w_order = ((devctl & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
-	if (bp->mrrs == -1)
-		r_order = ((devctl & PCI_EXP_DEVCTL_READRQ) >> 12);
-	else {
-		DP(NETIF_MSG_HW, "force read order to %d\n", bp->mrrs);
-		r_order = bp->mrrs;
-	}
-
 	if (r_order > MAX_RD_ORD) {
 		DP(NETIF_MSG_HW, "read order of %d  order adjusted to %d\n",
 		   r_order, MAX_RD_ORD);
@@ -367,6 +478,11 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 	REG_WR(bp, PXP2_REG_WR_USDMDP_TH, (0x18 << w_order));
 
 	if (CHIP_IS_E1H(bp)) {
+		/*    MPS      w_order     optimal TH      presently TH
+		 *    128         0             0               2
+		 *    256         1             1               3
+		 *    >=512       2             2               3
+		 */
 		val = ((w_order == 0) ? 2 : 3);
 		REG_WR(bp, PXP2_REG_WR_HC_MPS, val);
 		REG_WR(bp, PXP2_REG_WR_USDM_MPS, val);
@@ -382,61 +498,4 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 	}
 }
 
-/*****************************************************************************
- * Description:
- *         Calculates crc 8 on a word value: polynomial 0-1-2-8
- *         Code was translated from Verilog.
- ****************************************************************************/
-static u8 calc_crc8(u32 data, u8 crc)
-{
-	u8 D[32];
-	u8 NewCRC[8];
-	u8 C[8];
-	u8 crc_res;
-	u8 i;
-
-	/* split the data into 31 bits */
-	for (i = 0; i < 32; i++) {
-		D[i] = data & 1;
-		data = data >> 1;
-	}
-
-	/* split the crc into 8 bits */
-	for (i = 0; i < 8; i++) {
-		C[i] = crc & 1;
-		crc = crc >> 1;
-	}
-
-	NewCRC[0] = D[31] ^ D[30] ^ D[28] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^
-		D[16] ^ D[14] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[0] ^ C[4] ^
-		C[6] ^ C[7];
-	NewCRC[1] = D[30] ^ D[29] ^ D[28] ^ D[24] ^ D[23] ^ D[22] ^ D[21] ^
-		D[20] ^ D[18] ^ D[17] ^ D[16] ^ D[15] ^ D[14] ^ D[13] ^
-		D[12] ^ D[9] ^ D[6] ^ D[1] ^ D[0] ^ C[0] ^ C[4] ^ C[5] ^ C[6];
-	NewCRC[2] = D[29] ^ D[28] ^ D[25] ^ D[24] ^ D[22] ^ D[17] ^ D[15] ^
-		D[13] ^ D[12] ^ D[10] ^ D[8] ^ D[6] ^ D[2] ^ D[1] ^ D[0] ^
-		C[0] ^ C[1] ^ C[4] ^ C[5];
-	NewCRC[3] = D[30] ^ D[29] ^ D[26] ^ D[25] ^ D[23] ^ D[18] ^ D[16] ^
-		D[14] ^ D[13] ^ D[11] ^ D[9] ^ D[7] ^ D[3] ^ D[2] ^ D[1] ^
-		C[1] ^ C[2] ^ C[5] ^ C[6];
-	NewCRC[4] = D[31] ^ D[30] ^ D[27] ^ D[26] ^ D[24] ^ D[19] ^ D[17] ^
-		D[15] ^ D[14] ^ D[12] ^ D[10] ^ D[8] ^ D[4] ^ D[3] ^ D[2] ^
-		C[0] ^ C[2] ^ C[3] ^ C[6] ^ C[7];
-	NewCRC[5] = D[31] ^ D[28] ^ D[27] ^ D[25] ^ D[20] ^ D[18] ^ D[16] ^
-		D[15] ^ D[13] ^ D[11] ^ D[9] ^ D[5] ^ D[4] ^ D[3] ^ C[1] ^
-		C[3] ^ C[4] ^ C[7];
-	NewCRC[6] = D[29] ^ D[28] ^ D[26] ^ D[21] ^ D[19] ^ D[17] ^ D[16] ^
-		D[14] ^ D[12] ^ D[10] ^ D[6] ^ D[5] ^ D[4] ^ C[2] ^ C[4] ^
-		C[5];
-	NewCRC[7] = D[30] ^ D[29] ^ D[27] ^ D[22] ^ D[20] ^ D[18] ^ D[17] ^
-		D[15] ^ D[13] ^ D[11] ^ D[7] ^ D[6] ^ D[5] ^ C[3] ^ C[5] ^
-		C[6];
-
-	crc_res = 0;
-	for (i = 0; i < 8; i++)
-		crc_res |= (NewCRC[i] << i);
-
-	return crc_res;
-}
-
 #endif /* BNX2X_INIT_OPS_H */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 23b9c7d..c4c0f97 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -153,7 +153,7 @@ MODULE_DEVICE_TABLE(pci, bnx2x_pci_tbl);
 /* used only at init
  * locking is done by mcp
  */
-static void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val)
+void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val)
 {
 	pci_write_config_dword(bp->pdev, PCICFG_GRC_ADDRESS, addr);
 	pci_write_config_dword(bp->pdev, PCICFG_GRC_DATA, val);
@@ -346,6 +346,21 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 	mutex_unlock(&bp->dmae_mutex);
 }
 
+void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
+			       u32 addr, u32 len)
+{
+	int offset = 0;
+
+	while (len > DMAE_LEN32_WR_MAX) {
+		bnx2x_write_dmae(bp, phys_addr + offset,
+				 addr + offset, DMAE_LEN32_WR_MAX);
+		offset += DMAE_LEN32_WR_MAX * 4;
+		len -= DMAE_LEN32_WR_MAX;
+	}
+
+	bnx2x_write_dmae(bp, phys_addr + offset, addr + offset, len);
+}
+
 /* used only for slowpath so not inlined */
 static void bnx2x_wb_wr(struct bnx2x *bp, int reg, u32 val_hi, u32 val_lo)
 {
@@ -5916,6 +5931,24 @@ static void bnx2x_reset_common(struct bnx2x *bp)
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR, 0x1403);
 }
 
+static void bnx2x_init_pxp(struct bnx2x *bp)
+{
+	u16 devctl;
+	int r_order, w_order;
+
+	pci_read_config_word(bp->pdev,
+			     bp->pcie_cap + PCI_EXP_DEVCTL, &devctl);
+	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", devctl);
+	w_order = ((devctl & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
+	if (bp->mrrs == -1)
+		r_order = ((devctl & PCI_EXP_DEVCTL_READRQ) >> 12);
+	else {
+		DP(NETIF_MSG_HW, "force read order to %d\n", bp->mrrs);
+		r_order = bp->mrrs;
+	}
+
+	bnx2x_init_pxp_arb(bp, r_order, w_order);
+}
 
 static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 {
@@ -6478,9 +6511,15 @@ static int bnx2x_init_func(struct bnx2x *bp)
 
 
 	if (CHIP_IS_E1H(bp)) {
-		for (i = 0; i < 9; i++)
-			bnx2x_init_block(bp,
-					 cm_blocks[i], FUNC0_STAGE + func);
+		bnx2x_init_block(bp, MISC_BLOCK, FUNC0_STAGE + func);
+		bnx2x_init_block(bp, TCM_BLOCK, FUNC0_STAGE + func);
+		bnx2x_init_block(bp, UCM_BLOCK, FUNC0_STAGE + func);
+		bnx2x_init_block(bp, CCM_BLOCK, FUNC0_STAGE + func);
+		bnx2x_init_block(bp, XCM_BLOCK, FUNC0_STAGE + func);
+		bnx2x_init_block(bp, TSEM_BLOCK, FUNC0_STAGE + func);
+		bnx2x_init_block(bp, USEM_BLOCK, FUNC0_STAGE + func);
+		bnx2x_init_block(bp, CSEM_BLOCK, FUNC0_STAGE + func);
+		bnx2x_init_block(bp, XSEM_BLOCK, FUNC0_STAGE + func);
 
 		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
 		REG_WR(bp, NIG_REG_LLH0_FUNC_VLAN_ID + port*8, bp->e1hov);
@@ -11833,22 +11872,22 @@ static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
 	BNX2X_ALLOC_AND_SET(init_ops_offsets, init_offsets_alloc_err, be16_to_cpu_n);
 
 	/* STORMs firmware */
-	bp->tsem_int_table_data = bp->firmware->data +
-		be32_to_cpu(fw_hdr->tsem_int_table_data.offset);
-	bp->tsem_pram_data      = bp->firmware->data +
-		be32_to_cpu(fw_hdr->tsem_pram_data.offset);
-	bp->usem_int_table_data = bp->firmware->data +
-		be32_to_cpu(fw_hdr->usem_int_table_data.offset);
-	bp->usem_pram_data      = bp->firmware->data +
-		be32_to_cpu(fw_hdr->usem_pram_data.offset);
-	bp->xsem_int_table_data = bp->firmware->data +
-		be32_to_cpu(fw_hdr->xsem_int_table_data.offset);
-	bp->xsem_pram_data      = bp->firmware->data +
-		be32_to_cpu(fw_hdr->xsem_pram_data.offset);
-	bp->csem_int_table_data = bp->firmware->data +
-		be32_to_cpu(fw_hdr->csem_int_table_data.offset);
-	bp->csem_pram_data      = bp->firmware->data +
-		be32_to_cpu(fw_hdr->csem_pram_data.offset);
+	INIT_TSEM_INT_TABLE_DATA(bp) = bp->firmware->data +
+			be32_to_cpu(fw_hdr->tsem_int_table_data.offset);
+	INIT_TSEM_PRAM_DATA(bp)      = bp->firmware->data +
+			be32_to_cpu(fw_hdr->tsem_pram_data.offset);
+	INIT_USEM_INT_TABLE_DATA(bp) = bp->firmware->data +
+			be32_to_cpu(fw_hdr->usem_int_table_data.offset);
+	INIT_USEM_PRAM_DATA(bp)      = bp->firmware->data +
+			be32_to_cpu(fw_hdr->usem_pram_data.offset);
+	INIT_XSEM_INT_TABLE_DATA(bp) = bp->firmware->data +
+			be32_to_cpu(fw_hdr->xsem_int_table_data.offset);
+	INIT_XSEM_PRAM_DATA(bp)      = bp->firmware->data +
+			be32_to_cpu(fw_hdr->xsem_pram_data.offset);
+	INIT_CSEM_INT_TABLE_DATA(bp) = bp->firmware->data +
+			be32_to_cpu(fw_hdr->csem_int_table_data.offset);
+	INIT_CSEM_PRAM_DATA(bp)      = bp->firmware->data +
+			be32_to_cpu(fw_hdr->csem_pram_data.offset);
 
 	return 0;
 init_offsets_alloc_err:
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 9998386..1e6f5aa 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -6019,3 +6019,116 @@ Theotherbitsarereservedandshouldbezero*/
 #define COMMAND_REG_SIMD_NOMASK     0x1c
 
 
+#define IGU_MEM_BASE						0x0000
+
+#define IGU_MEM_MSIX_BASE					0x0000
+#define IGU_MEM_MSIX_UPPER					0x007f
+#define IGU_MEM_MSIX_RESERVED_UPPER			0x01ff
+
+#define IGU_MEM_PBA_MSIX_BASE				0x0200
+#define IGU_MEM_PBA_MSIX_UPPER				0x0200
+
+#define IGU_CMD_BACKWARD_COMP_PROD_UPD		0x0201
+#define IGU_MEM_PBA_MSIX_RESERVED_UPPER 	0x03ff
+
+#define IGU_CMD_INT_ACK_BASE				0x0400
+#define IGU_CMD_INT_ACK_UPPER\
+	(IGU_CMD_INT_ACK_BASE + MAX_SB_PER_PORT * NUM_OF_PORTS_PER_PATH - 1)
+#define IGU_CMD_INT_ACK_RESERVED_UPPER		0x04ff
+
+#define IGU_CMD_E2_PROD_UPD_BASE			0x0500
+#define IGU_CMD_E2_PROD_UPD_UPPER\
+	(IGU_CMD_E2_PROD_UPD_BASE + MAX_SB_PER_PORT * NUM_OF_PORTS_PER_PATH - 1)
+#define IGU_CMD_E2_PROD_UPD_RESERVED_UPPER	0x059f
+
+#define IGU_CMD_ATTN_BIT_UPD_UPPER			0x05a0
+#define IGU_CMD_ATTN_BIT_SET_UPPER			0x05a1
+#define IGU_CMD_ATTN_BIT_CLR_UPPER			0x05a2
+
+#define IGU_REG_SISR_MDPC_WMASK_UPPER		0x05a3
+#define IGU_REG_SISR_MDPC_WMASK_LSB_UPPER	0x05a4
+#define IGU_REG_SISR_MDPC_WMASK_MSB_UPPER	0x05a5
+#define IGU_REG_SISR_MDPC_WOMASK_UPPER		0x05a6
+
+#define IGU_REG_RESERVED_UPPER				0x05ff
+
+
+#define CDU_REGION_NUMBER_XCM_AG 2
+#define CDU_REGION_NUMBER_UCM_AG 4
+
+
+/**
+ * String-to-compress [31:8] = CID (all 24 bits)
+ * String-to-compress [7:4] = Region
+ * String-to-compress [3:0] = Type
+ */
+#define CDU_VALID_DATA(_cid, _region, _type)\
+	(((_cid) << 8) | (((_region)&0xf)<<4) | (((_type)&0xf)))
+#define CDU_CRC8(_cid, _region, _type)\
+	(calc_crc8(CDU_VALID_DATA(_cid, _region, _type), 0xff))
+#define CDU_RSRVD_VALUE_TYPE_A(_cid, _region, _type)\
+	(0x80 | ((CDU_CRC8(_cid, _region, _type)) & 0x7f))
+#define CDU_RSRVD_VALUE_TYPE_B(_crc, _type)\
+	(0x80 | ((_type)&0xf << 3) | ((CDU_CRC8(_cid, _region, _type)) & 0x7))
+#define CDU_RSRVD_INVALIDATE_CONTEXT_VALUE(_val) ((_val) & ~0x80)
+
+/******************************************************************************
+ * Description:
+ *	   Calculates crc 8 on a word value: polynomial 0-1-2-8
+ *	   Code was translated from Verilog.
+ * Return:
+ *****************************************************************************/
+static inline u8 calc_crc8(u32 data, u8 crc)
+{
+	u8 D[32];
+	u8 NewCRC[8];
+	u8 C[8];
+	u8 crc_res;
+	u8 i;
+
+	/* split the data into 31 bits */
+	for (i = 0; i < 32; i++) {
+		D[i] = (u8)(data & 1);
+		data = data >> 1;
+	}
+
+	/* split the crc into 8 bits */
+	for (i = 0; i < 8; i++) {
+		C[i] = crc & 1;
+		crc = crc >> 1;
+	}
+
+	NewCRC[0] = D[31] ^ D[30] ^ D[28] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^
+		    D[16] ^ D[14] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[0] ^ C[4] ^
+		    C[6] ^ C[7];
+	NewCRC[1] = D[30] ^ D[29] ^ D[28] ^ D[24] ^ D[23] ^ D[22] ^ D[21] ^
+		    D[20] ^ D[18] ^ D[17] ^ D[16] ^ D[15] ^ D[14] ^ D[13] ^
+		    D[12] ^ D[9] ^ D[6] ^ D[1] ^ D[0] ^ C[0] ^ C[4] ^ C[5] ^
+		    C[6];
+	NewCRC[2] = D[29] ^ D[28] ^ D[25] ^ D[24] ^ D[22] ^ D[17] ^ D[15] ^
+		    D[13] ^ D[12] ^ D[10] ^ D[8] ^ D[6] ^ D[2] ^ D[1] ^ D[0] ^
+		    C[0] ^ C[1] ^ C[4] ^ C[5];
+	NewCRC[3] = D[30] ^ D[29] ^ D[26] ^ D[25] ^ D[23] ^ D[18] ^ D[16] ^
+		    D[14] ^ D[13] ^ D[11] ^ D[9] ^ D[7] ^ D[3] ^ D[2] ^ D[1] ^
+		    C[1] ^ C[2] ^ C[5] ^ C[6];
+	NewCRC[4] = D[31] ^ D[30] ^ D[27] ^ D[26] ^ D[24] ^ D[19] ^ D[17] ^
+		    D[15] ^ D[14] ^ D[12] ^ D[10] ^ D[8] ^ D[4] ^ D[3] ^ D[2] ^
+		    C[0] ^ C[2] ^ C[3] ^ C[6] ^ C[7];
+	NewCRC[5] = D[31] ^ D[28] ^ D[27] ^ D[25] ^ D[20] ^ D[18] ^ D[16] ^
+		    D[15] ^ D[13] ^ D[11] ^ D[9] ^ D[5] ^ D[4] ^ D[3] ^ C[1] ^
+		    C[3] ^ C[4] ^ C[7];
+	NewCRC[6] = D[29] ^ D[28] ^ D[26] ^ D[21] ^ D[19] ^ D[17] ^ D[16] ^
+		    D[14] ^ D[12] ^ D[10] ^ D[6] ^ D[5] ^ D[4] ^ C[2] ^ C[4] ^
+		    C[5];
+	NewCRC[7] = D[30] ^ D[29] ^ D[27] ^ D[22] ^ D[20] ^ D[18] ^ D[17] ^
+		    D[15] ^ D[13] ^ D[11] ^ D[7] ^ D[6] ^ D[5] ^ C[3] ^ C[5] ^
+		    C[6];
+
+	crc_res = 0;
+	for (i = 0; i < 8; i++)
+		crc_res |= (NewCRC[i] << i);
+
+	return crc_res;
+}
+
+
-- 
1.5.4.3




