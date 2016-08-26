From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 5/6] net: dsa: bcm_sf2: Utilize core B53 driver when possible
Date: Fri, 26 Aug 2016 12:18:33 -0700
Message-ID: <1472239114-26212-6-git-send-email-f.fainelli@gmail.com>
References: <1472239114-26212-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jonas.gorski@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35450 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753393AbcHZTSx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 15:18:53 -0400
Received: by mail-pa0-f65.google.com with SMTP id cf3so5113653pad.2
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 12:18:53 -0700 (PDT)
In-Reply-To: <1472239114-26212-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Broadcom Starfighter2 is almost entirely register compatible with
B53, yet for historical reasons came up first in the tree and is now
being updated to utilize b53_common.c to the fullest extent possible. A
few things need to be adjusted to allow that:

- the switch "core" registers currently operate on a 32-bit address,
  whereas b53 passes a page + reg pair to offset from, so we need to
  convert that, thankfully there is a generic formula to do that

- the link managemenent is not self contained with the B53/CORE register
  set, but instead is in the SWITCH_REG block which is part of the
  integration glue logic, so we keep that entirely custom here because
  this really is part of the existing bcm_sf2 implementation

- there are additional power management constraints on the port's
  memories that make us keep the port_enable/disable callbacks custom
  for now, also, we support tagging whereas b53_common does not support
  that yet

All the VLAN and bridge code is entirely identical though so, avoid
duplicating it. Other things will be migrated in the future like EEE and
possibly Wake-on-LAN.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/Kconfig   |   1 +
 drivers/net/dsa/bcm_sf2.c | 230 ++++++++++++++++++++++++++++++++++++----------
 drivers/net/dsa/bcm_sf2.h |  11 +++
 3 files changed, 195 insertions(+), 47 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 8f4544394f44..de6d04429a70 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -16,6 +16,7 @@ config NET_DSA_BCM_SF2
 	select FIXED_PHY
 	select BCM7XXX_PHY
 	select MDIO_BCM_UNIMAC
+	select B53
 	---help---
 	  This enables support for the Broadcom Starfighter 2 Ethernet
 	  switch chips.
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 220e5d1948ca..e99d0a21bd8b 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -29,9 +29,12 @@
 #include <linux/brcmphy.h>
 #include <linux/etherdevice.h>
 #include <net/switchdev.h>
+#include <linux/platform_data/b53.h>
 
 #include "bcm_sf2.h"
 #include "bcm_sf2_regs.h"
+#include "b53/b53_priv.h"
+#include "b53/b53_regs.h"
 
 /* String, offset, and register size in bytes if different from 4 bytes */
 static const struct bcm_sf2_hw_stats bcm_sf2_mib[] = {
@@ -106,7 +109,7 @@ static void bcm_sf2_sw_get_strings(struct dsa_switch *ds,
 static void bcm_sf2_sw_get_ethtool_stats(struct dsa_switch *ds,
 					 int port, uint64_t *data)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	const struct bcm_sf2_hw_stats *s;
 	unsigned int i;
 	u64 val = 0;
@@ -143,7 +146,7 @@ static enum dsa_tag_protocol bcm_sf2_sw_get_tag_protocol(struct dsa_switch *ds)
 
 static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int i;
 	u32 reg;
 
@@ -163,7 +166,7 @@ static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 
 static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	u32 reg, val;
 
 	/* Enable the port memories */
@@ -228,7 +231,7 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 
 static void bcm_sf2_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	u32 reg;
 
 	reg = core_readl(priv, CORE_EEE_EN_CTRL);
@@ -241,7 +244,7 @@ static void bcm_sf2_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
 
 static void bcm_sf2_gphy_enable_set(struct dsa_switch *ds, bool enable)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	u32 reg;
 
 	reg = reg_readl(priv, REG_SPHY_CNTRL);
@@ -315,7 +318,7 @@ static inline void bcm_sf2_port_intr_disable(struct bcm_sf2_priv *priv,
 static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 			      struct phy_device *phy)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	s8 cpu_port = ds->dst[ds->index].cpu_port;
 	u32 reg;
 
@@ -371,7 +374,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 				 struct phy_device *phy)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	u32 off, reg;
 
 	if (priv->wol_ports_mask & (1 << port))
@@ -403,7 +406,7 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 static int bcm_sf2_eee_init(struct dsa_switch *ds, int port,
 			    struct phy_device *phy)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_eee *p = &priv->port_sts[port].eee;
 	int ret;
 
@@ -421,7 +424,7 @@ static int bcm_sf2_eee_init(struct dsa_switch *ds, int port,
 static int bcm_sf2_sw_get_eee(struct dsa_switch *ds, int port,
 			      struct ethtool_eee *e)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_eee *p = &priv->port_sts[port].eee;
 	u32 reg;
 
@@ -436,7 +439,7 @@ static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
 			      struct phy_device *phydev,
 			      struct ethtool_eee *e)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_eee *p = &priv->port_sts[port].eee;
 
 	p->eee_enabled = e->eee_enabled;
@@ -482,7 +485,7 @@ static int bcm_sf2_fast_age_op(struct bcm_sf2_priv *priv)
  */
 static int bcm_sf2_sw_fast_age_port(struct dsa_switch *ds, int port)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 
 	core_writel(priv, port, CORE_FAST_AGE_PORT);
 
@@ -555,7 +558,7 @@ static int bcm_sf2_get_vlan_entry(struct bcm_sf2_priv *priv, u16 vid,
 static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
 			      struct net_device *bridge)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	s8 cpu_port = ds->dst->cpu_port;
 	unsigned int i;
 	u32 reg, p_ctl;
@@ -598,7 +601,7 @@ static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
 
 static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct net_device *bridge = priv->port_sts[port].bridge_dev;
 	s8 cpu_port = ds->dst->cpu_port;
 	unsigned int i;
@@ -636,7 +639,7 @@ static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
 static void bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
 					u8 state)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	u8 hw_state, cur_hw_state;
 	u32 reg;
 
@@ -816,7 +819,7 @@ static void bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 
 	if (bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
 		pr_err("%s: failed to add MAC address\n", __func__);
@@ -825,7 +828,7 @@ static void bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
 static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, int port,
 			      const struct switchdev_obj_port_fdb *fdb)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 
 	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
 }
@@ -882,7 +885,7 @@ static int bcm_sf2_sw_fdb_dump(struct dsa_switch *ds, int port,
 			       struct switchdev_obj_port_fdb *fdb,
 			       int (*cb)(struct switchdev_obj *obj))
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct net_device *dev = ds->ports[port].netdev;
 	struct bcm_sf2_arl_entry results[2];
 	unsigned int count = 0;
@@ -1073,7 +1076,7 @@ static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
 
 static int bcm_sf2_mdio_register(struct dsa_switch *ds)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct device_node *dn;
 	static int index;
 	int err;
@@ -1144,7 +1147,7 @@ static int bcm_sf2_sw_set_addr(struct dsa_switch *ds, u8 *addr)
 
 static u32 bcm_sf2_sw_get_phy_flags(struct dsa_switch *ds, int port)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 
 	/* The BCM7xxx PHY driver expects to find the integrated PHY revision
 	 * in bits 15:8 and the patch level in bits 7:0 which is exactly what
@@ -1157,7 +1160,7 @@ static u32 bcm_sf2_sw_get_phy_flags(struct dsa_switch *ds, int port)
 static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
 				   struct phy_device *phydev)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	u32 id_mode_dis = 0, port_mode;
 	const char *str = NULL;
 	u32 reg;
@@ -1237,7 +1240,7 @@ force_link:
 static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 					 struct fixed_phy_status *status)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	u32 duplex, pause;
 	u32 reg;
 
@@ -1289,7 +1292,7 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 
 static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int port;
 
 	bcm_sf2_intr_disable(priv);
@@ -1309,7 +1312,7 @@ static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 
 static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int port;
 	int ret;
 
@@ -1336,7 +1339,7 @@ static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 			       struct ethtool_wolinfo *wol)
 {
 	struct net_device *p = ds->dst[ds->index].master_netdev;
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_wolinfo pwol;
 
 	/* Get the parent device WoL settings */
@@ -1359,7 +1362,7 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 			      struct ethtool_wolinfo *wol)
 {
 	struct net_device *p = ds->dst[ds->index].master_netdev;
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	s8 cpu_port = ds->dst[ds->index].cpu_port;
 	struct ethtool_wolinfo pwol;
 
@@ -1420,7 +1423,7 @@ static void bcm_sf2_enable_vlan(struct bcm_sf2_priv *priv, bool enable)
 
 static void bcm_sf2_sw_configure_vlan(struct dsa_switch *ds)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int port;
 
 	/* Clear all VLANs */
@@ -1444,7 +1447,7 @@ static int bcm_sf2_sw_vlan_prepare(struct dsa_switch *ds, int port,
 				   const struct switchdev_obj_port_vlan *vlan,
 				   struct switchdev_trans *trans)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 
 	bcm_sf2_enable_vlan(priv, true);
 
@@ -1455,7 +1458,7 @@ static void bcm_sf2_sw_vlan_add(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_vlan *vlan,
 				struct switchdev_trans *trans)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	s8 cpu_port = ds->dst->cpu_port;
@@ -1488,7 +1491,7 @@ static void bcm_sf2_sw_vlan_add(struct dsa_switch *ds, int port,
 static int bcm_sf2_sw_vlan_del(struct dsa_switch *ds, int port,
 			       const struct switchdev_obj_port_vlan *vlan)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	s8 cpu_port = ds->dst->cpu_port;
 	struct bcm_sf2_vlan *vl;
@@ -1530,7 +1533,7 @@ static int bcm_sf2_sw_vlan_dump(struct dsa_switch *ds, int port,
 				struct switchdev_obj_port_vlan *vlan,
 				int (*cb)(struct switchdev_obj *obj))
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct bcm_sf2_port_status *p = &priv->port_sts[port];
 	struct bcm_sf2_vlan *vl;
 	u16 vid, pvid;
@@ -1562,7 +1565,7 @@ static int bcm_sf2_sw_vlan_dump(struct dsa_switch *ds, int port,
 
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int port;
 
 	/* Enable all valid ports and disable those unused */
@@ -1613,11 +1616,112 @@ static struct dsa_switch_ops bcm_sf2_switch_ops = {
 	.port_vlan_dump		= bcm_sf2_sw_vlan_dump,
 };
 
+/* The SWITCH_CORE register space is managed by b53 but operates on a page +
+ * register basis so we need to translate that into an address that the
+ * bus-glue understands.
+ */
+#define SF2_PAGE_REG_MKADDR(page, reg)	((page) << 10 | (reg) << 2)
+
+static int bcm_sf2_core_read8(struct b53_device *dev, u8 page, u8 reg,
+			      u8 *val)
+{
+	struct bcm_sf2_priv *priv = dev->priv;
+
+	*val = core_readl(priv, SF2_PAGE_REG_MKADDR(page, reg));
+
+	return 0;
+}
+
+static int bcm_sf2_core_read16(struct b53_device *dev, u8 page, u8 reg,
+			       u16 *val)
+{
+	struct bcm_sf2_priv *priv = dev->priv;
+
+	*val = core_readl(priv, SF2_PAGE_REG_MKADDR(page, reg));
+
+	return 0;
+}
+
+static int bcm_sf2_core_read32(struct b53_device *dev, u8 page, u8 reg,
+			       u32 *val)
+{
+	struct bcm_sf2_priv *priv = dev->priv;
+
+	*val = core_readl(priv, SF2_PAGE_REG_MKADDR(page, reg));
+
+	return 0;
+}
+
+static int bcm_sf2_core_read64(struct b53_device *dev, u8 page, u8 reg,
+			       u64 *val)
+{
+	struct bcm_sf2_priv *priv = dev->priv;
+
+	*val = core_readq(priv, SF2_PAGE_REG_MKADDR(page, reg));
+
+	return 0;
+}
+
+static int bcm_sf2_core_write8(struct b53_device *dev, u8 page, u8 reg,
+			       u8 value)
+{
+	struct bcm_sf2_priv *priv = dev->priv;
+
+	core_writel(priv, value, SF2_PAGE_REG_MKADDR(page, reg));
+
+	return 0;
+}
+
+static int bcm_sf2_core_write16(struct b53_device *dev, u8 page, u8 reg,
+				u16 value)
+{
+	struct bcm_sf2_priv *priv = dev->priv;
+
+	core_writel(priv, value, SF2_PAGE_REG_MKADDR(page, reg));
+
+	return 0;
+}
+
+static int bcm_sf2_core_write32(struct b53_device *dev, u8 page, u8 reg,
+				u32 value)
+{
+	struct bcm_sf2_priv *priv = dev->priv;
+
+	core_writel(priv, value, SF2_PAGE_REG_MKADDR(page, reg));
+
+	return 0;
+}
+
+static int bcm_sf2_core_write64(struct b53_device *dev, u8 page, u8 reg,
+				u64 value)
+{
+	struct bcm_sf2_priv *priv = dev->priv;
+
+	core_writeq(priv, value, SF2_PAGE_REG_MKADDR(page, reg));
+
+	return 0;
+}
+
+struct b53_io_ops bcm_sf2_io_ops = {
+	.read8	= bcm_sf2_core_read8,
+	.read16	= bcm_sf2_core_read16,
+	.read32	= bcm_sf2_core_read32,
+	.read48	= bcm_sf2_core_read64,
+	.read64	= bcm_sf2_core_read64,
+	.write8	= bcm_sf2_core_write8,
+	.write16 = bcm_sf2_core_write16,
+	.write32 = bcm_sf2_core_write32,
+	.write48 = bcm_sf2_core_write64,
+	.write64 = bcm_sf2_core_write64,
+};
+
 static int bcm_sf2_sw_probe(struct platform_device *pdev)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
 	struct device_node *dn = pdev->dev.of_node;
+	struct b53_platform_data *pdata;
 	struct bcm_sf2_priv *priv;
+	struct b53_device *dev;
 	struct dsa_switch *ds;
 	void __iomem **base;
 	struct resource *r;
@@ -1625,16 +1729,49 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	u32 reg, rev;
 	int ret;
 
-	ds = devm_kzalloc(&pdev->dev, sizeof(*ds) + sizeof(*priv), GFP_KERNEL);
-	if (!ds)
+	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	dev = b53_switch_alloc(&pdev->dev, &bcm_sf2_io_ops, priv);
+	if (!dev)
 		return -ENOMEM;
 
-	priv = (struct bcm_sf2_priv *)(ds + 1);
-	ds->priv = priv;
-	ds->dev = &pdev->dev;
-	ds->ops = &bcm_sf2_switch_ops;
+	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata)
+		return -ENOMEM;
+
+	/* Auto-detection using standard registers will not work, so
+	 * provide an indication of what kind of device we are for
+	 * b53_common to work with
+	 */
+	pdata->chip_id = BCM7445_DEVICE_ID;
+	dev->pdata = pdata;
+
+	priv->dev = dev;
+	ds = dev->ds;
+
+	/* Override the parts that are non-standard wrt. normal b53 devices */
+	ds->ops->get_tag_protocol = bcm_sf2_sw_get_tag_protocol;
+	ds->ops->setup = bcm_sf2_sw_setup;
+	ds->ops->get_phy_flags = bcm_sf2_sw_get_phy_flags;
+	ds->ops->adjust_link = bcm_sf2_sw_adjust_link;
+	ds->ops->fixed_link_update = bcm_sf2_sw_fixed_link_update;
+	ds->ops->suspend = bcm_sf2_sw_suspend;
+	ds->ops->resume = bcm_sf2_sw_resume;
+	ds->ops->get_wol = bcm_sf2_sw_get_wol;
+	ds->ops->set_wol = bcm_sf2_sw_set_wol;
+	ds->ops->port_enable = bcm_sf2_port_setup;
+	ds->ops->port_disable = bcm_sf2_port_disable;
+	ds->ops->get_eee = bcm_sf2_sw_get_eee;
+	ds->ops->set_eee = bcm_sf2_sw_set_eee;
+
+	/* Avoid having DSA free our slave MDIO bus (checking for
+	 * ds->slave_mii_bus and ds->ops->phy_read being non-NULL)
+	 */
+	ds->ops->phy_read = NULL;
 
-	dev_set_drvdata(&pdev->dev, ds);
+	dev_set_drvdata(&pdev->dev, priv);
 
 	spin_lock_init(&priv->indir_lock);
 	mutex_init(&priv->stats_mutex);
@@ -1709,7 +1846,7 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	rev = reg_readl(priv, REG_PHY_REVISION);
 	priv->hw_params.gphy_rev = rev & PHY_REVISION_MASK;
 
-	ret = dsa_register_switch(ds, dn);
+	ret = b53_switch_register(dev);
 	if (ret)
 		goto out_mdio;
 
@@ -1727,13 +1864,12 @@ out_mdio:
 
 static int bcm_sf2_sw_remove(struct platform_device *pdev)
 {
-	struct dsa_switch *ds = platform_get_drvdata(pdev);
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv = platform_get_drvdata(pdev);
 
 	/* Disable all ports and interrupts */
 	priv->wol_ports_mask = 0;
-	bcm_sf2_sw_suspend(ds);
-	dsa_unregister_switch(ds);
+	bcm_sf2_sw_suspend(priv->dev->ds);
+	dsa_unregister_switch(priv->dev->ds);
 	bcm_sf2_mdio_unregister(priv);
 
 	return 0;
@@ -1743,17 +1879,17 @@ static int bcm_sf2_sw_remove(struct platform_device *pdev)
 static int bcm_sf2_suspend(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
-	struct dsa_switch *ds = platform_get_drvdata(pdev);
+	struct bcm_sf2_priv *priv = platform_get_drvdata(pdev);
 
-	return dsa_switch_suspend(ds);
+	return dsa_switch_suspend(priv->dev->ds);
 }
 
 static int bcm_sf2_resume(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
-	struct dsa_switch *ds = platform_get_drvdata(pdev);
+	struct bcm_sf2_priv *priv = platform_get_drvdata(pdev);
 
-	return dsa_switch_resume(ds);
+	return dsa_switch_resume(priv->dev->ds);
 }
 #endif /* CONFIG_PM_SLEEP */
 
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 463bed8cbe4c..7e95fb7d5d2e 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -26,6 +26,7 @@
 #include <net/dsa.h>
 
 #include "bcm_sf2_regs.h"
+#include "b53/b53_priv.h"
 
 struct bcm_sf2_hw_params {
 	u16	top_rev;
@@ -134,6 +135,9 @@ struct bcm_sf2_priv {
 	u32				irq1_stat;
 	u32				irq1_mask;
 
+	/* Backing b53_device */
+	struct b53_device		*dev;
+
 	/* Mutex protecting access to the MIB counters */
 	struct mutex			stats_mutex;
 
@@ -160,6 +164,13 @@ struct bcm_sf2_priv {
 	struct bcm_sf2_vlan		vlans[VLAN_N_VID];
 };
 
+static inline struct bcm_sf2_priv *bcm_sf2_to_priv(struct dsa_switch *ds)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+
+	return dev->priv;
+}
+
 struct bcm_sf2_hw_stats {
 	const char	*string;
 	u16		reg;
-- 
2.7.4
