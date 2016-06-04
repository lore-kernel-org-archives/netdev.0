From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 8/9] net: dsa: bcm_sf2: Make it a real platform device driver
Date: Fri,  3 Jun 2016 17:05:32 -0700
Message-ID: <1464998733-10405-13-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34060 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbcFDAGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:06:00 -0400
Received: by mail-pa0-f68.google.com with SMTP id x1so6939805pav.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:59 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Broadcom Starfighter 2 switch driver should be a proper platform
driver, now that the DSA code has been updated to allow that, register a
switch device, feed it with the proper configuration data coming from
Device Tree and register our switch device with DSA.

The bulk of the changes consist in moving what bcm_sf2_sw_setup() did
into the platform driver probe function.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 251 ++++++++++++++++++++++++++++------------------
 net/dsa/dsa.c             |   1 -
 2 files changed, 151 insertions(+), 101 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 73df91bb0466..8dac74a6b5df 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -934,77 +934,8 @@ static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
 
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
-	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	struct device_node *dn;
-	void __iomem **base;
 	unsigned int port;
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
 
 	/* Enable all valid ports and disable those unused */
 	for (port = 0; port < priv->hw_params.num_ports; port++) {
@@ -1034,31 +965,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	else
 		ds->phys_mii_mask = 0;
 
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
 	return 0;
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
-	return ret;
 }
 
 static int bcm_sf2_sw_set_addr(struct dsa_switch *ds, u8 *addr)
@@ -1370,7 +1277,7 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 	return p->ethtool_ops->set_wol(p, wol);
 }
 
-static struct dsa_switch_driver bcm_sf2_switch_driver = {
+static struct dsa_switch_driver bcm_sf2_switch_ops = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
 	.probe			= bcm_sf2_sw_drv_probe,
 	.setup			= bcm_sf2_sw_setup,
@@ -1400,19 +1307,163 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.port_fdb_dump		= bcm_sf2_sw_fdb_dump,
 };
 
-static int __init bcm_sf2_init(void)
+static int bcm_sf2_sw_probe(struct platform_device *pdev)
 {
-	register_switch_driver(&bcm_sf2_switch_driver);
+	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
+	struct resource *res;
+	struct dsa_switch *ds;
+	struct bcm_sf2_priv *priv;
+	struct device_node *dn = pdev->dev.of_node;
+	void __iomem **base;
+	unsigned int i;
+	u32 reg, rev;
+	int ret;
+
+	ds = devm_kzalloc(&pdev->dev, sizeof(*ds) + sizeof(*priv), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	priv = (struct bcm_sf2_priv *)(ds + 1);
+
+	ds->priv = priv;
+	ds->dev = &pdev->dev;
+	ds->drv = &bcm_sf2_switch_ops;
+
+	spin_lock_init(&priv->indir_lock);
+	mutex_init(&priv->stats_mutex);
+
+	/* The port information of the switch is in the immediate child
+	 * sub-node
+	 */
+	bcm_sf2_identify_ports(priv, dn->child);
+
+	priv->irq0 = platform_get_irq(pdev, 0);
+	priv->irq1 = platform_get_irq(pdev, 1);
+
+	base = &priv->core;
+	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
+		res = platform_get_resource(pdev, IORESOURCE_MEM, i);
+		*base = devm_ioremap_resource(&pdev->dev, res);
+		if (*base == NULL) {
+			dev_err(&pdev->dev,
+				"unable to find register: %s\n", reg_names[i]);
+			return -ENODEV;
+		}
+		base++;
+	}
+
+	ret = bcm_sf2_sw_rst(priv);
+	if (ret) {
+		pr_err("unable to software reset switch: %d\n", ret);
+		return ret;
+	}
+
+	/* Disable all interrupts and request them */
+	bcm_sf2_intr_disable(priv);
+
+	ret = devm_request_irq(&pdev->dev, priv->irq0, bcm_sf2_switch_0_isr, 0,
+			       "switch_0", priv);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "failed to request switch_0 IRQ\n");
+		return ret;
+	}
+
+	ret = devm_request_irq(&pdev->dev, priv->irq1, bcm_sf2_switch_1_isr, 0,
+			       "switch_1", priv);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "failed to request switch_1 IRQ\n");
+		return ret;
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
+	rev = reg_readl(priv, REG_SWITCH_REVISION);
+	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
+					SWITCH_TOP_REV_MASK;
+	priv->hw_params.core_rev = (rev & SF2_REV_MASK);
+
+	rev = reg_readl(priv, REG_PHY_REVISION);
+	priv->hw_params.gphy_rev = rev & PHY_REVISION_MASK;
+
+	dev_set_drvdata(&pdev->dev, ds);
+
+	ret = dsa_register_switch(ds, pdev->dev.of_node);
+	if (ret)
+		return ret;
+
+	dev_info(&pdev->dev,
+		"Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
+		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
+		priv->hw_params.core_rev >> 8, priv->hw_params.core_rev & 0xff,
+		priv->core, priv->irq0, priv->irq1);
+
+	return 0;
+}
+
+static int bcm_sf2_sw_remove(struct platform_device *pdev)
+{
+	struct dsa_switch *ds = platform_get_drvdata(pdev);
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	/* Disable all ports and interrupts */
+	priv->wol_ports_mask = 0;
+	bcm_sf2_sw_suspend(ds);
+	dsa_unregister_switch(ds);
 
 	return 0;
 }
-module_init(bcm_sf2_init);
 
-static void __exit bcm_sf2_exit(void)
+#ifdef CONFIG_PM_SLEEP
+static int bcm_sf2_suspend(struct device *dev)
 {
-	unregister_switch_driver(&bcm_sf2_switch_driver);
+	struct platform_device *pdev = to_platform_device(dev);
+	struct dsa_switch *ds = platform_get_drvdata(pdev);
+
+	return dsa_switch_suspend(ds);
 }
-module_exit(bcm_sf2_exit);
+
+static int bcm_sf2_resume(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct dsa_switch *ds = platform_get_drvdata(pdev);
+
+	return dsa_switch_resume(ds);
+}
+#endif /* CONFIG_PM_SLEEP */
+
+static SIMPLE_DEV_PM_OPS(bcm_sf2_pm_ops,
+			 bcm_sf2_suspend, bcm_sf2_resume);
+
+static const struct of_device_id bcm_sf2_of_match[] = {
+	{ .compatible = "brcm,bcm7445-switch-v4.0" },
+	{ /* sentinel */ },
+};
+
+static struct platform_driver bcm_sf2_driver = {
+	.probe	= bcm_sf2_sw_probe,
+	.remove	= bcm_sf2_sw_remove,
+	.driver = {
+		.name = "brcm-sf2",
+		.of_match_table = bcm_sf2_of_match,
+		.pm = &bcm_sf2_pm_ops,
+	},
+};
+module_platform_driver(bcm_sf2_driver);
 
 MODULE_AUTHOR("Broadcom Corporation");
 MODULE_DESCRIPTION("Driver for Broadcom Starfighter 2 ethernet switch chip");
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 8fb8de6fb82d..7abe0cd3af9c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -1065,7 +1065,6 @@ static int dsa_resume(struct device *d)
 static SIMPLE_DEV_PM_OPS(dsa_pm_ops, dsa_suspend, dsa_resume);
 
 static const struct of_device_id dsa_of_match_table[] = {
-	{ .compatible = "brcm,bcm7445-switch-v4.0" },
 	{ .compatible = "marvell,dsa", },
 	{}
 };
-- 
2.7.4
