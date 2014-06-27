From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 20/30] net: fec: quiesce packet processing before stopping
 device in fec_set_features()
Date: Fri, 27 Jun 2014 16:20:35 +0100
Message-ID: <E1X0Xx5-0001OJ-G0@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45238 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754253AbaF0PUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:20:38 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_set_features() calls fec_stop() to stop the transmit ring while the
transmit queue is still active.  This can lead to the transmit ring
being restarted by an intervening packet queued for transmission, or
by the tx quirk timer expiring.

Fix this by disabling NAPI (which ensures that the NAPI handlers are
not running), and then take the transmit lock while we stop and
restart the adapter (which prevents new packets being queued).

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 7a3cfb19ae90..cc2fab7333fe 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2363,9 +2363,9 @@ static int fec_set_features(struct net_device *netdev,
 			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
 
 		if (netif_running(netdev)) {
-			fec_stop(netdev);
 			napi_disable(&fep->napi);
 			netif_tx_lock_bh(netdev);
+			fec_stop(netdev);
 			fec_restart(netdev, fep->phy_dev->duplex);
 			netif_wake_queue(netdev);
 			netif_tx_unlock_bh(netdev);
-- 
1.8.3.1
