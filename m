From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 03/12] switchdev: Add support for getting port object details
Date: Wed, 28 Sep 2016 14:42:53 +0200
Message-ID: <1475066582-1971-4-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36170 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932124AbcI1MnN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:13 -0400
Received: by mail-wm0-f45.google.com with SMTP id w84so233850765wmg.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:13 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The motivation for this prototype is to allow the statistics - number of
hits - of Open vSwitch (-line) flows which have been programmed into
hardware to be retrieved.

This patch takes a generic approach by adding a SDO to allow retrieval of
object details.  The idea is that an object is passed in with sufficient
detail to allow it to be looked up and the driver may then fill in other
details of the object.

A follow up patch will prototype using this new SDO to retrieve statistics
for Open vSwitch (-like) flows that have been programmed into hardware.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/switchdev.h   | 39 ++++++++++++++++++++++++++--
 net/switchdev/switchdev.c | 65 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 100 insertions(+), 4 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8eda96e46f98..92a9357e4fab 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -74,6 +74,12 @@ enum switchdev_obj_id {
 	SWITCHDEV_OBJ_SW_FLOW,
 };
 
+struct switchdev_obj_stats {
+	unsigned long rx_packets;
+	unsigned long rx_bytes;
+	unsigned long last_used;
+};
+
 struct switchdev_obj {
 	struct net_device *orig_dev;
 	enum switchdev_obj_id id;
@@ -135,8 +141,13 @@ struct switchdev_obj_sw_flow {
 	const struct sw_flow_key *key;
 	const struct sw_flow_key *mask;
 	u64 attrs;
-	const struct nlattr *actions;
-	u32 actions_len;
+	union {
+		struct {
+			const struct nlattr *actions;
+			u32 len;
+		} actions;
+		struct switchdev_obj_stats *stats;
+	};
 };
 
 #define SWITCHDEV_OBJ_SW_FLOW(obj) \
@@ -161,6 +172,8 @@ typedef int switchdev_obj_dump_cb_t(struct switchdev_obj *obj);
  * @switchdev_port_obj_del: Delete an object from port (see switchdev_obj_*).
  *
  * @switchdev_port_obj_dump: Dump port objects (see switchdev_obj_*).
+ *
+ * @switchdev_port_obj_get: Get an object from port (see switchdev_obj_*).
  */
 struct switchdev_ops {
 	int	(*switchdev_port_attr_get)(struct net_device *dev,
@@ -176,6 +189,8 @@ struct switchdev_ops {
 	int	(*switchdev_port_obj_dump)(struct net_device *dev,
 					   struct switchdev_obj *obj,
 					   switchdev_obj_dump_cb_t *cb);
+	int	(*switchdev_port_obj_get)(struct net_device *dev,
+					  struct switchdev_obj *obj);
 };
 
 enum switchdev_notifier_type {
@@ -212,6 +227,7 @@ int switchdev_port_obj_del(struct net_device *dev,
 			   const struct switchdev_obj *obj);
 int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 			    switchdev_obj_dump_cb_t *cb);
+int switchdev_port_obj_get(struct net_device *dev, struct switchdev_obj *obj);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
@@ -244,6 +260,10 @@ int switchdev_sw_flow_add(struct net_device *dev,
 int switchdev_sw_flow_del(struct net_device *dev,
 			  const struct sw_flow_key *key,
 			  const struct sw_flow_key *mask, u64 attrs);
+int switchdev_sw_flow_get_stats(struct net_device *dev,
+				const struct sw_flow_key *key,
+				const struct sw_flow_key *mask, u64 attrs,
+				struct switchdev_obj_stats *stats);
 void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
@@ -287,6 +307,12 @@ static inline int switchdev_port_obj_dump(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int switchdev_port_obj_get(struct net_device *dev,
+					 struct switchdev_obj *obj)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
@@ -386,6 +412,15 @@ static inline int switchdev_sw_flow_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int switchdev_ovs_flow_get_stats(struct net_device *dev,
+					       const struct sw_flow_key *key,
+					       const struct sw_flow_key *mask,
+					       u64 attrs,
+					       struct switchdev_obj_stats *stats)
+{
+	return 0;
+}
+
 static inline bool switchdev_port_same_parent_id(struct net_device *a,
 						 struct net_device *b)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index db96c3345129..f89e6dc90eb6 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -574,6 +574,36 @@ int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_obj_dump);
 
+/**
+ *	switchdev_port_obj_get - Get port object
+ *
+ *	@dev: port device
+ *	@obj: object to get
+ */
+int switchdev_port_obj_get(struct net_device *dev, struct switchdev_obj *obj)
+{
+	const struct switchdev_ops *ops = dev->switchdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->switchdev_port_obj_get)
+		return ops->switchdev_port_obj_get(dev, obj);
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to get objects on
+	 * first port at bottom of stack.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = switchdev_port_obj_get(lower_dev, obj);
+		break;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_obj_get);
+
 static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
 
 /**
@@ -1310,8 +1340,10 @@ int switchdev_sw_flow_add(struct net_device *dev,
 		.key = key,
 		.mask = mask,
 		.attrs = attrs,
-		.actions = actions,
-		.actions_len = actions_len,
+		.actions = {
+			.actions = actions,
+			.len = actions_len,
+		},
 	};
 
 	return switchdev_port_obj_add(dev, &sw_flow.obj);
@@ -1344,6 +1376,35 @@ int switchdev_sw_flow_del(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(switchdev_sw_flow_del);
 
+/**
+ *	switchdev_sw_flow_get_stats - Get statistics of a flow from switch
+ *
+ *	@dev: port device
+ *      @key: flow key
+ *      @mask: flow mask
+ *      @attrs: attributes present in key
+ *	@stats: statistics to fill in
+ *
+ *	Get statistics of a flow from a device where the flow is expressed as
+ *	an Open vSwitch flow key, mask and attributes.
+ */
+int switchdev_sw_flow_get_stats(struct net_device *dev,
+				 const struct sw_flow_key *key,
+				 const struct sw_flow_key *mask, u64 attrs,
+				 struct switchdev_obj_stats *stats)
+{
+	struct switchdev_obj_sw_flow sw_flow = {
+		.obj.id = SWITCHDEV_OBJ_SW_FLOW,
+		.key = key,
+		.mask = mask,
+		.attrs = attrs,
+		.stats = stats,
+	};
+
+	return switchdev_port_obj_get(dev, &sw_flow.obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_sw_flow_get_stats);
+
 bool switchdev_port_same_parent_id(struct net_device *a,
 				   struct net_device *b)
 {
-- 
2.7.0.rc3.207.g0ac5344
