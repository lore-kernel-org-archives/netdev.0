From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 09/25] bnx2x: Self-test false positive
Date: Wed, 13 Aug 2008 17:13:55 +0300
Message-ID: <1218636835.547.85.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1375 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034AbYHMOOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:14:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Self-test false positive
- The memory test should use a mask according to the chip type
- In the register test, check the port only once and not inside the for 
  loop (not causing a failure - just ugly)

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index b8cdce2..a4177e9 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8420,6 +8420,7 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 {
 	int idx, i, rc = -ENODEV;
 	u32 wr_val = 0;
+	int port = BP_PORT(bp);
 	static const struct {
 		u32  offset0;
 		u32  offset1;
@@ -8485,7 +8486,6 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 
 		for (i = 0; reg_tbl[i].offset0 != 0xffffffff; i++) {
 			u32 offset, mask, save_val, val;
-			int port = BP_PORT(bp);
 
 			offset = reg_tbl[i].offset0 + port*reg_tbl[i].offset1;
 			mask = reg_tbl[i].mask;
@@ -8531,16 +8531,17 @@ static int bnx2x_test_memory(struct bnx2x *bp)
 	static const struct {
 		char *name;
 		u32 offset;
-		u32 mask;
+		u32 e1_mask;
+		u32 e1h_mask;
 	} prty_tbl[] = {
-		{ "CCM_REG_CCM_PRTY_STS",     CCM_REG_CCM_PRTY_STS,     0 },
-		{ "CFC_REG_CFC_PRTY_STS",     CFC_REG_CFC_PRTY_STS,     0 },
-		{ "DMAE_REG_DMAE_PRTY_STS",   DMAE_REG_DMAE_PRTY_STS,   0 },
-		{ "TCM_REG_TCM_PRTY_STS",     TCM_REG_TCM_PRTY_STS,     0 },
-		{ "UCM_REG_UCM_PRTY_STS",     UCM_REG_UCM_PRTY_STS,     0 },
-		{ "XCM_REG_XCM_PRTY_STS",     XCM_REG_XCM_PRTY_STS,     0x1 },
-
-		{ NULL, 0xffffffff, 0 }
+		{ "CCM_PRTY_STS",  CCM_REG_CCM_PRTY_STS,   0x3ffc0, 0 },
+		{ "CFC_PRTY_STS",  CFC_REG_CFC_PRTY_STS,   0x2,     0x2 },
+		{ "DMAE_PRTY_STS", DMAE_REG_DMAE_PRTY_STS, 0,       0 },
+		{ "TCM_PRTY_STS",  TCM_REG_TCM_PRTY_STS,   0x3ffc0, 0 },
+		{ "UCM_PRTY_STS",  UCM_REG_UCM_PRTY_STS,   0x3ffc0, 0 },
+		{ "XCM_PRTY_STS",  XCM_REG_XCM_PRTY_STS,   0x3ffc1, 0 },
+
+		{ NULL, 0xffffffff, 0, 0 }
 	};
 
 	if (!netif_running(bp->dev))
@@ -8554,7 +8555,8 @@ static int bnx2x_test_memory(struct bnx2x *bp)
 	/* Check the parity status */
 	for (i = 0; prty_tbl[i].offset != 0xffffffff; i++) {
 		val = REG_RD(bp, prty_tbl[i].offset);
-		if (val & ~(prty_tbl[i].mask)) {
+		if ((CHIP_IS_E1(bp) && (val & ~(prty_tbl[i].e1_mask))) ||
+		    (CHIP_IS_E1H(bp) && (val & ~(prty_tbl[i].e1h_mask)))) {
 			DP(NETIF_MSG_HW,
 			   "%s is 0x%x\n", prty_tbl[i].name, val);
 			goto test_mem_exit;
-- 
1.5.3.2




