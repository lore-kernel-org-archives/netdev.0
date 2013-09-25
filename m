From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 1/2] net: Add layer 2 hardware acceleration operations for macvlan devices
Date: Wed, 25 Sep 2013 16:16:48 -0400
Message-ID: <1380140209-24587-2-git-send-email-nhorman@tuxdriver.com>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
 <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, john.fastabend@intel.com,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48741 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab3IYURN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 16:17:13 -0400
In-Reply-To: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a operations structure that allows a network interface to export the fact
that it supports package forwarding in hardware between physical interfaces and
other mac layer devices assigned to it (such as macvlans).  this operaions
structure can be used by virtual mac devices to bypass software switching so
that forwarding can be done in hardware more efficiently.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: john.fastabend@intel.com
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/macvlan.c      | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/if_macvlan.h |  1 +
 include/linux/netdevice.h  | 10 ++++++++++
 net/core/dev.c             |  3 +++
 4 files changed, 51 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9bf46bd..0c37b30 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -296,8 +296,16 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	unsigned int len = skb->len;
 	int ret;
 	const struct macvlan_dev *vlan = netdev_priv(dev);
+	const struct l2_forwarding_accel_ops *l2a_ops = vlan->lowerdev->l2a_ops;
+
+	if (l2a_ops->l2_accel_xmit) {
+		ret = l2a_ops->l2_accel_xmit(skb, vlan->l2a_priv);
+		if (likely(ret == NETDEV_TX_OK))
+			goto update_stats;
+	}
 
 	ret = macvlan_queue_xmit(skb, dev);
+update_stats:
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
 		struct macvlan_pcpu_stats *pcpu_stats;
 
@@ -336,6 +344,7 @@ static int macvlan_open(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
+	const struct l2_forwarding_accel_ops *l2a_ops = lowerdev->l2a_ops;
 	int err;
 
 	if (vlan->port->passthru) {
@@ -347,6 +356,19 @@ static int macvlan_open(struct net_device *dev)
 		goto hash_add;
 	}
 
+	if (l2a_ops->l2_accel_add_dev) {
+		/* The lowerdev supports l2 switching
+		 * try to add this macvlan to it
+		 */
+		vlan->l2a_priv = kzalloc(l2a_ops->priv_size, GFP_KERNEL);
+		if (!vlan->l2a_priv)
+			return -ENOMEM;
+		err = l2a_ops->l2_accel_add_dev(vlan->lowerdev,
+						dev, vlan->l2a_priv);
+		if (err < 0)
+			return err;
+	}
+
 	err = -EBUSY;
 	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
 		goto out;
@@ -367,6 +389,13 @@ hash_add:
 del_unicast:
 	dev_uc_del(lowerdev, dev->dev_addr);
 out:
+	if (vlan->l2a_priv) {
+		if (l2a_ops->l2_accel_del_dev)
+			l2a_ops->l2_accel_del_dev(vlan->lowerdev,
+						  vlan->l2a_priv);
+		kfree(vlan->l2a_priv);
+		vlan->l2a_priv = NULL;
+	}
 	return err;
 }
 
@@ -374,6 +403,7 @@ static int macvlan_stop(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
+	const struct l2_forwarding_accel_ops *l2a_ops = lowerdev->l2a_ops;
 
 	dev_uc_unsync(lowerdev, dev);
 	dev_mc_unsync(lowerdev, dev);
@@ -391,6 +421,12 @@ static int macvlan_stop(struct net_device *dev)
 
 hash_del:
 	macvlan_hash_del(vlan, !dev->dismantle);
+	if (vlan->l2a_priv) {
+		l2a_ops->l2_accel_del_dev(vlan->lowerdev, vlan->l2a_priv);
+		kfree(vlan->l2a_priv);
+		vlan->l2a_priv = NULL;
+	}
+
 	return 0;
 }
 
@@ -801,6 +837,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		if (err < 0)
 			return err;
 	}
+
 	port = macvlan_port_get_rtnl(lowerdev);
 
 	/* Only 1 macvlan device can be created in passthru mode */
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index ddd33fd..9b16af9 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -61,6 +61,7 @@ struct macvlan_dev {
 	struct hlist_node	hlist;
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
+	void			*l2a_priv;
 	struct macvlan_pcpu_stats __percpu *pcpu_stats;
 
 	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3de49ac..4cbc535 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1099,6 +1099,15 @@ struct net_device_ops {
 						      __be16 port);
 };
 
+struct l2_forwarding_accel_ops {
+	size_t priv_size;
+	int	(*l2_accel_add_dev)(struct net_device *pdev,
+				    struct net_device *vdev, void *priv);
+	void	(*l2_accel_del_dev)(struct net_device *pdev, void *priv);
+	netdev_tx_t             (*l2_accel_xmit)(struct sk_buff *skb,
+						 void *priv);
+};
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -1183,6 +1192,7 @@ struct net_device {
 	/* Management operations */
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
+	const struct l2_forwarding_accel_ops *l2a_ops;
 
 	/* Hardware header description */
 	const struct header_ops *header_ops;
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2..5c5eec2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5992,6 +5992,7 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 }
 
 static const struct ethtool_ops default_ethtool_ops;
+static const struct l2_forwarding_accel_ops default_l2a_ops;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops)
@@ -6090,6 +6091,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	dev->group = INIT_NETDEV_GROUP;
 	if (!dev->ethtool_ops)
 		dev->ethtool_ops = &default_ethtool_ops;
+	if (!dev->l2a_ops)
+		dev->l2a_ops = &default_l2a_ops;
 	return dev;
 
 free_all:
-- 
1.8.3.1
