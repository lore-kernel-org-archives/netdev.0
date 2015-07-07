From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 2/3] net: dsa: add support for switchdev VLAN objects
Date: Tue,  7 Jul 2015 17:18:19 -0400
Message-ID: <1436303900-24259-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:51637 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933290AbbGGVS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 17:18:28 -0400
In-Reply-To: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the glue between DSA and switchdev operations to add,
delete and dump SWITCHDEV_OBJ_PORT_VLAN objects.

This is a first step to link the "bridge vlan" command with hardware
entries for DSA compatible switch chips.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  |   9 ++++
 net/dsa/dsa_priv.h |   6 +++
 net/dsa/slave.c    | 142 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 157 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63b..cabf2a5 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -302,6 +302,15 @@ struct dsa_switch_driver {
 			   const unsigned char *addr, u16 vid);
 	int	(*fdb_getnext)(struct dsa_switch *ds, int port,
 			       unsigned char *addr, bool *is_static);
+
+	/*
+	 * VLAN support
+	 */
+	int	(*port_vlan_add)(struct dsa_switch *ds, int port, u16 vid,
+				 u16 bridge_flags);
+	int	(*port_vlan_del)(struct dsa_switch *ds, int port, u16 vid);
+	int	(*port_vlan_dump)(struct dsa_switch *ds, int port, u16 vid,
+				  u16 *bridge_flags);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d5f1f9b..9029717 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -13,6 +13,7 @@
 
 #include <linux/phy.h>
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 
 struct dsa_device_ops {
 	netdev_tx_t (*xmit)(struct sk_buff *skb, struct net_device *dev);
@@ -47,6 +48,11 @@ struct dsa_slave_priv {
 	int			old_duplex;
 
 	struct net_device	*bridge_dev;
+
+	/*
+	 * Which VLANs this port is a member of.
+	 */
+	DECLARE_BITMAP(vlan_bitmap, VLAN_N_VID);
 };
 
 /* dsa.c */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 04ffad3..1da861e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -18,6 +18,7 @@
 #include <net/rtnetlink.h>
 #include <net/switchdev.h>
 #include <linux/if_bridge.h>
+#include <linux/if_vlan.h>
 #include "dsa_priv.h"
 
 /* slave mii_bus handling ***************************************************/
@@ -363,6 +364,141 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	return ret;
 }
 
+static int dsa_slave_port_vlans_add(struct net_device *dev,
+				     struct switchdev_obj *obj)
+{
+	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int vid, err = 0;
+
+	if (!ds->drv->port_vlan_add)
+		return -EOPNOTSUPP;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		err = ds->drv->port_vlan_add(ds, p->port, vid, vlan->flags);
+		if (err)
+			break;
+		set_bit(vid, p->vlan_bitmap);
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_obj_add(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	int err = -EOPNOTSUPP;
+
+	/*
+	 * The DSA drivers don't need to allocate any memory for operations on
+	 * prepare phase, and they won't fail to HW on commit phase (unless
+	 * something terrible goes wrong on the MDIO bus, in which case the
+	 * commit phase wouldn't have been able to predict anyway).
+	 *
+	 * If an object is supported, skip the prepare phase by returning 0,
+	 * otherwise return -EOPNOTSUPP.
+	 */
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		if (obj->trans == SWITCHDEV_TRANS_PREPARE)
+			return 0;
+
+		if (obj->trans == SWITCHDEV_TRANS_COMMIT)
+			err = dsa_slave_port_vlans_add(dev, obj);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_vlans_del(struct net_device *dev,
+				     struct switchdev_obj *obj)
+{
+	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int vid, err = 0;
+
+	if (!ds->drv->port_vlan_del)
+		return -EOPNOTSUPP;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		err = ds->drv->port_vlan_del(ds, p->port, vid);
+		if (err)
+			break;
+		clear_bit(vid, p->vlan_bitmap);
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_obj_del(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	int err;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = dsa_slave_port_vlans_del(dev, obj);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_vlans_dump(struct net_device *dev,
+				     struct switchdev_obj *obj)
+{
+	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int vid, err = 0;
+
+	if (!ds->drv->port_vlan_dump)
+		return -EOPNOTSUPP;
+
+	for_each_set_bit(vid, p->vlan_bitmap, VLAN_N_VID) {
+		u16 flags = 0;
+
+		err = ds->drv->port_vlan_dump(ds, p->port, vid, &flags);
+		if (err)
+			break;
+
+		vlan->flags = flags;
+		vlan->vid_begin = vlan->vid_end = vid;
+		err = obj->cb(dev, obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_obj_dump(struct net_device *dev,
+				   struct switchdev_obj *obj)
+{
+	int err;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = dsa_slave_port_vlans_dump(dev, obj);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
 static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
@@ -697,11 +833,17 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_fdb_dump		= dsa_slave_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 	.ndo_get_iflink		= dsa_slave_get_iflink,
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_attr_get	= dsa_slave_port_attr_get,
 	.switchdev_port_attr_set	= dsa_slave_port_attr_set,
+	.switchdev_port_obj_add		= dsa_slave_port_obj_add,
+	.switchdev_port_obj_del		= dsa_slave_port_obj_del,
+	.switchdev_port_obj_dump	= dsa_slave_port_obj_dump,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
-- 
2.4.5
