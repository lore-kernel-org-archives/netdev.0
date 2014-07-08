From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH B 08/10] net: fec: quiesce packet processing before changing
 features
Date: Tue, 08 Jul 2014 12:40:33 +0100
Message-ID: <E1X4TlB-0005oO-EN@rmk-PC.arm.linux.org.uk>
References: <20140708113911.GH21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58535 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754444AbaGHLkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 07:40:35 -0400
In-Reply-To: <20140708113911.GH21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the features (receive checksumming) requires the hardware to be
reprogrammed, and also changes the checks in the receive packet
processing.

The current implementation has a race - fec_set_features() changes the
flags which alter the receive packet processing while the adapter is
active, and potentially receiving frames.  Only after we've modified
the software flag do we shutdown and reconfigure the hardware.

This can lead to packets being received and marked with a valid checksum
(via CHECKSUM_UNNECESSARY) when the hardware checksum validation has not
yet been enabled.

We must quiesce the device, then change the software configuration for
this feature, and then resume the device if it was previously running.

The resulting code structure also allows us to add other configuration
features in this path without having to quiesce and resume the network
interface and device.

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 2945cf6e65cf..124d3c5f8046 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2346,12 +2346,21 @@ static void fec_poll_controller(struct net_device *dev)
 }
 #endif
 
+#define FEATURES_NEED_QUIESCE NETIF_F_RXCSUM
+
 static int fec_set_features(struct net_device *netdev,
 	netdev_features_t features)
 {
 	struct fec_enet_private *fep = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
 
+	/* Quiesce the device if necessary */
+	if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {
+		napi_disable(&fep->napi);
+		netif_tx_lock_bh(netdev);
+		fec_stop(netdev);
+	}
+
 	netdev->features = features;
 
 	/* Receive checksum has been changed */
@@ -2360,16 +2369,14 @@ static int fec_set_features(struct net_device *netdev,
 			fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
 		else
 			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
+	}
 
-		if (netif_running(netdev)) {
-			napi_disable(&fep->napi);
-			netif_tx_lock_bh(netdev);
-			fec_stop(netdev);
-			fec_restart(netdev, fep->phy_dev->duplex);
-			netif_wake_queue(netdev);
-			netif_tx_unlock_bh(netdev);
-			napi_enable(&fep->napi);
-		}
+	/* Resume the device after updates */
+	if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {
+		fec_restart(netdev, fep->phy_dev->duplex);
+		netif_wake_queue(netdev);
+		netif_tx_unlock_bh(netdev);
+		napi_enable(&fep->napi);
 	}
 
 	return 0;
-- 
1.8.3.1
