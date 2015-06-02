From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 2/9] net: dsa: add basic support for VLAN operations
Date: Mon,  1 Jun 2015 21:27:43 -0400
Message-ID: <1433208470-25338-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"Scott Feldman" <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"Chris Healy" <cphealy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the glue between DSA and switchdev to add and delete
SWITCHDEV_OBJ_PORT_VLAN objects.

This will allow the DSA switch drivers implementing the port_vlan_add
and port_vlan_del functions to access the switch VLAN database through
userspace commands such as "bridge vlan".

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  7 +++++++
 net/dsa/slave.c   | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63b..726357b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -302,6 +302,13 @@ struct dsa_switch_driver {
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
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index cbda00a..52ba5a1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -363,6 +363,25 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	return ret;
 }
 
+static int dsa_slave_port_vlans_add(struct net_device *dev,
+				    struct switchdev_obj_vlan *vlan)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int vid, err = 0;
+
+	if (!ds->drv->port_vlan_add)
+		return -ENOTSUPP;
+
+	for (vid = vlan->vid_start; vid <= vlan->vid_end; ++vid) {
+		err = ds->drv->port_vlan_add(ds, p->port, vid, vlan->flags);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 static int dsa_slave_port_obj_add(struct net_device *dev,
 				  struct switchdev_obj *obj)
 {
@@ -378,6 +397,9 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 		return 0;
 
 	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = dsa_slave_port_vlans_add(dev, &obj->u.vlan);
+		break;
 	default:
 		err = -ENOTSUPP;
 		break;
@@ -386,12 +408,34 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	return err;
 }
 
+static int dsa_slave_port_vlans_del(struct net_device *dev,
+				    struct switchdev_obj_vlan *vlan)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int vid, err = 0;
+
+	if (!ds->drv->port_vlan_del)
+		return -ENOTSUPP;
+
+	for (vid = vlan->vid_start; vid <= vlan->vid_end; ++vid) {
+		err = ds->drv->port_vlan_del(ds, p->port, vid);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 static int dsa_slave_port_obj_del(struct net_device *dev,
 				  struct switchdev_obj *obj)
 {
 	int err;
 
 	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = dsa_slave_port_vlans_del(dev, &obj->u.vlan);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -473,6 +517,15 @@ static netdev_tx_t dsa_slave_notag_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static int dsa_slave_vlan_noop(struct net_device *dev, __be16 proto, u16 vid)
+{
+	/* NETIF_F_HW_VLAN_CTAG_FILTER requires ndo_vlan_rx_add_vid and
+	 * ndo_vlan_rx_kill_vid, otherwise the VLAN acceleration is considered
+	 * buggy (see net/core/dev.c).
+	 */
+	return 0;
+}
+
 
 /* ethtool operations *******************************************************/
 static int
@@ -734,6 +787,10 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_fdb_dump		= dsa_slave_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 	.ndo_get_iflink		= dsa_slave_get_iflink,
+	.ndo_vlan_rx_add_vid	= dsa_slave_vlan_noop,
+	.ndo_vlan_rx_kill_vid	= dsa_slave_vlan_noop,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
@@ -924,7 +981,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	if (slave_dev == NULL)
 		return -ENOMEM;
 
-	slave_dev->features = master->vlan_features;
+	slave_dev->features = master->vlan_features | NETIF_F_VLAN_FEATURES;
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->tx_queue_len = 0;
@@ -936,7 +993,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->dev.of_node = ds->pd->port_dn[port];
-	slave_dev->vlan_features = master->vlan_features;
+	slave_dev->vlan_features = slave_dev->features;
 
 	p = netdev_priv(slave_dev);
 	p->dev = slave_dev;
-- 
2.4.1
