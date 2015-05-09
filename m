From: sfeldma@gmail.com
Subject: [PATCH net-next v6 06/23] switchdev: convert STP update to switchdev attr set
Date: Sat,  9 May 2015 10:40:08 -0700
Message-ID: <1431193225-807-7-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33493 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbbEIRnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:23 -0400
Received: by pacwv17 with SMTP id wv17so75782182pac.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:22 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

STP update is just a settable port attribute, so convert
switchdev_port_stp_update to an attr set.

For DSA, the prepare phase is skipped and STP updates are only done in the
commit phase.  This is because currently the DSA drivers don't need to
allocate any memory for STP updates and the STP update will not fail to HW
(unless something horrible goes wrong on the MDIO bus, in which case the
prepare phase wouldn't have been able to predict anyway).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   13 ++++---------
 include/net/switchdev.h              |   13 ++-----------
 net/bridge/br_stp.c                  |    6 +++++-
 net/dsa/slave.c                      |   20 +++++++++++++++++++-
 net/switchdev/switchdev.c            |   28 ----------------------------
 5 files changed, 30 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index dc471c0..d260837 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4347,14 +4347,6 @@ static int rocker_port_attr_get(struct net_device *dev,
 	return 0;
 }
 
-static int rocker_port_switchdev_port_stp_update(struct net_device *dev,
-						 u8 state)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-
-	return rocker_port_stp_update(rocker_port, state);
-}
-
 static void rocker_port_trans_abort(struct rocker_port *rocker_port)
 {
 	struct list_head *mem, *tmp;
@@ -4385,6 +4377,9 @@ static int rocker_port_attr_set(struct net_device *dev,
 	}
 
 	switch (attr->id) {
+	case SWITCHDEV_ATTR_PORT_STP_STATE:
+		err = rocker_port_stp_update(rocker_port, attr->stp_state);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4422,7 +4417,7 @@ static int rocker_port_switchdev_fib_ipv4_del(struct net_device *dev,
 
 static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_attr_get	= rocker_port_attr_get,
-	.switchdev_port_stp_update	= rocker_port_switchdev_port_stp_update,
+	.switchdev_port_attr_set	= rocker_port_attr_set,
 	.switchdev_fib_ipv4_add		= rocker_port_switchdev_fib_ipv4_add,
 	.switchdev_fib_ipv4_del		= rocker_port_switchdev_fib_ipv4_del,
 };
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 93316e7..aec5e49 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -26,6 +26,7 @@ enum switchdev_trans {
 enum switchdev_attr_id {
 	SWITCHDEV_ATTR_UNDEFINED,
 	SWITCHDEV_ATTR_PORT_PARENT_ID,
+	SWITCHDEV_ATTR_PORT_STP_STATE,
 };
 
 struct switchdev_attr {
@@ -34,6 +35,7 @@ struct switchdev_attr {
 	u32 flags;
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
+		u8 stp_state;				/* PORT_STP_STATE */
 	};
 };
 
@@ -46,9 +48,6 @@ struct fib_info;
  *
  * @switchdev_port_attr_set: Set a port attribute (see switchdev_attr).
  *
- * @switchdev_port_stp_update: Called to notify switch device port of bridge
- *   port STP state change.
- *
  * @switchdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
  * @switchdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
@@ -58,7 +57,6 @@ struct switchdev_ops {
 					   struct switchdev_attr *attr);
 	int	(*switchdev_port_attr_set)(struct net_device *dev,
 					   struct switchdev_attr *attr);
-	int	(*switchdev_port_stp_update)(struct net_device *dev, u8 state);
 	int	(*switchdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 					  int dst_len, struct fib_info *fi,
 					  u8 tos, u8 type, u32 nlflags,
@@ -95,7 +93,6 @@ int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
-int switchdev_port_stp_update(struct net_device *dev, u8 state);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
@@ -128,12 +125,6 @@ static inline int switchdev_port_attr_set(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int switchdev_port_stp_update(struct net_device *dev,
-					    u8 state)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 28e3f4b..b9300da 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -39,10 +39,14 @@ void br_log_state(const struct net_bridge_port *p)
 
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_PORT_STP_STATE,
+		.stp_state = state,
+	};
 	int err;
 
 	p->state = state;
-	err = switchdev_port_stp_update(p->dev, state);
+	err = switchdev_port_attr_set(p->dev, &attr);
 	if (err && err != -EOPNOTSUPP)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b465d7c..1546d9e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -345,6 +345,24 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 	return ret;
 }
 
+static int dsa_slave_port_attr_set(struct net_device *dev,
+				   struct switchdev_attr *attr)
+{
+	int ret = 0;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_PORT_STP_STATE:
+		if (attr->trans == SWITCHDEV_TRANS_COMMIT)
+			ret = dsa_slave_stp_update(dev, attr->stp_state);
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
@@ -683,7 +701,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_attr_get	= dsa_slave_port_attr_get,
-	.switchdev_port_stp_update	= dsa_slave_stp_update,
+	.switchdev_port_attr_set	= dsa_slave_port_attr_set,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 117fd07..a3c3590 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -187,34 +187,6 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
-/**
- *	switchdev_port_stp_update - Notify switch device port of STP
- *					state change
- *	@dev: port device
- *	@state: port STP state
- *
- *	Notify switch device port of bridge port STP state change.
- */
-int switchdev_port_stp_update(struct net_device *dev, u8 state)
-{
-	const struct switchdev_ops *ops = dev->switchdev_ops;
-	struct net_device *lower_dev;
-	struct list_head *iter;
-	int err = -EOPNOTSUPP;
-
-	if (ops && ops->switchdev_port_stp_update)
-		return ops->switchdev_port_stp_update(dev, state);
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_stp_update(lower_dev, state);
-		if (err && err != -EOPNOTSUPP)
-			return err;
-	}
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(switchdev_port_stp_update);
-
 static DEFINE_MUTEX(switchdev_mutex);
 static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
 
-- 
1.7.10.4
