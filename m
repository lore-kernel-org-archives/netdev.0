From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [net-next] ARM: orion: fix PHYLIB dependency
Date: Fri, 10 Feb 2017 12:57:54 -0800
Message-ID: <b78765e9-2696-5587-0485-e497eb4459db@gmail.com>
References: <20170209150834.1158193-1-arnd@arndb.de>
 <CAK8P3a2Yss8r0qoubg2C7Jp+0JE3Fx+igWHQOscR+SB6d+W_HA@mail.gmail.com>
 <352146cc-845c-2860-44ca-7338eb53e260@gmail.com> <2626135.PlNJ5EMbcM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
        Networking <netdev@vger.kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2626135.PlNJ5EMbcM@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/10/2017 12:05 PM, Arnd Bergmann wrote:
> On Friday, February 10, 2017 9:42:21 AM CET Florian Fainelli wrote:
>> On 02/10/2017 12:20 AM, Arnd Bergmann wrote:
>>> On Thu, Feb 9, 2017 at 7:22 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>> On 02/09/2017 07:08 AM, Arnd Bergmann wrote:
>>>> I disabled CONFIG_NETDEVICES to force CONFIG_PHY not to be set here, and
>>>> I was not able to reproduce this, what am I missing?
>>>
>>> In the ARMv5 allmodconfig build, this fails because CONFIG_PHY=m, and
>>> we can't call into it. You could use IS_BUILTIN instead of IS_ENABLED in
>>> the header as a oneline workaround, but I think that would be more confusing
>>> to real users that try to use CONFIG_PHY=m without realizing why they lose
>>> access to their switch.
>>
>> I see, this patch should also help fixing this:
>>
>> http://patchwork.ozlabs.org/patch/726381/
> 
> I think you still have the same problem, as you can still have the
> boardinfo registration in a loadable module.

The patch exports mdiobus_register_board_info() so that should solve
your problem here, and I did verify this with a loadable module that
references mdiobus_register_board_info() in that case.

> 
> I have come up with a patch too now and done some randconfig testing
> on it (it took me several tries as well), please see below. It does
> some of the same things as yours and some others.
> 
> The main trick is to have a separate 'MDIO_BOARDINFO' Kconfig symbol
> that can be selected regardless of all the other symbols, and that
> will lead to the registration being either built-in when it's needed
> or not built at all when either no board calls it, or PHYLIB is
> disabled.

Your patch is fine in premise except that you are making CONFIG_MDIO
encompass both drivers/net/mdio.c and
drivers/net/phy/mdio_{bus,device}.c and these do share the same header
(for better or for worse), but are not quite dealing with MDIO at the
same level. drivers/net/mdio.c is more like PHYLIB for the old-style,
pre mdiobus() drivers helper functions.

I like it that you made MDIO_BOARDINFO separate, and that is probably a
patch I should incorporate in the other patch splitting things up, see
below though for the remainder of the changes.

> 
> From f35e89cacfabdf7b822772013389132605941def Mon Sep 17 00:00:00 2001
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Wed, 27 Apr 2016 11:51:18 +0200
> Subject: [PATCH] [RFC] move ethernet PHY config into drivers/phy/Kconfig
> 
> Calling mdiobus_register_board_info from builtin code with CONFIG_PHYLIB=m
> currently results in a link error:
> 
> arch/arm/plat-orion/common.o: In function `orion_ge00_switch_init':
> common.c:(.init.text+0x6a4): undefined reference to `mdiobus_register_board_info'
> 
> As the long-term strategy is to separate mdio from phylib, and to get generic-phy
> and (networking-only) phylib closer together, this performs a first step in that
> direction: The Kconfig file for phylib gets logically pulled under the PHY
> driver configuration and becomes independent from networking. This lets us
> select the new CONFIG_MDIO_BOARDINFO from platforms that need it, and provide
> the functions exactly when we need them.

This is too broad, the only part that is worth in drivers/net/phy/ of
pulling out of drivers/net/phy/ is what I tried to extract: mdio bus and
device. There are some bad inter-dependencies between that code and
phy_device.c and phy.c which makes it hard to split and make that part
completely standalone for now.

The only part that is truly valuable to non-Ethernet PHY devices is the
MDIO bus/device registration part, which is available in my patch with
CONFIG_MDIO_DEVICE, and which probably should not depend from
NETDEVICES, so the other part of your patch makes sense too here.

Thanks!


> 
> In the same step, we can also split out the MDIO driver configuration from
> phylib. This is based on an older experimental patch I had, but it still
> requires some code changes in phylib itself to let users actually rely on
> MDIO without all of PHYLIB.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> diff --git a/arch/arm/mach-orion5x/Kconfig b/arch/arm/mach-orion5x/Kconfig
> index 468b8cb7fd5f..e1126e1aa3d2 100644
> --- a/arch/arm/mach-orion5x/Kconfig
> +++ b/arch/arm/mach-orion5x/Kconfig
> @@ -4,6 +4,7 @@ menuconfig ARCH_ORION5X
>  	select CPU_FEROCEON
>  	select GENERIC_CLOCKEVENTS
>  	select GPIOLIB
> +	select MDIO_BOARDINFO
>  	select MVEBU_MBUS
>  	select PCI
>  	select PLAT_ORION_LEGACY
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index a993cbeb9e0c..9eb15b7518bd 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -378,8 +378,6 @@ config NET_SB1000
>  
>  	  If you don't have this card, of course say N.
>  
> -source "drivers/net/phy/Kconfig"
> -
>  source "drivers/net/plip/Kconfig"
>  
>  source "drivers/net/ppp/Kconfig"
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 7336cbd3ef5d..3ab87e9f9442 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -17,7 +17,7 @@ obj-$(CONFIG_MII) += mii.o
>  obj-$(CONFIG_MDIO) += mdio.o
>  obj-$(CONFIG_NET) += Space.o loopback.o
>  obj-$(CONFIG_NETCONSOLE) += netconsole.o
> -obj-$(CONFIG_PHYLIB) += phy/
> +obj-y+= phy/
>  obj-$(CONFIG_RIONET) += rionet.o
>  obj-$(CONFIG_NET_TEAM) += team/
>  obj-$(CONFIG_TUN) += tun.o
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index 8c08f9deef92..9c4652ae2750 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -11,9 +11,6 @@ menuconfig ETHERNET
>  
>  if ETHERNET
>  
> -config MDIO
> -	tristate
> -
>  config SUNGEM_PHY
>  	tristate
>  
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 8dbd59baa34d..37f5552cc5b3 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -3,8 +3,9 @@
>  #
>  
>  menuconfig PHYLIB
> -	tristate "PHY Device support and infrastructure"
> +	tristate "Ethernet PHY Device support and infrastructure"
>  	depends on NETDEVICES
> +	select MDIO
>  	help
>  	  Ethernet controllers are usually attached to PHY
>  	  devices.  This option provides infrastructure for
> @@ -248,6 +249,16 @@ config FIXED_PHY
>  	  PHYs that are not connected to the real MDIO bus.
>  
>  	  Currently tested with mpc866ads and mpc8349e-mitx.
> +endif # PHYLIB
> +
> +config MDIO
> +	tristate
> +	help
> +	  The MDIO bus is typically used ethernet PHYs, but can also be
> +	  used by other PHY drivers.
> +
> +menu "MDIO bus drivers"
> +	depends on MDIO
>  
>  config ICPLUS_PHY
>  	tristate "ICPlus PHYs"
> @@ -340,7 +351,10 @@ config XILINX_GMII2RGMII
>           the Reduced Gigabit Media Independent Interface(RGMII) between
>           Ethernet physical media devices and the Gigabit Ethernet controller.
>  
> -endif # PHYLIB
> +endmenu # MDIO
> +
> +config MDIO_BOARDINFO
> +	bool
>  
>  config MICREL_KS8995MA
>  	tristate "Micrel KS8995MA 5-ports 10/100 managed Ethernet switch"
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 407b0b601ea8..e60e5d2fae53 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -1,11 +1,13 @@
>  # Makefile for Linux PHY drivers and MDIO bus drivers
>  
> -libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o \
> -				   mdio-boardinfo.o
> +libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o
>  libphy-$(CONFIG_SWPHY)		+= swphy.o
>  libphy-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
>  
>  obj-$(CONFIG_PHYLIB)		+= libphy.o
> +ifdef CONFIG_PHYLIB
> +obj-$(CONFIG_MDIO_BOARDINFO)	+= mdio-boardinfo.o
> +endif
>  
>  obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
>  obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
> diff --git a/drivers/net/phy/mdio-boardinfo.c b/drivers/net/phy/mdio-boardinfo.c
> index 6b988f77da08..f7cf98093344 100644
> --- a/drivers/net/phy/mdio-boardinfo.c
> +++ b/drivers/net/phy/mdio-boardinfo.c
> @@ -55,6 +55,7 @@ void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus)
>  	}
>  	mutex_unlock(&mdio_board_lock);
>  }
> +EXPORT_SYMBOL_GPL(mdiobus_setup_mdiodev_from_board_info);
>  
>  /**
>   * mdio_register_board_info - register MDIO devices for a given board
> diff --git a/drivers/net/phy/mdio-boardinfo.h b/drivers/net/phy/mdio-boardinfo.h
> index 00f98163e90e..3a72bd978114 100644
> --- a/drivers/net/phy/mdio-boardinfo.h
> +++ b/drivers/net/phy/mdio-boardinfo.h
> @@ -14,6 +14,12 @@ struct mdio_board_entry {
>  	struct mdio_board_info	board_info;
>  };
>  
> +#ifdef CONFIG_MDIO_BOARDINFO
>  void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus);
> +#else
> +static inline void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus)
> +{
> +}
> +#endif
>  
>  #endif /* __MDIO_BOARD_INFO_H */
> diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
> index 519241bc8817..87c581f11297 100644
> --- a/drivers/phy/Kconfig
> +++ b/drivers/phy/Kconfig
> @@ -2,7 +2,9 @@
>  # PHY
>  #
>  
> -menu "PHY Subsystem"
> +menu "PHY drivers"
> +
> +menu "Generic PHY subsystem"
>  
>  config GENERIC_PHY
>  	bool "PHY Core"
> @@ -515,3 +517,7 @@ config PHY_NSP_USB3
>  	  Enable this to support the Broadcom Northstar plus USB3 PHY.
>  	  If unsure, say N.
>  endmenu
> +
> +source "drivers/net/phy/Kconfig"
> +
> +endmenu
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index d9bdf53e0514..2ec82a4c3b8f 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -893,7 +893,7 @@ struct mdio_board_info {
>  	const void	*platform_data;
>  };
>  
> -#if IS_ENABLED(CONFIG_PHYLIB)
> +#if IS_ENABLED(CONFIG_PHYLIB) && IS_ENABLED(CONFIG_MDIO_BOARDINFO)
>  int mdiobus_register_board_info(const struct mdio_board_info *info,
>  				unsigned int n);
>  #else
> 


-- 
Florian
