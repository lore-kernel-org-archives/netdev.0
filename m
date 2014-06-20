From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 15/30] net: fec: ensure fec_enet_close() copes with resume
 failure
Date: Fri, 20 Jun 2014 13:12:59 +0100
Message-ID: <E1Wxxgh-0005Xo-QP@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36362 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967378AbaFTMNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:13:02 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
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
