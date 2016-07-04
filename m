From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/14] mlxsw: spectrum: Add couple of lower device helper functions
Date: Mon,  4 Jul 2016 08:23:12 +0200
Message-ID: <1467613397-17140-10-git-send-email-jiri@resnulli.us>
References: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33402 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbcGDGXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 02:23:33 -0400
Received: by mail-wm0-f66.google.com with SMTP id r201so19141474wme.0
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 23:23:32 -0700 (PDT)
In-Reply-To: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add functions that iterate over lower devices and find port device.
As a dependency add netdev_for_each_all_lower_dev and
netdev_for_each_all_lower_dev_rcu macro with
netdev_all_lower_get_next and netdev_all_lower_get_next_rcu shelpers.

Also, add functions to return mlxsw struct according to lower device
found and mlxsw_port struct with a reference to lower device.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 65 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  3 ++
 include/linux/netdevice.h                      | 18 +++++++
 net/core/dev.c                                 | 46 ++++++++++++++++++
 4 files changed, 127 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f0799898..f54fd6a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2567,6 +2567,66 @@ static struct mlxsw_driver mlxsw_sp_driver = {
 	.profile			= &mlxsw_sp_config_profile,
 };
 
+static bool mlxsw_sp_port_dev_check(const struct net_device *dev)
+{
+	return dev->netdev_ops == &mlxsw_sp_port_netdev_ops;
+}
+
+static struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find(struct net_device *dev)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+
+	if (mlxsw_sp_port_dev_check(dev))
+		return netdev_priv(dev);
+
+	netdev_for_each_all_lower_dev(dev, lower_dev, iter) {
+		if (mlxsw_sp_port_dev_check(lower_dev))
+			return netdev_priv(lower_dev);
+	}
+	return NULL;
+}
+
+static struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port;
+
+	mlxsw_sp_port = mlxsw_sp_port_dev_lower_find(dev);
+	return mlxsw_sp_port ? mlxsw_sp_port->mlxsw_sp : NULL;
+}
+
+static struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find_rcu(struct net_device *dev)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+
+	if (mlxsw_sp_port_dev_check(dev))
+		return netdev_priv(dev);
+
+	netdev_for_each_all_lower_dev_rcu(dev, lower_dev, iter) {
+		if (mlxsw_sp_port_dev_check(lower_dev))
+			return netdev_priv(lower_dev);
+	}
+	return NULL;
+}
+
+struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port;
+
+	rcu_read_lock();
+	mlxsw_sp_port = mlxsw_sp_port_dev_lower_find_rcu(dev);
+	if (mlxsw_sp_port)
+		dev_hold(mlxsw_sp_port->dev);
+	rcu_read_unlock();
+	return mlxsw_sp_port;
+}
+
+void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	dev_put(mlxsw_sp_port->dev);
+}
+
 static bool mlxsw_sp_lag_port_fid_member(struct mlxsw_sp_port *lag_port,
 					 u16 fid)
 {
@@ -2647,11 +2707,6 @@ int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
 		return mlxsw_sp_port_fdb_flush_by_port_fid(mlxsw_sp_port, fid);
 }
 
-static bool mlxsw_sp_port_dev_check(const struct net_device *dev)
-{
-	return dev->netdev_ops == &mlxsw_sp_port_netdev_ops;
-}
-
 static bool mlxsw_sp_master_bridge_check(struct mlxsw_sp *mlxsw_sp,
 					 struct net_device *br_dev)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 877a879..fefff25 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -292,6 +292,9 @@ struct mlxsw_sp_port {
 	struct list_head vports_list;
 };
 
+struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
+void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port);
+
 static inline bool
 mlxsw_sp_port_is_pause_en(const struct mlxsw_sp_port *mlxsw_sp_port)
 {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7dc2ec7..0c6ee2c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3804,12 +3804,30 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 
 void *netdev_lower_get_next(struct net_device *dev,
 				struct list_head **iter);
+
 #define netdev_for_each_lower_dev(dev, ldev, iter) \
 	for (iter = (dev)->adj_list.lower.next, \
 	     ldev = netdev_lower_get_next(dev, &(iter)); \
 	     ldev; \
 	     ldev = netdev_lower_get_next(dev, &(iter)))
 
+struct net_device *netdev_all_lower_get_next(struct net_device *dev,
+					     struct list_head **iter);
+struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
+						 struct list_head **iter);
+
+#define netdev_for_each_all_lower_dev(dev, ldev, iter) \
+	for (iter = (dev)->all_adj_list.lower.next, \
+	     ldev = netdev_all_lower_get_next(dev, &(iter)); \
+	     ldev; \
+	     ldev = netdev_all_lower_get_next(dev, &(iter)))
+
+#define netdev_for_each_all_lower_dev_rcu(dev, ldev, iter) \
+	for (iter = (dev)->all_adj_list.lower.next, \
+	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)); \
+	     ldev; \
+	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)))
+
 void *netdev_adjacent_get_private(struct list_head *adj_list);
 void *netdev_lower_get_first_private_rcu(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index aba10d2..a4f3b0a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5445,6 +5445,52 @@ void *netdev_lower_get_next(struct net_device *dev, struct list_head **iter)
 EXPORT_SYMBOL(netdev_lower_get_next);
 
 /**
+ * netdev_all_lower_get_next - Get the next device from all lower neighbour list
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent from the dev's all lower neighbour
+ * list, starting from iter position. The caller must hold RTNL lock or
+ * its own locking that guarantees that the neighbour all lower
+ * list will remain unchanged.
+ */
+struct net_device *netdev_all_lower_get_next(struct net_device *dev, struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	lower = list_entry(*iter, struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->all_adj_list.lower)
+		return NULL;
+
+	*iter = lower->list.next;
+
+	return lower->dev;
+}
+EXPORT_SYMBOL(netdev_all_lower_get_next);
+
+/**
+ * netdev_all_lower_get_next_rcu - Get the next device from all
+ *				   lower neighbour list, RCU variant
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent from the dev's all lower neighbour
+ * list, starting from iter position. The caller must hold RCU read lock.
+ */
+struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
+						 struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	lower = list_first_or_null_rcu(&dev->all_adj_list.lower,
+				       struct netdev_adjacent, list);
+
+	return lower ? lower->dev : NULL;
+}
+EXPORT_SYMBOL(netdev_all_lower_get_next_rcu);
+
+/**
  * netdev_lower_get_first_private_rcu - Get the first ->private from the
  *				       lower neighbour list, RCU
  *				       variant
-- 
2.5.5
