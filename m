From: sfeldma@gmail.com
Subject: [PATCH net-next v3 3/3] switchdev: split switchdev_attr into individual structs
Date: Thu, 22 Oct 2015 20:25:17 -0700
Message-ID: <1445570717-40780-3-git-send-email-sfeldma@gmail.com>
References: <1445570717-40780-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35946 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbbJWDWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 23:22:25 -0400
Received: by pacfv9 with SMTP id fv9so109731291pac.3
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 20:22:24 -0700 (PDT)
In-Reply-To: <1445570717-40780-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This was already done for switchdev_objs.   Changing switchdev_attrs to new
style makes switchdev API consistent for both attrs and objs.

No functional changes here.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
v2->v3: remove something that slipped in from the future.  I got a piece of
another patchset mixed in with this one.  Oops.

v1->v2: add Jiri's Acked-by

 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   24 ++++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |    7 +-
 drivers/net/ethernet/rocker/rocker.c               |   23 ++++--
 include/net/switchdev.h                            |   42 +++++++++--
 net/bridge/br_stp.c                                |   24 +++---
 net/core/net-sysfs.c                               |   14 ++--
 net/core/rtnetlink.c                               |   14 ++--
 net/dsa/slave.c                                    |   10 ++-
 net/switchdev/switchdev.c                          |   77 +++++++++++++-------
 9 files changed, 163 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index c39b7a1..efa1aa8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -56,15 +56,19 @@ static int mlxsw_sp_port_attr_get(struct net_device *dev,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct switchdev_attr_port_parent_id *parent_id;
+	struct switchdev_attr_port_bridge_flags *brport_flags;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
-		attr->u.ppid.id_len = sizeof(mlxsw_sp->base_mac);
-		memcpy(&attr->u.ppid.id, &mlxsw_sp->base_mac,
-		       attr->u.ppid.id_len);
+		parent_id = SWITCHDEV_ATTR_PORT_PARENT_ID(attr);
+		parent_id->ppid.id_len = sizeof(mlxsw_sp->base_mac);
+		memcpy(&parent_id->ppid.id, &mlxsw_sp->base_mac,
+		       parent_id->ppid.id_len);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
-		attr->u.brport_flags =
+		brport_flags = SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS(attr);
+		brport_flags->brport_flags =
 			(mlxsw_sp_port->learning ? BR_LEARNING : 0) |
 			(mlxsw_sp_port->learning_sync ? BR_LEARNING_SYNC : 0);
 		break;
@@ -166,20 +170,26 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 				  struct switchdev_trans *trans)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct switchdev_attr_port_stp_state *stp_state;
+	struct switchdev_attr_port_bridge_flags *brport_flags;
+	struct switchdev_attr_bridge_ageing_time *ageing_time;
 	int err = 0;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
+		stp_state = SWITCHDEV_ATTR_PORT_STP_STATE(attr);
 		err = mlxsw_sp_port_attr_stp_state_set(mlxsw_sp_port, trans,
-						       attr->u.stp_state);
+						       stp_state->state);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
+		brport_flags = SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS(attr);
 		err = mlxsw_sp_port_attr_br_flags_set(mlxsw_sp_port, trans,
-						      attr->u.brport_flags);
+						      brport_flags->brport_flags);
 		break;
 	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
+		ageing_time = SWITCHDEV_ATTR_BRIDGE_AGEING_TIME(attr);
 		err = mlxsw_sp_port_attr_br_ageing_set(mlxsw_sp_port, trans,
-						       attr->u.ageing_time);
+						       ageing_time->ageing_time);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 2fd2279..edabc82 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -864,11 +864,14 @@ static int mlxsw_sx_port_attr_get(struct net_device *dev,
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
 	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	struct switchdev_attr_port_parent_id *parent_id;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
-		attr->u.ppid.id_len = sizeof(mlxsw_sx->hw_id);
-		memcpy(&attr->u.ppid.id, &mlxsw_sx->hw_id, attr->u.ppid.id_len);
+		parent_id = SWITCHDEV_ATTR_PORT_PARENT_ID(attr);
+		parent_id->ppid.id_len = sizeof(mlxsw_sx->hw_id);
+		memcpy(&parent_id->ppid.id, &mlxsw_sx->hw_id,
+		       parent_id->ppid.id_len);
 		break;
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 32a80d2..512dc51 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4327,14 +4327,19 @@ static int rocker_port_attr_get(struct net_device *dev,
 {
 	const struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct rocker *rocker = rocker_port->rocker;
+	struct switchdev_attr_port_parent_id *parent_id;
+	struct switchdev_attr_port_bridge_flags *brport_flags;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
-		attr->u.ppid.id_len = sizeof(rocker->hw.id);
-		memcpy(&attr->u.ppid.id, &rocker->hw.id, attr->u.ppid.id_len);
+		parent_id = SWITCHDEV_ATTR_PORT_PARENT_ID(attr);
+		parent_id->ppid.id_len = sizeof(rocker->hw.id);
+		memcpy(&parent_id->ppid.id, &rocker->hw.id,
+		       parent_id->ppid.id_len);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
-		attr->u.brport_flags = rocker_port->brport_flags;
+		brport_flags = SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS(attr);
+		brport_flags->brport_flags = rocker_port->brport_flags;
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -4378,20 +4383,26 @@ static int rocker_port_attr_set(struct net_device *dev,
 				struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct switchdev_attr_port_stp_state *stp_state;
+	struct switchdev_attr_port_bridge_flags *brport_flags;
+	struct switchdev_attr_bridge_ageing_time *ageing_time;
 	int err = 0;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
+		stp_state = SWITCHDEV_ATTR_PORT_STP_STATE(attr);
 		err = rocker_port_stp_update(rocker_port, trans, 0,
-					     attr->u.stp_state);
+					     stp_state->state);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
+		brport_flags = SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS(attr);
 		err = rocker_port_brport_flags_set(rocker_port, trans,
-						   attr->u.brport_flags);
+						   brport_flags->brport_flags);
 		break;
 	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
+		ageing_time = SWITCHDEV_ATTR_BRIDGE_AGEING_TIME(attr);
 		err = rocker_port_bridge_ageing_time(rocker_port, trans,
-						     attr->u.ageing_time);
+						     ageing_time->ageing_time);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index bc865e2..6e2e044 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -52,14 +52,44 @@ enum switchdev_attr_id {
 struct switchdev_attr {
 	enum switchdev_attr_id id;
 	u32 flags;
-	union {
-		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
-		u8 stp_state;				/* PORT_STP_STATE */
-		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
-		u32 ageing_time;			/* BRIDGE_AGEING_TIME */
-	} u;
 };
 
+/* SWITCHDEV_ATTR_ID_PORT_PARENT_ID */
+struct switchdev_attr_port_parent_id {
+	struct switchdev_attr attr;
+	struct netdev_phys_item_id ppid;
+};
+
+#define SWITCHDEV_ATTR_PORT_PARENT_ID(attr) \
+	container_of(attr, struct switchdev_attr_port_parent_id, attr)
+
+/* SWITCHDEV_ATTR_ID_PORT_STP_STATE */
+struct switchdev_attr_port_stp_state {
+	struct switchdev_attr attr;
+	u8 state;
+};
+
+#define SWITCHDEV_ATTR_PORT_STP_STATE(attr) \
+	container_of(attr, struct switchdev_attr_port_stp_state, attr)
+
+/* SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS */
+struct switchdev_attr_port_bridge_flags {
+	struct switchdev_attr attr;
+	unsigned long brport_flags;
+};
+
+#define SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS(attr) \
+	container_of(attr, struct switchdev_attr_port_bridge_flags, attr)
+
+/* SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME */
+struct switchdev_attr_bridge_ageing_time {
+	struct switchdev_attr attr;
+	u32 ageing_time;
+};
+
+#define SWITCHDEV_ATTR_BRIDGE_AGEING_TIME(attr) \
+	container_of(attr, struct switchdev_attr_bridge_ageing_time, attr)
+
 enum switchdev_obj_id {
 	SWITCHDEV_OBJ_ID_UNDEFINED,
 	SWITCHDEV_OBJ_ID_PORT_VLAN,
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 80c34d7..50bc679 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -39,15 +39,17 @@ void br_log_state(const struct net_bridge_port *p)
 
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
-	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
-		.flags = SWITCHDEV_F_DEFER,
-		.u.stp_state = state,
+	struct switchdev_attr_port_stp_state attr = {
+		.attr = {
+			.id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
+			.flags = SWITCHDEV_F_DEFER,
+		},
+		.state = state,
 	};
 	int err;
 
 	p->state = state;
-	err = switchdev_port_attr_set(p->dev, &attr);
+	err = switchdev_port_attr_set(p->dev, &attr.attr);
 	if (err)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
@@ -569,10 +571,12 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
 
 int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
 {
-	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
-		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
-		.u.ageing_time = ageing_time,
+	struct switchdev_attr_bridge_ageing_time attr = {
+		.attr = {
+			.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
+			.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
+		},
+		.ageing_time = ageing_time,
 	};
 	unsigned long t = clock_t_to_jiffies(ageing_time);
 	int err;
@@ -580,7 +584,7 @@ int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
 	if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
 		return -ERANGE;
 
-	err = switchdev_port_attr_set(br->dev, &attr);
+	err = switchdev_port_attr_set(br->dev, &attr.attr);
 	if (err)
 		return err;
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index f88a62a..1ee6d44 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -470,15 +470,17 @@ static ssize_t phys_switch_id_show(struct device *dev,
 		return restart_syscall();
 
 	if (dev_isalive(netdev)) {
-		struct switchdev_attr attr = {
-			.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
-			.flags = SWITCHDEV_F_NO_RECURSE,
+		struct switchdev_attr_port_parent_id parent_id = {
+			.attr = {
+				.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
+				.flags = SWITCHDEV_F_NO_RECURSE,
+			},
 		};
 
-		ret = switchdev_port_attr_get(netdev, &attr);
+		ret = switchdev_port_attr_get(netdev, &parent_id.attr);
 		if (!ret)
-			ret = sprintf(buf, "%*phN\n", attr.u.ppid.id_len,
-				      attr.u.ppid.id);
+			ret = sprintf(buf, "%*phN\n", parent_id.ppid.id_len,
+				      parent_id.ppid.id);
 	}
 	rtnl_unlock();
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2477595..656e7a5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1024,20 +1024,22 @@ static int rtnl_phys_port_name_fill(struct sk_buff *skb, struct net_device *dev)
 static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
-	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
-		.flags = SWITCHDEV_F_NO_RECURSE,
+	struct switchdev_attr_port_parent_id parent_id = {
+		.attr = {
+			.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
+			.flags = SWITCHDEV_F_NO_RECURSE,
+		},
 	};
 
-	err = switchdev_port_attr_get(dev, &attr);
+	err = switchdev_port_attr_get(dev, &parent_id.attr);
 	if (err) {
 		if (err == -EOPNOTSUPP)
 			return 0;
 		return err;
 	}
 
-	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, attr.u.ppid.id_len,
-		    attr.u.ppid.id))
+	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, parent_id.ppid.id_len,
+		    parent_id.ppid.id))
 		return -EMSGSIZE;
 
 	return 0;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b0b8da0..e41803f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -458,15 +458,17 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
+	struct switchdev_attr_port_stp_state *stp_state;
 	int ret;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
+		stp_state = SWITCHDEV_ATTR_PORT_STP_STATE(attr);
 		if (switchdev_trans_ph_prepare(trans))
 			ret = ds->drv->port_stp_update ? 0 : -EOPNOTSUPP;
 		else
 			ret = ds->drv->port_stp_update(ds, p->port,
-						       attr->u.stp_state);
+						       stp_state->state);
 		break;
 	default:
 		ret = -EOPNOTSUPP;
@@ -595,11 +597,13 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
+	struct switchdev_attr_port_parent_id *parent_id;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
-		attr->u.ppid.id_len = sizeof(ds->index);
-		memcpy(&attr->u.ppid.id, &ds->index, attr->u.ppid.id_len);
+		parent_id = SWITCHDEV_ATTR_PORT_PARENT_ID(attr);
+		parent_id->ppid.id_len = sizeof(ds->index);
+		memcpy(&parent_id->ppid.id, &ds->index, parent_id->ppid.id_len);
 		break;
 	default:
 		return -EOPNOTSUPP;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index bff8e2b..3cda6fc 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -309,7 +309,27 @@ static void switchdev_port_attr_set_deferred(struct net_device *dev,
 static int switchdev_port_attr_set_defer(struct net_device *dev,
 					 const struct switchdev_attr *attr)
 {
-	return switchdev_deferred_enqueue(dev, attr, sizeof(*attr),
+	size_t size = 0;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		size = sizeof(struct switchdev_attr_port_parent_id);
+		break;
+	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
+		size = sizeof(struct switchdev_attr_port_stp_state);
+		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
+		size = sizeof(struct switchdev_attr_port_bridge_flags);
+		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
+		size = sizeof(struct switchdev_attr_bridge_ageing_time);
+		break;
+	default:
+		WARN_ON(!size);
+		return -EINVAL;
+	}
+
+	return switchdev_deferred_enqueue(dev, attr, size,
 					  switchdev_port_attr_set_deferred);
 }
 
@@ -756,19 +776,19 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				  struct net_device *dev, u32 filter_mask,
 				  int nlflags)
 {
-	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
+	struct switchdev_attr_port_bridge_flags attr = {
+		.attr.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	};
 	u16 mode = BRIDGE_MODE_UNDEF;
 	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
 	int err;
 
-	err = switchdev_port_attr_get(dev, &attr);
+	err = switchdev_port_attr_get(dev, &attr.attr);
 	if (err && err != -EOPNOTSUPP)
 		return err;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
-				       attr.u.brport_flags, mask, nlflags,
+				       attr.brport_flags, mask, nlflags,
 				       filter_mask, switchdev_port_vlan_fill);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_getlink);
@@ -777,22 +797,22 @@ static int switchdev_port_br_setflag(struct net_device *dev,
 				     struct nlattr *nlattr,
 				     unsigned long brport_flag)
 {
-	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
+	struct switchdev_attr_port_bridge_flags attr = {
+		.attr.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	};
 	u8 flag = nla_get_u8(nlattr);
 	int err;
 
-	err = switchdev_port_attr_get(dev, &attr);
+	err = switchdev_port_attr_get(dev, &attr.attr);
 	if (err)
 		return err;
 
 	if (flag)
-		attr.u.brport_flags |= brport_flag;
+		attr.brport_flags |= brport_flag;
 	else
-		attr.u.brport_flags &= ~brport_flag;
+		attr.brport_flags &= ~brport_flag;
 
-	return switchdev_port_attr_set(dev, &attr);
+	return switchdev_port_attr_set(dev, &attr.attr);
 }
 
 static const struct nla_policy
@@ -1109,10 +1129,10 @@ static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 
 static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 {
-	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
+	struct switchdev_attr_port_parent_id parent_id = {
+		.attr.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 	};
-	struct switchdev_attr prev_attr;
+	struct switchdev_attr_port_parent_id prev_parent_id;
 	struct net_device *dev = NULL;
 	int nhsel;
 
@@ -1130,14 +1150,15 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 		if (!dev)
 			return NULL;
 
-		if (switchdev_port_attr_get(dev, &attr))
+		if (switchdev_port_attr_get(dev, &parent_id.attr))
 			return NULL;
 
 		if (nhsel > 0 &&
-		    !netdev_phys_item_id_same(&prev_attr.u.ppid, &attr.u.ppid))
+		    !netdev_phys_item_id_same(&prev_parent_id.ppid,
+					      &parent_id.ppid))
 				return NULL;
 
-		prev_attr = attr;
+		prev_parent_id = parent_id;
 	}
 
 	return dev;
@@ -1264,20 +1285,24 @@ EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_abort);
 static bool switchdev_port_same_parent_id(struct net_device *a,
 					  struct net_device *b)
 {
-	struct switchdev_attr a_attr = {
-		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
-		.flags = SWITCHDEV_F_NO_RECURSE,
+	struct switchdev_attr_port_parent_id parent_a_id = {
+		.attr = {
+			.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
+			.flags = SWITCHDEV_F_NO_RECURSE,
+		},
 	};
-	struct switchdev_attr b_attr = {
-		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
-		.flags = SWITCHDEV_F_NO_RECURSE,
+	struct switchdev_attr_port_parent_id parent_b_id = {
+		.attr = {
+			.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
+			.flags = SWITCHDEV_F_NO_RECURSE,
+		},
 	};
 
-	if (switchdev_port_attr_get(a, &a_attr) ||
-	    switchdev_port_attr_get(b, &b_attr))
+	if (switchdev_port_attr_get(a, &parent_a_id.attr) ||
+	    switchdev_port_attr_get(b, &parent_b_id.attr))
 		return false;
 
-	return netdev_phys_item_id_same(&a_attr.u.ppid, &b_attr.u.ppid);
+	return netdev_phys_item_id_same(&parent_a_id.ppid, &parent_b_id.ppid);
 }
 
 static u32 switchdev_port_fwd_mark_get(struct net_device *dev,
-- 
1.7.10.4
