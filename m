From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 7/8] tg3: Migrate phy preprocessor defs to
 system defs
Date: Mon, 13 Jun 2011 16:39:01 -0700
Message-ID: <1308008342-21030-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3164 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755372Ab1FMXiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 19:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes to code to use some of the preprocessor
definitions from mii.h over its homegrown equivalents.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c   |   26 ++++++++++++--------------
 drivers/net/tg3.h   |    8 --------
 include/linux/mii.h |    2 ++
 3 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a7bea86..7dfacc0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -861,7 +861,7 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 	int ret;
 
 	if ((tp->phy_flags & TG3_PHYFLG_IS_FET) &&
-	    (reg == MII_TG3_CTRL || reg == MII_TG3_AUX_CTRL))
+	    (reg == MII_CTRL1000 || reg == MII_TG3_AUX_CTRL))
 		return 0;
 
 	if ((tp->mi_mode & MAC_MI_MODE_AUTO_POLL) != 0) {
@@ -1981,15 +1981,14 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 
 		/* Set full-duplex, 1000 mbps.  */
 		tg3_writephy(tp, MII_BMCR,
-			     BMCR_FULLDPLX | TG3_BMCR_SPEED1000);
+			     BMCR_FULLDPLX | BMCR_SPEED1000);
 
 		/* Set to master mode.  */
-		if (tg3_readphy(tp, MII_TG3_CTRL, &phy9_orig))
+		if (tg3_readphy(tp, MII_CTRL1000, &phy9_orig))
 			continue;
 
-		tg3_writephy(tp, MII_TG3_CTRL,
-			     (MII_TG3_CTRL_AS_MASTER |
-			      MII_TG3_CTRL_ENABLE_AS_MASTER));
+		tg3_writephy(tp, MII_CTRL1000,
+			     CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER);
 
 		err = TG3_PHY_AUXCTL_SMDSP_ENABLE(tp);
 		if (err)
@@ -2014,7 +2013,7 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 
 	TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
 
-	tg3_writephy(tp, MII_TG3_CTRL, phy9_orig);
+	tg3_writephy(tp, MII_CTRL1000, phy9_orig);
 
 	if (!tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32)) {
 		reg32 &= ~0x3000;
@@ -2958,16 +2957,15 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 
 	new_adv = 0;
 	if (advertise & ADVERTISED_1000baseT_Half)
-		new_adv |= MII_TG3_CTRL_ADV_1000_HALF;
+		new_adv |= ADVERTISE_1000HALF;
 	if (advertise & ADVERTISED_1000baseT_Full)
-		new_adv |= MII_TG3_CTRL_ADV_1000_FULL;
+		new_adv |= ADVERTISE_1000FULL;
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
 	    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
-		new_adv |= (MII_TG3_CTRL_AS_MASTER |
-			    MII_TG3_CTRL_ENABLE_AS_MASTER);
+		new_adv |= CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER;
 
-	err = tg3_writephy(tp, MII_TG3_CTRL, new_adv);
+	err = tg3_writephy(tp, MII_CTRL1000, new_adv);
 	if (err)
 		goto done;
 
@@ -3076,7 +3074,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 			break;
 
 		case SPEED_1000:
-			bmcr |= TG3_BMCR_SPEED1000;
+			bmcr |= BMCR_SPEED1000;
 			break;
 		}
 
@@ -3153,7 +3151,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 		if (mask & ADVERTISED_1000baseT_Full)
 			all_mask |= ADVERTISE_1000FULL;
 
-		if (tg3_readphy(tp, MII_TG3_CTRL, &tg3_ctrl))
+		if (tg3_readphy(tp, MII_CTRL1000, &tg3_ctrl))
 			return 0;
 
 		if ((tg3_ctrl & all_mask) != all_mask)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 54441a3..bedc3b4 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2152,14 +2152,6 @@
 
 
 /*** Tigon3 specific PHY MII registers. ***/
-#define  TG3_BMCR_SPEED1000		0x0040
-
-#define MII_TG3_CTRL			0x09 /* 1000-baseT control register */
-#define  MII_TG3_CTRL_ADV_1000_HALF	0x0100
-#define  MII_TG3_CTRL_ADV_1000_FULL	0x0200
-#define  MII_TG3_CTRL_AS_MASTER		0x0800
-#define  MII_TG3_CTRL_ENABLE_AS_MASTER	0x1000
-
 #define MII_TG3_MMD_CTRL		0x0d /* MMD Access Control register */
 #define MII_TG3_MMD_CTRL_DATA_NOINC	0x4000
 #define MII_TG3_MMD_ADDRESS		0x0e /* MMD Address Data register */
diff --git a/include/linux/mii.h b/include/linux/mii.h
index 359fba8..103113a 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -128,6 +128,8 @@
 /* 1000BASE-T Control register */
 #define ADVERTISE_1000FULL      0x0200  /* Advertise 1000BASE-T full duplex */
 #define ADVERTISE_1000HALF      0x0100  /* Advertise 1000BASE-T half duplex */
+#define CTL1000_AS_MASTER	0x0800
+#define CTL1000_ENABLE_MASTER	0x1000
 
 /* 1000BASE-T Status register */
 #define LPA_1000LOCALRXOK       0x2000  /* Link partner local receiver status */
-- 
1.7.3.4


