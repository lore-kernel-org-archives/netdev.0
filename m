From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v3 1/2] net: Add layer 2 hardware acceleration
	operations for macvlan devices
Date: Tue, 05 Nov 2013 15:30:12 -0800
Message-ID: <20131105233011.5400.23253.stgit@jf-dev1-dcblab>
References: <20131105232443.5400.97238.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, andy@greyhouse.net,
	davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, vyasevich@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755905Ab3KEXv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 18:51:26 -0500
In-Reply-To: <20131105232443.5400.97238.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a operations structure that allows a network interface to export
the fact that it supports package forwarding in hardware between
physical interfaces and other mac layer devices assigned to it (such
as macvlans). This operaions structure can be used by virtual mac
devices to bypass software switching so that forwarding can be done
in hardware more efficiently.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
---

 drivers/net/macvlan.c           |   36 +++++++++++++++++++++++++++++++++++-
 include/linux/if_macvlan.h      |    1 +
 include/linux/netdev_features.h |    2 ++
 include/linux/netdevice.h       |   36 +++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if.h         |    1 +
 net/core/dev.c                  |   18 +++++++++++++-----
 net/core/ethtool.c              |    1 +
 net/sched/sch_generic.c         |    2 +-
 8 files changed, 89 insertions(+), 8 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index cc9845e..eb68dd0 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -297,7 +297,13 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	int ret;
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 
-	ret = macvlan_queue_xmit(skb, dev);
+	if (vlan->fwd_priv) {
+		skb->dev = vlan->lowerdev;
+		ret = dev_hard_start_xmit(skb, skb->dev, NULL, vlan->fwd_priv);
+	} else {
+		ret = macvlan_queue_xmit(skb, dev);
+	}
+
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
 		struct macvlan_pcpu_stats *pcpu_stats;
 
@@ -347,6 +353,21 @@ static int macvlan_open(struct net_device *dev)
 		goto hash_add;
 	}
 
+	if (lowerdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
+		vlan->fwd_priv =
+		      lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev, dev);
+
+		 /* If we get a NULL pointer back, or if we get an error
+		  * then we should just fall through to the non accelerated path
+		  */
+		if (IS_ERR_OR_NULL(vlan->fwd_priv)) {
+			vlan->fwd_priv = NULL;
+		} else {
+			dev->features &= ~NETIF_F_LLTX;
+			return 0;
+		}
+	}
+
 	err = -EBUSY;
 	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
 		goto out;
@@ -367,6 +388,11 @@ hash_add:
 del_unicast:
 	dev_uc_del(lowerdev, dev->dev_addr);
 out:
+	if (vlan->fwd_priv) {
+		lowerdev->netdev_ops->ndo_dfwd_del_station(lowerdev,
+							   vlan->fwd_priv);
+		vlan->fwd_priv = NULL;
+	}
 	return err;
 }
 
@@ -375,6 +401,13 @@ static int macvlan_stop(struct net_device *dev)
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
+	if (vlan->fwd_priv) {
+		lowerdev->netdev_ops->ndo_dfwd_del_station(lowerdev,
+							   vlan->fwd_priv);
+		vlan->fwd_priv = NULL;
+		return 0;
+	}
+
 	dev_uc_unsync(lowerdev, dev);
 	dev_mc_unsync(lowerdev, dev);
 
@@ -833,6 +866,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (err < 0)
 		goto destroy_port;
 
+	dev->priv_flags |= IFF_MACVLAN;
 	err = netdev_upper_dev_link(lowerdev, dev);
 	if (err)
 		goto destroy_port;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index ddd33fd..c270285 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -61,6 +61,7 @@ struct macvlan_dev {
 	struct hlist_node	hlist;
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
+	void			*fwd_priv;
 	struct macvlan_pcpu_stats __percpu *pcpu_stats;
 
 	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index b05a4b5..1005ebf 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -62,6 +62,7 @@ enum {
 	NETIF_F_HW_VLAN_STAG_TX_BIT,	/* Transmit VLAN STAG HW acceleration */
 	NETIF_F_HW_VLAN_STAG_RX_BIT,	/* Receive VLAN STAG HW acceleration */
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
+	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -116,6 +117,7 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
+#define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e6353ca..d62c130 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -962,6 +962,25 @@ struct netdev_phys_port_id {
  *	Called by vxlan to notify the driver about a UDP port and socket
  *	address family that vxlan is not listening to anymore. The operation
  *	is protected by the vxlan_net->sock_lock.
+ *
+ * void* (*ndo_dfwd_add_station)(struct net_device *pdev,
+ *				 struct net_device *dev)
+ *	Called by upper layer devices to accelerate switching or other
+ *	station functionality into hardware. 'pdev is the lowerdev
+ *	to use for the offload and 'dev' is the net device that will
+ *	back the offload. Returns a pointer to the private structure
+ *	the upper layer will maintain.
+ * void (*ndo_dfwd_del_station)(struct net_device *pdev, void *priv)
+ *	Called by upper layer device to delete the station created
+ *	by 'ndo_dfwd_add_station'. 'pdev' is the net device backing
+ *	the station and priv is the structure returned by the add
+ *	operation.
+ * netdev_tx_t (*ndo_dfwd_start_xmit)(struct sk_buff *skb,
+ *				      struct net_device *dev,
+ *				      void *priv);
+ *	Callback to use for xmit over the accelerated station. This
+ *	is used in place of ndo_start_xmit on accelerated net
+ *	devices.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1098,6 +1117,15 @@ struct net_device_ops {
 	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
 						      __be16 port);
+
+	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
+							struct net_device *dev);
+	void			(*ndo_dfwd_del_station)(struct net_device *pdev,
+							void *priv);
+
+	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
+							struct net_device *dev,
+							void *priv);
 };
 
 /*
@@ -1195,6 +1223,7 @@ struct net_device {
 	/* Management operations */
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
+	const struct forwarding_accel_ops *fwd_ops;
 
 	/* Hardware header description */
 	const struct header_ops *header_ops;
@@ -2388,7 +2417,7 @@ int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_port_id *ppid);
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq);
+			struct netdev_queue *txq, void *accel_priv);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 
 extern int		netdev_budget;
@@ -2967,6 +2996,11 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
+static inline bool netif_is_macvlan(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_MACVLAN;
+}
+
 static inline bool netif_is_bond_master(struct net_device *dev)
 {
 	return dev->flags & IFF_MASTER && dev->priv_flags & IFF_BONDING;
diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1ec407b..d758163 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -83,6 +83,7 @@
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
 					 * change when it's running */
+#define IFF_MACVLAN 0x200000		/* Macvlan device */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/dev.c b/net/core/dev.c
index 0e61365..8ffc52e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2538,7 +2538,7 @@ static inline int skb_needs_linearize(struct sk_buff *skb,
 }
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq)
+			struct netdev_queue *txq, void *accel_priv)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc = NETDEV_TX_OK;
@@ -2604,9 +2604,13 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			dev_queue_xmit_nit(skb, dev);
 
 		skb_len = skb->len;
-		rc = ops->ndo_start_xmit(skb, dev);
+		if (accel_priv)
+			rc = ops->ndo_dfwd_start_xmit(skb, dev, accel_priv);
+		else
+			rc = ops->ndo_start_xmit(skb, dev);
+
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
-		if (rc == NETDEV_TX_OK)
+		if (rc == NETDEV_TX_OK && txq)
 			txq_trans_update(txq);
 		return rc;
 	}
@@ -2622,7 +2626,10 @@ gso:
 			dev_queue_xmit_nit(nskb, dev);
 
 		skb_len = nskb->len;
-		rc = ops->ndo_start_xmit(nskb, dev);
+		if (accel_priv)
+			rc = ops->ndo_dfwd_start_xmit(nskb, dev, accel_priv);
+		else
+			rc = ops->ndo_start_xmit(nskb, dev);
 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
@@ -2647,6 +2654,7 @@ out_kfree_skb:
 out:
 	return rc;
 }
+EXPORT_SYMBOL_GPL(dev_hard_start_xmit);
 
 static void qdisc_pkt_len_init(struct sk_buff *skb)
 {
@@ -2854,7 +2862,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 			if (!netif_xmit_stopped(txq)) {
 				__this_cpu_inc(xmit_recursion);
-				rc = dev_hard_start_xmit(skb, dev, txq);
+				rc = dev_hard_start_xmit(skb, dev, txq, NULL);
 				__this_cpu_dec(xmit_recursion);
 				if (dev_xmit_complete(rc)) {
 					HARD_TX_UNLOCK(dev, txq);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 8629898..30071de 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -96,6 +96,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
 	[NETIF_F_RXALL_BIT] =            "rx-all",
+	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7fc899a..922a094 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -126,7 +126,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_stopped(txq))
-		ret = dev_hard_start_xmit(skb, dev, txq);
+		ret = dev_hard_start_xmit(skb, dev, txq, NULL);
 
 	HARD_TX_UNLOCK(dev, txq);
 
