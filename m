From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] switchdev: bring back switchdev_obj and use it as a generic object param
Date: Wed, 30 Sep 2015 18:00:15 +0200
Message-ID: <1443628815-25095-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33852 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbbI3QAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 12:00:18 -0400
Received: by wicfx3 with SMTP id fx3so204783536wic.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 09:00:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Replace "void *obj" with a generic structure. Introduce couple of
helpers along that.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 41 +++++++++++++++++++++--------------
 include/net/switchdev.h              | 42 ++++++++++++++++++++++++++----------
 net/bridge/br_fdb.c                  |  2 +-
 net/bridge/br_vlan.c                 |  6 ++++--
 net/dsa/slave.c                      | 35 ++++++++++++++++++------------
 net/switchdev/switchdev.c            | 40 ++++++++++++++++++----------------
 6 files changed, 104 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9773f5b..1236835 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4437,7 +4437,8 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_add(struct net_device *dev,
-			       enum switchdev_obj_id id, const void *obj,
+			       enum switchdev_obj_id id,
+			       const struct switchdev_obj *obj,
 			       struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
@@ -4446,16 +4447,18 @@ static int rocker_port_obj_add(struct net_device *dev,
 
 	switch (id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, trans, obj);
+		err = rocker_port_vlans_add(rocker_port, trans,
+					    SWITCHDEV_OBJ_VLAN(obj));
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
-		fib4 = obj;
+		fib4 = SWITCHDEV_OBJ_IPV4_FIB(obj);
 		err = rocker_port_fib_ipv4(rocker_port, trans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, trans, obj);
+		err = rocker_port_fdb_add(rocker_port, trans,
+					  SWITCHDEV_OBJ_FDB(obj));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4508,7 +4511,8 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_del(struct net_device *dev,
-			       enum switchdev_obj_id id, const void *obj)
+			       enum switchdev_obj_id id,
+			       const struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct switchdev_obj_ipv4_fib *fib4;
@@ -4516,17 +4520,19 @@ static int rocker_port_obj_del(struct net_device *dev,
 
 	switch (id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_del(rocker_port, obj);
+		err = rocker_port_vlans_del(rocker_port,
+					    SWITCHDEV_OBJ_VLAN(obj));
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
-		fib4 = obj;
+		fib4 = SWITCHDEV_OBJ_IPV4_FIB(obj);
 		err = rocker_port_fib_ipv4(rocker_port, NULL,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_del(rocker_port, NULL, obj);
+		err = rocker_port_fdb_del(rocker_port, NULL,
+					  SWITCHDEV_OBJ_FDB(obj));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4538,7 +4544,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 
 static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 				struct switchdev_obj_fdb *fdb,
-				int (*cb)(void *obj))
+				switchdev_obj_dump_cb_t *cb)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_tbl_entry *found;
@@ -4555,7 +4561,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 		fdb->ndm_state = NUD_REACHABLE;
 		fdb->vid = rocker_port_vlan_to_vid(rocker_port,
 						   found->key.vlan_id);
-		err = cb(fdb);
+		err = cb(&fdb->obj);
 		if (err)
 			break;
 	}
@@ -4566,7 +4572,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 
 static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 				 struct switchdev_obj_vlan *vlan,
-				int (*cb)(void *obj))
+				 switchdev_obj_dump_cb_t *cb)
 {
 	u16 vid;
 	int err = 0;
@@ -4578,7 +4584,7 @@ static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 		if (rocker_vlan_id_is_internal(htons(vid)))
 			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
 		vlan->vid_begin = vlan->vid_end = vid;
-		err = cb(vlan);
+		err = cb(&vlan->obj);
 		if (err)
 			break;
 	}
@@ -4587,18 +4593,21 @@ static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_dump(struct net_device *dev,
-				enum switchdev_obj_id id, void *obj,
-				int (*cb)(void *obj))
+				enum switchdev_obj_id id,
+				struct switchdev_obj *obj,
+				switchdev_obj_dump_cb_t *cb)
 {
 	const struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
 
 	switch (id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_dump(rocker_port, obj, cb);
+		err = rocker_port_fdb_dump(rocker_port,
+					   SWITCHDEV_OBJ_FDB(obj), cb);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlan_dump(rocker_port, obj, cb);
+		err = rocker_port_vlan_dump(rocker_port,
+					    SWITCHDEV_OBJ_VLAN(obj), cb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index e11425e..a79a7f0 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -64,15 +64,23 @@ enum switchdev_obj_id {
 	SWITCHDEV_OBJ_PORT_FDB,
 };
 
+struct switchdev_obj {
+};
+
 /* SWITCHDEV_OBJ_PORT_VLAN */
 struct switchdev_obj_vlan {
+	struct switchdev_obj obj;
 	u16 flags;
 	u16 vid_begin;
 	u16 vid_end;
 };
 
+#define SWITCHDEV_OBJ_VLAN(obj) \
+	container_of(obj, struct switchdev_obj_vlan, obj)
+
 /* SWITCHDEV_OBJ_IPV4_FIB */
 struct switchdev_obj_ipv4_fib {
+	struct switchdev_obj obj;
 	u32 dst;
 	int dst_len;
 	struct fib_info *fi;
@@ -82,18 +90,27 @@ struct switchdev_obj_ipv4_fib {
 	u32 tb_id;
 };
 
+#define SWITCHDEV_OBJ_IPV4_FIB(obj) \
+	container_of(obj, struct switchdev_obj_ipv4_fib, obj)
+
 /* SWITCHDEV_OBJ_PORT_FDB */
 struct switchdev_obj_fdb {
+	struct switchdev_obj obj;
 	const unsigned char *addr;
 	u16 vid;
 	u16 ndm_state;
 };
 
+#define SWITCHDEV_OBJ_FDB(obj) \
+	container_of(obj, struct switchdev_obj_fdb, obj)
+
 void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
 				  void *data, void (*destructor)(void const *),
 				  struct switchdev_trans_item *tritem);
 void *switchdev_trans_item_dequeue(struct switchdev_trans *trans);
 
+typedef int switchdev_obj_dump_cb_t(struct switchdev_obj *obj);
+
 /**
  * struct switchdev_ops - switchdev operations
  *
@@ -115,14 +132,15 @@ struct switchdev_ops {
 					   struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_add)(struct net_device *dev,
 					  enum switchdev_obj_id id,
-					  const void *obj,
+					  const struct switchdev_obj *obj,
 					  struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_del)(struct net_device *dev,
 					  enum switchdev_obj_id id,
-					  const void *obj);
+					  const struct switchdev_obj *obj);
 	int	(*switchdev_port_obj_dump)(struct net_device *dev,
-					   enum switchdev_obj_id id, void *obj,
-					   int (*cb)(void *obj));
+					   enum switchdev_obj_id id,
+					   struct switchdev_obj *obj,
+					   switchdev_obj_dump_cb_t *cb);
 };
 
 enum switchdev_notifier_type {
@@ -153,11 +171,12 @@ int switchdev_port_attr_get(struct net_device *dev,
 int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_obj_add(struct net_device *dev, enum switchdev_obj_id id,
-			   const void *obj);
+			   const struct switchdev_obj *obj);
 int switchdev_port_obj_del(struct net_device *dev, enum switchdev_obj_id id,
-			   const void *obj);
+			   const struct switchdev_obj *obj);
 int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
-			    void *obj, int (*cb)(void *obj));
+			    const struct switchdev_obj *obj,
+			    switchdev_obj_dump_cb_t *cb);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
@@ -203,21 +222,22 @@ static inline int switchdev_port_attr_set(struct net_device *dev,
 
 static inline int switchdev_port_obj_add(struct net_device *dev,
 					 enum switchdev_obj_id id,
-					 const void *obj)
+					 const struct switchdev_obj *obj)
 {
 	return -EOPNOTSUPP;
 }
 
 static inline int switchdev_port_obj_del(struct net_device *dev,
 					 enum switchdev_obj_id id,
-					 const void *obj)
+					 const struct switchdev_obj *obj)
 {
 	return -EOPNOTSUPP;
 }
 
 static inline int switchdev_port_obj_dump(struct net_device *dev,
-					  enum switchdev_obj_id id, void *obj,
-					  int (*cb)(void *obj))
+					  enum switchdev_obj_id id,
+					  const struct switchdev_obj *obj,
+					  switchdev_obj_dump_cb_t *cb)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 7826782d..6a01858 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -138,7 +138,7 @@ static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 		.vid = f->vlan_id,
 	};
 
-	switchdev_port_obj_del(f->dst->dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
+	switchdev_port_obj_del(f->dst->dev, SWITCHDEV_OBJ_PORT_FDB, &fdb.obj);
 }
 
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index e227164..04dee44 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -86,7 +86,8 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_PORT_VLAN, &v);
+		err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_PORT_VLAN,
+					     &v.obj);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
@@ -134,7 +135,8 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_PORT_VLAN, &v);
+		err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_PORT_VLAN,
+					     &v.obj);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7b1d9ec..964b66e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -299,7 +299,7 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
 				    struct switchdev_obj_vlan *vlan,
-				    int (*cb)(void *obj))
+				    switchdev_obj_dump_cb_t *cb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
@@ -332,7 +332,7 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 		if (test_bit(p->port, untagged))
 			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
-		err = cb(vlan);
+		err = cb(&vlan->obj);
 		if (err)
 			break;
 	}
@@ -371,7 +371,7 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 
 static int dsa_slave_port_fdb_dump(struct net_device *dev,
 				   struct switchdev_obj_fdb *fdb,
-				   int (*cb)(void *obj))
+				   switchdev_obj_dump_cb_t *cb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
@@ -394,7 +394,7 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 		fdb->vid = vid;
 		fdb->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
 
-		ret = cb(fdb);
+		ret = cb(&fdb->obj);
 		if (ret < 0)
 			break;
 	}
@@ -474,7 +474,8 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_add(struct net_device *dev,
-				  enum switchdev_obj_id id, const void *obj,
+				  enum switchdev_obj_id id,
+				  const struct switchdev_obj *obj,
 				  struct switchdev_trans *trans)
 {
 	int err;
@@ -486,10 +487,12 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 
 	switch (id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = dsa_slave_port_fdb_add(dev, obj, trans);
+		err = dsa_slave_port_fdb_add(dev, SWITCHDEV_OBJ_FDB(obj),
+					     trans);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = dsa_slave_port_vlan_add(dev, obj, trans);
+		err = dsa_slave_port_vlan_add(dev, SWITCHDEV_OBJ_VLAN(obj),
+					      trans);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -500,16 +503,17 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_del(struct net_device *dev,
-				  enum switchdev_obj_id id, const void *obj)
+				  enum switchdev_obj_id id,
+				  const struct switchdev_obj *obj)
 {
 	int err;
 
 	switch (id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = dsa_slave_port_fdb_del(dev, obj);
+		err = dsa_slave_port_fdb_del(dev, SWITCHDEV_OBJ_FDB(obj));
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = dsa_slave_port_vlan_del(dev, obj);
+		err = dsa_slave_port_vlan_del(dev, SWITCHDEV_OBJ_VLAN(obj));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -520,17 +524,20 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_dump(struct net_device *dev,
-				   enum switchdev_obj_id id, void *obj,
-				   int (*cb)(void *obj))
+				   enum switchdev_obj_id id,
+				   struct switchdev_obj *obj,
+				   switchdev_obj_dump_cb_t *cb)
 {
 	int err;
 
 	switch (id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = dsa_slave_port_fdb_dump(dev, obj, cb);
+		err = dsa_slave_port_fdb_dump(dev, SWITCHDEV_OBJ_FDB(obj),
+					      cb);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = dsa_slave_port_vlan_dump(dev, obj, cb);
+		err = dsa_slave_port_vlan_dump(dev, SWITCHDEV_OBJ_VLAN(obj),
+					       cb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index fe82fab..e67a418 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -270,7 +270,8 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
 static int __switchdev_port_obj_add(struct net_device *dev,
-				    enum switchdev_obj_id id, const void *obj,
+				    enum switchdev_obj_id id,
+				    const struct switchdev_obj *obj,
 				    struct switchdev_trans *trans)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
@@ -309,7 +310,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
  *	rtnl_lock must be held.
  */
 int switchdev_port_obj_add(struct net_device *dev, enum switchdev_obj_id id,
-			   const void *obj)
+			   const struct switchdev_obj *obj)
 {
 	struct switchdev_trans trans;
 	int err;
@@ -361,7 +362,7 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
  *	@obj: object to delete
  */
 int switchdev_port_obj_del(struct net_device *dev, enum switchdev_obj_id id,
-			   const void *obj)
+			   const struct switchdev_obj *obj)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
@@ -395,7 +396,8 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
  *	@cb: function to call with a filled object
  */
 int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
-			    void *obj, int (*cb)(void *obj))
+			    const struct switchdev_obj *obj,
+			    switchdev_obj_dump_cb_t *cb)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
@@ -521,9 +523,9 @@ static int switchdev_port_vlan_dump_put(struct switchdev_vlan_dump *dump)
 	return 0;
 }
 
-static int switchdev_port_vlan_dump_cb(void *obj)
+static int switchdev_port_vlan_dump_cb(struct switchdev_obj *obj)
 {
-	struct switchdev_obj_vlan *vlan = obj;
+	struct switchdev_obj_vlan *vlan = SWITCHDEV_OBJ_VLAN(obj);
 	struct switchdev_vlan_dump *dump =
 		container_of(vlan, struct switchdev_vlan_dump, vlan);
 	int err = 0;
@@ -585,7 +587,7 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
 	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
 		err = switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_PORT_VLAN,
-					      &dump.vlan,
+					      &dump.vlan.obj,
 					      switchdev_port_vlan_dump_cb);
 		if (err)
 			goto err_out;
@@ -700,11 +702,11 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 				    struct nlattr *afspec,
 				    int (*f)(struct net_device *dev,
 					     enum switchdev_obj_id id,
-					     const void *obj))
+					     const struct switchdev_obj *obj))
 {
 	struct nlattr *attr;
 	struct bridge_vlan_info *vinfo;
-	struct switchdev_obj_vlan vlan = { 0 };
+	struct switchdev_obj_vlan vlan = { {}, 0 };
 	int rem;
 	int err;
 
@@ -725,7 +727,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 			vlan.vid_end = vinfo->vid;
 			if (vlan.vid_end <= vlan.vid_begin)
 				return -EINVAL;
-			err = f(dev, SWITCHDEV_OBJ_PORT_VLAN, &vlan);
+			err = f(dev, SWITCHDEV_OBJ_PORT_VLAN, &vlan.obj);
 			if (err)
 				return err;
 			memset(&vlan, 0, sizeof(vlan));
@@ -734,7 +736,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 				return -EINVAL;
 			vlan.vid_begin = vinfo->vid;
 			vlan.vid_end = vinfo->vid;
-			err = f(dev, SWITCHDEV_OBJ_PORT_VLAN, &vlan);
+			err = f(dev, SWITCHDEV_OBJ_PORT_VLAN, &vlan.obj);
 			if (err)
 				return err;
 			memset(&vlan, 0, sizeof(vlan));
@@ -824,7 +826,7 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		.vid = vid,
 	};
 
-	return switchdev_port_obj_add(dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
+	return switchdev_port_obj_add(dev, SWITCHDEV_OBJ_PORT_FDB, &fdb.obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
 
@@ -848,7 +850,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 		.vid = vid,
 	};
 
-	return switchdev_port_obj_del(dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
+	return switchdev_port_obj_del(dev, SWITCHDEV_OBJ_PORT_FDB, &fdb.obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
@@ -860,9 +862,9 @@ struct switchdev_fdb_dump {
 	int idx;
 };
 
-static int switchdev_port_fdb_dump_cb(void *obj)
+static int switchdev_port_fdb_dump_cb(struct switchdev_obj *obj)
 {
-	struct switchdev_obj_fdb *fdb = obj;
+	struct switchdev_obj_fdb *fdb = SWITCHDEV_OBJ_FDB(obj);
 	struct switchdev_fdb_dump *dump =
 		container_of(fdb, struct switchdev_fdb_dump, fdb);
 	u32 portid = NETLINK_CB(dump->cb->skb).portid;
@@ -926,7 +928,7 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		.idx = idx,
 	};
 
-	switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_PORT_FDB, &dump.fdb,
+	switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_PORT_FDB, &dump.fdb.obj,
 				switchdev_port_fdb_dump_cb);
 	return dump.idx;
 }
@@ -1033,7 +1035,8 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_IPV4_FIB, &ipv4_fib);
+	err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_IPV4_FIB,
+				     &ipv4_fib.obj);
 	if (!err)
 		fi->fib_flags |= RTNH_F_OFFLOAD;
 
@@ -1075,7 +1078,8 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_IPV4_FIB, &ipv4_fib);
+	err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_IPV4_FIB,
+				     &ipv4_fib.obj);
 	if (!err)
 		fi->fib_flags &= ~RTNH_F_OFFLOAD;
 
-- 
1.9.3
