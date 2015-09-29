From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next 5/6] net: switchdev: abstract object in add/del ops
Date: Tue, 29 Sep 2015 12:07:17 -0400
Message-ID: <1443542838-19234-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similar to the notifier_call callback of a notifier_block, change the
function signature of switchdev add and del operations to:

    int switchdev_port_obj_add/del(struct net_device *dev,
                                   enum switchdev_obj_id id, void *obj);

This allows the caller to pass a specific switchdev_obj_* structure
instead of the generic switchdev_obj one.

Drivers implementation of these operations and switchdev have been
changed accordingly.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c |  21 +++---
 include/net/switchdev.h              |  18 ++++--
 net/bridge/br_fdb.c                  |  11 ++--
 net/bridge/br_vlan.c                 |  24 +++----
 net/dsa/slave.c                      |  20 +++---
 net/switchdev/switchdev.c            | 122 ++++++++++++++++-------------------
 6 files changed, 99 insertions(+), 117 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 107adb6..9773f5b 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4437,26 +4437,25 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_add(struct net_device *dev,
-			       struct switchdev_obj *obj,
+			       enum switchdev_obj_id id, const void *obj,
 			       struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (obj->id) {
+	switch (id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, trans,
-					    &obj->u.vlan);
+		err = rocker_port_vlans_add(rocker_port, trans, obj);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
-		fib4 = &obj->u.ipv4_fib;
+		fib4 = obj;
 		err = rocker_port_fib_ipv4(rocker_port, trans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, trans, &obj->u.fdb);
+		err = rocker_port_fdb_add(rocker_port, trans, obj);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4509,25 +4508,25 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_del(struct net_device *dev,
-			       struct switchdev_obj *obj)
+			       enum switchdev_obj_id id, const void *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (obj->id) {
+	switch (id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_del(rocker_port, &obj->u.vlan);
+		err = rocker_port_vlans_del(rocker_port, obj);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
-		fib4 = &obj->u.ipv4_fib;
+		fib4 = obj;
 		err = rocker_port_fib_ipv4(rocker_port, NULL,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_del(rocker_port, NULL, &obj->u.fdb);
+		err = rocker_port_fdb_del(rocker_port, NULL, obj);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index a2f57fb..bcadac3 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -115,10 +115,12 @@ struct switchdev_ops {
 					   struct switchdev_attr *attr,
 					   struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_add)(struct net_device *dev,
-					  struct switchdev_obj *obj,
+					  enum switchdev_obj_id id,
+					  const void *obj,
 					  struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_del)(struct net_device *dev,
-					  struct switchdev_obj *obj);
+					  enum switchdev_obj_id id,
+					  const void *obj);
 	int	(*switchdev_port_obj_dump)(struct net_device *dev,
 					   enum switchdev_obj_id id, void *obj,
 					   int (*cb)(void *obj));
@@ -151,8 +153,10 @@ int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
-int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
-int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
+int switchdev_port_obj_add(struct net_device *dev, enum switchdev_obj_id id,
+			   const void *obj);
+int switchdev_port_obj_del(struct net_device *dev, enum switchdev_obj_id id,
+			   const void *obj);
 int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
 			    void *obj, int (*cb)(void *obj));
 int register_switchdev_notifier(struct notifier_block *nb);
@@ -199,13 +203,15 @@ static inline int switchdev_port_attr_set(struct net_device *dev,
 }
 
 static inline int switchdev_port_obj_add(struct net_device *dev,
-					 struct switchdev_obj *obj)
+					 enum switchdev_obj_id id,
+					 const void *obj)
 {
 	return -EOPNOTSUPP;
 }
 
 static inline int switchdev_port_obj_del(struct net_device *dev,
-					 struct switchdev_obj *obj)
+					 enum switchdev_obj_id id,
+					 const void *obj)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 6663cc0..cd593b3 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -133,15 +133,12 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
 
 static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 {
-	struct switchdev_obj obj = {
-		.id = SWITCHDEV_OBJ_PORT_FDB,
-		.u.fdb = {
-			.addr = f->addr.addr,
-			.vid = f->vlan_id,
-		},
+	struct switchdev_obj_fdb fdb = {
+		.addr = f->addr.addr,
+		.vid = f->vlan_id,
 	};
 
-	switchdev_port_obj_del(f->dst->dev, &obj);
+	switchdev_port_obj_del(f->dst->dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
 }
 
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 5f5a02b..c9aac0a 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -50,16 +50,13 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
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
+		struct switchdev_obj_vlan v = {
+			.flags = flags,
+			.vid_begin = vid,
+			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_add(dev, &vlan_obj);
+		err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_PORT_VLAN, &v);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
@@ -130,15 +127,12 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 	if (ops->ndo_vlan_rx_kill_vid) {
 		vlan_vid_del(dev, br->vlan_proto, vid);
 	} else {
-		struct switchdev_obj vlan_obj = {
-			.id = SWITCHDEV_OBJ_PORT_VLAN,
-			.u.vlan = {
-				.vid_begin = vid,
-				.vid_end = vid,
-			},
+		struct switchdev_obj_vlan v = {
+			.vid_begin = vid,
+			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_del(dev, &vlan_obj);
+		err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_PORT_VLAN, &v);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index c3b868c..04f0153 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -242,10 +242,9 @@ static int dsa_bridge_check_vlan_range(struct dsa_switch *ds,
 }
 
 static int dsa_slave_port_vlan_add(struct net_device *dev,
-				   struct switchdev_obj *obj,
+				   const struct switchdev_obj_vlan *vlan,
 				   struct switchdev_trans *trans)
 {
-	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	u16 vid;
@@ -279,9 +278,8 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 }
 
 static int dsa_slave_port_vlan_del(struct net_device *dev,
-				   struct switchdev_obj *obj)
+				   const struct switchdev_obj_vlan *vlan)
 {
-	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	u16 vid;
@@ -343,10 +341,9 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_add(struct net_device *dev,
-				  struct switchdev_obj *obj,
+				  const struct switchdev_obj_fdb *fdb,
 				  struct switchdev_trans *trans)
 {
-	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
@@ -360,9 +357,8 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_del(struct net_device *dev,
-				  struct switchdev_obj *obj)
+				  const struct switchdev_obj_fdb *fdb)
 {
-	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
@@ -473,7 +469,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_add(struct net_device *dev,
-				  struct switchdev_obj *obj,
+				  enum switchdev_obj_id id, const void *obj,
 				  struct switchdev_trans *trans)
 {
 	int err;
@@ -483,7 +479,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	 * supported, return -EOPNOTSUPP.
 	 */
 
-	switch (obj->id) {
+	switch (id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
 		err = dsa_slave_port_fdb_add(dev, obj, trans);
 		break;
@@ -499,11 +495,11 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_del(struct net_device *dev,
-				  struct switchdev_obj *obj)
+				  enum switchdev_obj_id id, const void *obj)
 {
 	int err;
 
-	switch (obj->id) {
+	switch (id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
 		err = dsa_slave_port_fdb_del(dev, obj);
 		break;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 2ef863c..fe82fab 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -270,7 +270,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
 static int __switchdev_port_obj_add(struct net_device *dev,
-				    struct switchdev_obj *obj,
+				    enum switchdev_obj_id id, const void *obj,
 				    struct switchdev_trans *trans)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
@@ -279,7 +279,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_obj_add)
-		return ops->switchdev_port_obj_add(dev, obj, trans);
+		return ops->switchdev_port_obj_add(dev, id, obj, trans);
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to add object on
@@ -287,7 +287,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = __switchdev_port_obj_add(lower_dev, obj, trans);
+		err = __switchdev_port_obj_add(lower_dev, id, obj, trans);
 		if (err)
 			break;
 	}
@@ -299,6 +299,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
  *	switchdev_port_obj_add - Add port object
  *
  *	@dev: port device
+ *	@id: object ID
  *	@obj: object to add
  *
  *	Use a 2-phase prepare-commit transaction model to ensure
@@ -307,7 +308,8 @@ static int __switchdev_port_obj_add(struct net_device *dev,
  *
  *	rtnl_lock must be held.
  */
-int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
+int switchdev_port_obj_add(struct net_device *dev, enum switchdev_obj_id id,
+			   const void *obj)
 {
 	struct switchdev_trans trans;
 	int err;
@@ -324,7 +326,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 */
 
 	trans.ph_prepare = true;
-	err = __switchdev_port_obj_add(dev, obj, &trans);
+	err = __switchdev_port_obj_add(dev, id, obj, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
 		 * resources reserved in the prepare phase are
@@ -343,8 +345,8 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 */
 
 	trans.ph_prepare = false;
-	err = __switchdev_port_obj_add(dev, obj, &trans);
-	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
+	err = __switchdev_port_obj_add(dev, id, obj, &trans);
+	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, id);
 	switchdev_trans_items_warn_destroy(dev, &trans);
 
 	return err;
@@ -355,9 +357,11 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
  *	switchdev_port_obj_del - Delete port object
  *
  *	@dev: port device
+ *	@id: object ID
  *	@obj: object to delete
  */
-int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj)
+int switchdev_port_obj_del(struct net_device *dev, enum switchdev_obj_id id,
+			   const void *obj)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
@@ -365,7 +369,7 @@ int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj)
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_obj_del)
-		return ops->switchdev_port_obj_del(dev, obj);
+		return ops->switchdev_port_obj_del(dev, id, obj);
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to delete object on
@@ -373,7 +377,7 @@ int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj)
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_obj_del(lower_dev, obj);
+		err = switchdev_port_obj_del(lower_dev, id, obj);
 		if (err)
 			break;
 	}
@@ -695,14 +699,12 @@ static int switchdev_port_br_setlink_protinfo(struct net_device *dev,
 static int switchdev_port_br_afspec(struct net_device *dev,
 				    struct nlattr *afspec,
 				    int (*f)(struct net_device *dev,
-					     struct switchdev_obj *obj))
+					     enum switchdev_obj_id id,
+					     const void *obj))
 {
 	struct nlattr *attr;
 	struct bridge_vlan_info *vinfo;
-	struct switchdev_obj obj = {
-		.id = SWITCHDEV_OBJ_PORT_VLAN,
-	};
-	struct switchdev_obj_vlan *vlan = &obj.u.vlan;
+	struct switchdev_obj_vlan vlan = { 0 };
 	int rem;
 	int err;
 
@@ -712,30 +714,30 @@ static int switchdev_port_br_afspec(struct net_device *dev,
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
+			err = f(dev, SWITCHDEV_OBJ_PORT_VLAN, &vlan);
 			if (err)
 				return err;
-			memset(vlan, 0, sizeof(*vlan));
+			memset(&vlan, 0, sizeof(vlan));
 		} else {
-			if (vlan->vid_begin)
+			if (vlan.vid_begin)
 				return -EINVAL;
-			vlan->vid_begin = vinfo->vid;
-			vlan->vid_end = vinfo->vid;
-			err = f(dev, &obj);
+			vlan.vid_begin = vinfo->vid;
+			vlan.vid_end = vinfo->vid;
+			err = f(dev, SWITCHDEV_OBJ_PORT_VLAN, &vlan);
 			if (err)
 				return err;
-			memset(vlan, 0, sizeof(*vlan));
+			memset(&vlan, 0, sizeof(vlan));
 		}
 	}
 
@@ -817,15 +819,12 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev, const unsigned char *addr,
 			   u16 vid, u16 nlm_flags)
 {
-	struct switchdev_obj obj = {
-		.id = SWITCHDEV_OBJ_PORT_FDB,
-		.u.fdb = {
-			.addr = addr,
-			.vid = vid,
-		},
+	struct switchdev_obj_fdb fdb = {
+		.addr = addr,
+		.vid = vid,
 	};
 
-	return switchdev_port_obj_add(dev, &obj);
+	return switchdev_port_obj_add(dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
 
@@ -844,15 +843,12 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev, const unsigned char *addr,
 			   u16 vid)
 {
-	struct switchdev_obj obj = {
-		.id = SWITCHDEV_OBJ_PORT_FDB,
-		.u.fdb = {
-			.addr = addr,
-			.vid = vid,
-		},
+	struct switchdev_obj_fdb fdb = {
+		.addr = addr,
+		.vid = vid,
 	};
 
-	return switchdev_port_obj_del(dev, &obj);
+	return switchdev_port_obj_del(dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
@@ -1009,17 +1005,14 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
-	struct switchdev_obj fib_obj = {
-		.id = SWITCHDEV_OBJ_IPV4_FIB,
-		.u.ipv4_fib = {
-			.dst = dst,
-			.dst_len = dst_len,
-			.fi = fi,
-			.tos = tos,
-			.type = type,
-			.nlflags = nlflags,
-			.tb_id = tb_id,
-		},
+	struct switchdev_obj_ipv4_fib ipv4_fib = {
+		.dst = dst,
+		.dst_len = dst_len,
+		.fi = fi,
+		.tos = tos,
+		.type = type,
+		.nlflags = nlflags,
+		.tb_id = tb_id,
 	};
 	struct net_device *dev;
 	int err = 0;
@@ -1040,7 +1033,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_add(dev, &fib_obj);
+	err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_IPV4_FIB, &ipv4_fib);
 	if (!err)
 		fi->fib_flags |= RTNH_F_OFFLOAD;
 
@@ -1063,17 +1056,14 @@ EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_add);
 int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 tb_id)
 {
-	struct switchdev_obj fib_obj = {
-		.id = SWITCHDEV_OBJ_IPV4_FIB,
-		.u.ipv4_fib = {
-			.dst = dst,
-			.dst_len = dst_len,
-			.fi = fi,
-			.tos = tos,
-			.type = type,
-			.nlflags = 0,
-			.tb_id = tb_id,
-		},
+	struct switchdev_obj_ipv4_fib ipv4_fib = {
+		.dst = dst,
+		.dst_len = dst_len,
+		.fi = fi,
+		.tos = tos,
+		.type = type,
+		.nlflags = 0,
+		.tb_id = tb_id,
 	};
 	struct net_device *dev;
 	int err = 0;
@@ -1085,7 +1075,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_del(dev, &fib_obj);
+	err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_IPV4_FIB, &ipv4_fib);
 	if (!err)
 		fi->fib_flags &= ~RTNH_F_OFFLOAD;
 
-- 
2.6.0
