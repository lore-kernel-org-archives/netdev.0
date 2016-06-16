From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 1/4] netdevice: add SW statistics ndo
Date: Thu, 16 Jun 2016 10:37:14 +0200
Message-ID: <1466066237-7719-2-git-send-email-jiri@resnulli.us>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35706 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbcFPIhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 04:37:25 -0400
Received: by mail-wm0-f66.google.com with SMTP id k184so9580327wme.2
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 01:37:24 -0700 (PDT)
In-Reply-To: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Till now we had a ndo statistics function that returned SW statistics.
We want to change the "basic" statistics to return HW statistics if
available.
In this case we need to expose a new ndo to return the SW statistics.
Add a new ndo declaration to get SW statistics
Add a function that gets SW statistics if a compatible ndo exist

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 13 +++++++++++++
 net/core/dev.c            | 31 +++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 890158e..6338e38 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -890,6 +890,14 @@ struct tc_to_netdev {
  *	   field is written atomically.
  *	3. Update dev->stats asynchronously and atomically, and define
  *	   neither operation.
+ *	Driver should return HW statistics, if available.
+ *
+ * struct rtnl_link_stats64* (*ndo_get_sw_stats64)(struct net_device *dev,
+ *			struct rtnl_link_stats64 *storage);
+ *	Similar to rtnl_link_stats64 but used to get SW statistics,
+ *	if it is possible to get HW and SW statistics separately.
+ *	If this option isn't valid - driver doesn't need to define
+ *	this function.
  *
  * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, __be16 proto, u16 vid);
  *	If device supports VLAN filtering this function is called when a
@@ -1132,6 +1140,9 @@ struct net_device_ops {
 
 	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
 						     struct rtnl_link_stats64 *storage);
+	struct rtnl_link_stats64* (*ndo_get_sw_stats64)(struct net_device *dev,
+							struct rtnl_link_stats64 *storage);
+
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 
 	int			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
@@ -3779,6 +3790,8 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					struct rtnl_link_stats64 *storage);
 void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 			     const struct net_device_stats *netdev_stats);
+int dev_get_sw_stats(struct net_device *dev, struct rtnl_link_stats64 *storage);
+bool dev_have_sw_stats(const struct net_device *dev);
 
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
diff --git a/net/core/dev.c b/net/core/dev.c
index b148357..087f0ea 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7368,6 +7368,8 @@ EXPORT_SYMBOL(netdev_stats_to_stats64);
  *	The device driver may provide its own method by setting
  *	dev->netdev_ops->get_stats64 or dev->netdev_ops->get_stats;
  *	otherwise the internal statistics structure is used.
+ *	If device supports both HW & SW statistics - this function should
+ *	return the HW statistics.
  */
 struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					struct rtnl_link_stats64 *storage)
@@ -7389,6 +7391,35 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 }
 EXPORT_SYMBOL(dev_get_stats);
 
+/*	dev_get_sw_stats    - get network device SW statistics
+ *	(if it is possible to get HW & SW statistics separately)
+ *	@dev: device to get statistics from
+ *	@storage: place to store stats
+ *
+ *	if exist a function to query the netdev SW statistics get it to storage
+ *	return 0 if did, or -EINVAL if this function doesn't exist
+ */
+int dev_get_sw_stats(struct net_device *dev,
+		     struct rtnl_link_stats64 *storage)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (ops->ndo_get_sw_stats64) {
+		memset(storage, 0, sizeof(*storage));
+		ops->ndo_get_sw_stats64(dev, storage);
+	} else {
+		return -EINVAL;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(dev_get_sw_stats);
+
+bool dev_have_sw_stats(const struct net_device *dev)
+{
+	return dev->netdev_ops->ndo_get_sw_stats64 != NULL;
+}
+EXPORT_SYMBOL(dev_have_sw_stats);
+
 struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 {
 	struct netdev_queue *queue = dev_ingress_queue(dev);
-- 
2.5.5
