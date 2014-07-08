From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH B 06/10] net: fec: quiesce packet processing before stopping
 device in fec_suspend()
Date: Tue, 08 Jul 2014 12:40:23 +0100
Message-ID: <E1X4Tl1-0005oD-6z@rmk-PC.arm.linux.org.uk>
References: <20140708113911.GH21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58529 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754444AbaGHLkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 07:40:25 -0400
In-Reply-To: <20140708113911.GH21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_suspend() calls fec_stop() to stop the transmit ring while the
transmit packet processing is still active.  This can lead to the
transmit queue being restarted by an intervening packet queued for
transmission, or by the tx quirk timer expiring.

Fix this by disabling NAPI first, which will ensure that the NAPI
handlers are not running.  Then, take the transmit lock before
detaching the netif device.  This ensures that there are no races
with the transmit path - and also ensures that the watchdog won't
fire.

We can then safely stop the ethernet device itself, knowing that the
rest of the driver is safely shut down.

On resume, we bring the device back up in reverse order - we restart
the device, reattach the device (under the tx lock), and then enable
the NAPI handlers.

We also need to adjust the close function to cope with this new
sequence, so that it's possible to cleanly close down the driver
after the hardware fails to resume (eg, due to the regulator_enable()
or pinctrl calls in the resume path returning an error.)

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 25a9f7fb30da..fc9f6f465e7a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2211,10 +2211,11 @@ fec_enet_close(struct net_device *ndev)
 
 	phy_stop(fep->phy_dev);
 
-	napi_disable(&fep->napi);
-	netif_tx_disable(ndev);
-	if (netif_device_present(ndev))
+	if (netif_device_present(ndev)) {
+		napi_disable(&fep->napi);
+		netif_tx_disable(ndev);
 		fec_stop(ndev);
+	}
 
 	phy_disconnect(fep->phy_dev);
 	fep->phy_dev = NULL;
@@ -2701,8 +2702,11 @@ fec_suspend(struct device *dev)
 	rtnl_lock();
 	if (netif_running(ndev)) {
 		phy_stop(fep->phy_dev);
-		fec_stop(ndev);
+		napi_disable(&fep->napi);
+		netif_tx_lock_bh(ndev);
 		netif_device_detach(ndev);
+		netif_tx_unlock_bh(ndev);
+		fec_stop(ndev);
 	}
 	rtnl_unlock();
 
@@ -2735,12 +2739,10 @@ fec_resume(struct device *dev)
 
 	rtnl_lock();
 	if (netif_running(ndev)) {
-		napi_disable(&fep->napi);
-		netif_tx_lock_bh(ndev);
 		fec_restart(ndev, fep->full_duplex);
+		netif_tx_lock_bh(ndev);
 		netif_device_attach(ndev);
 		netif_tx_unlock_bh(ndev);
-		netif_device_attach(ndev);
 		napi_enable(&fep->napi);
 		phy_start(fep->phy_dev);
 	}
-- 
1.8.3.1
