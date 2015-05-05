From: sfeldma@gmail.com
Subject: [PATCH net-next v5 04/21] switchdev: convert parent_id_get to switchdev attr get
Date: Tue,  5 May 2015 10:34:40 -0700
Message-ID: <1430847297-15728-5-git-send-email-sfeldma@gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36384 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965329AbbEEReE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:34:04 -0400
Received: by pabsx10 with SMTP id sx10so200251606pab.3
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 10:34:04 -0700 (PDT)
In-Reply-To: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Switch ID is just a gettable port attribute.  Convert switchdev op
switchdev_parent_id_get to a switchdev attr.

Note: for sysfs and netlink interfaces, SWITCHDEV_ATTR_PORT_PARENT_ID is
called with SWITCHDEV_F_NO_RECUSE to limit switch ID user-visiblity to only
port netdevs.  So when a port is stacked under bond/bridge, the user can
only query switch id via the switch ports, but not via the upper devices

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   17 ++++++++++-----
 include/net/switchdev.h              |   18 ++++------------
 net/core/net-sysfs.c                 |   10 ++++++---
 net/core/rtnetlink.c                 |    9 +++++---
 net/dsa/slave.c                      |   16 +++++++++-----
 net/switchdev/switchdev.c            |   38 ++++++++++------------------------
 6 files changed, 51 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 7473874..2428299 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4221,14 +4221,21 @@ static const struct net_device_ops rocker_port_netdev_ops = {
  * swdev interface
  ********************/
 
-static int rocker_port_switchdev_parent_id_get(struct net_device *dev,
-					       struct netdev_phys_item_id *psid)
+static int rocker_port_attr_get(struct net_device *dev,
+				struct switchdev_attr *attr)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct rocker *rocker = rocker_port->rocker;
 
-	psid->id_len = sizeof(rocker->hw.id);
-	memcpy(&psid->id, &rocker->hw.id, psid->id_len);
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_PORT_PARENT_ID:
+		attr->ppid.id_len = sizeof(rocker->hw.id);
+		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
 	return 0;
 }
 
@@ -4266,7 +4273,7 @@ static int rocker_port_switchdev_fib_ipv4_del(struct net_device *dev,
 }
 
 static const struct switchdev_ops rocker_port_switchdev_ops = {
-	.switchdev_parent_id_get	= rocker_port_switchdev_parent_id_get,
+	.switchdev_port_attr_get	= rocker_port_attr_get,
 	.switchdev_port_stp_update	= rocker_port_switchdev_port_stp_update,
 	.switchdev_fib_ipv4_add		= rocker_port_switchdev_fib_ipv4_add,
 	.switchdev_fib_ipv4_del		= rocker_port_switchdev_fib_ipv4_del,
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 2820438..93316e7 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -25,12 +25,16 @@ enum switchdev_trans {
 
 enum switchdev_attr_id {
 	SWITCHDEV_ATTR_UNDEFINED,
+	SWITCHDEV_ATTR_PORT_PARENT_ID,
 };
 
 struct switchdev_attr {
 	enum switchdev_attr_id id;
 	enum switchdev_trans trans;
 	u32 flags;
+	union {
+		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
+	};
 };
 
 struct fib_info;
@@ -38,10 +42,6 @@ struct fib_info;
 /**
  * struct switchdev_ops - switchdev operations
  *
- * @switchdev_parent_id_get: Called to get an ID of the switch chip this port
- *   is part of.  If driver implements this, it indicates that it
- *   represents a port of a switch chip.
- *
  * @switchdev_port_attr_get: Get a port attribute (see switchdev_attr).
  *
  * @switchdev_port_attr_set: Set a port attribute (see switchdev_attr).
@@ -54,8 +54,6 @@ struct fib_info;
  * @switchdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
  */
 struct switchdev_ops {
-	int	(*switchdev_parent_id_get)(struct net_device *dev,
-					   struct netdev_phys_item_id *psid);
 	int	(*switchdev_port_attr_get)(struct net_device *dev,
 					   struct switchdev_attr *attr);
 	int	(*switchdev_port_attr_set)(struct net_device *dev,
@@ -93,8 +91,6 @@ switchdev_notifier_info_to_dev(const struct switchdev_notifier_info *info)
 
 #ifdef CONFIG_NET_SWITCHDEV
 
-int switchdev_parent_id_get(struct net_device *dev,
-			    struct netdev_phys_item_id *psid);
 int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
@@ -120,12 +116,6 @@ void switchdev_fib_ipv4_abort(struct fib_info *fi);
 
 #else
 
-static inline int switchdev_parent_id_get(struct net_device *dev,
-					  struct netdev_phys_item_id *psid)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int switchdev_port_attr_get(struct net_device *dev,
 					  struct switchdev_attr *attr)
 {
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index be86a7c..5a9ce96 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -458,11 +458,15 @@ static ssize_t phys_switch_id_show(struct device *dev,
 		return restart_syscall();
 
 	if (dev_isalive(netdev)) {
-		struct netdev_phys_item_id ppid;
+		struct switchdev_attr attr = {
+			.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+			.flags = SWITCHDEV_F_NO_RECURSE,
+		};
 
-		ret = switchdev_parent_id_get(netdev, &ppid);
+		ret = switchdev_port_attr_get(netdev, &attr);
 		if (!ret)
-			ret = sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
+			ret = sprintf(buf, "%*phN\n", attr.ppid.id_len,
+				      attr.ppid.id);
 	}
 	rtnl_unlock();
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 81f074b..96ee907 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1004,16 +1004,19 @@ static int rtnl_phys_port_name_fill(struct sk_buff *skb, struct net_device *dev)
 static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
-	struct netdev_phys_item_id psid;
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+		.flags = SWITCHDEV_F_NO_RECURSE,
+	};
 
-	err = switchdev_parent_id_get(dev, &psid);
+	err = switchdev_port_attr_get(dev, &attr);
 	if (err) {
 		if (err == -EOPNOTSUPP)
 			return 0;
 		return err;
 	}
 
-	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, psid.id_len, psid.id))
+	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, attr.ppid.id_len, attr.ppid.id))
 		return -EMSGSIZE;
 
 	return 0;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index aee5877..b465d7c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -382,14 +382,20 @@ static int dsa_slave_bridge_port_leave(struct net_device *dev)
 	return ret;
 }
 
-static int dsa_slave_parent_id_get(struct net_device *dev,
-				   struct netdev_phys_item_id *psid)
+static int dsa_slave_port_attr_get(struct net_device *dev,
+				   struct switchdev_attr *attr)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	psid->id_len = sizeof(ds->index);
-	memcpy(&psid->id, &ds->index, psid->id_len);
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_PORT_PARENT_ID:
+		attr->ppid.id_len = sizeof(ds->index);
+		memcpy(&attr->ppid.id, &ds->index, attr->ppid.id_len);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
 
 	return 0;
 }
@@ -676,7 +682,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
-	.switchdev_parent_id_get	= dsa_slave_parent_id_get,
+	.switchdev_port_attr_get	= dsa_slave_port_attr_get,
 	.switchdev_port_stp_update	= dsa_slave_stp_update,
 };
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8f47187..117fd07 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -19,24 +19,6 @@
 #include <net/switchdev.h>
 
 /**
- *	switchdev_parent_id_get - Get ID of a switch
- *	@dev: port device
- *	@psid: switch ID
- *
- *	Get ID of a switch this port is part of.
- */
-int switchdev_parent_id_get(struct net_device *dev,
-			    struct netdev_phys_item_id *psid)
-{
-	const struct switchdev_ops *ops = dev->switchdev_ops;
-
-	if (!ops || !ops->switchdev_parent_id_get)
-		return -EOPNOTSUPP;
-	return ops->switchdev_parent_id_get(dev, psid);
-}
-EXPORT_SYMBOL_GPL(switchdev_parent_id_get);
-
-/**
  *	switchdev_port_attr_get - Get port attribute
  *
  *	@dev: port device
@@ -414,11 +396,10 @@ static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 	struct list_head *iter;
 
 	/* Recusively search down until we find a sw port dev.
-	 * (A sw port dev supports switchdev_parent_id_get).
+	 * (A sw port dev supports switchdev_port_attr_get).
 	 */
 
-	if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD &&
-	    ops && ops->switchdev_parent_id_get)
+	if (ops && ops->switchdev_port_attr_get)
 		return dev;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
@@ -432,8 +413,10 @@ static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 
 static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 {
-	struct netdev_phys_item_id psid;
-	struct netdev_phys_item_id prev_psid;
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+	};
+	struct switchdev_attr prev_attr;
 	struct net_device *dev = NULL;
 	int nhsel;
 
@@ -449,17 +432,18 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 		if (!dev)
 			return NULL;
 
-		if (switchdev_parent_id_get(dev, &psid))
+		if (switchdev_port_attr_get(dev, &attr))
 			return NULL;
 
 		if (nhsel > 0) {
-			if (prev_psid.id_len != psid.id_len)
+			if (prev_attr.ppid.id_len != attr.ppid.id_len)
 				return NULL;
-			if (memcmp(prev_psid.id, psid.id, psid.id_len))
+			if (memcmp(prev_attr.ppid.id, attr.ppid.id,
+				   attr.ppid.id_len))
 				return NULL;
 		}
 
-		prev_psid = psid;
+		prev_attr = attr;
 	}
 
 	return dev;
-- 
1.7.10.4
