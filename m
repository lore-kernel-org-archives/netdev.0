From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/2] net: Add layer 2 hardware acceleration operations for macvlan devices
Date: Fri,  4 Oct 2013 16:10:04 -0400
Message-ID: <1380917405-23801-2-git-send-email-nhorman@tuxdriver.com>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
 <1380917405-23801-1-git-send-email-nhorman@tuxdriver.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52912 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab3JDUK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 16:10:26 -0400
In-Reply-To: <1380917405-23801-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a operations structure that allows a network interface to export the fact
that it supports package forwarding in hardware between physical interfaces and
other mac layer devices assigned to it (such as macvlans).  this operaions
structure can be used by virtual mac devices to bypass software switching so
that forwarding can be done in hardware more efficiently.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: John Fastabend <john.r.fastabend@intel.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/macvlan.c      | 32 ++++++++++++++++++++++++++++++++
 include/linux/if_macvlan.h |  1 +
 include/linux/netdevice.h  | 22 ++++++++++++++++++++++
 include/linux/skbuff.h     |  9 ++++++---
 net/core/dev.c             |  3 +++
 5 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9bf46bd..38d0fc5 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -297,7 +297,17 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	int ret;
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 
+	if (vlan->fwd_priv) {
+		skb->dev = vlan->lowerdev;
+		skb->accel_priv = vlan->fwd_priv;
+		ret = dev_queue_xmit(skb);
+		if (likely(ret == NETDEV_TX_OK))
+			goto update_stats;
+	}
+
+	skb->accel_priv = NULL;
 	ret = macvlan_queue_xmit(skb, dev);
+update_stats:
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
 		struct macvlan_pcpu_stats *pcpu_stats;
 
@@ -347,6 +357,18 @@ static int macvlan_open(struct net_device *dev)
 		goto hash_add;
 	}
 
+	if (fwd_accel_supports(lowerdev, FA_FLG_STA_SUPPORT)) {
+		vlan->fwd_priv = fwd_accel_add_station(lowerdev, dev);
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
@@ -367,6 +389,10 @@ hash_add:
 del_unicast:
 	dev_uc_del(lowerdev, dev->dev_addr);
 out:
+	if (vlan->fwd_priv) {
+		fwd_accel_del_station(lowerdev, vlan->fwd_priv);
+		vlan->fwd_priv = NULL;
+	}
 	return err;
 }
 
@@ -391,6 +417,11 @@ static int macvlan_stop(struct net_device *dev)
 
 hash_del:
 	macvlan_hash_del(vlan, !dev->dismantle);
+	if (vlan->fwd_priv) {
+		fwd_accel_del_station(lowerdev, vlan->fwd_priv);
+		vlan->fwd_priv = NULL;
+	}
+
 	return 0;
 }
 
@@ -801,6 +832,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
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
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3de49ac..ea18f07 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1100,6 +1100,27 @@ struct net_device_ops {
 };
 
 /*
+ * Flags to ennumerate hardware acceleration support
+ */
+#define FA_FLG_STA_SUPPORT (1 << 1)
+
+#define fwd_accel_supports(dev, feature) (dev->fwd_ops->flags & feature)
+#define fwd_accel_add_station(pdev, vdev) dev->fwd_ops->fwd_accel_add_station(pdev, vdev)
+#define fwd_accel_del_station(pdev, priv) dev->fwd_ops->fwd_accel_del_station(pdev, priv)
+
+struct forwarding_accel_ops {
+	unsigned int flags;
+
+	/*
+	 * fwd_accel_[add|del]_station must be set if
+	 * FA_FLG_STA_SUPPORT is set
+	 */
+	void*	(*fwd_accel_add_station)(struct net_device *pdev,
+					struct net_device *vdev);
+	void	(*fwd_accel_del_station)(struct net_device *pdev, void *priv);
+};
+
+/*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
  *	data with strictly "high-level" data, and it has to know about
@@ -1183,6 +1204,7 @@ struct net_device {
 	/* Management operations */
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
+	const struct forwarding_accel_ops *fwd_ops;
 
 	/* Hardware header description */
 	const struct header_ops *header_ops;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d..0be9152 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -426,9 +426,12 @@ struct sk_buff {
 	char			cb[48] __aligned(8);
 
 	unsigned long		_skb_refdst;
-#ifdef CONFIG_XFRM
-	struct	sec_path	*sp;
-#endif
+
+	union {
+		struct	sec_path	*sp;
+		void 			*accel_priv;
+	};
+
 	unsigned int		len,
 				data_len;
 	__u16			mac_len,
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2..5f99382 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5992,6 +5992,7 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 }
 
 static const struct ethtool_ops default_ethtool_ops;
+static const struct forwarding_accel_ops default_fwd_ops;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops)
@@ -6090,6 +6091,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	dev->group = INIT_NETDEV_GROUP;
 	if (!dev->ethtool_ops)
 		dev->ethtool_ops = &default_ethtool_ops;
+	if (!dev->fwd_ops)
+		dev->fwd_ops = &default_fwd_ops;
 	return dev;
 
 free_all:
-- 
1.8.3.1
