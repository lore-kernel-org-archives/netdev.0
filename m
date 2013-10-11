From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/2] net: Add layer 2 hardware acceleration operations for macvlan devices
Date: Fri, 11 Oct 2013 14:43:56 -0400
Message-ID: <1381517037-26007-2-git-send-email-nhorman@tuxdriver.com>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
 <1381517037-26007-1-git-send-email-nhorman@tuxdriver.com>
Cc: john.fastabend@gmail.com, Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57810 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab3JKSoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 14:44:18 -0400
In-Reply-To: <1381517037-26007-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a operations structure that allows a network interface to export the fact
that it supports package forwarding in hardware between physical interfaces and
other mac layer devices assigned to it (such as macvlans).  this operaions
structure can be used by virtual mac devices to bypass software switching so
that forwarding can be done in hardware more efficiently.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: john.fastabend@gmail.com
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/macvlan.c           | 31 +++++++++++++++++++++++++++++++
 include/linux/if_macvlan.h      |  1 +
 include/linux/netdev_features.h |  2 ++
 include/linux/netdevice.h       | 11 ++++++++++-
 include/linux/skbuff.h          |  4 ++--
 net/core/dev.c                  | 18 +++++++++++++-----
 net/core/ethtool.c              |  1 +
 net/sched/sch_generic.c         |  2 +-
 8 files changed, 61 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9bf46bd..c5a2718 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -297,7 +297,16 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	int ret;
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 
+	if (vlan->fwd_priv) {
+		skb->dev = vlan->lowerdev;
+		ret = dev_hard_start_xmit(skb, skb->dev, NULL, vlan->fwd_priv);
+					  
+		if (likely(ret == NETDEV_TX_OK))
+			goto update_stats;
+	}
+
 	ret = macvlan_queue_xmit(skb, dev);
+update_stats:
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
 		struct macvlan_pcpu_stats *pcpu_stats;
 
@@ -347,6 +356,18 @@ static int macvlan_open(struct net_device *dev)
 		goto hash_add;
 	}
 
+	if (lowerdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
+		vlan->fwd_priv = lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev, dev);
+		/*
+		 * If we get a NULL pointer back, or if we get an error
+		 * then we should just fall through to the non accelerated path
+		 */
+		if (IS_ERR_OR_NULL(vlan->fwd_priv))
+			vlan->fwd_priv = NULL;
+		else
+			return 0;
+	}
+
 	err = -EBUSY;
 	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
 		goto out;
@@ -367,6 +388,10 @@ hash_add:
 del_unicast:
 	dev_uc_del(lowerdev, dev->dev_addr);
 out:
+	if (vlan->fwd_priv) {
+		lowerdev->netdev_ops->ndo_dfwd_del_station(lowerdev, vlan->fwd_priv);
+		vlan->fwd_priv = NULL;
+	}	
 	return err;
 }
 
@@ -391,6 +416,11 @@ static int macvlan_stop(struct net_device *dev)
 
 hash_del:
 	macvlan_hash_del(vlan, !dev->dismantle);
+	if (vlan->fwd_priv) {
+		lowerdev->netdev_ops->ndo_dfwd_del_station(lowerdev, vlan->fwd_priv);
+		vlan->fwd_priv = NULL;
+	}
+
 	return 0;
 }
 
@@ -801,6 +831,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		if (err < 0)
 			return err;
 	}
+
 	port = macvlan_port_get_rtnl(lowerdev);
 
 	/* Only 1 macvlan device can be created in passthru mode */
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
index a2a89a5..9d1ee76 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -60,6 +60,7 @@ enum {
 	NETIF_F_HW_VLAN_STAG_TX_BIT,	/* Transmit VLAN STAG HW acceleration */
 	NETIF_F_HW_VLAN_STAG_RX_BIT,	/* Receive VLAN STAG HW acceleration */
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
+	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -112,6 +113,7 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
+#define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3de49ac..0249179 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1097,6 +1097,13 @@ struct net_device_ops {
 	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
 						      __be16 port);
+
+	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
+							struct net_device *vdev);
+	void			(*ndo_dfwd_del_station)(struct net_device *pdev, void *priv);
+
+	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
+							struct net_device *dev, void *priv);
 };
 
 /*
@@ -1183,6 +1190,7 @@ struct net_device {
 	/* Management operations */
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
+	const struct forwarding_accel_ops *fwd_ops;
 
 	/* Hardware header description */
 	const struct header_ops *header_ops;
@@ -2383,7 +2391,8 @@ extern int		dev_get_phys_port_id(struct net_device *dev,
 					     struct netdev_phys_port_id *ppid);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev,
-					    struct netdev_queue *txq);
+					    struct netdev_queue *txq,
+					    void *accel_priv);
 extern int		dev_forward_skb(struct net_device *dev,
 					struct sk_buff *skb);
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d..1710fdb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -426,9 +426,9 @@ struct sk_buff {
 	char			cb[48] __aligned(8);
 
 	unsigned long		_skb_refdst;
-#ifdef CONFIG_XFRM
+
 	struct	sec_path	*sp;
-#endif
+
 	unsigned int		len,
 				data_len;
 	__u16			mac_len,
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2..ecad8c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2536,7 +2536,7 @@ static inline int skb_needs_linearize(struct sk_buff *skb,
 }
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq)
+			struct netdev_queue *txq, void *accel_priv)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc = NETDEV_TX_OK;
@@ -2602,9 +2602,13 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
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
@@ -2620,7 +2624,10 @@ gso:
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
@@ -2645,6 +2652,7 @@ out_kfree_skb:
 out:
 	return rc;
 }
+EXPORT_SYMBOL_GPL(dev_hard_start_xmit);
 
 static void qdisc_pkt_len_init(struct sk_buff *skb)
 {
@@ -2852,7 +2860,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 			if (!netif_xmit_stopped(txq)) {
 				__this_cpu_inc(xmit_recursion);
-				rc = dev_hard_start_xmit(skb, dev, txq);
+				rc = dev_hard_start_xmit(skb, dev, txq, NULL);
 				__this_cpu_dec(xmit_recursion);
 				if (dev_xmit_complete(rc)) {
 					HARD_TX_UNLOCK(dev, txq);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 78e9d92..9f0c599b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -94,6 +94,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
 	[NETIF_F_RXALL_BIT] =            "rx-all",
+	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e7121d2..8c44b1b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -126,7 +126,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_stopped(txq))
-		ret = dev_hard_start_xmit(skb, dev, txq);
+		ret = dev_hard_start_xmit(skb, dev, txq, NULL);
 
 	HARD_TX_UNLOCK(dev, txq);
 
-- 
1.8.3.1
