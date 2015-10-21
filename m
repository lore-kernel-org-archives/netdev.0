From: sfeldma@gmail.com
Subject: [PATCH net-next v2 2/3] switchdev: fix: pass correct obj size when deferring obj add/del
Date: Wed, 21 Oct 2015 10:00:20 -0700
Message-ID: <1445446821-26147-2-git-send-email-sfeldma@gmail.com>
References: <1445446821-26147-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36002 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbbJUQ5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 12:57:21 -0400
Received: by pacfv9 with SMTP id fv9so62215287pac.3
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 09:57:20 -0700 (PDT)
In-Reply-To: <1445446821-26147-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Fixes: 4d429c5dd ("switchdev: introduce possibility to defer obj_add/del")
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
v1->v2: use correct "Fixes" tag, use common func to calc obj size for add/del

 net/switchdev/switchdev.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 56d8479..bff8e2b 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -336,6 +336,21 @@ int switchdev_port_attr_set(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
+static size_t switchdev_obj_size(const struct switchdev_obj *obj)
+{
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
+		return sizeof(struct switchdev_obj_port_vlan);
+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
+		return sizeof(struct switchdev_obj_ipv4_fib);
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
+		return sizeof(struct switchdev_obj_port_fdb);
+	default:
+		BUG();
+	}
+	return 0;
+}
+
 static int __switchdev_port_obj_add(struct net_device *dev,
 				    const struct switchdev_obj *obj,
 				    struct switchdev_trans *trans)
@@ -421,7 +436,7 @@ static void switchdev_port_obj_add_deferred(struct net_device *dev,
 static int switchdev_port_obj_add_defer(struct net_device *dev,
 					const struct switchdev_obj *obj)
 {
-	return switchdev_deferred_enqueue(dev, obj, sizeof(*obj),
+	return switchdev_deferred_enqueue(dev, obj, switchdev_obj_size(obj),
 					  switchdev_port_obj_add_deferred);
 }
 
@@ -489,7 +504,7 @@ static void switchdev_port_obj_del_deferred(struct net_device *dev,
 static int switchdev_port_obj_del_defer(struct net_device *dev,
 					const struct switchdev_obj *obj)
 {
-	return switchdev_deferred_enqueue(dev, obj, sizeof(*obj),
+	return switchdev_deferred_enqueue(dev, obj, switchdev_obj_size(obj),
 					  switchdev_port_obj_del_deferred);
 }
 
-- 
1.7.10.4
