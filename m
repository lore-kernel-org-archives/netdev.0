From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] ixgbevf: Make use of NETIF_F_RXCSUM instead of keeping our own flag
Date: Tue, 17 Jul 2012 03:09:14 -0700
Message-ID: <1342519759-25137-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4797 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664Ab2GQKJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 06:09:24 -0400
In-Reply-To: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The IXGBE_FLAG_RX_CSUM_ENABLED flag is redundant since NETIF_F_RXCSUM is
keeping the value we want to already have.  As such we can drop the
redundant flag and just make use of NETIF_F_RXCSUM.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    3 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   19 +------------------
 2 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index ed19f7e..773dafa 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -207,8 +207,7 @@ struct ixgbevf_adapter {
 	 * thus the additional *_CAPABLE flags.
 	 */
 	u32 flags;
-#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1)
-#define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 1)
+#define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1)
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 3cd8651..2e85d79 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -307,7 +307,7 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_adapter *adapter,
 	skb_checksum_none_assert(skb);
 
 	/* Rx csum disabled */
-	if (!(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
+	if (!(adapter->netdev->features & NETIF_F_RXCSUM))
 		return;
 
 	/* if IP and error */
@@ -2077,9 +2077,6 @@ static int __devinit ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 	adapter->tx_ring_count = IXGBEVF_DEFAULT_TXD;
 	adapter->rx_ring_count = IXGBEVF_DEFAULT_RXD;
 
-	/* enable rx csum by default */
-	adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
-
 	set_bit(__IXGBEVF_DOWN, &adapter->state);
 	return 0;
 
@@ -3112,19 +3109,6 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 	return stats;
 }
 
-static int ixgbevf_set_features(struct net_device *netdev,
-	netdev_features_t features)
-{
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-
-	if (features & NETIF_F_RXCSUM)
-		adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
-	else
-		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
-
-	return 0;
-}
-
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbevf_open,
 	.ndo_stop		= ixgbevf_close,
@@ -3137,7 +3121,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_tx_timeout		= ixgbevf_tx_timeout,
 	.ndo_vlan_rx_add_vid	= ixgbevf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgbevf_vlan_rx_kill_vid,
-	.ndo_set_features	= ixgbevf_set_features,
 };
 
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
-- 
1.7.10.4
