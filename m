From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [PATCH 1/2] net: OpenFirmware GPIO based MDIO bitbang driver
Date: Mon, 26 May 2008 11:53:21 +0200
Message-ID: <200805261153.21932.laurentp@cse-semaphore.com>
References: <200805261152.37636.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6929385.JIj3WsFO6t";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Scott Wood <scottwood@freescale.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:49467 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751218AbYEZJy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 05:54:29 -0400
In-Reply-To: <200805261152.37636.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart6929385.JIj3WsFO6t
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

This patch adds an MDIO bitbang driver that uses the GPIO library and its
OF bindings to access the bus I/Os.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
=2D--
 Documentation/powerpc/booting-without-of.txt |   21 +++
 drivers/net/phy/Kconfig                      |    6 +
 drivers/net/phy/Makefile                     |    1 +
 drivers/net/phy/mdio-ofgpio.c                |  205 ++++++++++++++++++++++=
++++
 4 files changed, 233 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/mdio-ofgpio.c

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/p=
owerpc/booting-without-of.txt
index 21a3484..6f8c9d4 100644
=2D-- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -58,6 +58,7 @@ Table of Contents
       o) Xilinx IP cores
       p) Freescale Synchronous Serial Interface
 	  q) USB EHCI controllers
+      r) MDIO on GPIOs
=20
   VII - Marvell Discovery mv64[345]6x System Controller chips
     1) The /system-controller node
@@ -2880,6 +2881,26 @@ platforms are moved over to use the flattened-device=
=2Dtree model.
 		reg =3D <0xe8000000 32>;
 	};
=20
+   r) MDIO on GPIOs
+
+   Currently defined compatibles:
+   - virtual,gpio-mdio
+
+   MDC and MDIO lines connected to GPIO controllers are listed in the
+   gpios property as described in section VIII.1 in the following order:
+
+   MDC, MDIO.
+
+   Example:
+
+	mdio {
+		compatible =3D "virtual,mdio-gpio";
+		#address-cells =3D <1>;
+		#size-cells =3D <0>;
+		gpios =3D <&qe_pio_a 11
+			 &qe_pio_c 6>;
+	};
+
 VII - Marvell Discovery mv64[345]6x System Controller chips
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6bf9e76..ad7a138 100644
=2D-- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -83,4 +83,10 @@ config MDIO_BITBANG
=20
 	  If in doubt, say N.
=20
+config MDIO_OF_GPIO
+	tristate "Support for GPIO lib-based bitbanged MDIO buses"
+	depends on MDIO_BITBANG && OF_GPIO
+	---help---
+	  Supports GPIO lib-based MDIO busses.
+
 endif # PHYLIB
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 5997d6e..eee329f 100644
=2D-- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -15,3 +15,4 @@ obj-$(CONFIG_ICPLUS_PHY)	+=3D icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+=3D realtek.o
 obj-$(CONFIG_FIXED_PHY)		+=3D fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+=3D mdio-bitbang.o
+obj-$(CONFIG_MDIO_OF_GPIO)	+=3D mdio-ofgpio.o
diff --git a/drivers/net/phy/mdio-ofgpio.c b/drivers/net/phy/mdio-ofgpio.c
new file mode 100644
index 0000000..7edfc0c
=2D-- /dev/null
+++ b/drivers/net/phy/mdio-ofgpio.c
@@ -0,0 +1,205 @@
+/*
+ * OpenFirmware GPIO based MDIO bitbang driver.
+ *
+ * Copyright (c) 2008 CSE Semaphore Belgium.
+ *  by Laurent Pinchart <laurentp@cse-semaphore.com>
+ *
+ * Based on earlier work by
+ *
+ * Copyright (c) 2003 Intracom S.A.
+ *  by Pantelis Antoniou <panto@intracom.gr>
+ *
+ * 2005 (c) MontaVista Software, Inc.
+ * Vitaly Bordug <vbordug@ru.mvista.com>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/mdio-bitbang.h>
+#include <linux/of_gpio.h>
+#include <linux/of_platform.h>
+
+struct mdio_gpio_info {
+	struct mdiobb_ctrl ctrl;
+	int mdc, mdio;
+};
+
+static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
+{
+	struct mdio_gpio_info *bitbang =3D
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	if (dir)
+		gpio_direction_output(bitbang->mdio, 1);
+	else
+		gpio_direction_input(bitbang->mdio);
+}
+
+static int mdio_read(struct mdiobb_ctrl *ctrl)
+{
+	struct mdio_gpio_info *bitbang =3D
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	return gpio_get_value(bitbang->mdio);
+}
+
+static void mdio(struct mdiobb_ctrl *ctrl, int what)
+{
+	struct mdio_gpio_info *bitbang =3D
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	gpio_set_value(bitbang->mdio, what);
+}
+
+static void mdc(struct mdiobb_ctrl *ctrl, int what)
+{
+	struct mdio_gpio_info *bitbang =3D
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	gpio_set_value(bitbang->mdc, what);
+}
+
+static struct mdiobb_ops mdio_gpio_ops =3D {
+	.owner =3D THIS_MODULE,
+	.set_mdc =3D mdc,
+	.set_mdio_dir =3D mdio_dir,
+	.set_mdio_data =3D mdio,
+	.get_mdio_data =3D mdio_read,
+};
+
+static int __devinit mdio_ofgpio_bitbang_init(struct mii_bus *bus,
+                                         struct device_node *np)
+{
+	struct mdio_gpio_info *bitbang =3D bus->priv;
+
+	bitbang->mdc =3D of_get_gpio(np, 0);
+	bitbang->mdio =3D of_get_gpio(np, 1);
+
+	if (bitbang->mdc < 0 || bitbang->mdio < 0)
+		return -ENODEV;
+
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);
+	return 0;
+}
+
+static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
+{
+	const u32 *data;
+	int len, id, irq;
+
+	data =3D of_get_property(np, "reg", &len);
+	if (!data || len !=3D 4)
+		return;
+
+	id =3D *data;
+	bus->phy_mask &=3D ~(1 << id);
+
+	irq =3D of_irq_to_resource(np, 0, NULL);
+	if (irq !=3D NO_IRQ)
+		bus->irq[id] =3D irq;
+}
+
+static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
+                                        const struct of_device_id *match)
+{
+	struct device_node *np =3D NULL;
+	struct mii_bus *new_bus;
+	struct mdio_gpio_info *bitbang;
+	int ret =3D -ENOMEM;
+	int i;
+
+	bitbang =3D kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
+	if (!bitbang)
+		goto out;
+
+	bitbang->ctrl.ops =3D &mdio_gpio_ops;
+
+	new_bus =3D alloc_mdio_bitbang(&bitbang->ctrl);
+	if (!new_bus)
+		goto out_free_priv;
+
+	new_bus->name =3D "GPIO Bitbanged MII",
+
+	ret =3D mdio_ofgpio_bitbang_init(new_bus, ofdev->node);
+	if (ret)
+		goto out_free_bus;
+
+	new_bus->phy_mask =3D ~0;
+	new_bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!new_bus->irq)
+		goto out_free_bus;
+
+	for (i =3D 0; i < PHY_MAX_ADDR; i++)
+		new_bus->irq[i] =3D -1;
+
+	while ((np =3D of_get_next_child(ofdev->node, np)))
+		if (!strcmp(np->type, "ethernet-phy"))
+			add_phy(new_bus, np);
+
+	new_bus->dev =3D &ofdev->dev;
+	dev_set_drvdata(&ofdev->dev, new_bus);
+
+	ret =3D mdiobus_register(new_bus);
+	if (ret)
+		goto out_free_irqs;
+
+	return 0;
+
+out_free_irqs:
+	dev_set_drvdata(&ofdev->dev, NULL);
+	kfree(new_bus->irq);
+out_free_bus:
+	kfree(new_bus);
+out_free_priv:
+	free_mdio_bitbang(new_bus);
+out:
+	return ret;
+}
+
+static int mdio_ofgpio_remove(struct of_device *ofdev)
+{
+	struct mii_bus *bus =3D dev_get_drvdata(&ofdev->dev);
+	struct mdio_gpio_info *bitbang =3D bus->priv;
+
+	mdiobus_unregister(bus);
+	free_mdio_bitbang(bus);
+	dev_set_drvdata(&ofdev->dev, NULL);
+	kfree(bus->irq);
+	kfree(bitbang);
+	kfree(bus);
+
+	return 0;
+}
+
+static struct of_device_id mdio_ofgpio_match[] =3D {
+	{
+		.compatible =3D "virtual,mdio-gpio",
+	},
+	{},
+};
+
+static struct of_platform_driver mdio_ofgpio_driver =3D {
+	.name =3D "mdio-gpio",
+	.match_table =3D mdio_ofgpio_match,
+	.probe =3D mdio_ofgpio_probe,
+	.remove =3D mdio_ofgpio_remove,
+};
+
+static int mdio_ofgpio_init(void)
+{
+	return of_register_platform_driver(&mdio_ofgpio_driver);
+}
+
+static void mdio_ofgpio_exit(void)
+{
+	of_unregister_platform_driver(&mdio_ofgpio_driver);
+}
+
+module_init(mdio_ofgpio_init);
+module_exit(mdio_ofgpio_exit);
=2D-=20
1.5.0


=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart6929385.JIj3WsFO6t
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIOoiR8y9gWxC9vpcRAo0dAJ4rMoF4Sn6wIL2vsNA/OfBJw0ncSgCgnWCL
K3D2/Y/EMzutY3un0xwP6Lg=
=KNR8
-----END PGP SIGNATURE-----

--nextPart6929385.JIj3WsFO6t--
