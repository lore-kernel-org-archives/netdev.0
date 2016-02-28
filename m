From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 23/32] net: dsa: bcm_sf2: make it a real platform driver
Date: Sun, 28 Feb 2016 17:41:31 +0100
Message-ID: <1456677700-23027-24-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44913 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758186AbcB1QmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:10 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

The Broadcom Starfighter 2 switch driver should be a proper platform
driver, now that the DSA code has been updated to allow that, register
a switch device, feed it with the proper configuration data coming
from Device Tree and register our switch device with DSA.

The bulk of the changes consist in moving what bcm_sf2_sw_setup() did
into the component slave bind function.

This change does not however prevent the old DSA binding from working.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/dsa/broadcom.txt       |  54 ++++
 drivers/net/dsa/bcm_sf2.c                          | 293 ++++++++++++---------
 2 files changed, 224 insertions(+), 123 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/broadcom.txt

diff --git a/Documentation/devicetree/bindings/net/dsa/broadcom.txt b/Documentation/devicetree/bindings/net/dsa/broadcom.txt
new file mode 100644
index 000000000000..ea7c40b611fc
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/broadcom.txt
@@ -0,0 +1,54 @@
+* Broadcom Starfighter 2 integrated switch device
+
+WARNING: This binding is currently UNSTABLE. Do not write it into a
+FLASH never to be upgraded. Once it is stable, this warning will be
+removed.
+
+If you need a stable binding, see the old dsa.txt.
+
+Required properties:
+
+- compatible: should be "brcm,brcm-sf2"
+- reg: addresses and length of the register sets for the device, must be 6
+  pairs of register addresses and lengths
+- interrupts: interrupts for the devices, must be two interrupts
+
+- reg-names: litteral names for the device base register addresses,
+  when present must be: "core", "reg", "intrl2_0", "intrl2_1", "fcb",
+  "acb"
+
+- interrupt-names: litternal names for the device interrupt lines,
+  when present must be: "switch_0" and "switch_1"
+
+- brcm,num-gphy: specify the maximum number of integrated gigabit PHYs
+  in the switch
+
+Optional properties:
+
+- brcm,num-rgmii-ports: specify the maximum number of RGMII interfaces
+  supported by the switch
+
+- brcm,fcb-pause-override: boolean property, if present indicates that
+  the switch supports Failover Control Block pause override capability
+
+- brcm,acb-packets-inflight: boolean property, if present indicates
+  that the switch Admission Control Block supports reporting the
+  number of packets in-flight in a switch queue
+
+Example:
+
+	switchdev0: switchdev0 {
+		compatible = "brcm,brcm-sf2";
+		reg = <0x0 0x40000
+			0x40000 0x110
+			0x40340 0x30
+			0x40380 0x30
+			0x40400 0x34
+			0x40600 0x208>;
+		interrupts = <0 0x18 0
+				0 0x19 0>;
+		brcm,num-gphy = <1>;
+		brcm,num-rgmii-ports = <2>;
+		brcm,fcb-pause-override;
+		brcm,acb-packets-inflight;
+	};
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index c0c83c2f2691..b23b044d8401 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -9,6 +9,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -928,83 +929,8 @@ static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
 
 static int bcm_sf2_sw_setup(struct dsa_switch *ds, struct device *dev)
 {
-	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
-	struct bcm_sf2_priv *priv;
-	struct device_node *dn;
-	void __iomem **base;
-	unsigned int port;
-	unsigned int i;
-	u32 reg, rev;
-	int ret;
-
-	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
-	if (!priv)
-		return -ENOMEM;
-
-	ds->priv = priv;
-
-	spin_lock_init(&priv->indir_lock);
-	mutex_init(&priv->stats_mutex);
-
-	/* All the interesting properties are at the parent device_node
-	 * level
-	 */
-	dn = ds->pd->of_node->parent;
-	bcm_sf2_identify_ports(priv, ds->pd->of_node);
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
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	int port;
 
 	/* Enable all valid ports and disable those unused */
 	for (port = 0; port < priv->hw_params.num_ports; port++) {
@@ -1017,47 +943,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds, struct device *dev)
 			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
-	/* Include the pseudo-PHY address and the broadcast PHY address to
-	 * divert reads towards our workaround. This is only required for
-	 * 7445D0, since 7445E0 disconnects the internal switch pseudo-PHY such
-	 * that we can use the regular SWITCH_MDIO master controller instead.
-	 *
-	 * By default, DSA initializes ds->phys_mii_mask to ds->phys_port_mask
-	 * to have a 1:1 mapping between Port address and PHY address in order
-	 * to utilize the slave_mii_bus instance to read from Port PHYs. This is
-	 * not what we want here, so we initialize phys_mii_mask 0 to always
-	 * utilize the "master" MDIO bus backed by the "mdio-unimac" driver.
-	 */
-	if (of_machine_is_compatible("brcm,bcm7445d0"))
-		ds->phys_mii_mask |= ((1 << BRCM_PSEUDO_PHY_ADDR) | (1 << 0));
-	else
-		ds->phys_mii_mask = 0;
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
@@ -1399,19 +1285,180 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.port_fdb_dump		= bcm_sf2_sw_fdb_dump,
 };
 
-static int __init bcm_sf2_init(void)
+static int bcm_sf2_sw_bind(struct device *dev,
+			   struct device *master, void *data)
 {
-	register_switch_driver(&bcm_sf2_switch_driver);
+	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
+	struct platform_device *pdev = to_platform_device(dev);
+	struct dsa_switch_tree *dst = data;
+	struct bcm_sf2_priv *priv;
+	struct device_node *dn;
+	struct dsa_switch *ds;
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
+	ds->priv = priv;
+	ds->drv = &bcm_sf2_switch_driver;
+
+	spin_lock_init(&priv->indir_lock);
+	mutex_init(&priv->stats_mutex);
+
+	/* All the interesting properties are at the parent device_node
+	 * level
+	 */
+	dn = ds->pd->of_node->parent;
+	bcm_sf2_identify_ports(priv, ds->pd->of_node);
+
+	priv->irq0 = irq_of_parse_and_map(dn, 0);
+	priv->irq1 = irq_of_parse_and_map(dn, 1);
+
+	base = &priv->core;
+	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
+		*base = of_iomap(dn, i);
+		if (!base) {
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
+	/* Include the pseudo-PHY address and the broadcast PHY address to
+	 * divert reads towards our workaround. This is only required for
+	 * 7445D0, since 7445E0 disconnects the internal switch pseudo-PHY such
+	 * that we can use the regular SWITCH_MDIO master controller instead.
+	 *
+	 * By default, DSA initializes ds->phys_mii_mask to ds->phys_port_mask
+	 * to have a 1:1 mapping between Port address and PHY address in order
+	 * to utilize the slave_mii_bus instance to read from Port PHYs. This is
+	 * not what we want here, so we initialize phys_mii_mask 0 to always
+	 * utilize the "master" MDIO bus backed by the "mdio-unimac" driver.
+	 */
+	if (of_machine_is_compatible("brcm,bcm7445d0"))
+		ds->phys_mii_mask |= ((1 << BRCM_PSEUDO_PHY_ADDR) | (1 << 0));
+	else
+		ds->phys_mii_mask = 0;
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
+	platform_set_drvdata(pdev, ds);
+
+	return dsa_switch_register(dst, ds, dn, "Starfighter 2");
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
+	return ret;
+}
+
+static void bcm_sf2_sw_unbind(struct device *dev,
+			      struct device *master, void *data)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	/* Disable all ports and interrupts */
+	priv->wol_ports_mask = 0;
+	bcm_sf2_sw_suspend(ds);
+	dsa_switch_unregister(ds);
+}
+
+static const struct component_ops bcm_sf2_component_ops = {
+	.bind = bcm_sf2_sw_bind,
+	.unbind = bcm_sf2_sw_unbind,
+};
+
+static int bcm_sf2_sw_remove(struct platform_device *pdev)
+{
+	component_del(&pdev->dev, &bcm_sf2_component_ops);
 
 	return 0;
 }
-module_init(bcm_sf2_init);
 
-static void __exit bcm_sf2_exit(void)
+static int bcm_sf2_sw_probe(struct platform_device *pdev)
 {
-	unregister_switch_driver(&bcm_sf2_switch_driver);
+	return component_add(&pdev->dev, &bcm_sf2_component_ops);
 }
-module_exit(bcm_sf2_exit);
+
+static const struct of_device_id bcm_sf2_of_match[] = {
+	{ .compatible = "brcm,brcm-sf2" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, bcm_sf2_of_match);
+
+static struct platform_driver bcm_sf2_driver = {
+	.probe	= bcm_sf2_sw_probe,
+	.remove	= bcm_sf2_sw_remove,
+	.driver = {
+		.name = "brcm-sf2",
+		.of_match_table = bcm_sf2_of_match,
+	},
+};
+module_platform_driver(bcm_sf2_driver);
 
 MODULE_AUTHOR("Broadcom Corporation");
 MODULE_DESCRIPTION("Driver for Broadcom Starfighter 2 ethernet switch chip");
-- 
2.7.0
