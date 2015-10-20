From: sfeldma@gmail.com
Subject: [PATCH net-next 2/3] switchdev: fix: pass correct obj size when deferring obj add
Date: Tue, 20 Oct 2015 12:36:38 -0700
Message-ID: <1445369799-2345-2-git-send-email-sfeldma@gmail.com>
References: <1445369799-2345-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33571 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbJTTd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 15:33:58 -0400
Received: by pabrc13 with SMTP id rc13so29890626pab.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 12:33:58 -0700 (PDT)
In-Reply-To: <1445369799-2345-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Fixes: 0bc05d585d ("switchdev: allow caller to explicitly request attr_set as deferred")
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/switchdev/switchdev.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 56d8479..be8ced1 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -489,7 +489,24 @@ static void switchdev_port_obj_del_deferred(struct net_device *dev,
 static int switchdev_port_obj_del_defer(struct net_device *dev,
 					const struct switchdev_obj *obj)
 {
-	return switchdev_deferred_enqueue(dev, obj, sizeof(*obj),
+	size_t size = 0;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
+		size = sizeof(struct switchdev_obj_port_vlan);
+		break;
+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
+		size = sizeof(struct switchdev_obj_ipv4_fib);
+		break;
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
+		size = sizeof(struct switchdev_obj_port_fdb);
+		break;
+	default:
+		WARN_ON(!size);
+		return -EINVAL;
+	}
+
+	return switchdev_deferred_enqueue(dev, obj, size,
 					  switchdev_port_obj_del_deferred);
 }
 
-- 
1.7.10.4
