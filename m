From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 net-next 3/4] macvtap: Let TUNSETOFFLOAD actually controll offload features.
Date: Tue, 25 Jun 2013 16:04:21 -0400
Message-ID: <1372190662-30815-4-git-send-email-vyasevic@redhat.com>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152Ab3FYUEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 16:04:33 -0400
In-Reply-To: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the user issues TUNSETOFFLOAD ioctl, macvtap does not do
anything other then to verify arguments.  This patch adds
functionality to allow users to actually control offload features.
NETIF_F_GSO and NETIF_F_GRO are always on, but the rest of the
features can be controlled.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c      | 10 +++++++
 drivers/net/macvtap.c      | 65 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_macvlan.h |  2 ++
 3 files changed, 76 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index edfddc5..61c53a8 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -638,6 +638,14 @@ static int macvlan_ethtool_get_settings(struct net_device *dev,
 	return __ethtool_get_settings(vlan->lowerdev, cmd);
 }
 
+static netdev_features_t macvlan_fix_features(struct net_device *dev,
+					      netdev_features_t features)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	return features & (vlan->set_features | ~MACVLAN_FEATURES);
+}
+
 static const struct ethtool_ops macvlan_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_settings		= macvlan_ethtool_get_settings,
@@ -651,6 +659,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_stop		= macvlan_stop,
 	.ndo_start_xmit		= macvlan_start_xmit,
 	.ndo_change_mtu		= macvlan_change_mtu,
+	.ndo_fix_features	= macvlan_fix_features,
 	.ndo_change_rx_flags	= macvlan_change_rx_flags,
 	.ndo_set_mac_address	= macvlan_set_mac_address,
 	.ndo_set_rx_mode	= macvlan_set_mac_lists,
@@ -791,6 +800,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	vlan->port     = port;
 	vlan->receive  = receive;
 	vlan->forward  = forward;
+	vlan->set_features = MACVLAN_FEATURES;
 
 	vlan->mode     = MACVLAN_MODE_VEPA;
 	if (data && data[IFLA_MACVLAN_MODE])
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index d7856a8..7eab019 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -65,6 +65,9 @@ static struct cdev macvtap_cdev;
 
 static const struct proto_ops macvtap_socket_ops;
 
+#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
+		      NETIF_F_TSO6 | NETIF_F_UFO)
+#define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
 /*
  * RCU usage:
  * The macvtap_queue and the macvlan_dev are loosely coupled, the
@@ -349,6 +352,11 @@ static int macvtap_newlink(struct net *src_net,
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	INIT_LIST_HEAD(&vlan->queue_list);
 
+	/* Since macvlan supports all offloads by default, make
+	 * tap support all offloads also.
+	 */
+	vlan->tap_features = TUN_OFFLOADS;
+
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
@@ -958,6 +966,58 @@ static int macvtap_ioctl_set_queue(struct file *file, unsigned int flags)
 	return ret;
 }
 
+static int set_offload(struct macvtap_queue *q, unsigned long arg)
+{
+	struct macvlan_dev *vlan;
+	netdev_features_t features;
+	netdev_features_t feature_mask = 0;
+
+	vlan = rtnl_dereference(q->vlan);
+	if (!vlan)
+		return -ENOLINK;
+
+	features = vlan->dev->features;
+
+	if (arg & TUN_F_CSUM) {
+		feature_mask = NETIF_F_HW_CSUM;
+
+		if (arg & (TUN_F_TSO4 | TUN_F_TSO6)) {
+			if (arg & TUN_F_TSO_ECN)
+				feature_mask |= NETIF_F_TSO_ECN;
+			if (arg & TUN_F_TSO4)
+				feature_mask |= NETIF_F_TSO;
+			if (arg & TUN_F_TSO6)
+				feature_mask |= NETIF_F_TSO6;
+		}
+
+		if (arg & TUN_F_UFO)
+			feature_mask |= NETIF_F_UFO;
+	}
+
+	/* tun/tap driver inverts the usage for TSO offloads, where
+	 * setting the TSO bit means that the userspace wants to
+	 * accept TSO frames and turning it off means that user space
+	 * does not support TSO.
+	 * For macvtap, we have to invert it to mean the same thing.
+	 * When user space turns off TSO, we turn off GSO/LRO so that
+	 * user-space will not receive TSO frames.
+	 */
+	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO))
+		features |= RX_OFFLOADS;
+	else
+		features &= ~RX_OFFLOADS;
+
+	/* tap_features are the same as features on tun/tap and
+	 * reflect user expectations.
+	 */
+	vlan->tap_features = vlan->dev->features &
+			    (feature_mask | ~TUN_OFFLOADS);
+	vlan->set_features = features;
+	netdev_update_features(vlan->dev);
+
+	return 0;
+}
+
 /*
  * provide compatibility with generic tun/tap interface
  */
@@ -1050,7 +1110,10 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 			 got enabled for forwarded frames */
 		if (!(q->flags & IFF_VNET_HDR))
 			return  -EINVAL;
-		return 0;
+		rtnl_lock();
+		ret = set_offload(q, arg);
+		rtnl_unlock();
+		return ret;
 
 	default:
 		return -EINVAL;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index f49a9f6..ddd33fd 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -65,6 +65,7 @@ struct macvlan_dev {
 
 	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
 
+	netdev_features_t	set_features;
 	enum macvlan_mode	mode;
 	u16			flags;
 	int (*receive)(struct sk_buff *skb);
@@ -75,6 +76,7 @@ struct macvlan_dev {
 	struct list_head	queue_list;
 	int			numvtaps;
 	int			numqueues;
+	netdev_features_t	tap_features;
 	int			minor;
 };
 
-- 
1.8.1.4
