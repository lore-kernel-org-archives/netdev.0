From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/7] switchdev: allow caller to explicitly request attr_set as deferred
Date: Mon, 12 Oct 2015 15:15:05 +0200
Message-ID: <1444655710-8279-3-git-send-email-jiri@resnulli.us>
References: <1444655710-8279-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37963 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbbJLNPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 09:15:16 -0400
Received: by wieq12 with SMTP id q12so19895486wie.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 06:15:15 -0700 (PDT)
In-Reply-To: <1444655710-8279-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Caller should know if he can call attr_set directly (when holding RTNL)
or if he has to defer the att_set processing for later.

This also allows drivers to sleep inside attr_set and report operation
status back to switchdev core. Switchdev core then warns if status is
not ok, instead of silent errors happening in drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |   1 +
 net/bridge/br_stp.c       |   3 +-
 net/switchdev/switchdev.c | 107 ++++++++++++++++++++++++----------------------
 3 files changed, 59 insertions(+), 52 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d2879f2..6b109e4 100644
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
index d119e9c..9f94272 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -173,6 +173,49 @@ done:
 	return err;
 }
 
+static int switchdev_port_attr_set_now(struct net_device *dev,
+				       struct switchdev_attr *attr)
+{
+	struct switchdev_trans trans;
+	int err;
+
+	switchdev_trans_init(&trans);
+
+	/* Phase I: prepare for attr set. Driver/device should fail
+	 * here if there are going to be issues in the commit phase,
+	 * such as lack of resources or support.  The driver/device
+	 * should reserve resources needed for the commit phase here,
+	 * but should not commit the attr.
+	 */
+
+	trans.ph_prepare = true;
+	err = __switchdev_port_attr_set(dev, attr, &trans);
+	if (err) {
+		/* Prepare phase failed: abort the transaction.  Any
+		 * resources reserved in the prepare phase are
+		 * released.
+		 */
+
+		if (err != -EOPNOTSUPP)
+			switchdev_trans_items_destroy(&trans);
+
+		return err;
+	}
+
+	/* Phase II: commit attr set.  This cannot fail as a fault
+	 * of driver/device.  If it does, it's a bug in the driver/device
+	 * because the driver said everythings was OK in phase I.
+	 */
+
+	trans.ph_prepare = false;
+	err = __switchdev_port_attr_set(dev, attr, &trans);
+	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
+	     dev->name, attr->id);
+	switchdev_trans_items_warn_destroy(dev, &trans);
+
+	return err;
+}
+
 struct switchdev_attr_set_work {
 	struct work_struct work;
 	struct net_device *dev;
@@ -183,14 +226,17 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
 {
 	struct switchdev_attr_set_work *asw =
 		container_of(work, struct switchdev_attr_set_work, work);
+	bool rtnl_locked = rtnl_is_locked();
 	int err;
 
-	rtnl_lock();
-	err = switchdev_port_attr_set(asw->dev, &asw->attr);
+	if (!rtnl_locked)
+		rtnl_lock();
+	err = switchdev_port_attr_set_now(asw->dev, &asw->attr);
 	if (err && err != -EOPNOTSUPP)
 		netdev_err(asw->dev, "failed (err=%d) to set attribute (id=%d)\n",
 			   err, asw->attr.id);
-	rtnl_unlock();
+	if (!rtnl_locked)
+		rtnl_unlock();
 
 	dev_put(asw->dev);
 	kfree(work);
@@ -211,7 +257,7 @@ static int switchdev_port_attr_set_defer(struct net_device *dev,
 	asw->dev = dev;
 	memcpy(&asw->attr, attr, sizeof(asw->attr));
 
-	schedule_work(&asw->work);
+	queue_work(switchdev_wq, &asw->work);
 
 	return 0;
 }
@@ -225,57 +271,16 @@ static int switchdev_port_attr_set_defer(struct net_device *dev,
  *	Use a 2-phase prepare-commit transaction model to ensure
  *	system is not left in a partially updated state due to
  *	failure from driver/device.
+ *
+ *	rtnl_lock must be held and must not be in atomic section,
+ *	in case SWITCHDEV_F_DEFER flag is not set.
  */
 int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 {
-	struct switchdev_trans trans;
-	int err;
-
-	if (!rtnl_is_locked()) {
-		/* Running prepare-commit transaction across stacked
-		 * devices requires nothing moves, so if rtnl_lock is
-		 * not held, schedule a worker thread to hold rtnl_lock
-		 * while setting attr.
-		 */
-
+	if (attr->flags & SWITCHDEV_F_DEFER)
 		return switchdev_port_attr_set_defer(dev, attr);
-	}
-
-	switchdev_trans_init(&trans);
-
-	/* Phase I: prepare for attr set. Driver/device should fail
-	 * here if there are going to be issues in the commit phase,
-	 * such as lack of resources or support.  The driver/device
-	 * should reserve resources needed for the commit phase here,
-	 * but should not commit the attr.
-	 */
-
-	trans.ph_prepare = true;
-	err = __switchdev_port_attr_set(dev, attr, &trans);
-	if (err) {
-		/* Prepare phase failed: abort the transaction.  Any
-		 * resources reserved in the prepare phase are
-		 * released.
-		 */
-
-		if (err != -EOPNOTSUPP)
-			switchdev_trans_items_destroy(&trans);
-
-		return err;
-	}
-
-	/* Phase II: commit attr set.  This cannot fail as a fault
-	 * of driver/device.  If it does, it's a bug in the driver/device
-	 * because the driver said everythings was OK in phase I.
-	 */
-
-	trans.ph_prepare = false;
-	err = __switchdev_port_attr_set(dev, attr, &trans);
-	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
-	     dev->name, attr->id);
-	switchdev_trans_items_warn_destroy(dev, &trans);
-
-	return err;
+	ASSERT_RTNL();
+	return switchdev_port_attr_set_now(dev, attr);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
-- 
1.9.3
