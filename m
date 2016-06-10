From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: dsa: bcm_sf2: Move setup function at the far end
Date: Thu,  9 Jun 2016 17:42:06 -0700
Message-ID: <1465519328-14249-3-git-send-email-f.fainelli@gmail.com>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34531 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbcFJAmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 20:42:39 -0400
Received: by mail-pf0-f195.google.com with SMTP id 66so1987870pfy.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 17:42:38 -0700 (PDT)
In-Reply-To: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-order the bcm_sf2_sw_setup() function so that it is at the far end of
the driver to avoid any kind of forward declarations.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 238 +++++++++++++++++++++++-----------------------
 1 file changed, 119 insertions(+), 119 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index ad22caba51e5..d726f5906ef9 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1065,125 +1065,6 @@ static void bcm_sf2_mdio_unregister(struct bcm_sf2_priv *priv)
 		of_node_put(priv->master_mii_dn);
 }
 
-static int bcm_sf2_sw_setup(struct dsa_switch *ds)
-{
-	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	struct device_node *dn;
-	void __iomem **base;
-	unsigned int port;
-	unsigned int i;
-	u32 reg, rev;
-	int ret;
-
-	spin_lock_init(&priv->indir_lock);
-	mutex_init(&priv->stats_mutex);
-
-	/* All the interesting properties are at the parent device_node
-	 * level
-	 */
-	dn = ds->cd->of_node->parent;
-	bcm_sf2_identify_ports(priv, ds->cd->of_node);
-
-	priv->irq0 = irq_of_parse_and_map(dn, 0);
-	priv->irq1 = irq_of_parse_and_map(dn, 1);
-
-	base = &priv->core;
-	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
-		*base = of_iomap(dn, i);
-		if (*base == NULL) {
-			pr_err("unable to find register: %s\n", reg_names[i]);
-			ret = -ENOMEM;
-			goto out_unmap;
-		}
-		base++;
-	}
-
-	ret = bcm_sf2_sw_rst(priv);
-	if (ret) {
-		pr_err("unable to software reset switch: %d\n", ret);
-		goto out_unmap;
-	}
-
-	ret = bcm_sf2_mdio_register(ds);
-	if (ret) {
-		pr_err("failed to register MDIO bus\n");
-		goto out_unmap;
-	}
-
-	/* Disable all interrupts and request them */
-	bcm_sf2_intr_disable(priv);
-
-	ret = request_irq(priv->irq0, bcm_sf2_switch_0_isr, 0,
-			  "switch_0", priv);
-	if (ret < 0) {
-		pr_err("failed to request switch_0 IRQ\n");
-		goto out_unmap;
-	}
-
-	ret = request_irq(priv->irq1, bcm_sf2_switch_1_isr, 0,
-			  "switch_1", priv);
-	if (ret < 0) {
-		pr_err("failed to request switch_1 IRQ\n");
-		goto out_free_irq0;
-	}
-
-	/* Reset the MIB counters */
-	reg = core_readl(priv, CORE_GMNCFGCFG);
-	reg |= RST_MIB_CNT;
-	core_writel(priv, reg, CORE_GMNCFGCFG);
-	reg &= ~RST_MIB_CNT;
-	core_writel(priv, reg, CORE_GMNCFGCFG);
-
-	/* Get the maximum number of ports for this switch */
-	priv->hw_params.num_ports = core_readl(priv, CORE_IMP0_PRT_ID) + 1;
-	if (priv->hw_params.num_ports > DSA_MAX_PORTS)
-		priv->hw_params.num_ports = DSA_MAX_PORTS;
-
-	/* Assume a single GPHY setup if we can't read that property */
-	if (of_property_read_u32(dn, "brcm,num-gphy",
-				 &priv->hw_params.num_gphy))
-		priv->hw_params.num_gphy = 1;
-
-	/* Enable all valid ports and disable those unused */
-	for (port = 0; port < priv->hw_params.num_ports; port++) {
-		/* IMP port receives special treatment */
-		if ((1 << port) & ds->enabled_port_mask)
-			bcm_sf2_port_setup(ds, port, NULL);
-		else if (dsa_is_cpu_port(ds, port))
-			bcm_sf2_imp_setup(ds, port);
-		else
-			bcm_sf2_port_disable(ds, port, NULL);
-	}
-
-	rev = reg_readl(priv, REG_SWITCH_REVISION);
-	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
-					SWITCH_TOP_REV_MASK;
-	priv->hw_params.core_rev = (rev & SF2_REV_MASK);
-
-	rev = reg_readl(priv, REG_PHY_REVISION);
-	priv->hw_params.gphy_rev = rev & PHY_REVISION_MASK;
-
-	pr_info("Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
-		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
-		priv->hw_params.core_rev >> 8, priv->hw_params.core_rev & 0xff,
-		priv->core, priv->irq0, priv->irq1);
-
-	return 0;
-
-out_free_irq0:
-	free_irq(priv->irq0, priv);
-out_unmap:
-	base = &priv->core;
-	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
-		if (*base)
-			iounmap(*base);
-		base++;
-	}
-	bcm_sf2_mdio_unregister(priv);
-	return ret;
-}
-
 static int bcm_sf2_sw_set_addr(struct dsa_switch *ds, u8 *addr)
 {
 	return 0;
@@ -1431,6 +1312,125 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 	return p->ethtool_ops->set_wol(p, wol);
 }
 
+static int bcm_sf2_sw_setup(struct dsa_switch *ds)
+{
+	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct device_node *dn;
+	void __iomem **base;
+	unsigned int port;
+	unsigned int i;
+	u32 reg, rev;
+	int ret;
+
+	spin_lock_init(&priv->indir_lock);
+	mutex_init(&priv->stats_mutex);
+
+	/* All the interesting properties are at the parent device_node
+	 * level
+	 */
+	dn = ds->cd->of_node->parent;
+	bcm_sf2_identify_ports(priv, ds->cd->of_node);
+
+	priv->irq0 = irq_of_parse_and_map(dn, 0);
+	priv->irq1 = irq_of_parse_and_map(dn, 1);
+
+	base = &priv->core;
+	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
+		*base = of_iomap(dn, i);
+		if (*base == NULL) {
+			pr_err("unable to find register: %s\n", reg_names[i]);
+			ret = -ENOMEM;
+			goto out_unmap;
+		}
+		base++;
+	}
+
+	ret = bcm_sf2_sw_rst(priv);
+	if (ret) {
+		pr_err("unable to software reset switch: %d\n", ret);
+		goto out_unmap;
+	}
+
+	ret = bcm_sf2_mdio_register(ds);
+	if (ret) {
+		pr_err("failed to register MDIO bus\n");
+		goto out_unmap;
+	}
+
+	/* Disable all interrupts and request them */
+	bcm_sf2_intr_disable(priv);
+
+	ret = request_irq(priv->irq0, bcm_sf2_switch_0_isr, 0,
+			  "switch_0", priv);
+	if (ret < 0) {
+		pr_err("failed to request switch_0 IRQ\n");
+		goto out_unmap;
+	}
+
+	ret = request_irq(priv->irq1, bcm_sf2_switch_1_isr, 0,
+			  "switch_1", priv);
+	if (ret < 0) {
+		pr_err("failed to request switch_1 IRQ\n");
+		goto out_free_irq0;
+	}
+
+	/* Reset the MIB counters */
+	reg = core_readl(priv, CORE_GMNCFGCFG);
+	reg |= RST_MIB_CNT;
+	core_writel(priv, reg, CORE_GMNCFGCFG);
+	reg &= ~RST_MIB_CNT;
+	core_writel(priv, reg, CORE_GMNCFGCFG);
+
+	/* Get the maximum number of ports for this switch */
+	priv->hw_params.num_ports = core_readl(priv, CORE_IMP0_PRT_ID) + 1;
+	if (priv->hw_params.num_ports > DSA_MAX_PORTS)
+		priv->hw_params.num_ports = DSA_MAX_PORTS;
+
+	/* Assume a single GPHY setup if we can't read that property */
+	if (of_property_read_u32(dn, "brcm,num-gphy",
+				 &priv->hw_params.num_gphy))
+		priv->hw_params.num_gphy = 1;
+
+	/* Enable all valid ports and disable those unused */
+	for (port = 0; port < priv->hw_params.num_ports; port++) {
+		/* IMP port receives special treatment */
+		if ((1 << port) & ds->enabled_port_mask)
+			bcm_sf2_port_setup(ds, port, NULL);
+		else if (dsa_is_cpu_port(ds, port))
+			bcm_sf2_imp_setup(ds, port);
+		else
+			bcm_sf2_port_disable(ds, port, NULL);
+	}
+
+	rev = reg_readl(priv, REG_SWITCH_REVISION);
+	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
+					SWITCH_TOP_REV_MASK;
+	priv->hw_params.core_rev = (rev & SF2_REV_MASK);
+
+	rev = reg_readl(priv, REG_PHY_REVISION);
+	priv->hw_params.gphy_rev = rev & PHY_REVISION_MASK;
+
+	pr_info("Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
+		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
+		priv->hw_params.core_rev >> 8, priv->hw_params.core_rev & 0xff,
+		priv->core, priv->irq0, priv->irq1);
+
+	return 0;
+
+out_free_irq0:
+	free_irq(priv->irq0, priv);
+out_unmap:
+	base = &priv->core;
+	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
+		if (*base)
+			iounmap(*base);
+		base++;
+	}
+	bcm_sf2_mdio_unregister(priv);
+	return ret;
+}
+
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
 	.probe			= bcm_sf2_sw_drv_probe,
-- 
2.7.4
