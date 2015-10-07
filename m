From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/3] switchdev: allow caller to explicitly use deferred attr_set version
Date: Wed,  7 Oct 2015 20:30:51 +0200
Message-ID: <1444242652-17260-3-git-send-email-jiri@resnulli.us>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34270 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbbJGSa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 14:30:58 -0400
Received: by wicfx3 with SMTP id fx3so225380737wic.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 11:30:56 -0700 (PDT)
In-Reply-To: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Caller should know if he can call attr_set directly (when holding RTNL)
or if he has to use deferred version of this function.

This also allows drivers to sleep inside attr_set and report operation
status back to switchdev core. Switchdev core then warns if status is
not ok, instead of silent errors happening in drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |   2 +
 net/bridge/br_stp.c       |   4 +-
 net/switchdev/switchdev.c | 113 +++++++++++++++++++++++++---------------------
 3 files changed, 65 insertions(+), 54 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 89266a3..320be44 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -168,6 +168,8 @@ int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
+int switchdev_port_attr_set_deferred(struct net_device *dev,
+				     struct switchdev_attr *attr);
 int switchdev_port_obj_add(struct net_device *dev,
 			   const struct switchdev_obj *obj);
 int switchdev_port_obj_del(struct net_device *dev,
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 3a982c0..91a56b6 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -46,8 +46,8 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
 	int err;
 
 	p->state = state;
-	err = switchdev_port_attr_set(p->dev, &attr);
-	if (err && err != -EOPNOTSUPP)
+	err = switchdev_port_attr_set_deferred(p->dev, &attr);
+	if (err)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
 }
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 3fb05d5..c29f4ee 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -163,49 +163,6 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 	return err;
 }
 
-struct switchdev_attr_set_work {
-	struct work_struct work;
-	struct net_device *dev;
-	struct switchdev_attr attr;
-};
-
-static void switchdev_port_attr_set_work(struct work_struct *work)
-{
-	struct switchdev_attr_set_work *asw =
-		container_of(work, struct switchdev_attr_set_work, work);
-	int err;
-
-	rtnl_lock();
-	err = switchdev_port_attr_set(asw->dev, &asw->attr);
-	if (err && err != -EOPNOTSUPP)
-		netdev_err(asw->dev, "failed (err=%d) to set attribute (id=%d)\n",
-			   err, asw->attr.id);
-	rtnl_unlock();
-
-	dev_put(asw->dev);
-	kfree(work);
-}
-
-static int switchdev_port_attr_set_defer(struct net_device *dev,
-					 struct switchdev_attr *attr)
-{
-	struct switchdev_attr_set_work *asw;
-
-	asw = kmalloc(sizeof(*asw), GFP_ATOMIC);
-	if (!asw)
-		return -ENOMEM;
-
-	INIT_WORK(&asw->work, switchdev_port_attr_set_work);
-
-	dev_hold(dev);
-	asw->dev = dev;
-	memcpy(&asw->attr, attr, sizeof(asw->attr));
-
-	schedule_work(&asw->work);
-
-	return 0;
-}
-
 /**
  *	switchdev_port_attr_set - Set port attribute
  *
@@ -215,21 +172,16 @@ static int switchdev_port_attr_set_defer(struct net_device *dev,
  *	Use a 2-phase prepare-commit transaction model to ensure
  *	system is not left in a partially updated state due to
  *	failure from driver/device.
+ *
+ *	rtnl_lock must be held.
+ *	must not be in atomic section.
  */
 int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 {
 	struct switchdev_trans trans;
 	int err;
 
-	if (!rtnl_is_locked()) {
-		/* Running prepare-commit transaction across stacked
-		 * devices requires nothing moves, so if rtnl_lock is
-		 * not held, schedule a worker thread to hold rtnl_lock
-		 * while setting attr.
-		 */
-
-		return switchdev_port_attr_set_defer(dev, attr);
-	}
+	ASSERT_RTNL();
 
 	switchdev_trans_init(&trans);
 
@@ -269,6 +221,63 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
+struct switchdev_attr_set_work {
+	struct work_struct work;
+	struct net_device *dev;
+	struct switchdev_attr attr;
+};
+
+static void switchdev_port_attr_set_work(struct work_struct *work)
+{
+	struct switchdev_attr_set_work *asw =
+		container_of(work, struct switchdev_attr_set_work, work);
+	int err;
+
+	rtnl_lock();
+	err = switchdev_port_attr_set(asw->dev, &asw->attr);
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(asw->dev, "failed (err=%d) to set attribute (id=%d)\n",
+			   err, asw->attr.id);
+	rtnl_unlock();
+
+	dev_put(asw->dev);
+	kfree(asw);
+}
+
+/**
+ *	switchdev_port_attr_set_deferred - Set port attribute - deferred
+ *
+ *	@dev: port device
+ *	@attr: attribute to set
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ *	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ *
+ *	This version can be safely called from context when RTNL
+ *	mutex is not held and from atomic context.
+ */
+int switchdev_port_attr_set_deferred(struct net_device *dev,
+				     struct switchdev_attr *attr)
+{
+	struct switchdev_attr_set_work *asw;
+
+	asw = kmalloc(sizeof(*asw), GFP_ATOMIC);
+	if (!asw)
+		return -ENOMEM;
+
+	INIT_WORK(&asw->work, switchdev_port_attr_set_work);
+
+	dev_hold(dev);
+	asw->dev = dev;
+	memcpy(&asw->attr, attr, sizeof(asw->attr));
+
+	schedule_work(&asw->work);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_attr_set_deferred);
+
 static int __switchdev_port_obj_add(struct net_device *dev,
 				    const struct switchdev_obj *obj,
 				    struct switchdev_trans *trans)
-- 
1.9.3
