From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: switchdev: restrict vid range abstraction
Date: Sun, 26 Jul 2015 19:45:48 -0400
Message-ID: <1437954348-11859-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces the vid_begin and vid_end members of the
switchdev_obj_vlan structure for a single vid member. This way, the VID
range abstraction is restricted to switchdev, not exposed to drivers.

The main benefice to do so is to allow the prepare phase to be called
for each VID, not only once for the whole range.

For example, when adding VLANs 2-5, a switch chip may not be able to add
hardware VLAN 2 due to some bridge restriction (thus must return
-EOPNOTSUPP), while VLAN 3-5 are allowed.

Also, moving the iteration code to switchdev simplifies its
implementation and its drivers code (e.g. Rocker).

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c | 74 ++++++++++--------------------------
 include/net/switchdev.h              |  3 +-
 net/bridge/br_vlan.c                 |  6 +--
 net/switchdev/switchdev.c            | 70 +++++++++++++++++-----------------
 4 files changed, 58 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 7b4c347..f0dfd77 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4366,41 +4366,25 @@ static int rocker_port_attr_set(struct net_device *dev,
 }
 
 static int rocker_port_vlan_add(struct rocker_port *rocker_port,
-				enum switchdev_trans trans, u16 vid, u16 flags)
+				enum switchdev_trans trans,
+				const struct switchdev_obj_vlan *vlan)
 {
 	int err;
 
 	/* XXX deal with flags for PVID and untagged */
 
-	err = rocker_port_vlan(rocker_port, trans, 0, vid);
+	err = rocker_port_vlan(rocker_port, trans, 0, vlan->vid);
 	if (err)
 		return err;
 
-	err = rocker_port_router_mac(rocker_port, trans, 0, htons(vid));
+	err = rocker_port_router_mac(rocker_port, trans, 0, htons(vlan->vid));
 	if (err)
 		rocker_port_vlan(rocker_port, trans,
-				 ROCKER_OP_FLAG_REMOVE, vid);
+				 ROCKER_OP_FLAG_REMOVE, vlan->vid);
 
 	return err;
 }
 
-static int rocker_port_vlans_add(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans,
-				 const struct switchdev_obj_vlan *vlan)
-{
-	u16 vid;
-	int err;
-
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = rocker_port_vlan_add(rocker_port, trans,
-					   vid, vlan->flags);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
-
 static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 			       enum switchdev_trans trans,
 			       const struct switchdev_obj_fdb *fdb)
@@ -4434,8 +4418,8 @@ static int rocker_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, obj->trans,
-					    &obj->u.vlan);
+		err = rocker_port_vlan_add(rocker_port, obj->trans,
+					   &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
@@ -4455,32 +4439,17 @@ static int rocker_port_obj_add(struct net_device *dev,
 }
 
 static int rocker_port_vlan_del(struct rocker_port *rocker_port,
-				u16 vid, u16 flags)
+				const struct switchdev_obj_vlan *vlan)
 {
 	int err;
 
 	err = rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
-				     ROCKER_OP_FLAG_REMOVE, htons(vid));
+				     ROCKER_OP_FLAG_REMOVE, htons(vlan->vid));
 	if (err)
 		return err;
 
 	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
-				ROCKER_OP_FLAG_REMOVE, vid);
-}
-
-static int rocker_port_vlans_del(struct rocker_port *rocker_port,
-				 const struct switchdev_obj_vlan *vlan)
-{
-	u16 vid;
-	int err;
-
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = rocker_port_vlan_del(rocker_port, vid, vlan->flags);
-		if (err)
-			return err;
-	}
-
-	return 0;
+				ROCKER_OP_FLAG_REMOVE, vlan->vid);
 }
 
 static int rocker_port_fdb_del(struct rocker_port *rocker_port,
@@ -4505,7 +4474,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_del(rocker_port, &obj->u.vlan);
+		err = rocker_port_vlan_del(rocker_port, &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
@@ -4565,7 +4534,7 @@ static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
 		vlan->flags = 0;
 		if (rocker_vlan_id_is_internal(htons(vid)))
 			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-		vlan->vid_begin = vlan->vid_end = vid;
+		vlan->vid = vid;
 		err = obj->cb(rocker_port->dev, obj);
 		if (err)
 			break;
@@ -4944,9 +4913,9 @@ static void rocker_port_dev_addr_init(struct rocker_port *rocker_port)
 static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 {
 	const struct pci_dev *pdev = rocker->pdev;
+	const struct switchdev_obj_vlan vlan0 = { 0 };
 	struct rocker_port *rocker_port;
 	struct net_device *dev;
-	u16 untagged_vid = 0;
 	int err;
 
 	dev = alloc_etherdev(sizeof(struct rocker_port));
@@ -4992,8 +4961,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
 
-	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
-				   untagged_vid, 0);
+	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE, &vlan0);
 	if (err) {
 		netdev_err(rocker_port->dev, "install untagged VLAN failed\n");
 		goto err_untagged_vlan;
@@ -5241,7 +5209,7 @@ static bool rocker_port_dev_check(const struct net_device *dev)
 static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 				   struct net_device *bridge)
 {
-	u16 untagged_vid = 0;
+	const struct switchdev_obj_vlan vlan0 = { 0 };
 	int err;
 
 	/* Port is joining bridge, so the internal VLAN for the
@@ -5250,7 +5218,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 	 * re-add once internal VLAN has changed.
 	 */
 
-	err = rocker_port_vlan_del(rocker_port, untagged_vid, 0);
+	err = rocker_port_vlan_del(rocker_port, &vlan0);
 	if (err)
 		return err;
 
@@ -5262,16 +5230,15 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 	rocker_port->bridge_dev = bridge;
 	switchdev_port_fwd_mark_set(rocker_port->dev, bridge, true);
 
-	return rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
-				    untagged_vid, 0);
+	return rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE, &vlan0);
 }
 
 static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 {
-	u16 untagged_vid = 0;
+	const struct switchdev_obj_vlan vlan0 = { 0 };
 	int err;
 
-	err = rocker_port_vlan_del(rocker_port, untagged_vid, 0);
+	err = rocker_port_vlan_del(rocker_port, &vlan0);
 	if (err)
 		return err;
 
@@ -5285,8 +5252,7 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 				    false);
 	rocker_port->bridge_dev = NULL;
 
-	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
-				   untagged_vid, 0);
+	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE, &vlan0);
 	if (err)
 		return err;
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 89da893..337a6d7 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -57,8 +57,7 @@ struct switchdev_obj {
 	union {
 		struct switchdev_obj_vlan {		/* PORT_VLAN */
 			u16 flags;
-			u16 vid_begin;
-			u16 vid_end;
+			u16 vid;
 		} vlan;
 		struct switchdev_obj_ipv4_fib {		/* IPV4_FIB */
 			u32 dst;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 0d41f81..323bf15 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -54,8 +54,7 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 			.id = SWITCHDEV_OBJ_PORT_VLAN,
 			.u.vlan = {
 				.flags = flags,
-				.vid_begin = vid,
-				.vid_end = vid,
+				.vid = vid,
 			},
 		};
 
@@ -132,8 +131,7 @@ static void __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 		struct switchdev_obj vlan_obj = {
 			.id = SWITCHDEV_OBJ_PORT_VLAN,
 			.u.vlan = {
-				.vid_begin = vid,
-				.vid_end = vid,
+				.vid = vid,
 			},
 		};
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 33bafa2..81e8d82 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -444,42 +444,32 @@ static int switchdev_port_vlan_dump_cb(struct net_device *dev,
 	struct switchdev_obj_vlan *vlan = &dump->obj.u.vlan;
 	int err = 0;
 
-	if (vlan->vid_begin > vlan->vid_end)
-		return -EINVAL;
-
 	if (dump->filter_mask & RTEXT_FILTER_BRVLAN) {
 		dump->flags = vlan->flags;
-		for (dump->begin = dump->end = vlan->vid_begin;
-		     dump->begin <= vlan->vid_end;
-		     dump->begin++, dump->end++) {
-			err = switchdev_port_vlan_dump_put(dev, dump);
-			if (err)
-				return err;
-		}
+		dump->begin = dump->end = vlan->vid;
+		err = switchdev_port_vlan_dump_put(dev, dump);
+		if (err)
+			return err;
 	} else if (dump->filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED) {
-		if (dump->begin > vlan->vid_begin &&
-		    dump->begin >= vlan->vid_end) {
-			if ((dump->begin - 1) == vlan->vid_end &&
+		if (dump->begin > vlan->vid) {
+			if ((dump->begin - 1) == vlan->vid &&
 			    dump->flags == vlan->flags) {
 				/* prepend */
-				dump->begin = vlan->vid_begin;
+				dump->begin = vlan->vid;
 			} else {
 				err = switchdev_port_vlan_dump_put(dev, dump);
 				dump->flags = vlan->flags;
-				dump->begin = vlan->vid_begin;
-				dump->end = vlan->vid_end;
+				dump->begin = dump->end = vlan->vid;
 			}
-		} else if (dump->end <= vlan->vid_begin &&
-		           dump->end < vlan->vid_end) {
-			if ((dump->end  + 1) == vlan->vid_begin &&
+		} else if (dump->end < vlan->vid) {
+			if ((dump->end  + 1) == vlan->vid &&
 			    dump->flags == vlan->flags) {
 				/* append */
-				dump->end = vlan->vid_end;
+				dump->end = vlan->vid;
 			} else {
 				err = switchdev_port_vlan_dump_put(dev, dump);
 				dump->flags = vlan->flags;
-				dump->begin = vlan->vid_begin;
-				dump->end = vlan->vid_end;
+				dump->begin = dump->end = vlan->vid;
 			}
 		} else {
 			err = -EINVAL;
@@ -625,6 +615,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 		.id = SWITCHDEV_OBJ_PORT_VLAN,
 	};
 	struct switchdev_obj_vlan *vlan = &obj.u.vlan;
+	u16 vid_begin = 0, vid_end = 0;
 	int rem;
 	int err;
 
@@ -634,26 +625,35 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
 			return -EINVAL;
 		vinfo = nla_data(attr);
-		vlan->flags = vinfo->flags;
+
 		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
-			if (vlan->vid_begin)
+			if (vid_begin)
 				return -EINVAL;
-			vlan->vid_begin = vinfo->vid;
+			vid_begin = vinfo->vid;
 		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
-			if (!vlan->vid_begin)
+			u16 vid;
+
+			if (!vid_begin)
 				return -EINVAL;
-			vlan->vid_end = vinfo->vid;
-			if (vlan->vid_end <= vlan->vid_begin)
+			vid_end = vinfo->vid;
+			if (vid_end <= vid_begin)
 				return -EINVAL;
-			err = f(dev, &obj);
-			if (err)
-				return err;
-			memset(vlan, 0, sizeof(*vlan));
+
+			for (vid = vid_begin; vid <= vid_end; ++vid) {
+				vlan->flags = vinfo->flags;
+				vlan->vid = vid;
+				err = f(dev, &obj);
+				if (err)
+					return err;
+				memset(vlan, 0, sizeof(*vlan));
+			}
+			vid_begin = vid_end = 0;
 		} else {
-			if (vlan->vid_begin)
+			if (vid_begin)
 				return -EINVAL;
-			vlan->vid_begin = vinfo->vid;
-			vlan->vid_end = vinfo->vid;
+
+			vlan->flags = vinfo->flags;
+			vlan->vid = vinfo->vid;
 			err = f(dev, &obj);
 			if (err)
 				return err;
-- 
2.4.6
