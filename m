From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 02/12] switchdev: Add Open vSwitch (-like) flow object support
Date: Wed, 28 Sep 2016 14:42:52 +0200
Message-ID: <1475066582-1971-3-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36136 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcI1MnM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:12 -0400
Received: by mail-wm0-f44.google.com with SMTP id w84so233849236wmg.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:11 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The motivation of this patch is to provide objects for Open vSwitch (-like)
flows so that they may be programmed into hardware using switchdev.

The structures used here may well prove to be too Open vSwitch centric, but
the purpose of the prototype of which this patch is part is to explore if
switchdev is an appropriate mechanism for programming Open vSwitch (-like)
flows into hardware. The data structures can be tweaked/reworked as needed.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/switchdev.h   | 39 +++++++++++++++++++++++++++++++
 net/switchdev/switchdev.c | 58 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 97 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 729fe1534160..8eda96e46f98 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -71,6 +71,7 @@ enum switchdev_obj_id {
 	SWITCHDEV_OBJ_ID_IPV4_FIB,
 	SWITCHDEV_OBJ_ID_PORT_FDB,
 	SWITCHDEV_OBJ_ID_PORT_MDB,
+	SWITCHDEV_OBJ_SW_FLOW,
 };
 
 struct switchdev_obj {
@@ -128,6 +129,19 @@ struct switchdev_obj_port_mdb {
 #define SWITCHDEV_OBJ_PORT_MDB(obj) \
 	container_of(obj, struct switchdev_obj_port_mdb, obj)
 
+/* SWITCHDEV_OBJ_ID_PORT_SW_FLOW */
+struct switchdev_obj_sw_flow {
+	struct switchdev_obj obj;
+	const struct sw_flow_key *key;
+	const struct sw_flow_key *mask;
+	u64 attrs;
+	const struct nlattr *actions;
+	u32 actions_len;
+};
+
+#define SWITCHDEV_OBJ_SW_FLOW(obj) \
+	container_of(obj, struct switchdev_obj_sw_flow, obj)
+
 void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
 				  void *data, void (*destructor)(void const *),
 				  struct switchdev_trans_item *tritem);
@@ -223,6 +237,13 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev,
 			    struct net_device *filter_dev, int *idx);
+int switchdev_sw_flow_add(struct net_device *dev,
+			  const struct sw_flow_key *key,
+			  const struct sw_flow_key *mask, u64 attrs,
+			  const struct nlattr *actions, u32 actions_len);
+int switchdev_sw_flow_del(struct net_device *dev,
+			  const struct sw_flow_key *key,
+			  const struct sw_flow_key *mask, u64 attrs);
 void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
@@ -347,6 +368,24 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
        return *idx;
 }
 
+static inline int switchdev_sw_flow_add(struct net_device *dev,
+					const struct sw_flow_key *key,
+					const struct sw_flow_key *mask,
+					u64 attrs,
+					const struct nlattr *actions,
+					u32 actions_len)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int switchdev_sw_flow_del(struct net_device *dev,
+					const struct sw_flow_key *key,
+					const struct sw_flow_key *mask,
+					u64 attrs)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline bool switchdev_port_same_parent_id(struct net_device *a,
 						 struct net_device *b)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 10b819308439..db96c3345129 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1286,6 +1286,64 @@ void switchdev_fib_ipv4_abort(struct fib_info *fi)
 }
 EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_abort);
 
+/**
+ *	switchdev_sw_flow_add - Program a flow into a switch port
+ *
+ *	@dev: port device
+ *      @key: flow key
+ *      @mask: flow mask
+ *      @attrs: attributes present in key
+ *	@actions: actions of the flow
+ *	@actions_len: length of @actions
+ *
+ *	Program a flow into a port device where the flow is expressed as
+ *	an Open vSwitch flow key, mask, attributes, and actions
+ */
+int switchdev_sw_flow_add(struct net_device *dev,
+			  const struct sw_flow_key *key,
+			  const struct sw_flow_key *mask,
+			  u64 attrs, const struct nlattr *actions,
+			  u32 actions_len)
+{
+	struct switchdev_obj_sw_flow sw_flow = {
+		.obj.id = SWITCHDEV_OBJ_SW_FLOW,
+		.key = key,
+		.mask = mask,
+		.attrs = attrs,
+		.actions = actions,
+		.actions_len = actions_len,
+	};
+
+	return switchdev_port_obj_add(dev, &sw_flow.obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_sw_flow_add);
+
+/**
+ *	switchdev_sw_flow_del - Delete flow from switch
+ *
+ *	@dev: port device
+ *      @key: flow key
+ *      @mask: flow mask
+ *      @attrs: attributes present in key
+ *
+ *	Delete a flow from a device where the flow is expressed as
+ *	an Open vSwitch flow key, mask and attributes.
+ */
+int switchdev_sw_flow_del(struct net_device *dev,
+			  const struct sw_flow_key *key,
+			  const struct sw_flow_key *mask, u64 attrs)
+{
+	struct switchdev_obj_sw_flow sw_flow = {
+		.obj.id = SWITCHDEV_OBJ_SW_FLOW,
+		.key = key,
+		.mask = mask,
+		.attrs = attrs,
+	};
+
+	return switchdev_port_obj_del(dev, &sw_flow.obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_sw_flow_del);
+
 bool switchdev_port_same_parent_id(struct net_device *a,
 				   struct net_device *b)
 {
-- 
2.7.0.rc3.207.g0ac5344
