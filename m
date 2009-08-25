From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 08/12] tg3: Convert code to use PHY_IS_FET
Date: Tue, 25 Aug 2009 13:10:03 -0700
Message-ID: <1251232429.25413@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3452 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681AbZHYUeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the code to use the PHY_IS_FET flag rather than the
ASIC revision to decide whether or not to use FET paths.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   73 +++++++++++++++++++++++++++++++++-------------------
 drivers/net/tg3.h |    1 +
 2 files changed, 47 insertions(+), 27 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 800f980..2808152 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -784,7 +784,7 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 	unsigned int loops;
 	int ret;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 &&
+	if ((tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) &&
 	    (reg == MII_TG3_CTRL || reg == MII_TG3_AUX_CTRL))
 		return 0;
 
@@ -1069,6 +1069,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	case TG3_PHY_ID_RTL8201E:
 	case TG3_PHY_ID_BCMAC131:
 		phydev->interface = PHY_INTERFACE_MODE_MII;
+		tp->tg3_flags3 |= TG3_FLG3_PHY_IS_FET;
 		break;
 	}
 
@@ -1474,13 +1475,37 @@ static void tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
 	tg3_writephy(tp, MII_TG3_DSP_RW_PORT, val);
 }
 
+static void tg3_phy_fet_toggle_apd(struct tg3 *tp, bool enable)
+{
+	u32 phytest;
+
+	if (!tg3_readphy(tp, MII_TG3_FET_TEST, &phytest)) {
+		u32 phy;
+
+		tg3_writephy(tp, MII_TG3_FET_TEST,
+			     phytest | MII_TG3_FET_SHADOW_EN);
+		if (!tg3_readphy(tp, MII_TG3_FET_SHDW_AUXSTAT2, &phy)) {
+			if (enable)
+				phy |= MII_TG3_FET_SHDW_AUXSTAT2_APD;
+			else
+				phy &= ~MII_TG3_FET_SHDW_AUXSTAT2_APD;
+			tg3_writephy(tp, MII_TG3_FET_SHDW_AUXSTAT2, phy);
+		}
+		tg3_writephy(tp, MII_TG3_FET_TEST, phytest);
+	}
+}
+
 static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
 {
 	u32 reg;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		return;
+
+	if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) {
+		tg3_phy_fet_toggle_apd(tp, enable);
 		return;
+	}
 
 	reg = MII_TG3_MISC_SHDW_WREN |
 	      MII_TG3_MISC_SHDW_SCR5_SEL |
@@ -1511,7 +1536,7 @@ static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
 	    (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES))
 		return;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+	if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) {
 		u32 ephy;
 
 		if (!tg3_readphy(tp, MII_TG3_FET_TEST, &ephy)) {
@@ -2662,7 +2687,7 @@ static void tg3_aux_stat_to_speed_duplex(struct tg3 *tp, u32 val, u16 *speed, u8
 		break;
 
 	default:
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) {
 			*speed = (val & MII_TG3_AUX_STAT_100) ? SPEED_100 :
 				 SPEED_10;
 			*duplex = (val & MII_TG3_AUX_STAT_FULL) ? DUPLEX_FULL :
@@ -2997,7 +3022,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 
 	if (tp->tg3_flags & TG3_FLAG_USE_MI_INTERRUPT)
 		tg3_writephy(tp, MII_TG3_IMASK, ~MII_TG3_INT_LINKCHG);
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
+	else if (!(tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET))
 		tg3_writephy(tp, MII_TG3_IMASK, ~0);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
@@ -3107,7 +3132,9 @@ relink:
 			tp->mac_mode |= MAC_MODE_PORT_MODE_MII;
 		else
 			tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
-	} else
+	} else if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET)
+		tp->mac_mode |= MAC_MODE_PORT_MODE_MII;
+	else
 		tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
 
 	tp->mac_mode &= ~MAC_MODE_HALF_DUPLEX;
@@ -7349,7 +7376,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			return err;
 
 		if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) &&
-		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906) {
+		    !(tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET)) {
 			u32 tmp;
 
 			/* Clear CRC stats. */
@@ -9746,20 +9773,8 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	} else if (loopback_mode == TG3_PHY_LOOPBACK) {
 		u32 val;
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-			u32 phytest;
-
-			if (!tg3_readphy(tp, MII_TG3_FET_TEST, &phytest)) {
-				u32 phy, reg = MII_TG3_FET_SHDW_AUXSTAT2;
-
-				tg3_writephy(tp, MII_TG3_FET_TEST,
-					     phytest | MII_TG3_FET_SHADOW_EN);
-				if (!tg3_readphy(tp, reg, &phy)) {
-					phy &= ~MII_TG3_FET_SHDW_AUXSTAT2_APD;
-					tg3_writephy(tp, reg, phy);
-				}
-				tg3_writephy(tp, MII_TG3_FET_TEST, phytest);
-			}
+		if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) {
+			tg3_phy_fet_toggle_apd(tp, false);
 			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED100;
 		} else
 			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED1000;
@@ -9770,8 +9785,9 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 		udelay(40);
 
 		mac_mode = tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-			tg3_writephy(tp, MII_TG3_FET_PTEST, 0x1800);
+		if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) {
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+				tg3_writephy(tp, MII_TG3_FET_PTEST, 0x1800);
 			mac_mode |= MAC_MODE_PORT_MODE_MII;
 		} else
 			mac_mode |= MAC_MODE_PORT_MODE_GMII;
@@ -12268,12 +12284,15 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags |= TG3_FLAG_WOL_SPEED_100MB;
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+		tp->tg3_flags3 |= TG3_FLG3_PHY_IS_FET;
+
 	/* A few boards don't want Ethernet@WireSpeed phy feature */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) ||
 	    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) &&
 	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) &&
 	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A1)) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) ||
+	    (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) ||
 	    (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES))
 		tp->tg3_flags2 |= TG3_FLG2_NO_ETH_WIRE_SPEED;
 
@@ -12284,7 +12303,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags2 |= TG3_FLG2_PHY_5704_A0_BUG;
 
 	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906 &&
+	    !(tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57780) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
@@ -12409,7 +12428,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5753F ||
 	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5787F)) ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57790 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+	    (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET))
 		tp->tg3_flags |= TG3_FLAG_10_100_ONLY;
 
 	err = tg3_phy_probe(tp);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b8339c9..60b12ab 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2666,6 +2666,7 @@ struct tg3 {
 #define TG3_FLG3_5755_PLUS		0x00002000
 #define TG3_FLG3_NO_NVRAM		0x00004000
 #define TG3_FLG3_TOGGLE_10_100_L1PLLPD	0x00008000
+#define TG3_FLG3_PHY_IS_FET		0x00010000
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.6.3.3


