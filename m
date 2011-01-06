From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v3 05/10] net/fec: add dual fec support for mx28
Date: Thu, 6 Jan 2011 08:10:47 +0100
Message-ID: <20110106071047.GW25121@pengutronix.de>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com> <1294236457-17476-6-git-send-email-shawn.guo@freescale.com> <20110105163449.GU25121@pengutronix.de> <20110106041457.GC17891@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53451 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab1AFHLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 02:11:12 -0500
Content-Disposition: inline
In-Reply-To: <20110106041457.GC17891@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shawn,

On Thu, Jan 06, 2011 at 12:14:59PM +0800, Shawn Guo wrote:
> On Wed, Jan 05, 2011 at 05:34:49PM +0100, Uwe Kleine-K=F6nig wrote:
> > On Wed, Jan 05, 2011 at 10:07:32PM +0800, Shawn Guo wrote:
> > > +#define DRIVER_NAME  "fec"
> > > +#define ENET_MAC_NAME        "enet-mac"
> > > +
> > > +static struct platform_device_id fec_devtype[] =3D {
> > > +     {
> > > +             .name =3D DRIVER_NAME,
> > > +     }, {
> > > +             .name =3D ENET_MAC_NAME,
> > > +     }
> > I'd done it differently:
> >=20
> >         {
> >                 .name =3D "fec",
> >                 .driver_data =3D 0,
> >         }, {
> >                 .name =3D "imx28-fec",
> >                 .driver_data =3D HAS_ENET_MAC | ...,
> >         }
> >=20
> > and then test the bits in driver_data (which you get using
> > platform_get_device_id() when you need to distinguish.
> > Comparing names doesn't scale, assume there are three further featu=
res
> > to distinguish, then you need to use strtok or index and get device
> > names like enet-mac-with-feature1-but-without-feature2-and-feature3=
=2E
> >=20
> Makes sense.  The frame endian issue will be fixed in future revision=
,
> so I would define bit SWAP_FRAME for testing.
sounds sane
=20
> > > +     /*
> > > +      * enet-mac design made an improper assumption that it's ru=
nning
> > > +      * on a big endian system. As the result, driver has to swa=
p
> > if he was really aware that he limits the performant use of the fec=
 to
> > big endian systems, can you please make him stop designing hardware=
!?
> >=20
> You over looked my power :)  BTW, he had left Freescale.
so everything seems OK with your power :-)

> > > +      * every frame going to and coming from the controller.
> > > +      */
> > > +     if (fec_is_enetmac)
> > > +             swap_buffer(bufaddr, skb->len);
> > > +
> > >       /* Save skb pointer */
> > >       fep->tx_skbuff[fep->skb_cur] =3D skb;
> > >
> > > @@ -487,6 +522,9 @@ fec_enet_rx(struct net_device *dev)
> > >               dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_d=
atlen,
> > >                               DMA_FROM_DEVICE);
> > >
> > > +             if (fec_is_enetmac)
> > > +                     swap_buffer(data, pkt_len);
> > > +
> > >               /* This does 16 byte alignment, exactly what we nee=
d.
> > >                * The packet length includes FCS, but we don't wan=
t to
> > >                * include that when passing upstream as it messes =
up
> > > @@ -689,6 +727,7 @@ static int fec_enet_mii_probe(struct net_devi=
ce *dev)
> > >       char mdio_bus_id[MII_BUS_ID_SIZE];
> > >       char phy_name[MII_BUS_ID_SIZE + 3];
> > >       int phy_id;
> > > +     int dev_id =3D fep->pdev->id;
> > >
> > >       fep->phy_dev =3D NULL;
> > >
> > > @@ -700,6 +739,8 @@ static int fec_enet_mii_probe(struct net_devi=
ce *dev)
> > >                       continue;
> > >               if (fep->mii_bus->phy_map[phy_id]->phy_id =3D=3D 0)
> > >                       continue;
> > > +             if (fec_is_enetmac && dev_id--)
> > > +                     continue;
> > >               strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_S=
IZE);
> > >               break;
> > >       }
> > > @@ -741,6 +782,28 @@ static int fec_enet_mii_init(struct platform=
_device *pdev)
> > >       struct fec_enet_private *fep =3D netdev_priv(dev);
> > >       int err =3D -ENXIO, i;
> > >
> > > +     /*
> > > +      * The dual fec interfaces are not equivalent with enet-mac=
=2E
> > > +      * Here are the differences:
> > > +      *
> > > +      *  - fec0 supports MII & RMII modes while fec1 only suppor=
ts RMII
> > > +      *  - fec0 acts as the 1588 time master while fec1 is slave
> > > +      *  - external phys can only be configured by fec0
> > > +      *
> > > +      * That is to say fec1 can not work independently. It only =
works
> > > +      * when fec0 is working. The reason behind this design is t=
hat the
> > > +      * second interface is added primarily for Switch mode.
> > > +      *
> > > +      * Because of the last point above, both phys are attached =
on fec0
> > > +      * mdio interface in board design, and need to be configure=
d by
> > > +      * fec0 mii_bus.
> > > +      */
> > > +     if (fec_is_enetmac && pdev->id) {
> > > +             /* fec1 uses fec0 mii_bus */
> > > +             fep->mii_bus =3D fec_mii_bus;
> > > +             return 0;
> > > +     }
> > > +
> > >       fep->mii_timeout =3D 0;
> > >
> > >       /*
> > > @@ -777,6 +840,10 @@ static int fec_enet_mii_init(struct platform=
_device *pdev)
> > >       if (mdiobus_register(fep->mii_bus))
> > >               goto err_out_free_mdio_irq;
> > >
> > > +     /* save fec0 mii_bus */
> > > +     if (fec_is_enetmac)
> > > +             fec_mii_bus =3D fep->mii_bus;
> > > +
> > >       return 0;
> > >
> > >  err_out_free_mdio_irq:
> > > @@ -1149,11 +1216,22 @@ fec_restart(struct net_device *dev, int d=
uplex)
> > >  {
> > >       struct fec_enet_private *fep =3D netdev_priv(dev);
> > >       int i;
> > > +     u32 val, temp_mac[2];
> > >
> > >       /* Whack a reset.  We should wait for this. */
> > >       writel(1, fep->hwp + FEC_ECNTRL);
> > >       udelay(10);
> > >
> > > +     /*
> > > +      * enet-mac reset will reset mac address registers too,
> > > +      * so need to reconfigure it.
> > > +      */
> > > +     if (fec_is_enetmac) {
> > > +             memcpy(&temp_mac, dev->dev_addr, ETH_ALEN);
> 		  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > > +             writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADD=
R_LOW);
> > > +             writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADD=
R_HIGH);
> > where is the value saved to temp_mac[]?  For me it looks you write
> > uninitialized data into the mac registers.
>=20
> memcpy above.
oops.  right.  I looked for something like

	temp_mac[0] =3D dev->dev_addr[0] << $shiftfor0 | ...

which AFAIK is what you want here.  memcpy is sensible to (at least)
endian issues.  If you ask me factor out the setting of the mac address
in probe to a function and use that here, too.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
