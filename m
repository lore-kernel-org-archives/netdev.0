From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 08/18] bnx2x: Using DMA engine
Date: Mon, 02 Mar 2009 19:59:52 +0200
Message-ID: <1236016793.7723.79.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2320 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756120AbZCBSBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 08/18] bnx2x: Using DMA engine

Using DMA engine (DMAE) to initialize large consecutive memories in the chip

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_init.h |   36 +++++++++++++++++---------------
 drivers/net/bnx2x_main.c |   51 ++++++++++-----------------------------------
 2 files changed, 31 insertions(+), 56 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 8af2757..5362d5a 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -22,12 +22,15 @@
 #define INIT_ASIC			0x4
 #define INIT_HARDWARE			0x7
 
-#define STORM_INTMEM_SIZE_E1		(0x5800 / 4)
-#define STORM_INTMEM_SIZE_E1H		(0x10000 / 4)
-#define TSTORM_INTMEM_ADDR		0x1a0000
-#define CSTORM_INTMEM_ADDR		0x220000
-#define XSTORM_INTMEM_ADDR		0x2a0000
-#define USTORM_INTMEM_ADDR		0x320000
+#define TSTORM_INTMEM_ADDR		TSEM_REG_FAST_MEMORY
+#define CSTORM_INTMEM_ADDR		CSEM_REG_FAST_MEMORY
+#define XSTORM_INTMEM_ADDR		XSEM_REG_FAST_MEMORY
+#define USTORM_INTMEM_ADDR		USEM_REG_FAST_MEMORY
+/* RAM0 size in bytes */
+#define STORM_INTMEM_SIZE_E1		0x5800
+#define STORM_INTMEM_SIZE_E1H		0x10000
+#define STORM_INTMEM_SIZE(bp)	((CHIP_IS_E1H(bp) ? STORM_INTMEM_SIZE_E1H : \
+						    STORM_INTMEM_SIZE_E1) / 4)
 
 
 /* Init operation types and structures */
@@ -150,7 +153,6 @@ static void bnx2x_init_ind_wr(struct bnx2x *bp, u32 addr, const u32 *data,
 
 static void bnx2x_write_big_buf(struct bnx2x *bp, u32 addr, u32 len)
 {
-#ifdef USE_DMAE
 	int offset = 0;
 
 	if (bp->dmae_ready) {
@@ -164,21 +166,21 @@ static void bnx2x_write_big_buf(struct bnx2x *bp, u32 addr, u32 len)
 				 addr + offset, len);
 	} else
 		bnx2x_init_str_wr(bp, addr, bp->gunzip_buf, len);
-#else
-	bnx2x_init_str_wr(bp, addr, bp->gunzip_buf, len);
-#endif
 }
 
 static void bnx2x_init_fill(struct bnx2x *bp, u32 addr, int fill, u32 len)
 {
-	if ((len * 4) > FW_BUF_SIZE) {
-		BNX2X_ERR("LARGE DMAE OPERATION ! addr 0x%x  len 0x%x\n",
-			  addr, len*4);
-		return;
-	}
-	memset(bp->gunzip_buf, fill, len * 4);
+	u32 buf_len = (((len * 4) > FW_BUF_SIZE) ? FW_BUF_SIZE : (len * 4));
+	u32 buf_len32 = buf_len / 4;
+	int i;
 
-	bnx2x_write_big_buf(bp, addr, len);
+	memset(bp->gunzip_buf, fill, buf_len);
+
+	for (i = 0; i < len; i += buf_len32) {
+		u32 cur_len = min(buf_len32, len - i);
+
+		bnx2x_write_big_buf(bp, addr + i * 4, cur_len);
+	}
 }
 
 static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr, const u32 *data,
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 46e2492..3ef24b9 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4223,10 +4223,10 @@ static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
 {
 	int port = BP_PORT(bp);
 
-	bnx2x_init_fill(bp, BAR_USTRORM_INTMEM +
+	bnx2x_init_fill(bp, USTORM_INTMEM_ADDR +
 			USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
 			sizeof(struct ustorm_status_block)/4);
-	bnx2x_init_fill(bp, BAR_CSTRORM_INTMEM +
+	bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR +
 			CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
 			sizeof(struct cstorm_status_block)/4);
 }
@@ -4280,18 +4280,18 @@ static void bnx2x_zero_def_sb(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
 
-	bnx2x_init_fill(bp, BAR_USTRORM_INTMEM +
+	bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR +
+			TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
+			sizeof(struct tstorm_def_status_block)/4);
+	bnx2x_init_fill(bp, USTORM_INTMEM_ADDR +
 			USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
 			sizeof(struct ustorm_def_status_block)/4);
-	bnx2x_init_fill(bp, BAR_CSTRORM_INTMEM +
+	bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR +
 			CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
 			sizeof(struct cstorm_def_status_block)/4);
-	bnx2x_init_fill(bp, BAR_XSTRORM_INTMEM +
+	bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR +
 			XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
 			sizeof(struct xstorm_def_status_block)/4);
-	bnx2x_init_fill(bp, BAR_TSTRORM_INTMEM +
-			TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
-			sizeof(struct tstorm_def_status_block)/4);
 }
 
 static void bnx2x_init_def_sb(struct bnx2x *bp,
@@ -5615,37 +5615,10 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_init_block(bp, USDM_COMMON_START, USDM_COMMON_END);
 	bnx2x_init_block(bp, XSDM_COMMON_START, XSDM_COMMON_END);
 
-	if (CHIP_IS_E1H(bp)) {
-		bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR, 0,
-				STORM_INTMEM_SIZE_E1H/2);
-		bnx2x_init_fill(bp,
-				TSTORM_INTMEM_ADDR + STORM_INTMEM_SIZE_E1H/2,
-				0, STORM_INTMEM_SIZE_E1H/2);
-		bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR, 0,
-				STORM_INTMEM_SIZE_E1H/2);
-		bnx2x_init_fill(bp,
-				CSTORM_INTMEM_ADDR + STORM_INTMEM_SIZE_E1H/2,
-				0, STORM_INTMEM_SIZE_E1H/2);
-		bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR, 0,
-				STORM_INTMEM_SIZE_E1H/2);
-		bnx2x_init_fill(bp,
-				XSTORM_INTMEM_ADDR + STORM_INTMEM_SIZE_E1H/2,
-				0, STORM_INTMEM_SIZE_E1H/2);
-		bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0,
-				STORM_INTMEM_SIZE_E1H/2);
-		bnx2x_init_fill(bp,
-				USTORM_INTMEM_ADDR + STORM_INTMEM_SIZE_E1H/2,
-				0, STORM_INTMEM_SIZE_E1H/2);
-	} else { /* E1 */
-		bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR, 0,
-				STORM_INTMEM_SIZE_E1);
-		bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR, 0,
-				STORM_INTMEM_SIZE_E1);
-		bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR, 0,
-				STORM_INTMEM_SIZE_E1);
-		bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0,
-				STORM_INTMEM_SIZE_E1);
-	}
+	bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE(bp));
+	bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE(bp));
+	bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE(bp));
+	bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE(bp));
 
 	bnx2x_init_block(bp, TSEM_COMMON_START, TSEM_COMMON_END);
 	bnx2x_init_block(bp, USEM_COMMON_START, USEM_COMMON_END);
-- 
1.5.4.3




