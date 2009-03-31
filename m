From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 11/14] net: Rework pasemi_mac driver to use of_mdio
	infrastructure
Date: Tue, 31 Mar 2009 02:27:40 -0600
Message-ID: <20090331082740.1427.29696.stgit@localhost.localdomain>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, afleming@freescale.com, galak@kernel.crashing.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:47063 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbZCaI1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 04:27:44 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1584813wah.21
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 01:27:43 -0700 (PDT)
In-Reply-To: <20090331075537.1427.7819.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.

Tested-by: Olof Johansson <olof@lixom.net>
Acked-by: Olof Johansson <olof@lixom.net>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/powerpc/platforms/pasemi/gpio_mdio.c |   32 +++++------------------------
 drivers/net/pasemi_mac.c                  |   28 ++++---------------------
 drivers/net/pasemi_mac.h                  |    1 -
 3 files changed, 9 insertions(+), 52 deletions(-)


diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index 75cc165..3bf5467 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -29,7 +29,7 @@
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
 #include <linux/phy.h>
-#include <linux/platform_device.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #define DELAY 1
@@ -39,6 +39,7 @@ static void __iomem *gpio_regs;
 struct gpio_priv {
 	int mdc_pin;
 	int mdio_pin;
+	int mdio_irqs[PHY_MAX_ADDR];
 };
 
 #define MDC_PIN(bus)	(((struct gpio_priv *)bus->priv)->mdc_pin)
@@ -218,12 +219,11 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 				     const struct of_device_id *match)
 {
 	struct device *dev = &ofdev->dev;
-	struct device_node *phy_dn, *np = ofdev->node;
+	struct device_node *np = ofdev->node;
 	struct mii_bus *new_bus;
 	struct gpio_priv *priv;
 	const unsigned int *prop;
 	int err;
-	int i;
 
 	err = -ENOMEM;
 	priv = kzalloc(sizeof(struct gpio_priv), GFP_KERNEL);
@@ -244,27 +244,7 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", *prop);
 	new_bus->priv = priv;
 
-	new_bus->phy_mask = 0;
-
-	new_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-
-	if (!new_bus->irq)
-		goto out_free_bus;
-
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		new_bus->irq[i] = NO_IRQ;
-
-	for (phy_dn = of_get_next_child(np, NULL);
-	     phy_dn != NULL;
-	     phy_dn = of_get_next_child(np, phy_dn)) {
-		const unsigned int *ip, *regp;
-
-		ip = of_get_property(phy_dn, "interrupts", NULL);
-		regp = of_get_property(phy_dn, "reg", NULL);
-		if (!ip || !regp || *regp >= PHY_MAX_ADDR)
-			continue;
-		new_bus->irq[*regp] = irq_create_mapping(NULL, *ip);
-	}
+	new_bus->irq = priv->mdio_irqs;
 
 	prop = of_get_property(np, "mdc-pin", NULL);
 	priv->mdc_pin = *prop;
@@ -275,7 +255,7 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 	new_bus->parent = dev;
 	dev_set_drvdata(dev, new_bus);
 
-	err = mdiobus_register(new_bus);
+	err = of_mdiobus_register(new_bus, np);
 
 	if (err != 0) {
 		printk(KERN_ERR "%s: Cannot register as MDIO bus, err %d\n",
@@ -286,8 +266,6 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 	return 0;
 
 out_free_irq:
-	kfree(new_bus->irq);
-out_free_bus:
 	kfree(new_bus);
 out_free_priv:
 	kfree(priv);
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 5eeb5a8..2edbba3 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -24,6 +24,7 @@
 #include <linux/dmaengine.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
+#include <linux/of_mdio.h>
 #include <linux/etherdevice.h>
 #include <asm/dma-mapping.h>
 #include <linux/in.h>
@@ -1086,34 +1087,17 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 	struct pasemi_mac *mac = netdev_priv(dev);
 	struct device_node *dn, *phy_dn;
 	struct phy_device *phydev;
-	unsigned int phy_id;
-	const phandle *ph;
-	const unsigned int *prop;
-	struct resource r;
-	int ret;
 
 	dn = pci_device_to_OF_node(mac->pdev);
-	ph = of_get_property(dn, "phy-handle", NULL);
-	if (!ph)
-		return -ENODEV;
-	phy_dn = of_find_node_by_phandle(*ph);
-
-	prop = of_get_property(phy_dn, "reg", NULL);
-	ret = of_address_to_resource(phy_dn->parent, 0, &r);
-	if (ret)
-		goto err;
-
-	phy_id = *prop;
-	snprintf(mac->phy_id, sizeof(mac->phy_id), "%x:%02x",
-		 (int)r.start, phy_id);
-
+	phy_dn = of_parse_phandle(dn, "phy-handle", 0);
 	of_node_put(phy_dn);
 
 	mac->link = 0;
 	mac->speed = 0;
 	mac->duplex = -1;
 
-	phydev = phy_connect(dev, mac->phy_id, &pasemi_adjust_link, 0, PHY_INTERFACE_MODE_SGMII);
+	phydev = of_phy_connect(dev, phy_dn, &pasemi_adjust_link, 0,
+				PHY_INTERFACE_MODE_SGMII);
 
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to phy\n", dev->name);
@@ -1123,10 +1107,6 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 	mac->phydev = phydev;
 
 	return 0;
-
-err:
-	of_node_put(phy_dn);
-	return -ENODEV;
 }
 
 
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index 1a115ec..e2f4efa 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -100,7 +100,6 @@ struct pasemi_mac {
 	int	duplex;
 
 	unsigned int	msg_enable;
-	char	phy_id[BUS_ID_SIZE];
 };
 
 /* Software status descriptor (ring_info) */

