From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: Allow building mdio-boardinfo into the
 kernel
Date: Wed, 29 Mar 2017 11:07:03 -0700
Message-ID: <19f934c3-7fd2-976b-a65c-d7877fc853b8@gmail.com>
References: <20170328195709.13549-1-f.fainelli@gmail.com>
 <CAK8P3a08sng5o6QEsUoOWbsixX9zX3H-NByXsCGirGsz_EtYDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Networking <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, rmk+kernel@armlinux.org.uk
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34276 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752489AbdC2SHJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 14:07:09 -0400
Received: by mail-wr0-f193.google.com with SMTP id w43so5223396wrb.1
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 11:07:08 -0700 (PDT)
In-Reply-To: <CAK8P3a08sng5o6QEsUoOWbsixX9zX3H-NByXsCGirGsz_EtYDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2017 01:09 AM, Arnd Bergmann wrote:
> On Tue, Mar 28, 2017 at 9:57 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> mdio-boardinfo contains code that is helpful for platforms to register
>> specific MDIO bus devices independent of how CONFIG_MDIO_DEVICE or
>> CONFIG_PHYLIB will be selected (modular or built-in). In order to make
>> that possible, let's do the following:
>>
>> - descend into drivers/net/phy/ unconditionally
>>
>> - make mdiobus_setup_mdiodev_from_board_info() take a callback argument
>>   which allows us not to expose the internal MDIO board info list and
>>   mutex, yet maintain the logic within the same file
>>
>> - relocate the code that creates a MDIO device into
>>   drivers/net/phy/mdio_bus.c
>>
>> - build mdio-boardinfo.o into the kernel as soon as MDIO_DEVICE is
>>   defined (y or m)
>>
>> Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
>> Fixes: 648ea0134069 ("net: phy: Allow pre-declaration of MDIO devices")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> It survived the overnight randconfig build,
> 
> Tested-by: Arnd Bergmann <arnd@arndb.de>
> 
> On a related note, I ran into one more case of a network driver selecting a
> particular PHY:
> 
> drivers/net/built-in.o: In function `octeon_mdiobus_remove':
> wilink_platform_data.c:(.text+0xe58): undefined reference to
> `mdiobus_unregister'
> wilink_platform_data.c:(.text+0xe60): undefined reference to `mdiobus_free'
> drivers/net/built-in.o: In function `octeon_mdiobus_probe':
> wilink_platform_data.c:(.text+0xec8): undefined reference to
> `devm_mdiobus_alloc_size'
> wilink_platform_data.c:(.text+0x1090): undefined reference to
> `of_mdiobus_register'
> wilink_platform_data.c:(.text+0x10d0): undefined reference to `mdiobus_free'
> 
> Building with this hack fixes the three instances I found so far, but my
> current workaround seems rather fragile:
> 
> @@ -28,7 +28,7 @@ config MDIO_BCM_UNIMAC
> 
>  config MDIO_BITBANG
>         tristate "Bitbanged MDIO buses"
> -       depends on !(MDIO_DEVICE=y && PHYLIB=m)
> +       depends on m || !(MDIO_DEVICE=y && PHYLIB=m)
>         help
>           This module implements the MDIO bus protocol in software,
>           for use by low level drivers that export the ability to
> @@ -118,6 +118,7 @@ config MDIO_OCTEON
>  config MDIO_SUN4I
>         tristate "Allwinner sun4i MDIO interface support"
>         depends on ARCH_SUNXI
> +       depends on m || !(MDIO_DEVICE=y && PHYLIB=m)
>         help
>           This driver supports the MDIO interface found in the network
>           interface units of the Allwinner SoC that have an EMAC (A10,
> @@ -109,6 +109,7 @@ config MDIO_OCTEON
>         tristate "Octeon and some ThunderX SOCs MDIO buses"
>         depends on 64BIT
>         depends on HAS_IOMEM
> +       depends on m || !(MDIO_DEVICE=y && PHYLIB=m)
>         select MDIO_CAVIUM
>         help
>           This module provides a driver for the Octeon and ThunderX MDIO
> 
> The configuration causing it is something like this:
> 
> CONFIG_MDIO_OCTEON=y
> CONFIG_MDIO_DEVICE=y
> CONFIG_PHYLIB=m
> 
> This is what I'm trying now:

This change below looks a lot more scalable, thanks a lot for running
this through your randconfig tests.

> 
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -7,7 +7,16 @@ menuconfig MDIO_DEVICE
>         help
>            MDIO devices and driver infrastructure code.
> 
> -if MDIO_DEVICE
> +config MDIO_BUS
> +       tristate
> +       default m if PHYLIB=m
> +       default MDIO_DEVICE
> +       help
> +         This internal symbol is used for link time dependencies and it
> +         reflects whether the mdio_bus/mdio_device code is built as a
> +         loadable module or built-in.
> +
> +if MDIO_BUS
> 
>  config MDIO_BCM_IPROC
>         tristate "Broadcom iProc MDIO bus controller"
> @@ -28,7 +37,6 @@ config MDIO_BCM_UNIMAC
> 
>  config MDIO_BITBANG
>         tristate "Bitbanged MDIO buses"
> -       depends on m || !(MDIO_DEVICE=y && PHYLIB=m)
>         help
>           This module implements the MDIO bus protocol in software,
>           for use by low level drivers that export the ability to
> @@ -109,7 +117,6 @@ config MDIO_OCTEON
>         tristate "Octeon and some ThunderX SOCs MDIO buses"
>         depends on 64BIT
>         depends on HAS_IOMEM
> -       depends on m || !(MDIO_DEVICE=y && PHYLIB=m)
>         select MDIO_CAVIUM
>         help
>           This module provides a driver for the Octeon and ThunderX MDIO
> @@ -119,7 +126,6 @@ config MDIO_OCTEON
>  config MDIO_SUN4I
>         tristate "Allwinner sun4i MDIO interface support"
>         depends on ARCH_SUNXI
> -       depends on m || !(MDIO_DEVICE=y && PHYLIB=m)
>         help
>           This driver supports the MDIO interface found in the network
>           interface units of the Allwinner SoC that have an EMAC (A10,
> 
> 
>     Arnd
> 


-- 
Florian
