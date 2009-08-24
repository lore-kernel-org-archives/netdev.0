From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH 1/2] alchemy: add au1000-eth platform device
Date: Mon, 24 Aug 2009 22:02:57 +0400
Message-ID: <4A92D5D1.60009@ru.mvista.com>
References: <200908170105.38154.florian@openwrt.org> <4A8AC125.3020602@ru.mvista.com> <200908181801.41602.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	Manuel Lauss <manuel.lauss@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:57740 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753167AbZHXSBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 14:01:21 -0400
In-Reply-To: <200908181801.41602.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Florian Fainelli wrote:

>>>This patch adds the board code to register a per-board au1000-eth
>>>platform device to be used wit the au1000-eth platform driver in a
>>>subsequent patch. Note that the au1000-eth driver knows about the
>>>default driver settings such that we do not need to pass any
>>>platform_data informations in most cases except db1x00.

>>    Sigh, NAK...
>>    Please don't register the SoC device per board, do it in
>>alchemy/common/platfrom.c and find a way to pass the board specific
>>platform data from the board file there instead -- something like
>>arch/arm/mach-davinci/usb.c does.

> Ok, like I promised, this was the per-board device registration. Do you prefer something like this:

    I certainly do, but still not in this incarnation... :-)

> --
> From fd75b7c7fa3c05c21122c43e43260d2785475a79 Mon Sep 17 00:00:00 2001
> From: Florian Fainelli <florian@openwrt.org>
> Date: Tue, 18 Aug 2009 17:53:21 +0200
> Subject: [PATCH] alchemy: add au1000-eth platform device (v2)
> 
> This patch makes the board code register the au1000-eth
> platform device. The au1000-eth platform data can be
> overriden with the au1xxx_override_eth0_cfg function
> like it has to be done for the Bosporus board.
> 
> Changes from v1:
> - remove per-board platform.c file
> - add an override function to pass custom eth0 platform_data PHY settings
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> diff --git a/arch/mips/alchemy/common/platform.c b/arch/mips/alchemy/common/platform.c
> index 117f99f..559294a 100644
> --- a/arch/mips/alchemy/common/platform.c
> +++ b/arch/mips/alchemy/common/platform.c
> @@ -19,6 +19,7 @@
>  #include <asm/mach-au1x00/au1xxx.h>
>  #include <asm/mach-au1x00/au1xxx_dbdma.h>
>  #include <asm/mach-au1x00/au1100_mmc.h>
> +#include <asm/mach-au1x00/au1xxx_eth.h>
>  
>  #define PORT(_base, _irq)				\
>  	{						\
> @@ -331,6 +332,76 @@ static struct platform_device pbdb_smbus_device = {
>  };
>  #endif
>  
> +/* Macro to help defining the Ethernet MAC resources */
> +#define MAC_RES(_base, _enable, _irq)			\
> +	{						\
> +		.start	= CPHYSADDR(_base),		\
> +		.end	= CPHYSADDR(_base + 0xffff),	\
> +		.flags	= IORESOURCE_MEM,		\
> +	},						\
> +	{						\
> +		.start	= CPHYSADDR(_enable),		\
> +		.end	= CPHYSADDR(_enable + 0x3),	\
> +		.flags	= IORESOURCE_MEM,		\
> +	},						\
> +	{						\
> +		.start	= _irq,				\
> +		.end	= _irq,				\
> +		.flags	= IORESOURCE_IRQ		\
> +	}
> +
> +static struct resource au1xxx_eth0_resources[] = {
> +#if defined(CONFIG_SOC_AU1000)
> +	MAC_RES(AU1000_ETH0_BASE, AU1000_MAC0_ENABLE, AU1000_MAC0_DMA_INT),
> +#elif defined(CONFIG_SOC_AU1100)
> +	MAC_RES(AU1100_ETH0_BASE, AU1100_MAC0_ENABLE, AU1100_MAC0_DMA_INT),
> +#elif defined(CONFIG_SOC_AU1550)
> +	MAC_RES(AU1550_ETH0_BASE, AU1550_MAC0_ENABLE, AU1550_MAC0_DMA_INT),
> +#elif defined(CONFIG_SOC_AU1500)
> +	MAC_RES(AU1500_ETH0_BASE, AU1500_MAC0_ENABLE, AU1500_MAC0_DMA_INT),
> +#endif
> +};
> +
> +static struct resource au1xxx_eth1_resources[] = {
> +#if defined(CONFIG_SOC_AU1000)
> +	MAC_RES(AU1000_ETH1_BASE, AU1000_MAC1_ENABLE, AU1000_MAC1_DMA_INT),
> +#elif defined(CONFIG_SOC_AU1550)
> +	MAC_RES(AU1550_ETH1_BASE, AU1550_MAC1_ENABLE, AU1550_MAC1_DMA_INT),
> +#elif defined(CONFIG_SOC_AU1500)
> +	MAC_RES(AU1500_ETH1_BASE, AU1500_MAC1_ENABLE, AU1500_MAC1_DMA_INT),
> +#endif
> +};
> +
> +static struct au1000_eth_platform_data au1xxx_eth0_platform_data = {
> +	.phy1_search_mac0 = 1,
> +};

    I'm not sure that the default platfrom data is really a great idea...

> +#ifndef CONFIG_SOC_AU1100
> +static struct platform_device au1xxx_eth1_device = {
> +	.name		= "au1000-eth",
> +	.id		= 1,
> +	.num_resources	= ARRAY_SIZE(au1xxx_eth1_resources),
> +	.resource	= au1xxx_eth1_resources,

    And where's the platfrom data for the second Ethernet?

> +};
> +#endif
> +
> +void __init au1xxx_override_eth0_cfg(struct au1000_eth_platform_data *eth_data)
> +{
> +	if (!eth_data)
> +		return;
> +
> +	memcpy(&au1xxx_eth0_platform_data, eth_data,
> +		sizeof(struct au1000_eth_platform_data));

    Why not just set the pointer in au1xxx_eth0_device. And really, why not 
make the function more generic, with a prototype like:

void __init au1xxx_override_eth_cfg(unsigned port, struct
				    au1000_eth_platform_data *eth_data);

> +}
> +
>  static struct platform_device *au1xxx_platform_devices[] __initdata = {
>  	&au1xx0_uart_device,
>  	&au1xxx_usb_ohci_device,
> @@ -351,17 +422,25 @@ static struct platform_device *au1xxx_platform_devices[] __initdata = {
>  #ifdef SMBUS_PSC_BASE
>  	&pbdb_smbus_device,
>  #endif
> +	&au1xxx_eth0_device,
>  };
>  
>  static int __init au1xxx_platform_init(void)
>  {
>  	unsigned int uartclk = get_au1x00_uart_baud_base() * 16;
> -	int i;
> +	int i, ni;
>  
>  	/* Fill up uartclk. */
>  	for (i = 0; au1x00_uart_data[i].flags; i++)
>  		au1x00_uart_data[i].uartclk = uartclk;
>  
> +	/* Register second MAC if enabled in pinfunc */
> +#ifndef CONFIG_SOC_AU1100
> +	ni = (int)((au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4);
> +	if (!(ni + 1))

    Why so complex, and how can (ni + 1) ever be 0?! :-/
    Doesn't that field when 0 mean the pins configured for MAC1 and when 1 
-- for GPIO? Why not just:

	if (!(au_readl(SYS_PINFUNC) & SYS_PF_NI2))

> +		platform_device_register(&au1xxx_eth1_device);
> +#endif
> +

WBR, Sergei
