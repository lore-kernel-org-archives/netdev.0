From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 18/30] net: fec: remove inappropriate calls around
 fec_restart()
Date: Fri, 20 Jun 2014 13:13:15 +0100
Message-ID: <E1Wxxgx-0005Y0-50@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36371 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967378AbaFTMNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:13:17 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second stage to "move calls to quiesce/resume packet
processing out of fec_restart()", where we remove calls which are not
appropriate to the call site.

In the majority of cases, there is no need to detach and reattach the
interface as we are holding the queue xmit lock across the reset.  The
exception to that is in fec_resume(), where we are already detached by
the suspend function.  Here, we can remove the call to detach the
interface.

We also do not need to stop the transmit queue.  Holding the xmit lock
is enough to ensure that the transmit packet processing is not running
while we perform our task.  However, since fec_restart() always cleans
the rings, we call netif_wake_queue() (or netif_device_attach() in the
case of resume) just before dropping the xmit lock.  This prevents the
watchdog firing.

Lastly, always call napi_enable() after the device has been reattached
in the resume path so that we know that the transmit packet processing
is already in an enabled state, so we don't call netif_wake_queue()
while detached.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 26 ++++++--------------------
 1 file changed, 6 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4a295b4bfb94..49c154af6da2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1058,15 +1058,12 @@ static void fec_enet_work(struct work_struct *work)
 		fep->delay_work.timeout = false;
 		rtnl_lock();
 		if (netif_device_present(ndev) || netif_running(ndev)) {
-			netif_device_detach(ndev);
 			napi_disable(&fep->napi);
-			netif_tx_disable(ndev);
 			netif_tx_lock_bh(ndev);
 			fec_restart(ndev, fep->full_duplex);
-			netif_tx_unlock_bh(ndev);
 			netif_wake_queue(ndev);
+			netif_tx_unlock_bh(ndev);
 			napi_enable(&fep->napi);
-			netif_device_attach(ndev);
 		}
 		rtnl_unlock();
 	}
@@ -1524,15 +1521,12 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 
 		/* if any of the above changed restart the FEC */
 		if (status_change) {
-			netif_device_detach(ndev);
 			napi_disable(&fep->napi);
-			netif_tx_disable(ndev);
 			netif_tx_lock_bh(ndev);
 			fec_restart(ndev, phy_dev->duplex);
-			netif_tx_unlock_bh(ndev);
 			netif_wake_queue(ndev);
+			netif_tx_unlock_bh(ndev);
 			napi_enable(&fep->napi);
-			netif_device_attach(ndev);
 		}
 	} else {
 		if (fep->link) {
@@ -1919,15 +1913,12 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 		phy_start_aneg(fep->phy_dev);
 	}
 	if (netif_running(ndev)) {
-		netif_device_detach(ndev);
 		napi_disable(&fep->napi);
-		netif_tx_disable(ndev);
 		netif_tx_lock_bh(ndev);
 		fec_restart(ndev, fep->full_duplex);
-		netif_tx_unlock_bh(ndev);
 		netif_wake_queue(ndev);
+		netif_tx_unlock_bh(ndev);
 		napi_enable(&fep->napi);
-		netif_device_attach(ndev);
 	}
 
 	return 0;
@@ -2372,15 +2363,12 @@ static int fec_set_features(struct net_device *netdev,
 
 		if (netif_running(netdev)) {
 			fec_stop(netdev);
-			netif_device_detach(netdev);
 			napi_disable(&fep->napi);
-			netif_tx_disable(netdev);
 			netif_tx_lock_bh(netdev);
 			fec_restart(netdev, fep->phy_dev->duplex);
-			netif_tx_unlock_bh(netdev);
 			netif_wake_queue(netdev);
+			netif_tx_unlock_bh(netdev);
 			napi_enable(&fep->napi);
-			netif_device_attach(netdev);
 		}
 	}
 
@@ -2748,15 +2736,13 @@ fec_resume(struct device *dev)
 
 	rtnl_lock();
 	if (netif_running(ndev)) {
-		netif_device_detach(ndev);
 		napi_disable(&fep->napi);
-		netif_tx_disable(ndev);
 		netif_tx_lock_bh(ndev);
 		fec_restart(ndev, fep->full_duplex);
+		netif_device_attach(ndev);
 		netif_tx_unlock_bh(ndev);
-		netif_wake_queue(ndev);
-		napi_enable(&fep->napi);
 		netif_device_attach(ndev);
+		napi_enable(&fep->napi);
 		phy_start(fep->phy_dev);
 	}
 	rtnl_unlock();
-- 
1.8.3.1
