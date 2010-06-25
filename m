From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next-2.6 2/2] 3c59x: Use fine-grained locks for MII
 and windowed register access
Date: Fri, 25 Jun 2010 01:45:59 +0100
Message-ID: <1277426759.26161.179.camel@localhost>
References: <1277337161.26161.14.camel@localhost>
	 <1277337341.26161.18.camel@localhost> <20100624120517.GI5570@secunet.com>
	 <1277384239.26161.162.camel@localhost>  <20100624140057.GJ5570@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-EZprAUzYlfpevL+69CPC"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chase Douglas <chase.douglas@canonical.com>,
	Arne Nordmark <nordmark@mech.kth.se>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54904 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753856Ab0FYAqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 20:46:06 -0400
In-Reply-To: <20100624140057.GJ5570@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EZprAUzYlfpevL+69CPC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-06-24 at 16:00 +0200, Steffen Klassert wrote:
> On Thu, Jun 24, 2010 at 01:57:19PM +0100, Ben Hutchings wrote:
> > >=20
> > > This adds a lot of calls to spin_lock_irqsave/spin_unlock_irqrestore =
to many
> > > places where this is not necessary at all. For example during device =
probe and
> > > device open, window_read/window_write are called multiple times, each=
 time
> > > disabling the interrupts. I'd suggest to have unlocked, locked and ir=
qsave
> > > versions of window_read/window_write and use them in appropriate plac=
es.
> >=20
> > So what?  These are not speed-critical.  The fast-path functions do
> > acquire the lock just once.
> >=20
>=20
> The point is that we should not disable the interrupts if we don't need t=
o
> do so. It is not speed critical for the 3c59x driver but disabling the
> interrupts should be avoided whenever possible. For example during device
> probe and device open we can't race against an interrupt handler because
> the device is not yet running.
>=20
> An example from vortex_probe1() is:
>=20
> for (i =3D 0; i < 6; i++)
> 	window_write8(vp, dev->dev_addr[i], 2, i);
>=20
> which expands to someting like:
>=20
> for (i =3D 0; i < 6; i++) {
> 	unsigned long flags;
> 	spin_lock_irqsave(&vp->window_lock, flags);
> 	window_set(vp, window);
> 	iowrite8(dev->dev_addr[i], vp->ioaddr  + i);
> 	spin_unlock_irqrestore(&vp->window_lock, flags);
> 	return ret;
> }
[...]

I still fail to see why this matters.

The sfc driver which I look after in my day job also uses
spin_lock_irqsave() for each CSR update, when this could be avoided in
the initialisation path.  None of the many customers using rt kernels
has ever complained about this.  It's just not an important issue.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-EZprAUzYlfpevL+69CPC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATCP8POe/yOyVhhEJAQLOeg//QIGES8dppigLfvwUUXG93AWh2UR/D3dA
CSyZAlNyzPxhnNxwkQK6hMEdVhXxsMt43JhYJWvW2KFt2w7E1020UWZmW6akSG5Q
cDLnSV4ayMPV7NXi2buw9oQBZKPBFVrmtrvFGOw00eEGe74Vfj3iZvE0hRGptWYR
XygoZjDRBqvxz4oohpWc4n6TdEGusLXBjb1qpg/HKzJa0+CMG4enajSmGkEmrw1m
9q0ErqZBQmuIvddkyUZllluc4rimTdAh9ewQAYNpiu5T0oIo5y+KqBBMbxMU6JEO
lj+gtM6NYgA4cnFiGL+mYPescwjBJm8Hh5w0waI+WetBABJ49IgSrvFBVZ6dULAe
RozdGsWA+V6MC6H/N8TRl1i5/0o4ea1HPbLF/Kpz+ZzRkTGqp5tLRAH9s5JQSY/2
6/9LuFnfwX5kNdgx7Abr01oFkY5Hn2erNTrjUSvo3gawGfUHNXiy8ZsYPMGhd8FE
3HBfpBRbnuCilA9JFdqct+rD47fiMZsuHc/2Dz6lNcNLNm221V4WeOJwGpF+nb0t
aRMD17Q49txiGrkN2dU6dgT+qEs7+PUd7kmA+/WcmtC9ZsM9yVWOhziDPFKk7LlF
RCksrfHO5PuK80bRV+GFmbU+LgdDHRp73CX1hURX6uGEjCpEywOawVrxEZTalm3E
vPKmxDXyx7M=
=GzdT
-----END PGP SIGNATURE-----

--=-EZprAUzYlfpevL+69CPC--
