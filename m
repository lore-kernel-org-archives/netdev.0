From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH A 07/12] net: fec: stop the phy before shutting down the MAC
Date: Tue, 08 Jul 2014 00:23:04 +0100
Message-ID: <E1X4IFU-0004x5-Kp@rmk-PC.arm.linux.org.uk>
References: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:57987 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752791AbaGGXXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 19:23:06 -0400
In-Reply-To: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the network interface goes down, stop the phy to prevent further
link up status changes before taking the MAC or netif sections down.
This prevents further reception of link up events which could
potentially call fec_restart().

Since phy_stop() takes the mutex which adjust_link() runs under, we
also ensure that adjust_link() will not already be processing a link
up event.

We also need to do this when suspending as well - we don't want a
mis-timed phy state change to restart the MAC after we have stopped
it for suspend, and thus need to restart the phy when resuming.

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cf805468eecc..e0a1ac1826b7 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2181,13 +2181,14 @@ fec_enet_close(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	phy_stop(fep->phy_dev);
+
 	/* Don't know what to do yet. */
 	napi_disable(&fep->napi);
 	fep->opened = 0;
 	netif_tx_disable(ndev);
 	fec_stop(ndev);
 
-	phy_stop(fep->phy_dev);
 	phy_disconnect(fep->phy_dev);
 	fep->phy_dev = NULL;
 
@@ -2669,6 +2670,7 @@ fec_suspend(struct device *dev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
 	if (netif_running(ndev)) {
+		phy_stop(fep->phy_dev);
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
@@ -2702,6 +2704,7 @@ fec_resume(struct device *dev)
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
 		netif_device_attach(ndev);
+		phy_start(fep->phy_dev);
 	}
 
 	return 0;
-- 
1.8.3.1
