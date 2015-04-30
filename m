From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 6/8] net: dsa: bcm_sf2: make it a real platform driver
Date: Wed, 29 Apr 2015 18:57:42 -0700
Message-ID: <1430359064-23454-7-git-send-email-f.fainelli@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36250 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbbD3B6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:10 -0400
Received: by pabsx10 with SMTP id sx10so44534258pab.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:58:09 -0700 (PDT)
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Broadcom Starfighter 2 switch driver should be a proper platform
driver, now that the DSA code has been updated to allow that, register a
switch device, feed it with the proper configuration data coming from
Device Tree and register our switch device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 239 +++++++++++++++++++++++++---------------------
 1 file changed, 128 insertions(+), 111 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index cedb572bf25a..1e75f30eaf5c 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -131,11 +131,6 @@ static int bcm_sf2_sw_get_sset_count(struct dsa_switch *ds)
 	return BCM_SF2_STATS_SIZE;
 }
 
-static char *bcm_sf2_sw_probe(struct device *host_dev, int sw_addr)
-{
-	return "Broadcom Starfighter 2";
-}
-
 static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
@@ -612,76 +607,8 @@ static void bcm_sf2_intr_disable(struct bcm_sf2_priv *priv)
 
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
-	dn = ds->pd->of_node->parent;
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
@@ -699,31 +626,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	 */
 	ds->phys_mii_mask |= ((1 << 30) | (1 << 0));
 
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
@@ -947,8 +850,10 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 		status->pause = 1;
 }
 
-static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
+static int bcm_sf2_sw_suspend(struct device *d)
 {
+	struct platform_device *pdev = to_platform_device(d);
+	struct dsa_switch *ds = platform_get_drvdata(pdev);
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	unsigned int port;
 
@@ -967,8 +872,10 @@ static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 	return 0;
 }
 
-static int bcm_sf2_sw_resume(struct dsa_switch *ds)
+static int bcm_sf2_sw_resume(struct device *d)
 {
+	struct platform_device *pdev = to_platform_device(d);
+	struct dsa_switch *ds = platform_get_drvdata(pdev);
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	unsigned int port;
 	int ret;
@@ -1044,10 +951,8 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 	return p->ethtool_ops->set_wol(p, wol);
 }
 
-static struct dsa_switch_driver bcm_sf2_switch_driver = {
+static struct dsa_switch_driver bcm_sf2_switch_ops = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
-	.priv_size		= sizeof(struct bcm_sf2_priv),
-	.probe			= bcm_sf2_sw_probe,
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
 	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
@@ -1058,8 +963,6 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.get_sset_count		= bcm_sf2_sw_get_sset_count,
 	.adjust_link		= bcm_sf2_sw_adjust_link,
 	.fixed_link_update	= bcm_sf2_sw_fixed_link_update,
-	.suspend		= bcm_sf2_sw_suspend,
-	.resume			= bcm_sf2_sw_resume,
 	.get_wol		= bcm_sf2_sw_get_wol,
 	.set_wol		= bcm_sf2_sw_set_wol,
 	.port_enable		= bcm_sf2_port_setup,
@@ -1071,19 +974,133 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.port_stp_update	= bcm_sf2_sw_br_set_stp_state,
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
 
-	return 0;
+	ds = devm_kzalloc(&pdev->dev, sizeof(*ds) + sizeof(*priv), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	priv = ds_to_priv(ds);
+
+	ds->master_dev = &pdev->dev;
+	ds->tag_protocol = DSA_TAG_PROTO_BRCM;
+	ds->drv = &bcm_sf2_switch_ops;
+
+	spin_lock_init(&priv->indir_lock);
+	mutex_init(&priv->stats_mutex);
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
+	dev_info(&pdev->dev,
+		"Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
+		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
+		priv->hw_params.core_rev >> 8, priv->hw_params.core_rev & 0xff,
+		priv->core, priv->irq0, priv->irq1);
+
+	platform_set_drvdata(pdev, ds);
+
+	return dsa_switch_register(ds);
 }
-module_init(bcm_sf2_init);
 
-static void __exit bcm_sf2_exit(void)
+static int bcm_sf2_sw_remove(struct platform_device *pdev)
 {
-	unregister_switch_driver(&bcm_sf2_switch_driver);
+	struct dsa_switch *ds = platform_get_drvdata(pdev);
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	/* Disable all ports and interrupts */
+	priv->wol_ports_mask = 0;
+	bcm_sf2_sw_suspend(&pdev->dev);
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
 }
-module_exit(bcm_sf2_exit);
+
+static SIMPLE_DEV_PM_OPS(bcm_sf2_pm_ops,
+			 bcm_sf2_sw_suspend, bcm_sf2_sw_resume);
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
-- 
2.1.0
