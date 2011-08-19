From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/6] tg3: Pull phy int lpbk setup into separate
 func
Date: Fri, 19 Aug 2011 16:58:21 -0700
Message-ID: <1313798304-26171-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2639 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756169Ab1HSXu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 19:50:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch pulls out the internal phy loopback setup code into a
separate function.  This cleans up the loopback test code and makes it
available for NETIF_F_LOOPBACK support later.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  149 +++++++++++++++++++++--------------
 1 files changed, 90 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 4529095..5e9d8a0 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6370,6 +6370,80 @@ static void tg3_mac_loopback(struct tg3 *tp, bool enable)
 	udelay(40);
 }
 
+static void tg3_phy_lpbk_set(struct tg3 *tp, u32 speed)
+{
+	u32 val, bmcr, mac_mode;
+
+	tg3_phy_toggle_apd(tp, false);
+	tg3_phy_toggle_automdix(tp, 0);
+
+	bmcr = BMCR_LOOPBACK | BMCR_FULLDPLX;
+	switch (speed) {
+	case SPEED_10:
+		break;
+	case SPEED_100:
+		bmcr |= BMCR_SPEED100;
+		break;
+	case SPEED_1000:
+	default:
+		if (tp->phy_flags & TG3_PHYFLG_IS_FET) {
+			speed = SPEED_100;
+			bmcr |= BMCR_SPEED100;
+		} else {
+			speed = SPEED_1000;
+			bmcr |= BMCR_SPEED1000;
+		}
+	}
+
+	tg3_writephy(tp, MII_BMCR, bmcr);
+
+	/* The write needs to be flushed for the FETs */
+	if (tp->phy_flags & TG3_PHYFLG_IS_FET)
+		tg3_readphy(tp, MII_BMCR, &bmcr);
+
+	udelay(40);
+
+	if ((tp->phy_flags & TG3_PHYFLG_IS_FET) &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
+		tg3_writephy(tp, MII_TG3_FET_PTEST,
+			     MII_TG3_FET_PTEST_FRC_TX_LINK |
+			     MII_TG3_FET_PTEST_FRC_TX_LOCK);
+
+		/* The write needs to be flushed for the AC131 */
+		tg3_readphy(tp, MII_TG3_FET_PTEST, &val);
+	}
+
+	/* Reset to prevent losing 1st rx packet intermittently */
+	if ((tp->phy_flags & TG3_PHYFLG_MII_SERDES) &&
+	    tg3_flag(tp, 5780_CLASS)) {
+		tw32_f(MAC_RX_MODE, RX_MODE_RESET);
+		udelay(10);
+		tw32_f(MAC_RX_MODE, tp->rx_mode);
+	}
+
+	mac_mode = tp->mac_mode &
+		   ~(MAC_MODE_PORT_MODE_MASK | MAC_MODE_HALF_DUPLEX);
+	if (speed == SPEED_1000)
+		mac_mode |= MAC_MODE_PORT_MODE_GMII;
+	else
+		mac_mode |= MAC_MODE_PORT_MODE_MII;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) {
+		u32 masked_phy_id = tp->phy_id & TG3_PHY_ID_MASK;
+
+		if (masked_phy_id == TG3_PHY_ID_BCM5401)
+			mac_mode &= ~MAC_MODE_LINK_POLARITY;
+		else if (masked_phy_id == TG3_PHY_ID_BCM5411)
+			mac_mode |= MAC_MODE_LINK_POLARITY;
+
+		tg3_writephy(tp, MII_TG3_EXT_CTRL,
+			     MII_TG3_EXT_CTRL_LNK3_LED_MODE);
+	}
+
+	tw32(MAC_MODE, mac_mode);
+	udelay(40);
+}
+
 static void tg3_set_loopback(struct net_device *dev, u32 features)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -11265,7 +11339,7 @@ static const u8 tg3_tso_header[] = {
 
 static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 {
-	u32 mac_mode, rx_start_idx, rx_idx, tx_idx, opaque_key;
+	u32 rx_start_idx, rx_idx, tx_idx, opaque_key;
 	u32 base_flags = 0, mss = 0, desc_idx, coal_now, data_off, val;
 	u32 budget;
 	struct sk_buff *skb, *rx_skb;
@@ -11286,56 +11360,6 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 	}
 	coal_now = tnapi->coal_now | rnapi->coal_now;
 
-	if (loopback_mode != TG3_MAC_LOOPBACK) {
-		if (tp->phy_flags & TG3_PHYFLG_IS_FET) {
-			tg3_phy_fet_toggle_apd(tp, false);
-			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED100;
-		} else
-			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED1000;
-
-		tg3_phy_toggle_automdix(tp, 0);
-
-		tg3_writephy(tp, MII_BMCR, val);
-		udelay(40);
-
-		mac_mode = tp->mac_mode &
-			   ~(MAC_MODE_PORT_MODE_MASK | MAC_MODE_HALF_DUPLEX);
-		if (tp->phy_flags & TG3_PHYFLG_IS_FET) {
-			tg3_writephy(tp, MII_TG3_FET_PTEST,
-				     MII_TG3_FET_PTEST_FRC_TX_LINK |
-				     MII_TG3_FET_PTEST_FRC_TX_LOCK);
-			/* The write needs to be flushed for the AC131 */
-			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
-				tg3_readphy(tp, MII_TG3_FET_PTEST, &val);
-			mac_mode |= MAC_MODE_PORT_MODE_MII;
-		} else
-			mac_mode |= MAC_MODE_PORT_MODE_GMII;
-
-		/* reset to prevent losing 1st rx packet intermittently */
-		if (tp->phy_flags & TG3_PHYFLG_MII_SERDES) {
-			tw32_f(MAC_RX_MODE, RX_MODE_RESET);
-			udelay(10);
-			tw32_f(MAC_RX_MODE, tp->rx_mode);
-		}
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) {
-			u32 masked_phy_id = tp->phy_id & TG3_PHY_ID_MASK;
-			if (masked_phy_id == TG3_PHY_ID_BCM5401)
-				mac_mode &= ~MAC_MODE_LINK_POLARITY;
-			else if (masked_phy_id == TG3_PHY_ID_BCM5411)
-				mac_mode |= MAC_MODE_LINK_POLARITY;
-			tg3_writephy(tp, MII_TG3_EXT_CTRL,
-				     MII_TG3_EXT_CTRL_LNK3_LED_MODE);
-		}
-		tw32(MAC_MODE, mac_mode);
-
-		/* Wait for link */
-		for (i = 0; i < 100; i++) {
-			if (tr32(MAC_TX_STATUS) & TX_STATUS_LINK_UP)
-				break;
-			mdelay(1);
-		}
-	}
-
 	err = -EIO;
 
 	tx_len = pktsz;
@@ -11547,10 +11571,6 @@ static int tg3_test_loopback(struct tg3 *tp)
 			tw32(i, 0x0);
 	}
 
-	/* Turn off gphy autopowerdown. */
-	if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
-		tg3_phy_toggle_apd(tp, false);
-
 	/* HW errata - mac loopback fails in some cases on 5780.
 	 * Normal traffic and PHY loopback are not affected by
 	 * errata.  Also, the MAC loopback test is deprecated for
@@ -11574,6 +11594,17 @@ static int tg3_test_loopback(struct tg3 *tp)
 
 	if (!(tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
 	    !tg3_flag(tp, USE_PHYLIB)) {
+		int i;
+
+		tg3_phy_lpbk_set(tp, 0);
+
+		/* Wait for link */
+		for (i = 0; i < 100; i++) {
+			if (tr32(MAC_TX_STATUS) & TX_STATUS_LINK_UP)
+				break;
+			mdelay(1);
+		}
+
 		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_PHY_LOOPBACK))
 			err |= TG3_STD_LOOPBACK_FAILED <<
 			       TG3_PHY_LOOPBACK_SHIFT;
@@ -11585,11 +11616,11 @@ static int tg3_test_loopback(struct tg3 *tp)
 		    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_PHY_LOOPBACK))
 			err |= TG3_JMB_LOOPBACK_FAILED <<
 			       TG3_PHY_LOOPBACK_SHIFT;
-	}
 
-	/* Re-enable gphy autopowerdown. */
-	if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
-		tg3_phy_toggle_apd(tp, true);
+		/* Re-enable gphy autopowerdown. */
+		if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
+			tg3_phy_toggle_apd(tp, true);
+	}
 
 done:
 	tp->phy_flags |= eee_cap;
-- 
1.7.3.4


