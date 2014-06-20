From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 21/30] net: fec: quiesce packet processing before changing
 features
Date: Fri, 20 Jun 2014 13:13:30 +0100
Message-ID: <E1WxxhC-0005YC-Fe@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36381 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967419AbaFTMNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:13:32 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
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

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cc2fab7333fe..466268fffadd 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2347,12 +2347,21 @@ static void fec_poll_controller(struct net_device *dev)
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
@@ -2361,16 +2370,14 @@ static int fec_set_features(struct net_device *netdev,
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
