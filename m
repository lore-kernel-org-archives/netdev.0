From: sfeldma@gmail.com
Subject: [PATCH net-next] switchdev: don't use anonymous union on switchdev attr/obj structs
Date: Wed, 13 May 2015 11:16:50 -0700
Message-ID: <1431541011-53025-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33585 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264AbbEMSPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 14:15:38 -0400
Received: by pacwv17 with SMTP id wv17so58221701pac.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 11:15:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Older gcc versions (e.g.  gcc version 4.4.6) don't like anonymous unions
which was causing build issues on the newly added switchdev attr/obj
structs.  Fix this by using named union on structs.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c |   18 ++++++++--------
 include/net/switchdev.h              |    4 ++--
 net/bridge/br_stp.c                  |    2 +-
 net/core/net-sysfs.c                 |    4 ++--
 net/core/rtnetlink.c                 |    3 ++-
 net/dsa/slave.c                      |    6 +++---
 net/switchdev/switchdev.c            |   39 +++++++++++++++++-----------------
 7 files changed, 39 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index ca53393..f0a9cb4 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4339,11 +4339,11 @@ static int rocker_port_attr_get(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_PARENT_ID:
-		attr->ppid.id_len = sizeof(rocker->hw.id);
-		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
+		attr->u.ppid.id_len = sizeof(rocker->hw.id);
+		memcpy(&attr->u.ppid.id, &rocker->hw.id, attr->u.ppid.id_len);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
-		attr->brport_flags = rocker_port->brport_flags;
+		attr->u.brport_flags = rocker_port->brport_flags;
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -4400,11 +4400,11 @@ static int rocker_port_attr_set(struct net_device *dev,
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, attr->trans,
-					     attr->stp_state);
+					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
 		err = rocker_port_brport_flags_set(rocker_port, attr->trans,
-						   attr->brport_flags);
+						   attr->u.brport_flags);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4466,10 +4466,10 @@ static int rocker_port_obj_add(struct net_device *dev,
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, obj->trans,
-					    &obj->vlan);
+					    &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
-		fib4 = &obj->ipv4_fib;
+		fib4 = &obj->u.ipv4_fib;
 		err = rocker_port_fib_ipv4(rocker_port, obj->trans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
@@ -4520,10 +4520,10 @@ static int rocker_port_obj_del(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_del(rocker_port, &obj->vlan);
+		err = rocker_port_vlans_del(rocker_port, &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
-		fib4 = &obj->ipv4_fib;
+		fib4 = &obj->u.ipv4_fib;
 		err = rocker_port_fib_ipv4(rocker_port, SWITCHDEV_TRANS_NONE,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id,
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 9f9a7cc5..ea5b1c2 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -38,7 +38,7 @@ struct switchdev_attr {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
-	};
+	} u;
 };
 
 struct fib_info;
@@ -67,7 +67,7 @@ struct switchdev_obj {
 			u32 nlflags;
 			u32 tb_id;
 		} ipv4_fib;
-	};
+	} u;
 };
 
 /**
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index b9300da..45f1ff1 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -41,7 +41,7 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
 	struct switchdev_attr attr = {
 		.id = SWITCHDEV_ATTR_PORT_STP_STATE,
-		.stp_state = state,
+		.u.stp_state = state,
 	};
 	int err;
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5a9ce96..18b34d7 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -465,8 +465,8 @@ static ssize_t phys_switch_id_show(struct device *dev,
 
 		ret = switchdev_port_attr_get(netdev, &attr);
 		if (!ret)
-			ret = sprintf(buf, "%*phN\n", attr.ppid.id_len,
-				      attr.ppid.id);
+			ret = sprintf(buf, "%*phN\n", attr.u.ppid.id_len,
+				      attr.u.ppid.id);
 	}
 	rtnl_unlock();
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c6c6b2c..141ccc3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1016,7 +1016,8 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 		return err;
 	}
 
-	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, attr.ppid.id_len, attr.ppid.id))
+	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, attr.u.ppid.id_len,
+		    attr.u.ppid.id))
 		return -EMSGSIZE;
 
 	return 0;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3fb5210..04ffad3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -353,7 +353,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
 		if (attr->trans == SWITCHDEV_TRANS_COMMIT)
-			ret = dsa_slave_stp_update(dev, attr->stp_state);
+			ret = dsa_slave_stp_update(dev, attr->u.stp_state);
 		break;
 	default:
 		ret = -EOPNOTSUPP;
@@ -408,8 +408,8 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_PARENT_ID:
-		attr->ppid.id_len = sizeof(ds->index);
-		memcpy(&attr->ppid.id, &ds->index, attr->ppid.id_len);
+		attr->u.ppid.id_len = sizeof(ds->index);
+		memcpy(&attr->u.ppid.id, &ds->index, attr->u.ppid.id_len);
 		break;
 	default:
 		return -EOPNOTSUPP;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 77f1b6e..0409f9b 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -383,7 +383,7 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 		return err;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
-				       attr.brport_flags, mask, nlflags);
+				       attr.u.brport_flags, mask, nlflags);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_getlink);
 
@@ -402,9 +402,9 @@ static int switchdev_port_br_setflag(struct net_device *dev,
 		return err;
 
 	if (flag)
-		attr.brport_flags |= brport_flag;
+		attr.u.brport_flags |= brport_flag;
 	else
-		attr.brport_flags &= ~brport_flag;
+		attr.u.brport_flags &= ~brport_flag;
 
 	return switchdev_port_attr_set(dev, &attr);
 }
@@ -466,6 +466,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 	struct switchdev_obj obj = {
 		.id = SWITCHDEV_OBJ_PORT_VLAN,
 	};
+	struct switchdev_obj_vlan *vlan = &obj.u.vlan;
 	int rem;
 	int err;
 
@@ -475,30 +476,30 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
 			return -EINVAL;
 		vinfo = nla_data(attr);
-		obj.vlan.flags = vinfo->flags;
+		vlan->flags = vinfo->flags;
 		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
-			if (obj.vlan.vid_start)
+			if (vlan->vid_start)
 				return -EINVAL;
-			obj.vlan.vid_start = vinfo->vid;
+			vlan->vid_start = vinfo->vid;
 		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
-			if (!obj.vlan.vid_start)
+			if (!vlan->vid_start)
 				return -EINVAL;
-			obj.vlan.vid_end = vinfo->vid;
-			if (obj.vlan.vid_end <= obj.vlan.vid_start)
+			vlan->vid_end = vinfo->vid;
+			if (vlan->vid_end <= vlan->vid_start)
 				return -EINVAL;
 			err = f(dev, &obj);
 			if (err)
 				return err;
-			memset(&obj.vlan, 0, sizeof(obj.vlan));
+			memset(vlan, 0, sizeof(*vlan));
 		} else {
-			if (obj.vlan.vid_start)
+			if (vlan->vid_start)
 				return -EINVAL;
-			obj.vlan.vid_start = vinfo->vid;
-			obj.vlan.vid_end = vinfo->vid;
+			vlan->vid_start = vinfo->vid;
+			vlan->vid_end = vinfo->vid;
 			err = f(dev, &obj);
 			if (err)
 				return err;
-			memset(&obj.vlan, 0, sizeof(obj.vlan));
+			memset(vlan, 0, sizeof(*vlan));
 		}
 	}
 
@@ -613,10 +614,10 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 			return NULL;
 
 		if (nhsel > 0) {
-			if (prev_attr.ppid.id_len != attr.ppid.id_len)
+			if (prev_attr.u.ppid.id_len != attr.u.ppid.id_len)
 				return NULL;
-			if (memcmp(prev_attr.ppid.id, attr.ppid.id,
-				   attr.ppid.id_len))
+			if (memcmp(prev_attr.u.ppid.id, attr.u.ppid.id,
+				   attr.u.ppid.id_len))
 				return NULL;
 		}
 
@@ -644,7 +645,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 {
 	struct switchdev_obj fib_obj = {
 		.id = SWITCHDEV_OBJ_IPV4_FIB,
-		.ipv4_fib = {
+		.u.ipv4_fib = {
 			.dst = dst,
 			.dst_len = dst_len,
 			.fi = fi,
@@ -698,7 +699,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 {
 	struct switchdev_obj fib_obj = {
 		.id = SWITCHDEV_OBJ_IPV4_FIB,
-		.ipv4_fib = {
+		.u.ipv4_fib = {
 			.dst = dst,
 			.dst_len = dst_len,
 			.fi = fi,
-- 
1.7.10.4
