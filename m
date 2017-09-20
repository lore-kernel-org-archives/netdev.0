From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: use dedicated CPU port
Date: Wed, 20 Sep 2017 12:28:05 -0400
Message-ID: <20170920162805.29503-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Each port in DSA has its own dedicated CPU port currently available in
its parent switch's ds->ports[port].cpu_dp. Use it instead of getting
the unique tree CPU port, which will be deprecated soon.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c | 4 ++--
 drivers/net/dsa/bcm_sf2.c        | 6 +++---
 drivers/net/dsa/mt7530.c         | 4 ++--
 drivers/net/dsa/mv88e6060.c      | 2 +-
 drivers/net/dsa/qca8k.c          | 2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index a9f2a5b55a5e..d4ce092def83 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1336,7 +1336,7 @@ EXPORT_SYMBOL(b53_fdb_dump);
 int b53_br_join(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = ds->ports[port].cpu_dp->index;
 	u16 pvlan, reg;
 	unsigned int i;
 
@@ -1382,7 +1382,7 @@ void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
 	struct b53_vlan *vl = &dev->vlans[0];
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = ds->ports[port].cpu_dp->index;
 	unsigned int i;
 	u16 pvlan, reg, pvid;
 
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 0072a959db5b..898d5642b516 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -661,7 +661,7 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 			       struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->dst->cpu_dp->netdev;
+	struct net_device *p = ds->ports[port].cpu_dp->netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_wolinfo pwol;
 
@@ -684,9 +684,9 @@ static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 			      struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->dst->cpu_dp->netdev;
+	struct net_device *p = ds->ports[port].cpu_dp->netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst->cpu_dp->index;
+	s8 cpu_port = ds->ports[port].cpu_dp->index;
 	struct ethtool_wolinfo pwol;
 
 	p->ethtool_ops->get_wol(p, &pwol);
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index c142b97add2c..faa3b88d2206 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -928,11 +928,11 @@ mt7530_setup(struct dsa_switch *ds)
 	struct device_node *dn;
 	struct mt7530_dummy_poll p;
 
-	/* The parent node of cpu_dp->netdev which holds the common system
+	/* The parent node of master netdev which holds the common system
 	 * controller also is the container for two GMACs nodes representing
 	 * as two netdev instances.
 	 */
-	dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
+	dn = ds->ports[MT7530_CPU_PORT].netdev->dev.of_node->parent;
 	priv->ethernet = syscon_node_to_regmap(dn);
 	if (IS_ERR(priv->ethernet))
 		return PTR_ERR(priv->ethernet);
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index dce7fa57eb55..621cdc46ad81 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -176,7 +176,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 		  ((p & 0xf) << PORT_VLAN_MAP_DBNUM_SHIFT) |
 		   (dsa_is_cpu_port(ds, p) ?
 			ds->enabled_port_mask :
-			BIT(ds->dst->cpu_dp->index)));
+			BIT(ds->ports[p].cpu_dp->index)));
 
 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 5ada7a41449c..82f09711ac1a 100644
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
-- 
2.14.1
