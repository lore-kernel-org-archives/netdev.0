From: Greg Ungerer <gerg@snapgear.com>
Subject: [PATCH 1/2] fec: add FEC platform support to ColdFire CPU's setup code
Date: Tue, 17 Feb 2009 10:53:01 +1000
Message-ID: <200902170053.n1H0r15O002064@localhost.localdomain>
Cc: gerg@uclinux.org, netdev@vger.kernel.org
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:49295 "EHLO
	snapgear.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751331AbZBQAxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 19:53:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

m68knommu: add FEC platform support to ColdFire CPU's setup code

Move the per-CPU FEC driver setup code into the actual platform
setup code for each ColdFire CPU varient.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>


diff a/arch/m68knommu/platform/520x/config.c b/arch/m68knommu/platform/520x/config.c
--- a/arch/m68knommu/platform/520x/config.c
+++ b/arch/m68knommu/platform/520x/config.c
@@ -49,8 +49,39 @@ static struct platform_device m520x_uart = {
 	.dev.platform_data	= m520x_uart_platform,
 };
 
+static struct resource m520x_fec_resources[] = {
+	{
+		.start		= MCF_MBAR + 0x30000,
+		.end		= MCF_MBAR + 0x30000 + 0x7ff,
+		.flags		= IORESOURCE_MEM,
+	},
+	{
+		.start		= 64 + 36,
+		.end		= 64 + 36,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 40,
+		.end		= 64 + 40,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 42,
+		.end		= 64 + 42,
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device m520x_fec = {
+	.name			= "fec",
+	.id			= 0,
+	.num_resources		= ARRAY_SIZE(m520x_fec_resources),
+	.resource		= m520x_fec_resources,
+};
+
 static struct platform_device *m520x_devices[] __initdata = {
 	&m520x_uart,
+	&m520x_fec,
 };
 
 /***************************************************************************/
@@ -103,6 +134,30 @@ static void __init m520x_uarts_init(void)
 
 /***************************************************************************/
 
+static void __init m520x_fec_init(void)
+{
+	u32 imr;
+	u8 v;
+
+	/* Unmask FEC interrupts at ColdFire interrupt controller */
+	writeb(0x4, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 36);
+	writeb(0x4, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 40);
+	writeb(0x4, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 42);
+
+	imr = readl(MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH);
+	imr &= ~0x0001FFF0;
+	writel(imr, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH);
+	
+	/* Set multi-function pins to ethernet mode */
+	v = readb(MCF_IPSBAR + MCF_GPIO_PAR_FEC);
+	writeb(v | 0xf0, MCF_IPSBAR + MCF_GPIO_PAR_FEC);
+	
+	v = readb(MCF_IPSBAR + MCF_GPIO_PAR_FECI2C);
+	writeb(v | 0x0f, MCF_IPSBAR + MCF_GPIO_PAR_FECI2C);
+}
+
+/***************************************************************************/
+
 /*
  *  Program the vector to be an auto-vectored.
  */
@@ -118,6 +173,7 @@ void __init config_BSP(char *commandp, int size)
 {
 	mach_reset = coldfire_reset;
 	m520x_uarts_init();
+	m520x_fec_init();
 }
 
 /***************************************************************************/
diff a/arch/m68knommu/platform/523x/config.c b/arch/m68knommu/platform/523x/config.c
--- a/arch/m68knommu/platform/523x/config.c
+++ b/arch/m68knommu/platform/523x/config.c
@@ -50,8 +50,39 @@ static struct platform_device m523x_uart = {
 	.dev.platform_data	= m523x_uart_platform,
 };
 
+static struct resource m523x_fec_resources[] = {
+	{
+		.start		= MCF_MBAR + 0x1000,
+		.end		= MCF_MBAR + 0x1000 + 0x7ff,
+		.flags		= IORESOURCE_MEM,
+	},
+	{
+		.start		= 64 + 23,
+		.end		= 64 + 23,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 27,
+		.end		= 64 + 27,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 29,
+		.end		= 64 + 29,
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device m523x_fec = {
+	.name			= "fec",
+	.id			= 0,
+	.num_resources		= ARRAY_SIZE(m523x_fec_resources),
+	.resource		= m523x_fec_resources,
+};
+
 static struct platform_device *m523x_devices[] __initdata = {
 	&m523x_uart,
+	&m523x_fec,
 };
 
 /***************************************************************************/
@@ -83,6 +114,25 @@ static void __init m523x_uarts_init(void)
 
 /***************************************************************************/
 
+static void __init m523x_fec_init(void)
+{
+	u32 imr;
+
+	/* Unmask FEC interrupts at ColdFire interrupt controller */
+	writeb(0x28, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 23);
+	writeb(0x27, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 27);
+	writeb(0x26, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 29);
+
+	imr = readl(MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH);
+	imr &= ~0xf;
+	writel(imr, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH);
+	imr = readl(MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRL);
+	imr &= ~0xff800001;
+	writel(imr, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRL);
+}
+
+/***************************************************************************/
+
 void mcf_disableall(void)
 {
 	*((volatile unsigned long *) (MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH)) = 0xffffffff;
@@ -103,6 +153,7 @@ void __init config_BSP(char *commandp, int size)
 	mcf_disableall();
 	mach_reset = coldfire_reset;
 	m523x_uarts_init();
+	m523x_fec_init();
 }
 
 /***************************************************************************/
diff a/arch/m68knommu/platform/5272/config.c b/arch/m68knommu/platform/5272/config.c
--- a/arch/m68knommu/platform/5272/config.c
+++ b/arch/m68knommu/platform/5272/config.c
@@ -55,8 +55,39 @@ static struct platform_device m5272_uart = {
 	.dev.platform_data	= m5272_uart_platform,
 };
 
+static struct resource m5272_fec_resources[] = {
+	{
+		.start		= MCF_MBAR + 0x840,
+		.end		= MCF_MBAR + 0x840 + 0x1cf,
+		.flags		= IORESOURCE_MEM,
+	},
+	{
+		.start		= 86,
+		.end		= 86,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 87,
+		.end		= 87,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 88,
+		.end		= 88,
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device m5272_fec = {
+	.name			= "fec",
+	.id			= 0,
+	.num_resources		= ARRAY_SIZE(m5272_fec_resources),
+	.resource		= m5272_fec_resources,
+};
+
 static struct platform_device *m5272_devices[] __initdata = {
 	&m5272_uart,
+	&m5272_fec,
 };
 
 /***************************************************************************/
@@ -91,6 +122,22 @@ static void __init m5272_uarts_init(void)
 
 /***************************************************************************/
 
+static void __init m5272_fec_init(void)
+{
+	u32 imr;
+
+	/* Unmask FEC interrupts at ColdFire interrupt controller */
+	imr = readl(MCF_MBAR + MCFSIM_ICR3);
+	imr = (imr & ~0x00000fff) | 0x00000ddd;
+	writel(imr, MCF_MBAR + MCFSIM_ICR3);
+
+	imr = readl(MCF_MBAR + MCFSIM_ICR1);
+	imr = (imr & ~0x0f000000) | 0x0d000000;
+	writel(imr, MCF_MBAR + MCFSIM_ICR1);
+}
+
+/***************************************************************************/
+
 void mcf_disableall(void)
 {
 	volatile unsigned long	*icrp;
@@ -155,6 +202,7 @@ void __init config_BSP(char *commandp, int size)
 static int __init init_BSP(void)
 {
 	m5272_uarts_init();
+	m5272_fec_init();
 	platform_add_devices(m5272_devices, ARRAY_SIZE(m5272_devices));
 	return 0;
 }
diff a/arch/m68knommu/platform/527x/config.c b/arch/m68knommu/platform/527x/config.c
--- a/arch/m68knommu/platform/527x/config.c
+++ b/arch/m68knommu/platform/527x/config.c
@@ -50,8 +50,73 @@ static struct platform_device m527x_uart = {
 	.dev.platform_data	= m527x_uart_platform,
 };
 
+static struct resource m527x_fec0_resources[] = {
+	{
+		.start		= MCF_MBAR + 0x1000,
+		.end		= MCF_MBAR + 0x1000 + 0x7ff,
+		.flags		= IORESOURCE_MEM,
+	},
+	{
+		.start		= 64 + 23,
+		.end		= 64 + 23,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 27,
+		.end		= 64 + 27,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 29,
+		.end		= 64 + 29,
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct resource m527x_fec1_resources[] = {
+	{
+		.start		= MCF_MBAR + 0x1800,
+		.end		= MCF_MBAR + 0x1800 + 0x7ff,
+		.flags		= IORESOURCE_MEM,
+	},
+	{
+		.start		= 128 + 23,
+		.end		= 128 + 23,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 128 + 27,
+		.end		= 128 + 27,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 128 + 29,
+		.end		= 128 + 29,
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device m527x_fec[] = {
+	{
+		.name		= "fec",
+		.id		= 0,
+		.num_resources	= ARRAY_SIZE(m527x_fec0_resources),
+		.resource	= m527x_fec0_resources,
+	},
+	{
+		.name		= "fec",
+		.id		= 1,
+		.num_resources	= ARRAY_SIZE(m527x_fec1_resources),
+		.resource	= m527x_fec1_resources,
+	},
+};
+
 static struct platform_device *m527x_devices[] __initdata = {
 	&m527x_uart,
+	&m527x_fec[0],
+#ifdef CONFIG_FEC2
+	&m527x_fec[1],
+#endif
 };
 
 /***************************************************************************/
@@ -97,6 +162,51 @@ static void __init m527x_uarts_init(void)
 
 /***************************************************************************/
 
+static void __init m527x_fec_irq_init(int nr)
+{
+	unsigned long base;
+	u32 imr;
+
+	base = MCF_IPSBAR + (nr ? MCFICM_INTC1 : MCFICM_INTC0);
+
+	writeb(0x28, base + MCFINTC_ICR0 + 23);
+	writeb(0x27, base + MCFINTC_ICR0 + 27);
+	writeb(0x26, base + MCFINTC_ICR0 + 29);
+
+	imr = readl(base + MCFINTC_IMRH);
+	imr &= ~0xf;
+	writel(imr, base + MCFINTC_IMRH);
+	imr = readl(base + MCFINTC_IMRL);
+	imr &= ~0xff800001;
+	writel(imr, base + MCFINTC_IMRL);
+}
+
+static void __init m527x_fec_init(void)
+{
+	u16 par;
+	u8 v;
+
+	m527x_fec_irq_init(0);
+
+	/* Set multi-function pins to ethernet mode for fec0 */
+	par = readw(MCF_IPSBAR + 0x100082);
+	writew(par | 0xf00, MCF_IPSBAR + 0x100082);
+	v = readb(MCF_IPSBAR + 0x100078);
+	writeb(v | 0xc0, MCF_IPSBAR + 0x100078);
+
+#ifdef CONFIG_FEC2
+	m527x_fec_irq_init(1);
+
+	/* Set multi-function pins to ethernet mode for fec1 */
+	par = readw(MCF_IPSBAR + 0x100082);
+	writew(par | 0xa0, MCF_IPSBAR + 0x100082);
+	v = readb(MCF_IPSBAR + 0x100079);
+	writeb(v | 0xc0, MCF_IPSBAR + 0x100079);
+#endif
+}
+
+/***************************************************************************/
+
 void mcf_disableall(void)
 {
 	*((volatile unsigned long *) (MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH)) = 0xffffffff;
@@ -116,13 +226,14 @@ void __init config_BSP(char *commandp, int size)
 {
 	mcf_disableall();
 	mach_reset = coldfire_reset;
+	m527x_uarts_init();
+	m527x_fec_init();
 }
 
 /***************************************************************************/
 
 static int __init init_BSP(void)
 {
-	m527x_uarts_init();
 	platform_add_devices(m527x_devices, ARRAY_SIZE(m527x_devices));
 	return 0;
 }
diff a/arch/m68knommu/platform/528x/config.c b/arch/m68knommu/platform/528x/config.c
--- a/arch/m68knommu/platform/528x/config.c
+++ b/arch/m68knommu/platform/528x/config.c
@@ -285,8 +284,40 @@ static struct platform_device m528x_uart = {
 	.dev.platform_data	= m528x_uart_platform,
 };
 
+static struct resource m528x_fec_resources[] = {
+	{
+		.start		= MCF_MBAR + 0x1000,
+		.end		= MCF_MBAR + 0x1000 + 0x7ff,
+		.flags		= IORESOURCE_MEM,
+	},
+	{
+		.start		= 64 + 23,
+		.end		= 64 + 23,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 27,
+		.end		= 64 + 27,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 29,
+		.end		= 64 + 29,
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device m528x_fec = {
+	.name			= "fec",
+	.id			= 0,
+	.num_resources		= ARRAY_SIZE(m528x_fec_resources),
+	.resource		= m528x_fec_resources,
+};
+
+
 static struct platform_device *m528x_devices[] __initdata = {
 	&m528x_uart,
+	&m528x_fec,
 };
 
 /***************************************************************************/
@@ -327,6 +358,31 @@ static void __init m528x_uarts_init(void)
 
 /***************************************************************************/
 
+static void __init m528x_fec_init(void)
+{
+	u32 imr;
+	u16 v16;
+
+	/* Unmask FEC interrupts at ColdFire interrupt controller */
+	writeb(0x28, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 23);
+	writeb(0x27, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 27);
+	writeb(0x26, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_ICR0 + 29);
+
+	imr = readl(MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH);
+	imr &= ~0xf;
+	writel(imr, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH);
+	imr = readl(MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRL);
+	imr &= ~0xff800001;
+	writel(imr, MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRL);
+
+	/* Set multi-function pins to ethernet mode for fec0 */
+	v16 = readw(MCF_IPSBAR + 0x100056);
+	writew(v16 | 0xf00, MCF_IPSBAR + 0x100056);
+	writeb(0xc0, MCF_IPSBAR + 0x100058);
+}
+
+/***************************************************************************/
+
 void mcf_disableall(void)
 {
 	*((volatile unsigned long *) (MCF_IPSBAR + MCFICM_INTC0 + MCFINTC_IMRH)) = 0xffffffff;
@@ -386,6 +442,7 @@ void __init config_BSP(char *commandp, int size)
 static int __init init_BSP(void)
 {
 	m528x_uarts_init();
+	m528x_fec_init();
 	platform_add_devices(m528x_devices, ARRAY_SIZE(m528x_devices));
 	return 0;
 }
diff a/arch/m68knommu/platform/532x/config.c b/arch/m68knommu/platform/532x/config.c
--- a/arch/m68knommu/platform/532x/config.c
+++ b/arch/m68knommu/platform/532x/config.c
@@ -61,8 +61,38 @@ static struct platform_device m532x_uart = {
 	.dev.platform_data	= m532x_uart_platform,
 };
 
+static struct resource m532x_fec_resources[] = {
+	{
+		.start		= 0xfc030000,
+		.end		= 0xfc0307ff,
+		.flags		= IORESOURCE_MEM,
+	},
+	{
+		.start		= 64 + 36,
+		.end		= 64 + 36,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 40,
+		.end		= 64 + 40,
+		.flags		= IORESOURCE_IRQ,
+	},
+	{
+		.start		= 64 + 42,
+		.end		= 64 + 42,
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device m532x_fec = {
+	.name			= "fec",
+	.id			= 0,
+	.num_resources		= ARRAY_SIZE(m532x_fec_resources),
+	.resource		= m532x_fec_resources,
+};
 static struct platform_device *m532x_devices[] __initdata = {
 	&m532x_uart,
+	&m532x_fec,
 };
 
 /***************************************************************************/
@@ -93,6 +123,24 @@ static void __init m532x_uarts_init(void)
 	for (line = 0; (line < nrlines); line++)
 		m532x_uart_init_line(line, m532x_uart_platform[line].irq);
 }
+/***************************************************************************/
+
+static void __init m532x_fec_init(void)
+{
+	/* Unmask FEC interrupts at ColdFire interrupt controller */
+	MCF_INTC0_ICR36 = 0x2;
+	MCF_INTC0_ICR40 = 0x2;
+	MCF_INTC0_ICR42 = 0x2;
+
+	MCF_INTC0_IMRH &= ~(MCF_INTC_IMRH_INT_MASK36 |
+		MCF_INTC_IMRH_INT_MASK40 | MCF_INTC_IMRH_INT_MASK42);
+
+	/* Set multi-function pins to ethernet mode for fec0 */
+	MCF_GPIO_PAR_FECI2C |= (MCF_GPIO_PAR_FECI2C_PAR_MDC_EMDC |
+		MCF_GPIO_PAR_FECI2C_PAR_MDIO_EMDIO);
+	MCF_GPIO_PAR_FEC = (MCF_GPIO_PAR_FEC_PAR_FEC_7W_FEC |
+		MCF_GPIO_PAR_FEC_PAR_FEC_MII_FEC);
+}
 
 /***************************************************************************/
 
@@ -150,6 +198,7 @@ void __init config_BSP(char *commandp, int size)
 static int __init init_BSP(void)
 {
 	m532x_uarts_init();
+	m532x_fec_init();
 	platform_add_devices(m532x_devices, ARRAY_SIZE(m532x_devices));
 	return 0;
 }
