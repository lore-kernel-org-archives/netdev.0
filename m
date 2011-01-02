From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: eepro testing positive EBUSY return by
 request_irq()?
Date: Sun, 02 Jan 2011 19:51:32 +0000
Message-ID: <1293997892.3167.53.camel@localhost>
References: <4D1DECFC.8020701@gmail.com>
	 <1293809262.2870.45.camel@localhost>  <4D209127.5080505@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-okZWYZPtMlXy5ZLi623H"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: roel kluin <roel.kluin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D209127.5080505@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-okZWYZPtMlXy5ZLi623H
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-01-02 at 15:52 +0100, roel kluin wrote:
> >> -		if (request_irq (*irqp, NULL, IRQF_SHARED, "bogus", dev) !=3D EBUSY=
) {
> >> +		if (request_irq (*irqp, NULL, IRQF_SHARED, "bogus", dev) !=3D -EBUS=
Y) {
>=20
> > This condition is completely bogus - request_irq() with a NULL handler
> > now returns -EINVAL before even checking whether the IRQ is in use.  Th=
e
> > code should be fixed along the lines of what I did for 3c503 in commit
> > b0cf4dfb7cd21556efd9a6a67edcba0840b4d98d.
> >=20
> > The e2100 and hp net drivers have the same bug.
> >=20
> > Ben.
>=20
> I've made an attempt to fix the mentioned issues, but I'm not sure it is =
complete.
> The commit made some other changes as well which didn't seem appropriate =
here to me.

They are absolutely necessary.

In the bad old days before plug-and-play, some expansion cards would
have jumpers to configure the IRQ number and no software mechanism to
set or query it.  Users were expected to specify the IRQ to the driver
explicitly.  probe_irq_{on,off}() allow drivers to avoid this by
triggering an IRQ and checking which was received.  That assumes that
there are no IRQ conflicts, and it only works reliably in a quiescent
system.

These drivers have been abusing request_irq(), probe_irq_{on,off}() to
do resource allocation for hardware that *does* have a software
mechanism to set the IRQ number.  This has become less reliable as
driver loading has been made more dynamic, and is now broken completely
due to the change in request_irq().  I believe the correct way to do
this allocation is what I did in 3c503.  Possibly it's worth adding a
generic function.

> And I didn't compile or run test this.

I compiled but didn't have hardware to test.

> As a side note, in the function changed by the commit you mentioned, el2_=
open(), it
> appears that in current git, boolean `seen' cannot ever become true, can =
it?
[...]

The IRQ handler data is set to &seen and el2_probe_interrupt() uses that
pointer to set it.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-okZWYZPtMlXy5ZLi623H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATSDXP+e/yOyVhhEJAQIL6Q//Y5oC8FGsBf0i5K/guIIMG5KupgziTDxe
ETP5rQLLGKS/N66nbSHQPCVMzGdj8U/4hHjDQaVBEpyD4XD4wea3kVPMzzoV84Mc
R/52TwXXtDqI0C1v1AyBID/1swRTCzhFeb+EnLyBThTRIfM4NRZhQq6rQuS3T9xM
pawLhG+0w+M31PPS198gKEQ7Nq40hnpzo8wZ4powzGKVciTzakmstY81GF37rFjh
p0QLiNV5yR8mzjA7bx9cyjxxaq8ZRWIr1eNNYJBcldbVjgbMXYkimucmx1MXagzW
639UzKuoECtuLJOj1EzwOWnoOK4GhjjDp0W5uLJIZiadZy18YppVEKFwQd+AOj3y
dqF4DFozsL5l/8zHLl2PZlOpUB3x02QzxoDOwIpJ6RKsaPnymkfdv8W4mmZp8+FX
P2e9I4ZxQd1m/qDhBf2XZ6+Zy6azexoHVeWTzDbmOu/a4yv0/zLVt+FVKUEq9rBh
4zwbYc38tdzBuZTi6StyRHowSvfGM1wCfDoAITI1QXoMrljUtyunXjT9nDZ1b6YK
aF5UkQM87MFVURdDG5GSx9UJbpklhCPcDE33SAXTK8F0q+Bmnm2gLv5rBRn/G87S
sCMeSADzDElV4FB9xlQskOu7sIovr8OAIEYARvg+9PxgzNPAxX9zuARiXcvggyc3
/HKbCa7mqH8=
=cJt2
-----END PGP SIGNATURE-----

--=-okZWYZPtMlXy5ZLi623H--
