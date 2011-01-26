From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 09/11] tg3: Fix EEE interoperability issue
Date: Tue, 25 Jan 2011 17:58:55 -0800
Message-ID: <1296007137-23146-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3970 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511Ab1AZB7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a problem where EEE will fail to work in certain
environments.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   42 +++++++++++++++++++++++++++++++++++-------
 drivers/net/tg3.h |    4 ++++
 2 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 997f0d2..eb90400 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1776,9 +1776,29 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 		tg3_phy_cl45_read(tp, MDIO_MMD_AN,
 				  TG3_CL45_D7_EEERES_STAT, &val);
 
-		if (val == TG3_CL45_D7_EEERES_STAT_LP_1000T ||
-		    val == TG3_CL45_D7_EEERES_STAT_LP_100TX)
+		switch (val) {
+		case TG3_CL45_D7_EEERES_STAT_LP_1000T:
+			switch (GET_ASIC_REV(tp->pci_chip_rev_id)) {
+			case ASIC_REV_5717:
+			case ASIC_REV_5719:
+			case ASIC_REV_57765:
+				/* Enable SM_DSP clock and tx 6dB coding. */
+				val = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
+				      MII_TG3_AUXCTL_ACTL_SMDSP_ENA |
+				      MII_TG3_AUXCTL_ACTL_TX_6DB;
+				tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
+
+				tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, 0x0000);
+
+				/* Turn off SM_DSP clock. */
+				val = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
+				      MII_TG3_AUXCTL_ACTL_TX_6DB;
+				tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
+			}
+			/* Fallthrough */
+		case TG3_CL45_D7_EEERES_STAT_LP_100TX:
 			tp->setlpicnt = 2;
+		}
 	}
 
 	if (!tp->setlpicnt) {
@@ -2968,11 +2988,19 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 		      MII_TG3_AUXCTL_ACTL_TX_6DB;
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
 
-		if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) &&
-		    !tg3_phydsp_read(tp, MII_TG3_DSP_CH34TP2, &val))
-			tg3_phydsp_write(tp, MII_TG3_DSP_CH34TP2,
-					 val | MII_TG3_DSP_CH34TP2_HIBW01);
+		switch (GET_ASIC_REV(tp->pci_chip_rev_id)) {
+		case ASIC_REV_5717:
+		case ASIC_REV_57765:
+			if (!tg3_phydsp_read(tp, MII_TG3_DSP_CH34TP2, &val))
+				tg3_phydsp_write(tp, MII_TG3_DSP_CH34TP2, val |
+						 MII_TG3_DSP_CH34TP2_HIBW01);
+			/* Fall through */
+		case ASIC_REV_5719:
+			val = MII_TG3_DSP_TAP26_ALNOKO |
+			      MII_TG3_DSP_TAP26_RMRXSTO |
+			      MII_TG3_DSP_TAP26_OPCSINPT;
+			tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, val);
+		}
 
 		val = 0;
 		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index fc8ecdd..1dbe5ec 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2113,6 +2113,10 @@
 
 #define MII_TG3_DSP_TAP1		0x0001
 #define  MII_TG3_DSP_TAP1_AGCTGT_DFLT	0x0007
+#define MII_TG3_DSP_TAP26		0x001a
+#define  MII_TG3_DSP_TAP26_ALNOKO	0x0001
+#define  MII_TG3_DSP_TAP26_RMRXSTO	0x0002
+#define  MII_TG3_DSP_TAP26_OPCSINPT	0x0004
 #define MII_TG3_DSP_AADJ1CH0		0x001f
 #define MII_TG3_DSP_CH34TP2		0x4022
 #define MII_TG3_DSP_CH34TP2_HIBW01	0x0010
-- 
1.7.2.2


