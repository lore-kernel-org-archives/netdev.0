From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 1/4] net: switchdev: change fdb addr for a byte array
Date: Tue,  4 Aug 2015 01:54:40 -0400
Message-ID: <1438667683-18872-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1438667683-18872-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438667683-18872-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The address in the switchdev_obj_fdb structure is currently represented
as a pointer. Replacing it for a 6-byte array allows switchdev to carry
addresses directly read from hardware registers, not stored by the
switch chip driver (as in Rocker).

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c | 2 +-
 include/net/switchdev.h              | 2 +-
 net/bridge/br_fdb.c                  | 2 +-
 net/switchdev/switchdev.c            | 4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 4cd5a71..faa5db0 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4543,7 +4543,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
 		if (found->key.pport != rocker_port->pport)
 			continue;
-		fdb->addr = found->key.addr;
+		memcpy(fdb->addr, found->key.addr, ETH_ALEN);
 		fdb->vid = rocker_port_vlan_to_vid(rocker_port,
 						   found->key.vlan_id);
 		err = obj->cb(rocker_port->dev, obj);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 89da893..e90e1a0 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -70,7 +70,7 @@ struct switchdev_obj {
 			u32 tb_id;
 		} ipv4_fib;
 		struct switchdev_obj_fdb {		/* PORT_FDB */
-			const unsigned char *addr;
+			u8 addr[ETH_ALEN];
 			u16 vid;
 		} fdb;
 	} u;
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9e9875d..2c64b6a 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -136,11 +136,11 @@ static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 	struct switchdev_obj obj = {
 		.id = SWITCHDEV_OBJ_PORT_FDB,
 		.u.fdb = {
-			.addr = f->addr.addr,
 			.vid = f->vlan_id,
 		},
 	};
 
+	memcpy(obj.u.fdb.addr, f->addr.addr, ETH_ALEN);
 	switchdev_port_obj_del(f->dst->dev, &obj);
 }
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 33bafa2..28786e8 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -742,11 +742,11 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	struct switchdev_obj obj = {
 		.id = SWITCHDEV_OBJ_PORT_FDB,
 		.u.fdb = {
-			.addr = addr,
 			.vid = vid,
 		},
 	};
 
+	memcpy(obj.u.fdb.addr, addr, ETH_ALEN);
 	return switchdev_port_obj_add(dev, &obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
@@ -769,11 +769,11 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	struct switchdev_obj obj = {
 		.id = SWITCHDEV_OBJ_PORT_FDB,
 		.u.fdb = {
-			.addr = addr,
 			.vid = vid,
 		},
 	};
 
+	memcpy(obj.u.fdb.addr, addr, ETH_ALEN);
 	return switchdev_port_obj_del(dev, &obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
-- 
2.4.6
