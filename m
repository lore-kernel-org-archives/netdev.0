From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next 2/3] bnx2x: prevent false parity error in MSI-X
 memory of HC block
Date: Tue, 19 Oct 2010 17:13:09 +0200
Message-ID: <1287501189.740.42.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1282 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312Ab0JSPaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 11:30:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   28 +++++++++++++++++++++++++++-
 drivers/net/bnx2x/bnx2x_reg.h  |    6 +++++-
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 3f49b55..f22e283 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -5457,7 +5457,8 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	struct bnx2x_ilt *ilt = BP_ILT(bp);
 	u16 cdu_ilt_start;
 	u32 addr, val;
-	int i;
+	u32 main_mem_base, main_mem_size, main_mem_prty_clr;
+	int i, main_mem_width;
 
 	DP(BNX2X_MSG_MCP, "starting func init  func %d\n", func);
 
@@ -5706,6 +5707,31 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	bnx2x_init_block(bp, MCP_BLOCK, FUNC0_STAGE + func);
 	bnx2x_init_block(bp, DMAE_BLOCK, FUNC0_STAGE + func);
 
+	if (CHIP_IS_E1x(bp)) {
+		main_mem_size = HC_REG_MAIN_MEMORY_SIZE / 2; /*dwords*/
+		main_mem_base = HC_REG_MAIN_MEMORY +
+				BP_PORT(bp) * (main_mem_size * 4);
+		main_mem_prty_clr = HC_REG_HC_PRTY_STS_CLR;
+		main_mem_width = 8;
+
+		val = REG_RD(bp, main_mem_prty_clr);
+		if (val)
+			DP(BNX2X_MSG_MCP, "Hmmm... Parity errors in HC "
+					  "block during "
+					  "function init (0x%x)!\n", val);
+
+		/* Clear "false" parity errors in MSI-X table */
+		for (i = main_mem_base;
+		     i < main_mem_base + main_mem_size * 4;
+		     i += main_mem_width) {
+			bnx2x_read_dmae(bp, i, main_mem_width / 4);
+			bnx2x_write_dmae(bp, bnx2x_sp_mapping(bp, wb_data),
+					 i, main_mem_width / 4);
+		}
+		/* Clear HC parity attention */
+		REG_RD(bp, main_mem_prty_clr);
+	}
+
 	bnx2x_phy_probe(&bp->link_params);
 
 	return 0;
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 18a8628..1cefe48 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -800,9 +800,13 @@
 #define HC_REG_HC_PRTY_MASK					 0x1080a0
 /* [R 3] Parity register #0 read */
 #define HC_REG_HC_PRTY_STS					 0x108094
-#define HC_REG_INT_MASK 					 0x108108
+/* [RC 3] Parity register #0 read clear */
+#define HC_REG_HC_PRTY_STS_CLR					 0x108098
+#define HC_REG_INT_MASK						 0x108108
 #define HC_REG_LEADING_EDGE_0					 0x108040
 #define HC_REG_LEADING_EDGE_1					 0x108048
+#define HC_REG_MAIN_MEMORY					 0x108800
+#define HC_REG_MAIN_MEMORY_SIZE					 152
 #define HC_REG_P0_PROD_CONS					 0x108200
 #define HC_REG_P1_PROD_CONS					 0x108400
 #define HC_REG_PBA_COMMAND					 0x108140
-- 
1.7.1




