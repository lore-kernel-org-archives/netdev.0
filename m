From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 1/5] net: dsa: Add infrastructure to support LAG
Date: Sun,  1 Oct 2017 12:46:35 -0700
Message-ID: <20171001194639.8647-2-f.fainelli@gmail.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us, idosch@mellanox.com, Woojung.Huh@microchip.com,
        john@phrozen.org, sean.wang@mediatek.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:37172 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdJATqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 15:46:49 -0400
Received: by mail-oi0-f68.google.com with SMTP id h9so2118049oia.4
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 12:46:49 -0700 (PDT)
In-Reply-To: <20171001194639.8647-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the necessary logic to support network device events targetting LAG events,
this is loosely inspired from mlxsw/spectrum.c.

In the process we change dsa_slave_changeupper() to be more generic and be called
from both LAG events as well as normal bridge enslaving events paths.

The DSA layer takes care of managing the LAG group identifiers, how many LAGs
may be supported by a switch, and how many members per LAG are supported by a
switch device. When a LAG group is identified, the port is then configured to
be a part of that group. When a LAG group no longer has any users, we remove it
and we tell the drivers whether it is safe to disable trunking altogether.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h  |  25 +++++++++
 net/dsa/dsa2.c     |  12 ++++
 net/dsa/dsa_priv.h |   7 +++
 net/dsa/port.c     |  92 +++++++++++++++++++++++++++++++
 net/dsa/slave.c    | 157 +++++++++++++++++++++++++++++++++++++++++++++++++----
 net/dsa/switch.c   |  30 ++++++++++
 6 files changed, 312 insertions(+), 11 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 10dceccd9ce8..247ea58add68 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -182,12 +182,20 @@ struct dsa_port {
 	u8			stp_state;
 	struct net_device	*bridge_dev;
 	struct devlink_port	devlink_port;
+	u8			lag_id;
+	bool			lagged;
 	/*
 	 * Original copy of the master netdev ethtool_ops
 	 */
 	const struct ethtool_ops *orig_ethtool_ops;
 };
 
+struct dsa_lag_group {
+	/* Used to know when we can disable lag on the switch */
+	unsigned int		ref_count;
+	struct net_device	*lag_dev;
+};
+
 struct dsa_switch {
 	struct device *dev;
 
@@ -242,6 +250,12 @@ struct dsa_switch {
 	/* Number of switch port queues */
 	unsigned int		num_tx_queues;
 
+	/* Number of lag groups */
+	unsigned int		max_lags;
+	struct dsa_lag_group	*lags;
+	/* Number of members per lag group */
+	unsigned int		max_lag_members;
+
 	/* Dynamically allocated ports, keep last */
 	size_t num_ports;
 	struct dsa_port ports[];
@@ -431,6 +445,16 @@ struct dsa_switch_ops {
 					 int port, struct net_device *br);
 	void	(*crosschip_bridge_leave)(struct dsa_switch *ds, int sw_index,
 					  int port, struct net_device *br);
+
+	/*
+	 * Link aggregation
+	 */
+	bool	(*port_lag_member)(struct dsa_switch *ds, int port, u8 lag_id);
+	int	(*port_lag_join)(struct dsa_switch *ds, int port, u8 lag_id);
+	void	(*port_lag_leave)(struct dsa_switch *ds, int port, u8 lag_id,
+				  bool lag_disable);
+	int	(*port_lag_change)(struct dsa_switch *ds, int port,
+				   struct netdev_lag_lower_state_info *info);
 };
 
 struct dsa_switch_driver {
@@ -455,6 +479,7 @@ static inline bool netdev_uses_dsa(struct net_device *dev)
 }
 
 struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n);
+int dsa_switch_alloc_lags(struct dsa_switch *ds, size_t n);
 void dsa_unregister_switch(struct dsa_switch *ds);
 int dsa_register_switch(struct dsa_switch *ds);
 #ifdef CONFIG_PM_SLEEP
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 54ed054777bd..dddf8128ba04 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -813,6 +813,18 @@ struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n)
 }
 EXPORT_SYMBOL_GPL(dsa_switch_alloc);
 
+int dsa_switch_alloc_lags(struct dsa_switch *ds, size_t n)
+{
+	ds->max_lags = n;
+	ds->lags = devm_kcalloc(ds->dev, ds->max_lags,
+			        sizeof(*ds->lags), GFP_KERNEL);
+	if (!ds->lags)
+		return -ENOMEM;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dsa_switch_alloc_lags);
+
 int dsa_register_switch(struct dsa_switch *ds)
 {
 	int err;
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 2850077cc9cc..0bd964bd9642 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -159,6 +159,11 @@ int dsa_port_vlan_add(struct dsa_port *dp,
 		      struct switchdev_trans *trans);
 int dsa_port_vlan_del(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan);
+int dsa_port_lag_join(struct dsa_port *dp, struct net_device *lag_dev);
+int dsa_port_lag_leave(struct dsa_port *dp, struct net_device *lag_dev);
+int dsa_port_lag_change(struct dsa_port *dp,
+			struct netdev_lag_lower_state_info *info);
+
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
@@ -170,6 +175,8 @@ int dsa_slave_register_notifier(void);
 void dsa_slave_unregister_notifier(void);
 
 /* switch.c */
+int dsa_switch_lag_get_index(struct dsa_switch *ds, struct net_device *lag_dev,
+			     u8 *lag_id);
 int dsa_switch_register_notifier(struct dsa_switch *ds);
 void dsa_switch_unregister_notifier(struct dsa_switch *ds);
 
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 72c8dbd3d3f2..d62fa7bfab4b 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -264,3 +264,95 @@ int dsa_port_vlan_del(struct dsa_port *dp,
 
 	return dsa_port_notify(dp, DSA_NOTIFIER_VLAN_DEL, &info);
 }
+
+static int dsa_port_lag_member(struct dsa_port *dp, u8 lag_id)
+{
+	struct dsa_switch *ds = dp->ds;
+	int err = -EOPNOTSUPP;
+	unsigned int i;
+
+	if (!ds->ops->port_lag_member && !ds->max_lag_members)
+		return err;
+
+	for (i = 0; i < ds->max_lag_members; i++) {
+		if (!ds->ops->port_lag_member(ds, i, lag_id)) {
+			return 0;
+		}
+	}
+
+	return -EBUSY;
+}
+
+int dsa_port_lag_join(struct dsa_port *dp, struct net_device *lag_dev)
+{
+	struct dsa_switch *ds = dp->ds;
+	struct dsa_lag_group *lag;
+	int err = -EOPNOTSUPP;
+	u8 lag_id;
+
+	if (!ds->ops->port_lag_join)
+		return err;
+
+	/* Obtain a new lag identifier */
+	err = dsa_switch_lag_get_index(ds, lag_dev, &lag_id);
+	if (err)
+		return err;
+
+	/* Create a lag group if non-existent */
+	lag = &ds->lags[lag_id];
+	if (!lag->ref_count)
+		lag->lag_dev = lag_dev;
+
+	err = dsa_port_lag_member(dp, lag_id);
+	if (err)
+		return err;
+
+	err = ds->ops->port_lag_join(ds, dp->index, lag_id);
+	if (err)
+		return err;
+
+	dp->lag_id = lag_id;
+	dp->lagged = true;
+	lag->ref_count++;
+
+	return err;
+}
+
+int dsa_port_lag_leave(struct dsa_port *dp, struct net_device *lag_dev)
+{
+	struct dsa_switch *ds = dp->ds;
+	struct dsa_lag_group *lag;
+	bool lag_disable = false;
+	int err = -EOPNOTSUPP;
+	u8 lag_id;
+
+	if (!ds->ops->port_lag_join)
+		return err;
+
+	if (!dp->lagged)
+		return 0;
+
+	lag_id = dp->lag_id;
+	lag = &ds->lags[lag_id];
+	WARN_ON(lag->ref_count == 0);
+
+	if (lag->ref_count == 1)
+		lag_disable = true;
+
+	ds->ops->port_lag_leave(ds, dp->index, lag_id, lag_disable);
+	dp->lagged = false;
+	lag->ref_count--;
+
+	return err;
+}
+
+int dsa_port_lag_change(struct dsa_port *dp,
+			struct netdev_lag_lower_state_info *info)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (!ds->ops->port_lag_change)
+		return -EOPNOTSUPP;
+
+	return ds->ops->port_lag_change(ds, dp->index, info);
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 4b634db05cee..b64320aa20f1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1216,36 +1216,171 @@ static bool dsa_slave_dev_check(struct net_device *dev)
 	return dev->netdev_ops == &dsa_slave_netdev_ops;
 }
 
-static int dsa_slave_changeupper(struct net_device *dev,
-				 struct netdev_notifier_changeupper_info *info)
+static bool dsa_slave_lag_check(struct net_device *dev, struct net_device *lag_dev,
+				struct netdev_lag_upper_info *lag_upper_info)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	u8 lag_id;
+
+	/* No more lag identifiers available or already in use */
+	if (dsa_switch_lag_get_index(p->dp->ds, lag_dev, &lag_id) != 0)
+		return false;
+
+	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH)
+		return false;
+
+	return true;
+}
+
+static int dsa_slave_changeupper_bridge(struct net_device *dev,
+					struct netdev_notifier_changeupper_info *info)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_port *dp = p->dp;
 	int err = NOTIFY_DONE;
 
-	if (netif_is_bridge_master(info->upper_dev)) {
-		if (info->linking) {
-			err = dsa_port_bridge_join(dp, info->upper_dev);
-			err = notifier_from_errno(err);
-		} else {
-			dsa_port_bridge_leave(dp, info->upper_dev);
-			err = NOTIFY_OK;
-		}
+	if (info->linking) {
+		err = dsa_port_bridge_join(dp, info->upper_dev);
+		err = notifier_from_errno(err);
+	} else {
+		dsa_port_bridge_leave(dp, info->upper_dev);
+		err = NOTIFY_OK;
+	}
+
+	return err;
+}
+
+static int dsa_slave_changeupper_lag(struct net_device *dev,
+				     struct netdev_notifier_changeupper_info *info)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+	int err = NOTIFY_DONE;
+
+	if (info->linking) {
+		err = dsa_port_lag_join(dp, info->upper_dev);
+		err = notifier_from_errno(err);
+	} else {
+		err = dsa_port_lag_leave(dp, info->upper_dev);
+		err = NOTIFY_OK;
+	}
+
+	return err;
+}
+
+static int dsa_slave_upper_event(struct net_device *lower_dev,
+				 struct net_device *slave_dev, unsigned long event,
+				 void *ptr)
+{
+	struct netdev_notifier_changeupper_info *info;
+	struct net_device *upper_dev;
+	struct dsa_slave_priv *p;
+	int err = 0;
+
+	info = ptr;
+	p = netdev_priv(slave_dev);
+
+	switch (event) {
+	case NETDEV_PRECHANGEUPPER:
+		upper_dev = info->upper_dev;
+		if (!is_vlan_dev(upper_dev) &&
+		    !netif_is_lag_master(upper_dev) &&
+		    !netif_is_bridge_master(upper_dev))
+			return -EINVAL;
+
+		if (!info->linking)
+			break;
+
+		if (netdev_has_any_upper_dev(upper_dev))
+			return -EINVAL;
+
+		if (netif_is_lag_master(upper_dev) &&
+		    !dsa_slave_lag_check(lower_dev, upper_dev, info->upper_info))
+			return -EINVAL;
+
+		break;
+	case NETDEV_CHANGEUPPER:
+		upper_dev = info->upper_dev;
+		if (netif_is_bridge_master(upper_dev))
+			err = dsa_slave_changeupper_bridge(lower_dev, info);
+		else if (netif_is_lag_master(upper_dev))
+			err = dsa_slave_changeupper_lag(lower_dev, info);
+		break;
 	}
 
 	return err;
 }
 
+static int dsa_slave_lower_event(struct net_device *dev,
+				 unsigned long event, void *ptr)
+{
+	struct netdev_notifier_changelowerstate_info *info;
+	struct dsa_slave_priv *p;
+	int err;
+
+	p = netdev_priv(dev);
+	info = ptr;
+
+	switch (event) {
+	case NETDEV_CHANGELOWERSTATE:
+		if (netif_is_lag_port(dev) && p->dp->lagged) {
+			err = dsa_port_lag_change(p->dp, info->lower_state_info);
+			if (err)
+				netdev_err(dev, "Failed to reflect LAG\n");
+		}
+		break;
+	}
+
+	return 0;
+}
+
+static int dsa_slave_upper_lower_event(struct net_device *lower_dev,
+				       struct net_device *slave_dev,
+				       unsigned long event, void *ptr)
+{
+	switch (event) {
+	case NETDEV_PRECHANGEUPPER:
+	case NETDEV_CHANGEUPPER:
+		return dsa_slave_upper_event(lower_dev, slave_dev, event, ptr);
+	case NETDEV_CHANGELOWERSTATE:
+		return dsa_slave_lower_event(slave_dev, event, ptr);
+	}
+
+	return NOTIFY_OK;
+}
+
+static int dsa_slave_lag_event(struct net_device *lag_dev,
+				unsigned long event, void *ptr)
+{
+	struct net_device *dev;
+	struct list_head *iter;
+	int err;
+
+	netdev_for_each_lower_dev(lag_dev, dev, iter) {
+		if (dsa_slave_dev_check(dev)) {
+			err = dsa_slave_upper_lower_event(lag_dev, dev,
+							  event, ptr);
+			if (err)
+				return err;
+		}
+	}
+
+	return NOTIFY_OK;
+}
+
 static int dsa_slave_netdevice_event(struct notifier_block *nb,
 				     unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
+	if (netif_is_lag_master(dev))
+		return dsa_slave_lag_event(dev, event, ptr);
+
 	if (!dsa_slave_dev_check(dev))
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_CHANGEUPPER)
-		return dsa_slave_changeupper(dev, ptr);
+		return dsa_slave_upper_event(dev, dev, event, ptr);
 
 	return NOTIFY_DONE;
 }
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index e6c06aa349a6..9ce1b25bf197 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -252,6 +252,36 @@ static int dsa_switch_event(struct notifier_block *nb,
 	return notifier_from_errno(err);
 }
 
+int dsa_switch_lag_get_index(struct dsa_switch *ds, struct net_device *lag_dev,
+			     u8 *lag_id)
+{
+	struct dsa_lag_group *lag;
+	int free_lag_idx = -1;
+	unsigned int i;
+
+	if (!ds->max_lags)
+		return -EOPNOTSUPP;
+
+	for (i = 0; i < ds->max_lags; i++) {
+		lag = &ds->lags[i];
+		if (lag->ref_count) {
+			if (lag->lag_dev == lag_dev) {
+				*lag_id = i;
+				return 0;
+			}
+		} else if (free_lag_idx < 0) {
+			free_lag_idx = i;
+		}
+	}
+
+	if (free_lag_idx < 0)
+		return -EBUSY;
+
+	*lag_id = free_lag_idx;
+
+	return 0;
+}
+
 int dsa_switch_register_notifier(struct dsa_switch *ds)
 {
 	ds->nb.notifier_call = dsa_switch_event;
-- 
2.11.0
