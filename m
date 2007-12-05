From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <Uwe.Kleine-Koenig@digi.com>
Subject: config_aneg for phy not supporting autonegotiation
Date: Wed, 5 Dec 2007 11:11:06 +0100
Message-ID: <20071205101106.GA32729@digi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail29.messagelabs.com ([216.82.249.147]:9031 "HELO
	mail29.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751761AbXLEKLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 05:11:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I added a driver for a phy that doesn't support autonegotiation (see
below).

I didn't add SUPPORTED_Autoneg to hirschmannrs422_driver.features.  I
expected that this results in hirschmannrs422_config_aneg never being
called, but that's wrong.  So I wonder what it should do.


Moreover that phy only supports 10MBit/Half but still it seems to use
something different first and short after bringing the device up I get =
a
printk saying:

	Trying 10/HALF

I didn't investigate that yet.

I couldn't find a place in the generic phy code that uses
driver.features, probably it's just that that needs fixing?

Best regards
Uwe

--->8---
=46rom: Uwe Kleine-K=F6nig <Uwe.Kleine-Koenig@digi.com>

add Hirschmann RS422 phy

Signed-off-by: Uwe Kleine-K=F6nig <Uwe.Kleine-Koenig@digi.com>
---
 drivers/net/phy/Kconfig            |    3 ++
 drivers/net/phy/Makefile           |    1 +
 drivers/net/phy/hirschmann-rs422.c |   55 ++++++++++++++++++++++++++++=
++++++++
 3 files changed, 59 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/hirschmann-rs422.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 54b2ba9..39d4905 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -90,6 +90,9 @@ config FIXED_MII_AMNT
         This control will have specified number allocated for each fix=
ed
         PHY type enabled.
=20
+config HIRSCHMANNRS422_PHY
+	tristate "Driver for Hirschmann's RS422 PHY"
+
 config MDIO_BITBANG
 	tristate "Support for bitbanged MDIO buses"
 	help
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 3d6cc7b..748d69f 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -13,4 +13,5 @@ obj-$(CONFIG_VITESSE_PHY)	+=3D vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+=3D broadcom.o
 obj-$(CONFIG_ICPLUS_PHY)	+=3D icplus.o
 obj-$(CONFIG_FIXED_PHY)		+=3D fixed.o
+obj-$(CONFIG_HIRSCHMANNRS422_PHY) +=3D hirschmann-rs422.o
 obj-$(CONFIG_MDIO_BITBANG)	+=3D mdio-bitbang.o
diff --git a/drivers/net/phy/hirschmann-rs422.c b/drivers/net/phy/hirsc=
hmann-rs422.c
new file mode 100644
index 0000000..f9bc326
--- /dev/null
+++ b/drivers/net/phy/hirschmann-rs422.c
@@ -0,0 +1,55 @@
+/*
+ * drivers/net/phy/hirschmann-rs422.c
+ *
+ * Copyright (C) 2007 by Digi International Inc.
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License version 2 as publ=
ished by
+ * the Free Software Foundation.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/phy.h>
+
+int hirschmannrs422_config_aneg(struct phy_device *phydev)
+{
+	/* XXX */
+	dev_warn(&phydev->dev, "I cannot autonegotiate (called from %p)\n",
+			__builtin_return_address(0));
+
+	dev_warn(&phydev->dev, "speed =3D %d, duplex =3D %d\n",
+			phydev->speed, phydev->duplex);
+	/* XXX: should better return -Esomething? */
+	return genphy_config_aneg(phydev);
+}
+
+static struct phy_driver hirschmannrs422_driver =3D {
+	.phy_id		=3D 0x00071810,
+	.name		=3D "Hirschmann_rs422",
+	.phy_id_mask	=3D 0xfffffff0,
+	/* XXX: SUPPORTED_TP? */
+	.features	=3D SUPPORTED_10baseT_Half | SUPPORTED_MII,
+	.read_status	=3D genphy_read_status,
+	.config_aneg	=3D hirschmannrs422_config_aneg,
+	.driver 	=3D { .owner =3D THIS_MODULE,},
+};
+
+static int __init hirschmannrs422_init(void)
+{
+	return phy_driver_register(&hirschmannrs422_driver);
+}
+
+static void __exit hirschmannrs422_exit(void)
+{
+	phy_driver_unregister(&hirschmannrs422_driver);
+}
+
+module_init(hirschmannrs422_init);
+module_exit(hirschmannrs422_exit);
+
+MODULE_AUTHOR("Uwe Kleine-Koenig");
+MODULE_DESCRIPTION("Hirschmann RS422 PHY driver");
+MODULE_LICENSE("GPL");
+
--=20
1.5.3.6


--=20
Uwe Kleine-K=F6nig, Software Engineer
Digi International GmbH Branch Breisach, K=FCferstrasse 8, 79206 Breisa=
ch, Germany
Tax: 315/5781/0242 / VAT: DE153662976 / Reg. Amtsgericht Dortmund HRB 1=
3962
