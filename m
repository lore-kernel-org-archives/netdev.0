From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/9][TG3]: PHY fixes.
Date: Wed, 27 Sep 2006 13:34:34 -0700
Message-ID: <1159389274.3411.20.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:57355 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030787AbWI0Uh4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:37:56 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: PHY fixes.

Some PHY related fixes:

1. Fix Serdes WoL.
2. Fix loopback test on 10/100 only devices.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6af8ebc..14e9645 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1117,6 +1117,12 @@ static void tg3_nvram_unlock(struct tg3 
 
 static void tg3_power_down_phy(struct tg3 *tp)
 {
+	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
+		return;
+
+	tg3_writephy(tp, MII_TG3_EXT_CTRL, MII_TG3_EXT_CTRL_FORCE_LED_OFF);
+	tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x01b2);
+
 	/* The PHY should not be powered down on some chips because
 	 * of bugs.
 	 */
@@ -1223,7 +1229,10 @@ static int tg3_set_power_state(struct tg
 			tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x5a);
 			udelay(40);
 
-			mac_mode = MAC_MODE_PORT_MODE_MII;
+			if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)
+				mac_mode = MAC_MODE_PORT_MODE_GMII;
+			else
+				mac_mode = MAC_MODE_PORT_MODE_MII;
 
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 ||
 			    !(tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB))
@@ -1301,15 +1310,8 @@ static int tg3_set_power_state(struct tg
 	}
 
 	if (!(tp->tg3_flags & TG3_FLAG_WOL_ENABLE) &&
-	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
-		/* Turn off the PHY */
-		if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
-			tg3_writephy(tp, MII_TG3_EXT_CTRL,
-				     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
-			tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x01b2);
-			tg3_power_down_phy(tp);
-		}
-	}
+	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
+		tg3_power_down_phy(tp);
 
 	tg3_frob_aux_power(tp);
 
@@ -7889,7 +7891,7 @@ static int tg3_set_wol(struct net_device
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 	if ((wol->wolopts & WAKE_MAGIC) &&
-	    tp->tg3_flags2 & TG3_FLG2_PHY_SERDES &&
+	    tp->tg3_flags2 & TG3_FLG2_ANY_SERDES &&
 	    !(tp->tg3_flags & TG3_FLAG_SERDES_WOL_CAP))
 		return -EINVAL;
 
@@ -8573,12 +8575,22 @@ static int tg3_run_loopback(struct tg3 *
 			return 0;
 
 		mac_mode = (tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK) |
-			   MAC_MODE_PORT_INT_LPBACK | MAC_MODE_LINK_POLARITY |
-			   MAC_MODE_PORT_MODE_GMII;
+			   MAC_MODE_PORT_INT_LPBACK | MAC_MODE_LINK_POLARITY;
+		if (tp->tg3_flags & TG3_FLAG_10_100_ONLY)
+			mac_mode |= MAC_MODE_PORT_MODE_MII;
+		else
+			mac_mode |= MAC_MODE_PORT_MODE_GMII;
 		tw32(MAC_MODE, mac_mode);
 	} else if (loopback_mode == TG3_PHY_LOOPBACK) {
-		tg3_writephy(tp, MII_BMCR, BMCR_LOOPBACK | BMCR_FULLDPLX |
-					   BMCR_SPEED1000);
+		u32 val;
+
+		val = BMCR_LOOPBACK | BMCR_FULLDPLX;
+		if (tp->tg3_flags & TG3_FLAG_10_100_ONLY)
+			val |= BMCR_SPEED100;
+		else
+			val |= BMCR_SPEED1000;
+
+		tg3_writephy(tp, MII_BMCR, val);
 		udelay(40);
 		/* reset to prevent losing 1st rx packet intermittently */
 		if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES) {
@@ -8587,7 +8599,11 @@ static int tg3_run_loopback(struct tg3 *
 			tw32_f(MAC_RX_MODE, tp->rx_mode);
 		}
 		mac_mode = (tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK) |
-			   MAC_MODE_LINK_POLARITY | MAC_MODE_PORT_MODE_GMII;
+			   MAC_MODE_LINK_POLARITY;
+		if (tp->tg3_flags & TG3_FLAG_10_100_ONLY)
+			mac_mode |= MAC_MODE_PORT_MODE_MII;
+		else
+			mac_mode |= MAC_MODE_PORT_MODE_GMII;
 		if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401) {
 			mac_mode &= ~MAC_MODE_LINK_POLARITY;
 			tg3_writephy(tp, MII_TG3_EXT_CTRL,
@@ -8636,7 +8652,8 @@ static int tg3_run_loopback(struct tg3 *
 
 	udelay(10);
 
-	for (i = 0; i < 10; i++) {
+	/* 250 usec to allow enough time on some 10/100 Mbps devices.  */
+	for (i = 0; i < 25; i++) {
 		tw32_f(HOSTCC_MODE, tp->coalesce_mode | HOSTCC_MODE_ENABLE |
 		       HOSTCC_MODE_NOW);
 


