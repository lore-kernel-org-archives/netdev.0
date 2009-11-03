From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/2] alchemy: add au1000-eth platform device
Date: Tue, 3 Nov 2009 22:14:30 +0100
Message-ID: <200911032214.30453.florian@openwrt.org>
References: <200908170105.38154.florian@openwrt.org> <200910171048.24962.florian@openwrt.org> <4AE1DEFD.4090902@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	Manuel Lauss <manuel.lauss@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:47720 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201AbZKCVOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 16:14:32 -0500
Received: by ey-out-2122.google.com with SMTP id d26so749915eyd.19
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 13:14:36 -0800 (PST)
In-Reply-To: <4AE1DEFD.4090902@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Friday 23 October 2009 18:51:09 Sergei Shtylyov wrote:
> Hello.
> 
> Florian Fainelli wrote:
> > Please find below and updated version, hopefully addressing most if not
> > all of your comments.
> 
>     Thanks. I still have some comments on the code testing the NI2 bit. :-)

This version hopefully addresses your last comments. Thanks !
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2] alchemy: add au1000-eth platform device (v4)

This patch makes the board code register the au1000-eth
platform device. The au1000-eth platform data can be
overriden with the au1xxx_override_eth_cfg function
like it has to be done for the Bosporus board which uses
a different MAC/PHY setup.

Changes from v3:
- declare a static au1000_eth_platform_data structure for bosporus and
initialize it
- remove parenthis and bit shifting on SYS_PF_NI2

Changes from v2:
- declared the au1000-eth second driver instance platform_data
- made the override function generic and pass it the port number too

Changes from v1:
- remove per-board platform.c file
- add an override function to pass custom eth0 platform_data PHY settings

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/arch/mips/alchemy/common/platform.c b/arch/mips/alchemy/common/platform.c
index 3be14b0..3fbe30c 100644
--- a/arch/mips/alchemy/common/platform.c
+++ b/arch/mips/alchemy/common/platform.c
@@ -19,6 +19,7 @@
 #include <asm/mach-au1x00/au1xxx.h>
 #include <asm/mach-au1x00/au1xxx_dbdma.h>
 #include <asm/mach-au1x00/au1100_mmc.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
 
 #define PORT(_base, _irq)					\
 	{							\
@@ -326,6 +327,88 @@ static struct platform_device pbdb_smbus_device = {
 };
 #endif
 
+/* Macro to help defining the Ethernet MAC resources */
+#define MAC_RES(_base, _enable, _irq)			\
+	{						\
+		.start	= CPHYSADDR(_base),		\
+		.end	= CPHYSADDR(_base + 0xffff),	\
+		.flags	= IORESOURCE_MEM,		\
+	},						\
+	{						\
+		.start	= CPHYSADDR(_enable),		\
+		.end	= CPHYSADDR(_enable + 0x3),	\
+		.flags	= IORESOURCE_MEM,		\
+	},						\
+	{						\
+		.start	= _irq,				\
+		.end	= _irq,				\
+		.flags	= IORESOURCE_IRQ		\
+	}
+
+static struct resource au1xxx_eth0_resources[] = {
+#if defined(CONFIG_SOC_AU1000)
+	MAC_RES(AU1000_ETH0_BASE, AU1000_MAC0_ENABLE, AU1000_MAC0_DMA_INT),
+#elif defined(CONFIG_SOC_AU1100)
+	MAC_RES(AU1100_ETH0_BASE, AU1100_MAC0_ENABLE, AU1100_MAC0_DMA_INT),
+#elif defined(CONFIG_SOC_AU1550)
+	MAC_RES(AU1550_ETH0_BASE, AU1550_MAC0_ENABLE, AU1550_MAC0_DMA_INT),
+#elif defined(CONFIG_SOC_AU1500)
+	MAC_RES(AU1500_ETH0_BASE, AU1500_MAC0_ENABLE, AU1500_MAC0_DMA_INT),
+#endif
+};
+
+static struct resource au1xxx_eth1_resources[] = {
+#if defined(CONFIG_SOC_AU1000)
+	MAC_RES(AU1000_ETH1_BASE, AU1000_MAC1_ENABLE, AU1000_MAC1_DMA_INT),
+#elif defined(CONFIG_SOC_AU1550)
+	MAC_RES(AU1550_ETH1_BASE, AU1550_MAC1_ENABLE, AU1550_MAC1_DMA_INT),
+#elif defined(CONFIG_SOC_AU1500)
+	MAC_RES(AU1500_ETH1_BASE, AU1500_MAC1_ENABLE, AU1500_MAC1_DMA_INT),
+#endif
+};
+
+static struct au1000_eth_platform_data au1xxx_eth0_platform_data = {
+	.phy1_search_mac0 = 1,
+};
+
+static struct platform_device au1xxx_eth0_device = {
+	.name		= "au1000-eth",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	= au1xxx_eth0_resources,
+	.dev.platform_data = &au1xxx_eth0_platform_data,
+};
+
+#ifndef CONFIG_SOC_AU1100
+static struct au1000_eth_platform_data au1xxx_eth1_platform_data = {
+	.phy1_search_mac0 = 1,
+};
+
+static struct platform_device au1xxx_eth1_device = {
+	.name		= "au1000-eth",
+	.id		= 1,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth1_resources),
+	.resource	= au1xxx_eth1_resources,
+	.dev.platform_data = &au1xxx_eth1_platform_data,
+};
+#endif
+
+void __init au1xxx_override_eth_cfg(unsigned int port,
+			struct au1000_eth_platform_data *eth_data)
+{
+	if (!eth_data || port > 1)
+		return;
+
+	if (port == 0)
+		memcpy(&au1xxx_eth0_platform_data, eth_data,
+			sizeof(struct au1000_eth_platform_data));
+#ifndef CONFIG_SOC_AU1100
+	else
+		memcpy(&au1xxx_eth1_platform_data, eth_data,
+			sizeof(struct au1000_eth_platform_data));
+#endif
+}
+
 static struct platform_device *au1xxx_platform_devices[] __initdata = {
 	&au1xx0_uart_device,
 	&au1xxx_usb_ohci_device,
@@ -345,6 +428,7 @@ static struct platform_device *au1xxx_platform_devices[] __initdata = {
 #ifdef SMBUS_PSC_BASE
 	&pbdb_smbus_device,
 #endif
+	&au1xxx_eth0_device,
 };
 
 static int __init au1xxx_platform_init(void)
@@ -356,6 +440,12 @@ static int __init au1xxx_platform_init(void)
 	for (i = 0; au1x00_uart_data[i].flags; i++)
 		au1x00_uart_data[i].uartclk = uartclk;
 
+#ifndef CONFIG_SOC_AU1100
+	/* Register second MAC if enabled in pinfunc */
+	if (!(au_readl(SYS_PINFUNC) & (u32)SYS_PF_NI2))
+		platform_device_register(&au1xxx_eth1_device);
+#endif
+
 	return platform_add_devices(au1xxx_platform_devices,
 				    ARRAY_SIZE(au1xxx_platform_devices));
 }
diff --git a/arch/mips/alchemy/devboards/db1x00/board_setup.c b/arch/mips/alchemy/devboards/db1x00/board_setup.c
index 7aee14d..ad26db2 100644
--- a/arch/mips/alchemy/devboards/db1x00/board_setup.c
+++ b/arch/mips/alchemy/devboards/db1x00/board_setup.c
@@ -32,6 +32,7 @@
 #include <linux/interrupt.h>
 
 #include <asm/mach-au1x00/au1000.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
 #include <asm/mach-db1x00/db1x00.h>
 #include <asm/mach-db1x00/bcsr.h>
 
@@ -43,6 +44,18 @@ char irq_tab_alchemy[][5] __initdata = {
 	[13] = { -1, AU1500_PCI_INTA, AU1500_PCI_INTB, AU1500_PCI_INTC, AU1500_PCI_INTD }, /* IDSEL 13 - PCI slot */
 };
 #endif
+	
+/*
+ * Micrel/Kendin 5 port switch attached to MAC0,
+ * MAC0 is associated with PHY address 5 (== WAN port)
+ * MAC1 is not associated with any PHY, since it's connected directly
+ * to the switch.
+ * no interrupts are used
+ */
+static struct au1000_eth_platform_data eth0_pdata = {
+	.phy_static_config	= 1,
+	.phy_addr		= 5,
+};
 
 #ifdef CONFIG_MIPS_BOSPORUS
 char irq_tab_alchemy[][5] __initdata = {
@@ -50,6 +63,8 @@ char irq_tab_alchemy[][5] __initdata = {
 	[12] = { -1, AU1500_PCI_INTA, 0xff, 0xff, 0xff }, /* IDSEL 12 - SN1741   */
 	[13] = { -1, AU1500_PCI_INTA, AU1500_PCI_INTB, AU1500_PCI_INTC, AU1500_PCI_INTD }, /* IDSEL 13 - PCI slot */
 };
+
+
 #endif
 
 #ifdef CONFIG_MIPS_MIRAGE
@@ -103,6 +118,8 @@ void __init board_setup(void)
 	printk(KERN_INFO "AMD Alchemy Au1100/Db1100 Board\n");
 #endif
 #ifdef CONFIG_MIPS_BOSPORUS
+	au1xxx_override_eth_cfg(0, &eth0_pdata);
+
 	printk(KERN_INFO "AMD Alchemy Bosporus Board\n");
 #endif
 #ifdef CONFIG_MIPS_MIRAGE
diff --git a/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h b/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
new file mode 100644
index 0000000..f30529e
--- /dev/null
+++ b/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
@@ -0,0 +1,18 @@
+#ifndef __AU1X00_ETH_DATA_H
+#define __AU1X00_ETH_DATA_H
+
+/* Platform specific PHY configuration passed to the MAC driver */
+struct au1000_eth_platform_data {
+	int phy_static_config;
+	int phy_search_highest_addr;
+	int phy1_search_mac0;
+	int phy_addr;
+	int phy_busid;
+	int phy_irq;
+};
+
+void __init au1xxx_override_eth_cfg(unsigned port,
+			struct au1000_eth_platform_data *eth_data);
+
+#endif /* __AU1X00_ETH_DATA_H */
+
