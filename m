From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 02/13] bnx2x: parity recovery flow enhancement
Date: Sun, 2 Dec 2012 16:05:46 +0200
Message-ID: <1354457157-4730-3-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Barak Witkowski" <barak@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2500 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084Ab2LBOFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:04 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

Parity recovery was enhanced in order to handle a few more corner cases.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   33 +++++++++++++--------
 1 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 5a22e19..62fcf0f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8720,7 +8720,8 @@ static void bnx2x_reset_mcp_prep(struct bnx2x *bp, u32 *magic_val)
 
 	/* Get shmem offset */
 	shmem = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
-	validity_offset = offsetof(struct shmem_region, validity_map[0]);
+	validity_offset =
+		offsetof(struct shmem_region, validity_map[BP_PORT(bp)]);
 
 	/* Clear validity map flags */
 	if (shmem > 0)
@@ -8813,7 +8814,11 @@ static void bnx2x_process_kill_chip_reset(struct bnx2x *bp, bool global)
 		MISC_REGISTERS_RESET_REG_2_RST_MCP_N_RESET_CMN_CPU |
 		MISC_REGISTERS_RESET_REG_2_RST_MCP_N_RESET_CMN_CORE;
 
-	/* Don't reset the following blocks */
+	/* Don't reset the following blocks.
+	 * Important: per port blocks (such as EMAC, BMAC, UMAC) can't be
+	 *            reset, as in 4 port device they might still be owned
+	 *            by the MCP (there is only one leader per path).
+	 */
 	not_reset_mask1 =
 		MISC_REGISTERS_RESET_REG_1_RST_HC |
 		MISC_REGISTERS_RESET_REG_1_RST_PXPV |
@@ -8829,19 +8834,19 @@ static void bnx2x_process_kill_chip_reset(struct bnx2x *bp, bool global)
 		MISC_REGISTERS_RESET_REG_2_RST_MCP_N_RESET_REG_HARD_CORE |
 		MISC_REGISTERS_RESET_REG_2_RST_MCP_N_HARD_CORE_RST_B |
 		MISC_REGISTERS_RESET_REG_2_RST_ATC |
-		MISC_REGISTERS_RESET_REG_2_PGLC;
+		MISC_REGISTERS_RESET_REG_2_PGLC |
+		MISC_REGISTERS_RESET_REG_2_RST_BMAC0 |
+		MISC_REGISTERS_RESET_REG_2_RST_BMAC1 |
+		MISC_REGISTERS_RESET_REG_2_RST_EMAC0 |
+		MISC_REGISTERS_RESET_REG_2_RST_EMAC1 |
+		MISC_REGISTERS_RESET_REG_2_UMAC0 |
+		MISC_REGISTERS_RESET_REG_2_UMAC1;
 
 	/*
 	 * Keep the following blocks in reset:
 	 *  - all xxMACs are handled by the bnx2x_link code.
 	 */
 	stay_reset2 =
-		MISC_REGISTERS_RESET_REG_2_RST_BMAC0 |
-		MISC_REGISTERS_RESET_REG_2_RST_BMAC1 |
-		MISC_REGISTERS_RESET_REG_2_RST_EMAC0 |
-		MISC_REGISTERS_RESET_REG_2_RST_EMAC1 |
-		MISC_REGISTERS_RESET_REG_2_UMAC0 |
-		MISC_REGISTERS_RESET_REG_2_UMAC1 |
 		MISC_REGISTERS_RESET_REG_2_XMAC |
 		MISC_REGISTERS_RESET_REG_2_XMAC_SOFT;
 
@@ -8931,6 +8936,7 @@ static int bnx2x_process_kill(struct bnx2x *bp, bool global)
 	int cnt = 1000;
 	u32 val = 0;
 	u32 sr_cnt, blk_cnt, port_is_idle_0, port_is_idle_1, pgl_exp_rom2;
+		u32 tags_63_32 = 0;
 
 
 	/* Empty the Tetris buffer, wait for 1s */
@@ -8940,10 +8946,14 @@ static int bnx2x_process_kill(struct bnx2x *bp, bool global)
 		port_is_idle_0 = REG_RD(bp, PXP2_REG_RD_PORT_IS_IDLE_0);
 		port_is_idle_1 = REG_RD(bp, PXP2_REG_RD_PORT_IS_IDLE_1);
 		pgl_exp_rom2 = REG_RD(bp, PXP2_REG_PGL_EXP_ROM2);
+		if (CHIP_IS_E3(bp))
+			tags_63_32 = REG_RD(bp, PGLUE_B_REG_TAGS_63_32);
+
 		if ((sr_cnt == 0x7e) && (blk_cnt == 0xa0) &&
 		    ((port_is_idle_0 & 0x1) == 0x1) &&
 		    ((port_is_idle_1 & 0x1) == 0x1) &&
-		    (pgl_exp_rom2 == 0xffffffff))
+		    (pgl_exp_rom2 == 0xffffffff) &&
+		    (!CHIP_IS_E3(bp) || (tags_63_32 == 0xffffffff)))
 			break;
 		usleep_range(1000, 1000);
 	} while (cnt-- > 0);
@@ -9000,9 +9010,6 @@ static int bnx2x_process_kill(struct bnx2x *bp, bool global)
 
 	/* TBD: Add resetting the NO_MCP mode DB here */
 
-	/* PXP */
-	bnx2x_pxp_prep(bp);
-
 	/* Open the gates #2, #3 and #4 */
 	bnx2x_set_234_gates(bp, false);
 
-- 
1.7.1
