From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/5][v2] phylib: Add generic 10G driver
Date: Thu, 28 Nov 2013 18:46:40 +0000
Message-ID: <32227243.rXJ6m6HlES@lenovo>
References: <1385459675-30364-1-git-send-email-shh.xie@gmail.com> <CAE5a0GjyY_62qM7VRqSoWe-9epf4vV5Dek=2nyMXbCc6mJSNjg@mail.gmail.com> <ED492CCEAF882048BC2237DE806547C915177468@039-SN2MPN1-013.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?6LCi6LCi6LCi?= <shh.xie@gmail.com>,
	David Miller <davem@davemloft.net>,
	"jg1.han@samsung.com" <jg1.han@samsung.com>,
	mugunthanvnm <mugunthanvnm@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Emilian Medve <Emilian.Medve@freescale.com>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>
To: Shaohui Xie <Shaohui.Xie@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ED492CCEAF882048BC2237DE806547C915177468@039-SN2MPN1-013.039d.mgd.msft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 28 novembre 2013, 09:59:53 Shaohui Xie a =C3=A9crit :

> Thank you for reviewing the patches!
> I thought I was suggested to use phy_drivers_register() and
> phy_drivers_unregister(), so I changed to use an array, seems I got y=
ou
> wrong. :)If using two separate genphy_driver instances as you mention=
ed
> above is OK, I=E2=80=99m OK to use them, the array size is a headache=
 to me, and
> may need to iterate the array when we unbind the driver.
> If we go for the
> array, I'd like to use some constant for the array indices. Right now=
 we
> only support a generic 10/100/1000 PHY and now a 10G phy, but one day=
 we
> might support a generic 40G or 100G PHY so the array indices won't be=
 as
> obvious as they are today.
> [S.H] if we go for the array, how about below codes:
>=20
> enum generic_phy {
>=20
>        INTERFACE_1G,
>=20
>        INTERFACE_10G,
>=20
>        INTERFACE_SUPP,
>=20
> };
>=20
> static struct phy_driver genphy_driver[ INTERFACE_SUPP];

I would prefer to use something named: GENPHY_DRV_1G, GENPHY_DRV_10G,=20
GENPHY_DRV_MAX, but yes  that's the idea.

>=20
> I=E2=80=99m OK with using array or two separate instances, anyone wou=
ld be accepted
> is good to me:)
> >  extern int mdio_bus_init(void);
> >  extern void mdio_bus_exit(void);
> >
> >
> >
> > @@ -539,7 +540,7 @@ static int phy_attach_direct(struct net_device =
*dev,
> > struct phy_device *phydev,
>=20
> >                         return -ENODEV;
> >                =20
> >                 }
> >
> >
> >
> > -               d->driver =3D &genphy_driver.driver;
> > +               d->driver =3D &genphy_driver[0].driver;
>=20
>=20
> This is where using a constant for an index would become useful.
> [S.H] Yes.  Should be something like:
> d->driver =3D &genphy_driver[INTERFACE_1G].driver;
> right?

Yes exactly

>=20
>=20
> >
> >
> >                 err =3D d->driver->probe(d);
> >                 if (err >=3D 0)
> >=20
> > @@ -620,7 +621,7 @@ void phy_detach(struct phy_device *phydev)
> >=20
> >          * was using the generic driver), we unbind the device
> >          * from the generic driver so that there's a chance a
> >          * real driver could be loaded */
> >=20
> > -       if (phydev->dev.driver =3D=3D &genphy_driver.driver)
> > +       if (phydev->dev.driver =3D=3D &genphy_driver[0].driver)
> >=20
> >                 device_release_driver(&phydev->dev);
> > =20
> >  }
>=20
> [S.H] This may also need to changed as:
>=20
>         for (i =3D 0; i < ARRAY_SIZE(genphy_driver); i++) {
>=20
>                 if (phydev->dev.driver =3D=3D &genphy_driver[i].drive=
r)
>=20
>                         device_release_driver(&phydev->dev);
>=20
>         }

Yes, indeed.

>=20
>=20
> >  EXPORT_SYMBOL(phy_detach);
> >=20
> > @@ -689,6 +690,12 @@ static int genphy_config_advert(struct phy_dev=
ice
> > *phydev)
>=20
> >         return changed;
> > =20
> >  }
> >
> >
> >
> > +int gen10g_config_advert(struct phy_device *dev)
> > +{
> > +       return 0;
> > +}
> > +EXPORT_SYMBOL(gen10g_config_advert);
> > +
> >=20
> >  /**
> > =20
> >   * genphy_setup_forced - configures/forces speed/duplex from @phyd=
ev
> >   * @phydev: target phy_device struct
> >=20
> > @@ -742,6 +749,11 @@ int genphy_restart_aneg(struct phy_device *phy=
dev)
> >=20
> >  }
> >  EXPORT_SYMBOL(genphy_restart_aneg);
> >
> >
> >
> > +int gen10g_restart_aneg(struct phy_device *phydev)
> > +{
> > +       return 0;
> > +}
> > +EXPORT_SYMBOL(gen10g_restart_aneg);
> >
> >
> >
> >  /**
> > =20
> >   * genphy_config_aneg - restart auto-negotiation or write BMCR
> >=20
> > @@ -784,6 +796,12 @@ int genphy_config_aneg(struct phy_device *phyd=
ev)
> >=20
> >  }
> >  EXPORT_SYMBOL(genphy_config_aneg);
> >
> >
> >
> > +int gen10g_config_aneg(struct phy_device *phydev)
> > +{
> > +       return 0;
> > +}
> > +EXPORT_SYMBOL(gen10g_config_aneg);
> > +
> >=20
> >  /**
> > =20
> >   * genphy_update_link - update link status in @phydev
> >   * @phydev: target phy_device struct
> >=20
> > @@ -913,6 +931,34 @@ int genphy_read_status(struct phy_device *phyd=
ev)
> >=20
> >  }
> >  EXPORT_SYMBOL(genphy_read_status);
> >
> >
> >
> > +int gen10g_read_status(struct phy_device *phydev)
> > +{
> > +       int devad, reg;
> > +       u32 mmd_mask =3D phydev->c45_ids.devices_in_package;
> > +
> > +       phydev->link =3D 1;
> > +
> > +       /* For now just lie and say it's 10G all the time */
> > +       phydev->speed =3D SPEED_10000;
> > +       phydev->duplex =3D DUPLEX_FULL;
> > +
> > +       for (devad =3D 0; mmd_mask; devad++, mmd_mask =3D mmd_mask =
>> 1) {
> > +               if (!(mmd_mask & 1))
> > +                       continue;
> > +
> > +               /* Read twice because link state is latched and a
> > +                * read moves the current state into the register
> > +                */
> > +               phy_read_mmd(phydev, devad, MDIO_STAT1);
> > +               reg =3D phy_read_mmd(phydev, devad, MDIO_STAT1);
> > +               if (reg < 0 || !(reg & MDIO_STAT1_LSTATUS))
> > +                       phydev->link =3D 0;
> > +       }
> > +
> > +       return 0;
> > +}
> > +EXPORT_SYMBOL(gen10g_read_status);
> > +
> >=20
> >  static int genphy_config_init(struct phy_device *phydev)
> >  {
> > =20
> >         int val;
> >=20
> > @@ -959,6 +1005,16 @@ static int genphy_config_init(struct phy_devi=
ce
> > *phydev)
>
> >
> >
> >         return 0;
> > =20
> >  }
> >=20
> > +
> > +static int gen10g_config_init(struct phy_device *phydev)
> > +{
> > +       /* Temporarily just say we support everything */
> > +       phydev->supported =3D SUPPORTED_10000baseT_Full;
> > +       phydev->advertising =3D SUPPORTED_10000baseT_Full;
> > +
> > +       return 0;
> > +}
> > +
> >=20
> >  int genphy_suspend(struct phy_device *phydev)
> >  {
> > =20
> >         int value;
> >=20
> > @@ -974,6 +1030,12 @@ int genphy_suspend(struct phy_device *phydev)
> >=20
> >  }
> >  EXPORT_SYMBOL(genphy_suspend);
> >
> >
> >
> > +int gen10g_suspend(struct phy_device *phydev)
> > +{
> > +       return 0;
> > +}
> > +EXPORT_SYMBOL(gen10g_suspend);
> > +
> >=20
> >  int genphy_resume(struct phy_device *phydev)
> >  {
> > =20
> >         int value;
> >=20
> > @@ -989,6 +1051,12 @@ int genphy_resume(struct phy_device *phydev)
> >=20
> >  }
> >  EXPORT_SYMBOL(genphy_resume);
> >
> >
> >
> > +int gen10g_resume(struct phy_device *phydev)
> > +{
> > +       return 0;
> > +}
> > +EXPORT_SYMBOL(gen10g_resume);
> > +
> >=20
> >  /**
> > =20
> >   * phy_probe - probe and init a PHY device
> >   * @dev: device to probe and init
> >=20
> > @@ -1116,7 +1184,8 @@ void phy_drivers_unregister(struct phy_driver=
 *drv,
> > int n)
>=20
> >  }
> >  EXPORT_SYMBOL(phy_drivers_unregister);
> >
> >
> >
> > -static struct phy_driver genphy_driver =3D {
> > +static struct phy_driver genphy_driver[] =3D {
> > +{
> >=20
> >         .phy_id         =3D 0xffffffff,
> >         .phy_id_mask    =3D 0xffffffff,
> >         .name           =3D "Generic PHY",
> >=20
> > @@ -1127,7 +1196,18 @@ static struct phy_driver genphy_driver =3D {
> >=20
> >         .suspend        =3D genphy_suspend,
> >         .resume         =3D genphy_resume,
> >         .driver         =3D {.owner=3D THIS_MODULE, },
> >=20
> > -};
> > +}, {
> > +       .phy_id         =3D 0xffffffff,
> > +       .phy_id_mask    =3D 0xffffffff,
> > +       .name           =3D "Generic 10G PHY",
> > +       .config_init    =3D gen10g_config_init,
> > +       .features       =3D 0,
> > +       .config_aneg    =3D gen10g_config_aneg,
> > +       .read_status    =3D gen10g_read_status,
> > +       .suspend        =3D gen10g_suspend,
> > +       .resume         =3D gen10g_resume,
> > +       .driver         =3D {.owner =3D THIS_MODULE, },
> > +} };
> >
> >
> >
> >  static int __init phy_init(void)
> >  {
> >=20
> > @@ -1137,7 +1217,8 @@ static int __init phy_init(void)
> >=20
> >         if (rc)
> >        =20
> >                 return rc;
> >
> >
> >
> > -       rc =3D phy_driver_register(&genphy_driver);
> > +       rc =3D phy_drivers_register(genphy_driver,
> > +                                 ARRAY_SIZE(genphy_driver));
> >=20
> >         if (rc)
> >        =20
> >                 mdio_bus_exit();
> >
> >
> >
> > @@ -1146,7 +1227,8 @@ static int __init phy_init(void)
> >
> >
> >
> >  static void __exit phy_exit(void)
> >  {
> >=20
> > -       phy_driver_unregister(&genphy_driver);
> > +       phy_drivers_unregister(genphy_driver,
> > +                              ARRAY_SIZE(genphy_driver));
> >=20
> >         mdio_bus_exit();
> > =20
> >  }
>=20
> [S.H] Using array could simplify the phy_init() and phy_exit(), this =
the
> advantage I see. But I may need to split the patch in two patches, on=
e to
> change the genphy_driver to array, the second to add the generic 10g
> driver. Is it acceptable?

Yes, I am okay with two patches doing that.

Thanks!
--=20
=46lorian
