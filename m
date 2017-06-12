From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/2] mdio_bus: use devm_gpiod_get_optional()
Date: Mon, 12 Jun 2017 23:55:39 +0300
Message-ID: <20170612210551.696721345@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Content-Disposition: inline; filename=mdio_bus-use-devm_gpiod_get_optional.patch
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The MDIO reset GPIO is really a classical optional GPIO property case,
so devm_gpiod_get_optional() should have been used, not devm_gpiod_get().
Doing this  saves several LoCs...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

---
 drivers/net/phy/mdio_bus.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

Index: net-next/drivers/net/phy/mdio_bus.c
===================================================================
--- net-next.orig/drivers/net/phy/mdio_bus.c
+++ net-next/drivers/net/phy/mdio_bus.c
@@ -354,16 +354,12 @@ int __mdiobus_register(struct mii_bus *b
 	mutex_init(&bus->mdio_lock);
 
 	/* de-assert bus level PHY GPIO reset */
-	gpiod = devm_gpiod_get(&bus->dev, "reset", GPIOD_OUT_LOW);
+	gpiod = devm_gpiod_get_optional(&bus->dev, "reset", GPIOD_OUT_LOW);
 	if (IS_ERR(gpiod)) {
-		err = PTR_ERR(gpiod);
-		if (err != -ENOENT) {
-			dev_err(&bus->dev,
-				"mii_bus %s couldn't get reset GPIO\n",
-				bus->id);
-			return err;
-		}
-	} else	{
+		dev_err(&bus->dev, "mii_bus %s couldn't get reset GPIO\n",
+			bus->id);
+		return PTR_ERR(gpiod);
+	} else	if (gpiod) {
 		bus->reset_gpiod = gpiod;
 
 		gpiod_set_value_cansleep(gpiod, 1);

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
