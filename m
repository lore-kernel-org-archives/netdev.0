From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 12/13] net: bridge: Remove FDB deletion through switchdev object
Date: Sun,  6 Aug 2017 16:15:50 +0300
Message-ID: <1502025351-41261-13-git-send-email-arkadis@mellanox.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44880 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751363AbdHFNMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:20 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point no driver supports FDB add/del through switchdev object
but rather via notification chain, thus, it is removed.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_fdb.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index a5e4a73..a79b648 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -169,29 +169,11 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
 	}
 }
 
-static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
-{
-	struct switchdev_obj_port_fdb fdb = {
-		.obj = {
-			.orig_dev = f->dst->dev,
-			.id = SWITCHDEV_OBJ_ID_PORT_FDB,
-			.flags = SWITCHDEV_F_DEFER,
-		},
-		.vid = f->vlan_id,
-	};
-
-	ether_addr_copy(fdb.addr, f->addr.addr);
-	switchdev_port_obj_del(f->dst->dev, &fdb.obj);
-}
-
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 {
 	if (f->is_static)
 		fdb_del_hw_addr(br, f->addr.addr);
 
-	if (f->added_by_external_learn)
-		fdb_del_external_learn(f);
-
 	hlist_del_init_rcu(&f->hlist);
 	fdb_notify(br, f, RTM_DELNEIGH);
 	call_rcu(&f->rcu, fdb_rcu_free);
-- 
2.4.11
