From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 2/2] phy: fixed-phy: Allow DT description of an MDIO bus and PHYs.
Date: Sat, 12 Mar 2016 00:08:46 +0100
Message-ID: <1457737726-23907-3-git-send-email-andrew@lunn.ch>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55224 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbcCKXIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:08:51 -0500
In-Reply-To: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not all MACs are connected to PHYs. They can for example be connected
to a switch. Using the fixed PHY properties with the MAC is possible,
but requires support in the MAC. It is however simpler to make use of
the phy-handle property to point to a PHY. To achieve this, the PHY
must be in the device tree.

Allow virtual MDIO busses to be represented in device tree, which
contains virtual fixed-phys.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/fixed-link.txt         |  39 +++++++
 drivers/net/phy/fixed_phy.c                        | 122 ++++++++++++++++++++-
 2 files changed, 157 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
index ec5d889fe3d8..2a22b92007fa 100644
--- a/Documentation/devicetree/bindings/net/fixed-link.txt
+++ b/Documentation/devicetree/bindings/net/fixed-link.txt
@@ -52,3 +52,42 @@ ethernet@1 {
 	};
 	...
 };
+
+Fixed link PHYs on an MDIO bus
+------------------------------
+
+An alternative to using the fixed link properties in the MAC is to
+define an MDIO bus with a number of fixed link phys on it.
+
+Required properties:
+- compatible = ""linux,mdio-fixed-phy";
+- #address-cells = <1>;
+- #size-cells = <0>;
+
+Child nodes represent PHYs on this mdio bus. Standard properties for
+fixed links, 'speed', 'full-duplex', 'pause', 'asym-pause',
+'link-gpios', as defined above are used. Additionally a 'reg' property
+is required for the address of the PHY on the bus. This should be of
+value 0 to 31.
+
+Example
+-------
+
+mdio {
+	compatible = "linux,mdio-fixed-phy";
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	phy0: phy@0 {
+		reg = <0>;
+		speed = <1000>;
+		pause;
+		link-gpios = <&gpio0 12 GPIO_ACTIVE_HIGH>;
+	};
+
+	phy1: phy@8 {
+		reg = <8>;
+		speed = <100>;
+		full-duplex;
+	};
+};
diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index fc07a8866020..4df2fcdcee68 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -22,6 +22,8 @@
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/of.h>
+#include <linux/of_irq.h>
+#include <linux/of_mdio.h>
 #include <linux/gpio.h>
 
 #define MII_REGS_NUM 29
@@ -241,12 +243,12 @@ int fixed_phy_update_state(struct phy_device *phydev,
 }
 EXPORT_SYMBOL(fixed_phy_update_state);
 
-int fixed_phy_add(unsigned int irq, int phy_addr,
-		  struct fixed_phy_status *status,
-		  int link_gpio)
+int fixed_phy_add_fmb(struct fixed_mdio_bus *fmb,
+		      unsigned int irq, int phy_addr,
+		      struct fixed_phy_status *status,
+		      int link_gpio)
 {
 	int ret;
-	struct fixed_mdio_bus *fmb = &platform_fmb;
 	struct fixed_phy *fp;
 
 	fp = kzalloc(sizeof(*fp), GFP_KERNEL);
@@ -283,6 +285,14 @@ err_regs:
 	kfree(fp);
 	return ret;
 }
+
+int fixed_phy_add(unsigned int irq, int phy_addr,
+		  struct fixed_phy_status *status,
+		  int link_gpio)
+{
+	return fixed_phy_add_fmb(&platform_fmb, irq, phy_addr, status,
+				 link_gpio);
+}
 EXPORT_SYMBOL_GPL(fixed_phy_add);
 
 static void fixed_phy_del(int phy_addr)
@@ -378,6 +388,103 @@ void fixed_phy_unregister(struct phy_device *phy)
 }
 EXPORT_SYMBOL_GPL(fixed_phy_unregister);
 
+static int mdio_fixed_phy_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct fixed_phy_status status;
+	struct fixed_mdio_bus *fmb;
+	struct device_node *child;
+	struct mii_bus *bus;
+	int phy_addr, irq;
+	int link_gpio;
+
+	int ret;
+
+	if (!np)
+		return -EINVAL;
+
+	bus = mdiobus_alloc_size(sizeof(*fmb));
+	if (!bus)
+		return -ENOMEM;
+
+	if (strlen(pdev->name) >= MII_BUS_ID_SIZE)
+		return -EINVAL;
+
+	strncpy(bus->id, pdev->name, MII_BUS_ID_SIZE - 1);
+	bus->name = bus->id;
+	bus->parent = &pdev->dev;
+	bus->read = fixed_mdio_read;
+	bus->write = fixed_mdio_write;
+	fmb = bus->priv;
+	fmb->mii_bus = bus;
+	INIT_LIST_HEAD(&fmb->phys);
+
+	for_each_available_child_of_node(np, child) {
+		phy_addr = of_mdio_parse_addr(&pdev->dev, child);
+		if (phy_addr < 0) {
+			ret = phy_addr;
+			goto err_out_free_phys;
+		}
+		irq = irq_of_parse_and_map(child, 0);
+
+		ret = of_phy_parse_fixed_link(child, &status, &link_gpio);
+		if (ret < 0)
+			goto err_out_free_phys;
+
+		ret = fixed_phy_add_fmb(fmb, irq, phy_addr,
+					&status, link_gpio);
+		if (ret < 0)
+			goto err_out_free_phys;
+	}
+
+	ret = of_mdiobus_register(bus, np);
+	if (ret < 0)
+		goto err_out_free_mdiobus;
+
+	platform_set_drvdata(pdev, bus);
+
+	return 0;
+
+err_out_free_phys:
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
+		fixed_phy_del(phy_addr);
+
+err_out_free_mdiobus:
+	mdiobus_free(bus);
+	return ret;
+}
+
+static int mdio_fixed_phy_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = platform_get_drvdata(pdev);
+	int phy_addr;
+
+	mdiobus_unregister(bus);
+
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
+		fixed_phy_del(phy_addr);
+
+	mdiobus_free(bus);
+
+	return 0;
+}
+
+static const struct of_device_id mdio_fixed_phy_dt_ids[] = {
+	{ .compatible = "linux,mdio-fixed-phy" },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(of, mdio_fixed_phy_dt_ids);
+
+static struct platform_driver mdio_fixed_phy_driver = {
+	.probe = mdio_fixed_phy_probe,
+	.remove = mdio_fixed_phy_remove,
+	.driver = {
+		.name = "mdio-fixed-phy",
+		.of_match_table = mdio_fixed_phy_dt_ids,
+	},
+};
+
 static int __init fixed_mdio_bus_init(void)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
@@ -406,8 +513,14 @@ static int __init fixed_mdio_bus_init(void)
 	if (ret)
 		goto err_mdiobus_alloc;
 
+	ret = platform_driver_register(&mdio_fixed_phy_driver);
+	if (ret)
+		goto err_mdiobus_register;
+
 	return 0;
 
+err_mdiobus_register:
+	mdiobus_unregister(fmb->mii_bus);
 err_mdiobus_alloc:
 	mdiobus_free(fmb->mii_bus);
 err_mdiobus_reg:
@@ -422,6 +535,7 @@ static void __exit fixed_mdio_bus_exit(void)
 	struct fixed_mdio_bus *fmb = &platform_fmb;
 	struct fixed_phy *fp, *tmp;
 
+	platform_driver_unregister(&mdio_fixed_phy_driver);
 	mdiobus_unregister(fmb->mii_bus);
 	mdiobus_free(fmb->mii_bus);
 	platform_device_unregister(pdev);
-- 
2.7.0
