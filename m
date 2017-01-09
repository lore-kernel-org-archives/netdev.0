From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/4] net: switchdev: Prepare for deferred functions modifying objects
Date: Mon,  9 Jan 2017 12:45:20 -0800
Message-ID: <20170109204523.5843-2-f.fainelli@gmail.com>
References: <20170109204523.5843-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@resnulli.us, marcelo.leitner@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33480 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755493AbdAIUp1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:45:27 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so25258213pfg.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 12:45:27 -0800 (PST)
In-Reply-To: <20170109204523.5843-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for adding support for deferred dump operations, allow
specifying a deferred function whose signature allows read/write
objects.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/switchdev/switchdev.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 017801f9dbaa..3d70ad02c617 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -100,11 +100,14 @@ static DEFINE_SPINLOCK(deferred_lock);
 
 typedef void switchdev_deferred_func_t(struct net_device *dev,
 				       const void *data);
+typedef void switchdev_deferred_func_rw_t(struct net_device *dev,
+					  void *data);
 
 struct switchdev_deferred_item {
 	struct list_head list;
 	struct net_device *dev;
 	switchdev_deferred_func_t *func;
+	switchdev_deferred_func_rw_t *func_rw;
 	unsigned long data[0];
 };
 
@@ -138,7 +141,10 @@ void switchdev_deferred_process(void)
 	ASSERT_RTNL();
 
 	while ((dfitem = switchdev_deferred_dequeue())) {
-		dfitem->func(dfitem->dev, dfitem->data);
+		if (dfitem->func)
+			dfitem->func(dfitem->dev, dfitem->data);
+		else if (dfitem->func_rw)
+			dfitem->func_rw(dfitem->dev, dfitem->data);
 		dev_put(dfitem->dev);
 		kfree(dfitem);
 	}
@@ -156,7 +162,8 @@ static DECLARE_WORK(deferred_process_work, switchdev_deferred_process_work);
 
 static int switchdev_deferred_enqueue(struct net_device *dev,
 				      const void *data, size_t data_len,
-				      switchdev_deferred_func_t *func)
+				      switchdev_deferred_func_t *func,
+				      switchdev_deferred_func_rw_t *func_rw)
 {
 	struct switchdev_deferred_item *dfitem;
 
@@ -165,6 +172,7 @@ static int switchdev_deferred_enqueue(struct net_device *dev,
 		return -ENOMEM;
 	dfitem->dev = dev;
 	dfitem->func = func;
+	dfitem->func_rw = func_rw;
 	memcpy(dfitem->data, data, data_len);
 	dev_hold(dev);
 	spin_lock_bh(&deferred_lock);
@@ -312,7 +320,8 @@ static int switchdev_port_attr_set_defer(struct net_device *dev,
 					 const struct switchdev_attr *attr)
 {
 	return switchdev_deferred_enqueue(dev, attr, sizeof(*attr),
-					  switchdev_port_attr_set_deferred);
+					  switchdev_port_attr_set_deferred,
+					  NULL);
 }
 
 /**
@@ -441,7 +450,8 @@ static int switchdev_port_obj_add_defer(struct net_device *dev,
 					const struct switchdev_obj *obj)
 {
 	return switchdev_deferred_enqueue(dev, obj, switchdev_obj_size(obj),
-					  switchdev_port_obj_add_deferred);
+					  switchdev_port_obj_add_deferred,
+					  NULL);
 }
 
 /**
@@ -511,7 +521,8 @@ static int switchdev_port_obj_del_defer(struct net_device *dev,
 					const struct switchdev_obj *obj)
 {
 	return switchdev_deferred_enqueue(dev, obj, switchdev_obj_size(obj),
-					  switchdev_port_obj_del_deferred);
+					  switchdev_port_obj_del_deferred,
+					  NULL);
 }
 
 /**
-- 
2.9.3
