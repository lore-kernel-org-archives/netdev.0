From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 5/8] switchdev: introduce possibility to defer obj_add/del
Date: Wed, 14 Oct 2015 19:40:52 +0200
Message-ID: <1444844455-12508-6-git-send-email-jiri@resnulli.us>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37681 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701AbbJNRlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:41:04 -0400
Received: by wijq8 with SMTP id q8so92521845wij.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:41:03 -0700 (PDT)
In-Reply-To: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
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
 net/switchdev/switchdev.c | 100 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 81 insertions(+), 20 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index f8672d7..bc865e2 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -69,6 +69,7 @@ enum switchdev_obj_id {
 
 struct switchdev_obj {
 	enum switchdev_obj_id id;
+	u32 flags;
 };
 
 /* SWITCHDEV_OBJ_ID_PORT_VLAN */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 5963d7a..eac68c4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -362,21 +362,8 @@ static int __switchdev_port_obj_add(struct net_device *dev,
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
@@ -418,18 +405,53 @@ int switchdev_port_obj_add(struct net_device *dev,
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
+
+static void switchdev_port_obj_add_deferred(struct net_device *dev,
+					    const void *data)
+{
+	const struct switchdev_obj *obj = data;
+	int err;
+
+	err = switchdev_port_obj_add_now(dev, obj);
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(dev, "failed (err=%d) to add object (id=%d)\n",
+			   err, obj->id);
+}
+
+static int switchdev_port_obj_add_defer(struct net_device *dev,
+					const struct switchdev_obj *obj)
+{
+	return switchdev_deferred_enqueue(dev, obj, sizeof(*obj),
+					  switchdev_port_obj_add_deferred);
+}
 
 /**
- *	switchdev_port_obj_del - Delete port object
+ *	switchdev_port_obj_add - Add port object
  *
  *	@dev: port device
  *	@id: object ID
- *	@obj: object to delete
+ *	@obj: object to add
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ *	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ *
+ *	rtnl_lock must be held and must not be in atomic section,
+ *	in case SWITCHDEV_F_DEFER flag is not set.
  */
-int switchdev_port_obj_del(struct net_device *dev,
+int switchdev_port_obj_add(struct net_device *dev,
 			   const struct switchdev_obj *obj)
 {
+	if (obj->flags & SWITCHDEV_F_DEFER)
+		return switchdev_port_obj_add_defer(dev, obj);
+	ASSERT_RTNL();
+	return switchdev_port_obj_add_now(dev, obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
+
+static int switchdev_port_obj_del_now(struct net_device *dev,
+				      const struct switchdev_obj *obj)
+{
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
 	struct list_head *iter;
@@ -444,13 +466,51 @@ int switchdev_port_obj_del(struct net_device *dev,
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
+static void switchdev_port_obj_del_deferred(struct net_device *dev,
+					    const void *data)
+{
+	const struct switchdev_obj *obj = data;
+	int err;
+
+	err = switchdev_port_obj_del_now(dev, obj);
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(dev, "failed (err=%d) to del object (id=%d)\n",
+			   err, obj->id);
+}
+
+static int switchdev_port_obj_del_defer(struct net_device *dev,
+					const struct switchdev_obj *obj)
+{
+	return switchdev_deferred_enqueue(dev, obj, sizeof(*obj),
+					  switchdev_port_obj_del_deferred);
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
+	ASSERT_RTNL();
+	return switchdev_port_obj_del_now(dev, obj);
+}
 EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
 
 /**
-- 
1.9.3
