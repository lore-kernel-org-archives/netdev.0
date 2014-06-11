From: Yuval Mintz <yuval.mintz@qlogic.com>
Subject: [PATCH net 3/4] bnx2x: Check for UNDI in uncommon branch
Date: Wed, 11 Jun 2014 16:27:27 +0300
Message-ID: <1402493248-5427-4-git-send-email-yuval.mintz@qlogic.com>
References: <1402493248-5427-1-git-send-email-yuval.mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>, Yuval Mintz <yuval.mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:61072 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753168AbaFKN1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 09:27:47 -0400
In-Reply-To: <1402493248-5427-1-git-send-email-yuval.mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If L2FW utilized by the UNDI driver has the same version number as that
of the regular FW, a driver loading after UNDI and receiving an uncommon
answer from management will mistakenly assume the loaded FW matches its
own requirement and try to exist the flow via FLR.

Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
Signed-off-by: Ariel Elior <ariel.elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 43 +++++++++++++++++-------
 1 file changed, 30 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ff2bdd8..8ea644b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10053,6 +10053,24 @@ static void bnx2x_prev_unload_close_mac(struct bnx2x *bp,
 #define BCM_5710_UNDI_FW_MF_VERS	(0x05)
 #define BNX2X_PREV_UNDI_MF_PORT(p) (BAR_TSTRORM_INTMEM + 0x150c + ((p) << 4))
 #define BNX2X_PREV_UNDI_MF_FUNC(f) (BAR_TSTRORM_INTMEM + 0x184c + ((f) << 4))
+
+static bool bnx2x_prev_is_after_undi(struct bnx2x *bp)
+{
+	/* UNDI marks its presence in DORQ -
+	 * it initializes CID offset for normal bell to 0x7
+	 */
+	if (!(REG_RD(bp, MISC_REG_RESET_REG_1) &
+	    MISC_REGISTERS_RESET_REG_1_RST_DORQ))
+		return false;
+
+	if (REG_RD(bp, DORQ_REG_NORM_CID_OFST) == 0x7) {
+		BNX2X_DEV_INFO("UNDI previously loaded\n");
+		return true;
+	}
+
+	return false;
+}
+
 static bool bnx2x_prev_unload_undi_fw_supports_mf(struct bnx2x *bp)
 {
 	u8 major, minor, version;
@@ -10302,6 +10320,10 @@ static int bnx2x_prev_unload_uncommon(struct bnx2x *bp)
 
 	BNX2X_DEV_INFO("Path is unmarked\n");
 
+	/* Cannot proceed with FLR if UNDI is loaded, since FW does not match */
+	if (bnx2x_prev_is_after_undi(bp))
+		goto out;
+
 	/* If function has FLR capabilities, and existing FW version matches
 	 * the one required, then FLR will be sufficient to clean any residue
 	 * left by previous driver
@@ -10322,6 +10344,7 @@ static int bnx2x_prev_unload_uncommon(struct bnx2x *bp)
 
 	BNX2X_DEV_INFO("Could not FLR\n");
 
+out:
 	/* Close the MCP request, return failure*/
 	rc = bnx2x_prev_mcp_done(bp);
 	if (!rc)
@@ -10360,19 +10383,13 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 		/* close LLH filters towards the BRB */
 		bnx2x_set_rx_filter(&bp->link_params, 0);
 
-		/* Check if the UNDI driver was previously loaded
-		 * UNDI driver initializes CID offset for normal bell to 0x7
-		 */
-		if (reset_reg & MISC_REGISTERS_RESET_REG_1_RST_DORQ) {
-			tmp_reg = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
-			if (tmp_reg == 0x7) {
-				BNX2X_DEV_INFO("UNDI previously loaded\n");
-				prev_undi = true;
-				/* clear the UNDI indication */
-				REG_WR(bp, DORQ_REG_NORM_CID_OFST, 0);
-				/* clear possible idle check errors */
-				REG_RD(bp, NIG_REG_NIG_INT_STS_CLR_0);
-			}
+		/* Check if the UNDI driver was previously loaded */
+		if (bnx2x_prev_is_after_undi(bp)) {
+			prev_undi = true;
+			/* clear the UNDI indication */
+			REG_WR(bp, DORQ_REG_NORM_CID_OFST, 0);
+			/* clear possible idle check errors */
+			REG_RD(bp, NIG_REG_NIG_INT_STS_CLR_0);
 		}
 		if (!CHIP_IS_E1x(bp))
 			/* block FW from writing to host */
-- 
1.8.1.4
