From: John Paul Foster <jaypee@jaypee.org.uk>
Subject: mii ioctls and copy_to_user
Date: Thu, 06 Aug 2009 08:42:19 +0100
Message-ID: <1249544539.14839.199.camel@jp-pc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-fRLc9lZU0dbiXL768hN0"
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:49424 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbZHFHmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 03:42:22 -0400
Received: by ewy10 with SMTP id 10so573346ewy.37
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2009 00:42:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fRLc9lZU0dbiXL768hN0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hello all,

I've written a program that uses SIOCGMIIREG to query
various mii interfaces on my board. We have a switch chip
with multiple PHYs MACs and switch fabrics on the mii bus.

I'm using kernel 2.6.23

I set the ifru_data up like this in user space

#include <linux/mii.h> // The user side if.h
struct mii_ioctl_data mii;
mii.phy_addr=3Dmyphy;
mii.reg_num=3Dmyreg;
ifr.ifr_data=3D(__caddr_t)&mii;

as according to my libc (uclibc) <net/if.h> that is what ifr_data is a
pointer not a structure.

This doesn't work. I get garbage in the ifr_data used by the network
driver. (kernel space)

If I add a copy_from/to_user around the call to generic_mii_ioctl(),
then it works. My driver isn't in the main kernel it is the stmmac
driver at stlinux.org but the ioctl function is the same as many in main
tree, pcnet32_ioctl() for example.

mii-tool works without me patching the driver.

mii-tool sets the ioctl up like this.

#include "mii.h" // it's own mmi structure
struct mii_data *mii =3D (struct mii_data *)&ifr.ifr_data;
mii->reg_num =3D location;

in mii-tool ifr_data is a pointer not allocated storage so you shouldn't
do that. However ifr_data is part of a union and the biggest thing in it
is bigger than struct mii_data, so we are not going to crap on our
stack/heap. Not safe though if the structure of mii_data grows, or the
union changes size.

looking at <linux/if.h> (the kernel side if.h)
ifru_data is a=20
void __user *ifru_data;

i.e. it needs copy_to/from_user.

Are the drivers AND mii-tool wrong? I'm feeling like either I've
uncovered a long standing bug (in both mii ioctls and mmi-tool) or I'm
missing something.

Apologies for the verbose message but I'm trying to tell it
as thoroughly as I can.

Cross posted on the linux-net list but it looks a pretty dead list.

JP

--=-fRLc9lZU0dbiXL768hN0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkp6iVsACgkQnb3tnJfc2VB7DQCcD2g12o6vqQ2Lm410D9JnubeL
ZxQAniVxpjX0PZLY4QxLZUzsuhFTXDRK
=WxOn
-----END PGP SIGNATURE-----

--=-fRLc9lZU0dbiXL768hN0--

