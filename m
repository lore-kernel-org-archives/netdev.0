From: sfeldma@gmail.com
Subject: [PATCH net-next v4 02/24] switchdev: convert parent_id_get to swdev attr get
Date: Sun, 12 Apr 2015 23:16:56 -0700
Message-ID: <1428905838-14920-3-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:32799 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbbDMGQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:34 -0400
Received: by pdbnk13 with SMTP id nk13so96488818pdb.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:34 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Switch ID is just a gettable port attribute.  Convert swdev op
swdev_parent_id_get to a swdev attr.

Note: for sysfs and netlink interfaces, SWDEV_ATTR_PORT_PARENT_ID is called
with SWDEV_F_NO_RECUSE to limit switch ID user-visiblity to only port
netdevs.  So port is stacked under bond/bridge, the user can only see switch
ID for port.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   16 +++++++++-----
 include/net/switchdev.h              |   18 ++++------------
 net/core/net-sysfs.c                 |   10 ++++++---
 net/core/rtnetlink.c                 |    9 +++++---
 net/dsa/slave.c                      |   16 +++++++++-----
 net/switchdev/switchdev.c            |   38 ++++++++++------------------------
 6 files changed, 50 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a87b177..1c468df 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4220,14 +4220,20 @@ static const struct net_device_ops rocker_port_netdev_ops = {
  * swdev interface
  ********************/
 
-static int rocker_port_swdev_parent_id_get(struct net_device *dev,
-					   struct netdev_phys_item_id *psid)
+static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct rocker *rocker = rocker_port->rocker;
 
-	psid->id_len = sizeof(rocker->hw.id);
-	memcpy(&psid->id, &rocker->hw.id, psid->id_len);
+	switch (attr->id) {
+	case SWDEV_ATTR_PORT_PARENT_ID:
+		attr->ppid.id_len = sizeof(rocker->hw.id);
+		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
 	return 0;
 }
 
@@ -4264,7 +4270,7 @@ static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
 }
 
 static const struct swdev_ops rocker_port_swdev_ops = {
-	.swdev_parent_id_get		= rocker_port_swdev_parent_id_get,
+	.swdev_port_attr_get		= rocker_port_attr_get,
 	.swdev_port_stp_update		= rocker_port_swdev_port_stp_update,
 	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
 	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1d45621..dcacd54 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -25,12 +25,16 @@ enum swdev_trans {
 
 enum swdev_attr_id {
 	SWDEV_ATTR_UNDEFINED,
+	SWDEV_ATTR_PORT_PARENT_ID,
 };
 
 struct swdev_attr {
 	enum swdev_attr_id id;
 	enum swdev_trans trans;
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
- * @swdev_parent_id_get: Called to get an ID of the switch chip this port
- *   is part of.  If driver implements this, it indicates that it
- *   represents a port of a switch chip.
- *
  * @swdev_port_attr_get: Get a port attribute (see swdev_attr).
  *
  * @swdev_port_attr_set: Set a port attribute (see swdev_attr).
@@ -54,8 +54,6 @@ struct fib_info;
  * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
  */
 struct swdev_ops {
-	int	(*swdev_parent_id_get)(struct net_device *dev,
-				       struct netdev_phys_item_id *psid);
 	int	(*swdev_port_attr_get)(struct net_device *dev,
 				       struct swdev_attr *attr);
 	int	(*swdev_port_attr_set)(struct net_device *dev,
@@ -93,8 +91,6 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 #ifdef CONFIG_NET_SWITCHDEV
 
-int netdev_switch_parent_id_get(struct net_device *dev,
-				struct netdev_phys_item_id *psid);
 int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
@@ -118,12 +114,6 @@ void netdev_switch_fib_ipv4_abort(struct fib_info *fi);
 
 #else
 
-static inline int netdev_switch_parent_id_get(struct net_device *dev,
-					      struct netdev_phys_item_id *psid)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int swdev_port_attr_get(struct net_device *dev,
 				      enum swdev_attr *attr)
 {
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 4238d6d..5e83d50 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -458,11 +458,15 @@ static ssize_t phys_switch_id_show(struct device *dev,
 		return restart_syscall();
 
 	if (dev_isalive(netdev)) {
-		struct netdev_phys_item_id ppid;
+		struct swdev_attr attr = {
+			.id = SWDEV_ATTR_PORT_PARENT_ID,
+			.flags = SWDEV_F_NO_RECURSE,
+		};
 
-		ret = netdev_switch_parent_id_get(netdev, &ppid);
+		ret = swdev_port_attr_get(netdev, &attr);
 		if (!ret)
-			ret = sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
+			ret = sprintf(buf, "%*phN\n", attr.ppid.id_len,
+				      attr.ppid.id);
 	}
 	rtnl_unlock();
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 358d52a..756f1cf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1004,16 +1004,19 @@ static int rtnl_phys_port_name_fill(struct sk_buff *skb, struct net_device *dev)
 static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
-	struct netdev_phys_item_id psid;
+	struct swdev_attr attr = {
+		.id = SWDEV_ATTR_PORT_PARENT_ID,
+		.flags = SWDEV_F_NO_RECURSE,
+	};
 
-	err = netdev_switch_parent_id_get(dev, &psid);
+	err = swdev_port_attr_get(dev, &attr);
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
index 827cda56..6ff2261 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -382,14 +382,20 @@ static int dsa_slave_bridge_port_leave(struct net_device *dev)
 	return ret;
 }
 
-static int dsa_slave_parent_id_get(struct net_device *dev,
-				   struct netdev_phys_item_id *psid)
+static int dsa_slave_port_attr_get(struct net_device *dev,
+				   struct swdev_attr *attr)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	psid->id_len = sizeof(ds->index);
-	memcpy(&psid->id, &ds->index, psid->id_len);
+	switch (attr->id) {
+	case SWDEV_ATTR_PORT_PARENT_ID:
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
 
 static const struct swdev_ops dsa_slave_swdev_ops = {
-	.swdev_parent_id_get = dsa_slave_parent_id_get,
+	.swdev_port_attr_get = dsa_slave_port_attr_get,
 	.swdev_port_stp_update = dsa_slave_stp_update,
 };
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index db0cc7b..7d94724 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -19,24 +19,6 @@
 #include <net/switchdev.h>
 
 /**
- *	netdev_switch_parent_id_get - Get ID of a switch
- *	@dev: port device
- *	@psid: switch ID
- *
- *	Get ID of a switch this port is part of.
- */
-int netdev_switch_parent_id_get(struct net_device *dev,
-				struct netdev_phys_item_id *psid)
-{
-	const struct swdev_ops *ops = dev->swdev_ops;
-
-	if (!ops || !ops->swdev_parent_id_get)
-		return -EOPNOTSUPP;
-	return ops->swdev_parent_id_get(dev, psid);
-}
-EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
-
-/**
  *	swdev_port_attr_get - Get port attribute
  *
  *	@dev: port device
@@ -421,11 +403,10 @@ static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 	struct list_head *iter;
 
 	/* Recusively search down until we find a sw port dev.
-	 * (A sw port dev supports swdev_parent_id_get).
+	 * (A sw port dev supports swdev_port_attr_get).
 	 */
 
-	if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD &&
-	    ops && ops->swdev_parent_id_get)
+	if (ops && ops->swdev_port_attr_get)
 		return dev;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
@@ -439,8 +420,10 @@ static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 
 static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
 {
-	struct netdev_phys_item_id psid;
-	struct netdev_phys_item_id prev_psid;
+	struct swdev_attr attr = {
+		.id = SWDEV_ATTR_PORT_PARENT_ID,
+	};
+	struct swdev_attr prev_attr;
 	struct net_device *dev = NULL;
 	int nhsel;
 
@@ -456,17 +439,18 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
 		if (!dev)
 			return NULL;
 
-		if (netdev_switch_parent_id_get(dev, &psid))
+		if (swdev_port_attr_get(dev, &attr))
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
