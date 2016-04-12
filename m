From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: GMII2RGMII Converter support in macb driver
Date: Tue, 12 Apr 2016 15:21:39 +0200
Message-ID: <570CF663.4000908@atmel.com>
References: <C246CAC1457055469EF09E3A7AC4E11A4A57592E@XAP-PVEXMBX01.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	Harini Katakam <harinik@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	"Appana Durga Kedareswara Rao" <appanad@xilinx.com>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:21193 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933786AbcDLNVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 09:21:22 -0400
In-Reply-To: <C246CAC1457055469EF09E3A7AC4E11A4A57592E@XAP-PVEXMBX01.xlnx.xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/04/2016 15:03, Appana Durga Kedareswara Rao a =E9crit :
> Hi All,
>=20
> =20
>=20
>              =20
>=20
>                There is a Xilinx custom IP for GMII to RGMII conversi=
on
> data sheet here
> (http://www.xilinx.com/support/documentation/ip_documentation/gmii_to=
_rgmii/v4_0/pg160-gmii-to-rgmii.pdf
> )
>=20
> =20
>=20
> =20
>=20
>                Unlike other Phy=92s this IP won=92t support auto nego=
tiation
> and other features that usually normal Phy=92s support.
>=20
> This IP has only one register (Control register) which needs to be
> programmed based on the external phy auto negotiation
>=20
> (Based on the external phy negotiated speed).
>=20
> =20
>=20
> I am able to make it work for GEM driver by doing the below changes i=
n
> the driver (drivers/net/ethernet/cadence/macb.c).
>=20
> =20
>=20
> +#define XEMACPS_GMII2RGMII_FULLDPLX                         BMCR_FUL=
LDPLX
>=20
> +#define XEMACPS_GMII2RGMII_SPEED1000                       BMCR_SPEE=
D1000
>=20
> +#define XEMACPS_GMII2RGMII_SPEED100                         BMCR_SPE=
ED100
>=20
> +#define
> XEMACPS_GMII2RGMII_REG_NUM                                       0x10
>=20
> +
>=20
> /*
>=20
>   * Graceful stop timeouts in us. We should allow up to
>=20
>   * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
>=20
> @@ -311,8 +317,10 @@ static void macb_handle_link_change(struct
> net_device *dev)
>=20
> {
>=20
>               struct macb *bp =3D netdev_priv(dev);
>=20
>               struct phy_device *phydev =3D bp->phy_dev;
>=20
> +             struct phy_device *gmii2rgmii_phydev =3D bp->gmii2rgmii=
_phy_dev;
>=20
>               unsigned long flags;
>=20
>               int status_change =3D 0;
>=20
> +             u16 gmii2rgmii_reg =3D 0;
>=20
>                spin_lock_irqsave(&bp->lock, flags);
>=20
> @@ -326,15 +334,27 @@ static void macb_handle_link_change(struct
> net_device *dev)
>=20
>                                             if (macb_is_gem(bp))
>=20
>                                                            reg &=3D
> ~GEM_BIT(GBE);
>=20
> -                                            if (phydev->duplex)
>=20
> +                                           if (phydev->duplex) {
>=20
>                                                            reg |=3D
> MACB_BIT(FD);
>=20
> -                                            if (phydev->speed =3D=3D=
 SPEED_100)
>=20
> +                                                        =20
> gmii2rgmii_reg |=3D XEMACPS_GMII2RGMII_FULLDPLX;
>=20
> +                                           }
>=20
> +                                           if (phydev->speed =3D=3D
> SPEED_100) {
>=20
>                                                            reg |=3D
> MACB_BIT(SPD);
>=20
> +                                                        =20
> gmii2rgmii_reg |=3D XEMACPS_GMII2RGMII_SPEED100;
>=20
> +                                           }
>=20
>                                             if (phydev->speed =3D=3D
> SPEED_1000 &&
>=20
> -                                                bp->caps &
> MACB_CAPS_GIGABIT_MODE_AVAILABLE)
>=20
> +                                               bp->caps &
> MACB_CAPS_GIGABIT_MODE_AVAILABLE) {
>=20
>                                                            reg |=3D
> GEM_BIT(GBE);
>=20
> +                                                        =20
> gmii2rgmii_reg |=3D XEMACPS_GMII2RGMII_SPEED1000;
>=20
> +                                           }
>=20
>                                              macb_or_gem_writel(bp,
> NCFGR, reg);
>=20
> +                                           if (gmii2rgmii_phydev !=3D=
 NULL) {
>=20
> +                                                        =20
> macb_mdio_write(bp->mii_bus,
>=20
> +                                                                    =
     gmii2rgmii_phydev->addr,
>=20
> +                                                                    =
     XEMACPS_GMII2RGMII_REG_NUM,
>=20
> +                                                                    =
     gmii2rgmii_reg);
>=20
> +                                           }
>=20
>                                              bp->speed =3D phydev->sp=
eed;
>=20
>                                             bp->duplex =3D phydev->du=
plex;
>=20
> @@ -382,6 +402,19 @@ static int macb_mii_probe(struct net_device *dev=
)
>=20
>               int phy_irq;
>=20
>               int ret;
>=20
> +             if (bp->gmii2rgmii_phy_node) {
>=20
> +                            phydev =3D of_phy_attach(bp->dev,
>=20
> +                                                                    =
     bp->gmii2rgmii_phy_node,
>=20
> +                                                                    =
     0,
> 0);
>=20
> +                            if (!phydev) {
>=20
> +                                           dev_err(&bp->pdev->dev, "=
%s:
> no gmii to rgmii converter found\n",
>=20
> +                                           dev->name);
>=20
> +                                           return -1;
>=20
> +                            }
>=20
> +                            bp->gmii2rgmii_phy_dev =3D phydev;
>=20
> +             } else
>=20
> +                            bp->gmii2rgmii_phy_dev =3D NULL;
>=20
> +
>=20
>               phydev =3D phy_find_first(bp->mii_bus);
>=20
>               if (!phydev) {
>=20
>                              netdev_err(dev, "no PHY found\n");
>=20
> @@ -402,6 +435,8 @@ static int macb_mii_probe(struct net_device *dev)
>=20
>                                                          =20
>  bp->phy_interface);
>=20
>               if (ret) {
>=20
>                              netdev_err(dev, "Could not attach to PHY=
\n");
>=20
> +                            if (bp->gmii2rgmii_phy_dev)
>=20
> +                                         =20
> phy_disconnect(bp->gmii2rgmii_phy_dev);
>=20
>                              return ret;
>=20
>               }
>=20
> @@ -3368,6 +3403,9 @@ static int macb_probe(struct platform_device *p=
dev)
>=20
>                              bp->phy_interface =3D err;
>=20
>               }
>=20
> +             bp->gmii2rgmii_phy_node =3D
> of_parse_phandle(bp->pdev->dev.of_node,
>=20
> +                                                                    =
                  =20
> "gmii2rgmii-phy-handle", 0);
>=20
> +
>=20
>               macb_reset_phy(pdev);
>=20
>                /* IP specific init */
>=20
> @@ -3422,6 +3460,8 @@ static int macb_remove(struct platform_device *=
pdev)
>=20
>                              bp =3D netdev_priv(dev);
>=20
>                              if (bp->phy_dev)
>=20
>                                             phy_disconnect(bp->phy_de=
v);
>=20
> +                            if (bp->gmii2rgmii_phy_dev)
>=20
> +                                         =20
> phy_disconnect(bp->gmii2rgmii_phy_dev);
>=20
> =20
>=20
> But doing above changes making driver looks odd.
>=20
> could you please suggest any better option to add support for this IP=
 in
> the macb driver?

Appana,

I certainly can't prototype the solution based on your datasheet and th=
e
code sent... do a sensible proposal, then we can evaluate.

As the IP is separated from the Eth controller, make it a separate
driver (an emulated phy one for instance... even if I don't know if it
makes sense).

I don't know if others have already made such an adaptation layer
between GMII to RGMII but I'm pretty sure it can't be inserted into the
macb driver.

Bye,
--=20
Nicolas Ferre
