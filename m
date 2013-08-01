From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v2 13/12] tile: set hw_features and vlan_features in setup
Date: Thu, 1 Aug 2013 11:36:42 -0400
Message-ID: <201308011545.r71Fjbco017295@farm-0002.internal.tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
  <cover.1375283104.git.cmetcalf@tilera.com>
  <799eca39dc7f85ba12e1d8c5b072f8b6740fda1c.1375283106.git.cmetcalf@tilera.com>
  <20130731.122534.774117327230299927.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130731.122534.774117327230299927.davem@redhat.com>
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
David, I've fixed the drivers to use hw_features as a follow-on "13 of
12" patch in the v2 series, rather than rebasing the previous patches,
since they weren't actually buggy as-is, and this was simpler.  However,
I am happy to provide a v3 of the patch series with the hw_features
change rebased to the front if that feels better to you.

 drivers/net/ethernet/tile/tilegx.c  | 15 ++++++++++----
 drivers/net/ethernet/tile/tilepro.c | 39 +++++++++++++++----------------------
 2 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index cd9bfc7..3b1dc66 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2169,14 +2169,21 @@ static const struct net_device_ops tile_net_ops = {
  */
 static void tile_net_setup(struct net_device *dev)
 {
+	netdev_features_t features = 0;
+
 	ether_setup(dev);
 	dev->netdev_ops = &tile_net_ops;
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
-	dev->features |= NETIF_F_HW_CSUM;
-	dev->features |= NETIF_F_SG;
-	dev->features |= NETIF_F_TSO;
-	dev->features |= NETIF_F_TSO6;
 	dev->mtu = 1500;
+
+	features |= NETIF_F_HW_CSUM;
+	features |= NETIF_F_SG;
+	features |= NETIF_F_TSO;
+	features |= NETIF_F_TSO6;
+
+	dev->hw_features   |= features;
+	dev->vlan_features |= features;
+	dev->features      |= features;
 }
 
 /* Allocate the device structure, register the device, and obtain the
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 874c7eb..2360b38 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -89,9 +89,9 @@
 /* ISSUE: This has not been thoroughly tested (except at 1500). */
 #define TILE_NET_MTU 1500
 
-/* HACK: Define to support GSO. */
-/* ISSUE: This may actually hurt performance of the TCP blaster. */
-/* #define TILE_NET_GSO */
+/* Define as 0 to enable all features by default. */
+/* ISSUE: GSO appears to actually hurt performance of the TCP blaster. */
+#define TILE_NETIF_F_DEFAULT_DISABLE NETIF_F_GSO
 
 /* HACK: Define this to verify incoming packets. */
 /* #define TILE_NET_VERIFY_INGRESS */
@@ -2249,37 +2249,30 @@ static const struct net_device_ops tile_net_ops = {
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
 
-	/* We support hardware tx checksums. */
-	dev->features |= NETIF_F_HW_CSUM;
-
-	/* We support scatter/gather. */
-	dev->features |= NETIF_F_SG;
+	features |= NETIF_F_HW_CSUM;
+	features |= NETIF_F_SG;
 
 	/* We support TSO iff the HV supports sufficient frags. */
 	if (LEPP_MAX_FRAGS >= 1 + MAX_SKB_FRAGS)
-		dev->features |= NETIF_F_TSO;
-
-#ifdef TILE_NET_GSO
-	/* We support GSO. */
-	dev->features |= NETIF_F_GSO;
-#endif
+		features |= NETIF_F_TSO;
 
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
+	dev->features      |= features & ~TILE_NETIF_F_DEFAULT_DISABLE;
 }
 
 
-- 
1.8.3.1
