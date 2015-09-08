From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 3/3] net: switchdev: extract switchdev_obj_fdb
Date: Tue,  8 Sep 2015 16:47:55 -0400
Message-ID: <1441745275-13200-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:41219
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752422AbbIHUtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 16:49:09 -0400
In-Reply-To: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the switchdev_obj_fdb structure out of the switchdev_obj union.

This lightens the switchdev_obj structure and allows drivers to access
the object transaction and callback directly from a switchdev_obj_fdb.
This is more consistent and convenient for add and dump operations.

The patch updates bridge, the Rocker driver and DSA accordingly.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c | 25 ++++++++++++++---------
 include/net/switchdev.h              | 15 +++++++-------
 net/bridge/br_fdb.c                  | 12 +++++------
 net/dsa/slave.c                      | 32 ++++++++++++++++-------------
 net/switchdev/switchdev.c            | 39 ++++++++++++++++--------------------
 5 files changed, 63 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 41aabbc..c3f25a9 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4410,7 +4410,6 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_add(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
@@ -4419,7 +4418,8 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, trans, fdb->addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, fdb->obj.trans, fdb->addr, vlan_id,
+			       flags);
 }
 
 static int rocker_port_obj_add(struct net_device *dev,
@@ -4428,6 +4428,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct switchdev_obj_vlan *vlan;
 	const struct switchdev_obj_ipv4_fib *fib4;
+	const struct switchdev_obj_fdb *fdb;
 	int err = 0;
 
 	switch (obj->trans) {
@@ -4453,7 +4454,8 @@ static int rocker_port_obj_add(struct net_device *dev,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, obj->trans, &obj->u.fdb);
+		fdb = (struct switchdev_obj_fdb *) obj;
+		err = rocker_port_fdb_add(rocker_port, fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4493,7 +4495,6 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_del(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
@@ -4502,7 +4503,8 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, trans, fdb->addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, fdb->obj.trans, fdb->addr, vlan_id,
+			       flags);
 }
 
 static int rocker_port_obj_del(struct net_device *dev,
@@ -4511,6 +4513,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct switchdev_obj_vlan *vlan;
 	const struct switchdev_obj_ipv4_fib *fib4;
+	const struct switchdev_obj_fdb *fdb;
 	int err = 0;
 
 	switch (obj->id) {
@@ -4526,7 +4529,8 @@ static int rocker_port_obj_del(struct net_device *dev,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_del(rocker_port, obj->trans, &obj->u.fdb);
+		fdb = (struct switchdev_obj_fdb *) obj;
+		err = rocker_port_fdb_del(rocker_port, fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4537,10 +4541,9 @@ static int rocker_port_obj_del(struct net_device *dev,
 }
 
 static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
-				struct switchdev_obj *obj)
+				struct switchdev_obj_fdb *fdb)
 {
 	struct rocker *rocker = rocker_port->rocker;
-	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct rocker_fdb_tbl_entry *found;
 	struct hlist_node *tmp;
 	unsigned long lock_flags;
@@ -4555,7 +4558,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 		fdb->ndm_state = NUD_REACHABLE;
 		fdb->vid = rocker_port_vlan_to_vid(rocker_port,
 						   found->key.vlan_id);
-		err = obj->cb(rocker_port->dev, obj);
+		err = fdb->obj.cb(rocker_port->dev, &fdb->obj);
 		if (err)
 			break;
 	}
@@ -4590,11 +4593,13 @@ static int rocker_port_obj_dump(struct net_device *dev,
 {
 	const struct rocker_port *rocker_port = netdev_priv(dev);
 	struct switchdev_obj_vlan *vlan;
+	struct switchdev_obj_fdb *fdb;
 	int err = 0;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_dump(rocker_port, obj);
+		fdb = (struct switchdev_obj_fdb *) obj;
+		err = rocker_port_fdb_dump(rocker_port, fdb);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		vlan = (struct switchdev_obj_vlan *) obj;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 0b76aa8..302f027 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -54,13 +54,6 @@ struct switchdev_obj {
 	enum switchdev_obj_id id;
 	enum switchdev_trans trans;
 	int (*cb)(struct net_device *dev, struct switchdev_obj *obj);
-	union {
-		struct switchdev_obj_fdb {		/* PORT_FDB */
-			const unsigned char *addr;
-			u16 vid;
-			u16 ndm_state;
-		} fdb;
-	} u;
 };
 
 /* SWITCHDEV_OBJ_PORT_VLAN */
@@ -83,6 +76,14 @@ struct switchdev_obj_ipv4_fib {
 	u32 tb_id;
 };
 
+/* SWITCHDEV_OBJ_PORT_FDB */
+struct switchdev_obj_fdb {
+	struct switchdev_obj obj;	/* must be first */
+	const unsigned char *addr;
+	u16 vid;
+	u16 ndm_state;
+};
+
 /**
  * struct switchdev_ops - switchdev operations
  *
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9e9875d..d20d9b9 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -133,15 +133,13 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
 
 static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 {
-	struct switchdev_obj obj = {
-		.id = SWITCHDEV_OBJ_PORT_FDB,
-		.u.fdb = {
-			.addr = f->addr.addr,
-			.vid = f->vlan_id,
-		},
+	struct switchdev_obj_fdb fdb = {
+		.obj.id = SWITCHDEV_OBJ_PORT_FDB,
+		.addr = f->addr.addr,
+		.vid = f->vlan_id,
 	};
 
-	switchdev_port_obj_del(f->dst->dev, &obj);
+	switchdev_port_obj_del(f->dst->dev, &fdb.obj);
 }
 
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 654afc8..d1de9df 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -344,25 +344,23 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_add(struct net_device *dev,
-				  struct switchdev_obj *obj)
+				  struct switchdev_obj_fdb *fdb)
 {
-	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (obj->trans == SWITCHDEV_TRANS_PREPARE)
+	if (fdb->obj.trans == SWITCHDEV_TRANS_PREPARE)
 		ret = ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
-	else if (obj->trans == SWITCHDEV_TRANS_COMMIT)
+	else if (fdb->obj.trans == SWITCHDEV_TRANS_COMMIT)
 		ret = ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
 
 	return ret;
 }
 
 static int dsa_slave_port_fdb_del(struct net_device *dev,
-				  struct switchdev_obj *obj)
+				  struct switchdev_obj_fdb *fdb)
 {
-	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
@@ -374,7 +372,7 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_dump(struct net_device *dev,
-				   struct switchdev_obj *obj)
+				   struct switchdev_obj_fdb *fdb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
@@ -393,11 +391,11 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 		if (ret < 0)
 			break;
 
-		obj->u.fdb.addr = addr;
-		obj->u.fdb.vid = vid;
-		obj->u.fdb.ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
+		fdb->addr = addr;
+		fdb->vid = vid;
+		fdb->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
 
-		ret = obj->cb(dev, obj);
+		ret = fdb->obj.cb(dev, &fdb->obj);
 		if (ret < 0)
 			break;
 	}
@@ -474,6 +472,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 				  struct switchdev_obj *obj)
 {
 	struct switchdev_obj_vlan *vlan;
+	struct switchdev_obj_fdb *fdb;
 	int err;
 
 	/* For the prepare phase, ensure the full set of changes is feasable in
@@ -483,7 +482,8 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = dsa_slave_port_fdb_add(dev, obj);
+		fdb = (struct switchdev_obj_fdb *) obj;
+		err = dsa_slave_port_fdb_add(dev, fdb);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		vlan = (struct switchdev_obj_vlan *) obj;
@@ -501,11 +501,13 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 				  struct switchdev_obj *obj)
 {
 	struct switchdev_obj_vlan *vlan;
+	struct switchdev_obj_fdb *fdb;
 	int err;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = dsa_slave_port_fdb_del(dev, obj);
+		fdb = (struct switchdev_obj_fdb *) obj;
+		err = dsa_slave_port_fdb_del(dev, fdb);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		vlan = (struct switchdev_obj_vlan *) obj;
@@ -523,11 +525,13 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 				   struct switchdev_obj *obj)
 {
 	struct switchdev_obj_vlan *vlan;
+	struct switchdev_obj_fdb *fdb;
 	int err;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = dsa_slave_port_fdb_dump(dev, obj);
+		fdb = (struct switchdev_obj_fdb *) obj;
+		err = dsa_slave_port_fdb_dump(dev, fdb);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		vlan = (struct switchdev_obj_vlan *) obj;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 10fde6f..5349752 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -739,15 +739,13 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
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
+		.obj.id = SWITCHDEV_OBJ_PORT_FDB,
+		.addr = addr,
+		.vid = vid,
 	};
 
-	return switchdev_port_obj_add(dev, &obj);
+	return switchdev_port_obj_add(dev, &fdb.obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
 
@@ -766,20 +764,18 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
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
+		.obj.id = SWITCHDEV_OBJ_PORT_FDB,
+		.addr = addr,
+		.vid = vid,
 	};
 
-	return switchdev_port_obj_del(dev, &obj);
+	return switchdev_port_obj_del(dev, &fdb.obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
 struct switchdev_fdb_dump {
-	struct switchdev_obj obj;
+	struct switchdev_obj_fdb fdb;	/* must be first */
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
 	int idx;
@@ -788,8 +784,7 @@ struct switchdev_fdb_dump {
 static int switchdev_port_fdb_dump_cb(struct net_device *dev,
 				      struct switchdev_obj *obj)
 {
-	struct switchdev_fdb_dump *dump =
-		container_of(obj, struct switchdev_fdb_dump, obj);
+	struct switchdev_fdb_dump *dump = (struct switchdev_fdb_dump *) obj;
 	u32 portid = NETLINK_CB(dump->cb->skb).portid;
 	u32 seq = dump->cb->nlh->nlmsg_seq;
 	struct nlmsghdr *nlh;
@@ -810,12 +805,12 @@ static int switchdev_port_fdb_dump_cb(struct net_device *dev,
 	ndm->ndm_flags   = NTF_SELF;
 	ndm->ndm_type    = 0;
 	ndm->ndm_ifindex = dev->ifindex;
-	ndm->ndm_state   = obj->u.fdb.ndm_state;
+	ndm->ndm_state   = dump->fdb.ndm_state;
 
-	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, obj->u.fdb.addr))
+	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, dump->fdb.addr))
 		goto nla_put_failure;
 
-	if (obj->u.fdb.vid && nla_put_u16(dump->skb, NDA_VLAN, obj->u.fdb.vid))
+	if (dump->fdb.vid && nla_put_u16(dump->skb, NDA_VLAN, dump->fdb.vid))
 		goto nla_put_failure;
 
 	nlmsg_end(dump->skb, nlh);
@@ -845,7 +840,7 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *filter_dev, int idx)
 {
 	struct switchdev_fdb_dump dump = {
-		.obj = {
+		.fdb.obj = {
 			.id = SWITCHDEV_OBJ_PORT_FDB,
 			.cb = switchdev_port_fdb_dump_cb,
 		},
@@ -855,7 +850,7 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	};
 	int err;
 
-	err = switchdev_port_obj_dump(dev, &dump.obj);
+	err = switchdev_port_obj_dump(dev, &dump.fdb.obj);
 	if (err)
 		return err;
 
-- 
2.5.1
