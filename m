From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/7] net: dsa: add support for switchdev VLAN objects
Date: Thu, 13 Aug 2015 12:52:17 -0400
Message-ID: <1439484743-5126-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Chris Healy" <cphealy@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add new functions in DSA drivers to access hardware VLAN entries through
SWITCHDEV_OBJ_PORT_VLAN objects:

 - port_pvid_get() and vlan_getnext() to dump a VLAN
 - port_vlan_del() to exclude a port from a VLAN
 - port_pvid_set() and port_vlan_add() to join a port to a VLAN

The DSA infrastructure will ensure that each VLAN of the given range
does not already belong to another bridge. If it does, it will fallback
to software VLAN and won't program the hardware.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  11 ++++
 net/dsa/slave.c   | 158 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 169 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6356f43..bd9b765 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -298,6 +298,17 @@ struct dsa_switch_driver {
 				   u8 state);
 
 	/*
+	 * VLAN support
+	 */
+	int	(*port_pvid_get)(struct dsa_switch *ds, int port, u16 *pvid);
+	int	(*port_pvid_set)(struct dsa_switch *ds, int port, u16 pvid);
+	int	(*port_vlan_add)(struct dsa_switch *ds, int port, u16 vid,
+				 bool untagged);
+	int	(*port_vlan_del)(struct dsa_switch *ds, int port, u16 vid);
+	int	(*vlan_getnext)(struct dsa_switch *ds, u16 *vid,
+				unsigned long *ports, unsigned long *untagged);
+
+	/*
 	 * Forwarding database
 	 */
 	int	(*port_fdb_add)(struct dsa_switch *ds, int port,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2767584..880ead7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -200,6 +200,152 @@ out:
 	return 0;
 }
 
+static int dsa_bridge_check_vlan_range(struct dsa_switch *ds,
+				       const struct net_device *bridge,
+				       u16 vid_begin, u16 vid_end)
+{
+	struct dsa_slave_priv *p;
+	struct net_device *dev, *vlan_br;
+	DECLARE_BITMAP(members, DSA_MAX_PORTS);
+	DECLARE_BITMAP(untagged, DSA_MAX_PORTS);
+	u16 vid;
+	int member, err;
+
+	if (!ds->drv->vlan_getnext || !vid_begin)
+		return -EOPNOTSUPP;
+
+	vid = vid_begin - 1;
+
+	do {
+		err = ds->drv->vlan_getnext(ds, &vid, members, untagged);
+		if (err)
+			break;
+
+		if (vid > vid_end)
+			break;
+
+		member = find_first_bit(members, DSA_MAX_PORTS);
+		if (member == DSA_MAX_PORTS)
+			continue;
+
+		dev = ds->ports[member];
+		p = netdev_priv(dev);
+		vlan_br = p->bridge_dev;
+		if (vlan_br == bridge)
+			continue;
+
+		netdev_dbg(vlan_br, "hardware VLAN %d already in use\n", vid);
+		return -EOPNOTSUPP;
+	} while (vid < vid_end);
+
+	return err == -ENOENT ? 0 : err;
+}
+
+static int dsa_slave_port_vlan_add(struct net_device *dev,
+				   struct switchdev_obj *obj)
+{
+	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	u16 vid;
+	int err;
+
+	switch (obj->trans) {
+	case SWITCHDEV_TRANS_PREPARE:
+		if (!ds->drv->port_vlan_add || !ds->drv->port_pvid_set)
+			return -EOPNOTSUPP;
+
+		/* If the requested port doesn't belong to the same bridge as
+		 * the VLAN members, fallback to software VLAN (hopefully).
+		 */
+		err = dsa_bridge_check_vlan_range(ds, p->bridge_dev,
+						  vlan->vid_begin,
+						  vlan->vid_end);
+		if (err)
+			return err;
+		break;
+	case SWITCHDEV_TRANS_COMMIT:
+		for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+			err = ds->drv->port_vlan_add(ds, p->port, vid,
+						     vlan->flags &
+						     BRIDGE_VLAN_INFO_UNTAGGED);
+			if (!err && vlan->flags & BRIDGE_VLAN_INFO_PVID)
+				err = ds->drv->port_pvid_set(ds, p->port, vid);
+			if (err)
+				return err;
+		}
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int dsa_slave_port_vlan_del(struct net_device *dev,
+				   struct switchdev_obj *obj)
+{
+	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	u16 vid;
+	int err;
+
+	if (!ds->drv->port_vlan_del)
+		return -EOPNOTSUPP;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		err = ds->drv->port_vlan_del(ds, p->port, vid);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int dsa_slave_port_vlan_dump(struct net_device *dev,
+				    struct switchdev_obj *obj)
+{
+	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	DECLARE_BITMAP(members, DSA_MAX_PORTS);
+	DECLARE_BITMAP(untagged, DSA_MAX_PORTS);
+	u16 pvid, vid = 0;
+	int err;
+
+	if (!ds->drv->vlan_getnext || !ds->drv->port_pvid_get)
+		return -EOPNOTSUPP;
+
+	err = ds->drv->port_pvid_get(ds, p->port, &pvid);
+	if (err)
+		return err;
+
+	for (;;) {
+		err = ds->drv->vlan_getnext(ds, &vid, members, untagged);
+		if (err)
+			break;
+
+		if (!test_bit(p->port, members))
+			continue;
+
+		memset(vlan, 0, sizeof(*vlan));
+		vlan->vid_begin = vlan->vid_end = vid;
+
+		if (vid == pvid)
+			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
+
+		if (test_bit(p->port, untagged))
+			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+
+		err = obj->cb(dev, obj);
+		if (err)
+			break;
+	}
+
+	return err == -ENOENT ? 0 : err;
+}
+
 static int dsa_slave_port_fdb_add(struct net_device *dev,
 				  struct switchdev_obj *obj)
 {
@@ -341,6 +487,9 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	case SWITCHDEV_OBJ_PORT_FDB:
 		err = dsa_slave_port_fdb_add(dev, obj);
 		break;
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = dsa_slave_port_vlan_add(dev, obj);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -358,6 +507,9 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 	case SWITCHDEV_OBJ_PORT_FDB:
 		err = dsa_slave_port_fdb_del(dev, obj);
 		break;
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = dsa_slave_port_vlan_del(dev, obj);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -375,6 +527,9 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	case SWITCHDEV_OBJ_PORT_FDB:
 		err = dsa_slave_port_fdb_dump(dev, obj);
 		break;
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = dsa_slave_port_vlan_dump(dev, obj);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -794,6 +949,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_netpoll_cleanup	= dsa_slave_netpoll_cleanup,
 	.ndo_poll_controller	= dsa_slave_poll_controller,
 #endif
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
-- 
2.5.0
