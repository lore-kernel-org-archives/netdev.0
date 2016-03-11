From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH 3/6] net: arc_emac: support the phy reset for emac driver
Date: Fri, 11 Mar 2016 15:56:04 +0100
Message-ID: <2693723.gBjS0iQk4I@diego>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com> <1457693731-6966-4-git-send-email-wxt@rock-chips.com> <56E2CC8F.5040703@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, Alexander Kochetkov <al.kochet@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Caesar Wang <wxt@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E2CC8F.5040703@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Caesar,

Am Freitag, 11. M=E4rz 2016, 16:47:59 schrieb Sergei Shtylyov:
> On 3/11/2016 1:55 PM, Caesar Wang wrote:
> > This patch adds to support the emac phy reset.
> >=20
> > 1) phy-reset-gpios:
> > The phy-reset-gpios is an optional property for arc emac device tre=
e boot.
> > Change the binding document to match the driver code.
> >=20
> > 2) phy-reset-duration:
> > Different boards may require different phy reset duration. Add prop=
erty
> > phy-reset-duration for device tree probe, so that the boards that n=
eed
> > a longer reset duration can specify it in their device tree.
> >=20
> > 3) phy-reset-active-high:
> > We need that for a custom hardware that needs the reverse reset seq=
uence.
> >=20
> > Of course, this patch will fix the issue on
> > https://patchwork.kernel.org/patch/8186801/.
> >=20
> > In some cases, the emac couldn't work if you don't have reset the p=
hy.
> > Let's add it to happy work.
> >=20
> > Signed-off-by: Caesar Wang <wxt@rock-chips.com>
> > ---
> >=20
> >   drivers/net/ethernet/arc/emac_main.c | 41
> >   ++++++++++++++++++++++++++++++++++++ 1 file changed, 41 insertion=
s(+)
> >=20
> > diff --git a/drivers/net/ethernet/arc/emac_main.c
> > b/drivers/net/ethernet/arc/emac_main.c index 6446af1..42384f6a 1006=
44
> > --- a/drivers/net/ethernet/arc/emac_main.c
> > +++ b/drivers/net/ethernet/arc/emac_main.c
> > @@ -764,6 +764,45 @@ static const struct net_device_ops
> > arc_emac_netdev_ops =3D {>=20
> >   #endif
> >   };
> >=20
> > +#ifdef CONFIG_OF
> > +static void emac_reset_phy(struct net_device *pdev)
> > +{
> > +	int err, phy_reset;
> > +	bool active_high =3D false;
> > +	int msec =3D 10;
> > +	struct device *dev =3D pdev->dev.parent;
> > +	struct device_node *np =3D dev->of_node;
> > +
> > +	if (!np)
> > +		return;
> > +
> > +	of_property_read_u32(np, "phy-reset-duration", &msec);
> > +	/* A sane reset duration should not be longer than 1s */
> > +	if (msec > 1000)
> > +		msec =3D 1;
> > +
> > +	phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
> > +	if (!gpio_is_valid(phy_reset))
> > +		return;
> > +
> > +	active_high =3D of_property_read_bool(np, "phy-reset-active-high"=
);
> > +
> > +	err =3D devm_gpio_request_one(dev, phy_reset, active_high ?
> > +				    GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
> > +				    "phy-reset");
> > +	if (err) {
> > +		dev_err(dev, "failed to get phy-reset-gpios: %d\n", err);
> > +		return;
> > +	}
> > +	msleep(msec);
> > +	gpio_set_value_cansleep(phy_reset, !active_high);
> > +}
>=20
> [...]
>=20
>     Why not make it the mii_bus::reset() method? It gets called befor=
e the
> MDIO bus scan.

while meddling with the emac, I've built some sort of preliminary varia=
nt of
Sergei's suggestion at [0] - maybe you could take a look for some sort =
of
inspiration ;-)=20

The code is lifted from the designware gmac driver, so the binding also=
 is
similar.


Heiko


[0] https://github.com/mmind/linux-rockchip/commit/a943c588783438ff1c50=
8dfa8c79f1709aa5775e
