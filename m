From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/4] net: dsa: move master ethtool ops in dsa_master
Date: Thu, 31 Aug 2017 14:37:44 -0400
Message-ID: <20170831183746.2109-3-vivien.didelot@savoirfairelinux.com>
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

The copy of the master netdev ethtool_ops is currently stored in the
dsa_port structure, but it is specific to the DSA master (CPU) port.

Move it in the new dsa_master structure. While modifying the ethtool
functions to take this structure as argument, move them in a new
master.c DSA core file.

Also the ethtool ops were the only remaining users for
master->port->netdev thus remove this assignment now.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  |   9 ++---
 net/dsa/dsa.c      |  28 --------------
 net/dsa/dsa2.c     |   4 +-
 net/dsa/dsa_priv.h |   5 +--
 net/dsa/legacy.c   |   4 +-
 net/dsa/master.c   | 105 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 net/dsa/slave.c    |  80 ----------------------------------------
 7 files changed, 114 insertions(+), 121 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 217e36cfc69f..f4a5afc4255b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -176,6 +176,10 @@ struct dsa_mall_tc_entry {
 struct dsa_master {
 	struct dsa_port *port;
 	struct net_device *netdev;
+
+	/* Original copy of the master netdev ethtool_ops */
+	const struct ethtool_ops *orig_ethtool_ops;
+	struct ethtool_ops ethtool_ops;
 };
 
 struct dsa_port {
@@ -189,11 +193,6 @@ struct dsa_port {
 	u8			stp_state;
 	struct net_device	*bridge_dev;
 	struct devlink_port	devlink_port;
-	/*
-	 * Original copy of the master netdev ethtool_ops
-	 */
-	struct ethtool_ops	ethtool_ops;
-	const struct ethtool_ops *orig_ethtool_ops;
 };
 
 struct dsa_switch {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 03c58b0eb082..81c852e32821 100644
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
-	memcpy(&cpu_dp->ethtool_ops, master->ethtool_ops,
-	       sizeof(struct ethtool_ops));
-	cpu_dp->orig_ethtool_ops = master->ethtool_ops;
-	memcpy(cpu_ops, &cpu_dp->ethtool_ops,
-	       sizeof(struct ethtool_ops));
-	dsa_cpu_port_ethtool_init(cpu_ops);
-	master->ethtool_ops = cpu_ops;
-
-	return 0;
-}
-
-void dsa_cpu_port_ethtool_restore(struct dsa_port *cpu_dp)
-{
-	cpu_dp->netdev->ethtool_ops = cpu_dp->orig_ethtool_ops;
-}
-
 void dsa_cpu_dsa_destroy(struct dsa_port *port)
 {
 	struct device_node *port_dn = port->dn;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 4c4381b7aafb..d60f681b96cc 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -434,7 +434,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	}
 
 	if (dst->master) {
-		err = dsa_cpu_port_ethtool_setup(dst->master->port);
+		err = dsa_master_ethtool_setup(dst->master);
 		if (err)
 			return err;
 	}
@@ -475,7 +475,7 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	}
 
 	if (dst->master) {
-		dsa_cpu_port_ethtool_restore(dst->master->port);
+		dsa_master_ethtool_restore(dst->master);
 		dst->master = NULL;
 	}
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 70f576b3d6fb..4fa14b4305b9 100644
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
@@ -115,6 +113,8 @@ int dsa_legacy_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 /* master.c */
 struct dsa_master *dsa_master_create(struct dsa_port *port,
 				     struct net_device *netdev);
+int dsa_master_ethtool_setup(struct dsa_master *master);
+void dsa_master_ethtool_restore(struct dsa_master *master);
 
 /* port.c */
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
@@ -143,7 +143,6 @@ int dsa_port_vlan_del(struct dsa_port *dp,
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
-void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops);
 int dsa_slave_create(struct dsa_port *port, const char *name);
 void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 7a21415d2a81..acd81c488bf4 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -209,7 +209,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 		netdev_err(master, "[%d] : can't configure CPU and DSA ports\n",
 			   index);
 
-	ret = dsa_cpu_port_ethtool_setup(ds->dst->master->port);
+	ret = dsa_master_ethtool_setup(ds->dst->master);
 	if (ret)
 		return ret;
 
@@ -689,7 +689,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 			dsa_switch_destroy(ds);
 	}
 
-	dsa_cpu_port_ethtool_restore(dst->master->port);
+	dsa_master_ethtool_restore(dst->master);
 
 	dev_put(dst->master->netdev);
 }
diff --git a/net/dsa/master.c b/net/dsa/master.c
index 294b82b9c114..9ecce3e7c8df 100644
--- a/net/dsa/master.c
+++ b/net/dsa/master.c
@@ -12,6 +12,110 @@
 
 #include "dsa_priv.h"
 
+static void dsa_master_get_ethtool_stats(struct net_device *dev,
+					 struct ethtool_stats *stats,
+					 uint64_t *data)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_master *master = dst->master;
+	struct dsa_port *port = master->port;
+	struct dsa_switch *ds = port->ds;
+	int count = 0;
+
+	if (master->ethtool_ops.get_sset_count) {
+		count = master->ethtool_ops.get_sset_count(dev, ETH_SS_STATS);
+		master->ethtool_ops.get_ethtool_stats(dev, stats, data);
+	}
+
+	if (ds->ops->get_ethtool_stats)
+		ds->ops->get_ethtool_stats(ds, port->index, data + count);
+}
+
+static int dsa_master_get_sset_count(struct net_device *dev, int sset)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_master *master = dst->master;
+	struct dsa_port *port = master->port;
+	struct dsa_switch *ds = port->ds;
+	int count = 0;
+
+	if (master->ethtool_ops.get_sset_count)
+		count += master->ethtool_ops.get_sset_count(dev, sset);
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
+	struct dsa_master *master = dst->master;
+	struct dsa_port *port = master->port;
+	struct dsa_switch *ds = port->ds;
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
+	if (master->ethtool_ops.get_sset_count) {
+		mcount = master->ethtool_ops.get_sset_count(dev, ETH_SS_STATS);
+		master->ethtool_ops.get_strings(dev, stringset, data);
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
+int dsa_master_ethtool_setup(struct dsa_master *master)
+{
+	struct device *dev = master->port->ds->dev;
+	struct net_device *netdev = master->netdev;
+	struct ethtool_ops *ops;
+
+	ops = devm_kzalloc(dev, sizeof(*ops), GFP_KERNEL);
+	if (!ops)
+		return -ENOMEM;
+
+	/* Back up the original master netdev ethtool_ops */
+	master->orig_ethtool_ops = netdev->ethtool_ops;
+	memcpy(&master->ethtool_ops, master->orig_ethtool_ops, sizeof(*ops));
+	memcpy(ops, &master->ethtool_ops, sizeof(*ops));
+
+	/* Change the master netdev ethtool_ops */
+	ops->get_sset_count = dsa_master_get_sset_count;
+	ops->get_ethtool_stats = dsa_master_get_ethtool_stats;
+	ops->get_strings = dsa_master_get_strings;
+	netdev->ethtool_ops = ops;
+
+	return 0;
+}
+
+void dsa_master_ethtool_restore(struct dsa_master *master)
+{
+	master->netdev->ethtool_ops = master->orig_ethtool_ops;
+	master->orig_ethtool_ops = NULL;
+}
+
 struct dsa_master *dsa_master_create(struct dsa_port *port,
 				     struct net_device *netdev)
 {
@@ -24,7 +128,6 @@ struct dsa_master *dsa_master_create(struct dsa_port *port,
 
 	master->port = port;
 	master->netdev = netdev;
-	master->port->netdev = netdev;
 
 	return master;
 }
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6d47eca47a0c..99f9e48a6cee 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -567,79 +567,6 @@ static void dsa_slave_get_strings(struct net_device *dev,
 	}
 }
 
-static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
-					   struct ethtool_stats *stats,
-					   uint64_t *data)
-{
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
-	s8 cpu_port = cpu_dp->index;
-	int count = 0;
-
-	if (cpu_dp->ethtool_ops.get_sset_count) {
-		count = cpu_dp->ethtool_ops.get_sset_count(dev, ETH_SS_STATS);
-		cpu_dp->ethtool_ops.get_ethtool_stats(dev, stats, data);
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
-	int count = 0;
-
-	if (cpu_dp->ethtool_ops.get_sset_count)
-		count += cpu_dp->ethtool_ops.get_sset_count(dev, sset);
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
-	if (cpu_dp->ethtool_ops.get_sset_count) {
-		mcount = cpu_dp->ethtool_ops.get_sset_count(dev, ETH_SS_STATS);
-		cpu_dp->ethtool_ops.get_strings(dev, stringset, data);
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
@@ -976,13 +903,6 @@ static void dsa_slave_get_stats64(struct net_device *dev,
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
