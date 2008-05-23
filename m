From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/8] tg3: Add TG3_FLG3_USE_PHYLIB
Date: Thu, 22 May 2008 19:57:00 -0700
Message-ID: <1211511420.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3677 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757447AbYEWCxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 22:53:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the TG3_FLG3_USE_PHYLIB flag and applies it to
some select places.  This work makes later patches a little easier to
read.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e402f16..5382325 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1605,7 +1605,7 @@ static void tg3_power_down_phy(struct tg3 *tp)
 		tw32_f(GRC_MISC_CFG, val | GRC_MISC_CFG_EPHY_IDDQ);
 		udelay(40);
 		return;
-	} else {
+	} else if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
 		tg3_writephy(tp, MII_TG3_EXT_CTRL,
 			     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x01b2);
@@ -1687,18 +1687,22 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT);
 
-	if (tp->link_config.phy_is_low_power == 0) {
+	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 		tp->link_config.phy_is_low_power = 1;
-		tp->link_config.orig_speed = tp->link_config.speed;
-		tp->link_config.orig_duplex = tp->link_config.duplex;
-		tp->link_config.orig_autoneg = tp->link_config.autoneg;
-	}
+	} else {
+		if (tp->link_config.phy_is_low_power == 0) {
+			tp->link_config.phy_is_low_power = 1;
+			tp->link_config.orig_speed = tp->link_config.speed;
+			tp->link_config.orig_duplex = tp->link_config.duplex;
+			tp->link_config.orig_autoneg = tp->link_config.autoneg;
+		}
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_ANY_SERDES)) {
-		tp->link_config.speed = SPEED_10;
-		tp->link_config.duplex = DUPLEX_HALF;
-		tp->link_config.autoneg = AUTONEG_ENABLE;
-		tg3_setup_phy(tp, 0);
+		if (!(tp->tg3_flags2 & TG3_FLG2_ANY_SERDES)) {
+			tp->link_config.speed = SPEED_10;
+			tp->link_config.duplex = DUPLEX_HALF;
+			tp->link_config.autoneg = AUTONEG_ENABLE;
+			tg3_setup_phy(tp, 0);
+		}
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
@@ -1729,8 +1733,10 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		u32 mac_mode;
 
 		if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
-			tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x5a);
-			udelay(40);
+			if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
+				tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x5a);
+				udelay(40);
+			}
 
 			if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)
 				mac_mode = MAC_MODE_PORT_MODE_GMII;
@@ -3821,7 +3827,15 @@ static int tg3_poll_work(struct tg3 *tp, int work_done, int budget)
 			sblk->status = SD_STATUS_UPDATED |
 				(sblk->status & ~SD_STATUS_LINK_CHG);
 			spin_lock(&tp->lock);
-			tg3_setup_phy(tp, 0);
+			if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+				tw32_f(MAC_STATUS,
+				     (MAC_STATUS_SYNC_CHANGED |
+				      MAC_STATUS_CFG_CHANGED |
+				      MAC_STATUS_MI_COMPLETION |
+				      MAC_STATUS_LNKSTATE_CHANGED));
+				udelay(40);
+			} else
+				tg3_setup_phy(tp, 0);
 			spin_unlock(&tp->lock);
 		}
 	}
@@ -6602,7 +6616,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tg3_abort_hw(tp, 1);
 	}
 
-	if (reset_phy)
+	if (reset_phy &&
+	    !(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB))
 		tg3_phy_reset(tp);
 
 	err = tg3_chip_reset(tp);
@@ -7153,13 +7168,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(MAC_RX_MODE, tp->rx_mode);
 	udelay(10);
 
-	if (tp->link_config.phy_is_low_power) {
-		tp->link_config.phy_is_low_power = 0;
-		tp->link_config.speed = tp->link_config.orig_speed;
-		tp->link_config.duplex = tp->link_config.orig_duplex;
-		tp->link_config.autoneg = tp->link_config.orig_autoneg;
-	}
-
 	tp->mi_mode &= ~MAC_MI_MODE_AUTO_POLL;
 	tw32_f(MAC_MI_MODE, tp->mi_mode);
 	udelay(80);
@@ -7210,19 +7218,28 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	}
 
-	err = tg3_setup_phy(tp, 0);
-	if (err)
-		return err;
+	if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
+		if (tp->link_config.phy_is_low_power) {
+			tp->link_config.phy_is_low_power = 0;
+			tp->link_config.speed = tp->link_config.orig_speed;
+			tp->link_config.duplex = tp->link_config.orig_duplex;
+			tp->link_config.autoneg = tp->link_config.orig_autoneg;
+		}
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906) {
-		u32 tmp;
+		err = tg3_setup_phy(tp, 0);
+		if (err)
+			return err;
 
-		/* Clear CRC stats. */
-		if (!tg3_readphy(tp, MII_TG3_TEST1, &tmp)) {
-			tg3_writephy(tp, MII_TG3_TEST1,
-				     tmp | MII_TG3_TEST1_CRC_EN);
-			tg3_readphy(tp, 0x14, &tmp);
+		if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) &&
+		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906) {
+			u32 tmp;
+
+			/* Clear CRC stats. */
+			if (!tg3_readphy(tp, MII_TG3_TEST1, &tmp)) {
+				tg3_writephy(tp, MII_TG3_TEST1,
+					     tmp | MII_TG3_TEST1_CRC_EN);
+				tg3_readphy(tp, 0x14, &tmp);
+			}
 		}
 	}
 
@@ -9644,7 +9661,8 @@ static int tg3_test_loopback(struct tg3 *tp)
 		tw32(TG3_CPMU_MUTEX_GNT, CPMU_MUTEX_GNT_DRIVER);
 	}
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
+	if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) &&
+	    !(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
 		if (tg3_run_loopback(tp, TG3_PHY_LOOPBACK))
 			err |= TG3_PHY_LOOPBACK_FAILED;
 	}
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5643be5..a3598ed 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2480,6 +2480,7 @@ struct tg3 {
 #define TG3_FLG3_ENABLE_APE		0x00000002
 #define TG3_FLG3_5761_5784_AX_FIXES	0x00000004
 #define TG3_FLG3_5701_DMA_BUG		0x00000008
+#define TG3_FLG3_USE_PHYLIB		0x00000010
 
 	struct timer_list		timer;
 	u16				timer_counter;


