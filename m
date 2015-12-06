From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: gigaset: freeing an active object
Date: Sun, 6 Dec 2015 16:29:32 +0100
Message-ID: <5664545C.90607@imap.cc>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
 <1448906497.3546.16.camel@tiscali.nl> <565F8341.7010704@hurleysoftware.com>
 <1449408690.2515.15.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="lIEKPO4N8qHf6F1CDt4VTEAOsMdTDe4Oc"
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Paul Bolle <pebolle@tiscali.nl>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:45233 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753117AbbLFP3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 10:29:46 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 7CBAB20796
	for <netdev@vger.kernel.org>; Sun,  6 Dec 2015 10:29:45 -0500 (EST)
In-Reply-To: <1449408690.2515.15.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lIEKPO4N8qHf6F1CDt4VTEAOsMdTDe4Oc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 06.12.2015 um 14:31 schrieb Paul Bolle:
> On wo, 2015-12-02 at 18:48 -0500, Peter Hurley wrote:
>> On 11/30/2015 01:01 PM, Paul Bolle wrote:

>>> --- a/drivers/isdn/gigaset/ser-gigaset.c
>>> +++ b/drivers/isdn/gigaset/ser-gigaset.c
>>> @@ -42,8 +42,9 @@ MODULE_PARM_DESC(cidmode, "stay in CID mode when
>>> idle");
>>> =20
>>>  static struct gigaset_driver *driver;
>>> =20
>>> +static struct platform_device pdev;
>>> +
>>>  struct ser_cardstate {
>>> -	struct platform_device	dev;
>>>  	struct tty_struct	*tty;
>>>  	atomic_t		refcnt;
>>>  	struct completion	dead_cmp;
>>> @@ -370,8 +371,8 @@ static void gigaset_freecshw(struct cardstate
>>> *cs)
>>>  	tasklet_kill(&cs->write_tasklet);
>>>  	if (!cs->hw.ser)
>>>  		return;
>>> -	dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
>>> -	platform_device_unregister(&cs->hw.ser->dev);
>>> +	dev_set_drvdata(&pdev.dev, NULL);
>>> +	platform_device_unregister(&pdev);
>>>  	kfree(cs->hw.ser);
>>
>> Tilman,
>>
>> Is there a 1:1 correspondence and lifetime for the embedded platform
>> device and it's containing memory?
>=20
> (Haven't heard from Tilman, so I'll give this a try.)

Sorry for that. Been busy.

> That containing memory is a struct ser_cardstate. And currently
> instances of struct _ser_cardstate are malloced and freed in routines
> that also call platform_device_register() and
> platform_device_unregister(). So yes, I think there's a 1:1
> correspondence.

Correct.

>> I ask because the typical approach for device teardown is to put the
>> kfree() in the release method;
>=20
> (Side note: the (struct device) release method of this driver=20
> -gigaset_device_release() - is actually a nop. It only frees device
> ->platform_data and platform_device->resource, but neither are actually=

> used: they remain NULL through their entire life.)

Yeah, that was just copied unthinkingly from driver/base/platform.c.

So the solution might be as simple as moving the kfree() call from
gigaset_freecshw() to gigaset_device_release(). Something like this:

--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -370,19 +370,18 @@ static void gigaset_freecshw(struct cardstate *cs)
        tasklet_kill(&cs->write_tasklet);
        if (!cs->hw.ser)
                return;
-       dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
        platform_device_unregister(&cs->hw.ser->dev);
-       kfree(cs->hw.ser);
-       cs->hw.ser =3D NULL;
 }

 static void gigaset_device_release(struct device *dev)
 {
-       struct platform_device *pdev =3D to_platform_device(dev);
+       struct cardstate *cs =3D dev_get_drvdata(dev);

-       /* adapted from platform_device_release() in
drivers/base/platform.c */
-       kfree(dev->platform_data);
-       kfree(pdev->resource);
+       if (!cs)
+               return;
+       dev_set_drvdata(dev, NULL);
+       kfree(cs->hw.ser);
+       cs->hw.ser =3D NULL;
 }

 /*

(Off the top of my hat, completely untested, don't even know if that
will compile.)

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--lIEKPO4N8qHf6F1CDt4VTEAOsMdTDe4Oc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWZFRoAAoJEFPuqx0v+F+qSz0H/j9Z1xrm/BEUlsh3Ijz1+6x7
gd8xpvi/5AlaKvYCWpVSXv9aKcVsEUGF42blNi10VoIqDjs+pKD5l//MhFHmaYyL
s88EDMn/jPGHTUsDDXA0e7wihrlFhiBBUk0akRoDeszOaoejIvaKupMIeDXeGhm4
LNHxbaDglFmlDW758d+RgVhWhgtv7KzYwu/GUugujLbe08FkPzKxkGbfZzPnd4vt
Bckzs9R6z+OTgP9/oth0QZIVrk91zDhIaCQa+6KaZpDp+BqLDkmKRD5w9XS4Gph8
3VTAzznEbkIq3Ndnvswr5aD52alhE3+aa4nlyHih38lFZ2WLe5N+LUwZS/AUB6c=
=i8cx
-----END PGP SIGNATURE-----

--lIEKPO4N8qHf6F1CDt4VTEAOsMdTDe4Oc--
