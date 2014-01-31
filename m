From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: [PATCH v2 4/6] can: sja1000: fuse of_platform into platform
Date: Fri, 31 Jan 2014 11:35:11 +0100
Message-ID: <1391164513-11529-5-git-send-email-florian.vaussard@epfl.ch>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, florian.vaussard@epfl.ch
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The OpenFirmware probe can be merged into the standard platform
probe to leverage common code.

Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
---
 drivers/net/can/sja1000/Kconfig               |  13 +-
 drivers/net/can/sja1000/Makefile              |   1 -
 drivers/net/can/sja1000/sja1000_of_platform.c | 218 --------------------------
 drivers/net/can/sja1000/sja1000_platform.c    | 141 +++++++++++++----
 4 files changed, 116 insertions(+), 257 deletions(-)
 delete mode 100644 drivers/net/can/sja1000/sja1000_of_platform.c

diff --git a/drivers/net/can/sja1000/Kconfig b/drivers/net/can/sja1000/Kconfig
index ff2ba86..4b18b87 100644
--- a/drivers/net/can/sja1000/Kconfig
+++ b/drivers/net/can/sja1000/Kconfig
@@ -17,16 +17,9 @@ config CAN_SJA1000_PLATFORM
 	  the "platform bus" (Linux abstraction for directly to the
 	  processor attached devices).  Which can be found on various
 	  boards from Phytec (http://www.phytec.de) like the PCM027,
-	  PCM038.
-
-config CAN_SJA1000_OF_PLATFORM
-	tristate "Generic OF Platform Bus based SJA1000 driver"
-	depends on OF
-	---help---
-	  This driver adds support for the SJA1000 chips connected to
-	  the OpenFirmware "platform bus" found on embedded systems with
-	  OpenFirmware bindings, e.g. if you have a PowerPC based system
-	  you may want to enable this option.
+	  PCM038. It also provides the OpenFirmware "platform bus" found
+	  on embedded systems with OpenFirmware bindings, e.g. if you
+	  have a PowerPC based system you may want to enable this option.
 
 config CAN_EMS_PCMCIA
 	tristate "EMS CPC-CARD Card"
diff --git a/drivers/net/can/sja1000/Makefile b/drivers/net/can/sja1000/Makefile
index b3d05cb..531d5fc 100644
--- a/drivers/net/can/sja1000/Makefile
+++ b/drivers/net/can/sja1000/Makefile
@@ -5,7 +5,6 @@
 obj-$(CONFIG_CAN_SJA1000) += sja1000.o
 obj-$(CONFIG_CAN_SJA1000_ISA) += sja1000_isa.o
 obj-$(CONFIG_CAN_SJA1000_PLATFORM) += sja1000_platform.o
-obj-$(CONFIG_CAN_SJA1000_OF_PLATFORM) += sja1000_of_platform.o
 obj-$(CONFIG_CAN_EMS_PCMCIA) += ems_pcmcia.o
 obj-$(CONFIG_CAN_EMS_PCI) += ems_pci.o
 obj-$(CONFIG_CAN_KVASER_PCI) += kvaser_pci.o
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
deleted file mode 100644
index 2f29eb9..0000000
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ /dev/null
@@ -1,218 +0,0 @@
-/*
- * Driver for SJA1000 CAN controllers on the OpenFirmware platform bus
- *
- * Copyright (C) 2008-2009 Wolfgang Grandegger <wg@grandegger.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the version 2 of the GNU General Public License
- * as published by the Free Software Foundation
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
- */
-
-/* This is a generic driver for SJA1000 chips on the OpenFirmware platform
- * bus found on embedded PowerPC systems. You need a SJA1000 CAN node
- * definition in your flattened device tree source (DTS) file similar to:
- *
- *   can@3,100 {
- *           compatible = "nxp,sja1000";
- *           reg = <3 0x100 0x80>;
- *           interrupts = <2 0>;
- *           interrupt-parent = <&mpic>;
- *           nxp,external-clock-frequency = <16000000>;
- *   };
- *
- * See "Documentation/devicetree/bindings/net/can/sja1000.txt" for further
- * information.
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
-#include <linux/delay.h>
-#include <linux/io.h>
-#include <linux/can/dev.h>
-
-#include <linux/of_platform.h>
-#include <linux/of_address.h>
-#include <linux/of_irq.h>
-
-#include "sja1000.h"
-
-#define DRV_NAME "sja1000_of_platform"
-
-MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
-MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the OF platform bus");
-MODULE_LICENSE("GPL v2");
-
-#define SJA1000_OFP_CAN_CLOCK  (16000000 / 2)
-
-static u8 sja1000_ofp_read_reg(const struct sja1000_priv *priv, int reg)
-{
-	return ioread8(priv->reg_base + reg);
-}
-
-static void sja1000_ofp_write_reg(const struct sja1000_priv *priv,
-				  int reg, u8 val)
-{
-	iowrite8(val, priv->reg_base + reg);
-}
-
-static int sja1000_ofp_remove(struct platform_device *ofdev)
-{
-	struct net_device *dev = platform_get_drvdata(ofdev);
-	struct sja1000_priv *priv = netdev_priv(dev);
-	struct device_node *np = ofdev->dev.of_node;
-	struct resource res;
-
-	unregister_sja1000dev(dev);
-	free_sja1000dev(dev);
-	iounmap(priv->reg_base);
-	irq_dispose_mapping(dev->irq);
-
-	of_address_to_resource(np, 0, &res);
-	release_mem_region(res.start, resource_size(&res));
-
-	return 0;
-}
-
-static int sja1000_ofp_probe(struct platform_device *ofdev)
-{
-	struct device_node *np = ofdev->dev.of_node;
-	struct net_device *dev;
-	struct sja1000_priv *priv;
-	struct resource res;
-	u32 prop;
-	int err, irq, res_size;
-	void __iomem *base;
-
-	err = of_address_to_resource(np, 0, &res);
-	if (err) {
-		dev_err(&ofdev->dev, "invalid address\n");
-		return err;
-	}
-
-	res_size = resource_size(&res);
-
-	if (!request_mem_region(res.start, res_size, DRV_NAME)) {
-		dev_err(&ofdev->dev, "couldn't request %pR\n", &res);
-		return -EBUSY;
-	}
-
-	base = ioremap_nocache(res.start, res_size);
-	if (!base) {
-		dev_err(&ofdev->dev, "couldn't ioremap %pR\n", &res);
-		err = -ENOMEM;
-		goto exit_release_mem;
-	}
-
-	irq = irq_of_parse_and_map(np, 0);
-	if (irq == 0) {
-		dev_err(&ofdev->dev, "no irq found\n");
-		err = -ENODEV;
-		goto exit_unmap_mem;
-	}
-
-	dev = alloc_sja1000dev(0);
-	if (!dev) {
-		err = -ENOMEM;
-		goto exit_dispose_irq;
-	}
-
-	priv = netdev_priv(dev);
-
-	priv->read_reg = sja1000_ofp_read_reg;
-	priv->write_reg = sja1000_ofp_write_reg;
-
-	err = of_property_read_u32(np, "nxp,external-clock-frequency", &prop);
-	if (!err)
-		priv->can.clock.freq = prop / 2;
-	else
-		priv->can.clock.freq = SJA1000_OFP_CAN_CLOCK; /* default */
-
-	err = of_property_read_u32(np, "nxp,tx-output-mode", &prop);
-	if (!err)
-		priv->ocr |= prop & OCR_MODE_MASK;
-	else
-		priv->ocr |= OCR_MODE_NORMAL; /* default */
-
-	err = of_property_read_u32(np, "nxp,tx-output-config", &prop);
-	if (!err)
-		priv->ocr |= (prop << OCR_TX_SHIFT) & OCR_TX_MASK;
-	else
-		priv->ocr |= OCR_TX0_PULLDOWN; /* default */
-
-	err = of_property_read_u32(np, "nxp,clock-out-frequency", &prop);
-	if (!err && prop) {
-		u32 divider = priv->can.clock.freq * 2 / prop;
-
-		if (divider > 1)
-			priv->cdr |= divider / 2 - 1;
-		else
-			priv->cdr |= CDR_CLKOUT_MASK;
-	} else {
-		priv->cdr |= CDR_CLK_OFF; /* default */
-	}
-
-	if (!of_property_read_bool(np, "nxp,no-comparator-bypass"))
-		priv->cdr |= CDR_CBP; /* default */
-
-	priv->irq_flags = IRQF_SHARED;
-	priv->reg_base = base;
-
-	dev->irq = irq;
-
-	dev_info(&ofdev->dev,
-		 "reg_base=0x%p irq=%d clock=%d ocr=0x%02x cdr=0x%02x\n",
-		 priv->reg_base, dev->irq, priv->can.clock.freq,
-		 priv->ocr, priv->cdr);
-
-	platform_set_drvdata(ofdev, dev);
-	SET_NETDEV_DEV(dev, &ofdev->dev);
-
-	err = register_sja1000dev(dev);
-	if (err) {
-		dev_err(&ofdev->dev, "registering %s failed (err=%d)\n",
-			DRV_NAME, err);
-		goto exit_free_sja1000;
-	}
-
-	return 0;
-
-exit_free_sja1000:
-	free_sja1000dev(dev);
-exit_dispose_irq:
-	irq_dispose_mapping(irq);
-exit_unmap_mem:
-	iounmap(base);
-exit_release_mem:
-	release_mem_region(res.start, res_size);
-
-	return err;
-}
-
-static struct of_device_id sja1000_ofp_table[] = {
-	{.compatible = "nxp,sja1000"},
-	{},
-};
-MODULE_DEVICE_TABLE(of, sja1000_ofp_table);
-
-static struct platform_driver sja1000_ofp_driver = {
-	.driver = {
-		.owner = THIS_MODULE,
-		.name = DRV_NAME,
-		.of_match_table = sja1000_ofp_table,
-	},
-	.probe = sja1000_ofp_probe,
-	.remove = sja1000_ofp_remove,
-};
-
-module_platform_driver(sja1000_ofp_driver);
diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 779679a..96a92a1 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -27,12 +27,16 @@
 #include <linux/can/dev.h>
 #include <linux/can/platform/sja1000.h>
 #include <linux/io.h>
+#include <linux/of.h>
+#include <linux/of_irq.h>
 
 #include "sja1000.h"
 
 #define DRV_NAME "sja1000_platform"
+#define SJA1000_OFP_CAN_CLOCK  (16000000 / 2)
 
 MODULE_AUTHOR("Sascha Hauer <s.hauer@pengutronix.de>");
+MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
 MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus");
 MODULE_ALIAS("platform:" DRV_NAME);
 MODULE_LICENSE("GPL v2");
@@ -67,24 +71,98 @@ static void sp_write_reg32(const struct sja1000_priv *priv, int reg, u8 val)
 	iowrite8(val, priv->reg_base + reg * 4);
 }
 
-static int sp_probe(struct platform_device *pdev)
+static void sp_populate(struct sja1000_priv *priv,
+			struct sja1000_platform_data *pdata,
+			unsigned long resource_mem_flags)
+{
+	/* The CAN clock frequency is half the oscillator clock frequency */
+	priv->can.clock.freq = pdata->osc_freq / 2;
+	priv->ocr = pdata->ocr;
+	priv->cdr = pdata->cdr;
+
+	switch (resource_mem_flags & IORESOURCE_MEM_TYPE_MASK) {
+	case IORESOURCE_MEM_32BIT:
+		priv->read_reg = sp_read_reg32;
+		priv->write_reg = sp_write_reg32;
+		break;
+	case IORESOURCE_MEM_16BIT:
+		priv->read_reg = sp_read_reg16;
+		priv->write_reg = sp_write_reg16;
+		break;
+	case IORESOURCE_MEM_8BIT:
+	default:
+		priv->read_reg = sp_read_reg8;
+		priv->write_reg = sp_write_reg8;
+		break;
+	}
+}
+
+#if defined(CONFIG_OF)
+static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
 {
 	int err;
+	u32 prop;
+
+	priv->read_reg = sp_read_reg8;
+	priv->write_reg = sp_write_reg8;
+
+	err = of_property_read_u32(of, "nxp,external-clock-frequency", &prop);
+	if (!err)
+		priv->can.clock.freq = prop / 2;
+	else
+		priv->can.clock.freq = SJA1000_OFP_CAN_CLOCK; /* default */
+
+	err = of_property_read_u32(of, "nxp,tx-output-mode", &prop);
+	if (!err)
+		priv->ocr |= prop & OCR_MODE_MASK;
+	else
+		priv->ocr |= OCR_MODE_NORMAL; /* default */
+
+	err = of_property_read_u32(of, "nxp,tx-output-config", &prop);
+	if (!err)
+		priv->ocr |= (prop << OCR_TX_SHIFT) & OCR_TX_MASK;
+	else
+		priv->ocr |= OCR_TX0_PULLDOWN; /* default */
+
+	err = of_property_read_u32(of, "nxp,clock-out-frequency", &prop);
+	if (!err && prop) {
+		u32 divider = priv->can.clock.freq * 2 / prop;
+
+		if (divider > 1)
+			priv->cdr |= divider / 2 - 1;
+		else
+			priv->cdr |= CDR_CLKOUT_MASK;
+	} else {
+		priv->cdr |= CDR_CLK_OFF; /* default */
+	}
+
+	if (!of_property_read_bool(of, "nxp,no-comparator-bypass"))
+		priv->cdr |= CDR_CBP; /* default */
+}
+#else
+static void sp_populate_of(struct sja1000_priv *priv, device_node *of)
+{
+}
+#endif
+
+static int sp_probe(struct platform_device *pdev)
+{
+	int err, irq = 0;
 	void __iomem *addr;
 	struct net_device *dev;
 	struct sja1000_priv *priv;
-	struct resource *res_mem, *res_irq;
+	struct resource *res_mem, *res_irq = 0;
 	struct sja1000_platform_data *pdata;
+	struct device_node *of = pdev->dev.of_node;
 
 	pdata = dev_get_platdata(&pdev->dev);
-	if (!pdata) {
+	if (!pdata && !of) {
 		dev_err(&pdev->dev, "No platform data provided!\n");
 		return -ENODEV;
 	}
 
 	res_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	res_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (!res_mem || !res_irq)
+	if (!res_mem)
 		return -ENODEV;
 
 	if (!devm_request_mem_region(&pdev->dev, res_mem->start,
@@ -96,36 +174,34 @@ static int sp_probe(struct platform_device *pdev)
 	if (!addr)
 		return -ENOMEM;
 
+	if (of)
+		irq = irq_of_parse_and_map(of, 0);
+	else
+		res_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+
+	if (!irq && !res_irq)
+		return -ENODEV;
+
 	dev = alloc_sja1000dev(0);
 	if (!dev)
 		return -ENOMEM;
 	priv = netdev_priv(dev);
 
-	dev->irq = res_irq->start;
-	priv->irq_flags = res_irq->flags & IRQF_TRIGGER_MASK;
-	if (res_irq->flags & IORESOURCE_IRQ_SHAREABLE)
-		priv->irq_flags |= IRQF_SHARED;
+	if (res_irq) {
+		irq = res_irq->start;
+		priv->irq_flags = res_irq->flags & IRQF_TRIGGER_MASK;
+		if (res_irq->flags & IORESOURCE_IRQ_SHAREABLE)
+			priv->irq_flags |= IRQF_SHARED;
+	} else
+		priv->irq_flags = IRQF_SHARED;
+
+	dev->irq = irq;
 	priv->reg_base = addr;
-	/* The CAN clock frequency is half the oscillator clock frequency */
-	priv->can.clock.freq = pdata->osc_freq / 2;
-	priv->ocr = pdata->ocr;
-	priv->cdr = pdata->cdr;
 
-	switch (res_mem->flags & IORESOURCE_MEM_TYPE_MASK) {
-	case IORESOURCE_MEM_32BIT:
-		priv->read_reg = sp_read_reg32;
-		priv->write_reg = sp_write_reg32;
-		break;
-	case IORESOURCE_MEM_16BIT:
-		priv->read_reg = sp_read_reg16;
-		priv->write_reg = sp_write_reg16;
-		break;
-	case IORESOURCE_MEM_8BIT:
-	default:
-		priv->read_reg = sp_read_reg8;
-		priv->write_reg = sp_write_reg8;
-		break;
-	}
+	if (of)
+		sp_populate_of(priv, of);
+	else
+		sp_populate(priv, pdata, res_mem->flags);
 
 	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -156,12 +232,21 @@ static int sp_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#if defined(CONFIG_OF)
+static struct of_device_id sja1000_ofp_table[] = {
+	{.compatible = "nxp,sja1000"},
+	{},
+};
+MODULE_DEVICE_TABLE(of, sja1000_ofp_table);
+#endif
+
 static struct platform_driver sp_driver = {
 	.probe = sp_probe,
 	.remove = sp_remove,
 	.driver = {
 		.name = DRV_NAME,
 		.owner = THIS_MODULE,
+		.of_match_table = of_match_ptr(sja1000_ofp_table),
 	},
 };
 
-- 
1.8.1.2
