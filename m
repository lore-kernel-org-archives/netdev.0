From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch] Micrel KS8695 integrated ethernet driver
Date: Tue, 09 Dec 2008 18:10:20 +0000
Message-ID: <1228846221.3141.5.camel@achroite>
References: <49394379.9000501@simtec.co.uk>
	 <1228499870.3520.66.camel@achroite>  <1228741685.19000.91.camel@petitemort>
	 <1228764912.3177.39.camel@achroite>  <1228843809.17317.34.camel@petitemort>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dsilvers@simtec.co.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:38155 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754017AbYLISK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 13:10:26 -0500
In-Reply-To: <1228843809.17317.34.camel@petitemort>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-09 at 17:30 +0000, Daniel Silverstone wrote:
[...]
> =EF=BB=BFKS8695: Add support for the KS8695 ethernet devices.
>=20
> Implements the KS8695 ethernet device (ks8695net).
>=20
> This driver is only of use on the KS8695 which is an ARM9 based SoC. =
The
> documentation on this SoC is sparse and poor, with barely a register
> description and a rough outline of how the ethernet works, this drive=
r was
> therefore written with strong reference to the Micrel supplied Linux =
2.6.9
> port, and to Andrew Victor's ks8695eth driver.
>=20
> Signed-off-by: Daniel Silverstone <dsilvers@simtec.co.uk>
> Signed-off-by: Vincent Sanders <vince@simtec.co.uk>
> Acked-by: Ben Dooks <ben@simtec.co.uk>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

>  Kconfig     |    8=20
>  Makefile    |    1=20
>  ks8695net.c | 1674 +++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++++++
>  ks8695net.h |  107 +++
>  4 files changed, 1790 insertions(+)
>=20
> Index: net-next-2.6/drivers/net/arm/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/drivers/net/arm/Kconfig   2008-12-08 12:55:46.8=
17658739 +0000
> +++ net-next-2.6/drivers/net/arm/Kconfig        2008-12-08 12:56:10.2=
13660241 +0000
> @@ -40,6 +40,14 @@
>           If you wish to compile a kernel for the AT91RM9200 and enab=
le
>           ethernet support, then you should always answer Y to this.
> =20
> +config ARM_KS8695_ETHER
> +       tristate "KS8695 Ethernet support"
> +       depends on ARM && ARCH_KS8695
> +       select MII
> +       help
> +         If you wish to compile a kernel for the KS8695 and want to
> +         use the internal ethernet then you should answer Y to this.
> +
>  config EP93XX_ETH
>         tristate "EP93xx Ethernet support"
>         depends on ARM && ARCH_EP93XX
> Index: net-next-2.6/drivers/net/arm/Makefile
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/drivers/net/arm/Makefile  2008-12-08 12:55:46.8=
41662533 +0000
> +++ net-next-2.6/drivers/net/arm/Makefile       2008-12-08 12:56:10.2=
13660241 +0000
> @@ -8,5 +8,6 @@
>  obj-$(CONFIG_ARM_ETHER3)       +=3D ether3.o
>  obj-$(CONFIG_ARM_ETHER1)       +=3D ether1.o
>  obj-$(CONFIG_ARM_AT91_ETHER)   +=3D at91_ether.o
> +obj-$(CONFIG_ARM_KS8695_ETHER) +=3D ks8695net.o
>  obj-$(CONFIG_EP93XX_ETH)       +=3D ep93xx_eth.o
>  obj-$(CONFIG_IXP4XX_ETH)       +=3D ixp4xx_eth.o
> Index: net-next-2.6/drivers/net/arm/ks8695net.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null   1970-01-01 00:00:00.000000000 +0000
> +++ net-next-2.6/drivers/net/arm/ks8695net.c    2008-12-09 17:26:28.4=
69658828 +0000
> @@ -0,0 +1,1674 @@
> +/*
> + * Micrel KS8695 (Centaur) Ethernet.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation; either version 2 of th=
e
> + * License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful, b=
ut
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.         See =
the GNU
> + * General Public License for more details.
> + *
> + * Copyright 2008 Simtec Electronics
> + *               Daniel Silverstone <dsilvers@simtec.co.uk>
> + *               Vincent Sanders <vince@simtec.co.uk>
> + */
> +
> +#include <linux/module.h>
> +#include <linux/ioport.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/init.h>
> +#include <linux/skbuff.h>
> +#include <linux/spinlock.h>
> +#include <linux/crc32.h>
> +#include <linux/mii.h>
> +#include <linux/ethtool.h>
> +#include <linux/delay.h>
> +#include <linux/platform_device.h>
> +#include <linux/irq.h>
> +#include <linux/delay.h>
> +#include <linux/io.h>
> +
> +#include <asm/irq.h>
> +
> +#include <mach/regs-switch.h>
> +#include <mach/regs-misc.h>
> +
> +#include "ks8695net.h"
> +
> +#define MODULENAME     "ks8695_ether"
> +#define MODULEVERSION  "1.01"
[...]

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

