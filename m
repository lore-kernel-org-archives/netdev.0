From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 05/20] net: dsa: pass dsa_port down to drivers VLAN ops
Date: Wed, 27 Apr 2016 18:30:02 -0400
Message-ID: <1461796217-18893-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that DSA as proper structure for DSA ports, pass it down to the
port_vlan_{filtering,prepare,add,del,dump} driver functions.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 41 +++++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx.h | 10 +++++-----
 include/net/dsa.h           | 11 ++++++-----
 net/dsa/slave.c             | 10 +++++-----
 4 files changed, 37 insertions(+), 35 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index c1ff763..7e03f4c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1367,7 +1367,7 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds,
 	return 0;
 }
 
-int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, struct dsa_port *dp,
 			     struct switchdev_obj_port_vlan *vlan,
 			     int (*cb)(struct switchdev_obj *obj))
 {
@@ -1378,7 +1378,7 @@ int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	err = _mv88e6xxx_port_pvid_get(ds, port, &pvid);
+	err = _mv88e6xxx_port_pvid_get(ds, dp->port, &pvid);
 	if (err)
 		goto unlock;
 
@@ -1394,14 +1394,15 @@ int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 		if (!next.valid)
 			break;
 
-		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+		if (next.data[dp->port] ==
+		    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 			continue;
 
 		/* reinit and dump this VLAN obj */
 		vlan->vid_begin = vlan->vid_end = next.vid;
 		vlan->flags = 0;
 
-		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
+		if (next.data[dp->port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
 			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
 		if (next.vid == pvid)
@@ -1789,7 +1790,7 @@ static const char * const mv88e6xxx_port_8021q_mode_names[] = {
 	[PORT_CONTROL_2_8021Q_SECURE] = "Secure",
 };
 
-int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, struct dsa_port *dp,
 				  bool vlan_filtering)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1799,7 +1800,7 @@ int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_CONTROL_2);
+	ret = _mv88e6xxx_reg_read(ds, REG_PORT(dp->port), PORT_CONTROL_2);
 	if (ret < 0)
 		goto unlock;
 
@@ -1809,12 +1810,12 @@ int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 		ret &= ~PORT_CONTROL_2_8021Q_MASK;
 		ret |= new & PORT_CONTROL_2_8021Q_MASK;
 
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_2,
-					   ret);
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
+					   PORT_CONTROL_2, ret);
 		if (ret < 0)
 			goto unlock;
 
-		netdev_dbg(ds->ports[port], "802.1Q Mode %s (was %s)\n",
+		netdev_dbg(ds->ports[dp->port], "802.1Q Mode %s (was %s)\n",
 			   mv88e6xxx_port_8021q_mode_names[new],
 			   mv88e6xxx_port_8021q_mode_names[old]);
 	}
@@ -1826,7 +1827,7 @@ unlock:
 	return ret;
 }
 
-int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 				const struct switchdev_obj_port_vlan *vlan,
 				struct switchdev_trans *trans)
 {
@@ -1835,7 +1836,7 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 	/* If the requested port doesn't belong to the same bridge as the VLAN
 	 * members, do not support it (yet) and fallback to software VLAN.
 	 */
-	err = mv88e6xxx_port_check_hw_vlan(ds, port, vlan->vid_begin,
+	err = mv88e6xxx_port_check_hw_vlan(ds, dp->port, vlan->vid_begin,
 					   vlan->vid_end);
 	if (err)
 		return err;
@@ -1863,7 +1864,7 @@ static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 	return _mv88e6xxx_vtu_loadpurge(ds, &vlan);
 }
 
-void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
+void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, struct dsa_port *dp,
 			     const struct switchdev_obj_port_vlan *vlan,
 			     struct switchdev_trans *trans)
 {
@@ -1875,12 +1876,12 @@ void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 	mutex_lock(&ps->smi_mutex);
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
-		if (_mv88e6xxx_port_vlan_add(ds, port, vid, untagged))
-			netdev_err(ds->ports[port], "failed to add VLAN %d%c\n",
+		if (_mv88e6xxx_port_vlan_add(ds, dp->port, vid, untagged))
+			netdev_err(ds->ports[dp->port], "failed to add VLAN %d%c\n",
 				   vid, untagged ? 'u' : 't');
 
-	if (pvid && _mv88e6xxx_port_pvid_set(ds, port, vlan->vid_end))
-		netdev_err(ds->ports[port], "failed to set PVID %d\n",
+	if (pvid && _mv88e6xxx_port_pvid_set(ds, dp->port, vlan->vid_end))
+		netdev_err(ds->ports[dp->port], "failed to set PVID %d\n",
 			   vlan->vid_end);
 
 	mutex_unlock(&ps->smi_mutex);
@@ -1921,7 +1922,7 @@ static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 	return _mv88e6xxx_atu_remove(ds, vlan.fid, port, false);
 }
 
-int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, struct dsa_port *dp,
 			    const struct switchdev_obj_port_vlan *vlan)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1930,17 +1931,17 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	err = _mv88e6xxx_port_pvid_get(ds, port, &pvid);
+	err = _mv88e6xxx_port_pvid_get(ds, dp->port, &pvid);
 	if (err)
 		goto unlock;
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-		err = _mv88e6xxx_port_vlan_del(ds, port, vid);
+		err = _mv88e6xxx_port_vlan_del(ds, dp->port, vid);
 		if (err)
 			goto unlock;
 
 		if (vid == pvid) {
-			err = _mv88e6xxx_port_pvid_set(ds, port, 0);
+			err = _mv88e6xxx_port_pvid_set(ds, dp->port, 0);
 			if (err)
 				goto unlock;
 		}
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 0b6c37a..c49a514 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -495,17 +495,17 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, struct dsa_port *dp,
 void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, struct dsa_port *dp,
 				 struct net_device *bridge);
 void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port, u8 state);
-int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, struct dsa_port *dp,
 				  bool vlan_filtering);
-int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 				const struct switchdev_obj_port_vlan *vlan,
 				struct switchdev_trans *trans);
-void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
+void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, struct dsa_port *dp,
 			     const struct switchdev_obj_port_vlan *vlan,
 			     struct switchdev_trans *trans);
-int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, struct dsa_port *dp,
 			    const struct switchdev_obj_port_vlan *vlan);
-int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, struct dsa_port *dp,
 			     struct switchdev_obj_port_vlan *vlan,
 			     int (*cb)(struct switchdev_obj *obj));
 int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, struct dsa_port *dp,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 65bbf72..08a9536 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -313,17 +313,18 @@ struct dsa_switch_driver {
 	/*
 	 * VLAN support
 	 */
-	int	(*port_vlan_filtering)(struct dsa_switch *ds, int port,
+	int	(*port_vlan_filtering)(struct dsa_switch *ds,
+				       struct dsa_port *dp,
 				       bool vlan_filtering);
-	int	(*port_vlan_prepare)(struct dsa_switch *ds, int port,
+	int	(*port_vlan_prepare)(struct dsa_switch *ds, struct dsa_port *dp,
 				     const struct switchdev_obj_port_vlan *vlan,
 				     struct switchdev_trans *trans);
-	void	(*port_vlan_add)(struct dsa_switch *ds, int port,
+	void	(*port_vlan_add)(struct dsa_switch *ds, struct dsa_port *dp,
 				 const struct switchdev_obj_port_vlan *vlan,
 				 struct switchdev_trans *trans);
-	int	(*port_vlan_del)(struct dsa_switch *ds, int port,
+	int	(*port_vlan_del)(struct dsa_switch *ds, struct dsa_port *dp,
 				 const struct switchdev_obj_port_vlan *vlan);
-	int	(*port_vlan_dump)(struct dsa_switch *ds, int port,
+	int	(*port_vlan_dump)(struct dsa_switch *ds, struct dsa_port *dp,
 				  struct switchdev_obj_port_vlan *vlan,
 				  int (*cb)(struct switchdev_obj *obj));
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1afcbc4..d6b6019 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -212,10 +212,10 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 		if (!ds->drv->port_vlan_prepare || !ds->drv->port_vlan_add)
 			return -EOPNOTSUPP;
 
-		return ds->drv->port_vlan_prepare(ds, p->dp->port, vlan, trans);
+		return ds->drv->port_vlan_prepare(ds, p->dp, vlan, trans);
 	}
 
-	ds->drv->port_vlan_add(ds, p->dp->port, vlan, trans);
+	ds->drv->port_vlan_add(ds, p->dp, vlan, trans);
 
 	return 0;
 }
@@ -229,7 +229,7 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 	if (!ds->drv->port_vlan_del)
 		return -EOPNOTSUPP;
 
-	return ds->drv->port_vlan_del(ds, p->dp->port, vlan);
+	return ds->drv->port_vlan_del(ds, p->dp, vlan);
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
@@ -240,7 +240,7 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->port_vlan_dump)
-		return ds->drv->port_vlan_dump(ds, p->dp->port, vlan, cb);
+		return ds->drv->port_vlan_dump(ds, p->dp, vlan, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -327,7 +327,7 @@ static int dsa_slave_vlan_filtering(struct net_device *dev,
 		return 0;
 
 	if (ds->drv->port_vlan_filtering)
-		return ds->drv->port_vlan_filtering(ds, p->dp->port,
+		return ds->drv->port_vlan_filtering(ds, p->dp,
 						    attr->u.vlan_filtering);
 
 	return 0;
-- 
2.8.0
