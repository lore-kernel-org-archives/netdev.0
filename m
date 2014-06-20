From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 23/30] net: fec: clean up duplex mode handling
Date: Fri, 20 Jun 2014 13:13:40 +0100
Message-ID: <E1WxxhM-0005YL-MV@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36388 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967290AbaFTMNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:13:42 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many places call fec_restart() with the second parameter being some kind
of previously saved duplex value, but only two places call it with some
other setting.  This is at odds with how the other link settings are
handled, and used to be racy before the rtnl locks were added to
fec_restart()'s various call paths.

Clean this up so all link capabilities are handled in the same way -
saved into the fec_enet_private structure, and then fec_restart() acts
on those settings.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b2b8aff3f73c..62120e47ef5a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -824,7 +824,7 @@ static void fec_enet_bd_init(struct net_device *dev)
  * packet processing for this device must be stopped before this call.
  */
 static void
-fec_restart(struct net_device *ndev, int duplex)
+fec_restart(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	const struct platform_device_id *id_entry =
@@ -875,7 +875,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	}
 
 	/* Enable MII mode */
-	if (duplex) {
+	if (fep->full_duplex == DUPLEX_FULL) {
 		/* FD enable */
 		writel(0x04, fep->hwp + FEC_X_CNTRL);
 	} else {
@@ -884,8 +884,6 @@ fec_restart(struct net_device *ndev, int duplex)
 		writel(0x0, fep->hwp + FEC_X_CNTRL);
 	}
 
-	fep->full_duplex = duplex;
-
 	/* Set MII speed */
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
@@ -1060,7 +1058,7 @@ static void fec_enet_work(struct work_struct *work)
 		if (netif_device_present(ndev) || netif_running(ndev)) {
 			napi_disable(&fep->napi);
 			netif_tx_lock_bh(ndev);
-			fec_restart(ndev, fep->full_duplex);
+			fec_restart(ndev);
 			netif_wake_queue(ndev);
 			netif_tx_unlock_bh(ndev);
 			napi_enable(&fep->napi);
@@ -1511,8 +1509,10 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 			status_change = 1;
 		}
 
-		if (fep->full_duplex != phy_dev->duplex)
+		if (fep->full_duplex != phy_dev->duplex) {
+			fep->full_duplex = phy_dev->duplex;
 			status_change = 1;
+		}
 
 		if (phy_dev->speed != fep->speed) {
 			fep->speed = phy_dev->speed;
@@ -1523,7 +1523,7 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 		if (status_change) {
 			napi_disable(&fep->napi);
 			netif_tx_lock_bh(ndev);
-			fec_restart(ndev, phy_dev->duplex);
+			fec_restart(ndev);
 			netif_wake_queue(ndev);
 			netif_tx_unlock_bh(ndev);
 			napi_enable(&fep->napi);
@@ -1919,7 +1919,7 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 	if (netif_running(ndev)) {
 		napi_disable(&fep->napi);
 		netif_tx_lock_bh(ndev);
-		fec_restart(ndev, fep->full_duplex);
+		fec_restart(ndev);
 		netif_wake_queue(ndev);
 		netif_tx_unlock_bh(ndev);
 		napi_enable(&fep->napi);
@@ -2202,7 +2202,7 @@ fec_enet_open(struct net_device *ndev)
 		return ret;
 	}
 
-	fec_restart(ndev, fep->full_duplex);
+	fec_restart(ndev);
 	napi_enable(&fep->napi);
 	phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
@@ -2378,7 +2378,7 @@ static int fec_set_features(struct net_device *netdev,
 
 	/* Resume the device after updates */
 	if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {
-		fec_restart(netdev, fep->phy_dev->duplex);
+		fec_restart(netdev);
 		netif_wake_queue(netdev);
 		netif_tx_unlock_bh(netdev);
 		napi_enable(&fep->napi);
@@ -2482,7 +2482,7 @@ static int fec_enet_init(struct net_device *ndev)
 
 	ndev->hw_features = ndev->features;
 
-	fec_restart(ndev, 0);
+	fec_restart(ndev);
 
 	return 0;
 }
@@ -2751,7 +2751,7 @@ fec_resume(struct device *dev)
 
 	rtnl_lock();
 	if (netif_running(ndev)) {
-		fec_restart(ndev, fep->full_duplex);
+		fec_restart(ndev);
 		netif_tx_lock_bh(ndev);
 		netif_device_attach(ndev);
 		netif_tx_unlock_bh(ndev);
-- 
1.8.3.1
