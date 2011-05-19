From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/13] tg3: Fix EEE interoperability workaround
Date: Thu, 19 May 2011 15:12:48 -0700
Message-ID: <1305843176-32358-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1120 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934941Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 21a00ab270f95d32e502d92f166dd75c518d3c5f, entitled
"tg3: Fix EEE interoperability issue", added an EEE interoperability
fix.  We found that the fix doesn't work if applied too early though.
This patch delays the fix until right before allowing LPI assertion.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   41 +++++++++++++++++++++--------------------
 drivers/net/tg3.h |    2 +-
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6c53e2c..695dab2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1822,22 +1822,9 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 		tg3_phy_cl45_read(tp, MDIO_MMD_AN,
 				  TG3_CL45_D7_EEERES_STAT, &val);
 
-		switch (val) {
-		case TG3_CL45_D7_EEERES_STAT_LP_1000T:
-			switch (GET_ASIC_REV(tp->pci_chip_rev_id)) {
-			case ASIC_REV_5717:
-			case ASIC_REV_5719:
-			case ASIC_REV_57765:
-				if (!TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
-					tg3_phydsp_write(tp, MII_TG3_DSP_TAP26,
-							 0x0000);
-					TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
-				}
-			}
-			/* Fallthrough */
-		case TG3_CL45_D7_EEERES_STAT_LP_100TX:
+		if (val == TG3_CL45_D7_EEERES_STAT_LP_1000T ||
+		    val == TG3_CL45_D7_EEERES_STAT_LP_100TX)
 			tp->setlpicnt = 2;
-		}
 	}
 
 	if (!tp->setlpicnt) {
@@ -1846,6 +1833,23 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 	}
 }
 
+static void tg3_phy_eee_enable(struct tg3 *tp)
+{
+	u32 val;
+
+	if (tp->link_config.active_speed == SPEED_1000 &&
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) &&
+	    !TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+		tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, 0x0003);
+		TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+	}
+
+	val = tr32(TG3_CPMU_EEE_MODE);
+	tw32(TG3_CPMU_EEE_MODE, val | TG3_CPMU_EEEMD_LPI_ENABLE);
+}
+
 static int tg3_wait_macro_done(struct tg3 *tp)
 {
 	int limit = 100;
@@ -8844,11 +8848,8 @@ static void tg3_timer(unsigned long __opaque)
 		if (tg3_flag(tp, 5705_PLUS))
 			tg3_periodic_fetch_stats(tp);
 
-		if (tp->setlpicnt && !--tp->setlpicnt) {
-			u32 val = tr32(TG3_CPMU_EEE_MODE);
-			tw32(TG3_CPMU_EEE_MODE,
-			     val | TG3_CPMU_EEEMD_LPI_ENABLE);
-		}
+		if (tp->setlpicnt && !--tp->setlpicnt)
+			tg3_phy_eee_enable(tp);
 
 		if (tg3_flag(tp, USE_LINKCHG_REG)) {
 			u32 mac_stat;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 330959b..83f45bf 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2186,7 +2186,7 @@
 #define  MII_TG3_DSP_TAP26_OPCSINPT	0x0004
 #define MII_TG3_DSP_AADJ1CH0		0x001f
 #define MII_TG3_DSP_CH34TP2		0x4022
-#define MII_TG3_DSP_CH34TP2_HIBW01	0x0010
+#define MII_TG3_DSP_CH34TP2_HIBW01	0x017b
 #define MII_TG3_DSP_AADJ1CH3		0x601f
 #define  MII_TG3_DSP_AADJ1CH3_ADCCKADJ	0x0002
 #define MII_TG3_DSP_EXP1_INT_STAT	0x0f01
-- 
1.7.3.4


