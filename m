From: Alban Bedel <alban.bedel@avionic-design.de>
Subject: Re: [PATCH] usbnet: ax88179_178a: Add support for writing the
 EEPROM
Date: Wed, 24 Aug 2016 16:40:58 +0200
Message-ID: <20160824164058.6ec64a8e@avionic-0020>
References: <20160824135231.21782-1-alban.bedel@avionic-design.de>
        <1472049039.11480.10.camel@suse.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/plNYGCFSdTutFignJ/sblyd"; protocol="application/pgp-signature"
Cc: Alban Bedel <alban.bedel@avionic-design.de>,
        linux-usb@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472049039.11480.10.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/plNYGCFSdTutFignJ/sblyd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 24 Aug 2016 16:30:39 +0200
Oliver Neukum <oneukum@suse.com> wrote:

> On Wed, 2016-08-24 at 15:52 +0200, Alban Bedel wrote:
> > Implement the .set_eeprom callback to allow setting the MAC address
> > as well as a few other parameters. Note that the EEPROM must have a
> > correct PID/VID checksum set otherwise the SROM is used and reads
> > return the SROM content.
> >=20
> > Signed-off-by: Alban Bedel <alban.bedel@avionic-design.de>
> > ---
> >  drivers/net/usb/ax88179_178a.c | 57
> > ++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 57 insertions(+)
> >=20
> > diff --git a/drivers/net/usb/ax88179_178a.c
> > b/drivers/net/usb/ax88179_178a.c
> > index e6338c16081a..e6a986303dad 100644
> > --- a/drivers/net/usb/ax88179_178a.c
> > +++ b/drivers/net/usb/ax88179_178a.c
> > @@ -28,6 +28,7 @@
> > =20
> >  #define AX88179_PHY_ID                         0x03
> >  #define AX_EEPROM_LEN                          0x100
> > +#define AX_EEPROM_BLOCK                                0x40u
> >  #define AX88179_EEPROM_MAGIC                   0x17900b95
> >  #define AX_MCAST_FLTSIZE                       8
> >  #define AX_MAX_MCAST                           64
> > @@ -43,6 +44,7 @@
> >  #define AX_ACCESS_PHY                          0x02
> >  #define AX_ACCESS_EEPROM                       0x04
> >  #define AX_ACCESS_EFUS                         0x05
> > +#define AX_RELOAD_EEPROM                       0x06
> >  #define AX_PAUSE_WATERLVL_HIGH                 0x54
> >  #define AX_PAUSE_WATERLVL_LOW                  0x55
> > =20
> > @@ -620,6 +622,60 @@ ax88179_get_eeprom(struct net_device *net, struct
> > ethtool_eeprom *eeprom,
> >         return 0;
> >  }
> > =20
> > +static int
> > +ax88179_set_eeprom(struct net_device *net, struct ethtool_eeprom
> > *eeprom,
> > +                  u8 *data)
> > +{
> > +       struct usbnet *dev =3D netdev_priv(net);
> > +       unsigned int offset =3D eeprom->offset;
> > +       unsigned int len =3D eeprom->len;
> > +       int i, err =3D 0;
> > +       u8 *block;
> > +
> > +       /* The EEPROM data must be aligned on blocks of 64 bytes */
> > +       if ((offset % AX_EEPROM_BLOCK) || (len % AX_EEPROM_BLOCK)) {
> > +               offset =3D eeprom->offset / AX_EEPROM_BLOCK *
> > AX_EEPROM_BLOCK;
> > +               len =3D eeprom->len + eeprom->offset - offset;
> > +               len =3D DIV_ROUND_UP(len, AX_EEPROM_BLOCK) *
> > AX_EEPROM_BLOCK;
> > +
> > +               block =3D kmalloc(len, GFP_KERNEL);
> > +               if (!block)
> > +                       return -ENOMEM;
> > +
> > +               /* Copy the current data, we could skip some but KISS
> > */
> > +               for (i =3D 0; i < len; i +=3D AX_EEPROM_BLOCK) {
> > +                       err =3D __ax88179_read_cmd(dev,
> > AX_ACCESS_EEPROM,
> > +                                                (offset + i) >> 1,
> > +                                                AX_EEPROM_BLOCK >> 1,
> > +                                                AX_EEPROM_BLOCK,
> > +                                                &block[i], 0);
> > +                       if (err < 0) {
> > +                               kfree(block);
> > +                               return err;
> > +                       }
> > +               }
> > +               memcpy(block + eeprom->offset - offset, data,
> > eeprom->len);
> > +       } else {
> > +               block =3D data;
> > +       }
> > +
> > +       for (i =3D 0; err >=3D 0 && i < len; i +=3D AX_EEPROM_BLOCK) {
> > +               err =3D ax88179_write_cmd(dev, AX_ACCESS_EEPROM,
> > +                                       (offset + i) >> 1,
> > +                                       AX_EEPROM_BLOCK >> 1,
> > +                                       AX_EEPROM_BLOCK, &block[i]);
> > +       }
> > +
> > +       if (block !=3D data)
> > +               kfree(block); =20
>=20
> And if block =3D=3D dta, what frees the memory?

In this case this function didn't allocate any memory, so there is
nothing to free.

Alban=20


--Sig_/plNYGCFSdTutFignJ/sblyd
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXvbH6AAoJEHSUmkuduC28PxMP/jlldiklI0roFS9o+XQD093B
wyNzjIyAbnAjjOz1K/ptvi35JDl2omdhNC1Dpz2C7WQlcMHvHgZMLrvT2uwtTO91
fCXQ8h5eNxNmmLz8/4d3CiZsmrFBPiUo2EjNpLm8Uhw0JOp/Ofk67DOHZ8ffcXCR
N9zo3lY7QczIh2KRGSuh4J0uTIwEfuo/+ri1r28J41hz5BiG+Zjw/w1Ja+pjgOLi
SxrI2iszaeJG6p8RVdPlZ5gXmvsF3hFjg0pK4WR18EhLaahblJVqI6AZb5x05AU0
D+RKpiUWGWpwSTMCdL8v+zea2nHjqUImyk7nP+Ag1RtL2ay+gTSPikd0TAyiljGu
Hb+bkb2Q2bGGGwXFewkpV7DD9RU0wDvrS6EQpmDKm85qekRFje/An9WYFirqbatc
jEtTplRE3L3F0ywQOGQn77F+bGPZHO4e2tuZmPon0bto9bbDC1JDH1mXDpridGYx
1ksyP6oSWJ0dz6HVP8wBCXCRUu0ExUT8m/86LLlb1kS1x4G9HRC4uROywTRgIMzu
7ZHzKH+MKOREp9SRNi8xY7i1YECpdMpRgAhKQzgY8DairRH63l47Ju0wokXHFltc
X4ZTrkCYhg8XK3XXqV1xbSZCTxfLsQe0jy+3dirlb7KB9mRxhAERBMNvPky5yFFC
YwN/WUWdoWzl7iQpIq2H
=gE2o
-----END PGP SIGNATURE-----

--Sig_/plNYGCFSdTutFignJ/sblyd--
