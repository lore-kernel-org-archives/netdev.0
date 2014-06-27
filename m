From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 15/30] net: fec: ensure fec_enet_close() copes with resume
 failure
Date: Fri, 27 Jun 2014 16:20:09 +0100
Message-ID: <E1X0Xwf-0001Nn-UW@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45219 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754150AbaF0PUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:20:12 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the FEC is suspended, the device is detached.  Upon resume failure,
the device is left in detached mode, possibly with some of the required
clocks not running.  We don't want to be poking the device in that state
because as it may cause bus errors.

If the device is marked detached, avoid calling fec_stop().

This depends upon: "net:fec: improve safety of suspend/resume paths"

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index caf0854b7e4f..79951af81db5 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2198,10 +2198,10 @@ fec_enet_close(struct net_device *ndev)
 
 	phy_stop(fep->phy_dev);
 
-	/* Don't know what to do yet. */
 	napi_disable(&fep->napi);
 	netif_tx_disable(ndev);
-	fec_stop(ndev);
+	if (netif_device_present(ndev))
+		fec_stop(ndev);
 
 	phy_disconnect(fep->phy_dev);
 	fep->phy_dev = NULL;
-- 
1.8.3.1
