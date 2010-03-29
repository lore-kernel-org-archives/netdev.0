From: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Subject: [PATCH 3/3] gpio: add support for Janz VMOD-TTL Digital IO module
Date: Mon, 29 Mar 2010 09:58:52 -0700
Message-ID: <1269881932-3803-4-git-send-email-iws@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <>
References: <>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The Janz VMOD-TTL is a MODULbus daughterboard which fits onto any MODULbus
carrier board. It essentially consists of some various logic and a Zilog
Z8536 CIO Counter/Timer and Parallel IO Unit.

The board must be physically configured with jumpers to enable a user to
drive output signals. I am only interested in outputs, so I have made this
driver as simple as possible. It only supports a very minimal subset of the
features provided by the Z8536 chip.

Signed-off-by: Ira W. Snyder <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
---
 drivers/gpio/Kconfig    |   10 ++
 drivers/gpio/Makefile   |    1 +
 drivers/gpio/janz-ttl.c |  257 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 268 insertions(+), 0 deletions(-)
 create mode 100644 drivers/gpio/janz-ttl.c

diff --git a/drivers/gpio/Kconfig b/drivers/gpio/Kconfig
index dd10eb8..1f38ff3 100644
--- a/drivers/gpio/Kconfig
+++ b/drivers/gpio/Kconfig
@@ -318,4 +318,14 @@ config GPIO_UCB1400
 	  To compile this driver as a module, choose M here: the
 	  module will be called ucb1400_gpio.
 
+comment "MODULbus GPIO expanders:"
+
+config GPIO_JANZ_TTL
+	tristate "Janz VMOD-TTL Digital IO Module"
+	depends on MFD_JANZ_CMODIO
+	help
+	  This enables support for the Janz VMOD-TTL Digital IO module.
+	  This driver provides support for driving the pins in output
+	  mode only. Input mode is not supported.
+
 endif
diff --git a/drivers/gpio/Makefile b/drivers/gpio/Makefile
index d3226d3..94a96c5 100644
--- a/drivers/gpio/Makefile
+++ b/drivers/gpio/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_GPIO_WM8350)	+= wm8350-gpiolib.o
 obj-$(CONFIG_GPIO_WM8994)	+= wm8994-gpio.o
 obj-$(CONFIG_GPIO_SCH)		+= sch_gpio.o
 obj-$(CONFIG_GPIO_RDC321X)	+= rdc321x-gpio.o
+obj-$(CONFIG_GPIO_JANZ_TTL)	+= janz-ttl.o
diff --git a/drivers/gpio/janz-ttl.c b/drivers/gpio/janz-ttl.c
new file mode 100644
index 0000000..d97eeda
--- /dev/null
+++ b/drivers/gpio/janz-ttl.c
@@ -0,0 +1,257 @@
+/*
+ * Janz MODULbus VMOD-TTL GPIO Driver
+ *
+ * Copyright (c) 2010 Ira W. Snyder <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
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
+#include <linux/interrupt.h>
+#include <linux/delay.h>
+#include <linux/platform_device.h>
+#include <linux/io.h>
+#include <linux/gpio.h>
+
+#include <linux/mfd/janz.h>
+
+#define DRV_NAME "janz-ttl"
+
+#define PORTA_DIRECTION		0x23
+#define PORTB_DIRECTION		0x2B
+#define PORTC_DIRECTION		0x06
+#define PORTA_IOCTL		0x24
+#define PORTB_IOCTL		0x2C
+#define PORTC_IOCTL		0x07
+
+#define MASTER_INT_CTL		0x00
+#define MASTER_CONF_CTL		0x01
+
+#define CONF_PAE		(1 << 2)
+#define CONF_PBE		(1 << 7)
+#define CONF_PCE		(1 << 4)
+
+struct ttl_control_regs {
+	__be16 portc;
+	__be16 portb;
+	__be16 porta;
+	__be16 control;
+};
+
+struct ttl_module {
+	struct gpio_chip gpio;
+
+	/* base address of registers */
+	struct ttl_control_regs __iomem *regs;
+
+	u8 portc_shadow;
+	u8 portb_shadow;
+	u8 porta_shadow;
+
+	spinlock_t lock;
+};
+
+static int ttl_get_value(struct gpio_chip *gpio, unsigned offset)
+{
+	struct ttl_module *mod = dev_get_drvdata(gpio->dev);
+	u8 *shadow;
+	int ret;
+
+	if (offset < 8) {
+		shadow = &mod->porta_shadow;
+	} else if (offset < 16) {
+		shadow = &mod->portb_shadow;
+		offset -= 8;
+	} else {
+		shadow = &mod->portc_shadow;
+		offset -= 16;
+	}
+
+	spin_lock(&mod->lock);
+	ret = *shadow & (1 << offset);
+	spin_unlock(&mod->lock);
+	return ret;
+}
+
+static void ttl_set_value(struct gpio_chip *gpio, unsigned offset, int value)
+{
+	struct ttl_module *mod = dev_get_drvdata(gpio->dev);
+	void __iomem *port;
+	u8 *shadow;
+
+	if (offset < 8) {
+		port = &mod->regs->porta;
+		shadow = &mod->porta_shadow;
+	} else if (offset < 16) {
+		port = &mod->regs->portb;
+		shadow = &mod->portb_shadow;
+		offset -= 8;
+	} else {
+		port = &mod->regs->portc;
+		shadow = &mod->portc_shadow;
+		offset -= 16;
+	}
+
+	spin_lock(&mod->lock);
+	if (value)
+		*shadow |= (1 << offset);
+	else
+		*shadow &= ~(1 << offset);
+
+	iowrite16be(*shadow, port);
+	spin_unlock(&mod->lock);
+}
+
+static void __devinit ttl_write_reg(struct ttl_module *mod, u8 reg, u16 val)
+{
+	iowrite16be(reg, &mod->regs->control);
+	iowrite16be(val, &mod->regs->control);
+}
+
+static void __devinit ttl_setup_device(struct ttl_module *mod)
+{
+	/* reset the device to a known state */
+	iowrite16be(0x0000, &mod->regs->control);
+	iowrite16be(0x0001, &mod->regs->control);
+	iowrite16be(0x0000, &mod->regs->control);
+
+	/* put all ports in open-drain mode */
+	ttl_write_reg(mod, PORTA_IOCTL, 0x00ff);
+	ttl_write_reg(mod, PORTB_IOCTL, 0x00ff);
+	ttl_write_reg(mod, PORTC_IOCTL, 0x000f);
+
+	/* set all ports as outputs */
+	ttl_write_reg(mod, PORTA_DIRECTION, 0x0000);
+	ttl_write_reg(mod, PORTB_DIRECTION, 0x0000);
+	ttl_write_reg(mod, PORTC_DIRECTION, 0x0000);
+
+	/* set all ports to drive zeroes */
+	iowrite16be(0x0000, &mod->regs->porta);
+	iowrite16be(0x0000, &mod->regs->portb);
+	iowrite16be(0x0000, &mod->regs->portc);
+
+	/* enable all ports */
+	ttl_write_reg(mod, MASTER_CONF_CTL, CONF_PAE | CONF_PBE | CONF_PCE);
+}
+
+static int __devinit ttl_probe(struct platform_device *pdev)
+{
+	struct janz_platform_data *pdata;
+	struct device *dev = &pdev->dev;
+	struct ttl_module *mod;
+	struct gpio_chip *gpio;
+	struct resource *res;
+	int ret;
+
+	pdata = pdev->dev.platform_data;
+	if (!pdata) {
+		dev_err(dev, "no platform data\n");
+		ret = -ENXIO;
+		goto out_return;
+	}
+
+	mod = kzalloc(sizeof(*mod), GFP_KERNEL);
+	if (!mod) {
+		dev_err(dev, "unable to allocate private data\n");
+		ret = -ENOMEM;
+		goto out_return;
+	}
+
+	platform_set_drvdata(pdev, mod);
+	spin_lock_init(&mod->lock);
+
+	/* get access to the MODULbus registers for this module */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(dev, "MODULbus registers not found\n");
+		ret = -ENODEV;
+		goto out_free_mod;
+	}
+
+	mod->regs = ioremap(res->start, resource_size(res));
+	if (!mod->regs) {
+		dev_err(dev, "MODULbus registers not ioremap\n");
+		ret = -ENOMEM;
+		goto out_free_mod;
+	}
+
+	ttl_setup_device(mod);
+
+	/* Initialize the GPIO data structures */
+	gpio = &mod->gpio;
+	gpio->dev = &pdev->dev;
+	gpio->label = pdev->name;
+	gpio->get = ttl_get_value;
+	gpio->set = ttl_set_value;
+	gpio->owner = THIS_MODULE;
+
+	/* request dynamic allocation */
+	gpio->base = -1;
+	gpio->ngpio = 20;
+
+	ret = gpiochip_add(gpio);
+	if (ret) {
+		dev_err(dev, "unable to add GPIO chip\n");
+		goto out_iounmap_regs;
+	}
+
+	dev_info(&pdev->dev, "module %d: registered GPIO device\n",
+			     pdata->modno);
+	return 0;
+
+out_iounmap_regs:
+	iounmap(mod->regs);
+out_free_mod:
+	kfree(mod);
+out_return:
+	return ret;
+}
+
+static int __devexit ttl_remove(struct platform_device *pdev)
+{
+	struct ttl_module *mod = platform_get_drvdata(pdev);
+	struct device *dev = &pdev->dev;
+	int ret;
+
+	ret = gpiochip_remove(&mod->gpio);
+	if (ret) {
+		dev_err(dev, "unable to remove GPIO chip\n");
+		return ret;
+	}
+
+	iounmap(mod->regs);
+	kfree(mod);
+	return 0;
+}
+
+static struct platform_driver ttl_driver = {
+	.driver		= {
+		.name	= DRV_NAME,
+		.owner	= THIS_MODULE,
+	},
+	.probe		= ttl_probe,
+	.remove		= __devexit_p(ttl_remove),
+};
+
+static int __init ttl_init(void)
+{
+	return platform_driver_register(&ttl_driver);
+}
+
+static void __exit ttl_exit(void)
+{
+	platform_driver_unregister(&ttl_driver);
+}
+
+MODULE_AUTHOR("Ira W. Snyder <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>");
+MODULE_DESCRIPTION("Janz MODULbus VMOD-TTL Driver");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:janz-ttl");
+
+module_init(ttl_init);
+module_exit(ttl_exit);
-- 
1.5.4.3
