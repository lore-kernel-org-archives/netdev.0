From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: store CPU port pointer in the tree
Date: Tue, 16 May 2017 14:10:33 -0400
Message-ID: <20170516181033.19980-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A dsa_switch_tree instance holds a dsa_switch pointer and a port index
to identify the switch port to which the CPU is attached.

Now that the DSA layer has a dsa_port structure to hold this data, use
it to point the switch CPU port.

This patch simply substitutes s/dst->cpu_switch/dst->cpu_dp->ds/ and
s/dst->cpu_port/dst->cpu_dp->index/.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c |  4 ++--
 drivers/net/dsa/bcm_sf2.c        |  4 ++--
 drivers/net/dsa/mv88e6060.c      |  2 +-
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                | 13 ++++++-------
 net/dsa/dsa2.c                   | 14 ++++++--------
 net/dsa/legacy.c                 | 10 ++++------
 net/dsa/slave.c                  | 10 +++++-----
 net/dsa/tag_brcm.c               |  2 +-
 net/dsa/tag_qca.c                |  2 +-
 net/dsa/tag_trailer.c            |  2 +-
 11 files changed, 30 insertions(+), 35 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index fa0eece21eef..658a12c888a8 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1344,7 +1344,7 @@ EXPORT_SYMBOL(b53_fdb_dump);
 int b53_br_join(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
-	s8 cpu_port = ds->dst->cpu_port;
+	s8 cpu_port = ds->dst->cpu_dp->index;
 	u16 pvlan, reg;
 	unsigned int i;
 
@@ -1390,7 +1390,7 @@ void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
 	struct b53_vlan *vl = &dev->vlans[0];
-	s8 cpu_port = ds->dst->cpu_port;
+	s8 cpu_port = ds->dst->cpu_dp->index;
 	unsigned int i;
 	u16 pvlan, reg, pvid;
 
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 2be963252ca5..215d41c1e71f 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -228,7 +228,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 			      struct phy_device *phy)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst[ds->index].cpu_port;
+	s8 cpu_port = ds->dst->cpu_dp->index;
 	unsigned int i;
 	u32 reg;
 
@@ -832,7 +832,7 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 {
 	struct net_device *p = ds->dst[ds->index].master_netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst[ds->index].cpu_port;
+	s8 cpu_port = ds->dst->cpu_dp->index;
 	struct ethtool_wolinfo pwol;
 
 	p->ethtool_ops->get_wol(p, &pwol);
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 5934b7a4c448..dce7fa57eb55 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -176,7 +176,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 		  ((p & 0xf) << PORT_VLAN_MAP_DBNUM_SHIFT) |
 		   (dsa_is_cpu_port(ds, p) ?
 			ds->enabled_port_mask :
-			BIT(ds->dst->cpu_port)));
+			BIT(ds->dst->cpu_dp->index)));
 
 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index a4fd4ccf7b67..942b9ac7f92a 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -507,7 +507,7 @@ qca8k_setup(struct dsa_switch *ds)
 		pr_warn("regmap initialization failed");
 
 	/* Initialize CPU port pad mode (xMII type, delays...) */
-	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
+	phy_mode = of_get_phy_mode(ds->dst->cpu_dp->dn);
 	if (phy_mode < 0) {
 		pr_err("Can't find phy-mode for master device\n");
 		return phy_mode;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8e24677b1c62..118a8bd2fd9a 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -137,10 +137,9 @@ struct dsa_switch_tree {
 	const struct ethtool_ops *master_orig_ethtool_ops;
 
 	/*
-	 * The switch and port to which the CPU is attached.
+	 * The switch port to which the CPU is attached.
 	 */
-	struct dsa_switch	*cpu_switch;
-	s8			cpu_port;
+	struct dsa_port		*cpu_dp;
 
 	/*
 	 * Data for the individual switch chips.
@@ -251,7 +250,7 @@ struct dsa_switch {
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 {
-	return !!(ds == ds->dst->cpu_switch && p == ds->dst->cpu_port);
+	return ds->dst->cpu_dp == &ds->ports[p];
 }
 
 static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
@@ -279,10 +278,10 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 	 * Else return the (DSA) port number that connects to the
 	 * switch that is one hop closer to the cpu.
 	 */
-	if (dst->cpu_switch == ds)
-		return dst->cpu_port;
+	if (dst->cpu_dp->ds == ds)
+		return dst->cpu_dp->index;
 	else
-		return ds->rtable[dst->cpu_switch->index];
+		return ds->rtable[dst->cpu_dp->ds->index];
 }
 
 struct switchdev_trans;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 033b3bfb63dc..2ac62349ba12 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -443,8 +443,8 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	if (dst->cpu_switch) {
-		err = dsa_cpu_port_ethtool_setup(dst->cpu_switch);
+	if (dst->cpu_dp) {
+		err = dsa_cpu_port_ethtool_setup(dst->cpu_dp->ds);
 		if (err)
 			return err;
 	}
@@ -484,8 +484,8 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 		dsa_ds_unapply(dst, ds);
 	}
 
-	if (dst->cpu_switch)
-		dsa_cpu_port_ethtool_restore(dst->cpu_switch);
+	if (dst->cpu_dp)
+		dsa_cpu_port_ethtool_restore(dst->cpu_dp->ds);
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
 	dst->applied = false;
@@ -518,10 +518,8 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	if (!dst->master_netdev)
 		dst->master_netdev = ethernet_dev;
 
-	if (!dst->cpu_switch) {
-		dst->cpu_switch = ds;
-		dst->cpu_port = index;
-	}
+	if (!dst->cpu_dp)
+		dst->cpu_dp = port;
 
 	tag_protocol = ds->ops->get_tag_protocol(ds);
 	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index ad345c8b0b06..bb28b011ba5a 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -115,13 +115,12 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			continue;
 
 		if (!strcmp(name, "cpu")) {
-			if (dst->cpu_switch) {
+			if (dst->cpu_dp) {
 				netdev_err(dst->master_netdev,
 					   "multiple cpu ports?!\n");
 				return -EINVAL;
 			}
-			dst->cpu_switch = ds;
-			dst->cpu_port = i;
+			dst->cpu_dp = &ds->ports[i];
 			ds->cpu_port_mask |= 1 << i;
 		} else if (!strcmp(name, "dsa")) {
 			ds->dsa_port_mask |= 1 << i;
@@ -144,7 +143,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * tagging protocol to the preferred tagging format of this
 	 * switch.
 	 */
-	if (dst->cpu_switch == ds) {
+	if (dst->cpu_dp->ds == ds) {
 		enum dsa_tag_protocol tag_protocol;
 
 		tag_protocol = ops->get_tag_protocol(ds);
@@ -624,7 +623,6 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 
 	dst->pd = pd;
 	dst->master_netdev = dev;
-	dst->cpu_port = -1;
 
 	for (i = 0; i < pd->nr_chips; i++) {
 		struct dsa_switch *ds;
@@ -735,7 +733,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 			dsa_switch_destroy(ds);
 	}
 
-	dsa_cpu_port_ethtool_restore(dst->cpu_switch);
+	dsa_cpu_port_ethtool_restore(dst->cpu_dp->ds);
 
 	dev_put(dst->master_netdev);
 }
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7693182df81e..77324c483d14 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -821,8 +821,8 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 					   uint64_t *data)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->cpu_switch;
-	s8 cpu_port = dst->cpu_port;
+	struct dsa_switch *ds = dst->cpu_dp->ds;
+	s8 cpu_port = dst->cpu_dp->index;
 	int count = 0;
 
 	if (dst->master_ethtool_ops.get_sset_count) {
@@ -838,7 +838,7 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->cpu_switch;
+	struct dsa_switch *ds = dst->cpu_dp->ds;
 	int count = 0;
 
 	if (dst->master_ethtool_ops.get_sset_count)
@@ -854,8 +854,8 @@ static void dsa_cpu_port_get_strings(struct net_device *dev,
 				     uint32_t stringset, uint8_t *data)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->cpu_switch;
-	s8 cpu_port = dst->cpu_port;
+	struct dsa_switch *ds = dst->cpu_dp->ds;
+	s8 cpu_port = dst->cpu_dp->index;
 	int len = ETH_GSTRING_LEN;
 	int mcount = 0, count;
 	unsigned int i;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 2a9b52c5af86..658ddee63dc9 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -101,7 +101,7 @@ static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	int source_port;
 	u8 *brcm_tag;
 
-	ds = dst->cpu_switch;
+	ds = dst->cpu_dp->ds;
 
 	if (unlikely(!pskb_may_pull(skb, BRCM_TAG_LEN)))
 		goto out_drop;
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 3ba3f59f7a34..be3b67750ac8 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -99,7 +99,7 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* This protocol doesn't support cascading multiple switches so it's
 	 * safe to assume the switch is first in the tree
 	 */
-	ds = dst->cpu_switch;
+	ds = dst->cpu_dp->ds;
 	if (!ds)
 		goto out_drop;
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index aafc2fc74c30..aa05e276ea22 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -67,7 +67,7 @@ static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 	u8 *trailer;
 	int source_port;
 
-	ds = dst->cpu_switch;
+	ds = dst->cpu_dp->ds;
 
 	if (skb_linearize(skb))
 		goto out_drop;
-- 
2.13.0
