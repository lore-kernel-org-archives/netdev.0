From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: gigaset: freeing an active object
Date: Mon, 7 Dec 2015 10:27:03 +0100
Message-ID: <566550E7.80801@imap.cc>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
 <1448906497.3546.16.camel@tiscali.nl> <565F8341.7010704@hurleysoftware.com>
 <1449408690.2515.15.camel@tiscali.nl> <5664545C.90607@imap.cc>
 <1449432742.2515.20.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="OpGCrtUvXV50QTd7W3AWj3WurUhMUAAJe"
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Paul Bolle <pebolle@tiscali.nl>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449432742.2515.20.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OpGCrtUvXV50QTd7W3AWj3WurUhMUAAJe
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 06.12.2015 um 21:12 schrieb Paul Bolle:
> On zo, 2015-12-06 at 16:29 +0100, Tilman Schmidt wrote:
>> So the solution might be as simple as moving the kfree() call from
>> gigaset_freecshw() to gigaset_device_release(). Something like this:
>>
>> --- a/drivers/isdn/gigaset/ser-gigaset.c
>> +++ b/drivers/isdn/gigaset/ser-gigaset.c
>> @@ -370,19 +370,18 @@ static void gigaset_freecshw(struct cardstate
>> *cs)
>>         tasklet_kill(&cs->write_tasklet);
>>         if (!cs->hw.ser)
>>                 return;
>> -       dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
>>         platform_device_unregister(&cs->hw.ser->dev);
>> -       kfree(cs->hw.ser);
>> -       cs->hw.ser =3D NULL;
>>  }
>>
>>  static void gigaset_device_release(struct device *dev)
>>  {
>> -       struct platform_device *pdev =3D to_platform_device(dev);
>> +       struct cardstate *cs =3D dev_get_drvdata(dev);
>>
>> -       /* adapted from platform_device_release() in drivers/base/plat=
form.c */
>> -       kfree(dev->platform_data);
>> -       kfree(pdev->resource);
>> +       if (!cs)
>> +               return;
>> +       dev_set_drvdata(dev, NULL);
>> +       kfree(cs->hw.ser);
>> +       cs->hw.ser =3D NULL;
>>  }
>=20
> This solution assumes that the struct platform_device is moved out of
> the struct ser_cardstate, doesn't it? In other words, this is something=

> to do on top of my (draft) patch.

No, that wasn't my intention. I thought of that solution as an
alternative, not an increment to your patch.

> Otherwise we'd still be freeing memory
> managed through reference counting.

Now I#m confused. I thought by following Peter's suggestion to put the
kfree() in the release method we'd avoid just that.

Regards,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--OpGCrtUvXV50QTd7W3AWj3WurUhMUAAJe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWZVD0AAoJEFPuqx0v+F+q1MYH/3mrcgm5tuDM9co1q79tjbmK
X5K91JW+DScmPIvSri7JtNtTCyoQmLZkZPl/4d+vtULp50YrHslnHUXX/lZM8hfd
dy2wnmo67UPExIO9R+BI60R90cNcAoigtK9Duuq3b4gxsTIXd9Ac9RCxpXWM7yMo
7BzoVFuPhbwLskHAZYfmz2obq+OWvg72UAgwltj0bOQy9OA2f9Bq2pfrxs9lLvx1
SwT4XgArIEIuSVaglisQ09+9jFQ93g6QXSeWbcBiURu+8ZmAJKK3yD5vMbsorVQD
ZWxodML8+rE5zGbuRICJsjgrMKobcanyd5PBoxyYqHehrnct52/P52qHYfpKwic=
=tYj3
-----END PGP SIGNATURE-----

--OpGCrtUvXV50QTd7W3AWj3WurUhMUAAJe--
