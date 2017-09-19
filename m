From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/4] net: dsa: move master ethtool code
Date: Tue, 19 Sep 2017 11:57:00 -0400
Message-ID: <20170919155700.14474-5-vivien.didelot@savoirfairelinux.com>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DSA overrides the master device ethtool ops, so that it can inject stats
from its dedicated switch CPU port as well.

The related code is currently split in dsa.c and slave.c, but it only
scopes the master net device. Move it to a new master.c DSA core file.

This file will be later extented with master net device specific code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/Makefile   |   2 +-
 net/dsa/dsa.c      |  28 -------------
 net/dsa/dsa2.c     |   4 +-
 net/dsa/dsa_priv.h |   7 ++--
 net/dsa/legacy.c   |   4 +-
 net/dsa/master.c   | 120 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c    |  83 ------------------------------------
 7 files changed, 129 insertions(+), 119 deletions(-)
 create mode 100644 net/dsa/master.c

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
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index abadf7b49236..81c852e32821 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -112,34 +112,6 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
 	return ops;
 }
 
-int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp)
-{
-	struct dsa_switch *ds = cpu_dp->ds;
-	struct net_device *master;
-	struct ethtool_ops *cpu_ops;
-
-	master = cpu_dp->netdev;
-
-	cpu_ops = devm_kzalloc(ds->dev, sizeof(*cpu_ops), GFP_KERNEL);
-	if (!cpu_ops)
-		return -ENOMEM;
-
-	cpu_dp->orig_ethtool_ops = master->ethtool_ops;
-	if (cpu_dp->orig_ethtool_ops)
-		memcpy(cpu_ops, cpu_dp->orig_ethtool_ops, sizeof(*cpu_ops));
-
-	dsa_cpu_port_ethtool_init(cpu_ops);
-	master->ethtool_ops = cpu_ops;
-
-	return 0;
-}
-
-void dsa_cpu_port_ethtool_restore(struct dsa_port *cpu_dp)
-{
-	cpu_dp->netdev->ethtool_ops = cpu_dp->orig_ethtool_ops;
-	cpu_dp->orig_ethtool_ops = NULL;
-}
-
 void dsa_cpu_dsa_destroy(struct dsa_port *port)
 {
 	struct device_node *port_dn = port->dn;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 032f8bc3e788..dcccaebde708 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -440,7 +440,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	wmb();
 	dst->cpu_dp->netdev->dsa_ptr = dst;
 
-	err = dsa_cpu_port_ethtool_setup(dst->cpu_dp);
+	err = dsa_master_ethtool_setup(dst->cpu_dp->netdev);
 	if (err)
 		return err;
 
@@ -457,7 +457,7 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	if (!dst->applied)
 		return;
 
-	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
+	dsa_master_ethtool_restore(dst->cpu_dp->netdev);
 
 	dst->cpu_dp->netdev->dsa_ptr = NULL;
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 9c3eeb72462d..f616b3444418 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -97,8 +97,6 @@ struct dsa_slave_priv {
 int dsa_cpu_dsa_setup(struct dsa_port *port);
 void dsa_cpu_dsa_destroy(struct dsa_port *dport);
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
-int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp);
-void dsa_cpu_port_ethtool_restore(struct dsa_port *cpu_dp);
 bool dsa_schedule_work(struct work_struct *work);
 
 /* legacy.c */
@@ -112,6 +110,10 @@ int dsa_legacy_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 		       struct net_device *dev,
 		       const unsigned char *addr, u16 vid);
 
+/* master.c */
+int dsa_master_ethtool_setup(struct net_device *dev);
+void dsa_master_ethtool_restore(struct net_device *dev);
+
 /* port.c */
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
 		       struct switchdev_trans *trans);
@@ -139,7 +141,6 @@ int dsa_port_vlan_del(struct dsa_port *dp,
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
-void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops);
 int dsa_slave_create(struct dsa_port *port, const char *name);
 void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 163910699db7..ae505d8e4417 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -602,7 +602,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	wmb();
 	dev->dsa_ptr = dst;
 
-	return dsa_cpu_port_ethtool_setup(dst->cpu_dp);
+	return dsa_master_ethtool_setup(dst->cpu_dp->netdev);
 }
 
 static int dsa_probe(struct platform_device *pdev)
@@ -667,7 +667,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
 
-	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
+	dsa_master_ethtool_restore(dst->cpu_dp->netdev);
 
 	dst->cpu_dp->netdev->dsa_ptr = NULL;
 
diff --git a/net/dsa/master.c b/net/dsa/master.c
new file mode 100644
index 000000000000..5e5147ec5a44
--- /dev/null
+++ b/net/dsa/master.c
@@ -0,0 +1,120 @@
+/*
+ * Handling of a master device, switching frames via its switch fabric CPU port
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
+static void dsa_master_get_ethtool_stats(struct net_device *dev,
+					 struct ethtool_stats *stats,
+					 uint64_t *data)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *port = dst->cpu_dp;
+	struct dsa_switch *ds = port->ds;
+	const struct ethtool_ops *ops = port->orig_ethtool_ops;
+	int count = 0;
+
+	if (ops && ops->get_sset_count && ops->get_ethtool_stats) {
+		count = ops->get_sset_count(dev, ETH_SS_STATS);
+		ops->get_ethtool_stats(dev, stats, data);
+	}
+
+	if (ds->ops->get_ethtool_stats)
+		ds->ops->get_ethtool_stats(ds, port->index, data + count);
+}
+
+static int dsa_master_get_sset_count(struct net_device *dev, int sset)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *port = dst->cpu_dp;
+	struct dsa_switch *ds = port->ds;
+	const struct ethtool_ops *ops = port->orig_ethtool_ops;
+	int count = 0;
+
+	if (ops && ops->get_sset_count)
+		count += ops->get_sset_count(dev, sset);
+
+	if (sset == ETH_SS_STATS && ds->ops->get_sset_count)
+		count += ds->ops->get_sset_count(ds);
+
+	return count;
+}
+
+static void dsa_master_get_strings(struct net_device *dev, uint32_t stringset,
+				   uint8_t *data)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *port = dst->cpu_dp;
+	struct dsa_switch *ds = port->ds;
+	const struct ethtool_ops *ops = port->orig_ethtool_ops;
+	int len = ETH_GSTRING_LEN;
+	int mcount = 0, count;
+	unsigned int i;
+	uint8_t pfx[4];
+	uint8_t *ndata;
+
+	snprintf(pfx, sizeof(pfx), "p%.2d", port->index);
+	/* We do not want to be NULL-terminated, since this is a prefix */
+	pfx[sizeof(pfx) - 1] = '_';
+
+	if (ops && ops->get_sset_count && ops->get_strings) {
+		mcount = ops->get_sset_count(dev, ETH_SS_STATS);
+		ops->get_strings(dev, stringset, data);
+	}
+
+	if (stringset == ETH_SS_STATS && ds->ops->get_strings) {
+		ndata = data + mcount * len;
+		/* This function copies ETH_GSTRINGS_LEN bytes, we will mangle
+		 * the output after to prepend our CPU port prefix we
+		 * constructed earlier
+		 */
+		ds->ops->get_strings(ds, port->index, ndata);
+		count = ds->ops->get_sset_count(ds);
+		for (i = 0; i < count; i++) {
+			memmove(ndata + (i * len + sizeof(pfx)),
+				ndata + i * len, len - sizeof(pfx));
+			memcpy(ndata + i * len, pfx, sizeof(pfx));
+		}
+	}
+}
+
+int dsa_master_ethtool_setup(struct net_device *dev)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *port = dst->cpu_dp;
+	struct dsa_switch *ds = port->ds;
+	struct ethtool_ops *ops;
+
+	ops = devm_kzalloc(ds->dev, sizeof(*ops), GFP_KERNEL);
+	if (!ops)
+		return -ENOMEM;
+
+	port->orig_ethtool_ops = dev->ethtool_ops;
+	if (port->orig_ethtool_ops)
+		memcpy(ops, port->orig_ethtool_ops, sizeof(*ops));
+
+	ops->get_sset_count = dsa_master_get_sset_count;
+	ops->get_ethtool_stats = dsa_master_get_ethtool_stats;
+	ops->get_strings = dsa_master_get_strings;
+
+	dev->ethtool_ops = ops;
+
+	return 0;
+}
+
+void dsa_master_ethtool_restore(struct net_device *dev)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *port = dst->cpu_dp;
+
+	dev->ethtool_ops = port->orig_ethtool_ops;
+	port->orig_ethtool_ops = NULL;
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2ff4f907d137..d51b10450e1b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -567,82 +567,6 @@ static void dsa_slave_get_strings(struct net_device *dev,
 	}
 }
 
-static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
-					   struct ethtool_stats *stats,
-					   uint64_t *data)
-{
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
-	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
-	s8 cpu_port = cpu_dp->index;
-	int count = 0;
-
-	if (ops && ops->get_sset_count && ops->get_ethtool_stats) {
-		count = ops->get_sset_count(dev, ETH_SS_STATS);
-		ops->get_ethtool_stats(dev, stats, data);
-	}
-
-	if (ds->ops->get_ethtool_stats)
-		ds->ops->get_ethtool_stats(ds, cpu_port, data + count);
-}
-
-static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
-{
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
-	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
-	int count = 0;
-
-	if (ops && ops->get_sset_count)
-		count += ops->get_sset_count(dev, sset);
-
-	if (sset == ETH_SS_STATS && ds->ops->get_sset_count)
-		count += ds->ops->get_sset_count(ds);
-
-	return count;
-}
-
-static void dsa_cpu_port_get_strings(struct net_device *dev,
-				     uint32_t stringset, uint8_t *data)
-{
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
-	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
-	s8 cpu_port = cpu_dp->index;
-	int len = ETH_GSTRING_LEN;
-	int mcount = 0, count;
-	unsigned int i;
-	uint8_t pfx[4];
-	uint8_t *ndata;
-
-	snprintf(pfx, sizeof(pfx), "p%.2d", cpu_port);
-	/* We do not want to be NULL-terminated, since this is a prefix */
-	pfx[sizeof(pfx) - 1] = '_';
-
-	if (ops && ops->get_sset_count && ops->get_strings) {
-		mcount = ops->get_sset_count(dev, ETH_SS_STATS);
-		ops->get_strings(dev, stringset, data);
-	}
-
-	if (stringset == ETH_SS_STATS && ds->ops->get_strings) {
-		ndata = data + mcount * len;
-		/* This function copies ETH_GSTRINGS_LEN bytes, we will mangle
-		 * the output after to prepend our CPU port prefix we
-		 * constructed earlier
-		 */
-		ds->ops->get_strings(ds, cpu_port, ndata);
-		count = ds->ops->get_sset_count(ds);
-		for (i = 0; i < count; i++) {
-			memmove(ndata + (i * len + sizeof(pfx)),
-				ndata + i * len, len - sizeof(pfx));
-			memcpy(ndata + i * len, pfx, sizeof(pfx));
-		}
-	}
-}
-
 static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 					struct ethtool_stats *stats,
 					uint64_t *data)
@@ -979,13 +903,6 @@ static void dsa_slave_get_stats64(struct net_device *dev,
 	}
 }
 
-void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
-{
-	ops->get_sset_count = dsa_cpu_port_get_sset_count;
-	ops->get_ethtool_stats = dsa_cpu_port_get_ethtool_stats;
-	ops->get_strings = dsa_cpu_port_get_strings;
-}
-
 static int dsa_slave_get_rxnfc(struct net_device *dev,
 			       struct ethtool_rxnfc *nfc, u32 *rule_locs)
 {
-- 
2.14.1
