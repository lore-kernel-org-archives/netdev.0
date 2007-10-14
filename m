From: Domen Puncer <domen.puncer@telargo.com>
Subject: [PATCH v3 4/4] FEC mpc52xx: phy part of the driver
Date: Sun, 14 Oct 2007 09:59:58 +0200
Message-ID: <20071014075958.GG3000@nd47.coderock.org>
References: <20071014075511.GC3000@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: galak@kernel.crashing.org, jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20071014075511.GC3000@nd47.coderock.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

PHY part of the driver for mpc5200(b) ethernet.


Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

---
 drivers/net/fec_mpc52xx/Kconfig   |   13 ++
 drivers/net/fec_mpc52xx/Makefile  |    5 
 drivers/net/fec_mpc52xx/fec.c     |   11 ++
 drivers/net/fec_mpc52xx/fec.h     |    2 
 drivers/net/fec_mpc52xx/fec_phy.c |  198 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 229 insertions(+)

Index: linux.git/drivers/net/fec_mpc52xx/fec_phy.c
===================================================================
--- /dev/null
+++ linux.git/drivers/net/fec_mpc52xx/fec_phy.c
@@ -0,0 +1,198 @@
+/*
+ * Driver for the MPC5200 Fast Ethernet Controller - PHY/MII part
+ *
+ * Copyright (C) 2007  Domen Puncer, Telargo, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/of_platform.h>
+#include <asm/io.h>
+#include <asm/mpc52xx.h>
+#include "fec.h"
+
+struct fec_mdio_priv {
+	struct mpc52xx_fec __iomem *regs;
+};
+
+static int fec_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	struct fec_mdio_priv *priv = bus->priv;
+	struct mpc52xx_fec __iomem *fec;
+	int tries = 100;
+	u32 request = FEC_MII_READ_FRAME;
+
+	fec = priv->regs;
+	out_be32(&fec->ievent, FEC_IEVENT_MII);
+
+	request |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
+	request |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
+
+	out_be32(&priv->regs->mii_data, request);
+
+	/* wait for it to finish, this takes about 23 us on lite5200b */
+	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
+		udelay(5);
+
+	if (tries == 0)
+		return -ETIMEDOUT;
+
+	return in_be32(&priv->regs->mii_data) & FEC_MII_DATA_DATAMSK;
+}
+
+static int fec_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 data)
+{
+	struct fec_mdio_priv *priv = bus->priv;
+	struct mpc52xx_fec __iomem *fec;
+	u32 value = data;
+	int tries = 100;
+
+	fec = priv->regs;
+	out_be32(&fec->ievent, FEC_IEVENT_MII);
+
+	value |= FEC_MII_WRITE_FRAME;
+	value |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
+	value |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
+
+	out_be32(&priv->regs->mii_data, value);
+
+	/* wait for request to finish */
+	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
+		udelay(5);
+
+	if (tries == 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int fec_mdio_probe(struct of_device *of, const struct of_device_id *match)
+{
+	struct device *dev = &of->dev;
+	struct device_node *np = of->node;
+	struct device_node *child = NULL;
+	struct mii_bus *bus;
+	struct fec_mdio_priv *priv;
+	struct resource res = {};
+	int err;
+	int i;
+
+	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
+	if (bus == NULL)
+		return -ENOMEM;
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (priv == NULL) {
+		err = -ENOMEM;
+		goto out_free;
+	}
+
+	bus->name = "mpc52xx MII bus";
+	bus->read = fec_mdio_read;
+	bus->write = fec_mdio_write;
+
+	/* setup irqs */
+	bus->irq = kmalloc(sizeof(bus->irq[0]) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (bus->irq == NULL) {
+		err = -ENOMEM;
+		goto out_free;
+	}
+	for (i=0; i<PHY_MAX_ADDR; i++)
+		bus->irq[i] = PHY_POLL;
+
+	while ((child = of_get_next_child(np, child)) != NULL) {
+		int irq = irq_of_parse_and_map(child, 0);
+		if (irq != NO_IRQ) {
+			const u32 *id = of_get_property(child, "reg", NULL);
+			bus->irq[*id] = irq;
+		}
+	}
+
+	/* setup registers */
+	err = of_address_to_resource(np, 0, &res);
+	if (err)
+		goto out_free;
+	priv->regs = ioremap(res.start, res.end - res.start + 1);
+	if (priv->regs == NULL) {
+		err = -ENOMEM;
+		goto out_free;
+	}
+
+	bus->id = res.start;
+	bus->priv = priv;
+
+	bus->dev = dev;
+	dev_set_drvdata(dev, bus);
+
+	/* set MII speed */
+	out_be32(&priv->regs->mii_speed, ((mpc52xx_find_ipb_freq(of->node) >> 20) / 5) << 1);
+
+	/* enable MII interrupt */
+	out_be32(&priv->regs->imask, in_be32(&priv->regs->imask) | FEC_IMASK_MII);
+
+	err = mdiobus_register(bus);
+	if (err)
+		goto out_unmap;
+
+	return 0;
+
+ out_unmap:
+	iounmap(priv->regs);
+ out_free:
+	for (i=0; i<PHY_MAX_ADDR; i++)
+		if (bus->irq[i] != PHY_POLL)
+			irq_dispose_mapping(bus->irq[i]);
+	kfree(bus->irq);
+	kfree(priv);
+	kfree(bus);
+
+	return err;
+}
+
+static int fec_mdio_remove(struct of_device *of)
+{
+	struct device *dev = &of->dev;
+	struct mii_bus *bus = dev_get_drvdata(dev);
+	struct fec_mdio_priv *priv = bus->priv;
+	int i;
+
+	mdiobus_unregister(bus);
+	dev_set_drvdata(dev, NULL);
+
+	iounmap(priv->regs);
+	for (i=0; i<PHY_MAX_ADDR; i++)
+		if (bus->irq[i])
+			irq_dispose_mapping(bus->irq[i]);
+	kfree(priv);
+	kfree(bus->irq);
+	kfree(bus);
+
+	return 0;
+}
+
+
+static struct of_device_id fec_mdio_match[] = {
+	{
+		.type = "mdio",
+		.compatible = "mpc5200b-fec-phy",
+	},
+	{},
+};
+
+struct of_platform_driver mpc52xx_fec_mdio_driver = {
+	.name = "mpc5200b-fec-phy",
+	.probe = fec_mdio_probe,
+	.remove = fec_mdio_remove,
+	.match_table = fec_mdio_match,
+};
+
+/* let fec driver call it, since this has to be registered before it */
+EXPORT_SYMBOL_GPL(mpc52xx_fec_mdio_driver);
+
+
+MODULE_LICENSE("Dual BSD/GPL");
Index: linux.git/drivers/net/fec_mpc52xx/Makefile
===================================================================
--- linux.git.orig/drivers/net/fec_mpc52xx/Makefile
+++ linux.git/drivers/net/fec_mpc52xx/Makefile
@@ -1,2 +1,7 @@
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 fec_mpc52xx-objs := fec.o
+
+ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
+	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
+	fec_mpc52xx_phy-objs := fec_phy.o
+endif
Index: linux.git/drivers/net/fec_mpc52xx/Kconfig
===================================================================
--- linux.git.orig/drivers/net/fec_mpc52xx/Kconfig
+++ linux.git/drivers/net/fec_mpc52xx/Kconfig
@@ -11,5 +11,18 @@ config FEC_MPC52xx
 	---help---
 	  This option enables support for the MPC5200's on-chip
 	  Fast Ethernet Controller
+	  If compiled as module, it will be called 'fec_mpc52xx.ko'.
+
+config FEC_MPC52xx_MDIO
+	bool "FEC MII PHY driver"
+	depends on FEC_MPC52xx
+	default y
+	---help---
+	  The MPC5200's FEC can connect to the Ethernet either with
+	  an external MII PHY chip or 10 Mbps 7-wire interface
+	  (Motorola? industry standard).
+	  If your board uses an external PHY, enable this.
+	  If not sure, enable.
+	  If compiled as module, it will be called 'fec_mpc52xx_phy.ko'.
 
 endmenu
Index: linux.git/drivers/net/fec_mpc52xx/fec.c
===================================================================
--- linux.git.orig/drivers/net/fec_mpc52xx/fec.c
+++ linux.git/drivers/net/fec_mpc52xx/fec.c
@@ -1080,6 +1080,14 @@ static struct of_platform_driver mpc52xx
 static int __init
 mpc52xx_fec_init(void)
 {
+#ifdef CONFIG_FEC_MPC52xx_MDIO
+	int ret;
+	ret = of_register_platform_driver(&mpc52xx_fec_mdio_driver);
+	if (ret) {
+		printk(KERN_ERR DRIVER_NAME ": failed to register mdio driver\n");
+		return ret;
+	}
+#endif
 	return of_register_platform_driver(&mpc52xx_fec_driver);
 }
 
@@ -1087,6 +1095,9 @@ static void __exit
 mpc52xx_fec_exit(void)
 {
 	of_unregister_platform_driver(&mpc52xx_fec_driver);
+#ifdef CONFIG_FEC_MPC52xx_MDIO
+	of_unregister_platform_driver(&mpc52xx_fec_mdio_driver);
+#endif
 }
 
 
Index: linux.git/drivers/net/fec_mpc52xx/fec.h
===================================================================
--- linux.git.orig/drivers/net/fec_mpc52xx/fec.h
+++ linux.git/drivers/net/fec_mpc52xx/fec.h
@@ -310,4 +310,6 @@ struct mpc52xx_fec {
 #define FEC_XMIT_FSM_ENABLE_CRC		0x01000000
 
 
+extern struct of_platform_driver mpc52xx_fec_mdio_driver;
+
 #endif	/* __DRIVERS_NET_MPC52XX_FEC_H__ */
