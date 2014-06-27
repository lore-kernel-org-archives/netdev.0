From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 17/30] net: fec: move calls to quiesce/resume packet
 processing out of fec_restart()
Date: Fri, 27 Jun 2014 16:20:20 +0100
Message-ID: <E1X0Xwq-0001Ny-5d@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45226 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754213AbaF0PUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:20:23 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the calls to quiesce and resume packet processing out of
fec_restart() to its call sites.  This is the first step in a two stage
clean up of this code, where we just move the calls out of fec_restart()
without changing them.  Not everywhere needs to issue these calls, and
not everywhere needs all of these calls to be issued.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 64 ++++++++++++++++++++++---------
 1 file changed, 45 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fc155ba85146..4a295b4bfb94 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -818,9 +818,10 @@ static void fec_enet_bd_init(struct net_device *dev)
 	fep->dirty_tx = bdp;
 }
 
-/* This function is called to start or restart the FEC during a link
- * change.  This only happens when switching between half and full
- * duplex.
+/*
+ * This function is called to start or restart the FEC during a link
+ * change, transmit timeout, or to reconfigure the FEC.  The network
+ * packet processing for this device must be stopped before this call.
  */
 static void
 fec_restart(struct net_device *ndev, int duplex)
@@ -834,13 +835,6 @@ fec_restart(struct net_device *ndev, int duplex)
 	u32 rcntl = OPT_FRAME_SIZE | 0x04;
 	u32 ecntl = 0x2; /* ETHEREN */
 
-	if (netif_running(ndev)) {
-		netif_device_detach(ndev);
-		napi_disable(&fep->napi);
-		netif_tx_disable(ndev);
-		netif_tx_lock_bh(ndev);
-	}
-
 	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
@@ -1009,13 +1003,6 @@ fec_restart(struct net_device *ndev, int duplex)
 
 	/* Enable interrupts we wish to service */
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
-
-	if (netif_running(ndev)) {
-		netif_tx_unlock_bh(ndev);
-		netif_wake_queue(ndev);
-		napi_enable(&fep->napi);
-		netif_device_attach(ndev);
-	}
 }
 
 static void
@@ -1071,8 +1058,15 @@ static void fec_enet_work(struct work_struct *work)
 		fep->delay_work.timeout = false;
 		rtnl_lock();
 		if (netif_device_present(ndev) || netif_running(ndev)) {
+			netif_device_detach(ndev);
+			napi_disable(&fep->napi);
+			netif_tx_disable(ndev);
+			netif_tx_lock_bh(ndev);
 			fec_restart(ndev, fep->full_duplex);
+			netif_tx_unlock_bh(ndev);
 			netif_wake_queue(ndev);
+			napi_enable(&fep->napi);
+			netif_device_attach(ndev);
 		}
 		rtnl_unlock();
 	}
@@ -1529,8 +1523,17 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 		}
 
 		/* if any of the above changed restart the FEC */
-		if (status_change)
+		if (status_change) {
+			netif_device_detach(ndev);
+			napi_disable(&fep->napi);
+			netif_tx_disable(ndev);
+			netif_tx_lock_bh(ndev);
 			fec_restart(ndev, phy_dev->duplex);
+			netif_tx_unlock_bh(ndev);
+			netif_wake_queue(ndev);
+			napi_enable(&fep->napi);
+			netif_device_attach(ndev);
+		}
 	} else {
 		if (fep->link) {
 			fec_stop(ndev);
@@ -1915,8 +1918,17 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 			fec_stop(ndev);
 		phy_start_aneg(fep->phy_dev);
 	}
-	if (netif_running(ndev))
+	if (netif_running(ndev)) {
+		netif_device_detach(ndev);
+		napi_disable(&fep->napi);
+		netif_tx_disable(ndev);
+		netif_tx_lock_bh(ndev);
 		fec_restart(ndev, fep->full_duplex);
+		netif_tx_unlock_bh(ndev);
+		netif_wake_queue(ndev);
+		napi_enable(&fep->napi);
+		netif_device_attach(ndev);
+	}
 
 	return 0;
 }
@@ -2360,8 +2372,15 @@ static int fec_set_features(struct net_device *netdev,
 
 		if (netif_running(netdev)) {
 			fec_stop(netdev);
+			netif_device_detach(netdev);
+			napi_disable(&fep->napi);
+			netif_tx_disable(netdev);
+			netif_tx_lock_bh(netdev);
 			fec_restart(netdev, fep->phy_dev->duplex);
+			netif_tx_unlock_bh(netdev);
 			netif_wake_queue(netdev);
+			napi_enable(&fep->napi);
+			netif_device_attach(netdev);
 		}
 	}
 
@@ -2729,7 +2748,14 @@ fec_resume(struct device *dev)
 
 	rtnl_lock();
 	if (netif_running(ndev)) {
+		netif_device_detach(ndev);
+		napi_disable(&fep->napi);
+		netif_tx_disable(ndev);
+		netif_tx_lock_bh(ndev);
 		fec_restart(ndev, fep->full_duplex);
+		netif_tx_unlock_bh(ndev);
+		netif_wake_queue(ndev);
+		napi_enable(&fep->napi);
 		netif_device_attach(ndev);
 		phy_start(fep->phy_dev);
 	}
-- 
1.8.3.1
