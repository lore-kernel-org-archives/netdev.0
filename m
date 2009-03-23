From: Oskar Schirmer <os@emlix.com>
Subject: [patch 2/3] xtensa: s6105 specific configuration for s6gmac
Date: Mon, 23 Mar 2009 15:13:19 +0100
Message-ID: <1237817600-29471-2-git-send-email-os@emlix.com>
References: <1237817600-29471-1-git-send-email-os@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Oskar Schirmer <os@emlix.com>,
	=?utf-8?q?Daniel=20Gl=C3=B6ckner?= <dg@emlix.com>
To: Jeff Garzik <jgarzik@pobox.com>, Chris Zankel <chris@zankel.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.emlix.com ([193.175.82.87]:57594 "EHLO mx1.emlix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757200AbZCWOM0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 10:12:26 -0400
In-Reply-To: <1237817600-29471-1-git-send-email-os@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Platform-specific configuration for the s6gmac driver, including the
PHY interrupt line.

Signed-off-by: Daniel Gl=C3=B6ckner <dg@emlix.com>
Signed-off-by: Oskar Schirmer <os@emlix.com>
---
 arch/xtensa/platforms/s6105/device.c |   91 ++++++++++++++++++++++++++=
++++++++
 arch/xtensa/platforms/s6105/setup.c  |    9 +++
 2 files changed, 100 insertions(+), 0 deletions(-)

diff --git a/arch/xtensa/platforms/s6105/device.c b/arch/xtensa/platfor=
ms/s6105/device.c
index 78b08be..963634a 100644
--- a/arch/xtensa/platforms/s6105/device.c
+++ b/arch/xtensa/platforms/s6105/device.c
@@ -5,14 +5,27 @@
  */
=20
 #include <linux/kernel.h>
+#include <linux/gpio.h>
 #include <linux/init.h>
+#include <linux/irq.h>
+#include <linux/phy.h>
 #include <linux/platform_device.h>
 #include <linux/serial.h>
 #include <linux/serial_8250.h>
=20
 #include <variant/hardware.h>
+#include <variant/dmac.h>
=20
+#include <platform/gpio.h>
+
+#define GPIO3_INTNUM		3
 #define UART_INTNUM		4
+#define GMAC_INTNUM		5
+
+static const signed char gpio3_irq_mappings[] =3D {
+	S6_INTC_GPIO(3),
+	-1
+};
=20
 static const signed char uart_irq_mappings[] =3D {
 	S6_INTC_UART(0),
@@ -20,8 +33,18 @@ static const signed char uart_irq_mappings[] =3D {
 	-1,
 };
=20
+static const signed char gmac_irq_mappings[] =3D {
+	S6_INTC_GMAC_STAT,
+	S6_INTC_GMAC_ERR,
+	S6_INTC_DMA_HOSTTERMCNT(0),
+	S6_INTC_DMA_HOSTTERMCNT(1),
+	-1
+};
+
 const signed char *platform_irq_mappings[NR_IRQS] =3D {
+	[GPIO3_INTNUM] =3D gpio3_irq_mappings,
 	[UART_INTNUM] =3D uart_irq_mappings,
+	[GMAC_INTNUM] =3D gmac_irq_mappings,
 };
=20
 static struct plat_serial8250_port serial_platform_data[] =3D {
@@ -46,6 +69,66 @@ static struct plat_serial8250_port serial_platform_d=
ata[] =3D {
 	{ },
 };
=20
+static struct resource s6_gmac_resource[] =3D {
+	{
+		.name   =3D "mem",
+		.start  =3D (resource_size_t)S6_REG_GMAC,
+		.end    =3D (resource_size_t)S6_REG_GMAC + 0x10000 - 1,
+		.flags  =3D IORESOURCE_MEM,
+	},
+	{
+		.name   =3D "dma",
+		.start  =3D (resource_size_t)
+			DMA_CHNL(S6_REG_HIFDMA, S6_HIFDMA_GMACTX),
+		.end    =3D (resource_size_t)
+			DMA_CHNL(S6_REG_HIFDMA, S6_HIFDMA_GMACTX) + 0x100 - 1,
+		.flags  =3D IORESOURCE_DMA,
+	},
+	{
+		.name   =3D "dma",
+		.start  =3D (resource_size_t)
+			DMA_CHNL(S6_REG_HIFDMA, S6_HIFDMA_GMACRX),
+		.end    =3D (resource_size_t)
+			DMA_CHNL(S6_REG_HIFDMA, S6_HIFDMA_GMACRX) + 0x100 - 1,
+		.flags  =3D IORESOURCE_DMA,
+	},
+	{
+		.name   =3D "io",
+		.start  =3D (resource_size_t)S6_MEM_GMAC,
+		.end    =3D (resource_size_t)S6_MEM_GMAC + 0x2000000 - 1,
+		.flags  =3D IORESOURCE_IO,
+	},
+	{
+		.name   =3D "irq",
+		.start  =3D (resource_size_t)GMAC_INTNUM,
+		.flags  =3D IORESOURCE_IRQ,
+	},
+	{
+		.name   =3D "irq",
+		.start  =3D (resource_size_t)PHY_POLL,
+		.flags  =3D IORESOURCE_IRQ,
+	},
+};
+
+static int __init prepare_phy_irq(int pin)
+{
+	int irq;
+	if (gpio_request(pin, "s6gmac_phy") < 0)
+		goto fail;
+	if (gpio_direction_input(pin) < 0)
+		goto free;
+	irq =3D gpio_to_irq(pin);
+	if (irq < 0)
+		goto free;
+	if (set_irq_type(irq, IRQ_TYPE_LEVEL_LOW) < 0)
+		goto free;
+	return irq;
+free:
+	gpio_free(pin);
+fail:
+	return PHY_POLL;
+}
+
 static struct platform_device platform_devices[] =3D {
 	{
 		.name =3D "serial8250",
@@ -54,12 +137,20 @@ static struct platform_device platform_devices[] =3D=
 {
 			.platform_data =3D serial_platform_data,
 		},
 	},
+	{
+		.name =3D "s6gmac",
+		.id =3D 0,
+		.resource =3D s6_gmac_resource,
+		.num_resources =3D ARRAY_SIZE(s6_gmac_resource),
+	},
 };
=20
 static int __init device_init(void)
 {
 	int i;
=20
+	s6_gmac_resource[5].start =3D prepare_phy_irq(GPIO_PHY_IRQ);
+
 	for (i =3D 0; i < ARRAY_SIZE(platform_devices); i++)
 		platform_device_register(&platform_devices[i]);
 	return 0;
diff --git a/arch/xtensa/platforms/s6105/setup.c b/arch/xtensa/platform=
s/s6105/setup.c
index 1dbf133..e64db1c 100644
--- a/arch/xtensa/platforms/s6105/setup.c
+++ b/arch/xtensa/platforms/s6105/setup.c
@@ -35,12 +35,21 @@ void __init platform_setup(char **cmdline)
 {
 	unsigned long reg;
=20
+	reg =3D readl(S6_REG_GREG1 + S6_GREG1_PLLSEL);
+	reg &=3D ~(S6_GREG1_PLLSEL_GMAC_MASK << S6_GREG1_PLLSEL_GMAC |
+		S6_GREG1_PLLSEL_GMII_MASK << S6_GREG1_PLLSEL_GMII);
+	reg |=3D S6_GREG1_PLLSEL_GMAC_125MHZ << S6_GREG1_PLLSEL_GMAC |
+		S6_GREG1_PLLSEL_GMII_125MHZ << S6_GREG1_PLLSEL_GMII;
+	writel(reg, S6_REG_GREG1 + S6_GREG1_PLLSEL);
+
 	reg =3D readl(S6_REG_GREG1 + S6_GREG1_CLKGATE);
 	reg &=3D ~(1 << S6_GREG1_BLOCK_SB);
+	reg &=3D ~(1 << S6_GREG1_BLOCK_GMAC);
 	writel(reg, S6_REG_GREG1 + S6_GREG1_CLKGATE);
=20
 	reg =3D readl(S6_REG_GREG1 + S6_GREG1_BLOCKENA);
 	reg |=3D 1 << S6_GREG1_BLOCK_SB;
+	reg |=3D 1 << S6_GREG1_BLOCK_GMAC;
 	writel(reg, S6_REG_GREG1 + S6_GREG1_BLOCKENA);
=20
 	printk(KERN_NOTICE "S6105 on Stretch S6000 - "
--=20
1.6.2.107.ge47ee

