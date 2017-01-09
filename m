From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: switchdev: Add object dump deferred operation
Date: Mon,  9 Jan 2017 11:45:01 -0800
Message-ID: <20170109194503.10713-3-f.fainelli@gmail.com>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@resnulli.us,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34297 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763765AbdAITpO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:45:14 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so4012761pfb.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 11:45:13 -0800 (PST)
In-Reply-To: <20170109194503.10713-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add plumbing required to perform dump operations in a deferred context,
this mostly wraps the existing switchdev_obj_port_dump() function into a
switchdev_obj_port_dump_now() and adds two wrappers (normal and
deferred) around.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/switchdev/switchdev.c | 71 +++++++++++++++++++++++++++++++++++++----------
 1 file changed, 57 insertions(+), 14 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 3d70ad02c617..4fa9972d72d2 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -545,26 +545,15 @@ int switchdev_port_obj_del(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
 
-/**
- *	switchdev_port_obj_dump - Dump port objects
- *
- *	@dev: port device
- *	@id: object ID
- *	@obj: object to dump
- *	@cb: function to call with a filled object
- *
- *	rtnl_lock must be held.
- */
-int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
-			    switchdev_obj_dump_cb_t *cb)
+static int switchdev_port_obj_dump_now(struct net_device *dev,
+				       struct switchdev_obj *obj,
+				       switchdev_obj_dump_cb_t *cb)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
 	struct list_head *iter;
 	int err = -EOPNOTSUPP;
 
-	ASSERT_RTNL();
-
 	if (ops && ops->switchdev_port_obj_dump)
 		return ops->switchdev_port_obj_dump(dev, obj, cb);
 
@@ -580,6 +569,60 @@ int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 
 	return err;
 }
+
+struct switchdev_obj_dump_deferred_item {
+	struct switchdev_obj obj;
+	switchdev_obj_dump_cb_t *cb;
+};
+
+static void switchdev_port_obj_dump_deferred(struct net_device *dev,
+					     void *data)
+{
+	struct switchdev_obj_dump_deferred_item *i = data;
+	struct switchdev_obj *obj = &i->obj;
+	int err;
+
+	err = switchdev_port_obj_dump_now(dev, obj, i->cb);
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(dev, "failed (err=%d) to dump object (id=%d)\n",
+			   err, obj->id);
+	if (obj->complete)
+		obj->complete(dev, err, obj->complete_priv);
+}
+
+static int switchdev_port_obj_dump_defer(struct net_device *dev,
+					 struct switchdev_obj *obj,
+					 switchdev_obj_dump_cb_t *cb)
+{
+	struct switchdev_obj_dump_deferred_item item;
+
+	memcpy(&item.obj, obj, switchdev_obj_size(obj));
+	item.cb = cb;
+
+	return switchdev_deferred_enqueue(dev, &item, sizeof(item),
+					  NULL,
+					  switchdev_port_obj_dump_deferred);
+}
+
+/**
+ *	switchdev_port_obj_dump - Dump port objects
+ *
+ *	@dev: port device
+ *	@id: object ID
+ *	@obj: object to dump
+ *	@cb: function to call with a filled object
+ *
+ *	rtnl_lock must be held and must not be in atomic section,
+ *	in case SWITCHDEV_F_DEFER flag is not set.
+ */
+int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
+			    switchdev_obj_dump_cb_t *cb)
+{
+	if (obj->flags & SWITCHDEV_F_DEFER)
+		return switchdev_port_obj_dump_defer(dev, obj, cb);
+	ASSERT_RTNL();
+	return switchdev_port_obj_dump_now(dev, obj, cb);
+}
 EXPORT_SYMBOL_GPL(switchdev_port_obj_dump);
 
 static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
-- 
2.9.3
