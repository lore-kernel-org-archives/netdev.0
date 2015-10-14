From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 6/8] bridge: defer switchdev fdb del call in fdb_del_external_learn
Date: Wed, 14 Oct 2015 19:40:53 +0200
Message-ID: <1444844455-12508-7-git-send-email-jiri@resnulli.us>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37705 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202AbbJNRlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:41:05 -0400
Received: by wijq8 with SMTP id q8so92522576wij.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:41:04 -0700 (PDT)
In-Reply-To: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since spinlock is held here, defer the switchdev operation. Also, ensure
that defered switchdev ops are processed before port master device
is unlinked.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_fdb.c | 5 ++++-
 net/bridge/br_if.c  | 3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index f5e7da0..c88bd8e 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -134,7 +134,10 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
 static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 {
 	struct switchdev_obj_port_fdb fdb = {
-		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
+		.obj = {
+			.id = SWITCHDEV_OBJ_ID_PORT_FDB,
+			.flags = SWITCHDEV_F_DEFER,
+		},
 		.vid = f->vlan_id,
 	};
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 45e4757..ec02f58 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -24,6 +24,7 @@
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <linux/if_vlan.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 
@@ -250,6 +251,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 0, 1);
+	switchdev_deferred_process();
+
 	nbp_update_port_count(br);
 
 	netdev_upper_dev_unlink(dev, br->dev);
-- 
1.9.3
