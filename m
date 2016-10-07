From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: [PATCH 09/10] net: phy: Add MDIO driver for Juniper's SAM FPGA
Date: Fri,  7 Oct 2016 18:18:37 +0300
Message-ID: <1475853518-22264-10-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Wolfram Sang <wsa@the-dreams.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Wim Van Sebroeck <wim@iguana.be>,
        Peter Rosin <peda@axentia.se>,
        Debjit Ghosh <dghosh@juniper.net>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        Maryam Seraj <mseraj@juniper.net>,
        Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-gpio@vger.kernel.org, linux-i2c@vger.kernel.org,
        linux-mtd@lists.infradead.org, li
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-i2c-owner@vger.kernel.org>
In-Reply-To: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Georgi Vlaev <gvlaev@juniper.net>

Add driver for the MDIO IP block present in Juniper's
SAM FPGA.

This driver supports only Clause 45 of the 802.3 spec.

Note that due to the fact that there are no drivers for
Broadcom/Avago retimers on 10/40Ge path that are controlled
from the MDIO interface there is a method to have direct
access to registers via a debugfs interface.

Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
---
 drivers/net/phy/Kconfig    |   8 +
 drivers/net/phy/Makefile   |   1 +
 drivers/net/phy/mdio-sam.c | 564 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 573 insertions(+)
 create mode 100644 drivers/net/phy/mdio-sam.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 5078a0d..7d7f265 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -122,6 +122,14 @@ config MDIO_OCTEON
 	  buses. It is required by the Octeon and ThunderX ethernet device
 	  drivers on some systems.
 
+config MDIO_SAM
+	tristate "Juniper Networks SAM FPGA MDIO controller"
+	depends on MFD_JUNIPER_SAM
+	help
+	  This module provides a driver for the Juniper Network SAM FPGA MDIO
+	  buses. This hardware can be found in the Gladiator PIC SAM FPGA. This
+	  driver is client of the sam-core MFD driver.
+
 config MDIO_SUN4I
 	tristate "Allwinner sun4i MDIO interface support"
 	depends on ARCH_SUNXI
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e58667d..c7631cf 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -17,6 +17,7 @@ obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
 obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o
+obj-$(CONFIG_MDIO_SAM)		+= mdio-sam.o
 obj-$(CONFIG_MDIO_SUN4I)	+= mdio-sun4i.o
 obj-$(CONFIG_MDIO_THUNDER)	+= mdio-thunder.o
 obj-$(CONFIG_MDIO_XGENE)	+= mdio-xgene.o
diff --git a/drivers/net/phy/mdio-sam.c b/drivers/net/phy/mdio-sam.c
new file mode 100644
index 0000000..73cefa1
--- /dev/null
+++ b/drivers/net/phy/mdio-sam.c
@@ -0,0 +1,564 @@
+/*
+ * Juniper Networks SAM FPGA MDIO driver.
+ *
+ * Copyright (c) 2015, Juniper Networks
+ * Author: Georgi Vlaev <gvlaev@juniper.net>
+ *
+ * The MDIO bus driver supports GPQAM, GPCAM, GPQ28 FPGAs found
+ * on Juniper's 10/40/100GE Gladiator PIC cards. Only Clause 45
+ * access is currently available natively.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/io.h>
+#include <linux/of_address.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#include <linux/string.h>
+#include <linux/ctype.h>
+#endif
+
+#define MDIO_CMD1	0x0000 /* Command Table 1 */
+#define MDIO_CMD2	0x0800 /* Command Table 2 */
+#define MDIO_RESULT	0x1000 /* Result Table (RO) */
+#define MDIO_PRI_CMD1	0x1800 /* Priority Command Table 1 */
+#define MDIO_PRI_CMD2	0x2000 /* Priority Command Table 1 */
+#define MDIO_PRI_RESULT	0x2800 /* Priority Result Table (RO) */
+#define MDIO_TBL_CMD	0x3000 /* Table Command Register (WO) */
+#define MDIO_STATUS	0x3008 /* Master Status (RO) */
+#define MDIO_STATUS_INT	0x3010 /* Master Status Interrupt Mask (W1C) */
+
+/* MDIO_TBL_CMD */
+#define TBL_CMD_REG_ABORT	BIT(31) /* Regular Table ABORT */
+#define TBL_CMD_REG_GO		BIT(30) /* Regular Table GO */
+#define TBL_CMD_PRI_ABORT	BIT(29) /* Priority Table Abort */
+#define TBL_CMD_PRI_GO		BIT(28) /* Priority Table GO */
+#define TBL_CMD_SOFT_RESET	BIT(27) /* Soft Reset */
+
+/* MDIO_STATUS */
+#define STAT_REG_RDY	BIT(31) /* READY for Programming Regular Table */
+#define STAT_REG_DONE	BIT(30)	/* DONE SUCCESSFULLY WITH REGULAR TABLE */
+#define STAT_PRI_RDY	BIT(29) /* READY for Programming Priority Table */
+#define STAT_PRI_DONE	BIT(28) /* DONE SUCCESSFULLY WITH PRIORITY TABLE */
+#define STAT_REG_ERR	BIT(27) /* DONE WITH ERRORS for Regular Table */
+#define STAT_PRI_ERR	BIT(26) /* DONE WITH ERRORS for Priority Table */
+#define STAT_REG_PROG_ERR	BIT(25) /* Programming Err for Regular Table */
+#define STAT_PRI_PROG_ERR	BIT(24) /* Programming Err for Priority Table */
+
+/* MDIO_CMD2, MDIO_PRI_CMD2 */
+#define CMD2_ENABLE	BIT(17)
+#define CMD2_READ	BIT(16)
+
+/* MDIO_RESULT, MDIO_PRI_RESULT */
+#define RES_SUCCESS	BIT(17)
+#define RES_ERROR	BIT(16)
+
+#define MDIO_RDY_TMO	30 /* in msec */
+
+struct mdio_sam_data {
+	void __iomem *base;
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *dir;
+	/* Clause 45 addressing
+	 * addr[5]: PHYAD
+	 * reg[21]: DEVAD 5 bits + REG 16 bits
+	 * value[16]
+	 */
+	u8 addr;	/* phyad */
+	u32 reg;	/* devad + reg = (devad & 0x1f) << 16 | reg */
+	u16 value;	/* value */
+#endif
+};
+
+/* raw_io binary attribute: read/write any device on the bus */
+static ssize_t
+mdio_sam_sysfs_write_raw_io(struct file *filp,
+			    struct kobject *kobj,
+			    struct bin_attribute *attr,
+			    char *buf, loff_t offset, size_t size)
+{
+	struct mii_bus *bus = to_mii_bus(container_of(kobj,
+					struct device, kobj));
+	int ret;
+	u32 reg = offset & 0x1fffff;
+	u8 phy = (offset >> 21) & 0x1f;
+
+	if (size != 2)
+		return -EINVAL;
+
+	ret = mdiobus_write(bus, phy, reg | MII_ADDR_C45, *(u16 *)buf);
+	if (ret)
+		return ret;
+
+	return size;
+}
+
+static ssize_t
+mdio_sam_sysfs_read_raw_io(struct file *filp,
+			   struct kobject *kobj,
+			   struct bin_attribute *attr,
+			   char *buf, loff_t offset, size_t size)
+{
+	struct mii_bus *bus = to_mii_bus(container_of(kobj,
+					struct device, kobj));
+	int ret;
+	u32 reg = offset & 0x1fffff;
+	u8 phy = (offset >> 21) & 0x1f;
+
+	if (size != 2)
+		return -EINVAL;
+
+	ret = mdiobus_read(bus, phy, reg | MII_ADDR_C45);
+	if (ret < 0)
+		return ret;
+
+	*(u16 *)buf = (u16)ret;
+
+	return size;
+}
+
+static struct bin_attribute bin_attr_raw_io = {
+	.attr = {.name = "raw_io", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0x4000000,
+	.read = mdio_sam_sysfs_read_raw_io,
+	.write = mdio_sam_sysfs_write_raw_io,
+};
+
+#ifdef CONFIG_DEBUG_FS
+/* debugfs: set/get register offset */
+static int mdio_sam_debugfs_addr_print(struct seq_file *s, void *p)
+{
+	struct mdio_sam_data *data = (struct mdio_sam_data *)s->private;
+
+	seq_printf(s, "0x%02x\n", data->addr);
+
+	return 0;
+}
+
+static int mdio_sam_debugfs_addr_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mdio_sam_debugfs_addr_print, inode->i_private);
+}
+
+static ssize_t
+mdio_sam_debugfs_addr_write(struct file *file, const char __user *user_buf,
+			    size_t count, loff_t *ppos)
+{
+	struct mdio_sam_data *data =
+		((struct seq_file *)(file->private_data))->private;
+	unsigned long addr;
+	int err;
+
+	err = kstrtoul_from_user(user_buf, count, 0, &addr);
+	if (err)
+		return err;
+
+	if (addr > 0x1f)
+		return -EINVAL;
+
+	data->addr = (u8)(addr);
+
+	return count;
+}
+
+static const struct file_operations mdio_sam_debugfs_addr_fops = {
+	.open = mdio_sam_debugfs_addr_open,
+	.write = mdio_sam_debugfs_addr_write,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+	.owner = THIS_MODULE,
+};
+
+/* debugfs: set/get register offset */
+static int mdio_sam_debugfs_reg_print(struct seq_file *s, void *p)
+{
+	struct mdio_sam_data *data = (struct mdio_sam_data *)s->private;
+
+	seq_printf(s, "0x%06X\n", data->reg);
+
+	return 0;
+}
+
+static int mdio_sam_debugfs_reg_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mdio_sam_debugfs_reg_print, inode->i_private);
+}
+
+static ssize_t
+mdio_sam_debugfs_reg_write(struct file *file, const char __user *user_buf,
+			   size_t count, loff_t *ppos)
+{
+	struct mdio_sam_data *data =
+		((struct seq_file *)(file->private_data))->private;
+	unsigned long reg;
+	int err;
+
+	err = kstrtoul_from_user(user_buf, count, 0, &reg);
+	if (err)
+		return err;
+
+	if (reg > 0x1fffff)
+		return -EINVAL;
+
+	data->reg = reg;
+
+	return count;
+}
+
+static const struct file_operations mdio_sam_debugfs_reg_fops = {
+	.open = mdio_sam_debugfs_reg_open,
+	.write = mdio_sam_debugfs_reg_write,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+	.owner = THIS_MODULE,
+};
+
+/* debugfs: set/get register value */
+static int mdio_sam_debugfs_val_print(struct seq_file *s, void *p)
+{
+	struct mii_bus *bus = (struct mii_bus *)s->private;
+	struct mdio_sam_data *data = bus->priv;
+	int ret;
+
+	ret = mdiobus_read(bus, data->addr, data->reg | MII_ADDR_C45);
+	if (ret < 0)
+		return ret;
+
+	seq_printf(s, "0x%04X\n", ret);
+	return 0;
+}
+
+static int mdio_sam_debugfs_val_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mdio_sam_debugfs_val_print, inode->i_private);
+}
+
+static ssize_t
+mdio_sam_debugfs_val_write(struct file *file, const char __user *user_buf,
+			   size_t count, loff_t *ppos)
+{
+	struct mii_bus *bus =
+		((struct seq_file *)(file->private_data))->private;
+	struct mdio_sam_data *data = bus->priv;
+	unsigned long value;
+	int ret;
+
+	ret = kstrtoul_from_user(user_buf, count, 0, &value);
+	if (ret)
+		return ret;
+
+	ret = mdiobus_write(bus, data->addr, data->reg | MII_ADDR_C45, value);
+	if (ret < 0)
+		return ret;
+
+	return count;
+}
+
+static const struct file_operations mdio_sam_debugfs_val_fops = {
+	.open = mdio_sam_debugfs_val_open,
+	.write = mdio_sam_debugfs_val_write,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+	.owner = THIS_MODULE,
+};
+
+static int mdio_sam_debugfs_init(struct mii_bus *bus)
+{
+	struct dentry *file;
+	struct mdio_sam_data *data = bus->priv;
+
+	data->dir = debugfs_create_dir(bus->id, NULL);
+	if (!data->dir)
+		return -ENOMEM;
+
+/* phy */
+	file = debugfs_create_file("addr", (S_IRUGO | S_IWUSR),
+				   data->dir, data,
+				   &mdio_sam_debugfs_addr_fops);
+	if (!file)
+		goto err;
+
+/* reg */
+	file = debugfs_create_file("reg", (S_IRUGO | S_IWUSR),
+				   data->dir, data,
+				   &mdio_sam_debugfs_reg_fops);
+	if (!file)
+		goto err;
+
+/* value */
+	file = debugfs_create_file("value", (S_IRUGO | S_IWUSR),
+				   data->dir, bus,
+				   &mdio_sam_debugfs_val_fops);
+	if (!file)
+		goto err;
+
+	return 0;
+err:
+	debugfs_remove_recursive(data->dir);
+	dev_err(&bus->dev, "failed to create debugfs entries.\n");
+
+	return -ENOMEM;
+}
+
+static void mdio_sam_debugfs_remove(struct mii_bus *bus)
+{
+	struct mdio_sam_data *data = bus->priv;
+
+	debugfs_remove_recursive(data->dir);
+}
+#endif
+
+static int mdio_sam_stat_wait(struct mii_bus *bus, u32 wait_mask)
+{
+	struct mdio_sam_data *data = bus->priv;
+	unsigned long timeout;
+	u32 stat;
+
+	timeout = jiffies + msecs_to_jiffies(MDIO_RDY_TMO);
+	do {
+		stat = ioread32(data->base + MDIO_STATUS);
+		if (stat & wait_mask)
+			return 0;
+
+		usleep_range(50, 100);
+	} while (time_before(jiffies, timeout));
+
+	return -EBUSY;
+}
+
+static int mdio_sam_read(struct mii_bus *bus, int phy_id, int regnum)
+{
+	struct mdio_sam_data *data = bus->priv;
+	u32 command, res;
+	int ret;
+
+	/* mdiobus_read holds the bus->mdio_lock mutex */
+
+	if (!(regnum & MII_ADDR_C45))
+		return -ENXIO;
+
+	ret = mdio_sam_stat_wait(bus, STAT_REG_RDY);
+	if (ret < 0)
+		return ret;
+
+	command = regnum & 0x1fffff; /* regnum = (dev_id << 16) | reg */
+	command |= ((phy_id & 0x1f) << 21);
+
+	iowrite32(command, data->base + MDIO_CMD1);
+	ioread32(data->base + MDIO_CMD1);
+	iowrite32(CMD2_READ | CMD2_ENABLE, data->base + MDIO_CMD2);
+	ioread32(data->base + MDIO_CMD2);
+	iowrite32(TBL_CMD_REG_GO, data->base + MDIO_TBL_CMD);
+	ioread32(data->base + MDIO_TBL_CMD);
+
+	usleep_range(50, 100);
+
+	ret = mdio_sam_stat_wait(bus, (STAT_REG_DONE | STAT_REG_ERR));
+	if (ret < 0)
+		return ret;
+
+	res = ioread32(data->base + MDIO_RESULT);
+
+	if (res & RES_ERROR || !(res & RES_SUCCESS))
+		return -EIO;
+
+	return (res & 0xffff);
+}
+
+static int mdio_sam_write(struct mii_bus *bus, int phy_id, int regnum, u16 val)
+{
+	struct mdio_sam_data *data = bus->priv;
+	u32 command;
+	int ret;
+
+	/* mdiobus_write holds the bus->mdio_lock mutex */
+
+	if (!(regnum & MII_ADDR_C45))
+		return -ENXIO;
+
+	ret = mdio_sam_stat_wait(bus, STAT_REG_RDY);
+	if (ret < 0)
+		return ret;
+
+	command = regnum & 0x1fffff; /* regnum = (dev_id << 16) | reg */
+	command |= ((phy_id & 0x1f) << 21);
+
+	iowrite32(command, data->base + MDIO_CMD1);
+	ioread32(data->base + MDIO_CMD1);
+	iowrite32(CMD2_ENABLE | val, data->base + MDIO_CMD2);
+	ioread32(data->base + MDIO_CMD2);
+	iowrite32(TBL_CMD_REG_GO, data->base + MDIO_TBL_CMD);
+	ioread32(data->base + MDIO_TBL_CMD);
+
+	usleep_range(50, 100);
+
+	ret = mdio_sam_stat_wait(bus, (STAT_REG_DONE | STAT_REG_ERR));
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static int mdio_sam_reset(struct mii_bus *bus)
+{
+	struct mdio_sam_data *data = bus->priv;
+
+	iowrite32(TBL_CMD_SOFT_RESET, data->base + MDIO_TBL_CMD);
+	ioread32(data->base + MDIO_TBL_CMD);
+	mdelay(10);
+	iowrite32(0, data->base + MDIO_TBL_CMD);
+	ioread32(data->base + MDIO_TBL_CMD);
+
+	/* zero tables */
+	memset_io(data->base + MDIO_CMD1, 0, 0x1000);
+	memset_io(data->base + MDIO_PRI_CMD1, 0, 0x1000);
+
+	return 0;
+}
+
+static int mdio_sam_of_register_bus(struct platform_device *pdev,
+				    struct device_node *np, void __iomem *base)
+{
+	struct mii_bus *bus;
+	struct mdio_sam_data *data;
+	u32 reg;
+	int ret;
+
+	bus = devm_mdiobus_alloc_size(&pdev->dev, sizeof(*data));
+	if (!bus)
+		return -ENOMEM;
+
+	/* bus offset */
+	ret = of_property_read_u32(np, "reg", &reg);
+	if (ret)
+		return -ENODEV;
+
+	data = bus->priv;
+	data->base = base + reg;
+
+	bus->parent = &pdev->dev;
+	bus->name = "mdio-sam";
+	bus->read = mdio_sam_read;
+	bus->write = mdio_sam_write;
+	bus->reset = mdio_sam_reset;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "mdiosam-%x-%x", pdev->id, reg);
+
+	ret = of_mdiobus_register(bus, np);
+	if (ret < 0)
+		return ret;
+#ifdef CONFIG_DEBUG_FS
+	ret = mdio_sam_debugfs_init(bus);
+	if (ret < 0)
+		goto err_unregister;
+#endif
+	ret = device_create_bin_file(&bus->dev, &bin_attr_raw_io);
+	if (ret)
+		goto err_debugfs;
+
+	return 0;
+
+err_debugfs:
+#ifdef CONFIG_DEBUG_FS
+	mdio_sam_debugfs_remove(bus);
+#endif
+err_unregister:
+	mdiobus_unregister(bus);
+
+	return ret;
+}
+
+static int mdio_sam_of_unregister_bus(struct device_node *np)
+{
+	struct mii_bus *bus;
+
+	bus = of_mdio_find_bus(np);
+	if (bus) {
+		device_remove_bin_file(&bus->dev, &bin_attr_raw_io);
+#ifdef CONFIG_DEBUG_FS
+		mdio_sam_debugfs_remove(bus);
+#endif
+		mdiobus_unregister(bus);
+	}
+	return 0;
+}
+
+static int mdio_sam_probe(struct platform_device *pdev)
+{
+	struct device_node *np;
+	struct resource *res;
+	void __iomem *base;
+	int ret;
+
+	if (!pdev->dev.of_node)
+		return -ENODEV;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	base = devm_ioremap_nocache(&pdev->dev, res->start,
+				    resource_size(res));
+	if (IS_ERR(base))
+		return PTR_ERR(base);
+
+	for_each_available_child_of_node(pdev->dev.of_node, np) {
+		ret = mdio_sam_of_register_bus(pdev, np, base);
+		if (ret)
+			goto err;
+	}
+
+	return 0;
+err:
+	/* roll back everything */
+	for_each_available_child_of_node(pdev->dev.of_node, np)
+		mdio_sam_of_unregister_bus(np);
+
+	return ret;
+}
+
+static int mdio_sam_remove(struct platform_device *pdev)
+{
+	struct device_node *np;
+
+	for_each_available_child_of_node(pdev->dev.of_node, np)
+		mdio_sam_of_unregister_bus(np);
+
+	return 0;
+}
+
+static const struct of_device_id mdio_sam_of_match[] = {
+	{ .compatible = "jnx,mdio-sam" },
+	{  }
+};
+MODULE_DEVICE_TABLE(of, mdio_sam_of_match);
+
+static struct platform_driver mdio_sam_driver = {
+	.probe = mdio_sam_probe,
+	.remove = mdio_sam_remove,
+	.driver = {
+		.name = "mdio-sam",
+		.owner = THIS_MODULE,
+		.of_match_table = mdio_sam_of_match,
+	},
+};
+
+module_platform_driver(mdio_sam_driver);
+
+MODULE_ALIAS("platform:mdio-sam");
+MODULE_AUTHOR("Georgi Vlaev <gvlaev@juniper.net>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Juniper Networks SAM MDIO bus driver");
-- 
1.9.1
