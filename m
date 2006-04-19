From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 08/10] bcm43xx: sysfs code cleanup
Date: Thu, 20 Apr 2006 00:05:00 +0200
Message-ID: <200604200005.01087.mb@bu3sch.de>
References: <200604190405.k3J457Zj008004@shell0.pdx.osdl.net> <20060419215035.GA29122@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1432784.gvjDjWdQjW";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linville@tuxdriver.com, netdev@vger.kernel.org,
	mb@bu3sch.de, greg@kroah.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:29355
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751277AbWDSWBW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 18:01:22 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060419215035.GA29122@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1432784.gvjDjWdQjW
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 19 April 2006 23:50, you wrote:
> akpm@osdl.org <akpm@osdl.org> :
> >=20
> > From: Michael Buesch <mb@bu3sch.de>
> >=20
> > This cleans up the bcm43xx sysfs code and makes it compliant with the
> > unwritten sysfs rules (at least I hope so).
> >=20
> > Signed-off-by: Michael Buesch <mb@bu3sch.de>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Cc: Greg KH <greg@kroah.com>
> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> [...]
> > diff -puN drivers/net/wireless/bcm43xx/bcm43xx.h~bcm43xx-sysfs-code-cle=
anup drivers/net/wireless/bcm43xx/bcm43xx.h
> > --- devel/drivers/net/wireless/bcm43xx/bcm43xx.h~bcm43xx-sysfs-code-cle=
anup	2006-04-12 18:11:12.000000000 -0700
> > +++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-04-12 18:11:=
12.000000000 -0700
> [...]
> > @@ -772,6 +769,20 @@ struct bcm43xx_private * bcm43xx_priv(st
> >  	return ieee80211softmac_priv(dev);
> >  }
> > =20
> > +struct device;
> > +
> > +static inline
> > +struct bcm43xx_private * dev_to_bcm(struct device *dev)
> > +{
> > +	struct net_device *net_dev;
> > +	struct bcm43xx_private *bcm;
> > +
> > +	net_dev =3D dev_get_drvdata(dev);
> > +	bcm =3D bcm43xx_priv(net_dev);
> > +
> > +	return bcm;
> > +}
> > +
>=20
> It's used only in bcm43xx_sysfs.c. It could go there and avoid
> an extra forward declaration.

But it is a very generic helper, that does not have anything to do
with sysfs. It converts a struct device to struct bcm43xx_private.
bcm43xx_sysfs.h does only contain sysfs specific stuff for bcm.

> [...]
> > diff -puN drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c~bcm43xx-sysfs-co=
de-cleanup drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
> > --- devel/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c~bcm43xx-sysfs-co=
de-cleanup	2006-04-12 18:11:12.000000000 -0700
> > +++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-04-12 =
18:11:12.000000000 -0700
> > @@ -71,14 +71,46 @@ static int get_boolean(const char *buf,=20
> >  	return -EINVAL;
> >  }
> > =20
> > +static int sprom2hex(const u16 *sprom, char *buf, size_t buf_len)
> > +{
> > +	int i, pos =3D 0;
> > +
> > +	for (i =3D 0; i < BCM43xx_SPROM_SIZE; i++) {
> > +		pos +=3D snprintf(buf + pos, buf_len - pos - 1,
> > +				"%04X", swab16(sprom[i]) & 0xFFFF);
> > +	}
> > +	pos +=3D snprintf(buf + pos, buf_len - pos - 1, "\n");
> > +
> > +	return pos + 1;
> > +}
> > +
> > +static int hex2sprom(u16 *sprom, const char *dump, size_t len)
> > +{
> > +	char tmp[5] =3D { 0 };
> > +	int cnt =3D 0;
> > +	unsigned long parsed;
> > +
> > +	if (len < BCM43xx_SPROM_SIZE * sizeof(u16) * 2)
> > +		return -EINVAL;
> > +
> > +	while (cnt < BCM43xx_SPROM_SIZE) {
> > +		memcpy(tmp, dump, 4);
> > +		dump +=3D 4;
> > +		parsed =3D simple_strtoul(tmp, NULL, 16);
> > +		sprom[cnt++] =3D swab16((u16)parsed);
> > +	}
> > +
> > +	return 0;
> > +}
>=20
> "4" suggests that the code walks dump -> dump + 4*BCM43xx_SPROM_SIZE
>=20
> >  static ssize_t bcm43xx_attr_sprom_store(struct device *dev,
> >  					const char *buf, size_t count)
> [...]
> > -	for (i =3D 0; i < BCM43xx_SPROM_SIZE; i++) {
> > -		sprom[i] =3D buf[i * 2] & 0xFF;
> > -		sprom[i] |=3D ((u16)(buf[i * 2 + 1] & 0xFF)) << 8;
> > -	}
> > +	err =3D hex2sprom(sprom, buf, count);
>=20
> ... whereas here it only parses buf -> buf + 2*BCM43xx_SPROM_SIZE

the deleted code parses binary input. The
new code parses human readable hex input.

=2D-=20
Greetings Michael.

--nextPart1432784.gvjDjWdQjW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBERrQNlb09HEdWDKgRAtPoAJ969PML7TE1HgIuZ2fSciMeunUrpQCgueWz
HMHcPJ6xB1JH/Fo1CCZ8YXM=
=d+qg
-----END PGP SIGNATURE-----

--nextPart1432784.gvjDjWdQjW--
