From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 5/7] switchdev: introduce possibility to defer obj_add/del
Date: Mon, 12 Oct 2015 17:45:48 +0200
Message-ID: <1444664750-11260-6-git-send-email-jiri@resnulli.us>
References: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38732 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbbJLPp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 11:45:59 -0400
Received: by wieq12 with SMTP id q12so26508890wie.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 08:45:58 -0700 (PDT)
In-Reply-To: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Similar to the attr usecase, the caller knows if he is holding RTNL and is
in atomic section. So let the called to decide the correct call variant.

This allows drivers to sleep inside their ops and wait for hw to get the
operation status. Then the status is propagated into switchdev core.
This avoids silent errors in drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |   1 +
 net/switchdev/switchdev.c | 137 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 110 insertions(+), 28 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 767d516..14e2595 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -69,6 +69,7 @@ enum switchdev_obj_id {
 
 struct switchdev_obj {
 	enum switchdev_obj_id id;
+	u32 flags;
 };
 
 /* SWITCHDEV_OBJ_ID_PORT_VLAN */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 77b616b..abb23b5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -312,21 +312,8 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	return err;
 }
 
-/**
- *	switchdev_port_obj_add - Add port object
- *
- *	@dev: port device
- *	@id: object ID
- *	@obj: object to add
- *
- *	Use a 2-phase prepare-commit transaction model to ensure
- *	system is not left in a partially updated state due to
- *	failure from driver/device.
- *
- *	rtnl_lock must be held.
- */
-int switchdev_port_obj_add(struct net_device *dev,
-			   const struct switchdev_obj *obj)
+static int switchdev_port_obj_add_now(struct net_device *dev,
+				      const struct switchdev_obj *obj)
 {
 	struct switchdev_trans trans;
 	int err;
@@ -368,19 +355,9 @@ int switchdev_port_obj_add(struct net_device *dev,
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
 
-/**
- *	switchdev_port_obj_del - Delete port object
- *
- *	@dev: port device
- *	@id: object ID
- *	@obj: object to delete
- *
- *	rtnl_lock must be held.
- */
-int switchdev_port_obj_del(struct net_device *dev,
-			   const struct switchdev_obj *obj)
+static int switchdev_port_obj_del_now(struct net_device *dev,
+				      const struct switchdev_obj *obj)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
@@ -398,13 +375,117 @@ int switchdev_port_obj_del(struct net_device *dev,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_obj_del(lower_dev, obj);
+		err = switchdev_port_obj_del_now(lower_dev, obj);
 		if (err)
 			break;
 	}
 
 	return err;
 }
+
+struct switchdev_obj_work {
+	struct work_struct work;
+	struct net_device *dev;
+	struct switchdev_obj obj;
+	bool add; /* add or del */
+};
+
+static void switchdev_port_obj_work(struct work_struct *work)
+{
+	struct switchdev_obj_work *ow =
+			container_of(work, struct switchdev_obj_work, work);
+	bool rtnl_locked = rtnl_is_locked();
+	int err;
+
+	if (!rtnl_locked)
+		rtnl_lock();
+	if (ow->add)
+		err = switchdev_port_obj_add_now(ow->dev, &ow->obj);
+	else
+		err = switchdev_port_obj_del_now(ow->dev, &ow->obj);
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(ow->dev, "failed (err=%d) to %s object (id=%d)\n",
+			   err, ow->add ? "add" : "del", ow->obj.id);
+	if (!rtnl_locked)
+		rtnl_unlock();
+
+	dev_put(ow->dev);
+	kfree(ow);
+}
+
+static int switchdev_port_obj_work_schedule(struct net_device *dev,
+					    const struct switchdev_obj *obj,
+					    bool add)
+{
+	struct switchdev_obj_work *ow;
+
+	ow = kmalloc(sizeof(*ow), GFP_ATOMIC);
+	if (!ow)
+		return -ENOMEM;
+
+	INIT_WORK(&ow->work, switchdev_port_obj_work);
+
+	dev_hold(dev);
+	ow->dev = dev;
+	memcpy(&ow->obj, obj, sizeof(ow->obj));
+	ow->add = add;
+
+	queue_work(switchdev_wq, &ow->work);
+	return 0;
+}
+
+static int switchdev_port_obj_add_defer(struct net_device *dev,
+					const struct switchdev_obj *obj)
+{
+	return switchdev_port_obj_work_schedule(dev, obj, true);
+}
+
+/**
+ *	switchdev_port_obj_add - Add port object
+ *
+ *	@dev: port device
+ *	@id: object ID
+ *	@obj: object to add
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ *	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ *
+ *	rtnl_lock must be held and must not be in atomic section,
+ *	in case SWITCHDEV_F_DEFER flag is not set.
+ */
+int switchdev_port_obj_add(struct net_device *dev,
+			   const struct switchdev_obj *obj)
+{
+	if (obj->flags & SWITCHDEV_F_DEFER)
+		return switchdev_port_obj_add_defer(dev, obj);
+	return switchdev_port_obj_add_now(dev, obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
+
+static int switchdev_port_obj_del_defer(struct net_device *dev,
+					const struct switchdev_obj *obj)
+{
+	return switchdev_port_obj_work_schedule(dev, obj, false);
+}
+
+/**
+ *	switchdev_port_obj_del - Delete port object
+ *
+ *	@dev: port device
+ *	@id: object ID
+ *	@obj: object to delete
+ *
+ *	rtnl_lock must be held and must not be in atomic section,
+ *	in case SWITCHDEV_F_DEFER flag is not set.
+ */
+int switchdev_port_obj_del(struct net_device *dev,
+			   const struct switchdev_obj *obj)
+{
+	if (obj->flags & SWITCHDEV_F_DEFER)
+		return switchdev_port_obj_del_defer(dev, obj);
+	return switchdev_port_obj_del_now(dev, obj);
+}
 EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
 
 /**
-- 
1.9.3
