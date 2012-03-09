From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c
Date: Thu, 8 Mar 2012 22:11:17 -0500
Message-ID: <CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>
	<4F4B2BB6.900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Michael Schmitz <schmitzmic@googlemail.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4F4B2BB6.900@gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 2:07 AM, Michael Schmitz
<schmitzmic@googlemail.com> wrote:
> Hi.
>
> after much prodding from Geert, and a bit of bouncing ideas back and =
forth,
> I've rewritten the Atari EtherNEC ethercard driver to use work with o=
nly
> minimal patches to ne.c (instead of duplicating ne.c as atari_etherne=
c.c).
>
> The EtherNEC adapter is a solution to use a RTL8019 ISA card on the
> cartridge (ROM) port of m68k Atari computers. The cartridge port does=
 not
> support generating interrupts. To service card interrupts, the 8390
> interrupt handler is called periodically from a dedicated hardware ti=
mer
> which needs to be shared with other users (the SMC91C111 EtherNAT dri=
ver,
> and a dummy handler dedicated to preventing interference from the int=
errupt
> watchdog if the card is idle).
>
> netdev subscribers please focus on the patch to ne.c at the top. Chan=
ges to
> ne.c are twofold: to select 8-bit mode for the driver, and to ensure =
the
> interrupt can be shared with aforementioned other users if the driver=
 is
> used on Atari.
>
> This patch applies on top of Geert's current linux-m68k. It won't cle=
anly
> apply on top of, or work if built from Linus' tree, as it relies on f=
urther
> patches relating to bus access quirks that are pending in Geert's tre=
e.
>
> The old EtherNEC driver is retained as-is, to be removed from Geert's=
 tree
> after this code has been accepted. It can still be built by selecting=
 the
> CONFIG_ATARI_ETHERNEC_OLD option.
>
> Comments to linux-m68k or me, please - I'm not subscribed to netdev.
>
> Cheers,
>
> =A0Michael
>
>
> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/83=
90/ne.c
> index f92ea2a..28b8781 100644
> --- a/drivers/net/ethernet/8390/ne.c
> +++ b/drivers/net/ethernet/8390/ne.c
> @@ -55,6 +55,9 @@ static const char version2[] =3D
>
> =A0#include <asm/system.h>
> =A0#include <asm/io.h>
> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
> +#include <asm/atariints.h>
> +#endif

Do you really need the #if here?  Should be avoidable.

>
> =A0#include "8390.h"
>
> @@ -165,7 +168,8 @@ bad_clone_list[] __initdata =3D {
> =A0#if defined(CONFIG_PLAT_MAPPI)
> =A0# =A0define DCR_VAL 0x4b
> =A0#elif defined(CONFIG_PLAT_OAKS32R) =A0|| \
> - =A0 defined(CONFIG_MACH_TX49XX)
> + =A0 defined(CONFIG_MACH_TX49XX) || \
> + =A0 IS_ENABLED(CONFIG_ATARI_ETHERNEC)
> =A0# =A0define DCR_VAL 0x48 =A0 =A0 =A0 =A0/* 8-bit mode */
> =A0#else
> =A0# =A0define DCR_VAL 0x49
> @@ -492,7 +496,16 @@ static int __init ne_probe1(struct net_device *d=
ev,
> unsigned long ioaddr)
>
> =A0 =A0 /* Snarf the interrupt now. =A0There's no point in waiting si=
nce we cannot
> =A0 =A0 =A0 =A0share and the board will usually be enabled. */
> - =A0 =A0ret =3D request_irq(dev->irq, eip_interrupt, 0, name, dev);
> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
> + =A0 =A0if (MACH_IS_ATARI) {
> + =A0 =A0 =A0 =A0/* Atari EtherNEC emulates the card interrupt via a =
timer -
> + =A0 =A0 =A0 =A0 =A0 this needs to be shared with the smc91C111 driv=
er and with
> + =A0 =A0 =A0 =A0 =A0 a dummy handler to catch unhandled interrupts !=
 */
> + =A0 =A0 =A0 =A0ret =3D request_irq(dev->irq, eip_interrupt, IRQF_SH=
ARED, name, dev);
> + =A0 =A0} else
> +#endif
> + =A0 =A0 =A0 =A0ret =3D request_irq(dev->irq, eip_interrupt, 0, name=
, dev);
> +

There has to be a cleaner way than this.  Something as simple as creati=
ng
a platform specific 8380_IRQ_FLAGS would get rid of this ifdef'ery in
the driver and that is with only 20s of thought invested.

Paul.
--

> =A0 =A0 if (ret) {
> =A0 =A0 =A0 =A0 printk (" unable to get IRQ %d (errno=3D%d).\n", dev-=
>irq, ret);
> =A0 =A0 =A0 =A0 goto err_out;
> diff --git a/arch/m68k/atari/config.c b/arch/m68k/atari/config.c
> index af78731..3ff7231 100644
> --- a/arch/m68k/atari/config.c
> +++ b/arch/m68k/atari/config.c
> @@ -687,13 +687,67 @@ static struct platform_device smc91x_device =3D=
 {
> =A0 =A0 .resource =A0 =A0=3D smc91x_resources,
> =A0};
>
> +
> +#define ATARI_ETHERNEC_BASE 0x300
> +#define ATARI_ETHERNEC_IRQ IRQ_MFP_TIMD
> +
> +
> +static struct resource rtl8019_resources[] =3D {
> + =A0 =A0[0] =3D {
> + =A0 =A0 =A0 =A0.name =A0 =A0=3D "rtl9019-regs",
> + =A0 =A0 =A0 =A0.start =A0 =A0=3D ATARI_ETHERNEC_BASE,
> + =A0 =A0 =A0 =A0.end =A0 =A0=3D ATARI_ETHERNEC_BASE + 0x20 - 1,
> + =A0 =A0 =A0 =A0.flags =A0 =A0=3D IORESOURCE_IO,
> + =A0 =A0},
> + =A0 =A0[1] =3D {
> + =A0 =A0 =A0 =A0.name =A0 =A0=3D "rtl9019-irq",
> + =A0 =A0 =A0 =A0.start =A0 =A0=3D ATARI_ETHERNEC_IRQ,
> + =A0 =A0 =A0 =A0.end =A0 =A0=3D ATARI_ETHERNEC_IRQ,
> + =A0 =A0 =A0 =A0.flags =A0 =A0=3D IORESOURCE_IRQ,
> + =A0 =A0},
> +};
> +
> +static struct platform_device rtl8019_device =3D {
> + =A0 =A0.name =A0 =A0 =A0 =A0=3D "ne",
> + =A0 =A0.id =A0 =A0 =A0 =A0=3D -1,
> + =A0 =A0.num_resources =A0 =A0=3D ARRAY_SIZE(rtl8019_resources),
> + =A0 =A0.resource =A0 =A0=3D rtl8019_resources,
> +};
> +
> +
> =A0static struct platform_device *atari_platform_devices[] __initdata=
 =3D {
> - &smc91x_device
> + &smc91x_device,
> + &rtl8019_device
> =A0};
>
> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC) || IS_ENABLED(CONFIG_ATARI_ETH=
ERNAT)
> +irqreturn_t atari_timerd_interrupt(int irq, void *dev_id)
> +{
> + =A0 =A0return IRQ_HANDLED;
> +}
> +#endif
> +
> =A0int __init atari_platform_init(void)
> =A0{
> - =A0 =A0return platform_add_devices(atari_platform_devices,
> ARRAY_SIZE(atari_platform_devices));
> +
> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC) || IS_ENABLED(CONFIG_ATARI_ETH=
ERNAT)
> + =A0 =A0if (hwreg_present(0xfffa0000) || hwreg_present(0x80000000)) =
{
> + =A0 =A0 =A0 =A0int ret;
> + =A0 =A0 =A0 =A0const char *name =3D "Timer D dummy interrupt";
> + =A0 =A0 =A0 =A0/* timer routine set up in atari_ethernec_probe() */
> + =A0 =A0 =A0 =A0/* set Timer D data Register */
> + =A0 =A0 =A0 =A0st_mfp.tim_dt_d =3D 123; =A0 =A0/* 200 Hz */
> + =A0 =A0 =A0 =A0/* start timer D, div =3D 1:100 */
> + =A0 =A0 =A0 =A0st_mfp.tim_ct_cd =3D (st_mfp.tim_ct_cd & 0xf0) | 0x6=
;
> + =A0 =A0 =A0 =A0/* Must make this shared in case other timer ints ar=
e needed */
> + =A0 =A0 =A0 =A0ret =3D request_irq(IRQ_MFP_TIMD, atari_timerd_inter=
rupt,
> IRQF_SHARED, name, atari_timerd_interrupt);
> + =A0 =A0 =A0 =A0if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "atari_platform_init: failed=
 to register dummy
> timer interrupt for EtherNEC/EtherNAT!\n");
> + =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0return platform_add_devices(atari_platform_devices,
> ARRAY_SIZE(atari_platform_devices));
> + =A0 =A0}
> +#endif
> + =A0 =A0return 0;
> =A0}
>
> =A0arch_initcall(atari_platform_init);
> diff --git a/arch/m68k/configs/atari_defconfig
> b/arch/m68k/configs/atari_defconfig
> index 6e86de1..5f8e91f 100644
> --- a/arch/m68k/configs/atari_defconfig
> +++ b/arch/m68k/configs/atari_defconfig
> @@ -201,7 +201,7 @@ CONFIG_NET_ETHERNET=3Dy
> =A0CONFIG_MII=3Dy
> =A0CONFIG_ATARILANCE=3Dy
> =A0CONFIG_ATARI_ETHERNAT=3Dm
> -CONFIG_ATARI_ETHERNEC=3Dy
> +CONFIG_ATARI_ETHERNEC=3Dm
> =A0# CONFIG_NETDEV_1000 is not set
> =A0# CONFIG_NETDEV_10000 is not set
> =A0CONFIG_PPP=3Dm
> diff --git a/drivers/net/Space.c b/drivers/net/Space.c
> index d5e8882..548b73b 100644
> --- a/drivers/net/Space.c
> +++ b/drivers/net/Space.c
> @@ -243,7 +243,7 @@ static struct devprobe2 m68k_probes[] __initdata =
=3D {
> =A0#ifdef CONFIG_ATARILANCE =A0 =A0/* Lance-based Atari ethernet boar=
ds */
> =A0 =A0 {atarilance_probe, 0},
> =A0#endif
> -#ifdef CONFIG_ATARI_ETHERNEC =A0 =A0/* NE2000 based ROM port etherne=
t cards */
> +#ifdef CONFIG_ATARI_ETHERNEC_OLD =A0 =A0/* NE2000 based ROM port eth=
ernet cards
> */
> =A0 =A0 {atari_ethernec_probe, 0},
> =A0#endif
> =A0#ifdef CONFIG_SUN3LANCE =A0 =A0 =A0 =A0 /* sun3 onboard Lance chip=
 */
> diff --git a/drivers/net/ethernet/8390/Kconfig
> b/drivers/net/ethernet/8390/Kconfig
> index b801056..ca5adab 100644
> --- a/drivers/net/ethernet/8390/Kconfig
> +++ b/drivers/net/ethernet/8390/Kconfig
> @@ -223,9 +223,18 @@ config APNE
> =A0 =A0 =A0 To compile this driver as a module, choose M here: the mo=
dule
> =A0 =A0 =A0 will be called apne.
>
> +config ATARI_ETHERNEC_OLD
> + =A0 =A0tristate "Atari EtherNEC Ethernet support - old driver"
> + =A0 =A0depends on ATARI_ROM_ISA
> + =A0 =A0help
> + =A0 =A0 =A0Say Y to include support for the EtherNEC network adapte=
r for the
> + =A0 =A0 =A0ROM port. The driver works by polling instead of interru=
pts, so it
> + =A0 =A0 =A0is quite slow.
> +
> =A0config ATARI_ETHERNEC
> - =A0 =A0tristate "Atari EtherNEC Ethernet support"
> + =A0 =A0tristate "Atari EtherNEC Ethernet support - mainstream NE200=
0 driver"
> =A0 =A0 depends on ATARI_ROM_ISA
> + =A0 =A0select CRC32
> =A0 =A0 help
> =A0 =A0 =A0 Say Y to include support for the EtherNEC network adapter=
 for the
> =A0 =A0 =A0 ROM port. The driver works by polling instead of interrup=
ts, so it
> diff --git a/drivers/net/ethernet/8390/Makefile
> b/drivers/net/ethernet/8390/Makefile
> index d896466..e620355 100644
> --- a/drivers/net/ethernet/8390/Makefile
> +++ b/drivers/net/ethernet/8390/Makefile
> @@ -6,7 +6,8 @@ obj-$(CONFIG_MAC8390) +=3D mac8390.o
> =A0obj-$(CONFIG_AC3200) +=3D ac3200.o 8390.o
> =A0obj-$(CONFIG_APNE) +=3D apne.o 8390.o
> =A0obj-$(CONFIG_ARM_ETHERH) +=3D etherh.o
> -obj-$(CONFIG_ATARI_ETHERNEC) +=3D atari_ethernec.o 8390.o
> +obj-$(CONFIG_ATARI_ETHERNEC_OLD) +=3D atari_ethernec.o 8390.o
> +obj-$(CONFIG_ATARI_ETHERNEC) +=3D ne.o 8390p.o
> =A0obj-$(CONFIG_AX88796) +=3D ax88796.o
> =A0obj-$(CONFIG_E2100) +=3D e2100.o 8390.o
> =A0obj-$(CONFIG_EL2) +=3D 3c503.o 8390p.o
> diff --git a/drivers/net/ethernet/8390/atari_ethernec.c
> b/drivers/net/ethernet/8390/atari_ethernec.c
> index 086d968..e051094 100644
> --- a/drivers/net/ethernet/8390/atari_ethernec.c
> +++ b/drivers/net/ethernet/8390/atari_ethernec.c
> @@ -93,6 +93,7 @@ static const char version2[] =3D
> =A0#include <linux/init.h>
> =A0#include <linux/interrupt.h>
> =A0#include <linux/delay.h>
> +#include <linux/platform_device.h>
> =A0#include <linux/netdevice.h>
> =A0#include <linux/etherdevice.h>
> =A0#include <linux/jiffies.h>
> @@ -185,13 +186,13 @@ bad_clone_list[] __initdata =3D {
> =A0# =A0define DCR_VAL 0x4b
> =A0#elif defined(CONFIG_PLAT_OAKS32R) =A0|| \
> =A0 =A0defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBT=
X4938) || \
> - =A0 defined(CONFIG_ATARI_ETHERNEC) || defined(CONFIG_ATARI_ETHERNEC=
_MODULE)
> + =A0 IS_ENABLED(CONFIG_ATARI_ETHERNEC_OLD)
> =A0# =A0define DCR_VAL 0x48 =A0 =A0 =A0 =A0/* 8-bit mode */
> =A0#else
> =A0# =A0define DCR_VAL 0x49
> =A0#endif
>
> -#if defined(CONFIG_ATARI_ETHERNEC) || defined(CONFIG_ATARI_ETHERNEC_=
MODULE)
> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC_OLD)
> =A0# =A0define ETHERNEC_RTL_8019_BASE 0x300
> =A0# =A0define ETHERNEC_RTL_8019_IRQ IRQ_MFP_TIMD
> =A0#endif
> @@ -229,7 +230,7 @@ irqreturn_t atari_ei_interrupt(int irq, void *dev=
_id)
> =A0 =A0 struct net_device *dev =3D dev_id;
> =A0 =A0 if (netif_running(dev))
> =A0 =A0 =A0 =A0 return ei_interrupt(dev->irq, dev);
> - =A0 =A0return IRQ_NONE;
> + =A0 =A0return IRQ_HANDLED;
> =A0}
>
> =A0static void atari_ethernec_int(struct work_struct *work)
> @@ -357,7 +358,7 @@ struct net_device * __init atari_ethernec_probe(i=
nt
> unit)
> =A0 =A0 sprintf(dev->name, "eth%d", unit);
> =A0 =A0 netdev_boot_setup_check(dev);
>
> -#if defined(CONFIG_ATARI_ETHERNEC)
> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC_OLD)
> =A0 =A0 dev->base_addr =3D ETHERNEC_RTL_8019_BASE;
> =A0 =A0 dev->irq =3D ETHERNEC_RTL_8019_IRQ;
> =A0#endif
> @@ -456,7 +457,7 @@ static int __init ne_probe1(struct net_device *de=
v, int
> ioaddr)
> =A0 =A0 }
>
> =A0 =A0 if (ei_debug && version_printed++ =3D=3D 0)
> - =A0 =A0 =A0 =A0printk(KERN_INFO "%s" KERN_INFO "%s", version1, vers=
ion2);
> + =A0 =A0 =A0 =A0printk(KERN_INFO "%s%s", version1, version2);
>
> =A0 =A0 /* A user with a poor card that fails to ack the reset, or th=
at
> =A0 =A0 =A0 =A0does not have a valid 0x57,0x57 signature can still us=
e this
> @@ -941,9 +942,10 @@ module_param(use_poll, int, 0);
> =A0MODULE_PARM_DESC(io, "I/O base address(es),required");
> =A0MODULE_PARM_DESC(irq, "IRQ number(s)");
> =A0MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
> -MODULE_PARM_DESC(use_poll, "Use timer interrupt to poll driver");
> +MODULE_PARM_DESC(use_poll, "Use system timer to poll driver");
> =A0MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
> =A0MODULE_LICENSE("GPL");
> +MODULE_ALIAS("platform:8390");
>
> =A0/* This is set up so that no ISA autoprobe takes place. We can't g=
uarantee
> =A0that the ne2k probe is the last 8390 based probe to take place (as=
 it
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
