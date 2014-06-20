From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 16/30] net: fec: only restart or stop the device if it is
 present and running
Date: Fri, 20 Jun 2014 13:13:04 +0100
Message-ID: <E1Wxxgm-0005Xs-U8@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36365 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967378AbaFTMNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:13:07 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid calling fec_restart() or fec_stop() while the device is down
or not present (iow suspended.)

Although the ndo_timeout method will only be called if the device is
present and running, we defer this to a work queue.  The work queue
can run independently, and so needs to repeat these checks to ensure
that a restart doesn't occur after the device has been taken down or
detached for suspend.  In this case, we call fec_restart() in the
resume path, so nothing is lost.

For fec_set_features, we add a call to fec_restart() in fec_enet_open()
to ensure that the hardware is appropriate programmed when the interface
is opened.  fec_set_features() call should not occur while we're
suspended, so we don't have to worry about that case.

The adjust_link needs similar treatment - this also is called from a
work queue, which may be run independently after we have taken the
device down and detached it.  In this case, we just mark the link
down and take no further action.  We will reset things appropriately
once the device is up and running again, at which point we will receive
another adjust_link callback.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 79951af81db5..fc155ba85146 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1065,12 +1065,15 @@ static void fec_enet_work(struct work_struct *work)
 		container_of(work,
 			     struct fec_enet_private,
 			     delay_work.delay_work.work);
+	struct net_device *ndev = fep->netdev;
 
 	if (fep->delay_work.timeout) {
 		fep->delay_work.timeout = false;
 		rtnl_lock();
-		fec_restart(fep->netdev, fep->full_duplex);
-		netif_wake_queue(fep->netdev);
+		if (netif_device_present(ndev) || netif_running(ndev)) {
+			fec_restart(ndev, fep->full_duplex);
+			netif_wake_queue(ndev);
+		}
 		rtnl_unlock();
 	}
 
@@ -1504,7 +1507,14 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 		return;
 	}
 
-	if (phy_dev->link) {
+	/*
+	 * If the netdev is down, or is going down, we're not interested
+	 * in link state events, so just mark our idea of the link as down
+	 * and ignore the event.
+	 */
+	if (!netif_running(ndev) || !netif_device_present(ndev)) {
+		fep->link = 0;
+	} else if (phy_dev->link) {
 		if (!fep->link) {
 			fep->link = phy_dev->link;
 			status_change = 1;
@@ -2185,6 +2195,7 @@ fec_enet_open(struct net_device *ndev)
 		return ret;
 	}
 
+	fec_restart(ndev, fep->full_duplex);
 	napi_enable(&fep->napi);
 	phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
@@ -2351,8 +2362,6 @@ static int fec_set_features(struct net_device *netdev,
 			fec_stop(netdev);
 			fec_restart(netdev, fep->phy_dev->duplex);
 			netif_wake_queue(netdev);
-		} else {
-			fec_restart(netdev, fep->phy_dev->duplex);
 		}
 	}
 
-- 
1.8.3.1
