From: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 3/4] gpio: ptxpmb-ext-cpld: Add driver for Juniper's PTXPMB extended CPLD
Date: Fri,  7 Oct 2016 18:19:33 +0300
Message-ID: <1475853574-22339-4-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        JawaharBalaji Thirumalaisamy <jawaharb-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475853574-22339-1-git-send-email-pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <groeck-3r7Miqu9kMnR7s880joybQ@public.gmane.org>

This IP block is present in the PTXPMB extended CPLD present on
Junipers PTX series of routers and provides SIB connector status pins
as GPIO pins for use with other drivers.

Signed-off-by: Guenter Roeck <groeck-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
Signed-off-by: JawaharBalaji Thirumalaisamy <jawaharb-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
---
 drivers/gpio/Kconfig                |  11 +
 drivers/gpio/Makefile               |   1 +
 drivers/gpio/gpio-ptxpmb-ext-cpld.c | 430 ++++++++++++++++++++++++++++++++++++
 3 files changed, 442 insertions(+)
 create mode 100644 drivers/gpio/gpio-ptxpmb-ext-cpld.c

diff --git a/drivers/gpio/Kconfig b/drivers/gpio/Kconfig
index c25dbe9..281029b 100644
--- a/drivers/gpio/Kconfig
+++ b/drivers/gpio/Kconfig
@@ -371,6 +371,17 @@ config GPIO_PTXPMB_CPLD
 	  This driver can also be built as a module.  If so, the module
 	  will be called gpio-ptxpmb-cpld.
 
+config GPIO_PTXPMB_EXT_CPLD
+	tristate "PTXPMB Extended CPLD GPIO"
+	depends on MFD_JUNIPER_EXT_CPLD
+	default y if MFD_JUNIPER_EXT_CPLD
+	help
+	  This driver exports various bits on the Juniper Control Board
+	  Extended CPLD as GPIO pins to userspace.
+
+	  This driver can also be built as a module.  If so, the module
+	  will be called gpio-ptxpmb-ext-cpld.
+
 config GPIO_PXA
 	bool "PXA GPIO support"
 	depends on ARCH_PXA || ARCH_MMP
diff --git a/drivers/gpio/Makefile b/drivers/gpio/Makefile
index 6691d8c..ec890c7 100644
--- a/drivers/gpio/Makefile
+++ b/drivers/gpio/Makefile
@@ -91,6 +91,7 @@ obj-$(CONFIG_GPIO_PCH)		+= gpio-pch.o
 obj-$(CONFIG_GPIO_PISOSR)	+= gpio-pisosr.o
 obj-$(CONFIG_GPIO_PL061)	+= gpio-pl061.o
 obj-$(CONFIG_GPIO_PTXPMB_CPLD)	+= gpio-ptxpmb-cpld.o
+obj-$(CONFIG_GPIO_PTXPMB_EXT_CPLD) += gpio-ptxpmb-ext-cpld.o
 obj-$(CONFIG_GPIO_PXA)		+= gpio-pxa.o
 obj-$(CONFIG_GPIO_RC5T583)	+= gpio-rc5t583.o
 obj-$(CONFIG_GPIO_RDC321X)	+= gpio-rdc321x.o
diff --git a/drivers/gpio/gpio-ptxpmb-ext-cpld.c b/drivers/gpio/gpio-ptxpmb-ext-cpld.c
new file mode 100644
index 0000000..0152f0b
--- /dev/null
+++ b/drivers/gpio/gpio-ptxpmb-ext-cpld.c
@@ -0,0 +1,430 @@
+/*
+ * Copyright (C) 2012 Juniper networks
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
+#include <linux/errno.h>
+#include <linux/of_device.h>
+#include <linux/of_platform.h>
+#include <linux/of_gpio.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/irqdomain.h>
+
+#include <linux/mfd/ptxpmb_ext_cpld.h>
+
+#define EXT_CPLD_NGPIO	32	/*  0..15: SIB presence bits	*/
+				/* 16..31: SIB interrupt status	*/
+
+/**
+ * struct ext_cpld_gpio - GPIO private data structure.
+ * @base: PCI base address of Memory mapped I/O register.
+ * @dev: Pointer to device structure.
+ * @gpio: Data for GPIO infrastructure.
+ */
+struct ext_cpld_gpio {
+	void __iomem *base;
+	struct device *dev;
+	struct gpio_chip gpio;
+	struct mutex irq_lock;
+	struct mutex work_lock;
+	struct irq_domain *domain;
+	int irq;
+	u8 irq_type[EXT_CPLD_NGPIO];
+	u16 sib_presence_cache;
+	u16 sib_presence_irq_enabled;
+	u16 sib_irq_status_cache;
+	u16 sib_irq_enabled;
+	struct delayed_work work;
+};
+
+static int ext_cpld_gpio_get(struct gpio_chip *gpio, unsigned int nr)
+{
+	struct ext_cpld_gpio *chip = container_of(gpio,
+						  struct ext_cpld_gpio, gpio);
+	struct pmb_boot_cpld_ext *cpld = chip->base;
+	u16 *addr = nr < 16 ? &cpld->sib_presence : &cpld->sib_irq_status;
+	u16 val;
+
+	val = ioread16(addr);
+	if (nr < 16)
+		chip->sib_presence_cache = val;
+	else
+		chip->sib_irq_status_cache = val;
+
+	return !!(val & (1 << (nr & 15)));
+}
+
+static int ext_cpld_gpio_direction_input(struct gpio_chip *gpio,
+					 unsigned int nr)
+{
+	/* all pins are input pins */
+	return 0;
+}
+
+static int ext_cpld_gpio_to_irq(struct gpio_chip *gpio, unsigned int offset)
+{
+	struct ext_cpld_gpio *chip = container_of(gpio,
+						  struct ext_cpld_gpio, gpio);
+
+	return irq_create_mapping(chip->domain, offset);
+}
+
+static void ext_cpld_irq_mask(struct irq_data *data)
+{
+	struct ext_cpld_gpio *chip = irq_data_get_irq_chip_data(data);
+	struct pmb_boot_cpld_ext *cpld = chip->base;
+	u16 *addr = data->hwirq < 16 ?
+		&cpld->sib_presence_irq_en : &cpld->sib_irq_en;
+	u16 mask = 1 << (data->hwirq & 0x0f);
+
+	if (chip->irq)
+		iowrite16(ioread16(addr) & ~mask, addr);
+
+	if (data->hwirq < 16)
+		chip->sib_presence_irq_enabled &= ~mask;
+	else
+		chip->sib_irq_enabled &= ~mask;
+}
+
+static void ext_cpld_irq_unmask(struct irq_data *data)
+{
+	struct ext_cpld_gpio *chip = irq_data_get_irq_chip_data(data);
+	struct pmb_boot_cpld_ext *cpld = chip->base;
+	u16 *addr = data->hwirq < 16 ?
+		&cpld->sib_presence_irq_en : &cpld->sib_irq_en;
+	u16 mask = 1 << (data->hwirq & 0x0f);
+
+	if (chip->irq)
+		iowrite16(ioread16(addr) | mask, addr);
+
+	if (data->hwirq < 16)
+		chip->sib_presence_irq_enabled |= mask;
+	else
+		chip->sib_irq_enabled |= mask;
+}
+
+static int ext_cpld_irq_set_type(struct irq_data *data, unsigned int type)
+{
+	struct ext_cpld_gpio *chip = irq_data_get_irq_chip_data(data);
+
+	chip->irq_type[data->hwirq] = type & 0x0f;
+
+	return 0;
+}
+
+static void ext_cpld_irq_bus_lock(struct irq_data *data)
+{
+	struct ext_cpld_gpio *chip = irq_data_get_irq_chip_data(data);
+
+	mutex_lock(&chip->irq_lock);
+}
+
+static void ext_cpld_irq_bus_unlock(struct irq_data *data)
+{
+	struct ext_cpld_gpio *chip = irq_data_get_irq_chip_data(data);
+
+	/* Synchronize interrupts to chip */
+
+	mutex_unlock(&chip->irq_lock);
+}
+
+static struct irq_chip ext_cpld_irq_chip = {
+	.name = "gpio-ext-cpld",
+	.irq_mask = ext_cpld_irq_mask,
+	.irq_unmask = ext_cpld_irq_unmask,
+	.irq_set_type = ext_cpld_irq_set_type,
+	.irq_bus_lock = ext_cpld_irq_bus_lock,
+	.irq_bus_sync_unlock = ext_cpld_irq_bus_unlock,
+};
+
+static int ext_cpld_gpio_irq_map(struct irq_domain *domain, unsigned int irq,
+				 irq_hw_number_t hwirq)
+{
+	pr_info("ext_cpld_gpio_irq_map irq %d hwirq %d\n", irq, (int)hwirq);
+
+	irq_set_chip_data(irq, domain->host_data);
+	irq_set_chip(irq, &ext_cpld_irq_chip);
+	irq_set_nested_thread(irq, true);
+
+	irq_set_noprobe(irq);
+
+	return 0;
+}
+
+static const struct irq_domain_ops ext_cpld_gpio_irq_domain_ops = {
+	.map = ext_cpld_gpio_irq_map,
+	.xlate = irq_domain_xlate_twocell,
+};
+
+static void __ext_cpld_gpio_irq_work(struct ext_cpld_gpio *chip,
+				     u16 *datap, u16 *cachep,
+				     unsigned long enabled, int base)
+{
+	u16 data, cache;
+	unsigned int pos;
+
+	cache = *cachep;
+	data = ioread16(datap);
+
+	for_each_set_bit(pos, &enabled, 16) {
+		u16 mask = 1 << pos;
+		u16 bit;
+		int type;
+
+		bit = data & mask;
+		if (bit == (cache & mask))
+			continue;
+
+		type = chip->irq_type[base + pos];
+		/*
+		 * check irq->type for match. Only handle edge triggered
+		 * interrupts; anything else doesn't make sense here.
+		 * TBD: While this is correct for insertion status interrupts,
+		 * we may need to support level triggered interrupts to handle
+		 * the irq status register.
+		 */
+		if (((type & IRQ_TYPE_EDGE_RISING) && bit) ||
+		    ((type & IRQ_TYPE_EDGE_FALLING) && !bit)) {
+			int virq = irq_find_mapping(chip->domain, base + pos);
+
+			handle_nested_irq(virq);
+		}
+	}
+	*cachep = data;
+}
+
+static void ext_cpld_gpio_irq_work(struct ext_cpld_gpio *chip)
+{
+	struct pmb_boot_cpld_ext *cpld = chip->base;
+
+	mutex_lock(&chip->work_lock);
+
+	__ext_cpld_gpio_irq_work(chip, &cpld->sib_presence,
+				 &chip->sib_presence_cache,
+				 chip->sib_presence_irq_enabled,
+				 0);
+
+	__ext_cpld_gpio_irq_work(chip, &cpld->sib_irq_status,
+				 &chip->sib_irq_status_cache,
+				 chip->sib_irq_enabled,
+				 16);
+
+	mutex_unlock(&chip->work_lock);
+}
+
+static irqreturn_t ext_cpld_gpio_irq_handler(int irq, void *data)
+{
+	struct ext_cpld_gpio *chip = data;
+	struct pmb_boot_cpld_ext *cpld = chip->base;
+
+	pr_info("ext_cpld got interrupt %d 0x%x:0x%x\n", irq,
+		ioread16(&cpld->sib_presence),
+		ioread16(&cpld->sib_irq_status));
+
+	ext_cpld_gpio_irq_work(chip);
+
+	return IRQ_HANDLED;
+}
+
+static void ext_cpld_gpio_worker(struct work_struct *work)
+{
+	struct ext_cpld_gpio *chip = container_of(work, struct ext_cpld_gpio,
+						  work.work);
+
+	ext_cpld_gpio_irq_work(chip);
+	schedule_delayed_work(&chip->work, 1);
+}
+
+static int ext_cpld_gpio_irq_setup(struct device *dev,
+				   struct ext_cpld_gpio *chip)
+{
+	int ret;
+
+	chip->domain = irq_domain_add_linear(dev->of_node, EXT_CPLD_NGPIO,
+					     &ext_cpld_gpio_irq_domain_ops,
+					     chip);
+	if (!chip->domain)
+		return -ENOMEM;
+
+	INIT_DELAYED_WORK(&chip->work, ext_cpld_gpio_worker);
+
+	if (chip->irq) {
+		dev_info(dev, "Setting up interrupt %d\n", chip->irq);
+		ret = devm_request_threaded_irq(dev, chip->irq, NULL,
+						ext_cpld_gpio_irq_handler,
+						IRQF_ONESHOT,
+						dev_name(dev), chip);
+		if (ret)
+			goto out_remove_domain;
+	} else {
+		schedule_delayed_work(&chip->work, 1);
+	}
+
+	chip->gpio.to_irq = ext_cpld_gpio_to_irq;
+
+	return 0;
+
+out_remove_domain:
+	irq_domain_remove(chip->domain);
+	return ret;
+}
+
+static void ext_cpld_gpio_irq_teardown(struct device *dev,
+				       struct ext_cpld_gpio *chip)
+{
+	struct pmb_boot_cpld_ext *cpld = chip->base;
+	int i;
+
+	if (chip->irq) {
+		iowrite16(0, &cpld->sib_presence_irq_en);
+		iowrite16(0, &cpld->sib_irq_en);
+	}
+
+	for (i = 0; i < EXT_CPLD_NGPIO; i++) {
+		int irq = irq_find_mapping(chip->domain, i);
+
+		if (irq > 0)
+			irq_dispose_mapping(irq);
+	}
+	irq_domain_remove(chip->domain);
+}
+
+static int ext_cpld_gpio_of_xlate(struct gpio_chip *gpio,
+				  const struct of_phandle_args *gpiospec,
+				  u32 *flags)
+{
+	if (WARN_ON(gpio->of_gpio_n_cells < 2))
+		return -EINVAL;
+
+	if (WARN_ON(gpiospec->args_count < gpio->of_gpio_n_cells))
+		return -EINVAL;
+
+	if (gpiospec->args[0] > gpio->ngpio)
+		return -EINVAL;
+
+	if (flags)
+		*flags = gpiospec->args[1] >> 16;
+
+	return gpiospec->args[0];
+}
+
+static void ext_cpld_gpio_setup(struct ext_cpld_gpio *chip)
+{
+	struct gpio_chip *gpio = &chip->gpio;
+
+	gpio->label = dev_name(chip->dev);
+	gpio->owner = THIS_MODULE;
+	gpio->get = ext_cpld_gpio_get;
+	gpio->direction_input = ext_cpld_gpio_direction_input;
+	gpio->dbg_show = NULL;
+	gpio->base = -1;
+	gpio->ngpio = EXT_CPLD_NGPIO;
+	gpio->can_sleep = 0;
+	gpio->of_node = chip->dev->of_node;
+	gpio->of_xlate = ext_cpld_gpio_of_xlate;
+	gpio->of_gpio_n_cells = 2;
+}
+
+static int ext_cpld_gpio_probe(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct pmb_boot_cpld_ext *cpld;
+	struct ext_cpld_gpio *chip;
+	struct resource *res;
+	int ret;
+
+	chip = devm_kzalloc(dev, sizeof(*chip), GFP_KERNEL);
+	if (!chip)
+		return -ENOMEM;
+
+	chip->dev = dev;
+	platform_set_drvdata(pdev, chip);
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENODEV;
+
+	chip->base = devm_ioremap(dev, res->start, resource_size(res));
+	if (!chip->base)
+		return -ENOMEM;
+
+	cpld = chip->base;
+	chip->sib_presence_cache = ioread16(&cpld->sib_presence);
+
+	mutex_init(&chip->irq_lock);
+	mutex_init(&chip->work_lock);
+	ext_cpld_gpio_setup(chip);
+
+	ret = ext_cpld_gpio_irq_setup(dev, chip);
+	if (ret < 0)
+		return ret;
+
+	ret = gpiochip_add(&chip->gpio);
+	if (ret) {
+		dev_err(dev, "Extended CPLD gpio: Failed to register GPIO\n");
+		goto teardown;
+	}
+	return 0;
+
+teardown:
+	if (chip->domain)
+		ext_cpld_gpio_irq_teardown(dev, chip);
+	return ret;
+}
+
+static int ext_cpld_gpio_remove(struct platform_device *pdev)
+{
+	struct ext_cpld_gpio *chip = platform_get_drvdata(pdev);
+
+	cancel_delayed_work_sync(&chip->work);
+	if (chip->domain)
+		ext_cpld_gpio_irq_teardown(&pdev->dev, chip);
+
+	gpiochip_remove(&chip->gpio);
+
+	return 0;
+}
+
+static const struct of_device_id ext_cpld_gpio_ids[] = {
+	{ .compatible = "jnx,gpio-ptxpmb-ext-cpld", },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, ext_cpld_gpio_ids);
+
+static struct platform_driver ext_cpld_gpio_driver = {
+	.driver = {
+		.name = "gpio-ptxpmb-ext-cpld",
+		.owner  = THIS_MODULE,
+		.of_match_table = ext_cpld_gpio_ids,
+	},
+	.probe = ext_cpld_gpio_probe,
+	.remove = ext_cpld_gpio_remove,
+};
+
+static int __init ext_cpld_gpio_init(void)
+{
+	return platform_driver_register(&ext_cpld_gpio_driver);
+}
+module_init(ext_cpld_gpio_init);
+
+static void __exit ext_cpld_gpio_exit(void)
+{
+	platform_driver_unregister(&ext_cpld_gpio_driver);
+}
+module_exit(ext_cpld_gpio_exit);
+
+MODULE_DESCRIPTION("Extended CPLD FPGA GPIO Driver");
+MODULE_LICENSE("GPL");
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
