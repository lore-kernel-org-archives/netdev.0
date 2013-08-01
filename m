From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v3 01/13] tile: set hw_features and vlan_features in setup
Date: Thu, 1 Aug 2013 11:36:42 -0400
Message-ID: <07af860a72f3ef63cb517aae9894147ee6390f74.1375385119.git.cmetcalf@tilera.com>
References: <20130801.113100.2059303096028571906.davem@davemloft.net>
	<cover.1375385119.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375385119.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change allows the user to configure various features of the tile
networking drivers on and off.  There is no change to the default
initialization state of either the tilegx or tilepro drivers.

Neither driver needs the ndo_fix_features or ndo_set_features callbacks,
since the generic code already handles the dependencies for
fix_features, and there is no hardware state to tweak in set_features.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c  | 15 +++++++++----
 drivers/net/ethernet/tile/tilepro.c | 43 ++++++++++++-------------------------
 2 files changed, 25 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index f3c2d03..6085571 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -1800,14 +1800,21 @@ static const struct net_device_ops tile_net_ops = {
  */
 static void tile_net_setup(struct net_device *dev)
 {
+	netdev_features_t features = 0;
+
 	ether_setup(dev);
 	dev->netdev_ops = &tile_net_ops;
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
-	dev->features |= NETIF_F_LLTX;
-	dev->features |= NETIF_F_HW_CSUM;
-	dev->features |= NETIF_F_SG;
-	dev->features |= NETIF_F_TSO;
 	dev->mtu = 1500;
+
+	features |= NETIF_F_LLTX;
+	features |= NETIF_F_HW_CSUM;
+	features |= NETIF_F_SG;
+	features |= NETIF_F_TSO;
+
+	dev->hw_features   |= features;
+	dev->vlan_features |= features;
+	dev->features      |= features;
 }
 
 /* Allocate the device structure, register the device, and obtain the
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index f66ac20..34b43b4 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -89,10 +89,6 @@
 /* ISSUE: This has not been thoroughly tested (except at 1500). */
 #define TILE_NET_MTU 1500
 
-/* HACK: Define to support GSO. */
-/* ISSUE: This may actually hurt performance of the TCP blaster. */
-/* #define TILE_NET_GSO */
-
 /* Define this to collapse "duplicate" acks. */
 /* #define IGNORE_DUP_ACKS */
 
@@ -2336,39 +2332,28 @@ static const struct net_device_ops tile_net_ops = {
  */
 static void tile_net_setup(struct net_device *dev)
 {
-	PDEBUG("tile_net_setup()\n");
+	netdev_features_t features = 0;
 
 	ether_setup(dev);
-
 	dev->netdev_ops = &tile_net_ops;
-
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
+	dev->tx_queue_len = TILE_NET_TX_QUEUE_LEN;
+	dev->mtu = TILE_NET_MTU;
 
-	/* We want lockless xmit. */
-	dev->features |= NETIF_F_LLTX;
-
-	/* We support hardware tx checksums. */
-	dev->features |= NETIF_F_HW_CSUM;
-
-	/* We support scatter/gather. */
-	dev->features |= NETIF_F_SG;
-
-	/* We support TSO. */
-	dev->features |= NETIF_F_TSO;
-
-#ifdef TILE_NET_GSO
-	/* We support GSO. */
-	dev->features |= NETIF_F_GSO;
-#endif
+	features |= NETIF_F_LLTX;
+	features |= NETIF_F_HW_CSUM;
+	features |= NETIF_F_SG;
+	features |= NETIF_F_TSO;
 
+	/* We can't support HIGHDMA without hash_default, since we need
+	 * to be able to finv() with a VA if we don't have hash_default.
+	 */
 	if (hash_default)
-		dev->features |= NETIF_F_HIGHDMA;
-
-	/* ISSUE: We should support NETIF_F_UFO. */
+		features |= NETIF_F_HIGHDMA;
 
-	dev->tx_queue_len = TILE_NET_TX_QUEUE_LEN;
-
-	dev->mtu = TILE_NET_MTU;
+	dev->hw_features   |= features;
+	dev->vlan_features |= features;
+	dev->features      |= features;
 }
 
 
-- 
1.8.3.1
