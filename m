From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/4] net: dsa: introduce dsa_master
Date: Thu, 31 Aug 2017 14:37:43 -0400
Message-ID: <20170831183746.2109-2-vivien.didelot@savoirfairelinux.com>
References: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new dsa_master structure to represent the DSA switch port
physically linked to the CPU master Ethernet device.

This device, a.k.a. a CPU port, is responsible to receive/send frames
from/to the DSA slave ports, a.k.a. user ports.

For the moment, this structure only contains a pointer to a dsa_port
(i.e. the switch device side) and a pointer to the master interface
(i.e. the SoC CPU side).

The structure will be extended with master-specific data such as the
tagging operations or the master ethtool_ops copies.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c |  4 ++--
 drivers/net/dsa/bcm_sf2.c        |  8 ++++----
 drivers/net/dsa/mt7530.c         |  4 ++--
 drivers/net/dsa/mv88e6060.c      |  2 +-
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                | 12 ++++++++----
 net/dsa/Makefile                 |  2 +-
 net/dsa/dsa2.c                   | 27 ++++++++++++++-------------
 net/dsa/dsa_priv.h               |  8 ++++++--
 net/dsa/legacy.c                 | 21 ++++++++++++---------
 net/dsa/master.c                 | 30 ++++++++++++++++++++++++++++++
 net/dsa/slave.c                  |  6 +-----
 12 files changed, 82 insertions(+), 44 deletions(-)
 create mode 100644 net/dsa/master.c

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 274f3679f33d..798045939281 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1280,7 +1280,7 @@ EXPORT_SYMBOL(b53_fdb_dump);
 int b53_br_join(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = ds->dst->master->port->index;
 	u16 pvlan, reg;
 	unsigned int i;
 
@@ -1326,7 +1326,7 @@ void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
 	struct b53_vlan *vl = &dev->vlans[0];
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = ds->dst->master->port->index;
 	unsigned int i;
 	u16 pvlan, reg, pvid;
 
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 8492c9d64004..39468a0c1cee 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -227,7 +227,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 			      struct phy_device *phy)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = ds->dst->master->port->index;
 	unsigned int i;
 	u32 reg;
 
@@ -788,7 +788,7 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 			       struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->dst->cpu_dp->netdev;
+	struct net_device *p = ds->dst->master->netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_wolinfo pwol;
 
@@ -811,9 +811,9 @@ static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 			      struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->dst->cpu_dp->netdev;
+	struct net_device *p = ds->dst->master->netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = ds->dst->master->port->index;
 	struct ethtool_wolinfo pwol;
 
 	p->ethtool_ops->get_wol(p, &pwol);
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index c142b97add2c..4998c05dba1b 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -928,11 +928,11 @@ mt7530_setup(struct dsa_switch *ds)
 	struct device_node *dn;
 	struct mt7530_dummy_poll p;
 
-	/* The parent node of cpu_dp->netdev which holds the common system
+	/* The parent node of master->netdev which holds the common system
 	 * controller also is the container for two GMACs nodes representing
 	 * as two netdev instances.
 	 */
-	dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
+	dn = ds->dst->master->netdev->dev.of_node->parent;
 	priv->ethernet = syscon_node_to_regmap(dn);
 	if (IS_ERR(priv->ethernet))
 		return PTR_ERR(priv->ethernet);
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index dce7fa57eb55..6a30e15b9c01 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -176,7 +176,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 		  ((p & 0xf) << PORT_VLAN_MAP_DBNUM_SHIFT) |
 		   (dsa_is_cpu_port(ds, p) ?
 			ds->enabled_port_mask :
-			BIT(ds->dst->cpu_dp->index)));
+			BIT(ds->dst->master->port->index)));
 
 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 5ada7a41449c..c34d6c82efb3 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -506,7 +506,7 @@ qca8k_setup(struct dsa_switch *ds)
 		pr_warn("regmap initialization failed");
 
 	/* Initialize CPU port pad mode (xMII type, delays...) */
-	phy_mode = of_get_phy_mode(ds->dst->cpu_dp->dn);
+	phy_mode = of_get_phy_mode(ds->dst->master->port->dn);
 	if (phy_mode < 0) {
 		pr_err("Can't find phy-mode for master device\n");
 		return phy_mode;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 398ca8d70ccd..217e36cfc69f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -138,7 +138,7 @@ struct dsa_switch_tree {
 	/*
 	 * The switch port to which the CPU is attached.
 	 */
-	struct dsa_port		*cpu_dp;
+	struct dsa_master	*master;
 
 	/*
 	 * Data for the individual switch chips.
@@ -173,6 +173,10 @@ struct dsa_mall_tc_entry {
 	};
 };
 
+struct dsa_master {
+	struct dsa_port *port;
+	struct net_device *netdev;
+};
 
 struct dsa_port {
 	struct dsa_switch	*ds;
@@ -273,10 +277,10 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 	 * Else return the (DSA) port number that connects to the
 	 * switch that is one hop closer to the cpu.
 	 */
-	if (dst->cpu_dp->ds == ds)
-		return dst->cpu_dp->index;
+	if (dst->master->port->ds == ds)
+		return dst->master->port->index;
 	else
-		return ds->rtable[dst->cpu_dp->ds->index];
+		return ds->rtable[dst->master->port->ds->index];
 }
 
 typedef int dsa_fdb_dump_cb_t(const unsigned char *addr, u16 vid,
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index fcce25da937c..2e7ac8bab19d 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,6 +1,6 @@
 # the core
 obj-$(CONFIG_NET_DSA) += dsa_core.o
-dsa_core-y += dsa.o dsa2.o legacy.o port.o slave.o switch.o
+dsa_core-y += dsa.o dsa2.o legacy.o master.o port.o slave.o switch.o
 
 # tagging formats
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index cceaa4dd9f53..4c4381b7aafb 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -337,7 +337,7 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 		return err;
 
 	if (ds->ops->set_addr) {
-		err = ds->ops->set_addr(ds, dst->cpu_dp->netdev->dev_addr);
+		err = ds->ops->set_addr(ds, dst->master->netdev->dev_addr);
 		if (err < 0)
 			return err;
 	}
@@ -433,8 +433,8 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	if (dst->cpu_dp) {
-		err = dsa_cpu_port_ethtool_setup(dst->cpu_dp);
+	if (dst->master) {
+		err = dsa_cpu_port_ethtool_setup(dst->master->port);
 		if (err)
 			return err;
 	}
@@ -444,7 +444,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dst->cpu_dp->netdev->dsa_ptr = dst;
+	dst->master->netdev->dsa_ptr = dst;
 	dst->applied = true;
 
 	return 0;
@@ -458,7 +458,7 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	if (!dst->applied)
 		return;
 
-	dst->cpu_dp->netdev->dsa_ptr = NULL;
+	dst->master->netdev->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point get sent
@@ -474,9 +474,9 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 		dsa_ds_unapply(dst, ds);
 	}
 
-	if (dst->cpu_dp) {
-		dsa_cpu_port_ethtool_restore(dst->cpu_dp);
-		dst->cpu_dp = NULL;
+	if (dst->master) {
+		dsa_cpu_port_ethtool_restore(dst->master->port);
+		dst->master = NULL;
 	}
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
@@ -504,9 +504,10 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	if (!ethernet_dev)
 		return -EPROBE_DEFER;
 
-	if (!dst->cpu_dp) {
-		dst->cpu_dp = port;
-		dst->cpu_dp->netdev = ethernet_dev;
+	if (!dst->master) {
+		dst->master = dsa_master_create(port, ethernet_dev);
+		if (!dst->master)
+			return -ENOMEM;
 	}
 
 	/* Initialize cpu_port_mask now for drv->setup()
@@ -577,7 +578,7 @@ static int dsa_dst_parse(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	if (!dst->cpu_dp->netdev) {
+	if (!dst->master) {
 		pr_warn("Tree has no master device\n");
 		return -EINVAL;
 	}
@@ -595,7 +596,7 @@ static int dsa_dst_parse(struct dsa_switch_tree *dst)
 			    dsa_port_is_cpu(dp))
 				continue;
 
-			dp->cpu_dp = dst->cpu_dp;
+			dp->cpu_dp = dst->master->port;
 		}
 	}
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 9c3eeb72462d..70f576b3d6fb 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -112,6 +112,10 @@ int dsa_legacy_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 		       struct net_device *dev,
 		       const unsigned char *addr, u16 vid);
 
+/* master.c */
+struct dsa_master *dsa_master_create(struct dsa_port *port,
+				     struct net_device *netdev);
+
 /* port.c */
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
 		       struct switchdev_trans *trans);
@@ -177,12 +181,12 @@ extern const struct dsa_device_ops trailer_netdev_ops;
 
 static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
 {
-	return p->dp->cpu_dp->netdev;
+	return p->dp->ds->dst->master->netdev;
 }
 
 static inline struct dsa_port *dsa_get_cpu_port(struct dsa_switch_tree *dst)
 {
-	return dst->cpu_dp;
+	return dst->master->port;
 }
 
 #endif
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 91e6f7981d39..7a21415d2a81 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -114,13 +114,16 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 			continue;
 
 		if (!strcmp(name, "cpu")) {
-			if (dst->cpu_dp) {
+			if (dst->master) {
 				netdev_err(master,
 					   "multiple cpu ports?!\n");
 				return -EINVAL;
 			}
-			dst->cpu_dp = &ds->ports[i];
-			dst->cpu_dp->netdev = master;
+
+			dst->master = dsa_master_create(&ds->ports[i], master);
+			if (!dst->master)
+				return -ENOMEM;
+
 			ds->cpu_port_mask |= 1 << i;
 		} else if (!strcmp(name, "dsa")) {
 			ds->dsa_port_mask |= 1 << i;
@@ -143,7 +146,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	 * tagging protocol to the preferred tagging format of this
 	 * switch.
 	 */
-	if (dst->cpu_dp->ds == ds) {
+	if (dst->master->port->ds == ds) {
 		enum dsa_tag_protocol tag_protocol;
 
 		tag_protocol = ops->get_tag_protocol(ds);
@@ -189,7 +192,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	 */
 	for (i = 0; i < ds->num_ports; i++) {
 		ds->ports[i].dn = cd->port_dn[i];
-		ds->ports[i].cpu_dp = dst->cpu_dp;
+		ds->ports[i].cpu_dp = dst->master->port;
 
 		if (!(ds->enabled_port_mask & (1 << i)))
 			continue;
@@ -206,7 +209,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 		netdev_err(master, "[%d] : can't configure CPU and DSA ports\n",
 			   index);
 
-	ret = dsa_cpu_port_ethtool_setup(ds->dst->cpu_dp);
+	ret = dsa_cpu_port_ethtool_setup(ds->dst->master->port);
 	if (ret)
 		return ret;
 
@@ -671,7 +674,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
 
-	dst->cpu_dp->netdev->dsa_ptr = NULL;
+	dst->master->netdev->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point get sent
@@ -686,9 +689,9 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 			dsa_switch_destroy(ds);
 	}
 
-	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
+	dsa_cpu_port_ethtool_restore(dst->master->port);
 
-	dev_put(dst->cpu_dp->netdev);
+	dev_put(dst->master->netdev);
 }
 
 static int dsa_remove(struct platform_device *pdev)
diff --git a/net/dsa/master.c b/net/dsa/master.c
new file mode 100644
index 000000000000..294b82b9c114
--- /dev/null
+++ b/net/dsa/master.c
@@ -0,0 +1,30 @@
+/*
+ * Handling of a master port, receiving/sending frames from/to slave ports
+ *
+ * Copyright (c) 2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include "dsa_priv.h"
+
+struct dsa_master *dsa_master_create(struct dsa_port *port,
+				     struct net_device *netdev)
+{
+	struct device *dev = port->ds->dev;
+	struct dsa_master *master;
+
+	master = devm_kzalloc(dev, sizeof(struct dsa_master), GFP_KERNEL);
+	if (!master)
+		return NULL;
+
+	master->port = port;
+	master->netdev = netdev;
+	master->port->netdev = netdev;
+
+	return master;
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 78e78a6e6833..6d47eca47a0c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1250,15 +1250,11 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 {
 	struct dsa_switch *ds = port->ds;
 	struct dsa_switch_tree *dst = ds->dst;
-	struct net_device *master;
+	struct net_device *master = dst->master->netdev;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
-	struct dsa_port *cpu_dp;
 	int ret;
 
-	cpu_dp = ds->dst->cpu_dp;
-	master = cpu_dp->netdev;
-
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
 				 NET_NAME_UNKNOWN, ether_setup);
 	if (slave_dev == NULL)
-- 
2.14.1
