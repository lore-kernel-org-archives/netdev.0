From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 02/10] bnx2x: Removing indirect register access
Date: Thu, 26 Jan 2012 18:01:46 +0200
Message-ID: <1327593714-18358-3-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1867 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752694Ab2AZQBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:01:53 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In virtualized environments indirect access to the device may not be supported
(depending on the Hypervisor type). Indirect device access was used since in
some harware contexts (i.e. certain chipset and BIOS) every access the driver
makes across the pci is followed by a BIOS initiated Zero Length Read to the
same address. When accessing widebus registers this zero length read corrupts
the serialization of the read/write sequence resulting with errors. To avoid
this problem widebus registers are always accessed via the DMAE or the indirect
interface. However, the 57712x and 578xx devices intercept the zero length read
and so using the indirect interface with these devices is not necessary. Since
PDA is only supported for 57712x and 578xx the indirect access to device was
restricted to 57710 and 57711x.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h   |   53 +++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   24 ++++++---
 2 files changed, 47 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
index 7ec1724..f05ee2f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
@@ -69,12 +69,12 @@ static void bnx2x_write_big_buf(struct bnx2x *bp, u32 addr, u32 len,
 {
 	if (bp->dmae_ready)
 		bnx2x_write_dmae_phys_len(bp, GUNZIP_PHYS(bp), addr, len);
-	else if (wb)
-		/*
-		 * Wide bus registers with no dmae need to be written
-		 * using indirect write.
-		 */
+
+	/* in E1 chips BIOS initiated ZLR may interrupt widebus writes */
+	else if (wb && CHIP_IS_E1(bp))
 		bnx2x_init_ind_wr(bp, addr, GUNZIP_BUF(bp), len);
+
+	/* in later chips PXP root complex handles BIOS ZLR w/o interrupting */
 	else
 		bnx2x_init_str_wr(bp, addr, GUNZIP_BUF(bp), len);
 }
@@ -99,8 +99,14 @@ static void bnx2x_write_big_buf_wb(struct bnx2x *bp, u32 addr, u32 len)
 {
 	if (bp->dmae_ready)
 		bnx2x_write_dmae_phys_len(bp, GUNZIP_PHYS(bp), addr, len);
-	else
+
+	/* in E1 chips BIOS initiated ZLR may interrupt widebus writes */
+	else if (CHIP_IS_E1(bp))
 		bnx2x_init_ind_wr(bp, addr, GUNZIP_BUF(bp), len);
+
+	/* in later chips PXP root complex handles BIOS ZLR w/o interrupting */
+	else
+		bnx2x_init_str_wr(bp, addr, GUNZIP_BUF(bp), len);
 }
 
 static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr,
@@ -177,8 +183,14 @@ static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr,
 {
 	if (bp->dmae_ready)
 		VIRT_WR_DMAE_LEN(bp, data, addr, len, 0);
-	else
+
+	/* in E1 chips BIOS initiated ZLR may interrupt widebus writes */
+	else if (CHIP_IS_E1(bp))
 		bnx2x_init_ind_wr(bp, addr, data, len);
+
+	/* in later chips PXP root complex handles BIOS ZLR w/o interrupting */
+	else
+		bnx2x_init_str_wr(bp, addr, data, len);
 }
 
 static void bnx2x_wr_64(struct bnx2x *bp, u32 reg, u32 val_lo,
@@ -840,25 +852,15 @@ static void bnx2x_qm_init_cid_count(struct bnx2x *bp, int qm_cid_count,
 	}
 }
 
-static void bnx2x_qm_set_ptr_table(struct bnx2x *bp, int qm_cid_count)
+static void bnx2x_qm_set_ptr_table(struct bnx2x *bp, int qm_cid_count,
+				   u32 base_reg, u32 reg)
 {
 	int i;
-	u32 wb_data[2];
-
-	wb_data[0] = wb_data[1] = 0;
-
+	u32 wb_data[2] = {0, 0};
 	for (i = 0; i < 4 * QM_QUEUES_PER_FUNC; i++) {
-		REG_WR(bp, QM_REG_BASEADDR + i*4,
+		REG_WR(bp, base_reg + i*4,
 		       qm_cid_count * 4 * (i % QM_QUEUES_PER_FUNC));
-		bnx2x_init_ind_wr(bp, QM_REG_PTRTBL + i*8,
-				  wb_data, 2);
-
-		if (CHIP_IS_E1H(bp)) {
-			REG_WR(bp, QM_REG_BASEADDR_EXT_A + i*4,
-			       qm_cid_count * 4 * (i % QM_QUEUES_PER_FUNC));
-			bnx2x_init_ind_wr(bp, QM_REG_PTRTBL_EXT_A + i*8,
-					  wb_data, 2);
-		}
+		bnx2x_init_wr_wb(bp, reg + i*8,	 wb_data, 2);
 	}
 }
 
@@ -873,7 +875,12 @@ static void bnx2x_qm_init_ptr_table(struct bnx2x *bp, int qm_cid_count,
 	case INITOP_INIT:
 		/* set in the init-value array */
 	case INITOP_SET:
-		bnx2x_qm_set_ptr_table(bp, qm_cid_count);
+		bnx2x_qm_set_ptr_table(bp, qm_cid_count,
+				       QM_REG_BASEADDR, QM_REG_PTRTBL);
+		if (CHIP_IS_E1H(bp))
+			bnx2x_qm_set_ptr_table(bp, qm_cid_count,
+					       QM_REG_BASEADDR_EXT_A,
+					       QM_REG_PTRTBL_EXT_A);
 		break;
 	case INITOP_CLEAR:
 		break;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1e3f978..e56b832 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -498,9 +498,13 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 	if (!bp->dmae_ready) {
 		u32 *data = bnx2x_sp(bp, wb_data[0]);
 
-		DP(BNX2X_MSG_OFF, "DMAE is not ready (dst_addr %08x  len32 %d)"
-		   "  using indirect\n", dst_addr, len32);
-		bnx2x_init_ind_wr(bp, dst_addr, data, len32);
+		DP(BNX2X_MSG_OFF,
+		   "DMAE is not ready (dst_addr %08x len32 %d) using indirect\n",
+		   dst_addr, len32);
+		if (CHIP_IS_E1(bp))
+			bnx2x_init_ind_wr(bp, dst_addr, data, len32);
+		else
+			bnx2x_init_str_wr(bp, dst_addr, data, len32);
 		return;
 	}
 
@@ -528,10 +532,16 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 		u32 *data = bnx2x_sp(bp, wb_data[0]);
 		int i;
 
-		DP(BNX2X_MSG_OFF, "DMAE is not ready (src_addr %08x  len32 %d)"
-		   "  using indirect\n", src_addr, len32);
-		for (i = 0; i < len32; i++)
-			data[i] = bnx2x_reg_rd_ind(bp, src_addr + i*4);
+		if (CHIP_IS_E1(bp)) {
+			DP(BNX2X_MSG_OFF,
+			   "DMAE is not ready (src_addr %08x len32 %d) using indirect\n",
+			   src_addr, len32);
+			for (i = 0; i < len32; i++)
+				data[i] = bnx2x_reg_rd_ind(bp, src_addr + i*4);
+		} else
+			for (i = 0; i < len32; i++)
+				data[i] = REG_RD(bp, src_addr + i*4);
+
 		return;
 	}
 
-- 
1.7.1
