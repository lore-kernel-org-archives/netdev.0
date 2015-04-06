From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [RFC PATCH net-next] switchdev: fdb add/del via swdev obj.
Date: Mon,  6 Apr 2015 16:25:10 -0700
Message-ID: <1428362710-20815-1-git-send-email-sridhar.samudrala@intel.com>
To: sfeldman@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbbDFXYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 19:24:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a patch on top of Scott's v3 version of switchdev spring
cleanup patches.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c | 26 +++++++++-------
 drivers/net/team/team.c              |  2 ++
 include/net/switchdev.h              | 27 +++++++++++++++++
 net/switchdev/switchdev.c            | 58 ++++++++++++++++++++++++++++++++++++
 4 files changed, 103 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 0990286..70d1494 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4031,12 +4031,9 @@ static int rocker_port_vlan_rx_kill_vid(struct net_device *dev,
 	return rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, vid);
 }
 
-static int rocker_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
-			       struct net_device *dev,
-			       const unsigned char *addr, u16 vid,
-			       u16 nlm_flags)
+static int rocker_port_fdb_add(struct rocker_port *rocker_port,
+			       const unsigned char *addr, u16 vid)
 {
-	struct rocker_port *rocker_port = netdev_priv(dev);
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, NULL);
 	int flags = 0;
 
@@ -4046,11 +4043,9 @@ static int rocker_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
 }
 
-static int rocker_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
-			       struct net_device *dev,
+static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 			       const unsigned char *addr, u16 vid)
 {
-	struct rocker_port *rocker_port = netdev_priv(dev);
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, NULL);
 	int flags = ROCKER_OP_FLAG_REMOVE;
 
@@ -4155,8 +4150,8 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_set_mac_address		= rocker_port_set_mac_address,
 	.ndo_vlan_rx_add_vid		= rocker_port_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
-	.ndo_fdb_add			= rocker_port_fdb_add,
-	.ndo_fdb_del			= rocker_port_fdb_del,
+	.ndo_fdb_add			= swdev_port_fdb_add,
+	.ndo_fdb_del			= swdev_port_fdb_del,
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_bridge_setlink		= swdev_port_bridge_setlink,
 	.ndo_bridge_getlink		= swdev_port_bridge_getlink,
@@ -4248,6 +4243,7 @@ static int rocker_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct swdev_obj_ipv4_fib *fib4;
+	struct swdev_obj_fdb *fdb;
 	int err = 0;
 
 	if (obj->flags & SWDEV_F_TRANS_PREPARE)
@@ -4263,6 +4259,11 @@ static int rocker_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
 					   fib4->dst_len, fib4->fi,
 					   fib4->tb_id, 0);
 		break;
+	case SWDEV_OBJ_FDB:
+		fdb = &obj->fdb;
+		err = rocker_port_fdb_add(rocker_port, fdb->mac,
+					  fdb->vid);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4316,6 +4317,11 @@ static int rocker_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
 					   fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
+	case SWDEV_OBJ_FDB:
+		fdb = &obj->fdb;
+		err = rocker_port_fdb_del(rocker_port, fdb->mac,
+					  fdb->vid);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6500fd7..e77bc70 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1981,6 +1981,8 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_bridge_getlink	= swdev_port_bridge_getlink,
 	.ndo_bridge_dellink	= swdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
+	.ndo_fdb_add		= swdev_port_fdb_add,
+	.ndo_fdb_del		= swdev_port_fdb_del,
 };
 
 /***********************
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index c3b1dfd..d8502ff 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -42,6 +42,7 @@ enum swdev_obj_id {
 	SWDEV_OBJ_UNDEFINED,
 	SWDEV_OBJ_PORT_VLAN,
 	SWDEV_OBJ_IPV4_FIB,
+	SWDEV_OBJ_FDB,
 };
 
 struct swdev_obj {
@@ -62,6 +63,10 @@ struct swdev_obj {
 			u32 nlflags;
 			u32 tb_id;
 		} ipv4_fib;
+		struct swdev_obj_fdb {
+			const u8 *mac;
+			u16 vid;
+		} fdb;
 	};
 };
 
@@ -130,6 +135,13 @@ int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 		       u8 tos, u8 type, u32 tb_id);
 void swdev_fib_ipv4_abort(struct fib_info *fi);
 
+int swdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+		       struct net_device *dev, const unsigned char *addr,
+		       u16 vid, u16 flags);
+int swdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+		       struct net_device *dev, const unsigned char *addr,
+		       u16 vid);
+
 #else
 
 static inline int swdev_port_attr_get(struct net_device *dev,
@@ -208,6 +220,21 @@ static inline void swdev_fib_ipv4_abort(struct fib_info *fi)
 {
 }
 
+static inline int swdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+				     struct net_device *dev,
+				     const unsigned char *addr, u16 vid,
+				     u16 flags);
+{
+	return 0;
+}
+
+static inline int swdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+				     struct net_device *dev,
+				     const unsigned char *addr, u16 vid);
+{
+	return 0;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 04e8efd..b515153 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -697,3 +697,61 @@ void swdev_fib_ipv4_abort(struct fib_info *fi)
 	fi->fib_net->ipv4.fib_offload_disabled = true;
 }
 EXPORT_SYMBOL_GPL(swdev_fib_ipv4_abort);
+
+/**
+ *	swdev_port_fdb_add -  Add fdb entry to switch device port
+ *
+ *	@ndm: struct ndmsg
+ *	@tb: pointer to array of nlattr
+ *	@dev: switch device port netdev
+ *	@addr: MAC address entry to be added
+ *	@vid: VLAN id
+ *	@flags: flags for fdb addition
+ *
+ *	Add fdb entry to switch device port.
+ */
+int swdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			struct net_device *dev,
+			const unsigned char *addr, u16 vid,
+			u16 flags)
+{
+	struct swdev_obj fdb_obj = {
+		.id = SWDEV_OBJ_FDB,
+		.fdb = {
+			.mac = addr,
+			.vid = vid,
+		},
+	};
+
+	return swdev_port_obj_add(dev, &fdb_obj);
+
+}
+EXPORT_SYMBOL_GPL(swdev_port_fdb_add);
+
+/**
+ *	swdev_port_fdb_del -  Delete fdb entry from switch device port
+ *
+ *	@ndm: struct ndmsg
+ *	@tb: pointer to array of nlattr
+ *	@dev: switch device port netdev
+ *	@addr: MAC address entry to be added
+ *	@vid: VLAN id
+ *
+ *	Delete fdb entry to switch device port.
+ */
+int swdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+			struct net_device *dev,
+			const unsigned char *addr, u16 vid)
+{
+	struct swdev_obj fdb_obj = {
+		.id = SWDEV_OBJ_FDB,
+		.fdb = {
+			.mac = addr,
+			.vid = vid,
+		},
+	};
+
+	return swdev_port_obj_del(dev, &fdb_obj);
+
+}
+EXPORT_SYMBOL_GPL(swdev_port_fdb_del);
-- 
1.8.4.2
