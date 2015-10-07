From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 3/3] switchdev: introduce deferred variants of obj_add/del helpers
Date: Wed,  7 Oct 2015 20:30:52 +0200
Message-ID: <1444242652-17260-4-git-send-email-jiri@resnulli.us>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33619 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbbJGSa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 14:30:59 -0400
Received: by wiclk2 with SMTP id lk2so226313473wic.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 11:30:57 -0700 (PDT)
In-Reply-To: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
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
 include/net/switchdev.h   |  4 +++
 net/bridge/br_fdb.c       |  2 +-
 net/switchdev/switchdev.c | 86 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 320be44..5841599 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -172,8 +172,12 @@ int switchdev_port_attr_set_deferred(struct net_device *dev,
 				     struct switchdev_attr *attr);
 int switchdev_port_obj_add(struct net_device *dev,
 			   const struct switchdev_obj *obj);
+int switchdev_port_obj_add_deferred(struct net_device *dev,
+				    const struct switchdev_obj *obj);
 int switchdev_port_obj_del(struct net_device *dev,
 			   const struct switchdev_obj *obj);
+int switchdev_port_obj_del_deferred(struct net_device *dev,
+				    const struct switchdev_obj *obj);
 int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 			    switchdev_obj_dump_cb_t *cb);
 int register_switchdev_notifier(struct notifier_block *nb);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 7f7d551..2086767 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -139,7 +139,7 @@ static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 		.vid = f->vlan_id,
 	};
 
-	switchdev_port_obj_del(f->dst->dev, &fdb.obj);
+	switchdev_port_obj_del_deferred(f->dst->dev, &fdb.obj);
 }
 
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index c29f4ee..49e6e6f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -362,6 +362,75 @@ int switchdev_port_obj_add(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
 
+struct switchdev_obj_work {
+	struct work_struct work;
+	struct net_device *dev;
+	struct switchdev_obj obj;
+	bool add; /* add of del */
+};
+
+static void switchdev_port_obj_work(struct work_struct *work)
+{
+	struct switchdev_obj_work *ow =
+			container_of(work, struct switchdev_obj_work, work);
+	int err;
+
+	rtnl_lock();
+	if (ow->add)
+		err = switchdev_port_obj_add(ow->dev, &ow->obj);
+	else
+		err = switchdev_port_obj_del(ow->dev, &ow->obj);
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(ow->dev, "failed (err=%d) to %s object (id=%d)\n",
+			   err, ow->add ? "add" : "del", ow->obj.id);
+	rtnl_unlock();
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
+	schedule_work(&ow->work);
+	return 0;
+}
+
+/**
+ *	switchdev_port_obj_add_deferred - Add port object - deferred
+ *
+ *	@dev: port device
+ *	@id: object ID
+ *	@obj: object to add
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ *	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ *
+ *	This version can be safely called from context when RTNL
+ *	mutex is not held and from atomic context.
+ */
+int switchdev_port_obj_add_deferred(struct net_device *dev,
+				    const struct switchdev_obj *obj)
+{
+	return switchdev_port_obj_work_schedule(dev, obj, true);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_obj_add_deferred);
+
 /**
  *	switchdev_port_obj_del - Delete port object
  *
@@ -400,6 +469,23 @@ int switchdev_port_obj_del(struct net_device *dev,
 EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
 
 /**
+ *	switchdev_port_obj_del_deferred - Delete port object - deferred
+ *
+ *	@dev: port device
+ *	@id: object ID
+ *	@obj: object to delete
+ *
+ *	This version can be safely called from context when RTNL
+ *	mutex is not held and from atomic context.
+ */
+int switchdev_port_obj_del_deferred(struct net_device *dev,
+				    const struct switchdev_obj *obj)
+{
+	return switchdev_port_obj_work_schedule(dev, obj, false);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_obj_del_deferred);
+
+/**
  *	switchdev_port_obj_dump - Dump port objects
  *
  *	@dev: port device
-- 
1.9.3
