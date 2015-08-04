From: Alban Bedel <albeu@free.fr>
Subject: [PATCH v3] MIPS: Remove all the uses of custom gpio.h
Date: Tue,  4 Aug 2015 10:50:52 +0200
Message-ID: <1438678305-25524-1-git-send-email-albeu@free.fr>
Cc: Alban Bedel <albeu@free.fr>, Ralf Baechle <ralf@linux-mips.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Florian Fainelli <florian@openwrt.org>,
	Manuel Lauss <manuel.lauss@gmail.com>,
	Joe Perches <joe@perches.com>,
	Daniel Walter <dwalter@google.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Huacai Chen <chenhc@lemote.com>,
	James Hartley <james.hartley@imgtec.com>,
	Andrew Bresticker <abrestic@chromium.org>,
	Paul Burton <paul.burton@imgtec.com>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Brian Norris <computersforpeace@gmail.com>,
	Varka Bhadram <varkabhadram@gmail.com>,
	Wolfram Sang <wsa@the-dreams.de>,
	Randy Dunla
To: linux-mips@linux-mips.org
Return-path: <linux-input-owner@vger.kernel.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently CONFIG_ARCH_HAVE_CUSTOM_GPIO_H is defined for all MIPS
machines, and each machine type provides its own gpio.h. However
only a handful really implement the GPIO API, most just forward
everythings to gpiolib.

The Alchemy machine is notable as it provides a system to allow
implementing the GPIO API at the board level. But it is not used by
any board currently supported, so it can also be removed.

For most machine types we can just remove the custom gpio.h, as well
as the custom wrappers if some exists. Some of the code found in
the wrappers must be moved to the respective GPIO driver.

A few more fixes are need in some drivers as they rely on linux/gpio.h
to provides some machine specific definitions, or used asm/gpio.h
instead of linux/gpio.h for the gpio API.

Signed-off-by: Alban Bedel <albeu@free.fr>
---

This patch is based on my previous serie:
"MIPS: ath79: Move the GPIO driver to drivers/gpio".

It supercede my previous patch named:
"MIPS: Remove most of the custom gpio.h"

Changelog:
v3: * Add the missing includes to fix the build on jz4740 machines
v2: * Don't remove AR7_GPIO_MAX and TITAN_GPIO_MAX, that's for another
      patch
v1: * Fixed gpio_to_irq on jz4740 and rb532
    * Cleaned up alchemy as well
    * Removed asm/gpio.h

For testing I tried to build all mips defconfig, however my toolchain
couldn't handle a few configs: ip28 malta_qemu_32r6 maltasmvp_eva
sead3micro. If somebody can test these that would be more than welcome.

Now a few stats about the state of CONFIG_ARCH_HAVE_CUSTOM_GPIO_H
after appling this patch. Of the 31 supportd arch, 15 still have
asm/gpio.h, of these 9 are just a "#warning Include linux/gpio.h
instead of asm/gpio.h". So we have 6 arch left: arm, avr32, blackfin,
m68k, sh and unicore32. But only m68k and unicore32 really provides
custom wrappers, all the others only forward to gpiolib.

On the drivers side we only have 13 occurences of '#include
<asm/gpio.h>' left, mostly in drivers used on ARM SoC.

So the work left to phase out the legacy GPIO is really not that much
anymore.

Alban
---
 arch/mips/Kconfig                               |   1 -
 arch/mips/alchemy/Kconfig                       |   7 --
 arch/mips/alchemy/board-gpr.c                   |   1 +
 arch/mips/alchemy/board-mtx1.c                  |   1 +
 arch/mips/alchemy/common/Makefile               |   7 +-
 arch/mips/alchemy/devboards/db1000.c            |   1 +
 arch/mips/alchemy/devboards/db1300.c            |   1 +
 arch/mips/alchemy/devboards/db1550.c            |   1 +
 arch/mips/alchemy/devboards/pm.c                |   2 +-
 arch/mips/ar7/gpio.c                            |   5 +-
 arch/mips/ar7/platform.c                        |   1 -
 arch/mips/ar7/setup.c                           |   1 -
 arch/mips/include/asm/gpio.h                    |   6 -
 arch/mips/include/asm/mach-ar7/ar7.h            |   4 +
 arch/mips/include/asm/mach-ar7/gpio.h           |  41 -------
 arch/mips/include/asm/mach-ath25/gpio.h         |  16 ---
 arch/mips/include/asm/mach-ath79/gpio.h         |  26 -----
 arch/mips/include/asm/mach-au1x00/gpio-au1000.h | 148 ++----------------------
 arch/mips/include/asm/mach-au1x00/gpio.h        |  86 --------------
 arch/mips/include/asm/mach-bcm47xx/gpio.h       |  17 ---
 arch/mips/include/asm/mach-bcm63xx/gpio.h       |  15 ---
 arch/mips/include/asm/mach-cavium-octeon/gpio.h |  21 ----
 arch/mips/include/asm/mach-generic/gpio.h       |  21 ----
 arch/mips/include/asm/mach-jz4740/gpio.h        |   2 -
 arch/mips/include/asm/mach-lantiq/gpio.h        |  13 ---
 arch/mips/include/asm/mach-loongson64/gpio.h    |  36 ------
 arch/mips/include/asm/mach-pistachio/gpio.h     |  21 ----
 arch/mips/include/asm/mach-rc32434/gpio.h       |  12 --
 arch/mips/jz4740/board-qi_lb60.c                |   1 +
 arch/mips/jz4740/gpio.c                         |  21 ++--
 arch/mips/pci/pci-lantiq.c                      |   1 -
 arch/mips/rb532/devices.c                       |   1 +
 arch/mips/rb532/gpio.c                          |   6 +
 arch/mips/txx9/generic/setup.c                  |  16 ---
 drivers/ata/pata_rb532_cf.c                     |   3 +-
 drivers/gpio/gpio-ath79.c                       |  32 -----
 drivers/input/misc/rb532_button.c               |   1 +
 drivers/net/ethernet/ti/cpmac.c                 |   2 +
 38 files changed, 47 insertions(+), 551 deletions(-)
 delete mode 100644 arch/mips/include/asm/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-ar7/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-ath25/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-ath79/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-au1x00/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-bcm47xx/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-bcm63xx/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-cavium-octeon/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-generic/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-lantiq/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-loongson64/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-pistachio/gpio.h

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index d896ffb..1bab15d 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -13,7 +13,6 @@ config MIPS
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_BPF_JIT if !CPU_MICROMIPS
-	select ARCH_HAVE_CUSTOM_GPIO_H
 	select HAVE_FUNCTION_TRACER
 	select HAVE_DYNAMIC_FTRACE
 	select HAVE_FTRACE_MCOUNT_RECORD
diff --git a/arch/mips/alchemy/Kconfig b/arch/mips/alchemy/Kconfig
index b962898..7fa2488 100644
--- a/arch/mips/alchemy/Kconfig
+++ b/arch/mips/alchemy/Kconfig
@@ -6,13 +6,6 @@ config ALCHEMY_GPIOINT_AU1000
 config ALCHEMY_GPIOINT_AU1300
 	bool
 
-# select this in your board config if you don't want to use the gpio
-# namespace as documented in the manuals.  In this case however you need
-# to create the necessary gpio_* functions in your board code/headers!
-# see arch/mips/include/asm/mach-au1x00/gpio.h   for more information.
-config ALCHEMY_GPIO_INDIRECT
-	def_bool n
-
 choice
 	prompt "Machine type"
 	depends on MIPS_ALCHEMY
diff --git a/arch/mips/alchemy/board-gpr.c b/arch/mips/alchemy/board-gpr.c
index acf9a2a..79efe4c 100644
--- a/arch/mips/alchemy/board-gpr.c
+++ b/arch/mips/alchemy/board-gpr.c
@@ -34,6 +34,7 @@
 #include <asm/idle.h>
 #include <asm/reboot.h>
 #include <asm/mach-au1x00/au1000.h>
+#include <asm/mach-au1x00/gpio-au1000.h>
 #include <prom.h>
 
 const char *get_system_type(void)
diff --git a/arch/mips/alchemy/board-mtx1.c b/arch/mips/alchemy/board-mtx1.c
index 1e3b102..85bb756 100644
--- a/arch/mips/alchemy/board-mtx1.c
+++ b/arch/mips/alchemy/board-mtx1.c
@@ -32,6 +32,7 @@
 #include <asm/bootinfo.h>
 #include <asm/reboot.h>
 #include <asm/mach-au1x00/au1000.h>
+#include <asm/mach-au1x00/gpio-au1000.h>
 #include <asm/mach-au1x00/au1xxx_eth.h>
 #include <prom.h>
 
diff --git a/arch/mips/alchemy/common/Makefile b/arch/mips/alchemy/common/Makefile
index f64744f..23800b8 100644
--- a/arch/mips/alchemy/common/Makefile
+++ b/arch/mips/alchemy/common/Makefile
@@ -5,10 +5,5 @@
 # Makefile for the Alchemy Au1xx0 CPUs, generic files.
 #
 
-obj-y += prom.o time.o clock.o platform.o power.o \
+obj-y += prom.o time.o clock.o platform.o power.o gpiolib.o \
 	 setup.o sleeper.o dma.o dbdma.o vss.o irq.o usb.o
-
-# optional gpiolib support
-ifeq ($(CONFIG_ALCHEMY_GPIO_INDIRECT),)
- obj-$(CONFIG_GPIOLIB) += gpiolib.o
-endif
diff --git a/arch/mips/alchemy/devboards/db1000.c b/arch/mips/alchemy/devboards/db1000.c
index 001102e..bdeed9d 100644
--- a/arch/mips/alchemy/devboards/db1000.c
+++ b/arch/mips/alchemy/devboards/db1000.c
@@ -33,6 +33,7 @@
 #include <linux/spi/spi_gpio.h>
 #include <linux/spi/ads7846.h>
 #include <asm/mach-au1x00/au1000.h>
+#include <asm/mach-au1x00/gpio-au1000.h>
 #include <asm/mach-au1x00/au1000_dma.h>
 #include <asm/mach-au1x00/au1100_mmc.h>
 #include <asm/mach-db1x00/bcsr.h>
diff --git a/arch/mips/alchemy/devboards/db1300.c b/arch/mips/alchemy/devboards/db1300.c
index 1c64fdb..b580770 100644
--- a/arch/mips/alchemy/devboards/db1300.c
+++ b/arch/mips/alchemy/devboards/db1300.c
@@ -24,6 +24,7 @@
 #include <linux/wm97xx.h>
 
 #include <asm/mach-au1x00/au1000.h>
+#include <asm/mach-au1x00/gpio-au1300.h>
 #include <asm/mach-au1x00/au1100_mmc.h>
 #include <asm/mach-au1x00/au1200fb.h>
 #include <asm/mach-au1x00/au1xxx_dbdma.h>
diff --git a/arch/mips/alchemy/devboards/db1550.c b/arch/mips/alchemy/devboards/db1550.c
index 0fd5177..5740bcf 100644
--- a/arch/mips/alchemy/devboards/db1550.c
+++ b/arch/mips/alchemy/devboards/db1550.c
@@ -20,6 +20,7 @@
 #include <linux/spi/flash.h>
 #include <asm/bootinfo.h>
 #include <asm/mach-au1x00/au1000.h>
+#include <asm/mach-au1x00/gpio-au1000.h>
 #include <asm/mach-au1x00/au1xxx_eth.h>
 #include <asm/mach-au1x00/au1xxx_dbdma.h>
 #include <asm/mach-au1x00/au1xxx_psc.h>
diff --git a/arch/mips/alchemy/devboards/pm.c b/arch/mips/alchemy/devboards/pm.c
index bfeb8f3..93024dc 100644
--- a/arch/mips/alchemy/devboards/pm.c
+++ b/arch/mips/alchemy/devboards/pm.c
@@ -9,7 +9,7 @@
 #include <linux/suspend.h>
 #include <linux/sysfs.h>
 #include <asm/mach-au1x00/au1000.h>
-#include <asm/mach-au1x00/gpio.h>
+#include <asm/mach-au1x00/gpio-au1000.h>
 #include <asm/mach-db1x00/bcsr.h>
 
 /*
diff --git a/arch/mips/ar7/gpio.c b/arch/mips/ar7/gpio.c
index d8dbd8f..f493045 100644
--- a/arch/mips/ar7/gpio.c
+++ b/arch/mips/ar7/gpio.c
@@ -21,7 +21,10 @@
 #include <linux/module.h>
 #include <linux/gpio.h>
 
-#include <asm/mach-ar7/gpio.h>
+#include <asm/mach-ar7/ar7.h>
+
+#define AR7_GPIO_MAX 32
+#define TITAN_GPIO_MAX 51
 
 struct ar7_gpio_chip {
 	void __iomem		*regs;
diff --git a/arch/mips/ar7/platform.c b/arch/mips/ar7/platform.c
index be9ff16..462a252 100644
--- a/arch/mips/ar7/platform.c
+++ b/arch/mips/ar7/platform.c
@@ -39,7 +39,6 @@
 
 #include <asm/addrspace.h>
 #include <asm/mach-ar7/ar7.h>
-#include <asm/mach-ar7/gpio.h>
 #include <asm/mach-ar7/prom.h>
 
 /*****************************************************************************
diff --git a/arch/mips/ar7/setup.c b/arch/mips/ar7/setup.c
index 820b7a3..7bb9a67 100644
--- a/arch/mips/ar7/setup.c
+++ b/arch/mips/ar7/setup.c
@@ -23,7 +23,6 @@
 #include <asm/reboot.h>
 #include <asm/mach-ar7/ar7.h>
 #include <asm/mach-ar7/prom.h>
-#include <asm/mach-ar7/gpio.h>
 
 static void ar7_machine_restart(char *command)
 {
diff --git a/arch/mips/include/asm/gpio.h b/arch/mips/include/asm/gpio.h
deleted file mode 100644
index 06e46fa..0000000
--- a/arch/mips/include/asm/gpio.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef __ASM_MIPS_GPIO_H
-#define __ASM_MIPS_GPIO_H
-
-#include <gpio.h>
-
-#endif /* __ASM_MIPS_GPIO_H */
diff --git a/arch/mips/include/asm/mach-ar7/ar7.h b/arch/mips/include/asm/mach-ar7/ar7.h
index a47ea0c..468cbd6 100644
--- a/arch/mips/include/asm/mach-ar7/ar7.h
+++ b/arch/mips/include/asm/mach-ar7/ar7.h
@@ -203,4 +203,8 @@ static inline void ar7_device_off(u32 bit)
 int __init ar7_gpio_init(void);
 void __init ar7_init_clocks(void);
 
+/* Board specific GPIO functions */
+int ar7_gpio_enable(unsigned gpio);
+int ar7_gpio_disable(unsigned gpio);
+
 #endif /* __AR7_H__ */
diff --git a/arch/mips/include/asm/mach-ar7/gpio.h b/arch/mips/include/asm/mach-ar7/gpio.h
deleted file mode 100644
index c177cd1..0000000
--- a/arch/mips/include/asm/mach-ar7/gpio.h
+++ /dev/null
@@ -1,41 +0,0 @@
-/*
- * Copyright (C) 2007-2009 Florian Fainelli <florian@openwrt.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
- */
-
-#ifndef __AR7_GPIO_H__
-#define __AR7_GPIO_H__
-
-#include <asm/mach-ar7/ar7.h>
-
-#define AR7_GPIO_MAX 32
-#define TITAN_GPIO_MAX	51
-#define NR_BUILTIN_GPIO TITAN_GPIO_MAX
-
-#define gpio_to_irq(gpio)	-1
-
-#define gpio_get_value __gpio_get_value
-#define gpio_set_value __gpio_set_value
-
-#define gpio_cansleep __gpio_cansleep
-
-/* Board specific GPIO functions */
-int ar7_gpio_enable(unsigned gpio);
-int ar7_gpio_disable(unsigned gpio);
-
-#include <asm-generic/gpio.h>
-
-#endif
diff --git a/arch/mips/include/asm/mach-ath25/gpio.h b/arch/mips/include/asm/mach-ath25/gpio.h
deleted file mode 100644
index 713564b..0000000
--- a/arch/mips/include/asm/mach-ath25/gpio.h
+++ /dev/null
@@ -1,16 +0,0 @@
-#ifndef __ASM_MACH_ATH25_GPIO_H
-#define __ASM_MACH_ATH25_GPIO_H
-
-#include <asm-generic/gpio.h>
-
-#define gpio_get_value __gpio_get_value
-#define gpio_set_value __gpio_set_value
-#define gpio_cansleep __gpio_cansleep
-#define gpio_to_irq __gpio_to_irq
-
-static inline int irq_to_gpio(unsigned irq)
-{
-	return -EINVAL;
-}
-
-#endif	/* __ASM_MACH_ATH25_GPIO_H */
diff --git a/arch/mips/include/asm/mach-ath79/gpio.h b/arch/mips/include/asm/mach-ath79/gpio.h
deleted file mode 100644
index 60dcb62..0000000
--- a/arch/mips/include/asm/mach-ath79/gpio.h
+++ /dev/null
@@ -1,26 +0,0 @@
-/*
- *  Atheros AR71XX/AR724X/AR913X GPIO API definitions
- *
- *  Copyright (C) 2008-2010 Gabor Juhos <juhosg@openwrt.org>
- *  Copyright (C) 2008 Imre Kaloz <kaloz@openwrt.org>
- *
- *  This program is free software; you can redistribute it and/or modify it
- *  under the terms of the GNU General Public License version 2 as published
- *  by the Free Software Foundation.
- *
- */
-
-#ifndef __ASM_MACH_ATH79_GPIO_H
-#define __ASM_MACH_ATH79_GPIO_H
-
-#define ARCH_NR_GPIOS	64
-#include <asm-generic/gpio.h>
-
-int gpio_to_irq(unsigned gpio);
-int irq_to_gpio(unsigned irq);
-int gpio_get_value(unsigned gpio);
-void gpio_set_value(unsigned gpio, int value);
-
-#define gpio_cansleep	__gpio_cansleep
-
-#endif /* __ASM_MACH_ATH79_GPIO_H */
diff --git a/arch/mips/include/asm/mach-au1x00/gpio-au1000.h b/arch/mips/include/asm/mach-au1x00/gpio-au1000.h
index 9785e4e..adde1fa 100644
--- a/arch/mips/include/asm/mach-au1x00/gpio-au1000.h
+++ b/arch/mips/include/asm/mach-au1x00/gpio-au1000.h
@@ -266,6 +266,17 @@ static inline int alchemy_gpio1_to_irq(int gpio)
 	return -ENXIO;
 }
 
+/* On Au1000, Au1500 and Au1100 GPIOs won't work as inputs before
+ * SYS_PININPUTEN is written to at least once.  On Au1550/Au1200/Au1300 this
+ * register enables use of GPIOs as wake source.
+ */
+static inline void alchemy_gpio1_input_enable(void)
+{
+	void __iomem *base = (void __iomem *)KSEG1ADDR(AU1000_SYS_PHYS_ADDR);
+	__raw_writel(0, base + 0x110);		/* the write op is key */
+	wmb();
+}
+
 /*
  * GPIO2 block macros for common linux GPIO functions. The 'gpio'
  * parameter must be in range of ALCHEMY_GPIO2_BASE..ALCHEMY_GPIO2_MAX.
@@ -518,141 +529,4 @@ static inline int alchemy_irq_to_gpio(int irq)
 	return -ENXIO;
 }
 
-/**********************************************************************/
-
-/* Linux gpio framework integration.
- *
- * 4 use cases of Au1000-Au1200 GPIOS:
- *(1) GPIOLIB=y, ALCHEMY_GPIO_INDIRECT=y:
- *	Board must register gpiochips.
- *(2) GPIOLIB=y, ALCHEMY_GPIO_INDIRECT=n:
- *	2 (1 for Au1000) gpio_chips are registered.
- *
- *(3) GPIOLIB=n, ALCHEMY_GPIO_INDIRECT=y:
- *	the boards' gpio.h must provide the linux gpio wrapper functions,
- *
- *(4) GPIOLIB=n, ALCHEMY_GPIO_INDIRECT=n:
- *	inlinable gpio functions are provided which enable access to the
- *	Au1000 gpios only by using the numbers straight out of the data-
- *	sheets.
-
- * Cases 1 and 3 are intended for boards which want to provide their own
- * GPIO namespace and -operations (i.e. for example you have 8 GPIOs
- * which are in part provided by spare Au1000 GPIO pins and in part by
- * an external FPGA but you still want them to be accssible in linux
- * as gpio0-7. The board can of course use the alchemy_gpioX_* functions
- * as required).
- */
-
-#ifndef CONFIG_GPIOLIB
-
-#ifdef CONFIG_ALCHEMY_GPIOINT_AU1000
-
-#ifndef CONFIG_ALCHEMY_GPIO_INDIRECT	/* case (4) */
-
-static inline int gpio_direction_input(int gpio)
-{
-	return alchemy_gpio_direction_input(gpio);
-}
-
-static inline int gpio_direction_output(int gpio, int v)
-{
-	return alchemy_gpio_direction_output(gpio, v);
-}
-
-static inline int gpio_get_value(int gpio)
-{
-	return alchemy_gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(int gpio, int v)
-{
-	alchemy_gpio_set_value(gpio, v);
-}
-
-static inline int gpio_get_value_cansleep(unsigned gpio)
-{
-	return gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value_cansleep(unsigned gpio, int value)
-{
-	gpio_set_value(gpio, value);
-}
-
-static inline int gpio_is_valid(int gpio)
-{
-	return alchemy_gpio_is_valid(gpio);
-}
-
-static inline int gpio_cansleep(int gpio)
-{
-	return alchemy_gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(int gpio)
-{
-	return alchemy_gpio_to_irq(gpio);
-}
-
-static inline int irq_to_gpio(int irq)
-{
-	return alchemy_irq_to_gpio(irq);
-}
-
-static inline int gpio_request(unsigned gpio, const char *label)
-{
-	return 0;
-}
-
-static inline int gpio_request_one(unsigned gpio,
-					unsigned long flags, const char *label)
-{
-	return 0;
-}
-
-static inline int gpio_request_array(struct gpio *array, size_t num)
-{
-	return 0;
-}
-
-static inline void gpio_free(unsigned gpio)
-{
-}
-
-static inline void gpio_free_array(struct gpio *array, size_t num)
-{
-}
-
-static inline int gpio_set_debounce(unsigned gpio, unsigned debounce)
-{
-	return -ENOSYS;
-}
-
-static inline int gpio_export(unsigned gpio, bool direction_may_change)
-{
-	return -ENOSYS;
-}
-
-static inline int gpio_export_link(struct device *dev, const char *name,
-				   unsigned gpio)
-{
-	return -ENOSYS;
-}
-
-static inline int gpio_sysfs_set_active_low(unsigned gpio, int value)
-{
-	return -ENOSYS;
-}
-
-static inline void gpio_unexport(unsigned gpio)
-{
-}
-
-#endif	/* !CONFIG_ALCHEMY_GPIO_INDIRECT */
-
-#endif	/* CONFIG_ALCHEMY_GPIOINT_AU1000 */
-
-#endif	/* !CONFIG_GPIOLIB */
-
 #endif /* _ALCHEMY_GPIO_AU1000_H_ */
diff --git a/arch/mips/include/asm/mach-au1x00/gpio.h b/arch/mips/include/asm/mach-au1x00/gpio.h
deleted file mode 100644
index 22e7ff1..0000000
--- a/arch/mips/include/asm/mach-au1x00/gpio.h
+++ /dev/null
@@ -1,86 +0,0 @@
-/*
- * Alchemy GPIO support.
- *
- * With CONFIG_GPIOLIB=y different types of on-chip GPIO can be supported within
- *  the same kernel image.
- * With CONFIG_GPIOLIB=n, your board must select ALCHEMY_GPIOINT_AU1XXX for the
- *  appropriate CPU type (AU1000 currently).
- */
-
-#ifndef _ALCHEMY_GPIO_H_
-#define _ALCHEMY_GPIO_H_
-
-#include <asm/mach-au1x00/au1000.h>
-#include <asm/mach-au1x00/gpio-au1000.h>
-#include <asm/mach-au1x00/gpio-au1300.h>
-
-/* On Au1000, Au1500 and Au1100 GPIOs won't work as inputs before
- * SYS_PININPUTEN is written to at least once.  On Au1550/Au1200/Au1300 this
- * register enables use of GPIOs as wake source.
- */
-static inline void alchemy_gpio1_input_enable(void)
-{
-	void __iomem *base = (void __iomem *)KSEG1ADDR(AU1000_SYS_PHYS_ADDR);
-	__raw_writel(0, base + 0x110);		/* the write op is key */
-	wmb();
-}
-
-
-/* Linux gpio framework integration.
-*
-* 4 use cases of Alchemy GPIOS:
-*(1) GPIOLIB=y, ALCHEMY_GPIO_INDIRECT=y:
-*	Board must register gpiochips.
-*(2) GPIOLIB=y, ALCHEMY_GPIO_INDIRECT=n:
-*	A gpiochip for the 75 GPIOs is registered.
-*
-*(3) GPIOLIB=n, ALCHEMY_GPIO_INDIRECT=y:
-*	the boards' gpio.h must provide	the linux gpio wrapper functions,
-*
-*(4) GPIOLIB=n, ALCHEMY_GPIO_INDIRECT=n:
-*	inlinable gpio functions are provided which enable access to the
-*	Au1300 gpios only by using the numbers straight out of the data-
-*	sheets.
-
-* Cases 1 and 3 are intended for boards which want to provide their own
-* GPIO namespace and -operations (i.e. for example you have 8 GPIOs
-* which are in part provided by spare Au1300 GPIO pins and in part by
-* an external FPGA but you still want them to be accssible in linux
-* as gpio0-7. The board can of course use the alchemy_gpioX_* functions
-* as required).
-*/
-
-#ifdef CONFIG_GPIOLIB
-
-/* wraps the cpu-dependent irq_to_gpio functions */
-/* FIXME: gpiolib needs an irq_to_gpio hook */
-static inline int __au_irq_to_gpio(unsigned int irq)
-{
-	switch (alchemy_get_cputype()) {
-	case ALCHEMY_CPU_AU1000...ALCHEMY_CPU_AU1200:
-		return alchemy_irq_to_gpio(irq);
-	case ALCHEMY_CPU_AU1300:
-		return au1300_irq_to_gpio(irq);
-	}
-	return -EINVAL;
-}
-
-
-/* using gpiolib to provide up to 2 gpio_chips for on-chip gpios */
-#ifndef CONFIG_ALCHEMY_GPIO_INDIRECT	/* case (2) */
-
-/* get everything through gpiolib */
-#define gpio_to_irq	__gpio_to_irq
-#define gpio_get_value	__gpio_get_value
-#define gpio_set_value	__gpio_set_value
-#define gpio_cansleep	__gpio_cansleep
-#define irq_to_gpio	__au_irq_to_gpio
-
-#include <asm-generic/gpio.h>
-
-#endif	/* !CONFIG_ALCHEMY_GPIO_INDIRECT */
-
-
-#endif	/* CONFIG_GPIOLIB */
-
-#endif	/* _ALCHEMY_GPIO_H_ */
diff --git a/arch/mips/include/asm/mach-bcm47xx/gpio.h b/arch/mips/include/asm/mach-bcm47xx/gpio.h
deleted file mode 100644
index 90daefa..0000000
--- a/arch/mips/include/asm/mach-bcm47xx/gpio.h
+++ /dev/null
@@ -1,17 +0,0 @@
-#ifndef __ASM_MIPS_MACH_BCM47XX_GPIO_H
-#define __ASM_MIPS_MACH_BCM47XX_GPIO_H
-
-#include <asm-generic/gpio.h>
-
-#define gpio_get_value __gpio_get_value
-#define gpio_set_value __gpio_set_value
-
-#define gpio_cansleep __gpio_cansleep
-#define gpio_to_irq __gpio_to_irq
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif
diff --git a/arch/mips/include/asm/mach-bcm63xx/gpio.h b/arch/mips/include/asm/mach-bcm63xx/gpio.h
deleted file mode 100644
index 1eb534d..0000000
--- a/arch/mips/include/asm/mach-bcm63xx/gpio.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef __ASM_MIPS_MACH_BCM63XX_GPIO_H
-#define __ASM_MIPS_MACH_BCM63XX_GPIO_H
-
-#include <bcm63xx_gpio.h>
-
-#define gpio_to_irq(gpio)	-1
-
-#define gpio_get_value __gpio_get_value
-#define gpio_set_value __gpio_set_value
-
-#define gpio_cansleep __gpio_cansleep
-
-#include <asm-generic/gpio.h>
-
-#endif /* __ASM_MIPS_MACH_BCM63XX_GPIO_H */
diff --git a/arch/mips/include/asm/mach-cavium-octeon/gpio.h b/arch/mips/include/asm/mach-cavium-octeon/gpio.h
deleted file mode 100644
index 34e9f7a..0000000
--- a/arch/mips/include/asm/mach-cavium-octeon/gpio.h
+++ /dev/null
@@ -1,21 +0,0 @@
-#ifndef __ASM_MACH_CAVIUM_OCTEON_GPIO_H
-#define __ASM_MACH_CAVIUM_OCTEON_GPIO_H
-
-#ifdef CONFIG_GPIOLIB
-#define gpio_get_value	__gpio_get_value
-#define gpio_set_value	__gpio_set_value
-#define gpio_cansleep	__gpio_cansleep
-#else
-int gpio_request(unsigned gpio, const char *label);
-void gpio_free(unsigned gpio);
-int gpio_direction_input(unsigned gpio);
-int gpio_direction_output(unsigned gpio, int value);
-int gpio_get_value(unsigned gpio);
-void gpio_set_value(unsigned gpio, int value);
-#endif
-
-#include <asm-generic/gpio.h>
-
-#define gpio_to_irq	__gpio_to_irq
-
-#endif /* __ASM_MACH_GENERIC_GPIO_H */
diff --git a/arch/mips/include/asm/mach-generic/gpio.h b/arch/mips/include/asm/mach-generic/gpio.h
deleted file mode 100644
index b4e7020..0000000
--- a/arch/mips/include/asm/mach-generic/gpio.h
+++ /dev/null
@@ -1,21 +0,0 @@
-#ifndef __ASM_MACH_GENERIC_GPIO_H
-#define __ASM_MACH_GENERIC_GPIO_H
-
-#ifdef CONFIG_GPIOLIB
-#define gpio_get_value	__gpio_get_value
-#define gpio_set_value	__gpio_set_value
-#define gpio_cansleep	__gpio_cansleep
-#else
-int gpio_request(unsigned gpio, const char *label);
-void gpio_free(unsigned gpio);
-int gpio_direction_input(unsigned gpio);
-int gpio_direction_output(unsigned gpio, int value);
-int gpio_get_value(unsigned gpio);
-void gpio_set_value(unsigned gpio, int value);
-#endif
-int gpio_to_irq(unsigned gpio);
-int irq_to_gpio(unsigned irq);
-
-#include <asm-generic/gpio.h>		/* cansleep wrappers */
-
-#endif /* __ASM_MACH_GENERIC_GPIO_H */
diff --git a/arch/mips/include/asm/mach-jz4740/gpio.h b/arch/mips/include/asm/mach-jz4740/gpio.h
index eaacba7..bf8c3e1 100644
--- a/arch/mips/include/asm/mach-jz4740/gpio.h
+++ b/arch/mips/include/asm/mach-jz4740/gpio.h
@@ -73,8 +73,6 @@ int jz_gpio_port_direction_output(int port, uint32_t mask);
 void jz_gpio_port_set_value(int port, uint32_t value, uint32_t mask);
 uint32_t jz_gpio_port_get_value(int port, uint32_t mask);
 
-#include <asm/mach-generic/gpio.h>
-
 #define JZ_GPIO_PORTA(x) ((x) + 32 * 0)
 #define JZ_GPIO_PORTB(x) ((x) + 32 * 1)
 #define JZ_GPIO_PORTC(x) ((x) + 32 * 2)
diff --git a/arch/mips/include/asm/mach-lantiq/gpio.h b/arch/mips/include/asm/mach-lantiq/gpio.h
deleted file mode 100644
index 9ba1cae..0000000
--- a/arch/mips/include/asm/mach-lantiq/gpio.h
+++ /dev/null
@@ -1,13 +0,0 @@
-#ifndef __ASM_MIPS_MACH_LANTIQ_GPIO_H
-#define __ASM_MIPS_MACH_LANTIQ_GPIO_H
-
-#define gpio_to_irq __gpio_to_irq
-
-#define gpio_get_value __gpio_get_value
-#define gpio_set_value __gpio_set_value
-
-#define gpio_cansleep __gpio_cansleep
-
-#include <asm-generic/gpio.h>
-
-#endif
diff --git a/arch/mips/include/asm/mach-loongson64/gpio.h b/arch/mips/include/asm/mach-loongson64/gpio.h
deleted file mode 100644
index b3b2169..0000000
--- a/arch/mips/include/asm/mach-loongson64/gpio.h
+++ /dev/null
@@ -1,36 +0,0 @@
-/*
- * Loongson GPIO Support
- *
- * Copyright (c) 2008  Richard Liu, STMicroelectronics <richard.liu@st.com>
- * Copyright (c) 2008-2010  Arnaud Patard <apatard@mandriva.com>
- * Copyright (c) 2014  Huacai Chen <chenhc@lemote.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef __LOONGSON_GPIO_H
-#define __LOONGSON_GPIO_H
-
-#include <asm-generic/gpio.h>
-
-#define gpio_get_value __gpio_get_value
-#define gpio_set_value __gpio_set_value
-#define gpio_cansleep __gpio_cansleep
-
-/* The chip can do interrupt
- * but it has not been tested and doc not clear
- */
-static inline int gpio_to_irq(int gpio)
-{
-	return -EINVAL;
-}
-
-static inline int irq_to_gpio(int gpio)
-{
-	return -EINVAL;
-}
-
-#endif	/* __LOONGSON_GPIO_H */
diff --git a/arch/mips/include/asm/mach-pistachio/gpio.h b/arch/mips/include/asm/mach-pistachio/gpio.h
deleted file mode 100644
index 6c1649c..0000000
--- a/arch/mips/include/asm/mach-pistachio/gpio.h
+++ /dev/null
@@ -1,21 +0,0 @@
-/*
- * Pistachio IRQ setup
- *
- * Copyright (C) 2014 Google, Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- */
-
-#ifndef __ASM_MACH_PISTACHIO_GPIO_H
-#define __ASM_MACH_PISTACHIO_GPIO_H
-
-#include <asm-generic/gpio.h>
-
-#define gpio_get_value	__gpio_get_value
-#define gpio_set_value	__gpio_set_value
-#define gpio_cansleep	__gpio_cansleep
-#define gpio_to_irq	__gpio_to_irq
-
-#endif /* __ASM_MACH_PISTACHIO_GPIO_H */
diff --git a/arch/mips/include/asm/mach-rc32434/gpio.h b/arch/mips/include/asm/mach-rc32434/gpio.h
index 4dee0a3..db21121 100644
--- a/arch/mips/include/asm/mach-rc32434/gpio.h
+++ b/arch/mips/include/asm/mach-rc32434/gpio.h
@@ -13,18 +13,6 @@
 #ifndef _RC32434_GPIO_H_
 #define _RC32434_GPIO_H_
 
-#include <linux/types.h>
-#include <asm-generic/gpio.h>
-
-#define NR_BUILTIN_GPIO		32
-
-#define gpio_get_value	__gpio_get_value
-#define gpio_set_value	__gpio_set_value
-#define gpio_cansleep	__gpio_cansleep
-
-#define gpio_to_irq(gpio)	(8 + 4 * 32 + gpio)
-#define irq_to_gpio(irq)	(irq - (8 + 4 * 32))
-
 struct rb532_gpio_reg {
 	u32   gpiofunc;	  /* GPIO Function Register
 			   * gpiofunc[x]==0 bit = gpio
diff --git a/arch/mips/jz4740/board-qi_lb60.c b/arch/mips/jz4740/board-qi_lb60.c
index 4e62bf8..459cb01 100644
--- a/arch/mips/jz4740/board-qi_lb60.c
+++ b/arch/mips/jz4740/board-qi_lb60.c
@@ -26,6 +26,7 @@
 #include <linux/power/jz4740-battery.h>
 #include <linux/power/gpio-charger.h>
 
+#include <asm/mach-jz4740/gpio.h>
 #include <asm/mach-jz4740/jz4740_fb.h>
 #include <asm/mach-jz4740/jz4740_mmc.h>
 #include <asm/mach-jz4740/jz4740_nand.h>
diff --git a/arch/mips/jz4740/gpio.c b/arch/mips/jz4740/gpio.c
index 54c80d4..c122a07 100644
--- a/arch/mips/jz4740/gpio.c
+++ b/arch/mips/jz4740/gpio.c
@@ -28,6 +28,7 @@
 #include <linux/seq_file.h>
 
 #include <asm/mach-jz4740/base.h>
+#include <asm/mach-jz4740/gpio.h>
 
 #define JZ4740_GPIO_BASE_A (32*0)
 #define JZ4740_GPIO_BASE_B (32*1)
@@ -231,6 +232,13 @@ static int jz_gpio_direction_input(struct gpio_chip *chip, unsigned gpio)
 	return 0;
 }
 
+static int jz_gpio_to_irq(struct gpio_chip *chip, unsigned gpio)
+{
+	struct jz_gpio_chip *jz_gpio = gpio_chip_to_jz_gpio_chip(chip);
+
+	return jz_gpio->irq_base + gpio;
+}
+
 int jz_gpio_port_direction_input(int port, uint32_t mask)
 {
 	writel(mask, GPIO_TO_REG(port, JZ_REG_GPIO_DIRECTION_CLEAR));
@@ -262,18 +270,6 @@ uint32_t jz_gpio_port_get_value(int port, uint32_t mask)
 }
 EXPORT_SYMBOL(jz_gpio_port_get_value);
 
-int gpio_to_irq(unsigned gpio)
-{
-	return JZ4740_IRQ_GPIO(0) + gpio;
-}
-EXPORT_SYMBOL_GPL(gpio_to_irq);
-
-int irq_to_gpio(unsigned irq)
-{
-	return irq - JZ4740_IRQ_GPIO(0);
-}
-EXPORT_SYMBOL_GPL(irq_to_gpio);
-
 #define IRQ_TO_BIT(irq) BIT(irq_to_gpio(irq) & 0x1f)
 
 static void jz_gpio_check_trigger_both(struct jz_gpio_chip *chip, unsigned int irq)
@@ -403,6 +399,7 @@ static int jz_gpio_irq_set_wake(struct irq_data *data, unsigned int on)
 		.get = jz_gpio_get_value, \
 		.direction_output = jz_gpio_direction_output, \
 		.direction_input = jz_gpio_direction_input, \
+		.to_irq = jz_gpio_to_irq, \
 		.base = JZ4740_GPIO_BASE_ ## _bank, \
 		.ngpio = JZ4740_GPIO_NUM_ ## _bank, \
 	}, \
diff --git a/arch/mips/pci/pci-lantiq.c b/arch/mips/pci/pci-lantiq.c
index c5347d9..6a15dbd 100644
--- a/arch/mips/pci/pci-lantiq.c
+++ b/arch/mips/pci/pci-lantiq.c
@@ -20,7 +20,6 @@
 #include <linux/of_irq.h>
 #include <linux/of_pci.h>
 
-#include <asm/gpio.h>
 #include <asm/addrspace.h>
 
 #include <lantiq_soc.h>
diff --git a/arch/mips/rb532/devices.c b/arch/mips/rb532/devices.c
index e31e8cd..9bd7a2d 100644
--- a/arch/mips/rb532/devices.c
+++ b/arch/mips/rb532/devices.c
@@ -23,6 +23,7 @@
 #include <linux/mtd/nand.h>
 #include <linux/mtd/mtd.h>
 #include <linux/mtd/partitions.h>
+#include <linux/gpio.h>
 #include <linux/gpio_keys.h>
 #include <linux/input.h>
 #include <linux/serial_8250.h>
diff --git a/arch/mips/rb532/gpio.c b/arch/mips/rb532/gpio.c
index 5aa3df8..650d5d3 100644
--- a/arch/mips/rb532/gpio.c
+++ b/arch/mips/rb532/gpio.c
@@ -140,6 +140,11 @@ static int rb532_gpio_direction_output(struct gpio_chip *chip,
 	return 0;
 }
 
+static int rb532_gpio_to_irq(struct gpio_chip *chip, unsigned gpio)
+{
+	return 8 + 4 * 32 + gpio;
+}
+
 static struct rb532_gpio_chip rb532_gpio_chip[] = {
 	[0] = {
 		.chip = {
@@ -148,6 +153,7 @@ static struct rb532_gpio_chip rb532_gpio_chip[] = {
 			.direction_output	= rb532_gpio_direction_output,
 			.get			= rb532_gpio_get,
 			.set			= rb532_gpio_set,
+			.to_irq			= rb532_gpio_to_irq,
 			.base			= 0,
 			.ngpio			= 32,
 		},
diff --git a/arch/mips/txx9/generic/setup.c b/arch/mips/txx9/generic/setup.c
index 2791b86..9d9962a 100644
--- a/arch/mips/txx9/generic/setup.c
+++ b/arch/mips/txx9/generic/setup.c
@@ -117,22 +117,6 @@ void clk_put(struct clk *clk)
 }
 EXPORT_SYMBOL(clk_put);
 
-/* GPIO support */
-
-#ifdef CONFIG_GPIOLIB
-int gpio_to_irq(unsigned gpio)
-{
-	return -EINVAL;
-}
-EXPORT_SYMBOL(gpio_to_irq);
-
-int irq_to_gpio(unsigned irq)
-{
-	return -EINVAL;
-}
-EXPORT_SYMBOL(irq_to_gpio);
-#endif
-
 #define BOARD_VEC(board)	extern struct txx9_board_vec board;
 #include <asm/txx9/boards.h>
 #undef BOARD_VEC
diff --git a/drivers/ata/pata_rb532_cf.c b/drivers/ata/pata_rb532_cf.c
index 6d08446..12fe0f3 100644
--- a/drivers/ata/pata_rb532_cf.c
+++ b/drivers/ata/pata_rb532_cf.c
@@ -27,12 +27,11 @@
 #include <linux/io.h>
 #include <linux/interrupt.h>
 #include <linux/irq.h>
+#include <linux/gpio.h>
 
 #include <linux/libata.h>
 #include <scsi/scsi_host.h>
 
-#include <asm/gpio.h>
-
 #define DRV_NAME	"pata-rb532-cf"
 #define DRV_VERSION	"0.1.0"
 #define DRV_DESC	"PATA driver for RouterBOARD 532 Compact Flash"
diff --git a/drivers/gpio/gpio-ath79.c b/drivers/gpio/gpio-ath79.c
index c3c92eb..03b9953 100644
--- a/drivers/gpio/gpio-ath79.c
+++ b/drivers/gpio/gpio-ath79.c
@@ -202,35 +202,3 @@ static struct platform_driver ath79_gpio_driver = {
 };
 
 module_platform_driver(ath79_gpio_driver);
-
-int gpio_get_value(unsigned gpio)
-{
-	if (gpio < ath79_gpio_count)
-		return __ath79_gpio_get_value(gpio);
-
-	return __gpio_get_value(gpio);
-}
-EXPORT_SYMBOL(gpio_get_value);
-
-void gpio_set_value(unsigned gpio, int value)
-{
-	if (gpio < ath79_gpio_count)
-		__ath79_gpio_set_value(gpio, value);
-	else
-		__gpio_set_value(gpio, value);
-}
-EXPORT_SYMBOL(gpio_set_value);
-
-int gpio_to_irq(unsigned gpio)
-{
-	/* FIXME */
-	return -EINVAL;
-}
-EXPORT_SYMBOL(gpio_to_irq);
-
-int irq_to_gpio(unsigned irq)
-{
-	/* FIXME */
-	return -EINVAL;
-}
-EXPORT_SYMBOL(irq_to_gpio);
diff --git a/drivers/input/misc/rb532_button.c b/drivers/input/misc/rb532_button.c
index e956e81..62c5814 100644
--- a/drivers/input/misc/rb532_button.c
+++ b/drivers/input/misc/rb532_button.c
@@ -7,6 +7,7 @@
 #include <linux/input-polldev.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
+#include <linux/gpio.h>
 
 #include <asm/mach-rc32434/gpio.h>
 #include <asm/mach-rc32434/rb.h>
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index dd94300..cba3d9f 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -41,6 +41,8 @@
 #include <linux/gpio.h>
 #include <linux/atomic.h>
 
+#include <asm/mach-ar7/ar7.h>
+
 MODULE_AUTHOR("Eugene Konev <ejka@imfi.kspu.ru>");
 MODULE_DESCRIPTION("TI AR7 ethernet driver (CPMAC)");
 MODULE_LICENSE("GPL");
-- 
2.0.0

