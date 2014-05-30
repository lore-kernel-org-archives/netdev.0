From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next] macvlan: add netpoll support
Date: Fri, 30 May 2014 16:00:56 +0800
Message-ID: <53883AB8.6030205@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:38252 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbaE3IB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 04:01:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netpoll support to macvlan devices. Based on the netpoll support in the 802.1q vlan code.

Tested and macvlan could work well with netconsole.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c      | 66 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_macvlan.h |  3 +++
 2 files changed, 68 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3e24770..45ebb91 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -33,6 +33,7 @@
 #include <linux/workqueue.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
+#include <linux/netpoll.h>
 
 #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
 
@@ -357,12 +358,26 @@ xmit_world:
 	return dev_queue_xmit(skb);
 }
 
+static inline netdev_tx_t macvlan_netpoll_send_skb(struct macvlan_dev *vlan, struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (vlan->netpoll)
+		netpoll_send_skb(vlan->netpoll, skb);
+#else
+	BUG();
+#endif
+	return NETDEV_TX_OK;
+}
+
 static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
 	unsigned int len = skb->len;
 	int ret;
-	const struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	if (unlikely(netpoll_tx_running(dev)))
+		return macvlan_netpoll_send_skb(vlan, skb);
 
 	if (vlan->fwd_priv) {
 		skb->dev = vlan->lowerdev;
@@ -786,6 +801,50 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
 	return features;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void macvlan_dev_poll_controller(struct net_device *dev)
+{
+	return;
+}
+
+static int macvlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *real_dev = vlan->lowerdev;
+	struct netpoll *netpoll;
+	int err = 0;
+
+	netpoll = kzalloc(sizeof(*netpoll), GFP_KERNEL);
+	err = -ENOMEM;
+	if (!netpoll)
+		goto out;
+
+	err = __netpoll_setup(netpoll, real_dev);
+	if (err) {
+		kfree(netpoll);
+		goto out;
+	}
+
+	vlan->netpoll = netpoll;
+
+out:
+	return err;
+}
+
+static void macvlan_dev_netpoll_cleanup(struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct netpoll *netpoll = vlan->netpoll;
+
+	if (!netpoll)
+		return;
+
+	vlan->netpoll = NULL;
+
+	__netpoll_free_async(netpoll);
+}
+#endif	/* CONFIG_NET_POLL_CONTROLLER */
+
 static const struct ethtool_ops macvlan_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_settings		= macvlan_ethtool_get_settings,
@@ -811,6 +870,11 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_fdb_del		= macvlan_fdb_del,
 	.ndo_fdb_dump		= ndo_dflt_fdb_dump,
 	.ndo_get_lock_subclass  = macvlan_get_nest_level,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= macvlan_dev_poll_controller,
+	.ndo_netpoll_setup	= macvlan_dev_netpoll_setup,
+	.ndo_netpoll_cleanup	= macvlan_dev_netpoll_cleanup,
+#endif
 };
 
 void macvlan_common_setup(struct net_device *dev)
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index a9a53b1..6b2c7cf 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -57,6 +57,9 @@ struct macvlan_dev {
 	netdev_features_t	tap_features;
 	int			minor;
 	int			nest_level;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct netpoll		*netpoll;
+#endif
 };
 
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
-- 
1.8.0
