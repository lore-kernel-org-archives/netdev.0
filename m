From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 10/14] tg3: Add error reporting to
 tg3_phydsp_write()
Date: Mon, 2 Aug 2010 14:26:04 -0700
Message-ID: <1280784368-4226-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2868 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755429Ab0HBV0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds error reporting to the tg3_phydsp_write() function and
converts a few more locations to use this function over the inlined
equivalent.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   51 ++++++++++++++++++++-------------------------------
 1 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 820a7dd..a9bca8a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1572,10 +1572,15 @@ static void tg3_phy_fini(struct tg3 *tp)
 	}
 }
 
-static void tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
+static int tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
 {
-	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, reg);
-	tg3_writephy(tp, MII_TG3_DSP_RW_PORT, val);
+	int err;
+
+	err = tg3_writephy(tp, MII_TG3_DSP_ADDRESS, reg);
+	if (!err)
+		err = tg3_writephy(tp, MII_TG3_DSP_RW_PORT, val);
+
+	return err;
 }
 
 static void tg3_phy_fet_toggle_apd(struct tg3 *tp, bool enable)
@@ -1872,8 +1877,7 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
 
 		/* Block the PHY control access.  */
-		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8005);
-		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x0800);
+		tg3_phydsp_write(tp, 0x8005, 0x0800);
 
 		err = tg3_phy_write_and_check_testpat(tp, &do_phy_reset);
 		if (!err)
@@ -1884,8 +1888,7 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 	if (err)
 		return err;
 
-	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8005);
-	tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x0000);
+	tg3_phydsp_write(tp, 0x8005, 0x0000);
 
 	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8200);
 	tg3_writephy(tp, 0x16, 0x0000);
@@ -1994,10 +1997,8 @@ static int tg3_phy_reset(struct tg3 *tp)
 out:
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_ADC_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
-		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x201f);
-		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x2aaa);
-		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
-		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x0323);
+		tg3_phydsp_write(tp, 0x201f, 0x2aaa);
+		tg3_phydsp_write(tp, 0x000a, 0x0323);
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
 	}
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_5704_A0_BUG) {
@@ -2006,12 +2007,9 @@ out:
 	}
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_BER_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
-		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
-		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x310b);
-		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x201f);
-		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x9506);
-		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x401f);
-		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x14e2);
+		tg3_phydsp_write(tp, 0x000a, 0x310b);
+		tg3_phydsp_write(tp, 0x201f, 0x9506);
+		tg3_phydsp_write(tp, 0x401f, 0x14e2);
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
 	} else if (tp->tg3_flags2 & TG3_FLG2_PHY_JITTER_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
@@ -2979,20 +2977,11 @@ static int tg3_init_5401phy_dsp(struct tg3 *tp)
 	/* Set Extended packet length bit */
 	err  = tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4c20);
 
-	err |= tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x0012);
-	err |= tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x1804);
-
-	err |= tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x0013);
-	err |= tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x1204);
-
-	err |= tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8006);
-	err |= tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x0132);
-
-	err |= tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8006);
-	err |= tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x0232);
-
-	err |= tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x201f);
-	err |= tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x0a20);
+	err |= tg3_phydsp_write(tp, 0x0012, 0x1804);
+	err |= tg3_phydsp_write(tp, 0x0013, 0x1204);
+	err |= tg3_phydsp_write(tp, 0x8006, 0x0132);
+	err |= tg3_phydsp_write(tp, 0x8006, 0x0232);
+	err |= tg3_phydsp_write(tp, 0x201f, 0x0a20);
 
 	udelay(40);
 
-- 
1.7.1


