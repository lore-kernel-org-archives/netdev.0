From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 3/4] ARM: sa1100/neponset: add ethernet oscillator
Date: Tue, 30 Aug 2016 11:52:45 +0100
Message-ID: <E1beger-000775-Hr@rmk-PC.armlinux.org.uk>
References: <20160830105117.GM1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Nicolas Pitre <nico@fluxnic.net>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:36586 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758030AbcH3Kwv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 06:52:51 -0400
In-Reply-To: <20160830105117.GM1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the clock structure for the external SMC91x ethernet oscillator.
This oscillator has an enable signal which allows the oscillator to be
placed in low power mode when not required.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 arch/arm/mach-sa1100/neponset.c | 42 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/arch/arm/mach-sa1100/neponset.c b/arch/arm/mach-sa1100/neponset.c
index bff6efdfaeaf..700659cadebb 100644
--- a/arch/arm/mach-sa1100/neponset.c
+++ b/arch/arm/mach-sa1100/neponset.c
@@ -1,6 +1,8 @@
 /*
  * linux/arch/arm/mach-sa1100/neponset.c
  */
+#include <linux/clk-provider.h>
+#include <linux/clkdev.h>
 #include <linux/err.h>
 #include <linux/gpio/driver.h>
 #include <linux/gpio/machine.h>
@@ -78,6 +80,9 @@ struct neponset_drvdata {
 	struct platform_device *smc91x;
 	unsigned irq_base;
 	struct gpio_chip *gpio[4];
+	struct clk_hw *enet_osc_ck;
+	struct clk_hw *enet_osc_gate;
+	struct clk_lookup *enet_osc_cl;
 };
 
 static struct gpiod_lookup_table neponset_uart1_gpio_table = {
@@ -217,6 +222,38 @@ static int neponset_init_gpio(struct gpio_chip **gcp,
 	return 0;
 }
 
+static int neponset_init_enet(struct device *dev, struct neponset_drvdata *d)
+{
+	int ret;
+
+	d->enet_osc_ck = clk_hw_register_fixed_rate(dev, "nep_enet_osc",
+						    NULL, 0, 20000000);
+	if (IS_ERR(d->enet_osc_ck))
+		return PTR_ERR(d->enet_osc_ck);
+
+	d->enet_osc_gate = clk_hw_register_gpio_gate(dev, "nep_enet_gate",
+						     "nep_enet_osc",
+						     d->gpio[0]->base + 3,
+						     false, 0);
+	if (IS_ERR(d->enet_osc_gate)) {
+		ret = PTR_ERR(d->enet_osc_gate);
+		goto err;
+	}
+
+	d->enet_osc_cl = clkdev_hw_create(d->enet_osc_gate, NULL, "smc91x.0");
+	if (!d->enet_osc_cl) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	return 0;
+
+err:
+	if (d->enet_osc_ck)
+		clk_hw_unregister_fixed_rate(d->enet_osc_ck);
+	return ret;
+}
+
 static struct sa1111_platform_data sa1111_info = {
 	.disable_devs	= SA1111_DEVID_PS2_MSE,
 };
@@ -333,6 +370,8 @@ static int neponset_probe(struct platform_device *dev)
 	gpiod_add_lookup_table(&neponset_uart3_gpio_table);
 	gpiod_add_lookup_table(&neponset_pcmcia_table);
 
+	neponset_init_enet(&dev->dev, d);
+
 	/*
 	 * We would set IRQ_GPIO25 to be a wake-up IRQ, but unfortunately
 	 * something on the Neponset activates this IRQ on sleep (eth?)
@@ -385,6 +424,9 @@ static int neponset_remove(struct platform_device *dev)
 	if (!IS_ERR(d->smc91x))
 		platform_device_unregister(d->smc91x);
 
+	clkdev_drop(d->enet_osc_cl);
+	clk_hw_unregister_fixed_rate(d->enet_osc_ck);
+
 	gpiod_remove_lookup_table(&neponset_pcmcia_table);
 	gpiod_remove_lookup_table(&neponset_uart3_gpio_table);
 	gpiod_remove_lookup_table(&neponset_uart1_gpio_table);
-- 
2.1.0
