From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] can: mscan-mpc5xxx: add support for the
	MPC521x processor
Date: Sat, 2 Jan 2010 14:57:34 +0100
Message-ID: <20100102135734.GC2239@pengutronix.de>
References: <1262420274-16586-1-git-send-email-wg@grandegger.com>
	<1262420274-16586-2-git-send-email-wg@grandegger.com>
	<1262420274-16586-3-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0534521259=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1262420274-16586-3-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============0534521259==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eHhjakXzOLJAF9wJ"
Content-Disposition: inline


--eHhjakXzOLJAF9wJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jan 02, 2010 at 09:17:53AM +0100, Wolfgang Grandegger wrote:
> From: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
>=20
> The main differences compared to the MSCAN on the MPC5200 are:
>=20
> - More flexibility in choosing the CAN source clock and frequency:
>=20
>   Three different clock sources can be selected: "ip", "ref" or "sys".
>   For the latter two, a clock divider can be defined as well. If the
>   clock source is not specified by the device tree, we first try to
>   find an optimal CAN source clock based on the system clock. If that
>   is not possible, the reference clock will be used.
>=20
> - The behavior of bus-off recovery is configurable:
>=20
>   To comply with the usual handling of Socket-CAN bus-off recovery,
>   "recovery on request" is selected (instead of automatic recovery).
>=20
> Signed-off-by: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
> ---
>  drivers/net/can/mscan/Kconfig       |    2 +-
>  drivers/net/can/mscan/mpc5xxx_can.c |  234 +++++++++++++++++++++++++++++=
------
>  drivers/net/can/mscan/mscan.c       |   41 +++++--
>  drivers/net/can/mscan/mscan.h       |   81 ++++++------
>  4 files changed, 271 insertions(+), 87 deletions(-)
>=20
> diff --git a/drivers/net/can/mscan/Kconfig b/drivers/net/can/mscan/Kconfig
> index cd0f2d6..723d009 100644
> --- a/drivers/net/can/mscan/Kconfig
> +++ b/drivers/net/can/mscan/Kconfig
> @@ -11,7 +11,7 @@ if CAN_MSCAN
> =20
>  config CAN_MPC5XXX
>  	tristate "Freescale MPC5xxx onboard CAN controller"
> -	depends on PPC_MPC52xx
> +	depends on (PPC_MPC52xx || PPC_MPC512x)
>  	---help---
>  	  If you say yes here you get support for Freescale's MPC5xxx
>  	  onboard CAN controller.
> diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/=
mpc5xxx_can.c
> index 1de6f63..42c719b 100644
> --- a/drivers/net/can/mscan/mpc5xxx_can.c
> +++ b/drivers/net/can/mscan/mpc5xxx_can.c
> @@ -29,6 +29,7 @@
>  #include <linux/can/dev.h>
>  #include <linux/of_platform.h>
>  #include <sysdev/fsl_soc.h>
> +#include <linux/clk.h>
>  #include <linux/io.h>
>  #include <asm/mpc52xx.h>
> =20
> @@ -36,22 +37,15 @@
> =20
>  #define DRV_NAME "mpc5xxx_can"
> =20
> +#ifdef CONFIG_PPC_MPC5200
>  static struct of_device_id mpc52xx_cdm_ids[] __devinitdata =3D {
>  	{ .compatible =3D "fsl,mpc5200-cdm", },
>  	{}
>  };
> =20
> -/*
> - * Get frequency of the MSCAN clock source
> - *
> - * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock (IP_CLK)
> - * can be selected. According to the MPC5200 user's manual, the oscillat=
or
> - * clock is the better choice as it has less jitter but due to a hardware
> - * bug, it can not be selected for the old MPC5200 Rev. A chips.
> - */
> -
> -static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *=
of,
> -						      int clock_src)
> +static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
> +					   const char *clock_name,
> +					   int *mscan_clksrc)
>  {
>  	unsigned int pvr;
>  	struct mpc52xx_cdm  __iomem *cdm;
> @@ -61,11 +55,24 @@ static unsigned int  __devinit mpc52xx_can_clock_freq=
(struct of_device *of,
> =20
>  	pvr =3D mfspr(SPRN_PVR);
> =20
> -	freq =3D mpc5xxx_get_bus_frequency(of->node);
> +	/*
> +	 * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock
> +	 * (IP_CLK) can be selected as MSCAN clock source. According to
> +	 * the MPC5200 user's manual, the oscillator clock is the better
> +	 * choice as it has less jitter. For this reason, it is selected
> +	 * by default. Unfortunately, it can not be selected for the old
> +	 * MPC5200 Rev. A chips due toa hardware bug (check errata).

s/toa/to a/

> +	 */
> +	if (clock_name && strcmp(clock_name, "ip") =3D=3D 0)
> +		*mscan_clksrc =3D MSCAN_CLKSRC_BUS;
> +	else
> +		*mscan_clksrc =3D MSCAN_CLKSRC_XTAL;
> +
> +	freq =3D mpc5xxx_get_bus_frequency(ofdev->node);
>  	if (!freq)
>  		return 0;
> =20
> -	if (clock_src =3D=3D MSCAN_CLKSRC_BUS || pvr =3D=3D 0x80822011)
> +	if (*mscan_clksrc =3D=3D MSCAN_CLKSRC_BUS || pvr =3D=3D 0x80822011)
>  		return freq;
> =20
>  	/* Determine SYS_XTAL_IN frequency from the clock domain settings */
> @@ -75,7 +82,6 @@ static unsigned int  __devinit mpc52xx_can_clock_freq(s=
truct of_device *of,
>  		return 0;
>  	}
>  	cdm =3D of_iomap(np_cdm, 0);
> -	of_node_put(np_cdm);
> =20
>  	if (in_8(&cdm->ipb_clk_sel) & 0x1)
>  		freq *=3D 2;
> @@ -84,10 +90,157 @@ static unsigned int  __devinit mpc52xx_can_clock_fre=
q(struct of_device *of,
>  	freq *=3D (val & (1 << 5)) ? 8 : 4;
>  	freq /=3D (val & (1 << 6)) ? 12 : 16;
> =20
> +	of_node_put(np_cdm);
>  	iounmap(cdm);
> =20
>  	return freq;
>  }
> +#else /* !CONFIG_PPC_MPC5200 */
> +static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
> +					   const char *clock_name,
> +					   int *mscan_clksrc)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_PPC_MPC5200 */

Hmmm, I don't really like those empty functions. I once used the data-field=
 of
struct of_device_id, which carried a function pointer to a specific
init-function for the matched device. What do you think about such an appro=
ach?

> +
> +#ifdef CONFIG_PPC_MPC512x
> +struct mpc512x_clockctl {
> +	u32 spmr;		/* System PLL Mode Reg */
> +	u32 sccr[2];		/* System Clk Ctrl Reg 1 & 2 */
> +	u32 scfr1;		/* System Clk Freq Reg 1 */
> +	u32 scfr2;		/* System Clk Freq Reg 2 */
> +	u32 reserved;
> +	u32 bcr;		/* Bread Crumb Reg */
> +	u32 pccr[12];		/* PSC Clk Ctrl Reg 0-11 */
> +	u32 spccr;		/* SPDIF Clk Ctrl Reg */
> +	u32 cccr;		/* CFM Clk Ctrl Reg */
> +	u32 dccr;		/* DIU Clk Cnfg Reg */
> +	u32 mccr[4];		/* MSCAN Clk Ctrl Reg 1-3 */
> +};
> +
> +static struct of_device_id mpc512x_clock_ids[] __devinitdata =3D {
> +	{ .compatible =3D "fsl,mpc5121-clock", },
> +	{}
> +};
> +
> +static u32  __devinit mpc512x_can_get_clock(struct of_device *ofdev,
> +					    const char *clock_name,
> +					    int *mscan_clksrc,
> +					    ssize_t mscan_addr)
> +{
> +	struct mpc512x_clockctl __iomem *clockctl;
> +	struct device_node *np_clock;
> +	struct clk *sys_clk, *ref_clk;
> +	int plen, clockidx, clocksrc =3D -1;
> +	u32 sys_freq, val, clockdiv =3D 1, freq =3D 0;
> +	const u32 *pval;
> +
> +	np_clock =3D of_find_matching_node(NULL, mpc512x_clock_ids);
> +	if (!np_clock) {
> +		dev_err(&ofdev->dev, "couldn't find clock node\n");
> +		return -ENODEV;
> +	}
> +	clockctl =3D of_iomap(np_clock, 0);
> +	if (!clockctl) {
> +		dev_err(&ofdev->dev, "couldn't map clock registers\n");
> +		return 0;
> +	}
> +
> +	/* Determine the MSCAN device index from the physical address */
> +	clockidx =3D (mscan_addr & 0x80) ? 1 : 0;
> +	if (mscan_addr & 0x2000)
> +		clockidx +=3D 2;

The PSCs use 'cell-index', here we use mscan_addr to derive the index. This=
 is
not consistent, but should be IMHO. Now, which is the preferred way? I think
I'd go for 'cell-index', as other processors might have mscan_addr shuffled.
Also, we could use 'of_iomap' again in the probe_routine.

> +
> +	/*
> +	 * Clock source and divider selection: 3 different clock sources
> +	 * can be selected: "ip", "ref" or "sys". For the latetr two, a
> +	 * clock divider can be defined as well. If the clock source is
> +	 * not specified by the device tree, we first try to find an
> +	 * optimal CAN source clock based on the system clock. If that
> +	 * is not posslible, the reference clock will be used.
> +	 */
> +	if (clock_name && !strcmp(clock_name, "ip")) {
> +		*mscan_clksrc =3D MSCAN_CLKSRC_IPS;
> +		freq =3D mpc5xxx_get_bus_frequency(ofdev->node);
> +	} else {
> +		*mscan_clksrc =3D MSCAN_CLKSRC_BUS;
> +
> +		pval =3D of_get_property(ofdev->node,
> +				       "fsl,mscan-clock-divider", &plen);
> +		if (pval && plen =3D=3D sizeof(*pval))
> +			clockdiv =3D *pval;
> +		if (!clockdiv)
> +			clockdiv =3D 1;
> +
> +		if (!clock_name || !strcmp(clock_name, "sys")) {
> +			sys_clk =3D clk_get(&ofdev->dev, "sys_clk");
> +			if (!sys_clk) {
> +				dev_err(&ofdev->dev, "couldn't get sys_clk\n");
> +				goto exit_unmap;
> +			}
> +			/* Get and round up/down sys clock rate */
> +			sys_freq =3D 1000000 *
> +				((clk_get_rate(sys_clk) + 499999) / 1000000);
> +
> +			if (!clock_name) {
> +				/* A multiple of 16 MHz would be optimal */
> +				if ((sys_freq % 16000000) =3D=3D 0) {
> +					clocksrc =3D 0;
> +					clockdiv =3D sys_freq / 16000000;
> +					freq =3D sys_freq / clockdiv;
> +				}
> +			} else {
> +				clocksrc =3D 0;
> +				freq =3D sys_freq / clockdiv;
> +			}
> +		}
> +
> +		if (clocksrc < 0) {
> +			ref_clk =3D clk_get(&ofdev->dev, "ref_clk");
> +			if (!ref_clk) {
> +				dev_err(&ofdev->dev, "couldn't get ref_clk\n");
> +				goto exit_unmap;
> +			}
> +			clocksrc =3D 1;
> +			freq =3D clk_get_rate(ref_clk) / clockdiv;
> +		}
> +	}
> +
> +	/* Disable clock */
> +	out_be32(&clockctl->mccr[clockidx], 0x0);
> +	if (clocksrc >=3D 0) {
> +		/* Set source and divider */
> +		val =3D (clocksrc << 14) | ((clockdiv - 1) << 17);
> +		out_be32(&clockctl->mccr[clockidx], val);
> +		/* Dnable clock */

Enable

> +		out_be32(&clockctl->mccr[clockidx], val | 0x10000);
> +	}
> +
> +	/* Enable MSCAN clock domain */
> +	val =3D in_be32(&clockctl->sccr[1]);
> +	if (!(val & (1 << 25)))
> +		out_be32(&clockctl->sccr[1], val | (1 << 25));
> +
> +	dev_dbg(&ofdev->dev, "using '%s' with frequency divider %d\n",
> +		*mscan_clksrc =3D=3D MSCAN_CLKSRC_IPS ? "ips_clk" :
> +		clocksrc =3D=3D 1 ? "ref_clk" : "sys_clk", clockdiv);
> +
> +exit_unmap:
> +	of_node_put(np_clock);
> +	iounmap(clockctl);
> +
> +	return freq;
> +}
> +#else /* !CONFIG_PPC_MPC512x */
> +static u32  __devinit mpc512x_can_get_clock(struct of_device *ofdev,
> +					    const char *clock_name,
> +					    int *mscan_clksrc,
> +					    ssize_t mscan_addr)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_PPC_MPC512x */
> =20
>  static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
>  				       const struct of_device_id *id)
> @@ -95,15 +248,21 @@ static int __devinit mpc5xxx_can_probe(struct of_dev=
ice *ofdev,
>  	struct device_node *np =3D ofdev->node;
>  	struct net_device *dev;
>  	struct mscan_priv *priv;
> +	struct resource res;
>  	void __iomem *base;
> -	const char *clk_src;
> -	int err, irq, clock_src;
> +	const char *clock_name =3D NULL;
> +	int irq, clock_src =3D 0;
> +	int err =3D -ENOMEM;
> =20
> -	base =3D of_iomap(ofdev->node, 0);
> +	if (of_address_to_resource(np, 0, &res)) {
> +		dev_err(&ofdev->dev, "couldn't get resource address\n");
> +		return err;
> +	}
> +
> +	base =3D ioremap(res.start, resource_size(&res));
>  	if (!base) {
>  		dev_err(&ofdev->dev, "couldn't ioremap\n");
> -		err =3D -ENOMEM;
> -		goto exit_release_mem;
> +		return err;
>  	}
> =20
>  	irq =3D irq_of_parse_and_map(np, 0);
> @@ -114,31 +273,27 @@ static int __devinit mpc5xxx_can_probe(struct of_de=
vice *ofdev,
>  	}
> =20
>  	dev =3D alloc_mscandev();
> -	if (!dev) {
> -		err =3D -ENOMEM;
> +	if (!dev)
>  		goto exit_dispose_irq;
> -	}
> =20
>  	priv =3D netdev_priv(dev);
>  	priv->reg_base =3D base;
>  	dev->irq =3D irq;
> =20
> -	/*
> -	 * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock
> -	 * (IP_CLK) can be selected as MSCAN clock source. According to
> -	 * the MPC5200 user's manual, the oscillator clock is the better
> -	 * choice as it has less jitter. For this reason, it is selected
> -	 * by default.
> -	 */
> -	clk_src =3D of_get_property(np, "fsl,mscan-clock-source", NULL);
> -	if (clk_src && strcmp(clk_src, "ip") =3D=3D 0)
> -		clock_src =3D MSCAN_CLKSRC_BUS;
> -	else
> -		clock_src =3D MSCAN_CLKSRC_XTAL;
> -	priv->can.clock.freq =3D mpc52xx_can_clock_freq(ofdev, clock_src);
> +	clock_name =3D of_get_property(np, "fsl,mscan-clock-source", NULL);
> +
> +	if (of_device_is_compatible(np, "fsl,mpc5121-mscan")) {
> +		priv->type =3D MSCAN_TYPE_MPC5121;
> +		priv->can.clock.freq =3D
> +			mpc512x_can_get_clock(ofdev, clock_name, &clock_src,
> +					      res.start);
> +	} else {
> +		priv->type =3D MSCAN_TYPE_MPC5200;
> +		priv->can.clock.freq =3D
> +			mpc52xx_can_get_clock(ofdev, clock_name, &clock_src);
> +	}
>  	if (!priv->can.clock.freq) {
> -		dev_err(&ofdev->dev, "couldn't get MSCAN clock frequency\n");
> -		err =3D -ENODEV;
> +		dev_err(&ofdev->dev, "couldn't get MSCAN clock properties\n");
>  		goto exit_free_mscan;
>  	}
> =20
> @@ -164,7 +319,7 @@ exit_dispose_irq:
>  	irq_dispose_mapping(irq);
>  exit_unmap_mem:
>  	iounmap(base);
> -exit_release_mem:
> +
>  	return err;
>  }
> =20
> @@ -227,6 +382,7 @@ static int mpc5xxx_can_resume(struct of_device *ofdev)
> =20
>  static struct of_device_id __devinitdata mpc5xxx_can_table[] =3D {
>  	{.compatible =3D "fsl,mpc5200-mscan"},
> +	{.compatible =3D "fsl,mpc5121-mscan"},
>  	{},
>  };
> =20
> @@ -255,5 +411,5 @@ static void __exit mpc5xxx_can_exit(void)
>  module_exit(mpc5xxx_can_exit);
> =20
>  MODULE_AUTHOR("Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>");
> -MODULE_DESCRIPTION("Freescale MPC5200 CAN driver");
> +MODULE_DESCRIPTION("Freescale MPC5200 and MPC521x CAN driver");

simply 5xxx?

>  MODULE_LICENSE("GPL v2");
> diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
> index abdf5e8..9812aa0 100644
> --- a/drivers/net/can/mscan/mscan.c
> +++ b/drivers/net/can/mscan/mscan.c
> @@ -169,6 +169,27 @@ static int mscan_start(struct net_device *dev)
>  	return 0;
>  }
> =20
> +static int mscan_restart(struct net_device *dev)
> +{
> +	struct mscan_priv *priv =3D netdev_priv(dev);
> +
> +	if (priv->type =3D=3D MSCAN_TYPE_MPC5121) {
> +		struct mscan_regs *regs =3D (struct mscan_regs *)priv->reg_base;
> +
> +		priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +		if (!(in_8(&regs->canmisc) & MSCAN_BOHOLD))
> +			dev_err(dev->dev.parent, "Oops, not bus-off");

I think this error-message could be improved :)

> +		else
> +			out_8(&regs->canmisc, MSCAN_BOHOLD);
> +	} else {
> +		if (priv->can.state <=3D CAN_STATE_BUS_OFF)
> +			mscan_set_mode(dev, MSCAN_INIT_MODE);
> +		return mscan_start(dev);
> +	}
> +
> +	return 0;
> +}
> +
>  static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_devi=
ce *dev)
>  {
>  	struct can_frame *frame =3D (struct can_frame *)skb->data;
> @@ -364,9 +385,12 @@ static void mscan_get_err_frame(struct net_device *d=
ev, struct can_frame *frame,
>  			 * automatically. To avoid that we stop the chip doing
>  			 * a light-weight stop (we are in irq-context).
>  			 */
> -			out_8(&regs->cantier, 0);
> -			out_8(&regs->canrier, 0);
> -			setbits8(&regs->canctl0, MSCAN_SLPRQ | MSCAN_INITRQ);
> +			if (priv->type !=3D MSCAN_TYPE_MPC5121) {
> +				out_8(&regs->cantier, 0);
> +				out_8(&regs->canrier, 0);
> +				setbits8(&regs->canctl0,
> +					 MSCAN_SLPRQ | MSCAN_INITRQ);
> +			}
>  			can_bus_off(dev);
>  			break;
>  		default:
> @@ -496,9 +520,7 @@ static int mscan_do_set_mode(struct net_device *dev, =
enum can_mode mode)
> =20
>  	switch (mode) {
>  	case CAN_MODE_START:
> -		if (priv->can.state <=3D CAN_STATE_BUS_OFF)
> -			mscan_set_mode(dev, MSCAN_INIT_MODE);
> -		ret =3D mscan_start(dev);
> +		ret =3D mscan_restart(dev);
>  		if (ret)
>  			break;
>  		if (netif_queue_stopped(dev))
> @@ -597,18 +619,21 @@ static const struct net_device_ops mscan_netdev_ops=
 =3D {
>         .ndo_start_xmit         =3D mscan_start_xmit,
>  };
> =20
> -int register_mscandev(struct net_device *dev, int clock_src)
> +int register_mscandev(struct net_device *dev, int mscan_clksrc)
>  {
>  	struct mscan_priv *priv =3D netdev_priv(dev);
>  	struct mscan_regs *regs =3D (struct mscan_regs *)priv->reg_base;
>  	u8 ctl1;
> =20
>  	ctl1 =3D in_8(&regs->canctl1);
> -	if (clock_src)
> +	if (mscan_clksrc)
>  		ctl1 |=3D MSCAN_CLKSRC;
>  	else
>  		ctl1 &=3D ~MSCAN_CLKSRC;
> =20
> +	if (priv->type =3D=3D MSCAN_TYPE_MPC5121)
> +		ctl1 |=3D MSCAN_BORM; /* bus-off recovery upon request */
> +
>  	ctl1 |=3D MSCAN_CANE;
>  	out_8(&regs->canctl1, ctl1);
>  	udelay(100);
> diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
> index 00fc4aa..2114942 100644
> --- a/drivers/net/can/mscan/mscan.h
> +++ b/drivers/net/can/mscan/mscan.h
> @@ -39,17 +39,19 @@
>  #define MSCAN_LOOPB		0x20
>  #define MSCAN_LISTEN		0x10
>  #define MSCAN_WUPM		0x04
> +#define MSCAN_BORM		0x08

This should be one line up to keep the sorting intact.

>  #define MSCAN_SLPAK		0x02
>  #define MSCAN_INITAK		0x01
> =20
> -/* Use the MPC5200 MSCAN variant? */
> +/* Use the MPC5XXX MSCAN variant? */
>  #ifdef CONFIG_PPC
> -#define MSCAN_FOR_MPC5200
> +#define MSCAN_FOR_MPC5XXX
>  #endif
> =20
> -#ifdef MSCAN_FOR_MPC5200
> +#ifdef MSCAN_FOR_MPC5XXX
>  #define MSCAN_CLKSRC_BUS	0
>  #define MSCAN_CLKSRC_XTAL	MSCAN_CLKSRC
> +#define MSCAN_CLKSRC_IPS	MSCAN_CLKSRC
>  #else
>  #define MSCAN_CLKSRC_BUS	MSCAN_CLKSRC
>  #define MSCAN_CLKSRC_XTAL	0
> @@ -136,7 +138,7 @@
>  #define MSCAN_EFF_RTR_SHIFT	0
>  #define MSCAN_EFF_FLAGS		0x18	/* IDE + SRR */
> =20
> -#ifdef MSCAN_FOR_MPC5200
> +#ifdef MSCAN_FOR_MPC5XXX
>  #define _MSCAN_RESERVED_(n, num) u8 _res##n[num]
>  #define _MSCAN_RESERVED_DSR_SIZE	2
>  #else
> @@ -165,67 +167,66 @@ struct mscan_regs {
>  	u8 cantbsel;				/* + 0x14     0x0a */
>  	u8 canidac;				/* + 0x15     0x0b */
>  	u8 reserved;				/* + 0x16     0x0c */
> -	_MSCAN_RESERVED_(6, 5);			/* + 0x17          */
> -#ifndef MSCAN_FOR_MPC5200
> -	u8 canmisc;				/*            0x0d */
> -#endif
> +	_MSCAN_RESERVED_(6, 2);			/* + 0x17          */
> +	u8 canmisc;				/* + 0x19     0x0d */
> +	_MSCAN_RESERVED_(7, 2);			/* + 0x1a          */
>  	u8 canrxerr;				/* + 0x1c     0x0e */
>  	u8 cantxerr;				/* + 0x1d     0x0f */
> -	_MSCAN_RESERVED_(7, 2);			/* + 0x1e          */
> +	_MSCAN_RESERVED_(8, 2);			/* + 0x1e          */
>  	u16 canidar1_0;				/* + 0x20     0x10 */
> -	_MSCAN_RESERVED_(8, 2);			/* + 0x22          */
> +	_MSCAN_RESERVED_(9, 2);			/* + 0x22          */
>  	u16 canidar3_2;				/* + 0x24     0x12 */
> -	_MSCAN_RESERVED_(9, 2);			/* + 0x26          */
> +	_MSCAN_RESERVED_(10, 2);		/* + 0x26          */
>  	u16 canidmr1_0;				/* + 0x28     0x14 */
> -	_MSCAN_RESERVED_(10, 2);		/* + 0x2a          */
> +	_MSCAN_RESERVED_(11, 2);		/* + 0x2a          */
>  	u16 canidmr3_2;				/* + 0x2c     0x16 */
> -	_MSCAN_RESERVED_(11, 2);		/* + 0x2e          */
> +	_MSCAN_RESERVED_(12, 2);		/* + 0x2e          */
>  	u16 canidar5_4;				/* + 0x30     0x18 */
> -	_MSCAN_RESERVED_(12, 2);		/* + 0x32          */
> +	_MSCAN_RESERVED_(13, 2);		/* + 0x32          */
>  	u16 canidar7_6;				/* + 0x34     0x1a */
> -	_MSCAN_RESERVED_(13, 2);		/* + 0x36          */
> +	_MSCAN_RESERVED_(14, 2);		/* + 0x36          */
>  	u16 canidmr5_4;				/* + 0x38     0x1c */
> -	_MSCAN_RESERVED_(14, 2);		/* + 0x3a          */
> +	_MSCAN_RESERVED_(15, 2);		/* + 0x3a          */
>  	u16 canidmr7_6;				/* + 0x3c     0x1e */
> -	_MSCAN_RESERVED_(15, 2);		/* + 0x3e          */
> +	_MSCAN_RESERVED_(16, 2);		/* + 0x3e          */
>  	struct {
>  		u16 idr1_0;			/* + 0x40     0x20 */
> -		 _MSCAN_RESERVED_(16, 2);	/* + 0x42          */
> +		_MSCAN_RESERVED_(17, 2);	/* + 0x42          */
>  		u16 idr3_2;			/* + 0x44     0x22 */
> -		 _MSCAN_RESERVED_(17, 2);	/* + 0x46          */
> +		_MSCAN_RESERVED_(18, 2);	/* + 0x46          */
>  		u16 dsr1_0;			/* + 0x48     0x24 */
> -		 _MSCAN_RESERVED_(18, 2);	/* + 0x4a          */
> +		_MSCAN_RESERVED_(19, 2);	/* + 0x4a          */
>  		u16 dsr3_2;			/* + 0x4c     0x26 */
> -		 _MSCAN_RESERVED_(19, 2);	/* + 0x4e          */
> +		_MSCAN_RESERVED_(20, 2);	/* + 0x4e          */
>  		u16 dsr5_4;			/* + 0x50     0x28 */
> -		 _MSCAN_RESERVED_(20, 2);	/* + 0x52          */
> +		_MSCAN_RESERVED_(21, 2);	/* + 0x52          */
>  		u16 dsr7_6;			/* + 0x54     0x2a */
> -		 _MSCAN_RESERVED_(21, 2);	/* + 0x56          */
> +		_MSCAN_RESERVED_(22, 2);	/* + 0x56          */
>  		u8 dlr;				/* + 0x58     0x2c */
> -		 u8:8;				/* + 0x59     0x2d */
> -		 _MSCAN_RESERVED_(22, 2);	/* + 0x5a          */
> +		u8 reserved;			/* + 0x59     0x2d */
> +		_MSCAN_RESERVED_(23, 2);	/* + 0x5a          */
>  		u16 time;			/* + 0x5c     0x2e */
>  	} rx;
> -	 _MSCAN_RESERVED_(23, 2);		/* + 0x5e          */
> +	_MSCAN_RESERVED_(24, 2);		/* + 0x5e          */
>  	struct {
>  		u16 idr1_0;			/* + 0x60     0x30 */
> -		 _MSCAN_RESERVED_(24, 2);	/* + 0x62          */
> +		_MSCAN_RESERVED_(25, 2);	/* + 0x62          */
>  		u16 idr3_2;			/* + 0x64     0x32 */
> -		 _MSCAN_RESERVED_(25, 2);	/* + 0x66          */
> +		_MSCAN_RESERVED_(26, 2);	/* + 0x66          */
>  		u16 dsr1_0;			/* + 0x68     0x34 */
> -		 _MSCAN_RESERVED_(26, 2);	/* + 0x6a          */
> +		_MSCAN_RESERVED_(27, 2);	/* + 0x6a          */
>  		u16 dsr3_2;			/* + 0x6c     0x36 */
> -		 _MSCAN_RESERVED_(27, 2);	/* + 0x6e          */
> +		_MSCAN_RESERVED_(28, 2);	/* + 0x6e          */
>  		u16 dsr5_4;			/* + 0x70     0x38 */
> -		 _MSCAN_RESERVED_(28, 2);	/* + 0x72          */
> +		_MSCAN_RESERVED_(29, 2);	/* + 0x72          */
>  		u16 dsr7_6;			/* + 0x74     0x3a */
> -		 _MSCAN_RESERVED_(29, 2);	/* + 0x76          */
> +		_MSCAN_RESERVED_(30, 2);	/* + 0x76          */
>  		u8 dlr;				/* + 0x78     0x3c */
>  		u8 tbpr;			/* + 0x79     0x3d */
> -		 _MSCAN_RESERVED_(30, 2);	/* + 0x7a          */
> +		_MSCAN_RESERVED_(31, 2);	/* + 0x7a          */
>  		u16 time;			/* + 0x7c     0x3e */
>  	} tx;
> -	 _MSCAN_RESERVED_(31, 2);		/* + 0x7e          */
> +	_MSCAN_RESERVED_(32, 2);		/* + 0x7e          */
>  } __attribute__ ((packed));
> =20
>  #undef _MSCAN_RESERVED_
> @@ -238,6 +239,12 @@ struct mscan_regs {
>  #define MSCAN_SET_MODE_RETRIES	255
>  #define MSCAN_ECHO_SKB_MAX	3
> =20
> +/* MSCAN type variants */
> +enum {
> +	MSCAN_TYPE_MPC5200,
> +	MSCAN_TYPE_MPC5121
> +};
> +
>  #define BTR0_BRP_MASK		0x3f
>  #define BTR0_SJW_SHIFT		6
>  #define BTR0_SJW_MASK		(0x3 << BTR0_SJW_SHIFT)
> @@ -270,6 +277,7 @@ struct tx_queue_entry {
> =20
>  struct mscan_priv {
>  	struct can_priv can;	/* must be the first member */
> +	unsigned int type; 	/* MSCAN type variants */
>  	long open_time;
>  	unsigned long flags;
>  	void __iomem *reg_base;	/* ioremap'ed address to registers */
> @@ -285,11 +293,6 @@ struct mscan_priv {
>  };
> =20
>  extern struct net_device *alloc_mscandev(void);
> -/*
> - * clock_src:
> - *	1 =3D The MSCAN clock source is the onchip Bus Clock.
> - *	0 =3D The MSCAN clock source is the chip Oscillator Clock.
> - */
>  extern int register_mscandev(struct net_device *dev, int clock_src);

s/clock_src/mscan_clksrc/

>  extern void unregister_mscandev(struct net_device *dev);
> =20
> --=20
> 1.6.2.5
>=20

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--eHhjakXzOLJAF9wJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAks/UM4ACgkQD27XaX1/VRvmcgCfb/jVNrd+dreBGfLIbG9XyRCP
rgwAnjgzDV/6Sg1xsNmhWGnj5CufF4mf
=BMLW
-----END PGP SIGNATURE-----

--eHhjakXzOLJAF9wJ--

--===============0534521259==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0534521259==--
