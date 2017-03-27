From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v3 3/3] net: phy: Allow splitting MDIO bus/device
 support from PHYs
Date: Mon, 27 Mar 2017 17:41:49 +0200
Message-ID: <CAK8P3a2C2cwOugYcPABxySEwiDTM5Grje7tpJiMf4gJJFFoVzg@mail.gmail.com>
References: <20170323170119.4004-1-f.fainelli@gmail.com> <20170323170119.4004-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Networking <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, rmk+kernel@armlinux.org.uk
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:35771 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752146AbdC0Plv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 11:41:51 -0400
Received: by mail-ot0-f196.google.com with SMTP id s100so4321587ota.2
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 08:41:50 -0700 (PDT)
In-Reply-To: <20170323170119.4004-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 6:01 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Introduce a new configuration symbol: MDIO_DEVICE which allows building
> the MDIO devices and bus code, without pulling in the entire Ethernet
> PHY library and devices code.
>
> PHYLIB nows select MDIO_DEVICE and the relevant Makefile files are
> updated to reflect that.
>
> When MDIO_DEVICE (MDIO bus/device only) is selected, but not PHYLIB, we
> have mdio-bus.ko as a loadable module, and it does not have a
> module_exit() function because the safety of removing a bus class is
> unclear.
>
> When both MDIO_DEVICE and PHYLIB are enabled, we need to assemble
> everything into a common loadable module: libphy.ko because of nasty
> circular dependencies between phy.c, phy_device.c and mdio_bus.c which
> are really tough to untangle.

I'm getting a couple of link errors with this:

- ARCH_ORION5X calls mdiobus_register_board_info and must force
  mdio-boardinfo.o to be built-in, but I don't see how it should
ideally do that:

arch/arm/plat-orion/common.o: In function `orion_ge00_switch_init':
common.c:(.init.text+0x6a6): undefined reference to
`mdiobus_register_board_info'

- sun4i_mdio.ko depends on mdiobus, but it gets selected from another driver
  which makes it built-in without checking if mdiobus is a module

drivers/net/built-in.o: In function `sun4i_mdio_remove':
:(.text+0x51c): undefined reference to `mdiobus_unregister'
:(.text+0x524): undefined reference to `mdiobus_free'
drivers/net/built-in.o: In function `sun4i_mdio_probe':
:(.text+0x728): undefined reference to `mdiobus_alloc_size'
:(.text+0x85c): undefined reference to `of_mdiobus_register'
:(.text+0x894): undefined reference to `mdiobus_free'

- Some drivers select MDIO_BITBANG, which may need to be a module:
warning: (FS_ENET_MDIO_FCC && AX88796 && SH_ETH && RAVB) selects
MDIO_BITBANG which has unmet direct dependencies (NETDEVICES &&
MDIO_DEVICE && (MDIO_DEVICE!=y || PHYLIB!=m))

I've been able to work around the latter two using this hack:

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 60ffc9da6a28..d82857f46cec 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -28,7 +28,7 @@ config MDIO_BCM_UNIMAC

 config MDIO_BITBANG
  tristate "Bitbanged MDIO buses"
- depends on !(MDIO_DEVICE=y && PHYLIB=m)
+ depends on m || !(MDIO_DEVICE=y && PHYLIB=m)
  help
   This module implements the MDIO bus protocol in software,
   for use by low level drivers that export the ability to
@@ -118,6 +118,7 @@ config MDIO_OCTEON
 config MDIO_SUN4I
  tristate "Allwinner sun4i MDIO interface support"
  depends on ARCH_SUNXI
+ depends on m || !(MDIO_DEVICE=y && PHYLIB=m)
  help
   This driver supports the MDIO interface found in the network
   interface units of the Allwinner SoC that have an EMAC (A10,


      Arnd
