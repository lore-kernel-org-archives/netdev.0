From: sainath.grandhi@intel.com
Subject: [PATCH RFC v1 2/3] net: Abstracting out common routines from veth for use by vethtap
Date: Wed,  6 Sep 2017 17:34:26 -0700
Message-ID: <1504744467-79590-3-git-send-email-sainath.grandhi@intel.com>
References: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, Sainath Grandhi <sainath.grandhi@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:52065 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751978AbdIGAh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 20:37:59 -0400
In-Reply-To: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sainath Grandhi <sainath.grandhi@intel.com>

Abstracting out common routines for link operations in veth implementation
for use by vethtap interfaces

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 drivers/net/veth.c      | 47 +++++++++++++++++++++++++++++++++--------------
 include/linux/if_veth.h |  9 +++++++++
 2 files changed, 42 insertions(+), 14 deletions(-)
 create mode 100644 include/linux/if_veth.h

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f5438d0..a1b370d 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -18,6 +18,7 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 #include <linux/veth.h>
+#include <linux/if_veth.h>
 #include <linux/module.h>
 
 #define DRV_NAME	"veth"
@@ -29,12 +30,6 @@ struct pcpu_vstats {
 	struct u64_stats_sync	syncp;
 };
 
-struct veth_priv {
-	struct net_device __rcu	*peer;
-	atomic64_t		dropped;
-	unsigned		requested_headroom;
-};
-
 /*
  * ethtool interface
  */
@@ -298,13 +293,12 @@ static const struct net_device_ops veth_netdev_ops = {
 		       NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | \
 		       NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_STAG_RX )
 
-static void veth_setup(struct net_device *dev)
+void veth_common_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
-	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->priv_flags |= IFF_PHONY_HEADROOM;
 
 	dev->netdev_ops = &veth_netdev_ops;
@@ -325,6 +319,12 @@ static void veth_setup(struct net_device *dev)
 	dev->mpls_features = NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE;
 }
 
+static void veth_setup(struct net_device *dev)
+{
+	veth_common_setup(dev);
+	dev->priv_flags |= IFF_NO_QUEUE;
+}
+
 /*
  * netlink interface
  */
@@ -465,7 +465,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	return err;
 }
 
-static void veth_dellink(struct net_device *dev, struct list_head *head)
+void veth_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct veth_priv *priv;
 	struct net_device *peer;
@@ -503,21 +503,40 @@ static struct rtnl_link_ops veth_link_ops = {
 	.kind		= DRV_NAME,
 	.priv_size	= sizeof(struct veth_priv),
 	.setup		= veth_setup,
-	.validate	= veth_validate,
 	.newlink	= veth_newlink,
 	.dellink	= veth_dellink,
-	.policy		= veth_policy,
-	.maxtype	= VETH_INFO_MAX,
-	.get_link_net	= veth_get_link_net,
 };
 
+int veth_link_register(struct rtnl_link_ops *ops)
+{
+	/* common fields */
+	ops->validate     = veth_validate;
+	ops->policy       = veth_policy;
+	ops->maxtype      = VETH_INFO_MAX;
+	ops->get_link_net = veth_get_link_net;
+
+	return rtnl_link_register(ops);
+}
+
+void veth_link_ops_init(struct rtnl_link_ops *ops)
+{
+	/*common fields*/
+	ops->validate       = veth_validate;
+	ops->policy         = veth_policy;
+	ops->maxtype        = VETH_INFO_MAX;
+	ops->get_link_net   = veth_get_link_net;
+}
 /*
  * init/fini
  */
 
 static __init int veth_init(void)
 {
-	return rtnl_link_register(&veth_link_ops);
+	int err;
+
+	err = veth_link_register(&veth_link_ops);
+
+	return err;
 }
 
 static __exit void veth_exit(void)
diff --git a/include/linux/if_veth.h b/include/linux/if_veth.h
new file mode 100644
index 0000000..b007891
--- /dev/null
+++ b/include/linux/if_veth.h
@@ -0,0 +1,9 @@
+struct veth_priv {
+	struct net_device __rcu *peer;
+	atomic64_t              dropped;
+	unsigned int            requested_headroom;
+};
+
+void veth_common_setup(struct net_device *dev);
+void veth_dellink(struct net_device *dev, struct list_head *head);
+void veth_link_ops_init(struct rtnl_link_ops *ops);
-- 
2.7.4
