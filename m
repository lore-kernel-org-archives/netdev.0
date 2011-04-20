From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 6/9] tg3: Add read accessor for AUX CTRL phy
 reg
Date: Wed, 20 Apr 2011 10:57:40 -0700
Message-ID: <1303322263-18991-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4135 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755472Ab1DTRs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a read accessor for the aux ctrl register.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   39 ++++++++++++++++++++++++++++-----------
 drivers/net/tg3.h |   17 ++++++++++-------
 2 files changed, 38 insertions(+), 18 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ea41d76..7be10cf 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -949,6 +949,19 @@ static int tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
 	return err;
 }
 
+static int tg3_phy_auxctl_read(struct tg3 *tp, int reg, u32 *val)
+{
+	int err;
+
+	err = tg3_writephy(tp, MII_TG3_AUX_CTRL,
+			   (reg << MII_TG3_AUXCTL_MISC_RDSEL_SHIFT) |
+			   MII_TG3_AUXCTL_SHDWSEL_MISC);
+	if (!err)
+		err = tg3_readphy(tp, MII_TG3_AUX_CTRL, val);
+
+	return err;
+}
+
 static int tg3_bmcr_reset(struct tg3 *tp)
 {
 	u32 phy_control;
@@ -1679,10 +1692,11 @@ static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
 			tg3_writephy(tp, MII_TG3_FET_TEST, ephy);
 		}
 	} else {
-		phy = MII_TG3_AUXCTL_MISC_RDSEL_MISC |
-		      MII_TG3_AUXCTL_SHDWSEL_MISC;
-		if (!tg3_writephy(tp, MII_TG3_AUX_CTRL, phy) &&
-		    !tg3_readphy(tp, MII_TG3_AUX_CTRL, &phy)) {
+		int ret;
+
+		ret = tg3_phy_auxctl_read(tp,
+					  MII_TG3_AUXCTL_SHDWSEL_MISC, &phy);
+		if (!ret) {
 			if (enable)
 				phy |= MII_TG3_AUXCTL_MISC_FORCE_AMDIX;
 			else
@@ -1695,13 +1709,14 @@ static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
 
 static void tg3_phy_set_wirespeed(struct tg3 *tp)
 {
+	int ret;
 	u32 val;
 
 	if (tp->phy_flags & TG3_PHYFLG_NO_ETH_WIRE_SPEED)
 		return;
 
-	if (!tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x7007) &&
-	    !tg3_readphy(tp, MII_TG3_AUX_CTRL, &val))
+	ret = tg3_phy_auxctl_read(tp, MII_TG3_AUXCTL_SHDWSEL_MISC, &val);
+	if (!ret)
 		tg3_writephy(tp, MII_TG3_AUX_CTRL,
 			     (val | (1 << 15) | (1 << 4)));
 }
@@ -2092,8 +2107,9 @@ out:
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4c20);
 	} else if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
 		/* Set bit 14 with read-modify-write to preserve other bits */
-		if (!tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0007) &&
-		    !tg3_readphy(tp, MII_TG3_AUX_CTRL, &val))
+		err = tg3_phy_auxctl_read(tp,
+					  MII_TG3_AUXCTL_SHDWSEL_AUXCTL, &val);
+		if (!err)
 			tg3_writephy(tp, MII_TG3_AUX_CTRL, val | 0x4000);
 	}
 
@@ -3263,9 +3279,10 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 	current_duplex = DUPLEX_INVALID;
 
 	if (tp->phy_flags & TG3_PHYFLG_CAPACITIVE_COUPLING) {
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4007);
-		tg3_readphy(tp, MII_TG3_AUX_CTRL, &val);
-		if (!(val & (1 << 10))) {
+		err = tg3_phy_auxctl_read(tp,
+					  MII_TG3_AUXCTL_SHDWSEL_MISCTEST,
+					  &val);
+		if (!err && !(val & (1 << 10))) {
 			val |= (1 << 10);
 			tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
 			goto relink;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index dd331f8..b9382f1 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2194,19 +2194,22 @@
 
 #define MII_TG3_AUX_CTRL		0x18 /* auxiliary control register */
 
+#define MII_TG3_AUXCTL_SHDWSEL_AUXCTL	0x0000
+#define MII_TG3_AUXCTL_ACTL_TX_6DB	0x0400
+#define MII_TG3_AUXCTL_ACTL_SMDSP_ENA	0x0800
+
+#define MII_TG3_AUXCTL_SHDWSEL_PWRCTL	0x0002
 #define MII_TG3_AUXCTL_PCTL_100TX_LPWR	0x0010
 #define MII_TG3_AUXCTL_PCTL_SPR_ISOLATE	0x0020
 #define MII_TG3_AUXCTL_PCTL_VREG_11V	0x0180
-#define MII_TG3_AUXCTL_SHDWSEL_PWRCTL	0x0002
 
-#define MII_TG3_AUXCTL_MISC_WREN	0x8000
-#define MII_TG3_AUXCTL_MISC_FORCE_AMDIX	0x0200
-#define MII_TG3_AUXCTL_MISC_RDSEL_MISC	0x7000
+#define MII_TG3_AUXCTL_SHDWSEL_MISCTEST	0x0004
+
 #define MII_TG3_AUXCTL_SHDWSEL_MISC	0x0007
+#define MII_TG3_AUXCTL_MISC_FORCE_AMDIX	0x0200
+#define MII_TG3_AUXCTL_MISC_RDSEL_SHIFT	12
+#define MII_TG3_AUXCTL_MISC_WREN	0x8000
 
-#define MII_TG3_AUXCTL_ACTL_SMDSP_ENA	0x0800
-#define MII_TG3_AUXCTL_ACTL_TX_6DB	0x0400
-#define MII_TG3_AUXCTL_SHDWSEL_AUXCTL	0x0000
 
 #define MII_TG3_AUX_STAT		0x19 /* auxiliary status register */
 #define MII_TG3_AUX_STAT_LPASS		0x0004
-- 
1.7.3.4


