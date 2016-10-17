From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 13/15] ethernet/tile: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:15 -0400
Message-ID: <20161017195417.48259-14-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Chris Metcalf <cmetcalf@mellanox.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tilegx: min_mtu 68, max_mtu 1500 or 9000, depending on modparam
- remove tile_net_change_mtu now that it is fully redundant

tilepro: min_mtu 68, max_mtu 1500
- hardware supports jumbo packets up to 10226, but it's not implemented or
  tested yet, according to code comments

CC: netdev@vger.kernel.org
CC: Chris Metcalf <cmetcalf@mellanox.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/tile/tilegx.c  | 21 ++++++++-------------
 drivers/net/ethernet/tile/tilepro.c | 27 +++++----------------------
 2 files changed, 13 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 11213a3..0aaf975 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -59,6 +59,9 @@
 /* Maximum number of packets to handle per "poll". */
 #define TILE_NET_WEIGHT 64
 
+/* Maximum Jumbo Packet MTU */
+#define TILE_JUMBO_MAX_MTU 9000
+
 /* Number of entries in each iqueue. */
 #define IQUEUE_ENTRIES 512
 
@@ -2101,17 +2104,6 @@ static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return -EOPNOTSUPP;
 }
 
-/* Change the MTU. */
-static int tile_net_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < 68)
-		return -EINVAL;
-	if (new_mtu > ((jumbo_num != 0) ? 9000 : 1500))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 /* Change the Ethernet address of the NIC.
  *
  * The hypervisor driver does not support changing MAC address.  However,
@@ -2154,7 +2146,6 @@ static const struct net_device_ops tile_net_ops = {
 	.ndo_start_xmit = tile_net_tx,
 	.ndo_select_queue = tile_net_select_queue,
 	.ndo_do_ioctl = tile_net_ioctl,
-	.ndo_change_mtu = tile_net_change_mtu,
 	.ndo_tx_timeout = tile_net_tx_timeout,
 	.ndo_set_mac_address = tile_net_set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2174,7 +2165,11 @@ static void tile_net_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->netdev_ops = &tile_net_ops;
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
-	dev->mtu = 1500;
+
+	/* MTU range: 68 - 1500 or 9000 */
+	dev->mtu = ETH_DATA_LEN;
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = jumbo_num ? TILE_JUMBO_MAX_MTU : ETH_DATA_LEN;
 
 	features |= NETIF_F_HW_CSUM;
 	features |= NETIF_F_SG;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 4ef605a..0a3b7da 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -87,7 +87,7 @@
 /* This should be 1500 if "jumbo" is not set in LIPP. */
 /* This should be at most 10226 (10240 - 14) if "jumbo" is set in LIPP. */
 /* ISSUE: This has not been thoroughly tested (except at 1500). */
-#define TILE_NET_MTU 1500
+#define TILE_NET_MTU ETH_DATA_LEN
 
 /* HACK: Define this to verify incoming packets. */
 /* #define TILE_NET_VERIFY_INGRESS */
@@ -2095,26 +2095,6 @@ static struct rtnl_link_stats64 *tile_net_get_stats64(struct net_device *dev,
 }
 
 
-/*
- * Change the "mtu".
- *
- * The "change_mtu" method is usually not needed.
- * If you need it, it must be like this.
- */
-static int tile_net_change_mtu(struct net_device *dev, int new_mtu)
-{
-	PDEBUG("tile_net_change_mtu()\n");
-
-	/* Check ranges. */
-	if ((new_mtu < 68) || (new_mtu > 1500))
-		return -EINVAL;
-
-	/* Accept the value. */
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 
 /*
  * Change the Ethernet Address of the NIC.
@@ -2229,7 +2209,6 @@ static const struct net_device_ops tile_net_ops = {
 	.ndo_start_xmit = tile_net_tx,
 	.ndo_do_ioctl = tile_net_ioctl,
 	.ndo_get_stats64 = tile_net_get_stats64,
-	.ndo_change_mtu = tile_net_change_mtu,
 	.ndo_tx_timeout = tile_net_tx_timeout,
 	.ndo_set_mac_address = tile_net_set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2252,7 +2231,11 @@ static void tile_net_setup(struct net_device *dev)
 	dev->netdev_ops = &tile_net_ops;
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
 	dev->tx_queue_len = TILE_NET_TX_QUEUE_LEN;
+
+	/* MTU range: 68 - 1500 */
 	dev->mtu = TILE_NET_MTU;
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = TILE_NET_MTU;
 
 	features |= NETIF_F_HW_CSUM;
 	features |= NETIF_F_SG;
-- 
2.10.0
