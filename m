From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: [PATCH 1/3] mfd: add support for Janz CMOD-IO PCI MODULbus Carrier Board
Date: Thu, 18 Mar 2010 09:38:42 -0700
Message-ID: <1268930324-29841-2-git-send-email-iws@ovro.caltech.edu>
Cc: netdev@vger.kernel.org, sameo@linux.intel.com,
	socketcan-core@lists.berlios.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <>
References: <>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Janz CMOD-IO PCI MODULbus carrier board is a PCI to MODULbus bridge,
which may host many different types of MODULbus daughterboards, including
CAN and GPIO controllers.

Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
Cc: Samuel Ortiz <sameo@linux.intel.com>
---
 drivers/mfd/Kconfig       |    8 +
 drivers/mfd/Makefile      |    1 +
 drivers/mfd/janz-cmodio.c |  339 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mfd/janz.h  |   54 +++++++
 4 files changed, 402 insertions(+), 0 deletions(-)
 create mode 100644 drivers/mfd/janz-cmodio.c
 create mode 100644 include/linux/mfd/janz.h

diff --git a/drivers/mfd/Kconfig b/drivers/mfd/Kconfig
index 8782978..f1858d7 100644
--- a/drivers/mfd/Kconfig
+++ b/drivers/mfd/Kconfig
@@ -27,6 +27,14 @@ config MFD_SM501_GPIO
 	 lines on the SM501. The platform data is used to supply the
 	 base number for the first GPIO line to register.
 
+config MFD_JANZ_CMODIO
+	tristate "Support for Janz CMOD-IO PCI MODULbus Carrier Board"
+	---help---
+	  This is the core driver for the Janz CMOD-IO PCI MODULbus
+	  carrier board. This device is a PCI to MODULbus bridge which may
+	  host many different types of MODULbus daughterboards, including
+	  CAN and GPIO controllers.
+
 config MFD_ASIC3
 	bool "Support for Compaq ASIC3"
 	depends on GENERIC_HARDIRQS && GPIOLIB && ARM
diff --git a/drivers/mfd/Makefile b/drivers/mfd/Makefile
index e09eb48..e8fa905 100644
--- a/drivers/mfd/Makefile
+++ b/drivers/mfd/Makefile
@@ -3,6 +3,7 @@
 #
 
 obj-$(CONFIG_MFD_SM501)		+= sm501.o
+obj-$(CONFIG_MFD_JANZ_CMODIO)	+= janz-cmodio.o
 obj-$(CONFIG_MFD_ASIC3)		+= asic3.o tmio_core.o
 obj-$(CONFIG_MFD_SH_MOBILE_SDHI)		+= sh_mobile_sdhi.o
 
diff --git a/drivers/mfd/janz-cmodio.c b/drivers/mfd/janz-cmodio.c
new file mode 100644
index 0000000..914280e
--- /dev/null
+++ b/drivers/mfd/janz-cmodio.c
@@ -0,0 +1,339 @@
+/*
+ * Janz CMOD-IO MODULbus Carrier Board PCI Driver
+ *
+ * Copyright (c) 2010 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * Lots of inspiration and code was copied from drivers/mfd/sm501.c
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or (at your
+ * option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/delay.h>
+#include <linux/platform_device.h>
+
+#include <linux/mfd/janz.h>
+
+#define DRV_NAME "janz-cmodio"
+
+/* Size of each MODULbus module in PCI BAR4 */
+#define CMODIO_MODULBUS_SIZE	0x200
+
+/* Maximum number of MODULbus modules on a CMOD-IO carrier board */
+#define CMODIO_MAX_MODULES	4
+
+/* Module Parameters */
+static unsigned int num_modules = CMODIO_MAX_MODULES;
+static unsigned char *modules[CMODIO_MAX_MODULES] = {
+	"janz-ican3",
+	"janz-ican3",
+	"",
+	"janz-ttl",
+};
+
+module_param_array(modules, charp, &num_modules, S_IRUGO);
+MODULE_PARM_DESC(modules, "MODULbus modules attached to the carrier board");
+
+struct cmodio_device {
+	/* Parent PCI device */
+	struct pci_dev *pdev;
+
+	/* PLX control registers */
+	struct janz_cmodio_onboard_regs __iomem *ctrl;
+
+	/* hex switch position */
+	u8 hex;
+
+	/* Subdevice ID numbers */
+	unsigned int subdev_id;
+};
+
+/*
+ * Subdevice Support
+ */
+
+static int cmodio_remove_subdev(struct device *dev, void *data)
+{
+	platform_device_unregister(to_platform_device(dev));
+	return 0;
+}
+
+static void cmodio_subdev_release(struct device *dev)
+{
+	kfree(to_platform_device(dev));
+}
+
+static struct platform_device *cmodio_create_subdev(struct cmodio_device *priv,
+						    char *name,
+						    unsigned int res_count,
+						    unsigned int pdata_size)
+{
+	struct platform_device *pdev;
+	size_t res_size;
+
+	res_size = sizeof(struct resource) * res_count;
+	pdev = kzalloc(sizeof(*pdev) + res_size + pdata_size, GFP_KERNEL);
+	if (!pdev)
+		return NULL;
+
+	pdev->dev.release = cmodio_subdev_release;
+	pdev->dev.parent = &priv->pdev->dev;
+	pdev->name = name;
+
+	if (res_count) {
+		pdev->resource = (struct resource *)(pdev + 1);
+		pdev->num_resources = res_count;
+	}
+
+	if (pdata_size)
+		pdev->dev.platform_data = (void *)(pdev + 1) + res_size;
+
+	return pdev;
+}
+
+/* Create a memory resource for a subdevice */
+static void cmodio_create_mem(struct resource *parent, struct resource *res,
+			      resource_size_t offset, resource_size_t size)
+{
+	res->flags = IORESOURCE_MEM;
+	res->parent = parent;
+	res->start = parent->start + offset;
+	res->end = parent->start + offset + size - 1;
+}
+
+/* Create an IRQ resource for a subdevice */
+static void cmodio_create_irq(struct resource *res, unsigned int irq)
+{
+	res->flags = IORESOURCE_IRQ;
+	res->parent = NULL;
+	res->start = irq;
+	res->end = irq;
+}
+
+static int __devinit cmodio_probe_subdevice(struct cmodio_device *priv,
+					    char *name, unsigned int modno)
+{
+	struct janz_platform_data *pdata;
+	struct platform_device *pdev;
+	resource_size_t offset, size;
+	struct pci_dev *pci;
+	int ret;
+
+	pci = priv->pdev;
+	pdev = cmodio_create_subdev(priv, name, 3, sizeof(*pdata));
+	if (!pdev) {
+		dev_err(&pci->dev, "MODULbus slot %d alloc failed\n", modno);
+		ret = -ENOMEM;
+		goto out_return;
+	}
+
+	pdata = pdev->dev.platform_data;
+	pdata->modno = modno;
+	pdev->id = priv->subdev_id++;
+
+	/* MODULbus registers -- PCI BAR3 is big-endian MODULbus access */
+	offset = CMODIO_MODULBUS_SIZE * modno;
+	size = CMODIO_MODULBUS_SIZE;
+	cmodio_create_mem(&pci->resource[3], &pdev->resource[0], offset, size);
+
+	/* PLX Control Registers -- PCI BAR4 is interrupt and other registers */
+	offset = 0;
+	size = resource_size(&pci->resource[4]);
+	cmodio_create_mem(&pci->resource[4], &pdev->resource[1], offset, size);
+
+	/* IRQ */
+	cmodio_create_irq(&pdev->resource[2], pci->irq);
+
+	/* Register the device */
+	ret = platform_device_register(pdev);
+	if (ret) {
+		dev_err(&pci->dev, "MODULbus slot %d register failed\n", modno);
+		goto out_free;
+	}
+
+	return 0;
+
+out_free:
+	cmodio_subdev_release(&pdev->dev);
+out_return:
+	return ret;
+}
+
+/* Probe each submodule using kernel parameters */
+static int __devinit cmodio_probe_submodules(struct cmodio_device *priv)
+{
+	char *name;
+	int i;
+
+	for (i = 0; i < num_modules; i++) {
+		name = modules[i];
+		if (!strcmp(name, ""))
+			continue;
+
+		dev_dbg(&priv->pdev->dev, "MODULbus %d: name %s\n", i, name);
+		cmodio_probe_subdevice(priv, name, i);
+	}
+
+	return 0;
+}
+
+/*
+ * SYSFS Attributes
+ */
+
+static ssize_t mbus_show(struct device *dev, struct device_attribute *attr,
+			 char *buf)
+{
+	struct cmodio_device *priv = dev_get_drvdata(dev);
+
+	return snprintf(buf, PAGE_SIZE, "%x\n", priv->hex);
+}
+
+static DEVICE_ATTR(modulbus_number, S_IRUGO, mbus_show, NULL);
+
+static struct attribute *cmodio_sysfs_attrs[] = {
+	&dev_attr_modulbus_number.attr,
+	NULL,
+};
+
+static const struct attribute_group cmodio_sysfs_attr_group = {
+	.attrs = cmodio_sysfs_attrs,
+};
+
+/*
+ * PCI Driver
+ */
+
+static int __devinit cmodio_pci_probe(struct pci_dev *dev,
+				      const struct pci_device_id *id)
+{
+	struct cmodio_device *priv;
+	int ret;
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		dev_err(&dev->dev, "unable to allocate private data\n");
+		ret = -ENOMEM;
+		goto out_return;
+	}
+
+	pci_set_drvdata(dev, priv);
+	priv->pdev = dev;
+
+	/* Hardware Initialization */
+	ret = pci_enable_device(dev);
+	if (ret) {
+		dev_err(&dev->dev, "unable to enable device\n");
+		goto out_free_priv;
+	}
+
+	pci_set_master(dev);
+	ret = pci_request_regions(dev, DRV_NAME);
+	if (ret) {
+		dev_err(&dev->dev, "unable to request regions\n");
+		goto out_pci_disable_device;
+	}
+
+	/* Onboard configuration registers */
+	priv->ctrl = pci_ioremap_bar(dev, 4);
+	if (!priv->ctrl) {
+		dev_err(&dev->dev, "unable to remap onboard regs\n");
+		ret = -ENOMEM;
+		goto out_pci_release_regions;
+	}
+
+	/* Read the hex switch on the carrier board */
+	priv->hex = ioread8(&priv->ctrl->int_enable);
+
+	/* Add the MODULbus number (hex switch value) to the device's sysfs */
+	ret = sysfs_create_group(&dev->dev.kobj, &cmodio_sysfs_attr_group);
+	if (ret) {
+		dev_err(&dev->dev, "unable to create sysfs attributes\n");
+		goto out_unmap_ctrl;
+	}
+
+	/*
+	 * Disable all interrupt lines, each submodule will enable its
+	 * own interrupt line if needed
+	 */
+	iowrite8(0xf, &priv->ctrl->int_disable);
+
+	/* Register drivers for all submodules */
+	ret = cmodio_probe_submodules(priv);
+	if (ret) {
+		dev_err(&dev->dev, "unable to probe submodules\n");
+		goto out_sysfs_remove_group;
+	}
+
+	return 0;
+
+out_sysfs_remove_group:
+	sysfs_remove_group(&dev->dev.kobj, &cmodio_sysfs_attr_group);
+out_unmap_ctrl:
+	iounmap(priv->ctrl);
+out_pci_release_regions:
+	pci_release_regions(dev);
+out_pci_disable_device:
+	pci_disable_device(dev);
+out_free_priv:
+	kfree(priv);
+out_return:
+	return ret;
+}
+
+static void __devexit cmodio_pci_remove(struct pci_dev *dev)
+{
+	struct cmodio_device *priv = pci_get_drvdata(dev);
+
+	device_for_each_child(&dev->dev, NULL, cmodio_remove_subdev);
+	sysfs_remove_group(&dev->dev.kobj, &cmodio_sysfs_attr_group);
+	iounmap(priv->ctrl);
+	pci_release_regions(dev);
+	pci_disable_device(dev);
+	kfree(priv);
+}
+
+#define PCI_VENDOR_ID_JANZ		0x13c3
+
+/* The list of devices that this module will support */
+static DEFINE_PCI_DEVICE_TABLE(cmodio_pci_ids) = {
+	{ PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9030, PCI_VENDOR_ID_JANZ, 0x0101 },
+	{ PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9050, PCI_VENDOR_ID_JANZ, 0x0100 },
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, cmodio_pci_ids);
+
+static struct pci_driver cmodio_pci_driver = {
+	.name     = DRV_NAME,
+	.id_table = cmodio_pci_ids,
+	.probe    = cmodio_pci_probe,
+	.remove   = __devexit_p(cmodio_pci_remove),
+};
+
+/*
+ * Module Init / Exit
+ */
+
+static int __init cmodio_init(void)
+{
+	return pci_register_driver(&cmodio_pci_driver);
+}
+
+static void __exit cmodio_exit(void)
+{
+	pci_unregister_driver(&cmodio_pci_driver);
+}
+
+MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
+MODULE_DESCRIPTION("Janz CMOD-IO PCI MODULbus Carrier Board Driver");
+MODULE_LICENSE("GPL");
+
+module_init(cmodio_init);
+module_exit(cmodio_exit);
diff --git a/include/linux/mfd/janz.h b/include/linux/mfd/janz.h
new file mode 100644
index 0000000..e9994c4
--- /dev/null
+++ b/include/linux/mfd/janz.h
@@ -0,0 +1,54 @@
+/*
+ * Common Definitions for Janz MODULbus devices
+ *
+ * Copyright (c) 2010 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or (at your
+ * option) any later version.
+ */
+
+#ifndef JANZ_H
+#define JANZ_H
+
+struct janz_platform_data {
+	/* MODULbus Module Number */
+	unsigned int modno;
+};
+
+/* PLX bridge chip onboard registers */
+struct janz_cmodio_onboard_regs {
+	u8 unused1;
+
+	/*
+	 * Read access: interrupt status
+	 * Write access: interrupt disable
+	 */
+	u8 int_disable;
+	u8 unused2;
+
+	/*
+	 * Read access: MODULbus number (hex switch)
+	 * Write access: interrupt enable
+	 */
+	u8 int_enable;
+	u8 unused3;
+
+	/* write-only */
+	u8 reset_assert;
+	u8 unused4;
+
+	/* write-only */
+	u8 reset_deassert;
+	u8 unused5;
+
+	/* read-write access to serial EEPROM */
+	u8 eep;
+	u8 unused6;
+
+	/* write-only access to EEPROM chip select */
+	u8 enid;
+};
+
+#endif /* JANZ_H */
-- 
1.5.4.3
