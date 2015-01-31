From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 4/4] enic: add ethtool support for changing alloc order
Date: Sat, 31 Jan 2015 17:58:10 +0530
Message-ID: <1422707290-939-5-git-send-email-_govind@gmx.com>
References: <1422707290-939-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com, edumazet@google.com,
	ben@decadent.org.uk, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:61138 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751759AbbAaM3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2015 07:29:30 -0500
In-Reply-To: <1422707290-939-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for changing page order of enic frag allocator.

In case of changing mtu, if size of new mtu is greater than size of compound
page allocated in enic frag allocator, we change the order to min order required
for the new mtu. We would like to give high priority for changing mtu than order
value.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 15 +++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c    | 18 ++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 3f9d91b..e29423c 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -18,6 +18,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_vlan.h>
 
 #include "enic_res.h"
 #include "enic.h"
@@ -409,6 +410,9 @@ static int enic_get_tunable(struct net_device *dev,
 	case ETHTOOL_RX_COPYBREAK:
 		*(u32 *)data = enic->rx_copybreak;
 		break;
+	case ETHTOOL_RX_ALLOC_ORDER:
+		*(u8 *)data = enic->alloc_order;
+		break;
 	default:
 		ret = -EINVAL;
 		break;
@@ -428,6 +432,17 @@ static int enic_set_tunable(struct net_device *dev,
 	case ETHTOOL_RX_COPYBREAK:
 		enic->rx_copybreak = *(u32 *)data;
 		break;
+	case ETHTOOL_RX_ALLOC_ORDER:
+		ret = dev->mtu + VLAN_ETH_HLEN + NET_IP_ALIGN + NET_SKB_PAD;
+		ret = SKB_DATA_ALIGN(ret) +
+		      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+		if (*(u8 *)data < get_order(ret)) {
+			ret = -EINVAL;
+			break;
+		}
+		ret = 0;
+		enic->alloc_order = *(u8 *)data;
+		break;
 	default:
 		ret = -EINVAL;
 		break;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index f15687d..4a759a0 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1872,7 +1872,11 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct enic *enic = netdev_priv(netdev);
 	int running = netif_running(netdev);
+	size_t len;
 
+	len = new_mtu + VLAN_ETH_HLEN + NET_IP_ALIGN + NET_SKB_PAD;
+	len = SKB_DATA_ALIGN(len) +
+	      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	if (new_mtu < ENIC_MIN_MTU || new_mtu > ENIC_MAX_MTU)
 		return -EINVAL;
 
@@ -1884,6 +1888,11 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 
 	netdev->mtu = new_mtu;
 
+	if (len > (PAGE_SIZE << enic->alloc_order)) {
+		enic->alloc_order = get_order(len);
+		netdev_warn(netdev, "new mtu is greater than size of rx alloc_page, resetting enic->alloc_order to :%d\n",
+			    enic->alloc_order);
+	}
 	if (netdev->mtu > enic->port_mtu)
 		netdev_warn(netdev,
 			"interface MTU (%d) set higher than port MTU (%d)\n",
@@ -1902,8 +1911,12 @@ static void enic_change_mtu_work(struct work_struct *work)
 	int new_mtu = vnic_dev_mtu(enic->vdev);
 	int err;
 	unsigned int i;
+	size_t len;
 
 	new_mtu = max_t(int, ENIC_MIN_MTU, min_t(int, ENIC_MAX_MTU, new_mtu));
+	len = new_mtu + VLAN_ETH_HLEN + NET_IP_ALIGN + NET_SKB_PAD;
+	len = SKB_DATA_ALIGN(len) +
+	      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	rtnl_lock();
 
@@ -1927,6 +1940,11 @@ static void enic_change_mtu_work(struct work_struct *work)
 
 	/* Fill RQ with new_mtu-sized buffers */
 	netdev->mtu = new_mtu;
+	if (len > (PAGE_SIZE << enic->alloc_order)) {
+		enic->alloc_order = get_order(len);
+		netdev_warn(netdev, "new mtu is greater than size of rx alloc_page, resetting enic->alloc_order to :%d\n",
+			    enic->alloc_order);
+	}
 	vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
 	/* Need at least one buffer on ring to get going */
 	if (vnic_rq_desc_used(&enic->rq[0]) == 0) {
-- 
2.2.2
