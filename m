From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 1/4] netdevice: add SW statistics ndo
Date: Fri, 13 May 2016 16:54:14 +0200
Message-ID: <1463151257-3972-2-git-send-email-jiri@resnulli.us>
References: <1463151257-3972-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34294 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbcEMOyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 10:54:22 -0400
Received: by mail-wm0-f66.google.com with SMTP id n129so4202740wmn.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 07:54:21 -0700 (PDT)
In-Reply-To: <1463151257-3972-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Till now we had a ndo statistics function that returned SW statistics.
We want to change the "basic" statistics to return HW statistics if
available.
In this case we need to expose a new ndo to return the SW statistics.
Add a new ndo declaration to get SW statistics
Add a function that gets SW statistics if a competible ndo exist

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
v2->v3:
- added dev_have_sw_stats helper
v1->v2:
- no change
---
 include/linux/netdevice.h | 13 +++++++++++++
 net/core/dev.c            | 31 +++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c2f5112..1513d8b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -891,6 +891,14 @@ struct tc_to_netdev {
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
@@ -1133,6 +1141,9 @@ struct net_device_ops {
 
 	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
 						     struct rtnl_link_stats64 *storage);
+	struct rtnl_link_stats64* (*ndo_get_sw_stats64)(struct net_device *dev,
+							struct rtnl_link_stats64 *storage);
+
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 
 	int			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
@@ -3755,6 +3766,8 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					struct rtnl_link_stats64 *storage);
 void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 			     const struct net_device_stats *netdev_stats);
+int dev_get_sw_stats(struct net_device *dev, struct rtnl_link_stats64 *storage);
+bool dev_have_sw_stats(struct net_device *dev);
 
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
diff --git a/net/core/dev.c b/net/core/dev.c
index 12436d1..82967b7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7376,6 +7376,8 @@ EXPORT_SYMBOL(netdev_stats_to_stats64);
  *	The device driver may provide its own method by setting
  *	dev->netdev_ops->get_stats64 or dev->netdev_ops->get_stats;
  *	otherwise the internal statistics structure is used.
+ *	If device supports both HW & SW statistics - this function should
+ *	return the HW statistics.
  */
 struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					struct rtnl_link_stats64 *storage)
@@ -7397,6 +7399,35 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
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
+bool dev_have_sw_stats(struct net_device *dev)
+{
+	return (dev->netdev_ops->ndo_get_sw_stats64 != NULL);
+}
+EXPORT_SYMBOL(dev_have_sw_stats);
+
 struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 {
 	struct netdev_queue *queue = dev_ingress_queue(dev);
-- 
2.5.5
