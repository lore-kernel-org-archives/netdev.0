From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/13] tg3: 5784 / 5764 GPHY power down fix
Date: Fri, 09 Nov 2007 16:38:40 -0800
Message-ID: <1194655120.5745.264.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2639 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227AbXKJAjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

5784 and 5764 devices fail to link / pass traffic after one load /
unload cycle.  This happens because of a hardware bug in the new CPMU.
During normal operation, the MAC depends on the PHY clock being
available.  When the PHY is powered down, the clock the MAC depends on
is disabled.  The fix is to switch the MAC clock to an alternate source
before powering down the PHY, and to restore the MAC clock to the PHY
source upon device resume.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ddeaa0c..82b1cf0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1106,6 +1106,19 @@ static int tg3_phy_reset(struct tg3 *tp)
 	if (err)
 		return err;
 
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0) {
+		u32 val;
+
+		val = tr32(TG3_CPMU_LSPD_1000MB_CLK);
+		if ((val & CPMU_LSPD_1000MB_MACCLK_MASK) ==
+		    CPMU_LSPD_1000MB_MACCLK_12_5) {
+			val &= ~CPMU_LSPD_1000MB_MACCLK_MASK;
+			udelay(40);
+			tw32_f(TG3_CPMU_LSPD_1000MB_CLK, val);
+		}
+	}
+
 out:
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_ADC_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
@@ -1297,6 +1310,8 @@ static void tg3_nvram_unlock(struct tg3 *);
 
 static void tg3_power_down_phy(struct tg3 *tp)
 {
+	u32 val;
+
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
 			u32 sg_dig_ctrl = tr32(SG_DIG_CTRL);
@@ -1311,8 +1326,6 @@ static void tg3_power_down_phy(struct tg3 *tp)
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-		u32 val;
-
 		tg3_bmcr_reset(tp);
 		val = tr32(GRC_MISC_CFG);
 		tw32_f(GRC_MISC_CFG, val | GRC_MISC_CFG_EPHY_IDDQ);
@@ -1332,6 +1345,15 @@ static void tg3_power_down_phy(struct tg3 *tp)
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 &&
 	     (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)))
 		return;
+
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0) {
+		val = tr32(TG3_CPMU_LSPD_1000MB_CLK);
+		val &= ~CPMU_LSPD_1000MB_MACCLK_MASK;
+		val |= CPMU_LSPD_1000MB_MACCLK_12_5;
+		tw32_f(TG3_CPMU_LSPD_1000MB_CLK, val);
+	}
+
 	tg3_writephy(tp, MII_BMCR, BMCR_PDOWN);
 }
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 1d5b2a3..4659697 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -109,6 +109,7 @@
 #define  CHIPREV_ID_5714_A2		 0x9002
 #define  CHIPREV_ID_5906_A1		 0xc001
 #define  CHIPREV_ID_5784_A0		 0x5784000
+#define  CHIPREV_ID_5761_A0		 0x5761000
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
@@ -856,7 +857,13 @@
 #define  CPMU_CTRL_LINK_IDLE_MODE	 0x00000200
 #define  CPMU_CTRL_LINK_AWARE_MODE	 0x00000400
 #define  CPMU_CTRL_LINK_SPEED_MODE	 0x00004000
-/* 0x3604 --> 0x365c unused */
+/* 0x3604 --> 0x360c unused */
+
+#define TG3_CPMU_LSPD_1000MB_CLK	0x0000360c
+#define  CPMU_LSPD_1000MB_MACCLK_62_5	 0x00000000
+#define  CPMU_LSPD_1000MB_MACCLK_12_5	 0x00110000
+#define  CPMU_LSPD_1000MB_MACCLK_MASK	 0x001f0000
+/* 0x3610 --> 0x365c unused */
 
 #define TG3_CPMU_MUTEX_REQ		0x0000365c
 #define  CPMU_MUTEX_REQ_DRIVER		 0x00001000


