From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [BNX2X][PATCH 5/8] bnx2x_init.h
Date: Sun, 07 Oct 2007 18:23:35 +0200
Message-ID: <47090807.5030900@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4538 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752801AbXJGQW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 12:22:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bnx2x_init.h - Various bits of init code.

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com 
<mailto:eliezert@broadcom.com>>
---
drivers/net/bnx2x_init.h |  555 
++++++++++++++++++++++++++++++++++++++++++++++
1 files changed, 555 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
new file mode 100644
index 0000000..c46f064
--- /dev/null
+++ b/drivers/net/bnx2x_init.h
@@ -0,0 +1,555 @@
+/* bnx2x_init.h: Broadcom Everest network driver.
+ *
+ * Copyright (c) 2007 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Eliezer Tamir <eliezert@broadcom.com 
<mailto:eliezert@broadcom.com>>
+ */        
+#ifndef EVEREST_INIT_FUNCTIONS_H
+#define EVEREST_INIT_FUNCTIONS_H
+
+#define COMMON 0x1
+#define PORT0  0x2
+#define PORT1  0x4
+
+#define INIT_EMULATION 0x1
+#define INIT_FPGA 0x2
+#define INIT_ASIC 0x4
+#define INIT_HARDWARE 0x7
+
+#define BLCNUM_PRS      0
+#define BLCNUM_SRCH     1
+#define BLCNUM_TSDM     2
+#define BLCNUM_TCM      3
+#define BLCNUM_BRB1     4
+#define BLCNUM_TSEM     5
+#define BLCNUM_PXPCS    6
+#define BLCNUM_EMAC0    7
+#define BLCNUM_EMAC1    8
+#define BLCNUM_DBU      9
+#define BLCNUM_MISC     10
+#define BLCNUM_DBG      11
+#define BLCNUM_NIG      12
+#define BLCNUM_MCP      13
+#define BLCNUM_UPB      14
+#define BLCNUM_CSDM     15
+#define BLCNUM_USDM     16
+#define BLCNUM_CCM      17
+#define BLCNUM_UCM      18
+#define BLCNUM_USEM     19
+#define BLCNUM_CSEM     20
+#define BLCNUM_XPB      21
+#define BLCNUM_DQ       22
+#define BLCNUM_TIMERS   23
+#define BLCNUM_XSDM     24
+#define BLCNUM_QM       25
+#define BLCNUM_PBF      26
+#define BLCNUM_XCM      27
+#define BLCNUM_XSEM     28
+#define BLCNUM_CDU      29
+#define BLCNUM_DMAE     30
+#define BLCNUM_PXP      31
+#define BLCNUM_CFC      32
+#define BLCNUM_HC       33
+#define BLCNUM_PXP2     34
+#define BLCNUM_MISC_AEU 35
+
+
+static void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
+
+static void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr,
+      u32 wb_addr, u32 wb_len);
+
+static int bnx2x_gunzip(struct bnx2x *bp, u8 *zbuf, int len);
+
+
+#define MEM_WR(block_addr, reg, value, len32) \
+do { \
+ int __i; \
+ for (__i = 0; __i < len32; __i++) { \
+ REG_WR(bp, block_addr, reg + __i*4, (((u32 *)(value))[__i])); \
+ if (!(__i % 10000)) { \
+ touch_softlockup_watchdog(); \
+ cpu_relax(); \
+ } \
+ } \
+} while (0)
+
+#define MEM_IND(block_addr, reg, value, len32) \
+do { \
+ int __i; \
+ for (__i = 0; __i < len32; __i++) { \
+ REG_WR_IND(bp, block_addr, reg + __i*4, \
+ (((u32 *)(value))[__i])); \
+ if (!(__i % 10000)) { \
+ touch_softlockup_watchdog(); \
+ cpu_relax(); \
+ } \
+ } \
+} while (0)
+
+#define _DMAE_WR(block_addr, reg, len32) \
+do { \
+ int __len32 = len32, offset = 0; \
+ while (__len32 > DMAE_LEN_MAX) { \
+/* DP(NETIF_MSG_DMAE, "DMAE_WR: offset %d  len32 %d\n", \
+    offset, __len32); */ \
+ bnx2x_write_dmae(bp, bp->gunzip_mapping + offset, \
+ block_addr + reg + offset, DMAE_LEN_MAX); \
+ offset += DMAE_LEN_MAX * 4; \
+ __len32 -= DMAE_LEN_MAX; \
+ } \
+/* DP(NETIF_MSG_DMAE, "DMAE_WR: offset %d  len32 %d\n", offset, \
+    __len32); */ \
+ bnx2x_write_dmae(bp, bp->gunzip_mapping + offset, \
+ block_addr + reg + offset, __len32); \
+} while (0)
+
+#define DMAE_WR(block_addr, reg, value, len32) \
+do { \
+/* DP(NETIF_MSG_DMAE, "DMAE_WR: block 0x%x  reg 0x%lx  len32 %d\n", \
+    block_addr, reg, len32); */ \
+ memcpy(bp->gunzip_buf, value, (len32) * 4); \
+ _DMAE_WR(block_addr, reg, len32); \
+} while (0)
+
+#define DMAE_CLR(bp, block_addr, reg, len32) \
+do { \
+/* DP(NETIF_MSG_DMAE, "DMAE_CLR: block 0x%x  reg 0x%lx  len32 %d\n", \
+    block_addr, reg, len32); */ \
+ memset(bp->gunzip_buf, 0, (len32) * 4); \
+ _DMAE_WR(block_addr, reg, len32); \
+} while (0)
+
+#define GUNZIP_DMAE_WR(block_addr, reg, value, len8) \
+do { \
+/* DP(NETIF_MSG_DMAE, "GUNZIP_DMAE_WR: block 0x%x  reg 0x%lx  len8 %d\n", \
+    block_addr, reg, len8); */ \
+ bnx2x_gunzip(bp, (u8 *)(value), len8); \
+/* DP(NETIF_MSG_DMAE, "  ==> outlen %d\n", bp->gunzip_outlen); */ \
+ _DMAE_WR(block_addr, reg, bp->gunzip_outlen); \
+} while (0)
+
+
+#define INIT_INTERNAL0_MEM_WR(block_bar, block, reg, \
+       part, hw, value, off, len) \
+ INIT_MEM_WR(block, reg, part, hw, value, off, len);
+
+#define INIT_REG_WR(block, reg, value, part, hw) \
+do { \
+ if ((_block == BLCNUM_##block) && (_part == part) && (_hw & hw)) { \
+ REG_WR(bp, GRCBASE_##block, reg, value); \
+ usage++; \
+ } \
+} while (0)
+
+#define INIT_REG_RD(block, reg, value, part, hw) \
+do { \
+ u32 val; \
+ if ((_block == BLCNUM_##block) && (_part == part) && (_hw & hw)) { \
+ val = REG_RD(bp, GRCBASE_##block, reg); \
+ usage++; \
+ } \
+} while (0)
+
+#define INIT_MEM_WR(block, reg, part, hw, value, off, len) \
+do { \
+ if ((_block == BLCNUM_##block) && (_part == part) && (_hw & hw)) { \
+ MEM_WR(GRCBASE_##block, reg + (off<<2), value, len); \
+ usage++; \
+ } \
+} while (0)
+
+#define INIT_MEM_IND(block, reg, part, hw, value, off, len) \
+do { \
+ if ((_block == BLCNUM_##block) && (_part == part) && (_hw & hw)) { \
+ MEM_IND(GRCBASE_##block, reg + (off<<2), value, len); \
+ usage++; \
+ } \
+} while (0)
+
+#define INIT_MEM_WB(block, reg, part, hw, value, off, len) \
+do { \
+ if ((_block == BLCNUM_##block) && (_part == part) && (_hw & hw)) { \
+ DMAE_WR(GRCBASE_##block, reg + (off<<2), value, len); \
+ usage++; \
+ } \
+} while (0)
+
+#define INIT_MEM_CLR(block, reg, part, hw, off, len) \
+do { \
+ if ((_block == BLCNUM_##block) && (_part == part) && (_hw & hw)) { \
+ DMAE_CLR(bp, GRCBASE_##block, reg + (off<<2), len); \
+ usage++; \
+ } \
+} while (0)
+
+#define INIT_GUNZIP_DMAE(block, reg, part, hw, value, off, len) \
+do { \
+ if ((_block == BLCNUM_##block) && (_part == part) && (_hw & hw)) { \
+ GUNZIP_DMAE_WR(GRCBASE_##block, reg + (off<<2), value, len); \
+ usage++; \
+ } \
+} while (0)
+
+
+static void bnx2x_init_stage(struct bnx2x *bp, int _block, int _part)
+{
+ int _hw;
+ int usage = 0;
+
+ switch (CHIP_REV(bp)) {
+ case CHIP_REV_EMUL:
+ _hw = INIT_EMULATION;
+ break;
+ case CHIP_REV_FPGA:
+ _hw = INIT_FPGA;
+ break;
+ default:
+ _hw = INIT_ASIC;
+ }
+
+ touch_softlockup_watchdog();
+
+#define STORAGE_CLASS static const u32
+#ifdef __BIG_ENDIAN
+#include "bnx2x_asm_be.h"
+#else
+#include "bnx2x_asm.h"
+#endif
+#include "bnx2x_init_values.h"
+
+ DP(NETIF_MSG_HW, "Block %d, Part %d, hw %d -  usage %d\n",
+    _block, _part, _hw, usage);
+}
+
+#undef INIT_INTERNAL0_MEM_WR
+#undef INIT_REG_WR
+#undef INIT_REG_RD
+#undef INIT_MEM_WR
+#undef INIT_MEM_IND
+#undef INIT_MEM_WB
+#undef INIT_MEM_CLR
+#undef INIT_GUNZIP_DMAE
+
+
+static void bnx2x_zero_intmem(struct bnx2x *bp)
+{
+#define STORM_INTMEM_SIZE 22528
+
+ u32 storms[4] = {0x1a0000, /*T*/
+ 0x220000, /*C*/
+ 0x2a0000, /*X*/
+ 0x320000};/*U*/
+ u32 i;
+
+ for (i = 0; i < 4; i++) {
+ DMAE_CLR(bp, storms[i], 0UL, STORM_INTMEM_SIZE / 4);
+ }
+}
+
+
+/****************************************************************************
+* PXP
+****************************************************************************/
+
+#define NUM_WR_Q 13
+#define NUM_RD_Q 29
+#define MAX_RD_ORD 3
+#define MAX_WR_ORD 2
+
+struct arb_line {
+ int l;
+ int add;
+ int ubound;
+};
+
+static const struct arb_line read_arb_data[NUM_RD_Q][MAX_RD_ORD + 1] = {
+ {{ 8 , 64 , 25}, { 16 , 64 , 25}, { 32 , 64 , 25}, { 64 , 64 , 41}},
+ {{ 4 , 8 , 4},   { 4 , 8 , 4},    { 4 , 8 , 4},    { 4 , 8 , 4}},
+ {{ 4 , 3 , 3},   { 4 , 3 , 3},    { 4 , 3 , 3},    { 4 , 3 , 3}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 16 , 3 , 11},  { 16 , 3 , 11}},
+ {{ 8 , 64 , 25}, { 16 , 64 , 25}, { 32 , 64 , 25}, { 64 , 64 , 41}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 64 , 3 , 41}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 64 , 3 , 41}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 64 , 3 , 41}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 64 , 3 , 41}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},
+ {{ 8 , 64 , 25}, { 16 , 64 , 41}, { 32 , 64 , 81}, { 64 , 64 , 120}}};
+
+static const struct arb_line write_arb_data[NUM_WR_Q][MAX_WR_ORD + 1] = {
+ {{ 4 , 6 , 3},   { 4 , 6 , 3},    { 4 , 6 , 3}},
+ {{ 4 , 2 , 3},   { 4 , 2 , 3},    { 4 , 2 , 3}},
+ {{ 8 , 2 , 6},   { 16 , 2 , 11},  { 16 , 2 , 11}},
+ {{ 8 , 2 , 6},   { 16 , 2 , 11},  { 32 , 2 , 21}},
+ {{ 8 , 2 , 6},   { 16 , 2 , 11},  { 32 , 2 , 21}},
+ {{ 8 , 2 , 6},   { 16 , 2 , 11},  { 32 , 2 , 21}},
+ {{ 8 , 64 , 25}, { 16 , 64 , 25}, { 32 , 64 , 25}},
+ {{ 8 , 2 , 6},   { 16 , 2 , 11},  { 16 , 2 , 11}},
+ {{ 8 , 2 , 6},   { 16 , 2 , 11},  { 16 , 2 , 11}},
+ {{ 8 , 9 , 6},   { 16 , 9 , 11},  { 32 , 9 , 21}},
+ {{ 8 , 47 , 19}, { 16 , 47 , 19}, { 32 , 47 , 21}},
+ {{ 8 , 9 , 6},   { 16 , 9 , 11},  { 16 , 9 , 11}},
+ {{ 8 , 64 , 25}, { 16 , 64 , 41}, { 32 , 64 , 81}}};
+
+static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
+ {PXP2_REGISTERS_RQ_BW_RD_L0, PXP2_REGISTERS_RQ_BW_RD_ADD0  ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND0},
+ {PXP2_REGISTERS_PSWRQ_BW_L1, PXP2_REGISTERS_PSWRQ_BW_ADD1  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB1},
+ {PXP2_REGISTERS_PSWRQ_BW_L2, PXP2_REGISTERS_PSWRQ_BW_ADD2  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB2},
+ {PXP2_REGISTERS_PSWRQ_BW_L3, PXP2_REGISTERS_PSWRQ_BW_ADD3  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB3},
+ {PXP2_REGISTERS_RQ_BW_RD_L4, PXP2_REGISTERS_RQ_BW_RD_ADD4  ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND4},
+ {PXP2_REGISTERS_RQ_BW_RD_L5, PXP2_REGISTERS_RQ_BW_RD_ADD5  ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND5},
+ {PXP2_REGISTERS_PSWRQ_BW_L6, PXP2_REGISTERS_PSWRQ_BW_ADD6  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB6},
+ {PXP2_REGISTERS_PSWRQ_BW_L7, PXP2_REGISTERS_PSWRQ_BW_ADD7  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB7},
+ {PXP2_REGISTERS_PSWRQ_BW_L8, PXP2_REGISTERS_PSWRQ_BW_ADD8  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB8},
+ {PXP2_REGISTERS_PSWRQ_BW_L9, PXP2_REGISTERS_PSWRQ_BW_ADD9  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB9},
+ {PXP2_REGISTERS_PSWRQ_BW_L10, PXP2_REGISTERS_PSWRQ_BW_ADD10 ,
+ PXP2_REGISTERS_PSWRQ_BW_UB10},
+ {PXP2_REGISTERS_PSWRQ_BW_L11, PXP2_REGISTERS_PSWRQ_BW_ADD11 ,
+ PXP2_REGISTERS_PSWRQ_BW_UB11},
+ {PXP2_REGISTERS_RQ_BW_RD_L12, PXP2_REGISTERS_RQ_BW_RD_ADD12 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND12},
+ {PXP2_REGISTERS_RQ_BW_RD_L13, PXP2_REGISTERS_RQ_BW_RD_ADD13 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND13},
+ {PXP2_REGISTERS_RQ_BW_RD_L14, PXP2_REGISTERS_RQ_BW_RD_ADD14 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND14},
+ {PXP2_REGISTERS_RQ_BW_RD_L15, PXP2_REGISTERS_RQ_BW_RD_ADD15 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND15},
+ {PXP2_REGISTERS_RQ_BW_RD_L16, PXP2_REGISTERS_RQ_BW_RD_ADD16 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND16},
+ {PXP2_REGISTERS_RQ_BW_RD_L17, PXP2_REGISTERS_RQ_BW_RD_ADD17 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND17},
+ {PXP2_REGISTERS_RQ_BW_RD_L18, PXP2_REGISTERS_RQ_BW_RD_ADD18 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND18},
+ {PXP2_REGISTERS_RQ_BW_RD_L19, PXP2_REGISTERS_RQ_BW_RD_ADD19 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND19},
+ {PXP2_REGISTERS_RQ_BW_RD_L20, PXP2_REGISTERS_RQ_BW_RD_ADD20 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND20},
+ {PXP2_REGISTERS_RQ_BW_RD_L22, PXP2_REGISTERS_RQ_BW_RD_ADD22 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND22},
+ {PXP2_REGISTERS_RQ_BW_RD_L23, PXP2_REGISTERS_RQ_BW_RD_ADD23 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND23},
+ {PXP2_REGISTERS_RQ_BW_RD_L24, PXP2_REGISTERS_RQ_BW_RD_ADD24 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND24},
+ {PXP2_REGISTERS_RQ_BW_RD_L25, PXP2_REGISTERS_RQ_BW_RD_ADD25 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND25},
+ {PXP2_REGISTERS_RQ_BW_RD_L26, PXP2_REGISTERS_RQ_BW_RD_ADD26 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND26},
+ {PXP2_REGISTERS_RQ_BW_RD_L27, PXP2_REGISTERS_RQ_BW_RD_ADD27 ,
+ PXP2_REGISTERS_RQ_BW_RD_UBOUND27},
+ {PXP2_REGISTERS_PSWRQ_BW_L28, PXP2_REGISTERS_PSWRQ_BW_ADD28 ,
+ PXP2_REGISTERS_PSWRQ_BW_UB28}};
+
+static const struct arb_line write_arb_addr[NUM_WR_Q-1] = {
+ {PXP2_REGISTERS_PSWRQ_BW_L1, PXP2_REGISTERS_PSWRQ_BW_ADD1  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB1},
+ {PXP2_REGISTERS_PSWRQ_BW_L2, PXP2_REGISTERS_PSWRQ_BW_ADD2  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB2},
+ {PXP2_REGISTERS_PSWRQ_BW_L3, PXP2_REGISTERS_PSWRQ_BW_ADD3  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB3},
+ {PXP2_REGISTERS_PSWRQ_BW_L6, PXP2_REGISTERS_PSWRQ_BW_ADD6  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB6},
+ {PXP2_REGISTERS_PSWRQ_BW_L7, PXP2_REGISTERS_PSWRQ_BW_ADD7  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB7},
+ {PXP2_REGISTERS_PSWRQ_BW_L8, PXP2_REGISTERS_PSWRQ_BW_ADD8  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB8},
+ {PXP2_REGISTERS_PSWRQ_BW_L9, PXP2_REGISTERS_PSWRQ_BW_ADD9  ,
+ PXP2_REGISTERS_PSWRQ_BW_UB9},
+ {PXP2_REGISTERS_PSWRQ_BW_L10, PXP2_REGISTERS_PSWRQ_BW_ADD10 ,
+ PXP2_REGISTERS_PSWRQ_BW_UB10},
+ {PXP2_REGISTERS_PSWRQ_BW_L11, PXP2_REGISTERS_PSWRQ_BW_ADD11 ,
+ PXP2_REGISTERS_PSWRQ_BW_UB11},
+ {PXP2_REGISTERS_PSWRQ_BW_L28, PXP2_REGISTERS_PSWRQ_BW_ADD28 ,
+ PXP2_REGISTERS_PSWRQ_BW_UB28},
+ {PXP2_REGISTERS_RQ_BW_WR_L29, PXP2_REGISTERS_RQ_BW_WR_ADD29 ,
+ PXP2_REGISTERS_RQ_BW_WR_UBOUND29},
+ {PXP2_REGISTERS_RQ_BW_WR_L30, PXP2_REGISTERS_RQ_BW_WR_ADD30 ,
+ PXP2_REGISTERS_RQ_BW_WR_UBOUND30}};
+
+static void bnx2x_init_pxp(struct bnx2x *bp, int r_order, int w_order)
+{
+ int i, val;
+
+ if (r_order > MAX_RD_ORD) {
+ DP(NETIF_MSG_HW, "read order of %d  order adjusted to %d\n",
+    r_order, MAX_RD_ORD);
+ r_order = MAX_RD_ORD;
+ }
+
+ if (w_order > MAX_WR_ORD) {
+ DP(NETIF_MSG_HW, "write order of %d  order adjusted to %d\n",
+    w_order, MAX_WR_ORD);
+ w_order = MAX_WR_ORD;
+ }
+
+ DP(NETIF_MSG_HW, "read order %d  write order %d\n", r_order, w_order);
+
+ for (i = 0; i < NUM_RD_Q-1; i++) {
+ REG_WR(bp, GRCBASE_PXP2, read_arb_addr[i].l,
+        read_arb_data[i][r_order].l);
+ REG_WR(bp, GRCBASE_PXP2, read_arb_addr[i].add,
+        read_arb_data[i][r_order].add);
+ REG_WR(bp, GRCBASE_PXP2, read_arb_addr[i].ubound,
+        read_arb_data[i][r_order].ubound);
+ }
+
+ for (i = 0; i < NUM_WR_Q-1; i++) {
+ if ((write_arb_addr[i].l == PXP2_REGISTERS_RQ_BW_WR_L29) ||
+     (write_arb_addr[i].l == PXP2_REGISTERS_RQ_BW_WR_L30)) {
+
+ REG_WR(bp, GRCBASE_PXP2, write_arb_addr[i].l,
+        write_arb_data[i][w_order].l);
+
+ REG_WR(bp, GRCBASE_PXP2, write_arb_addr[i].add,
+        write_arb_data[i][w_order].add);
+
+ REG_WR(bp, GRCBASE_PXP2, write_arb_addr[i].ubound,
+        write_arb_data[i][w_order].ubound);
+ } else {
+
+ val = REG_RD(bp, GRCBASE_PXP2, write_arb_addr[i].l);
+ REG_WR(bp, GRCBASE_PXP2, write_arb_addr[i].l,
+        val | (write_arb_data[i][w_order].l << 10));
+
+ val = REG_RD(bp, GRCBASE_PXP2, write_arb_addr[i].add);
+ REG_WR(bp, GRCBASE_PXP2, write_arb_addr[i].add,
+        val | (write_arb_data[i][w_order].add << 10));
+
+ val = REG_RD(bp, GRCBASE_PXP2,
+      write_arb_addr[i].ubound);
+ REG_WR(bp, GRCBASE_PXP2, write_arb_addr[i].ubound,
+        val | (write_arb_data[i][w_order].ubound << 7));
+ }
+ }
+
+ val =  write_arb_data[NUM_WR_Q-1][w_order].add;
+ val += write_arb_data[NUM_WR_Q-1][w_order].ubound << 10;
+ val += write_arb_data[NUM_WR_Q-1][w_order].l << 17;
+ REG_WR(bp, GRCBASE_PXP2, PXP2_REGISTERS_PSWRQ_BW_RD, val);
+
+ val =  read_arb_data[NUM_RD_Q-1][r_order].add;
+ val += read_arb_data[NUM_RD_Q-1][r_order].ubound << 10;
+ val += read_arb_data[NUM_RD_Q-1][r_order].l << 17;
+ REG_WR(bp, GRCBASE_PXP2, PXP2_REGISTERS_PSWRQ_BW_WR, val);
+
+ REG_WR(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_WR_MBS0, w_order);
+ REG_WR(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_WR_MBS0 + 8, w_order);
+ REG_WR(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_RD_MBS0, r_order);
+ REG_WR(bp, GRCBASE_PXP2, PXP2_REGISTERS_RQ_RD_MBS0 + 8, r_order);
+}
+
+
+/****************************************************************************
+* CDU
+****************************************************************************/
+
+#define CDU_REGION_NUMBER_XCM_AG 2
+#define CDU_REGION_NUMBER_UCM_AG 4
+
+/**
+ * String-to-compress [31:8] = CID (all 24 bits)
+ * String-to-compress [7:4] = Region
+ * String-to-compress [3:0] = Type
+ */
+#define CDU_VALID_DATA(_cid, _region, _type) \
+ (((_cid) << 8) | (((_region) & 0xf) << 4) | (((_type) & 0xf)))
+#define CDU_CRC8(_cid, _region, _type) \
+ calc_crc8(CDU_VALID_DATA(_cid, _region, _type), 0xff)
+#define CDU_RSRVD_VALUE_TYPE_A(_cid, _region, _type) \
+ (0x80 | (CDU_CRC8(_cid, _region, _type) & 0x7f))
+#define CDU_RSRVD_VALUE_TYPE_B(_crc, _type) \
+ (0x80 | ((_type) & 0xf << 3) | (CDU_CRC8(_cid, _region, _type) & 0x7))
+#define CDU_RSRVD_INVALIDATE_CONTEXT_VALUE(_val) ((_val) & ~0x80)
+
+/*****************************************************************************
+ * Description:
+ *         Calculates crc 8 on a word value: polynomial 0-1-2-8
+ *         Code was translated from Verilog.
+ 
****************************************************************************/
+static u8 calc_crc8(u32 data, u8 crc)
+{
+ u8 D[32];
+ u8 NewCRC[8];
+ u8 C[8];
+ u8 crc_res;
+ u8 i;
+
+ /* split the data into 31 bits */
+ for (i = 0; i < 32; i++) {
+ D[i] = data & 1;
+ data = data >> 1;
+ }
+
+ /* split the crc into 8 bits */
+ for (i = 0; i < 8; i++ ) {
+ C[i] = crc & 1;
+ crc = crc >> 1;
+ }
+
+ NewCRC[0] = D[31] ^ D[30] ^ D[28] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^
+ D[16] ^ D[14] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[0] ^ C[4] ^
+ C[6] ^ C[7];
+ NewCRC[1] = D[30] ^ D[29] ^ D[28] ^ D[24] ^ D[23] ^ D[22] ^ D[21] ^
+ D[20] ^ D[18] ^ D[17] ^ D[16] ^ D[15] ^ D[14] ^ D[13] ^
+ D[12] ^ D[9] ^ D[6] ^ D[1] ^ D[0] ^ C[0] ^ C[4] ^ C[5] ^ C[6];
+ NewCRC[2] = D[29] ^ D[28] ^ D[25] ^ D[24] ^ D[22] ^ D[17] ^ D[15] ^
+ D[13] ^ D[12] ^ D[10] ^ D[8] ^ D[6] ^ D[2] ^ D[1] ^ D[0] ^
+ C[0] ^ C[1] ^ C[4] ^ C[5];
+ NewCRC[3] = D[30] ^ D[29] ^ D[26] ^ D[25] ^ D[23] ^ D[18] ^ D[16] ^
+ D[14] ^ D[13] ^ D[11] ^ D[9] ^ D[7] ^ D[3] ^ D[2] ^ D[1] ^
+ C[1] ^ C[2] ^ C[5] ^ C[6];
+ NewCRC[4] = D[31] ^ D[30] ^ D[27] ^ D[26] ^ D[24] ^ D[19] ^ D[17] ^
+ D[15] ^ D[14] ^ D[12] ^ D[10] ^ D[8] ^ D[4] ^ D[3] ^ D[2] ^
+ C[0] ^ C[2] ^ C[3] ^ C[6] ^ C[7];
+ NewCRC[5] = D[31] ^ D[28] ^ D[27] ^ D[25] ^ D[20] ^ D[18] ^ D[16] ^
+ D[15] ^ D[13] ^ D[11] ^ D[9] ^ D[5] ^ D[4] ^ D[3] ^ C[1] ^
+ C[3] ^ C[4] ^ C[7];
+ NewCRC[6] = D[29] ^ D[28] ^ D[26] ^ D[21] ^ D[19] ^ D[17] ^ D[16] ^
+ D[14] ^ D[12] ^ D[10] ^ D[6] ^ D[5] ^ D[4] ^ C[2] ^ C[4] ^
+ C[5];
+ NewCRC[7] = D[30] ^ D[29] ^ D[27] ^ D[22] ^ D[20] ^ D[18] ^ D[17] ^
+ D[15] ^ D[13] ^ D[11] ^ D[7] ^ D[6] ^ D[5] ^ C[3] ^ C[5] ^
+ C[6];
+
+ crc_res = 0;
+ for (i = 0; i < 8; i++) {
+ crc_res |= (NewCRC[i] << i);
+ }
+
+ return crc_res;
+}
+
+
+#endif /* EVEREST_INIT_FUNCTIONS_H */
+
-- 
1.4.2



