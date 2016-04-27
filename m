From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 14/20] net: dsa: add tree-wide bridge ops
Date: Wed, 27 Apr 2016 18:30:11 -0400
Message-ID: <1461796217-18893-15-git-send-email-vivien.didelot@savoirfairelinux.com>
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

In order to support cross-chip operations, we need to inform each switch
driver when a port operation occurs in a DSA tree.

This allows drivers to configure cross-chip port-based VLAN table, VTU
or FDB entries on DSA links, in order to implement a correct hardware
switching of frames.

Add a new tree.c file to implement tree-wide operations, propagating a
port-based operation on each switch of a tree.

Implement tree-wide bridge operations.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c   |  6 +++++
 drivers/net/dsa/mv88e6xxx.c |  6 +++++
 include/net/dsa.h           |  6 +++++
 net/dsa/Makefile            |  2 +-
 net/dsa/dsa_priv.h          |  6 +++++
 net/dsa/slave.c             | 46 ++++---------------------------
 net/dsa/tree.c              | 66 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 96 insertions(+), 42 deletions(-)
 create mode 100644 net/dsa/tree.c

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 6e3b844..0a91ea9 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -498,6 +498,9 @@ static int bcm_sf2_sw_br_join(struct dsa_switch *ds, struct dsa_port *dp,
 	struct dsa_port *intp;
 	u32 reg, p_ctl;
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(dp->port));
 
 	dsa_switch_for_each_port(ds, intp, priv->hw_params.num_ports) {
@@ -531,6 +534,9 @@ static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, struct dsa_port *dp,
 	struct dsa_port *intp;
 	u32 reg, p_ctl;
 
+	if (dsa_port_is_external(dp, ds))
+		return;
+
 	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(dp->port));
 
 	dsa_switch_for_each_port(ds, intp, priv->hw_params.num_ports) {
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 89d0206..6fef29b 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2212,6 +2212,9 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, struct dsa_port *dp,
 	struct dsa_port *intp;
 	int err;
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	/* Remap each port's VLANTable */
@@ -2234,6 +2237,9 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, struct dsa_port *dp,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct dsa_port *intp;
 
+	if (dsa_port_is_external(dp, ds))
+		return;
+
 	mutex_lock(&ps->smi_mutex);
 
 	/* Remap each port's VLANTable */
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 85fac8a..33172c9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -193,6 +193,12 @@ struct dsa_switch {
 	struct list_head	dp;
 };
 
+static inline bool dsa_port_is_external(struct dsa_port *dp,
+					struct dsa_switch *ds)
+{
+	return dp->ds != ds;
+}
+
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 {
 	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index da06ed1..bf8d12c 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,6 +1,6 @@
 # the core
 obj-$(CONFIG_NET_DSA) += dsa_core.o
-dsa_core-y += dsa.o slave.o
+dsa_core-y += dsa.o tree.o slave.o
 
 # tagging formats
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c5afddd..6e08b3d 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -46,6 +46,12 @@ struct dsa_slave_priv {
 /* dsa.c */
 extern char dsa_driver_version[];
 
+/* tree.c */
+int dsa_tree_bridge_port_join(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			      struct net_device *br);
+void dsa_tree_bridge_port_leave(struct dsa_switch_tree *dst,
+				struct dsa_port *dp, struct net_device *br);
+
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b90caf8..7123ae2 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -425,45 +425,6 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	return err;
 }
 
-static int dsa_slave_bridge_port_join(struct net_device *dev,
-				      struct net_device *br)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-	int ret = -EOPNOTSUPP;
-
-	p->dp->br = br;
-
-	if (ds->drv->port_bridge_join)
-		ret = ds->drv->port_bridge_join(ds, p->dp, br);
-
-	if (ret && ret != -EOPNOTSUPP) {
-		p->dp->br = NULL;
-		return ret;
-	}
-
-	return 0;
-}
-
-static void dsa_slave_bridge_port_leave(struct net_device *dev)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-	struct net_device *br = p->dp->br;
-
-	p->dp->br = NULL;
-
-	if (ds->drv->port_bridge_leave)
-		ds->drv->port_bridge_leave(ds, p->dp, br);
-
-	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
-	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
-	 */
-	if (ds->drv->port_stp_state_set)
-		ds->drv->port_stp_state_set(ds, p->dp->port,
-					    BR_STATE_FORWARDING);
-}
-
 static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
@@ -1140,6 +1101,9 @@ static bool dsa_slave_dev_check(struct net_device *dev)
 static int dsa_slave_port_upper_event(struct net_device *dev,
 				      unsigned long event, void *ptr)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+	struct dsa_switch_tree *dst = dp->ds->dst;
 	struct netdev_notifier_changeupper_info *info = ptr;
 	struct net_device *upper = info->upper_dev;
 	int err = 0;
@@ -1148,9 +1112,9 @@ static int dsa_slave_port_upper_event(struct net_device *dev,
 	case NETDEV_CHANGEUPPER:
 		if (netif_is_bridge_master(upper)) {
 			if (info->linking)
-				err = dsa_slave_bridge_port_join(dev, upper);
+				err = dsa_tree_bridge_port_join(dst, dp, upper);
 			else
-				dsa_slave_bridge_port_leave(dev);
+				dsa_tree_bridge_port_leave(dst, dp, upper);
 		}
 
 		break;
diff --git a/net/dsa/tree.c b/net/dsa/tree.c
new file mode 100644
index 0000000..d3f5aea
--- /dev/null
+++ b/net/dsa/tree.c
@@ -0,0 +1,66 @@
+/*
+ * net/dsa/tree.c - DSA switch tree handling
+ * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/if_bridge.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+
+#include "dsa_priv.h"
+
+int dsa_tree_bridge_port_join(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			      struct net_device *br)
+{
+	struct dsa_switch *ds;
+	int err = 0;
+
+	/* on NETDEV_CHANGEUPPER, the port is already bridged */
+	dp->br = br;
+
+	dsa_tree_for_each_switch(dst, ds) {
+		if (ds->drv->port_bridge_join) {
+			err = ds->drv->port_bridge_join(ds, dp, br);
+			if (err) {
+				if (err != -EOPNOTSUPP)
+					break;
+				err = 0;
+			}
+		}
+	}
+
+	/* if an error is reported, bridge rolls back the operation */
+	if (err)
+		dp->br = NULL;
+
+	return err;
+}
+
+void dsa_tree_bridge_port_leave(struct dsa_switch_tree *dst,
+				struct dsa_port *dp, struct net_device *br)
+{
+	struct dsa_switch *ds;
+
+	/* on NETDEV_CHANGEUPPER, the port is already unbridged */
+	dp->br = NULL;
+
+	dsa_tree_for_each_switch(dst, ds) {
+		if (ds->drv->port_bridge_leave)
+			ds->drv->port_bridge_leave(ds, dp, br);
+
+		if (dsa_port_is_external(dp, ds))
+			continue;
+
+		/* The bridge layer put the port in BR_STATE_DISABLED,
+		 * restore BR_STATE_FORWARDING to keep it functional.
+		 */
+		if (ds->drv->port_stp_state_set)
+			ds->drv->port_stp_state_set(ds, dp->port,
+						    BR_STATE_FORWARDING);
+	}
+}
-- 
2.8.0
