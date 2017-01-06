From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net] net: Fix inconsistent rtnl_lock usage on dev_get_stats().
Date: Thu,  5 Jan 2017 23:21:18 -0500
Message-ID: <1483676478-14228-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33747 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753483AbdAFEWe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 23:22:34 -0500
Received: by mail-pg0-f41.google.com with SMTP id g1so208568051pgn.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 20:21:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some callers take rtnl_lock() before calling dev_get_stats() and some
don't.  Most network drivers expect the ndo_get_stats64() to be called
under rtnl_lock() to avoid race conditions with device close or ethtool
reconfigurations.  Fix it so that all callers take rtnl_lock().

Rename the original dev_get_stats() as __dev_get_stats() and add a new
dev_get_stats() that takes rtnl_lock() before calling __dev_get_stats().
Modify all callers that already take rtnl_lock() to call __dev_get_stats().

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/bonding/bond_main.c                      |  4 ++--
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c     |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c     |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c         |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c |  2 +-
 include/linux/netdevice.h                            |  2 ++
 net/core/dev.c                                       | 19 ++++++++++++++++---
 net/core/rtnetlink.c                                 |  4 ++--
 8 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8029dd4..9a2fbea 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1509,7 +1509,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	slave_dev->priv_flags |= IFF_BONDING;
 	/* initialize slave stats */
-	dev_get_stats(new_slave->dev, &new_slave->slave_stats);
+	__dev_get_stats(new_slave->dev, &new_slave->slave_stats);
 
 	if (bond_is_lb(bond)) {
 		/* bond_alb_init_slave() must be called before all other stages since
@@ -3351,7 +3351,7 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 	rcu_read_lock();
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		const struct rtnl_link_stats64 *new =
-			dev_get_stats(slave->dev, &temp);
+			__dev_get_stats(slave->dev, &temp);
 
 		bond_fold_stats(stats, new, &slave->slave_stats);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3ac2183..8396336 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -865,7 +865,7 @@ void hns_get_ethtool_stats(struct net_device *netdev,
 
 	h->dev->ops->update_stats(h, &netdev->stats);
 
-	net_stats = dev_get_stats(netdev, &temp);
+	net_stats = __dev_get_stats(netdev, &temp);
 
 	/* get netdev statistics */
 	p[0] = net_stats->rx_packets;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index fd192bf..f8097c4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1145,7 +1145,7 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 	char *p = NULL;
 
 	ixgbe_update_stats(adapter);
-	net_stats = dev_get_stats(netdev, &temp);
+	net_stats = __dev_get_stats(netdev, &temp);
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
 		switch (ixgbe_gstrings_stats[i].type) {
 		case NETDEV_STATS:
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 508e72c..622ccad 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -406,7 +406,7 @@ static void ixgbevf_get_ethtool_stats(struct net_device *netdev,
 	char *p;
 
 	ixgbevf_update_stats(adapter);
-	net_stats = dev_get_stats(netdev, &temp);
+	net_stats = __dev_get_stats(netdev, &temp);
 	for (i = 0; i < IXGBEVF_GLOBAL_STATS_LEN; i++) {
 		switch (ixgbevf_gstrings_stats[i].type) {
 		case NETDEV_STATS:
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 1b26e96..ea77de0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -270,7 +270,7 @@ static void nfp_net_get_stats(struct net_device *netdev,
 	int i, j, k;
 	u8 *p;
 
-	netdev_stats = dev_get_stats(netdev, &temp);
+	netdev_stats = __dev_get_stats(netdev, &temp);
 
 	for (i = 0; i < NN_ET_GLOBAL_STATS_LEN; i++) {
 		switch (nfp_net_et_stats[i].type) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 994f742..76bc92f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3787,6 +3787,8 @@ static inline void __dev_mc_unsync(struct net_device *dev,
 void netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 void dev_load(struct net *net, const char *name);
+struct rtnl_link_stats64 *__dev_get_stats(struct net_device *dev,
+					  struct rtnl_link_stats64 *storage);
 struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					struct rtnl_link_stats64 *storage);
 void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
diff --git a/net/core/dev.c b/net/core/dev.c
index 8db5a0b..ecd1eee 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7578,7 +7578,7 @@ void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 EXPORT_SYMBOL(netdev_stats_to_stats64);
 
 /**
- *	dev_get_stats	- get network device statistics
+ *	__dev_get_stats	- get network device statistics
  *	@dev: device to get statistics from
  *	@storage: place to store stats
  *
@@ -7587,11 +7587,12 @@ void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
  *	dev->netdev_ops->get_stats64 or dev->netdev_ops->get_stats;
  *	otherwise the internal statistics structure is used.
  */
-struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
-					struct rtnl_link_stats64 *storage)
+struct rtnl_link_stats64 *__dev_get_stats(struct net_device *dev,
+					  struct rtnl_link_stats64 *storage)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
+	ASSERT_RTNL();
 	if (ops->ndo_get_stats64) {
 		memset(storage, 0, sizeof(*storage));
 		ops->ndo_get_stats64(dev, storage);
@@ -7605,6 +7606,18 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 	storage->rx_nohandler += atomic_long_read(&dev->rx_nohandler);
 	return storage;
 }
+EXPORT_SYMBOL(__dev_get_stats);
+
+struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
+					struct rtnl_link_stats64 *storage)
+{
+	struct rtnl_link_stats64 *stats;
+
+	rtnl_lock();
+	stats = __dev_get_stats(dev, storage);
+	rtnl_unlock();
+	return stats;
+}
 EXPORT_SYMBOL(dev_get_stats);
 
 struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 75e3ea7..37c9ccd 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1100,7 +1100,7 @@ static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 		return -EMSGSIZE;
 
 	sp = nla_data(attr);
-	dev_get_stats(dev, sp);
+	__dev_get_stats(dev, sp);
 
 	attr = nla_reserve(skb, IFLA_STATS,
 			   sizeof(struct rtnl_link_stats));
@@ -3767,7 +3767,7 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 			goto nla_put_failure;
 
 		sp = nla_data(attr);
-		dev_get_stats(dev, sp);
+		__dev_get_stats(dev, sp);
 	}
 
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, *idxattr)) {
-- 
1.8.3.1
