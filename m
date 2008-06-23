From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 04/15]bnx2x: New init infrastructure
Date: Mon, 23 Jun 2008 19:01:51 +0300
Message-ID: <1214236911.3690.47.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1633 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758782AbYFWQCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 12:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new initialization code supports the 57711 HW. It also supports the
emulation and FPGA for the 57711 and 57710 initializations values (very
small amount of code which is very helpful in the lab - less than 30
lines).
The initialization is done via DMAE after the DMAE block is ready -
before it is ready, some of the initialization is done via PCI
configuration transactions (referred to as indirect write).
A mutex to protect the DMAE from being overlapped was added.
There are few new registers which needs to be initialized by SW - the
full comment for those registers is added to the register file.
A place holder for the 57711 (referred to as E1H) microcode was added-
the microcode itself is too big and it is split over the following 4 
patches

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h             |   99 ++-
 drivers/net/bnx2x_hsi.h         |   27 +-
 drivers/net/bnx2x_init.h        |  345 ++++++-
 drivers/net/bnx2x_init_values.h | 2149 +++++++++++++++++++++++++++++----------
 drivers/net/bnx2x_main.c        |  166 ++--
 5 files changed, 2130 insertions(+), 656 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 2a13def..0979ca0 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -557,25 +557,37 @@ struct bnx2x {
 
 	u32     		shmem_base;
 
-	u32     		chip_id;
+	u32			chip_id;
 /* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
-#define CHIP_ID(bp)     		(((bp)->chip_id) & 0xfffffff0)
-
-#define CHIP_NUM(bp)    		(((bp)->chip_id) & 0xffff0000)
-
-#define CHIP_REV(bp)    		(((bp)->chip_id) & 0x0000f000)
-#define CHIP_REV_Ax     		0x00000000
-#define CHIP_REV_Bx     		0x00001000
-#define CHIP_REV_Cx     		0x00002000
-#define CHIP_REV_EMUL   		0x0000e000
-#define CHIP_REV_FPGA   		0x0000f000
-#define CHIP_REV_IS_SLOW(bp)    	((CHIP_REV(bp) == CHIP_REV_EMUL) || \
-					 (CHIP_REV(bp) == CHIP_REV_FPGA))
-#define CHIP_REV_IS_EMUL(bp)		(CHIP_REV(bp) == CHIP_REV_EMUL)
-#define CHIP_REV_IS_FPGA(bp)		(CHIP_REV(bp) == CHIP_REV_FPGA)
-
-#define CHIP_METAL(bp)  		(((bp)->chip_id) & 0x00000ff0)
-#define CHIP_BOND_ID(bp)		(((bp)->chip_id) & 0x0000000f)
+#define CHIP_ID(bp)			(bp->chip_id & 0xfffffff0)
+
+#define CHIP_NUM(bp)			(bp->chip_id >> 16)
+#define CHIP_NUM_57710			0x164e
+#define CHIP_NUM_57711			0x164f
+#define CHIP_NUM_57711E			0x1650
+#define CHIP_IS_E1(bp)			(CHIP_NUM(bp) == CHIP_NUM_57710)
+#define CHIP_IS_57711(bp)		(CHIP_NUM(bp) == CHIP_NUM_57711)
+#define CHIP_IS_57711E(bp)		(CHIP_NUM(bp) == CHIP_NUM_57711E)
+#define CHIP_IS_E1H(bp)			(CHIP_IS_57711(bp) || \
+					 CHIP_IS_57711E(bp))
+#define IS_E1H_OFFSET			CHIP_IS_E1H(bp)
+
+#define CHIP_REV(bp)			(bp->chip_id & 0x0000f000)
+#define CHIP_REV_Ax			0x00000000
+/* assume maximum 5 revisions */
+#define CHIP_REV_IS_SLOW(bp)		(CHIP_REV(bp) > 0x00005000)
+/* Emul versions are A=>0xe, B=>0xc, C=>0xa, D=>8, E=>6 */
+#define CHIP_REV_IS_EMUL(bp)		((CHIP_REV_IS_SLOW(bp)) && \
+					 !(CHIP_REV(bp) & 0x00001000))
+/* FPGA versions are A=>0xf, B=>0xd, C=>0xb, D=>9, E=>7 */
+#define CHIP_REV_IS_FPGA(bp)		((CHIP_REV_IS_SLOW(bp)) && \
+					 (CHIP_REV(bp) & 0x00001000))
+
+#define CHIP_TIME(bp)			((CHIP_REV_IS_EMUL(bp)) ? 2000 : \
+					((CHIP_REV_IS_FPGA(bp)) ? 200 : 1))
+
+#define CHIP_METAL(bp)			(bp->chip_id & 0x00000ff0)
+#define CHIP_BOND_ID(bp)		(bp->chip_id & 0x0000000f)
 
 	u16     		fw_seq;
 	u16     		fw_drv_pulse_wr_seq;
@@ -678,6 +690,13 @@ struct bnx2x {
 	struct dmae_command     dmae;
 	int     		executer_idx;
 
+	int			dmae_ready;
+	/* used to synchronize dmae accesses */
+	struct mutex		dmae_mutex;
+	struct dmae_command	init_dmae;
+
+
+
 	u32     		old_brb_discard;
 	struct bmac_stats       old_bmac;
 	struct tstorm_per_client_stats old_tclient;
@@ -685,7 +704,7 @@ struct bnx2x {
 	void    		*gunzip_buf;
 	dma_addr_t      	gunzip_mapping;
 	int     		gunzip_outlen;
-#define FW_BUF_SIZE     		0x8000
+#define FW_BUF_SIZE			0x8000
 
 };
 
@@ -774,12 +793,6 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 #define STROM_ASSERT_ARRAY_SIZE 	50
 
 
-#define MDIO_INDIRECT_REG_ADDR  	0x1f
-#define MDIO_SET_REG_BANK(bp, reg_bank) \
-		bnx2x_mdio22_write(bp, MDIO_INDIRECT_REG_ADDR, reg_bank)
-
-#define MDIO_ACCESS_TIMEOUT     	1000
-
 
 /* must be used on a CID before placing it on a HW ring */
 #define HW_CID(bp, x)   		(x | (bp->port << 23))
@@ -818,6 +831,42 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 		       DPM_TRIGER_TYPE); \
 	} while (0)
 
+/* DMAE command defines */
+#define DMAE_CMD_SRC_PCI		0
+#define DMAE_CMD_SRC_GRC		DMAE_COMMAND_SRC
+
+#define DMAE_CMD_DST_PCI		(1 << DMAE_COMMAND_DST_SHIFT)
+#define DMAE_CMD_DST_GRC		(2 << DMAE_COMMAND_DST_SHIFT)
+
+#define DMAE_CMD_C_DST_PCI		0
+#define DMAE_CMD_C_DST_GRC		(1 << DMAE_COMMAND_C_DST_SHIFT)
+
+#define DMAE_CMD_C_ENABLE		DMAE_COMMAND_C_TYPE_ENABLE
+
+#define DMAE_CMD_ENDIANITY_NO_SWAP	(0 << DMAE_COMMAND_ENDIANITY_SHIFT)
+#define DMAE_CMD_ENDIANITY_B_SWAP	(1 << DMAE_COMMAND_ENDIANITY_SHIFT)
+#define DMAE_CMD_ENDIANITY_DW_SWAP	(2 << DMAE_COMMAND_ENDIANITY_SHIFT)
+#define DMAE_CMD_ENDIANITY_B_DW_SWAP	(3 << DMAE_COMMAND_ENDIANITY_SHIFT)
+
+#define DMAE_CMD_PORT_0			0
+#define DMAE_CMD_PORT_1			DMAE_COMMAND_PORT
+
+#define DMAE_CMD_SRC_RESET		DMAE_COMMAND_SRC_RESET
+#define DMAE_CMD_DST_RESET		DMAE_COMMAND_DST_RESET
+#define DMAE_CMD_E1HVN_SHIFT		DMAE_COMMAND_E1HVN_SHIFT
+
+#define DMAE_LEN32_RD_MAX		0x80
+#define DMAE_LEN32_WR_MAX		0x400
+
+#define DMAE_COMP_VAL			0xe0d0d0ae
+
+#define MAX_DMAE_C_PER_PORT		8
+#define INIT_DMAE_C(bp)			(BP_PORT(bp)*MAX_DMAE_C_PER_PORT + \
+					 BP_E1HVN(bp))
+#define PMF_DMAE_C(bp)			(BP_PORT(bp)*MAX_DMAE_C_PER_PORT + \
+					 E1HVN_MAX)
+
+
 /* PCIE link and speed */
 #define PCICFG_LINK_WIDTH		0x1f00000
 #define PCICFG_LINK_WIDTH_SHIFT		20
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index b21075c..96208ac 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -522,8 +522,21 @@ struct dev_info {						     /* size */
 
 #define FUNC_0				0
 #define FUNC_1				1
+#define FUNC_2				2
+#define FUNC_3				3
+#define FUNC_4				4
+#define FUNC_5				5
+#define FUNC_6				6
+#define FUNC_7				7
 #define E1_FUNC_MAX			2
-#define FUNC_MAX			E1_FUNC_MAX
+#define E1H_FUNC_MAX			8
+
+#define VN_0				0
+#define VN_1				1
+#define VN_2				2
+#define VN_3				3
+#define E1VN_MAX			1
+#define E1HVN_MAX			4
 
 
 /* This value (in milliseconds) determines the frequency of the driver
@@ -747,7 +760,11 @@ struct shmem_region {			       /*   SharedMem Offset (size) */
 	struct mgmtfw_state	mgmtfw_state;	       /* 0x4ac     (0x1b8) */
 
 	struct drv_port_mb	port_mb[PORT_MAX];     /* 0x664 (16*2=0x20) */
-	struct drv_func_mb	func_mb[FUNC_MAX];     /* 0x684 (44*2=0x58) */
+#if defined(b710)
+	struct drv_func_mb	func_mb[E1_FUNC_MAX];  /* 0x684 (44*2=0x58) */
+#else
+	struct drv_func_mb	func_mb[E1H_FUNC_MAX];
+#endif
 
 };						       /* 0x6dc */
 
@@ -901,8 +918,10 @@ struct dmae_command {
 #define DMAE_COMMAND_SRC_RESET_SHIFT 13
 #define DMAE_COMMAND_DST_RESET (0x1<<14)
 #define DMAE_COMMAND_DST_RESET_SHIFT 14
-#define DMAE_COMMAND_RESERVED0 (0x1FFFF<<15)
-#define DMAE_COMMAND_RESERVED0_SHIFT 15
+#define DMAE_COMMAND_E1HVN (0x3<<15)
+#define DMAE_COMMAND_E1HVN_SHIFT 15
+#define DMAE_COMMAND_RESERVED0 (0x7FFF<<17)
+#define DMAE_COMMAND_RESERVED0_SHIFT 17
 	u32 src_addr_lo;
 	u32 src_addr_hi;
 	u32 dst_addr_lo;
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index bb0ee2d..5a4e82b 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -22,7 +22,8 @@
 #define INIT_ASIC			0x4
 #define INIT_HARDWARE			0x7
 
-#define STORM_INTMEM_SIZE		(0x5800 / 4)
+#define STORM_INTMEM_SIZE_E1		(0x5800 / 4)
+#define STORM_INTMEM_SIZE_E1H		(0x10000 / 4)
 #define TSTORM_INTMEM_ADDR		0x1a0000
 #define CSTORM_INTMEM_ADDR		0x220000
 #define XSTORM_INTMEM_ADDR		0x2a0000
@@ -30,7 +31,7 @@
 
 
 /* Init operation types and structures */
-
+/* Common for both E1 and E1H */
 #define OP_RD			0x1 /* read single register */
 #define OP_WR			0x2 /* write single register */
 #define OP_IW			0x3 /* write single register using mailbox */
@@ -38,7 +39,37 @@
 #define OP_SI			0x5 /* copy a string using mailbox */
 #define OP_ZR			0x6 /* clear memory */
 #define OP_ZP			0x7 /* unzip then copy with DMAE */
-#define OP_WB			0x8 /* copy a string using DMAE */
+#define OP_WR_64		0x8 /* write 64 bit pattern */
+#define OP_WB			0x9 /* copy a string using DMAE */
+
+/* Operation specific for E1 */
+#define OP_RD_E1		0xa /* read single register */
+#define OP_WR_E1		0xb /* write single register */
+#define OP_IW_E1		0xc /* write single register using mailbox */
+#define OP_SW_E1		0xd /* copy a string to the device */
+#define OP_SI_E1		0xe /* copy a string using mailbox */
+#define OP_ZR_E1		0xf /* clear memory */
+#define OP_ZP_E1		0x10 /* unzip then copy with DMAE */
+#define OP_WR_64_E1		0x11 /* write 64 bit pattern on E1 */
+#define OP_WB_E1		0x12 /* copy a string using DMAE */
+
+/* Operation specific for E1H */
+#define OP_RD_E1H		0x13 /* read single register */
+#define OP_WR_E1H		0x14 /* write single register */
+#define OP_IW_E1H		0x15 /* write single register using mailbox */
+#define OP_SW_E1H		0x16 /* copy a string to the device */
+#define OP_SI_E1H		0x17 /* copy a string using mailbox */
+#define OP_ZR_E1H		0x18 /* clear memory */
+#define OP_ZP_E1H		0x19 /* unzip then copy with DMAE */
+#define OP_WR_64_E1H		0x1a /* write 64 bit pattern on E1H */
+#define OP_WB_E1H		0x1b /* copy a string using DMAE */
+
+/* FPGA and EMUL specific operations */
+#define OP_WR_EMUL_E1H		0x1c /* write single register on E1H Emul */
+#define OP_WR_EMUL		0x1d /* write single register on Emulation */
+#define OP_WR_FPGA		0x1e /* write single register on FPGA */
+#define OP_WR_ASIC		0x1f /* write single register on ASIC */
+
 
 struct raw_op {
 	u32 op		:8;
@@ -117,11 +148,117 @@ static void bnx2x_init_ind_wr(struct bnx2x *bp, u32 addr, const u32 *data,
 	}
 }
 
+static void bnx2x_write_big_buf(struct bnx2x *bp, u32 addr, u32 len)
+{
+#ifdef USE_DMAE
+	int offset = 0;
+
+	if (bp->dmae_ready) {
+		while (len > DMAE_LEN32_WR_MAX) {
+			bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
+					 addr + offset, DMAE_LEN32_WR_MAX);
+			offset += DMAE_LEN32_WR_MAX * 4;
+			len -= DMAE_LEN32_WR_MAX;
+		}
+		bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
+				 addr + offset, len);
+	} else
+		bnx2x_init_str_wr(bp, addr, bp->gunzip_buf, len);
+#else
+	bnx2x_init_str_wr(bp, addr, bp->gunzip_buf, len);
+#endif
+}
+
+static void bnx2x_init_fill(struct bnx2x *bp, u32 addr, int fill, u32 len)
+{
+	if ((len * 4) > FW_BUF_SIZE) {
+		BNX2X_ERR("LARGE DMAE OPERATION ! addr 0x%x  len 0x%x\n",
+			  addr, len*4);
+		return;
+	}
+	memset(bp->gunzip_buf, fill, len * 4);
+
+	bnx2x_write_big_buf(bp, addr, len);
+}
+
+static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr, const u32 *data,
+			     u32 len64)
+{
+	u32 buf_len32 = FW_BUF_SIZE/4;
+	u32 len = len64*2;
+	u64 data64 = 0;
+	int i;
+
+	/* 64 bit value is in a blob: first low DWORD, then high DWORD */
+	data64 = HILO_U64((*(data + 1)), (*data));
+	len64 = min((u32)(FW_BUF_SIZE/8), len64);
+	for (i = 0; i < len64; i++) {
+		u64 *pdata = ((u64 *)(bp->gunzip_buf)) + i;
+
+		*pdata = data64;
+	}
+
+	for (i = 0; i < len; i += buf_len32) {
+		u32 cur_len = min(buf_len32, len - i);
+
+		bnx2x_write_big_buf(bp, addr + i * 4, cur_len);
+	}
+}
+
+/*********************************************************
+   There are different blobs for each PRAM section.
+   In addition, each blob write operation is divided into a few operations
+   in order to decrease the amount of phys. contigious buffer needed.
+   Thus, when we select a blob the address may be with some offset
+   from the beginning of PRAM section.
+   The same holds for the INT_TABLE sections.
+**********************************************************/
+#define IF_IS_INT_TABLE_ADDR(base, addr) \
+			if (((base) <= (addr)) && ((base) + 0x400 >= (addr)))
+
+#define IF_IS_PRAM_ADDR(base, addr) \
+			if (((base) <= (addr)) && ((base) + 0x40000 >= (addr)))
+
+static const u32 *bnx2x_sel_blob(u32 addr, const u32 *data, int is_e1)
+{
+	IF_IS_INT_TABLE_ADDR(TSEM_REG_INT_TABLE, addr)
+		data = is_e1 ? tsem_int_table_data_e1 :
+			       tsem_int_table_data_e1h;
+	else
+		IF_IS_INT_TABLE_ADDR(CSEM_REG_INT_TABLE, addr)
+		data = is_e1 ? csem_int_table_data_e1 :
+			       csem_int_table_data_e1h;
+	else
+		IF_IS_INT_TABLE_ADDR(USEM_REG_INT_TABLE, addr)
+		data = is_e1 ? usem_int_table_data_e1 :
+			       usem_int_table_data_e1h;
+	else
+		IF_IS_INT_TABLE_ADDR(XSEM_REG_INT_TABLE, addr)
+		data = is_e1 ? xsem_int_table_data_e1 :
+			       xsem_int_table_data_e1h;
+	else
+		IF_IS_PRAM_ADDR(TSEM_REG_PRAM, addr)
+		data = is_e1 ? tsem_pram_data_e1 : tsem_pram_data_e1h;
+	else
+		IF_IS_PRAM_ADDR(CSEM_REG_PRAM, addr)
+		data = is_e1 ? csem_pram_data_e1 : csem_pram_data_e1h;
+	else
+		IF_IS_PRAM_ADDR(USEM_REG_PRAM, addr)
+		data = is_e1 ? usem_pram_data_e1 : usem_pram_data_e1h;
+	else
+		IF_IS_PRAM_ADDR(XSEM_REG_PRAM, addr)
+		data = is_e1 ? xsem_pram_data_e1 : xsem_pram_data_e1h;
+
+	return data;
+}
+
 static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
-			     u32 len, int gunzip)
+			     u32 len, int gunzip, int is_e1, u32 blob_off)
 {
 	int offset = 0;
 
+	data = bnx2x_sel_blob(addr, data, is_e1) + blob_off;
+
 	if (gunzip) {
 		int rc;
 #ifdef __BIG_ENDIAN
@@ -136,64 +273,59 @@ static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 #endif
 		rc = bnx2x_gunzip(bp, (u8 *)data, len);
 		if (rc) {
-			DP(NETIF_MSG_HW, "gunzip failed ! rc %d\n", rc);
+			BNX2X_ERR("gunzip failed ! rc %d\n", rc);
 			return;
 		}
 		len = bp->gunzip_outlen;
 #ifdef __BIG_ENDIAN
 		kfree(temp);
 		for (i = 0; i < len; i++)
-			 ((u32 *)bp->gunzip_buf)[i] =
+			((u32 *)bp->gunzip_buf)[i] =
 					swab32(((u32 *)bp->gunzip_buf)[i]);
 #endif
 	} else {
 		if ((len * 4) > FW_BUF_SIZE) {
-			BNX2X_ERR("LARGE DMAE OPERATION ! len 0x%x\n", len*4);
+			BNX2X_ERR("LARGE DMAE OPERATION ! "
+				  "addr 0x%x  len 0x%x\n", addr, len*4);
 			return;
 		}
 		memcpy(bp->gunzip_buf, data, len * 4);
 	}
 
-	while (len > DMAE_LEN32_MAX) {
-		bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
-				 addr + offset, DMAE_LEN32_MAX);
-		offset += DMAE_LEN32_MAX * 4;
-		len -= DMAE_LEN32_MAX;
-	}
-	bnx2x_write_dmae(bp, bp->gunzip_mapping + offset, addr + offset, len);
-}
-
-#define INIT_MEM_WB(reg, data, reg_off, len) \
-	bnx2x_init_wr_wb(bp, reg + reg_off*4, data, len, 0)
-
-#define INIT_GUNZIP_DMAE(reg, data, reg_off, len) \
-	bnx2x_init_wr_wb(bp, reg + reg_off*4, data, len, 1)
-
-static void bnx2x_init_fill(struct bnx2x *bp, u32 addr, int fill, u32 len)
-{
-	int offset = 0;
-
-	if ((len * 4) > FW_BUF_SIZE) {
-		BNX2X_ERR("LARGE DMAE OPERATION ! len 0x%x\n", len * 4);
-		return;
-	}
-	memset(bp->gunzip_buf, fill, len * 4);
-
-	while (len > DMAE_LEN32_MAX) {
+	if (bp->dmae_ready) {
+		while (len > DMAE_LEN32_WR_MAX) {
+			bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
+					 addr + offset, DMAE_LEN32_WR_MAX);
+			offset += DMAE_LEN32_WR_MAX * 4;
+			len -= DMAE_LEN32_WR_MAX;
+		}
 		bnx2x_write_dmae(bp, bp->gunzip_mapping + offset,
-				 addr + offset, DMAE_LEN32_MAX);
-		offset += DMAE_LEN32_MAX * 4;
-		len -= DMAE_LEN32_MAX;
-	}
-	bnx2x_write_dmae(bp, bp->gunzip_mapping + offset, addr + offset, len);
+				 addr + offset, len);
+	} else
+		bnx2x_init_ind_wr(bp, addr, bp->gunzip_buf, len);
 }
 
 static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 {
-	int i;
+	int is_e1       = CHIP_IS_E1(bp);
+	int is_e1h      = CHIP_IS_E1H(bp);
+	int is_emul_e1h = (CHIP_REV_IS_EMUL(bp) && is_e1h);
+	int hw_wr, i;
 	union init_op *op;
 	u32 op_type, addr, len;
-	const u32 *data;
+	const u32 *data, *data_base;
+
+	if (CHIP_REV_IS_FPGA(bp))
+		hw_wr = OP_WR_FPGA;
+	else if (CHIP_REV_IS_EMUL(bp))
+		hw_wr = OP_WR_EMUL;
+	else
+		hw_wr = OP_WR_ASIC;
+
+	if (is_e1)
+		data_base = init_data_e1;
+	else /* CHIP_IS_E1H(bp) */
+		data_base = init_data_e1h;
 
 	for (i = op_start; i < op_end; i++) {
 
@@ -202,7 +334,30 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 		op_type = op->str_wr.op;
 		addr = op->str_wr.offset;
 		len = op->str_wr.data_len;
-		data = init_data + op->str_wr.data_off;
+		data = data_base + op->str_wr.data_off;
+
+		/* carefull! it must be in order */
+		if (unlikely(op_type > OP_WB)) {
+
+			/* If E1 only */
+			if (op_type <= OP_WB_E1) {
+				if (is_e1)
+					op_type -= (OP_RD_E1 - OP_RD);
+
+			/* If E1H only */
+			} else if (op_type <= OP_WB_E1H) {
+				if (is_e1h)
+					op_type -= (OP_RD_E1H - OP_RD);
+			}
+
+			/* HW/EMUL specific */
+			if (op_type == hw_wr)
+				op_type = OP_WR;
+
+			/* EMUL on E1H is special */
+			if ((op_type == OP_WR_EMUL_E1H) && is_emul_e1h)
+				op_type = OP_WR;
+		}
 
 		switch (op_type) {
 		case OP_RD:
@@ -215,7 +370,7 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 			bnx2x_init_str_wr(bp, addr, data, len);
 			break;
 		case OP_WB:
-			bnx2x_init_wr_wb(bp, addr, data, len, 0);
+			bnx2x_init_wr_wb(bp, addr, data, len, 0, is_e1, 0);
 			break;
 		case OP_SI:
 			bnx2x_init_ind_wr(bp, addr, data, len);
@@ -224,10 +379,21 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 			bnx2x_init_fill(bp, addr, 0, op->zero.len);
 			break;
 		case OP_ZP:
-			bnx2x_init_wr_wb(bp, addr, data, len, 1);
+			bnx2x_init_wr_wb(bp, addr, data, len, 1, is_e1,
+					 op->str_wr.data_off);
+			break;
+		case OP_WR_64:
+			bnx2x_init_wr_64(bp, addr, data, len);
 			break;
 		default:
-			BNX2X_ERR("BAD init operation!\n");
+			/* happens whenever an op is of a diff HW */
+#if 0
+			DP(NETIF_MSG_HW, "skipping init operation  "
+			   "index %d[%d:%d]: type %d  addr 0x%x  "
+			   "len %d(0x%x)\n",
+			   i, op_start, op_end, op_type, addr, len, len);
+#endif
+			break;
 		}
 	}
 }
@@ -238,7 +404,7 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 ****************************************************************************/
 /*
  * This code configures the PCI read/write arbiter
- * which implements a wighted round robin
+ * which implements a weighted round robin
  * between the virtual queues in the chip.
  *
  * The values were derived for each PCI max payload and max request size.
@@ -308,7 +474,7 @@ static const struct arb_line write_arb_data[NUM_WR_Q][MAX_WR_ORD + 1] = {
 	{{8 , 64 , 25}, {16 , 64 , 41}, {32 , 64 , 81} }
 };
 
-/* register adresses for read queues */
+/* register addresses for read queues */
 static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
 	{PXP2_REG_RQ_BW_RD_L0, PXP2_REG_RQ_BW_RD_ADD0,
 		PXP2_REG_RQ_BW_RD_UBOUND0},
@@ -368,7 +534,7 @@ static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
 		PXP2_REG_PSWRQ_BW_UB28}
 };
 
-/* register adresses for wrtie queues */
+/* register addresses for write queues */
 static const struct arb_line write_arb_addr[NUM_WR_Q-1] = {
 	{PXP2_REG_PSWRQ_BW_L1, PXP2_REG_PSWRQ_BW_ADD1,
 		PXP2_REG_PSWRQ_BW_UB1},
@@ -417,6 +583,10 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 		   w_order, MAX_WR_ORD);
 		w_order = MAX_WR_ORD;
 	}
+	if (CHIP_REV_IS_FPGA(bp)) {
+		DP(NETIF_MSG_HW, "write order adjusted to 1 for FPGA\n");
+		w_order = 0;
+	}
 	DP(NETIF_MSG_HW, "read order %d  write order %d\n", r_order, w_order);
 
 	for (i = 0; i < NUM_RD_Q-1; i++) {
@@ -474,7 +644,20 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 		REG_WR(bp, PXP2_REG_RQ_PDR_LIMIT, 0xe00);
 
 	REG_WR(bp, PXP2_REG_WR_USDMDP_TH, (0x18 << w_order));
-	REG_WR(bp, PXP2_REG_WR_DMAE_TH, (128 << w_order)/16);
+
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR(bp, PXP2_REG_WR_HC_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_USDM_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_CSDM_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_TSDM_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_XSDM_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_QM_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_TM_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_SRC_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_DBG_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_DMAE_MPS, 2); /* DMAE is special */
+		REG_WR(bp, PXP2_REG_WR_CDU_MPS, w_order+1);
+	}
 }
 
 
@@ -557,6 +740,72 @@ static u8 calc_crc8(u32 data, u8 crc)
 	return crc_res;
 }
 
+/* regiesers addresses are not in order
+   so these arrays help simplify the code */
+static const int cm_start[E1H_FUNC_MAX][9] = {
+	{MISC_FUNC0_START, TCM_FUNC0_START, UCM_FUNC0_START, CCM_FUNC0_START,
+	 XCM_FUNC0_START, TSEM_FUNC0_START, USEM_FUNC0_START, CSEM_FUNC0_START,
+	 XSEM_FUNC0_START},
+	{MISC_FUNC1_START, TCM_FUNC1_START, UCM_FUNC1_START, CCM_FUNC1_START,
+	 XCM_FUNC1_START, TSEM_FUNC1_START, USEM_FUNC1_START, CSEM_FUNC1_START,
+	 XSEM_FUNC1_START},
+	{MISC_FUNC2_START, TCM_FUNC2_START, UCM_FUNC2_START, CCM_FUNC2_START,
+	 XCM_FUNC2_START, TSEM_FUNC2_START, USEM_FUNC2_START, CSEM_FUNC2_START,
+	 XSEM_FUNC2_START},
+	{MISC_FUNC3_START, TCM_FUNC3_START, UCM_FUNC3_START, CCM_FUNC3_START,
+	 XCM_FUNC3_START, TSEM_FUNC3_START, USEM_FUNC3_START, CSEM_FUNC3_START,
+	 XSEM_FUNC3_START},
+	{MISC_FUNC4_START, TCM_FUNC4_START, UCM_FUNC4_START, CCM_FUNC4_START,
+	 XCM_FUNC4_START, TSEM_FUNC4_START, USEM_FUNC4_START, CSEM_FUNC4_START,
+	 XSEM_FUNC4_START},
+	{MISC_FUNC5_START, TCM_FUNC5_START, UCM_FUNC5_START, CCM_FUNC5_START,
+	 XCM_FUNC5_START, TSEM_FUNC5_START, USEM_FUNC5_START, CSEM_FUNC5_START,
+	 XSEM_FUNC5_START},
+	{MISC_FUNC6_START, TCM_FUNC6_START, UCM_FUNC6_START, CCM_FUNC6_START,
+	 XCM_FUNC6_START, TSEM_FUNC6_START, USEM_FUNC6_START, CSEM_FUNC6_START,
+	 XSEM_FUNC6_START},
+	{MISC_FUNC7_START, TCM_FUNC7_START, UCM_FUNC7_START, CCM_FUNC7_START,
+	 XCM_FUNC7_START, TSEM_FUNC7_START, USEM_FUNC7_START, CSEM_FUNC7_START,
+	 XSEM_FUNC7_START}
+};
+
+static const int cm_end[E1H_FUNC_MAX][9] = {
+	{MISC_FUNC0_END, TCM_FUNC0_END, UCM_FUNC0_END, CCM_FUNC0_END,
+	 XCM_FUNC0_END, TSEM_FUNC0_END, USEM_FUNC0_END, CSEM_FUNC0_END,
+	 XSEM_FUNC0_END},
+	{MISC_FUNC1_END, TCM_FUNC1_END, UCM_FUNC1_END, CCM_FUNC1_END,
+	 XCM_FUNC1_END, TSEM_FUNC1_END, USEM_FUNC1_END, CSEM_FUNC1_END,
+	 XSEM_FUNC1_END},
+	{MISC_FUNC2_END, TCM_FUNC2_END, UCM_FUNC2_END, CCM_FUNC2_END,
+	 XCM_FUNC2_END, TSEM_FUNC2_END, USEM_FUNC2_END, CSEM_FUNC2_END,
+	 XSEM_FUNC2_END},
+	{MISC_FUNC3_END, TCM_FUNC3_END, UCM_FUNC3_END, CCM_FUNC3_END,
+	 XCM_FUNC3_END, TSEM_FUNC3_END, USEM_FUNC3_END, CSEM_FUNC3_END,
+	 XSEM_FUNC3_END},
+	{MISC_FUNC4_END, TCM_FUNC4_END, UCM_FUNC4_END, CCM_FUNC4_END,
+	 XCM_FUNC4_END, TSEM_FUNC4_END, USEM_FUNC4_END, CSEM_FUNC4_END,
+	 XSEM_FUNC4_END},
+	{MISC_FUNC5_END, TCM_FUNC5_END, UCM_FUNC5_END, CCM_FUNC5_END,
+	 XCM_FUNC5_END, TSEM_FUNC5_END, USEM_FUNC5_END, CSEM_FUNC5_END,
+	 XSEM_FUNC5_END},
+	{MISC_FUNC6_END, TCM_FUNC6_END, UCM_FUNC6_END, CCM_FUNC6_END,
+	 XCM_FUNC6_END, TSEM_FUNC6_END, USEM_FUNC6_END, CSEM_FUNC6_END,
+	 XSEM_FUNC6_END},
+	{MISC_FUNC7_END, TCM_FUNC7_END, UCM_FUNC7_END, CCM_FUNC7_END,
+	 XCM_FUNC7_END, TSEM_FUNC7_END, USEM_FUNC7_END, CSEM_FUNC7_END,
+	 XSEM_FUNC7_END},
+};
+
+static const int hc_limits[E1H_FUNC_MAX][2] = {
+	{HC_FUNC0_START, HC_FUNC0_END},
+	{HC_FUNC1_START, HC_FUNC1_END},
+	{HC_FUNC2_START, HC_FUNC2_END},
+	{HC_FUNC3_START, HC_FUNC3_END},
+	{HC_FUNC4_START, HC_FUNC4_END},
+	{HC_FUNC5_START, HC_FUNC5_END},
+	{HC_FUNC6_START, HC_FUNC6_END},
+	{HC_FUNC7_START, HC_FUNC7_END}
+};
 
 #endif /* BNX2X_INIT_H */
 
diff --git a/drivers/net/bnx2x_init_values.h b/drivers/net/bnx2x_init_values.h
index bef0a9b..41adbec 100644
--- a/drivers/net/bnx2x_init_values.h
+++ b/drivers/net/bnx2x_init_values.h
@@ -57,6 +57,7 @@ static const struct raw_op init_ops[] = {
 	{OP_RD, PRS_REG_NUM_OF_CFC_FLUSH_MESSAGES, 0x0},
 	{OP_RD, PRS_REG_NUM_OF_TRANSPARENT_FLUSH_MESSAGES, 0x0},
 	{OP_RD, PRS_REG_NUM_OF_DEAD_CYCLES, 0x0},
+	{OP_WR_E1H, PRS_REG_FCOE_TYPE, 0x8906},
 	{OP_WR, PRS_REG_FLUSH_REGIONS_TYPE_0, 0xff},
 	{OP_WR, PRS_REG_FLUSH_REGIONS_TYPE_1, 0xff},
 	{OP_WR, PRS_REG_FLUSH_REGIONS_TYPE_2, 0xff},
@@ -74,23 +75,27 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, PRS_REG_PACKET_REGIONS_TYPE_5, 0x3f},
 	{OP_WR, PRS_REG_PACKET_REGIONS_TYPE_6, 0x3f},
 	{OP_WR, PRS_REG_PACKET_REGIONS_TYPE_7, 0x3f},
-#define PRS_COMMON_END          46
-#define PRS_PORT0_START         46
-	{OP_WR, PRS_REG_CID_PORT_0, 0x0},
-#define PRS_PORT0_END           47
-#define PRS_PORT1_START         47
-	{OP_WR, PRS_REG_CID_PORT_1, 0x800000},
-#define PRS_PORT1_END           48
+#define PRS_COMMON_END          47
+#define SRCH_COMMON_START       47
+	{OP_WR_E1H, SRC_REG_E1HMF_ENABLE, 0x1},
+#define SRCH_COMMON_END         48
 #define TSDM_COMMON_START       48
-	{OP_WR, TSDM_REG_CFC_RSP_START_ADDR, 0x411},
-	{OP_WR, TSDM_REG_CMP_COUNTER_START_ADDR, 0x400},
-	{OP_WR, TSDM_REG_Q_COUNTER_START_ADDR, 0x404},
-	{OP_WR, TSDM_REG_PCK_END_MSG_START_ADDR, 0x419},
+	{OP_WR_E1, TSDM_REG_CFC_RSP_START_ADDR, 0x411},
+	{OP_WR_E1H, TSDM_REG_CFC_RSP_START_ADDR, 0x211},
+	{OP_WR_E1, TSDM_REG_CMP_COUNTER_START_ADDR, 0x400},
+	{OP_WR_E1H, TSDM_REG_CMP_COUNTER_START_ADDR, 0x200},
+	{OP_WR_E1, TSDM_REG_Q_COUNTER_START_ADDR, 0x404},
+	{OP_WR_E1H, TSDM_REG_Q_COUNTER_START_ADDR, 0x204},
+	{OP_WR_E1, TSDM_REG_PCK_END_MSG_START_ADDR, 0x419},
+	{OP_WR_E1H, TSDM_REG_PCK_END_MSG_START_ADDR, 0x219},
 	{OP_WR, TSDM_REG_CMP_COUNTER_MAX0, 0xffff},
 	{OP_WR, TSDM_REG_CMP_COUNTER_MAX1, 0xffff},
 	{OP_WR, TSDM_REG_CMP_COUNTER_MAX2, 0xffff},
 	{OP_WR, TSDM_REG_CMP_COUNTER_MAX3, 0xffff},
-	{OP_ZR, TSDM_REG_AGG_INT_EVENT_0, 0x80},
+	{OP_ZR, TSDM_REG_AGG_INT_EVENT_0, 0x2},
+	{OP_WR, TSDM_REG_AGG_INT_EVENT_2, 0x34},
+	{OP_WR, TSDM_REG_AGG_INT_EVENT_3, 0x35},
+	{OP_ZR, TSDM_REG_AGG_INT_EVENT_4, 0x7c},
 	{OP_WR, TSDM_REG_ENABLE_IN1, 0x7ffffff},
 	{OP_WR, TSDM_REG_ENABLE_IN2, 0x3f},
 	{OP_WR, TSDM_REG_ENABLE_OUT1, 0x7ffffff},
@@ -109,9 +114,12 @@ static const struct raw_op init_ops[] = {
 	{OP_RD, TSDM_REG_NUM_OF_PKT_END_MSG, 0x0},
 	{OP_RD, TSDM_REG_NUM_OF_PXP_ASYNC_REQ, 0x0},
 	{OP_RD, TSDM_REG_NUM_OF_ACK_AFTER_PLACE, 0x0},
-	{OP_WR, TSDM_REG_TIMER_TICK, 0x3e8},
-#define TSDM_COMMON_END         76
-#define TCM_COMMON_START        76
+	{OP_WR_E1, TSDM_REG_INIT_CREDIT_PXP_CTRL, 0x1},
+	{OP_WR_ASIC, TSDM_REG_TIMER_TICK, 0x3e8},
+	{OP_WR_EMUL, TSDM_REG_TIMER_TICK, 0x1},
+	{OP_WR_FPGA, TSDM_REG_TIMER_TICK, 0xa},
+#define TSDM_COMMON_END         86
+#define TCM_COMMON_START        86
 	{OP_WR, TCM_REG_XX_MAX_LL_SZ, 0x20},
 	{OP_WR, TCM_REG_XX_OVFL_EVNT_ID, 0x32},
 	{OP_WR, TCM_REG_TQM_TCM_HDR_P, 0x2150020},
@@ -143,9 +151,14 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, TCM_REG_N_SM_CTX_LD_3, 0x8},
 	{OP_ZR, TCM_REG_N_SM_CTX_LD_4, 0x4},
 	{OP_WR, TCM_REG_TCM_REG0_SZ, 0x6},
-	{OP_WR, TCM_REG_PHYS_QNUM0_0, 0xd},
-	{OP_WR, TCM_REG_PHYS_QNUM0_1, 0x2d},
-	{OP_ZR, TCM_REG_PHYS_QNUM1_0, 0x6},
+	{OP_WR_E1, TCM_REG_PHYS_QNUM0_0, 0xd},
+	{OP_WR_E1, TCM_REG_PHYS_QNUM0_1, 0x2d},
+	{OP_WR_E1, TCM_REG_PHYS_QNUM1_0, 0x7},
+	{OP_WR_E1, TCM_REG_PHYS_QNUM1_1, 0x27},
+	{OP_WR_E1, TCM_REG_PHYS_QNUM2_0, 0x7},
+	{OP_WR_E1, TCM_REG_PHYS_QNUM2_1, 0x27},
+	{OP_WR_E1, TCM_REG_PHYS_QNUM3_0, 0x7},
+	{OP_WR_E1, TCM_REG_PHYS_QNUM3_1, 0x27},
 	{OP_WR, TCM_REG_TCM_STORM0_IFEN, 0x1},
 	{OP_WR, TCM_REG_TCM_STORM1_IFEN, 0x1},
 	{OP_WR, TCM_REG_TCM_TQM_IFEN, 0x1},
@@ -162,23 +175,75 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, TCM_REG_CDU_SM_WR_IFEN, 0x1},
 	{OP_WR, TCM_REG_CDU_SM_RD_IFEN, 0x1},
 	{OP_WR, TCM_REG_TCM_CFC_IFEN, 0x1},
-#define TCM_COMMON_END          126
-#define BRB1_COMMON_START       126
+#define TCM_COMMON_END          141
+#define TCM_FUNC0_START         141
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM0_0, 0xd},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM1_0, 0x7},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM2_0, 0x7},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM3_0, 0x7},
+#define TCM_FUNC0_END           145
+#define TCM_FUNC1_START         145
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM0_1, 0x2d},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM1_1, 0x27},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM2_1, 0x27},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM3_1, 0x27},
+#define TCM_FUNC1_END           149
+#define TCM_FUNC2_START         149
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM0_0, 0x1d},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM1_0, 0x17},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM2_0, 0x17},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM3_0, 0x17},
+#define TCM_FUNC2_END           153
+#define TCM_FUNC3_START         153
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM0_1, 0x3d},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM1_1, 0x37},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM2_1, 0x37},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM3_1, 0x37},
+#define TCM_FUNC3_END           157
+#define TCM_FUNC4_START         157
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM0_0, 0x4d},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM1_0, 0x47},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM2_0, 0x47},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM3_0, 0x47},
+#define TCM_FUNC4_END           161
+#define TCM_FUNC5_START         161
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM0_1, 0x6d},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM1_1, 0x67},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM2_1, 0x67},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM3_1, 0x67},
+#define TCM_FUNC5_END           165
+#define TCM_FUNC6_START         165
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM0_0, 0x5d},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM1_0, 0x57},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM2_0, 0x57},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM3_0, 0x57},
+#define TCM_FUNC6_END           169
+#define TCM_FUNC7_START         169
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM0_1, 0x7d},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM1_1, 0x77},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM2_1, 0x77},
+	{OP_WR_E1H, TCM_REG_PHYS_QNUM3_1, 0x77},
+#define TCM_FUNC7_END           173
+#define BRB1_COMMON_START       173
 	{OP_SW, BRB1_REG_LL_RAM, 0x2000020},
 	{OP_WR, BRB1_REG_SOFT_RESET, 0x1},
-	{OP_RD, BRB1_REG_NUM_OF_PAUSE_CYCLES_0, 0x0},
-	{OP_RD, BRB1_REG_NUM_OF_PAUSE_CYCLES_1, 0x0},
-	{OP_RD, BRB1_REG_NUM_OF_PAUSE_CYCLES_2, 0x0},
-	{OP_RD, BRB1_REG_NUM_OF_PAUSE_CYCLES_3, 0x0},
-	{OP_RD, BRB1_REG_NUM_OF_FULL_CYCLES_0, 0x0},
-	{OP_RD, BRB1_REG_NUM_OF_FULL_CYCLES_1, 0x0},
-	{OP_RD, BRB1_REG_NUM_OF_FULL_CYCLES_2, 0x0},
-	{OP_RD, BRB1_REG_NUM_OF_FULL_CYCLES_3, 0x0},
 	{OP_RD, BRB1_REG_NUM_OF_FULL_CYCLES_4, 0x0},
 	{OP_SW, BRB1_REG_FREE_LIST_PRS_CRDT, 0x30220},
 	{OP_WR, BRB1_REG_SOFT_RESET, 0x0},
-#define BRB1_COMMON_END         139
-#define TSEM_COMMON_START       139
+#define BRB1_COMMON_END         178
+#define BRB1_PORT0_START        178
+	{OP_WR_E1, BRB1_REG_PAUSE_LOW_THRESHOLD_0, 0xb8},
+	{OP_WR_E1, BRB1_REG_PAUSE_HIGH_THRESHOLD_0, 0x114},
+	{OP_RD, BRB1_REG_NUM_OF_PAUSE_CYCLES_0, 0x0},
+	{OP_RD, BRB1_REG_NUM_OF_FULL_CYCLES_0, 0x0},
+#define BRB1_PORT0_END          182
+#define BRB1_PORT1_START        182
+	{OP_WR_E1, BRB1_REG_PAUSE_LOW_THRESHOLD_1, 0xb8},
+	{OP_WR_E1, BRB1_REG_PAUSE_HIGH_THRESHOLD_1, 0x114},
+	{OP_RD, BRB1_REG_NUM_OF_PAUSE_CYCLES_1, 0x0},
+	{OP_RD, BRB1_REG_NUM_OF_FULL_CYCLES_1, 0x0},
+#define BRB1_PORT1_END          186
+#define TSEM_COMMON_START       186
 	{OP_RD, TSEM_REG_MSG_NUM_FIC0, 0x0},
 	{OP_RD, TSEM_REG_MSG_NUM_FIC1, 0x0},
 	{OP_RD, TSEM_REG_MSG_NUM_FOC0, 0x0},
@@ -222,106 +287,243 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, TSEM_REG_FAST_MEMORY + 0x18040, 0x18},
 	{OP_WR, TSEM_REG_FAST_MEMORY + 0x18080, 0xc},
 	{OP_WR, TSEM_REG_FAST_MEMORY + 0x180c0, 0x20},
-	{OP_WR, TSEM_REG_FAST_MEMORY + 0x18300, 0x7a120},
+	{OP_WR_ASIC, TSEM_REG_FAST_MEMORY + 0x18300, 0x7a120},
+	{OP_WR_EMUL, TSEM_REG_FAST_MEMORY + 0x18300, 0x138},
+	{OP_WR_FPGA, TSEM_REG_FAST_MEMORY + 0x18300, 0x1388},
 	{OP_WR, TSEM_REG_FAST_MEMORY + 0x183c0, 0x1f4},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x2000, 0x1b3},
-	{OP_SW, TSEM_REG_FAST_MEMORY + 0x2000 + 0x6cc, 0x10223},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1020, 0xc8},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1000, 0x2},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x800, 0x2},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x808, 0x2},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x810, 0x4},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1fa0, 0x4},
-	{OP_SW, TSEM_REG_FAST_MEMORY + 0x4cf0, 0x80224},
-	{OP_ZP, TSEM_REG_INT_TABLE, 0x8c022c},
-	{OP_ZP, TSEM_REG_PRAM, 0x3395024f},
-	{OP_ZP, TSEM_REG_PRAM + 0x8000, 0x2c760f35},
-	{OP_ZP, TSEM_REG_PRAM + 0x10000, 0x5e1a53},
-	{OP_ZP, TSEM_REG_PRAM + 0x18000, 0x5e1a6b},
-	{OP_ZP, TSEM_REG_PRAM + 0x20000, 0x5e1a83},
-	{OP_ZP, TSEM_REG_PRAM + 0x28000, 0x5e1a9b},
-	{OP_ZP, TSEM_REG_PRAM + 0x30000, 0x5e1ab3},
-	{OP_ZP, TSEM_REG_PRAM + 0x38000, 0x5e1acb},
-#define TSEM_COMMON_END         202
-#define TSEM_PORT0_START        202
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x4000, 0x16c},
-	{OP_SW, TSEM_REG_FAST_MEMORY + 0x4000 + 0x5b0, 0x21ae3},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1370, 0xa},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x13c0, 0x6},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1418, 0xc},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1478, 0x12},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1508, 0x90},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x800, 0x2},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x820, 0x10},
-	{OP_SW, TSEM_REG_FAST_MEMORY + 0x820 + 0x40, 0x21ae5},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x2908, 0xa},
-#define TSEM_PORT0_END          213
-#define TSEM_PORT1_START        213
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x45b8, 0x16c},
-	{OP_SW, TSEM_REG_FAST_MEMORY + 0x45b8 + 0x5b0, 0x21ae7},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1398, 0xa},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x13d8, 0x6},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1448, 0xc},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x14c0, 0x12},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x1748, 0x90},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x808, 0x2},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x868, 0x10},
-	{OP_SW, TSEM_REG_FAST_MEMORY + 0x868 + 0x40, 0x21ae9},
-	{OP_ZR, TSEM_REG_FAST_MEMORY + 0x2930, 0xa},
-#define TSEM_PORT1_END          224
-#define MISC_COMMON_START       224
-	{OP_WR, MISC_REG_GRC_TIMEOUT_EN, 0x1},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x2000, 0xb2},
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x11480, 0x1},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x23c8, 0xc1},
+	{OP_WR_EMUL_E1H, TSEM_REG_FAST_MEMORY + 0x11480, 0x0},
+	{OP_SW_E1, TSEM_REG_FAST_MEMORY + 0x23c8 + 0x304, 0x10223},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x1000, 0x2b3},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1020, 0xc8},
+	{OP_SW_E1H, TSEM_REG_FAST_MEMORY + 0x1000 + 0xacc, 0x10223},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1000, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0xa020, 0xc8},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1c18, 0x4},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0xa000, 0x2},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x800, 0x2},
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x1ad0, 0x0},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x808, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3b28, 0x6},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x810, 0x4},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5000, 0x2},
+	{OP_SW_E1, TSEM_REG_FAST_MEMORY + 0x1fb0, 0x40224},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5008, 0x4},
+	{OP_SW_E1, TSEM_REG_FAST_MEMORY + 0x4cb0, 0x80228},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5018, 0x4},
+	{OP_ZP_E1, TSEM_REG_INT_TABLE, 0x940000},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5028, 0x4},
+	{OP_WR_64_E1, TSEM_REG_INT_TABLE + 0x360, 0x140230},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5038, 0x4},
+	{OP_ZP_E1, TSEM_REG_PRAM, 0x6ab70000},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5048, 0x4},
+	{OP_WR_64_E1, TSEM_REG_PRAM + 0x117f0, 0x5d020232},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5058, 0x4},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5068, 0x4},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5078, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x4000, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x4008, 0x2},
+	{OP_SW_E1H, TSEM_REG_FAST_MEMORY + 0x6140, 0x200224},
+	{OP_ZP_E1H, TSEM_REG_INT_TABLE, 0x960000},
+	{OP_WR_64_E1H, TSEM_REG_INT_TABLE + 0x360, 0x140244},
+	{OP_ZP_E1H, TSEM_REG_PRAM, 0x6d080000},
+	{OP_WR_64_E1H, TSEM_REG_PRAM + 0x11c70, 0x5c720246},
+#define TSEM_COMMON_END         272
+#define TSEM_PORT0_START        272
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x22c8, 0x20},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x2000, 0x16c},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x4000, 0xfc},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0xb000, 0x28},
+	{OP_WR_E1, TSEM_REG_FAST_MEMORY + 0x4b60, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0xb140, 0xc},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1400, 0xa},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x32c0, 0x12},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1450, 0x6},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3350, 0xfa},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1500, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x8108, 0x2},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1570, 0x12},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x9c0, 0xbe},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x800, 0x2},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x820, 0xe},
+	{OP_SW_E1, TSEM_REG_FAST_MEMORY + 0x1fb0, 0x20234},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x2908, 0x2},
+#define TSEM_PORT0_END          290
+#define TSEM_PORT1_START        290
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x2348, 0x20},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x25b0, 0x16c},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x43f0, 0xfc},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0xb0a0, 0x28},
+	{OP_WR_E1, TSEM_REG_FAST_MEMORY + 0x4b64, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0xb170, 0xc},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1428, 0xa},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3308, 0x12},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1468, 0x6},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3738, 0xfa},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x1538, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x8110, 0x2},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x15b8, 0x12},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0xcb8, 0xbe},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x808, 0x2},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x858, 0xe},
+	{OP_SW_E1, TSEM_REG_FAST_MEMORY + 0x1fb8, 0x20236},
+	{OP_ZR_E1, TSEM_REG_FAST_MEMORY + 0x2910, 0x2},
+#define TSEM_PORT1_END          308
+#define TSEM_FUNC0_START        308
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x2b60, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3000, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x31c0, 0x8},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5000, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5080, 0x12},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x4000, 0x2},
+#define TSEM_FUNC0_END          314
+#define TSEM_FUNC1_START        314
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x2b64, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3038, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x31e0, 0x8},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5010, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x50c8, 0x12},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x4008, 0x2},
+#define TSEM_FUNC1_END          320
+#define TSEM_FUNC2_START        320
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x2b68, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3070, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3200, 0x8},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5020, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5110, 0x12},
+	{OP_SW_E1H, TSEM_REG_FAST_MEMORY + 0x4010, 0x20248},
+#define TSEM_FUNC2_END          326
+#define TSEM_FUNC3_START        326
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x2b6c, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x30a8, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3220, 0x8},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5030, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5158, 0x12},
+	{OP_SW_E1H, TSEM_REG_FAST_MEMORY + 0x4018, 0x2024a},
+#define TSEM_FUNC3_END          332
+#define TSEM_FUNC4_START        332
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x2b70, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x30e0, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3240, 0x8},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5040, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x51a0, 0x12},
+	{OP_SW_E1H, TSEM_REG_FAST_MEMORY + 0x4020, 0x2024c},
+#define TSEM_FUNC4_END          338
+#define TSEM_FUNC5_START        338
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x2b74, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3118, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3260, 0x8},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5050, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x51e8, 0x12},
+	{OP_SW_E1H, TSEM_REG_FAST_MEMORY + 0x4028, 0x2024e},
+#define TSEM_FUNC5_END          344
+#define TSEM_FUNC6_START        344
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x2b78, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3150, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3280, 0x8},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5060, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5230, 0x12},
+	{OP_SW_E1H, TSEM_REG_FAST_MEMORY + 0x4030, 0x20250},
+#define TSEM_FUNC6_END          350
+#define TSEM_FUNC7_START        350
+	{OP_WR_E1H, TSEM_REG_FAST_MEMORY + 0x2b7c, 0x0},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x3188, 0xe},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x32a0, 0x8},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5070, 0x2},
+	{OP_ZR_E1H, TSEM_REG_FAST_MEMORY + 0x5278, 0x12},
+	{OP_SW_E1H, TSEM_REG_FAST_MEMORY + 0x4038, 0x20252},
+#define TSEM_FUNC7_END          356
+#define MISC_COMMON_START       356
+	{OP_WR_E1, MISC_REG_GRC_TIMEOUT_EN, 0x1},
 	{OP_WR, MISC_REG_PLL_STORM_CTRL_1, 0x71d2911},
 	{OP_WR, MISC_REG_PLL_STORM_CTRL_2, 0x0},
 	{OP_WR, MISC_REG_PLL_STORM_CTRL_3, 0x9c0424},
 	{OP_WR, MISC_REG_PLL_STORM_CTRL_4, 0x0},
 	{OP_WR, MISC_REG_LCPLL_CTRL_1, 0x209},
-#define MISC_COMMON_END         230
-#define NIG_COMMON_START        230
+	{OP_WR_E1, MISC_REG_SPIO, 0xff000000},
+#define MISC_COMMON_END         363
+#define MISC_FUNC0_START        363
+	{OP_WR_E1H, MISC_REG_NIG_WOL_P0, 0x0},
+#define MISC_FUNC0_END          364
+#define MISC_FUNC1_START        364
+	{OP_WR_E1H, MISC_REG_NIG_WOL_P1, 0x0},
+#define MISC_FUNC1_END          365
+#define MISC_FUNC2_START        365
+	{OP_WR_E1H, MISC_REG_NIG_WOL_P0, 0x0},
+#define MISC_FUNC2_END          366
+#define MISC_FUNC3_START        366
+	{OP_WR_E1H, MISC_REG_NIG_WOL_P1, 0x0},
+#define MISC_FUNC3_END          367
+#define MISC_FUNC4_START        367
+	{OP_WR_E1H, MISC_REG_NIG_WOL_P0, 0x0},
+#define MISC_FUNC4_END          368
+#define MISC_FUNC5_START        368
+	{OP_WR_E1H, MISC_REG_NIG_WOL_P1, 0x0},
+#define MISC_FUNC5_END          369
+#define MISC_FUNC6_START        369
+	{OP_WR_E1H, MISC_REG_NIG_WOL_P0, 0x0},
+#define MISC_FUNC6_END          370
+#define MISC_FUNC7_START        370
+	{OP_WR_E1H, MISC_REG_NIG_WOL_P1, 0x0},
+#define MISC_FUNC7_END          371
+#define NIG_COMMON_START        371
 	{OP_WR, NIG_REG_PBF_LB_IN_EN, 0x1},
 	{OP_WR, NIG_REG_PRS_REQ_IN_EN, 0x1},
 	{OP_WR, NIG_REG_EGRESS_DEBUG_IN_EN, 0x1},
 	{OP_WR, NIG_REG_BRB_LB_OUT_EN, 0x1},
 	{OP_WR, NIG_REG_PRS_EOP_OUT_EN, 0x1},
-#define NIG_COMMON_END          235
-#define NIG_PORT0_START         235
+#define NIG_COMMON_END          376
+#define NIG_PORT0_START         376
 	{OP_WR, NIG_REG_LLH0_CM_HEADER, 0x300000},
-	{OP_WR, NIG_REG_LLH0_EVENT_ID, 0x26},
+	{OP_WR, NIG_REG_LLH0_EVENT_ID, 0x28},
 	{OP_WR, NIG_REG_LLH0_ERROR_MASK, 0x0},
 	{OP_WR, NIG_REG_LLH0_XCM_MASK, 0x4},
 	{OP_WR, NIG_REG_LLH0_BRB1_NOT_MCP, 0x1},
 	{OP_WR, NIG_REG_STATUS_INTERRUPT_PORT0, 0x0},
+	{OP_WR_E1H, NIG_REG_LLH0_CLS_TYPE, 0x1},
 	{OP_WR, NIG_REG_LLH0_XCM_INIT_CREDIT, 0x30},
 	{OP_WR, NIG_REG_BRB0_PAUSE_IN_EN, 0x1},
 	{OP_WR, NIG_REG_EGRESS_PBF0_IN_EN, 0x1},
 	{OP_WR, NIG_REG_BRB0_OUT_EN, 0x1},
 	{OP_WR, NIG_REG_XCM0_OUT_EN, 0x1},
-#define NIG_PORT0_END           246
-#define NIG_PORT1_START         246
+#define NIG_PORT0_END           388
+#define NIG_PORT1_START         388
 	{OP_WR, NIG_REG_LLH1_CM_HEADER, 0x300000},
-	{OP_WR, NIG_REG_LLH1_EVENT_ID, 0x26},
+	{OP_WR, NIG_REG_LLH1_EVENT_ID, 0x28},
 	{OP_WR, NIG_REG_LLH1_ERROR_MASK, 0x0},
 	{OP_WR, NIG_REG_LLH1_XCM_MASK, 0x4},
 	{OP_WR, NIG_REG_LLH1_BRB1_NOT_MCP, 0x1},
 	{OP_WR, NIG_REG_STATUS_INTERRUPT_PORT1, 0x0},
+	{OP_WR_E1H, NIG_REG_LLH1_CLS_TYPE, 0x1},
 	{OP_WR, NIG_REG_LLH1_XCM_INIT_CREDIT, 0x30},
 	{OP_WR, NIG_REG_BRB1_PAUSE_IN_EN, 0x1},
 	{OP_WR, NIG_REG_EGRESS_PBF1_IN_EN, 0x1},
 	{OP_WR, NIG_REG_BRB1_OUT_EN, 0x1},
 	{OP_WR, NIG_REG_XCM1_OUT_EN, 0x1},
-#define NIG_PORT1_END           257
-#define UPB_COMMON_START        257
+#define NIG_PORT1_END           400
+#define UPB_COMMON_START        400
 	{OP_WR, GRCBASE_UPB + PB_REG_CONTROL, 0x20},
-#define UPB_COMMON_END          258
-#define CSDM_COMMON_START       258
-	{OP_WR, CSDM_REG_CFC_RSP_START_ADDR, 0xa11},
-	{OP_WR, CSDM_REG_CMP_COUNTER_START_ADDR, 0xa00},
-	{OP_WR, CSDM_REG_Q_COUNTER_START_ADDR, 0xa04},
+#define UPB_COMMON_END          401
+#define CSDM_COMMON_START       401
+	{OP_WR_E1, CSDM_REG_CFC_RSP_START_ADDR, 0xa11},
+	{OP_WR_E1H, CSDM_REG_CFC_RSP_START_ADDR, 0x211},
+	{OP_WR_E1, CSDM_REG_CMP_COUNTER_START_ADDR, 0xa00},
+	{OP_WR_E1H, CSDM_REG_CMP_COUNTER_START_ADDR, 0x200},
+	{OP_WR_E1, CSDM_REG_Q_COUNTER_START_ADDR, 0xa04},
+	{OP_WR_E1H, CSDM_REG_Q_COUNTER_START_ADDR, 0x204},
 	{OP_WR, CSDM_REG_CMP_COUNTER_MAX0, 0xffff},
 	{OP_WR, CSDM_REG_CMP_COUNTER_MAX1, 0xffff},
 	{OP_WR, CSDM_REG_CMP_COUNTER_MAX2, 0xffff},
 	{OP_WR, CSDM_REG_CMP_COUNTER_MAX3, 0xffff},
-	{OP_ZR, CSDM_REG_AGG_INT_EVENT_0, 0x80},
+	{OP_WR, CSDM_REG_AGG_INT_EVENT_0, 0xc6},
+	{OP_WR, CSDM_REG_AGG_INT_EVENT_1, 0x0},
+	{OP_WR, CSDM_REG_AGG_INT_EVENT_2, 0x34},
+	{OP_WR, CSDM_REG_AGG_INT_EVENT_3, 0x35},
+	{OP_ZR, CSDM_REG_AGG_INT_EVENT_4, 0x1c},
+	{OP_WR, CSDM_REG_AGG_INT_T_0, 0x1},
+	{OP_ZR, CSDM_REG_AGG_INT_T_1, 0x5f},
 	{OP_WR, CSDM_REG_ENABLE_IN1, 0x7ffffff},
 	{OP_WR, CSDM_REG_ENABLE_IN2, 0x3f},
 	{OP_WR, CSDM_REG_ENABLE_OUT1, 0x7ffffff},
@@ -340,19 +542,29 @@ static const struct raw_op init_ops[] = {
 	{OP_RD, CSDM_REG_NUM_OF_PKT_END_MSG, 0x0},
 	{OP_RD, CSDM_REG_NUM_OF_PXP_ASYNC_REQ, 0x0},
 	{OP_RD, CSDM_REG_NUM_OF_ACK_AFTER_PLACE, 0x0},
-	{OP_WR, CSDM_REG_TIMER_TICK, 0x3e8},
-#define CSDM_COMMON_END         285
-#define USDM_COMMON_START       285
-	{OP_WR, USDM_REG_CFC_RSP_START_ADDR, 0xa11},
-	{OP_WR, USDM_REG_CMP_COUNTER_START_ADDR, 0xa00},
-	{OP_WR, USDM_REG_Q_COUNTER_START_ADDR, 0xa04},
-	{OP_WR, USDM_REG_PCK_END_MSG_START_ADDR, 0xa21},
+	{OP_WR_E1, CSDM_REG_INIT_CREDIT_PXP_CTRL, 0x1},
+	{OP_WR_ASIC, CSDM_REG_TIMER_TICK, 0x3e8},
+	{OP_WR_EMUL, CSDM_REG_TIMER_TICK, 0x1},
+	{OP_WR_FPGA, CSDM_REG_TIMER_TICK, 0xa},
+#define CSDM_COMMON_END         440
+#define USDM_COMMON_START       440
+	{OP_WR_E1, USDM_REG_CFC_RSP_START_ADDR, 0xa11},
+	{OP_WR_E1H, USDM_REG_CFC_RSP_START_ADDR, 0x411},
+	{OP_WR_E1, USDM_REG_CMP_COUNTER_START_ADDR, 0xa00},
+	{OP_WR_E1H, USDM_REG_CMP_COUNTER_START_ADDR, 0x400},
+	{OP_WR_E1, USDM_REG_Q_COUNTER_START_ADDR, 0xa04},
+	{OP_WR_E1H, USDM_REG_Q_COUNTER_START_ADDR, 0x404},
+	{OP_WR_E1, USDM_REG_PCK_END_MSG_START_ADDR, 0xa21},
+	{OP_WR_E1H, USDM_REG_PCK_END_MSG_START_ADDR, 0x421},
 	{OP_WR, USDM_REG_CMP_COUNTER_MAX0, 0xffff},
 	{OP_WR, USDM_REG_CMP_COUNTER_MAX1, 0xffff},
 	{OP_WR, USDM_REG_CMP_COUNTER_MAX2, 0xffff},
 	{OP_WR, USDM_REG_CMP_COUNTER_MAX3, 0xffff},
 	{OP_WR, USDM_REG_AGG_INT_EVENT_0, 0x46},
-	{OP_ZR, USDM_REG_AGG_INT_EVENT_1, 0x5f},
+	{OP_WR, USDM_REG_AGG_INT_EVENT_1, 0x5},
+	{OP_WR, USDM_REG_AGG_INT_EVENT_2, 0x34},
+	{OP_WR, USDM_REG_AGG_INT_EVENT_3, 0x35},
+	{OP_ZR, USDM_REG_AGG_INT_EVENT_4, 0x5c},
 	{OP_WR, USDM_REG_AGG_INT_MODE_0, 0x1},
 	{OP_ZR, USDM_REG_AGG_INT_MODE_1, 0x1f},
 	{OP_WR, USDM_REG_ENABLE_IN1, 0x7ffffff},
@@ -374,9 +586,12 @@ static const struct raw_op init_ops[] = {
 	{OP_RD, USDM_REG_NUM_OF_PKT_END_MSG, 0x0},
 	{OP_RD, USDM_REG_NUM_OF_PXP_ASYNC_REQ, 0x0},
 	{OP_RD, USDM_REG_NUM_OF_ACK_AFTER_PLACE, 0x0},
-	{OP_WR, USDM_REG_TIMER_TICK, 0x3e8},
-#define USDM_COMMON_END         317
-#define CCM_COMMON_START        317
+	{OP_WR_E1, USDM_REG_INIT_CREDIT_PXP_CTRL, 0x1},
+	{OP_WR_ASIC, USDM_REG_TIMER_TICK, 0x3e8},
+	{OP_WR_EMUL, USDM_REG_TIMER_TICK, 0x1},
+	{OP_WR_FPGA, USDM_REG_TIMER_TICK, 0xa},
+#define USDM_COMMON_END         482
+#define CCM_COMMON_START        482
 	{OP_WR, CCM_REG_XX_OVFL_EVNT_ID, 0x32},
 	{OP_WR, CCM_REG_CQM_CCM_HDR_P, 0x2150020},
 	{OP_WR, CCM_REG_CQM_CCM_HDR_S, 0x2150020},
@@ -401,23 +616,28 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, CCM_REG_XX_INIT_CRD, 0x3},
 	{OP_WR, CCM_REG_XX_MSG_NUM, 0x18},
 	{OP_ZR, CCM_REG_XX_TABLE, 0x12},
-	{OP_SW, CCM_REG_XX_DESCR_TABLE, 0x241aeb},
+	{OP_SW_E1, CCM_REG_XX_DESCR_TABLE, 0x240238},
+	{OP_SW_E1H, CCM_REG_XX_DESCR_TABLE, 0x240254},
 	{OP_WR, CCM_REG_N_SM_CTX_LD_0, 0x1},
 	{OP_WR, CCM_REG_N_SM_CTX_LD_1, 0x2},
 	{OP_WR, CCM_REG_N_SM_CTX_LD_2, 0x8},
 	{OP_WR, CCM_REG_N_SM_CTX_LD_3, 0x8},
 	{OP_ZR, CCM_REG_N_SM_CTX_LD_4, 0x4},
 	{OP_WR, CCM_REG_CCM_REG0_SZ, 0x4},
-	{OP_WR, CCM_REG_QOS_PHYS_QNUM0_0, 0x9},
-	{OP_WR, CCM_REG_QOS_PHYS_QNUM0_1, 0x29},
-	{OP_WR, CCM_REG_QOS_PHYS_QNUM1_0, 0xa},
-	{OP_WR, CCM_REG_QOS_PHYS_QNUM1_1, 0x2a},
-	{OP_ZR, CCM_REG_QOS_PHYS_QNUM2_0, 0x4},
-	{OP_WR, CCM_REG_PHYS_QNUM1_0, 0xc},
-	{OP_WR, CCM_REG_PHYS_QNUM1_1, 0x2c},
-	{OP_WR, CCM_REG_PHYS_QNUM2_0, 0xb},
-	{OP_WR, CCM_REG_PHYS_QNUM2_1, 0x2b},
-	{OP_ZR, CCM_REG_PHYS_QNUM3_0, 0x2},
+	{OP_WR_E1, CCM_REG_QOS_PHYS_QNUM0_0, 0x9},
+	{OP_WR_E1, CCM_REG_QOS_PHYS_QNUM0_1, 0x29},
+	{OP_WR_E1, CCM_REG_QOS_PHYS_QNUM1_0, 0xa},
+	{OP_WR_E1, CCM_REG_QOS_PHYS_QNUM1_1, 0x2a},
+	{OP_WR_E1, CCM_REG_QOS_PHYS_QNUM2_0, 0x7},
+	{OP_WR_E1, CCM_REG_QOS_PHYS_QNUM2_1, 0x27},
+	{OP_WR_E1, CCM_REG_QOS_PHYS_QNUM3_0, 0x7},
+	{OP_WR_E1, CCM_REG_QOS_PHYS_QNUM3_1, 0x27},
+	{OP_WR_E1, CCM_REG_PHYS_QNUM1_0, 0xc},
+	{OP_WR_E1, CCM_REG_PHYS_QNUM1_1, 0x2c},
+	{OP_WR_E1, CCM_REG_PHYS_QNUM2_0, 0xc},
+	{OP_WR_E1, CCM_REG_PHYS_QNUM2_1, 0x2c},
+	{OP_WR_E1, CCM_REG_PHYS_QNUM3_0, 0xc},
+	{OP_WR_E1, CCM_REG_PHYS_QNUM3_1, 0x2c},
 	{OP_WR, CCM_REG_CCM_STORM0_IFEN, 0x1},
 	{OP_WR, CCM_REG_CCM_STORM1_IFEN, 0x1},
 	{OP_WR, CCM_REG_CCM_CQM_IFEN, 0x1},
@@ -433,8 +653,80 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, CCM_REG_CDU_SM_WR_IFEN, 0x1},
 	{OP_WR, CCM_REG_CDU_SM_RD_IFEN, 0x1},
 	{OP_WR, CCM_REG_CCM_CFC_IFEN, 0x1},
-#define CCM_COMMON_END          373
-#define UCM_COMMON_START        373
+#define CCM_COMMON_END          543
+#define CCM_FUNC0_START         543
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM0_0, 0x9},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM1_0, 0xa},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM2_0, 0x7},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM3_0, 0x7},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM1_0, 0xc},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM2_0, 0xb},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM3_0, 0x7},
+#define CCM_FUNC0_END           550
+#define CCM_FUNC1_START         550
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM0_1, 0x29},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM1_1, 0x2a},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM2_1, 0x27},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM3_1, 0x27},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM1_1, 0x2c},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM2_1, 0x2b},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM3_1, 0x27},
+#define CCM_FUNC1_END           557
+#define CCM_FUNC2_START         557
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM0_0, 0x19},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM1_0, 0x1a},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM2_0, 0x17},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM3_0, 0x17},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM1_0, 0x1c},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM2_0, 0x1b},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM3_0, 0x17},
+#define CCM_FUNC2_END           564
+#define CCM_FUNC3_START         564
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM0_1, 0x39},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM1_1, 0x3a},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM2_1, 0x37},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM3_1, 0x37},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM1_1, 0x3c},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM2_1, 0x3b},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM3_1, 0x37},
+#define CCM_FUNC3_END           571
+#define CCM_FUNC4_START         571
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM0_0, 0x49},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM1_0, 0x4a},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM2_0, 0x47},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM3_0, 0x47},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM1_0, 0x4c},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM2_0, 0x4b},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM3_0, 0x47},
+#define CCM_FUNC4_END           578
+#define CCM_FUNC5_START         578
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM0_1, 0x69},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM1_1, 0x6a},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM2_1, 0x67},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM3_1, 0x67},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM1_1, 0x6c},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM2_1, 0x6b},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM3_1, 0x67},
+#define CCM_FUNC5_END           585
+#define CCM_FUNC6_START         585
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM0_0, 0x59},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM1_0, 0x5a},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM2_0, 0x57},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM3_0, 0x57},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM1_0, 0x5c},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM2_0, 0x5b},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM3_0, 0x57},
+#define CCM_FUNC6_END           592
+#define CCM_FUNC7_START         592
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM0_1, 0x79},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM1_1, 0x7a},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM2_1, 0x77},
+	{OP_WR_E1H, CCM_REG_QOS_PHYS_QNUM3_1, 0x77},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM1_1, 0x7c},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM2_1, 0x7b},
+	{OP_WR_E1H, CCM_REG_PHYS_QNUM3_1, 0x77},
+#define CCM_FUNC7_END           599
+#define UCM_COMMON_START        599
 	{OP_WR, UCM_REG_XX_OVFL_EVNT_ID, 0x32},
 	{OP_WR, UCM_REG_UQM_UCM_HDR_P, 0x2150020},
 	{OP_WR, UCM_REG_UQM_UCM_HDR_S, 0x2150020},
@@ -457,20 +749,23 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, UCM_REG_FIC1_INIT_CRD, 0x40},
 	{OP_WR, UCM_REG_TM_INIT_CRD, 0x4},
 	{OP_WR, UCM_REG_UQM_INIT_CRD, 0x20},
-	{OP_WR, UCM_REG_XX_INIT_CRD, 0xc},
-	{OP_WR, UCM_REG_XX_MSG_NUM, 0x20},
+	{OP_WR, UCM_REG_XX_INIT_CRD, 0xe},
+	{OP_WR, UCM_REG_XX_MSG_NUM, 0x1b},
 	{OP_ZR, UCM_REG_XX_TABLE, 0x12},
-	{OP_SW, UCM_REG_XX_DESCR_TABLE, 0x201b0f},
-	{OP_WR, UCM_REG_N_SM_CTX_LD_0, 0xa},
+	{OP_SW_E1, UCM_REG_XX_DESCR_TABLE, 0x1b025c},
+	{OP_SW_E1H, UCM_REG_XX_DESCR_TABLE, 0x1b0278},
+	{OP_WR, UCM_REG_N_SM_CTX_LD_0, 0x10},
 	{OP_WR, UCM_REG_N_SM_CTX_LD_1, 0x7},
 	{OP_WR, UCM_REG_N_SM_CTX_LD_2, 0xf},
 	{OP_WR, UCM_REG_N_SM_CTX_LD_3, 0x10},
-	{OP_ZR, UCM_REG_N_SM_CTX_LD_4, 0x4},
+	{OP_ZR_E1, UCM_REG_N_SM_CTX_LD_4, 0x4},
+	{OP_WR_E1H, UCM_REG_N_SM_CTX_LD_4, 0xd},
+	{OP_ZR_E1H, UCM_REG_N_SM_CTX_LD_5, 0x3},
 	{OP_WR, UCM_REG_UCM_REG0_SZ, 0x3},
-	{OP_WR, UCM_REG_PHYS_QNUM0_0, 0xf},
-	{OP_WR, UCM_REG_PHYS_QNUM0_1, 0x2f},
-	{OP_WR, UCM_REG_PHYS_QNUM1_0, 0xe},
-	{OP_WR, UCM_REG_PHYS_QNUM1_1, 0x2e},
+	{OP_WR_E1, UCM_REG_PHYS_QNUM0_0, 0xf},
+	{OP_WR_E1, UCM_REG_PHYS_QNUM0_1, 0x2f},
+	{OP_WR_E1, UCM_REG_PHYS_QNUM1_0, 0xe},
+	{OP_WR_E1, UCM_REG_PHYS_QNUM1_1, 0x2e},
 	{OP_WR, UCM_REG_UCM_STORM0_IFEN, 0x1},
 	{OP_WR, UCM_REG_UCM_STORM1_IFEN, 0x1},
 	{OP_WR, UCM_REG_UCM_UQM_IFEN, 0x1},
@@ -488,8 +783,56 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, UCM_REG_CDU_SM_WR_IFEN, 0x1},
 	{OP_WR, UCM_REG_CDU_SM_RD_IFEN, 0x1},
 	{OP_WR, UCM_REG_UCM_CFC_IFEN, 0x1},
-#define UCM_COMMON_END          426
-#define USEM_COMMON_START       426
+#define UCM_COMMON_END          655
+#define UCM_FUNC0_START         655
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM0_0, 0xf},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM1_0, 0xe},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM2_0, 0x0},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM3_0, 0x0},
+#define UCM_FUNC0_END           659
+#define UCM_FUNC1_START         659
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM0_1, 0x2f},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM1_1, 0x2e},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM2_1, 0x0},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM3_1, 0x0},
+#define UCM_FUNC1_END           663
+#define UCM_FUNC2_START         663
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM0_0, 0x1f},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM1_0, 0x1e},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM2_0, 0x0},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM3_0, 0x0},
+#define UCM_FUNC2_END           667
+#define UCM_FUNC3_START         667
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM0_1, 0x3f},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM1_1, 0x3e},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM2_1, 0x0},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM3_1, 0x0},
+#define UCM_FUNC3_END           671
+#define UCM_FUNC4_START         671
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM0_0, 0x4f},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM1_0, 0x4e},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM2_0, 0x0},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM3_0, 0x0},
+#define UCM_FUNC4_END           675
+#define UCM_FUNC5_START         675
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM0_1, 0x6f},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM1_1, 0x6e},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM2_1, 0x0},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM3_1, 0x0},
+#define UCM_FUNC5_END           679
+#define UCM_FUNC6_START         679
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM0_0, 0x5f},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM1_0, 0x5e},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM2_0, 0x0},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM3_0, 0x0},
+#define UCM_FUNC6_END           683
+#define UCM_FUNC7_START         683
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM0_1, 0x7f},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM1_1, 0x7e},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM2_1, 0x0},
+	{OP_WR_E1H, UCM_REG_PHYS_QNUM3_1, 0x0},
+#define UCM_FUNC7_END           687
+#define USEM_COMMON_START       687
 	{OP_RD, USEM_REG_MSG_NUM_FIC0, 0x0},
 	{OP_RD, USEM_REG_MSG_NUM_FIC1, 0x0},
 	{OP_RD, USEM_REG_MSG_NUM_FOC0, 0x0},
@@ -533,87 +876,191 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, USEM_REG_FAST_MEMORY + 0x18040, 0x4e},
 	{OP_WR, USEM_REG_FAST_MEMORY + 0x18080, 0x10},
 	{OP_WR, USEM_REG_FAST_MEMORY + 0x180c0, 0x20},
-	{OP_WR, USEM_REG_FAST_MEMORY + 0x18300, 0x7a120},
+	{OP_WR_ASIC, USEM_REG_FAST_MEMORY + 0x18300, 0x7a120},
+	{OP_WR_EMUL, USEM_REG_FAST_MEMORY + 0x18300, 0x138},
+	{OP_WR_FPGA, USEM_REG_FAST_MEMORY + 0x18300, 0x1388},
 	{OP_WR, USEM_REG_FAST_MEMORY + 0x183c0, 0x1f4},
-	{OP_WR, USEM_REG_FAST_MEMORY + 0x18380, 0x1dcd6500},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x5000, 0x102},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1020, 0xc8},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1000, 0x2},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1e20, 0x40},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3000, 0x400},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x2400, 0x2},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x2408, 0x2},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x2410, 0x6},
-	{OP_SW, USEM_REG_FAST_MEMORY + 0x2410 + 0x18, 0x21b2f},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x4b68, 0x2},
-	{OP_SW, USEM_REG_FAST_MEMORY + 0x4b68 + 0x8, 0x21b31},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x4b10, 0x2},
-	{OP_SW, USEM_REG_FAST_MEMORY + 0x2c30, 0x21b33},
+	{OP_WR_ASIC, USEM_REG_FAST_MEMORY + 0x18380, 0x1dcd6500},
+	{OP_WR_EMUL, USEM_REG_FAST_MEMORY + 0x18380, 0x4c4b4},
+	{OP_WR_FPGA, USEM_REG_FAST_MEMORY + 0x18380, 0x4c4b40},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x5000, 0x102},
+	{OP_WR_EMUL_E1H, USEM_REG_FAST_MEMORY + 0x11480, 0x0},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1020, 0xc8},
+	{OP_WR_E1H, USEM_REG_FAST_MEMORY + 0x11480, 0x1},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1000, 0x2},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x2000, 0x102},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x57e8, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x8020, 0xc8},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x57d0, 0x5},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x8000, 0x2},
+	{OP_SW_E1, USEM_REG_FAST_MEMORY + 0x57d0 + 0x14, 0x10277},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3760, 0x4},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1e20, 0x42},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3738, 0x9},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3000, 0x400},
+	{OP_SW_E1H, USEM_REG_FAST_MEMORY + 0x3738 + 0x24, 0x10293},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x2c00, 0x2},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3180, 0x42},
+	{OP_SW_E1, USEM_REG_FAST_MEMORY + 0x2c00 + 0x8, 0x20278},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5000, 0x400},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x4b68, 0x2},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4000, 0x2},
+	{OP_SW_E1, USEM_REG_FAST_MEMORY + 0x4b68 + 0x8, 0x2027a},
+	{OP_SW_E1H, USEM_REG_FAST_MEMORY + 0x4000 + 0x8, 0x20294},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x4b10, 0x2},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x6b68, 0x2},
+	{OP_SW_E1, USEM_REG_FAST_MEMORY + 0x2830, 0x2027c},
+	{OP_SW_E1H, USEM_REG_FAST_MEMORY + 0x6b68 + 0x8, 0x20296},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x6b10, 0x2},
+	{OP_SW_E1H, USEM_REG_FAST_MEMORY + 0x74c0, 0x20298},
 	{OP_WR, USEM_REG_FAST_MEMORY + 0x10800, 0x1000000},
-	{OP_SW, USEM_REG_FAST_MEMORY + 0x10c00, 0x101b35},
+	{OP_SW_E1, USEM_REG_FAST_MEMORY + 0x10c00, 0x10027e},
+	{OP_SW_E1H, USEM_REG_FAST_MEMORY + 0x10c00, 0x10029a},
 	{OP_WR, USEM_REG_FAST_MEMORY + 0x10800, 0x0},
-	{OP_SW, USEM_REG_FAST_MEMORY + 0x10c40, 0x101b45},
-	{OP_ZP, USEM_REG_INT_TABLE, 0xb41b55},
-	{OP_ZP, USEM_REG_PRAM, 0x32d01b82},
-	{OP_ZP, USEM_REG_PRAM + 0x8000, 0x32172836},
-	{OP_ZP, USEM_REG_PRAM + 0x10000, 0x1a7a34bc},
-	{OP_ZP, USEM_REG_PRAM + 0x18000, 0x5f3b5b},
-	{OP_ZP, USEM_REG_PRAM + 0x20000, 0x5f3b73},
-	{OP_ZP, USEM_REG_PRAM + 0x28000, 0x5f3b8b},
-	{OP_ZP, USEM_REG_PRAM + 0x30000, 0x5f3ba3},
-	{OP_ZP, USEM_REG_PRAM + 0x38000, 0x5f3bbb},
-#define USEM_COMMON_END         498
-#define USEM_PORT0_START        498
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1400, 0xa0},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1900, 0xa},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1950, 0x2e},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1d00, 0x24},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3000, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3100, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3200, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3300, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3400, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3500, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3600, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3700, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3800, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3900, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3a00, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3b00, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3c00, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3d00, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3e00, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3f00, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x2400, 0x2},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x4b78, 0x52},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x4e08, 0xc},
-#define USEM_PORT0_END          521
-#define USEM_PORT1_START        521
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1680, 0xa0},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1928, 0xa},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1a08, 0x2e},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x1d90, 0x24},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3080, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3180, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3280, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3380, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3480, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3580, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3680, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3780, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3880, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3980, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3a80, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3b80, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3c80, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3d80, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3e80, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x3f80, 0x20},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x2408, 0x2},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x4cc0, 0x52},
-	{OP_ZR, USEM_REG_FAST_MEMORY + 0x4e38, 0xc},
-#define USEM_PORT1_END          544
-#define CSEM_COMMON_START       544
+	{OP_SW_E1, USEM_REG_FAST_MEMORY + 0x10c40, 0x10028e},
+	{OP_SW_E1H, USEM_REG_FAST_MEMORY + 0x10c40, 0x1002aa},
+	{OP_ZP_E1, USEM_REG_INT_TABLE, 0xc20000},
+	{OP_ZP_E1H, USEM_REG_INT_TABLE, 0xc40000},
+	{OP_WR_64_E1, USEM_REG_INT_TABLE + 0x368, 0x13029e},
+	{OP_WR_64_E1H, USEM_REG_INT_TABLE + 0x368, 0x1302ba},
+	{OP_ZP_E1, USEM_REG_PRAM, 0x975a0000},
+	{OP_ZP_E1H, USEM_REG_PRAM, 0x985c0000},
+	{OP_WR_64_E1, USEM_REG_PRAM + 0x17f90, 0x500e02a0},
+	{OP_WR_64_E1H, USEM_REG_PRAM + 0x18200, 0x4fc002bc},
+#define USEM_COMMON_END         781
+#define USEM_PORT0_START        781
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1400, 0xa0},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x9000, 0xa0},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1900, 0xa},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x9500, 0x28},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1950, 0x2e},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x9640, 0x34},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1d00, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3080, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1d20, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3288, 0x96},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x5440, 0x72},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5000, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3000, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5100, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3100, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5200, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3200, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5300, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3300, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5400, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3400, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5500, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3500, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5600, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3600, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5700, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3700, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5800, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3800, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5900, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3900, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5a00, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3a00, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5b00, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3b00, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5c00, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3c00, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5d00, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3d00, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5e00, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3e00, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5f00, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3f00, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x6b78, 0x52},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x2c10, 0x2},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x6e08, 0xc},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x4b78, 0x52},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x4e08, 0xc},
+#define USEM_PORT0_END          829
+#define USEM_PORT1_START        829
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1680, 0xa0},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x9280, 0xa0},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1928, 0xa},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x95a0, 0x28},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1a08, 0x2e},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x9710, 0x34},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1d10, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3100, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x1da0, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x34e0, 0x96},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x5608, 0x72},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5080, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3080, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5180, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3180, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5280, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3280, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5380, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3380, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5480, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3480, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5580, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3580, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5680, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3680, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5780, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3780, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5880, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3880, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5980, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3980, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5a80, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3a80, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5b80, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3b80, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5c80, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3c80, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5d80, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3d80, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5e80, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3e80, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x5f80, 0x20},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x3f80, 0x20},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x6cc0, 0x52},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x2c20, 0x2},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x6e38, 0xc},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x4cc0, 0x52},
+	{OP_ZR_E1, USEM_REG_FAST_MEMORY + 0x4e38, 0xc},
+#define USEM_PORT1_END          877
+#define USEM_FUNC0_START        877
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3000, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4010, 0x2},
+#define USEM_FUNC0_END          879
+#define USEM_FUNC1_START        879
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3010, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4020, 0x2},
+#define USEM_FUNC1_END          881
+#define USEM_FUNC2_START        881
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3020, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4030, 0x2},
+#define USEM_FUNC2_END          883
+#define USEM_FUNC3_START        883
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3030, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4040, 0x2},
+#define USEM_FUNC3_END          885
+#define USEM_FUNC4_START        885
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3040, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4050, 0x2},
+#define USEM_FUNC4_END          887
+#define USEM_FUNC5_START        887
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3050, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4060, 0x2},
+#define USEM_FUNC5_END          889
+#define USEM_FUNC6_START        889
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3060, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4070, 0x2},
+#define USEM_FUNC6_END          891
+#define USEM_FUNC7_START        891
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x3070, 0x4},
+	{OP_ZR_E1H, USEM_REG_FAST_MEMORY + 0x4080, 0x2},
+#define USEM_FUNC7_END          893
+#define CSEM_COMMON_START       893
 	{OP_RD, CSEM_REG_MSG_NUM_FIC0, 0x0},
 	{OP_RD, CSEM_REG_MSG_NUM_FIC1, 0x0},
 	{OP_RD, CSEM_REG_MSG_NUM_FOC0, 0x0},
@@ -658,50 +1105,104 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, CSEM_REG_FAST_MEMORY + 0x18080, 0x30},
 	{OP_WR, CSEM_REG_FAST_MEMORY + 0x180c0, 0xe},
 	{OP_WR, CSEM_REG_FAST_MEMORY + 0x183c0, 0x1f4},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x5000, 0x42},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x1020, 0xc8},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x1000, 0x2},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x2000, 0xc0},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x3070, 0x80},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x4280, 0x4},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x25c0, 0x240},
-	{OP_SW, CSEM_REG_FAST_MEMORY + 0x25c0 + 0x900, 0x83bd3},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x5000, 0x42},
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x11480, 0x1},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x1020, 0xc8},
+	{OP_WR_EMUL_E1H, CSEM_REG_FAST_MEMORY + 0x11480, 0x0},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x1000, 0x2},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x1000, 0x42},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x2000, 0xc0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x7020, 0xc8},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x3070, 0x80},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x7000, 0x2},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x4280, 0x4},
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x11e8, 0x0},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x25c0, 0x240},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3000, 0xc0},
+	{OP_SW_E1, CSEM_REG_FAST_MEMORY + 0x2ec8, 0x802a2},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x4070, 0x80},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x5280, 0x4},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x6280, 0x240},
+	{OP_SW_E1H, CSEM_REG_FAST_MEMORY + 0x6b88, 0x2002be},
 	{OP_WR, CSEM_REG_FAST_MEMORY + 0x10800, 0x13fffff},
-	{OP_SW, CSEM_REG_FAST_MEMORY + 0x10c00, 0x103bdb},
+	{OP_SW_E1, CSEM_REG_FAST_MEMORY + 0x10c00, 0x1002aa},
+	{OP_SW_E1H, CSEM_REG_FAST_MEMORY + 0x10c00, 0x1002de},
 	{OP_WR, CSEM_REG_FAST_MEMORY + 0x10800, 0x0},
-	{OP_SW, CSEM_REG_FAST_MEMORY + 0x10c40, 0x103beb},
-	{OP_ZP, CSEM_REG_INT_TABLE, 0x5f3bfb},
-	{OP_ZP, CSEM_REG_PRAM, 0x32423c13},
-	{OP_ZP, CSEM_REG_PRAM + 0x8000, 0xf2148a4},
-	{OP_ZP, CSEM_REG_PRAM + 0x10000, 0x5f4c6d},
-	{OP_ZP, CSEM_REG_PRAM + 0x18000, 0x5f4c85},
-	{OP_ZP, CSEM_REG_PRAM + 0x20000, 0x5f4c9d},
-	{OP_ZP, CSEM_REG_PRAM + 0x28000, 0x5f4cb5},
-	{OP_ZP, CSEM_REG_PRAM + 0x30000, 0x5f4ccd},
-	{OP_ZP, CSEM_REG_PRAM + 0x38000, 0x5f4ce5},
-#define CSEM_COMMON_END         609
-#define CSEM_PORT0_START        609
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x1400, 0xa0},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x1900, 0x10},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x1980, 0x30},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x2300, 0x2},
-	{OP_SW, CSEM_REG_FAST_MEMORY + 0x2300 + 0x8, 0x24cfd},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x3040, 0x6},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x2410, 0x30},
-#define CSEM_PORT0_END          616
-#define CSEM_PORT1_START        616
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x1680, 0xa0},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x1940, 0x10},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x1a40, 0x30},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x2310, 0x2},
-	{OP_SW, CSEM_REG_FAST_MEMORY + 0x2310 + 0x8, 0x24cff},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x3058, 0x6},
-	{OP_ZR, CSEM_REG_FAST_MEMORY + 0x24d0, 0x30},
-#define CSEM_PORT1_END          623
-#define XPB_COMMON_START        623
+	{OP_SW_E1, CSEM_REG_FAST_MEMORY + 0x10c40, 0x1002ba},
+	{OP_SW_E1H, CSEM_REG_FAST_MEMORY + 0x10c40, 0x1002ee},
+	{OP_ZP_E1, CSEM_REG_INT_TABLE, 0x6e0000},
+	{OP_ZP_E1H, CSEM_REG_INT_TABLE, 0x6f0000},
+	{OP_WR_64_E1, CSEM_REG_INT_TABLE + 0x380, 0x1002ca},
+	{OP_WR_64_E1H, CSEM_REG_INT_TABLE + 0x380, 0x1002fe},
+	{OP_ZP_E1, CSEM_REG_PRAM, 0x48bc0000},
+	{OP_ZP_E1H, CSEM_REG_PRAM, 0x493d0000},
+	{OP_WR_64_E1, CSEM_REG_PRAM + 0xb210, 0x682402cc},
+	{OP_WR_64_E1H, CSEM_REG_PRAM + 0xb430, 0x67e00300},
+#define CSEM_COMMON_END         970
+#define CSEM_PORT0_START        970
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x1400, 0xa0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x8000, 0xa0},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x1900, 0x10},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x8500, 0x40},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x1980, 0x30},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x8700, 0x3c},
+	{OP_WR_E1, CSEM_REG_FAST_MEMORY + 0x5118, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x4040, 0x6},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x2300, 0xe},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x6040, 0x30},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x3040, 0x6},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x2410, 0x30},
+#define CSEM_PORT0_END          982
+#define CSEM_PORT1_START        982
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x1680, 0xa0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x8280, 0xa0},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x1940, 0x10},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x8600, 0x40},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x1a40, 0x30},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x87f0, 0x3c},
+	{OP_WR_E1, CSEM_REG_FAST_MEMORY + 0x511c, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x4058, 0x6},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x2338, 0xe},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x6100, 0x30},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x3058, 0x6},
+	{OP_ZR_E1, CSEM_REG_FAST_MEMORY + 0x24d0, 0x30},
+#define CSEM_PORT1_END          994
+#define CSEM_FUNC0_START        994
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x1148, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3300, 0x2},
+#define CSEM_FUNC0_END          996
+#define CSEM_FUNC1_START        996
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x114c, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3308, 0x2},
+#define CSEM_FUNC1_END          998
+#define CSEM_FUNC2_START        998
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x1150, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3310, 0x2},
+#define CSEM_FUNC2_END          1000
+#define CSEM_FUNC3_START        1000
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x1154, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3318, 0x2},
+#define CSEM_FUNC3_END          1002
+#define CSEM_FUNC4_START        1002
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x1158, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3320, 0x2},
+#define CSEM_FUNC4_END          1004
+#define CSEM_FUNC5_START        1004
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x115c, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3328, 0x2},
+#define CSEM_FUNC5_END          1006
+#define CSEM_FUNC6_START        1006
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x1160, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3330, 0x2},
+#define CSEM_FUNC6_END          1008
+#define CSEM_FUNC7_START        1008
+	{OP_WR_E1H, CSEM_REG_FAST_MEMORY + 0x1164, 0x0},
+	{OP_ZR_E1H, CSEM_REG_FAST_MEMORY + 0x3338, 0x2},
+#define CSEM_FUNC7_END          1010
+#define XPB_COMMON_START        1010
 	{OP_WR, GRCBASE_XPB + PB_REG_CONTROL, 0x20},
-#define XPB_COMMON_END          624
-#define DQ_COMMON_START         624
+#define XPB_COMMON_END          1011
+#define DQ_COMMON_START         1011
 	{OP_WR, DORQ_REG_MODE_ACT, 0x2},
 	{OP_WR, DORQ_REG_NORM_CID_OFST, 0x3},
 	{OP_WR, DORQ_REG_OUTST_REQ, 0x4},
@@ -720,8 +1221,8 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, DORQ_REG_DQ_FIFO_AFULL_TH, 0x76c},
 	{OP_WR, DORQ_REG_REGN, 0x7c1004},
 	{OP_WR, DORQ_REG_IF_EN, 0xf},
-#define DQ_COMMON_END           642
-#define TIMERS_COMMON_START     642
+#define DQ_COMMON_END           1029
+#define TIMERS_COMMON_START     1029
 	{OP_ZR, TM_REG_CLIN_PRIOR0_CLIENT, 0x2},
 	{OP_WR, TM_REG_LIN_SETCLR_FIFO_ALFULL_THR, 0x1c},
 	{OP_WR, TM_REG_CFC_AC_CRDCNT_VAL, 0x1},
@@ -730,8 +1231,11 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, TM_REG_CLOUT_CRDCNT1_VAL, 0x1},
 	{OP_WR, TM_REG_CLOUT_CRDCNT2_VAL, 0x1},
 	{OP_WR, TM_REG_EXP_CRDCNT_VAL, 0x1},
-	{OP_WR, TM_REG_PCIARB_CRDCNT_VAL, 0x2},
-	{OP_WR, TM_REG_TIMER_TICK_SIZE, 0x3d090},
+	{OP_WR_E1, TM_REG_PCIARB_CRDCNT_VAL, 0x1},
+	{OP_WR_E1H, TM_REG_PCIARB_CRDCNT_VAL, 0x2},
+	{OP_WR_ASIC, TM_REG_TIMER_TICK_SIZE, 0x3d090},
+	{OP_WR_EMUL, TM_REG_TIMER_TICK_SIZE, 0x9c},
+	{OP_WR_FPGA, TM_REG_TIMER_TICK_SIZE, 0x9c4},
 	{OP_WR, TM_REG_CL0_CONT_REGION, 0x8},
 	{OP_WR, TM_REG_CL1_CONT_REGION, 0xc},
 	{OP_WR, TM_REG_CL2_CONT_REGION, 0x10},
@@ -741,24 +1245,37 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, TM_REG_EN_CL0_INPUT, 0x1},
 	{OP_WR, TM_REG_EN_CL1_INPUT, 0x1},
 	{OP_WR, TM_REG_EN_CL2_INPUT, 0x1},
-#define TIMERS_COMMON_END       661
-#define TIMERS_PORT0_START      661
+#define TIMERS_COMMON_END       1051
+#define TIMERS_PORT0_START      1051
 	{OP_ZR, TM_REG_LIN0_PHY_ADDR, 0x2},
-#define TIMERS_PORT0_END        662
-#define TIMERS_PORT1_START      662
+#define TIMERS_PORT0_END        1052
+#define TIMERS_PORT1_START      1052
 	{OP_ZR, TM_REG_LIN1_PHY_ADDR, 0x2},
-#define TIMERS_PORT1_END        663
-#define XSDM_COMMON_START       663
-	{OP_WR, XSDM_REG_CFC_RSP_START_ADDR, 0xa14},
-	{OP_WR, XSDM_REG_CMP_COUNTER_START_ADDR, 0xa00},
-	{OP_WR, XSDM_REG_Q_COUNTER_START_ADDR, 0xa04},
+#define TIMERS_PORT1_END        1053
+#define XSDM_COMMON_START       1053
+	{OP_WR_E1, XSDM_REG_CFC_RSP_START_ADDR, 0x614},
+	{OP_WR_E1H, XSDM_REG_CFC_RSP_START_ADDR, 0x424},
+	{OP_WR_E1, XSDM_REG_CMP_COUNTER_START_ADDR, 0x600},
+	{OP_WR_E1H, XSDM_REG_CMP_COUNTER_START_ADDR, 0x410},
+	{OP_WR_E1, XSDM_REG_Q_COUNTER_START_ADDR, 0x604},
+	{OP_WR_E1H, XSDM_REG_Q_COUNTER_START_ADDR, 0x414},
 	{OP_WR, XSDM_REG_CMP_COUNTER_MAX0, 0xffff},
 	{OP_WR, XSDM_REG_CMP_COUNTER_MAX1, 0xffff},
 	{OP_WR, XSDM_REG_CMP_COUNTER_MAX2, 0xffff},
 	{OP_WR, XSDM_REG_CMP_COUNTER_MAX3, 0xffff},
 	{OP_WR, XSDM_REG_AGG_INT_EVENT_0, 0x20},
 	{OP_WR, XSDM_REG_AGG_INT_EVENT_1, 0x20},
-	{OP_ZR, XSDM_REG_AGG_INT_EVENT_2, 0x5e},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_2, 0x34},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_3, 0x35},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_4, 0x23},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_5, 0x24},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_6, 0x25},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_7, 0x26},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_8, 0x27},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_9, 0x29},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_10, 0x2a},
+	{OP_WR, XSDM_REG_AGG_INT_EVENT_11, 0x2b},
+	{OP_ZR, XSDM_REG_AGG_INT_EVENT_12, 0x54},
 	{OP_WR, XSDM_REG_AGG_INT_MODE_0, 0x1},
 	{OP_ZR, XSDM_REG_AGG_INT_MODE_1, 0x1f},
 	{OP_WR, XSDM_REG_ENABLE_IN1, 0x7ffffff},
@@ -779,9 +1296,12 @@ static const struct raw_op init_ops[] = {
 	{OP_RD, XSDM_REG_NUM_OF_PKT_END_MSG, 0x0},
 	{OP_RD, XSDM_REG_NUM_OF_PXP_ASYNC_REQ, 0x0},
 	{OP_RD, XSDM_REG_NUM_OF_ACK_AFTER_PLACE, 0x0},
-	{OP_WR, XSDM_REG_TIMER_TICK, 0x3e8},
-#define XSDM_COMMON_END         694
-#define QM_COMMON_START         694
+	{OP_WR_E1, XSDM_REG_INIT_CREDIT_PXP_CTRL, 0x1},
+	{OP_WR_ASIC, XSDM_REG_TIMER_TICK, 0x3e8},
+	{OP_WR_EMUL, XSDM_REG_TIMER_TICK, 0x1},
+	{OP_WR_FPGA, XSDM_REG_TIMER_TICK, 0xa},
+#define XSDM_COMMON_END         1100
+#define QM_COMMON_START         1100
 	{OP_WR, QM_REG_ACTCTRINITVAL_0, 0x6},
 	{OP_WR, QM_REG_ACTCTRINITVAL_1, 0x5},
 	{OP_WR, QM_REG_ACTCTRINITVAL_2, 0xa},
@@ -820,13 +1340,27 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, QM_REG_WRRWEIGHTS_3, 0x1010120},
 	{OP_ZR, QM_REG_QVOQIDX_17, 0x4},
 	{OP_WR, QM_REG_WRRWEIGHTS_4, 0x1010101},
-	{OP_ZR, QM_REG_QVOQIDX_21, 0x4},
-	{OP_WR, QM_REG_WRRWEIGHTS_5, 0x1010101},
-	{OP_ZR, QM_REG_QVOQIDX_25, 0x4},
-	{OP_WR, QM_REG_WRRWEIGHTS_6, 0x1010101},
-	{OP_ZR, QM_REG_QVOQIDX_29, 0x3},
+	{OP_ZR_E1, QM_REG_QVOQIDX_21, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_21, 0x0},
+	{OP_WR_E1, QM_REG_WRRWEIGHTS_5, 0x1010101},
+	{OP_WR_E1H, QM_REG_QVOQIDX_22, 0x4},
+	{OP_ZR_E1, QM_REG_QVOQIDX_25, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_23, 0x4},
+	{OP_WR_E1, QM_REG_WRRWEIGHTS_6, 0x1010101},
+	{OP_WR_E1H, QM_REG_QVOQIDX_24, 0x2},
+	{OP_ZR_E1, QM_REG_QVOQIDX_29, 0x3},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_5, 0x8012004},
+	{OP_WR_E1H, QM_REG_QVOQIDX_25, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_26, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_27, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_28, 0x5},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_6, 0x20081001},
+	{OP_WR_E1H, QM_REG_QVOQIDX_29, 0x8},
+	{OP_WR_E1H, QM_REG_QVOQIDX_30, 0x6},
+	{OP_WR_E1H, QM_REG_QVOQIDX_31, 0x7},
 	{OP_WR, QM_REG_QVOQIDX_32, 0x1},
-	{OP_WR, QM_REG_WRRWEIGHTS_7, 0x1010101},
+	{OP_WR_E1, QM_REG_WRRWEIGHTS_7, 0x1010101},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_7, 0x1010120},
 	{OP_WR, QM_REG_QVOQIDX_33, 0x1},
 	{OP_WR, QM_REG_QVOQIDX_34, 0x1},
 	{OP_WR, QM_REG_QVOQIDX_35, 0x1},
@@ -853,36 +1387,169 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, QM_REG_QVOQIDX_52, 0x1},
 	{OP_WR, QM_REG_WRRWEIGHTS_12, 0x1010101},
 	{OP_WR, QM_REG_QVOQIDX_53, 0x1},
-	{OP_WR, QM_REG_QVOQIDX_54, 0x1},
-	{OP_WR, QM_REG_QVOQIDX_55, 0x1},
-	{OP_WR, QM_REG_QVOQIDX_56, 0x1},
-	{OP_WR, QM_REG_WRRWEIGHTS_13, 0x1010101},
-	{OP_WR, QM_REG_QVOQIDX_57, 0x1},
-	{OP_WR, QM_REG_QVOQIDX_58, 0x1},
-	{OP_WR, QM_REG_QVOQIDX_59, 0x1},
-	{OP_WR, QM_REG_QVOQIDX_60, 0x1},
-	{OP_WR, QM_REG_WRRWEIGHTS_14, 0x1010101},
-	{OP_WR, QM_REG_QVOQIDX_61, 0x1},
-	{OP_WR, QM_REG_QVOQIDX_62, 0x1},
-	{OP_WR, QM_REG_QVOQIDX_63, 0x1},
-	{OP_WR, QM_REG_WRRWEIGHTS_15, 0x1010101},
-	{OP_WR, QM_REG_VOQQMASK_0_LSB, 0xffff003f},
-	{OP_ZR, QM_REG_VOQQMASK_0_MSB, 0x2},
-	{OP_WR, QM_REG_VOQQMASK_1_MSB, 0xffff003f},
-	{OP_WR, QM_REG_VOQQMASK_2_LSB, 0x100},
-	{OP_WR, QM_REG_VOQQMASK_2_MSB, 0x100},
+	{OP_WR_E1, QM_REG_QVOQIDX_54, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_54, 0x4},
+	{OP_WR_E1, QM_REG_QVOQIDX_55, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_55, 0x4},
+	{OP_WR_E1, QM_REG_QVOQIDX_56, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_56, 0x2},
+	{OP_WR_E1, QM_REG_WRRWEIGHTS_13, 0x1010101},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_13, 0x8012004},
+	{OP_WR_E1, QM_REG_QVOQIDX_57, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_57, 0x5},
+	{OP_WR_E1, QM_REG_QVOQIDX_58, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_58, 0x5},
+	{OP_WR_E1, QM_REG_QVOQIDX_59, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_59, 0x5},
+	{OP_WR_E1, QM_REG_QVOQIDX_60, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_60, 0x5},
+	{OP_WR_E1, QM_REG_WRRWEIGHTS_14, 0x1010101},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_14, 0x20081001},
+	{OP_WR_E1, QM_REG_QVOQIDX_61, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_61, 0x8},
+	{OP_WR_E1, QM_REG_QVOQIDX_62, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_62, 0x6},
+	{OP_WR_E1, QM_REG_QVOQIDX_63, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_63, 0x7},
+	{OP_WR_E1, QM_REG_WRRWEIGHTS_15, 0x1010101},
+	{OP_WR_E1H, QM_REG_QVOQIDX_64, 0x0},
+	{OP_WR_E1, QM_REG_VOQQMASK_0_LSB, 0xffff003f},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_15, 0x1010120},
+	{OP_ZR_E1, QM_REG_VOQQMASK_0_MSB, 0x2},
+	{OP_ZR_E1H, QM_REG_QVOQIDX_65, 0x4},
+	{OP_WR_E1, QM_REG_VOQQMASK_1_MSB, 0xffff003f},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_16, 0x1010101},
+	{OP_WR_E1, QM_REG_VOQQMASK_2_LSB, 0x100},
+	{OP_WR_E1H, QM_REG_QVOQIDX_69, 0x0},
+	{OP_WR_E1, QM_REG_VOQQMASK_2_MSB, 0x100},
+	{OP_WR_E1H, QM_REG_QVOQIDX_70, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_71, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_72, 0x2},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_17, 0x8012004},
+	{OP_WR_E1H, QM_REG_QVOQIDX_73, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_74, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_75, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_76, 0x5},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_18, 0x20081001},
+	{OP_WR_E1H, QM_REG_QVOQIDX_77, 0x8},
+	{OP_WR_E1H, QM_REG_QVOQIDX_78, 0x6},
+	{OP_WR_E1H, QM_REG_QVOQIDX_79, 0x7},
+	{OP_WR_E1H, QM_REG_QVOQIDX_80, 0x0},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_19, 0x1010120},
+	{OP_ZR_E1H, QM_REG_QVOQIDX_81, 0x4},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_20, 0x1010101},
+	{OP_WR_E1H, QM_REG_QVOQIDX_85, 0x0},
+	{OP_WR_E1H, QM_REG_QVOQIDX_86, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_87, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_88, 0x2},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_21, 0x8012004},
+	{OP_WR_E1H, QM_REG_QVOQIDX_89, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_90, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_91, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_92, 0x5},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_22, 0x20081001},
+	{OP_WR_E1H, QM_REG_QVOQIDX_93, 0x8},
+	{OP_WR_E1H, QM_REG_QVOQIDX_94, 0x6},
+	{OP_WR_E1H, QM_REG_QVOQIDX_95, 0x7},
+	{OP_WR_E1H, QM_REG_QVOQIDX_96, 0x1},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_23, 0x1010120},
+	{OP_WR_E1H, QM_REG_QVOQIDX_97, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_98, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_99, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_100, 0x1},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_24, 0x1010101},
+	{OP_WR_E1H, QM_REG_QVOQIDX_101, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_102, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_103, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_104, 0x2},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_25, 0x8012004},
+	{OP_WR_E1H, QM_REG_QVOQIDX_105, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_106, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_107, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_108, 0x5},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_26, 0x20081001},
+	{OP_WR_E1H, QM_REG_QVOQIDX_109, 0x8},
+	{OP_WR_E1H, QM_REG_QVOQIDX_110, 0x6},
+	{OP_WR_E1H, QM_REG_QVOQIDX_111, 0x7},
+	{OP_WR_E1H, QM_REG_QVOQIDX_112, 0x1},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_27, 0x1010120},
+	{OP_WR_E1H, QM_REG_QVOQIDX_113, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_114, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_115, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_116, 0x1},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_28, 0x1010101},
+	{OP_WR_E1H, QM_REG_QVOQIDX_117, 0x1},
+	{OP_WR_E1H, QM_REG_QVOQIDX_118, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_119, 0x4},
+	{OP_WR_E1H, QM_REG_QVOQIDX_120, 0x2},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_29, 0x8012004},
+	{OP_WR_E1H, QM_REG_QVOQIDX_121, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_122, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_123, 0x5},
+	{OP_WR_E1H, QM_REG_QVOQIDX_124, 0x5},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_30, 0x20081001},
+	{OP_WR_E1H, QM_REG_QVOQIDX_125, 0x8},
+	{OP_WR_E1H, QM_REG_QVOQIDX_126, 0x6},
+	{OP_WR_E1H, QM_REG_QVOQIDX_127, 0x7},
+	{OP_WR_E1H, QM_REG_WRRWEIGHTS_31, 0x1010120},
+	{OP_WR_E1H, QM_REG_VOQQMASK_0_LSB, 0x3f003f},
+	{OP_WR_E1H, QM_REG_VOQQMASK_0_MSB, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_0_LSB_EXT_A, 0x3f003f},
+	{OP_WR_E1H, QM_REG_VOQQMASK_0_MSB_EXT_A, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_1_LSB, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_1_MSB, 0x3f003f},
+	{OP_WR_E1H, QM_REG_VOQQMASK_1_LSB_EXT_A, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_1_MSB_EXT_A, 0x3f003f},
+	{OP_WR_E1H, QM_REG_VOQQMASK_2_LSB, 0x1000100},
+	{OP_WR_E1H, QM_REG_VOQQMASK_2_MSB, 0x1000100},
+	{OP_WR_E1H, QM_REG_VOQQMASK_2_LSB_EXT_A, 0x1000100},
+	{OP_WR_E1H, QM_REG_VOQQMASK_2_MSB_EXT_A, 0x1000100},
 	{OP_ZR, QM_REG_VOQQMASK_3_LSB, 0x2},
-	{OP_WR, QM_REG_VOQQMASK_4_LSB, 0xc0},
-	{OP_WR, QM_REG_VOQQMASK_4_MSB, 0xc0},
-	{OP_WR, QM_REG_VOQQMASK_5_LSB, 0x1e00},
-	{OP_WR, QM_REG_VOQQMASK_5_MSB, 0x1e00},
-	{OP_WR, QM_REG_VOQQMASK_6_LSB, 0x4000},
-	{OP_WR, QM_REG_VOQQMASK_6_MSB, 0x4000},
-	{OP_WR, QM_REG_VOQQMASK_7_LSB, 0x8000},
-	{OP_WR, QM_REG_VOQQMASK_7_MSB, 0x8000},
-	{OP_WR, QM_REG_VOQQMASK_8_LSB, 0x2000},
-	{OP_WR, QM_REG_VOQQMASK_8_MSB, 0x2000},
-	{OP_ZR, QM_REG_VOQQMASK_9_LSB, 0x7},
+	{OP_WR_E1, QM_REG_VOQQMASK_4_LSB, 0xc0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_3_LSB_EXT_A, 0x0},
+	{OP_WR_E1, QM_REG_VOQQMASK_4_MSB, 0xc0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_3_MSB_EXT_A, 0x0},
+	{OP_WR_E1, QM_REG_VOQQMASK_5_LSB, 0x1e00},
+	{OP_WR_E1H, QM_REG_VOQQMASK_4_LSB, 0xc000c0},
+	{OP_WR_E1, QM_REG_VOQQMASK_5_MSB, 0x1e00},
+	{OP_WR_E1H, QM_REG_VOQQMASK_4_MSB, 0xc000c0},
+	{OP_WR_E1, QM_REG_VOQQMASK_6_LSB, 0x4000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_4_LSB_EXT_A, 0xc000c0},
+	{OP_WR_E1, QM_REG_VOQQMASK_6_MSB, 0x4000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_4_MSB_EXT_A, 0xc000c0},
+	{OP_WR_E1, QM_REG_VOQQMASK_7_LSB, 0x8000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_5_LSB, 0x1e001e00},
+	{OP_WR_E1, QM_REG_VOQQMASK_7_MSB, 0x8000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_5_MSB, 0x1e001e00},
+	{OP_WR_E1, QM_REG_VOQQMASK_8_LSB, 0x2000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_5_LSB_EXT_A, 0x1e001e00},
+	{OP_WR_E1, QM_REG_VOQQMASK_8_MSB, 0x2000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_5_MSB_EXT_A, 0x1e001e00},
+	{OP_ZR_E1, QM_REG_VOQQMASK_9_LSB, 0x7},
+	{OP_WR_E1H, QM_REG_VOQQMASK_6_LSB, 0x40004000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_6_MSB, 0x40004000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_6_LSB_EXT_A, 0x40004000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_6_MSB_EXT_A, 0x40004000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_7_LSB, 0x80008000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_7_MSB, 0x80008000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_7_LSB_EXT_A, 0x80008000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_7_MSB_EXT_A, 0x80008000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_8_LSB, 0x20002000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_8_MSB, 0x20002000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_8_LSB_EXT_A, 0x20002000},
+	{OP_WR_E1H, QM_REG_VOQQMASK_8_MSB_EXT_A, 0x20002000},
+	{OP_ZR_E1H, QM_REG_VOQQMASK_9_LSB, 0x2},
+	{OP_WR_E1H, QM_REG_VOQQMASK_9_LSB_EXT_A, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_9_MSB_EXT_A, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_10_LSB, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_10_MSB, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_10_LSB_EXT_A, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_10_MSB_EXT_A, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_11_LSB, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_11_MSB, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_11_LSB_EXT_A, 0x0},
+	{OP_WR_E1H, QM_REG_VOQQMASK_11_MSB_EXT_A, 0x0},
+	{OP_WR_E1H, QM_REG_VOQPORT_0, 0x0},
 	{OP_WR, QM_REG_VOQPORT_1, 0x1},
 	{OP_ZR, QM_REG_VOQPORT_2, 0xa},
 	{OP_WR, QM_REG_CMINTVOQMASK_0, 0xc08},
@@ -893,8 +1560,12 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, QM_REG_CMINTVOQMASK_5, 0x80},
 	{OP_WR, QM_REG_CMINTVOQMASK_6, 0x200},
 	{OP_WR, QM_REG_CMINTVOQMASK_7, 0x0},
-	{OP_WR, QM_REG_HWAEMPTYMASK_LSB, 0xffff01ff},
-	{OP_WR, QM_REG_HWAEMPTYMASK_MSB, 0xffff01ff},
+	{OP_WR_E1, QM_REG_HWAEMPTYMASK_LSB, 0xffff01ff},
+	{OP_WR_E1H, QM_REG_HWAEMPTYMASK_LSB, 0x1ff01ff},
+	{OP_WR_E1, QM_REG_HWAEMPTYMASK_MSB, 0xffff01ff},
+	{OP_WR_E1H, QM_REG_HWAEMPTYMASK_MSB, 0x1ff01ff},
+	{OP_WR_E1H, QM_REG_HWAEMPTYMASK_LSB_EXT_A, 0x1ff01ff},
+	{OP_WR_E1H, QM_REG_HWAEMPTYMASK_MSB_EXT_A, 0x1ff01ff},
 	{OP_WR, QM_REG_ENBYPVOQMASK, 0x13},
 	{OP_WR, QM_REG_VOQCREDITAFULLTHR, 0x13f},
 	{OP_WR, QM_REG_VOQINITCREDIT_0, 0x140},
@@ -910,15 +1581,29 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, QM_REG_BYTECRDINITVAL, 0x8000},
 	{OP_WR, QM_REG_BYTECRDCOST, 0x25e4},
 	{OP_WR, QM_REG_BYTECREDITAFULLTHR, 0x7fff},
-	{OP_WR, QM_REG_ENBYTECRD_LSB, 0x7},
-	{OP_WR, QM_REG_ENBYTECRD_MSB, 0x7},
+	{OP_WR_E1, QM_REG_ENBYTECRD_LSB, 0x7},
+	{OP_WR_E1H, QM_REG_ENBYTECRD_LSB, 0x70007},
+	{OP_WR_E1, QM_REG_ENBYTECRD_MSB, 0x7},
+	{OP_WR_E1H, QM_REG_ENBYTECRD_MSB, 0x70007},
+	{OP_WR_E1H, QM_REG_ENBYTECRD_LSB_EXT_A, 0x70007},
+	{OP_WR_E1H, QM_REG_ENBYTECRD_MSB_EXT_A, 0x70007},
 	{OP_WR, QM_REG_BYTECRDPORT_LSB, 0x0},
 	{OP_WR, QM_REG_BYTECRDPORT_MSB, 0xffffffff},
-	{OP_WR, QM_REG_FUNCNUMSEL_LSB, 0x0},
-	{OP_WR, QM_REG_FUNCNUMSEL_MSB, 0xffffffff},
+	{OP_WR_E1, QM_REG_FUNCNUMSEL_LSB, 0x0},
+	{OP_WR_E1H, QM_REG_BYTECRDPORT_LSB_EXT_A, 0x0},
+	{OP_WR_E1, QM_REG_FUNCNUMSEL_MSB, 0xffffffff},
+	{OP_WR_E1H, QM_REG_BYTECRDPORT_MSB_EXT_A, 0xffffffff},
+	{OP_WR_E1H, QM_REG_PQ2PCIFUNC_0, 0x0},
+	{OP_WR_E1H, QM_REG_PQ2PCIFUNC_1, 0x2},
+	{OP_WR_E1H, QM_REG_PQ2PCIFUNC_2, 0x1},
+	{OP_WR_E1H, QM_REG_PQ2PCIFUNC_3, 0x3},
+	{OP_WR_E1H, QM_REG_PQ2PCIFUNC_4, 0x4},
+	{OP_WR_E1H, QM_REG_PQ2PCIFUNC_5, 0x6},
+	{OP_WR_E1H, QM_REG_PQ2PCIFUNC_6, 0x5},
+	{OP_WR_E1H, QM_REG_PQ2PCIFUNC_7, 0x7},
 	{OP_WR, QM_REG_CMINTEN, 0xff},
-#define QM_COMMON_END           829
-#define PBF_COMMON_START        829
+#define QM_COMMON_END           1400
+#define PBF_COMMON_START        1400
 	{OP_WR, PBF_REG_INIT, 0x1},
 	{OP_WR, PBF_REG_INIT_P4, 0x1},
 	{OP_WR, PBF_REG_MAC_LB_ENABLE, 0x1},
@@ -926,20 +1611,20 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, PBF_REG_INIT_P4, 0x0},
 	{OP_WR, PBF_REG_INIT, 0x0},
 	{OP_WR, PBF_REG_DISABLE_NEW_TASK_PROC_P4, 0x0},
-#define PBF_COMMON_END          836
-#define PBF_PORT0_START         836
+#define PBF_COMMON_END          1407
+#define PBF_PORT0_START         1407
 	{OP_WR, PBF_REG_INIT_P0, 0x1},
 	{OP_WR, PBF_REG_MAC_IF0_ENABLE, 0x1},
 	{OP_WR, PBF_REG_INIT_P0, 0x0},
 	{OP_WR, PBF_REG_DISABLE_NEW_TASK_PROC_P0, 0x0},
-#define PBF_PORT0_END           840
-#define PBF_PORT1_START         840
+#define PBF_PORT0_END           1411
+#define PBF_PORT1_START         1411
 	{OP_WR, PBF_REG_INIT_P1, 0x1},
 	{OP_WR, PBF_REG_MAC_IF1_ENABLE, 0x1},
 	{OP_WR, PBF_REG_INIT_P1, 0x0},
 	{OP_WR, PBF_REG_DISABLE_NEW_TASK_PROC_P1, 0x0},
-#define PBF_PORT1_END           844
-#define XCM_COMMON_START        844
+#define PBF_PORT1_END           1415
+#define XCM_COMMON_START        1415
 	{OP_WR, XCM_REG_XX_OVFL_EVNT_ID, 0x32},
 	{OP_WR, XCM_REG_XQM_XCM_HDR_P, 0x3150020},
 	{OP_WR, XCM_REG_XQM_XCM_HDR_S, 0x3150020},
@@ -971,14 +1656,18 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, XCM_REG_TM_INIT_CRD, 0x4},
 	{OP_WR, XCM_REG_XQM_INIT_CRD, 0x20},
 	{OP_WR, XCM_REG_XX_INIT_CRD, 0x2},
-	{OP_WR, XCM_REG_XX_MSG_NUM, 0x1f},
+	{OP_WR_E1, XCM_REG_XX_MSG_NUM, 0x1f},
+	{OP_WR_E1H, XCM_REG_XX_MSG_NUM, 0x20},
 	{OP_ZR, XCM_REG_XX_TABLE, 0x12},
-	{OP_SW, XCM_REG_XX_DESCR_TABLE, 0x1f4d01},
+	{OP_SW_E1, XCM_REG_XX_DESCR_TABLE, 0x1f02ce},
+	{OP_SW_E1H, XCM_REG_XX_DESCR_TABLE, 0x1f0302},
 	{OP_WR, XCM_REG_N_SM_CTX_LD_0, 0xf},
 	{OP_WR, XCM_REG_N_SM_CTX_LD_1, 0x7},
 	{OP_WR, XCM_REG_N_SM_CTX_LD_2, 0xb},
 	{OP_WR, XCM_REG_N_SM_CTX_LD_3, 0xe},
-	{OP_ZR, XCM_REG_N_SM_CTX_LD_4, 0x4},
+	{OP_ZR_E1, XCM_REG_N_SM_CTX_LD_4, 0x4},
+	{OP_WR_E1H, XCM_REG_N_SM_CTX_LD_4, 0xc},
+	{OP_ZR_E1H, XCM_REG_N_SM_CTX_LD_5, 0x3},
 	{OP_WR, XCM_REG_XCM_REG0_SZ, 0x4},
 	{OP_WR, XCM_REG_XCM_STORM0_IFEN, 0x1},
 	{OP_WR, XCM_REG_XCM_STORM1_IFEN, 0x1},
@@ -1000,28 +1689,116 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, XCM_REG_CDU_SM_WR_IFEN, 0x1},
 	{OP_WR, XCM_REG_CDU_SM_RD_IFEN, 0x1},
 	{OP_WR, XCM_REG_XCM_CFC_IFEN, 0x1},
-#define XCM_COMMON_END          904
-#define XCM_PORT0_START         904
-	{OP_WR, XCM_REG_GLB_DEL_ACK_TMR_VAL_0, 0xc8},
-	{OP_WR, XCM_REG_GLB_DEL_ACK_MAX_CNT_0, 0x2},
-	{OP_WR, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00, 0x0},
-	{OP_WR, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD10, 0x0},
-	{OP_WR, XCM_REG_WU_DA_CNT_CMD00, 0x2},
-	{OP_WR, XCM_REG_WU_DA_CNT_CMD10, 0x2},
-	{OP_WR, XCM_REG_WU_DA_CNT_UPD_VAL00, 0xff},
-	{OP_WR, XCM_REG_WU_DA_CNT_UPD_VAL10, 0xff},
-#define XCM_PORT0_END           912
-#define XCM_PORT1_START         912
-	{OP_WR, XCM_REG_GLB_DEL_ACK_TMR_VAL_1, 0xc8},
-	{OP_WR, XCM_REG_GLB_DEL_ACK_MAX_CNT_1, 0x2},
-	{OP_WR, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD01, 0x0},
-	{OP_WR, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD11, 0x0},
-	{OP_WR, XCM_REG_WU_DA_CNT_CMD01, 0x2},
-	{OP_WR, XCM_REG_WU_DA_CNT_CMD11, 0x2},
-	{OP_WR, XCM_REG_WU_DA_CNT_UPD_VAL01, 0xff},
-	{OP_WR, XCM_REG_WU_DA_CNT_UPD_VAL11, 0xff},
-#define XCM_PORT1_END           920
-#define XSEM_COMMON_START       920
+#define XCM_COMMON_END          1479
+#define XCM_PORT0_START         1479
+	{OP_WR_E1, XCM_REG_GLB_DEL_ACK_TMR_VAL_0, 0xc8},
+	{OP_WR_E1, XCM_REG_GLB_DEL_ACK_MAX_CNT_0, 0x2},
+	{OP_WR_E1, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00, 0x0},
+	{OP_WR_E1, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD10, 0x0},
+	{OP_WR_E1, XCM_REG_WU_DA_CNT_CMD00, 0x2},
+	{OP_WR_E1, XCM_REG_WU_DA_CNT_CMD10, 0x2},
+	{OP_WR_E1, XCM_REG_WU_DA_CNT_UPD_VAL00, 0xff},
+	{OP_WR_E1, XCM_REG_WU_DA_CNT_UPD_VAL10, 0xff},
+#define XCM_PORT0_END           1487
+#define XCM_PORT1_START         1487
+	{OP_WR_E1, XCM_REG_GLB_DEL_ACK_TMR_VAL_1, 0xc8},
+	{OP_WR_E1, XCM_REG_GLB_DEL_ACK_MAX_CNT_1, 0x2},
+	{OP_WR_E1, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD01, 0x0},
+	{OP_WR_E1, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD11, 0x0},
+	{OP_WR_E1, XCM_REG_WU_DA_CNT_CMD01, 0x2},
+	{OP_WR_E1, XCM_REG_WU_DA_CNT_CMD11, 0x2},
+	{OP_WR_E1, XCM_REG_WU_DA_CNT_UPD_VAL01, 0xff},
+	{OP_WR_E1, XCM_REG_WU_DA_CNT_UPD_VAL11, 0xff},
+#define XCM_PORT1_END           1495
+#define XCM_FUNC0_START         1495
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_TMR_VAL_0, 0xc8},
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_MAX_CNT_0, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD10, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD00, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD10, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL00, 0xff},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL10, 0xff},
+	{OP_WR_E1H, XCM_REG_PHYS_QNUM3_0, 0x0},
+#define XCM_FUNC0_END           1504
+#define XCM_FUNC1_START         1504
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_TMR_VAL_1, 0xc8},
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_MAX_CNT_1, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD01, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD11, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD01, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD11, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL01, 0xff},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL11, 0xff},
+	{OP_WR_E1H, XCM_REG_PHYS_QNUM3_1, 0x0},
+#define XCM_FUNC1_END           1513
+#define XCM_FUNC2_START         1513
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_TMR_VAL_0, 0xc8},
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_MAX_CNT_0, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD10, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD00, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD10, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL00, 0xff},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL10, 0xff},
+	{OP_WR_E1H, XCM_REG_PHYS_QNUM3_0, 0x0},
+#define XCM_FUNC2_END           1522
+#define XCM_FUNC3_START         1522
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_TMR_VAL_1, 0xc8},
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_MAX_CNT_1, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD01, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD11, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD01, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD11, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL01, 0xff},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL11, 0xff},
+	{OP_WR_E1H, XCM_REG_PHYS_QNUM3_1, 0x0},
+#define XCM_FUNC3_END           1531
+#define XCM_FUNC4_START         1531
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_TMR_VAL_0, 0xc8},
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_MAX_CNT_0, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD10, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD00, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD10, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL00, 0xff},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL10, 0xff},
+	{OP_WR_E1H, XCM_REG_PHYS_QNUM3_0, 0x0},
+#define XCM_FUNC4_END           1540
+#define XCM_FUNC5_START         1540
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_TMR_VAL_1, 0xc8},
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_MAX_CNT_1, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD01, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD11, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD01, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD11, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL01, 0xff},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL11, 0xff},
+	{OP_WR_E1H, XCM_REG_PHYS_QNUM3_1, 0x0},
+#define XCM_FUNC5_END           1549
+#define XCM_FUNC6_START         1549
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_TMR_VAL_0, 0xc8},
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_MAX_CNT_0, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD10, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD00, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD10, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL00, 0xff},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL10, 0xff},
+	{OP_WR_E1H, XCM_REG_PHYS_QNUM3_0, 0x0},
+#define XCM_FUNC6_END           1558
+#define XCM_FUNC7_START         1558
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_TMR_VAL_1, 0xc8},
+	{OP_WR_E1H, XCM_REG_GLB_DEL_ACK_MAX_CNT_1, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD01, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD11, 0x0},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD01, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_CMD11, 0x2},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL01, 0xff},
+	{OP_WR_E1H, XCM_REG_WU_DA_CNT_UPD_VAL11, 0xff},
+	{OP_WR_E1H, XCM_REG_PHYS_QNUM3_1, 0x0},
+#define XCM_FUNC7_END           1567
+#define XSEM_COMMON_START       1567
 	{OP_RD, XSEM_REG_MSG_NUM_FIC0, 0x0},
 	{OP_RD, XSEM_REG_MSG_NUM_FIC1, 0x0},
 	{OP_RD, XSEM_REG_MSG_NUM_FOC0, 0x0},
@@ -1065,157 +1842,398 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, XSEM_REG_FAST_MEMORY + 0x18040, 0x18},
 	{OP_WR, XSEM_REG_FAST_MEMORY + 0x18080, 0xc},
 	{OP_WR, XSEM_REG_FAST_MEMORY + 0x180c0, 0x66},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x18300, 0x7a120},
+	{OP_WR_ASIC, XSEM_REG_FAST_MEMORY + 0x18300, 0x7a120},
+	{OP_WR_EMUL, XSEM_REG_FAST_MEMORY + 0x18300, 0x138},
+	{OP_WR_FPGA, XSEM_REG_FAST_MEMORY + 0x18300, 0x1388},
 	{OP_WR, XSEM_REG_FAST_MEMORY + 0x183c0, 0x1f4},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x18340, 0x1f4},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x18380, 0x1dcd6500},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x55d8, 0x2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5000, 0x48},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x1020, 0xc8},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x1000, 0x2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5128, 0x92},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x5378, 0x0},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x5380, 0x24d20},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x5428, 0x44d22},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x1518, 0x1},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x1830, 0x0},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x1838, 0x0},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x1820, 0x24d26},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x4ac0, 0x2},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x4ad8, 0x24d28},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x4b08, 0x4},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x1f50, 0x24d2a},
+	{OP_WR_ASIC, XSEM_REG_FAST_MEMORY + 0x18340, 0x1f4},
+	{OP_WR_EMUL, XSEM_REG_FAST_MEMORY + 0x18340, 0x0},
+	{OP_WR_FPGA, XSEM_REG_FAST_MEMORY + 0x18340, 0x5},
+	{OP_WR_EMUL, XSEM_REG_FAST_MEMORY + 0x18380, 0x4c4b4},
+	{OP_WR_ASIC, XSEM_REG_FAST_MEMORY + 0x18380, 0x1dcd6500},
+	{OP_WR_EMUL_E1H, XSEM_REG_FAST_MEMORY + 0x11480, 0x0},
+	{OP_WR_FPGA, XSEM_REG_FAST_MEMORY + 0x18380, 0x4c4b40},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3d00, 0x4},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x11480, 0x1},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3000, 0x48},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x28a8, 0x4},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x1020, 0xc8},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x2080, 0x48},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x1000, 0x2},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x9020, 0xc8},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3128, 0x8e},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x9000, 0x2},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x3368, 0x0},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x21a8, 0x86},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x3370, 0x202ed},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x2000, 0x20},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x3b90, 0x402ef},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x23c8, 0x0},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x1518, 0x1},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x23d0, 0x20321},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x1830, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x2498, 0x40323},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x1838, 0x0},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x2ac8, 0x0},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x1820, 0x202f3},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x2ab8, 0x0},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x4ac0, 0x2},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x3010, 0x1},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x4b00, 0x4},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x4040, 0x10},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x1f50, 0x202f5},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x4000, 0x100327},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x6ac0, 0x2},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x6b00, 0x4},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x83b0, 0x20337},
 	{OP_WR, XSEM_REG_FAST_MEMORY + 0x10800, 0x0},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x10c00, 0x104d2c},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x10c00, 0x1002f7},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x10c00, 0x100339},
 	{OP_WR, XSEM_REG_FAST_MEMORY + 0x10800, 0x1000000},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x10c40, 0x84d3c},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x10c40, 0x80307},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x10c40, 0x80349},
 	{OP_WR, XSEM_REG_FAST_MEMORY + 0x10800, 0x2000000},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x10c60, 0x84d44},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x10800, 0x3000000},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x10c80, 0x84d4c},
-	{OP_ZP, XSEM_REG_INT_TABLE, 0x814d54},
-	{OP_ZP, XSEM_REG_PRAM, 0x35774d75},
-	{OP_ZP, XSEM_REG_PRAM + 0x8000, 0x36525ad3},
-	{OP_ZP, XSEM_REG_PRAM + 0x10000, 0x27266868},
-	{OP_ZP, XSEM_REG_PRAM + 0x18000, 0x5e7232},
-	{OP_ZP, XSEM_REG_PRAM + 0x20000, 0x5e724a},
-	{OP_ZP, XSEM_REG_PRAM + 0x28000, 0x5e7262},
-	{OP_ZP, XSEM_REG_PRAM + 0x30000, 0x5e727a},
-	{OP_ZP, XSEM_REG_PRAM + 0x38000, 0x5e7292},
-#define XSEM_COMMON_END         1000
-#define XSEM_PORT0_START        1000
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x1400, 0xa},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x1450, 0x6},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5388, 0xc},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x5388 + 0x30, 0x272aa},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x55e0, 0x772ac},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5600, 0x7},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x1500, 0x0},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x1508, 0x1},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3020, 0x2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3030, 0x2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3000, 0x2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3010, 0x2},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x3040, 0x0},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3048, 0xc},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x3048 + 0x30, 0x272b3},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x30b8, 0x1},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x4ac8, 0x272b5},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x4b18, 0x42},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x4d28, 0x4},
-#define XSEM_PORT0_END          1019
-#define XSEM_PORT1_START        1019
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x1428, 0xa},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x1468, 0x6},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x53c0, 0xc},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x53c0 + 0x30, 0x272b7},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x5620, 0x772b9},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5640, 0x7},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x1504, 0x0},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x150c, 0x1},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3028, 0x2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3038, 0x2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3008, 0x2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3018, 0x2},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x3044, 0x0},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x3080, 0xc},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x3080 + 0x30, 0x272c0},
-	{OP_WR, XSEM_REG_FAST_MEMORY + 0x30bc, 0x1},
-	{OP_SW, XSEM_REG_FAST_MEMORY + 0x4ad0, 0x272c2},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x4c20, 0x42},
-	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x4d38, 0x4},
-#define XSEM_PORT1_END          1038
-#define CDU_COMMON_START        1038
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x10c60, 0x8030f},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x10c60, 0x80351},
+	{OP_ZP_E1, XSEM_REG_INT_TABLE, 0xab0000},
+	{OP_ZP_E1H, XSEM_REG_INT_TABLE, 0xac0000},
+	{OP_WR_64_E1, XSEM_REG_INT_TABLE + 0x368, 0x130317},
+	{OP_WR_64_E1H, XSEM_REG_INT_TABLE + 0x368, 0x130359},
+	{OP_ZP_E1, XSEM_REG_PRAM, 0xc09e0000},
+	{OP_ZP_E1H, XSEM_REG_PRAM, 0xc3b20000},
+	{OP_WR_64_E1, XSEM_REG_PRAM + 0x1c0c0, 0x47e80319},
+	{OP_WR_64_E1H, XSEM_REG_PRAM + 0x1c8c0, 0x46e8035b},
+#define XSEM_COMMON_END         1671
+#define XSEM_PORT0_START        1671
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3ba0, 0x10},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0xc000, 0xfc},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3c20, 0x1c},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x24a8, 0x10},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x1400, 0xa},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x2528, 0x1c},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x1450, 0x6},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x2608, 0x1c},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3378, 0xfc},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x26e8, 0x1c},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x3b58, 0x0},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x27c8, 0x1c},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x3d10, 0x10031b},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0xa000, 0x28},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x1500, 0x0},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0xa140, 0xc},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x1508, 0x1},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x3000, 0x1},
+	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5020, 0x2},
+	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5030, 0x2},
+	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5000, 0x2},
+	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5010, 0x2},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x5040, 0x0},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x5208, 0x1},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x5048, 0xe},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x6ac8, 0x2035d},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x50b8, 0x1},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x6b10, 0x42},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x4ac8, 0x2032b},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x6d20, 0x4},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x4b10, 0x42},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x4d20, 0x4},
+#define XSEM_PORT0_END          1703
+#define XSEM_PORT1_START        1703
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3be0, 0x10},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0xc3f0, 0xfc},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3c90, 0x1c},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x24e8, 0x10},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x1428, 0xa},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x2598, 0x1c},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x1468, 0x6},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x2678, 0x1c},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x3768, 0xfc},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x2758, 0x1c},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x3b5c, 0x0},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x2838, 0x1c},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x3d50, 0x10032d},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0xa0a0, 0x28},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x1504, 0x0},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0xa170, 0xc},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x150c, 0x1},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x3004, 0x1},
+	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5028, 0x2},
+	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5038, 0x2},
+	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5008, 0x2},
+	{OP_ZR, XSEM_REG_FAST_MEMORY + 0x5018, 0x2},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x5044, 0x0},
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0x520c, 0x1},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x5080, 0xe},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x6ad0, 0x2035f},
+	{OP_WR_E1, XSEM_REG_FAST_MEMORY + 0x50bc, 0x1},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x6c18, 0x42},
+	{OP_SW_E1, XSEM_REG_FAST_MEMORY + 0x4ad0, 0x2033d},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x6d30, 0x4},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x4c18, 0x42},
+	{OP_ZR_E1, XSEM_REG_FAST_MEMORY + 0x4d30, 0x4},
+#define XSEM_PORT1_END          1735
+#define XSEM_FUNC0_START        1735
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0xc7e0, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x28b8, 0x100361},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x5048, 0xe},
+#define XSEM_FUNC0_END          1738
+#define XSEM_FUNC1_START        1738
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0xc7e4, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x28f8, 0x100371},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x5080, 0xe},
+#define XSEM_FUNC1_END          1741
+#define XSEM_FUNC2_START        1741
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0xc7e8, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x2938, 0x100381},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x50b8, 0xe},
+#define XSEM_FUNC2_END          1744
+#define XSEM_FUNC3_START        1744
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0xc7ec, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x2978, 0x100391},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x50f0, 0xe},
+#define XSEM_FUNC3_END          1747
+#define XSEM_FUNC4_START        1747
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0xc7f0, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x29b8, 0x1003a1},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x5128, 0xe},
+#define XSEM_FUNC4_END          1750
+#define XSEM_FUNC5_START        1750
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0xc7f4, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x29f8, 0x1003b1},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x5160, 0xe},
+#define XSEM_FUNC5_END          1753
+#define XSEM_FUNC6_START        1753
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0xc7f8, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x2a38, 0x1003c1},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x5198, 0xe},
+#define XSEM_FUNC6_END          1756
+#define XSEM_FUNC7_START        1756
+	{OP_WR_E1H, XSEM_REG_FAST_MEMORY + 0xc7fc, 0x0},
+	{OP_SW_E1H, XSEM_REG_FAST_MEMORY + 0x2a78, 0x1003d1},
+	{OP_ZR_E1H, XSEM_REG_FAST_MEMORY + 0x51d0, 0xe},
+#define XSEM_FUNC7_END          1759
+#define CDU_COMMON_START        1759
 	{OP_WR, CDU_REG_CDU_CONTROL0, 0x1},
+	{OP_WR_E1H, CDU_REG_MF_MODE, 0x1},
 	{OP_WR, CDU_REG_CDU_CHK_MASK0, 0x3d000},
 	{OP_WR, CDU_REG_CDU_CHK_MASK1, 0x3d},
-	{OP_WB, CDU_REG_L1TT, 0x20072c4},
-	{OP_WB, CDU_REG_MATT, 0x2074c4},
-	{OP_ZR, CDU_REG_MATT + 0x80, 0x20},
-#define CDU_COMMON_END          1044
-#define DMAE_COMMON_START       1044
+	{OP_WB_E1, CDU_REG_L1TT, 0x200033f},
+	{OP_WB_E1H, CDU_REG_L1TT, 0x20003e1},
+	{OP_WB_E1, CDU_REG_MATT, 0x20053f},
+	{OP_WB_E1H, CDU_REG_MATT, 0x2805e1},
+	{OP_ZR_E1, CDU_REG_MATT + 0x80, 0x2},
+	{OP_WB_E1, CDU_REG_MATT + 0x88, 0x6055f},
+	{OP_ZR, CDU_REG_MATT + 0xa0, 0x18},
+#define CDU_COMMON_END          1770
+#define DMAE_COMMON_START       1770
+	{OP_ZR, DMAE_REG_CMD_MEM, 0xe0},
 	{OP_WR, DMAE_REG_CRC16C_INIT, 0x0},
 	{OP_WR, DMAE_REG_CRC16T10_INIT, 0x1},
-	{OP_WR, DMAE_REG_PXP_REQ_INIT_CRD, 0x2},
+	{OP_WR_E1, DMAE_REG_PXP_REQ_INIT_CRD, 0x1},
+	{OP_WR_E1H, DMAE_REG_PXP_REQ_INIT_CRD, 0x2},
 	{OP_WR, DMAE_REG_PCI_IFEN, 0x1},
 	{OP_WR, DMAE_REG_GRC_IFEN, 0x1},
-#define DMAE_COMMON_END         1049
-#define PXP_COMMON_START        1049
-	{OP_SI, PXP_REG_HST_INBOUND_INT + 0x400, 0x574e4},
-	{OP_SI, PXP_REG_HST_INBOUND_INT + 0x420, 0x574e9},
-	{OP_SI, PXP_REG_HST_INBOUND_INT, 0x574ee},
-#define PXP_COMMON_END          1052
-#define CFC_COMMON_START        1052
+#define DMAE_COMMON_END         1777
+#define PXP_COMMON_START        1777
+	{OP_WB_E1, PXP_REG_HST_INBOUND_INT + 0x400, 0x50565},
+	{OP_WB_E1H, PXP_REG_HST_INBOUND_INT + 0x400, 0x50609},
+	{OP_WB_E1, PXP_REG_HST_INBOUND_INT + 0x420, 0x5056a},
+	{OP_WB_E1H, PXP_REG_HST_INBOUND_INT, 0x5060e},
+	{OP_WB_E1, PXP_REG_HST_INBOUND_INT, 0x5056f},
+#define PXP_COMMON_END          1782
+#define CFC_COMMON_START        1782
+	{OP_ZR_E1H, CFC_REG_LINK_LIST, 0x100},
 	{OP_WR, CFC_REG_CONTROL0, 0x10},
 	{OP_WR, CFC_REG_DISABLE_ON_ERROR, 0x3fff},
 	{OP_WR, CFC_REG_LCREQ_WEIGHTS, 0x84924a},
-#define CFC_COMMON_END          1055
-#define HC_COMMON_START         1055
-	{OP_ZR, HC_REG_USTORM_ADDR_FOR_COALESCE, 0x4},
-#define HC_COMMON_END           1056
-#define HC_PORT0_START          1056
-	{OP_WR, HC_REG_CONFIG_0, 0x1080},
-	{OP_ZR, HC_REG_UC_RAM_ADDR_0, 0x2},
-	{OP_WR, HC_REG_ATTN_NUM_P0, 0x10},
-	{OP_WR, HC_REG_LEADING_EDGE_0, 0xffff},
-	{OP_WR, HC_REG_TRAILING_EDGE_0, 0xffff},
-	{OP_WR, HC_REG_AGG_INT_0, 0x0},
-	{OP_WR, HC_REG_ATTN_IDX, 0x0},
-	{OP_ZR, HC_REG_ATTN_BIT, 0x2},
-	{OP_WR, HC_REG_VQID_0, 0x2b5},
-	{OP_WR, HC_REG_PCI_CONFIG_0, 0x0},
-	{OP_ZR, HC_REG_P0_PROD_CONS, 0x4a},
-	{OP_ZR, HC_REG_PBA_COMMAND, 0x2},
-	{OP_WR, HC_REG_INT_MASK, 0x1ffff},
-	{OP_WR, HC_REG_CONFIG_0, 0x1a82},
-	{OP_ZR, HC_REG_STATISTIC_COUNTERS, 0x24},
-	{OP_ZR, HC_REG_STATISTIC_COUNTERS + 0x120, 0x4a},
-	{OP_ZR, HC_REG_STATISTIC_COUNTERS + 0x370, 0x4a},
-	{OP_ZR, HC_REG_STATISTIC_COUNTERS + 0x5c0, 0x4a},
-#define HC_PORT0_END            1074
-#define HC_PORT1_START          1074
-	{OP_WR, HC_REG_CONFIG_1, 0x1080},
-	{OP_ZR, HC_REG_UC_RAM_ADDR_1, 0x2},
-	{OP_WR, HC_REG_ATTN_NUM_P1, 0x10},
-	{OP_WR, HC_REG_LEADING_EDGE_1, 0xffff},
-	{OP_WR, HC_REG_TRAILING_EDGE_1, 0xffff},
-	{OP_WR, HC_REG_AGG_INT_1, 0x0},
-	{OP_WR, HC_REG_ATTN_IDX + 0x4, 0x0},
-	{OP_ZR, HC_REG_ATTN_BIT + 0x8, 0x2},
-	{OP_WR, HC_REG_VQID_1, 0x2b5},
-	{OP_WR, HC_REG_PCI_CONFIG_1, 0x0},
-	{OP_ZR, HC_REG_P1_PROD_CONS, 0x4a},
-	{OP_ZR, HC_REG_PBA_COMMAND + 0x8, 0x2},
-	{OP_WR, HC_REG_INT_MASK + 0x4, 0x1ffff},
-	{OP_WR, HC_REG_CONFIG_1, 0x1a82},
-	{OP_ZR, HC_REG_STATISTIC_COUNTERS + 0x90, 0x24},
-	{OP_ZR, HC_REG_STATISTIC_COUNTERS + 0x248, 0x4a},
-	{OP_ZR, HC_REG_STATISTIC_COUNTERS + 0x498, 0x4a},
-	{OP_ZR, HC_REG_STATISTIC_COUNTERS + 0x6e8, 0x4a},
-#define HC_PORT1_END            1092
-#define PXP2_COMMON_START       1092
-	{OP_WR, PXP2_REG_PGL_CONTROL0, 0xe38324},
+#define CFC_COMMON_END          1786
+#define HC_COMMON_START         1786
+	{OP_ZR_E1, HC_REG_USTORM_ADDR_FOR_COALESCE, 0x4},
+#define HC_COMMON_END           1787
+#define HC_PORT0_START          1787
+	{OP_WR_E1, HC_REG_CONFIG_0, 0x1080},
+	{OP_ZR_E1, HC_REG_UC_RAM_ADDR_0, 0x2},
+	{OP_WR_E1, HC_REG_ATTN_NUM_P0, 0x10},
+	{OP_WR_E1, HC_REG_LEADING_EDGE_0, 0xffff},
+	{OP_WR_E1, HC_REG_TRAILING_EDGE_0, 0xffff},
+	{OP_WR_E1, HC_REG_AGG_INT_0, 0x0},
+	{OP_WR_E1, HC_REG_ATTN_IDX, 0x0},
+	{OP_ZR_E1, HC_REG_ATTN_BIT, 0x2},
+	{OP_WR_E1, HC_REG_VQID_0, 0x2b5},
+	{OP_WR_E1, HC_REG_PCI_CONFIG_0, 0x0},
+	{OP_ZR_E1, HC_REG_P0_PROD_CONS, 0x4a},
+	{OP_WR_E1, HC_REG_INT_MASK, 0x1ffff},
+	{OP_ZR_E1, HC_REG_PBA_COMMAND, 0x2},
+	{OP_WR_E1, HC_REG_CONFIG_0, 0x1a80},
+	{OP_ZR_E1, HC_REG_STATISTIC_COUNTERS, 0x24},
+	{OP_ZR_E1, HC_REG_STATISTIC_COUNTERS + 0x120, 0x4a},
+	{OP_ZR_E1, HC_REG_STATISTIC_COUNTERS + 0x370, 0x4a},
+	{OP_ZR_E1, HC_REG_STATISTIC_COUNTERS + 0x5c0, 0x4a},
+	{OP_ZR_E1, HC_REG_PBA_COMMAND, 0x2},
+#define HC_PORT0_END            1806
+#define HC_PORT1_START          1806
+	{OP_WR_E1, HC_REG_CONFIG_1, 0x1080},
+	{OP_ZR_E1, HC_REG_UC_RAM_ADDR_1, 0x2},
+	{OP_WR_E1, HC_REG_ATTN_NUM_P1, 0x10},
+	{OP_WR_E1, HC_REG_LEADING_EDGE_1, 0xffff},
+	{OP_WR_E1, HC_REG_TRAILING_EDGE_1, 0xffff},
+	{OP_WR_E1, HC_REG_AGG_INT_1, 0x0},
+	{OP_WR_E1, HC_REG_ATTN_IDX + 0x4, 0x0},
+	{OP_ZR_E1, HC_REG_ATTN_BIT + 0x8, 0x2},
+	{OP_WR_E1, HC_REG_VQID_1, 0x2b5},
+	{OP_WR_E1, HC_REG_PCI_CONFIG_1, 0x0},
+	{OP_ZR_E1, HC_REG_P1_PROD_CONS, 0x4a},
+	{OP_WR_E1, HC_REG_INT_MASK + 0x4, 0x1ffff},
+	{OP_ZR_E1, HC_REG_PBA_COMMAND + 0x8, 0x2},
+	{OP_WR_E1, HC_REG_CONFIG_1, 0x1a80},
+	{OP_ZR_E1, HC_REG_STATISTIC_COUNTERS + 0x90, 0x24},
+	{OP_ZR_E1, HC_REG_STATISTIC_COUNTERS + 0x248, 0x4a},
+	{OP_ZR_E1, HC_REG_STATISTIC_COUNTERS + 0x498, 0x4a},
+	{OP_ZR_E1, HC_REG_STATISTIC_COUNTERS + 0x6e8, 0x4a},
+	{OP_ZR_E1, HC_REG_PBA_COMMAND + 0x8, 0x2},
+#define HC_PORT1_END            1825
+#define HC_FUNC0_START          1825
+	{OP_WR_E1H, HC_REG_CONFIG_0, 0x1080},
+	{OP_WR_E1H, HC_REG_FUNC_NUM_P0, 0x0},
+	{OP_WR_E1H, HC_REG_ATTN_NUM_P0, 0x10},
+	{OP_WR_E1H, HC_REG_ATTN_IDX, 0x0},
+	{OP_ZR_E1H, HC_REG_ATTN_BIT, 0x2},
+	{OP_WR_E1H, HC_REG_VQID_0, 0x2b5},
+	{OP_WR_E1H, HC_REG_PCI_CONFIG_0, 0x0},
+	{OP_ZR_E1H, HC_REG_P0_PROD_CONS, 0x4a},
+	{OP_WR_E1H, HC_REG_INT_MASK, 0x1ffff},
+	{OP_ZR_E1H, HC_REG_PBA_COMMAND, 0x2},
+	{OP_WR_E1H, HC_REG_CONFIG_0, 0x1a80},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS, 0x24},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x120, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x370, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x5c0, 0x4a},
+#define HC_FUNC0_END            1840
+#define HC_FUNC1_START          1840
+	{OP_WR_E1H, HC_REG_CONFIG_1, 0x1080},
+	{OP_WR_E1H, HC_REG_FUNC_NUM_P1, 0x1},
+	{OP_WR_E1H, HC_REG_ATTN_NUM_P1, 0x10},
+	{OP_WR_E1H, HC_REG_ATTN_IDX + 0x4, 0x0},
+	{OP_ZR_E1H, HC_REG_ATTN_BIT + 0x8, 0x2},
+	{OP_WR_E1H, HC_REG_VQID_1, 0x2b5},
+	{OP_WR_E1H, HC_REG_PCI_CONFIG_1, 0x0},
+	{OP_ZR_E1H, HC_REG_P1_PROD_CONS, 0x4a},
+	{OP_WR_E1H, HC_REG_INT_MASK + 0x4, 0x1ffff},
+	{OP_ZR_E1H, HC_REG_PBA_COMMAND + 0x8, 0x2},
+	{OP_WR_E1H, HC_REG_CONFIG_1, 0x1a80},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x90, 0x24},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x248, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x498, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x6e8, 0x4a},
+#define HC_FUNC1_END            1855
+#define HC_FUNC2_START          1855
+	{OP_WR_E1H, HC_REG_CONFIG_0, 0x1080},
+	{OP_WR_E1H, HC_REG_FUNC_NUM_P0, 0x2},
+	{OP_WR_E1H, HC_REG_ATTN_NUM_P0, 0x10},
+	{OP_WR_E1H, HC_REG_ATTN_IDX, 0x0},
+	{OP_ZR_E1H, HC_REG_ATTN_BIT, 0x2},
+	{OP_WR_E1H, HC_REG_VQID_0, 0x2b5},
+	{OP_WR_E1H, HC_REG_PCI_CONFIG_0, 0x0},
+	{OP_ZR_E1H, HC_REG_P0_PROD_CONS, 0x4a},
+	{OP_WR_E1H, HC_REG_INT_MASK, 0x1ffff},
+	{OP_ZR_E1H, HC_REG_PBA_COMMAND, 0x2},
+	{OP_WR_E1H, HC_REG_CONFIG_0, 0x1a80},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS, 0x24},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x120, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x370, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x5c0, 0x4a},
+#define HC_FUNC2_END            1870
+#define HC_FUNC3_START          1870
+	{OP_WR_E1H, HC_REG_CONFIG_1, 0x1080},
+	{OP_WR_E1H, HC_REG_FUNC_NUM_P1, 0x3},
+	{OP_WR_E1H, HC_REG_ATTN_NUM_P1, 0x10},
+	{OP_WR_E1H, HC_REG_ATTN_IDX + 0x4, 0x0},
+	{OP_ZR_E1H, HC_REG_ATTN_BIT + 0x8, 0x2},
+	{OP_WR_E1H, HC_REG_VQID_1, 0x2b5},
+	{OP_WR_E1H, HC_REG_PCI_CONFIG_1, 0x0},
+	{OP_ZR_E1H, HC_REG_P1_PROD_CONS, 0x4a},
+	{OP_WR_E1H, HC_REG_INT_MASK + 0x4, 0x1ffff},
+	{OP_ZR_E1H, HC_REG_PBA_COMMAND + 0x8, 0x2},
+	{OP_WR_E1H, HC_REG_CONFIG_1, 0x1a80},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x90, 0x24},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x248, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x498, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x6e8, 0x4a},
+#define HC_FUNC3_END            1885
+#define HC_FUNC4_START          1885
+	{OP_WR_E1H, HC_REG_CONFIG_0, 0x1080},
+	{OP_WR_E1H, HC_REG_FUNC_NUM_P0, 0x4},
+	{OP_WR_E1H, HC_REG_ATTN_NUM_P0, 0x10},
+	{OP_WR_E1H, HC_REG_ATTN_IDX, 0x0},
+	{OP_ZR_E1H, HC_REG_ATTN_BIT, 0x2},
+	{OP_WR_E1H, HC_REG_VQID_0, 0x2b5},
+	{OP_WR_E1H, HC_REG_PCI_CONFIG_0, 0x0},
+	{OP_ZR_E1H, HC_REG_P0_PROD_CONS, 0x4a},
+	{OP_WR_E1H, HC_REG_INT_MASK, 0x1ffff},
+	{OP_ZR_E1H, HC_REG_PBA_COMMAND, 0x2},
+	{OP_WR_E1H, HC_REG_CONFIG_0, 0x1a80},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS, 0x24},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x120, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x370, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x5c0, 0x4a},
+#define HC_FUNC4_END            1900
+#define HC_FUNC5_START          1900
+	{OP_WR_E1H, HC_REG_CONFIG_1, 0x1080},
+	{OP_WR_E1H, HC_REG_FUNC_NUM_P1, 0x5},
+	{OP_WR_E1H, HC_REG_ATTN_NUM_P1, 0x10},
+	{OP_WR_E1H, HC_REG_ATTN_IDX + 0x4, 0x0},
+	{OP_ZR_E1H, HC_REG_ATTN_BIT + 0x8, 0x2},
+	{OP_WR_E1H, HC_REG_VQID_1, 0x2b5},
+	{OP_WR_E1H, HC_REG_PCI_CONFIG_1, 0x0},
+	{OP_ZR_E1H, HC_REG_P1_PROD_CONS, 0x4a},
+	{OP_WR_E1H, HC_REG_INT_MASK + 0x4, 0x1ffff},
+	{OP_ZR_E1H, HC_REG_PBA_COMMAND + 0x8, 0x2},
+	{OP_WR_E1H, HC_REG_CONFIG_1, 0x1a80},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x90, 0x24},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x248, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x498, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x6e8, 0x4a},
+#define HC_FUNC5_END            1915
+#define HC_FUNC6_START          1915
+	{OP_WR_E1H, HC_REG_CONFIG_0, 0x1080},
+	{OP_WR_E1H, HC_REG_FUNC_NUM_P0, 0x6},
+	{OP_WR_E1H, HC_REG_ATTN_NUM_P0, 0x10},
+	{OP_WR_E1H, HC_REG_ATTN_IDX, 0x0},
+	{OP_ZR_E1H, HC_REG_ATTN_BIT, 0x2},
+	{OP_WR_E1H, HC_REG_VQID_0, 0x2b5},
+	{OP_WR_E1H, HC_REG_PCI_CONFIG_0, 0x0},
+	{OP_ZR_E1H, HC_REG_P0_PROD_CONS, 0x4a},
+	{OP_WR_E1H, HC_REG_INT_MASK, 0x1ffff},
+	{OP_ZR_E1H, HC_REG_PBA_COMMAND, 0x2},
+	{OP_WR_E1H, HC_REG_CONFIG_0, 0x1a80},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS, 0x24},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x120, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x370, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x5c0, 0x4a},
+#define HC_FUNC6_END            1930
+#define HC_FUNC7_START          1930
+	{OP_WR_E1H, HC_REG_CONFIG_1, 0x1080},
+	{OP_WR_E1H, HC_REG_FUNC_NUM_P1, 0x7},
+	{OP_WR_E1H, HC_REG_ATTN_NUM_P1, 0x10},
+	{OP_WR_E1H, HC_REG_ATTN_IDX + 0x4, 0x0},
+	{OP_ZR_E1H, HC_REG_ATTN_BIT + 0x8, 0x2},
+	{OP_WR_E1H, HC_REG_VQID_1, 0x2b5},
+	{OP_WR_E1H, HC_REG_PCI_CONFIG_1, 0x0},
+	{OP_ZR_E1H, HC_REG_P1_PROD_CONS, 0x4a},
+	{OP_WR_E1H, HC_REG_INT_MASK + 0x4, 0x1ffff},
+	{OP_ZR_E1H, HC_REG_PBA_COMMAND + 0x8, 0x2},
+	{OP_WR_E1H, HC_REG_CONFIG_1, 0x1a80},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x90, 0x24},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x248, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x498, 0x4a},
+	{OP_ZR_E1H, HC_REG_STATISTIC_COUNTERS + 0x6e8, 0x4a},
+#define HC_FUNC7_END            1945
+#define PXP2_COMMON_START       1945
+	{OP_WR_E1, PXP2_REG_PGL_CONTROL0, 0xe38340},
+	{OP_WR_E1H, PXP2_REG_RQ_DRAM_ALIGN, 0x1},
 	{OP_WR, PXP2_REG_PGL_CONTROL1, 0x3c10},
+	{OP_WR_E1H, PXP2_REG_RQ_ELT_DISABLE, 0x1},
+	{OP_WR_E1H, PXP2_REG_WR_REV_MODE, 0x0},
 	{OP_WR, PXP2_REG_PGL_INT_TSDM_0, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_TSDM_1, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_TSDM_2, 0xffffffff},
@@ -1231,6 +2249,7 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, PXP2_REG_PGL_INT_USDM_5, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_USDM_6, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_USDM_7, 0xffffffff},
+	{OP_WR_E1H, PXP2_REG_PGL_INT_XSDM_1, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_XSDM_2, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_XSDM_3, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_XSDM_4, 0xffffffff},
@@ -1245,9 +2264,11 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, PXP2_REG_PGL_INT_CSDM_5, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_CSDM_6, 0xffffffff},
 	{OP_WR, PXP2_REG_PGL_INT_CSDM_7, 0xffffffff},
-	{OP_WR, PXP2_REG_PGL_INT_XSDM_0, 0xffff5330},
-	{OP_WR, PXP2_REG_PGL_INT_XSDM_1, 0xffff5348},
-	{OP_WR, PXP2_REG_PGL_INT_USDM_0, 0xf0003000},
+	{OP_WR_E1, PXP2_REG_PGL_INT_XSDM_0, 0xffff3330},
+	{OP_WR_E1H, PXP2_REG_PGL_INT_XSDM_0, 0xff802000},
+	{OP_WR_E1, PXP2_REG_PGL_INT_XSDM_1, 0xffff3340},
+	{OP_WR_E1H, PXP2_REG_PGL_INT_USDM_0, 0xf0005000},
+	{OP_WR_E1, PXP2_REG_PGL_INT_USDM_0, 0xf0003000},
 	{OP_WR, PXP2_REG_RD_MAX_BLKS_VQ6, 0x8},
 	{OP_WR, PXP2_REG_RD_MAX_BLKS_VQ9, 0x8},
 	{OP_WR, PXP2_REG_RD_MAX_BLKS_VQ10, 0x8},
@@ -1257,6 +2278,7 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, PXP2_REG_RD_MAX_BLKS_VQ19, 0x4},
 	{OP_WR, PXP2_REG_RD_MAX_BLKS_VQ22, 0x0},
 	{OP_WR, PXP2_REG_RD_START_INIT, 0x1},
+	{OP_WR, PXP2_REG_WR_DMAE_TH, 0x3f},
 	{OP_WR, PXP2_REG_RQ_BW_RD_ADD0, 0x40},
 	{OP_WR, PXP2_REG_PSWRQ_BW_ADD1, 0x1808},
 	{OP_WR, PXP2_REG_PSWRQ_BW_ADD2, 0x803},
@@ -1321,58 +2343,102 @@ static const struct raw_op init_ops[] = {
 	{OP_WR, PXP2_REG_PSWRQ_BW_L2, 0x1004},
 	{OP_WR, PXP2_REG_PSWRQ_BW_RD, 0x106440},
 	{OP_WR, PXP2_REG_PSWRQ_BW_WR, 0x106440},
+	{OP_WR_E1H, PXP2_REG_RQ_ILT_MODE, 0x1},
 	{OP_WR, PXP2_REG_RQ_RBC_DONE, 0x1},
-#define PXP2_COMMON_END         1200
-#define MISC_AEU_COMMON_START   1200
+#define PXP2_COMMON_END         2061
+#define MISC_AEU_COMMON_START   2061
 	{OP_ZR, MISC_REG_AEU_GENERAL_ATTN_0, 0x16},
-#define MISC_AEU_COMMON_END     1201
-#define MISC_AEU_PORT0_START    1201
-	{OP_WR, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0, 0xbf5c0000},
-	{OP_WR, MISC_REG_AEU_ENABLE2_FUNC_0_OUT_0, 0xfff51fef},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE1_NIG_0, 0x55540000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE2_NIG_0, 0x55555555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE3_NIG_0, 0x5555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_NIG_0, 0xf0000000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE1_PXP_0, 0x55540000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE2_PXP_0, 0x55555555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE3_PXP_0, 0x5555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_PXP_0, 0xf0000000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE1_NIG_1, 0x55540000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE2_NIG_1, 0x55555555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE3_NIG_1, 0x5555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_NIG_1, 0xf0000000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE1_PXP_1, 0x0},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE2_PXP_1, 0x10000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE3_PXP_1, 0x5014},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_PXP_1, 0x0},
+	{OP_WR_E1H, MISC_REG_AEU_CLR_LATCH_SIGNAL, 0xc00},
+	{OP_WR_E1H, MISC_REG_AEU_GENERAL_MASK, 0x3},
+#define MISC_AEU_COMMON_END     2080
+#define MISC_AEU_PORT0_START    2080
+	{OP_WR_E1, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0, 0xbf5c0000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0, 0xff5c0000},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE2_FUNC_0_OUT_0, 0xfff51fef},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE2_FUNC_0_OUT_0, 0xfff55fff},
 	{OP_WR, MISC_REG_AEU_ENABLE3_FUNC_0_OUT_0, 0xffff},
-	{OP_WR, MISC_REG_AEU_ENABLE4_FUNC_0_OUT_0, 0x500003e0},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE4_FUNC_0_OUT_0, 0x500003e0},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_0_OUT_0, 0xf00003e0},
 	{OP_WR, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_1, 0x0},
 	{OP_WR, MISC_REG_AEU_ENABLE2_FUNC_0_OUT_1, 0xa000},
 	{OP_ZR, MISC_REG_AEU_ENABLE3_FUNC_0_OUT_1, 0x5},
 	{OP_WR, MISC_REG_AEU_ENABLE4_FUNC_0_OUT_2, 0xfe00000},
-	{OP_ZR, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_3, 0x14},
-	{OP_WR, MISC_REG_AEU_ENABLE1_NIG_0, 0x55540000},
-	{OP_WR, MISC_REG_AEU_ENABLE2_NIG_0, 0x55555555},
-	{OP_WR, MISC_REG_AEU_ENABLE3_NIG_0, 0x5555},
-	{OP_WR, MISC_REG_AEU_ENABLE4_NIG_0, 0x0},
-	{OP_WR, MISC_REG_AEU_ENABLE1_PXP_0, 0x55540000},
-	{OP_WR, MISC_REG_AEU_ENABLE2_PXP_0, 0x55555555},
-	{OP_WR, MISC_REG_AEU_ENABLE3_PXP_0, 0x5555},
-	{OP_WR, MISC_REG_AEU_ENABLE4_PXP_0, 0x0},
-	{OP_WR, MISC_REG_AEU_INVERTER_1_FUNC_0, 0x0},
-	{OP_ZR, MISC_REG_AEU_INVERTER_2_FUNC_0, 0x3},
-	{OP_WR, MISC_REG_AEU_MASK_ATTN_FUNC_0, 0x7},
-#define MISC_AEU_PORT0_END      1221
-#define MISC_AEU_PORT1_START    1221
-	{OP_WR, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0, 0xbf5c0000},
-	{OP_WR, MISC_REG_AEU_ENABLE2_FUNC_1_OUT_0, 0xfff51fef},
+	{OP_ZR_E1, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_3, 0x14},
+	{OP_ZR_E1H, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_3, 0x7},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE1_NIG_0, 0x55540000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_0_OUT_4, 0x400},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE2_NIG_0, 0x55555555},
+	{OP_ZR_E1H, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_5, 0x3},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE3_NIG_0, 0x5555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_0_OUT_5, 0x1000},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE4_NIG_0, 0x0},
+	{OP_ZR_E1H, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_6, 0x3},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE1_PXP_0, 0x55540000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_0_OUT_6, 0x4000},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE2_PXP_0, 0x55555555},
+	{OP_ZR_E1H, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_7, 0x3},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE3_PXP_0, 0x5555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_0_OUT_7, 0x10000},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE4_PXP_0, 0x0},
+	{OP_ZR_E1H, MISC_REG_AEU_INVERTER_1_FUNC_0, 0x4},
+	{OP_WR_E1, MISC_REG_AEU_INVERTER_1_FUNC_0, 0x0},
+	{OP_ZR_E1, MISC_REG_AEU_INVERTER_2_FUNC_0, 0x3},
+	{OP_WR_E1, MISC_REG_AEU_MASK_ATTN_FUNC_0, 0x7},
+#define MISC_AEU_PORT0_END      2112
+#define MISC_AEU_PORT1_START    2112
+	{OP_WR_E1, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0, 0xbf5c0000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0, 0xff5c0000},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE2_FUNC_1_OUT_0, 0xfff51fef},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE2_FUNC_1_OUT_0, 0xfff55fff},
 	{OP_WR, MISC_REG_AEU_ENABLE3_FUNC_1_OUT_0, 0xffff},
-	{OP_WR, MISC_REG_AEU_ENABLE4_FUNC_1_OUT_0, 0x500003e0},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE4_FUNC_1_OUT_0, 0x500003e0},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_1_OUT_0, 0xf00003e0},
 	{OP_WR, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_1, 0x0},
 	{OP_WR, MISC_REG_AEU_ENABLE2_FUNC_1_OUT_1, 0xa000},
 	{OP_ZR, MISC_REG_AEU_ENABLE3_FUNC_1_OUT_1, 0x5},
 	{OP_WR, MISC_REG_AEU_ENABLE4_FUNC_1_OUT_2, 0xfe00000},
-	{OP_ZR, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_3, 0x14},
-	{OP_WR, MISC_REG_AEU_ENABLE1_NIG_1, 0x55540000},
-	{OP_WR, MISC_REG_AEU_ENABLE2_NIG_1, 0x55555555},
-	{OP_WR, MISC_REG_AEU_ENABLE3_NIG_1, 0x5555},
-	{OP_WR, MISC_REG_AEU_ENABLE4_NIG_1, 0x0},
-	{OP_WR, MISC_REG_AEU_ENABLE1_PXP_1, 0x55540000},
-	{OP_WR, MISC_REG_AEU_ENABLE2_PXP_1, 0x55555555},
-	{OP_WR, MISC_REG_AEU_ENABLE3_PXP_1, 0x5555},
-	{OP_WR, MISC_REG_AEU_ENABLE4_PXP_1, 0x0},
-	{OP_WR, MISC_REG_AEU_INVERTER_1_FUNC_1, 0x0},
-	{OP_ZR, MISC_REG_AEU_INVERTER_2_FUNC_1, 0x3},
-	{OP_WR, MISC_REG_AEU_MASK_ATTN_FUNC_1, 0x7}
-#define MISC_AEU_PORT1_END      1241
+	{OP_ZR_E1, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_3, 0x14},
+	{OP_ZR_E1H, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_3, 0x7},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE1_NIG_1, 0x55540000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_1_OUT_4, 0x800},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE2_NIG_1, 0x55555555},
+	{OP_ZR_E1H, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_5, 0x3},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE3_NIG_1, 0x5555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_1_OUT_5, 0x2000},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE4_NIG_1, 0x0},
+	{OP_ZR_E1H, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_6, 0x3},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE1_PXP_1, 0x55540000},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_1_OUT_6, 0x8000},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE2_PXP_1, 0x55555555},
+	{OP_ZR_E1H, MISC_REG_AEU_ENABLE1_FUNC_1_OUT_7, 0x3},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE3_PXP_1, 0x5555},
+	{OP_WR_E1H, MISC_REG_AEU_ENABLE4_FUNC_1_OUT_7, 0x20000},
+	{OP_WR_E1, MISC_REG_AEU_ENABLE4_PXP_1, 0x0},
+	{OP_ZR_E1H, MISC_REG_AEU_INVERTER_1_FUNC_1, 0x4},
+	{OP_WR_E1, MISC_REG_AEU_INVERTER_1_FUNC_1, 0x0},
+	{OP_ZR_E1, MISC_REG_AEU_INVERTER_2_FUNC_1, 0x3},
+	{OP_WR_E1, MISC_REG_AEU_MASK_ATTN_FUNC_1, 0x7},
+#define MISC_AEU_PORT1_END      2144
+
 };
 
-static const u32 init_data[] = {
+static const u32 init_data_e1[] = {
 	0x00010000, 0x000204c0, 0x00030980, 0x00040e40, 0x00051300, 0x000617c0,
 	0x00071c80, 0x00082140, 0x00092600, 0x000a2ac0, 0x000b2f80, 0x000c3440,
 	0x000d3900, 0x000e3dc0, 0x000f4280, 0x00104740, 0x00114c00, 0x001250c0,
@@ -6365,4 +7431,55 @@ static const u32 init_data[] = {
 	0xcccccccc, 0xcccccccc, 0xcccccccc, 0xcccccccc, 0x00002000
 };
 
+static const u32 init_data_e1h[] = {
+};
+
+static const u32 tsem_int_table_data_e1[] = {
+};
+
+static const u32 tsem_pram_data_e1[] = {
+};
+
+static const u32 usem_int_table_data_e1[] = {
+};
+
+static const u32 usem_pram_data_e1[] = {
+};
+
+static const u32 csem_int_table_data_e1[] = {
+};
+
+static const u32 csem_pram_data_e1[] = {
+};
+
+static const u32 xsem_int_table_data_e1[] = {
+};
+
+static const u32 xsem_pram_data_e1[] = {
+};
+
+static const u32 tsem_int_table_data_e1h[] = {
+};
+
+static const u32 tsem_pram_data_e1h[] = {
+};
+
+static const u32 usem_int_table_data_e1h[] = {
+};
+
+static const u32 usem_pram_data_e1h[] = {
+};
+
+static const u32 csem_int_table_data_e1h[] = {
+};
+
+static const u32 csem_pram_data_e1h[] = {
+};
+
+static const u32 xsem_int_table_data_e1h[] = {
+};
+
+static const u32 xsem_pram_data_e1h[] = {
+};
+
 #endif /*__BNX2X_INIT_VALUES_H__*/
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 7b547f0..efa9426 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -137,7 +137,6 @@ static void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val)
 			       PCICFG_VENDOR_ID_OFFSET);
 }
 
-#ifdef BNX2X_IND_RD
 static u32 bnx2x_reg_rd_ind(struct bnx2x *bp, u32 addr)
 {
 	u32 val;
@@ -149,7 +148,6 @@ static u32 bnx2x_reg_rd_ind(struct bnx2x *bp, u32 addr)
 
 	return val;
 }
-#endif
 
 static const u32 dmae_reg_go_c[] = {
 	DMAE_REG_GO_C0, DMAE_REG_GO_C1, DMAE_REG_GO_C2, DMAE_REG_GO_C3,
@@ -169,19 +167,29 @@ static void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae,
 	for (i = 0; i < (sizeof(struct dmae_command)/4); i++) {
 		REG_WR(bp, cmd_offset + i*4, *(((u32 *)dmae) + i));
 
-/*      	DP(NETIF_MSG_DMAE, "DMAE cmd[%d].%d (0x%08x) : 0x%08x\n",
-		   idx, i, cmd_offset + i*4, *(((u32 *)dmae) + i)); */
+		DP(BNX2X_MSG_OFF, "DMAE cmd[%d].%d (0x%08x) : 0x%08x\n",
+		   idx, i, cmd_offset + i*4, *(((u32 *)dmae) + i));
 	}
 	REG_WR(bp, dmae_reg_go_c[idx], 1);
 }
 
-void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr,
-			     u32 dst_addr, u32 len32)
+void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
+		      u32 len32)
 {
-	struct dmae_command *dmae = &bp->dmae;
-	int port = bp->port;
+	struct dmae_command *dmae = &bp->init_dmae;
 	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
-	int timeout = 200;
+	int cnt = 200;
+
+	if (!bp->dmae_ready) {
+		u32 *data = bnx2x_sp(bp, wb_data[0]);
+
+		DP(BNX2X_MSG_OFF, "DMAE is not ready (dst_addr %08x  len32 %d)"
+		   "  using indirect\n", dst_addr, len32);
+		bnx2x_init_ind_wr(bp, dst_addr, data, len32);
+		return;
+	}
+
+	mutex_lock(&bp->dmae_mutex);
 
 	memset(dmae, 0, sizeof(struct dmae_command));
 
@@ -193,7 +201,7 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr,
 #else
 			DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
+			(bp->port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
 	dmae->src_addr_lo = U64_LO(dma_addr);
 	dmae->src_addr_hi = U64_HI(dma_addr);
 	dmae->dst_addr_lo = dst_addr >> 2;
@@ -201,48 +209,62 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr,
 	dmae->len = len32;
 	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
 	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
-	dmae->comp_val = BNX2X_WB_COMP_VAL;
+	dmae->comp_val = DMAE_COMP_VAL;
 
-/*
-	DP(NETIF_MSG_DMAE, "dmae: opcode 0x%08x\n"
+	DP(BNX2X_MSG_OFF, "dmae: opcode 0x%08x\n"
 	   DP_LEVEL "src_addr  [%x:%08x]  len [%d *4]  "
 		    "dst_addr [%x:%08x (%08x)]\n"
 	   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
 	   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
 	   dmae->len, dmae->dst_addr_hi, dmae->dst_addr_lo, dst_addr,
 	   dmae->comp_addr_hi, dmae->comp_addr_lo, dmae->comp_val);
-*/
-/*
-	DP(NETIF_MSG_DMAE, "data [0x%08x 0x%08x 0x%08x 0x%08x]\n",
+	DP(BNX2X_MSG_OFF, "data [0x%08x 0x%08x 0x%08x 0x%08x]\n",
 	   bp->slowpath->wb_data[0], bp->slowpath->wb_data[1],
 	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
-*/
 
 	*wb_comp = 0;
 
-	bnx2x_post_dmae(bp, dmae, port * 8);
+	bnx2x_post_dmae(bp, dmae, (bp->port)*MAX_DMAE_C_PER_PORT);
 
 	udelay(5);
-	/* adjust timeout for emulation/FPGA */
-	if (CHIP_REV_IS_SLOW(bp))
-		timeout *= 100;
-	while (*wb_comp != BNX2X_WB_COMP_VAL) {
-/*      	DP(NETIF_MSG_DMAE, "wb_comp 0x%08x\n", *wb_comp); */
-		udelay(5);
-		if (!timeout) {
+
+	while (*wb_comp != DMAE_COMP_VAL) {
+		DP(BNX2X_MSG_OFF, "wb_comp 0x%08x\n", *wb_comp);
+
+		/* adjust delay for emulation/FPGA */
+		if (CHIP_REV_IS_SLOW(bp))
+			msleep(100);
+		else
+			udelay(5);
+
+		if (!cnt) {
 			BNX2X_ERR("dmae timeout!\n");
 			break;
 		}
-		timeout--;
+		cnt--;
 	}
+
+	mutex_unlock(&bp->dmae_mutex);
 }
 
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 {
-	struct dmae_command *dmae = &bp->dmae;
-	int port = bp->port;
+	struct dmae_command *dmae = &bp->init_dmae;
 	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
-	int timeout = 200;
+	int cnt = 200;
+
+	if (!bp->dmae_ready) {
+		u32 *data = bnx2x_sp(bp, wb_data[0]);
+		int i;
+
+		DP(BNX2X_MSG_OFF, "DMAE is not ready (src_addr %08x  len32 %d)"
+		   "  using indirect\n", src_addr, len32);
+		for (i = 0; i < len32; i++)
+			data[i] = bnx2x_reg_rd_ind(bp, src_addr + i*4);
+		return;
+	}
+
+	mutex_lock(&bp->dmae_mutex);
 
 	memset(bnx2x_sp(bp, wb_data[0]), 0, sizeof(u32) * 4);
 	memset(dmae, 0, sizeof(struct dmae_command));
@@ -255,7 +277,7 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 #else
 			DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
+			(bp->port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
 	dmae->src_addr_lo = src_addr >> 2;
 	dmae->src_addr_hi = 0;
 	dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_data));
@@ -263,38 +285,64 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 	dmae->len = len32;
 	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
 	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
-	dmae->comp_val = BNX2X_WB_COMP_VAL;
+	dmae->comp_val = DMAE_COMP_VAL;
 
-/*
-	DP(NETIF_MSG_DMAE, "dmae: opcode 0x%08x\n"
+	DP(BNX2X_MSG_OFF, "dmae: opcode 0x%08x\n"
 	   DP_LEVEL "src_addr  [%x:%08x]  len [%d *4]  "
 		    "dst_addr [%x:%08x (%08x)]\n"
 	   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
 	   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
 	   dmae->len, dmae->dst_addr_hi, dmae->dst_addr_lo, src_addr,
 	   dmae->comp_addr_hi, dmae->comp_addr_lo, dmae->comp_val);
-*/
 
 	*wb_comp = 0;
 
-	bnx2x_post_dmae(bp, dmae, port * 8);
+	bnx2x_post_dmae(bp, dmae, (bp->port)*MAX_DMAE_C_PER_PORT);
 
 	udelay(5);
-	while (*wb_comp != BNX2X_WB_COMP_VAL) {
-		udelay(5);
-		if (!timeout) {
+
+	while (*wb_comp != DMAE_COMP_VAL) {
+
+		/* adjust delay for emulation/FPGA */
+		if (CHIP_REV_IS_SLOW(bp))
+			msleep(100);
+		else
+			udelay(5);
+
+		if (!cnt) {
 			BNX2X_ERR("dmae timeout!\n");
 			break;
 		}
-		timeout--;
+		cnt--;
 	}
-/*
-	DP(NETIF_MSG_DMAE, "data [0x%08x 0x%08x 0x%08x 0x%08x]\n",
+	DP(BNX2X_MSG_OFF, "data [0x%08x 0x%08x 0x%08x 0x%08x]\n",
 	   bp->slowpath->wb_data[0], bp->slowpath->wb_data[1],
 	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
-*/
+
+	mutex_unlock(&bp->dmae_mutex);
+}
+
+/* used only for slowpath so not inlined */
+static void bnx2x_wb_wr(struct bnx2x *bp, int reg, u32 val_hi, u32 val_lo)
+{
+	u32 wb_write[2];
+
+	wb_write[0] = val_hi;
+	wb_write[1] = val_lo;
+	REG_WR_DMAE(bp, reg, wb_write, 2);
 }
 
+#ifdef USE_WB_RD
+static u64 bnx2x_wb_rd(struct bnx2x *bp, int reg)
+{
+	u32 wb_data[2];
+
+	REG_RD_DMAE(bp, reg, wb_data, 2);
+
+	return HILO_U64(wb_data[0], wb_data[1]);
+}
+#endif
+
 static int bnx2x_mc_assert(struct bnx2x *bp)
 {
 	int i, j, rc = 0;
@@ -3438,17 +3486,12 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	int count, i;
 	u32 val = 0;
 
-	switch (CHIP_REV(bp)) {
-	case CHIP_REV_EMUL:
-		factor = 200;
-		break;
-	case CHIP_REV_FPGA:
+	if (CHIP_REV_IS_FPGA(bp))
 		factor = 120;
-		break;
-	default:
+	else if (CHIP_REV_IS_EMUL(bp))
+		factor = 200;
+	else
 		factor = 1;
-		break;
-	}
 
 	DP(NETIF_MSG_HW, "start part1\n");
 
@@ -3777,10 +3820,14 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		bnx2x_init_block(bp, USDM_COMMON_START, USDM_COMMON_END);
 		bnx2x_init_block(bp, XSDM_COMMON_START, XSDM_COMMON_END);
 
-		bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE);
-		bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE);
-		bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE);
-		bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE);
+		bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR, 0,
+				STORM_INTMEM_SIZE_E1);
+		bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR, 0,
+				STORM_INTMEM_SIZE_E1);
+		bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR, 0,
+				STORM_INTMEM_SIZE_E1);
+		bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0,
+				STORM_INTMEM_SIZE_E1);
 
 		bnx2x_init_block(bp, TSEM_COMMON_START, TSEM_COMMON_END);
 		bnx2x_init_block(bp, USEM_COMMON_START, USEM_COMMON_END);
@@ -3990,8 +4037,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 #endif
 	/* Port DQ comes here */
 	/* Port BRB1 comes here */
-	bnx2x_init_block(bp, func ? PRS_PORT1_START : PRS_PORT0_START,
-			     func ? PRS_PORT1_END : PRS_PORT0_END);
+	/* Port PRS comes here */
 	/* Port TSDM comes here */
 	/* Port CSDM comes here */
 	/* Port USDM comes here */
@@ -7264,12 +7310,6 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 
 	bnx2x_get_hwinfo(bp);
 
-	if (CHIP_REV(bp) == CHIP_REV_FPGA) {
-		printk(KERN_ERR PFX "FPGA detected. MCP disabled,"
-		       " will only init first device\n");
-		onefunc = 1;
-		nomcp = 1;
-	}
 
 	if (nomcp) {
 		printk(KERN_ERR PFX "MCP disabled, will only"
-- 
1.5.3.2




