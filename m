From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/5] net: dsa: use slave device phydev
Date: Tue, 26 Sep 2017 17:15:32 -0400
Message-ID: <20170926211535.21273-3-vivien.didelot@savoirfairelinux.com>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41230 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937274AbdIZVTZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 17:19:25 -0400
In-Reply-To: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to store a phy_device in dsa_slave_priv since
net_device already provides one. Simply s/p->phy/dev->phydev/.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |   1 -
 net/dsa/slave.c    | 116 ++++++++++++++++++++++++-----------------------------
 2 files changed, 53 insertions(+), 64 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 0298a0f6a349..eccc62776283 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -79,7 +79,6 @@ struct dsa_slave_priv {
 	 * The phylib phy_device pointer for the PHY connected
 	 * to this port.
 	 */
-	struct phy_device	*phy;
 	phy_interface_t		phy_interface;
 	int			old_link;
 	int			old_pause;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 79c5a0cd9923..4ea1c6eb0da8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -96,12 +96,12 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_allmulti;
 	}
 
-	err = dsa_port_enable(dp, p->phy);
+	err = dsa_port_enable(dp, dev->phydev);
 	if (err)
 		goto clear_promisc;
 
-	if (p->phy)
-		phy_start(p->phy);
+	if (dev->phydev)
+		phy_start(dev->phydev);
 
 	return 0;
 
@@ -124,10 +124,10 @@ static int dsa_slave_close(struct net_device *dev)
 	struct net_device *master = dsa_master_netdev(p);
 	struct dsa_port *dp = p->dp;
 
-	if (p->phy)
-		phy_stop(p->phy);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 
-	dsa_port_disable(dp, p->phy);
+	dsa_port_disable(dp, dev->phydev);
 
 	dev_mc_unsync(master, dev);
 	dev_uc_unsync(master, dev);
@@ -264,12 +264,10 @@ dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-
-	if (!p->phy)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(p->phy, ifr, cmd);
+	return phy_mii_ioctl(dev->phydev, ifr, cmd);
 }
 
 static int dsa_slave_port_attr_set(struct net_device *dev,
@@ -426,12 +424,10 @@ static int
 dsa_slave_get_link_ksettings(struct net_device *dev,
 			     struct ethtool_link_ksettings *cmd)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-
-	if (!p->phy)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	phy_ethtool_ksettings_get(p->phy, cmd);
+	phy_ethtool_ksettings_get(dev->phydev, cmd);
 
 	return 0;
 }
@@ -440,12 +436,10 @@ static int
 dsa_slave_set_link_ksettings(struct net_device *dev,
 			     const struct ethtool_link_ksettings *cmd)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-
-	if (!p->phy)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_ksettings_set(p->phy, cmd);
+	return phy_ethtool_ksettings_set(dev->phydev, cmd);
 }
 
 static void dsa_slave_get_drvinfo(struct net_device *dev,
@@ -479,24 +473,20 @@ dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
 
 static int dsa_slave_nway_reset(struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-
-	if (!p->phy)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return genphy_restart_aneg(p->phy);
+	return genphy_restart_aneg(dev->phydev);
 }
 
 static u32 dsa_slave_get_link(struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-
-	if (!p->phy)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	genphy_update_link(p->phy);
+	genphy_update_link(dev->phydev);
 
-	return p->phy->link;
+	return dev->phydev->link;
 }
 
 static int dsa_slave_get_eeprom_len(struct net_device *dev)
@@ -631,7 +621,7 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	int ret;
 
 	/* Port's PHY and MAC both need to be EEE capable */
-	if (!p->phy)
+	if (!dev->phydev)
 		return -ENODEV;
 
 	if (!ds->ops->set_mac_eee)
@@ -642,12 +632,12 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 		return ret;
 
 	if (e->eee_enabled) {
-		ret = phy_init_eee(p->phy, 0);
+		ret = phy_init_eee(dev->phydev, 0);
 		if (ret)
 			return ret;
 	}
 
-	return phy_ethtool_set_eee(p->phy, e);
+	return phy_ethtool_set_eee(dev->phydev, e);
 }
 
 static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
@@ -657,7 +647,7 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	int ret;
 
 	/* Port's PHY and MAC both need to be EEE capable */
-	if (!p->phy)
+	if (!dev->phydev)
 		return -ENODEV;
 
 	if (!ds->ops->get_mac_eee)
@@ -667,7 +657,7 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (ret)
 		return ret;
 
-	return phy_ethtool_get_eee(p->phy, e);
+	return phy_ethtool_get_eee(dev->phydev, e);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -976,26 +966,26 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 	struct dsa_switch *ds = p->dp->ds;
 	unsigned int status_changed = 0;
 
-	if (p->old_link != p->phy->link) {
+	if (p->old_link != dev->phydev->link) {
 		status_changed = 1;
-		p->old_link = p->phy->link;
+		p->old_link = dev->phydev->link;
 	}
 
-	if (p->old_duplex != p->phy->duplex) {
+	if (p->old_duplex != dev->phydev->duplex) {
 		status_changed = 1;
-		p->old_duplex = p->phy->duplex;
+		p->old_duplex = dev->phydev->duplex;
 	}
 
-	if (p->old_pause != p->phy->pause) {
+	if (p->old_pause != dev->phydev->pause) {
 		status_changed = 1;
-		p->old_pause = p->phy->pause;
+		p->old_pause = dev->phydev->pause;
 	}
 
 	if (ds->ops->adjust_link && status_changed)
-		ds->ops->adjust_link(ds, p->dp->index, p->phy);
+		ds->ops->adjust_link(ds, p->dp->index, dev->phydev);
 
 	if (status_changed)
-		phy_print_status(p->phy);
+		phy_print_status(dev->phydev);
 }
 
 static int dsa_slave_fixed_link_update(struct net_device *dev,
@@ -1020,17 +1010,18 @@ static int dsa_slave_phy_connect(struct net_device *slave_dev, int addr)
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
 	struct dsa_switch *ds = p->dp->ds;
 
-	p->phy = mdiobus_get_phy(ds->slave_mii_bus, addr);
-	if (!p->phy) {
+	slave_dev->phydev = mdiobus_get_phy(ds->slave_mii_bus, addr);
+	if (!slave_dev->phydev) {
 		netdev_err(slave_dev, "no phy at %d\n", addr);
 		return -ENODEV;
 	}
 
 	/* Use already configured phy mode */
 	if (p->phy_interface == PHY_INTERFACE_MODE_NA)
-		p->phy_interface = p->phy->interface;
-	return phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
-				  p->phy_interface);
+		p->phy_interface = slave_dev->phydev->interface;
+
+	return phy_connect_direct(slave_dev, slave_dev->phydev,
+				  dsa_slave_adjust_link, p->phy_interface);
 }
 
 static int dsa_slave_phy_setup(struct net_device *slave_dev)
@@ -1082,22 +1073,23 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
 				return ret;
 			}
 		} else {
-			p->phy = of_phy_connect(slave_dev, phy_dn,
-						dsa_slave_adjust_link,
-						phy_flags,
-						p->phy_interface);
+			slave_dev->phydev = of_phy_connect(slave_dev, phy_dn,
+							   dsa_slave_adjust_link,
+							   phy_flags,
+							   p->phy_interface);
 		}
 
 		of_node_put(phy_dn);
 	}
 
-	if (p->phy && phy_is_fixed)
-		fixed_phy_set_link_update(p->phy, dsa_slave_fixed_link_update);
+	if (slave_dev->phydev && phy_is_fixed)
+		fixed_phy_set_link_update(slave_dev->phydev,
+					  dsa_slave_fixed_link_update);
 
 	/* We could not connect to a designated PHY, so use the switch internal
 	 * MDIO bus instead
 	 */
-	if (!p->phy) {
+	if (!slave_dev->phydev) {
 		ret = dsa_slave_phy_connect(slave_dev, p->dp->index);
 		if (ret) {
 			netdev_err(slave_dev, "failed to connect to port %d: %d\n",
@@ -1108,7 +1100,7 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
 		}
 	}
 
-	phy_attached_info(p->phy);
+	phy_attached_info(slave_dev->phydev);
 
 	return 0;
 }
@@ -1128,12 +1120,12 @@ int dsa_slave_suspend(struct net_device *slave_dev)
 
 	netif_device_detach(slave_dev);
 
-	if (p->phy) {
-		phy_stop(p->phy);
+	if (slave_dev->phydev) {
+		phy_stop(slave_dev->phydev);
 		p->old_pause = -1;
 		p->old_link = -1;
 		p->old_duplex = -1;
-		phy_suspend(p->phy);
+		phy_suspend(slave_dev->phydev);
 	}
 
 	return 0;
@@ -1141,13 +1133,11 @@ int dsa_slave_suspend(struct net_device *slave_dev)
 
 int dsa_slave_resume(struct net_device *slave_dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(slave_dev);
-
 	netif_device_attach(slave_dev);
 
-	if (p->phy) {
-		phy_resume(p->phy);
-		phy_start(p->phy);
+	if (slave_dev->phydev) {
+		phy_resume(slave_dev->phydev);
+		phy_start(slave_dev->phydev);
 	}
 
 	return 0;
@@ -1240,8 +1230,8 @@ void dsa_slave_destroy(struct net_device *slave_dev)
 	port_dn = p->dp->dn;
 
 	netif_carrier_off(slave_dev);
-	if (p->phy) {
-		phy_disconnect(p->phy);
+	if (slave_dev->phydev) {
+		phy_disconnect(slave_dev->phydev);
 
 		if (of_phy_is_fixed_link(port_dn))
 			of_phy_deregister_fixed_link(port_dn);
-- 
2.14.1
