From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/2] mdio_bus: handle only single PHY reset GPIO
Date: Mon, 12 Jun 2017 23:55:38 +0300
Message-ID: <20170612210547.823996341@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=mdio_bus-handle-only-single-PHY-reset-GPIO.patch
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 4c5e7a2c0501 ("dt-bindings: mdio: Clarify binding document")
declared that a MDIO reset GPIO property should have only a single GPIO
reference/specifier, however the supporting code was left intact, still
burdening the kernel with now apparently useless loops -- get rid of them.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

---
 drivers/net/phy/mdio_bus.c |   53 ++++++++++++++++-----------------------------
 drivers/of/of_mdio.c       |    1 
 include/linux/phy.h        |    6 +----
 3 files changed, 21 insertions(+), 39 deletions(-)

Index: net-next/drivers/net/phy/mdio_bus.c
===================================================================
--- net-next.orig/drivers/net/phy/mdio_bus.c
+++ net-next/drivers/net/phy/mdio_bus.c
@@ -353,33 +353,22 @@ int __mdiobus_register(struct mii_bus *b
 
 	mutex_init(&bus->mdio_lock);
 
-	/* de-assert bus level PHY GPIO resets */
-	if (bus->num_reset_gpios > 0) {
-		bus->reset_gpiod = devm_kcalloc(&bus->dev,
-						 bus->num_reset_gpios,
-						 sizeof(struct gpio_desc *),
-						 GFP_KERNEL);
-		if (!bus->reset_gpiod)
-			return -ENOMEM;
-	}
-
-	for (i = 0; i < bus->num_reset_gpios; i++) {
-		gpiod = devm_gpiod_get_index(&bus->dev, "reset", i,
-					     GPIOD_OUT_LOW);
-		if (IS_ERR(gpiod)) {
-			err = PTR_ERR(gpiod);
-			if (err != -ENOENT) {
-				dev_err(&bus->dev,
-					"mii_bus %s couldn't get reset GPIO\n",
-					bus->id);
-				return err;
-			}
-		} else {
-			bus->reset_gpiod[i] = gpiod;
-			gpiod_set_value_cansleep(gpiod, 1);
-			udelay(bus->reset_delay_us);
-			gpiod_set_value_cansleep(gpiod, 0);
+	/* de-assert bus level PHY GPIO reset */
+	gpiod = devm_gpiod_get(&bus->dev, "reset", GPIOD_OUT_LOW);
+	if (IS_ERR(gpiod)) {
+		err = PTR_ERR(gpiod);
+		if (err != -ENOENT) {
+			dev_err(&bus->dev,
+				"mii_bus %s couldn't get reset GPIO\n",
+				bus->id);
+			return err;
 		}
+	} else	{
+		bus->reset_gpiod = gpiod;
+
+		gpiod_set_value_cansleep(gpiod, 1);
+		udelay(bus->reset_delay_us);
+		gpiod_set_value_cansleep(gpiod, 0);
 	}
 
 	if (bus->reset)
@@ -414,10 +403,8 @@ error:
 	}
 
 	/* Put PHYs in RESET to save power */
-	for (i = 0; i < bus->num_reset_gpios; i++) {
-		if (bus->reset_gpiod[i])
-			gpiod_set_value_cansleep(bus->reset_gpiod[i], 1);
-	}
+	if (bus->reset_gpiod)
+		gpiod_set_value_cansleep(bus->reset_gpiod, 1);
 
 	device_del(&bus->dev);
 	return err;
@@ -442,10 +429,8 @@ void mdiobus_unregister(struct mii_bus *
 	}
 
 	/* Put PHYs in RESET to save power */
-	for (i = 0; i < bus->num_reset_gpios; i++) {
-		if (bus->reset_gpiod[i])
-			gpiod_set_value_cansleep(bus->reset_gpiod[i], 1);
-	}
+	if (bus->reset_gpiod)
+		gpiod_set_value_cansleep(bus->reset_gpiod, 1);
 
 	device_del(&bus->dev);
 }
Index: net-next/drivers/of/of_mdio.c
===================================================================
--- net-next.orig/drivers/of/of_mdio.c
+++ net-next/drivers/of/of_mdio.c
@@ -226,7 +226,6 @@ int of_mdiobus_register(struct mii_bus *
 	/* Get bus level PHY reset GPIO details */
 	mdio->reset_delay_us = DEFAULT_GPIO_RESET_DELAY;
 	of_property_read_u32(np, "reset-delay-us", &mdio->reset_delay_us);
-	mdio->num_reset_gpios = of_gpio_named_count(np, "reset-gpios");
 
 	/* Register the MDIO bus */
 	rc = mdiobus_register(mdio);
Index: net-next/include/linux/phy.h
===================================================================
--- net-next.orig/include/linux/phy.h
+++ net-next/include/linux/phy.h
@@ -226,10 +226,8 @@ struct mii_bus {
 
 	/* GPIO reset pulse width in microseconds */
 	int reset_delay_us;
-	/* Number of reset GPIOs */
-	int num_reset_gpios;
-	/* Array of RESET GPIO descriptors */
-	struct gpio_desc **reset_gpiod;
+	/* RESET GPIO descriptor pointer */
+	struct gpio_desc *reset_gpiod;
 };
 #define to_mii_bus(d) container_of(d, struct mii_bus, dev)
 

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
