From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 2/9] net/switchdev: Introduce hardware offload support
Date: Mon,  1 Feb 2016 08:34:38 +0000
Message-ID: <1454315685-32202-3-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32872 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752170AbcBAIg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:36:29 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the switchdev API with new operations: switchdev_port_flow_add()
and switchdev_port_flow_del().
It allows the user to add/del a hardware offloaded flow classification
and actions.
For every new flow object a cookie is supplied. This cookie will be
used later on to identify the flow when removed.

In order to make the API as flexible as possible, flow_dissector is
being used to describe the flow classifier.

Every new flow object is consists of a flow_dissector+key+mask to
describe the classifier and a switchdev_obj_port_flow_act to describe
the actions and their attributes.

object is passed to the lower layer driver to be pushed into the
hardware.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/net/switchdev.h   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 net/switchdev/switchdev.c | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d451122..c5a5681 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -15,6 +15,7 @@
 #include <linux/notifier.h>
 #include <linux/list.h>
 #include <net/ip_fib.h>
+#include <net/flow_dissector.h>
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 #define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)
@@ -69,6 +70,7 @@ enum switchdev_obj_id {
 	SWITCHDEV_OBJ_ID_IPV4_FIB,
 	SWITCHDEV_OBJ_ID_PORT_FDB,
 	SWITCHDEV_OBJ_ID_PORT_MDB,
+	SWITCHDEV_OBJ_ID_PORT_FLOW,
 };
 
 struct switchdev_obj {
@@ -124,6 +126,30 @@ struct switchdev_obj_port_mdb {
 #define SWITCHDEV_OBJ_PORT_MDB(obj) \
 	container_of(obj, struct switchdev_obj_port_mdb, obj)
 
+/* SWITCHDEV_OBJ_ID_PORT_FLOW */
+enum switchdev_obj_port_flow_action {
+	SWITCHDEV_OBJ_PORT_FLOW_ACT_DROP = 0,
+	SWITCHDEV_OBJ_PORT_FLOW_ACT_MARK = 1,
+};
+
+struct switchdev_obj_port_flow_act {
+	u32 actions; /* Bitmap of requested actions */
+	u32 mark; /* Value for mark action - if requested */
+};
+
+struct switchdev_obj_port_flow {
+	struct switchdev_obj obj;
+
+	unsigned long cookie;
+	struct flow_dissector *dissector; /* Dissector for mask and keys */
+	void *mask; /* Flow keys mask */
+	void *key;  /* Flow keys */
+	struct switchdev_obj_port_flow_act *actions;
+};
+
+#define SWITCHDEV_OBJ_PORT_FLOW(obj) \
+	container_of(obj, struct switchdev_obj_port_flow, obj)
+
 void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
 				  void *data, void (*destructor)(void const *),
 				  struct switchdev_trans_item *tritem);
@@ -223,6 +249,12 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
 
+int switchdev_port_flow_add(struct net_device *dev,
+			    struct flow_dissector *dissector,
+			    void *mask, void *key,
+			    struct switchdev_obj_port_flow_act *actions,
+			    unsigned long cookie);
+int switchdev_port_flow_del(struct net_device *dev, unsigned long cookie);
 #else
 
 static inline void switchdev_deferred_process(void)
@@ -347,6 +379,20 @@ static inline void switchdev_port_fwd_mark_set(struct net_device *dev,
 {
 }
 
+static inline int switchdev_port_flow_add(struct net_device *dev,
+					  struct flow_dissector *dissector,
+					  void *mask, void *key,
+					  struct switchdev_obj_port_flow_act *actions,
+					  unsigned long cookie)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int switchdev_port_flow_del(struct net_device *dev,
+					  unsigned long cookie)
+{
+	return -EOPNOTSUPP;
+}
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index ebc661d..67b4678 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1383,3 +1383,36 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 	dev->offload_fwd_mark = mark;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fwd_mark_set);
+
+/* Must not be deferred, since deffering does shallow copy, which will not
+ * copy mask and key content
+ */
+int switchdev_port_flow_add(struct net_device *dev,
+			    struct flow_dissector *dissector,
+			    void *mask, void *key,
+			    struct switchdev_obj_port_flow_act *actions,
+			    unsigned long cookie)
+{
+	struct switchdev_obj_port_flow flow = {
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_FLOW,
+		.cookie = cookie,
+		.dissector = dissector,
+		.mask = mask,
+		.key = key,
+		.actions = actions,
+	};
+
+	return switchdev_port_obj_add(dev, &flow.obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_flow_add);
+
+int switchdev_port_flow_del(struct net_device *dev, unsigned long cookie)
+{
+	struct switchdev_obj_port_flow flow = {
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_FLOW,
+		.cookie = cookie,
+	};
+
+	return switchdev_port_obj_del(dev, &flow.obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_flow_del);
-- 
2.7.0
