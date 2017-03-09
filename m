From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 7/7] net: stmmac: dwc-qos: Add Tegra186 support
Date: Thu, 9 Mar 2017 21:00:30 +0100
Message-ID: <20170309200030.GF5554@ulmo.ba.sec>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-8-thierry.reding@gmail.com>
 <c72dc23e-cdc3-8b89-3b7d-dce8d81d4ae0@kapsi.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="z+pzSjdB7cqptWpS"
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c72dc23e-cdc3-8b89-3b7d-dce8d81d4ae0-/1wQRMveznE@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--z+pzSjdB7cqptWpS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 27, 2017 at 01:46:01PM +0200, Mikko Perttunen wrote:
> On 23.02.2017 19:24, Thierry Reding wrote:
> > From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> >=20
> > The NVIDIA Tegra186 SoC contains an instance of the Synopsys DWC
> > ethernet QOS IP core. The binding that it uses is slightly different
> > from existing ones because of the integration (clocks, resets, ...).
> >=20
> > Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> > ---
> >  .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 252 +++++++++++++=
++++++++
> >  1 file changed, 252 insertions(+)
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/=
drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
> > index 5071d3c15adc..54dfbdc48f6d 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
> > @@ -14,6 +14,7 @@
> >  #include <linux/clk.h>
> >  #include <linux/clk-provider.h>
> >  #include <linux/device.h>
> > +#include <linux/gpio/consumer.h>
> >  #include <linux/ethtool.h>
> >  #include <linux/io.h>
> >  #include <linux/ioport.h>
> > @@ -22,10 +23,24 @@
> >  #include <linux/of_net.h>
> >  #include <linux/mfd/syscon.h>
> >  #include <linux/platform_device.h>
> > +#include <linux/reset.h>
> >  #include <linux/stmmac.h>
> >=20
> >  #include "stmmac_platform.h"
> >=20
> > +struct tegra_eqos {
> > +	struct device *dev;
> > +	void __iomem *regs;
> > +
> > +	struct reset_control *rst;
> > +	struct clk *clk_master;
> > +	struct clk *clk_slave;
> > +	struct clk *clk_tx;
> > +	struct clk *clk_rx;
> > +
> > +	struct gpio_desc *reset;
> > +};
> > +
> >  static int dwc_eth_dwmac_config_dt(struct platform_device *pdev,
> >  				   struct plat_stmmacenet_data *plat_dat)
> >  {
> > @@ -148,6 +163,237 @@ static int dwc_qos_remove(struct platform_device =
*pdev)
> >  	return 0;
> >  }
> >=20
> > +#define SDMEMCOMPPADCTRL 0x8800
> > +#define  SDMEMCOMPPADCTRL_PAD_E_INPUT_OR_E_PWRD BIT(31)
> > +
> > +#define AUTO_CAL_CONFIG 0x8804
> > +#define  AUTO_CAL_CONFIG_START BIT(31)
> > +#define  AUTO_CAL_CONFIG_ENABLE BIT(29)
> > +
> > +#define AUTO_CAL_STATUS 0x880c
> > +#define  AUTO_CAL_STATUS_ACTIVE BIT(31)
> > +
> > +static void tegra_eqos_fix_speed(void *priv, unsigned int speed)
> > +{
> > +	struct tegra_eqos *eqos =3D priv;
> > +	unsigned long rate =3D 125000000;
> > +	bool needs_calibration =3D false;
> > +	unsigned int i;
> > +	u32 value;
> > +
> > +	switch (speed) {
> > +	case SPEED_1000:
> > +		needs_calibration =3D true;
> > +		rate =3D 125000000;
> > +		break;
> > +
> > +	case SPEED_100:
> > +		needs_calibration =3D true;
> > +		rate =3D 25000000;
> > +		break;
> > +
> > +	case SPEED_10:
> > +		rate =3D 2500000;
> > +		break;
> > +
> > +	default:
> > +		dev_err(eqos->dev, "invalid speed %u\n", speed);
> > +		break;
> > +	}
> > +
> > +	if (needs_calibration) {
> > +		/* calibrate */
> > +		value =3D readl(eqos->regs + SDMEMCOMPPADCTRL);
> > +		value |=3D SDMEMCOMPPADCTRL_PAD_E_INPUT_OR_E_PWRD;
> > +		writel(value, eqos->regs + SDMEMCOMPPADCTRL);
> > +
> > +		udelay(1);
> > +
> > +		value =3D readl(eqos->regs + AUTO_CAL_CONFIG);
> > +		value |=3D AUTO_CAL_CONFIG_START | AUTO_CAL_CONFIG_ENABLE;
> > +		writel(value, eqos->regs + AUTO_CAL_CONFIG);
> > +
> > +		for (i =3D 0; i <=3D 10; i++) {
> > +			value =3D readl(eqos->regs + AUTO_CAL_STATUS);
> > +			if (value & AUTO_CAL_STATUS_ACTIVE)
> > +				break;
> > +
> > +			udelay(1);
> > +		}
> > +
> > +		if ((value & AUTO_CAL_STATUS_ACTIVE) =3D=3D 0) {
> > +			dev_err(eqos->dev, "calibration did not start\n");
> > +			goto failed;
> > +		}
> > +
> > +		for (i =3D 0; i <=3D 10; i++) {
> > +			value =3D readl(eqos->regs + AUTO_CAL_STATUS);
> > +			if ((value & AUTO_CAL_STATUS_ACTIVE) =3D=3D 0)
> > +				break;
> > +
> > +			udelay(20);
> > +		}
> > +
> > +		if (value & AUTO_CAL_STATUS_ACTIVE) {
> > +			dev_err(eqos->dev, "calibration didn't finish\n");
> > +			goto failed;
> > +		}
>=20
> Could use readl_poll_timeout/readl_poll_timeout_atomic for these loops
> instead.

I had considered that, but the code ends up looking a lot uglier with
that. But since you and Joao both prefer it, I'll switch over to the I/O
poll helpers anyway.

>=20
> > +
> > +	failed:
> > +		value =3D readl(eqos->regs + SDMEMCOMPPADCTRL);
> > +		value &=3D ~SDMEMCOMPPADCTRL_PAD_E_INPUT_OR_E_PWRD;
> > +		writel(value, eqos->regs + SDMEMCOMPPADCTRL);
> > +	} else {
> > +		value =3D readl(eqos->regs + AUTO_CAL_CONFIG);
> > +		value &=3D ~AUTO_CAL_CONFIG_ENABLE;
> > +		writel(value, eqos->regs + AUTO_CAL_CONFIG);
> > +	}
> > +
> > +	clk_set_rate(eqos->clk_tx, rate);
>=20
> Could check error code here, and for other clock ops too.

Done.

> > +}
> > +
> > +static int tegra_eqos_init(struct platform_device *pdev, void *priv)
> > +{
> > +	struct tegra_eqos *eqos =3D priv;
> > +	unsigned long rate;
> > +	u32 value;
> > +
> > +	rate =3D clk_get_rate(eqos->clk_slave);
> > +
> > +	value =3D readl(eqos->regs + 0xdc);
>=20
> No point in reading the value when it is fully overwritten.

Good catch.

> > +	value =3D (rate / 1000000) - 1;
> > +	writel(value, eqos->regs + 0xdc);
>=20
> Please add a define for 0xdc.

Right, I must've overlooked that while cleaning up the patch. I've added
a GMAC_1US_TIC_COUNTER define for it.

> > @@ -245,6 +496,7 @@ static int dwc_eth_dwmac_remove(struct platform_dev=
ice *pdev)
> >=20
> >  static const struct of_device_id dwc_eth_dwmac_match[] =3D {
> >  	{ .compatible =3D "snps,dwc-qos-ethernet-4.10", .data =3D &dwc_qos_da=
ta },
> > +	{ .compatible =3D "nvidia,tegra186-eqos", .data =3D &tegra_eqos_data},
>=20
> Missing space before '}'.

Good catch! Fixed.

Thanks,
Thierry

--z+pzSjdB7cqptWpS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljBtFwACgkQ3SOs138+
s6HzTxAAhZb6L2H65NEkbu6FfN2QI5rTM207yvAni+0WAJGcHhsD1+CqHUmeZk8g
Ma8iUwpcKVatXq/lu91mIzYr/tciHLegyJekL3YOhuYe91IhWEtk6eYIAzFqBhhW
6IWMRMS0m+nWr+8v6o7BdcAg+iif+CEjpBhqf0wTgCevR5qvP+s9/3uR9vXt5BS2
O1jAOkmV9e3ZjaxnsRPdjChudjv5v8f1IlLvHhrkfJrQyn+pmFqRvqbQdaxTao7w
Aub1ERDr8MBuJiuFY3KJTybVBhr/jJhRF74e9jYVPA67Ey3fGygFswUxHJKggjwi
g8SR7KRwmyLEHjo55BA+BAWvgp6916zR1i00IjF2rnQ0jC87P+bhu9mk9I/AidX8
ip4XDwss33JRCPIEEWdPZbSkKHXpuNDLANcWtvYKWFX4GCFPdESDbTuYS5hJgsDs
445SbzudUrBysqGMAAgUwh2oyb9owAWeql6k6fyzuJdRnOu6K2m1bnkzGQJghG5P
tDZYu7wGhnGilXXir4OaEVJBGTNwAUIN/i8r/JLO+E/7AuW2gMDCzIRMJsds1B0+
2HldAtsngg+UxyCyiiQbDNkXu4r95y6u51PnQkPdJiulatEfiatNvTqvl8+Osetn
LHZd9RTuxGBpT/AuuP3fx0teYX5EsqRulbFigB/M7VWxcRZQlNo=
=UUVo
-----END PGP SIGNATURE-----

--z+pzSjdB7cqptWpS--
