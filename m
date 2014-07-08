From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH B 02/10] net: fec: ensure fec_enet_close() copes with resume
 failure
Date: Tue, 08 Jul 2014 12:40:02 +0100
Message-ID: <E1X4Tkg-0005nu-Mj@rmk-PC.arm.linux.org.uk>
References: <20140708113911.GH21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58517 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754370AbaGHLkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 07:40:05 -0400
In-Reply-To: <20140708113911.GH21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the FEC is suspended, the device is detached.  Upon resume failure,
the device is left in detached mode, possibly with some of the required
clocks not running.  We don't want to be poking the device in that state
because as it may cause bus errors.

If the device is marked detached, avoid calling fec_stop().

This depends upon: "net:fec: improve safety of suspend/resume paths"

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1cd71a8d9996..03785cd14b7c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2197,10 +2197,10 @@ fec_enet_close(struct net_device *ndev)
 
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
