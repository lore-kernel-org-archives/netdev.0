From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/6] switchdev: push object ID back to object structure
Date: Thu,  1 Oct 2015 11:03:46 +0200
Message-ID: <1443690226-29833-7-git-send-email-jiri@resnulli.us>
References: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35920 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755375AbbJAJD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 05:03:56 -0400
Received: by wicgb1 with SMTP id gb1so19214048wic.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 02:03:55 -0700 (PDT)
In-Reply-To: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Suggested-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c |  9 ++----
 include/net/switchdev.h              | 14 +++------
 net/bridge/br_fdb.c                  |  4 +--
 net/bridge/br_vlan.c                 |  8 ++---
 net/dsa/slave.c                      |  9 ++----
 net/switchdev/switchdev.c            | 57 ++++++++++++++++++------------------
 6 files changed, 45 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2a577e5..cf91ffc 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4437,7 +4437,6 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_add(struct net_device *dev,
-			       enum switchdev_obj_id id,
 			       const struct switchdev_obj *obj,
 			       struct switchdev_trans *trans)
 {
@@ -4445,7 +4444,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (id) {
+	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, trans,
 					    SWITCHDEV_OBJ_PORT_VLAN(obj));
@@ -4511,14 +4510,13 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_del(struct net_device *dev,
-			       enum switchdev_obj_id id,
 			       const struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (id) {
+	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = rocker_port_vlans_del(rocker_port,
 					    SWITCHDEV_OBJ_PORT_VLAN(obj));
@@ -4593,14 +4591,13 @@ static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_dump(struct net_device *dev,
-				enum switchdev_obj_id id,
 				struct switchdev_obj *obj,
 				switchdev_obj_dump_cb_t *cb)
 {
 	const struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
 
-	switch (id) {
+	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_port_fdb_dump(rocker_port,
 					   SWITCHDEV_OBJ_PORT_FDB(obj), cb);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 3e1bd14..89266a3 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -65,6 +65,7 @@ enum switchdev_obj_id {
 };
 
 struct switchdev_obj {
+	enum switchdev_obj_id id;
 };
 
 /* SWITCHDEV_OBJ_ID_PORT_VLAN */
@@ -131,14 +132,11 @@ struct switchdev_ops {
 					   struct switchdev_attr *attr,
 					   struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_add)(struct net_device *dev,
-					  enum switchdev_obj_id id,
 					  const struct switchdev_obj *obj,
 					  struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_del)(struct net_device *dev,
-					  enum switchdev_obj_id id,
 					  const struct switchdev_obj *obj);
 	int	(*switchdev_port_obj_dump)(struct net_device *dev,
-					   enum switchdev_obj_id id,
 					   struct switchdev_obj *obj,
 					   switchdev_obj_dump_cb_t *cb);
 };
@@ -170,12 +168,11 @@ int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
-int switchdev_port_obj_add(struct net_device *dev, enum switchdev_obj_id id,
+int switchdev_port_obj_add(struct net_device *dev,
 			   const struct switchdev_obj *obj);
-int switchdev_port_obj_del(struct net_device *dev, enum switchdev_obj_id id,
+int switchdev_port_obj_del(struct net_device *dev,
 			   const struct switchdev_obj *obj);
-int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
-			    struct switchdev_obj *obj,
+int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 			    switchdev_obj_dump_cb_t *cb);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
@@ -221,21 +218,18 @@ static inline int switchdev_port_attr_set(struct net_device *dev,
 }
 
 static inline int switchdev_port_obj_add(struct net_device *dev,
-					 enum switchdev_obj_id id,
 					 const struct switchdev_obj *obj)
 {
 	return -EOPNOTSUPP;
 }
 
 static inline int switchdev_port_obj_del(struct net_device *dev,
-					 enum switchdev_obj_id id,
 					 const struct switchdev_obj *obj)
 {
 	return -EOPNOTSUPP;
 }
 
 static inline int switchdev_port_obj_dump(struct net_device *dev,
-					  enum switchdev_obj_id id,
 					  const struct switchdev_obj *obj,
 					  switchdev_obj_dump_cb_t *cb)
 {
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 34b62df..7f7d551 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -134,12 +134,12 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
 static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 {
 	struct switchdev_obj_port_fdb fdb = {
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
 		.addr = f->addr.addr,
 		.vid = f->vlan_id,
 	};
 
-	switchdev_port_obj_del(f->dst->dev, SWITCHDEV_OBJ_ID_PORT_FDB,
-			       &fdb.obj);
+	switchdev_port_obj_del(f->dst->dev, &fdb.obj);
 }
 
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 0995e28..e754b5d 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -81,13 +81,13 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 		err = vlan_vid_add(dev, br->vlan_proto, vid);
 	} else {
 		struct switchdev_obj_port_vlan v = {
+			.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
 			.flags = flags,
 			.vid_begin = vid,
 			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_ID_PORT_VLAN,
-					     &v.obj);
+		err = switchdev_port_obj_add(dev, &v.obj);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
@@ -131,12 +131,12 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 		vlan_vid_del(dev, br->vlan_proto, vid);
 	} else {
 		struct switchdev_obj_port_vlan v = {
+			.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
 			.vid_begin = vid,
 			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_ID_PORT_VLAN,
-					     &v.obj);
+		err = switchdev_port_obj_del(dev, &v.obj);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3f6d79d..5f65f92 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -474,7 +474,6 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_add(struct net_device *dev,
-				  enum switchdev_obj_id id,
 				  const struct switchdev_obj *obj,
 				  struct switchdev_trans *trans)
 {
@@ -485,7 +484,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	 * supported, return -EOPNOTSUPP.
 	 */
 
-	switch (id) {
+	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = dsa_slave_port_fdb_add(dev,
 					     SWITCHDEV_OBJ_PORT_FDB(obj),
@@ -505,12 +504,11 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_del(struct net_device *dev,
-				  enum switchdev_obj_id id,
 				  const struct switchdev_obj *obj)
 {
 	int err;
 
-	switch (id) {
+	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = dsa_slave_port_fdb_del(dev,
 					     SWITCHDEV_OBJ_PORT_FDB(obj));
@@ -528,13 +526,12 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_dump(struct net_device *dev,
-				   enum switchdev_obj_id id,
 				   struct switchdev_obj *obj,
 				   switchdev_obj_dump_cb_t *cb)
 {
 	int err;
 
-	switch (id) {
+	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = dsa_slave_port_fdb_dump(dev,
 					      SWITCHDEV_OBJ_PORT_FDB(obj),
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 0402b36..6e4a4f9 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -270,7 +270,6 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
 static int __switchdev_port_obj_add(struct net_device *dev,
-				    enum switchdev_obj_id id,
 				    const struct switchdev_obj *obj,
 				    struct switchdev_trans *trans)
 {
@@ -280,7 +279,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_obj_add)
-		return ops->switchdev_port_obj_add(dev, id, obj, trans);
+		return ops->switchdev_port_obj_add(dev, obj, trans);
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to add object on
@@ -288,7 +287,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = __switchdev_port_obj_add(lower_dev, id, obj, trans);
+		err = __switchdev_port_obj_add(lower_dev, obj, trans);
 		if (err)
 			break;
 	}
@@ -309,7 +308,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
  *
  *	rtnl_lock must be held.
  */
-int switchdev_port_obj_add(struct net_device *dev, enum switchdev_obj_id id,
+int switchdev_port_obj_add(struct net_device *dev,
 			   const struct switchdev_obj *obj)
 {
 	struct switchdev_trans trans;
@@ -327,7 +326,7 @@ int switchdev_port_obj_add(struct net_device *dev, enum switchdev_obj_id id,
 	 */
 
 	trans.ph_prepare = true;
-	err = __switchdev_port_obj_add(dev, id, obj, &trans);
+	err = __switchdev_port_obj_add(dev, obj, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
 		 * resources reserved in the prepare phase are
@@ -346,8 +345,8 @@ int switchdev_port_obj_add(struct net_device *dev, enum switchdev_obj_id id,
 	 */
 
 	trans.ph_prepare = false;
-	err = __switchdev_port_obj_add(dev, id, obj, &trans);
-	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, id);
+	err = __switchdev_port_obj_add(dev, obj, &trans);
+	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
 	switchdev_trans_items_warn_destroy(dev, &trans);
 
 	return err;
@@ -361,7 +360,7 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
  *	@id: object ID
  *	@obj: object to delete
  */
-int switchdev_port_obj_del(struct net_device *dev, enum switchdev_obj_id id,
+int switchdev_port_obj_del(struct net_device *dev,
 			   const struct switchdev_obj *obj)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
@@ -370,7 +369,7 @@ int switchdev_port_obj_del(struct net_device *dev, enum switchdev_obj_id id,
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_obj_del)
-		return ops->switchdev_port_obj_del(dev, id, obj);
+		return ops->switchdev_port_obj_del(dev, obj);
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to delete object on
@@ -378,7 +377,7 @@ int switchdev_port_obj_del(struct net_device *dev, enum switchdev_obj_id id,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_obj_del(lower_dev, id, obj);
+		err = switchdev_port_obj_del(lower_dev, obj);
 		if (err)
 			break;
 	}
@@ -395,8 +394,7 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
  *	@obj: object to dump
  *	@cb: function to call with a filled object
  */
-int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
-			    struct switchdev_obj *obj,
+int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 			    switchdev_obj_dump_cb_t *cb)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
@@ -405,7 +403,7 @@ int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_obj_dump)
-		return ops->switchdev_port_obj_dump(dev, id, obj, cb);
+		return ops->switchdev_port_obj_dump(dev, obj, cb);
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to dump objects on
@@ -413,7 +411,7 @@ int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_obj_dump(lower_dev, id, obj, cb);
+		err = switchdev_port_obj_dump(lower_dev, obj, cb);
 		break;
 	}
 
@@ -579,6 +577,7 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 				    u32 filter_mask)
 {
 	struct switchdev_vlan_dump dump = {
+		.vlan.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
 		.skb = skb,
 		.filter_mask = filter_mask,
 	};
@@ -586,8 +585,7 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 
 	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
 	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
-		err = switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_ID_PORT_VLAN,
-					      &dump.vlan.obj,
+		err = switchdev_port_obj_dump(dev, &dump.vlan.obj,
 					      switchdev_port_vlan_dump_cb);
 		if (err)
 			goto err_out;
@@ -701,12 +699,13 @@ static int switchdev_port_br_setlink_protinfo(struct net_device *dev,
 static int switchdev_port_br_afspec(struct net_device *dev,
 				    struct nlattr *afspec,
 				    int (*f)(struct net_device *dev,
-					     enum switchdev_obj_id id,
 					     const struct switchdev_obj *obj))
 {
 	struct nlattr *attr;
 	struct bridge_vlan_info *vinfo;
-	struct switchdev_obj_port_vlan vlan = { {}, 0 };
+	struct switchdev_obj_port_vlan vlan = {
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
+	};
 	int rem;
 	int err;
 
@@ -727,7 +726,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 			vlan.vid_end = vinfo->vid;
 			if (vlan.vid_end <= vlan.vid_begin)
 				return -EINVAL;
-			err = f(dev, SWITCHDEV_OBJ_ID_PORT_VLAN, &vlan.obj);
+			err = f(dev, &vlan.obj);
 			if (err)
 				return err;
 			memset(&vlan, 0, sizeof(vlan));
@@ -736,7 +735,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 				return -EINVAL;
 			vlan.vid_begin = vinfo->vid;
 			vlan.vid_end = vinfo->vid;
-			err = f(dev, SWITCHDEV_OBJ_ID_PORT_VLAN, &vlan.obj);
+			err = f(dev, &vlan.obj);
 			if (err)
 				return err;
 			memset(&vlan, 0, sizeof(vlan));
@@ -822,11 +821,12 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			   u16 vid, u16 nlm_flags)
 {
 	struct switchdev_obj_port_fdb fdb = {
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
 		.addr = addr,
 		.vid = vid,
 	};
 
-	return switchdev_port_obj_add(dev, SWITCHDEV_OBJ_ID_PORT_FDB, &fdb.obj);
+	return switchdev_port_obj_add(dev, &fdb.obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
 
@@ -846,11 +846,12 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   u16 vid)
 {
 	struct switchdev_obj_port_fdb fdb = {
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
 		.addr = addr,
 		.vid = vid,
 	};
 
-	return switchdev_port_obj_del(dev, SWITCHDEV_OBJ_ID_PORT_FDB, &fdb.obj);
+	return switchdev_port_obj_del(dev, &fdb.obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
@@ -922,14 +923,14 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *filter_dev, int idx)
 {
 	struct switchdev_fdb_dump dump = {
+		.fdb.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
 		.dev = dev,
 		.skb = skb,
 		.cb = cb,
 		.idx = idx,
 	};
 
-	switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_ID_PORT_FDB, &dump.fdb.obj,
-				switchdev_port_fdb_dump_cb);
+	switchdev_port_obj_dump(dev, &dump.fdb.obj, switchdev_port_fdb_dump_cb);
 	return dump.idx;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
@@ -1008,6 +1009,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
 	struct switchdev_obj_ipv4_fib ipv4_fib = {
+		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
 		.dst = dst,
 		.dst_len = dst_len,
 		.fi = fi,
@@ -1035,8 +1037,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_ID_IPV4_FIB,
-				     &ipv4_fib.obj);
+	err = switchdev_port_obj_add(dev, &ipv4_fib.obj);
 	if (!err)
 		fi->fib_flags |= RTNH_F_OFFLOAD;
 
@@ -1060,6 +1061,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 tb_id)
 {
 	struct switchdev_obj_ipv4_fib ipv4_fib = {
+		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
 		.dst = dst,
 		.dst_len = dst_len,
 		.fi = fi,
@@ -1078,8 +1080,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_ID_IPV4_FIB,
-				     &ipv4_fib.obj);
+	err = switchdev_port_obj_del(dev, &ipv4_fib.obj);
 	if (!err)
 		fi->fib_flags &= ~RTNH_F_OFFLOAD;
 
-- 
1.9.3
