From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/3] switchdev: Adding complete operation to deferred switchdev ops
Date: Thu, 21 Apr 2016 12:52:43 +0200
Message-ID: <1461235965-3930-2-git-send-email-jiri@resnulli.us>
References: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38861 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbcDUKwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 06:52:49 -0400
Received: by mail-wm0-f49.google.com with SMTP id u206so125769251wme.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 03:52:49 -0700 (PDT)
In-Reply-To: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

When using switchdev deferred operation (SWITCHDEV_F_DEFER), the operation
is executed in different context and the application doesn't have any way
to get the operation real status.

Adding a completion callback fixes that. This patch adds fields to
switchdev_attr and switchdev_obj "complete_priv" field which is used by
the "complete" callback.

Application can set a complete function which will be called once the
operation executed.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/net/switchdev.h   | 4 ++++
 net/switchdev/switchdev.c | 6 ++++++
 2 files changed, 10 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d451122..51d77b2 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -54,6 +54,8 @@ struct switchdev_attr {
 	struct net_device *orig_dev;
 	enum switchdev_attr_id id;
 	u32 flags;
+	void *complete_priv;
+	void (*complete)(struct net_device *dev, int err, void *priv);
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
@@ -75,6 +77,8 @@ struct switchdev_obj {
 	struct net_device *orig_dev;
 	enum switchdev_obj_id id;
 	u32 flags;
+	void *complete_priv;
+	void (*complete)(struct net_device *dev, int err, void *priv);
 };
 
 /* SWITCHDEV_OBJ_ID_PORT_VLAN */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 2b9b98f..b7e01d8 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -305,6 +305,8 @@ static void switchdev_port_attr_set_deferred(struct net_device *dev,
 	if (err && err != -EOPNOTSUPP)
 		netdev_err(dev, "failed (err=%d) to set attribute (id=%d)\n",
 			   err, attr->id);
+	if (attr->complete)
+		attr->complete(dev, err, attr->complete_priv);
 }
 
 static int switchdev_port_attr_set_defer(struct net_device *dev,
@@ -434,6 +436,8 @@ static void switchdev_port_obj_add_deferred(struct net_device *dev,
 	if (err && err != -EOPNOTSUPP)
 		netdev_err(dev, "failed (err=%d) to add object (id=%d)\n",
 			   err, obj->id);
+	if (obj->complete)
+		obj->complete(dev, err, obj->complete_priv);
 }
 
 static int switchdev_port_obj_add_defer(struct net_device *dev,
@@ -502,6 +506,8 @@ static void switchdev_port_obj_del_deferred(struct net_device *dev,
 	if (err && err != -EOPNOTSUPP)
 		netdev_err(dev, "failed (err=%d) to del object (id=%d)\n",
 			   err, obj->id);
+	if (obj->complete)
+		obj->complete(dev, err, obj->complete_priv);
 }
 
 static int switchdev_port_obj_del_defer(struct net_device *dev,
-- 
2.5.5
