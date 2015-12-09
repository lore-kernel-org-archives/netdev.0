From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 2/3] ser_gigaset: fix deallocation of platform device
 structure
Date: Wed, 9 Dec 2015 12:10:29 +0100
Message-ID: <56680C25.1050704@imap.cc>
References: <cover.1449570042.git.tilman@imap.cc>
 <83c4ab9bbca911aad62343154eabfa1af077b021.1449570042.git.tilman@imap.cc>
 <1449616321.2384.36.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="P3556eJXgKHBDqXIqnglnhGLi0sRUB3Ex"
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449616321.2384.36.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--P3556eJXgKHBDqXIqnglnhGLi0sRUB3Ex
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 09.12.2015 um 00:12 schrieb Paul Bolle:

>> --- a/drivers/isdn/gigaset/ser-gigaset.c
>> +++ b/drivers/isdn/gigaset/ser-gigaset.c
>> @@ -370,19 +370,23 @@ static void gigaset_freecshw(struct cardstate
>> *cs)
>>  	tasklet_kill(&cs->write_tasklet);
>>  	if (!cs->hw.ser)
>>  		return;
>> -	dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
>>  	platform_device_unregister(&cs->hw.ser->dev);
>> -	kfree(cs->hw.ser);
>> -	cs->hw.ser =3D NULL;
>>  }
>> =20
>>  static void gigaset_device_release(struct device *dev)
>>  {
>>  	struct platform_device *pdev =3D to_platform_device(dev);
>> +	struct cardstate *cs =3D dev_get_drvdata(dev);
>> =20
>>  	/* adapted from platform_device_release() in
>> drivers/base/platform.c */
>>  	kfree(dev->platform_data);
>>  	kfree(pdev->resource);
>> +
>> +	if (!cs)
>> +		return;
>> +	dev_set_drvdata(dev, NULL);
>=20
> dev equals cs->hw.ser->dev.dev, doesn't it?

Correct.

> So what does setting
> cs->hw.ser->dev.dev.driver_data to NULL just before freeing it buy us?

We're freeing cs->hw.ser, not cs->hw.ser->dev.
Clearing the reference to cs from the device structure before freeing cs
guards against possible use-after-free.

>> +	kfree(cs->hw.ser);
>> +	cs->hw.ser =3D NULL;
>=20
> I might be missing something, but what does setting this to NULL buy us=

> here?

Just defensive programming. Guarding against possible use-after-free or
double-free.

>=20
> (I realize that I'm asking questions to code that isn't actually new bu=
t
> only moved around, but I think that's still an opportunity to have
> another look at that code.)

I'm a big fan of one change per patch. If we also want to modify the
moved code then that should be done in a separate patch. It makes
bisecting so much easier. Same reason why I separated out patch 3/3. And
btw same reason why I think patch 1/3 should go in as-is, as an obvious
fix to commit f34d7a5b, and any concerns about whether those tests are
useful should be addressed by a separate patch.

Regards,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--P3556eJXgKHBDqXIqnglnhGLi0sRUB3Ex
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWaAwlAAoJEFPuqx0v+F+q5usH+wREECI5vRps3fYNweB2TUvy
0QzzzFNVro/i7L3dyQazzaeZIx9Kbt00FG4Utp+luNX2skujdkYESHEBuOTirFRQ
JpW9rRG9qOVEVXlWinp6PRVVvOXiuw/Gvf4XvpbG9cJBDFS/3c+BuFPj/czpwCkh
Pdb8HvpVK6e/1TqeEhu7kIpnEMG0PvTHO9S/Tz1imw4UDfUNWWMeeKmSbf4hNX22
Xzt3qVSTTe9DHzCXzgFWNruVx0tMSwXcQ8Lz8ob89xR7JnCsWhWxIV2HkuO+5YcN
0hCbVTvCj0xLSQSw4crhH7nqDfl5HwYnS4TaPkr1xd/1V4X3Ljd2kwN3D8enqCk=
=WfHT
-----END PGP SIGNATURE-----

--P3556eJXgKHBDqXIqnglnhGLi0sRUB3Ex--
