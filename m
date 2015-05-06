From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [PATCH net-next] switchdev: add support for fdb add/del/dump via switchdev_port_obj ops.
Date: Wed,  6 May 2015 14:54:13 -0700
Message-ID: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com>
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9751 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868AbbEFVxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 17:53:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- introduce port fdb obj and generic switchdev_port_fdb_add/del/dump()
- use switchdev_port_fdb_add/del/dump in rocker/team/bonding ndo ops.
- add support for fdb obj in switchdev_port_obj_add/del/dump()
- switch rocker to implement fdb ops via switchdev_ops

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/bonding/bond_main.c      |   3 +
 drivers/net/ethernet/rocker/rocker.c | 183 +++++++++++++++--------------------
 drivers/net/team/team.c              |   3 +
 include/net/switchdev.h              |  50 ++++++++++
 net/switchdev/switchdev.c            | 175 +++++++++++++++++++++++++++++++++
 5 files changed, 309 insertions(+), 105 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5215e63..f63d078 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4039,6 +4039,9 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
+	.ndo_fdb_add		= switchdev_port_fdb_add,
+	.ndo_fdb_del		= switchdev_port_fdb_del,
+	.ndo_fdb_dump		= switchdev_port_fdb_dump,
 	.ndo_features_check	= passthru_features_check,
 };
 
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index e9ee372..ba9011e 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4153,108 +4153,6 @@ static int rocker_port_vlan_rx_kill_vid(struct net_device *dev,
 	return rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, vid);
 }
 
-static int rocker_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
-			       struct net_device *dev,
-			       const unsigned char *addr, u16 vid,
-			       u16 nlm_flags)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, NULL);
-	int flags = 0;
-
-	if (!rocker_port_is_bridged(rocker_port))
-		return -EINVAL;
-
-	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
-}
-
-static int rocker_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
-			       struct net_device *dev,
-			       const unsigned char *addr, u16 vid)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, NULL);
-	int flags = ROCKER_OP_FLAG_REMOVE;
-
-	if (!rocker_port_is_bridged(rocker_port))
-		return -EINVAL;
-
-	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
-}
-
-static int rocker_fdb_fill_info(struct sk_buff *skb,
-				struct rocker_port *rocker_port,
-				const unsigned char *addr, u16 vid,
-				u32 portid, u32 seq, int type,
-				unsigned int flags)
-{
-	struct nlmsghdr *nlh;
-	struct ndmsg *ndm;
-
-	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*ndm), flags);
-	if (!nlh)
-		return -EMSGSIZE;
-
-	ndm = nlmsg_data(nlh);
-	ndm->ndm_family	 = AF_BRIDGE;
-	ndm->ndm_pad1    = 0;
-	ndm->ndm_pad2    = 0;
-	ndm->ndm_flags	 = NTF_SELF;
-	ndm->ndm_type	 = 0;
-	ndm->ndm_ifindex = rocker_port->dev->ifindex;
-	ndm->ndm_state   = NUD_REACHABLE;
-
-	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, addr))
-		goto nla_put_failure;
-
-	if (vid && nla_put_u16(skb, NDA_VLAN, vid))
-		goto nla_put_failure;
-
-	nlmsg_end(skb, nlh);
-	return 0;
-
-nla_put_failure:
-	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
-}
-
-static int rocker_port_fdb_dump(struct sk_buff *skb,
-				struct netlink_callback *cb,
-				struct net_device *dev,
-				struct net_device *filter_dev,
-				int idx)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_fdb_tbl_entry *found;
-	struct hlist_node *tmp;
-	int bkt;
-	unsigned long lock_flags;
-	const unsigned char *addr;
-	u16 vid;
-	int err;
-
-	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
-	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
-		if (found->key.pport != rocker_port->pport)
-			continue;
-		if (idx < cb->args[0])
-			goto skip;
-		addr = found->key.addr;
-		vid = rocker_port_vlan_to_vid(rocker_port, found->key.vlan_id);
-		err = rocker_fdb_fill_info(skb, rocker_port, addr, vid,
-					   NETLINK_CB(cb->skb).portid,
-					   cb->nlh->nlmsg_seq,
-					   RTM_NEWNEIGH, NLM_F_MULTI);
-		if (err < 0)
-			break;
-skip:
-		++idx;
-	}
-	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
-	return idx;
-}
-
 static int rocker_port_get_phys_port_name(struct net_device *dev,
 					  char *buf, size_t len)
 {
@@ -4277,12 +4175,12 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_set_mac_address		= rocker_port_set_mac_address,
 	.ndo_vlan_rx_add_vid		= rocker_port_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
-	.ndo_fdb_add			= rocker_port_fdb_add,
-	.ndo_fdb_del			= rocker_port_fdb_del,
-	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_bridge_getlink		= switchdev_port_bridge_getlink,
 	.ndo_bridge_setlink		= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink		= switchdev_port_bridge_dellink,
+	.ndo_fdb_add			= switchdev_port_fdb_add,
+	.ndo_fdb_del			= switchdev_port_fdb_del,
+	.ndo_fdb_dump			= switchdev_port_fdb_dump,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
 
@@ -4405,6 +4303,18 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 	return 0;
 }
 
+static int rocker_port_fdb_add(struct rocker_port *rocker_port,
+			       struct switchdev_obj_fdb *fdb)
+{
+	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
+	int flags = 0;
+
+	if (!rocker_port_is_bridged(rocker_port))
+		return -EINVAL;
+
+	return rocker_port_fdb(rocker_port, fdb->addr, vlan_id, flags);
+}
+
 static int rocker_port_obj_add(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
@@ -4435,6 +4345,9 @@ static int rocker_port_obj_add(struct net_device *dev,
 					   fib4->dst_len, fib4->fi,
 					   fib4->tb_id, 0);
 		break;
+	case SWITCHDEV_OBJ_PORT_FDB:
+		err = rocker_port_fdb_add(rocker_port, &obj->fdb);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4473,6 +4386,18 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 	return 0;
 }
 
+static int rocker_port_fdb_del(struct rocker_port *rocker_port,
+			       struct switchdev_obj_fdb *fdb)
+{
+	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
+	int flags = ROCKER_OP_FLAG_REMOVE;
+
+	if (!rocker_port_is_bridged(rocker_port))
+		return -EINVAL;
+
+	return rocker_port_fdb(rocker_port, fdb->addr, vlan_id, flags);
+}
+
 static int rocker_port_obj_del(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
@@ -4491,6 +4416,53 @@ static int rocker_port_obj_del(struct net_device *dev,
 					   fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
+	case SWITCHDEV_OBJ_PORT_FDB:
+		err = rocker_port_fdb_del(rocker_port, &obj->fdb);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int rocker_port_fdb_dump(struct rocker_port *rocker_port,
+				struct switchdev_obj *obj)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_fdb_tbl_entry *found;
+	struct hlist_node *tmp;
+	unsigned long lock_flags;
+	int bkt;
+	int err = 0;
+
+	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
+	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
+		if (found->key.pport != rocker_port->pport)
+			continue;
+		obj->fdb.addr = found->key.addr;
+		obj->fdb.vid = rocker_port_vlan_to_vid(rocker_port,
+						       found->key.vlan_id);
+		err = obj->cb(rocker_port->dev, obj);
+		if (err)
+			break;
+	}
+	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
+
+	return err;
+}
+
+static int rocker_port_obj_dump(struct net_device *dev,
+				struct switchdev_obj *obj)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_FDB:
+		err = rocker_port_fdb_dump(rocker_port, obj);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4504,6 +4476,7 @@ static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_attr_set	= rocker_port_attr_set,
 	.switchdev_port_obj_add		= rocker_port_obj_add,
 	.switchdev_port_obj_del		= rocker_port_obj_del,
+	.switchdev_port_obj_dump	= rocker_port_obj_dump,
 };
 
 /********************
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 1ec035a..daa054b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1980,6 +1980,9 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
+	.ndo_fdb_add		= switchdev_port_fdb_add,
+	.ndo_fdb_del		= switchdev_port_fdb_del,
+	.ndo_fdb_dump		= switchdev_port_fdb_dump,
 	.ndo_features_check	= passthru_features_check,
 };
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 3b217b4..0dba9a7 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -47,11 +47,13 @@ enum switchdev_obj_id {
 	SWITCHDEV_OBJ_UNDEFINED,
 	SWITCHDEV_OBJ_PORT_VLAN,
 	SWITCHDEV_OBJ_IPV4_FIB,
+	SWITCHDEV_OBJ_PORT_FDB,
 };
 
 struct switchdev_obj {
 	enum switchdev_obj_id id;
 	enum switchdev_trans trans;
+	int (*cb)(struct net_device *dev, struct switchdev_obj *obj);
 	union {
 		struct switchdev_obj_vlan {			/* PORT_VLAN */
 			u16 flags;
@@ -67,6 +69,10 @@ struct switchdev_obj {
 			u32 nlflags;
 			u32 tb_id;
 		} ipv4_fib;
+		struct switchdev_obj_fdb {		/* PORT_FDB */
+			const unsigned char *addr;
+			u16 vid;
+		} fdb;
 	};
 };
 
@@ -80,6 +86,8 @@ struct switchdev_obj {
  * @switchdev_port_obj_add: Add an object to port (see switchdev_obj).
  *
  * @switchdev_port_obj_del: Delete an object from port (see switchdev_obj).
+ *
+ * @switchdev_port_obj_dump: Dump port objects (see switchdev_obj).
  */
 struct switchdev_ops {
 	int	(*switchdev_port_attr_get)(struct net_device *dev,
@@ -90,6 +98,8 @@ struct switchdev_ops {
 					  struct switchdev_obj *obj);
 	int	(*switchdev_port_obj_del)(struct net_device *dev,
 					  struct switchdev_obj *obj);
+	int	(*switchdev_port_obj_dump)(struct net_device *dev,
+					  struct switchdev_obj *obj);
 };
 
 enum switchdev_notifier_type {
@@ -121,6 +131,7 @@ int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
 int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
+int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
@@ -137,6 +148,15 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 tb_id);
 void switchdev_fib_ipv4_abort(struct fib_info *fi);
+int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			   struct net_device *dev, const unsigned char *addr,
+			   u16 vid, u16 nlm_flags);
+int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+			   struct net_device *dev, const unsigned char *addr,
+			   u16 vid);
+int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
+			    struct net_device *dev,
+			    struct net_device *filter_dev, int idx);
 
 #else
 
@@ -164,6 +184,12 @@ static inline int switchdev_port_obj_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int switchdev_port_obj_dump(struct net_device *dev,
+					  struct switchdev_obj *obj)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
@@ -221,6 +247,30 @@ static inline void switchdev_fib_ipv4_abort(struct fib_info *fi)
 {
 }
 
+static inline int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+					 struct net_device *dev,
+					 const unsigned char *addr,
+					 u16 vid, u16 nlm_flags)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+					 struct net_device *dev,
+					 const unsigned char *addr, u16 vid)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
+					  struct netlink_callback *cb,
+					  struct net_device *dev,
+					  struct net_device *filter_dev,
+					  int idx)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 65d49d4..3f92a5e 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -295,6 +295,36 @@ int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj)
 }
 EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
 
+/**
+ *	switchdev_port_obj_dump - Dump port objects
+ *
+ *	@dev: port device
+ *	@obj: object to dump
+ */
+int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj)
+{
+	const struct switchdev_ops *ops = dev->switchdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->switchdev_port_obj_dump)
+		return ops->switchdev_port_obj_dump(dev, obj);
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to dump objects on
+	 * first port at bottom of stack.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = switchdev_port_obj_dump(lower_dev, obj);
+		break;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_obj_dump);
+
 static DEFINE_MUTEX(switchdev_mutex);
 static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
 
@@ -564,6 +594,151 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_dellink);
 
+/**
+ *	switchdev_port_fdb_add - Add FDB (MAC/VLAN) entry to port
+ *
+ *	@ndmsg: netlink hdr
+ *	@nlattr: netlink attributes
+ *	@dev: port device
+ *	@addr: MAC address to add
+ *	@vid: VLAN to add
+ *
+ *	Add FDB entry to switch device.
+ */
+int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			   struct net_device *dev, const unsigned char *addr,
+			   u16 vid, u16 nlm_flags)
+{
+	struct switchdev_obj obj = {
+		.id = SWITCHDEV_OBJ_PORT_FDB,
+		.fdb = {
+			.addr = addr,
+			.vid = vid,
+		},
+	};
+
+	return switchdev_port_obj_add(dev, &obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
+
+/**
+ *	switchdev_port_fdb_del - Delete FDB (MAC/VLAN) entry from port
+ *
+ *	@ndmsg: netlink hdr
+ *	@nlattr: netlink attributes
+ *	@dev: port device
+ *	@addr: MAC address to delete
+ *	@vid: VLAN to delete
+ *
+ *	Delete FDB entry from switch device.
+ */
+int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+			   struct net_device *dev, const unsigned char *addr,
+			   u16 vid)
+{
+	struct switchdev_obj obj = {
+		.id = SWITCHDEV_OBJ_PORT_FDB,
+		.fdb = {
+			.addr = addr,
+			.vid = vid,
+		},
+	};
+
+	return switchdev_port_obj_del(dev, &obj);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
+
+struct switchdev_fdb_dump {
+	struct switchdev_obj obj;
+	struct sk_buff *skb;
+	struct netlink_callback *cb;
+	struct net_device *filter_dev;
+	int idx;
+};
+
+static int switchdev_port_fdb_dump_cb(struct net_device *dev,
+				      struct switchdev_obj *obj)
+{
+	struct switchdev_fdb_dump *dump =
+		container_of(obj, struct switchdev_fdb_dump, obj);
+	u32 portid = NETLINK_CB(dump->cb->skb).portid;
+	u32 seq = dump->cb->nlh->nlmsg_seq;
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+	struct net_device *master = netdev_master_upper_dev_get(dev);
+
+	if (dump->idx < dump->cb->args[0])
+		goto skip;
+
+	if (master && dump->filter_dev != master)
+		goto skip;
+
+	nlh = nlmsg_put(dump->skb, portid, seq, RTM_NEWNEIGH,
+			sizeof(*ndm), NLM_F_MULTI);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ndm = nlmsg_data(nlh);
+	ndm->ndm_family  = AF_BRIDGE;
+	ndm->ndm_pad1    = 0;
+	ndm->ndm_pad2    = 0;
+	ndm->ndm_flags   = NTF_SELF;
+	ndm->ndm_type    = 0;
+	ndm->ndm_ifindex = dev->ifindex;
+	ndm->ndm_state   = NUD_REACHABLE;
+
+	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, obj->fdb.addr))
+		goto nla_put_failure;
+
+	if (obj->fdb.vid && nla_put_u16(dump->skb, NDA_VLAN, obj->fdb.vid))
+		goto nla_put_failure;
+
+	nlmsg_end(dump->skb, nlh);
+
+skip:
+	dump->idx++;
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(dump->skb, nlh);
+	return -EMSGSIZE;
+}
+
+/**
+ *	switchdev_port_fdb_dump - Dump port FDB (MAC/VLAN) entries
+ *
+ *	@skb: netlink skb
+ *	@cb: netlink callback
+ *	@dev: port device
+ *	@filter_dev: filter device
+ *	@idx:
+ *
+ *	Delete FDB entry from switch device.
+ */
+int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
+			    struct net_device *dev,
+			    struct net_device *filter_dev, int idx)
+{
+	struct switchdev_fdb_dump dump = {
+		.obj = {
+			.id = SWITCHDEV_OBJ_PORT_FDB,
+			.cb = switchdev_port_fdb_dump_cb,
+		},
+		.skb = skb,
+		.cb = cb,
+		.filter_dev = filter_dev,
+		.idx = idx,
+	};
+	int err;
+
+	err = switchdev_port_obj_dump(dev, &dump.obj);
+	if (err)
+		return err;
+
+	return dump.idx;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
+
 static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
-- 
2.1.0
