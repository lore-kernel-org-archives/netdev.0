From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/6] tg3: Consilidate MAC loopback code
Date: Fri, 19 Aug 2011 16:58:20 -0700
Message-ID: <1313798304-26171-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2637 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662Ab1HSXu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 19:50:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver puts the device into MAC loopback in two places in the
driver.  This patch consolidates the code into a single routine.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   91 +++++++++++++++++++---------------
 1 files changed, 51 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 756e2bb..4529095 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -94,7 +94,6 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
 #define DRV_MODULE_RELDATE	"May 18, 2011"
 
-#define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
 #define TG3_DEF_TX_MODE		0
 #define TG3_DEF_MSG_ENABLE	  \
@@ -6343,6 +6342,34 @@ dma_error:
 	return NETDEV_TX_OK;
 }
 
+static void tg3_mac_loopback(struct tg3 *tp, bool enable)
+{
+	if (enable) {
+		tp->mac_mode &= ~(MAC_MODE_HALF_DUPLEX |
+				  MAC_MODE_PORT_MODE_MASK);
+
+		tp->mac_mode |= MAC_MODE_PORT_INT_LPBACK;
+
+		if (!tg3_flag(tp, 5705_PLUS))
+			tp->mac_mode |= MAC_MODE_LINK_POLARITY;
+
+		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
+			tp->mac_mode |= MAC_MODE_PORT_MODE_MII;
+		else
+			tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
+	} else {
+		tp->mac_mode &= ~MAC_MODE_PORT_INT_LPBACK;
+
+		if (tg3_flag(tp, 5705_PLUS) ||
+		    (tp->phy_flags & TG3_PHYFLG_PHY_SERDES) ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700)
+			tp->mac_mode &= ~MAC_MODE_LINK_POLARITY;
+	}
+
+	tw32(MAC_MODE, tp->mac_mode);
+	udelay(40);
+}
+
 static void tg3_set_loopback(struct net_device *dev, u32 features)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -6351,16 +6378,8 @@ static void tg3_set_loopback(struct net_device *dev, u32 features)
 		if (tp->mac_mode & MAC_MODE_PORT_INT_LPBACK)
 			return;
 
-		/*
-		 * Clear MAC_MODE_HALF_DUPLEX or you won't get packets back in
-		 * loopback mode if Half-Duplex mode was negotiated earlier.
-		 */
-		tp->mac_mode &= ~MAC_MODE_HALF_DUPLEX;
-
-		/* Enable internal MAC loopback mode */
-		tp->mac_mode |= MAC_MODE_PORT_INT_LPBACK;
 		spin_lock_bh(&tp->lock);
-		tw32(MAC_MODE, tp->mac_mode);
+		tg3_mac_loopback(tp, true);
 		netif_carrier_on(tp->dev);
 		spin_unlock_bh(&tp->lock);
 		netdev_info(dev, "Internal MAC loopback mode enabled.\n");
@@ -6368,10 +6387,8 @@ static void tg3_set_loopback(struct net_device *dev, u32 features)
 		if (!(tp->mac_mode & MAC_MODE_PORT_INT_LPBACK))
 			return;
 
-		/* Disable internal MAC loopback mode */
-		tp->mac_mode &= ~MAC_MODE_PORT_INT_LPBACK;
 		spin_lock_bh(&tp->lock);
-		tw32(MAC_MODE, tp->mac_mode);
+		tg3_mac_loopback(tp, false);
 		/* Force link status check */
 		tg3_setup_phy(tp, 1);
 		spin_unlock_bh(&tp->lock);
@@ -11269,27 +11286,7 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 	}
 	coal_now = tnapi->coal_now | rnapi->coal_now;
 
-	if (loopback_mode == TG3_MAC_LOOPBACK) {
-		/* HW errata - mac loopback fails in some cases on 5780.
-		 * Normal traffic and PHY loopback are not affected by
-		 * errata.  Also, the MAC loopback test is deprecated for
-		 * all newer ASIC revisions.
-		 */
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 ||
-		    tg3_flag(tp, CPMU_PRESENT))
-			return 0;
-
-		mac_mode = tp->mac_mode &
-			   ~(MAC_MODE_PORT_MODE_MASK | MAC_MODE_HALF_DUPLEX);
-		mac_mode |= MAC_MODE_PORT_INT_LPBACK;
-		if (!tg3_flag(tp, 5705_PLUS))
-			mac_mode |= MAC_MODE_LINK_POLARITY;
-		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
-			mac_mode |= MAC_MODE_PORT_MODE_MII;
-		else
-			mac_mode |= MAC_MODE_PORT_MODE_GMII;
-		tw32(MAC_MODE, mac_mode);
-	} else {
+	if (loopback_mode != TG3_MAC_LOOPBACK) {
 		if (tp->phy_flags & TG3_PHYFLG_IS_FET) {
 			tg3_phy_fet_toggle_apd(tp, false);
 			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED100;
@@ -11554,12 +11551,26 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
 		tg3_phy_toggle_apd(tp, false);
 
-	if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_MAC_LOOPBACK))
-		err |= TG3_STD_LOOPBACK_FAILED << TG3_MAC_LOOPBACK_SHIFT;
+	/* HW errata - mac loopback fails in some cases on 5780.
+	 * Normal traffic and PHY loopback are not affected by
+	 * errata.  Also, the MAC loopback test is deprecated for
+	 * all newer ASIC revisions.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5780 &&
+	    !tg3_flag(tp, CPMU_PRESENT)) {
+		tg3_mac_loopback(tp, true);
 
-	if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
-	    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_MAC_LOOPBACK))
-		err |= TG3_JMB_LOOPBACK_FAILED << TG3_MAC_LOOPBACK_SHIFT;
+		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_MAC_LOOPBACK))
+			err |= TG3_STD_LOOPBACK_FAILED <<
+			       TG3_MAC_LOOPBACK_SHIFT;
+
+		if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
+		    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_MAC_LOOPBACK))
+			err |= TG3_JMB_LOOPBACK_FAILED <<
+			       TG3_MAC_LOOPBACK_SHIFT;
+
+		tg3_mac_loopback(tp, false);
+	}
 
 	if (!(tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
 	    !tg3_flag(tp, USE_PHYLIB)) {
@@ -14335,7 +14346,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tg3_flag(tp, ENABLE_APE))
 		tp->mac_mode = MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
 	else
-		tp->mac_mode = TG3_DEF_MAC_MODE;
+		tp->mac_mode = 0;
 
 	/* these are limited to 10/100 only */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 &&
-- 
1.7.3.4


