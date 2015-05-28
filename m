From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 1/3] net: dsa: add basic support for VLAN ndo
Date: Thu, 28 May 2015 17:37:13 -0400
Message-ID: <1432849035-8499-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <556723FF.7030606@roeck-us.net>
 <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:55767 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754745AbbE1VhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 17:37:22 -0400
In-Reply-To: <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ndo_vlan_rx_add_vid, ndo_vlan_rx_kill_vid, and
ndo_bridge_setlink wrapper operations, used to create and remove VLAN
entries in a DSA switch VLAN database.

The switch drivers have to implement the port_vlan_add, port_vlan_kill,
and port_bridge_setlink functions, in order to support VLANs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  9 +++++++
 net/dsa/slave.c   | 76 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 83 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63b..cf02357 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -19,6 +19,7 @@
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/ethtool.h>
+#include <uapi/linux/if_bridge.h>
 
 enum dsa_tag_protocol {
 	DSA_TAG_PROTO_NONE = 0,
@@ -302,6 +303,14 @@ struct dsa_switch_driver {
 			   const unsigned char *addr, u16 vid);
 	int	(*fdb_getnext)(struct dsa_switch *ds, int port,
 			       unsigned char *addr, bool *is_static);
+
+	/*
+	 * VLAN support
+	 */
+	int	(*port_vlan_add)(struct dsa_switch *ds, int port, u16 vid);
+	int	(*port_vlan_kill)(struct dsa_switch *ds, int port, u16 vid);
+	int	(*port_bridge_setlink)(struct dsa_switch *ds, int port,
+				       struct bridge_vlan_info *vinfo);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 827cda56..72c3ff0 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -412,6 +412,71 @@ static netdev_tx_t dsa_slave_notag_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static int dsa_slave_vlan_rx_add_vid(struct net_device *dev,
+				     __be16 proto, u16 vid)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (!ds->drv->port_vlan_add)
+		return -EOPNOTSUPP;
+
+	netdev_dbg(dev, "adding to VLAN %d\n", vid);
+
+	return ds->drv->port_vlan_add(ds, p->port, vid);
+}
+
+static int dsa_slave_vlan_rx_kill_vid(struct net_device *dev,
+				      __be16 proto, u16 vid)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (!ds->drv->port_vlan_kill)
+		return -EOPNOTSUPP;
+
+	netdev_dbg(dev, "removing from VLAN %d\n", vid);
+
+	return ds->drv->port_vlan_kill(ds, p->port, vid);
+}
+
+static int dsa_slave_bridge_setlink(struct net_device *dev,
+				    struct nlmsghdr *nlh, u16 flags)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	struct nlattr *afspec;
+	struct nlattr *attr;
+	struct bridge_vlan_info *vinfo = NULL;
+	int rem;
+
+	if (!ds->drv->port_bridge_setlink)
+		return -EOPNOTSUPP;
+
+	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
+	if (!afspec)
+		return -EINVAL;
+
+	nla_for_each_nested(attr, afspec, rem) {
+		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
+			continue;
+
+		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
+			return -EINVAL;
+
+		vinfo = nla_data(attr);
+	}
+
+	if (!vinfo)
+		return -EINVAL;
+
+	netdev_dbg(dev, "setting link to VLAN %d%s%s\n", vinfo->vid,
+		   vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED ?  " untagged" : "",
+		   vinfo->flags & BRIDGE_VLAN_INFO_PVID ? " (default)" : "");
+
+	return ds->drv->port_bridge_setlink(ds, p->port, vinfo);
+}
+
 
 /* ethtool operations *******************************************************/
 static int
@@ -673,6 +738,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_fdb_dump		= dsa_slave_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 	.ndo_get_iflink		= dsa_slave_get_iflink,
+	.ndo_vlan_rx_add_vid	= dsa_slave_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= dsa_slave_vlan_rx_kill_vid,
+	.ndo_bridge_setlink	= dsa_slave_bridge_setlink,
 };
 
 static const struct swdev_ops dsa_slave_swdev_ops = {
@@ -854,7 +922,9 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	if (slave_dev == NULL)
 		return -ENOMEM;
 
-	slave_dev->features = master->vlan_features;
+	slave_dev->features = master->vlan_features |
+		NETIF_F_VLAN_FEATURES |
+		NETIF_F_HW_SWITCH_OFFLOAD;
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->tx_queue_len = 0;
@@ -863,7 +933,9 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->dev.of_node = ds->pd->port_dn[port];
-	slave_dev->vlan_features = master->vlan_features;
+	slave_dev->vlan_features = master->vlan_features |
+		NETIF_F_VLAN_FEATURES |
+		NETIF_F_HW_SWITCH_OFFLOAD;
 
 	p = netdev_priv(slave_dev);
 	p->dev = slave_dev;
-- 
2.4.1
