From: Alban Bedel <albeu@free.fr>
Subject: [PATCH] MIPS: Remove most of the custom gpio.h
Date: Wed, 22 Jul 2015 19:33:08 +0200
Message-ID: <1437586416-14735-1-git-send-email-albeu@free.fr>
Cc: Alban Bedel <albeu@free.fr>, Ralf Baechle <ralf@linux-mips.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Florian Fainelli <florian@openwrt.org>,
	Joe Perches <joe@perches.com>,
	Daniel Walter <dwalter@google.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Huacai Chen <chenhc@lemote.com>,
	Andrew Bresticker <abrestic@chromium.org>,
	James Hartley <james.hartley@imgtec.com>,
	Paul Burton <paul.burton@imgtec.com>,
	Waldemar Brodkorb <wbx@openadk.org>,
	James Hogan <james.hogan@imgtec.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	Levente Kurusa <levex@linux.com>,
	abdoulaye berthe <berthe.ab@gmail.com>,
	Wolfram Sang <wsa
To: linux-mips@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently CONFIG_ARCH_HAVE_CUSTOM_GPIO_H is defined for all MIPS
machines, and each machine type provides its own gpio.h. However only
the Alchemy machine really use the feature, all other machines only
use the default wrappers.

For most machine types we can just remove the custom gpio.h, as well
as the custom wrappers if some exists. A few more fixes are need in
a few drivers as they rely on linux/gpio.h to provides some machine
specific definitions, or used asm/gpio.h instead of linux/gpio.h for
the gpio API.

Signed-off-by: Alban Bedel <albeu@free.fr>
---

This patch is based on my previous serie:
"MIPS: ath79: Move the GPIO driver to drivers/gpio".

For testing I tried to build all mips defconfig, however my toolchain
couldn't handle a few configs: ip28 malta_qemu_32r6 maltasmvp_eva
sead3micro. If somebody can test these that would be more than welcome.

It might well be that some more drivers for MIPS devices that are not
enabled in the defconfig will break because of this change, so more
testing would be nice :)

Regarding Alchemy I'm not sure what to do. It use a little more
complex setup, quoting arch/mips/include/asm/mach-au1x00/gpio.h:

/* Linux gpio framework integration.
*
* 4 use cases of Alchemy GPIOS:
*(1) GPIOLIB=y, ALCHEMY_GPIO_INDIRECT=y:
*       Board must register gpiochips.
*(2) GPIOLIB=y, ALCHEMY_GPIO_INDIRECT=n:
*       A gpiochip for the 75 GPIOs is registered.
*
*(3) GPIOLIB=n, ALCHEMY_GPIO_INDIRECT=y:
*       the boards' gpio.h must provide the linux gpio wrapper
functions,
*
*(4) GPIOLIB=n, ALCHEMY_GPIO_INDIRECT=n:
*       inlinable gpio functions are provided which enable access to the
*       Au1300 gpios only by using the numbers straight out of the data-
*       sheets.

* Cases 1 and 3 are intended for boards which want to provide their own
* GPIO namespace and -operations (i.e. for example you have 8 GPIOs
* which are in part provided by spare Au1300 GPIO pins and in part by
* an external FPGA but you still want them to be accssible in linux
* as gpio0-7. The board can of course use the alchemy_gpioX_* functions
* as required).
*/

This sound to me like this is really not needed anymore. Is there any
users of this left, or can it just go?

Alban
---
 arch/mips/Kconfig                               |  2 +-
 arch/mips/ar7/gpio.c                            | 12 ++------
 arch/mips/ar7/platform.c                        |  1 -
 arch/mips/ar7/setup.c                           |  1 -
 arch/mips/include/asm/mach-ar7/ar7.h            |  4 +++
 arch/mips/include/asm/mach-ar7/gpio.h           | 41 -------------------------
 arch/mips/include/asm/mach-ath25/gpio.h         | 16 ----------
 arch/mips/include/asm/mach-ath79/gpio.h         | 26 ----------------
 arch/mips/include/asm/mach-bcm47xx/gpio.h       | 17 ----------
 arch/mips/include/asm/mach-bcm63xx/gpio.h       | 15 ---------
 arch/mips/include/asm/mach-cavium-octeon/gpio.h | 21 -------------
 arch/mips/include/asm/mach-generic/gpio.h       | 21 -------------
 arch/mips/include/asm/mach-jz4740/gpio.h        |  2 --
 arch/mips/include/asm/mach-lantiq/gpio.h        | 13 --------
 arch/mips/include/asm/mach-loongson64/gpio.h    | 36 ----------------------
 arch/mips/include/asm/mach-pistachio/gpio.h     | 21 -------------
 arch/mips/include/asm/mach-rc32434/gpio.h       | 12 --------
 arch/mips/jz4740/gpio.c                         | 12 --------
 arch/mips/rb532/devices.c                       |  1 +
 arch/mips/txx9/generic/setup.c                  | 16 ----------
 drivers/ata/pata_rb532_cf.c                     |  3 +-
 drivers/gpio/gpio-ath79.c                       | 32 -------------------
 drivers/input/misc/rb532_button.c               |  1 +
 drivers/net/ethernet/ti/cpmac.c                 |  2 ++
 24 files changed, 13 insertions(+), 315 deletions(-)
 delete mode 100644 arch/mips/include/asm/mach-ar7/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-ath25/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-ath79/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-bcm47xx/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-bcm63xx/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-cavium-octeon/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-generic/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-lantiq/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-loongson64/gpio.h
 delete mode 100644 arch/mips/include/asm/mach-pistachio/gpio.h

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index d896ffb..c3b2f38 100644
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
@@ -77,6 +76,7 @@ config MIPS_ALCHEMY
 	select SYS_SUPPORTS_32BIT_KERNEL
 	select SYS_SUPPORTS_APM_EMULATION
 	select ARCH_REQUIRE_GPIOLIB
+	select ARCH_HAVE_CUSTOM_GPIO_H
 	select SYS_SUPPORTS_ZBOOT
 	select COMMON_CLK
 
diff --git a/arch/mips/ar7/gpio.c b/arch/mips/ar7/gpio.c
index d8dbd8f..ae29906 100644
--- a/arch/mips/ar7/gpio.c
+++ b/arch/mips/ar7/gpio.c
@@ -21,7 +21,7 @@
 #include <linux/module.h>
 #include <linux/gpio.h>
 
-#include <asm/mach-ar7/gpio.h>
+#include <asm/mach-ar7/ar7.h>
 
 struct ar7_gpio_chip {
 	void __iomem		*regs;
@@ -94,9 +94,6 @@ static int titan_gpio_direction_input(struct gpio_chip *chip, unsigned gpio)
 	void __iomem *gpio_dir0 = gpch->regs + TITAN_GPIO_DIR_0;
 	void __iomem *gpio_dir1 = gpch->regs + TITAN_GPIO_DIR_1;
 
-	if (gpio >= TITAN_GPIO_MAX)
-		return -EINVAL;
-
 	writel(readl(gpio >> 5 ? gpio_dir1 : gpio_dir0) | (1 << (gpio & 0x1f)),
 			gpio >> 5 ? gpio_dir1 : gpio_dir0);
 	return 0;
@@ -123,9 +120,6 @@ static int titan_gpio_direction_output(struct gpio_chip *chip,
 	void __iomem *gpio_dir0 = gpch->regs + TITAN_GPIO_DIR_0;
 	void __iomem *gpio_dir1 = gpch->regs + TITAN_GPIO_DIR_1;
 
-	if (gpio >= TITAN_GPIO_MAX)
-		return -EINVAL;
-
 	titan_gpio_set_value(chip, gpio, value);
 	writel(readl(gpio >> 5 ? gpio_dir1 : gpio_dir0) & ~(1 <<
 		(gpio & 0x1f)), gpio >> 5 ? gpio_dir1 : gpio_dir0);
@@ -141,7 +135,7 @@ static struct ar7_gpio_chip ar7_gpio_chip = {
 		.set			= ar7_gpio_set_value,
 		.get			= ar7_gpio_get_value,
 		.base			= 0,
-		.ngpio			= AR7_GPIO_MAX,
+		.ngpio			= 32,
 	}
 };
 
@@ -153,7 +147,7 @@ static struct ar7_gpio_chip titan_gpio_chip = {
 		.set			= titan_gpio_set_value,
 		.get			= titan_gpio_get_value,
 		.base			= 0,
-		.ngpio			= TITAN_GPIO_MAX,
+		.ngpio			= 51,
 	}
 };
 
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
diff --git a/arch/mips/jz4740/gpio.c b/arch/mips/jz4740/gpio.c
index 54c80d4..3dc500c 100644
--- a/arch/mips/jz4740/gpio.c
+++ b/arch/mips/jz4740/gpio.c
@@ -262,18 +262,6 @@ uint32_t jz_gpio_port_get_value(int port, uint32_t mask)
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
