From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 3/8] switchdev: allow caller to explicitly request attr_set as deferred
Date: Wed, 14 Oct 2015 19:40:50 +0200
Message-ID: <1444844455-12508-4-git-send-email-jiri@resnulli.us>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:32959 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932602AbbJNRlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:41:02 -0400
Received: by wijp11 with SMTP id p11so4730017wij.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:41:01 -0700 (PDT)
In-Reply-To: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Caller should know if he can call attr_set directly (when holding RTNL)
or if he has to defer the att_set processing for later.

This also allows drivers to sleep inside attr_set and report operation
status back to switchdev core. Switchdev core then warns if status is
not ok, instead of silent errors happening in drivers.

Benefit from newly introduced switchdev deferred ops infrastructure.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |   1 +
 net/bridge/br_stp.c       |   3 +-
 net/switchdev/switchdev.c | 108 ++++++++++++++++++----------------------------
 3 files changed, 46 insertions(+), 66 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d1c7f90..f7de6f8 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -17,6 +17,7 @@
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 #define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)
+#define SWITCHDEV_F_DEFER		BIT(2)
 
 struct switchdev_trans_item {
 	struct list_head list;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index db6d243de..80c34d7 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -41,13 +41,14 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
 	struct switchdev_attr attr = {
 		.id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
+		.flags = SWITCHDEV_F_DEFER,
 		.u.stp_state = state,
 	};
 	int err;
 
 	p->state = state;
 	err = switchdev_port_attr_set(p->dev, &attr);
-	if (err && err != -EOPNOTSUPP)
+	if (err)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
 }
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 23b4e5b..007b8f4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -250,75 +250,12 @@ done:
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
-					 const struct switchdev_attr *attr)
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
-/**
- *	switchdev_port_attr_set - Set port attribute
- *
- *	@dev: port device
- *	@attr: attribute to set
- *
- *	Use a 2-phase prepare-commit transaction model to ensure
- *	system is not left in a partially updated state due to
- *	failure from driver/device.
- */
-int switchdev_port_attr_set(struct net_device *dev,
-			    const struct switchdev_attr *attr)
+static int switchdev_port_attr_set_now(struct net_device *dev,
+				       const struct switchdev_attr *attr)
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
-
 	switchdev_trans_init(&trans);
 
 	/* Phase I: prepare for attr set. Driver/device should fail
@@ -355,6 +292,47 @@ int switchdev_port_attr_set(struct net_device *dev,
 
 	return err;
 }
+
+static void switchdev_port_attr_set_deferred(struct net_device *dev,
+					     const void *data)
+{
+	const struct switchdev_attr *attr = data;
+	int err;
+
+	err = switchdev_port_attr_set_now(dev, attr);
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(dev, "failed (err=%d) to set attribute (id=%d)\n",
+			   err, attr->id);
+}
+
+static int switchdev_port_attr_set_defer(struct net_device *dev,
+					 const struct switchdev_attr *attr)
+{
+	return switchdev_deferred_enqueue(dev, attr, sizeof(*attr),
+					  switchdev_port_attr_set_deferred);
+}
+
+/**
+ *	switchdev_port_attr_set - Set port attribute
+ *
+ *	@dev: port device
+ *	@attr: attribute to set
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ *	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ *
+ *	rtnl_lock must be held and must not be in atomic section,
+ *	in case SWITCHDEV_F_DEFER flag is not set.
+ */
+int switchdev_port_attr_set(struct net_device *dev,
+			    const struct switchdev_attr *attr)
+{
+	if (attr->flags & SWITCHDEV_F_DEFER)
+		return switchdev_port_attr_set_defer(dev, attr);
+	ASSERT_RTNL();
+	return switchdev_port_attr_set_now(dev, attr);
+}
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
 static int __switchdev_port_obj_add(struct net_device *dev,
-- 
1.9.3
