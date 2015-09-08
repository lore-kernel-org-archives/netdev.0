From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 1/3] net: switchdev: extract switchdev_obj_vlan
Date: Tue,  8 Sep 2015 16:47:53 -0400
Message-ID: <1441745275-13200-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:41203
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751972AbbIHUtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 16:49:05 -0400
In-Reply-To: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the switchdev_obj_vlan structure out of the switchdev_obj union.

This lightens the switchdev_obj structure and allows drivers to access
the object transaction and callback directly from a switchdev_obj_vlan.
This is more consistent and convenient for add and dump operations.

The patch updates bridge, the Rocker driver and DSA accordingly.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c | 21 +++++++++--------
 include/net/switchdev.h              | 13 +++++++----
 net/bridge/br_vlan.c                 | 26 +++++++++------------
 net/dsa/slave.c                      | 27 ++++++++++++----------
 net/switchdev/switchdev.c            | 44 ++++++++++++++++++------------------
 5 files changed, 68 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 34ac41a..e72d49a 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4394,14 +4394,13 @@ static int rocker_port_vlan_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlans_add(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans,
 				 const struct switchdev_obj_vlan *vlan)
 {
 	u16 vid;
 	int err;
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = rocker_port_vlan_add(rocker_port, trans,
+		err = rocker_port_vlan_add(rocker_port, vlan->obj.trans,
 					   vid, vlan->flags);
 		if (err)
 			return err;
@@ -4427,6 +4426,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	const struct switchdev_obj_vlan *vlan;
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
@@ -4443,8 +4443,8 @@ static int rocker_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, obj->trans,
-					    &obj->u.vlan);
+		vlan = (struct switchdev_obj_vlan *) obj;
+		err = rocker_port_vlans_add(rocker_port, vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
@@ -4509,12 +4509,14 @@ static int rocker_port_obj_del(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	const struct switchdev_obj_vlan *vlan;
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_del(rocker_port, &obj->u.vlan);
+		vlan = (struct switchdev_obj_vlan *) obj;
+		err = rocker_port_vlans_del(rocker_port, vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
@@ -4563,9 +4565,8 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
-				 struct switchdev_obj *obj)
+				 struct switchdev_obj_vlan *vlan)
 {
-	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	u16 vid;
 	int err = 0;
 
@@ -4576,7 +4577,7 @@ static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 		if (rocker_vlan_id_is_internal(htons(vid)))
 			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
 		vlan->vid_begin = vlan->vid_end = vid;
-		err = obj->cb(rocker_port->dev, obj);
+		err = vlan->obj.cb(rocker_port->dev, &vlan->obj);
 		if (err)
 			break;
 	}
@@ -4588,6 +4589,7 @@ static int rocker_port_obj_dump(struct net_device *dev,
 				struct switchdev_obj *obj)
 {
 	const struct rocker_port *rocker_port = netdev_priv(dev);
+	struct switchdev_obj_vlan *vlan;
 	int err = 0;
 
 	switch (obj->id) {
@@ -4595,7 +4597,8 @@ static int rocker_port_obj_dump(struct net_device *dev,
 		err = rocker_port_fdb_dump(rocker_port, obj);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlan_dump(rocker_port, obj);
+		vlan = (struct switchdev_obj_vlan *) obj;
+		err = rocker_port_vlan_dump(rocker_port, vlan);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 319baab..55fa106 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -55,11 +55,6 @@ struct switchdev_obj {
 	enum switchdev_trans trans;
 	int (*cb)(struct net_device *dev, struct switchdev_obj *obj);
 	union {
-		struct switchdev_obj_vlan {		/* PORT_VLAN */
-			u16 flags;
-			u16 vid_begin;
-			u16 vid_end;
-		} vlan;
 		struct switchdev_obj_ipv4_fib {		/* IPV4_FIB */
 			u32 dst;
 			int dst_len;
@@ -77,6 +72,14 @@ struct switchdev_obj {
 	} u;
 };
 
+/* SWITCHDEV_OBJ_PORT_VLAN */
+struct switchdev_obj_vlan {
+	struct switchdev_obj obj;	/* must be first */
+	u16 flags;
+	u16 vid_begin;
+	u16 vid_end;
+};
+
 /**
  * struct switchdev_ops - switchdev operations
  *
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 5f5a02b..44e8bc1 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -50,16 +50,14 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 	if (ops->ndo_vlan_rx_add_vid) {
 		err = vlan_vid_add(dev, br->vlan_proto, vid);
 	} else {
-		struct switchdev_obj vlan_obj = {
-			.id = SWITCHDEV_OBJ_PORT_VLAN,
-			.u.vlan = {
-				.flags = flags,
-				.vid_begin = vid,
-				.vid_end = vid,
-			},
+		struct switchdev_obj_vlan vlan = {
+			.obj.id = SWITCHDEV_OBJ_PORT_VLAN,
+			.flags = flags,
+			.vid_begin = vid,
+			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_add(dev, &vlan_obj);
+		err = switchdev_port_obj_add(dev, &vlan.obj);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
@@ -130,15 +128,13 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 	if (ops->ndo_vlan_rx_kill_vid) {
 		vlan_vid_del(dev, br->vlan_proto, vid);
 	} else {
-		struct switchdev_obj vlan_obj = {
-			.id = SWITCHDEV_OBJ_PORT_VLAN,
-			.u.vlan = {
-				.vid_begin = vid,
-				.vid_end = vid,
-			},
+		struct switchdev_obj_vlan vlan = {
+			.obj.id = SWITCHDEV_OBJ_PORT_VLAN,
+			.vid_begin = vid,
+			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_del(dev, &vlan_obj);
+		err = switchdev_port_obj_del(dev, &vlan.obj);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index cce9738..654afc8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -242,15 +242,14 @@ static int dsa_bridge_check_vlan_range(struct dsa_switch *ds,
 }
 
 static int dsa_slave_port_vlan_add(struct net_device *dev,
-				   struct switchdev_obj *obj)
+				   struct switchdev_obj_vlan *vlan)
 {
-	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	u16 vid;
 	int err;
 
-	switch (obj->trans) {
+	switch (vlan->obj.trans) {
 	case SWITCHDEV_TRANS_PREPARE:
 		if (!ds->drv->port_vlan_add || !ds->drv->port_pvid_set)
 			return -EOPNOTSUPP;
@@ -283,9 +282,8 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 }
 
 static int dsa_slave_port_vlan_del(struct net_device *dev,
-				   struct switchdev_obj *obj)
+				   struct switchdev_obj_vlan *vlan)
 {
-	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	u16 vid;
@@ -304,9 +302,8 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
-				    struct switchdev_obj *obj)
+				    struct switchdev_obj_vlan *vlan)
 {
-	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	DECLARE_BITMAP(members, DSA_MAX_PORTS);
@@ -329,7 +326,7 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 		if (!test_bit(p->port, members))
 			continue;
 
-		memset(vlan, 0, sizeof(*vlan));
+		vlan->flags = 0;
 		vlan->vid_begin = vlan->vid_end = vid;
 
 		if (vid == pvid)
@@ -338,7 +335,7 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 		if (test_bit(p->port, untagged))
 			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
-		err = obj->cb(dev, obj);
+		err = vlan->obj.cb(dev, &vlan->obj);
 		if (err)
 			break;
 	}
@@ -476,6 +473,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 static int dsa_slave_port_obj_add(struct net_device *dev,
 				  struct switchdev_obj *obj)
 {
+	struct switchdev_obj_vlan *vlan;
 	int err;
 
 	/* For the prepare phase, ensure the full set of changes is feasable in
@@ -488,7 +486,8 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 		err = dsa_slave_port_fdb_add(dev, obj);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = dsa_slave_port_vlan_add(dev, obj);
+		vlan = (struct switchdev_obj_vlan *) obj;
+		err = dsa_slave_port_vlan_add(dev, vlan);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -501,6 +500,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 static int dsa_slave_port_obj_del(struct net_device *dev,
 				  struct switchdev_obj *obj)
 {
+	struct switchdev_obj_vlan *vlan;
 	int err;
 
 	switch (obj->id) {
@@ -508,7 +508,8 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 		err = dsa_slave_port_fdb_del(dev, obj);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = dsa_slave_port_vlan_del(dev, obj);
+		vlan = (struct switchdev_obj_vlan *) obj;
+		err = dsa_slave_port_vlan_del(dev, vlan);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -521,6 +522,7 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 static int dsa_slave_port_obj_dump(struct net_device *dev,
 				   struct switchdev_obj *obj)
 {
+	struct switchdev_obj_vlan *vlan;
 	int err;
 
 	switch (obj->id) {
@@ -528,7 +530,8 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 		err = dsa_slave_port_fdb_dump(dev, obj);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = dsa_slave_port_vlan_dump(dev, obj);
+		vlan = (struct switchdev_obj_vlan *) obj;
+		err = dsa_slave_port_vlan_dump(dev, vlan);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 16c1c43..9923a97 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -397,7 +397,7 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
 
 struct switchdev_vlan_dump {
-	struct switchdev_obj obj;
+	struct switchdev_obj_vlan vlan;	/* must be first */
 	struct sk_buff *skb;
 	u32 filter_mask;
 	u16 flags;
@@ -439,9 +439,8 @@ static int switchdev_port_vlan_dump_put(struct net_device *dev,
 static int switchdev_port_vlan_dump_cb(struct net_device *dev,
 				       struct switchdev_obj *obj)
 {
-	struct switchdev_vlan_dump *dump =
-		container_of(obj, struct switchdev_vlan_dump, obj);
-	struct switchdev_obj_vlan *vlan = &dump->obj.u.vlan;
+	struct switchdev_vlan_dump *dump = (struct switchdev_vlan_dump *) obj;
+	struct switchdev_obj_vlan *vlan = (struct switchdev_obj_vlan *) obj;
 	int err = 0;
 
 	if (vlan->vid_begin > vlan->vid_end)
@@ -493,7 +492,7 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 				    u32 filter_mask)
 {
 	struct switchdev_vlan_dump dump = {
-		.obj = {
+		.vlan.obj = {
 			.id = SWITCHDEV_OBJ_PORT_VLAN,
 			.cb = switchdev_port_vlan_dump_cb,
 		},
@@ -504,7 +503,7 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 
 	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
 	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
-		err = switchdev_port_obj_dump(dev, &dump.obj);
+		err = switchdev_port_obj_dump(dev, &dump.vlan.obj);
 		if (err)
 			goto err_out;
 		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
@@ -621,10 +620,9 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 {
 	struct nlattr *attr;
 	struct bridge_vlan_info *vinfo;
-	struct switchdev_obj obj = {
-		.id = SWITCHDEV_OBJ_PORT_VLAN,
+	struct switchdev_obj_vlan vlan = {
+		.obj.id = SWITCHDEV_OBJ_PORT_VLAN,
 	};
-	struct switchdev_obj_vlan *vlan = &obj.u.vlan;
 	int rem;
 	int err;
 
@@ -634,30 +632,32 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
 			return -EINVAL;
 		vinfo = nla_data(attr);
-		vlan->flags = vinfo->flags;
+		vlan.flags = vinfo->flags;
 		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
-			if (vlan->vid_begin)
+			if (vlan.vid_begin)
 				return -EINVAL;
-			vlan->vid_begin = vinfo->vid;
+			vlan.vid_begin = vinfo->vid;
 		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
-			if (!vlan->vid_begin)
+			if (!vlan.vid_begin)
 				return -EINVAL;
-			vlan->vid_end = vinfo->vid;
-			if (vlan->vid_end <= vlan->vid_begin)
+			vlan.vid_end = vinfo->vid;
+			if (vlan.vid_end <= vlan.vid_begin)
 				return -EINVAL;
-			err = f(dev, &obj);
+			err = f(dev, &vlan.obj);
 			if (err)
 				return err;
-			memset(vlan, 0, sizeof(*vlan));
+			vlan.flags = 0;
+			vlan.vid_begin = vlan.vid_end = 0;
 		} else {
-			if (vlan->vid_begin)
+			if (vlan.vid_begin)
 				return -EINVAL;
-			vlan->vid_begin = vinfo->vid;
-			vlan->vid_end = vinfo->vid;
-			err = f(dev, &obj);
+			vlan.vid_begin = vinfo->vid;
+			vlan.vid_end = vinfo->vid;
+			err = f(dev, &vlan.obj);
 			if (err)
 				return err;
-			memset(vlan, 0, sizeof(*vlan));
+			vlan.flags = 0;
+			vlan.vid_begin = vlan.vid_end = 0;
 		}
 	}
 
-- 
2.5.1
