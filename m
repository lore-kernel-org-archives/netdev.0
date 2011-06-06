From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH] macvlan: add VLAN filters to lowerdev
Date: Mon, 06 Jun 2011 07:27:16 -0700
Message-ID: <20110606142715.2692.6311.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55355 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226Ab1FFOdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 10:33:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stacking VLANs on top of the macvlan device does not
work if the lowerdev device is using vlan filters set
by NETIF_F_HW_VLAN_FILTER. Add ndo ops to pass vlan
calls to lowerdev.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/macvlan.c |   39 ++++++++++++++++++++++++++++++++++++++-
 1 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d6aeaa5..cc67cbe 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -414,7 +414,8 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
-	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM)
+	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
+	 NETIF_F_HW_VLAN_FILTER)
 
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
@@ -509,6 +510,39 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
 	return stats;
 }
 
+static void macvlan_vlan_rx_register(struct net_device *dev,
+				     struct vlan_group *grp)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+
+	if (ops->ndo_vlan_rx_register)
+		ops->ndo_vlan_rx_register(lowerdev, grp);
+}
+
+static void macvlan_vlan_rx_add_vid(struct net_device *dev,
+				    unsigned short vid)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+
+	if (ops->ndo_vlan_rx_add_vid)
+		ops->ndo_vlan_rx_add_vid(lowerdev, vid);
+}
+
+static void macvlan_vlan_rx_kill_vid(struct net_device *dev,
+				     unsigned short vid)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+
+	if (ops->ndo_vlan_rx_kill_vid)
+		ops->ndo_vlan_rx_kill_vid(lowerdev, vid);
+}
+
 static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *drvinfo)
 {
@@ -541,6 +575,9 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_set_multicast_list	= macvlan_set_multicast_list,
 	.ndo_get_stats64	= macvlan_dev_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_vlan_rx_register	= macvlan_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= macvlan_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= macvlan_vlan_rx_kill_vid,
 };
 
 void macvlan_common_setup(struct net_device *dev)

