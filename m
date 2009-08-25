From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 07/12] tg3: Create MII_TG3_FET namespace
Date: Tue, 25 Aug 2009 13:09:36 -0700
Message-ID: <1251232429.25411@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4226 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114AbZHYUeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:34:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom's phys come in two distinctly different register layouts.  For
the lack of an official term to distinguish between the two formats, we
can loosely categorize them by their fast ethernet or gigabit ethernet
transceiver description.  This patch creates the (driver-internal) Fast
Ethernet Transceiver (FET) namespace and converts the 5906 EPHY
definitions over.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   38 +++++++++++++++++++++-----------------
 drivers/net/tg3.h |   21 +++++++++++++--------
 2 files changed, 34 insertions(+), 25 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 41e0d40..800f980 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1514,17 +1514,19 @@ static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		u32 ephy;
 
-		if (!tg3_readphy(tp, MII_TG3_EPHY_TEST, &ephy)) {
-			tg3_writephy(tp, MII_TG3_EPHY_TEST,
-				     ephy | MII_TG3_EPHY_SHADOW_EN);
-			if (!tg3_readphy(tp, MII_TG3_EPHYTST_MISCCTRL, &phy)) {
+		if (!tg3_readphy(tp, MII_TG3_FET_TEST, &ephy)) {
+			u32 reg = MII_TG3_FET_SHDW_MISCCTRL;
+
+			tg3_writephy(tp, MII_TG3_FET_TEST,
+				     ephy | MII_TG3_FET_SHADOW_EN);
+			if (!tg3_readphy(tp, reg, &phy)) {
 				if (enable)
-					phy |= MII_TG3_EPHYTST_MISCCTRL_MDIX;
+					phy |= MII_TG3_FET_SHDW_MISCCTRL_MDIX;
 				else
-					phy &= ~MII_TG3_EPHYTST_MISCCTRL_MDIX;
-				tg3_writephy(tp, MII_TG3_EPHYTST_MISCCTRL, phy);
+					phy &= ~MII_TG3_FET_SHDW_MISCCTRL_MDIX;
+				tg3_writephy(tp, reg, phy);
 			}
-			tg3_writephy(tp, MII_TG3_EPHY_TEST, ephy);
+			tg3_writephy(tp, MII_TG3_FET_TEST, ephy);
 		}
 	} else {
 		phy = MII_TG3_AUXCTL_MISC_RDSEL_MISC |
@@ -1915,7 +1917,7 @@ out:
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		/* adjust output voltage */
-		tg3_writephy(tp, MII_TG3_EPHY_PTEST, 0x12);
+		tg3_writephy(tp, MII_TG3_FET_PTEST, 0x12);
 	}
 
 	tg3_phy_toggle_automdix(tp, 1);
@@ -9747,14 +9749,16 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			u32 phytest;
 
-			if (!tg3_readphy(tp, MII_TG3_EPHY_TEST, &phytest)) {
-				u32 phy;
+			if (!tg3_readphy(tp, MII_TG3_FET_TEST, &phytest)) {
+				u32 phy, reg = MII_TG3_FET_SHDW_AUXSTAT2;
 
-				tg3_writephy(tp, MII_TG3_EPHY_TEST,
-					     phytest | MII_TG3_EPHY_SHADOW_EN);
-				if (!tg3_readphy(tp, 0x1b, &phy))
-					tg3_writephy(tp, 0x1b, phy & ~0x20);
-				tg3_writephy(tp, MII_TG3_EPHY_TEST, phytest);
+				tg3_writephy(tp, MII_TG3_FET_TEST,
+					     phytest | MII_TG3_FET_SHADOW_EN);
+				if (!tg3_readphy(tp, reg, &phy)) {
+					phy &= ~MII_TG3_FET_SHDW_AUXSTAT2_APD;
+					tg3_writephy(tp, reg, phy);
+				}
+				tg3_writephy(tp, MII_TG3_FET_TEST, phytest);
 			}
 			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED100;
 		} else
@@ -9767,7 +9771,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 		mac_mode = tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK;
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-			tg3_writephy(tp, MII_TG3_EPHY_PTEST, 0x1800);
+			tg3_writephy(tp, MII_TG3_FET_PTEST, 0x1800);
 			mac_mode |= MAC_MODE_PORT_MODE_MII;
 		} else
 			mac_mode |= MAC_MODE_PORT_MODE_GMII;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d096e10..b8339c9 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1909,7 +1909,6 @@
 
 #define MII_TG3_DSP_RW_PORT		0x15 /* DSP coefficient read/write port */
 
-#define MII_TG3_EPHY_PTEST		0x17 /* 5906 PHY register */
 #define MII_TG3_DSP_ADDRESS		0x17 /* DSP address register */
 
 #define MII_TG3_DSP_TAP1		0x0001
@@ -1976,17 +1975,23 @@
 #define MII_TG3_MISC_SHDW_SCR5_LPED	0x0010
 #define MII_TG3_MISC_SHDW_SCR5_SEL	0x1400
 
-
-#define MII_TG3_EPHY_TEST		0x1f /* 5906 PHY register */
-#define MII_TG3_EPHY_SHADOW_EN		0x80
-
-#define MII_TG3_EPHYTST_MISCCTRL	0x10 /* 5906 EPHY misc ctrl shadow register */
-#define MII_TG3_EPHYTST_MISCCTRL_MDIX	0x4000
-
 #define MII_TG3_TEST1			0x1e
 #define MII_TG3_TEST1_TRIM_EN		0x0010
 #define MII_TG3_TEST1_CRC_EN		0x8000
 
+
+/* Fast Ethernet Tranceiver definitions */
+#define MII_TG3_FET_PTEST		0x17
+#define MII_TG3_FET_TEST		0x1f
+#define  MII_TG3_FET_SHADOW_EN		0x0080
+
+#define MII_TG3_FET_SHDW_MISCCTRL	0x10
+#define  MII_TG3_FET_SHDW_MISCCTRL_MDIX	0x4000
+
+#define MII_TG3_FET_SHDW_AUXSTAT2	0x1b
+#define  MII_TG3_FET_SHDW_AUXSTAT2_APD	0x0020
+
+
 /* APE registers.  Accessible through BAR1 */
 #define TG3_APE_EVENT			0x000c
 #define  APE_EVENT_1			 0x00000001
-- 
1.6.3.3


