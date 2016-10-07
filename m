From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: [PATCH 05/10] gpio: Introduce SAM gpio driver
Date: Fri,  7 Oct 2016 18:18:33 +0300
Message-ID: <1475853518-22264-6-git-send-email-pantelis.antoniou@konsulko.com>
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
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <groeck@juniper.net>

The SAM GPIO IP block is present in the Juniper PTX series
of routers as part of the SAM FPGA.

Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
Signed-off-by: Guenter Roeck <groeck@juniper.net>
Signed-off-by: Rajat Jain <rajatjain@juniper.net>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
---
 drivers/gpio/Kconfig    |  11 +
 drivers/gpio/Makefile   |   1 +
 drivers/gpio/gpio-sam.c | 707 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 719 insertions(+)
 create mode 100644 drivers/gpio/gpio-sam.c

diff --git a/drivers/gpio/Kconfig b/drivers/gpio/Kconfig
index 9c91de6..c25dbe9 100644
--- a/drivers/gpio/Kconfig
+++ b/drivers/gpio/Kconfig
@@ -384,6 +384,17 @@ config GPIO_RCAR
 	help
 	  Say yes here to support GPIO on Renesas R-Car SoCs.
 
+config GPIO_SAM
+	tristate "SAM FPGA GPIO"
+	depends on MFD_JUNIPER_SAM
+	default y if MFD_JUNIPER_SAM
+	help
+	  This driver supports the GPIO interfaces on the SAM FPGA which is
+	  present on the relevant Juniper platforms.
+
+	  This driver can also be built as a module.  If so, the module
+	  will be called gpio-sam.
+
 config GPIO_SPEAR_SPICS
 	bool "ST SPEAr13xx SPI Chip Select as GPIO support"
 	depends on PLAT_SPEAR
diff --git a/drivers/gpio/Makefile b/drivers/gpio/Makefile
index d397ea5..6691d8c 100644
--- a/drivers/gpio/Makefile
+++ b/drivers/gpio/Makefile
@@ -96,6 +96,7 @@ obj-$(CONFIG_GPIO_RC5T583)	+= gpio-rc5t583.o
 obj-$(CONFIG_GPIO_RDC321X)	+= gpio-rdc321x.o
 obj-$(CONFIG_GPIO_RCAR)		+= gpio-rcar.o
 obj-$(CONFIG_ARCH_SA1100)	+= gpio-sa1100.o
+obj-$(CONFIG_GPIO_SAM)		+= gpio-sam.o
 obj-$(CONFIG_GPIO_SCH)		+= gpio-sch.o
 obj-$(CONFIG_GPIO_SCH311X)	+= gpio-sch311x.o
 obj-$(CONFIG_GPIO_SODAVILLE)	+= gpio-sodaville.o
diff --git a/drivers/gpio/gpio-sam.c b/drivers/gpio/gpio-sam.c
new file mode 100644
index 0000000..5082050
--- /dev/null
+++ b/drivers/gpio/gpio-sam.c
@@ -0,0 +1,707 @@
+/*
+ * Copyright (C) 2012 - 2015 Juniper Networks
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
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/pci.h>
+#include <linux/gpio.h>
+#include <linux/interrupt.h>
+#include <linux/irqdomain.h>
+#include <linux/errno.h>
+#include <linux/of_device.h>
+#include <linux/of_platform.h>
+#include <linux/of_gpio.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/mfd/sam.h>
+
+/* gpio status/configuration */
+#define SAM_GPIO_NEG_EDGE	(1 << 8)
+#define SAM_GPIO_NEG_EDGE_EN	(1 << 7)
+#define SAM_GPIO_POS_EDGE	(1 << 6)
+#define SAM_GPIO_POS_EDGE_EN	(1 << 5)
+#define SAM_GPIO_BLINK		(1 << 4)
+#define SAM_GPIO_OUT		(1 << 3)
+#define SAM_GPIO_OUT_TS		(1 << 2)
+#define SAM_GPIO_DEBOUNCE_EN	(1 << 1)
+#define SAM_GPIO_IN		(1 << 0)
+
+#define SAM_GPIO_BASE		0x1000
+
+#define SAM_MAX_NGPIO		512
+
+#define SAM_GPIO_ADDR(addr, nr)	((addr) + SAM_GPIO_BASE + (nr) * sizeof(u32))
+
+struct sam_gpio_irq_group {
+	int start;		/* 1st gpio pin */
+	int count;		/* # of pins in group */
+	int num_enabled;	/* # of enabled interrupts */
+};
+
+/**
+ * struct sam_gpio - GPIO private data structure.
+ * @base:			PCI base address of Memory mapped I/O register.
+ * @dev:			Pointer to device structure.
+ * @gpio:			Data for GPIO infrastructure.
+ * @gpio_base:			1st gpio pin
+ * @gpio_count:			# of gpio pins
+ * @irq_lock:			Lock used by interrupt subsystem
+ * @domain:			Pointer to interrupt domain
+ * @irq:			Interrupt # from parent
+ * @irq_high:			Second interrupt # from parent
+ *				(currently unused)
+ * @irq_group:			Interrupt group descriptions
+ *				(one group per interrupt bit)
+ * @irq_type:			The interrupt type for each gpio pin
+ */
+struct sam_gpio {
+	void __iomem *base;
+	struct device *dev;
+	struct gpio_chip gpio;
+	int gpio_base;
+	int gpio_count;
+	struct mutex irq_lock;
+	struct irq_domain *domain;
+	int irq;
+	int irq_high;
+	struct sam_gpio_irq_group irq_group[18];
+	u8 irq_type[SAM_MAX_NGPIO];
+	struct sam_platform_data *pdata;
+	const char **names;
+	u32 *export_flags;
+};
+#define to_sam(chip)	container_of((chip), struct sam_gpio, gpio)
+
+static void sam_gpio_bitop(struct sam_gpio *sam, unsigned int nr,
+			   u32 bit, bool set)
+{
+	u32 reg;
+
+	reg = ioread32(SAM_GPIO_ADDR(sam->base, nr));
+	if (set)
+		reg |= bit;
+	else
+		reg &= ~bit;
+	iowrite32(reg, SAM_GPIO_ADDR(sam->base, nr));
+	ioread32(SAM_GPIO_ADDR(sam->base, nr));
+}
+
+static int sam_gpio_debounce(struct gpio_chip *chip, unsigned int nr,
+			     unsigned int debounce)
+{
+	struct sam_gpio *sam = to_sam(chip);
+
+	sam_gpio_bitop(sam, nr, SAM_GPIO_DEBOUNCE_EN, debounce);
+
+	return 0;
+}
+
+static void sam_gpio_set(struct gpio_chip *chip, unsigned int nr, int val)
+{
+	struct sam_gpio *sam = to_sam(chip);
+
+	sam_gpio_bitop(sam, nr, SAM_GPIO_OUT, val);
+}
+
+static int sam_gpio_get(struct gpio_chip *chip, unsigned int nr)
+{
+	struct sam_gpio *sam = to_sam(chip);
+
+	return !!(ioread32(SAM_GPIO_ADDR(sam->base, nr)) & SAM_GPIO_IN);
+}
+
+static int sam_gpio_direction_output(struct gpio_chip *chip, unsigned int nr,
+				     int val)
+{
+	struct sam_gpio *sam = to_sam(chip);
+
+	sam_gpio_bitop(sam, nr, SAM_GPIO_OUT, val);
+	sam_gpio_bitop(sam, nr, SAM_GPIO_OUT_TS, false);
+	return 0;
+}
+
+static int sam_gpio_direction_input(struct gpio_chip *chip, unsigned int nr)
+{
+	struct sam_gpio *sam = to_sam(chip);
+
+	sam_gpio_bitop(sam, nr, SAM_GPIO_OUT_TS, true);
+	sam_gpio_bitop(sam, nr, SAM_GPIO_OUT, false);
+	return 0;
+}
+
+static void sam_gpio_setup(struct sam_gpio *sam)
+{
+	struct gpio_chip *chip = &sam->gpio;
+
+	chip->parent = sam->dev;
+	chip->label = dev_name(sam->dev);
+	chip->owner = THIS_MODULE;
+	chip->direction_input = sam_gpio_direction_input;
+	chip->get = sam_gpio_get;
+	chip->direction_output = sam_gpio_direction_output;
+	chip->set = sam_gpio_set;
+	chip->set_debounce = sam_gpio_debounce;
+	chip->dbg_show = NULL;
+	chip->base = sam->gpio_base;
+	chip->ngpio = sam->gpio_count;
+#ifdef CONFIG_OF_GPIO
+	chip->of_node = sam->dev->of_node;
+#endif
+	chip->names = sam->names;
+}
+
+static int sam_of_get_exports(struct device *dev, struct sam_gpio *sam)
+{
+	struct device_node *child, *exports;
+	int err = 0;
+
+	if (dev->of_node == NULL)
+		return 0;	/* No FDT node, we are done */
+
+	exports = of_get_child_by_name(dev->of_node, "gpio-exports");
+	if (exports == NULL)
+		return 0;	/* No exports, we are done */
+
+	if (of_get_child_count(exports) == 0)
+		return 0;	/* No children, we are done */
+
+	sam->names = devm_kzalloc(dev, sizeof(char *) * sam->gpio_count,
+				  GFP_KERNEL);
+	if (sam->names == NULL) {
+		err = -ENOMEM;
+		goto error;
+	}
+	sam->export_flags =
+		devm_kzalloc(dev, sizeof(u32) * sam->gpio_count, GFP_KERNEL);
+	if (sam->export_flags == NULL) {
+		err = -ENOMEM;
+		goto error;
+	}
+	for_each_child_of_node(exports, child) {
+		const char *label;
+		u32 pin, flags;
+
+		label = of_get_property(child, "label", NULL) ? : child->name;
+		err = of_property_read_u32_index(child, "pin", 0, &pin);
+		if (err)
+			break;
+		if (pin >= sam->gpio_count) {
+			err = -EINVAL;
+			break;
+		}
+		err = of_property_read_u32_index(child, "pin", 1, &flags);
+		if (err)
+			break;
+		/*
+		 * flags:
+		 * GPIOF_DIR_IN			bit 0=1
+		 * GPIOF_DIR_OUT		bit 0=0
+		 *	GPIOF_INIT_HIGH		bit 1=1
+		 * GPIOF_ACTIVE_LOW		bit 2=1
+		 * GPIOF_OPEN_DRAIN		bit 3=1
+		 * GPIOF_OPEN_SOURCE		bit 4=1
+		 * GPIOF_EXPORT			bit 5=1
+		 * GPIOF_EXPORT_CHANGEABLE	bit 6=1
+		 */
+		sam->names[pin] = label;
+		sam->export_flags[pin] = flags;
+	}
+error:
+	of_node_put(exports);
+	return err;
+}
+
+static int sam_gpio_of_init(struct device *dev, struct sam_gpio *sam)
+{
+	int err;
+	u32 val;
+	const u32 *igroup;
+	u32 group, start, count;
+	int i, iglen, ngpio;
+
+	if (of_have_populated_dt() && !dev->of_node) {
+		dev_err(dev, "No device node\n");
+		return -ENODEV;
+	}
+
+	err = of_property_read_u32(dev->of_node, "gpio-base", &val);
+	if (err)
+		val = -1;
+	sam->gpio_base = val;
+
+	err = of_property_read_u32(dev->of_node, "gpio-count", &val);
+	if (!err) {
+		if (val > SAM_MAX_NGPIO)
+			val = SAM_MAX_NGPIO;
+		sam->gpio_count = val;
+	}
+	/* validate gpio_count against chip data. Abort if chip data is bad. */
+	ngpio = ioread32(sam->base + 2 * sizeof(u32)) & 0xffff;
+	if (!ngpio || ngpio > SAM_MAX_NGPIO)
+		return -ENODEV;
+
+	if (!sam->gpio_count || sam->gpio_count > ngpio)
+		sam->gpio_count = ngpio;
+
+	igroup = of_get_property(dev->of_node, "gpio-interrupts", &iglen);
+	if (igroup) {
+		iglen /= sizeof(u32);
+		if (iglen < 3 || iglen % 3)
+			return -EINVAL;
+		iglen /= 3;
+		for (i = 0; i < iglen; i++) {
+			group = be32_to_cpu(igroup[i * 3]);
+			if (group >= ARRAY_SIZE(sam->irq_group))
+				return -EINVAL;
+			start = be32_to_cpu(igroup[i * 3 + 1]);
+			count = be32_to_cpu(igroup[i * 3 + 2]);
+			if (start >= sam->gpio_count || count == 0 ||
+			    start + count > sam->gpio_count)
+				return -EINVAL;
+			sam->irq_group[group].start = start;
+			sam->irq_group[group].count = count;
+		}
+	}
+
+	err = sam_of_get_exports(dev, sam);
+	return err;
+}
+
+static int sam_gpio_pin_to_irq_bit(struct sam_gpio *sam, int pin)
+{
+	int bit;
+
+	for (bit = 0; bit < ARRAY_SIZE(sam->irq_group); bit++) {
+		struct sam_gpio_irq_group *irq_group = &sam->irq_group[bit];
+
+		if (irq_group->count &&
+		    pin >= irq_group->start &&
+		    pin <= irq_group->start + irq_group->count)
+			return bit;
+	}
+	return -EINVAL;
+}
+
+static bool sam_gpio_irq_handle_group(struct sam_gpio *sam,
+				      struct sam_gpio_irq_group *irq_group)
+{
+	unsigned int virq = 0;
+	bool handled = false;
+	bool repeat;
+	int i;
+
+	/* no irq_group for the interrupt bit */
+	if (!irq_group->count)
+		return false;
+
+	WARN_ON(irq_group->num_enabled == 0);
+	do {
+		repeat = false;
+		for (i = 0; i < irq_group->count; i++) {
+			int pin = irq_group->start + i;
+			bool low, high;
+			u32 regval;
+			u8 type;
+
+			regval = ioread32(SAM_GPIO_ADDR(sam->base, pin));
+			/*
+			 * write back status to clear POS_EDGE and NEG_EDGE
+			 * status for this GPIO pin (status bits are
+			 * clear-on-one). This is necessary to clear the
+			 * high level interrupt status.
+			 * Also consider the interrupt to be handled in that
+			 * case, even if there is no taker.
+			 */
+			if (regval & (SAM_GPIO_POS_EDGE | SAM_GPIO_NEG_EDGE)) {
+				iowrite32(regval,
+					  SAM_GPIO_ADDR(sam->base, pin));
+				ioread32(SAM_GPIO_ADDR(sam->base, pin));
+				handled = true;
+			}
+
+			/*
+			 * Check if the pin changed its state.
+			 * If it did, and if the expected condition applies,
+			 * generate a virtual interrupt.
+			 * A pin can only generate an interrupt if
+			 * - interrupts are enabled for it
+			 * - it is configured as input
+			 */
+
+			if (!sam->irq_type[pin])
+				continue;
+			if (!(regval & SAM_GPIO_OUT_TS))
+				continue;
+
+			high = regval & (SAM_GPIO_IN | SAM_GPIO_POS_EDGE);
+			low = !(regval & SAM_GPIO_IN) ||
+				(regval & SAM_GPIO_NEG_EDGE);
+			type = sam->irq_type[pin];
+			if (((type & IRQ_TYPE_EDGE_RISING) &&
+			     (regval & SAM_GPIO_POS_EDGE)) ||
+			    ((type & IRQ_TYPE_EDGE_FALLING) &&
+			     (regval & SAM_GPIO_NEG_EDGE)) ||
+			    ((type & IRQ_TYPE_LEVEL_LOW) && low) ||
+			    ((type & IRQ_TYPE_LEVEL_HIGH) && high)) {
+				virq = irq_find_mapping(sam->domain, pin);
+				handle_nested_irq(virq);
+				if (type & (IRQ_TYPE_LEVEL_LOW
+					    | IRQ_TYPE_LEVEL_HIGH))
+					repeat = true;
+			}
+		}
+		schedule();
+	} while (repeat);
+
+	return handled;
+}
+
+static irqreturn_t sam_gpio_irq_handler(int irq, void *data)
+{
+	struct sam_gpio *sam = data;
+	struct sam_platform_data *pdata = sam->pdata;
+	irqreturn_t ret = IRQ_NONE;
+	bool handled;
+	u32 status;
+
+	do {
+		handled = false;
+		status = pdata->irq_status(sam->dev->parent, SAM_IRQ_GPIO,
+					   sam->irq);
+		pdata->irq_status_clear(sam->dev->parent, SAM_IRQ_GPIO,
+					sam->irq, status);
+		while (status) {
+			unsigned int bit;
+
+			bit = __ffs(status);
+			status &= ~(1 << bit);
+			handled =
+			  sam_gpio_irq_handle_group(sam, &sam->irq_group[bit]);
+			if (handled)
+				ret = IRQ_HANDLED;
+		}
+	} while (handled);
+
+	return ret;
+}
+
+static int sam_gpio_to_irq(struct gpio_chip *chip, unsigned int offset)
+{
+	struct sam_gpio *sam = to_sam(chip);
+
+	return irq_create_mapping(sam->domain, offset);
+}
+
+static void sam_irq_mask(struct irq_data *data)
+{
+	struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
+	struct sam_platform_data *pdata = sam->pdata;
+	int bit = sam_gpio_pin_to_irq_bit(sam, data->hwirq);
+
+	if (bit < 0)
+		return;
+
+	if (--sam->irq_group[bit].num_enabled <= 0) {
+		pdata->disable_irq(sam->dev->parent, SAM_IRQ_GPIO, sam->irq,
+				   1 << bit);
+	}
+}
+
+static void sam_irq_unmask(struct irq_data *data)
+{
+	struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
+	struct sam_platform_data *pdata = sam->pdata;
+	int bit = sam_gpio_pin_to_irq_bit(sam, data->hwirq);
+
+	if (bit < 0)
+		return;
+
+	sam->irq_group[bit].num_enabled++;
+	pdata->enable_irq(sam->dev->parent, SAM_IRQ_GPIO, sam->irq, 1 << bit);
+}
+
+static int sam_irq_set_type(struct irq_data *data, unsigned int type)
+{
+	struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
+	int bit = sam_gpio_pin_to_irq_bit(sam, data->hwirq);
+
+	if (bit < 0)
+		return bit;
+
+	sam->irq_type[data->hwirq] = type & 0x0f;
+	sam_gpio_bitop(sam, data->hwirq, SAM_GPIO_OUT_TS, true);
+	sam_gpio_bitop(sam, data->hwirq, SAM_GPIO_DEBOUNCE_EN, type & 0x10);
+	sam_gpio_bitop(sam, data->hwirq,
+		       SAM_GPIO_POS_EDGE_EN | SAM_GPIO_POS_EDGE,
+		       type & (IRQ_TYPE_EDGE_RISING | IRQ_TYPE_LEVEL_HIGH));
+	sam_gpio_bitop(sam, data->hwirq,
+		       SAM_GPIO_NEG_EDGE_EN | SAM_GPIO_NEG_EDGE,
+		       type & (IRQ_TYPE_EDGE_FALLING | IRQ_TYPE_LEVEL_LOW));
+
+	return 0;
+}
+
+static void sam_irq_bus_lock(struct irq_data *data)
+{
+	struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
+
+	mutex_lock(&sam->irq_lock);
+}
+
+static void sam_irq_bus_unlock(struct irq_data *data)
+{
+	struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
+
+	/* Synchronize interrupts to chip */
+
+	mutex_unlock(&sam->irq_lock);
+}
+
+static struct irq_chip sam_irq_chip = {
+	.name = "gpio-sam",
+	.irq_mask = sam_irq_mask,
+	.irq_unmask = sam_irq_unmask,
+	.irq_set_type = sam_irq_set_type,
+	.irq_bus_lock = sam_irq_bus_lock,
+	.irq_bus_sync_unlock = sam_irq_bus_unlock,
+};
+
+static int sam_gpio_irq_map(struct irq_domain *domain, unsigned int irq,
+			    irq_hw_number_t hwirq)
+{
+	irq_set_chip_data(irq, domain->host_data);
+	irq_set_chip(irq, &sam_irq_chip);
+	irq_set_nested_thread(irq, true);
+
+	irq_set_noprobe(irq);
+
+	return 0;
+}
+
+static const struct irq_domain_ops sam_gpio_irq_domain_ops = {
+	.map = sam_gpio_irq_map,
+	.xlate = irq_domain_xlate_twocell,
+};
+
+static int sam_gpio_irq_setup(struct device *dev, struct sam_gpio *sam)
+{
+	int ret;
+
+	sam->domain = irq_domain_add_linear(dev->of_node,
+					    sam->gpio_count,
+					    &sam_gpio_irq_domain_ops,
+					    sam);
+	if (sam->domain == NULL)
+		return -ENOMEM;
+
+	ret = devm_request_threaded_irq(dev, sam->irq, NULL,
+					sam_gpio_irq_handler,
+					IRQF_ONESHOT,
+					dev_name(dev), sam);
+	if (ret)
+		goto out_remove_domain;
+
+	sam->gpio.to_irq = sam_gpio_to_irq;
+
+	if (!try_module_get(dev->parent->driver->owner)) {
+		ret = -EINVAL;
+		goto out_remove_domain;
+	}
+
+	return 0;
+
+out_remove_domain:
+	irq_domain_remove(sam->domain);
+	sam->domain = NULL;
+	return ret;
+}
+
+static void sam_gpio_irq_teardown(struct device *dev, struct sam_gpio *sam)
+{
+	int i, irq;
+	struct sam_platform_data *pdata = sam->pdata;
+
+	pdata->disable_irq(dev->parent, SAM_IRQ_GPIO, sam->irq, 0xffffffff);
+
+	for (i = 0; i < sam->gpio_count; i++) {
+		irq = irq_find_mapping(sam->domain, i);
+		if (irq > 0)
+			irq_dispose_mapping(irq);
+	}
+	irq_domain_remove(sam->domain);
+	module_put(dev->parent->driver->owner);
+}
+
+static int sam_gpio_unexport(struct sam_gpio *sam)
+{
+	int i;
+
+	if (!sam->export_flags)
+		return 0;
+
+	/* un-export all auto-exported pins */
+	for (i = 0; i < sam->gpio_count; i++) {
+		struct gpio_desc *desc = gpio_to_desc(sam->gpio.base + i);
+
+		if (desc == NULL)
+			continue;
+
+		if (sam->export_flags[i] & GPIOF_EXPORT)
+			gpiochip_free_own_desc(desc);
+	}
+	return 0;
+}
+
+static int sam_gpio_export(struct sam_gpio *sam)
+{
+	int i, ret;
+
+	if (!sam->export_flags)
+		return 0;
+
+	/* auto-export pins as requested */
+
+	for (i = 0; i < sam->gpio_count; i++) {
+		u32 flags = sam->export_flags[i];
+		struct gpio_desc *desc;
+
+		/* request and initialize exported pins */
+		if (!(flags & GPIOF_EXPORT))
+			continue;
+
+		desc  = gpiochip_request_own_desc(&sam->gpio, i, "sam-export");
+		if (IS_ERR(desc)) {
+			ret = PTR_ERR(desc);
+			goto error;
+		}
+		if (flags & GPIOF_DIR_IN) {
+			ret = gpiod_direction_input(desc);
+			if (ret)
+				goto error;
+		} else {
+			ret = gpiod_direction_output(desc, flags &
+						    (GPIOF_OUT_INIT_HIGH |
+						     GPIOF_ACTIVE_LOW));
+			if (ret)
+				goto error;
+		}
+		ret = gpiod_export(desc, flags & GPIOF_EXPORT_CHANGEABLE);
+
+		if (ret)
+			goto error;
+	}
+	return 0;
+
+error:
+	sam_gpio_unexport(sam);
+	return ret;
+}
+
+static int sam_gpio_probe(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct sam_gpio *sam;
+	struct resource *res;
+	int ret;
+	struct sam_platform_data *pdata = dev_get_platdata(&pdev->dev);
+
+	sam = devm_kzalloc(dev, sizeof(*sam), GFP_KERNEL);
+	if (sam == NULL)
+		return -ENOMEM;
+
+	sam->dev = dev;
+	sam->pdata = pdata;
+	platform_set_drvdata(pdev, sam);
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENODEV;
+
+	sam->irq = platform_get_irq(pdev, 0);
+	sam->irq_high = platform_get_irq(pdev, 1);
+
+	sam->base = devm_ioremap_nocache(dev, res->start, resource_size(res));
+	if (!sam->base)
+		return -ENOMEM;
+
+	mutex_init(&sam->irq_lock);
+
+	ret = sam_gpio_of_init(dev, sam);
+	if (ret)
+		return ret;
+
+	sam_gpio_setup(sam);
+
+	if (pdata && sam->irq >= 0 && of_find_property(dev->of_node,
+					      "interrupt-controller", NULL)) {
+		ret = sam_gpio_irq_setup(dev, sam);
+		if (ret < 0)
+			return ret;
+	}
+
+	ret = gpiochip_add(&sam->gpio);
+	if (ret)
+		goto teardown;
+
+	ret = sam_gpio_export(sam);
+	if (ret)
+		goto teardown_remove;
+
+	return 0;
+
+teardown_remove:
+	gpiochip_remove(&sam->gpio);
+
+teardown:
+	if (sam->domain)
+		sam_gpio_irq_teardown(dev, sam);
+	return ret;
+}
+
+static int sam_gpio_remove(struct platform_device *pdev)
+{
+	struct sam_gpio *sam = platform_get_drvdata(pdev);
+	struct device *dev = &pdev->dev;
+
+	dev_info(dev, "remove\n");
+
+	sam_gpio_unexport(sam);
+
+	if (sam->domain)
+		sam_gpio_irq_teardown(dev, sam);
+
+	gpiochip_remove(&sam->gpio);
+
+	return 0;
+}
+
+static const struct of_device_id sam_gpio_ids[] = {
+	{ .compatible = "jnx,gpio-sam", },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, sam_gpio_ids);
+
+static struct platform_driver sam_gpio_driver = {
+	.driver = {
+		.name = "gpio-sam",
+		.owner  = THIS_MODULE,
+		.of_match_table = sam_gpio_ids,
+	},
+	.probe = sam_gpio_probe,
+	.remove = sam_gpio_remove,
+};
+
+module_platform_driver(sam_gpio_driver);
+
+MODULE_DESCRIPTION("SAM FPGA GPIO Driver");
+MODULE_LICENSE("GPL");
-- 
1.9.1

