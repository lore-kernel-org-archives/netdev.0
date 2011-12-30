From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [BUG] SIOCSIFFLAGS returns -EIO on SMSC LAN911x
Date: Fri, 30 Dec 2011 11:56:13 +0100
Message-ID: <1325242573.13595.71.camel@deadeye>
References: <CAAwP0s37E=9J-KR397snkvq=idrc7nmELDJKrm33reeK84wJYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Gjr5DDY7tCbPk6kExwUj"
Cc: netdev@vger.kernel.org,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: Javier Martinez Canillas <martinez.javier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48072 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751423Ab1L3K4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 05:56:23 -0500
In-Reply-To: <CAAwP0s37E=9J-KR397snkvq=idrc7nmELDJKrm33reeK84wJYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Gjr5DDY7tCbPk6kExwUj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-12-30 at 10:44 +0100, Javier Martinez Canillas wrote:
> Hello,
>=20
> We have an issue with the SMSC LAN911x driver with today linux-2.6 [1]
> executing on an IGEPv2 [2] board using omap2plus_defconfig.
>=20
> When I try to bring up the network interface, the ioctl set interface
> flags command (SIOCSIFFLAGS)  fails returning -EIO:
[...]
> By doing a git bisect we found that this strange behavior exists when
> the Kconfig tristate compilation condition SMSC_PHY has the value yes
> to be compiled built-in:
>=20
> SMSC_PHY=3Dy
>=20
> If this config symbol has the value module (m) or not build at all,
> then bringing up the network interface never fails.

So the PHY driver is doing something that interferes with soft reset.

The data sheet for this part
<http://www.smsc.com/media/Downloads_Public/Data_Sheets/9221.pdf> says
that soft reset does not work if the PHY is in certain states.  Also, it
doesn't seem to specify a maximum time for soft reset to complete,
though it does say that PHY reset takes 100 us.

> Did anyone have the same problem?
>=20
> The problem is really strange to me, especially since we are sure that
> all the requirements to software reset the device are meet in both
> cases (with SMSC_PHY compiled built-in and without it)

I don't know about that.  smsc_phy_config_init() attempts to enable
power-saving on the PHY, but it is writing to a bit that is reserved
according to the data sheet for the combined MAC/PHY chip.  You might
want to try reverting:

commit 698244ace8b63896565022143ab19f141bc48993
Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date:   Wed Jan 6 20:35:14 2010 -0800

    phy: SMSC device Energy Detect power-down mode

Ben.

> [1]: HEAD on commit 371de6e4e0042adf4f9b54c414154f57414ddd37 drm/i915:
> Disable RC6 on Sandybridge by default
> [2]: https://wiki.linaro.org/Boards/Igep
>=20
> Thank you and best regards,
>=20

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-Gjr5DDY7tCbPk6kExwUj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATv2Yzee/yOyVhhEJAQrd2w/9HF8ygWV6xFPblXAjXyuRAyBB2WlvN/CW
0YhxrxqVVOyETxasysloyG4ndaoXjG53FRfOcXQCFriWKhBq7hW2DH1ZXPq8Hy1T
L0ZzrbnFmqzIDHCnX4iBUTH0zm+ipWWQfY3eFxy5i4S5A1qbkEOmYmd2UDbZcL8I
5wTBtGeW3H1zU+klfoyNSIVdJPAeKsni20ULuSP9T6lGOH2HUVfrEMRPVsJmoySt
+r9TyePQqJcHL4c/wVMy+2Wj4m7gC0UqqKafB4eHDbIw/pHe+pT1VR6sgn4rNUns
mWJe95PFlOSLyk8CqQ/OHGZ82mmY/KkvOF3VGtErazXdhaovDlpKn2KiQKDRwGeO
0cY61Gl1mlaomRLRTf8msvJyh4yb+0y1U+ZEzpK48aZHpIJ9ihNwMbZ4Avwv5hl7
n6CDdX9PYt/eXjSO00dltC7lCvjDws+eM1YUXf+DGl1QNEEvlcnIdi/rqJbKY0JG
2r9SOKDtZ9u6dbS/D4UkvF+cGVm2h1+sQIEgrZcIEmDillSDWMHg2lyVIkX8RXKU
RzklMZCGRRMuqKw6Xv61u5np7HHxNqUczad34rk0hPWnoq9iTl9Kzd70UqrVJKoL
kfahw4DIP6rowML0bkaLnf2hGJwGDGfcbV/6B7DQ0MYeETfdgL+3xNszJnqCFo++
rLvlVM73mbE=
=4c5f
-----END PGP SIGNATURE-----

--=-Gjr5DDY7tCbPk6kExwUj--
