From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] net: dsa: bcm_sf2: Make it a real platform device driver
Date: Thu, 18 Aug 2016 15:30:14 -0700
Message-ID: <1471559416-13249-4-git-send-email-f.fainelli@gmail.com>
References: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34063 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754572AbcHSBEl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:04:41 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so561017pfb.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 18:03:52 -0700 (PDT)
In-Reply-To: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
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
 drivers/net/dsa/bcm_sf2.c | 178 ++++++++++++++++++++++++++++++----------------
 net/dsa/dsa.c             |   1 -
 2 files changed, 118 insertions(+), 61 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index b2b838724a9b..fe1cc92f72a8 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1571,23 +1571,84 @@ static int bcm_sf2_sw_vlan_dump(struct dsa_switch *ds, int port,
 
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
-	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	struct device_node *dn;
-	void __iomem **base;
 	unsigned int port;
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
+	bcm_sf2_sw_configure_vlan(ds);
+
+	return 0;
+}
+
+static struct dsa_switch_driver bcm_sf2_switch_driver = {
+	.tag_protocol		= DSA_TAG_PROTO_BRCM,
+	.probe			= bcm_sf2_sw_drv_probe,
+	.setup			= bcm_sf2_sw_setup,
+	.set_addr		= bcm_sf2_sw_set_addr,
+	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
+	.get_strings		= bcm_sf2_sw_get_strings,
+	.get_ethtool_stats	= bcm_sf2_sw_get_ethtool_stats,
+	.get_sset_count		= bcm_sf2_sw_get_sset_count,
+	.adjust_link		= bcm_sf2_sw_adjust_link,
+	.fixed_link_update	= bcm_sf2_sw_fixed_link_update,
+	.suspend		= bcm_sf2_sw_suspend,
+	.resume			= bcm_sf2_sw_resume,
+	.get_wol		= bcm_sf2_sw_get_wol,
+	.set_wol		= bcm_sf2_sw_set_wol,
+	.port_enable		= bcm_sf2_port_setup,
+	.port_disable		= bcm_sf2_port_disable,
+	.get_eee		= bcm_sf2_sw_get_eee,
+	.set_eee		= bcm_sf2_sw_set_eee,
+	.port_bridge_join	= bcm_sf2_sw_br_join,
+	.port_bridge_leave	= bcm_sf2_sw_br_leave,
+	.port_stp_state_set	= bcm_sf2_sw_br_set_stp_state,
+	.port_fdb_prepare	= bcm_sf2_sw_fdb_prepare,
+	.port_fdb_add		= bcm_sf2_sw_fdb_add,
+	.port_fdb_del		= bcm_sf2_sw_fdb_del,
+	.port_fdb_dump		= bcm_sf2_sw_fdb_dump,
+	.port_vlan_filtering	= bcm_sf2_sw_vlan_filtering,
+	.port_vlan_prepare	= bcm_sf2_sw_vlan_prepare,
+	.port_vlan_add		= bcm_sf2_sw_vlan_add,
+	.port_vlan_del		= bcm_sf2_sw_vlan_del,
+	.port_vlan_dump		= bcm_sf2_sw_vlan_dump,
+};
+
+static int bcm_sf2_sw_probe(struct platform_device *pdev)
+{
+	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
+	struct device_node *dn = pdev->dev.of_node;
+	struct bcm_sf2_priv *priv;
+	struct dsa_switch *ds;
+	void __iomem **base;
 	unsigned int i;
 	u32 reg, rev;
 	int ret;
 
+	ds = devm_kzalloc(&pdev->dev, sizeof(*ds) + sizeof(*priv), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	priv = (struct bcm_sf2_priv *)(ds + 1);
+	ds->priv = priv;
+	ds->dev = &pdev->dev;
+	ds->drv = &bcm_sf2_switch_driver;
+
+	dev_set_drvdata(&pdev->dev, ds);
+
 	spin_lock_init(&priv->indir_lock);
 	mutex_init(&priv->stats_mutex);
 
-	/* All the interesting properties are at the parent device_node
-	 * level
-	 */
-	dn = ds->cd->of_node->parent;
-	bcm_sf2_identify_ports(priv, ds->cd->of_node);
+	bcm_sf2_identify_ports(priv, dn->child);
 
 	priv->irq0 = irq_of_parse_and_map(dn, 0);
 	priv->irq1 = irq_of_parse_and_map(dn, 1);
@@ -1649,19 +1710,6 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 				 &priv->hw_params.num_gphy))
 		priv->hw_params.num_gphy = 1;
 
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
-	bcm_sf2_sw_configure_vlan(ds);
-
 	rev = reg_readl(priv, REG_SWITCH_REVISION);
 	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
 					SWITCH_TOP_REV_MASK;
@@ -1670,6 +1718,10 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	rev = reg_readl(priv, REG_PHY_REVISION);
 	priv->hw_params.gphy_rev = rev & PHY_REVISION_MASK;
 
+	ret = dsa_register_switch(ds, dn);
+	if (ret)
+		goto out_free_irq1;
+
 	pr_info("Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
 		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
 		priv->hw_params.core_rev >> 8, priv->hw_params.core_rev & 0xff,
@@ -1677,6 +1729,8 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 
 	return 0;
 
+out_free_irq1:
+	free_irq(priv->irq1, priv);
 out_free_irq0:
 	free_irq(priv->irq0, priv);
 out_mdio:
@@ -1691,52 +1745,56 @@ out_unmap:
 	return ret;
 }
 
-static struct dsa_switch_driver bcm_sf2_switch_driver = {
-	.tag_protocol		= DSA_TAG_PROTO_BRCM,
-	.probe			= bcm_sf2_sw_drv_probe,
-	.setup			= bcm_sf2_sw_setup,
-	.set_addr		= bcm_sf2_sw_set_addr,
-	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
-	.get_strings		= bcm_sf2_sw_get_strings,
-	.get_ethtool_stats	= bcm_sf2_sw_get_ethtool_stats,
-	.get_sset_count		= bcm_sf2_sw_get_sset_count,
-	.adjust_link		= bcm_sf2_sw_adjust_link,
-	.fixed_link_update	= bcm_sf2_sw_fixed_link_update,
-	.suspend		= bcm_sf2_sw_suspend,
-	.resume			= bcm_sf2_sw_resume,
-	.get_wol		= bcm_sf2_sw_get_wol,
-	.set_wol		= bcm_sf2_sw_set_wol,
-	.port_enable		= bcm_sf2_port_setup,
-	.port_disable		= bcm_sf2_port_disable,
-	.get_eee		= bcm_sf2_sw_get_eee,
-	.set_eee		= bcm_sf2_sw_set_eee,
-	.port_bridge_join	= bcm_sf2_sw_br_join,
-	.port_bridge_leave	= bcm_sf2_sw_br_leave,
-	.port_stp_state_set	= bcm_sf2_sw_br_set_stp_state,
-	.port_fdb_prepare	= bcm_sf2_sw_fdb_prepare,
-	.port_fdb_add		= bcm_sf2_sw_fdb_add,
-	.port_fdb_del		= bcm_sf2_sw_fdb_del,
-	.port_fdb_dump		= bcm_sf2_sw_fdb_dump,
-	.port_vlan_filtering	= bcm_sf2_sw_vlan_filtering,
-	.port_vlan_prepare	= bcm_sf2_sw_vlan_prepare,
-	.port_vlan_add		= bcm_sf2_sw_vlan_add,
-	.port_vlan_del		= bcm_sf2_sw_vlan_del,
-	.port_vlan_dump		= bcm_sf2_sw_vlan_dump,
-};
-
-static int __init bcm_sf2_init(void)
+static int bcm_sf2_sw_remove(struct platform_device *pdev)
 {
-	register_switch_driver(&bcm_sf2_switch_driver);
+	struct dsa_switch *ds = platform_get_drvdata(pdev);
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	/* Disable all ports and interrupts */
+	priv->wol_ports_mask = 0;
+	bcm_sf2_sw_suspend(ds);
+	dsa_unregister_switch(ds);
+	bcm_sf2_mdio_unregister(priv);
 
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
index 9f5b47200365..8bda74e595a5 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -1088,7 +1088,6 @@ static int dsa_resume(struct device *d)
 static SIMPLE_DEV_PM_OPS(dsa_pm_ops, dsa_suspend, dsa_resume);
 
 static const struct of_device_id dsa_of_match_table[] = {
-	{ .compatible = "brcm,bcm7445-switch-v4.0" },
 	{ .compatible = "marvell,dsa", },
 	{}
 };
-- 
2.7.4
