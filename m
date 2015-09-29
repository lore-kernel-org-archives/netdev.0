From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next 3/6] net: switchdev: remove dev from switchdev_obj cb
Date: Tue, 29 Sep 2015 12:07:15 -0400
Message-ID: <1443542838-19234-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:33818
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964805AbbI2QHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 12:07:51 -0400
In-Reply-To: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The net_device associated to a dump operation does not have to be passed
to the callback. switchdev stores it in a superset struct, if needed.

Also some drivers (such as DSA drivers) may not have easy access to it.

This will simplify pushing the callback function down to the drivers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c | 4 ++--
 include/net/switchdev.h              | 2 +-
 net/dsa/slave.c                      | 4 ++--
 net/switchdev/switchdev.c            | 6 ++----
 4 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index d3f6632..78fd443 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4556,7 +4556,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 		fdb->ndm_state = NUD_REACHABLE;
 		fdb->vid = rocker_port_vlan_to_vid(rocker_port,
 						   found->key.vlan_id);
-		err = obj->cb(rocker_port->dev, obj);
+		err = obj->cb(obj);
 		if (err)
 			break;
 	}
@@ -4579,7 +4579,7 @@ static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 		if (rocker_vlan_id_is_internal(htons(vid)))
 			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
 		vlan->vid_begin = vlan->vid_end = vid;
-		err = obj->cb(rocker_port->dev, obj);
+		err = obj->cb(obj);
 		if (err)
 			break;
 	}
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1820787..9ef7c56 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -66,7 +66,7 @@ enum switchdev_obj_id {
 
 struct switchdev_obj {
 	enum switchdev_obj_id id;
-	int (*cb)(struct net_device *dev, struct switchdev_obj *obj);
+	int (*cb)(struct switchdev_obj *obj);
 	union {
 		struct switchdev_obj_vlan {		/* PORT_VLAN */
 			u16 flags;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index f18cae5..0b47647 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -334,7 +334,7 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 		if (test_bit(p->port, untagged))
 			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
-		err = obj->cb(dev, obj);
+		err = obj->cb(obj);
 		if (err)
 			break;
 	}
@@ -397,7 +397,7 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 		obj->u.fdb.vid = vid;
 		obj->u.fdb.ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
 
-		ret = obj->cb(dev, obj);
+		ret = obj->cb(obj);
 		if (ret < 0)
 			break;
 	}
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index c0e2047..93f4971 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -514,8 +514,7 @@ static int switchdev_port_vlan_dump_put(struct switchdev_vlan_dump *dump)
 	return 0;
 }
 
-static int switchdev_port_vlan_dump_cb(struct net_device *dev,
-				       struct switchdev_obj *obj)
+static int switchdev_port_vlan_dump_cb(struct switchdev_obj *obj)
 {
 	struct switchdev_vlan_dump *dump =
 		container_of(obj, struct switchdev_vlan_dump, obj);
@@ -864,8 +863,7 @@ struct switchdev_fdb_dump {
 	int idx;
 };
 
-static int switchdev_port_fdb_dump_cb(struct net_device *dev,
-				      struct switchdev_obj *obj)
+static int switchdev_port_fdb_dump_cb(struct switchdev_obj *obj)
 {
 	struct switchdev_fdb_dump *dump =
 		container_of(obj, struct switchdev_fdb_dump, obj);
-- 
2.6.0
