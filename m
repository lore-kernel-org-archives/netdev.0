From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net 1/2] macvlan: introduce IFF_MACVLAN flag and helper
 functions
Date: Fri,  8 Nov 2013 14:41:04 +0100 (CET)
Message-ID: <7ca53d743ffa48f671c35335473798c66d908d56.1383915401.git.mkubecek@suse.cz>
References: <cover.1383915401.git.mkubecek@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45944 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756614Ab3KHNlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 08:41:05 -0500
In-Reply-To: <cover.1383915401.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce IFF_MACVLAN flag to recognize macvlan devices and two
helper functions, is_macvlan_dev() and macvlan_dev_real_dev().
These work like similar functions for 802.1q VLAN devices.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 drivers/net/macvlan.c      |  2 +-
 include/linux/if_macvlan.h | 26 ++++++++++++++++++++++++++
 include/uapi/linux/if.h    |  1 +
 3 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9bf46bd..3bdac0a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -685,7 +685,7 @@ void macvlan_common_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags	       &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
-	dev->priv_flags	       |= IFF_UNICAST_FLT;
+	dev->priv_flags	       |= IFF_UNICAST_FLT | IFF_MACVLAN;
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index ddd33fd..8f355f9 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -118,4 +118,30 @@ extern int macvlan_link_register(struct rtnl_link_ops *ops);
 extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
 
+#if IS_ENABLED(CONFIG_MACVLAN)
+static inline bool is_macvlan_dev(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_MACVLAN;
+}
+
+static inline struct net_device *
+macvlan_dev_real_dev(const struct net_device *dev)
+{
+	struct macvlan_dev *macvlan = netdev_priv(dev);
+
+	return macvlan->lowerdev;
+}
+#else
+static inline bool is_macvlan_dev(struct net_device *dev)
+{
+	return false;
+}
+
+static inline struct net_device *
+macvlan_dev_real_dev(const struct net_device *dev)
+{
+	return NULL;
+}
+#endif
+
 #endif /* _LINUX_IF_MACVLAN_H */
diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1ec407b..d8e48f8 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -83,6 +83,7 @@
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
 					 * change when it's running */
+#define IFF_MACVLAN	0x200000	/* macvlan device */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
-- 
1.8.1.4
