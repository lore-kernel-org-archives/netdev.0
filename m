From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: dsa: Stop accessing ds->dst->cpu_dp in drivers
Date: Tue,  6 Jun 2017 10:02:02 -0700
Message-ID: <20170606170202.21491-6-f.fainelli@gmail.com>
References: <20170606170202.21491-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34823 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdFFRCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 13:02:13 -0400
Received: by mail-qt0-f194.google.com with SMTP id x58so17314549qtc.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 10:02:13 -0700 (PDT)
In-Reply-To: <20170606170202.21491-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Out of the few drivers that do access ds->dst->cpu_dp, there is only a
handful for which we cannot substitute that for either an existing and
equivalent piece of information (b53, bcm_sf2, qca8k), and there is only
one for which we need to introduce a helper: mt7530. We do introduce
dsa_ds_get_cpu_dp() which reads the CPU port from ds->cpu_port_mask.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c |  4 ++--
 drivers/net/dsa/bcm_sf2.c        | 10 ++++++----
 drivers/net/dsa/mt7530.c         |  4 +++-
 drivers/net/dsa/mv88e6060.c      |  3 ++-
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                |  6 ++++++
 6 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index e68d368e20ac..faec6fcacd31 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1341,7 +1341,7 @@ EXPORT_SYMBOL(b53_fdb_dump);
 int b53_br_join(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = dev->cpu_port;
 	u16 pvlan, reg;
 	unsigned int i;
 
@@ -1387,7 +1387,7 @@ void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
 	struct b53_vlan *vl = &dev->vlans[0];
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = dev->cpu_port;
 	unsigned int i;
 	u16 pvlan, reg, pvid;
 
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 76e98e8ed315..9744100d0276 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -227,7 +227,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 			      struct phy_device *phy)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = priv->dev->cpu_port;
 	unsigned int i;
 	u32 reg;
 
@@ -806,8 +806,9 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 			       struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->dst[ds->index].cpu_dp->netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
+	struct dsa_port *cpu_dp = ds->ports[port].cpu_dp;
+	struct net_device *p = cpu_dp->netdev;
 	struct ethtool_wolinfo pwol;
 
 	/* Get the parent device WoL settings */
@@ -829,9 +830,10 @@ static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 			      struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->dst[ds->index].cpu_dp->netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	struct dsa_port *cpu_dp = ds->ports[port].cpu_dp;
+	struct net_device *p = cpu_dp->netdev;
+	s8 cpu_port = cpu_dp->index;
 	struct ethtool_wolinfo pwol;
 
 	p->ethtool_ops->get_wol(p, &pwol);
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1e46418a3b74..9b1b76c7b927 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -907,6 +907,7 @@ static int
 mt7530_setup(struct dsa_switch *ds)
 {
 	struct mt7530_priv *priv = ds->priv;
+	struct dsa_port *cpu_dp;
 	int ret, i;
 	u32 id, val;
 	struct device_node *dn;
@@ -916,7 +917,8 @@ mt7530_setup(struct dsa_switch *ds)
 	 * controller also is the container for two GMACs nodes representing
 	 * as two netdev instances.
 	 */
-	dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
+	cpu_dp = dsa_ds_get_cpu_dp(ds);
+	dn = cpu_dp->netdev->dev.of_node->parent;
 	priv->ethernet = syscon_node_to_regmap(dn);
 	if (IS_ERR(priv->ethernet))
 		return PTR_ERR(priv->ethernet);
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index dce7fa57eb55..76fcd4350679 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -153,6 +153,7 @@ static int mv88e6060_setup_global(struct dsa_switch *ds)
 
 static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 {
+	struct dsa_port *cpu_dp = dsa_ds_get_cpu_dp(ds);
 	int addr = REG_PORT(p);
 
 	/* Do not force flow control, disable Ingress and Egress
@@ -176,7 +177,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 		  ((p & 0xf) << PORT_VLAN_MAP_DBNUM_SHIFT) |
 		   (dsa_is_cpu_port(ds, p) ?
 			ds->enabled_port_mask :
-			BIT(ds->dst->cpu_dp->index)));
+			BIT(cpu_dp->index)));
 
 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index b3bee7eab45f..68b45298f6d1 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -506,7 +506,7 @@ qca8k_setup(struct dsa_switch *ds)
 		pr_warn("regmap initialization failed");
 
 	/* Initialize CPU port pad mode (xMII type, delays...) */
-	phy_mode = of_get_phy_mode(ds->dst->cpu_dp->dn);
+	phy_mode = of_get_phy_mode(ds->ports[QCA8K_CPU_PORT].dn);
 	if (phy_mode < 0) {
 		pr_err("Can't find phy-mode for master device\n");
 		return phy_mode;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 58969b9a090c..264cb3f93764 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -11,6 +11,7 @@
 #ifndef __LINUX_NET_DSA_H
 #define __LINUX_NET_DSA_H
 
+#include <linux/bitops.h>
 #include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/list.h>
@@ -261,6 +262,11 @@ static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
 }
 
+static inline struct dsa_port *dsa_ds_get_cpu_dp(struct dsa_switch *ds)
+{
+	return &ds->ports[fls(ds->cpu_port_mask) - 1];
+}
+
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 {
 	struct dsa_switch_tree *dst = ds->dst;
-- 
2.9.3
