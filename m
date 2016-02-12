From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] af_unix: Guard against other == sk in
 unix_dgram_sendmsg
Date: Fri, 12 Feb 2016 20:47:17 +0000
Message-ID: <1455310037.2801.61.camel@decadent.org.uk>
References: <56B4BF9D.9070609@pmhahn.de> <56BC90E7.7040007@pmhahn.de>
	 <87fuwzkzr5.fsf@doppelsaurus.mobileactivedefense.com>
	 <1455210224.2801.21.camel@decadent.org.uk>
	 <87r3gjjgbu.fsf@doppelsaurus.mobileactivedefense.com>
	 <87egcjcd5j.fsf@doppelsaurus.mobileactivedefense.com>
	 <87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
	 <56BDA3A8.6070807@pmhahn.de>
	 <8760xuvz5w.fsf@doppelsaurus.mobileactivedefense.com>
	 <1455306847.2801.45.camel@decadent.org.uk>
	 <87egchadk4.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-L6SQkHYDXgDXBFGiAYdE"
Cc: Philipp Hahn <pmhahn@pmhahn.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Karolin Seeger <kseeger@samba.org>,
	Jason Baron <jbaron@akamai.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arvid Requate <requate@univention.de>,
	Stefan Gohmann <gohmann@univention.de>, netdev@vger.kernel.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87egchadk4.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-L6SQkHYDXgDXBFGiAYdE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-12 at 20:17 +0000, Rainer Weikusat wrote:
> Ben Hutchings <ben@decadent.org.uk> writes:
> > On Fri, 2016-02-12 at 13:25 +0000, Rainer Weikusat wrote:
> > > Philipp Hahn <pmhahn@pmhahn.de> writes:
> > > > Hello Rainer,
> > > >=20
> > > > Am 11.02.2016 um 20:37 schrieb Rainer Weikusat:
> > > > > The unix_dgram_sendmsg routine use the following test
> > > > >=20
> > > > > if (unlikely(unix_peer(other) !=3D sk && unix_recvq_full(other)))=
 {
> > >=20
> > > [...]
> > >=20
> > > > > This isn't correct as the> specified address could have been boun=
d to
> > > > > the sending socket itself
> > >=20
> > > [...]
> > >=20
> > > > After applying that patch at least my machine running the samba tes=
t no
> > > > longer crashes.
> > >=20
> > > There's a possible gotcha in there: Send-to-self used to be limited b=
y
> > > the queue limit. But the rationale for that (IIRC) was that someone
> > > could keep using newly created sockets to queue ever more data to a
> > > single, unrelated receiver. I don't think this should apply when
> > > receiving and sending sockets are identical. But that's just my
> > > opinion. The other option would be to avoid the unix_state_double_loc=
k
> > > for sk =3D=3D other.
> >=20
> > Given that unix_state_double_lock() already handles sk =3D=3D other, I'=
m
> > not sure why you think it needs to be avoided.
>=20
> Because the whole complication of restarting the operation after locking
> both sk and other because other had to be unlocked before calling
> unix_state_double_lock is useless for this case: As other =3D=3D sk, ther=
e's
> no reason to drop the lock on it which guarantees that the result of all
> the earlier checks is still valid: If the -EAGAIN condition is not true,
> execution can just continue.

Well of course it's useless, but it's also harmless. =C2=A0If we really
wanted to optimise this we could also skip unlocking if other < sk.

> > > I'd be willing to change this accordingly if someone
> > > thinks the queue limit should apply to send-to-self.
> >=20
> > If we don't check the queue limit here, does anything else prevent the
> > queue growing to the point it's a DoS?
>=20
> The max_dgram_qlen limit exists specifically to prevent someone sending
> 'a lot' of messages to a socket unrelated to it by repeatedly creating a
> socket, sending as many messages as the send buffer size will allow,
> closing the socket, creating a new socket, ..., cf
>=20
> http://netdev.vger.kernel.narkive.com/tcZIFJeC/get-rid-of-proc-sys-net-un=
ix-max-dgram-qlen#post4
> (first copy I found)
>=20
> This 'attack' will obviously not work very well when sending and
> receiving socket are identical.

It looked to me like the queue length was the only limit here, as I was
looking in vain for a charge to the receiving socket's memory.
However, to answer my own question, AF_UNIX skbs are always charged to
the sending socket (which is the same thing in this case, but still
affects where the buffer limit is applied).

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.
--=-L6SQkHYDXgDXBFGiAYdE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVr5E1ee/yOyVhhEJAQrLiA//aiXK/oNCUFLUJPzJ2jvHlW1naHHCDwu1
cvYvVSUrHJ+HFJo+9mzWW6YTgyK+K7s3+O9DEknOX803s8qzHHjizzHB7qNRDagw
OArDZdLEnrp80scDtYS9J595+JT4fqGLunzVF77HaL50AA5QCiodg7OhCrgnSEW5
Y5L7bBmU87Hs32k/+K5kTr0M4KLiWrDYiSORVVU/+WihxLOtRJsLJi41R0hkq5nb
2xsA2L9nE/fvpZ+ydPIcBOyg+v3BwOu9ke9zaUiI1IHdGgpg62vTWtQ3QJRuBveA
UQuGjQ9EsSEGjjYopkp8shqzQIy3gJfi8rcWpbwt5txrHWzrWzpWwe+w2x/XvFyP
ITU0JDrTDLianHX8IIBJS0AToxqw72uHFDbiob6S6QVE7V3vq8b0/biNV9dmE6Ui
XtLDfQs9VpGT7fYJZ50lv39RtYQC9tVDq52guE0JtYwGLYywSCC3xeDRBjdYVrGx
OgUVuT7QFhEx1peYvqOWrfw6rYkmmHSGEFlW/VXpAIzBQtWdymBUF4b04bf0oFV0
Olj8T4Xi/tMPeIEtTylcwFN+VSOeP1k2xkaRiho09e6GCvOc4XQk6NQvLgJ2ANGe
aOZSBy4g1s2ZMLcWE7izr9ccrfxuW550nSJ2N6MlW1b/MXb0KKEiVYui5+Hi/meR
HXPAyceJzRU=
=NLlr
-----END PGP SIGNATURE-----

--=-L6SQkHYDXgDXBFGiAYdE--
