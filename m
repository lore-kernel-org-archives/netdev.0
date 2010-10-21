From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC][net-next-2.6 PATCH 1/4] net: consolidate 8021q tagging
Date: Thu, 21 Oct 2010 15:10:04 -0700
Message-ID: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:32051 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594Ab0JUWLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 18:11:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that VLAN packets are tagged in dev_hard_start_xmit()
at the bottom of the stack we no longer need to tag them
in the 8021Q module (Except in the !VLAN_FLAG_REORDER_HDR
case).

This allows the accel path and non accel paths to be consolidated.
Here the vlan_tci in the skb is always set and we allow the
stack to add the actual tag in dev_hard_start_xmit().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/8021q/vlan_dev.c |  105 +++-----------------------------------------------
 1 files changed, 7 insertions(+), 98 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 14e3d1f..78b1618 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -326,24 +326,12 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	 */
 	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
 	    vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		unsigned int orig_headroom = skb_headroom(skb);
 		u16 vlan_tci;
-
-		vlan_dev_info(dev)->cnt_encap_on_xmit++;
-
 		vlan_tci = vlan_dev_info(dev)->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-		skb = __vlan_put_tag(skb, vlan_tci);
-		if (!skb) {
-			txq->tx_dropped++;
-			return NETDEV_TX_OK;
-		}
-
-		if (orig_headroom < VLAN_HLEN)
-			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
+		skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 	}
 
-
 	skb_set_dev(skb, vlan_dev_info(dev)->real_dev);
 	len = skb->len;
 	ret = dev_queue_xmit(skb);
@@ -357,32 +345,6 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	return ret;
 }
 
-static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
-						    struct net_device *dev)
-{
-	int i = skb_get_queue_mapping(skb);
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-	u16 vlan_tci;
-	unsigned int len;
-	int ret;
-
-	vlan_tci = vlan_dev_info(dev)->vlan_id;
-	vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-	skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
-
-	skb->dev = vlan_dev_info(dev)->real_dev;
-	len = skb->len;
-	ret = dev_queue_xmit(skb);
-
-	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
-		txq->tx_packets++;
-		txq->tx_bytes += len;
-	} else
-		txq->tx_dropped++;
-
-	return ret;
-}
-
 static u16 vlan_dev_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct net_device *rdev = vlan_dev_info(dev)->real_dev;
@@ -719,8 +681,7 @@ static const struct header_ops vlan_header_ops = {
 	.parse	 = eth_header_parse,
 };
 
-static const struct net_device_ops vlan_netdev_ops, vlan_netdev_accel_ops,
-		    vlan_netdev_ops_sq, vlan_netdev_accel_ops_sq;
+static const struct net_device_ops vlan_netdev_ops, vlan_netdev_ops_sq;
 
 static int vlan_dev_init(struct net_device *dev)
 {
@@ -755,19 +716,16 @@ static int vlan_dev_init(struct net_device *dev)
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
-		if (real_dev->netdev_ops->ndo_select_queue)
-			dev->netdev_ops = &vlan_netdev_accel_ops_sq;
-		else
-			dev->netdev_ops = &vlan_netdev_accel_ops;
 	} else {
 		dev->header_ops      = &vlan_header_ops;
 		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
-		if (real_dev->netdev_ops->ndo_select_queue)
-			dev->netdev_ops = &vlan_netdev_ops_sq;
-		else
-			dev->netdev_ops = &vlan_netdev_ops;
 	}
 
+	if (real_dev->netdev_ops->ndo_select_queue)
+		dev->netdev_ops = &vlan_netdev_ops_sq;
+	else
+		dev->netdev_ops = &vlan_netdev_ops;
+
 	if (is_vlan_dev(real_dev))
 		subclass = 1;
 
@@ -908,30 +866,6 @@ static const struct net_device_ops vlan_netdev_ops = {
 #endif
 };
 
-static const struct net_device_ops vlan_netdev_accel_ops = {
-	.ndo_change_mtu		= vlan_dev_change_mtu,
-	.ndo_init		= vlan_dev_init,
-	.ndo_uninit		= vlan_dev_uninit,
-	.ndo_open		= vlan_dev_open,
-	.ndo_stop		= vlan_dev_stop,
-	.ndo_start_xmit =  vlan_dev_hwaccel_hard_start_xmit,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= vlan_dev_set_mac_address,
-	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
-	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
-	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
-	.ndo_do_ioctl		= vlan_dev_ioctl,
-	.ndo_neigh_setup	= vlan_dev_neigh_setup,
-	.ndo_get_stats64	= vlan_dev_get_stats64,
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
-	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
-	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
-	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
-	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
-	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
-#endif
-};
-
 static const struct net_device_ops vlan_netdev_ops_sq = {
 	.ndo_select_queue	= vlan_dev_select_queue,
 	.ndo_change_mtu		= vlan_dev_change_mtu,
@@ -957,31 +891,6 @@ static const struct net_device_ops vlan_netdev_ops_sq = {
 #endif
 };
 
-static const struct net_device_ops vlan_netdev_accel_ops_sq = {
-	.ndo_select_queue	= vlan_dev_select_queue,
-	.ndo_change_mtu		= vlan_dev_change_mtu,
-	.ndo_init		= vlan_dev_init,
-	.ndo_uninit		= vlan_dev_uninit,
-	.ndo_open		= vlan_dev_open,
-	.ndo_stop		= vlan_dev_stop,
-	.ndo_start_xmit =  vlan_dev_hwaccel_hard_start_xmit,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= vlan_dev_set_mac_address,
-	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
-	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
-	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
-	.ndo_do_ioctl		= vlan_dev_ioctl,
-	.ndo_neigh_setup	= vlan_dev_neigh_setup,
-	.ndo_get_stats64	= vlan_dev_get_stats64,
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
-	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
-	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
-	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
-	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
-	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
-#endif
-};
-
 void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);

