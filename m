From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [RFC PATCH 2/2] net: macb: Add gmii2rgmii phy converter support
Date: Fri, 1 Jul 2016 09:02:32 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5BA97B@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
 <1467354012-7364-3-git-send-email-appanad@xilinx.com>
 <57761F96.4060609@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Michal Simek <michals@xilinx.com>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Harini Katakam <harinik@xilinx.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57761F96.4060609@atmel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicolas Ferre,
=09
	Thanks for the quick review...

>=20
> Le 01/07/2016 08:20, Kedareswara rao Appana a =E9crit :
> > This patch adds support for gmii2rgmii phy converter in the macb
> > driver.
>=20
> Okay, I'd like more explanation here.
> Hints & key words:
> - dt property
> - mdio bus
> - mac speed

Sure will fix in the next version...

>=20
>=20
> > Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> > ---
> >  drivers/net/ethernet/cadence/macb.c |   21 ++++++++++++++++++++-
> >  drivers/net/ethernet/cadence/macb.h |    3 +++
> >  2 files changed, 23 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/cadence/macb.c
> > b/drivers/net/ethernet/cadence/macb.c
> > index cb07d95..de0ad71 100644
> > --- a/drivers/net/ethernet/cadence/macb.c
> > +++ b/drivers/net/ethernet/cadence/macb.c
> > @@ -257,6 +257,14 @@ static int macb_mdio_write(struct mii_bus *bus=
, int
> mii_id, int regnum,
> >  	return 0;
> >  }
> >
> > +static inline void macb_hw_fix_mac_speed(struct macb *bp,
> > +					 struct phy_device *phydev)
> > +{
> > +	if (likely(bp->converter_phy.fix_mac_speed))
>=20
> What is the purpose of this branch bias? The code isn't in some hot p=
ath, so I
> suspect that its not needed.

If we won't put this check driver will crash with NULL pointer derefere=
nce for the below cases
---> Converter driver is disabled
---> Converter driver is enabled but the converter probe is not called =
from the macb driver.

>=20
> > +		bp->converter_phy.fix_mac_speed(&bp->converter_phy,
> > +						phydev->speed);
> > +}
> > +
> >  /**
> >   * macb_set_tx_clk() - Set a clock to a new frequency
> >   * @clk		Pointer to the clock to change
> > @@ -329,6 +337,7 @@ static void macb_handle_link_change(struct
> net_device *dev)
> >  				reg |=3D GEM_BIT(GBE);
> >
> >  			macb_or_gem_writel(bp, NCFGR, reg);
> > +			macb_hw_fix_mac_speed(bp, phydev);
> >
> >  			bp->speed =3D phydev->speed;
> >  			bp->duplex =3D phydev->duplex;
> > @@ -2884,7 +2893,7 @@ static int macb_probe(struct platform_device
> *pdev)
> >  			struct clk **, struct clk **)
> >  					      =3D macb_clk_init;
> >  	int (*init)(struct platform_device *) =3D macb_init;
> > -	struct device_node *np =3D pdev->dev.of_node;
> > +	struct device_node *np =3D pdev->dev.of_node, *np1, *np11;
>=20
> Nitpicking:
> Be more explicit on variable names. Simple name for the iterator is o=
kay, the
> other is better if changed.
> I also like to see variable on separated lines.

Ok sure will fix in the next version...

>=20
> >  	struct device_node *phy_node;
> >  	const struct macb_config *macb_config =3D NULL;
> >  	struct clk *pclk, *hclk =3D NULL, *tx_clk =3D NULL; @@ -3011,6 +3=
020,16
> > @@ static int macb_probe(struct platform_device *pdev)
> >  		goto err_out_free_netdev;
> >
> >  	phydev =3D bp->phy_dev;
> > +	np1 =3D of_get_next_child(np, NULL);
> > +	for_each_child_of_node(np1, np11) {
> > +		if (of_device_is_compatible(np11, "xlnx,gmiitorgmii")) {
>=20
> This would definitively need documentation and at least link in the m=
acb binding
> to show how this emulated phy connect to the mdio bus...
>=20
> I'm not able to judge if the node arrangement is okay: I let Florian =
tell his view
> on this...

Ok will document in the macb binding doc.

>=20
> > +			bp->converter_phy.dev =3D dev;
> > +			bp->converter_phy.mii_bus =3D bp->mii_bus;
> > +			bp->converter_phy.mdio_write =3D macb_mdio_write;
> > +			bp->converter_phy.platform_data =3D bp->pdev-
> >dev.of_node;
> > +			gmii2rgmii_phyprobe(&bp->converter_phy);
> > +		}
> > +	}
> >
> >  	netif_carrier_off(dev);
> >
> > diff --git a/drivers/net/ethernet/cadence/macb.h
> > b/drivers/net/ethernet/cadence/macb.h
> > index 8a13824..735bce2 100644
> > --- a/drivers/net/ethernet/cadence/macb.h
> > +++ b/drivers/net/ethernet/cadence/macb.h
> > @@ -10,6 +10,8 @@
> >  #ifndef _MACB_H
> >  #define _MACB_H
> >
> > +#include <linux/xilinx_gmii2rgmii.h>
>=20
> No, put it in the macb.c.

Ok will fix in v2...

>=20
> > +
> >  #define MACB_GREGS_NBR 16
> >  #define MACB_GREGS_VERSION 2
> >  #define MACB_MAX_QUEUES 8
> > @@ -846,6 +848,7 @@ struct macb {
> >  	unsigned int		jumbo_max_len;
> >
> >  	u32			wol;
> > +	struct	gmii2rgmii	converter_phy;
> >  };
> >
> >  static inline bool macb_is_gem(struct macb *bp)
>=20
>=20
> If Florian and phy guys are okay with the approach, I'm fine with thi=
s patch, once
> corrected.

Ok thanks...

Regards,
Kedar.

>=20
> Thanks, bye,
> --
> Nicolas Ferre
