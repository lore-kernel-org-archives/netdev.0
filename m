From: sfeldma@gmail.com
Subject: [PATCH net-next v3 03/26] switchdev: convert STP update to swdev attr set
Date: Thu,  2 Apr 2015 01:09:49 -0700
Message-ID: <1427962212-18411-4-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33423 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbbDBIJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:25 -0400
Received: by pdbnk13 with SMTP id nk13so1988603pdb.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:24 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

STP update is just a writable port attribute, so convert swdev_port_stp_update
to an attr set.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   19 ++++++++++++++++---
 include/net/switchdev.h              |   13 ++-----------
 net/bridge/br_stp.c                  |    6 +++++-
 net/dsa/slave.c                      |   22 +++++++++++++++++++++-
 net/switchdev/switchdev.c            |   28 ----------------------------
 5 files changed, 44 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 00f55ab..d2015ba 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4237,11 +4237,24 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
 	return 0;
 }
 
-static int rocker_port_swdev_port_stp_update(struct net_device *dev, u8 state)
+static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	if (attr->flags & SWDEV_F_TRANS_PREPARE)
+		return 0;
+
+	switch (attr->id) {
+	case SWDEV_ATTR_PORT_STP_STATE:
+		err = rocker_port_stp_update(rocker_port, attr->stp_state);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
 
-	return rocker_port_stp_update(rocker_port, state);
+	return err;
 }
 
 static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
@@ -4271,7 +4284,7 @@ static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
 
 static const struct swdev_ops rocker_port_swdev_ops = {
 	.swdev_port_attr_get		= rocker_port_attr_get,
-	.swdev_port_stp_update		= rocker_port_swdev_port_stp_update,
+	.swdev_port_attr_set		= rocker_port_attr_set,
 	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
 	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
 };
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 5fa73db..9fe3b1c 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -21,6 +21,7 @@
 enum swdev_attr_id {
 	SWDEV_ATTR_UNDEFINED,
 	SWDEV_ATTR_PORT_PARENT_ID,
+	SWDEV_ATTR_PORT_STP_STATE,
 };
 
 struct swdev_attr {
@@ -29,6 +30,7 @@ struct swdev_attr {
 	int trans_id;
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
+		u8 stp_state;				/* PORT_STP_STATE */
 	};
 };
 
@@ -41,9 +43,6 @@ struct fib_info;
  *
  * @swdev_port_attr_set: Set a port attribute (see swdev_attr).
  *
- * @swdev_port_stp_update: Called to notify switch device port of bridge
- *   port STP state change.
- *
  * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
  * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
@@ -53,7 +52,6 @@ struct swdev_ops {
 				       struct swdev_attr *attr);
 	int	(*swdev_port_attr_set)(struct net_device *dev,
 				       struct swdev_attr *attr);
-	int	(*swdev_port_stp_update)(struct net_device *dev, u8 state);
 	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 				      int dst_len, struct fib_info *fi,
 				      u8 tos, u8 type, u32 nlflags,
@@ -88,7 +86,6 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
-int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
@@ -121,12 +118,6 @@ static inline int swdev_port_attr_set(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int netdev_switch_port_stp_update(struct net_device *dev,
-						u8 state)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int register_netdev_switch_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index fb3ebe6..f888dbc 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -39,10 +39,14 @@ void br_log_state(const struct net_bridge_port *p)
 
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
+	struct swdev_attr attr = {
+		.id = SWDEV_ATTR_PORT_STP_STATE,
+		.stp_state = state,
+	};
 	int err;
 
 	p->state = state;
-	err = netdev_switch_port_stp_update(p->dev, state);
+	err = swdev_port_attr_set(p->dev, &attr);
 	if (err && err != -EOPNOTSUPP)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e994cba..812cb1c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -347,6 +347,26 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 	return ret;
 }
 
+static int dsa_slave_port_attr_set(struct net_device *dev,
+				   struct swdev_attr *attr)
+{
+	int ret = 0;
+
+	if (attr->flags & SWDEV_F_TRANS_PREPARE)
+		return 0;
+
+	switch (attr->id) {
+	case SWDEV_ATTR_PORT_STP_STATE:
+		ret = dsa_slave_stp_update(dev, attr->stp_state);
+		break;
+	default:
+		ret = -EOPNOTSUPP;
+		break;
+	}
+
+	return ret;
+}
+
 static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
@@ -685,7 +705,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 
 static const struct swdev_ops dsa_slave_swdev_ops = {
 	.swdev_port_attr_get = dsa_slave_port_attr_get,
-	.swdev_port_stp_update = dsa_slave_stp_update,
+	.swdev_port_attr_set = dsa_slave_port_attr_set,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index f0fc2f6..1a9ae1e 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -140,34 +140,6 @@ int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(swdev_port_attr_set);
 
-/**
- *	netdev_switch_port_stp_update - Notify switch device port of STP
- *					state change
- *	@dev: port device
- *	@state: port STP state
- *
- *	Notify switch device port of bridge port STP state change.
- */
-int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
-{
-	const struct swdev_ops *ops = dev->swdev_ops;
-	struct net_device *lower_dev;
-	struct list_head *iter;
-	int err = -EOPNOTSUPP;
-
-	if (ops && ops->swdev_port_stp_update)
-		return ops->swdev_port_stp_update(dev, state);
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = netdev_switch_port_stp_update(lower_dev, state);
-		if (err && err != -EOPNOTSUPP)
-			return err;
-	}
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
-
 static DEFINE_MUTEX(netdev_switch_mutex);
 static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
 
-- 
1.7.10.4
