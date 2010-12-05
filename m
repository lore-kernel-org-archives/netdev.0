From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Add ndo_set_rx_mode support for enic vnics
Date: Sat, 04 Dec 2010 22:23:36 -0800
Message-ID: <20101205062336.28056.72156.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:11003 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab0LEGXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 01:23:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

Add ndo_set_rx_mode support to register unicast and multicast address filters for enic vnics

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic.h      |    4 +
 drivers/net/enic/enic_main.c |  121 ++++++++++++++++++++++++++++++++++--------
 drivers/net/enic/enic_res.h  |    1 
 3 files changed, 102 insertions(+), 24 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index a930fb9..084190e 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.8"
+#define DRV_VERSION		"1.4.1.9"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
@@ -78,8 +78,10 @@ struct enic {
 	spinlock_t devcmd_lock;
 	u8 mac_addr[ETH_ALEN];
 	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
+	u8 uc_addr[ENIC_UNICAST_PERFECT_FILTERS][ETH_ALEN];
 	unsigned int flags;
 	unsigned int mc_count;
+	unsigned int uc_count;
 	int csum_rx_enabled;
 	u32 port_mtu;
 	u32 rx_coalesce_usecs;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 075ca5f..de7b25c 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1002,7 +1002,7 @@ static int enic_dev_packet_filter(struct enic *enic, int directed,
 	return err;
 }
 
-static int enic_dev_add_multicast_addr(struct enic *enic, u8 *addr)
+static int enic_dev_add_addr(struct enic *enic, u8 *addr)
 {
 	int err;
 
@@ -1013,7 +1013,7 @@ static int enic_dev_add_multicast_addr(struct enic *enic, u8 *addr)
 	return err;
 }
 
-static int enic_dev_del_multicast_addr(struct enic *enic, u8 *addr)
+static int enic_dev_del_addr(struct enic *enic, u8 *addr)
 {
 	int err;
 
@@ -1024,29 +1024,19 @@ static int enic_dev_del_multicast_addr(struct enic *enic, u8 *addr)
 	return err;
 }
 
-/* netif_tx_lock held, BHs disabled */
-static void enic_set_multicast_list(struct net_device *netdev)
+static void enic_add_multicast_addr_list(struct enic *enic)
 {
-	struct enic *enic = netdev_priv(netdev);
+	struct net_device *netdev = enic->netdev;
 	struct netdev_hw_addr *ha;
-	int directed = 1;
-	int multicast = (netdev->flags & IFF_MULTICAST) ? 1 : 0;
-	int broadcast = (netdev->flags & IFF_BROADCAST) ? 1 : 0;
-	int promisc = (netdev->flags & IFF_PROMISC) ? 1 : 0;
 	unsigned int mc_count = netdev_mc_count(netdev);
-	int allmulti = (netdev->flags & IFF_ALLMULTI) ||
-		mc_count > ENIC_MULTICAST_PERFECT_FILTERS;
-	unsigned int flags = netdev->flags | (allmulti ? IFF_ALLMULTI : 0);
 	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
 	unsigned int i, j;
 
-	if (mc_count > ENIC_MULTICAST_PERFECT_FILTERS)
+	if (mc_count > ENIC_MULTICAST_PERFECT_FILTERS) {
+		netdev_warn(netdev, "Registering only %d out of %d "
+			"multicast addresses\n",
+			ENIC_MULTICAST_PERFECT_FILTERS, mc_count);
 		mc_count = ENIC_MULTICAST_PERFECT_FILTERS;
-
-	if (enic->flags != flags) {
-		enic->flags = flags;
-		enic_dev_packet_filter(enic, directed,
-			multicast, broadcast, promisc, allmulti);
 	}
 
 	/* Is there an easier way?  Trying to minimize to
@@ -1068,7 +1058,7 @@ static void enic_set_multicast_list(struct net_device *netdev)
 				mc_addr[j]) == 0)
 				break;
 		if (j == mc_count)
-			enic_dev_del_multicast_addr(enic, enic->mc_addr[i]);
+			enic_dev_del_addr(enic, enic->mc_addr[i]);
 	}
 
 	for (i = 0; i < mc_count; i++) {
@@ -1077,7 +1067,7 @@ static void enic_set_multicast_list(struct net_device *netdev)
 				enic->mc_addr[j]) == 0)
 				break;
 		if (j == enic->mc_count)
-			enic_dev_add_multicast_addr(enic, mc_addr[i]);
+			enic_dev_add_addr(enic, mc_addr[i]);
 	}
 
 	/* Save the list to compare against next time
@@ -1089,6 +1079,89 @@ static void enic_set_multicast_list(struct net_device *netdev)
 	enic->mc_count = mc_count;
 }
 
+static void enic_add_unicast_addr_list(struct enic *enic)
+{
+	struct net_device *netdev = enic->netdev;
+	struct netdev_hw_addr *ha;
+	unsigned int uc_count = netdev_uc_count(netdev);
+	u8 uc_addr[ENIC_UNICAST_PERFECT_FILTERS][ETH_ALEN];
+	unsigned int i, j;
+
+	if (uc_count > ENIC_UNICAST_PERFECT_FILTERS) {
+		netdev_warn(netdev, "Registering only %d out of %d "
+			"unicast addresses\n",
+			ENIC_UNICAST_PERFECT_FILTERS, uc_count);
+		uc_count = ENIC_UNICAST_PERFECT_FILTERS;
+	}
+
+	/* Is there an easier way?  Trying to minimize to
+	 * calls to add/del unicast addrs.  We keep the
+	 * addrs from the last call in enic->uc_addr and
+	 * look for changes to add/del.
+	 */
+
+	i = 0;
+	netdev_for_each_uc_addr(ha, netdev) {
+		if (i == uc_count)
+			break;
+		memcpy(uc_addr[i++], ha->addr, ETH_ALEN);
+	}
+
+	for (i = 0; i < enic->uc_count; i++) {
+		for (j = 0; j < uc_count; j++)
+			if (compare_ether_addr(enic->uc_addr[i],
+				uc_addr[j]) == 0)
+				break;
+		if (j == uc_count)
+			enic_dev_del_addr(enic, enic->uc_addr[i]);
+	}
+
+	for (i = 0; i < uc_count; i++) {
+		for (j = 0; j < enic->uc_count; j++)
+			if (compare_ether_addr(uc_addr[i],
+				enic->uc_addr[j]) == 0)
+				break;
+		if (j == enic->uc_count)
+			enic_dev_add_addr(enic, uc_addr[i]);
+	}
+
+	/* Save the list to compare against next time
+	 */
+
+	for (i = 0; i < uc_count; i++)
+		memcpy(enic->uc_addr[i], uc_addr[i], ETH_ALEN);
+
+	enic->uc_count = uc_count;
+}
+
+/* netif_tx_lock held, BHs disabled */
+static void enic_set_rx_mode(struct net_device *netdev)
+{
+	struct enic *enic = netdev_priv(netdev);
+	int directed = 1;
+	int multicast = (netdev->flags & IFF_MULTICAST) ? 1 : 0;
+	int broadcast = (netdev->flags & IFF_BROADCAST) ? 1 : 0;
+	int promisc = (netdev->flags & IFF_PROMISC) ||
+		netdev_uc_count(netdev) > ENIC_UNICAST_PERFECT_FILTERS;
+	int allmulti = (netdev->flags & IFF_ALLMULTI) ||
+		netdev_mc_count(netdev) > ENIC_MULTICAST_PERFECT_FILTERS;
+	unsigned int flags = netdev->flags |
+		(allmulti ? IFF_ALLMULTI : 0) |
+		(promisc ? IFF_PROMISC : 0);
+
+	if (enic->flags != flags) {
+		enic->flags = flags;
+		enic_dev_packet_filter(enic, directed,
+			multicast, broadcast, promisc, allmulti);
+	}
+
+	if (!promisc) {
+		enic_add_unicast_addr_list(enic);
+		if (!allmulti)
+			enic_add_multicast_addr_list(enic);
+	}
+}
+
 /* rtnl lock is held */
 static void enic_vlan_rx_register(struct net_device *netdev,
 	struct vlan_group *vlan_group)
@@ -1852,7 +1925,7 @@ static int enic_open(struct net_device *netdev)
 		vnic_rq_enable(&enic->rq[i]);
 
 	enic_dev_add_station_addr(enic);
-	enic_set_multicast_list(netdev);
+	enic_set_rx_mode(netdev);
 
 	netif_wake_queue(netdev);
 
@@ -2328,7 +2401,8 @@ static const struct net_device_ops enic_netdev_dynamic_ops = {
 	.ndo_start_xmit		= enic_hard_start_xmit,
 	.ndo_get_stats		= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= enic_set_multicast_list,
+	.ndo_set_rx_mode	= enic_set_rx_mode,
+	.ndo_set_multicast_list	= enic_set_rx_mode,
 	.ndo_set_mac_address	= enic_set_mac_address_dynamic,
 	.ndo_change_mtu		= enic_change_mtu,
 	.ndo_vlan_rx_register	= enic_vlan_rx_register,
@@ -2349,7 +2423,8 @@ static const struct net_device_ops enic_netdev_ops = {
 	.ndo_get_stats		= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= enic_set_mac_address,
-	.ndo_set_multicast_list	= enic_set_multicast_list,
+	.ndo_set_rx_mode	= enic_set_rx_mode,
+	.ndo_set_multicast_list	= enic_set_rx_mode,
 	.ndo_change_mtu		= enic_change_mtu,
 	.ndo_vlan_rx_register	= enic_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= enic_vlan_rx_add_vid,
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 9a103d9..25be273 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -34,6 +34,7 @@
 #define ENIC_MAX_MTU			9000
 
 #define ENIC_MULTICAST_PERFECT_FILTERS	32
+#define ENIC_UNICAST_PERFECT_FILTERS	32
 
 #define ENIC_NON_TSO_MAX_DESC		16
 

