From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [net-next-2.6 PATCH 3/3] can: sja1000: generic OF platform bus driver
Date: Sat, 30 May 2009 19:55:50 +0200
Message-ID: <20090530175548.309017071@denx.de>
References: <20090530175547.772116783@denx.de>
Cc: socketcan-core@lists.berlios.de, devicetree-discuss@ozlabs.org,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:37480 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932634AbZE3Rzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 13:55:50 -0400
Content-Disposition: inline; filename=sja1000-of-platform-driver.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a generic driver for SJA1000 chips on the OpenFirmware
platform bus found on embedded PowerPC systems. You need a SJA1000 node
definition in your flattened device tree source (DTS) file similar to:

  can@3,100 {
  	compatible = "nxp,sja1000";
  	reg = <3 0x100 0x80>;
  	interrupts = <2 0>;
  	interrupt-parent = <&mpic>;
  	nxp,external-clock-frequency = <16000000>;
  };

See also Documentation/powerpc/dts-bindings/can/sja1000.txt.

CC: devicetree-discuss@ozlabs.org
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 Documentation/powerpc/dts-bindings/can/sja1000.txt |   53 ++++
 drivers/net/can/Kconfig                            |    9 
 drivers/net/can/sja1000/Makefile                   |    1 
 drivers/net/can/sja1000/sja1000_of_platform.c      |  233 +++++++++++++++++++++
 include/linux/can/platform/sja1000.h               |    3 
 5 files changed, 299 insertions(+)

Index: net-next-2.6/drivers/net/can/Kconfig
===================================================================
--- net-next-2.6.orig/drivers/net/can/Kconfig	2009-05-30 19:48:32.736721524 +0200
+++ net-next-2.6/drivers/net/can/Kconfig	2009-05-30 19:48:40.388719327 +0200
@@ -51,6 +51,15 @@
 	  boards from Phytec (http://www.phytec.de) like the PCM027,
 	  PCM038.
 
+config CAN_SJA1000_OF_PLATFORM
+	depends on CAN_SJA1000 && PPC_OF
+	tristate "Generic OF Platform Bus based SJA1000 driver"
+	---help---
+	  This driver adds support for the SJA1000 chips connected to
+	  the OpenFirmware "platform bus" found on embedded systems with
+	  OpenFirmware bindings, e.g. if you have a PowerPC based system
+	  you may want to enable this option.
+
 config CAN_EMS_PCI
 	tristate "EMS CPC-PCI and CPC-PCIe Card"
 	depends on PCI && CAN_SJA1000
Index: net-next-2.6/drivers/net/can/sja1000/Makefile
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/Makefile	2009-05-30 19:48:32.737720828 +0200
+++ net-next-2.6/drivers/net/can/sja1000/Makefile	2009-05-30 19:48:40.389719190 +0200
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_CAN_SJA1000) += sja1000.o
 obj-$(CONFIG_CAN_SJA1000_PLATFORM) += sja1000_platform.o
+obj-$(CONFIG_CAN_SJA1000_OF_PLATFORM) += sja1000_of_platform.o
 obj-$(CONFIG_CAN_EMS_PCI) += ems_pci.o
 obj-$(CONFIG_CAN_KVASER_PCI) += kvaser_pci.o
 
Index: net-next-2.6/drivers/net/can/sja1000/sja1000_of_platform.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-next-2.6/drivers/net/can/sja1000/sja1000_of_platform.c	2009-05-30 19:48:40.397718650 +0200
@@ -0,0 +1,233 @@
+/*
+ * Driver for SJA1000 CAN controllers on the OpenFirmware platform bus
+ *
+ * Copyright (C) 2008-2009 Wolfgang Grandegger <wg@grandegger.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the version 2 of the GNU General Public License
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/* This is a generic driver for SJA1000 chips on the OpenFirmware platform
+ * bus found on embedded PowerPC systems. You need a SJA1000 CAN node
+ * definition in your flattened device tree source (DTS) file similar to:
+ *
+ *   can@3,100 {
+ *           compatible = "nxp,sja1000";
+ *           reg = <3 0x100 0x80>;
+ *           interrupts = <2 0>;
+ *           interrupt-parent = <&mpic>;
+ *           nxp,external-clock-frequency = <16000000>;
+ *   };
+ *
+ * See "Documentation/powerpc/dts-bindings/can/sja1000.txt" for further
+ * information.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/delay.h>
+#include <linux/can.h>
+#include <linux/can/dev.h>
+
+#include <linux/of_platform.h>
+#include <asm/prom.h>
+
+#include "sja1000.h"
+
+#define DRV_NAME "sja1000_of_platform"
+
+MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
+MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the OF platform bus");
+MODULE_LICENSE("GPL v2");
+
+#define SJA1000_OFP_CAN_CLOCK  (16000000 / 2)
+
+#define SJA1000_OFP_OCR        OCR_TX0_PULLDOWN
+#define SJA1000_OFP_CDR        (CDR_CBP | CDR_CLK_OFF)
+
+static u8 sja1000_ofp_read_reg(const struct sja1000_priv *priv, int reg)
+{
+	return in_8(priv->reg_base + reg);
+}
+
+static void sja1000_ofp_write_reg(const struct sja1000_priv *priv,
+				  int reg, u8 val)
+{
+	out_8(priv->reg_base + reg, val);
+}
+
+static int __devexit sja1000_ofp_remove(struct of_device *ofdev)
+{
+	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct sja1000_priv *priv = netdev_priv(dev);
+	struct device_node *np = ofdev->node;
+	struct resource res;
+
+	dev_set_drvdata(&ofdev->dev, NULL);
+
+	unregister_sja1000dev(dev);
+	free_sja1000dev(dev);
+	iounmap(priv->reg_base);
+	irq_dispose_mapping(dev->irq);
+
+	of_address_to_resource(np, 0, &res);
+	release_mem_region(res.start, resource_size(&res));
+
+	return 0;
+}
+
+static int __devinit sja1000_ofp_probe(struct of_device *ofdev,
+				       const struct of_device_id *id)
+{
+	struct device_node *np = ofdev->node;
+	struct net_device *dev;
+	struct sja1000_priv *priv;
+	struct resource res;
+	const u32 *prop;
+	int err, irq, res_size, prop_size;
+	void __iomem *base;
+
+	err = of_address_to_resource(np, 0, &res);
+	if (err) {
+		dev_err(&ofdev->dev, "invalid address\n");
+		return err;
+	}
+
+	res_size = resource_size(&res);
+
+	if (!request_mem_region(res.start, res_size, DRV_NAME)) {
+		dev_err(&ofdev->dev, "couldn't request %#x..%#x\n",
+			res.start, res.end);
+		return -EBUSY;
+	}
+
+	base = ioremap_nocache(res.start, res_size);
+	if (!base) {
+		dev_err(&ofdev->dev, "couldn't ioremap %#x..%#x\n",
+			res.start, res.end);
+		err = -ENOMEM;
+		goto exit_release_mem;
+	}
+
+	irq = irq_of_parse_and_map(np, 0);
+	if (irq == NO_IRQ) {
+		dev_err(&ofdev->dev, "no irq found\n");
+		err = -ENODEV;
+		goto exit_unmap_mem;
+	}
+
+	dev = alloc_sja1000dev(0);
+	if (!dev) {
+		err = -ENOMEM;
+		goto exit_dispose_irq;
+	}
+
+	priv = netdev_priv(dev);
+
+	priv->read_reg = sja1000_ofp_read_reg;
+	priv->write_reg = sja1000_ofp_write_reg;
+
+	prop = of_get_property(np, "nxp,external-clock-frequency", &prop_size);
+	if (prop && (prop_size ==  sizeof(u32)))
+		priv->can.clock.freq = *prop / 2;
+	else
+		priv->can.clock.freq = SJA1000_OFP_CAN_CLOCK; /* default */
+
+	prop = of_get_property(np, "nxp,tx-output-mode", &prop_size);
+	if (prop && (prop_size == sizeof(u32)))
+		priv->ocr |= *prop & OCR_MODE_MASK;
+	else
+		priv->ocr |= OCR_MODE_NORMAL; /* default */
+
+	prop = of_get_property(np, "nxp,tx-output-config", &prop_size);
+	if (prop && (prop_size == sizeof(u32)))
+		priv->ocr |= (*prop << OCR_TX_SHIFT) & OCR_TX_MASK;
+	else
+		priv->ocr |= OCR_TX0_PULLDOWN; /* default */
+
+	prop = of_get_property(np, "nxp,clock-out-frequency", &prop_size);
+	if (prop && (prop_size == sizeof(u32)) && *prop) {
+		u32 divider = priv->can.clock.freq * 2 / *prop;
+
+		if (divider > 1)
+			priv->cdr |= divider / 2 - 1;
+		else
+			priv->cdr |= CDR_CLKOUT_MASK;
+	} else {
+		priv->cdr |= CDR_CLK_OFF; /* default */
+	}
+
+	prop = of_get_property(np, "nxp,no-comparator-bypass", NULL);
+	if (!prop)
+		priv->cdr |= CDR_CBP; /* default */
+
+	priv->irq_flags = IRQF_SHARED;
+	priv->reg_base = base;
+
+	dev->irq = irq;
+
+	dev_info(&ofdev->dev,
+		 "reg_base=0x%p irq=%d clock=%d ocr=0x%02x cdr=0x%02x\n",
+		 priv->reg_base, dev->irq, priv->can.clock.freq,
+		 priv->ocr, priv->cdr);
+
+	dev_set_drvdata(&ofdev->dev, dev);
+	SET_NETDEV_DEV(dev, &ofdev->dev);
+
+	err = register_sja1000dev(dev);
+	if (err) {
+		dev_err(&ofdev->dev, "registering %s failed (err=%d)\n",
+			DRV_NAME, err);
+		goto exit_free_sja1000;
+	}
+
+	return 0;
+
+exit_free_sja1000:
+	free_sja1000dev(dev);
+exit_dispose_irq:
+	irq_dispose_mapping(irq);
+exit_unmap_mem:
+	iounmap(base);
+exit_release_mem:
+	release_mem_region(res.start, res_size);
+
+	return err;
+}
+
+static struct of_device_id __devinitdata sja1000_ofp_table[] = {
+	{.compatible = "nxp,sja1000"},
+	{},
+};
+
+static struct of_platform_driver sja1000_ofp_driver = {
+	.owner = THIS_MODULE,
+	.name = DRV_NAME,
+	.probe = sja1000_ofp_probe,
+	.remove = __devexit_p(sja1000_ofp_remove),
+	.match_table = sja1000_ofp_table,
+};
+
+static int __init sja1000_ofp_init(void)
+{
+	return of_register_platform_driver(&sja1000_ofp_driver);
+}
+module_init(sja1000_ofp_init);
+
+static void __exit sja1000_ofp_exit(void)
+{
+	return of_unregister_platform_driver(&sja1000_ofp_driver);
+};
+module_exit(sja1000_ofp_exit);
Index: net-next-2.6/Documentation/powerpc/dts-bindings/can/sja1000.txt
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-next-2.6/Documentation/powerpc/dts-bindings/can/sja1000.txt	2009-05-30 19:48:40.399720890 +0200
@@ -0,0 +1,53 @@
+Memory mapped SJA1000 CAN controller from NXP (formerly Philips)
+
+Required properties:
+
+- compatible : should be "nxp,sja1000".
+
+- reg : should specify the chip select, address offset and size required
+	to map the registers of the SJA1000. The size is usually 0x80.
+
+- interrupts: property with a value describing the interrupt source
+	(number and sensitivity) required for the SJA1000.
+
+Optional properties:
+
+- nxp,external-clock-frequency : Frequency of the external oscillator
+	clock in Hz. Note that the internal clock frequency used by the
+	SJA1000 is half of that value. If not specified, a default value
+	of 16000000 (16 MHz) is used.
+
+- nxp,tx-output-mode : operation mode of the TX output control logic:
+	<0x0> : bi-phase output mode
+	<0x1> : normal output mode (default)
+	<0x2> : test output mode
+	<0x3> : clock output mode
+
+- nxp,tx-output-config : TX output pin configuration:
+	<0x01> : TX0 invert
+	<0x02> : TX0 pull-down (default)
+	<0x04> : TX0 pull-up
+	<0x06> : TX0 push-pull
+	<0x08> : TX1 invert
+	<0x10> : TX1 pull-down
+	<0x20> : TX1 pull-up
+	<0x30> : TX1 push-pull
+
+- nxp,clock-out-frequency : clock frequency in Hz on the CLKOUT pin.
+	If not specified or if the specified value is 0, the CLKOUT pin
+	will be disabled.
+
+- nxp,no-comparator-bypass : Allows to disable the CAN input comperator.
+
+For futher information, please have a look to the SJA1000 data sheet.
+
+Examples:
+
+can@3,100 {
+	compatible = "nxp,sja1000";
+	reg = <3 0x100 0x80>;
+	interrupts = <2 0>;
+	interrupt-parent = <&mpic>;
+	nxp,external-clock-frequency = <16000000>;
+};
+
Index: net-next-2.6/include/linux/can/platform/sja1000.h
===================================================================
--- net-next-2.6.orig/include/linux/can/platform/sja1000.h	2009-05-30 19:48:32.738720411 +0200
+++ net-next-2.6/include/linux/can/platform/sja1000.h	2009-05-30 19:48:40.402720478 +0200
@@ -13,6 +13,7 @@
 #define OCR_MODE_TEST     0x01
 #define OCR_MODE_NORMAL   0x02
 #define OCR_MODE_CLOCK    0x03
+#define OCR_MODE_MASK     0x07
 #define OCR_TX0_INVERT    0x04
 #define OCR_TX0_PULLDOWN  0x08
 #define OCR_TX0_PULLUP    0x10
@@ -21,6 +22,8 @@
 #define OCR_TX1_PULLDOWN  0x40
 #define OCR_TX1_PULLUP    0x80
 #define OCR_TX1_PUSHPULL  0xc0
+#define OCR_TX_MASK       0xfc
+#define OCR_TX_SHIFT      2
 
 struct sja1000_platform_data {
 	u32 clock;	/* CAN bus oscillator frequency in Hz */

