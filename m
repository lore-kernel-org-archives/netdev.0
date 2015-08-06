From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/7] net: switchdev: change fdb addr for a byte array
Date: Thu,  6 Aug 2015 01:44:02 -0400
Message-ID: <1438839848-505-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
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
 net/switchdev/switchdev.c            | 5 +++--
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 4cd5a71..a5bf809 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4543,7 +4543,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
 		if (found->key.pport != rocker_port->pport)
 			continue;
-		fdb->addr = found->key.addr;
+		ether_addr_copy(fdb->addr, found->key.addr);
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
index 9e9875d..5656b44 100644
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
 
+	ether_addr_copy(obj.u.fdb.addr, f->addr.addr);
 	switchdev_port_obj_del(f->dst->dev, &obj);
 }
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 33bafa2..9db87a3 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -15,6 +15,7 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/if_bridge.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
@@ -742,11 +743,11 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	struct switchdev_obj obj = {
 		.id = SWITCHDEV_OBJ_PORT_FDB,
 		.u.fdb = {
-			.addr = addr,
 			.vid = vid,
 		},
 	};
 
+	ether_addr_copy(obj.u.fdb.addr, addr);
 	return switchdev_port_obj_add(dev, &obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
@@ -769,11 +770,11 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	struct switchdev_obj obj = {
 		.id = SWITCHDEV_OBJ_PORT_FDB,
 		.u.fdb = {
-			.addr = addr,
 			.vid = vid,
 		},
 	};
 
+	ether_addr_copy(obj.u.fdb.addr, addr);
 	return switchdev_port_obj_del(dev, &obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
-- 
2.4.6
