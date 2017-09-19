From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 08/12] net: dsa: b53: Move EEE functions to b53
Date: Mon, 18 Sep 2017 19:19:43 -0700
Message-ID: <20170919021947.8971-9-f.fainelli@gmail.com>
References: <20170919021947.8971-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35307 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdISCZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 22:25:28 -0400
Received: by mail-wm0-f68.google.com with SMTP id e64so2514436wmi.2
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 19:25:27 -0700 (PDT)
In-Reply-To: <20170919021947.8971-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the bcm_sf2 EEE-related functions to the b53 driver because this is shared
code amongst Gigabit capable switch, only 5325 and 5365 are too old to support
that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 63 ++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/b53/b53_priv.h   |  5 +++
 drivers/net/dsa/bcm_sf2.c        | 66 ++++------------------------------------
 drivers/net/dsa/bcm_sf2.h        |  2 --
 drivers/net/dsa/bcm_sf2_regs.h   |  3 --
 5 files changed, 74 insertions(+), 65 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index aa2187c71ea5..491e4ffa8a0e 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1531,6 +1531,69 @@ void b53_mirror_del(struct dsa_switch *ds, int port,
 }
 EXPORT_SYMBOL(b53_mirror_del);
 
+void b53_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
+{
+	struct b53_device *dev = ds->priv;
+	u16 reg;
+
+	b53_read16(dev, B53_EEE_PAGE, B53_EEE_EN_CTRL, &reg);
+	if (enable)
+		reg |= BIT(port);
+	else
+		reg &= ~BIT(port);
+	b53_write16(dev, B53_EEE_PAGE, B53_EEE_EN_CTRL, reg);
+}
+EXPORT_SYMBOL(b53_eee_enable_set);
+
+
+/* Returns 0 if EEE was not enabled, or 1 otherwise
+ */
+int b53_eee_init(struct dsa_switch *ds, int port, struct phy_device *phy)
+{
+	int ret;
+
+	ret = phy_init_eee(phy, 0);
+	if (ret)
+		return 0;
+
+	b53_eee_enable_set(ds, port, true);
+
+	return 1;
+}
+EXPORT_SYMBOL(b53_eee_init);
+
+int b53_get_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
+{
+	struct b53_device *dev = ds->priv;
+	struct ethtool_eee *p = &dev->ports[port].eee;
+	u16 reg;
+
+	if (is5325(dev) || is5365(dev))
+		return -EOPNOTSUPP;
+
+	b53_read16(dev, B53_EEE_PAGE, B53_EEE_LPI_INDICATE, &reg);
+	e->eee_enabled = p->eee_enabled;
+	e->eee_active = !!(reg & BIT(port));
+
+	return 0;
+}
+EXPORT_SYMBOL(b53_get_mac_eee);
+
+int b53_set_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
+{
+	struct b53_device *dev = ds->priv;
+	struct ethtool_eee *p = &dev->ports[port].eee;
+
+	if (is5325(dev) || is5365(dev))
+		return -EOPNOTSUPP;
+
+	p->eee_enabled = e->eee_enabled;
+	b53_eee_enable_set(ds, port, e->eee_enabled);
+
+	return 0;
+}
+EXPORT_SYMBOL(b53_set_mac_eee);
+
 static const struct dsa_switch_ops b53_switch_ops = {
 	.get_tag_protocol	= b53_get_tag_protocol,
 	.setup			= b53_setup,
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 44297b7c3795..0ed59672ef07 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -70,6 +70,7 @@ enum {
 
 struct b53_port {
 	u16		vlan_ctl_mask;
+	struct ethtool_eee eee;
 };
 
 struct b53_vlan {
@@ -310,5 +311,9 @@ int b53_mirror_add(struct dsa_switch *ds, int port,
 void b53_mirror_del(struct dsa_switch *ds, int port,
 		    struct dsa_mall_mirror_tc_entry *mirror);
 void b53_brcm_hdr_setup(struct dsa_switch *ds, int port);
+void b53_eee_enable_set(struct dsa_switch *ds, int port, bool enable);
+int b53_eee_init(struct dsa_switch *ds, int port, struct phy_device *phy);
+int b53_get_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
+int b53_set_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
 
 #endif
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 49cb51223f70..4e8ef4c07eab 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -107,19 +107,6 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 	core_writel(priv, reg, offset);
 }
 
-static void bcm_sf2_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	u32 reg;
-
-	reg = core_readl(priv, CORE_EEE_EN_CTRL);
-	if (enable)
-		reg |= 1 << port;
-	else
-		reg &= ~(1 << port);
-	core_writel(priv, reg, CORE_EEE_EN_CTRL);
-}
-
 static void bcm_sf2_gphy_enable_set(struct dsa_switch *ds, bool enable)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
@@ -256,8 +243,8 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	bcm_sf2_imp_vlan_setup(ds, cpu_port);
 
 	/* If EEE was enabled, restore it */
-	if (priv->port_sts[port].eee.eee_enabled)
-		bcm_sf2_eee_enable_set(ds, port, true);
+	if (priv->dev->ports[port].eee.eee_enabled)
+		b53_eee_enable_set(ds, port, true);
 
 	return 0;
 }
@@ -292,47 +279,6 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 	core_writel(priv, reg, CORE_MEM_PSM_VDD_CTRL);
 }
 
-/* Returns 0 if EEE was not enabled, or 1 otherwise
- */
-static int bcm_sf2_eee_init(struct dsa_switch *ds, int port,
-			    struct phy_device *phy)
-{
-	int ret;
-
-	ret = phy_init_eee(phy, 0);
-	if (ret)
-		return 0;
-
-	bcm_sf2_eee_enable_set(ds, port, true);
-
-	return 1;
-}
-
-static int bcm_sf2_sw_get_mac_eee(struct dsa_switch *ds, int port,
-				  struct ethtool_eee *e)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	struct ethtool_eee *p = &priv->port_sts[port].eee;
-	u32 reg;
-
-	reg = core_readl(priv, CORE_EEE_LPI_INDICATE);
-	e->eee_enabled = p->eee_enabled;
-	e->eee_active = !!(reg & (1 << port));
-
-	return 0;
-}
-
-static int bcm_sf2_sw_set_mac_eee(struct dsa_switch *ds, int port,
-				  struct ethtool_eee *e)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	struct ethtool_eee *p = &priv->port_sts[port].eee;
-
-	p->eee_enabled = e->eee_enabled;
-	bcm_sf2_eee_enable_set(ds, port, e->eee_enabled);
-
-	return 0;
-}
 
 static int bcm_sf2_sw_indir_rw(struct bcm_sf2_priv *priv, int op, int addr,
 			       int regnum, u16 val)
@@ -567,7 +513,7 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
 				   struct phy_device *phydev)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	struct ethtool_eee *p = &priv->port_sts[port].eee;
+	struct ethtool_eee *p = &priv->dev->ports[port].eee;
 	u32 id_mode_dis = 0, port_mode;
 	const char *str = NULL;
 	u32 reg, offset;
@@ -649,7 +595,7 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
 	core_writel(priv, reg, offset);
 
 	if (!phydev->is_pseudo_fixed_link)
-		p->eee_enabled = bcm_sf2_eee_init(ds, port, phydev);
+		p->eee_enabled = b53_eee_init(ds, port, phydev);
 }
 
 static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
@@ -978,8 +924,8 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.set_wol		= bcm_sf2_sw_set_wol,
 	.port_enable		= bcm_sf2_port_setup,
 	.port_disable		= bcm_sf2_port_disable,
-	.get_mac_eee		= bcm_sf2_sw_get_mac_eee,
-	.set_mac_eee		= bcm_sf2_sw_set_mac_eee,
+	.get_mac_eee		= b53_get_mac_eee,
+	.set_mac_eee		= b53_set_mac_eee,
 	.port_bridge_join	= b53_br_join,
 	.port_bridge_leave	= b53_br_leave,
 	.port_stp_state_set	= b53_br_set_stp_state,
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 02c499f9c56b..1922e027ff59 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -48,8 +48,6 @@ struct bcm_sf2_hw_params {
 
 struct bcm_sf2_port_status {
 	unsigned int link;
-
-	struct ethtool_eee eee;
 };
 
 struct bcm_sf2_cfp_priv {
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 788361ad68a0..d8b8074a47b9 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -244,9 +244,6 @@ enum bcm_sf2_reg_offs {
 
 #define CORE_JOIN_ALL_VLAN_EN		0xd140
 
-#define CORE_EEE_EN_CTRL		0x24800
-#define CORE_EEE_LPI_INDICATE		0x24810
-
 #define CORE_CFP_ACC			0x28000
 #define  OP_STR_DONE			(1 << 0)
 #define  OP_SEL_SHIFT			1
-- 
2.9.3
