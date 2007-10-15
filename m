From: Domen Puncer <domen.puncer@telargo.com>
Subject: Re: [PATCH v3 4/4] FEC mpc52xx: phy part of the driver\
Date: Mon, 15 Oct 2007 12:56:01 +0200
Message-ID: <20071015105601.GM3000@nd47.coderock.org>
References: <20071014075511.GC3000@nd47.coderock.org> <20071014075958.GG3000@nd47.coderock.org> <fa686aa40710141505w1787e7e1g6116185001561a4d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: galak@kernel.crashing.org, jgarzik@pobox.com,
	linuxppc-dev@ozlabs.org, tnt@246tnt.com, netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kukmak.uni-mb.si ([164.8.100.3]:44715 "EHLO kukmak.uni-mb.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757932AbXJOK4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 06:56:06 -0400
Content-Disposition: inline
In-Reply-To: <fa686aa40710141505w1787e7e1g6116185001561a4d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/10/07 16:05 -0600, Grant Likely wrote:
> On 10/14/07, Domen Puncer <domen.puncer@telargo.com> wrote:
> > PHY part of the driver for mpc5200(b) ethernet.
>=20
> Assuming I understand correctly, this comment is not correct and this
> patch just adds an MDIO bus driver.  PHY drivers are in phylib and
> data transfer is setup via the core driver, correct?

Right.

>=20
> It is conceivable that the PHY is connected to an alternate MDIO bus,
> or the MDIO bus is used for a PHY connected to an external Ethernet
> controller.
>=20
> Speaking of which, is it possible to use this MDIO bus without the
> core FEC being initialized?

IIRC fec doesn't need any initialization for MDIO bus registers to work=
=2E

>=20
> > +static struct of_device_id fec_mdio_match[] =3D {
> > +       {
> > +               .type =3D "mdio",
> > +               .compatible =3D "mpc5200b-fec-phy",
>=20
> This is not a phy; it's an MDIO bus.  Also, shouldn't this be
> "mpc5200-..." instead of "mpc5200b-..."?

Didn't know if it's ok for mpc5200, guess it is?

>=20
> > +       },
> > +       {},
> > +};
> > +
> > +struct of_platform_driver mpc52xx_fec_mdio_driver =3D {
> > +       .name =3D "mpc5200b-fec-phy",
> > +       .probe =3D fec_mdio_probe,
> > +       .remove =3D fec_mdio_remove,
> > +       .match_table =3D fec_mdio_match,
>=20
> Inconsistent naming.  Please use the same prefix on all global/static
> symbols (ie. use "mpc52xx_mdio_" instead of the mix of
> "mpc52xx_fec_mdio_", "fec_mdio_", etc.)  I also thing that "fec_mdio_=
"
> is too generic because there are a number of different incompatible
> FEC devices.

OK.

>=20
> > +};
> > +
> > +/* let fec driver call it, since this has to be registered before =
it */
> > +EXPORT_SYMBOL_GPL(mpc52xx_fec_mdio_driver);
>=20
> Why not have a module_init()/module_exit() in this file?  I don't
> think the FEC driver calls this driver's functions directly anymore,
> and it's still dependent on the of_platform bus probe order anyway.

It was one way of making sure mdio driver is registered before fec.
(and of_platform bus probe order won't work for modules)
Nicer alternatives?

>=20
> As an added bonus, it makes your Makefile much simpler.
>=20
> > +
> > +
> > +MODULE_LICENSE("Dual BSD/GPL");
> > Index: linux.git/drivers/net/fec_mpc52xx/Makefile
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux.git.orig/drivers/net/fec_mpc52xx/Makefile
> > +++ linux.git/drivers/net/fec_mpc52xx/Makefile
> > @@ -1,2 +1,7 @@
> >  obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx.o
> >  fec_mpc52xx-objs :=3D fec.o
> > +
> > +ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
> > +       obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx_phy.o
> > +       fec_mpc52xx_phy-objs :=3D fec_phy.o
> > +endif
> > Index: linux.git/drivers/net/fec_mpc52xx/Kconfig
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux.git.orig/drivers/net/fec_mpc52xx/Kconfig
> > +++ linux.git/drivers/net/fec_mpc52xx/Kconfig
> > @@ -11,5 +11,18 @@ config FEC_MPC52xx
> >         ---help---
> >           This option enables support for the MPC5200's on-chip
> >           Fast Ethernet Controller
> > +         If compiled as module, it will be called 'fec_mpc52xx.ko'=
=2E
>=20
> Drop this line and make the help text the same format as the other et=
h
> drivers in drivers/net.

How exactly is it different now?
And most of them have the "Module will be called xxx" line.

>=20
> > +
> > +config FEC_MPC52xx_MDIO
> > +       bool "FEC MII PHY driver"
> > +       depends on FEC_MPC52xx
> > +       default y
> > +       ---help---
> > +         The MPC5200's FEC can connect to the Ethernet either with
> > +         an external MII PHY chip or 10 Mbps 7-wire interface
> > +         (Motorola? industry standard).
> > +         If your board uses an external PHY, enable this.
>=20
> Not strictly true.  This enables talking to a PHY using the internal
> MDIO controller.  PHY register access could just as easily be accesse=
d
> via an alternate interface.

Not just that is also selects which mode will it use.
If you don't enable this, fec will be set up as 7-wire
( 696                 rcntrl |=3D FEC_RCNTRL_MII_MODE;)


>=20
> > +         If not sure, enable.
> > +         If compiled as module, it will be called 'fec_mpc52xx_phy=
=2Eko'.
>=20
> Drop the module name comment.
>=20
> Cheers,
> g.
>=20
> --=20
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
> grant.likely@secretlab.ca
> (403) 399-0195

--=20
Domen Puncer | Research & Development
=2E....................................................................=
=2E.......................
Telargo d.o.o. | Zagreb=C5=A1ka cesta 20 | 2000 Maribor | Slovenia
=2E....................................................................=
=2E.......................
www.telargo.com
