From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] ehea: Add kdump support
Date: Mon, 26 Nov 2007 19:16:28 +1100
Message-ID: <1196064988.19855.15.camel@concordia>
References: <200711091433.51259.osstklei@de.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-yy5JIdwYhC9mcuqd40ej"
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Michael Neuling <mikey@neuling.org>,
	Paul Mackerras <paulus@samba.org>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42828 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999AbXKZIQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 03:16:30 -0500
In-Reply-To: <200711091433.51259.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-yy5JIdwYhC9mcuqd40ej
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-11-09 at 14:33 +0100, Thomas Klein wrote:
> To support ehea driver reloading in a kdump kernel the driver has to perf=
orm
> firmware handle deregistrations when the original kernel crashes. As ther=
e's
> currently no notifier chain for machine crashes this patch enables kdump =
support
> in the ehea driver by bending the ppc_md.machine_crash_shutdown hook to i=
ts own
> machine crash handler. The original machine_crash_shutdown() fn is called
> afterwards. This works fine as long as the ehea driver is the only one wh=
ich
> does so. Problems may occur if other drivers do the same and unload regul=
arly.
> This patch enables 2.6.24-rc2 to use kdump with ehea and only puts a very
> low risk on base kernel. In 2.6.24 we know ehea is the only user of this
> mechanism. The next step for 2.6.25 would be to add a proper notifier cha=
in.
> The full solution might be that register_reboot_notifier() provides sth
> like a SYS_CRASH action. Please apply.
>=20
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
>=20
> ---
>  drivers/net/ehea/ehea.h      |    2 +-
>  drivers/net/ehea/ehea_main.c |   28 ++++++++++++++++++++++++++++
>  2 files changed, 29 insertions(+), 1 deletions(-)
>=20

Hi Thomas,

I'm sorry, but this patch is all wrong IMHO.

For kdump we have to assume that the kernel is fundamentally broken,
we've panicked, so something bad has happened - every line of kernel
code that is run decreases the chance that we'll successfully make it
into the kdump kernel.

So just calling unregister_driver() is no good, that's going to call
lots of code, try to take lots of locks, rely on lots of data structures
being uncorrupted etc. etc.

And the hijacking of machine_crash_shutdown() is IMO not an acceptable
solution, as you say it only works if EHEA is the only driver to do it.
And as soon as EHEA does it other drivers will want to do it.

What we need is the _minimal_ set of actions that can happen to make
EHEA work in the kdump kernel.

Solutions that might be better:

 a) if there are a finite number of handles and we can predict their=20
    values, just delete them all in the kdump kernel before the driver
    loads.
 b) if there are a small & finite number of handles, save their values=20
    in a device tree property and have the kdump kernel read them and=20
    delete them before the driver loads.
 c) if neither of those work, provide a minimal routine that _only_
    deletes the handles in the crashed kernel.
 d) <something else>

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-yy5JIdwYhC9mcuqd40ej
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHSoDcdSjSd0sB4dIRAmrHAJ44uAhPPnPmXxqcbiZBmDYoMIWxJgCgr5fL
qTu8td4i0rgrOuOESNq2MkA=
=cH8k
-----END PGP SIGNATURE-----

--=-yy5JIdwYhC9mcuqd40ej--

