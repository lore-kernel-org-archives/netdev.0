From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH v2 1/2] vlan: adds vlan_dev_select_queue
Date: Tue, 23 Mar 2010 17:41:45 -0700
Message-ID: <20100324004116.31609.73183.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Vasu Dev <vasu.dev@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:52967
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751505Ab0CXAmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 20:42:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

This is required to correctly select vlan tx queue for a driver
supporting multi tx queue with ndo_select_queue implemented since
currently selected vlan tx queue is unaligned to selected queue by
real net_devce ndo_select_queue.

Unaligned vlan tx queue selection causes thrash with higher vlan
tx lock contention for least fcoe traffic and wrong socket tx
queue_mapping for ixgbe having ndo_select_queue implemented.

-v2

As per Eric Dumazet<eric.dumazet@gmail.com> comments, mirrored
vlan net_device_ops to have them with and without vlan_dev_select_queue
and then select according to real dev ndo_select_queue present or not
for a vlan net_device. This is to completely skip vlan_dev_select_queue
calling for real net_device not supporting ndo_select_queue.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/8021q/vlan_dev.c |   71 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 68 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9e83272..2fd057c 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -361,6 +361,14 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	return ret;
 }
 
+static u16 vlan_dev_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	struct net_device *rdev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = rdev->netdev_ops;
+
+	return ops->ndo_select_queue(rdev, skb);
+}
+
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
 	/* TODO: gotta make sure the underlying layer can handle it,
@@ -688,7 +696,8 @@ static const struct header_ops vlan_header_ops = {
 	.parse	 = eth_header_parse,
 };
 
-static const struct net_device_ops vlan_netdev_ops, vlan_netdev_accel_ops;
+static const struct net_device_ops vlan_netdev_ops, vlan_netdev_accel_ops,
+		    vlan_netdev_ops_sq, vlan_netdev_accel_ops_sq;
 
 static int vlan_dev_init(struct net_device *dev)
 {
@@ -722,11 +731,17 @@ static int vlan_dev_init(struct net_device *dev)
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
-		dev->netdev_ops         = &vlan_netdev_accel_ops;
+		if (real_dev->netdev_ops->ndo_select_queue)
+			dev->netdev_ops = &vlan_netdev_accel_ops_sq;
+		else
+			dev->netdev_ops = &vlan_netdev_accel_ops;
 	} else {
 		dev->header_ops      = &vlan_header_ops;
 		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
-		dev->netdev_ops         = &vlan_netdev_ops;
+		if (real_dev->netdev_ops->ndo_select_queue)
+			dev->netdev_ops = &vlan_netdev_ops_sq;
+		else
+			dev->netdev_ops = &vlan_netdev_ops;
 	}
 
 	if (is_vlan_dev(real_dev))
@@ -865,6 +880,56 @@ static const struct net_device_ops vlan_netdev_accel_ops = {
 #endif
 };
 
+static const struct net_device_ops vlan_netdev_ops_sq = {
+	.ndo_select_queue	= vlan_dev_select_queue,
+	.ndo_change_mtu		= vlan_dev_change_mtu,
+	.ndo_init		= vlan_dev_init,
+	.ndo_uninit		= vlan_dev_uninit,
+	.ndo_open		= vlan_dev_open,
+	.ndo_stop		= vlan_dev_stop,
+	.ndo_start_xmit =  vlan_dev_hard_start_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= vlan_dev_set_mac_address,
+	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
+	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
+	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
+	.ndo_do_ioctl		= vlan_dev_ioctl,
+	.ndo_neigh_setup	= vlan_dev_neigh_setup,
+	.ndo_get_stats		= vlan_dev_get_stats,
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
+	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
+	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
+	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
+	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
+#endif
+};
+
+static const struct net_device_ops vlan_netdev_accel_ops_sq = {
+	.ndo_select_queue	= vlan_dev_select_queue,
+	.ndo_change_mtu		= vlan_dev_change_mtu,
+	.ndo_init		= vlan_dev_init,
+	.ndo_uninit		= vlan_dev_uninit,
+	.ndo_open		= vlan_dev_open,
+	.ndo_stop		= vlan_dev_stop,
+	.ndo_start_xmit =  vlan_dev_hwaccel_hard_start_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= vlan_dev_set_mac_address,
+	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
+	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
+	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
+	.ndo_do_ioctl		= vlan_dev_ioctl,
+	.ndo_neigh_setup	= vlan_dev_neigh_setup,
+	.ndo_get_stats		= vlan_dev_get_stats,
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
+	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
+	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
+	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
+	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
+#endif
+};
+
 void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);

