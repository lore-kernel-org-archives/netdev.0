From: "Michael Chan" <mchan@broadcom.com>
Subject: [3/5][TG3]: Enable auto MDI.
Date: Wed, 11 Jul 2007 16:32:15 -0700
Message-ID: <1184196735.5211.10.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, mcarlson@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2770 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934536AbXGKWkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 18:40:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Enable auto MDI.

This patch adds automatic MDI crossover support when autonegotiation is
turned off.  Automatic MDI crossover allows link to be established
without the use of a crossover cable.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1df129a..4f59e5c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -721,6 +721,44 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 	return ret;
 }
 
+static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
+{
+	u32 phy;
+
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
+	    (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES))
+		return;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		u32 ephy;
+
+		if (!tg3_readphy(tp, MII_TG3_EPHY_TEST, &ephy)) {
+			tg3_writephy(tp, MII_TG3_EPHY_TEST,
+				     ephy | MII_TG3_EPHY_SHADOW_EN);
+			if (!tg3_readphy(tp, MII_TG3_EPHYTST_MISCCTRL, &phy)) {
+				if (enable)
+					phy |= MII_TG3_EPHYTST_MISCCTRL_MDIX;
+				else
+					phy &= ~MII_TG3_EPHYTST_MISCCTRL_MDIX;
+				tg3_writephy(tp, MII_TG3_EPHYTST_MISCCTRL, phy);
+			}
+			tg3_writephy(tp, MII_TG3_EPHY_TEST, ephy);
+		}
+	} else {
+		phy = MII_TG3_AUXCTL_MISC_RDSEL_MISC |
+		      MII_TG3_AUXCTL_SHDWSEL_MISC;
+		if (!tg3_writephy(tp, MII_TG3_AUX_CTRL, phy) &&
+		    !tg3_readphy(tp, MII_TG3_AUX_CTRL, &phy)) {
+			if (enable)
+				phy |= MII_TG3_AUXCTL_MISC_FORCE_AMDIX;
+			else
+				phy &= ~MII_TG3_AUXCTL_MISC_FORCE_AMDIX;
+			phy |= MII_TG3_AUXCTL_MISC_WREN;
+			tg3_writephy(tp, MII_TG3_AUX_CTRL, phy);
+		}
+	}
+}
+
 static void tg3_phy_set_wirespeed(struct tg3 *tp)
 {
 	u32 val;
@@ -1045,23 +1083,11 @@ out:
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-		u32 phy_reg;
-
 		/* adjust output voltage */
 		tg3_writephy(tp, MII_TG3_EPHY_PTEST, 0x12);
-
-		if (!tg3_readphy(tp, MII_TG3_EPHY_TEST, &phy_reg)) {
-			u32 phy_reg2;
-
-			tg3_writephy(tp, MII_TG3_EPHY_TEST,
-				     phy_reg | MII_TG3_EPHY_SHADOW_EN);
-			/* Enable auto-MDIX */
-			if (!tg3_readphy(tp, 0x10, &phy_reg2))
-				tg3_writephy(tp, 0x10, phy_reg2 | 0x4000);
-			tg3_writephy(tp, MII_TG3_EPHY_TEST, phy_reg);
-		}
 	}
 
+	tg3_phy_toggle_automdix(tp, 1);
 	tg3_phy_set_wirespeed(tp);
 	return 0;
 }
@@ -8847,14 +8873,14 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 					     phytest | MII_TG3_EPHY_SHADOW_EN);
 				if (!tg3_readphy(tp, 0x1b, &phy))
 					tg3_writephy(tp, 0x1b, phy & ~0x20);
-				if (!tg3_readphy(tp, 0x10, &phy))
-					tg3_writephy(tp, 0x10, phy & ~0x4000);
 				tg3_writephy(tp, MII_TG3_EPHY_TEST, phytest);
 			}
 			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED100;
 		} else
 			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED1000;
 
+		tg3_phy_toggle_automdix(tp, 0);
+
 		tg3_writephy(tp, MII_BMCR, val);
 		udelay(40);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index bd9f4f4..e1b9381 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1642,6 +1642,11 @@
 
 #define MII_TG3_AUX_CTRL		0x18 /* auxilliary control register */
 
+#define MII_TG3_AUXCTL_MISC_WREN	0x8000
+#define MII_TG3_AUXCTL_MISC_FORCE_AMDIX	0x0200
+#define MII_TG3_AUXCTL_MISC_RDSEL_MISC	0x7000
+#define MII_TG3_AUXCTL_SHDWSEL_MISC		0x0007
+
 #define MII_TG3_AUX_STAT		0x19 /* auxilliary status register */
 #define MII_TG3_AUX_STAT_LPASS		0x0004
 #define MII_TG3_AUX_STAT_SPDMASK	0x0700
@@ -1667,6 +1672,9 @@
 #define MII_TG3_EPHY_TEST		0x1f /* 5906 PHY register */
 #define MII_TG3_EPHY_SHADOW_EN		0x80
 
+#define MII_TG3_EPHYTST_MISCCTRL	0x10 /* 5906 EPHY misc ctrl shadow register */
+#define MII_TG3_EPHYTST_MISCCTRL_MDIX	0x4000
+
 #define MII_TG3_TEST1			0x1e
 #define MII_TG3_TEST1_TRIM_EN		0x0010
 #define MII_TG3_TEST1_CRC_EN		0x8000


