From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/5] net: dsa: split dsa_port's netdev member
Date: Thu, 12 Oct 2017 18:51:56 -0400
Message-ID: <20171012225156.20758-6-vivien.didelot@savoirfairelinux.com>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa_port structure has a "netdev" member, which can be used for
either the master device, or the slave device, depending on its type.

It is true that today, CPU port are not exposed to userspace, thus the
port's netdev member can be used to point to its master interface.

But it is still slightly confusing, so split it into more explicit
"master" and "slave" members.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c        |  6 +++---
 drivers/net/dsa/mt7530.c         |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c |  2 +-
 include/net/dsa.h                |  7 ++++++-
 net/dsa/dsa.c                    |  6 +++---
 net/dsa/dsa2.c                   | 22 +++++++++++-----------
 net/dsa/dsa_priv.h               |  4 ++--
 net/dsa/legacy.c                 | 14 +++++++-------
 net/dsa/slave.c                  |  6 +++---
 9 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 32025b990437..b43c063b9634 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -601,7 +601,7 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 		 * state machine and make it go in PHY_FORCING state instead.
 		 */
 		if (!status->link)
-			netif_carrier_off(ds->ports[port].netdev);
+			netif_carrier_off(ds->ports[port].slave);
 		status->duplex = 1;
 	} else {
 		status->link = 1;
@@ -690,7 +690,7 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 			       struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->ports[port].cpu_dp->netdev;
+	struct net_device *p = ds->ports[port].cpu_dp->master;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_wolinfo pwol;
 
@@ -713,7 +713,7 @@ static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 			      struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->ports[port].cpu_dp->netdev;
+	struct net_device *p = ds->ports[port].cpu_dp->master;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	s8 cpu_port = ds->ports[port].cpu_dp->index;
 	struct ethtool_wolinfo pwol;
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 034241696ce2..fea2e665d0cb 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -933,7 +933,7 @@ mt7530_setup(struct dsa_switch *ds)
 	 * controller also is the container for two GMACs nodes representing
 	 * as two netdev instances.
 	 */
-	dn = ds->ports[MT7530_CPU_PORT].netdev->dev.of_node->parent;
+	dn = ds->ports[MT7530_CPU_PORT].master->dev.of_node->parent;
 	priv->ethernet = syscon_node_to_regmap(dn);
 	if (IS_ERR(priv->ethernet))
 		return PTR_ERR(priv->ethernet);
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d74c7335c512..955f4e214191 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1124,7 +1124,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
 				continue;
 
-			if (!ds->ports[port].netdev)
+			if (!ds->ports[port].slave)
 				continue;
 
 			if (vlan.member[i] ==
diff --git a/include/net/dsa.h b/include/net/dsa.h
index ce1d622734d7..4c769bc8a8b5 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -164,6 +164,12 @@ struct dsa_mall_tc_entry {
 
 
 struct dsa_port {
+	/* Master device, physically connected if this is a CPU port */
+	struct net_device *master;
+
+	/* Slave device, if this port is exposed to userspace */
+	struct net_device *slave;
+
 	/* CPU port tagging operations used by master or slave devices */
 	const struct dsa_device_ops *tag_ops;
 
@@ -176,7 +182,6 @@ struct dsa_port {
 	unsigned int		index;
 	const char		*name;
 	struct dsa_port		*cpu_dp;
-	struct net_device	*netdev;
 	struct device_node	*dn;
 	unsigned int		ageing_time;
 	u8			stp_state;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 832c659ff993..a3abf7a7b9a2 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -201,7 +201,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 #ifdef CONFIG_PM_SLEEP
 static bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 {
-	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
+	return ds->enabled_port_mask & (1 << p) && ds->ports[p].slave;
 }
 
 int dsa_switch_suspend(struct dsa_switch *ds)
@@ -213,7 +213,7 @@ int dsa_switch_suspend(struct dsa_switch *ds)
 		if (!dsa_is_port_initialized(ds, i))
 			continue;
 
-		ret = dsa_slave_suspend(ds->ports[i].netdev);
+		ret = dsa_slave_suspend(ds->ports[i].slave);
 		if (ret)
 			return ret;
 	}
@@ -240,7 +240,7 @@ int dsa_switch_resume(struct dsa_switch *ds)
 		if (!dsa_is_port_initialized(ds, i))
 			continue;
 
-		ret = dsa_slave_resume(ds->ports[i].netdev);
+		ret = dsa_slave_resume(ds->ports[i].slave);
 		if (ret)
 			return ret;
 	}
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 54ed054777bd..5ac78edd756f 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -279,7 +279,7 @@ static int dsa_user_port_apply(struct dsa_port *port)
 	if (err) {
 		dev_warn(ds->dev, "Failed to create slave %d: %d\n",
 			 port->index, err);
-		port->netdev = NULL;
+		port->slave = NULL;
 		return err;
 	}
 
@@ -289,7 +289,7 @@ static int dsa_user_port_apply(struct dsa_port *port)
 	if (err)
 		return err;
 
-	devlink_port_type_eth_set(&port->devlink_port, port->netdev);
+	devlink_port_type_eth_set(&port->devlink_port, port->slave);
 
 	return 0;
 }
@@ -297,9 +297,9 @@ static int dsa_user_port_apply(struct dsa_port *port)
 static void dsa_user_port_unapply(struct dsa_port *port)
 {
 	devlink_port_unregister(&port->devlink_port);
-	if (port->netdev) {
-		dsa_slave_destroy(port->netdev);
-		port->netdev = NULL;
+	if (port->slave) {
+		dsa_slave_destroy(port->slave);
+		port->slave = NULL;
 		port->ds->enabled_port_mask &= ~(1 << port->index);
 	}
 }
@@ -337,7 +337,7 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 		return err;
 
 	if (ds->ops->set_addr) {
-		err = ds->ops->set_addr(ds, dst->cpu_dp->netdev->dev_addr);
+		err = ds->ops->set_addr(ds, dst->cpu_dp->master->dev_addr);
 		if (err < 0)
 			return err;
 	}
@@ -438,9 +438,9 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dst->cpu_dp->netdev->dsa_ptr = dst->cpu_dp;
+	dst->cpu_dp->master->dsa_ptr = dst->cpu_dp;
 
-	err = dsa_master_ethtool_setup(dst->cpu_dp->netdev);
+	err = dsa_master_ethtool_setup(dst->cpu_dp->master);
 	if (err)
 		return err;
 
@@ -457,9 +457,9 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	if (!dst->applied)
 		return;
 
-	dsa_master_ethtool_restore(dst->cpu_dp->netdev);
+	dsa_master_ethtool_restore(dst->cpu_dp->master);
 
-	dst->cpu_dp->netdev->dsa_ptr = NULL;
+	dst->cpu_dp->master->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point get sent
@@ -505,7 +505,7 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 
 	if (!dst->cpu_dp) {
 		dst->cpu_dp = port;
-		dst->cpu_dp->netdev = ethernet_dev;
+		dst->cpu_dp->master = ethernet_dev;
 	}
 
 	/* Initialize cpu_port_mask now for drv->setup()
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index f1dc5a856fda..b47c46fba376 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -130,7 +130,7 @@ static inline struct net_device *dsa_master_get_slave(struct net_device *dev,
 	if (port < 0 || port >= ds->num_ports)
 		return NULL;
 
-	return ds->ports[port].netdev;
+	return ds->ports[port].slave;
 }
 
 /* port.c */
@@ -181,7 +181,7 @@ dsa_slave_get_master(const struct net_device *dev)
 {
 	struct dsa_port *dp = dsa_slave_to_port(dev);
 
-	return dp->cpu_dp->netdev;
+	return dp->cpu_dp->master;
 }
 
 /* switch.c */
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 6f2254753859..ce6bc80911d0 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -120,7 +120,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 				return -EINVAL;
 			}
 			dst->cpu_dp = &ds->ports[i];
-			dst->cpu_dp->netdev = master;
+			dst->cpu_dp->master = master;
 			ds->cpu_port_mask |= 1 << i;
 		} else if (!strcmp(name, "dsa")) {
 			ds->dsa_port_mask |= 1 << i;
@@ -267,10 +267,10 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		if (!(ds->enabled_port_mask & (1 << port)))
 			continue;
 
-		if (!ds->ports[port].netdev)
+		if (!ds->ports[port].slave)
 			continue;
 
-		dsa_slave_destroy(ds->ports[port].netdev);
+		dsa_slave_destroy(ds->ports[port].slave);
 	}
 
 	/* Disable configuration of the CPU and DSA ports */
@@ -607,7 +607,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	wmb();
 	dev->dsa_ptr = dst->cpu_dp;
 
-	return dsa_master_ethtool_setup(dst->cpu_dp->netdev);
+	return dsa_master_ethtool_setup(dst->cpu_dp->master);
 }
 
 static int dsa_probe(struct platform_device *pdev)
@@ -672,9 +672,9 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
 
-	dsa_master_ethtool_restore(dst->cpu_dp->netdev);
+	dsa_master_ethtool_restore(dst->cpu_dp->master);
 
-	dst->cpu_dp->netdev->dsa_ptr = NULL;
+	dst->cpu_dp->master->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point get sent
@@ -689,7 +689,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 			dsa_switch_destroy(ds);
 	}
 
-	dev_put(dst->cpu_dp->netdev);
+	dev_put(dst->cpu_dp->master);
 }
 
 static int dsa_remove(struct platform_device *pdev)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d2c780f13d78..672977689e1b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1123,7 +1123,7 @@ static void dsa_slave_notify(struct net_device *dev, unsigned long val)
 int dsa_slave_create(struct dsa_port *port, const char *name)
 {
 	struct dsa_port *cpu_dp = port->cpu_dp;
-	struct net_device *master = cpu_dp->netdev;
+	struct net_device *master = cpu_dp->master;
 	struct dsa_switch *ds = port->ds;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
@@ -1170,7 +1170,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	p->old_link = -1;
 	p->old_duplex = -1;
 
-	port->netdev = slave_dev;
+	port->slave = slave_dev;
 
 	netif_carrier_off(slave_dev);
 
@@ -1198,7 +1198,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 out_free:
 	free_percpu(p->stats64);
 	free_netdev(slave_dev);
-	port->netdev = NULL;
+	port->slave = NULL;
 	return ret;
 }
 
-- 
2.14.2
