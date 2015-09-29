From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next 4/6] net: switchdev: pass callback to dump operation
Date: Tue, 29 Sep 2015 12:07:16 -0400
Message-ID: <1443542838-19234-5-git-send-email-vivien.didelot@savoirfairelinux.com>
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
function signature of switchdev dump operation to:

    int switchdev_port_obj_dump(struct net_device *dev,
                                enum switchdev_obj_id id, void *obj,
                                int (*cb)(void *obj));

This allows the caller to pass and expect back a specific
switchdev_obj_* structure instead of the generic switchdev_obj one.

Drivers implementation of dump operation can now expect this specific
structure and call the callback with it. Drivers have been changed
accordingly.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c | 21 +++++++++--------
 include/net/switchdev.h              |  9 +++++---
 net/dsa/slave.c                      | 26 +++++++++++----------
 net/switchdev/switchdev.c            | 45 ++++++++++++++++++------------------
 4 files changed, 53 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 78fd443..107adb6 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4538,10 +4538,10 @@ static int rocker_port_obj_del(struct net_device *dev,
 }
 
 static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
-				struct switchdev_obj *obj)
+				struct switchdev_obj_fdb *fdb,
+				int (*cb)(void *obj))
 {
 	struct rocker *rocker = rocker_port->rocker;
-	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct rocker_fdb_tbl_entry *found;
 	struct hlist_node *tmp;
 	unsigned long lock_flags;
@@ -4556,7 +4556,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 		fdb->ndm_state = NUD_REACHABLE;
 		fdb->vid = rocker_port_vlan_to_vid(rocker_port,
 						   found->key.vlan_id);
-		err = obj->cb(obj);
+		err = cb(fdb);
 		if (err)
 			break;
 	}
@@ -4566,9 +4566,9 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
-				 struct switchdev_obj *obj)
+				 struct switchdev_obj_vlan *vlan,
+				int (*cb)(void *obj))
 {
-	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	u16 vid;
 	int err = 0;
 
@@ -4579,7 +4579,7 @@ static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 		if (rocker_vlan_id_is_internal(htons(vid)))
 			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
 		vlan->vid_begin = vlan->vid_end = vid;
-		err = obj->cb(obj);
+		err = cb(vlan);
 		if (err)
 			break;
 	}
@@ -4588,17 +4588,18 @@ static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_dump(struct net_device *dev,
-				struct switchdev_obj *obj)
+				enum switchdev_obj_id id, void *obj,
+				int (*cb)(void *obj))
 {
 	const struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
 
-	switch (obj->id) {
+	switch (id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_dump(rocker_port, obj);
+		err = rocker_port_fdb_dump(rocker_port, obj, cb);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlan_dump(rocker_port, obj);
+		err = rocker_port_vlan_dump(rocker_port, obj, cb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 9ef7c56..a2f57fb 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -120,7 +120,8 @@ struct switchdev_ops {
 	int	(*switchdev_port_obj_del)(struct net_device *dev,
 					  struct switchdev_obj *obj);
 	int	(*switchdev_port_obj_dump)(struct net_device *dev,
-					  struct switchdev_obj *obj);
+					   enum switchdev_obj_id id, void *obj,
+					   int (*cb)(void *obj));
 };
 
 enum switchdev_notifier_type {
@@ -152,7 +153,8 @@ int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
 int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
-int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj);
+int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
+			    void *obj, int (*cb)(void *obj));
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
@@ -209,7 +211,8 @@ static inline int switchdev_port_obj_del(struct net_device *dev,
 }
 
 static inline int switchdev_port_obj_dump(struct net_device *dev,
-					  struct switchdev_obj *obj)
+					  enum switchdev_obj_id id, void *obj,
+					  int (*cb)(void *obj))
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0b47647..c3b868c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -300,9 +300,9 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
-				    struct switchdev_obj *obj)
+				    struct switchdev_obj_vlan *vlan,
+				    int (*cb)(void *obj))
 {
-	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	DECLARE_BITMAP(members, DSA_MAX_PORTS);
@@ -334,7 +334,7 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 		if (test_bit(p->port, untagged))
 			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
-		err = obj->cb(obj);
+		err = cb(vlan);
 		if (err)
 			break;
 	}
@@ -374,7 +374,8 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_dump(struct net_device *dev,
-				   struct switchdev_obj *obj)
+				   struct switchdev_obj_fdb *fdb,
+				   int (*cb)(void *obj))
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
@@ -393,11 +394,11 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 		if (ret < 0)
 			break;
 
-		obj->u.fdb.addr = addr;
-		obj->u.fdb.vid = vid;
-		obj->u.fdb.ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
+		fdb->addr = addr;
+		fdb->vid = vid;
+		fdb->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
 
-		ret = obj->cb(obj);
+		ret = cb(fdb);
 		if (ret < 0)
 			break;
 	}
@@ -518,16 +519,17 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_dump(struct net_device *dev,
-				   struct switchdev_obj *obj)
+				   enum switchdev_obj_id id, void *obj,
+				   int (*cb)(void *obj))
 {
 	int err;
 
-	switch (obj->id) {
+	switch (id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = dsa_slave_port_fdb_dump(dev, obj);
+		err = dsa_slave_port_fdb_dump(dev, obj, cb);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = dsa_slave_port_vlan_dump(dev, obj);
+		err = dsa_slave_port_vlan_dump(dev, obj, cb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 93f4971..2ef863c 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -386,9 +386,12 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
  *	switchdev_port_obj_dump - Dump port objects
  *
  *	@dev: port device
+ *	@id: object ID
  *	@obj: object to dump
+ *	@cb: function to call with a filled object
  */
-int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj)
+int switchdev_port_obj_dump(struct net_device *dev, enum switchdev_obj_id id,
+			    void *obj, int (*cb)(void *obj))
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
@@ -396,7 +399,7 @@ int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj)
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_obj_dump)
-		return ops->switchdev_port_obj_dump(dev, obj);
+		return ops->switchdev_port_obj_dump(dev, id, obj, cb);
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to dump objects on
@@ -404,7 +407,7 @@ int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj)
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_obj_dump(lower_dev, obj);
+		err = switchdev_port_obj_dump(lower_dev, id, obj, cb);
 		break;
 	}
 
@@ -476,7 +479,7 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
 
 struct switchdev_vlan_dump {
-	struct switchdev_obj obj;
+	struct switchdev_obj_vlan vlan;
 	struct sk_buff *skb;
 	u32 filter_mask;
 	u16 flags;
@@ -514,11 +517,11 @@ static int switchdev_port_vlan_dump_put(struct switchdev_vlan_dump *dump)
 	return 0;
 }
 
-static int switchdev_port_vlan_dump_cb(struct switchdev_obj *obj)
+static int switchdev_port_vlan_dump_cb(void *obj)
 {
+	struct switchdev_obj_vlan *vlan = obj;
 	struct switchdev_vlan_dump *dump =
-		container_of(obj, struct switchdev_vlan_dump, obj);
-	struct switchdev_obj_vlan *vlan = &dump->obj.u.vlan;
+		container_of(vlan, struct switchdev_vlan_dump, vlan);
 	int err = 0;
 
 	if (vlan->vid_begin > vlan->vid_end)
@@ -570,10 +573,6 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 				    u32 filter_mask)
 {
 	struct switchdev_vlan_dump dump = {
-		.obj = {
-			.id = SWITCHDEV_OBJ_PORT_VLAN,
-			.cb = switchdev_port_vlan_dump_cb,
-		},
 		.skb = skb,
 		.filter_mask = filter_mask,
 	};
@@ -581,7 +580,9 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 
 	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
 	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
-		err = switchdev_port_obj_dump(dev, &dump.obj);
+		err = switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_PORT_VLAN,
+					      &dump.vlan,
+					      switchdev_port_vlan_dump_cb);
 		if (err)
 			goto err_out;
 		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
@@ -856,17 +857,18 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
 struct switchdev_fdb_dump {
-	struct switchdev_obj obj;
+	struct switchdev_obj_fdb fdb;
 	struct net_device *dev;
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
 	int idx;
 };
 
-static int switchdev_port_fdb_dump_cb(struct switchdev_obj *obj)
+static int switchdev_port_fdb_dump_cb(void *obj)
 {
+	struct switchdev_obj_fdb *fdb = obj;
 	struct switchdev_fdb_dump *dump =
-		container_of(obj, struct switchdev_fdb_dump, obj);
+		container_of(fdb, struct switchdev_fdb_dump, fdb);
 	u32 portid = NETLINK_CB(dump->cb->skb).portid;
 	u32 seq = dump->cb->nlh->nlmsg_seq;
 	struct nlmsghdr *nlh;
@@ -887,12 +889,12 @@ static int switchdev_port_fdb_dump_cb(struct switchdev_obj *obj)
 	ndm->ndm_flags   = NTF_SELF;
 	ndm->ndm_type    = 0;
 	ndm->ndm_ifindex = dump->dev->ifindex;
-	ndm->ndm_state   = obj->u.fdb.ndm_state;
+	ndm->ndm_state   = fdb->ndm_state;
 
-	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, obj->u.fdb.addr))
+	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, fdb->addr))
 		goto nla_put_failure;
 
-	if (obj->u.fdb.vid && nla_put_u16(dump->skb, NDA_VLAN, obj->u.fdb.vid))
+	if (fdb->vid && nla_put_u16(dump->skb, NDA_VLAN, fdb->vid))
 		goto nla_put_failure;
 
 	nlmsg_end(dump->skb, nlh);
@@ -922,17 +924,14 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *filter_dev, int idx)
 {
 	struct switchdev_fdb_dump dump = {
-		.obj = {
-			.id = SWITCHDEV_OBJ_PORT_FDB,
-			.cb = switchdev_port_fdb_dump_cb,
-		},
 		.dev = dev,
 		.skb = skb,
 		.cb = cb,
 		.idx = idx,
 	};
 
-	switchdev_port_obj_dump(dev, &dump.obj);
+	switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_PORT_FDB, &dump.fdb,
+				switchdev_port_fdb_dump_cb);
 	return dump.idx;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
-- 
2.6.0
