From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH 2/3] net: fec: convert to using gpiod framework
Date: Tue, 1 Dec 2015 11:29:17 +0100
Message-ID: <20151201112917.1f47af66@ipc1.ka-ro>
References: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
	<1448883168-30742-2-git-send-email-LW@KARO-electronics.de>
	<1448883168-30742-3-git-send-email-LW@KARO-electronics.de>
	<BN3PR0301MB1219D8F59FEB74A4C445E405F50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	"Stefan Agner" <stefan@agner.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Uwe Kleine-K?nig" <u.kleine-koenig@pengutronix.de>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR0301MB1219D8F59FEB74A4C445E405F50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de> Sent: Monday, Nove=
mber 30, 2015 7:33 PM
> > To: Andrew Lunn; David S. Miller; Estevam Fabio-R49496; Greg Ungere=
r;
> > Kevin Hao; Lothar Wa=C3=9Fmann; Lucas Stach; Duan Fugang-B38611; Ph=
ilippe
> > Reynes; Richard Cochran; Russell King; Sascha Hauer; Stefan Agner; =
linux-
> > kernel@vger.kernel.org; netdev@vger.kernel.org; Jeff Kirsher; Uwe K=
leine-
> > K=C3=B6nig
> > Subject: [PATCH 2/3] net: fec: convert to using gpiod framework
> >=20
> > Use gpiod_get_optional() instead of checking for a valid GPIO numbe=
r and
> > calling devm_gpio_request_one() conditionally.
> >=20
> > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c | 17 +++++++----------
> >  1 file changed, 7 insertions(+), 10 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index e17d74f..1a983fc 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -3233,7 +3233,7 @@ static int fec_enet_init(struct net_device *n=
dev)
> > #ifdef CONFIG_OF  static void fec_reset_phy(struct platform_device =
*pdev)
> > {
> > -	int err, phy_reset;
> > +	struct gpio_desc *phy_reset;
> >  	int msec =3D 1;
> >  	struct device_node *np =3D pdev->dev.of_node;
> >=20
> > @@ -3245,18 +3245,15 @@ static void fec_reset_phy(struct platform_d=
evice
> > *pdev)
> >  	if (msec > 1000)
> >  		msec =3D 1;
> >=20
> > -	phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
> > -	if (!gpio_is_valid(phy_reset))
> > -		return;
> > -
> > -	err =3D devm_gpio_request_one(&pdev->dev, phy_reset,
> > -				    GPIOF_OUT_INIT_LOW, "phy-reset");
> > -	if (err) {
> > -		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n",
> > err);
> > +	phy_reset =3D devm_gpiod_get_optional(&pdev->dev, "phy-reset",
> > +					    GPIOD_OUT_LOW);
> > +	if (IS_ERR(phy_reset)) {
> > +		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %ld\n",
> > +			PTR_ERR(phy_reset));
> >  		return;
> >  	}
> >  	msleep(msec);
> > -	gpio_set_value_cansleep(phy_reset, 1);
> > +	gpiod_set_value_cansleep(phy_reset, 1);
>=20
> This API will judge the GPIO active polarity, there many imx boards i=
n dts files don't care the polarity.
> So pls drop the patch.
>=20
> Or use gpiod_set_raw_value_cansleep() instead of gpiod_set_value_cans=
leep().
>=20
I could prepare a patch that temporarily uses the raw functions and add
a comment to convert these to the proper functions once all DTB files
have been corrected and some time has passed to account for boards usin=
g
old dtbs with newer kernels.

I could also send a patch to convert all in-tree dts files to use
GPIO_ACTIVE_LOW if that is desired.


Lothar Wa=C3=9Fmann
