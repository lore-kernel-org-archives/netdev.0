From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 2/4] ar7: implement clock API
Date: Wed, 27 Jan 2010 09:10:06 +0100
Message-ID: <201001270910.06224.florian@openwrt.org>
References: <201001032117.07022.florian@openwrt.org> <201001121015.27867.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Wim Van Sebroeck <wim@iguana.be>, ralf@linux-mips.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:41031 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab0A0IK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 03:10:27 -0500
Received: by ewy19 with SMTP id 19so143309ewy.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 00:10:25 -0800 (PST)
In-Reply-To: <201001121015.27867.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the ar7 clock code implement the
Linux clk API. Drivers using the various clocks
available in the SoC are updated accordingly.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
Acked-by: Wim Van Sebroeck <wim@iguana.be>
---
diff --git a/arch/mips/ar7/clock.c b/arch/mips/ar7/clock.c
index cc65c8e..fc0e715 100644
--- a/arch/mips/ar7/clock.c
+++ b/arch/mips/ar7/clock.c
@@ -1,6 +1,7 @@
 /*
  * Copyright (C) 2007 Felix Fietkau <nbd@openwrt.org>
  * Copyright (C) 2007 Eugene Konev <ejka@openwrt.org>
+ * Copyright (C) 2009 Florian Fainelli <florian@openwrt.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -24,6 +25,8 @@
 #include <linux/delay.h>
 #include <linux/gcd.h>
 #include <linux/io.h>
+#include <linux/err.h>
+#include <linux/clk.h>
 
 #include <asm/addrspace.h>
 #include <asm/mach-ar7/ar7.h>
@@ -94,12 +97,16 @@ struct tnetd7200_clocks {
 	struct tnetd7200_clock usb;
 };
 
-int ar7_cpu_clock = 150000000;
-EXPORT_SYMBOL(ar7_cpu_clock);
-int ar7_bus_clock = 125000000;
-EXPORT_SYMBOL(ar7_bus_clock);
-int ar7_dsp_clock;
-EXPORT_SYMBOL(ar7_dsp_clock);
+static struct clk bus_clk = {
+	.rate	= 125000000,
+};
+
+static struct clk cpu_clk = {
+	.rate	= 150000000,
+};
+
+static struct clk dsp_clk;
+static struct clk vbus_clk;
 
 static void approximate(int base, int target, int *prediv,
 			int *postdiv, int *mul)
@@ -185,7 +192,7 @@ static int tnetd7300_get_clock(u32 shift, struct tnetd7300_clock *clock,
 		base_clock = AR7_XTAL_CLOCK;
 		break;
 	case BOOT_PLL_SOURCE_CPU:
-		base_clock = ar7_cpu_clock;
+		base_clock = cpu_clk.rate;
 		break;
 	}
 
@@ -212,11 +219,11 @@ static void tnetd7300_set_clock(u32 shift, struct tnetd7300_clock *clock,
 	u32 *bootcr, u32 frequency)
 {
 	int prediv, postdiv, mul;
-	int base_clock = ar7_bus_clock;
+	int base_clock = bus_clk.rate;
 
 	switch ((*bootcr & (BOOT_PLL_SOURCE_MASK << shift)) >> shift) {
 	case BOOT_PLL_SOURCE_BUS:
-		base_clock = ar7_bus_clock;
+		base_clock = bus_clk.rate;
 		break;
 	case BOOT_PLL_SOURCE_REF:
 		base_clock = AR7_REF_CLOCK;
@@ -225,7 +232,7 @@ static void tnetd7300_set_clock(u32 shift, struct tnetd7300_clock *clock,
 		base_clock = AR7_XTAL_CLOCK;
 		break;
 	case BOOT_PLL_SOURCE_CPU:
-		base_clock = ar7_cpu_clock;
+		base_clock = cpu_clk.rate;
 		break;
 	}
 
@@ -247,18 +254,18 @@ static void __init tnetd7300_init_clocks(void)
 					ioremap_nocache(UR8_REGS_CLOCKS,
 					sizeof(struct tnetd7300_clocks));
 
-	ar7_bus_clock = tnetd7300_get_clock(BUS_PLL_SOURCE_SHIFT,
+	bus_clk.rate = tnetd7300_get_clock(BUS_PLL_SOURCE_SHIFT,
 		&clocks->bus, bootcr, AR7_AFE_CLOCK);
 
 	if (*bootcr & BOOT_PLL_ASYNC_MODE)
-		ar7_cpu_clock = tnetd7300_get_clock(CPU_PLL_SOURCE_SHIFT,
+		cpu_clk.rate = tnetd7300_get_clock(CPU_PLL_SOURCE_SHIFT,
 			&clocks->cpu, bootcr, AR7_AFE_CLOCK);
 	else
-		ar7_cpu_clock = ar7_bus_clock;
+		cpu_clk.rate = bus_clk.rate;
 
-	if (ar7_dsp_clock == 250000000)
+	if (dsp_clk.rate == 250000000)
 		tnetd7300_set_clock(DSP_PLL_SOURCE_SHIFT, &clocks->dsp,
-			bootcr, ar7_dsp_clock);
+			bootcr, dsp_clk.rate);
 
 	iounmap(clocks);
 	iounmap(bootcr);
@@ -343,20 +350,20 @@ static void __init tnetd7200_init_clocks(void)
 		printk(KERN_INFO "Clocks: Setting DSP clock\n");
 		calculate(dsp_base, TNETD7200_DEF_DSP_CLK,
 			&dsp_prediv, &dsp_postdiv, &dsp_mul);
-		ar7_bus_clock =
+		bus_clk.rate =
 			((dsp_base / dsp_prediv) * dsp_mul) / dsp_postdiv;
 		tnetd7200_set_clock(dsp_base, &clocks->dsp,
 			dsp_prediv, dsp_postdiv * 2, dsp_postdiv, dsp_mul * 2,
-			ar7_bus_clock);
+			bus_clk.rate);
 
 		printk(KERN_INFO "Clocks: Setting CPU clock\n");
 		calculate(cpu_base, TNETD7200_DEF_CPU_CLK, &cpu_prediv,
 			&cpu_postdiv, &cpu_mul);
-		ar7_cpu_clock =
+		cpu_clk.rate =
 			((cpu_base / cpu_prediv) * cpu_mul) / cpu_postdiv;
 		tnetd7200_set_clock(cpu_base, &clocks->cpu,
 			cpu_prediv, cpu_postdiv, -1, cpu_mul,
-			ar7_cpu_clock);
+			cpu_clk.rate);
 
 	} else
 		if (*bootcr & BOOT_PLL_2TO1_MODE) {
@@ -365,48 +372,90 @@ static void __init tnetd7200_init_clocks(void)
 			printk(KERN_INFO "Clocks: Setting CPU clock\n");
 			calculate(cpu_base, TNETD7200_DEF_CPU_CLK, &cpu_prediv,
 				&cpu_postdiv, &cpu_mul);
-			ar7_cpu_clock = ((cpu_base / cpu_prediv) * cpu_mul)
+			cpu_clk.rate = ((cpu_base / cpu_prediv) * cpu_mul)
 								/ cpu_postdiv;
 			tnetd7200_set_clock(cpu_base, &clocks->cpu,
 				cpu_prediv, cpu_postdiv, -1, cpu_mul,
-				ar7_cpu_clock);
+				cpu_clk.rate);
 
 			printk(KERN_INFO "Clocks: Setting DSP clock\n");
 			calculate(dsp_base, TNETD7200_DEF_DSP_CLK, &dsp_prediv,
 				&dsp_postdiv, &dsp_mul);
-			ar7_bus_clock = ar7_cpu_clock / 2;
+			bus_clk.rate = cpu_clk.rate / 2;
 			tnetd7200_set_clock(dsp_base, &clocks->dsp,
 				dsp_prediv, dsp_postdiv * 2, dsp_postdiv,
-				dsp_mul * 2, ar7_bus_clock);
+				dsp_mul * 2, bus_clk.rate);
 		} else {
 			printk(KERN_INFO "Clocks: Sync 1:1 mode\n");
 
 			printk(KERN_INFO "Clocks: Setting DSP clock\n");
 			calculate(dsp_base, TNETD7200_DEF_DSP_CLK, &dsp_prediv,
 				&dsp_postdiv, &dsp_mul);
-			ar7_bus_clock = ((dsp_base / dsp_prediv) * dsp_mul)
+			bus_clk.rate = ((dsp_base / dsp_prediv) * dsp_mul)
 								/ dsp_postdiv;
 			tnetd7200_set_clock(dsp_base, &clocks->dsp,
 				dsp_prediv, dsp_postdiv * 2, dsp_postdiv,
-				dsp_mul * 2, ar7_bus_clock);
+				dsp_mul * 2, bus_clk.rate);
 
-			ar7_cpu_clock = ar7_bus_clock;
+			cpu_clk.rate = bus_clk.rate;
 		}
 
 	printk(KERN_INFO "Clocks: Setting USB clock\n");
-	usb_base = ar7_bus_clock;
+	usb_base = bus_clk.rate;
 	calculate(usb_base, TNETD7200_DEF_USB_CLK, &usb_prediv,
 		&usb_postdiv, &usb_mul);
 	tnetd7200_set_clock(usb_base, &clocks->usb,
 		usb_prediv, usb_postdiv, -1, usb_mul,
 		TNETD7200_DEF_USB_CLK);
 
-	ar7_dsp_clock = ar7_cpu_clock;
+	dsp_clk.rate = cpu_clk.rate;
 
 	iounmap(clocks);
 	iounmap(bootcr);
 }
 
+/*
+ * Linux clock API
+ */
+int clk_enable(struct clk *clk)
+{
+	return 0;
+}
+EXPORT_SYMBOL(clk_enable);
+
+void clk_disable(struct clk *clk)
+{
+}
+EXPORT_SYMBOL(clk_disable);
+
+unsigned long clk_get_rate(struct clk *clk)
+{
+	return clk->rate;
+}
+EXPORT_SYMBOL(clk_get_rate);
+
+struct clk *clk_get(struct device *dev, const char *id)
+{
+	if (!strcmp(id, "bus"))
+		return &bus_clk;
+	/* cpmac and vbus share the same rate */
+	if (!strcmp(id, "cpmac"))
+		return &vbus_clk;
+	if (!strcmp(id, "cpu"))
+		return &cpu_clk;
+	if (!strcmp(id, "dsp"));
+		return &dsp_clk;
+	if (!strcmp(id, "vbus"))
+		return &vbus_clk;
+	return ERR_PTR(-ENOENT);
+}
+EXPORT_SYMBOL(clk_get);
+
+void clk_put(struct clk *clk)
+{
+}
+EXPORT_SYMBOL(clk_put);
+
 int __init ar7_init_clocks(void)
 {
 	switch (ar7_chip_id()) {
@@ -415,12 +464,14 @@ int __init ar7_init_clocks(void)
 		tnetd7200_init_clocks();
 		break;
 	case AR7_CHIP_7300:
-		ar7_dsp_clock = tnetd7300_dsp_clock();
+		dsp_clk.rate = tnetd7300_dsp_clock();
 		tnetd7300_init_clocks();
 		break;
 	default:
 		break;
 	}
+	/* adjust vbus clock rate */
+	vbus_clk.rate = bus_clk.rate / 2;
 
 	return 0;
 }
diff --git a/arch/mips/ar7/platform.c b/arch/mips/ar7/platform.c
index acbe147..c591f69 100644
--- a/arch/mips/ar7/platform.c
+++ b/arch/mips/ar7/platform.c
@@ -35,6 +35,7 @@
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/gpio.h>
+#include <linux/clk.h>
 
 #include <asm/addrspace.h>
 #include <asm/mach-ar7/ar7.h>
@@ -507,13 +508,18 @@ static int __init ar7_register_devices(void)
 	u32 *bootcr, val;
 #ifdef CONFIG_SERIAL_8250
 	static struct uart_port uart_port[2] __initdata;
+	struct clk *bus_clk;
 
 	memset(uart_port, 0, sizeof(struct uart_port) * 2);
 
+	bus_clk = clk_get(NULL, "bus");
+	if (IS_ERR(bus_clk))
+		panic("unable to get bus clk\n");
+
 	uart_port[0].type = PORT_16550A;
 	uart_port[0].line = 0;
 	uart_port[0].irq = AR7_IRQ_UART0;
-	uart_port[0].uartclk = ar7_bus_freq() / 2;
+	uart_port[0].uartclk = clk_get_rate(bus_clk) / 2;
 	uart_port[0].iotype = UPIO_MEM32;
 	uart_port[0].mapbase = AR7_REGS_UART0;
 	uart_port[0].membase = ioremap(uart_port[0].mapbase, 256);
@@ -528,7 +534,7 @@ static int __init ar7_register_devices(void)
 		uart_port[1].type = PORT_16550A;
 		uart_port[1].line = 1;
 		uart_port[1].irq = AR7_IRQ_UART1;
-		uart_port[1].uartclk = ar7_bus_freq() / 2;
+		uart_port[1].uartclk = clk_get_rate(bus_clk) / 2;
 		uart_port[1].iotype = UPIO_MEM32;
 		uart_port[1].mapbase = UR8_REGS_UART1;
 		uart_port[1].membase = ioremap(uart_port[1].mapbase, 256);
diff --git a/arch/mips/ar7/time.c b/arch/mips/ar7/time.c
index a1fba89..5fb8a01 100644
--- a/arch/mips/ar7/time.c
+++ b/arch/mips/ar7/time.c
@@ -20,11 +20,21 @@
 
 #include <linux/init.h>
 #include <linux/time.h>
+#include <linux/err.h>
+#include <linux/clk.h>
 
 #include <asm/time.h>
 #include <asm/mach-ar7/ar7.h>
 
 void __init plat_time_init(void)
 {
-	mips_hpt_frequency = ar7_cpu_freq() / 2;
+	struct clk *cpu_clk;
+
+	cpu_clk = clk_get(NULL, "cpu");
+	if (IS_ERR(cpu_clk)) {
+		printk(KERN_ERR "unable to get cpu clock\n");
+		return;
+	}
+
+	mips_hpt_frequency = clk_get_rate(cpu_clk) / 2;
 }
diff --git a/arch/mips/include/asm/mach-ar7/ar7.h b/arch/mips/include/asm/mach-ar7/ar7.h
index 21cbbc7..f1cf389 100644
--- a/arch/mips/include/asm/mach-ar7/ar7.h
+++ b/arch/mips/include/asm/mach-ar7/ar7.h
@@ -105,26 +105,9 @@ static inline u8 ar7_chip_rev(void)
 	return (readl((void *)KSEG1ADDR(AR7_REGS_GPIO + 0x14)) >> 16) & 0xff;
 }
 
-static inline int ar7_cpu_freq(void)
-{
-	return ar7_cpu_clock;
-}
-
-static inline int ar7_bus_freq(void)
-{
-	return ar7_bus_clock;
-}
-
-static inline int ar7_vbus_freq(void)
-{
-	return ar7_bus_clock / 2;
-}
-#define ar7_cpmac_freq ar7_vbus_freq
-
-static inline int ar7_dsp_freq(void)
-{
-	return ar7_dsp_clock;
-}
+struct clk {
+	unsigned int	rate;
+};
 
 static inline int ar7_has_high_cpmac(void)
 {
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 8d0be26..bf2072e 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -36,6 +36,7 @@
 #include <linux/phy_fixed.h>
 #include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
+#include <linux/clk.h>
 #include <asm/gpio.h>
 #include <asm/atomic.h>
 
@@ -294,9 +295,16 @@ static int cpmac_mdio_write(struct mii_bus *bus, int phy_id,
 
 static int cpmac_mdio_reset(struct mii_bus *bus)
 {
+	struct clk *cpmac_clk;
+
+	cpmac_clk = clk_get(&bus->dev, "cpmac");
+	if (IS_ERR(cpmac_clk)) {
+		printk(KERN_ERR "unable to get cpmac clock\n");
+		return -1;
+	}
 	ar7_device_reset(AR7_RESET_BIT_MDIO);
 	cpmac_write(bus->priv, CPMAC_MDIO_CONTROL, MDIOC_ENABLE |
-		    MDIOC_CLKDIV(ar7_cpmac_freq() / 2200000 - 1));
+		    MDIOC_CLKDIV(clk_get_rate(cpmac_clk) / 2200000 - 1));
 	return 0;
 }
 
diff --git a/drivers/watchdog/ar7_wdt.c b/drivers/watchdog/ar7_wdt.c
index 2e94b71..2bb95cd 100644
--- a/drivers/watchdog/ar7_wdt.c
+++ b/drivers/watchdog/ar7_wdt.c
@@ -34,6 +34,7 @@
 #include <linux/ioport.h>
 #include <linux/io.h>
 #include <linux/uaccess.h>
+#include <linux/clk.h>
 
 #include <asm/addrspace.h>
 #include <asm/mach-ar7/ar7.h>
@@ -80,6 +81,8 @@ static struct resource *ar7_regs_wdt;
 /* Pointer to the remapped WDT IO space */
 static struct ar7_wdt *ar7_wdt;
 
+static struct clk *vbus_clk;
+
 static void ar7_wdt_kick(u32 value)
 {
 	WRITE_REG(ar7_wdt->kick_lock, 0x5555);
@@ -138,17 +141,19 @@ static void ar7_wdt_disable(u32 value)
 static void ar7_wdt_update_margin(int new_margin)
 {
 	u32 change;
+	u32 vbus_rate;
 
-	change = new_margin * (ar7_vbus_freq() / prescale_value);
+	vbus_rate = clk_get_rate(vbus_clk);
+	change = new_margin * (vbus_rate / prescale_value);
 	if (change < 1)
 		change = 1;
 	if (change > 0xffff)
 		change = 0xffff;
 	ar7_wdt_change(change);
-	margin = change * prescale_value / ar7_vbus_freq();
+	margin = change * prescale_value / vbus_rate;
 	printk(KERN_INFO DRVNAME
 	       ": timer margin %d seconds (prescale %d, change %d, freq %d)\n",
-	       margin, prescale_value, change, ar7_vbus_freq());
+	       margin, prescale_value, change, vbus_rate);
 }
 
 static void ar7_wdt_enable_wdt(void)
@@ -298,6 +303,13 @@ static int __devinit ar7_wdt_probe(struct platform_device *pdev)
 		goto out_mem_region;
 	}
 
+	vbus_clk = clk_get(NULL, "vbus");
+	if (IS_ERR(vbus_clk)) {
+		printk(KERN_ERR DRVNAME ": could not get vbus clock\n");
+		rc = PTR_ERR(vbus_clk);
+		goto out_mem_region;
+	}
+
 	ar7_wdt_disable_wdt();
 	ar7_wdt_prescale(prescale_value);
 	ar7_wdt_update_margin(margin);
