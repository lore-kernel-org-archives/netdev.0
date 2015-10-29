From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: use switchdev obj for VLAN add/del ops
Date: Thu, 29 Oct 2015 10:28:50 -0400
Message-ID: <1446128930-26109-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify DSA by pushing the switchdev objects for VLAN add and delete
operations down to its drivers. Currently only mv88e6xxx is affected.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |   2 +-
 drivers/net/dsa/mv88e6352.c |   2 +-
 drivers/net/dsa/mv88e6xxx.c | 108 +++++++++++++++++++++++++++++++++++---------
 drivers/net/dsa/mv88e6xxx.h |  12 +++--
 include/net/dsa.h           |  13 ++++--
 net/dsa/slave.c             |  29 ++++--------
 6 files changed, 115 insertions(+), 51 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 2c8eb6f..1bd876e 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -115,7 +115,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.get_regs		= mv88e6xxx_get_regs,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
 	.port_pvid_get		= mv88e6xxx_port_pvid_get,
-	.port_pvid_set		= mv88e6xxx_port_pvid_set,
+	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.vlan_getnext		= mv88e6xxx_vlan_getnext,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index cbf4dd8..4458d6a 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -342,7 +342,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.get_regs		= mv88e6xxx_get_regs,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
 	.port_pvid_get		= mv88e6xxx_port_pvid_get,
-	.port_pvid_set		= mv88e6xxx_port_pvid_set,
+	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.vlan_getnext		= mv88e6xxx_vlan_getnext,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b1b14f5..c404466 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1121,6 +1121,19 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 	return 0;
 }
 
+static int _mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
+{
+	int ret;
+
+	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_DEFAULT_VLAN);
+	if (ret < 0)
+		return ret;
+
+	*pvid = ret & PORT_DEFAULT_VLAN_MASK;
+
+	return 0;
+}
+
 int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
 {
 	int ret;
@@ -1134,9 +1147,9 @@ int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
 	return 0;
 }
 
-int mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 pvid)
+static int _mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 pvid)
 {
-	return mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
+	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
 				   pvid & PORT_DEFAULT_VLAN_MASK);
 }
 
@@ -1441,61 +1454,87 @@ static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
 	return 0;
 }
 
-int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
-			    bool untagged)
+int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_vlan *vlan,
+				struct switchdev_trans *trans)
+{
+	/* We don't need any dynamic resource from the kernel (yet),
+	 * so skip the prepare phase.
+	 */
+	return 0;
+}
+
+static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
+				    bool untagged)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int err;
 
-	mutex_lock(&ps->smi_mutex);
-
 	err = _mv88e6xxx_vtu_vid_write(ds, vid - 1);
 	if (err)
-		goto unlock;
+		return err;
 
 	err = _mv88e6xxx_vtu_getnext(ds, &vlan);
 	if (err)
-		goto unlock;
+		return err;
 
 	if (vlan.vid != vid || !vlan.valid) {
 		err = _mv88e6xxx_vlan_init(ds, vid, &vlan);
 		if (err)
-			goto unlock;
+			return err;
 	}
 
 	vlan.data[port] = untagged ?
 		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
 		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
 
-	err = _mv88e6xxx_vtu_loadpurge(ds, &vlan);
+	return _mv88e6xxx_vtu_loadpurge(ds, &vlan);
+}
+
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_vlan *vlan,
+			    struct switchdev_trans *trans)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
+	u16 vid;
+	int err = 0;
+
+	mutex_lock(&ps->smi_mutex);
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		err = _mv88e6xxx_port_vlan_add(ds, port, vid, untagged);
+		if (err)
+			goto unlock;
+	}
+
+	/* no PVID with ranges, otherwise it's a bug */
+	if (pvid)
+		err = _mv88e6xxx_port_pvid_set(ds, port, vid);
 unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	return err;
 }
 
-int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
+int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int i, err;
 
-	mutex_lock(&ps->smi_mutex);
-
 	err = _mv88e6xxx_vtu_vid_write(ds, vid - 1);
 	if (err)
-		goto unlock;
+		return err;
 
 	err = _mv88e6xxx_vtu_getnext(ds, &vlan);
 	if (err)
-		goto unlock;
+		return err;
 
 	if (vlan.vid != vid || !vlan.valid ||
-	    vlan.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
-		err = -ENOENT;
-		goto unlock;
-	}
+	    vlan.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+		return -ENOENT;
 
 	vlan.data[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
@@ -1513,9 +1552,36 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 
 	err = _mv88e6xxx_vtu_loadpurge(ds, &vlan);
 	if (err)
+		return err;
+
+	return _mv88e6xxx_atu_remove(ds, vlan.fid, port, false);
+}
+
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_vlan *vlan)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 pvid, vid;
+	int err = 0;
+
+	mutex_lock(&ps->smi_mutex);
+
+	err = _mv88e6xxx_port_pvid_get(ds, port, &pvid);
+	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_atu_remove(ds, vlan.fid, port, false);
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		err = _mv88e6xxx_port_vlan_del(ds, port, vid);
+		if (err)
+			goto unlock;
+
+		if (vid == pvid) {
+			err = _mv88e6xxx_port_pvid_set(ds, port, 0);
+			if (err)
+				goto unlock;
+		}
+	}
+
 unlock:
 	mutex_unlock(&ps->smi_mutex);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6f9ed5d..e0692b9 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -457,11 +457,15 @@ int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
+int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_vlan *vlan,
+				struct switchdev_trans *trans);
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_vlan *vlan,
+			    struct switchdev_trans *trans);
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_vlan *vlan);
 int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *vid);
-int mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 vid);
-int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
-			    bool untagged);
-int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid);
 int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 			   unsigned long *ports, unsigned long *untagged);
 int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 98ccbde..82a4c60 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -200,6 +200,7 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 struct switchdev_trans;
 struct switchdev_obj;
 struct switchdev_obj_port_fdb;
+struct switchdev_obj_port_vlan;
 
 struct dsa_switch_driver {
 	struct list_head	list;
@@ -309,11 +310,15 @@ struct dsa_switch_driver {
 	/*
 	 * VLAN support
 	 */
+	int	(*port_vlan_prepare)(struct dsa_switch *ds, int port,
+				     const struct switchdev_obj_port_vlan *vlan,
+				     struct switchdev_trans *trans);
+	int	(*port_vlan_add)(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_vlan *vlan,
+				 struct switchdev_trans *trans);
+	int	(*port_vlan_del)(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_vlan *vlan);
 	int	(*port_pvid_get)(struct dsa_switch *ds, int port, u16 *pvid);
-	int	(*port_pvid_set)(struct dsa_switch *ds, int port, u16 pvid);
-	int	(*port_vlan_add)(struct dsa_switch *ds, int port, u16 vid,
-				 bool untagged);
-	int	(*port_vlan_del)(struct dsa_switch *ds, int port, u16 vid);
 	int	(*vlan_getnext)(struct dsa_switch *ds, u16 *vid,
 				unsigned long *ports, unsigned long *untagged);
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 481754e..7bc787b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -247,11 +247,10 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	u16 vid;
 	int err;
 
 	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->drv->port_vlan_add || !ds->drv->port_pvid_set)
+		if (!ds->drv->port_vlan_prepare || !ds->drv->port_vlan_add)
 			return -EOPNOTSUPP;
 
 		/* If the requested port doesn't belong to the same bridge as
@@ -262,16 +261,14 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 						  vlan->vid_end);
 		if (err)
 			return err;
+
+		err = ds->drv->port_vlan_prepare(ds, p->port, vlan, trans);
+		if (err)
+			return err;
 	} else {
-		for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-			err = ds->drv->port_vlan_add(ds, p->port, vid,
-						     vlan->flags &
-						     BRIDGE_VLAN_INFO_UNTAGGED);
-			if (!err && vlan->flags & BRIDGE_VLAN_INFO_PVID)
-				err = ds->drv->port_pvid_set(ds, p->port, vid);
-			if (err)
-				return err;
-		}
+		err = ds->drv->port_vlan_add(ds, p->port, vlan, trans);
+		if (err)
+			return err;
 	}
 
 	return 0;
@@ -282,19 +279,11 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	u16 vid;
-	int err;
 
 	if (!ds->drv->port_vlan_del)
 		return -EOPNOTSUPP;
 
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-		err = ds->drv->port_vlan_del(ds, p->port, vid);
-		if (err)
-			return err;
-	}
-
-	return 0;
+	return ds->drv->port_vlan_del(ds, p->port, vlan);
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
-- 
2.6.2
