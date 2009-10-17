From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/2] alchemy: add au1000-eth platform device
Date: Sat, 17 Oct 2009 10:48:23 +0200
Message-ID: <200910171048.24962.florian@openwrt.org>
References: <200908170105.38154.florian@openwrt.org> <4A969519.7010604@ru.mvista.com> <200908271655.11086.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	Manuel Lauss <manuel.lauss@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:35189 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbZJQIsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 04:48:23 -0400
Received: by ewy4 with SMTP id 4so67568ewy.37
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2009 01:48:26 -0700 (PDT)
In-Reply-To: <200908271655.11086.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Please find below and updated version, hopefully addressing most if not all
of your comments.
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2] alchemy: add au1000-eth platform device (v3)

This patch makes the board code register the au1000-eth
platform device. The au1000-eth platform data can be
overriden with the au1xxx_override_eth_cfg function
like it has to be done for the Bosporus board which uses
a different MAC/PHY setup.

Changes from v2:
- declared the au1000-eth second driver instance platform_data
- made the override function generic and pass it the port number too

Changes from v1:
- remove per-board platform.c file
- add an override function to pass custom eth0 platform_data PHY settings

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/arch/mips/alchemy/common/platform.c b/arch/mips/alchemy/common/platform.c
index 195e5b3..167b24e 100644
--- a/arch/mips/alchemy/common/platform.c
+++ b/arch/mips/alchemy/common/platform.c
@@ -19,6 +19,7 @@
 #include <asm/mach-au1x00/au1xxx.h>
 #include <asm/mach-au1x00/au1xxx_dbdma.h>
 #include <asm/mach-au1x00/au1100_mmc.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
 
 #define PORT(_base, _irq)					\
 	{							\
@@ -324,6 +325,88 @@ static struct platform_device pbdb_smbus_device = {
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
@@ -343,6 +426,7 @@ static struct platform_device *au1xxx_platform_devices[] __initdata = {
 #ifdef SMBUS_PSC_BASE
 	&pbdb_smbus_device,
 #endif
+	&au1xxx_eth0_device,
 };
 
 static int __init au1xxx_platform_init(void)
@@ -354,6 +438,12 @@ static int __init au1xxx_platform_init(void)
 	for (i = 0; au1x00_uart_data[i].flags; i++)
 		au1x00_uart_data[i].uartclk = uartclk;
 
+#ifndef CONFIG_SOC_AU1100
+	/* Register second MAC if enabled in pinfunc */
+	if (!(au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4)
+		platform_device_register(&au1xxx_eth1_device);
+#endif
+
 	return platform_add_devices(au1xxx_platform_devices,
 				    ARRAY_SIZE(au1xxx_platform_devices));
 }
diff --git a/arch/mips/alchemy/devboards/db1x00/board_setup.c b/arch/mips/alchemy/devboards/db1x00/board_setup.c
index 64eb26f..f938924 100644
--- a/arch/mips/alchemy/devboards/db1x00/board_setup.c
+++ b/arch/mips/alchemy/devboards/db1x00/board_setup.c
@@ -32,6 +32,7 @@
 #include <linux/interrupt.h>
 
 #include <asm/mach-au1x00/au1000.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
 #include <asm/mach-db1x00/db1x00.h>
 #include <asm/mach-db1x00/bcsr.h>
 
@@ -101,6 +102,22 @@ void __init board_setup(void)
 	printk(KERN_INFO "AMD Alchemy Au1100/Db1100 Board\n");
 #endif
 #ifdef CONFIG_MIPS_BOSPORUS
+	struct au1000_eth_platform_data eth0_pdata;
+
+	/*
+	 * Micrel/Kendin 5 port switch attached to MAC0,
+	 * MAC0 is associated with PHY address 5 (== WAN port)
+	 * MAC1 is not associated with any PHY, since it's connected directly
+	 * to the switch.
+	 * no interrupts are used
+	 */
+	eth0_pdata.phy1_search_mac0 = 0;
+	eth0_pdata.phy_static_config = 1;
+	eth0_pdata.phy_addr = 5;
+	eth0_pdata.phy_busid = 0;
+
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


