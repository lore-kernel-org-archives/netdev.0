From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH V2 1/4] CS89x0 : add platform driver support
Date: Wed, 11 Jan 2012 09:05:17 +0100
Message-ID: <20120111080517.GJ14252@pengutronix.de>
References: <1326237197-23594-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, kernel@pengutronix.de, davem@davemloft.net,
	cavokz@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58956 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110Ab2AKIF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 03:05:26 -0500
Content-Disposition: inline
In-Reply-To: <1326237197-23594-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jaccon,

On Wed, Jan 11, 2012 at 12:13:17AM +0100, Jaccon Bastiaansen wrote:
> The CS89x0 ethernet controller is used on a number of evaluation
> boards, such as the MX31ADS. The current driver has memory address an=
d
> IRQ settings for each board on which this controller is used. Driver
> updates are therefore required to support other boards that also use
> the CS89x0. To avoid these driver updates, a better mechanism
> (platform driver support) is added to communicate the board dependent
> settings to the driver.
>=20
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
> ---
>  drivers/net/Space.c                  |    4 +
>  drivers/net/ethernet/cirrus/Kconfig  |   19 +++--
>  drivers/net/ethernet/cirrus/cs89x0.c |  147 ++++++++++++++++++++++++=
+++++-----
>  3 files changed, 143 insertions(+), 27 deletions(-)
>=20
> diff --git a/drivers/net/Space.c b/drivers/net/Space.c
> index 068c356..00fe11b 100644
> --- a/drivers/net/Space.c
> +++ b/drivers/net/Space.c
> @@ -190,8 +190,12 @@ static struct devprobe2 isa_probes[] __initdata =
=3D {
>  	{seeq8005_probe, 0},
>  #endif
>  #ifdef CONFIG_CS89x0
> +#if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351=
) || \
> +	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440) || \
> +	defined(CONFIG_MACH_MX31ADS)
>   	{cs89x0_probe, 0},
>  #endif
> +#endif
>  #ifdef CONFIG_AT1700
>  	{at1700_probe, 0},
>  #endif
> diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethern=
et/cirrus/Kconfig
> index 1f8648f..3784b1b 100644
> --- a/drivers/net/ethernet/cirrus/Kconfig
> +++ b/drivers/net/ethernet/cirrus/Kconfig
> @@ -5,8 +5,7 @@
>  config NET_VENDOR_CIRRUS
>  	bool "Cirrus devices"
>  	default y
> -	depends on ISA || EISA || MACH_IXDP2351 || ARCH_IXDP2X01 \
> -		|| MACH_MX31ADS || MACH_QQ2440 || (ARM && ARCH_EP93XX) || MAC
> +	depends on ISA || EISA || ARM || (ARM && ARCH_EP93XX) || MAC
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, sa=
y Y
>  	  and read the Ethernet-HOWTO, available from
> @@ -21,8 +20,7 @@ if NET_VENDOR_CIRRUS
> =20
>  config CS89x0
>  	tristate "CS89x0 support"
> -	depends on (ISA || EISA || MACH_IXDP2351 \
> -		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440)
> +	depends on ISA || EISA || ARM
>  	---help---
>  	  Support for CS89x0 chipset based Ethernet cards. If you have a
>  	  network (Ethernet) card of this type, say Y and read the
> @@ -33,10 +31,15 @@ config CS89x0
>  	  To compile this driver as a module, choose M here. The module
>  	  will be called cs89x0.
> =20
> -config CS89x0_NONISA_IRQ
> -	def_bool y
> -	depends on CS89x0 !=3D n
> -	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_Q=
Q2440
> +config CS89x0_PLATFORM
> +	bool "CS89x0 platform driver support"
> +	depends on CS89x0
> +	help
> +	  Say Y to compile the cs89x0 driver as a platform driver. This
> +	  makes this driver suitable for use on certain evaluation boards
> +	  such as the iMX21ADS.
> +
> +	  If you are unsure, say N.
> =20
>  config EP93XX_ETH
>  	tristate "EP93xx Ethernet support"
> diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ether=
net/cirrus/cs89x0.c
> index f328da2..d6c6398 100644
> --- a/drivers/net/ethernet/cirrus/cs89x0.c
> +++ b/drivers/net/ethernet/cirrus/cs89x0.c
> @@ -100,9 +100,6 @@
> =20
>  */
> =20
> -/* Always include 'config.h' first in case the user wants to turn on
> -   or override something. */
> -#include <linux/module.h>
> =20
>  /*
>   * Set this to zero to disable DMA code
> @@ -131,9 +128,12 @@
> =20
>  */
> =20
> +#include <linux/module.h>
> +#include <linux/printk.h>
>  #include <linux/errno.h>
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
> +#include <linux/platform_device.h>
>  #include <linux/kernel.h>
>  #include <linux/types.h>
>  #include <linux/fcntl.h>
> @@ -151,13 +151,14 @@
>  #include <asm/system.h>
>  #include <asm/io.h>
>  #include <asm/irq.h>
> +#include <linux/atomic.h>
>  #if ALLOW_DMA
>  #include <asm/dma.h>
>  #endif
> =20
>  #include "cs89x0.h"
> =20
> -static char version[] __initdata =3D
> +static char version[] =3D
Isn't it possible to use __devinitdata here and accordingly __devinit
for the other functions?

>  "cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Mo=
rton\n";
> =20
>  #define DRV_NAME "cs89x0"
> @@ -173,6 +174,7 @@ static char version[] __initdata =3D
>  /* The cs8900 has 4 IRQ pins, software selectable. cs8900_irq_map ma=
ps
>     them to system IRQ numbers. This mapping is card specific and is =
set to
>     the configuration of the Cirrus Eval board for this chip. */
> +#if defined(CONFIG_CS89x0_PLATFORM)
>  #if defined(CONFIG_MACH_IXDP2351)
>  static unsigned int netcard_portlist[] __used __initdata =3D {IXDP23=
51_VIRT_CS8900_BASE, 0};
>  static unsigned int cs8900_irq_map[] =3D {IRQ_IXDP2351_CS8900, 0, 0,=
 0};
> @@ -189,6 +191,7 @@ static unsigned int netcard_portlist[] __used __i=
nitdata =3D {
>  	PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
>  };
>  static unsigned cs8900_irq_map[] =3D {EXPIO_INT_ENET_INT, 0, 0, 0};
> +#endif
>  #else
>  static unsigned int netcard_portlist[] __used __initdata =3D
>     { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, =
0x2a0, 0x2c0, 0x2e0, 0};
> @@ -236,6 +239,11 @@ struct net_local {
>  	unsigned char *end_dma_buff;	/* points to the end of the buffer */
>  	unsigned char *rx_dma_ptr;	/* points to the next packet  */
>  #endif
> +#ifdef CONFIG_CS89x0_PLATFORM
> +	void *virt_addr;	/* Virtual address for accessing the CS890x. */
> +	unsigned long phys_addr;/* Physical address for accessing the CS89x=
0. */
> +	unsigned long size;	/* Length of CS89x0 memory region. */
> +#endif
>  };
> =20
>  /* Index to functions, as function prototypes. */
> @@ -294,6 +302,9 @@ static int __init media_fn(char *str)
>  __setup("cs89x0_media=3D", media_fn);
> =20
> =20
> +#if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351=
) || \
> +	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440) ||  \
> +	defined(CONFIG_MACH_MX31ADS)
CONFIG_ARM similar to your changes to Kconfig?

>  /* Check for a network adaptor of this type, and return '0' iff one =
exists.
>     If dev->base_addr =3D=3D 0, probe all likely locations.
>     If dev->base_addr =3D=3D 1, always return failure.
> @@ -343,6 +354,7 @@ out:
>  	return ERR_PTR(err);
>  }
>  #endif
> +#endif
> =20
>  #if defined(CONFIG_MACH_IXDP2351)
>  static u16
> @@ -424,7 +436,7 @@ writereg(struct net_device *dev, u16 regno, u16 v=
alue)
>  	writeword(dev->base_addr, DATA_PORT, value);
>  }
> =20
> -static int __init
> +static int
>  wait_eeprom_ready(struct net_device *dev)
>  {
>  	int timeout =3D jiffies;
> @@ -437,7 +449,7 @@ wait_eeprom_ready(struct net_device *dev)
>  	return 0;
>  }
> =20
> -static int __init
> +static int
>  get_eeprom_data(struct net_device *dev, int off, int len, int *buffe=
r)
>  {
>  	int i;
> @@ -455,7 +467,7 @@ get_eeprom_data(struct net_device *dev, int off, =
int len, int *buffer)
>          return 0;
>  }
> =20
> -static int  __init
> +static int
>  get_eeprom_cksum(int off, int len, int *buffer)
>  {
>  	int i, cksum;
> @@ -503,7 +515,7 @@ static const struct net_device_ops net_ops =3D {
>     Return 0 on success.
>   */
> =20
> -static int __init
> +static int
>  cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
>  {
>  	struct net_local *lp =3D netdev_priv(dev);
> @@ -736,10 +748,8 @@ cs89x0_probe1(struct net_device *dev, int ioaddr=
, int modular)
>  			dev->irq =3D i;
>  	} else {
>  		i =3D lp->isa_config & INT_NO_MASK;
> +#ifndef CONFIG_CS89x0_PLATFORM
>  		if (lp->chip_type =3D=3D CS8900) {
> -#ifdef CONFIG_CS89x0_NONISA_IRQ
> -		        i =3D cs8900_irq_map[0];
> -#else
>  			/* Translate the IRQ using the IRQ mapping table. */
>  			if (i >=3D ARRAY_SIZE(cs8900_irq_map))
>  				printk("\ncs89x0: invalid ISA interrupt number %d\n", i);
> @@ -747,6 +757,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr,=
 int modular)
>  				i =3D cs8900_irq_map[i];
> =20
>  			lp->irq_map =3D CS8900_IRQ_MAP; /* fixed IRQ map for CS8900 */
> +
unrelated

>  		} else {
>  			int irq_map_buff[IRQ_MAP_LEN/2];
> =20
> @@ -756,8 +767,8 @@ cs89x0_probe1(struct net_device *dev, int ioaddr,=
 int modular)
>  				if ((irq_map_buff[0] & 0xff) =3D=3D PNP_IRQ_FRMT)
>  					lp->irq_map =3D (irq_map_buff[0]>>8) | (irq_map_buff[1] << 8);
>  			}
> -#endif
>  		}
> +#endif
>  		if (!dev->irq)
>  			dev->irq =3D i;
>  	}
> @@ -954,10 +965,10 @@ skip_this_frame:
>  static void __init reset_chip(struct net_device *dev)
>  {
>  #if !defined(CONFIG_MACH_MX31ADS)
> -#if !defined(CS89x0_NONISA_IRQ)
> +#if !defined(CONFIG_CS89x0_PLATFORM)
>  	struct net_local *lp =3D netdev_priv(dev);
>  	int ioaddr =3D dev->base_addr;
> -#endif /* CS89x0_NONISA_IRQ */
> +#endif /* CONFIG_CS89x0_PLATFORM */
>  	int reset_start_time;
> =20
>  	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET=
);
> @@ -965,7 +976,7 @@ static void __init reset_chip(struct net_device *=
dev)
>  	/* wait 30 ms */
>  	msleep(30);
> =20
> -#if !defined(CS89x0_NONISA_IRQ)
> +#if !defined(CONFIG_CS89x0_PLATFORM)
>  	if (lp->chip_type !=3D CS8900) {
>  		/* Hardware problem requires PNP registers to be reconfigured afte=
r a reset */
>  		writeword(ioaddr, ADD_PORT, PP_CS8920_ISAINT);
> @@ -976,7 +987,7 @@ static void __init reset_chip(struct net_device *=
dev)
>  		outb((dev->mem_start >> 16) & 0xff, ioaddr + DATA_PORT);
>  		outb((dev->mem_start >> 8) & 0xff,   ioaddr + DATA_PORT + 1);
>  	}
> -#endif /* CS89x0_NONISA_IRQ */
> +#endif /* CONFIG_CS89x0_PLATFORM */
> =20
>  	/* Wait until the chip is reset */
>  	reset_start_time =3D jiffies;
> @@ -1168,6 +1179,9 @@ write_irq(struct net_device *dev, int chip_type=
, int irq)
>  	int i;
> =20
>  	if (chip_type =3D=3D CS8900) {
> +#if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351=
) || \
> +	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440) ||  \
> +	defined(CONFIG_MACH_MX31ADS)
>  		/* Search the mapping table for the corresponding IRQ pin. */
>  		for (i =3D 0; i !=3D ARRAY_SIZE(cs8900_irq_map); i++)
>  			if (cs8900_irq_map[i] =3D=3D irq)
> @@ -1175,6 +1189,10 @@ write_irq(struct net_device *dev, int chip_typ=
e, int irq)
>  		/* Not found */
>  		if (i =3D=3D ARRAY_SIZE(cs8900_irq_map))
>  			i =3D 3;
> +#else
> +		/* INTRQ0 pin is used for interrupt generation. */
> +		i =3D 0;
> +#endif
>  		writereg(dev, PP_CS8900_ISAINT, i);
>  	} else {
>  		writereg(dev, PP_CS8920_ISAINT, irq);
> @@ -1228,7 +1246,7 @@ net_open(struct net_device *dev)
>  	}
>  	else
>  	{
> -#ifndef CONFIG_CS89x0_NONISA_IRQ
> +#ifndef CONFIG_CS89x0_PLATFORM
>  		if (((1 << dev->irq) & lp->irq_map) =3D=3D 0) {
>  			printk(KERN_ERR "%s: IRQ %d is not in our map of allowable IRQs, =
which is %x\n",
>                                 dev->name, dev->irq, lp->irq_map);
> @@ -1746,7 +1764,7 @@ static int set_mac_address(struct net_device *d=
ev, void *p)
>  	return 0;
>  }
> =20
> -#ifdef MODULE
> +#if defined(MODULE) && !defined(CONFIG_CS89x0_PLATFORM)
> =20
>  static struct net_device *dev_cs89x0;
> =20
> @@ -1900,7 +1918,98 @@ cleanup_module(void)
>  	release_region(dev_cs89x0->base_addr, NETCARD_IO_EXTENT);
>  	free_netdev(dev_cs89x0);
>  }
> -#endif /* MODULE */
> +#endif /* MODULE && !CONFIG_CS89x0_PLATFORM */
> +
> +#ifdef CONFIG_CS89x0_PLATFORM
> +static int cs89x0_platform_probe(struct platform_device *pdev)
> +{
> +	struct net_device *dev =3D alloc_etherdev(sizeof(struct net_local))=
;
> +	struct net_local *lp =3D netdev_priv(dev);
> +	struct resource *mem_res;
> +	struct resource *irq_res;
> +	int err;
> +
> +	if (!dev)
> +		return -ENODEV;
> +
> +	mem_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	irq_res =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +	if (mem_res =3D=3D NULL || irq_res =3D=3D NULL) {
> +		dev_warn(&dev->dev, "memory/interrupt resource missing.\n");
> +		err =3D -ENOENT;
> +		goto free;
> +	}
> +
> +	lp->phys_addr =3D mem_res->start;
> +	lp->size =3D mem_res->end - mem_res->start + 1;
> +	if (!request_mem_region(lp->phys_addr, lp->size, DRV_NAME)) {
> +		dev_warn(&dev->dev, "request_mem_region() failed.\n");
> +		err =3D -ENOMEM;
> +		goto free;
> +	}
> +
> +	lp->virt_addr =3D ioremap(lp->phys_addr, lp->size);
> +	if (!lp->virt_addr) {
> +		dev_warn(&dev->dev, "ioremap() failed.\n");
> +		err =3D -ENOMEM;
> +		goto release;
> +	}
> +
> +	dev->irq =3D irq_res->start;
for irqs there is platform_get_irq. The usage isn't considerably easier=
,
but I'd still prefer it being used. (Note to check with <=3D 0 for
validity like:

	dev->irq =3D platform_get_irq(pdev, 0)
	if (dev->irq <=3D 0)
		goto error_handling;

)

> +	err =3D cs89x0_probe1(dev, (int)lp->virt_addr, 0);
> +	if (err) {
> +		dev_warn(&dev->dev, "no cs8900 or cs8920 detected.\n");
> +		goto unmap;
> +	}
> +
> +	platform_set_drvdata(pdev, dev);
> +	return 0;
> +
> +unmap:
> +	iounmap(lp->virt_addr);
> +release:
> +	release_mem_region(lp->phys_addr, lp->size);
> +free:
> +	free_netdev(dev);
> +	return err;
> +}
> +
> +static int cs89x0_platform_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev =3D platform_get_drvdata(pdev);
> +	struct net_local *lp =3D netdev_priv(dev);
> +
> +	unregister_netdev(dev);
> +	iounmap(lp->virt_addr);
> +	release_mem_region(lp->phys_addr, lp->size);
> +	free_netdev(dev);
> +	return 0;
> +}
> +
> +static struct platform_driver cs89x0_platform_driver =3D {
> +	.driver =3D {
> +		.name	=3D DRV_NAME,
> +		.owner	=3D THIS_MODULE,
> +	},
> +	.probe	=3D cs89x0_platform_probe,
> +	.remove	=3D cs89x0_platform_remove,
After .driver you used a space, aber .probe and .remove a tab. Please
make this uniform. (If you want to know my personal preference: A singl=
e
space. Otherwise (well unless you use a single tab) either the layout
gets broken when a member with a longer name is added or you have to
touch unrelated lines.)

> +};
> +
> +static int __init cs89x0_init(void)
> +{
> +	return platform_driver_register(&cs89x0_platform_driver);
> +}
> +
> +module_init(cs89x0_init);
> +
> +static void __exit cs89x0_cleanup(void)
> +{
> +	platform_driver_unregister(&cs89x0_platform_driver);
> +}
> +
> +module_exit(cs89x0_cleanup);
It should be possible to use module_platform_driver here. See

	http://mid.gmane.org/1326250797-17716-1-git-send-email-festevam@gmail.=
com

for an example.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
