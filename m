From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH] net: fec: Fix sparse warnings with different lock contexts for basic block
Date: Sat, 11 Oct 2014 11:00:29 +0800
Message-ID: <1412996429-2253-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <festevam@gmail.com>,
	<sparse@chrisli.org>, <b20596@freescale.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0145.outbound.protection.outlook.com ([157.56.110.145]:20065
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750795AbaJKDa7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 23:30:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reproduce:
make  ARCH=arm C=1 2>fec.txt drivers/net/ethernet/freescale/fec_main.o
cat fec.txt

sparse warnings:
drivers/net/ethernet/freescale/fec_main.c:2916:12: warning: context imbalance
in 'fec_set_features' - different lock contexts for basic block

Christopher Li suggest to change as below:
	if (need_lock) {
		lock();
		do_something_real();
		unlock();
	} else {
		do_something_real();
	}

Reported-by: Fabio Estevam <festevam@gmail.com>
Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Christopher Li <sparse@chrisli.org>
---
 drivers/net/ethernet/freescale/fec_main.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 87975b5..7a8209e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2912,20 +2912,12 @@ static void fec_poll_controller(struct net_device *dev)
 #endif
 
 #define FEATURES_NEED_QUIESCE NETIF_F_RXCSUM
-
-static int fec_set_features(struct net_device *netdev,
+static inline void fec_enet_set_netdev_features(struct net_device *netdev,
 	netdev_features_t features)
 {
 	struct fec_enet_private *fep = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
 
-	/* Quiesce the device if necessary */
-	if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {
-		napi_disable(&fep->napi);
-		netif_tx_lock_bh(netdev);
-		fec_stop(netdev);
-	}
-
 	netdev->features = features;
 
 	/* Receive checksum has been changed */
@@ -2935,13 +2927,25 @@ static int fec_set_features(struct net_device *netdev,
 		else
 			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
 	}
+}
+
+static int fec_set_features(struct net_device *netdev,
+	netdev_features_t features)
+{
+	struct fec_enet_private *fep = netdev_priv(netdev);
+	netdev_features_t changed = features ^ netdev->features;
 
-	/* Resume the device after updates */
 	if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {
+		napi_disable(&fep->napi);
+		netif_tx_lock_bh(netdev);
+		fec_stop(netdev);
+		fec_enet_set_netdev_features(netdev, features);
 		fec_restart(netdev);
 		netif_tx_wake_all_queues(netdev);
 		netif_tx_unlock_bh(netdev);
 		napi_enable(&fep->napi);
+	} else {
+		fec_enet_set_netdev_features(netdev, features);
 	}
 
 	return 0;
-- 
1.7.8
