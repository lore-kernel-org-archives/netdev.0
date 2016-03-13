From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 2/3] net: dsa: make port_bridge_leave return void
Date: Sun, 13 Mar 2016 01:42:25 -0500
Message-ID: <1457851346-26257-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34418 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbcCMGm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 01:42:59 -0500
In-Reply-To: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_upper_dev_unlink() which notifies NETDEV_CHANGEUPPER, returns
void, as well as del_nbp(). So there's no advantage to catch an eventual
error from the port_bridge_leave routine at the DSA level.

Make this routine void for the DSA layer and its existing drivers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c   |  4 +---
 drivers/net/dsa/mv88e6xxx.c | 28 +++++++++-------------------
 drivers/net/dsa/mv88e6xxx.h |  2 +-
 include/net/dsa.h           |  2 +-
 net/dsa/slave.c             |  9 +++------
 5 files changed, 15 insertions(+), 30 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 4bcc9eb..95944d5 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -516,7 +516,7 @@ static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static int bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
+static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	struct net_device *bridge = priv->port_sts[port].bridge_dev;
@@ -543,8 +543,6 @@ static int bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
 	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
 	priv->port_sts[port].vlan_ctl_mask = p_ctl;
 	priv->port_sts[port].bridge_dev = NULL;
-
-	return 0;
 }
 
 static int bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5f07524..448d4ef 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2219,39 +2219,29 @@ unlock:
 	return err;
 }
 
-int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
+void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct net_device *bridge = ps->ports[port].bridge_dev;
 	u16 fid;
-	int i, err;
+	int i;
 
 	mutex_lock(&ps->smi_mutex);
 
 	/* Give the port a fresh Filtering Information Database */
-	err = _mv88e6xxx_fid_new(ds, &fid);
-	if (err)
-		goto unlock;
-
-	err = _mv88e6xxx_port_fid_set(ds, port, fid);
-	if (err)
-		goto unlock;
+	if (_mv88e6xxx_fid_new(ds, &fid) ||
+	    _mv88e6xxx_port_fid_set(ds, port, fid))
+		netdev_warn(ds->ports[port], "failed to assign a new FID\n");
 
 	/* Unassign the bridge and remap each port's VLANTable */
 	ps->ports[port].bridge_dev = NULL;
 
-	for (i = 0; i < ps->num_ports; ++i) {
-		if (i == port || ps->ports[i].bridge_dev == bridge) {
-			err = _mv88e6xxx_port_based_vlan_map(ds, i);
-			if (err)
-				break;
-		}
-	}
+	for (i = 0; i < ps->num_ports; ++i)
+		if (i == port || ps->ports[i].bridge_dev == bridge)
+			if (_mv88e6xxx_port_based_vlan_map(ds, i))
+				netdev_warn(ds->ports[i], "failed to remap\n");
 
-unlock:
 	mutex_unlock(&ps->smi_mutex);
-
-	return err;
 }
 
 static void mv88e6xxx_bridge_work(struct work_struct *work)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 3425616..afd495c 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -488,7 +488,7 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e);
 int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 			       struct net_device *bridge);
-int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port);
+void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
 int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 				  bool vlan_filtering);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 004e034..6463bb2 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -298,7 +298,7 @@ struct dsa_switch_driver {
 	 */
 	int	(*port_bridge_join)(struct dsa_switch *ds, int port,
 				    struct net_device *bridge);
-	int	(*port_bridge_leave)(struct dsa_switch *ds, int port);
+	void	(*port_bridge_leave)(struct dsa_switch *ds, int port);
 	int	(*port_stp_update)(struct dsa_switch *ds, int port,
 				   u8 state);
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b997ee1..54976c4 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -454,15 +454,14 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	return ret;
 }
 
-static int dsa_slave_bridge_port_leave(struct net_device *dev)
+static void dsa_slave_bridge_port_leave(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
 
 
 	if (ds->drv->port_bridge_leave)
-		ret = ds->drv->port_bridge_leave(ds, p->port);
+		ds->drv->port_bridge_leave(ds, p->port);
 
 	p->bridge_dev = NULL;
 
@@ -470,8 +469,6 @@ static int dsa_slave_bridge_port_leave(struct net_device *dev)
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
 	 */
 	dsa_slave_stp_update(dev, BR_STATE_FORWARDING);
-
-	return ret;
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
@@ -1152,7 +1149,7 @@ static int dsa_slave_master_changed(struct net_device *dev)
 	    !strcmp(master->rtnl_link_ops->kind, "bridge"))
 		err = dsa_slave_bridge_port_join(dev, master);
 	else if (dsa_port_is_bridged(p))
-		err = dsa_slave_bridge_port_leave(dev);
+		dsa_slave_bridge_port_leave(dev);
 
 	return err;
 }
-- 
2.7.2
