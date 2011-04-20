From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 7/9] tg3: Add write accessor for AUX CTRL phy
 reg
Date: Wed, 20 Apr 2011 10:57:41 -0700
Message-ID: <1303322263-18991-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4291 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755514Ab1DTRsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a write accessor for the aux ctrl phy register.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   48 +++++++++++++++++++++++++++++++-----------------
 drivers/net/tg3.h |    4 ++++
 2 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7be10cf..69cd7cf 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -962,6 +962,14 @@ static int tg3_phy_auxctl_read(struct tg3 *tp, int reg, u32 *val)
 	return err;
 }
 
+static int tg3_phy_auxctl_write(struct tg3 *tp, int reg, u32 set)
+{
+	if (reg == MII_TG3_AUXCTL_SHDWSEL_MISC)
+		set |= MII_TG3_AUXCTL_MISC_WREN;
+
+	return tg3_writephy(tp, MII_TG3_AUX_CTRL, set | reg);
+}
+
 static int tg3_bmcr_reset(struct tg3 *tp)
 {
 	u32 phy_control;
@@ -1701,8 +1709,8 @@ static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
 				phy |= MII_TG3_AUXCTL_MISC_FORCE_AMDIX;
 			else
 				phy &= ~MII_TG3_AUXCTL_MISC_FORCE_AMDIX;
-			phy |= MII_TG3_AUXCTL_MISC_WREN;
-			tg3_writephy(tp, MII_TG3_AUX_CTRL, phy);
+			tg3_phy_auxctl_write(tp,
+					     MII_TG3_AUXCTL_SHDWSEL_MISC, phy);
 		}
 	}
 }
@@ -1717,8 +1725,8 @@ static void tg3_phy_set_wirespeed(struct tg3 *tp)
 
 	ret = tg3_phy_auxctl_read(tp, MII_TG3_AUXCTL_SHDWSEL_MISC, &val);
 	if (!ret)
-		tg3_writephy(tp, MII_TG3_AUX_CTRL,
-			     (val | (1 << 15) | (1 << 4)));
+		tg3_phy_auxctl_write(tp, MII_TG3_AUXCTL_SHDWSEL_MISC,
+				     val | MII_TG3_AUXCTL_MISC_WIRESPD_EN);
 }
 
 static void tg3_phy_apply_otp(struct tg3 *tp)
@@ -2104,13 +2112,14 @@ out:
 	/* support jumbo frames */
 	if ((tp->phy_id & TG3_PHY_ID_MASK) == TG3_PHY_ID_BCM5401) {
 		/* Cannot do read-modify-write on 5401 */
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4c20);
+		tg3_phy_auxctl_write(tp, MII_TG3_AUXCTL_SHDWSEL_AUXCTL, 0x4c20);
 	} else if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
 		/* Set bit 14 with read-modify-write to preserve other bits */
 		err = tg3_phy_auxctl_read(tp,
 					  MII_TG3_AUXCTL_SHDWSEL_AUXCTL, &val);
 		if (!err)
-			tg3_writephy(tp, MII_TG3_AUX_CTRL, val | 0x4000);
+			tg3_phy_auxctl_write(tp, MII_TG3_AUXCTL_SHDWSEL_AUXCTL,
+					   val | MII_TG3_AUXCTL_ACTL_EXTPKTLEN);
 	}
 
 	/* Set phy register 0x10 bit 0 to high fifo elasticity to support
@@ -2319,11 +2328,10 @@ static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 		tg3_writephy(tp, MII_TG3_EXT_CTRL,
 			     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
 
-		tg3_writephy(tp, MII_TG3_AUX_CTRL,
-			     MII_TG3_AUXCTL_SHDWSEL_PWRCTL |
-			     MII_TG3_AUXCTL_PCTL_100TX_LPWR |
-			     MII_TG3_AUXCTL_PCTL_SPR_ISOLATE |
-			     MII_TG3_AUXCTL_PCTL_VREG_11V);
+		val = MII_TG3_AUXCTL_PCTL_100TX_LPWR |
+		      MII_TG3_AUXCTL_PCTL_SPR_ISOLATE |
+		      MII_TG3_AUXCTL_PCTL_VREG_11V;
+		tg3_phy_auxctl_write(tp, MII_TG3_AUXCTL_SHDWSEL_PWRCTL, val);
 	}
 
 	/* The PHY should not be powered down on some chips because
@@ -2717,8 +2725,13 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 		u32 mac_mode;
 
 		if (!(tp->phy_flags & TG3_PHYFLG_PHY_SERDES)) {
-			if (do_low_power) {
-				tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x5a);
+			if (do_low_power &&
+			    !(tp->phy_flags & TG3_PHYFLG_IS_FET)) {
+				tg3_phy_auxctl_write(tp,
+					       MII_TG3_AUXCTL_SHDWSEL_PWRCTL,
+					       MII_TG3_AUXCTL_PCTL_WOL_EN |
+					       MII_TG3_AUXCTL_PCTL_100TX_LPWR |
+					       MII_TG3_AUXCTL_PCTL_CL_AB_TXDAC);
 				udelay(40);
 			}
 
@@ -3092,7 +3105,7 @@ static int tg3_init_5401phy_dsp(struct tg3 *tp)
 
 	/* Turn off tap power management. */
 	/* Set Extended packet length bit */
-	err  = tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4c20);
+	err = tg3_phy_auxctl_write(tp, MII_TG3_AUXCTL_SHDWSEL_AUXCTL, 0x4c20);
 
 	err |= tg3_phydsp_write(tp, 0x0012, 0x1804);
 	err |= tg3_phydsp_write(tp, 0x0013, 0x1204);
@@ -3198,7 +3211,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 		udelay(80);
 	}
 
-	tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x02);
+	tg3_phy_auxctl_write(tp, MII_TG3_AUXCTL_SHDWSEL_PWRCTL, 0);
 
 	/* Some third-party PHYs need to be reset on link going
 	 * down.
@@ -3283,8 +3296,9 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 					  MII_TG3_AUXCTL_SHDWSEL_MISCTEST,
 					  &val);
 		if (!err && !(val & (1 << 10))) {
-			val |= (1 << 10);
-			tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
+			tg3_phy_auxctl_write(tp,
+					     MII_TG3_AUXCTL_SHDWSEL_MISCTEST,
+					     val | (1 << 10));
 			goto relink;
 		}
 	}
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b9382f1..eaa7669 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2197,15 +2197,19 @@
 #define MII_TG3_AUXCTL_SHDWSEL_AUXCTL	0x0000
 #define MII_TG3_AUXCTL_ACTL_TX_6DB	0x0400
 #define MII_TG3_AUXCTL_ACTL_SMDSP_ENA	0x0800
+#define MII_TG3_AUXCTL_ACTL_EXTPKTLEN	0x4000
 
 #define MII_TG3_AUXCTL_SHDWSEL_PWRCTL	0x0002
+#define MII_TG3_AUXCTL_PCTL_WOL_EN	0x0008
 #define MII_TG3_AUXCTL_PCTL_100TX_LPWR	0x0010
 #define MII_TG3_AUXCTL_PCTL_SPR_ISOLATE	0x0020
+#define MII_TG3_AUXCTL_PCTL_CL_AB_TXDAC	0x0040
 #define MII_TG3_AUXCTL_PCTL_VREG_11V	0x0180
 
 #define MII_TG3_AUXCTL_SHDWSEL_MISCTEST	0x0004
 
 #define MII_TG3_AUXCTL_SHDWSEL_MISC	0x0007
+#define MII_TG3_AUXCTL_MISC_WIRESPD_EN	0x0010
 #define MII_TG3_AUXCTL_MISC_FORCE_AMDIX	0x0200
 #define MII_TG3_AUXCTL_MISC_RDSEL_SHIFT	12
 #define MII_TG3_AUXCTL_MISC_WREN	0x8000
-- 
1.7.3.4


