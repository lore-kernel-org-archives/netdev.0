From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: [PATCH (net.git) 2/3] Revert "stmmac: Fix 'eth0: No PHY found'
 regression"
Date: Wed, 11 May 2016 20:33:25 +0200
Message-ID: <20160511183324.GA31991@torres.zugschlus.de>
References: <1459494436-27386-1-git-send-email-peppe.cavallaro@st.com>
 <1459494436-27386-3-git-send-email-peppe.cavallaro@st.com>
 <20160413154425.GA30954@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gabriel.fernandez@linaro.org,
	afaerber@suse.de, fschaefer.oss@googlemail.com,
	dinh.linux@gmail.com, davem@davemloft.net, preid@electromag.com.au,
	rhgadsdon@gmail.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160413154425.GA30954@torres.zugschlus.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2016 at 05:44:25PM +0200, Marc Haber wrote:
> On Fri, Apr 01, 2016 at 09:07:15AM +0200, Giuseppe Cavallaro wrote:
> > This reverts commit 88f8b1bb41c6208f81b6a480244533ded7b59493.
> > due to problems on GeekBox and Banana Pi M1 board when
> > connected to a real transceiver instead of a switch via
> > fixed-link.
>=20
> This reversal is still needed in Linux 4.5.1 on Banana Pi.
>=20
> Please consider including it in Linux 4.5.2.

This reversal is still needed in Linux 4.5.4 on Banana Pi.

Please consider including it in Linux 4.5.5.

Greetings
Marc



>=20
> >=20
> > Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> > Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
> > Cc: Andreas F=C3=A4rber <afaerber@suse.de>
> > Cc: Frank Sch=C3=A4fer <fschaefer.oss@googlemail.com>
> > Cc: Dinh Nguyen <dinh.linux@gmail.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   11 ++++++++=
++-
> >  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    9 +-------=
-
> >  include/linux/stmmac.h                             |    1 -
> >  3 files changed, 11 insertions(+), 10 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/dr=
ivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> > index ea76129..af09ced 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> > @@ -199,12 +199,21 @@ int stmmac_mdio_register(struct net_device *n=
dev)
> >  	struct stmmac_priv *priv =3D netdev_priv(ndev);
> >  	struct stmmac_mdio_bus_data *mdio_bus_data =3D priv->plat->mdio_b=
us_data;
> >  	int addr, found;
> > -	struct device_node *mdio_node =3D priv->plat->mdio_node;
> > +	struct device_node *mdio_node =3D NULL;
> > +	struct device_node *child_node =3D NULL;
> > =20
> >  	if (!mdio_bus_data)
> >  		return 0;
> > =20
> >  	if (IS_ENABLED(CONFIG_OF)) {
> > +		for_each_child_of_node(priv->device->of_node, child_node) {
> > +			if (of_device_is_compatible(child_node,
> > +						    "snps,dwmac-mdio")) {
> > +				mdio_node =3D child_node;
> > +				break;
> > +			}
> > +		}
> > +
> >  		if (mdio_node) {
> >  			netdev_dbg(ndev, "FOUND MDIO subnode\n");
> >  		} else {
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c =
b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > index dcbd2a1..9cf181f 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > @@ -146,7 +146,6 @@ stmmac_probe_config_dt(struct platform_device *=
pdev, const char **mac)
> >  	struct device_node *np =3D pdev->dev.of_node;
> >  	struct plat_stmmacenet_data *plat;
> >  	struct stmmac_dma_cfg *dma_cfg;
> > -	struct device_node *child_node =3D NULL;
> > =20
> >  	plat =3D devm_kzalloc(&pdev->dev, sizeof(*plat), GFP_KERNEL);
> >  	if (!plat)
> > @@ -177,19 +176,13 @@ stmmac_probe_config_dt(struct platform_device=
 *pdev, const char **mac)
> >  		plat->phy_node =3D of_node_get(np);
> >  	}
> > =20
> > -	for_each_child_of_node(np, child_node)
> > -		if (of_device_is_compatible(child_node,	"snps,dwmac-mdio")) {
> > -			plat->mdio_node =3D child_node;
> > -			break;
> > -		}
> > -
> >  	/* "snps,phy-addr" is not a standard property. Mark it as depreca=
ted
> >  	 * and warn of its use. Remove this when phy node support is adde=
d.
> >  	 */
> >  	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) =3D=
=3D 0)
> >  		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
> > =20
> > -	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || !plat->mdio_=
node)
> > +	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || plat->phy_bu=
s_name)
> >  		plat->mdio_bus_data =3D NULL;
> >  	else
> >  		plat->mdio_bus_data =3D
> > diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> > index 4bcf5a6..6e53fa8 100644
> > --- a/include/linux/stmmac.h
> > +++ b/include/linux/stmmac.h
> > @@ -114,7 +114,6 @@ struct plat_stmmacenet_data {
> >  	int interface;
> >  	struct stmmac_mdio_bus_data *mdio_bus_data;
> >  	struct device_node *phy_node;
> > -	struct device_node *mdio_node;
> >  	struct stmmac_dma_cfg *dma_cfg;
> >  	int clk_csr;
> >  	int has_gmac;
> > --=20
> > 1.7.4.4
> >=20
>=20
> --=20
> ---------------------------------------------------------------------=
--------
> Marc Haber         | "I don't trust Computers. They | Mailadresse im =
Header
> Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1=
600402
> Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1=
600421

--=20
-----------------------------------------------------------------------=
------
Marc Haber         | "I don't trust Computers. They | Mailadresse im He=
ader
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 160=
0402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 160=
0421
