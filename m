From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/7] bridge: defer switchdev fdb del call in fdb_del_external_learn
Date: Sun, 11 Oct 2015 17:21:09 +0200
Message-ID: <1444576871-19138-6-git-send-email-jiri@resnulli.us>
References: <1444576871-19138-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35260 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbbJKPVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 11:21:23 -0400
Received: by wicge5 with SMTP id ge5so122657766wic.0
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 08:21:22 -0700 (PDT)
In-Reply-To: <1444576871-19138-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since spinlock is held here, defer the switchdev operation.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_fdb.c | 5 ++++-
 net/bridge/br_if.c  | 3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b3801fd..8b723b4 100644
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
index 934cae9..09147cb 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -24,6 +24,7 @@
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <linux/if_vlan.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 
@@ -249,6 +250,8 @@ static void del_nbp(struct net_bridge_port *p)
 	list_del_rcu(&p->list);
 
 	br_fdb_delete_by_port(br, p, 0, 1);
+	switchdev_flush_deferred();
+
 	nbp_update_port_count(br);
 
 	netdev_upper_dev_unlink(dev, br->dev);
-- 
1.9.3
